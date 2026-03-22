`timescale 1ns/1ns

// Parameters:
//   ADDR_W : address width (depth = 2**ADDR_W)
//   DATA_W : data width
///////////////////////////////////////////////////////////////////////////
module mem #(
    parameter int ADDR_W = 5,
    parameter int DATA_W = 8
) (
    input  logic                 clk,
    input  logic                 read,
    input  logic                 write,
    input  logic [ADDR_W-1:0]    addr,
    input  logic [DATA_W-1:0]    data_in,
    output logic [DATA_W-1:0]    data_out
);

    localparam int DEPTH = (1 << ADDR_W);

    logic [DATA_W-1:0] mem_array [0:DEPTH-1];

    // Optional: initialize to zero for deterministic sims
    /*initial begin
        for (int i = 0; i < DEPTH; i++) mem_array[i] = '0;
        data_out = '0;
    end*/

    always_ff @(posedge clk) begin
        if (read && write) begin
            $error("mem.sv: Illegal condition: read and write both high at time %0t", $time);
        end else if (write) begin
            mem_array[addr] <= data_in;
        end else if (read) begin
            data_out <= mem_array[addr];
        end
    end

endmodule


