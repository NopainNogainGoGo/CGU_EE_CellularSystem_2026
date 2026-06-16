clear; clc; close all;

M = 16;
k = log2(M); 
n = 320000;        
sps = 1;
rng default;
dataIn = randi([0 1], n, 1);
dataSymbolsIn = bit2int(dataIn, k);
% 16-QAM (Gray Coding)
dataMod = qammod(dataSymbolsIn, M, 'gray');
EbNo_dB = 0:2:20;
BER_sim  = zeros(1, length(EbNo_dB));   % 模擬 BER
BER_theo = zeros(1, length(EbNo_dB));   % 理論 BER
for i = 1:length(EbNo_dB)
    EbNo = EbNo_dB(i);
    snr = EbNo + 10*log10(k) - 10*log10(sps);
    receivedSignal = awgn(dataMod, snr, 'measured');
    dataSymbolsOut = qamdemod(receivedSignal, M, 'gray');
    dataOut = int2bit(dataSymbolsOut, k);
    [~, BER_sim(i)] = biterr(dataIn, dataOut);
    EbNo_lin = 10^(EbNo / 10);
    BER_theo(i) = (3/8) * erfc(sqrt((4/10) * EbNo_lin));
end
figure;
semilogy(EbNo_dB, BER_sim,  'bo-', 'LineWidth', 1.5, 'MarkerSize', 7, ...
         'DisplayName', '模擬 BER');
hold on;
semilogy(EbNo_dB, BER_theo, 'r^--', 'LineWidth', 1.5, 'MarkerSize', 7, ...
         'DisplayName', '理論 BER');
hold off;
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
title('16-QAM BER vs E_b/N_0');
legend('Location', 'southwest');
grid on;
xlim([0 20]);
ylim([1e-5 1]);