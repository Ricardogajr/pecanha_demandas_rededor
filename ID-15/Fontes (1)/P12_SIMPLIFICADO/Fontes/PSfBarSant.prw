#INCLUDE "PROTHEUS.CH"   


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FBARSANT  ∫Autor  Thiago GÛes          ∫ Data ≥  25/04/19   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Programa respons·vel pela geraÁ„o do cÛdigo de barras      ∫±±
±±∫          ≥ do banco santander                                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ CNAB SANTANDER                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/


USER FUNCTION fBarSant ()

Local cCodBar   := SE2->E2_CODBAR
Local cLinDig   := SE2->E2_LINDIG
Local cRet      := ""
Local lLdig     := .F.
Local cCmpLiv   := ""

 
 If !(Empty(SE2->E2_CODBAR)) .And. Len(alltrim(cCodBar)) > 44

	cCmpLiv := SubStr(SE2->E2_CODBAR, 5, 28)
	cBloco  := SubStr(cCmpLiv, 1, 5) + SubStr(cCmpLiv, 7, 10) + SubStr(cCmpLiv, 18, 10)

	cCodBar := SUBSTR(SE2->E2_CODBAR,1,3)
	cCodBar += SUBSTR(SE2->E2_CODBAR,4,1)
	cCodBar += SUBSTR(SE2->E2_CODBAR,33,1)
   	cCodBar += SUBSTR(SE2->E2_CODBAR,34,14)
	cCodBar += cBloco
	//cCodBar += SUBSTR(SE2->E2_CODBAR,05,5)
	//cCodBar += SUBSTR(SE2->E2_CODBAR,07,10)
	//cCodBar += SUBSTR(SE2->E2_CODBAR,18,10)
	lLDig := .T.
 EndIf
 
 cRet := Alltrim(cCodBar)
 
Return(cRet)
 
//linha digitavel --  c√≥digo de barras
//01 a 03 - 01 a 03 
//04 - 04
//05 a 32 - 20 a 44
//33 - 05
//34 a 47 - 06 a 19 
