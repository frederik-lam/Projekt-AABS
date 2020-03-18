function [ se, sp, acc, ppv ] = GetScoreFIS( confusionMatrix )
%Funkce pro vyhodnocení úspìšnosti rozpoznávání fibrilace síní v EKG

%Vstup:         confusionMatrix:            Matice zámìn z funkce Main()

%Výstup:    se:                 Výsledná senzitivita metody
%           sp:                 Výsledná specificita metody
%           acc:                Výsledná pøesnost metody
%           ppv:                Pozitivní prediktivní hodnota metody

    tn = confusionMatrix( 1, 1 );
    tp = confusionMatrix( 2, 2 );
    fp = confusionMatrix( 2, 1 );
    fn = confusionMatrix( 1, 2 );
    
    if ( tp + fn ) == 0
        error('Division by zero. Invalid confusion matrix.')
    end
    
    if ( tn + fp ) == 0
        error('Division by zero. Invalid confusion matrix.')
    end
    
    if ( tp + fp ) == 0
        error('Division by zero. Invalid confusion matrix.')
    end

    se = tp/( tp + fn );
    sp = tn/( tn + fp );
    acc = ( tp + tn )/( tp + tn + fp + fn );
    ppv = tp/( tp + fp );
    
end