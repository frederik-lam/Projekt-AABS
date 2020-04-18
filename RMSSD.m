function [AF] = RMSSD(RR_data,t)
N = length(RR_data);
avrg_value = mean(RR_data);
help = zeros(1,N-1);
    for i = 1:(N-1)
        help(i) = (RR_data(i+1)-RR_data(i))^2; 
    end
suma_help = sum(help);
rmssd = sqrt(1/(N-1)*suma_help);
nrmssd = rmssd/avrg_value;

    if nrmssd >= t %0.1 % https://link.springer.com/article/10.1007/s10439-009-9740-z
        AF = 1;
    else
        AF = 0;
    end
end
