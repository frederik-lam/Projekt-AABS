function [ se, sp, acc, ppv, confusionMatrix ] = Main( filePath )
%Funkce slou�� pro ov��en� navr�en�ch algoritm� pro rozpozn�v�n� fibrilace s�n� (FIS).
%Algoritmy budou ov��ov�ny na skryt� mno�in� dat, v odevzdan�m projektu je proto
%nutn� dodr�et sktrukturu tohoto k�du. 

%Vstup:     filePath:           N�zev slo�ky (textov� �et�zec) obsahuj�c� data

%V�stup:    se:                 V�sledn� senzitivita rozpozn�v�n� FIS
%           sp:                 V�sledn� specificita 
%           acc:                V�sledn� p�esnost rozpozn�v�n� FIS
%           ppv:                Pozitivn� prediktivn� hodnota 
%           confusionMatrix:    Matice z�m�n

%Funkce:    MyMethod()           Funkce pro implementaci p�edzpracov�n� 
%a anal�zy dat. Do funkce vstupuje v�dy jen 1 objekt (pacient). Ve�kere metody implementujte 
%ve funkci MyMethod(). �prava hlavn� funkce Main m��e v�st
%k chybn�mu b�hu programu p�i testov�n�.

%           GetScoreFIS()          Funkce pro vyhodnocen� �sp�nosti
%           rozpozn�v�n� FIS. Z dostupn�ch hodnot vyberte do prezentace
%           metriky vhodn� pro va�e data (samotnou funkci GetScoreFIS neupravujte).


    %% Nastaven� cest a inicializace prom�nn�ch
    if ~isfolder( filePath )
        error('Folder does not exist.')
    end
        
    inputRef = readtable([ filePath '\' 'referencesTest.csv' ]); %Na�ten� souboru s referencemi (referencesTrain.csv resp. referencesTest.csv)
    numberRecords = size( inputRef, 1 ); %Po�et EKG z�znam�
    confusionMatrix = zeros( 2 ); %Inicializace matice z�m�n

    
    for idx = 1:numberRecords                

    
        %% Ur�en� v�stupu modelu pro 1 objekt
        doctorOutputChar = inputRef{ idx, 2 }{1}; %reference, tj. hodnocen� doktora: A - fibrilace s�n�, N - sinusov� rytmus, O - jin� srde�n� arytmie.
        doctorOutput = 0; %Inicializace referen�n� hodnoty v �iseln�m form�tu (defaultn� 0 - pro v�echny typy, krom� fibrilace s�n�; tj. N a O budou spadat do stejn� kategorie)
        doctorOutput(doctorOutputChar == 'A')=1; %Dosazen� referen�n� hodnoty = 1 pro sign�l s fibrilaci s�n�
      
        inputData = load([ filePath '\' inputRef{ idx, 1 }{1} '.mat']); %Na�ten� EKG z�znam� dan�ho pacienta
        inputData = inputData.val;
        
        methodOutput = MyMethod( inputData ); %Vyhodnocen� EKG vlastn� metodou, v�stup metody ve form�tu: 1 - fibrilace s�n�, 0 - ostatn� (tj. sinusov� rytmus nebo jin� arytmie)

        
        %% Aktualizace matice z�m�n
        switch methodOutput
            case {0, 1}
                confusionMatrix( methodOutput + 1, doctorOutput + 1 ) = confusionMatrix( methodOutput + 1, doctorOutput + 1 ) + 1;
            otherwise
                error('Invalid class number. Operation aborted.')
        end

        
        %% Vyhodnocen� metody pro rozpozn�v�n� FIS
        [ se, sp, acc, ppv ] = GetScoreFIS( confusionMatrix );

    end


end



