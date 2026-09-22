#INCLUDE 'Protheus.ch'

/*
{Protheus.doc} MT131MNU()
Ponto de Entrada para Adicionar a Tela de Log e Mendição Automatizada na Rotina de Geração Cotação" 
@Author     Mick William da Silva
@Project    MAN00000462901_EF_001
*/

User Function MT131MNU()

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	IF lExecPECli .And. FindFunction('U_FSPE0013')
		U_FSPE0013()
	EndIF

	U_F1200700()

Return
 
