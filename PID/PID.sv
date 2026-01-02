`timescale 1ns / 1ps

// 
//////////////////////////////////////////////////////////////////////////////////


module PID #(
    parameter W = 16,
    parameter signed MAX_VAL = 32767, 
    parameter signed MIN_VAL = -32768
)(
    input logic clk,
    input logic reset_n,
    input logic [W-1:0] sensor_measurment,
    input logic [W-1:0] setpoint,
    //Control parameters
    input  logic signed [W-1:0] Kp, Ki, Kd,
    output logic [W-1:0] y_out
);
    //Pipeline registers
    logic signed [W:0] error, prev_error, diff;
    logic signed [(2*W)+1:0] p_term, i_term, d_term;
    logic signed [(2*W)+1:0]  acc;
    
    //Beginning of pipeline
    //Stage 1//
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            error <=0 ;
            prev_error <= 0;
            diff <= 0;
        end
        else begin
            prev_error <= error;
            error <= setpoint - $signed(sensor_measurment);
            diff <= error-prev_error;
        end        
    end
    //Stage 2// 
        always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            p_term <= 0;
            i_term <= 0;
            d_term <= 0;
        end 
        else  begin
            p_term <= error * Kp;
            i_term <= error * Ki;
            d_term <= diff * Kd;
        end
    end
    //Stage 3//
    logic signed [(2*W)+1:0] full_sum;
    logic saturated;
    assign full_sum  = p_term + acc + d_term;
    assign saturated = (full_sum >= MAX_VAL) || (full_sum <= MIN_VAL);
        always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            acc       <= 0;
            y_out  <= 0;
        end
            else begin
                if (!saturated) begin
                    acc <= acc + i_term;
                end

                // Final Clamping
                if (full_sum > MAX_VAL)
                    y_out <= MAX_VAL[W-1:0];
                else if (full_sum < MIN_VAL)
                    y_out <= MIN_VAL[W-1:0];
                else
                    y_out <= full_sum[W-1:0];
            end
        end

endmodule
