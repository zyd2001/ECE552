module control(ins, insFunc, MemRead, MemWrite, RegWrite, RegWriteAddrSel, SignExtension, ShortImmediate, Halt,
    Jump, Branch, JMux1, JMux2, ALUInB, ALUControl, WriteDataMem, WriteDataPC, exception, RTI);

    localparam HALT = 5'b00000;
    localparam NOP  = 5'b00001;

    input [4:0] ins;
    input [1:0] insFunc;
    output reg exception, RTI;
    output reg MemRead, MemWrite, RegWrite, SignExtension, ShortImmediate, Halt, 
        Jump, Branch, JMux1, JMux2, ALUInB, WriteDataMem, WriteDataPC;
    output reg [3:0] ALUControl;
    output reg [1:0] RegWriteAddrSel; 

    always @* begin
        MemRead = 0; MemWrite = 0; Halt = 0; Jump = 0; Branch = 0;
        JMux1 = 0; JMux2 = 0; exception = 0; RTI = 0;
        ALUControl = ins[3:0]; // most takes ins[3:0]
        RegWrite = 1; // most write Register
        ShortImmediate = 1; // short: extension of [4:0] bits
        RegWriteAddrSel = 2'b10; // reg write address [4:2]
        WriteDataMem = 0; // reg write from ALU
        WriteDataPC = 0; // reg write from (ALU or Mem)
        SignExtension = 1; // most Sign extended
        ALUInB = 0; // 0 for immediate
        casex (ins)
            HALT : begin Halt = 1; RegWrite = 0; end
            NOP  : begin RegWrite = 0; end
            
            // reg write address [7:5]
            // ADDI, SUBI
            5'b0100x : begin RegWriteAddrSel = 2'b01; ALUControl = {~ins[3], ins[2:0]}; end 
            // XORI ANDNI
            5'b0101x : begin RegWriteAddrSel = 2'b01; SignExtension = 0; ALUControl = {~ins[3], ins[2:0]}; end
            // ROLI, SLLI, RORI, SRLI
            5'b101xx : begin RegWriteAddrSel = 2'b01; SignExtension = 0; end

            // ST
            5'b10000 : begin MemWrite = 1; RegWrite = 0; ALUControl = 4'b0000; end
            // LD
            5'b10001 : begin MemRead = 1; WriteDataMem = 1; RegWriteAddrSel = 2'b01; ALUControl = 4'b0000; end
            // STU
            5'b10011 : begin MemWrite = 1; RegWriteAddrSel = 2'b00; ALUControl = 4'b0000; end

            // reg write address [4:2]
            // BTR, ADD, SUB, XOR, ANDN, ROL, SLL, ROR, SRL, SEQ, SLT, SLE, SCO
            5'b111xx : begin ALUInB = 1; end
            5'b1101x : begin ALUInB = 1; ALUControl = {~ins[1:0], insFunc}; end
            5'b11001 : begin ALUInB = 1; end

            // branch
            5'b011xx : begin JMux1 = 1; // select immediate
                 RegWrite = 0; Branch = 1; ShortImmediate = 0; end

            // LBI, SLBI
            5'b11000 : begin RegWriteAddrSel = 2'b00; ShortImmediate = 0; end
            5'b10010 : begin RegWriteAddrSel = 2'b00; ShortImmediate = 0; SignExtension = 0; ALUControl = 4'b1010; end

            // jump
            // J, JR
            5'b00100 : begin RegWrite = 0; Jump = 1; end
            5'b00101 : begin JMux1 = 1; JMux2 = 1; // select immediate and Rs
                RegWrite = 0; Jump = 1; ShortImmediate = 0; end
            // JAL, JALR
            5'b00110 : begin Jump = 1; RegWriteAddrSel = 2'b11; WriteDataPC = 1; end
            5'b00111 : begin JMux1 = 1; JMux2 = 1; Jump = 1; RegWriteAddrSel = 2'b11; WriteDataPC = 1; ShortImmediate = 0; end

            // SIIC, RTI
            5'b00010 : begin exception = 1; Jump = 1; RegWrite = 0; end
            5'b00011 : begin RegWrite = 0; Jump = 1; RTI = 1; end
            default: begin exception = 1; Jump = 1; RegWrite = 0; end
        endcase
    end
endmodule // control