 `include "cache_control_if.vh"
 `include "cpu_types_pkg.vh"
 `include "cpu_ram_if.vh"
 `include "caches_if.vh"
 `include "system_if.vh"
 import cpu_types_pkg::*;
 

`timescale 1 ns / 1 ns
 module memory_control_tb();

cpu_ram_if ramif();
caches_if cif0();
caches_if cif1();
system_if syif();
cache_control_if ccif(cif0, cif1);

parameter PERIOD = 10;

logic CLK = 0, nRST;

integer i;

// clock
always #(PERIOD/2) CLK++;

parameter CLKDIV = 2;
  logic CPUCLK;
  logic [3:0] count;
  //logic CPUnRST;

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

task automatic dump_memory();
    string filename = "memcpu.hex";
    int memfd;

    //cif0.tbCTRL = 1;
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
      //cif0.tbCTRL = 0;
      cif0.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask


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
assign ramif.ramaddr = ccif.ramaddr;
assign ramif.ramstore = ccif.ramstore;
assign ramif.ramREN = ccif.ramREN;
assign ramif.ramWEN = ccif.ramWEN;
assign ccif.ramstate = ramif.ramstate;
assign ccif.ramload = ramif.ramload;
`ifndef MAPPED
    ram  DUTRAM(CLK, nRST, ramif);
`else 
    ram DUTRAM(
        .CLK(CLK),
        .nRST(nRST),
        .\ramif.ramaddr(ramif.ramaddr),
        .\ramif.ramstore(ramif.ramstore),
        .\ramif.ramREN(ramif.ramREN),
        .\ramif.ramWEN(ramif.ramWEN),
        .\ramif.ramstate(ramif.ramstate),
        .\ramif.ramload(ramif.ramload)
    );
`endif
`ifndef MAPPED
  memory_control DUT(CLK, nRST, ccif);
`else
  memory_control DUT(
    .CLK(CLK),
    .nRST(nRST),
    .\ccif.iREN(ccif.iREN),
    .\ccif.dREN(ccif.dREN),
    .\ccif.dWEN(ccif.dWEN),
    .\ccif.dstore(ccif.dstore),
    .\ccif.iaddr(ccif.iaddr),
    .\ccif.daddr(ccif.daddr),
    .\ccif.ramload(ccif.ramload),
    .\ccif.ramstate(ccif.ramstate),
    .\ccif.ccwrite(ccif.ccwrite),
    .\ccif.cctrans(ccif.cctrans),
    .\ccif.iwait(ccif.iwait),
    .\ccif.dwait(ccif.dwait),
    .\ccif.iload(ccif.iload),
    .\ccif.dload(ccif.iload),
    .\ccif.ramstore(ccif.ramstore),
    .\ccif.ramaddr(ccif.ramaddr),
    .\ccif.ramWEN(ccif.ramWEN),
    .\ccif.ramREN(ccif.ramREN),
    .\ccif.ccwait(ccif.ccwait),
    .\ccif.ccinv(ccif.ccinv),
    .\ccif.ccsnoopaddr(ccif.ccsnoopaddr)
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
    reset_dut();
    #(10ns);
    cif0.iREN = 1'b1;
    cif0.dREN = 1'b0;
    cif0.dWEN = 1'b0;
    cif0.dstore = 32'hABCABCAB;
    cif0.daddr = '0;
    cif0.iaddr = '0;

    for(i = 0; i < 30; i = i + 1) begin
        cif0.iaddr = cif0.iaddr + 4;
        @(posedge CPUCLK);
    end
    // store word
    #(100ns);
    cif0.iREN = 1'b1;
    cif0.dWEN = 1'b1;
    cif0.daddr = 32'hF1F1F1FC;
    for(i = 0; i < 30; i = i + 1) begin
        cif0.daddr = cif0.daddr + 4;
        cif0.dstore = cif0.dstore + 1;
        @(posedge CPUCLK);
    end

    // load word
    #(1000ns);
    @(posedge CPUCLK);
    cif0.iREN = 1'b0;
    cif0.dWEN = 1'b0;
    cif0.dREN = 1'b1;
    cif0.daddr = 32'hF1F1F1FC;
    @(posedge CPUCLK);
    for(i = 0; i < 30; i = i + 1)begin
        cif0.daddr = cif0.daddr + 4;
        @(posedge CPUCLK);
    end
    //reset_dut();
    dump_memory();
    $stop(1);
end

 endmodule
