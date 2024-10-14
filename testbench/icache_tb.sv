// mapped needs this
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module icache_tb;
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
  integer i;

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
caches_if cif0();
caches_if cif1();

cache_control_if ccif (.cif0(cif0), .cif1(cif1));
cpu_ram_if ramif ();

  // ram (can't find it if you don't use name RAM??)
ram RAM(CLK, nRST, ramif);
memory_control mc(CLK, nRST, ccif);

  assign ccif.ramload = ramif.ramload;
  assign ccif.ramstate = ramif.ramstate;

  assign ramif.ramREN = ccif.ramREN;
  assign ramif.ramWEN = ccif.ramWEN;
  assign ramif.ramaddr = ccif.ramaddr;
  assign ramif.ramstore = ccif.ramstore;

icache DUT(CPUCLK, nRST, dpif, cif0);


task reset_dut;
  begin
	// Activate the design's reset (does not need to be synchronize with clock)
	nRST = 1'b0;	
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
  
  task automatic dump_memory();
	string filename = "memcpu.hex";
	int memfd;

	cif0.daddr = 0;
	cif0.dWEN = 0;
	cif0.dREN = 0;

	memfd = $fopen(filename,"w");
	if (memfd)
	  $display("Starting memory dump.");
	else
	  begin $display("Failed to open %s.",filename); $finish; end

	for (int unsigned i = 0; memfd && i < 16384; i++)
	begin
	  int chksum = 0;
	  bit [7:0][7:0] values;
	  string ihex;

	  cif0.daddr = i << 2;
	  cif0.dREN = 1;
	  repeat (4) @(posedge CLK);
	  if (cif0.dload === 0)
		continue;
	  values = {8'h04,16'(i),8'h00,cif0.dload};
	  foreach (values[j])
		chksum += values[j];
	  chksum = 16'h100 - chksum;
	  ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
	  $fdisplay(memfd,"%s",ihex.toupper());
	end //for
	if (memfd)
	begin
	  cif0.dREN = 0;
	  $fdisplay(memfd,":00000001FF");
	  $fclose(memfd);
	  $display("Finished memory dump.");
	end
  endtask


initial begin
  // case 0 : INIT
  tb_test_num               = 0;
  tb_test_case              = "Reset DUT";
	cif0.daddr = '0;
	cif0.dREN = 0;
	cif0.dWEN = 0;
	cif0.iREN = 0;
	cif0.iaddr = 0;
    dpif.halt = 0;
    dpif.dmemREN = 0;
    dpif.dmemWEN = 0;
    dpif.imemREN = 1; // only two signals we care about
    dpif.imemaddr = 0; // only two signals that we care about 
    dpif.dmemstore = 0;
    dpif.dmemaddr = 0;
	
  reset_dut();

#(PERIOD * 2)

  // case 1: 
  reset_dut();
  tb_test_num               += 1;
  tb_test_case              = "Read Data miss";

for(i = 0; i < 16; i = i + 1) begin 
    @(posedge dpif.ihit);
    @(posedge CLK);
	@(posedge CLK);
	dpif.imemaddr += 4'b0100;
end

	// to put some gap
	dpif.imemREN = 0;
	dpif.imemaddr = 0;
	i = 0;
  #(2 * PERIOD);

  // case 2: 
  tb_test_num               += 1;
  tb_test_case              = "Read hit";

	dpif.imemREN = 1'b1;
  dpif.imemaddr = 0;
  #(PERIOD * 2);
	@(posedge CLK);
for(i = 0; i < 16; i = i +1) begin 
    //@(posedge dpif.ihit);
    @(posedge CLK);
	@(posedge CLK);
	dpif.imemaddr += 4'b0100;
end

	
    @(negedge CLK);
    dpif.imemREN = 1'b0;
    
	@(negedge CLK);
	dump_memory();
  $stop();  
end

endmodule
