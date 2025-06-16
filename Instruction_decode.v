module instruction_decode (
    input clk,
    input [31:0] instruction,
    output [106:0] id_ex
);
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [15:0] imm = instruction[15:0];
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] imm_extended;
    wire [106:0] id_ex_temp;
    wire is_r_type, is_i_type;
    assign is_r_type = (opcode >= 6'b000000 && opcode <= 6'b000101);
    assign is_i_type = (opcode >= 6'b001000 && opcode <= 6'b001100);
    wire [4:0] dest_reg = is_r_type ? rd : rt;
    wire [31:0] b_val = is_r_type ? reg_data2 : 32'd0;
    wire [31:0] imm_val = is_i_type ? imm_extended : 32'd0;

    register_bank a2 (
        .clk(clk),
        .reset(1'b0),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(5'd0),
        .write_data(32'd0),
        .reg_write(1'b0),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    sign_extension a3 (
        .a(imm),
        .b(imm_extended)
    );

    assign id_ex_temp = {
        opcode,       
        reg_data1,     
        b_val,         
        dest_reg,      
        imm_val       
    };

    master_slave_register a1 (
        .clk(clk),
        .datain(id_ex_temp),
        .dataout(id_ex)
    );
endmodule

module register_bank (
    input clk,
    input reset,                  
    input [4:0] read_reg1,        
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,
    input reg_write,             
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers [31:0]; 
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    always @(posedge clk) begin
        registers[0]=32'd0;
        if (reset) begin
            integer i;
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && write_reg != 5'd0) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

module master_slave_register (
    input clk,
    input [106:0] datain,
    output reg [106:0] dataout
);
    reg [106:0] a;
    always @(posedge clk)begin
        a<=datain;
    end
    always @(negedge clk)begin
        dataout<=a;
    end
endmodule

module sign_extension(
    input [15:0] a,
    output [31:0] b
);
    assign b= {{16{a[15]}},a};
endmodule