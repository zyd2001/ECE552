/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
module cla_4b(A, B, C_in, S, C_out, P, G);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out, P, G;

    wire [3:0] g, p;
    wire [2:0] C;

    //generate p, g for every bit
    assign p = A | B;
    assign g = A & B;

    //generate P and G
    assign P = &p;

    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

    fullAdder_1b fa[3:0](.A(A), .B(B), .C_in({C, C_in}), .S(S), .C_out());
    carry ca(.p(p), .g(g), .c_in(C_in), .c({C_out, C}));

endmodule
