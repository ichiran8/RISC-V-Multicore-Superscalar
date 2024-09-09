 `include "cache_control_if.vh"
 `include "cpu_types_pkg.vh"
 `include "cpu_ram_if.vh"
 `include "caches_if.vh"
 `include "system_if.vh"
 import cpu_types_pkg::*;
 

`timescale 1 ns / 1 ns
 module request_unit_tb;

request_unit_if ruif();

parameter PERIOD = 10;

logic CLK = 0, nRST;

integer i;

// clock
always #(PERIOD/2) CLK++;

task reset_dut;
  begin
    nRST = 1'b0;

    @(posedge CLK);
    @(posedge CLK);

    @(negedge CLK);

    nRST = 1'b1;

    @(negedge CLK);
    @(negedge CLK);
  end
  endtask

  task check_outputs;
    input expected_i, expected_dR, expected_dW, expected_pc;
    begin
        if(expected_i == ruif.imemREN)
            $display("correct imemREN");
        else
            $display("incorrect imemREN");
        if(expected_dR == ruif.dmemREN)
            $display("correct dmemREN");
        else   
            $display("incorrect dmemREN");
        if(expected_dW == ruif.dmemWEN)
            $display("correct dmemWEN");
        else
            $display("incorrect dmemWEN");
        if(expected_pc == ruif.pc_enable)
            $display("correct pc");
        else
            $display("incorrect pc");
    end
  endtask

`ifndef MAPPED
    request_unit  DUT(CLK, nRST, ruif);
`else 
    request_unit DUT(
        .CLK(CLK),
        .nRST(nRST),
        .\ruif.imemREN(ruif.imemREN),
        .\ruif.dmemREN(ruif.dmemREN),
        .\ruif.dmemWEN(ruif.dmemWEN),
        .\ruif.memread(ruif.memread),
        .\ruif.memwrite(ruif.memwrite),
        .\ruif.dhit(ruif.dhit),
        .\ruif.ihit(ruif.ihit),
        .\ruif.pc_enable(ruif.pc_enable)
    );
`endif

// // controller ports to ram and caches
//   modport cc (
//             // cache inputs
//     input   iREN, dREN, dWEN, dstore, iaddr, daddr,
//             // ram inputs
//             ramload, ramstate,
//             // coherence inputs from cache
//             ccwrite, cctrans,
//             // cache outputs
//     output  iwait, dwait, iload, dload,
//             // ram outputs
//             ramstore, ramaddr, ramWEN, ramREN,
//             // coherence outputs to cache
//             ccwait, ccinv, ccsnoopaddr
//   );
initial begin

    // reset)
    ruif.memread = 1'b0;
    ruif.memwrite = 1'b0;
    ruif.ihit = 1'b0;
    ruif.dhit = 1'b0;
    // reset
    reset_dut();
    check_outputs(1'b1, 1'b0, 1'b0, 1'b0);


    // first instruction fetch
    @(posedge CLK);
    check_outputs(1'b1, 1'b0, 1'b0, 1'b0);
   
   ruif.ihit = 1'b1;
   ruif.memread = 1'b1;
   @(posedge CLK);
   @(posedge CLK);
   check_outputs(1'b1, 1'b1, 1'b0, 1'b1);

   ruif.memread = 1'b1;
   ruif.ihit = 1'b0;
   ruif.dhit = 1'b1;
   @(posedge CLK);
   @(posedge CLK);
   check_outputs(1'b1, 1'b0, 1'b0, 1'b0);
    
    ruif.memread = 1'b0;
    ruif.ihit = 1'b1;
    ruif.dhit = 1'b0;
    ruif.memwrite = 1'b1;
    @(posedge CLK);
    @(posedge CLK);
    check_outputs(1'b1, 1'b0, 1'b1, 1'b1);

    ruif.dhit = 1'b1;
    ruif.ihit = 1'b0;
    @(posedge CLK);
    @(posedge CLK);
    check_outputs(1'b1, 1'b0, 1'b0, 1'b0);




    $stop(1);
end

 endmodule
