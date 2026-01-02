# FPGA-Based Closed-Loop Control System (FIR + PID)
## Overview
This folder contais a modularized digital control system implemented in SystemVerilog. The architecture integrates a 5 stage pipelined
FIR Moving Average Filter with a 3 stage pipelined PID controller. For the interconnection between those 2 modules the AXI4-Stream protocol
was used. The specific design is optimised for high speed instumentation applications
## System Architecture
The system is designed to process sensor data in real-time while maintaining high clock frequencies (100 MHz+).
### Components:
* FIR Filter(8 tap moving average)
* PID controller(implements control coupled with Anti-Windup to prevent accumulator saturation.)
* AXI4-Stream interconnect(ensures compatability with heterogeneous SoC environments)
## Engineering Challenges : Stability + Latency
The primary challenge faced during the development of this product was the managing of the total 8-clock cycle delay that was introduced
by the FIR filter and the controller.
### Stability Analysis
* To combat the high 8-cc latency a relatively high Kd was used making the system responsive to changes and acting as a lead compensator.
* The system was fined tuned to achieve a critically damped step response.
* The current version of this project was implemented with integer level prescision. Future improvements may include fixed point scaling.
## Verification of the design via closed loop TB:
The system was verified using a SystemVerilog testbench that simulates a physical "Plant" (integrator model).
* Noise injection: andom Gaussian noise was added to the plant feedback to validate the FIR filter's efficacy in preventing "D-term jitter."
* Results: The simulation confirms that the controller successfully stabilizes the plant at the desired setpoint despite the 80ns transport delay (at 100MHz).
** Project Visuals:
  ![The block design of my project](../docs/Screenshot 2026-01-02 175156.png)
  ![The output that is produced when applying a step function of amplitude 1000](../docs/pid_whole_system.png)
