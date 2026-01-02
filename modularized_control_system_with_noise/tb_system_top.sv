`timescale 1ns / 1ps

module tb_system_top();

    // --- Parameters ---
    parameter W = 16;
    logic [15:0] Kd_0 = 16'd120;
    logic [15:0] Ki_0 = 16'd0;
    logic [15:0] Kp_0 = 16'd8;
    logic [15:0] setpoint_0 = 16'd1000;
    logic [15:0] plant_state_viz;
    assign plant_state_viz = $rtoi(plant_state);
    
    logic clk_in1_0 = 0;
    logic locked_0;
    logic reset_0 = 1;      // Clock Wizard Reset (Active High)
    logic reset_n_0 = 0;    // System Reset (Active Low)

    // AXI-Stream Slave//
    logic [15:0] s_axis_0_tdata;
    logic s_axis_0_tvalid;
    logic s_axis_0_tready;

    // AXI-Stream Master//
    logic signed [15:0] m_axi_0_tdata;
    logic m_axi_0_tvalid;
    logic m_axi_0_tready = 1; // Testbench is always ready

    // Plant//
    real plant_state = 0.0;
    real noise_magnitude = 15.0; // Simulated sensor noise

    //Clock(100 MHz)//
    always #5 clk_in1_0 = ~clk_in1_0;

    // Unit Under Test//
    design_1_wrapper dut (
        .Kd_0(Kd_0),
        .Ki_0(Ki_0),
        .Kp_0(Kp_0),
        .clk_in1_0(clk_in1_0),
        .locked_0(locked_0),
        .m_axi_0_tdata(m_axi_0_tdata),
        .m_axi_0_tready(m_axi_0_tready),
        .m_axi_0_tvalid(m_axi_0_tvalid),
        .reset_0(reset_0),
        .reset_n_0(reset_n_0),
        .s_axis_0_tdata(s_axis_0_tdata),
        .s_axis_0_tready(s_axis_0_tready),
        .s_axis_0_tvalid(s_axis_0_tvalid),
        .setpoint_0(setpoint_0)
    );

    // Closed-Loop Physics Engine//
    always @(posedge clk_in1_0) begin
        if (!reset_n_0) begin
            plant_state <= 0;
            s_axis_0_tvalid <= 0;
            s_axis_0_tdata  <= 0;
        end else if (locked_0) begin
            plant_state <= plant_state + ($signed(m_axi_0_tdata) * 0.0005);
            s_axis_0_tvalid <= 1;
            s_axis_0_tdata  <= $rtoi(plant_state) + ($signed($random) % $rtoi(noise_magnitude));
        end
    end

    // --- Simulation Control ---
    initial begin
        $display("Starting PID+FIR Closed-Loop Simulation...");
        
        // Initial Reset Sequence
        reset_0 = 1;
        reset_n_0 = 0;
        #100;
        reset_0 = 0;
        
        wait(locked_0 == 1);
        #100;
        reset_n_0 = 1;
        
        // Run for 100 microseconds to see settling
        #100000;
        
        $display("Step response complete. Final Plant State: %f", plant_state);
        $finish;
    end

endmodule