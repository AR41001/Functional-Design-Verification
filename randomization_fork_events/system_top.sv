module system_top #(parameter ADDR_W=9, DATA_W=8)
(
    mem_if.dut instr_if,
    mem_if.dut data_if
);

    mem #(.ADDR_W(ADDR_W), .DATA_W(DATA_W))
        Instr_Mem (
            .clk(instr_if.clk),
            .read(instr_if.read),
            .write(instr_if.write),
            .addr(instr_if.addr),
            .data_in(instr_if.data_in),
            .data_out(instr_if.data_out)
        );

    mem #(.ADDR_W(ADDR_W), .DATA_W(DATA_W))
        Data_Mem (
            .clk(data_if.clk),
            .read(data_if.read),
            .write(data_if.write),
            .addr(data_if.addr),
            .data_in(data_if.data_in),
            .data_out(data_if.data_out)
        );

endmodule
