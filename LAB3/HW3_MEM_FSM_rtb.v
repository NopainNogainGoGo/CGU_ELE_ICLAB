// -----------------------------------------------------------------------
// (C) COPYRIGHT 2023 in ELE, CGU.
// ALL RIGHTS RESVERVED.
// -----------------------------------------------------------------------
// Course:     Digital Integrated Cirucit Design
// Homework:   HW3
// File:       HW3_MEM_FSM_rtb.v 
// Author:     Chih-Feng Wu 
// E-mail:     tfengwu@mail.cgu.edu.tw
// TEL:        03-2118800 #3790
// Date:       3/14/2023
// Abstract:   Memory Write/Read Access Control
// -----------------------------------------------------------------------

`timescale 1ns/1ps

`define WL 24
`define AddrLEN 32
`define DLY  #1

module MEM_FSM_RTB;
  
  // I/O signals
  wire [`WL-1:0] Data_Out;
  wire WRMEM_Done, RDMEM_Done;
  reg [`WL-1:0] Data_In, TRUE_OUT;
  reg CLK, RESET_;
  
  // For FSM Signals
  reg SelfTST;
  wire WENAB_FSM, RENAB_FSM;
  // Integer variables
  integer i, j, outfile, PAT_ERROR;

  // Test module of ALU
  MEM_WRCNTL DUT_MEM_WRCNTL( .MEM_DO(Data_Out),
                             .MEM_DI(Data_In),
                             .WRMEM_Done(WRMEM_Done),
                             .RDMEM_Done(RDMEM_Done),
                             .WENAB(WENAB_FSM), // (WENAB),
                             .RENAB(RENAB_FSM), // (RENAB),
                             .CLK(CLK), 
                             .RESET_(RESET_) );

  FSM_CNTL DUT_FSM_CNTL( .WENAB(WENAB_FSM),           
                         .RENAB(RENAB_FSM),           
                         .SelfTST(SelfTST), 
                         .WRMEM_Done(WRMEM_Done),      
                         .RDMEM_Done(RDMEM_Done),
                         .CLK(CLK), 
                         .RESET_(RESET_) );

  //cycle time is 20ns 
  always #10 CLK=~CLK;                      
  
  // Dump fsdb file
  initial begin
    $fsdbDumpfile("HW3_MEM_FSM.fsdb");
    $fsdbDumpvars(0, MEM_FSM_RTB);
  end
  
  // Input pattern assignment and open file for writing error message
  initial begin

    outfile=$fopen("HW3_MEM_FSM_OUT.txt");          
    if(!outfile) 
    begin
      $display("Can not write file!");
      $finish;
    end
  end
  initial begin
  
    // Initial the related variables (int) and signals (reg and wire)  
    #0  
    PAT_ERROR=0;
    RESET_=1'b1;
    CLK=1'b1;
    Data_In =(`WL'h00_001F); // `WL'h00_0000; // 48'h0000_0000_0000;
    TRUE_OUT =(`WL'h00_001F);// `WL'h00_0000; // 48'h0000_0000_0000;
    SelfTST = 1'b0; 

    // system reset
    #5  RESET_= 1'b0;                            
    #10 RESET_= 1'b1;
    #5  SelfTST = `DLY 1'b1;
    // write operation
    $display("// ----- Write operation -----");
    
    #10
    for(i=0;i<31;i=i+1)
    begin
      #20 Data_In = Data_In - 1'b1;     
    end
    
    #10 
    $display("// ----- Read operation -----");  
    #21 Data_In =  (`WL'h00_0000);
    for (i=0;i<31;i=i+1)
    begin
//      #20 TRUE_OUT = TRUE_OUT - 1'b1; 
      if (Data_Out !== TRUE_OUT) 
      begin
        $fdisplay(outfile,"TRUE_OUT = %b, but Data_Out = %b.", TRUE_OUT, Data_Out);
        PAT_ERROR=PAT_ERROR+1;
      end          
      #20 TRUE_OUT = TRUE_OUT - 1'b1; 
    end    
    #20
    #20
    if(!PAT_ERROR)
      $display("// ----\n// Congratulations!! Reading Operation is correct !!\n// ---- \n");
    else
      $display("// ****\n// Your Verilog Code has %d errors. \n// Please read ALU_OUT.txt for details.\n// ****\n",PAT_ERROR);
    
    $fclose(outfile);   
    #20 $finish;

  end // initial

endmodule
