#include 'protheus.ch'
#include 'parmtype.ch'

/*
{Protheus.doc}  MT103NFE()
Ponto de entrada para permitir o estorno ou exclusão de uma nota fiscal de serviço onde já houve o fechamento de estoque.
@Author  Ramon Teodoro e Silva	
@Since   02/04/2018       
@Version P12.7
*/

User function MT103NFE()

Local nOpc     := PARAMIXB
Local dDtFchto := If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
Local dDtDigit := SF1->F1_DTDIGIT 
Local lRecusa  := .F.
Local aArea    := GetArea()

If SF1->F1_XSOLPAG == "1" .Or. Empty (Alltrim (SF1->F1_XID))
	
	If nOpc == 5 .And. dDtFchto >= dDtDigit
		
		DbSelectArea("SE2")
		DbSetOrder(6)
	
		If SE2->(DbSeek(xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)))
			lRecusa := !Empty(SE2->E2_XDTRECU) .And. SE2->E2_XSTRECU == "R"	
		EndIf
		
		If lRecusa
			RecLock("SF1", .F.)
			SF1->F1_DTDIGIT := dDataBase
			SF1->F1_XDTCNTR  := dDtDigit
			SF1->(MsUnlock())
		Else
			MsgAlert("Para excluir\estornar esta nota é necessário fazer a recusa do título","Operação não permitida")
		EndIf
		
 	EndIf	
 	
EndIf

RestArea(aArea)

Return