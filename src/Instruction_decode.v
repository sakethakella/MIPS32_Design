/* instruction_decode.v: Corrected Instruction Decode with proper concatenation and widths */

module instruction_decode (
    input  wire        clk,
    input  wire [31:0] instruction,
    input  wire        write_data12,       // reg_write from WB
    input  wire [4:0]  write_address1,     // wb_dest
    input  wire [31:0] write_data1,        // wb_data
    output wire [107:0] id_ex               // ID/EX bus (108 bits)
);
    // --- Decode instruction fields ---
    wire [5:0]  opcode = instruction[31:26];
    wire [4:0]  rs     = instruction[25:21];
    wire [4:0]  rt     = instruction[20:16];
    wire [4:0]  rd     = instruction[15:11];
    wire [15:0] imm    = instruction[15:0];

    // --- Register file read with write-back ---
    wire [31:0] reg_data1, reg_data2;
    register_bank rf (
        .clk        (clk),
        .reset      (1'b0),
        .read_reg1  (rs),
        .read_reg2  (rt),
        .write_reg  (write_address1),
        .write_data (write_data1),
        .reg_write  (write_data12),
        .read_data1 (reg_data1),
        .read_data2 (reg_data2)
    );

    // --- Sign extension for I-type ---
    wire [31:0] imm_extended;
    sign_extension se(
        .a(imm),
        .b(imm_extended)
    );

    // --- Determine instruction type and operands ---
    wire is_r_type = (opcode >= 6'b000000 && opcode <= 6'b000101);
    wire [4:0] dest_reg = is_r_type ? rd : rt;
    wire [31:0] b_val    = is_r_type ? reg_data2 : imm_extended;

    // --- Build ID/EX pipeline bus ---
    // [107:102] opcode (6 bits)
    // [101:70]  reg_data1 (32 bits)
    // [69:38]   b_val (32 bits)
    // [37:33]   dest_reg (5 bits)
    // [32]      is_r_type (1 bit)
    // [31:0]    reserved/pad (zeros)
    wire [107:0] id_ex_temp = {
        opcode,
        reg_data1,
        b_val,
        dest_reg,
        is_r_type,
        32'd0
    };

    // --- Register for ID/EX ---
    master_slave_register2 #(.WIDTH(108)) id_ex_reg (
        .clk     (clk),
        .datain  (id_ex_temp),
        .dataout (id_ex)
    );
endmodule

// Register file module
module register_bank (
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,
    input  wire        reg_write,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] regs [31:0];
    integer i;

    assign read_data1 = regs[read_reg1];
    assign read_data2 = regs[read_reg2];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
            regs[0] <= 32'd0;
            if (reg_write && write_reg != 5'd0)
                regs[write_reg] <= write_data;
        end
    end
endmodule

// Master-slave pipeline register
module master_slave_register2 #(
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

// Sign extension module
module sign_extension(
    input  wire [15:0] a,
    output wire [31:0] b
);
    assign b = {{16{a[15]}}, a};
endmodule
