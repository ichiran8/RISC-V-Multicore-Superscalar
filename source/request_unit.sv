`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"
module request_unit(
    input logic CLK, nRST, request_unit_if.ru ruif
);

    logic next_imemREN, next_dmemREN, next_dmemWEN;

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            immREN <= 1'b0;
            dmemREN <= 1'b0;
            dmemWEN <= 1'b0;
        end else begin
            imemREN <= next_imemREN;
            dmemREN <= next_dmemREN;
            dmemWEN <= next_dmemWEN;
        end
    end

    always_comb begin
        
        if(ruif.memread) begin
        
        end else if(ruiif.memwrite) begin
        
        end else begin
        
        end
    end

endmodule



  // datapath ports
  modport dp (
    input   ihit // instruction hit
    , imemload // instuction memload
    , dhit // data hit
    , dmemload // data mem load,
    output  halt // irrelevant for what I am doing at the VERY moment
    , imemREN // instruction read enable
    , imemaddr // instruction memory address
    , dmemREN // data memory read enable (lw)
    , dmemWEN// datamemory write enable (sw)
    , datomic // idk
    ,
            dmemstore // data to store to memory (sw)
            ,dmemaddr // data memory address
  );