`timescale 1ns/1ns
interface mem_if #(parameter int ADDR_W = 5, parameter int DATA_W = 8);
 	logic clk; 
	logic read;
	logic write;
	logic [ADDR_W-1:0]	addr;
	logic [DATA_W-1:0]	data_in;
	logic [DATA_W-1:0]	data_out;
	
	//----------TASKS MENTIONED BELOW------------------------------
	task write_mem (
		input logic [ADDR_W-1:0] write_addr,
		input logic [DATA_W-1:0] write_data,
		input logic debug = 0				// doing this because a default instantiation was requested
	);

	begin
		@(negedge clk);
		addr    <= write_addr;
		data_in <= write_data;
		write   <= 1'b1;
		read	<= 1'b0;

		@(negedge clk);
		write   <= 1'b0;

		if (debug)
			$display("Debug is high: WRITE: addr=%d data=%d", write_addr, write_data);
	end
	endtask: write_mem



	task read_mem (
		input logic [ADDR_W-1:0] read_addr,
		output logic [DATA_W-1:0] read_data,
		input logic debug = 0
	);
	begin
		$display (" Starting to read data from the memory ");
		@(negedge clk)
		addr		<= read_addr;
		read		<= 1'b1;
		write		<= 1'b0;	
		
		@(posedge clk)
		#1;
		$display (" Writing to data_out");
		read_data <= data_out;				// JUST TESTING NOT FINAL

		@(negedge clk)
		read <= 0;
		
		if (debug)
			$display("Debug is high: READ: addr=%d data=%d", read_addr, read_data);
		
	end
	endtask: read_mem


	task back2back_write (
    		input logic [ADDR_W-1:0] start_addr,
    		input int count
	); 
	begin
		for (int k = 0; k < count; k++) begin
			@(negedge clk);
			addr 	<= start_addr + k;
			data_in	<= start_addr + k;
			write	<= 1'b1;
			read	<= 1'b0;
		end

		@(negedge clk)
		write <= 1'b0;
	end
	endtask: back2back_write

	//--------------------MOD PORT DECLARATION---------------------------------------

	modport tb (
			input clk, data_out,
		    	output read, write, addr, data_in, 
		    	import write_mem,read_mem, back2back_write 
		);

	modport dut (
		    	input clk, read, write, addr, data_in,
			output data_out
		);


endinterface: mem_if 

