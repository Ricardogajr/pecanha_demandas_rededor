#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   

/*{Protheus.doc} MT120APV()
Alteração de Grupo de Aprovação
@Author     Nairan Alves Silva
@Since      14/09/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Menu		Compras\Atualizações\Pedidos\solicitações de Pagamento*/
User Function MT120APV()

	Local xRet

	//Tratamento para solicitação de pagamento
	xRet := U_F0100409()

	//Tratamento para integração
	If ValType(xRet) != "C"
		xRet := U_F0702604()
	EndIf 

Return xRet
