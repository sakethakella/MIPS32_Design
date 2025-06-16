module instruction_decode ();
    
endmodule


module master_slave_register (
    input clk,
    input [101:0] datain,
    output reg [101:0] dataout
);
    reg [101:0] a;
    always @(posedge clk)begin
        a<=datain;
    end
    always @(negedge clk)begin
        dataout<=a;
    end
endmodule