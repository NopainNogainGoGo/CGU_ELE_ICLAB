// -----------------------------------------------------------------------
// (C) COPYRIGHT 2023 in ELE, CGU.
// ALL RIGHTS RESERVED.
// -----------------------------------------------------------------------
// Course:     Digital Integrated Circuit Design
// Homework:   HW1
// File:       HW1_ALU_rtl.v 
// Author:     Chih-Feng Wu 
// E-mail:     tfengwu@mail.cgu.edu.tw
// TEL:        03-2118800 #3790
// Date:       3/14/2023
// Abstract:   A 8-bit ALU design with 4-bit instruction set
// -----------------------------------------------------------------------
//           | instruction[3:0] | operation         | Notes
// -----------------------------------------------------------------------
//           |     0000         | 2'sc addition     | X=A+B
//           |     0001         | 2'sc subtraction  | X=A-B
//           |     0010         | NOT               | X=~B
//           |     0011         | AND               | X=A&B
//           |     0100         | OR                | X=A|B
//           |     0101         | XOR               | X=A^B
//           |     others       | no operation      | --> output is zero
// -----------------------------------------------------------------------

`timescale 1ns/100ps

module ALU ( ALU_OUT,      // alu output
             INSTRUCTION,  // instruction input
             INPUT_A,      // input A
             INPUT_B,      // input B
             CLK,          // clock
             RESET_);      // reset
  
  // output declaration      
  output signed [7:0] ALU_OUT;
  reg signed [7:0] ALU_OUT;
  
  // input declaration
  input signed [7:0] INPUT_A, INPUT_B;
  input [3:0] INSTRUCTION;
  input CLK, RESET_;
  
  // You need to add your design here.

  // Decoder 
  reg [6:0]decode; 

  always @(*) begin
      decode = 7'b000_0000; // Default: all off
      case(INSTRUCTION)
          4'b0000: decode[0] = 1'b1; // ADD
          4'b0001: decode[1] = 1'b1; // SUB
          4'b0010: decode[2] = 1'b1; // NOT
          4'b0011: decode[3] = 1'b1; // AND
          4'b0100: decode[4] = 1'b1; // OR
          4'b0101: decode[5] = 1'b1; // XOR
          default: decode[6] = 1'b1; // Others 
      endcase
  end


  reg [7:0] X;                    
  reg [7:0] adder_op_b;   
  wire [7:0] NOT_B = ~INPUT_B;
  wire [7:0] sum_result = INPUT_A + adder_op_b;
  wire [7:0] inc_result = sum_result + 8'd1;
  
  always @(*) begin
    X = 8'd0;
    adder_op_b = INPUT_B; 
      case(decode)
        7'b0_000_001: // A + B
          X = sum_result;

        7'b0_000_010: begin // A + (~B + 1)
          adder_op_b = NOT_B;
          X = inc_result;
        end

        7'b0_000_100:  // NOT: ~B
          X = NOT_B;
        
        7'b0_001_000: // AND: A & B
            X = INPUT_A & INPUT_B;
        
        7'b0_010_000: // OR: A | B
            X = INPUT_A | INPUT_B;
        
        7'b0_100_000: // XOR: A ^ B
            X = INPUT_A ^ INPUT_B;
        
        default: // Others: No operation
            X = 8'd0;
      endcase
  end

  always @(posedge CLK or negedge RESET_) begin
    if (!RESET_) 
      ALU_OUT <= 8'd0;
    else 
      ALU_OUT <= X;
  end

endmodule
