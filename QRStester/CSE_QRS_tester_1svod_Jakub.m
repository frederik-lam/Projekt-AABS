% -------------------------------------------------------------------------
% Odvozeno z CSE QRS TESTER:                            
% VÍTEK, M.; KOZUMPLÍK, J.: CSE QRS TESTER; Software pro testování 
% detektorù QRS na databázi CSE. Ústav biomedicínského inženýrství Vysoké 
% uèení technické v Brnì Kolejní 2906/4 612 00 Brno Èeská republika. 
% URL: http://www.ubmi.feec.vutbr.cz/vyzkum-a-vyvoj/produkty. (software)
% Vítek 17.10.2011
% -------------------------------------------------------------------------

function [chybne] = CSE_QRS_tester_1svod_v0()

% POZOR! Je-li nutné, upravte nastavení cest k adresáøùm   
% POZOR! Pro vìtšinu detektoru je velmi obtížný napø. signál è.117 (proto 
% výsledky detekce pro tento signál budou znázornìny graficky)
% POZOR! Pro databazi CSE platí vzorkovací kmitoèet 500 Hz (viz promìnná
% fvz), který je mimo jiné použit pøi výpoètu toleranèního pásma pro
% hodnocení úspìšnosti detekce QRS. Signály z databáze použité v projektu
% byly snímáný se vzorkovacím kmitoètem 300 Hz!

%------ POPIS -------------------------------------------------------------

% Program CSE QRS TESTER je urèen pro automatické testování algoritmù
% detekce komplexù QRS na zvoleném svodu (lead I) standardní databáze CSE.

% Umožòuje:
% 1.    výpoèet sensitivity a pozitivní pøedpovìdní hodnoty algoritmu
% 2.    výpoèet èasové nároènosti algoritmu

%------ NÁPOVÌDA ----------------------------------------------------------

% Program CSE QRS TESTER je realizován formou funkce bez vstupních a
% výstupních promìnných.

% Výstupem funkce je výpis do pøíkazového øádku Matlabu, který obsahuje:

% 1.    poèet zpracovaných signálù databáze CSE
% 2.    dosažené hodnoty sensitivity a prediktivity
% 3.    dobu potøebnou ke zpracování daného typu databáze

% V èásti VSTUPNÍ PROMÌNNÉ je možné nastavit:

% 1.    èísla signálu, které mají být zpracovány
% 2.    vzorkovací kmitoèet testovaných signálù
% 3.    toleranci pro detekci komplexù QRS

% V èásti NAÈTENÍ REFERENÈNÍCH POZIC QRS je nezbytné zadat cestu k souboru s
% referenèními pozicemi komplexù QRS.

% V èásti DETEKCE KOMPLEXÙ QRS je tøeba volat funkci, která
% realizuje testovaný detektor komplexù QRS. Povinným vstupem této funkce
% je promìnná x(i,:), což je vstupní signál dodávaný hlavní funkcí.
% Povinným výstupem je promìnná QRS, která obsahuje nadetekované pozice.
% POZOR: pro ilustraci fungování testeru máte k dispozici již
% implementovaný jednoduchý prahový detektor QRS (viz QRSdetektor_prah.m),
% jehož úspešnost je velmi nízká

% Použití testeru z pøíkazové øádky: >> CSE_QRS_tester_1svod

% Pro bìh programu je nezbytné vlastnit databázi CSE a soubor s
% referenèními pozicemi komplexù QRS.

%------ VSTUPNÍ PROMÌNNÉ --------------------------------------------------
cisla = 1:125; 
cisla([67, 70]) = []; % vynechani neexistujicich signalu v testovaci databazi
fvz = 500; % vzorkovaci frekvence EKG z CSE databazi
tol = 0.12 * fvz;   % toleranèní pásmo pro hodnocení úspìšnosti detekce QRS, napø. tol = 60 odpovida 0.12 s (T = 1/fvz = 2 ms)

%------ CESTA K DATABÁZÍ CSE ----------------------------------------------
cesta = 'QRStester\';

%------ NAÈTENÍ REFERENÈNÍCH POZIC QRS-------------------------------------
load QRStester\poziceQRSvCSEv2.mat
     
%------ DETEKCE KOMPLEXÙ QRS ----------------------------------------------
disp('------------------------------------------------------------------')
tic;

disp(sprintf('Probíhá analýza %i EKG signálù databáze CSE.',length(cisla)))

chybne = [];

for cislo = cisla
    load([cesta 'W' sprintf('%0.3d',cislo)])
    pocet_svodu = size(x,1);
    
    for i = 1:pocet_svodu % pozn.: jen jeden svod
        x(i,:) = x(i,:) - mean(x(i,:));
        
        % volání algoritmu pro detekci QRS
        QRS = detectQRS(fvz,x(i,:)); % detekce QRS prahovanim puvodniho EKG
        
        % kresba pro dva vybrane signaly z databaze (pro ilustraci)
        if cislo == 1 || cislo == 117
            figure 
            plot(x(i,:),'b'), hold on 
            for k=1:length(QRS)
                plot(QRS(k),max(x),'o')
            end
            hold off
            title(['Vysledek detekce QRS v zaznamu c. ' num2str(cislo)])
        end
        
        poziceQRSmoje(cislo,i) = {QRS};
        
        % volání pomocné funkce pro výpoèet TP, FP a FN
        [TP,FP,FN,chyba]= SeP(QRS,poziceQRSvCSEv2{cislo,1},tol);
        if chyba > 0
            chybne = [chybne cislo];
        end
            
        if isempty(find(x(i,:), 1))
            kontrola(cislo) = 1;
            TP = 0;
            FP = 0;
            FN = 0;
        else
            kontrola(cislo) = 0;
        end
        vysledky(cislo,i) = {[TP FP FN]};
    end
end

%------ VYHODNOCENÍ -------------------------------------------------------

pom = [0 0 0];
for cislo = cisla
    for i = 1:pocet_svodu 
        pom = pom + vysledky{cislo,i};
    end    
end
Se = pom(1)*100/(pom(1)+pom(3));
P = pom(1)*100/(pom(1)+pom(2));

%------ VÝPIS DO PØÍKAZOVÉHO ØÁDKU ----------------------------------------

disp(sprintf('Analýza dokonèena'))
disp(sprintf('Výsledky detekce QRS: standardní svody'))
disp(sprintf('Se(local) = %.2f %%',Se))
disp(sprintf('P(local) = %.2f %%',P))
disp(sprintf('Celkový èas analýzy = %.2f sekund.',toc))
end

%------ POMOCNÉ FUNKCE ----------------------------------------------------
function [TP,FP,FN,chyba]= SeP(QRS,refQRS,tol)
TP = 0;
FP = 0;
FN = 0;
chyba = 0;

for i = 1:length(QRS)
    pom = find(QRS(i)>=refQRS-tol & QRS(i)<=refQRS+tol, 1);
    if isempty(pom)
        FP = FP+1;
        chyba = chyba + 1;
    end
end

for i = 1:length(refQRS)
    pom = find(refQRS(i)>=QRS-tol & refQRS(i)<=QRS+tol);
    if isempty(pom)
        FN = FN+1;
        chyba = chyba + 1;
    elseif  ~isempty(pom)
        TP = TP+1;
        if length(pom) >= 2
            FP = FP + length(pom) - 1;
            chyba = chyba + 1;
        end
    end
end

if isempty(refQRS)
    TP = 0;
    FP = 0;
    FN = 0;
end
end