module execution (
    input  wire [107:0] id_ex,    // {opcode[5:0], op_a[31:0], op_b[31:0], dest_reg[4:0], is_r[0]}
    input  wire        clk,
    output wire [75:0] ex_mem    // {opcode[5:0], alu_out[31:0], dest_reg[4:0], is_r[0]}
);

    // --- unpack ID/EX ---
    wire [5:0]  opcode   = id_ex[75:70];
    wire [31:0] op_a     = id_ex[69:38];
    wire [31:0] op_b     = id_ex[37:6];
    wire [4:0]  dest_reg = id_ex[5:1];
    wire        is_r     = id_ex[0];

    // --- ALU result (32‑bit) ---
    wire [31:0] alu_out;

    // pack for EX/MEM
    wire [75:0] ex_in = { id_ex[107:76],opcode, alu_out, dest_reg, is_r };

    // instantiate ALU
    ALU a1 (
        .opcode  (opcode),
        .a       (op_a),
        .b       (op_b),
        .clk     (clk),
        .alu_out (alu_out)
    );

    // EX/MEM pipeline register
    master_slave_register3 a2 (
        .clk     (clk),
        .datain  (ex_in),
        .dataout (ex_mem)
    );

endmodule


module ALU (
    input  wire [5:0]  opcode,
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        clk,
    output reg  [31:0] alu_out
);
    always @(posedge clk) begin
        case (opcode)
            6'd0:  alu_out <= a + b;                       // ADD
            6'd1:  alu_out <= a - b;                       // SUB
            6'd2:  alu_out <= a & b;                       // AND
            6'd3:  alu_out <= a | b;                       // OR
            6'd4:  alu_out <= (a < b) ? 32'd1 : 32'd0;     // SLT
            6'd5:  alu_out <= a * b;                       // MUL
            6'd8:  alu_out <= a + b;                       // ADDI
            6'd9:  alu_out <= a + b;                       // SLTI (placeholder)
            6'd10: alu_out <= a + b;                       // ANDI (placeholder)
            6'd11: alu_out <= a - b;                       // ORI (placeholder)
            6'd12: alu_out <= (a < b) ? 32'd1 : 32'd0;     // SLLI (placeholder)
            default: alu_out <= 32'd0;
        endcase
    end
endmodule


// Parameterized master‑slave register
module master_slave_register3 (
    input  wire              clk,
    input  wire [75:0]  datain,
    output reg  [75:0]  dataout
);
    reg [75:0] a;

    always @(posedge clk) begin
        a <= datain;
    end

    always @(negedge clk) begin
        dataout <= a;
    end
endmodule
