// -----------------------------------------------------------------------
// (C) COPYRIGHT 2023 in ELE, CGU.
// ALL RIGHTS RESVERVED.
// -----------------------------------------------------------------------
// Course:     Digital Integrated Cirucit Design
// Homework:   HW2
// File:       HW2_MEM_WRCNT_rtl.v 
// Author:     Chih-Feng Wu 
// E-mail:     tfengwu@mail.cgu.edu.tw
// TEL:        03-2118800 #3790
// Date:       3/14/2023
// Abstract:   Memory Write/Read Access Control
// -----------------------------------------------------------------------
`timescale 1ns / 1ps
`define DLY     #1      // CLK-q delay
`define IC_ENAB
`define WL      24
`define AddrLEN 32

module MEM_WRCNTL (
    MEM_DO,
    MEM_DI,
    WRMEM_Done,
    RDMEM_Done,
    WENAB,
    RENAB,
    CLK,
    RESET_
);
    // ----------------------------------------
    // I/O signals
    // ----------------------------------------
    output [`WL-1:0]    MEM_DO;      // data output of memory
    wire   [`WL-1:0]    MEM_DO;
    
    output              WRMEM_Done;  // Done signal for WR and RD
    output              RDMEM_Done;  // Done signal for WR and RD
    reg                 WRMEM_Done;
    reg                 RDMEM_Done;

    input  [`WL-1:0]    MEM_DI;      // data input of memory
    input               WENAB;       // Write enable
    input               RENAB;       // Read enable
    input               CLK;         // clock
    input               RESET_;      // reset

    // ----------------------------------------
    // Declaration for internal control signals
    // ----------------------------------------
    reg [4:0]           ADDR_CNT;
    reg                 ACNT_ENAB;
    reg                 WEN;

    // ----------------------------------------
    // Design
    // ----------------------------------------

    // Address Counter
    always @(posedge CLK or negedge RESET_) begin
        if (!RESET_)
            ADDR_CNT <= `DLY 5'd0;
        else if (ACNT_ENAB)
            ADDR_CNT <= `DLY ADDR_CNT + 5'd1;
        else
            ADDR_CNT <= `DLY 5'd0;
    end

    // ACNT_ENAB logic
    assign ACNT_ENAB = (!WENAB || RENAB);

    // WEN (Write active low, Read active high)
    always @(*) begin
        if (!WENAB)
            WEN = 1'b0;
        else
            WEN = 1'b1;
    end

    // WRMEM_Done
    always @(posedge CLK or negedge RESET_) begin
        if (!RESET_)
            WRMEM_Done <= `DLY 1'b0;
        else if (ADDR_CNT == 5'd31 && !WENAB)
            WRMEM_Done <= `DLY 1'b1;
        else
            WRMEM_Done <= `DLY 1'b0;
    end

    // RDMEM_Done
    always @(posedge CLK or negedge RESET_) begin
        if (!RESET_)
            RDMEM_Done <= `DLY 1'b0;
        else if (ADDR_CNT == 5'd31 && RENAB)
            RDMEM_Done <= `DLY 1'b1;
        else
            RDMEM_Done <= `DLY 1'b0;
    end

    // ----------------------------------------
    // Register file instantiation
    // ----------------------------------------
`ifdef IC_ENAB
    RF1_32x24b DUT_MEM (
        .Q    (MEM_DO),
        .CLK  (CLK),
        .CEN  (1'b0),     // 0 表示啟用，1 表示閒置
        .WEN  (WEN),      // add your wr/rd enable signal
        .A    (ADDR_CNT), // add your address bus
        .D    (MEM_DI)
    );
`else
    // MEM Design for evaluation
`endif

endmodule                