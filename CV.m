function [AF] = CV(data_RR)
avrg_RR = mean(data_RR);
sigma_RR = std(data_RR); %vypocet smerodatnej odchylky 

koeficient = sigma_RR/avrg_RR;

koeficient_NSR = 0.19; % Podla K. Tateno L. Glass 
if koeficient >= koeficient_NSR
    AF = 1;
else
    AF = 0;
end
