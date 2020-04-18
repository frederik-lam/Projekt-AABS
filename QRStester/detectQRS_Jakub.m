function [QRSpos] = detectQRS(fvz, signal0)
% odstranenie driftu
n = 1000;
h_hp = fir1(n, 0.67/(fvz/2), 'high');
signal = filtfilt(h_hp, 1, signal0);


w_start = 11/(fvz/2); % Zaciatok pasmovej propusti na 11 HZ
w_stop = 21/(fvz/2); % Koniec pasmovej propusti na 21 Hz 
n = 100; % Rad filtru
h_bp = fir1(n,[w_start, w_stop], 'bandpass'); % impulz. ch. pasmovej propusti

w_lp = 10/(fvz/2); % Medzna f dolnej priepusti
h_lp = fir1(n,w_lp,'low'); % Imp. ch. dolnej priepusti

filt_sig1 = filtfilt(h_bp,1,signal); % filtracia signalu pasmovou priepustou
E = envelope(filt_sig1, 100); 
filt_sig2 = filt_sig1.^2; % Umocnenie signalu
E2 = E.^2;

filt_sig = filtfilt(h_lp,1,filt_sig2); % Vyhladeny sig dp.

ekgMax = max(E2);
prah = ekgMax*0.03; % prahova hodnota pro detekci QRS

%[pks,locs0] = findpeaks(filt_sig,'MinPeakHeight', prah, 'MinPeakDistance', 100 );
[pks0,locs0] = findpeaks(E2, 'MinPeakDistance', 100, 'MinPeakHeight', prah);
locs = [];
pks = [];
for i = 1:length(locs0)
    a = filt_sig(locs0(i))/E2(locs0(i));
    if filt_sig(locs0(i))/E2(locs0(i)) > 0.15
        locs = [locs locs0(i)];
        pks = [pks pks0(i)];
    end
end
QRSpos = locs;


% figure
% subplot 311
% plot(signal0); title('Povodny signal metoda Jakub');
% subplot 312 
% plot(filt_sig1); title('Filtrovany signal PP a obalka');
% hold on
% plot(E)
% subplot 313
% plot(filt_sig); title('Filtrovany signal PP a obalka^2');
% hold on
% plot(E2)
% stem(locs,pks,'x')