module reg16(en, wdata, rdata, clk, rst);
	input clk, rst, en;
	input [15:0] wdata;
	output [15:0] rdata;
	
	wire [15:0] in;
	
	assign in = (en) ? wdata : rdata;
	
	dff ff[15:0](.q(rdata), .d(in), .rst(rst), .clk(clk));
endmodule