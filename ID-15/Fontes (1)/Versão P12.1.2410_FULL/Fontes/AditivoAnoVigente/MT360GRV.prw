#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MT360GRV
Descrição:
Este ponto de entrada é executado apos a atualização de todas as tabelas da rotina de condição de pagamento nas operações de inclusão, alteração e exclusão.

Eventos

@author 
@since 
@version 1.0
@type function
/*/
User Function MT360GRV()

	Local aArea 	:= GetArea()

	//Campos utilizados para integraï¿½ï¿½o com Taxfy - KTGroup
	If SE4->(FieldPos("E4_ZONERGY")) > 0 .AND. SE4->(FieldPos("E4_ZINTOGY")) > 0
		If Inclui
			RecLock("SE4",.F.)
				M->E4_ZONERGY := .T.	//Habilita registro para integraï¿½ï¿½o
				M->E4_ZINTOGY := "1"	//1-Pendente | 2- Integrado | 3- Erro
			SE4->(MsUnlock())
		ElseIf Altera
			RecLock("SE4",.F.)
				SE4->E4_ZONERGY := .T.	//Habilita registro para integraï¿½ï¿½o
				SE4->E4_ZINTOGY := "1"	//1-Pendente | 2- Integrado | 3- Erro
			SE4->(MsUnlock())
		EndIf
	Else 
		FWAlertError("Condição de pagamento não será integrada ao Taxfy. Campos E4_ZONERGY e E4_ZINTOGY não foram criados. Rode o U_UPDKTG().","MT360GRV.prw - Taxfy - KTGroup")
	Endif

	RestArea(aArea)

Return 
