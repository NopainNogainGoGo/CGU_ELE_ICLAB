`timescale 1ns / 1ps
module cordic_fixedpoint (
    input clk,
    input rst_n,
    input start,
    input signed [31:0] y_in, // Q16.16 被除數
    input signed [31:0] x_in, // Q16.16 除數
    output reg signed [31:0] q_out,  // Q16.16 商
    output reg done
);

    localparam IDLE       = 3'd0;
    localparam PRE_SCALE  = 3'd1;
    localparam CORDIC_OP  = 3'd2;
    localparam POST_SCALE = 3'd3;
    localparam DONE       = 3'd4;

    reg signed [31:0] cordic_step;
    reg [2:0] curr_state, next_state;

    reg signed [31:0] x, y, z;
    reg [4:0]  shift_count;
    reg [3:0]  iter;        
    
    // LUT (Q16.16)
    always @(*) begin
        case (iter)
            4'd0  : cordic_step = 32'h0001_0000; // 2^0   = 1.0
            4'd1  : cordic_step = 32'h0000_8000; // 2^-1  = 0.5
            4'd2  : cordic_step = 32'h0000_4000; // 2^-2  = 0.25
            4'd3  : cordic_step = 32'h0000_2000; // 2^-3  = 0.125
            4'd4  : cordic_step = 32'h0000_1000; // 2^-4  = 0.0625
            4'd5  : cordic_step = 32'h0000_0800; // 2^-5  = 0.03125
            4'd6  : cordic_step = 32'h0000_0400; // 2^-6  = 0.015625
            4'd7  : cordic_step = 32'h0000_0200; // 2^-7  = 0.0078125
            4'd8  : cordic_step = 32'h0000_0100; // 2^-8  = 0.00390625
            4'd9  : cordic_step = 32'h0000_0080; // 2^-9  = 0.001953125
            4'd10 : cordic_step = 32'h0000_0040; // 2^-10 = 0.0009765625
            4'd11 : cordic_step = 32'h0000_0020; // 2^-11 = 0.00048828125
            4'd12 : cordic_step = 32'h0000_0010; // 2^-12 = 0.000244140625
            4'd13 : cordic_step = 32'h0000_0008; // 2^-13 = 0.0001220703125
            4'd14 : cordic_step = 32'h0000_0004; // 2^-14 = 0.00006103515625
            4'd15 : cordic_step = 32'h0000_0002; // 2^-15 = 0.000030517578125
            default: cordic_step = 32'h0000_0000;
        endcase
    end
    
    wire signed [31:0] abs_y;
    wire signed [31:0] abs_x;
    wire sign;
    
    assign abs_y = (y[31]) ? -y : y;
    assign abs_x = (x[31]) ? -x : x;
    assign sign = y_in[31] ^ x_in[31];

    wire scale;
    assign scale = (abs_y >>> 1) > abs_x;

    // fsm
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) curr_state <= IDLE;
        else        curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            IDLE:       next_state = start ? PRE_SCALE : IDLE;
            PRE_SCALE:  next_state = (scale) ? PRE_SCALE : CORDIC_OP;
            CORDIC_OP:  next_state = (iter == 4'd15) ? POST_SCALE : CORDIC_OP;
            POST_SCALE: next_state = DONE;
            DONE:       next_state = IDLE;
            default:    next_state = IDLE;
        endcase
    end

    // iter 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            iter <= 4'd0;
        else if (curr_state == IDLE) 
            iter <= 4'd0; 
        else if (curr_state == CORDIC_OP) 
            iter <= iter + 1'b1;
    end

    // shift_count 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            shift_count <= 5'd0;
        else if (curr_state == IDLE) 
            shift_count <= 5'd0; 
        else if (curr_state == PRE_SCALE && scale)
            shift_count <= shift_count + 1'b1;
    end

    // x 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            x <= 32'd0;
        else if(start) 
            x <= x_in[31] ? -x_in : x_in;  // |x|
    end

    // y 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            y <= 32'd0;
        else if (start)
            y <= y_in[31] ? -y_in : y_in;  // |y|
        else if (scale)
            y <= y >>> 1;
        else if (curr_state == CORDIC_OP) begin
            if (y[31])  y <= y + (x >>> iter);
            else        y <= y - (x >>> iter);
        end
    end


    // z 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            z <= 32'd0;
        else if (start)
            z <= 32'd0;     // 初始商值 = 0
        else if(curr_state == CORDIC_OP && y[31]) 
            z <= z - cordic_step;
        else if(curr_state == CORDIC_OP && !y[31]) 
            z <= z + cordic_step;
    end

    // q_out 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q_out <= 32'd0;
        else if (curr_state == POST_SCALE) 
            q_out <= sign ? -(z << shift_count) : (z << shift_count);
    end

    // done 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            done <= 1'b0;
        else if (curr_state == POST_SCALE)
            done <= 1'b1;
        else 
            done <= 1'b0;    
    end

endmodule