#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT110LEG
Ponto de entrada para adicionar legendas na Dialog da solicitação de compras.
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return aCores Array com as cores da legenda da Solicitação
/*/
User Function MT110LEG()

	Local aCores := ParamIxb[1]

//	aAdd(aCores,{"DESTINOS"	, "Integração Bionexo" })
	aAdd(aCores,{"PMSTASK4", "Integrado Bionexo"})
	aAdd(aCores,{"PMSTASK6", "Aguardando integração Bionexo"})
	aAdd(aCores,{"PMSTASK5", "Aguardando desvínculo Bionexo"})
	aAdd(aCores,{"PMSTASK3", "Erro de integração bionexo"})

Return aCores