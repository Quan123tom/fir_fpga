`timescale 1ns / 1ps

module PID_controller_wrapper #(
    parameter W = 16,
    parameter signed MAX_VAL = 32767, 
    parameter signed MIN_VAL = -32768
)(
    input  wire clk,
    input  wire reset_n,
    input  wire [W-1:0] s_axi_tdata,
    input  wire s_axi_tvalid,
    output wire s_axi_tready,
    
    input  wire [W-1:0] Kp, 
    input  wire [W-1:0] Ki, 
    input  wire [W-1:0] Kd,
    input  wire [W-1:0] setpoint,
    
    output wire [W-1:0] m_axi_tdata,
    output wire m_axi_tvalid,
    input  wire m_axi_tready
);

    PID_controller #(
        .W(W),
        .MAX_VAL(MAX_VAL),
        .MIN_VAL(MIN_VAL)
    ) pid_inst (
        .clk(clk),
        .reset_n(reset_n),
        
        .s_axi_tdata(s_axi_tdata),
        .s_axi_tvalid(s_axi_tvalid),
        .s_axi_tready(s_axi_tready),
        
        .Kp($signed(Kp)),
        .Ki($signed(Ki)),
        .Kd($signed(Kd)),
        .setpoint($signed(setpoint)),
        
        .m_axi_tdata(m_axi_tdata),
        .m_axi_tvalid(m_axi_tvalid),
        .m_axi_tready(m_axi_tready)
    );

endmodule