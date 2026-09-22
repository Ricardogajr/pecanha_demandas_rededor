#INCLUDE "AE_Cargos.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AE_CARGOS³ Autor ³ Itamar Oliveira       ³ Data ³ 30/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Edicao da tabela LJL -> Cargos				  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template CDV (Controle de Despesas de Viagens)			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AE_CARGOS
Private cCadastro := STR0001 //"Cadastro de Cargos"
Private aRotina := MenuDef()
Private cDelFunc := "U_ValExc()" // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString := "LJL"

dbSelectArea("LJL")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return

//*********************************************************************************//
//Valida Exclusao do Cargo
//*********************************************************************************//
User Function ValExc()
Local lRet:=.T., aArea:=GetArea()

//Procura cargo no cadastro de colaboradores. Caso encontre, nao deixar o cargo ser excluido
DbSelectArea("LHT")
dbSetOrder(5)
LHT->(DbGoTop())
If (DbSeek(xFilial()+LJL->LJL_CODCAR))
	MsgInfo(STR0002) //"Este cargo esta relacionado a colaboradores, portanto não poderá ser excluído."
	lRet:=.F.
EndIf
	
RestArea(aArea)
Return lRet

//*********************************************************************************//
//Padronização de valores para todos os cargos
//*********************************************************************************//
User Function ValorPadrao()
Local _cMens, _nOpc:=0
Private oDlgPadrao, oBtnSalvar, oBtnCancelar, oBOLD, oVlCPer, oVlSPer, oIntern, oAcresc, oBtnCanc
Private _nVlCPer:=0, _nVlSPer:=0, _nIntern:=0, _nAcresc:=0
 
_cMens := STR0003 //"Esta rotina seve para padronizar os valores que serão usados no calculo do adiantamento. "
_cMens += STR0004 //"Após a confirmação, os valores serão iguais para todos os cargos."
MsgAlert(_cMens)

//DEFINE MSDIALOG oDlgPadrao TITLE "Padronização de valores para cargos" From 02,03 To 232,350 PIXEL //Para utilizar os botoes Salvar e Cancelar ativar essa linha
DEFINE MSDIALOG oDlgPadrao TITLE "Padronização de valores para cargos" From 02,03 To 205,350 PIXEL

	@015,005 TO 035,170 OF oDlgPadrao PIXEL

	DEFINE FONT oBOLD Name "ARIAL" SIZE 0, -13 BOLD
	@ 022,010 SAY STR0005 OF oDlgPadrao PIXEL FONT oBOLD COLOR CLR_HBLUE //'Informe os valores para calculo do adiantamento'
	                                       
	@ 035,005 TO 097,170 OF oDlgPadrao PIXEL

	@ 042,015 SAY STR0006 OF oDlgPadrao PIXEL //'Território Nacional com Pernoite:'
	@ 041,110 MSGET oVlCPer Var _nVlCPer Picture '@E 99,999.99' SIZE 20,07 OF oDlgPadrao PIXEL

	@ 055,015 SAY STR0007 OF oDlgPadrao PIXEL //'Território Nacional sem Pernoite:'
	@ 054,110 MSGET oVlSPer Var _nVlSPer Picture '@E 99,999.99' SIZE 20,07 OF oDlgPadrao PIXEL

	@ 068,015 SAY STR0008 OF oDlgPadrao PIXEL //'Viagens Internacionais:'
	@ 067,110 MSGET oIntern Var _nIntern Picture '@E 99,999.99' SIZE 20,07 OF oDlgPadrao PIXEL
	
	@ 081,015 SAY STR0009 OF oDlgPadrao PIXEL //'Acréscimo (Ex: Taxi até o aeroporto):'
	@ 080,110 MSGET oAcresc Var _nAcresc Picture '@E 99,999.99' SIZE 20,07 OF oDlgPadrao PIXEL

ACTIVATE MSDIALOG oDlgPadrao ON INIT EnchoiceBar(oDlgPadrao, {|| If(U_Valida(),(_nOpc:=1,oDlgPadrao:End()), Nil) }, {|| oDlgPadrao:End() }) CENTER

If _nOpc == 1
	If U_GravaPadrao()
		MsgInfo(STR0010) //"Valores gravados com sucesso."
	EndIf
EndIf

Return

//*********************************************************************************//
//Grava as alteracoes
//*********************************************************************************//
User Function GravaPadrao()
Local lRet := .F.
	
	DbSelectArea("LJL") 
    DbGoTop()
	Do While !EOF()
		RecLock("LJL", .F.)
			LJL->LJL_VLCPER	:= _nVlCPer
			LJL->LJL_VLSPER	:= _nVlSPer
			LJL->LJL_VLINT	:= _nIntern
			LJL->LJL_ACRESC	:= _nAcresc
		MsUnlock("LJL")
		DbSkip()
	EndDo
	lRet:=.T.
Return lRet

//*********************************************************************************//
//Valida as alteracoes
//*********************************************************************************//
User Function Valida()
Local lRet := .T.
	If _nVlCPer==0 .Or. _nVlSPer==0 .Or. _nIntern==0 .Or. _nAcresc==0
 		If ! MsgYesNo(STR0011) //"Existem valores zerados. Deseja continuar assim mesmo?"
			lRet := .F.
		EndIf
	EndIf
Return lRet

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
Local aRotina := { 	{STR0012,	"AxPesqui",		0,1} ,; //"Pesquisar"
             			{STR0013,	"AxVisual",		0,2} ,; //"Visualizar"
						{STR0014,		"AxInclui",		0,3} ,; //"Incluir"
						{STR0015,		"AxAltera",		0,4} ,; //"Alterar"
						{STR0016,		"AxDeleta",		0,5} ,; //"Excluir"
						{STR0017,	"U_ValorPadrao",0,6} } //"Padronizar"
Return(aRotina)
 