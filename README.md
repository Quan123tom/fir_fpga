# fir_fpga
This project implements a pipelined FIR filter written in SystemVerilog.
The filter that is written here processes one input sample per clock cycle after pipeline fill and is suitable for real- time digital conditioning applications such as data acquisition systems or RF signal preprocessing.
Architecture
*Input: Streaming signed fixed - point samples
*Filter type : FIR(moving averge implementation)
