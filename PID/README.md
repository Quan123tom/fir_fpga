# Pipelined PID Controller
## Overview
This directory contains a standalone PID controller module implemented in SystemVerilog. The controller was implemented using a 3-stage pipeline 
to maximize clock frequency.
## Architecture
The controller implements the discrete-time PID algorithm in its parallel form. To handle high-speed feedback requirements (e.g., LLRF field regulation), the math is split across three clock cycles:
1. Stage 1: Error and derivative calculation.
2. Stage 2: Parallel multiplications of the gains(Kp, Ki, Kd)
3. Stage 3: Summation of the terms and saturation check
## Key feautres
* Synchronous Reset: Ensures that the integral accumulator can be cleared
* Anti - Windup logic: It implements conditional integration
* Fully - pipelined: All arithmetic operations are registered. This allows the design to operate on high frequencies on Xilinx Artix-7 or Zynq-7000 series FPGAs.

