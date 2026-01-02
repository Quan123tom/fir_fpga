`timescale 1ns / 1ps
module PID_controller #(
    parameter W = 16,
    parameter signed MAX_VAL = 32767, 
    parameter signed MIN_VAL = -32768
)(
    input logic clk,
    input logic reset_n,
    
    // AXI Stream Slave Interface
    input  logic signed [W-1:0] s_axi_tdata,
    input  logic         s_axi_tvalid,
    output logic         s_axi_tready,
    
    // Control Parameters
    input  logic signed [W-1:0] Kp, Ki, Kd,
    input  logic signed [W-1:0] setpoint,
    
    // AXI Stream Master Interface
    output logic [W-1:0] m_axi_tdata,
    output logic         m_axi_tvalid, // Fixed typo from header
    input  logic         m_axi_tready
);

    // --- Pipeline Registers ---
    logic signed [W:0]        err_s1, prev_err_s1, diff_s1;
    logic                     valid_s1;
    
    logic signed [(2*W)+1:0]    p_term_s2, i_term_s2, d_term_s2;
    logic                     valid_s2;
    
    logic signed [(2*W)+1:0]  acc_s3; 
    logic                     valid_s3;

    // Handshake logic: System is ready if downstream is ready
    assign s_axi_tready = m_axi_tready;

    // --- STAGE 1: Error & Delta ---
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            err_s1      <= 0;
            prev_err_s1 <= 0;
            diff_s1     <= 0;
            valid_s1    <= 0;
        end else if (s_axi_tready) begin
            valid_s1 <= s_axi_tvalid;
            if (s_axi_tvalid) begin
                prev_err_s1 <= err_s1;
                err_s1      <= setpoint - $signed(s_axi_tdata);
                diff_s1     <= prev_err_s1 - err_s1;
            end
        end
    end

    // --- STAGE 2: Multiplications ---
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            p_term_s2 <= 0;
            i_term_s2 <= 0;
            d_term_s2 <= 0;
            valid_s2  <= 0;
        end else if (s_axi_tready) begin
            valid_s2  <= valid_s1;
            p_term_s2 <= err_s1 * Kp;
            i_term_s2 <= err_s1 * Ki;
            d_term_s2 <= diff_s1 * Kd;
        end
    end

    // --- STAGE 3: Summation & Saturation ---
    logic signed [(2*W)+1:0] full_sum;
    logic saturated;

    assign full_sum  = p_term_s2 + acc_s3 + d_term_s2;
    assign saturated = (full_sum >= MAX_VAL) || (full_sum <= MIN_VAL);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            acc_s3       <= 0;
            m_axi_tdata  <= 0;
            valid_s3     <= 0;
        end else if (s_axi_tready) begin
            valid_s3 <= valid_s2;
            if (valid_s2) begin
                // Improved Anti-Windup
                if (!saturated) begin
                    acc_s3 <= acc_s3 + i_term_s2;
                end

                // Final Clamping
                if (full_sum > MAX_VAL)
                    m_axi_tdata <= MAX_VAL[W-1:0];
                else if (full_sum < MIN_VAL)
                    m_axi_tdata <= MIN_VAL[W-1:0];
                else
                    m_axi_tdata <= full_sum[W-1:0];
            end
        end
    end

    assign m_axi_tvalid = valid_s3;

endmodule