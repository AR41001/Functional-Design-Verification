module system_test
#(
    parameter ADDR_W = 9,
    parameter DATA_W = 8
)
(
    mem_if.tb instr_vif,
    mem_if.tb data_vif
);

    mem_test #(.ADDR_W(ADDR_W), .DATA_W(DATA_W), .TEST_NAME("INSTR_MEM_TEST"))
        TB_instr (instr_vif);

    mem_test #(.ADDR_W(ADDR_W), .DATA_W(DATA_W), .TEST_NAME("DATA_MEM_TEST"))
        TB_data  (data_vif);

endmodule
