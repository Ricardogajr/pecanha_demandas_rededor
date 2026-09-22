#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F1000302
Retorna filtro de Doc. Entrada. Se rotina específica (U_F1000301), apresenta
somente documentos com origem em solicitações de pagamento.
@author izac.ciszevski
@since 01/06/2017
@Project    MAN0000007423044_EF_003 
/*/
User Function F1000302()
	
	Local cFiltro := ""

	If FwIsInCallStack("U_F1000301")
		cFiltro := "F1_XSOLPAG = '1'" // Origem Solicitação de Pagamento
	Else
		cFiltro := "F1_XSOLPAG != '1'" // Outra Origem
	EndIf 
	
Return cFiltro