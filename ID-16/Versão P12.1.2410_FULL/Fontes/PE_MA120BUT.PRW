/*/{Protheus.doc} MA120BUT
Ponto de entrada que tem o objetivo de Inclusão de uma opção de usuário no ToolBar.
Rotina de Pedido de Compras MATA120()
@type function
@author Ricardo da Silva
@since 25/10/2017
@version 1.0
@return aButton Array com os Botões em uso.
/*/
User Function MA120BUT() 

Local aButtons := {} 

Public cObsSC 	:= ""
    
	// Botoes a adicionar
	aAdd(aButtons,{"S4WB005N",{|| U_REDA011()}  ,"Observação da Solicitação de Compras","Observação SC"}) 
    aAdd(aButtons,{"S4WB005N",{|| U_F0400101(1)},"Banco Conhecimento","BC Conhecimento"})
    
Return (aButtons)