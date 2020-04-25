// dff with enable
module dffre (q, d, en, clk, rst);
    input d, en, clk, rst;
    output q;

    wire in, o;
    
    assign in = (en) ? d : o;
    assign q = ~o;

    dff ff(.q(o), .d(in), .clk(clk), .rst(rst));
endmodule