#INCLUDE 'TOTVS.ch'
/*{Protheus.doc} MTA110MNU

	Ponto de Entrada para adicionar as botões no arotina da Solicitação de Compra MATA110.PRX
	
	@author Cleiton Genuino
	@since 16/06/2023
	@Obs
		FSPE0016 - Desvincular solicitação
		F0400103 - Opçoes do Banco de Conhecimento
		FSPE0021 - Destravar Solicitação
*/
User Function MTA110MNU()

	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	IF lExecPECli .And. FindFunction('U_FSPE0016')
		U_FSPE0016()
	EndIF

	IF FindFunction('U_F0400103')
		U_F0400103()
	EndIF

	IF FindFunction('U_FSPE0021')
		U_FSPE0021()
	EndIF

Return
