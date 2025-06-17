`include "instruction_fetch.v"
`include "instruction_decode.v"
`include "execution.v"
`include "memory_access.v"
`include "write_back.v"

module pipeline (
    input  wire clk,
    input  wire reset
);
    wire [31:0] if_id;
    wire [107:0]id_ex;
    wire [75:0] ex_mem;
    wire [43:0] mem_wb;
    wire reg_write;  
    wire  [4:0]  write_reg;  
    wire  [31:0] write_data ;
    instruction_fetch ifstage(clk,if_id);
    instruction_decode idstage(clk,if_id,reg_write,write_reg,write_data,id_ex);
    execution exstage(id_ex,clk,ex_mem);
    memory_access memstage(ex_mem,clk,mem_wb);
    write_back wbstage(clk,1'b0,mem_wb,reg_write,write_reg,write_data);
    
  
endmodule
