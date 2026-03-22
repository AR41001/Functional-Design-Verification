`timescale 1ns/1ns

module top;

    parameter ADDR_W = 9;
    parameter DATA_W = 8;

    // Interfaces
    mem_if #(ADDR_W, DATA_W) instr_if();
    mem_if #(ADDR_W, DATA_W) data_if();

    // Clock generation
    initial instr_if.clk = 0;
    always #10 instr_if.clk = ~instr_if.clk;  // 20 time unit

    initial data_if.clk = 0;
    always #5 data_if.clk = ~data_if.clk;     // 10 time unit

    // DUT
    system_top #(ADDR_W, DATA_W) DUT (
        .instr_if(instr_if),
        .data_if(data_if)
    );

    // Test
    system_test #(.ADDR_W(ADDR_W), .DATA_W(DATA_W)) TEST (
        .instr_vif(instr_if),
        .data_vif(data_if)
    );

endmodule
