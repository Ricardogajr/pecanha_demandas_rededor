#INCLUDE "AE_FINAN_AP6.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_FINAN_AP6ºAutor  ³Willy / Armando     º Data ³  09/06/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mbrowse da efetivação da Solicitação no Depto de Viagem.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP6                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_FINAN()

Local aOpcAdc		:= {}

Private aCores		:= {}
Private cCadastro	:= ""
Private _cPerg 	:= "FINAN1    "
Private _cFilSOl 	:= ""
Private _aIndexLHP	:= {}
Private bFiltraBrw := {|| Nil}
Private aRotina 	:= MenuDef()

ChkTemplate("CDV")

cCadastro := STR0001 //"Departamento de Viagem"

// M - Marrom    -> Solicitação Iniciada
// D - Verde     -> Para Aprovação
// I - Amarela   -> Aguardando Aprovacao
// A - AZUL      -> Solicitação Aprovada
// P - PRETO     -> Solicitação Reprovada
// E - Laranja   -> Encaminhado
// B - Branco    -> Prestação de Contas sem Solicitação
// C - Vermelho  -> Respectivo acerto concluido
// Z - Cinza     -> Fechamento da Viagem

aCores := {	{ 'LHP_Flag1 = "M"', 'BR_MARROM'  	},;
			{ 'LHP_Flag1 = "D"', 'BR_VERDE'   	},;
			{ 'LHP_Flag1 = "I"', 'BR_AMARELO' 	},;
			{ 'LHP_Flag1 = "A"', 'BR_AZUL'    	},;
			{ 'LHP_Flag1 = "P"', 'BR_PRETO'   	},;
			{ 'LHP_Flag1 = "E"', 'BR_LARANJA' 	},;
			{ 'LHP_Flag1 = "K"', 'BR_PINK'		},;
			{ 'LHP_Flag1 = "B"', 'BR_BRANCO'  	},;
			{ 'LHP_Flag1 = "C"', 'BR_VERMELHO'	},;
			{ 'LHP_Flag1 = "Z"', 'BR_CINZA'   	} }

dbSelectArea("LHP")

If ExistBlock("AE_FNMENU")
	aOpcAdc := ExecBlock("AE_FNMENU",.F.,.F.)
	If ValType(aOpcAdc) == "A"
		If !Empty(aOpcAdc) .AND. Len(aOpcAdc) >= 4
			aAdd(aRotina, aOpcAdc)
		Endif
	Endif
Endif

If Pergunte(_cPerg,.T.)
	dbSelectArea('LHP')
	dbSetOrder(1)
	If Mv_Par01 == 1
		_cFilSOl := 'LHP->LHP_Flag1 == "D".And.'
	ElseIf Mv_Par01 == 2
		_cFilSOl := 'LHP->LHP_Flag1 == "I".And.'
	ElseIf Mv_Par01 == 3
		_cFilSOl := 'LHP->LHP_Flag1 == "A".And.'
	ElseIf Mv_Par01 == 4
		_cFilSOl := 'LHP->LHP_Flag1 == "E".And.'
	Endif
	_cFilSOl += 'dTos(LHP_EMISS)>="'+dTos(Mv_PAR02)+'" .And. dTos(LHP_EMISS)<="'+dTos(Mv_PAR03)+'" .And.'
	_cFilSOl += 'dTos(LHP_SAIDA)>="'+dTos(Mv_PAR04)+'" .And. dTos(LHP_SAIDA)<="'+dTos(Mv_PAR05)+'"'
	
	MsAguarde({ || LHPFilter() }, "Selecionando Viagens ...")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	mBrowse(6, 1, 22, 75, "LHP",,,,,, aCores)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("LHP",_aIndexLHP)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a condicao de Entrada                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIf	

Return
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function LHPFilter()
*--------------------------------------------------------------------------------------

bFiltraBrw	:= {|| FilBrowse("LHP",@_aIndexLHP,@_cFilSOl)}
Eval(bFiltraBrw)

Return(.T.)
*--------------------------------------------------------------------------------------

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

aRotina := {{STR0012		,'PesqBrw'				,0, 1},; //"Pesquisa"
			{STR0013		,'U_AE_SV001(0)'		,0, 2},; //"Visualiza"
			{STR0014		,'U_AE_SV003(.F.)'		,0, 2},; //"Imprimir"
			{STR0015		,'U_AE_SV001(4)'		,0, 4},; //"Aprovação"
			{STR0016		,'U_AE_FV001(_cFilSOl)'	,0, 4},; //"Encaminhar"
			{STR0017		,'U_Cancela("D")'		,0, 4},; //"Cancelar"
			{STR0018		,'U_AE_AprovFin()'     	,0, 4},; //"Parametros"
			{STR0019		,'U_AE_FV002'			,0, 2, ,.F.} } //"Legenda"
			
Return(aRotina)                                                                                                   
 