function [filt_sig] = nulovanie_spektra(signal,fvz,medz_freq1,medz_freq2)
a = signal(1); %zistenie pociatocnej hodnoty
b = signal(end); %zostenie konec hodnotz
help_start = a * ones(1,100); %vytvorenie vektora s pociatocnou
help_end = b * ones(1,100); % a konecnou hodnotou
signal = [help_start signal]; %predlzenie signalu z dovodu obmedzenia
signal = [signal help_end]; %kruhovo konvolucnej vlastnosti fft

freq_spektrum = fft(signal); %prevod signalu do freq oblasti
krok = fvz/length(signal);

switch  nargin
    case 3
    nul_ciara1 = round(medz_freq1/krok); %urcenie hranice filtracie
    freq_spektrum(1:nul_ciara1) = 0; % nulovanie nizsich frekvenici nez medz_freq1
    freq_spektrum(end-nul_ciara1+1:end) = 0;

    case 4
    nul_ciara1 = round(medz_freq1/krok); %urcenie hranice pasmovej zadrze
    nul_ciara2 = round(medz_freq2/krok);

    freq_spektrum(1:nul_ciara1) = 0; % nulovanie nizsich frekvenici nez medz_freq1
    freq_spektrum(end-nul_ciara1+2:end) = 0;
    freq_spektrum(nul_ciara2:end-nul_ciara2) = 0; % nulovanie vyssich frekvenici nez medz_freq2
end

filt_sig = ifft(freq_spektrum,'symmetric'); %prevod naspat do ampl. spektra
filt_sig(1:100) = []; % odstranenie umelo pridanych vzorkov
filt_sig(end-99:end) = [];
  

% figure
% subplot 311
% plot(signal); title('Povod sig'); % povodny signal je stale predlzeny
% subplot 312
% plot(filt_sig); title('Filt sig');
% subplot 313
% plot(abs(fft(filt_sig/fvz))); title('Spektrum filt sig');
end