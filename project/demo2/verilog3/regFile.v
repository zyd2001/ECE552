/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

	input        clk, rst;
	input [2:0]  read1RegSel;
	input [2:0]  read2RegSel;
	input [2:0]  writeRegSel;
	input [15:0] writeData;
	input        writeEn;

	output reg [15:0] read1Data;
	output reg [15:0] read2Data;
	output err;

    reg writeErr, read1Err, read2Err;
	reg [7:0] writeReg;
	wire [7:0] enables;
	wire [16*8-1:0] out;

	assign enables = (writeEn) ? writeReg : 8'b0;
    assign err = writeErr | read1Err | read2Err;

	reg16 regs[7:0](.clk(clk), .rst(rst), .en(enables), .rdata(out), .wdata(writeData));

	always @* begin
		writeReg = 8'h00;
		writeErr = 1'b0;
		case (writeRegSel) 
			3'b000 : writeReg = 8'h01;
			3'b001 : writeReg = 8'h02;
			3'b010 : writeReg = 8'h04;
			3'b011 : writeReg = 8'h08;
			3'b100 : writeReg = 8'h10;
			3'b101 : writeReg = 8'h20;
			3'b110 : writeReg = 8'h40;
			3'b111 : writeReg = 8'h80;
			default: writeErr = 1'b1;
		endcase
    end

    always @* begin
        read1Data = 8'h00;
        read1Err = 1'b0;
		case (read1RegSel) 
			3'b000 : read1Data = out[15:0];
			3'b001 : read1Data = out[31:16];
			3'b010 : read1Data = out[47:32];
			3'b011 : read1Data = out[63:48];
			3'b100 : read1Data = out[79:64];
			3'b101 : read1Data = out[95:80];
			3'b110 : read1Data = out[111:96];
			3'b111 : read1Data = out[127:112];
			default: read1Err = 1'b1;
		endcase
    end

    always @* begin
        read2Data = 8'h00;
        read2Err = 1'b0;
		case (read2RegSel) 
			3'b000 : read2Data = out[15:0];
			3'b001 : read2Data = out[31:16];
			3'b010 : read2Data = out[47:32];
			3'b011 : read2Data = out[63:48];
			3'b100 : read2Data = out[79:64];
			3'b101 : read2Data = out[95:80];
			3'b110 : read2Data = out[111:96];
			3'b111 : read2Data = out[127:112];
			default: read2Err = 1'b1;
		endcase
	end
endmodule
