module systolic_2x2 (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    // A matrix enters from the left (one value per row)
    input  logic signed [7:0]  a_row0,
    input  logic signed [7:0]  a_row1,
    // B matrix enters from the top (one value per column)
    input  logic signed [7:0]  b_col0,
    input  logic signed [7:0]  b_col1,
    // The four accumulator outputs
    output logic signed [31:0] acc00,
    output logic signed [31:0] acc01,
    output logic signed [31:0] acc10,
    output logic signed [31:0] acc11
);

    // Wires for the data passing between PEs
    logic signed [7:0] a00_to_01, a10_to_11;  // a flowing right
    logic signed [7:0] b00_to_10, b01_to_11;  // b flowing down

    // Top-left PE [0,0]
    mac_pe pe00 (
        .clk(clk), .rst(rst), .en(en),
        .a_in(a_row0),    .b_in(b_col0),
        .a_out(a00_to_01), .b_out(b00_to_10),
        .acc(acc00)
    );

    // Top-right PE [0,1]
    mac_pe pe01 (
        .clk(clk), .rst(rst), .en(en),
        .a_in(a00_to_01), .b_in(b_col1),
        .a_out(),          .b_out(b01_to_11),
        .acc(acc01)
    );

    // Bottom-left PE [1,0]
    mac_pe pe10 (
        .clk(clk), .rst(rst), .en(en),
        .a_in(a_row1),     .b_in(b00_to_10),
        .a_out(a10_to_11), .b_out(),
        .acc(acc10)
    );

    // Bottom-right PE [1,1]
    mac_pe pe11 (
        .clk(clk), .rst(rst), .en(en),
        .a_in(a10_to_11), .b_in(b01_to_11),
        .a_out(),          .b_out(),
        .acc(acc11)
    );

endmodule