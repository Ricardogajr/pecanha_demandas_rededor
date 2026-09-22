#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F1000303
Valida a origem do documento. Documentos de solicitação de pagamento só podem
ser manipulados por rotina específica (F1000301). 
@author izac.ciszevski
@since 01/06/2017s
@project MAN0000007423044_EF_003
@project MAN0000007423044_EF_004

/*/
User Function F1000304()
	
	Local lSolPag  := FwIsInCallStack("U_F1000301")
	Local lValido  := .T.

	SD1->(DbSeek(XFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
	
	If SC7->(DbSeek(FwXFilial("SC7") + SD1->D1_PEDIDO))
		If lSolPag
			lValido := SC7->C7_XSOLPAG == "1" // Origem Solicitação de Pagamento
		Else
			lValido := SC7->C7_XSOLPAG != "1" // Outra Origem
		EndIf
	EndIf

	If !lValido
		Help("" ,1 , "Alerta!", , "Existem itens provenientes de Solicitação de Pagamento e Pedidos de Compra." +;
								  "Este Documento não será confirmado.", 2, 0)
	EndIf

Return lValido
