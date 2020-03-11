module shift_right(In, Cnt, Op, Out);
    parameter   N = 16;
    parameter   C = 4;

    input [N-1:0]   In;
    input [C-1:0]   Cnt;
    input Op;
    output [N-1:0]  Out;
    
    wire [N-1:0] shift_1, shift_2, shift_4;

    assign shift_1 = (Cnt[0]) ? {((Op) ? 1'b0 : In[15]), In[15: 1]} : In;
    assign shift_2 = (Cnt[1]) ? {{2{(Op) ? 1'b0 : shift_1[15]}}, shift_1[15: 2]} : shift_1;
    assign shift_4 = (Cnt[2]) ? {{4{(Op) ? 1'b0 : shift_2[15]}}, shift_2[15: 4]} : shift_2;
    assign Out = (Cnt[3]) ? {{8{(Op) ? 1'b0 : shift_4[15]}}, shift_4[15: 8]} : shift_4;

endmodule // shift_right