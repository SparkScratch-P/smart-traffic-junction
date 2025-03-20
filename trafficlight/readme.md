## Features of the Traffic Light System Resembling a Real-World Traffic Light at a Crossing

### **1. Core Traffic Light Functionality**
- **Main and Side Roads:**
  - The system manages two sets of traffic lights: one for the main road and one for the side road.
  - Each road is equipped with three lights:
    - **Red:** Signals vehicles to stop.
    - **Green:** Allows vehicles to proceed.
    - **Yellow:** Warns vehicles to prepare to stop as the green light transitions to red.
  - Lights cycle through a predefined pattern to regulate traffic alternately between the main road and the side road.

---

### **2. Predefined Light Cycle Timing**
- Each phase in the light cycle has customizable durations, resembling standard traffic lights:
  - **Main Road Green:** 15 seconds (default).
  - **Main Road Yellow:** 3 seconds.
  - **Side Road Green:** 10 seconds.
  - **Side Road Yellow:** 3 seconds.
- These timings can be adjusted based on the expected traffic density of each road.

---

### **3. Pedestrian Crossing Functionality**
- **Pedestrian Request Button:**
  - A button is installed for pedestrians to signal a crossing request.
  - When pressed, the system pauses the regular traffic cycle.
  - All lights (main and side roads) turn **red**, ensuring vehicles stop completely.
- **Pedestrian Signal:**
  - A dedicated pedestrian signal (LED) is activated, indicating that pedestrians can safely cross the road.
- **Automatic Return:**
  - After the crossing time (5 seconds by default), the pedestrian signal turns off, and the system resumes its regular light cycle.

---

### **4. Emergency Override**
- **Priority Traffic Management:**
  - The system includes an emergency override feature, controlled remotely via the Blynk platform.
  - Two emergency modes are available:
    - **Emergency Override for Main Road (V1 = 1):** Forces the main road to green while the side road remains red.
    - **Emergency Override for Side Road (V1 = 2):** Forces the side road to green while the main road remains red.
  - This feature ensures immediate priority for emergency vehicles (like ambulances, fire trucks, or police) traveling on either road.
- **Interrupt Capability:**
  - The emergency mode takes precedence over all other operations, including pedestrian crossings and normal cycles.

---

### **5. State Machine Architecture**
- **Efficient State Transitions:**
  - The system uses a state machine to manage the light cycles. States include:
    - **Main Road Green → Main Road Yellow → Side Road Green → Side Road Yellow → Pedestrian Crossing.**
  - Each state transitions smoothly based on a non-blocking timer (`millis()`), avoiding delays in the control loop.
- **Responsiveness:**
  - The state machine ensures the system can quickly adapt to changing conditions (e.g., emergency signals or pedestrian requests).

---

### **6. Real-Time, Non-Blocking Timing**
- **No `delay()`:**
  - Unlike basic programs that use blocking delays, this system leverages `millis()` for timekeeping. This ensures:
    - The system remains responsive to emergency overrides or pedestrian requests.
    - Lights transition smoothly without freezing the entire system during timing intervals.

---

### **7. Hardware Integration**
- **Traffic Light LEDs:**
  - Each road has three LEDs to simulate real-world traffic lights:
    - **Red, Yellow, and Green** LEDs for both the main and side roads.
- **Pedestrian Features:**
  - **Button:** A physical button is used for pedestrians to request a crossing.
  - **Signal LED:** Indicates when it's safe for pedestrians to cross.
- **Remote Control:**
  - The system interfaces with the Blynk platform, allowing remote control for emergency management.

---

### **8. Safety Mechanisms**
- **All-Red State During Pedestrian Crossing:**
  - Ensures no vehicles move while pedestrians are crossing.
- **Emergency Handling:**
  - Overrides normal light cycles to prioritize safety during emergencies.
- **Fail-Safe Transitions:**
  - Lights transition via yellow phases to warn drivers of impending changes, minimizing sudden stops or starts.

---

### **9. Scalability**
- **Dynamic Adjustments:**
  - The timing durations for each light can be easily modified to match traffic conditions.
- **Sensor Integration Potential:**
  - The system can be expanded to incorporate traffic density sensors or vehicle detection systems, allowing for adaptive control.

---

This system effectively emulates a modern, real-world traffic light at an intersection crossing. Its advanced features prioritize safety, efficiency, and adaptability, ensuring smooth traffic flow and pedestrian convenience.
