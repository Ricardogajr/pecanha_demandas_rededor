#include "rwmake.ch"

User Function FA260GRSE2()
	Local cCodPgt := "DDA"


	If (SE2->E2_XMNKSTA == "1" .And. !Empty(SE2->E2_XPORTAD))
		If  SUBSTR(SE2->E2_CODBAR,1,3) == SE2->E2_XPORTAD .and. Len(alltrim(SE2->E2_CODBAR)) < 48
			cCodPgt := "30"
		ElseIf SUBSTR(SE2->E2_CODBAR,1,3) <> SE2->E2_XPORTAD  .and. Len(alltrim(SE2->E2_CODBAR)) < 48
			cCodPgt := "31"
		EndIf
	Else
		If  SUBSTR(SE2->E2_CODBAR,1,3) == SE2->E2_PORTADO .and. Len(alltrim(SE2->E2_CODBAR)) < 48
			cCodPgt := "30"
		ElseIf SUBSTR(SE2->E2_CODBAR,1,3) <> SE2->E2_PORTADO  .and. Len(alltrim(SE2->E2_CODBAR)) < 48
			cCodPgt := "31"
		EndIf
	EndIf


	If cCOdPgt <> "DDA"
		SE2->E2_FORMPAG := cCOdPgt
	EndIf

Return Nil
