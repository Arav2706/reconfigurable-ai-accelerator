`timescale 1ns/1ps

module memory_buffer_tb;

    logic               clk;
    logic               we;
    logic [5:0]         addr;
    logic signed [7:0]  din;
    logic signed [7:0]  dout;

    // Instantiate the memory (using default parameters: 8 wide, 64 deep)
    memory_buffer dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; we = 0; addr = 0; din = 0;

        // ---- WRITE PHASE ----
        // Write value 25 to address 3
        @(negedge clk);
        we = 1; addr = 3; din = 25;

        // Write value -12 to address 7
        @(negedge clk);
        we = 1; addr = 7; din = -12;

        // Write value 100 to address 0
        @(negedge clk);
        we = 1; addr = 0; din = 100;

        // Stop writing
        @(negedge clk);
        we = 0;

        // ---- READ PHASE ----
        // Read address 3 (expect 25)
        @(negedge clk);
        addr = 3;
        @(posedge clk);   // wait one cycle for data to appear
        #1;
        $display("Read addr 3: %0d (expected 25)", dout);

        // Read address 7 (expect -12)
        @(negedge clk);
        addr = 7;
        @(posedge clk);
        #1;
        $display("Read addr 7: %0d (expected -12)", dout);

        // Read address 0 (expect 100)
        @(negedge clk);
        addr = 0;
        @(posedge clk);
        #1;
        $display("Read addr 0: %0d (expected 100)", dout);

        $finish;
    end

endmodule