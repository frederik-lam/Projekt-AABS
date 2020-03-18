function [ se, sp, acc, ppv ] = GetScoreFIS( confusionMatrix )
%Funkce pro vyhodnocen� �sp�nosti rozpozn�v�n� fibrilace s�n� v EKG

%Vstup:         confusionMatrix:            Matice z�m�n z funkce Main()

%V�stup:    se:                 V�sledn� senzitivita metody
%           sp:                 V�sledn� specificita metody
%           acc:                V�sledn� p�esnost metody
%           ppv:                Pozitivn� prediktivn� hodnota metody

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