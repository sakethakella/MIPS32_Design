/* memory_access.v: MEM stage and DataMemory for load/store */

module memory_access (
    input  wire [75:0] ex_mem,    // {store_data[31:0], opcode[5:0], alu_result[31:0], dest_reg[4:0], is_r[0]} = 76 bits
    input  wire        clk,
    output wire [43:0] mem_wb     // {opcode[5:0], wb_data[31:0], dest_reg[4:0], is_load[0]} = 44 bits
);
    // --- unpack EX/MEM ---
    wire [31:0] store_data = ex_mem[75:44];
    wire [5:0]  opcode     = ex_mem[43:38];
    wire [31:0] alu_out    = ex_mem[37:6];
    wire [4:0]  dest_reg   = ex_mem[5:1];
    // wire        is_r       = ex_mem[0]; // not used here

    // Load/Store control
    wire mem_read  = (opcode == 6'd35); // LW opcode
    wire mem_write = (opcode == 6'd43); // SW opcode

    // Data memory interface
    wire [31:0] mem_rdata;
    DataMemory dm (
        .clk        (clk),
        .addr       (alu_out),
        .write_data (store_data),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .read_data  (mem_rdata)
    );

    // Select write-back data
    wire [31:0] wb_data = mem_read ? mem_rdata : alu_out;
    wire        is_load = mem_read;

    // pack for MEM/WB
    wire [43:0] memwb_in = { opcode, wb_data, dest_reg, is_load };

    // MEM/WB pipeline register
    master_slave_register4 memwb_reg (
        .clk     (clk),
        .datain  (memwb_in),
        .dataout (mem_wb)
    );
endmodule


// Simple synchronous DataMemory: 1K words x 32 bits
module DataMemory (
    input  wire        clk,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    input  wire        mem_write,
    input  wire        mem_read,
    output reg  [31:0] read_data
);
    reg [31:0] mem_array [0:1023];

    always @(posedge clk) begin
        if (mem_write) begin
            mem_array[ addr[11:2] ] <= write_data;
        end
        if (mem_read) begin
            read_data <= mem_array[ addr[11:2] ];
        end
    end
endmodule


// Parameterized master-slave register for pipelining
module master_slave_register4(
    input  wire [43:0] datain,
    input  wire  clk,
    output reg  [43:0] dataout
);
    reg [43:0] a;
    always @(posedge clk) a <= datain;
    always @(negedge clk) dataout <= a;
endmodule
