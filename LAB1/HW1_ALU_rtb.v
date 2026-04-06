// -----------------------------------------------------------------------
// (C) COPYRIGHT 2023 in ELE, CGU.
// ALL RIGHTS RESVERVED.
// -----------------------------------------------------------------------
// Course:     Digital Integrated Cirucit Design
// Homework:   HW1
// File:       HW1_ALU_rtb.v 
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

`timescale 1ns/10ps

module ALU_RTB;
  
  // I/O signals
  reg signed [7:0]  INPUT_A, INPUT_B, TRUE_OUT;
  reg CLK, RESET_;
  reg [3:0] INSTRUCTION;
  wire signed [7:0] ALU_OUT;

  // Integer variables
  integer i, j, outfile, PAT_ERROR;

  // Test module of ALU
  ALU U_ALU( .ALU_OUT(ALU_OUT),
             .INSTRUCTION(INSTRUCTION),
             .INPUT_A(INPUT_A),
             .INPUT_B(INPUT_B),
             .CLK(CLK),
             .RESET_(RESET_));

  //cycle time is 20ns 
  always #10 CLK=~CLK;                      
  
  // Dump fsdb file
  initial begin
    $fsdbDumpfile("HW1_ALU.fsdb");
    $fsdbDumpvars(0,ALU_RTB);
  end
  
  // Input pattern assignment and open file for writing error message
  initial begin
    outfile=$fopen("ALU_OUT.txt");          
    if(!outfile) 
    begin
      $display("Can not write file!");
      $finish;
    end

    // Initial the related variables (int) and signals (reg and wire)  
    PAT_ERROR=0;

    RESET_=1'b1;
    CLK=1'b1;
    INPUT_A=0;
    INPUT_B=0;
    INSTRUCTION=4'b0000;
    
    // system reset
    #5 RESET_=1'b0;                            
    #5 RESET_=1'b1;
    
    // test for instruction 1: Add, INSTRUCTION=4'b0000;
    INSTRUCTION=4'b0000;
    $display("// INST[%b]",INSTRUCTION);
    for(i=0;i<=127;i=i+1)
    begin
      INPUT_A= i; 
      for(j=-128;j<=0;j=j+1)
      begin
        INPUT_B= j;
        #20 TRUE_OUT=INPUT_A+INPUT_B;
           if(ALU_OUT !== TRUE_OUT[7:0]) 
           begin
             $fdisplay(outfile,"INST[%b] %b + %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
             PAT_ERROR=PAT_ERROR+1;
           end                           
      end
    end
    for(i=-128;i<=0;i=i+1)
    begin
      INPUT_A= i; 
      for(j=0;j<=127;j=j+1)
      begin
        INPUT_B= j;
        #20 TRUE_OUT=INPUT_A+INPUT_B;
           if(ALU_OUT !== TRUE_OUT[7:0]) 
           begin
             $fdisplay(outfile,"INST[%b] %b + %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
             PAT_ERROR=PAT_ERROR+1;
           end                           
      end
    end     
    // test for instruction 2: Sub, INSTRUCTION=4'b0001;
    INSTRUCTION=4'b0001;
    $display("// INST[%b] ",INSTRUCTION);
    // (+) - (+)
    for(i=127;i>=0;i=i-1)
    begin
      INPUT_A = i ;
      for(j=0;j<=127;j=j+1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A-INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b - %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    // (-) - (+)
    for(i=-64;i<=0;i=i+1)
    begin
      INPUT_A = i ;
      for(j=64;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A-INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b - %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    // (-) - (-)
    for(i=-128;i<=0;i=i+1)
    begin
      INPUT_A = i ;
      for(j=-128;j<=0;j=j+1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A-INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b - %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    // (+) - (-)
    for(i=64;i>=0;i=i-1)
    begin
      INPUT_A = i ;
      for(j=-63;j<=0;j=j+1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A-INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b - %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    // test for instruction 3: NOT B, INSTRUCTION=4'b0010;
    INSTRUCTION=4'b0010;
    INPUT_A=8'h00;
    $display("// INST[%b] ",INSTRUCTION);
    for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=~INPUT_B;
        if(ALU_OUT !== TRUE_OUT[7:0]) 
        begin
          $fdisplay(outfile,"INST[%b] ~ %b should be %b. But your output is %b.",INSTRUCTION,INPUT_B,TRUE_OUT,ALU_OUT);
          PAT_ERROR=PAT_ERROR+1;
        end                           
     end
         
    // test for instruction 4: AND, INSTRUCTION=4'b0011;
    INSTRUCTION=4'b0011;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A&INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b & %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end

    // test for instruction 5: OR, INSTRUCTION=4'b0100;
    INSTRUCTION=4'b0100;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A|INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b | %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end

    // test for instruction 6: XOR, INSTRUCTION=4'b0101;
    INSTRUCTION=4'b0101;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=INPUT_A^INPUT_B;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end

    // test for instruction 7: Others, INSTRUCTION=4'b0111;
    INSTRUCTION=4'b0111;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    
    // test for instruction 8: Others, INSTRUCTION=4'b1000;
    INSTRUCTION=4'b1000;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    
    // test for instruction 9: Others, INSTRUCTION=4'b1001;
    INSTRUCTION=4'b1001;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    
    // test for instruction 10: Others, INSTRUCTION=4'b1010;
    INSTRUCTION=4'b1010;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    
    // test for instruction 111: Others, INSTRUCTION=4'b1011;
    INSTRUCTION=4'b1011;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end

    // test for instruction 12: Others, INSTRUCTION=4'b1100;
    INSTRUCTION=4'b1100;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    
    // test for instruction 13: Others, INSTRUCTION=4'b1101;
    INSTRUCTION=4'b1101;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end             
    
    // test for instruction 14: Others, INSTRUCTION=4'b1110;
    INSTRUCTION=4'b1110;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    
    // test for instruction 15: Others, INSTRUCTION=4'b1111;
    INSTRUCTION=4'b1111;
    $display("// INST[%b] ",INSTRUCTION);
    for(i=0;i<=255;i=i+1)
    begin
      INPUT_A = i;
      for(j=255;j>=0;j=j-1)
      begin
        INPUT_B = j;
        #20 TRUE_OUT=8'b0000_0000;
          if(ALU_OUT !== TRUE_OUT[7:0]) 
          begin
            $fdisplay(outfile,"INST[%b] %b ^ %b should be %b. But your output is %b.",INSTRUCTION, INPUT_A,INPUT_B,TRUE_OUT,ALU_OUT);
            PAT_ERROR=PAT_ERROR+1;
          end                           
      end
    end
    $display("\n// ----- PAT_ERROR = %d !!\n", PAT_ERROR);
    if(!PAT_ERROR)
      $display("\nCongratulations!! Your Verilog Code is correct!!\n");
    else
      $display("\nYour Verilog Code has %d errors. \nPlease read ALU_OUT.txt for details.\n",PAT_ERROR);
    
    $fclose(outfile);   
    #10 $finish;

  end // initial

endmodule
