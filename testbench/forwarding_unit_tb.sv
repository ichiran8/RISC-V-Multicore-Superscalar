// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module forwarding_unit_tb;
  import cpu_types_pkg::*;

  regbits_t id_ex_rsel1, id_ex_rsel2, ex_mem_wsel, mem_wb_wsel;
  logic ex_mem_regwrite, mem_wb_regwrite;
  logic [1:0] forwardA, forwardB;

  logic [1:0] expected_forwardA, expected_forwardB;

  integer tb_test_num;
  string  tb_test_case;

  // DUT
  forwarding_unit DUT(
    id_ex_rsel1,
    id_ex_rsel2,
    ex_mem_wsel,
    mem_wb_wsel,
    ex_mem_regwrite,
    mem_wb_regwrite,
    forwardA,
    forwardB
  );

initial begin
  // case 0: INIT
  tb_test_num               = 0;
  tb_test_case              = "TB Init";

  id_ex_rsel1 = 0;
  id_ex_rsel2 = 0;
  ex_mem_wsel = 0;
  mem_wb_wsel = 0;
  ex_mem_regwrite = 0;
  mem_wb_regwrite = 0;

  expected_forwardA = 0;
  expected_forwardB = 0;

  // Get away from Time = 0
  #10; 

  // case 1
  tb_test_num               = 1;
  tb_test_case              = "Forward to A from ex_mem to id_ex";

  ex_mem_regwrite = 1;
  mem_wb_regwrite = 0;
  ex_mem_wsel = 2;
  id_ex_rsel1 = 2;

  expected_forwardA = 2;
  expected_forwardB = 0;

  #10; 


  // case 2
  tb_test_num               += 1;
  tb_test_case              = "Forward to A from mem_wb to id_ex";

  ex_mem_regwrite = 0;
  mem_wb_regwrite = 1;
  ex_mem_wsel = 0;
  mem_wb_wsel = 3;
  id_ex_rsel1 = 3;

  expected_forwardA = 1;
  expected_forwardB = 0;

  #10; 


  // case 3
  tb_test_num               += 1;
  tb_test_case              = "Forward to B from ex_mem to id_ex";

  ex_mem_regwrite = 1;
  mem_wb_regwrite = 0;
  ex_mem_wsel = 2;
  id_ex_rsel1 = 0;
  id_ex_rsel2 = 2;

  expected_forwardA = 0;
  expected_forwardB = 2;

  #10; 


  // case 4
  tb_test_num               += 1;
  tb_test_case              = "Forward to A and B from mem_wb to id_ex";

  ex_mem_regwrite = 0;
  mem_wb_regwrite = 1;
  ex_mem_wsel = 0;
  mem_wb_wsel = 3;
  id_ex_rsel1 = 3;
  id_ex_rsel2 = 3;

  expected_forwardA = 1;
  expected_forwardB = 1;

  #10; 


  // case 4
  tb_test_num               += 1;
  tb_test_case              = "Prioritize ex_mem to mem_wb (closer instruction)";

  ex_mem_regwrite = 1;
  mem_wb_regwrite = 1;
  ex_mem_wsel = 2;
  mem_wb_wsel = 2;
  id_ex_rsel1 = 2;

  expected_forwardA = 2;
  expected_forwardB = 0;

  #10; 

  $stop();  
end

endmodule
