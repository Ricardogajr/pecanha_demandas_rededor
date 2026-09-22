#Include 'Protheus.ch'

/*
{Protheus.doc}  MT140FIL()
Ponto de entrada para filtrar os documentos de entrada, separando o que veio da solicitação de pagamento dos demais documentos.
@Author  Ramon Teodoro e Silva	
@Since   21/11/2017       
@Version P12.7
*/

User Function MT140FIL()

Local cRet  := ""
Local aArea := GetArea()

If IsInCallStack("U_TEWBTYP3")
	cRet := "F1_XSOLPAG = '1'"
Else
	cRet := "F1_XSOLPAG <> '1'"
EndIf

RestArea(aArea)
Return cRet

