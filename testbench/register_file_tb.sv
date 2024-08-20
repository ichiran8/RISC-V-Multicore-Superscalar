/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (CLK, nRST, rfif);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test(input logic CLK, output logic nRST, register_file_if rfif);

  integer i;
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
    input logic [31:0] expected_wdat, expected_rdat1, expected_rdat2;
  begin
    // if(expected_wdat == rfif.wdat) begin
    //   $display("correct wdat value!");
    // end else begin
    //   $display("Incorrect wdat value! Got %d", rfif.wdat);
    // end

    if(expected_rdat1 == rfif.rdat1) begin
      $display("correct rdat1 value!");
    end else begin
      $display("Incorrect rdat1 value! Got %d", rfif.rdat1);
    end


    if(expected_rdat2 == rfif.rdat2) begin
      $display("correct rdat2 value!");
    end else begin
      $display("Incorrect rdat2 value! Got %d", rfif.rdat2);
    end
  end
  endtask 

  
  initial begin
    nRST = 1'b1; // initialize the reset 
    rfif.rsel1 = '0;
    rfif.rsel2 = '0;
    rfif.wsel = '0;
    rfif.wdat = '0;


    // reset 
    reset_dut;

    rfif.WEN = 1'b1;
    check_outputs('0, '0, '0);

    @(negedge CLK);


    // test 1
    reset_dut();
    rfif.wdat = 32'd10;
    rfif.wsel = 32'b0;
    
    @(posedge CLK);

    rfif.rsel1 = '0;

    @(posedge CLK);

    check_outputs('0, '0, '0);

    // test 2
    reset_dut();
    //integer i;

    for(i = 1; i < 32; i = i + 1) begin
      rfif.wsel = i;
      //rfif.rsel1 = i;
      @(posedge CLK);
      rfif.rsel1 = i;
      @(posedge CLK);
      check_outputs('0, 32'd10, '0);

    end


  end

endprogram
