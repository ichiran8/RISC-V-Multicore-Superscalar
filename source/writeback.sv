`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
module writeback(
    control_unit.cuif cif,
    register_file_if.rf rfif
);
cif.alu_src = 0; // choosing whether or not we take a value to r2 or immediate
    cif.regwrite = 0; // determine whether or not we write into a register
    cif.memwrite = 0; // determine whether or not we write into memory
    cif.memread = 0; // determine whether or not we are reading from memory
    cif.memreg = 0; // determine whether or not we take the value from memory or the alu result to be written back 
    cif.alu_op = ALU_ADD; // alu operation
    cif.jump = 1'b0; // jump for JAL and JALR (write back block); I think AUIPC too?

always_comb begin
    rfif.wdat = '0;
    if() begin
    end
end

endmodule