`timescale 1ns / 1ps

module PID_tb;

    parameter W = 16;
    parameter signed MAX_VAL = 32767;
    parameter signed MIN_VAL = -32768;

    logic clk;
    logic reset_n;
    logic [W-1:0] sensor_measurement;
    logic [W-1:0] setpoint;
    logic signed [W-1:0] Kp, Ki, Kd;
    logic [W-1:0] y_out;

    PID #(
        .W(W),
        .MAX_VAL(MAX_VAL),
        .MIN_VAL(MIN_VAL)
    ) uut (
        .clk(clk),
        .reset_n(reset_n),
        .sensor_measurment(sensor_measurement),
        .setpoint(setpoint),
        .Kp(Kp),
        .Ki(Ki),
        .Kd(Kd),
        .y_out(y_out)
    );

    always #5 clk = ~clk;

    real plant_state = 0;
    
    initial begin
        clk = 0;
        reset_n = 0;
        sensor_measurement = 0;
        setpoint = 0;
        
        Kp = 16'd10; 
        Ki = 16'd1;  
        Kd = 16'd20;  

        #20 reset_n = 1;
        #20 setpoint = 16'd1000;

        repeat (500) begin
            @(posedge clk);
            plant_state = plant_state + ($signed(y_out) * 0.01);
            sensor_measurement = $shortrealtobits(plant_state); 
            sensor_measurement = $rtoi(plant_state);
        end


        #100 $finish;
    end

    initial begin
        $monitor("Time=%0t | SP=%d | PV=%d | Out=%d", $time, setpoint, sensor_measurement, $signed(y_out));
    end

endmodule