/* write_back.v: Sequential WB stage with pipeline register
 *
 * This module registers the MEM/WB signals on the clock edge,
 * then outputs the write-back control signals for the register file.
 */

module write_back (
    input  wire        clk,
    input  wire        reset,
    input  wire [43:0] mem_wb,      // { opcode[5:0], wb_data[31:0], dest_reg[4:0], is_load[0] }
    output reg         reg_write,   // enable register write
    output reg  [4:0]  write_reg,   // destination register index
    output reg  [31:0] write_data   // data to write into register
);

    // Pipeline register for MEM/WB latch
    reg [43:0] wb_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_reg     <= 44'b0;
            reg_write  <= 1'b0;
            write_reg  <= 5'd0;
            write_data <= 32'd0;
        end else begin
            // Register incoming MEM/WB signals
            wb_reg <= mem_wb;

            // Write-back enabled for all instructions except SW (opcode 43)
            reg_write  <= (wb_reg[43:38] != 6'd43);
            write_reg  <= wb_reg[5:1];
            write_data <= wb_reg[37:6];
        end
    end

endmodule
