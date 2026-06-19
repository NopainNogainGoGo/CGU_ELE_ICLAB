`timescale 1ns/10ps
`define WL 9
`include "Hw4_3bitCLA_rtl - Student.v"

module Hw4_9bitCLA ( 
    input [`WL-1:0] X,
    input [`WL-1:0] Y,
    input Cin,
    output [`WL-1:0] Sum,
    output Cout,
    output OV 
);

    wire [2:0] G_LCG;   
    wire [2:0] P_LCG;    
    wire [3:0] Carry_in; 

    assign Carry_in[0] = Cin;
    assign Carry_in[1] = G_LCG[0] |  (P_LCG[0] & Carry_in[0]);
    assign Carry_in[2] = G_LCG[1] |  (P_LCG[1] & G_LCG[0]) |  (P_LCG[1] & P_LCG[0] & Carry_in[0]);      
    assign Carry_in[3] = G_LCG[2] |  (P_LCG[2] & G_LCG[1]) |  (P_LCG[2] & P_LCG[1] & G_LCG[0]) |  (P_LCG[2] & P_LCG[1] & P_LCG[0] & Carry_in[0]);
    assign Cout = Carry_in[3];

    Hw4_3bitCLA CLA_1 (
        .X(X[2:0]),
        .Y(Y[2:0]),
        .Cin(Carry_in[0]),
        .Sum(Sum[2:0]),
        .G(G_LCG[0]),
        .P(P_LCG[0])
    );

    Hw4_3bitCLA CLA_2 (
        .X(X[5:3]),
        .Y(Y[5:3]),
        .Cin(Carry_in[1]),
        .Sum(Sum[5:3]),
        .G(G_LCG[1]),
        .P(P_LCG[1])
    );

    Hw4_3bitCLA CLA_3 (
        .X(X[8:6]),
        .Y(Y[8:6]),
        .Cin(Carry_in[2]),
        .Sum(Sum[8:6]),
        .G(G_LCG[2]),
        .P(P_LCG[2])
    );

    // OV = (X_sign == Y_sign) && (Sum_sign != X_sign)
    assign OV = (X[`WL-1] ~^ Y[`WL-1]) & (Sum[`WL-1] ^ X[`WL-1]);

endmodule