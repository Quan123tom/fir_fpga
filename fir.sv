`timescale 1ns / 1ps


module fir #(
parameter WIDTH = 16
)(
input logic CLK,
input logic rst,
input logic [WIDTH-1:0] input_data,
output logic [WIDTH+2:0] out_data,
logic [WIDTH +2:0] s1_a, s1_b, s1_c, s1_d,
logic [WIDTH +2:0] s2_a, s2_b, s3,
logic [WIDTH + 4:0] result
);
// 1st pipeline stage: load the input into register x for further proccessing
logic [WIDTH-1:0] x [0:7];
always_ff @(posedge CLK or negedge rst) begin
    if (!rst) begin
        for (int i = 0; i<8; i++) x[i] <= 16'b0;
        s1_a <= 0;
        s1_b <= 0;
        s1_c <= 0;
        s1_d <= 0;
        s2_a <= 0;
        s2_b <= 0;
        s3 <= 0;
    end
    else begin
        x[0] <= input_data;
        for (int i = 1; i <8; i++) x[i] <= x[i-1];
    end
end
// 2nd pipeline stage 
always_ff @(posedge CLK) begin
    s1_a <= x[0] + x[1];
    s1_b <= x[2] + x[3];
    s1_c <= x[4] + x[5];
    s1_d <= x[6] + x[7]; 
end
// 3rd pipeline stage 
always_ff @(posedge CLK) begin
    s2_a <= s1_a + s2_b;
    s2_b <= s1_c + s1_d;
end
// 4rth stage 
always_ff @(posedge CLK) begin
    s3 <= s2_a + s2_b;
end
// 5th stage (division by 3)
always_ff @(posedge CLK) begin
    result <= s3 >>> 3;
end
endmodule
