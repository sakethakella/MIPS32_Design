module instruction_fetch (
    input clk,
    output [31:0] output_if
);
    wire [31:0] output_;
    wire [9:0] address;
    reg [31:0] datain=32'b0;
    reg write =1'b0;
    instruction_memory a1(clk,address,datain,write,output_);
    master_slave_register1 a2(clk,output_,output_if);
    program_counter a3(clk,address);
endmodule

module instruction_memory (
    input clk,
    input [9:0] address,
    input [31:0] datain,
    input write,
    output reg [31:0] data
);

    reg [31:0] ram [0:1023]; 

    always @(posedge clk) begin
        if (write)
            ram[address] <= datain;
        else if (!write)
            data <= ram[address];
        else
            data <= 32'b0; 
    end
endmodule

module program_counter(
    input clk,
    output reg [9:0] next_address
);
    reg [9:0] address=10'b0;
    always @(posedge clk)begin
        next_address<=address;
        address<=address+10'd1;
    end
endmodule

module master_slave_register1 (
    input clk,
    input [31:0] datain,
    output reg [31:0] dataout
);
    reg [31:0] a;
    always @(posedge clk)begin
        a<=datain;
    end
    always @(negedge clk)begin
        dataout<=a;
    end
endmodule