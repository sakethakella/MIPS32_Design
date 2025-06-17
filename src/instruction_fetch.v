/* instruction_fetch.v: IF stage with PC, Instruction Memory preloaded, and pipeline register */

module instruction_fetch (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] if_id_instr,
    output wire [9:0]  if_id_pc
);
    // Program Counter
    wire [9:0] pc_current;
    program_counter pc_inst (
        .clk    (clk),
        .reset  (reset),
        .pc_out (pc_current)
    );

    // Instruction Memory (read-only in IF), preloaded with test instructions
    wire [31:0] instr;
    instruction_memory imem (
        .clk     (clk),
        .address (pc_current),
        .datain  (32'b0),
        .write   (1'b0),
        .data    (instr)
    );

    // IF/ID pipeline register (42 bits: instr[31:0] + pc[9:0])
    master_slave_register #(.WIDTH(42)) if_id_reg (
        .clk     (clk),
        .datain  ({instr, pc_current}),
        .dataout({if_id_instr, if_id_pc})
    );

endmodule


// Instruction Memory: 1K x 32-bit, preloaded with instructions
module instruction_memory (
    input  wire        clk,
    input  wire [9:0]  address,
    input  wire [31:0] datain,
    input  wire        write,
    output reg  [31:0] data
);
    reg [31:0] mem_array [0:1023];

    // Preload instructions
    initial begin
        // addi r5, r0, 100  --> opcode=8, rs=0, rt=5, imm=100
        mem_array[0] = 32'h20050064;
        // add  r6, r5, r5   --> R-type: opcode=0, rs=5, rt=5, rd=6, shamt=0, funct=32
        mem_array[1] = 32'h00A53020;
        // sw   r6, 0(r0)    --> opcode=43, rs=0, rt=6, imm=0
        mem_array[2] = 32'hAC060000;
        // lw   r7, 0(r0)    --> opcode=35, rs=0, rt=7, imm=0
        mem_array[3] = 32'h8C070000;
        // nop (sll $0,$0,0)
        mem_array[4] = 32'h00000000;
    end

    always @(posedge clk) begin
        if (write)
            mem_array[address] <= datain;
        data <= mem_array[address];
    end
endmodule


// Program Counter: increments each cycle
module program_counter (
    input  wire       clk,
    input  wire       reset,
    output reg [9:0]  pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 10'd0;
        else
            pc_out <= pc_out + 10'd1;
    end
endmodule


// Master-slave pipeline register
module master_slave_register #(
    parameter WIDTH = 1
)(
    input  wire             clk,
    input  wire [WIDTH-1:0] datain,
    output reg  [WIDTH-1:0] dataout
);
    reg [WIDTH-1:0] tmp;
    always @(posedge clk) tmp     <= datain;
    always @(negedge clk) dataout <= tmp;
endmodule
