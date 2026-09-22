#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MT080GRV
Confirmação de inclusão ou alteração no TES - https://tdn.totvs.com/pages/releaseview.action?pageId=701692370
@author Joalisson Laurentino
@since 02/07/2023
@version 1.0
@type function
/*/
User Function MT080GRV()
	Local aArea := FWGetArea()
	Local lRet	:= .T.

	//Campos utilizados para integração com Taxfy - KTGroup
	If SF4->(FieldPos("F4_ZONERGY")) > 0 .AND. SF4->(FieldPos("F4_ZINTOGY")) > 0
		If INCLUI 
			RecLock("SF4",.F.)
				M->F4_ZONERGY := .T.	//Habilita registro para integração
				M->F4_ZINTOGY := "1"	//1-Pendente | 2- Integrado | 3- Erro
			SF4->(MsUnlock())
		ElseIf ALTERA
			SF4->(RecLock("SF4",.F.))
				SF4->F4_ZONERGY := .T.	//Habilita registro para integração
				SF4->F4_ZINTOGY := "1"	//1-Pendente | 2- Integrado | 3- Erro
			SF4->(MsUnlock())
		Endif
	Else 
		FWAlertError("TES não será integrada ao Taxfy. Campos F4_ZONERGY e F4_ZINTOGY não foram criados. Rode o U_UPDTAX().","MT080GRV.prw - Taxfy - KTGroup")
	Endif

	FWRestArea(aArea)
Return lRet
