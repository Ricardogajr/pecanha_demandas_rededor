#INCLUDE "AE_SViag_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_SVIAG  ºAutor  ³Armando / Willy     º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Mbrowse da Solicitação de Viagem Nacional e Internacional.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_SViag()
 
Local lLHPFIL := ExistBlock("LHPFIL")
Local cFil := "" 
Local aOpcAdc		:= {}

Private aCores,cCadastro

//chkUser("CDV")

// D - Verde     -> Montando Solicitacao
// I - Amarela   -> Encaminhado para Aprocação via Workflow
// A - AZUL      -> Solicitacao Aprovada
// P - PRETO     -> Solicitacao Reprovada
// M - MARROM    -> Aguardando Depto de Viagens
// E - Laranja   -> Liberado para Prestação de Contas
// B - BRANCO    -> Prestação de Contas sem Solicitacao
// C - Vermelho  -> Respectivo acerto Concluido
// Z - Cinza     -> Fechamento da Viagem


aCores := {	{ 'LHP_Flag = "D" ', 'BR_VERDE'   	},;
			{ 'LHP_Flag = "I" ', 'BR_AMARELO' 	},;
			{ 'LHP_Flag = "A" ', 'BR_AZUL'    	},;
			{ 'LHP_Flag = "P" ', 'BR_PRETO'   	},;
			{ 'LHP_Flag = "M" ', 'BR_MARROM'  	},;
			{ 'LHP_Flag = "E" ', 'BR_LARANJA' 	},;
			{ 'LHP_Flag = "B" ', 'BR_BRANCO'  	},;
			{ 'LHP_Flag = "C" ', 'BR_VERMELHO'	},;
			{ 'LHP_Flag = "K" ', 'BR_PINK'	  	},;
			{ 'LHP_Flag = "Z" ', 'BR_CINZA'   	} }

Private aRotina := MenuDef()

cCadastro := STR0001 //"Solicitação de Viagem"

If ExistBlock("AE_SVMENU")
	aOpcAdc := ExecBlock("AE_SVMENU",.F.,.F.,{aRotina})
	If ValType(aOpcAdc) == "A" .And. Len(aOpcAdc) > 0
		aRotina := aClone(aOpcAdc)
	Endif
Endif

dbSelectArea('LHP')
LHP->(DbSetOrder(2))

If lLHPFIL 
	cFil := Execblock("LHPFIL",.F.,.F.,__cUserID)
	If !Empty(cFil)
		DbSetFilter({||&(cFil)},cFil)
	EndIf	
EndIf

mBrowse(6, 1, 22, 75, "LHP",,,,,, aCores)

If lLHPFIL 
	DBClearFilter()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³08/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {	{STR0002, 	'AxPesqui',        	0, 1},; //"Pesquisa"
				{STR0003,	'U_AE_SV001(0)',	0, 2},; //"Visualiza"
				{STR0004,  	'U_AE_SV001(1)',    0, 3},; //"Incluir"
				{STR0005,  	'U_AE_SV001(2)', 	0, 4},; //"Alterar"
				{STR0006,  	'U_AE_SV001(3)',   	0, 5},; //"Excluir"
				{STR0007, 	'U_AE_SV003(.T.)', 	0, 6},; //"Imprimir"
				{STR0008,	'U_AE_SV001(4)',    0, 7},; //"Aprovação"
				{STR0009,   	'U_AE_SV001(5)', 	0, 8},; //"Copiar"
				{STR0010,   	'U_Cancela("S")', 	0, 9},; //"Cancelar"
				{STR0011,  	'U_AE_SV005',      	0, 10, ,.F.}} //"Legenda"

Return(aRotina)
 