function [QRSpos] = detectQRS(signal,fvz)
w_start = 11/(fvz/2); % Zaciatok pasmovej priepusti na 6 HZ
w_stop = 23/(fvz/2); % Koniec pasmovej priepusti na 23 Hz 
n = 100; % Rad filtru

filt_sig1 = filter(h_bp,1,signal);% filtracia signalu pasmovou priepustou
%filt_sig1 = filt_sig1(1:end-delay); %odsptranenie dobehu filtra
filt_sig1(1:delay) = []; %odstranenie nabehu filtra
filt_sig2 = filt_sig1.^2; % Umocnenie signalu

w_lp = 5/(fvz/2); % Medzna f dolnej priepusti
h_lp = fir1(n,w_lp,'low'); % Imp. ch. dolnej priepusti
filt_sig = filter(h_lp,1,filt_sig2,[]); % Vyhladeny sig dp.
%filt_sig = filt_sig(1:end-delay); %odsptranenie dobehu filtra
filt_sig(1:delay) = []; %odstranenie nabehu filtra

ekgMax = max(filt_sig);
prah = ekgMax*0.4; % prahova hodnota pro detekci QRS
w_lp = 10/(fvz/2); % Medzna f dolnej priepusti
h_lp = fir1(n,w_lp,'low'); % Imp. ch. dolnej priepusti

filt_sig1 = filter(h_bp,1,signal); % filtracia signalu pasmovou priepustou
filt_sig2 = filt_sig1.^2; % Umocnenie signalu

filt_sig = filter(h_lp,1,filt_sig2); % Vyhladeny sig dp.

ekgMax = max(filt_sig);
prah = ekgMax*0.45; % prahova hodnota pro detekci QRS

[pks,locs] = findpeaks(filt_sig,'MinPeakHeight',prah);
QRSpos = [locs];

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