`timescale 1ns / 1ps

module fir_tb;

    // Parameters
    parameter WIDTH = 16;
    parameter CLK_PERIOD = 10; 

    // Signals
    logic CLK;
    logic rst;
    logic signed [WIDTH-1:0] input_data;
    logic signed [WIDTH+2:0] out_data;
    
    // 1. Updated memory size to 1000
    logic [WIDTH-1:0] data_buffer [0:999]; 

    // Instantiate UUT
    fir #(.WIDTH(WIDTH)) UUT (
        .CLK(CLK),
        .rst(rst),
        .input_data(input_data),
        .out_data(out_data)
    );

    integer k;
    integer FILE1;

    // Clock Generation
    initial CLK = 0;
    always #(CLK_PERIOD/2) CLK = ~CLK;

    initial begin 
        input_data = 0;
        rst = 0; // Active-Low Reset (0 = Resetting)
        
        // Use your full paths
        $readmemb("C:/Users/giorg/OneDrive/Desktop/Lab/inpuut.data", data_buffer);
        FILE1 = $fopen("C:/Users/giorg/OneDrive/Desktop/Lab/save.data", "w");
        #(CLK_PERIOD * 3);
        @(posedge CLK);
        rst <= 1; // Release Reset
        
        $display("Starting simulation for 1000 samples...");

        // 2. Loop for 1000 samples + 5 extra for pipeline flush
        for (k = 0; k < 1005; k = k + 1) begin 
            @(posedge CLK);
            
            if (k < 1000)
                input_data <= data_buffer[k];
            else
                input_data <= 0;

            // Sample on negative edge to allow signals to settle
            @(negedge CLK);
            $fdisplay(FILE1, "%b", out_data);
        end
        
        $fclose(FILE1);
        $finish;
    end
            
endmodule