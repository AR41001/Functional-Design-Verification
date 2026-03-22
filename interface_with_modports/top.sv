`timescale 1ns/1ns

module top();

	parameter ADDR_W = 5;
	parameter DATA_W = 8;

	//Instantiate interface
	mem_if #(ADDR_W, DATA_W) mem_if_inst();

	//Clock generation
	initial mem_if_inst.clk = 0;
	always #5 mem_if_inst.clk = ~mem_if_inst.clk;

	//DUT
	mem #(.ADDR_W(ADDR_W), .DATA_W(DATA_W))
		DUT (
        		.clk(mem_if_inst.clk),
        		.read(mem_if_inst.read),
        		.write(mem_if_inst.write),
        		.addr(mem_if_inst.addr),
        		.data_in(mem_if_inst.data_in),
        		.data_out(mem_if_inst.data_out)
    	);

    	// Testbench
    	mem_test #(.ADDR_W(ADDR_W), .DATA_W(DATA_W))
    	TB (mem_if_inst);
	
endmodule


