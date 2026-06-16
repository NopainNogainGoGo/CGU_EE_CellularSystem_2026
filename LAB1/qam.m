clear; clc; close all;

M = 16;      
k = log2(M); 
n = 32000;   
sps = 1;     
rng default; 

dataIn = randi([0 1], n, 1);
dataSymbolsIn = bit2int(dataIn, k);

% 16-QAM (Gray Coding)
dataMod = qammod(dataSymbolsIn, M);

EbNo_values = [5, 10, 20];

for i = 1:length(EbNo_values)
    EbNo = EbNo_values(i);
    
    snr = EbNo + 10*log10(k) - 10*log10(sps);
    
    % AWGN 
    receivedSignal = awgn(dataMod, snr, 'measured');
    
    sPlotFig = scatterplot(receivedSignal, 1, 0, 'b.');
    hold on;
    scatterplot(dataMod, 1, 0, 'r*', sPlotFig); 
    title(['16-QAM Constellation at Eb/N0 = ', num2str(EbNo), ' dB']);
    grid on;
    hold off;
end