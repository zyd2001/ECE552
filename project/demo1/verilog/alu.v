/*
    CS/ECE 552 Spring '20
    Homework #2, Problem 2

    A 16-bit ALU module.  It is designed to choose
    the correct operation to perform on 2 16-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the 16-bit result
    of the operation, as well as output a Zero bit and an Overflow
    (OFL) bit.
*/
module alu (InA, InB, Op, Out, err);

    // declare constant for size of inputs, outputs (N),
    // and operations (O)
    parameter    N = 16;
    parameter    O = 4;

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam XOR  = 4'b0010;
    localparam ANDN = 4'b0011;
    localparam SHFT = 4'b01xx;
    localparam SEQ  = 4'b1100;
    localparam SLT  = 4'b1101;
    localparam SLE  = 4'b1110;
    localparam SCO  = 4'b1111;
    localparam BTR  = 4'b1001;
    localparam LBI  = 4'b1000;
    localparam SLBI = 4'b1010;
    
    input [N-1:0] InA;
    input [N-1:0] InB;
    input [O-1:0] Op;
    output reg [N-1:0] Out;
    output reg err;

    wire [N-1:0] shift, add, A, B;
    wire zero;
    wire sub;
    wire slt;
    reg subA, subB;

    assign A = (subA) ? ~InA : InA;
    assign B = (subB) ? ~InB : InB;
    assign sub = subA | subB;
    assign slt = (InA[15] == InB[15]) ? add[15] : InA[15];

    cla_16b cla(.A(A), .B(B), .C_in(sub), .S(add), .C_out(cout));
    shifter sf(.In(A), .Cnt(B[3:0]), .Op(Op[1:0]), .Out(shift));

    assign zero = ~|add;

    always @* begin
        err = 0; Out = 0; subA = 0; subB = 0;
        casex (Op)
            ADD : Out = add; 
            SUB : begin Out = add; subA = 1; end
            XOR : Out = A ^ B;
            ANDN: Out = A & ~B;
            SHFT: Out = shift;
            SEQ : begin Out = zero; subB = 1; end
            SLT : begin Out = slt; subB = 1; end
            SLE : begin Out = slt | zero; subB = 1; end
            SCO : Out = cout;
            BTR : Out = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],A[11],A[12],A[13],A[14],A[15]};
            LBI : Out = B;
            SLBI: Out = {A[7:0], 8'b0} | B;
            default: err = 1;
        endcase
    end
    
endmodule
