`timescale 1ns/1ns

module mem_test #(
    parameter int ADDR_W = 5,
    parameter int DATA_W = 8
) (mem_if.tb mem_vif);

	int error_count = 0;

	//mem DUT (.clk(mem_vif.clk), .read(mem_vif.read), .write(mem_vif.write),.addr(mem_vif.addr), .data_in(mem_vif.data_in));


	// Clock Generation
	/*initial mem_vif.clk = 0;
	always #5 mem_vif.clk = ~mem_vif.clk;*/

	// Display for debugging
	initial begin
        $display("------Simulation Start------"); 
	$monitor("Time=%0t | Addr=%h | Data_in=%h | Data_out=%h | Read=%b | Write=%b",
                 $time, mem_vif.addr, mem_vif.data_in, mem_vif.data_out, mem_vif.read, mem_vif.write);
	end

	
	//------------------INSTANTIATING TASKS FROM INTERFACE TO READ AND WRITE FROM THE MEMORY-------------------------
	


	//------------------TEST CASE FOR CLEARING MEMORY----------------------------
	task memory_clear;
		logic [DATA_W-1:0] value_check;

		begin
			for ( int i=0; i<32;i++)
			begin
				mem_vif.write_mem (i, 0);
			end
			for ( int j=0; j<32;j++)
			begin
				mem_vif.read_mem (j, value_check);
				if (value_check != 0)
				begin
					$display("****ERROR FOUND**** \n CLEAR TEST HAS FAILED AT %d",j);
					error_count++;
				end
			end
		printstatus(error_count);
	end
	endtask: memory_clear


	//------------------TEST CASE FOR DATA VALIDITY----------------------------	
	task data_validity;
		logic [DATA_W-1:0] data_check;
		begin
			for (int i=0; i<32; i++)
				mem_vif.write_mem (i, i);

			for (int j=0; j<32; j++)
			begin
				mem_vif.read_mem (j, data_check);
				if (data_check != j)
				begin
					$display("****ERROR FOUND**** \n Data Validity Test Failed at addr %d",j);
					error_count++;
				end
			end
		end
		printstatus(error_count);
	endtask: data_validity

	//---------------TEST CASE FOR BACK 2 BACK WRITE---------------------------
	task back2back_test;
		logic [DATA_W-1:0] rdata;
		int start;
		int count;
	begin
		start = 8;						// random starting address, it can be anything
		count = 11;						// random counting given, this to can be anything
    		$display("---- Starting Back-to-Back Write Test ----");
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
	end
	endtask: back2back_test
	
	/*------------------UNCOMMENT THIS TASK TO CHECK ERROR DETECTION--------------------------------
	//------------------TEST TO CHECK WHETHER ERROR IS BEING DETECTED OR NOT------------------------
	task error_check;
		logic [DATA_W-1:0] data_check;
		begin
			for (int i=0; i<32; i++)
				mem_vif.write_mem (i, i);

			for (int j=0; j<32; j++)
			begin
				mem_vif.read_mem (j+1, data_check);		//delibrately checking wrong address
				if (data_check != j)
				begin
					$display("****ERROR FOUND**** \n Data Validity Test Failed at addr %d",j);
					error_count++;
				end
			end
		end
		printstatus(error_count);
	endtask: error_check*/
		
	
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


	//------------------------BONUS FILE READING TASKS----------------------------
	task read_file2mem;
		int read_file;
    		int status;
    		byte char;  			// store ASCII character
    		int addr_count;

		begin
			addr_count = 0;
			read_file = $fopen("stimulus.txt","r");
			if (!read_file) 
			begin
            			$display("ERROR: Could not open stimulus.txt");
            			return;
        		end
			while (!$feof(read_file))
			begin
				if ($fscanf(read_file, "%c\n", char)) 
				begin
            			mem_vif.write_mem(addr_count, char);
            			addr_count++;
        			end
			end
		$fclose(read_file);

		end
	endtask: read_file2mem

	task read_verify_filedata;
		int filetoberead;
		int newfile;
		int expectedvalue;
		int index;
		logic [DATA_W-1:0] rdata;

		begin
			index = 0;
			filetoberead = $fopen("stimulus.txt","r");
			newfile = $fopen("test_results.txt", "w");
			if (!filetoberead || !newfile)
			begin
				$display("ERROR: Could not open file");
            			return;
			end

			while (!$feof(filetoberead))
			begin
				if ($fscanf(filetoberead, "%c\n", expectedvalue)) 
				begin
					mem_vif.read_mem(index, rdata);
					if (rdata == expectedvalue)
					begin
						$fdisplay (newfile, "PASS: Addr=%d Data=%d", index,rdata);
					end
					else
					begin
						$fdisplay (newfile, "FAIL: Addr=%d Expected=%d Got=%d",index,expectedvalue,rdata);
						error_count++;
					end
					index++;
				end
			end
		$fclose(filetoberead);
		$fclose(newfile);
		end
		
	endtask: read_verify_filedata 

	//--------------------EXECUTING THE TESTS AND THE FUNCTIONALITIES------------
	initial 
	begin

		    // Start waveform dumping
    		$dumpfile("waveform.vcd");   // Specify the waveform file 
    		$dumpvars(0, mem_vif);       // Dump all signals inside the mem_vif interface
		mem_vif.read  = 0;
		mem_vif.write = 0;
		mem_vif.addr  = 0;
		mem_vif.data_in = 0;
		
		repeat(2) @(posedge mem_vif.clk);
		memory_clear();

		data_validity();
		back2back_test();
		//error_check();		// CALL THIS TASK TO DELIBRATELY CHECK ERROR DETECTION FUNCTIONALITY

		read_file2mem();
		read_verify_filedata();
		printstatus(error_count);

    		$finish;
	end


endmodule


