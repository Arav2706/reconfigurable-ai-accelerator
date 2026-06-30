`timescale 1ns/1ps

module systolic_2x2_tb;

    logic               clk;
    logic               rst;
    logic               en;
    logic signed [7:0]  a_row0, a_row1;
    logic signed [7:0]  b_col0, b_col1;
    logic signed [31:0] acc00, acc01, acc10, acc11;

    systolic_2x2 dut (
        .clk(clk), .rst(rst), .en(en),
        .a_row0(a_row0), .a_row1(a_row1),
        .b_col0(b_col0), .b_col1(b_col1),
        .acc00(acc00), .acc01(acc01),
        .acc10(acc10), .acc11(acc11)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst = 1; en = 0;
        a_row0 = 0; a_row1 = 0;
        b_col0 = 0; b_col1 = 0;

        // Release reset
        #20;
        rst = 0;
        en  = 1;

        // ---- Cycle 1 ----
        @(negedge clk);
        a_row0 = 1; a_row1 = 0;
        b_col0 = 5; b_col1 = 0;

        // ---- Cycle 2 ----
        @(negedge clk);
        a_row0 = 2; a_row1 = 3;
        b_col0 = 7; b_col1 = 6;

        // ---- Cycle 3 ----
        @(negedge clk);
        a_row0 = 0; a_row1 = 4;
        b_col0 = 0; b_col1 = 8;

        // ---- Cycle 4: feed zeros, let data finish flowing ----
        @(negedge clk);
        a_row0 = 0; a_row1 = 0;
        b_col0 = 0; b_col1 = 0;

        // Let it settle, then stop accumulating
        @(negedge clk);
        @(negedge clk);
        en = 0;

        // Wait and check
        #20;

        $display("acc00 = %0d (expected 19)", acc00);
        $display("acc01 = %0d (expected 22)", acc01);
        $display("acc10 = %0d (expected 43)", acc10);
        $display("acc11 = %0d (expected 50)", acc11);

        $finish;
    end

endmodule