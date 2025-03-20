#include <WiFi.h>
#include <BlynkSimpleEsp32.h>

// WiFi and Blynk credentials
char auth[] = "YourAuthToken";
char ssid[] = "YourNetworkName";
char pass[] = "YourPassword";

// Traffic light pin definitions
#define TRAFFIC_MAIN_RED_PIN     13
#define TRAFFIC_MAIN_GREEN_PIN   12
#define TRAFFIC_MAIN_YELLOW_PIN  14

#define TRAFFIC_SIDE_RED_PIN     27
#define TRAFFIC_SIDE_GREEN_PIN   26
#define TRAFFIC_SIDE_YELLOW_PIN  25

// Pedestrian system pins
#define PEDESTRIAN_BUTTON_PIN    33  // Active LOW
#define PEDESTRIAN_SIGNAL_PIN    32

// Timing constants (in milliseconds)
const unsigned long MAIN_GREEN_TIME   = 15000; // 15 seconds
const unsigned long SIDE_GREEN_TIME   = 10000; // 10 seconds
const unsigned long YELLOW_TIME       = 3000;  // 3 seconds
const unsigned long PEDESTRIAN_TIME   = 5000;  // 5 seconds

// State machine definition for the traffic light cycle
enum TrafficState {
  STATE_MAIN_GREEN,
  STATE_MAIN_YELLOW,
  STATE_SIDE_GREEN,
  STATE_SIDE_YELLOW,
  STATE_PEDESTRIAN
};
TrafficState currentState = STATE_MAIN_GREEN;
unsigned long stateStartTime = 0;

// Emergency override variable (set via Blynk V1)
// 0 = no emergency, 1 = emergency override for MAIN road,
// 2 = emergency override for SIDE road.
int emergencyOverride = 0;

// Pedestrian crossing request flag
bool pedestrianRequest = false;

// Blynk timer for periodic state updates
BlynkTimer timer;

void setup() {
  // Configure traffic light pins
  pinMode(TRAFFIC_MAIN_RED_PIN, OUTPUT);
  pinMode(TRAFFIC_MAIN_GREEN_PIN, OUTPUT);
  pinMode(TRAFFIC_MAIN_YELLOW_PIN, OUTPUT);

  pinMode(TRAFFIC_SIDE_RED_PIN, OUTPUT);
  pinMode(TRAFFIC_SIDE_GREEN_PIN, OUTPUT);
  pinMode(TRAFFIC_SIDE_YELLOW_PIN, OUTPUT);

  // Configure pedestrian pins
  pinMode(PEDESTRIAN_BUTTON_PIN, INPUT_PULLUP);
  pinMode(PEDESTRIAN_SIGNAL_PIN, OUTPUT);

  // Start Blynk connection
  Blynk.begin(auth, ssid, pass);

  // Initialize state timer and current state
  stateStartTime = millis();
  currentState = STATE_MAIN_GREEN;

  // Set a short interval (100 ms) to update the state machine
  timer.setInterval(100, updateTrafficLights);
}

void loop() {
  Blynk.run();
  timer.run();

  // Check the pedestrian button (active LOW)
  if (digitalRead(PEDESTRIAN_BUTTON_PIN) == LOW) {
    pedestrianRequest = true;
  }
}

// Blynk virtual pin handler for emergency override (e.g., V1)
BLYNK_WRITE(V1) {
  emergencyOverride = param.asInt();
}

// The main non-blocking state machine update function
void updateTrafficLights() {
  // Emergency override always takes priority.
  if (emergencyOverride != 0) {
    handleEmergency();
    return;
  }

  unsigned long currentTime = millis();

  switch(currentState) {

    case STATE_MAIN_GREEN:
      // MAIN GREEN: Main road green, side road red.
      setMainGreen();
      if (currentTime - stateStartTime >= MAIN_GREEN_TIME) {
        currentState = STATE_MAIN_YELLOW;
        stateStartTime = currentTime;
      }
      break;

    case STATE_MAIN_YELLOW:
      // MAIN YELLOW: Main road yellow, side road red.
      setMainYellow();
      if (currentTime - stateStartTime >= YELLOW_TIME) {
        // If pedestrian crossing is requested, transition accordingly.
        if (pedestrianRequest) {
          currentState = STATE_PEDESTRIAN;
        } else {
          currentState = STATE_SIDE_GREEN;
        }
        stateStartTime = currentTime;
      }
      break;

    case STATE_SIDE_GREEN:
      // SIDE GREEN: Side road green, main road red.
      setSideGreen();
      if (currentTime - stateStartTime >= SIDE_GREEN_TIME) {
        currentState = STATE_SIDE_YELLOW;
        stateStartTime = currentTime;
      }
      break;

    case STATE_SIDE_YELLOW:
      // SIDE YELLOW: Side road yellow, main road red.
      setSideYellow();
      if (currentTime - stateStartTime >= YELLOW_TIME) {
        // Check for pending pedestrian crossing.
        if (pedestrianRequest) {
          currentState = STATE_PEDESTRIAN;
        } else {
          currentState = STATE_MAIN_GREEN;
        }
        stateStartTime = currentTime;
      }
      break;

    case STATE_PEDESTRIAN:
      // PEDESTRIAN: Both roads red, pedestrian signal active.
      setAllRed();
      digitalWrite(PEDESTRIAN_SIGNAL_PIN, HIGH);
      if (currentTime - stateStartTime >= PEDESTRIAN_TIME) {
        // End pedestrian crossing and clear the request.
        pedestrianRequest = false;
        digitalWrite(PEDESTRIAN_SIGNAL_PIN, LOW);
        currentState = STATE_MAIN_GREEN; // Resume standard cycle.
        stateStartTime = currentTime;
      }
      break;
  }
}

