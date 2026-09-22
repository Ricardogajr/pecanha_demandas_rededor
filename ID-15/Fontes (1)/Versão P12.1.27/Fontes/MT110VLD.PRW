#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MT110VLD
Ponto de entrada que valida o registro na Solicitação de Compras.
Se a solicitação foi integrada via Bionexo, o sistema não deixará o usuário excluir ou alterar a solicitação.
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return lRet .T. valido, .F. não valido.
/*/
User Function MT110VLD()

	Local nOpc	:= ParamIxb[1]
	Local lRet	:= .T.
	
	If ALTERA .Or. nOpc == 6 
		If !Empty(SC1->C1_XIDBIO)
			Alert("Solicitação Integrada com a Bionexo. " + Iif(nOpc==4, "Alteração", "Eliminação") +" não será permitida!!")
			lRet := .F.
		elseif !Empty(SC1->C1_XIDPLAN)
			Alert("Solicitação Integrada com a Plannexo. " + Iif(nOpc==4, "Alteração", "Exclusão") +" não será permitida!!")
			lRet := .F.		
		EndIf
	EndIf
Return lRet
