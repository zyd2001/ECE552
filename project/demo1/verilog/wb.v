/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (MemData, ALUData, PCData, WriteDataMem, WriteDataPC, writeData);
    input [15:0] MemData, ALUData, PCData;
    input WriteDataMem, WriteDataPC;
    output [15:0] writeData;

    assign writeData = (WriteDataPC) ? PCData : ((WriteDataMem) ? MemData : ALUData);
endmodule
