clear; clc; close all;

M_array = [4, 16, 64];          
n_base = 600000;             
sps = 1;
EbNo_dB = 0:1:18;               

BER_sim  = zeros(length(M_array), length(EbNo_dB));
BER_theo = zeros(length(M_array), length(EbNo_dB));

rng default;

for m_idx = 1:length(M_array)
    M = M_array(m_idx);
    k = log2(M);
    
    n = floor(n_base / k) * k;
    dataIn = randi([0 1], n, 1);
    dataSymbolsIn = bit2int(dataIn, k);
    
    dataMod = qammod(dataSymbolsIn, M, 'gray');
    
    for i = 1:length(EbNo_dB)
        EbNo = EbNo_dB(i);
        snr = EbNo + 10*log10(k) - 10*log10(sps);
        
        receivedSignal = awgn(dataMod, snr, 'measured');
        
        dataSymbolsOut = qamdemod(receivedSignal, M, 'gray');
        dataOut = int2bit(dataSymbolsOut, k);
        
        [~, BER_sim(m_idx, i)] = biterr(dataIn, dataOut);
        
        % 計算理論 BER (通用 M-QAM 公式)
        EbNo_lin = 10^(EbNo / 10);
        BER_theo(m_idx, i) = (2/k) * (1 - 1/sqrt(M)) * erfc(sqrt((3*k) / (2*(M-1)) * EbNo_lin));
    end
end


figure;
colors = ['g', 'b', 'r'];  
markers = ['s', 'o', '^'];  

for m_idx = 1:length(M_array)
    M = M_array(m_idx);
    semilogy(EbNo_dB, BER_sim(m_idx, :), [colors(m_idx) markers(m_idx) '-'], ...
             'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', sprintf('%d-QAM (Sim)', M));
    hold on;
    semilogy(EbNo_dB, BER_theo(m_idx, :), [colors(m_idx) '--'], ...
             'LineWidth', 1.5, 'DisplayName', sprintf('%d-QAM (Theo)', M));
end

yline(1e-3, 'k:', 'BER = 10^{-3}', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');

xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
title('BER v.s. E_b/N_0 for 4-QAM, 16-QAM, and 64-QAM');
legend('Location', 'southwest');
grid on;
xlim([0 18]);
ylim([1e-5 1]);

fprintf('\n=========================================\n');
fprintf('當 BER = 10^-3 時，所需的 Eb/N0：\n');
fprintf('=========================================\n');

EbNo_target = zeros(1, length(M_array));
for m_idx = 1:length(M_array)
    EbNo_target(m_idx) = interp1(log10(BER_theo(m_idx, :)), EbNo_dB, log10(1e-3), 'linear');
    fprintf('%d-QAM : %.2f dB\n', M_array(m_idx), EbNo_target(m_idx));
end
