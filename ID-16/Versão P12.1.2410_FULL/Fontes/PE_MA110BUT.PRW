/*/{Protheus.doc} MA110BUT
Ponto de entrada tem o objetivo de permitir ao usuário manipular a barra de botões nas rotinas de visualização, 
inclusão, Alteração e exclusão de solcitação de compras.
Rotina de Solicitação de Compras MATA110()
@type function
@author Ricardo da Silva
@since 23/10/2017
@version 1.0
@return aButton Array com os Botões em uso.
/*/
User Function MA110BUT()

Local nOpc    := PARAMIXB[1]
Local aButtons:= PARAMIXB[2]

Public pIncObsSC 	:= ""
	
	// Botoes a adicionar
	aAdd(aButtons,{"S4WB005N",{|| U_REDA009()}  ,"Observação da Solicitação de Compras","Observação SC"}) 
	aAdd(aButtons,{"S4WB005N",{|| U_F0400101(1)},"Banco Conhecimento","BC Conhecimento"})
	
Return (aButtons) 