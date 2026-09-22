#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F1000301
Entrada de Solitação de Pagamento.
Chamada Específica do MATA103 para realização de filtro.
@author izac.ciszevski
@since 01/06/2017
@Project    MAN0000007423044_EF_003
@menu Atualizações > Movimentos > Entrada Sol. Pag.
/*/
User Function F1000301()

	SetFunName("MATA103")
	MATA103()
	
Return