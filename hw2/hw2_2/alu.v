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
module alu (InA, InB, Cin, Op, invA, invB, sign, Out, Zero, Ofl);

    // declare constant for size of inputs, outputs (N),
    // and operations (O)
    parameter    N = 16;
    parameter    O = 3;
    
    input [N-1:0] InA;
    input [N-1:0] InB;
    input         Cin;
    input [O-1:0] Op;
    input         invA;
    input         invB;
    input         sign;
    output [N-1:0] Out;
    output         Ofl;
    output         Zero;

    wire [N-1:0] shift, add, A, B;
    wire cout, pos, neg;

    assign A = (invA) ? ~InA : InA;
    assign B = (invB) ? ~InB : InB;

    cla_16b cla(.A(A), .B(B), .C_in(Cin), .S(add), .C_out(cout));
    shifter sf(.In(A), .Cnt(B[3:0]), .Op(Op[1:0]), .Out(shift));

    assign neg = A[15] & B[15]; // both negative
    assign pos = ~(A[15] | B[15]); // both positive
    assign Ofl = (Op == 3'b100) ? ((sign) ? (pos & add[15] | neg & ~add[15]) : (cout)) : 1'b0;
    assign Zero = ~|Out;
    assign Out = (~Op[2]) ? shift : 
                ((Op[1:0] == 2'b00) ? add : 
                ((Op[1:0] == 2'b01) ? A & B : 
                ((Op[1:0] == 2'b10) ? A | B : A ^ B)));
    
endmodule
