// -----------------------------------------------------------------------
// (C) COPYRIGHT 2023 in ELE, CGU.
// ALL RIGHTS RESVERVED.
// -----------------------------------------------------------------------
// Course:     Digital Integrated Cirucit Design
// Homework:   HW2
// File:       HW2_MEM_WRCNT_rtb.v 
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

module MEM_WRCNTL_RTB;
  
  // I/O signals
  wire [`WL-1:0] Data_Out;
  wire WRMEM_Done, RDMEM_Done;
  reg [`WL-1:0] Data_In, TRUE_OUT;
  reg WENAB, RENAB;
  reg CLK, RESET_;
  
  // Integer variables
  integer i, j, outfile, PAT_ERROR;

  // Test module of ALU
  MEM_WRCNTL DUT_MEM_WRCNTL( .MEM_DO(Data_Out),
                             .MEM_DI(Data_In),
                             .WRMEM_Done(WRMEM_Done),
                             .RDMEM_Done(RDMEM_Done),
                             .WENAB(WENAB),
                             .RENAB(RENAB),
                             .CLK(CLK), 
                             .RESET_(RESET_) );

  //cycle time is 20ns 
  always #10 CLK=~CLK;                      
  
  // Dump fsdb file
  initial begin
    $fsdbDumpfile("HW2_MEM_WRCNTL.fsdb");
    $fsdbDumpvars(0, MEM_WRCNTL_RTB);
  end
  
  // Input pattern assignment and open file for writing error message
  initial begin

    outfile=$fopen("ALU_OUT.txt");          
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
    WENAB = 1'b1;    // active Low
    RENAB = 1'b0;    // active high
    // system reset
    #5  RESET_= 1'b0;                            
    #10 RESET_= 1'b1;
    #5  WENAB = `DLY 1'b0;
    // write operation
    $display("// ----- Write operation -----");
    
    #10
    for(i=0;i<31;i=i+1)
    begin
      #20 Data_In = Data_In - 1'b1;     
    end
    
    #10 WENAB =  (1'b1);                // disable Write enable
    #10 Data_In =  (`WL'h00_0000);
    
    // read operation
    $display("// ----- Read operation -----");  
    #50 RENAB = (1'b1);                 // enable Write enable
    #21
    for(i=0;i<31;i=i+1)
    begin
      if (Data_Out !== TRUE_OUT) 
      begin
        $fdisplay(outfile,"TRUE_OUT = %b, but Data_Out = %b.", TRUE_OUT, Data_Out);
        PAT_ERROR=PAT_ERROR+1;
      end
      #20 TRUE_OUT = TRUE_OUT - 1'b1; 
    end
    #20 RENAB =  (1'b0);                // disable Write enable
        Data_In =  (`WL'h00_0000);

    if(!PAT_ERROR)
      $display("\nCongratulations!! Your Verilog Code is correct!!\n");
    else
      $display("\nYour Verilog Code has %d errors. \nPlease read ALU_OUT.txt for details.\n",PAT_ERROR);
    
    $fclose(outfile);   
    #20 $finish;

  end // initial

endmodule
