/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out);
    input  A, B;
    input  C_in;
    output S;
    output C_out;

    assign S = A ^ B ^ C_in;
    assign C_out = (A & C_in) | (B & C_in) | (A & B);

endmodule
