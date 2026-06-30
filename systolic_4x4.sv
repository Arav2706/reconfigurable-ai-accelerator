`timescale 1ns/1ps

module systolic_4x4_tb;

    logic               clk;
    logic               rst;
    logic               en;
    logic signed [7:0]  a_in [4];
    logic signed [7:0]  b_in [4];
    logic signed [31:0] acc  [4][4];

    // The source matrices
    logic signed [7:0] A [4][4];
    logic signed [7:0] B [4][4];

    systolic_4x4 dut (
        .clk(clk), .rst(rst), .en(en),
        .a_in(a_in), .b_in(b_in),
        .acc(acc)
    );

    always #5 clk = ~clk;

    integer i, j, t;

    initial begin
        // Define matrix A
        A[0][0]=1; A[0][1]=2; A[0][2]=3; A[0][3]=4;
        A[1][0]=5; A[1][1]=6; A[1][2]=7; A[1][3]=8;
        A[2][0]=1; A[2][1]=1; A[2][2]=1; A[2][3]=1;
        A[3][0]=2; A[3][1]=2; A[3][2]=2; A[3][3]=2;

        // Define matrix B (identity)
        B[0][0]=1; B[0][1]=0; B[0][2]=0; B[0][3]=0;
        B[1][0]=0; B[1][1]=1; B[1][2]=0; B[1][3]=0;
        B[2][0]=0; B[2][1]=0; B[2][2]=1; B[2][3]=0;
        B[3][0]=0; B[3][1]=0; B[3][2]=0; B[3][3]=1;

        // Initialize
        clk = 0; rst = 1; en = 0;
        for (i = 0; i < 4; i++) begin
            a_in[i] = 0;
            b_in[i] = 0;
        end

        // Release reset
        #20;
        rst = 0;
        en  = 1;

        // Feed the matrices with staggered timing
        // We run for enough cycles to let all data flow through
        for (t = 0; t < 11; t++) begin
            @(negedge clk);

            // Feed A: row r contributes A[r][t-r] at time t (if valid)
            for (i = 0; i < 4; i++) begin
                if ((t - i) >= 0 && (t - i) < 4)
                    a_in[i] = A[i][t-i];
                else
                    a_in[i] = 0;
            end

            // Feed B: col c contributes B[t-c][c] at time t (if valid)
            for (j = 0; j < 4; j++) begin
                if ((t - j) >= 0 && (t - j) < 4)
                    b_in[j] = B[t-j][j];
                else
                    b_in[j] = 0;
            end
        end

        // Stop feeding
        @(negedge clk);
        en = 0;
        #20;

        // Print results
        $display("Result matrix C (should equal A):");
        for (i = 0; i < 4; i++) begin
            $display("  %0d  %0d  %0d  %0d",
                     acc[i][0], acc[i][1], acc[i][2], acc[i][3]);
        end

        $finish;
    end

endmodule