// -- Light-setting Helper Functions --

// Main road green state: Main green, side red.
void setMainGreen() {
  digitalWrite(TRAFFIC_MAIN_GREEN_PIN, HIGH);
  digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, LOW);
  digitalWrite(TRAFFIC_MAIN_RED_PIN, LOW);

  digitalWrite(TRAFFIC_SIDE_RED_PIN, HIGH);
  digitalWrite(TRAFFIC_SIDE_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, LOW);
}

// Main road yellow state: Main yellow, side stays red.
void setMainYellow() {
  digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, HIGH);
  digitalWrite(TRAFFIC_MAIN_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_MAIN_RED_PIN, LOW);

  digitalWrite(TRAFFIC_SIDE_RED_PIN, HIGH);
  digitalWrite(TRAFFIC_SIDE_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, LOW);
}

// Side road green state: Side green, main red.
void setSideGreen() {
  digitalWrite(TRAFFIC_SIDE_GREEN_PIN, HIGH);
  digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, LOW);
  digitalWrite(TRAFFIC_SIDE_RED_PIN, LOW);

  digitalWrite(TRAFFIC_MAIN_RED_PIN, HIGH);
  digitalWrite(TRAFFIC_MAIN_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, LOW);
}

// Side road yellow state: Side yellow, main remains red.
void setSideYellow() {
  digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, HIGH);
  digitalWrite(TRAFFIC_SIDE_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_SIDE_RED_PIN, LOW);

  digitalWrite(TRAFFIC_MAIN_RED_PIN, HIGH);
  digitalWrite(TRAFFIC_MAIN_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, LOW);
}

// All red state used during pedestrian crossing.
void setAllRed() {
  digitalWrite(TRAFFIC_MAIN_RED_PIN, HIGH);
  digitalWrite(TRAFFIC_MAIN_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, LOW);

  digitalWrite(TRAFFIC_SIDE_RED_PIN, HIGH);
  digitalWrite(TRAFFIC_SIDE_GREEN_PIN, LOW);
  digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, LOW);
}

// -- Emergency Override Handler --
// Immediately override normal states if an emergency signal is active.
void handleEmergency() {
  // Emergency Override for Main Road (vEmergency = 1):  
  // Main road forced to green, side remains red.
  if (emergencyOverride == 1) {
    digitalWrite(TRAFFIC_MAIN_GREEN_PIN, HIGH);
    digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, LOW);
    digitalWrite(TRAFFIC_MAIN_RED_PIN, LOW);
    
    digitalWrite(TRAFFIC_SIDE_RED_PIN, HIGH);
    digitalWrite(TRAFFIC_SIDE_GREEN_PIN, LOW);
    digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, LOW);
  }
  // Emergency Override for Side Road (vEmergency = 2):  
  // Side road forced to green, main remains red.
  else if (emergencyOverride == 2) {
    digitalWrite(TRAFFIC_SIDE_GREEN_PIN, HIGH);
    digitalWrite(TRAFFIC_SIDE_YELLOW_PIN, LOW);
    digitalWrite(TRAFFIC_SIDE_RED_PIN, LOW);
    
    digitalWrite(TRAFFIC_MAIN_RED_PIN, HIGH);
    digitalWrite(TRAFFIC_MAIN_GREEN_PIN, LOW);
    digitalWrite(TRAFFIC_MAIN_YELLOW_PIN, LOW);
  }
  // (If emergency changes to 0 externally, the system resumes the normal cycle.)
}
