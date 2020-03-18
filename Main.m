function [ se, sp, acc, ppv, confusionMatrix ] = Main( filePath )
%Funkce slouží pro ovìøení navržených algoritmù pro rozpoznávání fibrilace síní (FIS).
%Algoritmy budou ovìøovány na skryté množinì dat, v odevzdaném projektu je proto
%nutné dodržet sktrukturu tohoto kódu. 

%Vstup:     filePath:           Název složky (textový øetìzec) obsahující data

%Výstup:    se:                 Výsledná senzitivita rozpoznávání FIS
%           sp:                 Výsledná specificita 
%           acc:                Výsledná pøesnost rozpoznávání FIS
%           ppv:                Pozitivní prediktivní hodnota 
%           confusionMatrix:    Matice zámìn

%Funkce:    MyMethod()           Funkce pro implementaci pøedzpracování 
%a analýzy dat. Do funkce vstupuje vždy jen 1 objekt (pacient). Veškere metody implementujte 
%ve funkci MyMethod(). Úprava hlavní funkce Main mùže vést
%k chybnému bìhu programu pøi testování.

%           GetScoreFIS()          Funkce pro vyhodnocení úspìšnosti
%           rozpoznávání FIS. Z dostupných hodnot vyberte do prezentace
%           metriky vhodné pro vaše data (samotnou funkci GetScoreFIS neupravujte).


    %% Nastavení cest a inicializace promìnných
    if ~isfolder( filePath )
        error('Folder does not exist.')
    end
        
    inputRef = readtable([ filePath '\' 'referencesTest.csv' ]); %Naètení souboru s referencemi (referencesTrain.csv resp. referencesTest.csv)
    numberRecords = size( inputRef, 1 ); %Poèet EKG záznamù
    confusionMatrix = zeros( 2 ); %Inicializace matice zámìn

    
    for idx = 1:numberRecords                

    
        %% Urèení výstupu modelu pro 1 objekt
        doctorOutputChar = inputRef{ idx, 2 }{1}; %reference, tj. hodnocení doktora: A - fibrilace síní, N - sinusový rytmus, O - jiná srdeèní arytmie.
        doctorOutput = 0; %Inicializace referenèní hodnoty v èiselném formátu (defaultnì 0 - pro všechny typy, kromì fibrilace síní; tj. N a O budou spadat do stejné kategorie)
        doctorOutput(doctorOutputChar == 'A')=1; %Dosazení referenèní hodnoty = 1 pro signál s fibrilaci síní
      
        inputData = load([ filePath '\' inputRef{ idx, 1 }{1} '.mat']); %Naètení EKG záznamù daného pacienta
        inputData = inputData.val;
        
        methodOutput = MyMethod( inputData ); %Vyhodnocení EKG vlastní metodou, výstup metody ve formátu: 1 - fibrilace síní, 0 - ostatní (tj. sinusový rytmus nebo jiná arytmie)

        
        %% Aktualizace matice zámìn
        switch methodOutput
            case {0, 1}
                confusionMatrix( methodOutput + 1, doctorOutput + 1 ) = confusionMatrix( methodOutput + 1, doctorOutput + 1 ) + 1;
            otherwise
                error('Invalid class number. Operation aborted.')
        end

        
        %% Vyhodnocení metody pro rozpoznávání FIS
        [ se, sp, acc, ppv ] = GetScoreFIS( confusionMatrix );

    end


end



