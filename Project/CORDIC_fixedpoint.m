clc; clear;
rng(42);
for k = 1:5000
    % 產生正負
    x_sign = randi([0, 1]) * 2 - 1;
    q_sign = randi([0, 1]) * 2 - 1;
    
    x_temp = (0.5 + rand() * 10) * x_sign;
    q_temp = (0.1 + rand() * 30) * q_sign;
    
    % Q16.16
    x_input(k) = floor(x_temp * 2^16) / 2^16;
    
    y_temp = x_input(k) * q_temp;
    y_input(k) = floor(y_temp * 2^16) / 2^16;
end

fid_in = fopen('data_input.txt', 'w');
fid_out = fopen('data_output.txt', 'w');

for idx = 1:5000
    y_val = y_input(idx);
    x_val = x_input(idx);
    exact_q = y_val / x_val;
    
    % 模擬硬體輸入
    x = abs(x_val) * 2^16; 
    y = abs(y_val) * 2^16;
    z = 0;
    shift_count = 0;
    
    % PRE_SCALE 模擬 y_ext > x2_ext 與 y <= y >>> 1
    while y >= x * 2
        y = floor(y / 2);  % y >>> 1
        shift_count = shift_count + 1;
    end
    
    % CORDIC_OP
    for iter = 0:15
        x_shifted = floor(x / 2^iter);  % x >>> iter
        cordic_step = floor(2^16 / 2^iter);  % LUT step
        if y >= 0
            y = y - x_shifted;
            z = z + cordic_step;
        else
            y = y + x_shifted;
            z = z - cordic_step;
        end
    end
    
    % POST_SCALE (z << shift_count) 補 sign
    cordic = z * (2^shift_count);
    if sign(y_val) ~= sign(x_val)
        cordic = -cordic;
    end
    
    cordic_q = cordic / 2^16;
        
    abs_err = abs(cordic_q - exact_q);
    
    exact_q_all(idx) = exact_q;
    cordic_q_all(idx) = cordic_q;


    if idx <= 3 || idx == 5000
        fprintf('組別 %04d\n', idx);
        fprintf('  輸入 Y            = %.8f\n', y_val);
        fprintf('  輸入 X            = %.8f\n', x_val);
        fprintf('  MATLAB 商值       = %.8f\n', exact_q);
        fprintf('  CORDIC 商值       = %.8f\n', cordic_q);
        fprintf('  誤差              = %.12e\n\n', abs_err);
    elseif idx == 6
        fprintf('... 等 ...\n\n');
    end

    
    y_fixed = sfi(y_val, 32, 16);
    x_fixed = sfi(x_val, 32, 16);

    q_floor = floor(cordic_q * 2^16) / 2^16;
    q_fixed = sfi(q_floor, 32, 16);
    
    y_hex = hex(y_fixed);
    x_hex = hex(x_fixed);
    q_hex = hex(q_fixed);
    
    fprintf(fid_in, '%s %s\n', y_hex, x_hex);
    fprintf(fid_out, '%s\n', q_hex);
end
   

fclose(fid_in);
fclose(fid_out);


% 計算 MSE (dB) 、 SQNR (dB)
err_signal = exact_q_all - cordic_q_all;

mse_linear = mean(err_signal.^2);
mse_dB = 10 * log10(mse_linear);

signal_power = mean(exact_q_all.^2);
sqnr_dB = 10 * log10(signal_power / mse_linear);

fprintf('MSE & SQNR \n');
fprintf('測試 : 5000 筆\n');
fprintf('MSE (線性) : %e\n', mse_linear);
fprintf('MSE (dB)   : %.4f dB\n', mse_dB);
fprintf('SQNR (dB)  : %.4f dB\n', sqnr_dB);




