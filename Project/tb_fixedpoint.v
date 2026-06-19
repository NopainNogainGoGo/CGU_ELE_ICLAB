`timescale 1ns / 1ps
`define SDFFILE    "CORDIC_syn.sdf"   
`define CYCLE      10.0   

module tb;

    reg clk;
    reg rst_n;
    reg start;
    reg signed [31:0] y_in;
    reg signed [31:0] x_in;

    wire signed [31:0] q_out;   
    wire done;

    `ifdef SDF
    initial $sdf_annotate(`SDFFILE, uut);
    `endif

    cordic_fixedpoint uut (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .y_in  (y_in),
        .x_in  (x_in),
        .q_out (q_out),
        .done  (done)
    );

    // 時脈 100 MHz (週期 10 ns)
    initial clk = 0;
    always begin #(`CYCLE/2) clk = ~clk; end

    initial begin
        $fsdbDumpfile("cordic.fsdb");
        $fsdbDumpMDA;
        $fsdbDumpvars;
    end

    // 等待 done
    task wait_done;
        integer timeout;
        begin
            timeout = 0;
            while (done !== 1'b1) begin
                @(posedge clk);
                timeout = timeout + 1;
                if (timeout > 1000) begin
                    $display("[TIMEOUT] 等待 done 超時！Y:%h X:%h", y_in, x_in);
                    disable wait_done;
                end
            end
        end
    endtask

    integer file_in, file_out;
    integer status_in, status_out;
    integer pass_cnt, fail_cnt, total_cnt;

    reg signed [31:0] exp_q;
    
    reg signed [31:0] TruePATT; 
    localparam real SCALE = 1.0 / (1 << 16);

    real real_y_in, real_x_in;
    real real_q_out, real_exp_q;

    initial begin
        rst_n     = 0;
        start     = 0;
        y_in      = 0;
        x_in      = 0;
        pass_cnt  = 0;
        fail_cnt  = 0;
        total_cnt = 0;
        TruePATT  = 0; 

        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        file_in  = $fopen("data_input.txt",  "r");
        file_out = $fopen("data_output.txt", "r");

        if (file_in == 0 || file_out == 0) begin
            $display("[ERROR] 無法開啟 data_input.txt 或 data_output.txt");
            $finish;
        end

        $display("=====================================================================================================================================================");
        $display("  linear_cordic_fixedpoint Testbench ");
        $display("=====================================================================================================================================================");

        while (!$feof(file_in) && !$feof(file_out)) begin

            status_in  = $fscanf(file_in,  "%h %h\n", y_in, x_in);
            status_out = $fscanf(file_out, "%h\n",   exp_q);
            
            TruePATT = exp_q; 
            total_cnt = total_cnt + 1;

            @(negedge clk); 
            start = 1'b1;     
            
            @(negedge clk);   
            start = 1'b0;    

            // 等待運算完成 
            wait_done;
            
            @(negedge clk);

            // 將所有定點數轉換為浮點數 (Real) 
            real_y_in  = $itor(y_in) * SCALE;
            real_x_in  = $itor(x_in) * SCALE;
            real_q_out = $itor(q_out) * SCALE;
            real_exp_q = $itor(exp_q) * SCALE;

            if (q_out === exp_q) begin
                $display("[PASS #%4d] Y: %12.6f (%08h)  X: %12.6f (%08h)  =>  Got: %12.6f (%08h)  Exp: %12.6f (%08h) ",
                        total_cnt, real_y_in, y_in, real_x_in, x_in, real_q_out, q_out, real_exp_q, exp_q);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("[FAIL #%4d] Y: %12.6f (%08h)  X: %12.6f (%08h)  =>  Got: %12.6f (%08h)  Exp: %12.6f (%08h) *** ",
                        total_cnt, real_y_in, y_in, real_x_in, x_in, real_q_out, q_out, real_exp_q, exp_q);
                fail_cnt = fail_cnt + 1;
            end

            // 等 FSM 回到 IDLE 再進行下一筆 
            repeat (2) @(posedge clk);
        end

        $fclose(file_in);
        $fclose(file_out);

        $display("=====================================================================================================================================================");
        $display("  測試完成：共 %0d 筆，PASS %0d，FAIL %0d",
                 total_cnt, pass_cnt, fail_cnt);
        $display("=====================================================================================================================================================");
        $finish;
    end

    initial begin
        #10_000_000;
        $display("[TIMEOUT] 模擬超時，強制結束！");
        $finish;
    end

endmodule