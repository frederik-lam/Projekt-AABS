function [QRSpos] = detectQRS(fvz, signal)
w_start = 9/(fvz/2); % Zaciatok pasmovej zadrze na 6 HZ
w_stop = 23/(fvz/2); % Koniec pasmovej zadrze na 23 Hz 
n = 50; % Rad filtru
h_bp = fir1(n,[w_start, w_stop]); % impulz. ch. pasmovej zadrze

w_lp = 10/(fvz/2); % Medzna f dolnej priepusti
h_lp = fir1(n,w_lp,'low'); % Imp. ch. dolnej priepusti

filt_sig1 = filter(h_bp,1,signal); % filtracia signalu pasmovou priepustou
filt_sig2 = filt_sig1.^2; % Umocnenie signalu

filt_sig = filter(h_lp,1,filt_sig2); % Vyhladeny sig dp.

ekgMax = max(filt_sig);
prah = ekgMax*0.45; % prahova hodnota pro detekci QRS

[pks,locs] = findpeaks(filt_sig,'MinPeakHeight',prah);
QRSpos = [locs;pks];

% figure
% subplot 411 
% plot(signal)
% subplot 412
% plot(filt_sig1)
% subplot 413
% plot(filt_sig2)
% subplot 414 
% plot(filt_sig)
% hold on
% stem(locs,pks,'x')