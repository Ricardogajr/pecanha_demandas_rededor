#include "rwmake.ch"

User Function FA260GRSE2()
Local cCodPgt := "DDA"

Do Case
    Case  SUBSTR(SE2->E2_CODBAR,1,3) == SE2->E2_PORTADO .and. Len(alltrim(SE2->E2_CODBAR)) < 48
        cCodPgt := "30"
    Case SUBSTR(SE2->E2_CODBAR,1,3) <> SE2->E2_PORTADO  .and. Len(alltrim(SE2->E2_CODBAR)) < 48
        cCodPgt := "31"
EndCase

If cCOdPgt <> "DDA"
    SE2->E2_FORMPAG := cCOdPgt
EndIf

Return Nil
