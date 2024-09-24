`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module hazard_unit_tb;

  // clock

  logic id_ex_memread, branch, jump, halt, PCWrite, if_id_write, if_flush, id_flush, ex_flush;
  logic [4:0] id_ex_rd, if_id_rs1, if_id_rs2;
  

  hazard_unit DUT(.id_ex_memread(id_ex_memread), .id_ex_rd(id_ex_rd), .if_id_rs1(if_id_rs1), .if_id_rs2(if_id_rs2), .PCWrite(PCWrite), .if_id_write(if_id_write), .branch(branch), .jump(jump), .halt(halt), .if_flush(if_flush), .id_flush(id_flush), .ex_flush(ex_flush));

//     input logic id_ex_memread,
//     input regbits_t id_ex_rd,
//     input regbits_t if_id_rs1,
//     input regbits_t if_id_rs2,
//     output logic PCWrite,
//     output logic if_id_write,
//     // we don't use top right now

//     input logic branch,
//     input logic jump,
//     input logic halt,
//     output logic if_flush,
//     output logic id_flush,
//     output logic ex_flush

task check_outputs;
    input logic expected_if_flush, expected_id_flush, expected_ex_flush, expected_pcwrite, expected_if_idwrite;
    begin
        if(expected_if_flush == if_flush)
            $display("correct");
        else
            $display("Incorrect if_flush, wanted %d", if_flush);

        if(expected_id_flush == id_flush)
            $display("correct");
        else
            $display("Incorrect id_flush, wanted %d", id_flush);

        if(expected_ex_flush == ex_flush)
            $display("correct");
        else
            $display("Incorrect, ex_flush, wanted %d", ex_flush);

        if(expected_pcwrite == PCWrite)
            $display("correct");
        else
            $display("Incorrect pcwrite, wanted %d", PCWrite);

        if(expected_if_idwrite == if_id_write)
            $display("correct");
        else
            $display("Incorrect if_id_write, wanted %d", if_id_write);
    end
endtask
initial begin
    id_ex_memread = 1'b0;
    id_ex_rd = 5'd0;
    if_id_rs1 = 5'd0;
    if_id_rs2 = 5'd0;
    branch = 1'b0;
    jump = 1'b0;
    halt = 1'b0;

    #10;
    check_outputs(0, 0, 0, 1, 1);
    id_ex_memread = 1'b1;
    id_ex_rd = 5'd2;
    #10;
    //    input logic expected_if_flush, expected_id_flush, expected_ex_flush, expected_pcwrite, expected_if_idwrite;

    check_outputs(0, 0, 0, 1, 1);

    if_id_rs1 = 5'd2;
    #10;
    check_outputs(0, 1, 0, 0, 0);


    if_id_rs2 = 5'd2;
    #10;
    check_outputs(0, 1, 0, 0, 0);

    jump = 1'b1;
    #10;
    check_outputs(1, 1, 0, 0, 0);
    jump = 1'b0;
    branch = 1'b1;
    #10;
    check_outputs(1, 1, 1, 0, 0);

    branch = 1'b0;
    halt = 1'b1;
    #10;
    check_outputs(1, 1, 0, 0, 0);

    branch = 1'b1;
    jump = 1'b1;
    #10;
    check_outputs(1, 1, 1, 0, 0);

    if_id_rs1 = 0;
    if_id_rs2 = 0;
    #10;
    check_outputs(1, 1, 1, 1, 1);    
    $stop();
end
endmodule

// module hazard_unit (
//     input logic id_ex_memread,
//     input regbits_t id_ex_rd,
//     input regbits_t if_id_rs1,
//     input regbits_t if_id_rs2,
//     output logic PCWrite,
//     output logic if_id_write,
//     // we don't use top right now

//     input logic branch,
//     input logic jump,
//     input logic halt,
//     output logic if_flush,
//     output logic id_flush,
//     output logic ex_flush
// );
//     always_comb begin : BRANCH_JUMP_HAZARDING
//         if_flush = jump | halt | branch;
//         id_flush = jump | halt | branch;
//         ex_flush = branch;
//         PCWrite = 1;
//         if_id_write = 1;
//         if(id_ex_memread && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) begin
//              PCWrite = 0;
//              if_id_write = 0;
//              id_flush = 1;
//          end
//     end