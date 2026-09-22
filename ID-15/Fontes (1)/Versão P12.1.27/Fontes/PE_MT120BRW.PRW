#INCLUDE 'TOTVS.CH'
/*{Protheus.doc} MT120BRW
	
	Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
	
	@Author			Nairan Alves Silva
	@Since			15/09/2016
	@Project    	MAN00000463801_EF_001

*/
User Function MT120BRW()

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	IF lExecPECli .And. FindFunction('U_FSPE0015')
		U_FSPE0015()
	EndIF
	
	IF FindFunction('U_F0400103')
		U_F0400103()
	EndIF

	IF FindFunction('U_FSPE0022')
		U_FSPE0022()
	EndIF

	IF FindFunction('U_FSPE0023')
		U_FSPE0023()
	EndIF

Return
