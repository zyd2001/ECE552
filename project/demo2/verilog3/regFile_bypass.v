/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
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

	output [15:0] read1Data;
	output [15:0] read2Data;
	output        err;

	wire [15:0] interRead1Data, interRead2Data;
	
	assign read1Data = (writeEn & (read1RegSel === writeRegSel)) ? writeData : interRead1Data;
	assign read2Data = (writeEn & (read2RegSel === writeRegSel)) ? writeData : interRead2Data;
	
	regFile rf0 (
			// Outputs
			.read1Data                    (interRead1Data[15:0]),
			.read2Data                    (interRead2Data[15:0]),
			.err                          (err),
			// Inputs
			.clk                          (clk),
			.rst                          (rst),
			.read1RegSel                  (read1RegSel[2:0]),
			.read2RegSel                  (read2RegSel[2:0]),
			.writeRegSel                  (writeRegSel[2:0]),
			.writeData                    (writeData[15:0]),
			.writeEn                      (writeEn));

endmodule
