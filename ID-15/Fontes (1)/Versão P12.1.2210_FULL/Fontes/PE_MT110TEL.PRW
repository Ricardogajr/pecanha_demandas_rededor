#Include 'Protheus.ch'

/*
{Protheus.doc} MT110TEL()
Manipulação do Cabeçalho da Solicitação de Compras
@Author  Fabrica de Software
@Since   05/10/2018
@Project MAN0000007423048_EF_060
*/
User Function MT110TEL()
	
	Local oNewDialog := PARAMIXB[1]
	Local aPosGet    := PARAMIXB[2]
	Local nOpcx      := PARAMIXB[3]
	Local nReg       := PARAMIXB[4]
	
	U_F1206001(oNewDialog,aPosGet)
	
Return