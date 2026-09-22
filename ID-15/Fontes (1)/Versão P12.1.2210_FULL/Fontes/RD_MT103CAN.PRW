#Include 'Protheus.ch'

/*
{Protheus.doc}  MT103CAN()
Ponto de entrada para que a data de digitação, quando alterada pelo ponto de entrada MT103NFE, possa ser atualizada
com o conteúdo original quando a operação de exclusão\estorno for cancelada.
@Author  Ramon Teodoro e Silva	
@Since   02/04/2018       
@Version P12.7
*/

User Function MT103CAN()

Local dDtFchto := If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))

If SF1->F1_XSOLPAG == "1" .Or. Empty (Alltrim (SF1->F1_XID))

	If dDtFchto >= SF1->F1_XDTCNTR .And. !Empty(SF1->F1_XDTCNTR)
		RecLock("SF1", .F.)
		SF1->F1_DTDIGIT  := SF1->F1_XDTCNTR
		SF1->(MsUnlock())
	EndIf

EndIf

Return

