/*/{Protheus.doc} MA150BUT
Ponto de entrada que tem o objetivo de Inclusão de uma opção de usuário no ToolBar.
Rotina de Preços de Cotação MATA150()
@type function
@author Ricardo da Silva
@since 24/10/2017
@version 1.0
@return aButton Array com os Botões em uso.
/*/
User Function MA150BUT()

Local aBotao := {}

Public cObsSC 	:= ""

	aAdd( aBotao, {"S4WB005N",{|| U_REDA010()},"Observação da Solicitação de Compras","Observação SC"}) 

Return( aBotao )