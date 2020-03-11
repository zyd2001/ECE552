module control(ins, insFunc, MemRead, MemWrite, RegWrite, RegWriteAddrSel, SignExtension, ShortImmediate, Halt,
    Jump, Branch, JMux1, JMux2, ALUInB, ALUControl, WriteDataMem, WriteDataPC, err);

    localparam HALT = 5'b00000;
    localparam NOP  = 5'b00001;

    input [4:0] ins;
    input [1:0] insFunc;
    output err;
    output reg MemRead, MemWrite, RegWrite, SignExtension, ShortImmediate, Halt, 
        Jump, Branch, JMux1, JMux2, ALUInB, WriteDataMem, WriteDataPC;
    output reg [3:0] ALUControl;
    output reg [1:0] RegWriteAddrSel; 

    reg ALUErr, controlErr;
    assign err = ALUErr | controlErr;

    always @* begin // for ALUControl
        ALUControl = 0;
        casex ({ins})
            // ADDI..
            5'b010xx : ALUControl = {~ins[3], ins[2:0]};
            // Shift I
            5'b101xx : ALUControl = ins[3:0];
            // LD, ST
            5'b1000x : ALUControl = 4'b0000;
            5'b10011 : ALUControl = 4'b0000;
            // ADD.. Shift
            5'b1101x : ALUControl = {~ins[1:0], insFunc};
            // SEQ..
            5'b111xx : ALUControl = ins[3:0];
            // BTR
            5'b11001 : ALUControl = ins[3:0];
            // LBI
            5'b11000 : ALUControl = ins[3:0];
            // SLBI
            5'b10010 : ALUControl = 4'b1010;
            default: ALUErr = 1;
        endcase
    end

    always @* begin
        MemRead = 0; MemWrite = 0; RegWriteAddrSel = 2'b0; Halt = 0; Jump = 0; Branch = 0; err = 0;
        JMux1 = 0; JMux2 = 0;
        RegWrite = 1; // most write Register
        ShortImmediate = 1; // short: extension of [4:0] bits
        RegWriteAddrSel = 2'b10; // reg write address [4:2]
        WriteDataMem = 0; // reg write from ALU
        WriteDataPC = 0; // reg write from (ALU or Mem)
        SignExtension = 1; // most Sign extended
        ALUInB = 0; // 0 for immediate
        casex (ins)
            HALT : Halt = 1;
            NOP  : Halt = 0;
            
            // reg write address [7:5]
            // ADDI, SUBI
            2'b0100x : begin RegWriteAddrSel = 2'b01; end 
            // XORI ANDNI
            2'b0101x : begin RegWriteAddrSel = 2'b01; SignExtension = 0; end
            // ROLI, SLLI, RORI, SRLI
            2'b101xx : begin RegWriteAddrSel = 2'b01; SignExtension = 0; end

            // ST
            2'b10000 : begin MemWrite = 1; RegWrite = 0; end
            // LD
            2'b10001 : begin MemRead = 1; WriteDataMem = 1; RegWriteAddrSel = 2'b01; end
            // STU
            2'b10011 : begin MemWrite = 1; RegWriteAddrSel = 2'b11 end

            // reg write address [4:2]
            // BTR, ADD, SUB, XOR, ANDN, ROL, SLL, ROR, SRL, SEQ, SLT, SLE, SCO
            2'b11xxx : begin ALUInB = 1; end

            // branch
            2'b011xx : begin JMux1 = 1; // select immediate
                 RegWrite = 0; Branch = 1; ShortImmediate = 0; end

            // LBI, SLBI
            2'b11000 : begin RegWriteAddrSel = 2'b00; ShortImmediate = 0; end
            2'b10010 : begin RegWriteAddrSel = 2'b00; ShortImmediate = 0; SignExtension = 0; end

            // jump
            // J, JR
            2'b00100 : begin RegWrite = 0; Jump = 1; end
            2'b00101 : begin JMux1 = 1; JMux2 = 1; // select immediate and Rs
                RegWrite = 0; Jump = 1; ShortImmediate = 0; end
            // JAL, JALR
            2'b00110 : begin Jump = 1; RegWriteAddrSel = 2'b11; WriteDataPC = 1; end
            2'b00111 : begin JMux1 = 1; JMux2 = 1; Jump = 1; RegWriteAddrSel = 2'b11; WriteDataPC = 1; ShortImmediate = 0; end

            default: controlErr = 1;
        endcase
    end
endmodule // control