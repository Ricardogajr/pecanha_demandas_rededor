#Include 'Protheus.ch'

/*
{Protheus.doc}  MT103NFE()
Ponto de entrada usado para complementar o MT103NFE, onde o campo F1_DTDIGIT foi alterado. Após a confirmação da exclusão\estorno
este ponto de entrada irá ajustar a data de digitação com o conteúdo original. 
@Author  Ramon Teodoro e Silva	
@Since   02/04/2018       
@Version P12.7
*/

User Function SF1100E()

Local dDtFchto := If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))

If  SF1->F1_XSOLPAG == "1" .Or. Empty (Alltrim (SF1->F1_XID))

	If dDtFchto >= SF1->F1_XDTCNTR .And. !Empty(SF1->F1_XDTCNTR)
		RecLock("SF1", .F.)
		SF1->F1_DTDIGIT  := SF1->F1_XDTCNTR
		SF1->F1_XDTCNTR  := CtoD(" ")
		SF1->(MsUnlock())
	EndIf

EndIf

Return 

