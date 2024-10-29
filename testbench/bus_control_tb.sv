`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
import cpu_types_pkg::*;

`timescale 1 ns / 1 ns

module bus_control_tb();

parameter PERIOD = 10;

caches_if cif0();
caches_if cif1();
system_if syif();
cache_control_if ccif(cif0, cif1);
  // signals
  logic CLK = 1, nRST;


    integer tb_test_num;
    string tb_test_case;
  // clock
  always #(PERIOD/2) CLK++;


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

    bus_control DUT(CLK, nRST, ccif);
    
    initial begin
        tb_test_case = "";
        tb_test_num = 0;
        cif0.iREN = 1'b0;
        cif0.dREN = 1'b0;
        cif0.dWEN = 1'b0;
        cif0.dstore = 32'hABCABCAB;
        cif0.daddr = '0;
        cif0.iaddr = '0;
        cif0.cctrans = 0;
        cif0.ccwrite = 0;

        cif1.iREN =  1'b0;
        cif1.dREN =  1'b0;
        cif1.dWEN = 1'b0;
        cif1.dstore = 32'hABCABCAB;
        cif1.daddr = '0;
        cif1.iaddr = '0;

        ccif.ramstate = BUSY;
        ccif.ramload = '0;
        //ccif.ccwrite = 0;
        cif1.cctrans = 0;
        cif1.ccwrite = 0;
        nRST = 1'b0;
        //ccif.cctrans = 0;
        reset_dut();
        // test case #1 

        tb_test_num               += 1;
        tb_test_case              = "I fetch (post reset, LRU should choose iREN)";
        cif0.iREN = 1'b1;
        cif1.iREN = 1'b1;
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        ccif.ramload = 32'h12345678;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        cif0.iREN = 0;
        cif1.iREN = 0;
        @(posedge CLK);

        tb_test_num               += 1;
        tb_test_case              = "DWEN ; LRU should choose core 0 then core 1";
        cif0.dWEN = 1;
        cif1.dWEN = 1;
        cif0.daddr = 32'hABCABCAB;
        cif1.daddr = 32'hABCABCAB;
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        cif0.dWEN = 0;
        cif1.dWEN = 0;
        @(posedge CLK);
        @(posedge CLK);

        tb_test_num               += 1;
        tb_test_case              = "DREN ; LRU should choose core 0 then core 1";
        cif1.daddr = 32'h12345670; // MSI = Invalid ; main memory transaction
        cif0.daddr = 32'h12345678;
        cif0.dREN = 1'b1;
        ccif.ramstate = BUSY;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        cif1.daddr = 32'h12345673;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        cif1.daddr = 32'h12345672;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        @(posedge CLK);
        ccif.ramstate = ACCESS;
        @(posedge CLK);
        ccif.ramstate = BUSY;
        cif0.dREN = 1'b0;
        @(posedge CLK);
        
        $stop();
    end
endmodule