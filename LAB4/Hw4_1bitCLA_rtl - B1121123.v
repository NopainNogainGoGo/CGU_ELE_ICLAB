`timescale 1ns/10ps
module Hw4_1bitCLA (
    input X,
    input Y,
    input Cin,
    output Sum,
    output G,
    output P
);

assign P = X ^ Y;
assign G = X & Y;
assign Sum = P ^ Cin; //  X ^ Y ^ Cin

endmodule
