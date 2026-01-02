`timescale 1ns / 1ps

module fir_wrapper #(
    parameter WIDTH = 16
)(
    input  wire clk,
    input  wire reset_n,
    input  wire [WIDTH-1:0] s_axis_tdata,
    input  wire s_axis_tvalid,
    output wire s_axis_tready,
    
    output wire [WIDTH-1:0]  m_axis_tdata,
    output wire m_axis_tvalid,
    input  wire m_axis_tready
);
    fir #(
        .WIDTH(WIDTH)
    ) fir_inst (
        .clk(clk),
        .reset_n(reset_n),
        
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

endmodule
