`include "cpu_types_pkg.vh"
`include "writeback_if.vh"

import cpu_types_pkg::*;
module writeback(
    writeback_if.wb wbif
);


always_comb begin
    wbif.wdat = '0;
    if(wbif.jump || wbif.jalr) begin
        wbif.wdat = wbif.pc_add; // jal and jalr will have this where R[rd] = pc + 4;
    end else if(!wbif.memreg) begin
        wbif.wdat = wbif.result;
    end else if (wbif.cauipc) begin
        wbif.wdat = wbif.pc + wbif.result;
    end else if(wbif.memreg) begin
        wbif.wdat = wbif.memread_data;
    end else begin
        wbif.wdat = '0;
    end
end

endmodule