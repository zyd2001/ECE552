/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
module cla_16b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;

    wire [3:0] P, G;
    wire [2:0] C;

    cla_4b cla0(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .S(S[3:0]), .C_out(), .P(P[0]), .G(G[0]));
    cla_4b cla1(.A(A[7:4]), .B(B[7:4]), .C_in(C[0]), .S(S[7:4]), .C_out(), .P(P[1]), .G(G[1]));
    cla_4b cla2(.A(A[11:8]), .B(B[11:8]), .C_in(C[1]), .S(S[11:8]), .C_out(), .P(P[2]), .G(G[2]));
    cla_4b cla3(.A(A[15:12]), .B(B[15:12]), .C_in(C[2]), .S(S[15:12]), .C_out(), .P(P[3]), .G(G[3]));
    carry ca(.p(P), .g(G), .c_in(C_in), .c({C_out, C}));

endmodule
