#Include 'Protheus.ch'
/*---------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} FSUPDEND
Ponto de  Entrada do FSTools
@Author     queizy.nascimento
@Since      02/12/2016
@Version    P12.7
@Project    MAN0000007423039_EF_002
@Return
/*///---------------------------------------------------------------------------------------------------------------------------
#Include 'Protheus.ch'

/*
{Protheus.doc} FSUPDEND()

@Author     Henrique Madureira
@Since      20/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return	 
*/
User Function FSUPDEND()

	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return .T.
	EndIf

If FindFunction("U_F0100202") //Criação da Tabela U001 - PRAZOS PARA RECONTRATACAO
	U_F0100202()
EndIf

If FindFunction("U_F0300601") //Criação da Tabela U002 - TABELA DE COPARTICIPACAO
	U_F0300601()
EndIf

If FindFunction("U_F0500107") //Criação da Tabela U005 - TP RESCISÕES VS. VISÕES
	U_F0500107()
EndIf

If FindFunction("U_F0500108") //Criação da Tabela U006 - CODIGO RESCISAO
	U_F0500108()
EndIf

If FindFunction("U_F0500207") //Criação da Tabela U007 - STATUS DAS SOLICITAÇÕES
	U_F0500207()
EndIf

If FindFunction("U_F0500111") //Criação da Tabela U008 - VISAO CANDIDATO INTERNO e U009 - VISAO CANDIDATO EXTERNO
	U_F0500111()
EndIf

If FindFunction("U_F0500406") //Criação da Tabela U004 - MOVIMENTACOES VS VISOES
	U_F0500406()
Endif

If FindFunction("U_F0800101") //Carga Tipo de Solicitação
	U_F0800101()
EndIf

If FindFunction("U_F0800102") //Criação da Tabela U010 - TIPO MOVIMENTACAO DE PESSOA
	U_F0800102()
EndIf

PutMv ("MV_PROXNUM", "U010")

Return .T.