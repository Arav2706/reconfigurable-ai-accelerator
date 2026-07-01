module memory_buffer #(
    parameter WIDTH = 8,      // bits per slot
    parameter DEPTH = 64,     // number of slots
    parameter ADDR_BITS = 6   // address width (2^6 = 64)
)(
    input  logic                   clk,
    input  logic                   we,        // write enable
    input  logic [ADDR_BITS-1:0]   addr,      // which slot
    input  logic signed [WIDTH-1:0] din,      // data to write
    output logic signed [WIDTH-1:0] dout       // data read out
);

    // The actual storage: an array of DEPTH slots, each WIDTH bits
    logic signed [WIDTH-1:0] mem [DEPTH];

    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= din;   // write: store din at addr

        dout <= mem[addr];       // read: output value at addr (one cycle later)
    end

endmodule