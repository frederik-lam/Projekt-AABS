% -------------------------------------------------------------------------
% Odvozeno z CSE QRS TESTER:                            
% V�TEK, M.; KOZUMPL�K, J.: CSE QRS TESTER; Software pro testov�n� 
% detektor� QRS na datab�zi CSE. �stav biomedic�nsk�ho in�en�rstv� Vysok� 
% u�en� technick� v Brn� Kolejn� 2906/4 612 00 Brno �esk� republika. 
% URL: http://www.ubmi.feec.vutbr.cz/vyzkum-a-vyvoj/produkty. (software)
% V�tek 17.10.2011
% -------------------------------------------------------------------------

function [chybne] = CSE_QRS_tester_1svod_v0()

% POZOR! Je-li nutn�, upravte nastaven� cest k adres���m   
% POZOR! Pro v�t�inu detektoru je velmi obt�n� nap�. sign�l �.117 (proto 
% v�sledky detekce pro tento sign�l budou zn�zorn�ny graficky)
% POZOR! Pro databazi CSE plat� vzorkovac� kmito�et 500 Hz (viz prom�nn�
% fvz), kter� je mimo jin� pou�it p�i v�po�tu toleran�n�ho p�sma pro
% hodnocen� �sp�nosti detekce QRS. Sign�ly z datab�ze pou�it� v projektu
% byly sn�m�n� se vzorkovac�m kmito�tem 300 Hz!

%------ POPIS -------------------------------------------------------------

% Program CSE QRS TESTER je ur�en pro automatick� testov�n� algoritm�
% detekce komplex� QRS na zvolen�m svodu (lead I) standardn� datab�ze CSE.

% Umo��uje:
% 1.    v�po�et sensitivity a pozitivn� p�edpov�dn� hodnoty algoritmu
% 2.    v�po�et �asov� n�ro�nosti algoritmu

%------ N�POV�DA ----------------------------------------------------------

% Program CSE QRS TESTER je realizov�n formou funkce bez vstupn�ch a
% v�stupn�ch prom�nn�ch.

% V�stupem funkce je v�pis do p��kazov�ho ��dku Matlabu, kter� obsahuje:

% 1.    po�et zpracovan�ch sign�l� datab�ze CSE
% 2.    dosa�en� hodnoty sensitivity a prediktivity
% 3.    dobu pot�ebnou ke zpracov�n� dan�ho typu datab�ze

% V ��sti VSTUPN� PROM�NN� je mo�n� nastavit:

% 1.    ��sla sign�lu, kter� maj� b�t zpracov�ny
% 2.    vzorkovac� kmito�et testovan�ch sign�l�
% 3.    toleranci pro detekci komplex� QRS

% V ��sti NA�TEN� REFEREN�N�CH POZIC QRS je nezbytn� zadat cestu k souboru s
% referen�n�mi pozicemi komplex� QRS.

% V ��sti DETEKCE KOMPLEX� QRS je t�eba volat funkci, kter�
% realizuje testovan� detektor komplex� QRS. Povinn�m vstupem t�to funkce
% je prom�nn� x(i,:), co� je vstupn� sign�l dod�van� hlavn� funkc�.
% Povinn�m v�stupem je prom�nn� QRS, kter� obsahuje nadetekovan� pozice.
% POZOR: pro ilustraci fungov�n� testeru m�te k dispozici ji�
% implementovan� jednoduch� prahov� detektor QRS (viz QRSdetektor_prah.m),
% jeho� �spe�nost je velmi n�zk�

% Pou�it� testeru z p��kazov� ��dky: >> CSE_QRS_tester_1svod

% Pro b�h programu je nezbytn� vlastnit datab�zi CSE a soubor s
% referen�n�mi pozicemi komplex� QRS.

%------ VSTUPN� PROM�NN� --------------------------------------------------
cisla = 1:125; 
cisla([67, 70]) = []; % vynechani neexistujicich signalu v testovaci databazi
fvz = 500; % vzorkovaci frekvence EKG z CSE databazi
tol = 0.12 * fvz;   % toleran�n� p�smo pro hodnocen� �sp�nosti detekce QRS, nap�. tol = 60 odpovida 0.12 s (T = 1/fvz = 2 ms)

%------ CESTA K DATAB�Z� CSE ----------------------------------------------
cesta = 'QRStester\';

%------ NA�TEN� REFEREN�N�CH POZIC QRS-------------------------------------
load QRStester\poziceQRSvCSEv2.mat
     
%------ DETEKCE KOMPLEX� QRS ----------------------------------------------
disp('------------------------------------------------------------------')
tic;

disp(sprintf('Prob�h� anal�za %i EKG sign�l� datab�ze CSE.',length(cisla)))

chybne = [];

for cislo = cisla
    load([cesta 'W' sprintf('%0.3d',cislo)])
    pocet_svodu = size(x,1);
    
    for i = 1:pocet_svodu % pozn.: jen jeden svod
        x(i,:) = x(i,:) - mean(x(i,:));
        
        % vol�n� algoritmu pro detekci QRS
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
        
        % vol�n� pomocn� funkce pro v�po�et TP, FP a FN
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

%------ VYHODNOCEN� -------------------------------------------------------

pom = [0 0 0];
for cislo = cisla
    for i = 1:pocet_svodu 
        pom = pom + vysledky{cislo,i};
    end    
end
Se = pom(1)*100/(pom(1)+pom(3));
P = pom(1)*100/(pom(1)+pom(2));

%------ V�PIS DO P��KAZOV�HO ��DKU ----------------------------------------

disp(sprintf('Anal�za dokon�ena'))
disp(sprintf('V�sledky detekce QRS: standardn� svody'))
disp(sprintf('Se(local) = %.2f %%',Se))
disp(sprintf('P(local) = %.2f %%',P))
disp(sprintf('Celkov� �as anal�zy = %.2f sekund.',toc))
end

%------ POMOCN� FUNKCE ----------------------------------------------------
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