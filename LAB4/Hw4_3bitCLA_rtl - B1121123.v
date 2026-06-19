`timescale 1ns/10ps
`include "Hw4_1bitCLA_rtl - Student.v"
module Hw4_3bitCLA (
    input [2:0] X,
    input [2:0] Y,
    input Cin,
    output [2:0] Sum,
    output  G, // Group Generate
    output  P  // Group Propagate
);

    wire [2:0] G_LCG;   // 3-bit lookahead carry generate from sub-modules
    wire [2:0] P_LCG;   // 3-bit lookahead carry propagate from sub-modules
    wire [2:0] Carry_in;


    assign Carry_in[0] = G_LCG[0] | (P_LCG[0] & Cin);
    assign Carry_in[1] = G_LCG[1] | (P_LCG[1] & G_LCG[0]) | (P_LCG[1] & P_LCG[0] & Cin);  
    assign Carry_in[2] = G_LCG[2] | (P_LCG[2] & G_LCG[1]) | (P_LCG[2] & P_LCG[1] & G_LCG[0]) | (P_LCG[2] & P_LCG[1] & P_LCG[0] & Cin); 

    
    Hw4_1bitCLA cla_1 (
        .X(X[0]),
        .Y(Y[0]),
        .Cin(Cin),
        .Sum(Sum[0]),
        .G(G_LCG[0]),
        .P(P_LCG[0])
    );

    Hw4_1bitCLA cla_2 (
        .X(X[1]),
        .Y(Y[1]),
        .Cin(Carry_in[0]),
        .Sum(Sum[1]),
        .G(G_LCG[1]),
        .P(P_LCG[1])
    );

    Hw4_1bitCLA cla_3 (
        .X(X[2]),
        .Y(Y[2]),
        .Cin(Carry_in[1]),
        .Sum(Sum[2]),
        .G(G_LCG[2]),
        .P(P_LCG[2])
    );

    assign P = P_LCG[2] & P_LCG[1] & P_LCG[0];
    assign G = G_LCG[2] | (P_LCG[2] & G_LCG[1]) | (P_LCG[2] & P_LCG[1] & G_LCG[0]);

endmodule


/*
module Hw4_3bitCLA (
    input [2:0] X,
    input [2:0] Y,
    input Cin,
    output [2:0] Sum,
    output  G,
    output  P
);
wire [2:0] G_LCG ;   // 3-bit lookahead carry generate
wire [2:0] P_LCG ;   // 3-bit lookahead carry propagate
wire [3:0] Carry_in; // Expanded to 4 bits [3:0] for clean matching

assign Carry_in[0] = Cin;

genvar i;
generate
    for(i=0; i<3; i=i+1) begin: logit
        assign P_LCG[i] = X[i] ^ Y[i];
        assign G_LCG[i] = X[i] & Y[i];
        assign Sum[i] = P_LCG[i] ^ Carry_in[i];
    end
endgenerate

assign Carry_in[1] = G_LCG[0] | (P_LCG[0] & Carry_in[0]);
assign Carry_in[2] = G_LCG[1] | (P_LCG[1] & G_LCG[0]) |  (P_LCG[1] & P_LCG[0] & Carry_in[0]);  
assign Carry_in[3] = G_LCG[2] |  (P_LCG[2] & G_LCG[1]) |  (P_LCG[2] & P_LCG[1] & G_LCG[0]) |  (P_LCG[2] & P_LCG[1] & P_LCG[0] & Carry_in[0]); // Fixed: Cin[0] to Carry_in[0]

assign P = P_LCG[2] & P_LCG[1] & P_LCG[0];
assign G = G_LCG[2] | (P_LCG[2] & G_LCG[1]) | (P_LCG[2] & P_LCG[1] & G_LCG[0]);

endmodule
*/