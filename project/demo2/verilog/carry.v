module carry(p, g, c_in, c);
    input [3:0] p, g;
    input c_in;
    output [3:0] c; // 4-bits carry signal generated

    wire [3:0] notG, notP, nandPC;
    wire [3:0] notC; // not of C_in, C[0], C[1], C[2]

    wire p0c0; //wire for c1
    wire p1g0, p1p0c0; //wire for c2
    wire p2g1, p2p1g0, p2p1p0c0; //wire for c3
    wire p3g2, p3p2g1, p3p2p1g0, p3p2p1p0c0; //wire for c4
    wire nc1, nc2;
    
    //c1
    assign p0c0 = p[0] & c_in;
    assign c[0] = g[0] | p0c0;

    //c2
    assign p1g0 = p[1] & g[0];
    assign p1p0c0 = p[1] & p0c0;
    assign c[1] = g[1] | p1g0 | p1p0c0;

    //c3
    assign p2g1 = p[2] & g[1];
    assign p2p1g0 = p[2] & p1g0;
    assign p2p1p0c0 = p[2] & p1p0c0;
    assign c[2] = g[2] | p2g1 | p2p1g0 | p2p1p0c0;

    //c4
    assign p3g2 = p[3] & g[2];
    assign p3p2g1 = p[3] & p2g1;
    assign p3p2p1g0 = p[3] & p2p1g0;
    assign p3p2p1p0c0 = p[3] & p2p1p0c0;
    assign c[3] = g[3] | p3g2 | p3p2g1 | p3p2p1g0 | p3p2p1p0c0;
endmodule