subplot(241);
plot(real(rx_signal),'r');
hold on;
plot(imag(rx_signal),'b');
grid on;
title('接收端时域信号');
subplot(242);
plot(time_error,'b')
grid on;
title('定时同步误差曲线');
subplot(243);
plot((th_max-127:th_max+1),cor_abs(th_max-127:th_max+1),'b');
grid on;
title('帧同步曲线');
subplot(244);
plot(phase_curve,'b');
grid on;
title('相位校正曲线');
subplot(245);
plot(real(out_signal6),imag(out_signal6),'b.');
grid on;
axis square;