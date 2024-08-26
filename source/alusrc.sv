`include "alusrc_if.vh"
module alusrc (
    alusrc_if.src sc
);

assign sc.portB = (sc.alu_src) ? sc.imm_gen : sc.rdat2;

endmodule