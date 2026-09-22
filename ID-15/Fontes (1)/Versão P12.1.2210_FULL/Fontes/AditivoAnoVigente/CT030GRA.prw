#Include "Protheus.ch"

User Function CT030GRA()
	Local aArea := GetArea()

	//Campos utilizados para integracao com Taxfy - KTGroup
	If CTT->(FieldPos("CTT_ZONERG")) > 0 .AND. CTT->(FieldPos("CTT_ZINTOG")) > 0
		RecLock("CTT",.F.)
			CTT->CTT_ZONERG := .T.	//Habilita registro para integração
			CTT->CTT_ZINTOG := "1"	//1-Pendente | 2- Integrado | 3- Erro
		CTT->(MsUnlock())
	Else 
		FWAlertError("Centro de custo não será integrada ao Taxfy. Campos CTT_ZONERG e CTT_ZINTOG não foram criados. Rode o U_UPDZKT().","P.E CT030GRA.prw - Taxfy - KTGroup")
	Endif

	RestArea(aArea)
Return()
