clc;clear all; close all;
%x = load('W027.mat')
x = load('W026.mat');
sig = x.x;

% filt_sig = nulovanie_spektra(sig,500,3);
% filt_sig = nulovanie_spektra(filt_sig,500,11,21);
[pos] = detectQRS(500,sig);
% [pz] = detectQRS_Jakub(500,sig);


% figure
% subplot 411
% plot(sig); title('Povod sig');
% subplot 412
% plot(filt_sig); title('Filtrovany sig');
% subplot 413
% plot(abs(fft(filt_sig))); title('Spektrum filt');
% subplot 414
% plot(abs(fft(sig))); title('Spektrum povod');