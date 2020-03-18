function [QRS1] = QRSdetektor_prah(fs_ECG,ECG)

% detektor komplexù QRS vycházející z prahování pùvodního signálu
% vstupy:
% fs_ECG ... vzorkovací kmitoèet signálu EKG
% ECG ... jeden svod signálu EKG

% výstupy:
% QRS1 ... polohy detekovaných QRS z 1svodového EKG

ekgMax = max(ECG); % maximalni vychylka v EKG
prah = ekgMax*0.75; % prahova hodnota pro detekci QRS

% Hledani nadprahovych hodnot v EKG:
nadprah = find(ECG > prah); % indexy nadprah. hodnot, napr. [5 6 7 15 16 17]
nad1 = [0 nadprah(1:end-1)]; %                    napr. [0 5 6  7 15 16]
dif = nadprah - nad1; %                           napr. [5 1 1  8  1  1]
zacatky = find(dif>1); %                          napr. [1 4] 
konce = [zacatky(2:end)-1 length(nadprah)]; %     napr. [3 6]

% Hledani pozic QRS komplexu z detekovanych nadprahovych hodnot:
QRS1 = []; ekgMaxLokalni = [];
for i = 1:length(zacatky)
   [hodnota, pol] = max(ECG(nadprah(zacatky(i)):nadprah(konce(i))));
   poloha = nadprah(zacatky(i)) + pol;
   ekgMaxLokalni = [ekgMaxLokalni hodnota];
   QRS1 = [QRS1 poloha];
end

end