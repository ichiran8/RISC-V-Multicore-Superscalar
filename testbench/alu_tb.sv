/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "cpu_types_pkg.vh"
`include "arithmetic_logic_if.vh"

import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module alu_tb;

  parameter PERIOD = 10;


 
  // clock

  // interface
  arithmetic_logic_if aluif ();
  // test program
  test PROG (aluif);
  // DUT
`ifndef MAPPED
  alu DUT(aluif);
`else
  alu DUT(
    .\aluif.rda (aluif.rda),
    .\aluif.rdb (aluif.rdb),
    .\aluif.result (aluif.result),
    .\aluif.zero (aluif.zero),
    .\aluif.alu_op (aluif.alu_op),
    .\aluif.overflow (aluif.overflow)
  );
`endif

endmodule

program test(arithmetic_logic_if aluif);


  task check_outputs;
    input logic [31:0] expected_result;
  begin
    if(expected_result == (aluif.result)) begin
        $display("Correct result!");
    end else begin
        $display("Incorrect result! Got this %d instead", aluif.result);
    end 
  end
  endtask 

    task check_zero;
    input logic expected_zero;
  begin
    if(expected_zero == $signed(aluif.zero)) begin
        $display("Correct result!");
    end else begin
        $display("Incorrect zero result! Got this %d instead", aluif.zero);
    end 
  end
  endtask 


    task check_negative;
    input logic expected_negative;
  begin
    if(expected_negative == $signed(aluif.negative)) begin
        $display("Correct result!");
    end else begin
        $display("Incorrect negative result! Got this %d instead", aluif.negative);
    end 
  end
    endtask

    task check_overflow;
    input logic expected_overflow;
  begin
    if(expected_overflow == $signed(aluif.overflow)) begin
        $display("Correct result!");
    end else begin
        $display("Incorrect overflow result! Got this %d instead", aluif.overflow);
    end 
  end
  endtask 



  
  initial begin
    integer i;
    aluif.rda = '0;
    aluif.rdb = '0;
    aluif.alu_op = ALU_ADD;

    // task 1 add

    aluif.rda = 32'd25;
    aluif.rdb = 32'd25;
    aluif.alu_op = ALU_ADD;
    #(10ns);
    check_outputs(32'd50);
    check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);
    #(10ns);

    // task 2 sub

    aluif.alu_op = ALU_SUB;
    #(10ns);
    check_outputs(32'd0);
        check_zero(1'b1);
    check_negative(1'b0);
    check_overflow(1'b0);

    // task 3 xor

    aluif.rda = 32'h10000001;
    aluif.rdb = 32'h01111110;
    aluif.alu_op = ALU_XOR;
    #(10ns);
    check_outputs(32'h11111111);
        check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);

    //task 4

    aluif.rda = 32'd5;
    aluif.rdb = 32'd8;

    aluif.alu_op = ALU_SLL;
    #(10ns);
    check_outputs(32'd1280);
        check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);

    //task 5 
    aluif.rda = 32'd1280;
    aluif.rdb = 32'd8;

    aluif.alu_op = ALU_SRL;
    
    #(10ns);

    check_outputs(32'd5);
        check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);

    //task 6

    aluif.rda = 32'h80000001;
    aluif.rdb = 32'd2;
    aluif.alu_op = ALU_SRA;

    #(10ns);
    check_outputs((32'hE0000000));
        check_zero(1'b0);
    check_negative(1'b1);
    check_overflow(1'b0);

  //task 7

  aluif.rda = 32'h11111111;
  aluif.rdb = 32'h0;

  aluif.alu_op = ALU_OR;
  #(10ns);
  check_outputs(32'h11111111);
      check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);

  //task 8 

  aluif.alu_op = ALU_XOR;

  #(10ns);
  check_outputs(32'h11111111);
      check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);

  //task 9

  aluif.rda = -32'd5;

  aluif.rdb = -32'd10;

  aluif.alu_op = ALU_SLT;

  #(10ns);

  check_outputs(32'h0);
      check_zero(1'b1);
    check_negative(1'b0);
    check_overflow(1'b0);


//task 10

  aluif.rda = 32'd5;

  aluif.rdb = 32'd10;

aluif.alu_op = ALU_SLTU;

#(10ns)
check_outputs(32'h1);
    check_zero(1'b0);
    check_negative(1'b0);
    check_overflow(1'b0);

//task 11
aluif.rda = 10;
aluif.rdb = 10;
aluif.alu_op = ALU_SUB;
#(10ns);

check_zero(1'b1);

//task 12

aluif.rda = 5;
aluif.rdb = 10;
#(10ns);

check_negative(1'b1);

// special task

aluif.rda = 32'd01111111011111110111111101111111;
aluif.rdb = 32'd01111111011111110111111101111111;
aluif.alu_op = ALU_ADD;

#(10ns);
check_overflow(1'b1);


end

endprogram
