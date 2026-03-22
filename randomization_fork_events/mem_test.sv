`timescale 1ns/1ns

module mem_test #(
	parameter int ADDR_W ,
	parameter int DATA_W ,
	parameter string TEST_NAME = "MEM_TEST"
) (mem_if.tb mem_vif);

	// ------------------------------------------------------------
	// ENUM DECLARATION
	// ------------------------------------------------------------	
	typedef enum {
		PRINTABLE_ASCII,
		UPPER_CASE,
		LOWER_CASE,
		WEIGHTED_CASE,
		EXTENDED_ASCII
	} random_constraints;

	// ------------------------------------------------------------
	// RANDOMIZATION CLASS TO DEFINE CONSTRAINTS
	// ------------------------------------------------------------	
	class constr;
		rand bit [7:0] data;
        	random_constraints policy;

		//PRINTABLE ASCII
		constraint printable_c {
			if (policy == PRINTABLE_ASCII)
			data inside {[8'h41:8'h7F]};
		}
        
		// UPPER CASE
        	constraint upper_c {
            		if (policy == UPPER_CASE)
                	data inside {[8'h41:8'h5A]};
        	}

        	// LOWER CASE
        	constraint lower_c {
            		if (policy == LOWER_CASE)
                	data inside {[8'h61:8'h7A]};
        	}

        	// WEIGHTED UPPER/LOWER
        	constraint weighted_c {
            		if (policy == WEIGHTED_CASE)
                	data dist {
                    		[8'h41:8'h5A] := 80,
                    		[8'h61:8'h7A] := 20
                	};
       		 }

        	// EXTENDED ASCII
        	constraint extended_c {
            		if (policy == EXTENDED_ASCII)
                	data inside {[8'h80:8'hFF]};
        	}
	endclass

	// ------------------------------------------------------------
	// LOCAL VARIABLES INITIALIZATION
	// ------------------------------------------------------------

	localparam DEPTH = 1 << ADDR_W;
	int error_count = 0;
	event instr_ready;
	event data_ready;
	
	constr rand_gen;

	logic [DATA_W-1:0] instr_ref [0:DEPTH-1];
	logic [DATA_W-1:0] data_ref  [0:DEPTH-1];



	// ------------------------------------------------------------
	// DISPLAY FOR DEBUGGING
	// ------------------------------------------------------------
	always @(posedge mem_vif.clk) begin
        
	$display("[%s]	Time=%0t | Addr=%h | Data_in=%c | Data_out=%c | Read=%b | Write=%b",
                 TEST_NAME, $time, mem_vif.addr, mem_vif.data_in, mem_vif.data_out, mem_vif.read, mem_vif.write);	// used display because $monitor was not allowing multiple simulation outputs, it overwrites
	end

	
	// ------------------------------------------------------------
	// Tasks having read_mem() and write__mem() instantiated from mem_if
	// ------------------------------------------------------------

    	// RANDOM INSTRUCTION MEMORY TEST
    	// ------------------------------------------------------------
   	task random_instr_mem_test(random_constraints mode);
        	logic [DATA_W-1:0] rdata;
        	rand_gen.policy = mode;
        	$display("\n---- RANDOM INSTRUCTION MEMORY TEST (%0d) ----", mode);

	fork
		begin:producer1
			for(int i = 0; i < DEPTH; i++) 
			begin
				assert(rand_gen.randomize());
				instr_ref[i] = rand_gen.data;
				mem_vif.write_mem(i, rand_gen.data);

				
			end
			//-> instr_ready;			// Blocking
			->> instr_ready;			// Non Blocking
		end:producer1

		begin:consumer1
			begin
				@(instr_ready);

				for(int i = 0; i < DEPTH; i++)
				begin
					mem_vif.read_mem(i, rdata);

					if(rdata != instr_ref[i]) 
						begin
                				$display("ERROR addr=%0d expected=%c got=%c",i, instr_ref[i], rdata);
                				error_count++;
            					end
            				else 
						begin
                				$display("OK addr=%0d data=%c", i, rdata);
            					end
				end
			end
		end:consumer1
		
	join
        	printstatus(error_count);
    	endtask: random_instr_mem_test

    	// RANDOM DATA MEMORY TEST
    	// ------------------------------------------------------------
	task random_data_mem_test();
		logic [DATA_W-1:0] rdata;
		rand_gen.policy = EXTENDED_ASCII;
		$display("\n---- RANDOM DATA MEMORY TEST ----");
		
	fork
		begin:producer2
			for(int i = 0; i < DEPTH; i++) 
			begin
				assert(rand_gen.randomize());
				data_ref[i] = rand_gen.data;
				mem_vif.write_mem(i, rand_gen.data);

			end
			//-> data_ready;		 // Blocking Event Trigger
			->> data_ready;		// Non Blocking
		end:producer2

		begin:consumer2
			begin
				@(data_ready);

				for(int i = 0; i < DEPTH; i++)
				begin
					mem_vif.read_mem(i, rdata);

					if(rdata != data_ref[i]) 
						begin
                				$display("ERROR addr=%0d expected=%c got=%c",i, data_ref[i], rdata);
                				error_count++;
            					end
            				else 
						begin
                				$display("OK addr=%0d data=%c", i, rdata);
            					end
				end
			end
		end:consumer2
		
	join
        	printstatus(error_count);
    	endtask: random_data_mem_test



	//------------------TEST CASE FOR CLEARING MEMORY----------------------------
	task memory_clear;
		logic [DATA_W-1:0] value_check;
    		$display("@%t: Starting memory clear", $time);
    	fork
        // ---------------- STIMULUS THREAD ----------------
        	begin
            		for (int i=0; i<DEPTH; i++) 
			begin
                	mem_vif.write_mem(i, 0);
            		end
        	end

        // ---------------- CHECKER THREAD ----------------
        	begin
            	// Small delay so first write happens
            		repeat(2) @(posedge mem_vif.clk);
            		for (int j=0; j<DEPTH; j++) 
			begin
                		mem_vif.read_mem(j, value_check);
                		if (value_check != 0) 
				begin
                    			$display("ERROR at %0d", j);
                    			error_count++;
               			end
            		end
        	end
    	join

    		printstatus(error_count);
    		$display("@%t: Ending memory clear", $time);

	endtask: memory_clear


	//------------------TEST CASE FOR DATA VALIDITY----------------------------	
	task data_validity;
		logic [DATA_W-1:0] data_check;
		$display("@%t: ------------------------starting data validity-------------------------------------", $time);
	
		begin
			for (int i=0; i<DEPTH; i++)
				mem_vif.write_mem (i, i[DATA_W-1:0]);

			for (int j=0; j<DEPTH; j++)
			begin
				repeat(2) @(posedge mem_vif.clk);
				mem_vif.read_mem (j, data_check);
				if (data_check != j[DATA_W-1:0])
				begin
					$display("****ERROR FOUND**** \n Data Validity Test Failed at addr %d",j);
					error_count++;
				end
			end
		end
	
		printstatus(error_count);
		$display("@%t: ------------------------ending data validity-------------------------------------", $time);
	endtask: data_validity

	//---------------TEST CASE FOR BACK 2 BACK WRITE---------------------------
	task back2back_test;
		logic [DATA_W-1:0] rdata;
		int start;
		int count;
	$display("@%t: ------------------------starting b2b test-------------------------------------", $time);
	begin
		start = 8;						// random starting address, it can be anything
		count = 11;						// random counting given, this to can be anything
		mem_vif.back2back_write(start, count);
		// Now verify by reading back
		for (int i = 0; i < count; i++) 
		begin
			mem_vif.read_mem(start + i, rdata);
				if (rdata != (start + i)) 
				begin
            				$display("****ERROR FOUND**** \n BACK2BACK Write Test Failed at addr %0d", start+i);
            				error_count++;
        			end
    		end
		printstatus(error_count);
	$display("@%t: ------------------------ending b2b test-------------------------------------", $time);
	end
	endtask: back2back_test
		
	
	// ------------------------------------------------------------
	// TASKS END HERE
	// ------------------------------------------------------------



	//------------------------FUNCTION FOR PRINTING STATUS-----------------------
	function void printstatus ( input int status );
	begin
		if ( !status )
			$display ("-------------TEST PASSED-----------");
		else
			$display ("-------------TEST FAILED-----------");
			$display ("ERRORS FOUND ARE: %d",error_count);
	end
	endfunction


	// ------------------------------------------------------------
	// MAIN TEST CONTROL (ONLY INITIAL BLOCK)
	// ------------------------------------------------------------

	initial begin

	rand_gen = new();
	$display("[%m] ------------------Simulation Start---------------------");

    	/*memory_clear();
    	data_validity();
    	back2back_test();*/
	
	
	random_data_mem_test();
	random_instr_mem_test(WEIGHTED_CASE);
	

    	$display("[%s] All tests completed", TEST_NAME);
	$display("[%m] ------------------Simulation Finished---------------------");
    	$finish;

	end

endmodule



