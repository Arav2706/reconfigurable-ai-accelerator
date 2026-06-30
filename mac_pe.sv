module mac_pe (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    input  logic signed [7:0]  a_in,
    input  logic signed [7:0]  b_in,
    output logic signed [7:0]  a_out,
    output logic signed [7:0]  b_out,
    output logic signed [31:0] acc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            acc   <= 32'sd0;
            a_out <= 8'sd0;
            b_out <= 8'sd0;
        end
        else if (en) begin
            acc   <= acc + (a_in * b_in);  // multiply-accumulate
            a_out <= a_in;                  // pass a to the right
            b_out <= b_in;                  // pass b downward
        end
    end

endmodule