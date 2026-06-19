// -----------------------------------------------------------------------
// (C) COPYRIGHT 2023 in ELE, CGU.
// ALL RIGHTS RESVERVED.
// -----------------------------------------------------------------------
// Course:     Digital Integrated Cirucit Design
// Homework:   HW3
// File:       HW3_FSM_CNTl_rtl.v 
// Author:     Chih-Feng Wu 
// E-mail:     tfengwu@mail.cgu.edu.tw
// TEL:        03-2118800 #3790
// Date:       3/14/2023
// Abstract:   Memory Write/Read Access Control
// -----------------------------------------------------------------------

`timescale  1 ns / 1ps
`define DLY #1

module FSM_CNTL ( WENAB,           // O/P
                  RENAB,           // O/P
                  SelfTST, 
                  WRMEM_Done,      
                  RDMEM_Done,
                  CLK, RESET_ );
  
  // I/O signals
  output reg WENAB, RENAB;       // Write/Read enable
  input SelfTST;
  input WRMEM_Done, RDMEM_Done;
  input CLK, RESET_;        // clock and RESET_

  // local declaration
  parameter [1:0] ST0=2'b00, ST1=2'b01, ST2=2'b10, ST3=2'b11; 
  // Internal control signals
  reg [1:0] Current_ST, Next_ST;   

  // ----
  // my design 

  always @(posedge CLK or negedge RESET_) begin
      if(!RESET_) Current_ST <= ST0;
      else        Current_ST <= `DLY Next_ST;
  end

 always @(*) begin
     case(Current_ST)
         ST0: Next_ST = SelfTST ? ST1 : ST0;
         ST1: Next_ST = WRMEM_Done ? ST2 : ST1;
         ST2: Next_ST = RDMEM_Done ? ST3 : ST2;
         ST3: Next_ST = ST3; 
         default: Next_ST = ST0; 
     endcase
 end


  always @(*) begin
       case(Current_ST)
           ST0: {WENAB, RENAB} = 2'b00;
           ST1: begin
               // 當 WRMEM_Done 為 1 時，代表寫入已完成
               // 提前在 ST1 的最後一拍將 WENAB 拉高 (1) 並將 RENAB 拉高 (1) 準備讀取
               if (WRMEM_Done) {WENAB, RENAB} = 2'b11; 
               else            {WENAB, RENAB} = 2'b00;
           end
           ST2: begin
               // 當 RDMEM_Done 為 1 時，代表讀取已完成
               // 提前在 ST2 的最後一拍將 RENAB 拉低 (0) 回到閒置狀態
               if (RDMEM_Done) {WENAB, RENAB} = 2'b10;
               else            {WENAB, RENAB} = 2'b11;
           end
           ST3: {WENAB, RENAB} = 2'b10;
           default: {WENAB, RENAB} = 2'b10;
       endcase
 end
  // ----

endmodule                       