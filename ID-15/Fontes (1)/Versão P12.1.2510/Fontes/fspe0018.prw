#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120LEG
Ponto de entrada para Manipular apresentaï¿½ï¿½o das cores na mBrowse.
Adicionada a legenda Integrado Bionexo e (Integrado Bionexo e Recebido).
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return aLegenda Array com as cores da legenda
/*/

User Function FSPE0018()

	Local aLegenda := ParamIxb[1]
	
	aAdd( aLegenda, {"PMSTASK4", 	"Integrado Bionexo - Liberado" })
	aAdd( aLegenda, {"PMSTASK6", 	"Integrado Bionexo - Bloqueado" })
	aAdd( aLegenda, {"BR_MARRON_OCEAN", "Pedido de NF devolvida mês Fechado" })
	
Return( aLegenda )