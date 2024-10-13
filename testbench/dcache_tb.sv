// mapped needs this
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module dcache_tb;
  import cpu_types_pkg::*;

  parameter PERIOD = 10;

  // signals
  logic CLK = 1, nRST = 0;

  // clock
  always #(PERIOD/2) CLK++;

  // clock division
  parameter CLKDIV = 2;
  logic CPUCLK;
  logic [3:0] count;

  always_ff @(posedge CLK, negedge nRST)
  begin
	if (!nRST)
	begin
	  count <= 0;
	  CPUCLK <= 0;
	end
	else if (count == CLKDIV-2)
	begin
	  count <= 0;
	  CPUCLK <= ~CPUCLK;
	end
	else
	begin
	  count <= count + 1;
	end
  end

  integer tb_test_num;
  string  tb_test_case;
  
  word_t expected_out;

  // interface

	datapath_cache_if dpif();
	caches_if ccif();
  caches_if cif1();

  cache_control_if mc_cache_if (.cif0(ccif), .cif1(cif1));
  cpu_ram_if ramif ();

  // ram (can't find it if you don't use name RAM??)
  ram RAM(CLK, nRST, ramif);
  memory_control mc(CPUCLK, nRST, mc_cache_if);

  assign mc_cache_if.ramload = ramif.ramload;
  assign mc_cache_if.ramstate = ramif.ramstate;

  assign ramif.ramREN = mc_cache_if.ramREN;
  assign ramif.ramWEN = mc_cache_if.ramWEN;
  assign ramif.ramaddr = mc_cache_if.ramaddr;
  assign ramif.ramstore = mc_cache_if.ramstore;

  // DUT
`ifndef MAPPED
  dcache DUT(CPUCLK, nRST, dpif, ccif);
`else
  dcache DUT(
	.\ccif.dwait (ccif.dwait)
	.\ccif.dload (ccif.dload)
	.\dpif.halt (dpif.halt)
	.\dpif.dmemREN (dpif.dmemREN)
	.\dpif.dmemWEN (dpif.dmemWEN)
	.\dpif.dmemstore (dpif.dmemstore)
	.\dpif.dmemaddr (dpif.dmemaddr)
	.\ccif.dREN (ccif.dREN)
	.\ccif.dWEN (ccif.dWEN)
	.\ccif.daddr (ccif.daddr)
	.\ccif.dstore (ccif.dstore)
	.\dpif.dhit (dpif.dhit)
	.\dpif.dmemload (dpif.dmemload)
	.\dpif.flushed (dpif.flushed)
	.\nRST (nRST),
	.\CPUCLK (CPUCLK)
  );
`endif

task reset_dut;
  begin
	// Activate the design's reset (does not need to be synchronize with clock)
	nRST = 1'b0;

	dpif.halt = 0;
	dpif.dmemREN = 0;
	dpif.dmemWEN = 0;
	dpif.dmemstore = '0;
	dpif.dmemaddr = '0;
	
	// Wait for a couple clock cycles
	@(posedge CLK);
	@(posedge CLK);
	
	// Release the reset
	@(negedge CLK);
	nRST = 1;
	
	// Wait for a while before activating the design
	@(posedge CLK);
	@(posedge CLK);
  end
endtask
  
  // task automatic dump_memory();
	// string filename = "memcpu.hex";
	// int memfd;

	// cif0.daddr = 0;
	// cif0.dWEN = 0;
	// cif0.dREN = 0;

	// memfd = $fopen(filename,"w");
	// if (memfd)
	//   $display("Starting memory dump.");
	// else
	//   begin $display("Failed to open %s.",filename); $finish; end

	// for (int unsigned i = 0; memfd && i < 16384; i++)
	// begin
	//   int chksum = 0;
	//   bit [7:0][7:0] values;
	//   string ihex;

	//   cif0.daddr = i << 2;
	//   cif0.dREN = 1;
	//   repeat (4) @(posedge CLK);
	//   if (cif0.dload === 0)
	// 	continue;
	//   values = {8'h04,16'(i),8'h00,cif0.dload};
	//   foreach (values[j])
	// 	chksum += values[j];
	//   chksum = 16'h100 - chksum;
	//   ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
	//   $fdisplay(memfd,"%s",ihex.toupper());
	// end //for
	// if (memfd)
	// begin
	//   cif0.dREN = 0;
	//   $fdisplay(memfd,":00000001FF");
	//   $fclose(memfd);
	//   $display("Finished memory dump.");
	// end
  // endtask


initial begin
  // case -1: INIT
  tb_test_num               = -1;
  tb_test_case              = "TB Init";
  expected_out = '0;

	ccif.iREN = 0;
	ccif.iaddr = 0; // error with addr not updating!!! counterpart has to be 0
	
  reset_dut();


	dpif.halt = 0;
	dpif.dmemREN = 0;
	dpif.dmemWEN = 0;
	dpif.dmemstore = '0;
	dpif.dmemaddr = '0;
	

  // Get away from Time = 0
  #0.1; 


  // case 0: 
  reset_dut();
  tb_test_num               += 1;
  tb_test_case              = "Write data";

  dpif.dmemWEN = 1;
  dpif.dmemstore = 32'b1;
  dpif.dmemaddr = 32'b1000;

  @(posedge dpif.dhit);
  @(posedge CPUCLK);

  dpif.dmemWEN = 0;
  dpif.dmemstore = '0;
  dpif.dmemaddr = '0;

	// to put some gap
  #(2 * PERIOD);

  // case 1: 
  tb_test_num               += 1;
  tb_test_case              = "Write data to existing frame (hit)";

  dpif.dmemWEN = 1;
  dpif.dmemstore = 32'd2;
  dpif.dmemaddr = 32'b1100;

  // @(posedge dpif.dhit); // little hazard :(
  @(posedge CPUCLK);
  @(posedge CPUCLK);

  dpif.dmemWEN = 0;
  dpif.dmemstore = '0;
  dpif.dmemaddr = '0;

	// to put some gap
  #(2 * PERIOD);

  tb_test_num               += 1;
  tb_test_case              = "Read data from existing frame (hit)";

  dpif.dmemREN = 1;
  dpif.dmemaddr = 32'b1100;

  @(posedge CPUCLK);
  @(posedge CPUCLK);

  dpif.dmemREN = 0;
  dpif.dmemstore = '0;
  dpif.dmemaddr = '0;

	// to put some gap
  #(2 * PERIOD);

  // cif0.dWEN = 1;
  // cif0.iREN = 1;
  // cif0.dstore = 32'b1;
  // cif0.daddr = 32'b100;

  // #(2 * PERIOD);

  // cif0.dREN = 0;
  // cif0.dWEN = 0;

  // cif0.dstore = '0;
  // cif0.iaddr = '0;
  // cif0.daddr = '0;

  // #(2 * PERIOD);

  // // case 1: 
  // tb_test_num               += 1;
  // tb_test_case              = "Read data";

  // cif0.iREN = 1;
  // cif0.dREN = 1;
  // cif0.daddr = 32'b100;

  // #(2 * PERIOD);

  // cif0.iREN = 0;
  // cif0.dREN = 0;
  // cif0.dWEN = 0;

  // cif0.dstore = '0;
  // cif0.iaddr = '0;
  // cif0.daddr = '0;

  // dump_memory();

  // #(10 * PERIOD);

  $stop();  
end

endmodule
