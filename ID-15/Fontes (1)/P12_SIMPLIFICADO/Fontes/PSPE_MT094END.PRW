#INCLUDE 'Protheus.ch'

/*
{Protheus.doc} MT094END()
Ponto de Entrada na Liberação de Documentos de Compras
@Author     Mick William da Silva
@Since      06/05/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Project    MAN00000462901_EF_022
@Param      ParamIxb[1] - Pedido de Compra
@Return     
*/

User Function MT094END()

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
    Local cCodDoc  := ParamIxb[1]  // numero do documento
    Local cTipo    := ParamIxb[2]  // PC, SC, NF, SA, IP, AE
    Local cOper    := ParamIxb[3]  // 1- Aprovar, 2-Estornar, 3-Aprovar pelo superior, 4-Transferir pelo superior, 5-Rejeitar, 6-Bloquear
    Local cFil     := ParamIxb[4] 

	U_F0100404()

	//IF cTipo = 'PC'
    //	U_F0702203( cCodDoc, 9, Nil, )   // Rotina para integrara com os fronts ws client de Desbloqueio
	//Endif
	
	If lExecPECli .And. FindFunction("U_FSPE0004")
		U_FSPE0004()
	EndIf
	
	  If cTipo == "PC" .And. cOper == 1 .And. SC7->C7_XSOLPAG == "1"
		U_ENVMAILPC(cFil, cCodDoc)
	EndIf
    
Return 
