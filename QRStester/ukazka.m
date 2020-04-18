x = load('W027.mat')
sig = x.x;

filt_sig1 = nulovanie_spektra(sig,500,2); % odstranenie driftu
filt_sig = nulovanie_spektra(filt_sig1,500,11,21); % pasmova zadrz

% figure
% subplot 411
% plot(sig); title('Povod sig');
% subplot 412
% plot(filt_sig); title('Filtrovany sig');
% subplot 413
% plot(abs(fft(filt_sig))); title('Spektrum filt');
% subplot 414
% plot(abs(fft(sig))); title('Spektrum povod');