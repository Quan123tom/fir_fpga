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
* To combat the high 8-cc latency a relatively high Kd was used making the system responsive to changes and acting as a lead compensator
* Response Characteristics 
