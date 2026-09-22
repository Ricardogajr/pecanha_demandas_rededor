#Include "Protheus.ch"
#Include "rwmake.ch"
#include "totvs.ch"
#include 'parmtype.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RDINTPCUP

Função responsável pela realização de Upload dos Pedidos de Compras a serem integrados com o FRONT.

@type function
@version   
@author Sato
@since 19/05/2025
@return array, return_description
/*///------------------------------------------------------------------------------
User Function RDINTPCUP() As Array

	Local oWizard       As Object
	Local oStep1        As Object
	Local oStep2        As Object
	Local oStep3        As Object
	Local oStep4        As Object
	Local oStep5        As Object

	Local lCancel		As Logical
	Local aRetTela      As Array

	Local cArquivo      As Character
	Local aDadosSC7     As Array
	Local aCampos       As Array
	Local aLogs         As Array

	Local cArqLOC       As Character
	Local cArqSET       As Character
	Local lCheck01      As Logical
	Local lCheck02      As Logical
	Local lCheck03      As Logical
	Local lCheck04      As Logical
	Local aListaPed     As Array

	Local cArqConf      As Character
	Local aConfer       As Array

//seta o ambiente com a empresa 01 filial 01F70003 no módulo CTB
//RpcSetEnv( "01","01F70003", , , "COM", "RDINTPCUP", {"SC7"}, , , ,  )

	cArquivo    := ""
	aDadosSC7   := {}
	aCampos     := {}
	aLogs       := {}


	aRetTela    := {}
	lCancel		:= .F.

	cArqLOC     := ""
	cArqSET     := ""
	lCheck01    := .F.
	lCheck02    := .F.
	lCheck03    := .F.
	lCheck04    := .F.
	aListaPed   := {}

	cArqConf    := ""
	aConfer     := {}

	oWizard := FWWizardControl():New( /*oObjPai*/, { 560, 850 } )	// Instancia a classe FWWizardControl

	oWizard:ActiveUISteps()

/*
    Apresentação
*/
	oStep1 := oWizard:AddStep( 'Step1', { | oPanel | Step1( oPanel ) } )
	oStep1:SetStepDescription( "Início" )            		        // Define o título do "Passo" | "Início"
	oStep1:SetNextTitle( "Próximo" )	    				        // Define o título do botão de avanço | "Próximo"
	oStep1:SetNextAction( { || .T. } )						        // Define o bloco ao clicar no botão Próximo
	oStep1:SetCancelAction( { || lCancel := .T. } )			        // Define o bloco ao clicar no botão Cancelar

/*
    "Seleção de Arquivo"
*/
	oStep2 := oWizard:AddStep( 'Step2', { | oPanel | Step2( oPanel, @cArquivo, @lCheck01, @lCheck02, @lCheck03, @lCheck04, @cArqLOC, @cArqSET ) } )
	oStep2:SetStepDescription( "Seleção de Arquivo" )      	                        // Define o título do "Passo" | "Seleção de Arquivo"
	oStep2:SetNextTitle( "Próximo" )						                        // Define o título do botão de avanço | "Próximo"
	oStep2:SetNextAction( { || ValStep2( cArquivo, lCheck03, lCheck04, cArqLOC, cArqSET ) } )  // Define o bloco ao clicar no botão Próximo
	oStep2:SetCancelAction( { || lCancel := .T. } )                                 // Define o bloco ao clicar no botão Cancelar

/*
    "Conferência dos Dados"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
*/
	oStep3 := oWizard:AddStep( 'Step3', { | oPanel | Step3( oPanel, cArquivo, lCheck01, lCheck02, lCheck03, lCheck04, cArqLOC, cArqSET,  @aListaPed, @aDadosSC7, @aCampos ) } )
	oStep3:SetStepDescription( "Conferência dos Dados" )            // Define o título do "Passo" | "Conferência dos Dados"
	oStep3:SetNextTitle( "Próximo" )								// Define o título do botão de avanço | "Próximo"
	oStep3:SetNextAction( { || ValStep3( aListaPed, aDadosSC7, aCampos ) } )   // Define o bloco ao clicar no botão Próximo
	oStep3:SetCancelAction( { || lCancel := .T. } )					// Define o bloco ao clicar no botão Cancelar

/*
    "Processamento das correções"
*/
	oStep4 := oWizard:AddStep( 'Step4', { | oPanel | Step4( oPanel, cArquivo, aListaPed, aDadosSC7, aCampos, @aLogs, @cArqConf, @aConfer ) } )
	oStep4:SetStepDescription( "Processamento dos Pedidos" )        // Define o título do "Passo" | "Processamento dos Pedidos"
	oStep4:SetNextTitle( "Próximo" )                                // Define o título do botão de avanço | "Próximo"
	oStep4:SetNextAction( { || ValStep4( aLogs ) } )                // Define o bloco ao clicar no botão Próximo
	oStep4:SetCancelAction( { || lCancel := .T. } )                 // Define o bloco ao clicar no botão Cancelar

/*
    "Finalização"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
*/
	oStep5 := oWizard:AddStep( 'Step5', { | oPanel | Step5( oPanel, cArquivo, aLogs, cArqConf, aConfer) } )
	oStep5:SetStepDescription( "Finalização" )                      // Define o título do "Passo" | "Finalização"
	oStep5:SetNextAction( { || .T. } )	                            // Define o bloco ao clicar no botão Próximo
	oStep5:SetCancelAction( { || lCancel := .T. } )					// Define o bloco ao clicar no botão Cancelar

	oWizard:Activate()

	oWizard:Destroy()

	aRetTela := { {}, {}, {}, {}, {}, lCancel }

//RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return aRetTela



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step1

Função responsável pela exibição da Tela de apresentação

@type function
@version  
@author Sato
@since 19/05/2025
@param oPanel, object, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step1( oPanel As Object )

	Local oFont		As Object
	Local oFontV	As Object
	Local oSayTop	As Object
	Local oSay1     As Object
	Local oSay2     As Object

	oFont 	:= TFont():New( ,, -20, .T., .T.,,,,, )
	oFontV 	:= TFont():New( ,, -12, .T., .T.,,,,, )

	oSayTop	:= TSay():New( 010,  10, { || "Upload de Pedidos de Compras a serem integrados com o FRONT" }, oPanel,, oFont,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 030,  10, { || "Este programa tem como obejtivo realizar manualmente o reenvio dos Pedidos de Compras informados através de um arquivo CSV, onde serão atualizados os campos " }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 040,  10, { || "e reenviado o Pedido de Compra para o FRONT via integração." }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay1	:= TSay():New( 050,  10, { || "Para a realização dos uploads, é necessário a criação de um template no formato CSV com os seguintes campos:" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 060,  15, { || "- C7_FILIAL - Filial do Sistema;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 070,  15, { || "- C7_NUM - Numero do Pedido;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 080,  15, { || "- C7_FORNECE - Código do Fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 090,  15, { || "- C7_LOJA - Loja do fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 100,  15, { || "- C7_OBS - Observações;" }, oPanel,,,,,, .T., CLR_BLUE, )

//oSay1	:= TSay():New( 050, 145, { || "- C7_ITEM - Item do pedido de compra;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 060, 145, { || "- C7_PRODUTO  - Código do produto;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 070, 145, { || "- C7_QUANT - Quantidade do Item;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 080, 145, { || "- C7_PRECO - Preço do Item;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 090, 145, { || "- C7_TPFRETE - Tipo Frete;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 100, 145, { || "- C7_FRETE - Valor Frete;" }, oPanel,,,,,, .T., CLR_BLUE, )

//oSay1	:= TSay():New( 050, 275, { || "- C7_LOCAL - Local de Estoque;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 060, 275, { || "- C7_CC - Centro de Custo;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 070, 275, { || "- C7_XFRONT - Sigla do Fronte;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 080, 275, { || "- C7_XNUM - ID do Pedido de Compra no Fronte." }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 090, 275, { || "- C7_DESC1 - Desconto;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 100, 275, { || "- C7_XDESFIN - Desc. Financeiro;" }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay2	:= TSay():New( 115, 10, { || "Importante: " }, oPanel,, oFontV,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 125, 10, { || "Os dados do arquivo CSV (template) utilizados como base dos uploads, deverão seguir algumas premissas:" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 135, 15, { || "- Utilizar ponto e vírgula (;) como separador de colunas;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 145, 15, { || "- Utilizar vírgula (,) como separador da parte decimal em campos numéricos;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 155, 15, { || "- Utilizar 4 dígitos para especificar o ano em campos tipo 'data'. Ex.: dd/mm/aaaa;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 165, 15, { || "- Não conter caracteres especiais;" }, oPanel,,,,,, .T., CLR_BLUE, )

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Step2

Função responsável pela Seleção do Arquivo de Upload dos Pedidos de Comrpas.

@type function
@version  
@author Sato
@since 20/05/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step2( oPanel As Object, cArquivo As Character, lCheck01 as Logical, lCheck02 as Logical, lCheck03 as Logical, lCheck04 as Logical, cArqLOC As Character, cArqSET As Character)

	Local aArea2    As Array
	Local oButton   As Object
	Local oButton3  As Object
	Local oButton4  As Object
	Local oGetarq   As Object
	Local oGet3     As Object
	Local oGet4     As Object
	Local nAltGet   As Numeric

	Local oGroup1   As Object
	Local oGroup2   As Object

	Local oChkp1701 As Object
	Local oChkCCT02 As Object
	Local oChkLOC03 As Object
	Local oChkSET04 As Object

	Default lCheck01 :=  .F.
	Default lCheck02 :=  .F.
	Default lCheck03 :=  .F.
	Default lCheck04 :=  .F.
	Default cArquivo :=  ""
	Default cArqCCT  :=  ""
	Default cArqLOC  :=  ""
	Default cArqSET  :=  ""

//SOMENTE PARA TESTE
/*
cArquivo :=  "c:\testes\integrador pedidos\teste_todos_pedidos.csv"
cArqCCT  :=  "c:\testes\integrador pedidos\depara_ctt.csv"
cArqLOC  :=  "c:\testes\integrador pedidos\depara_nnr_local.csv"
cArqSET  :=  "c:\testes\integrador pedidos\depara_p11_setor.csv"
lCheck01 :=  .T.
lCheck02 :=  .T.
lCheck03 :=  .T.
lCheck04 :=  .T.
*/
//

	aArea2 := GetArea()

	nAltGet  := 13

	oGroup1 := TGroup():New(20,25,50,400,'Arquivo de Pedidos',oPanel,,,.T.)

	oButton := TButton():New( 30, 30 , "Selecione arquivo...",oPanel,{ || cArquivo := cGetFile("Arquivos .CSV|*.CSV","Selecione o arquivo a ser importado",0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE) }, 60, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGetarq   := TGet():New( 30, 95, { |u| If( PCount() > 0, cArquivo := u, cArquivo ) }, oPanel, 280, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cArquivo" )

	oGroup2 := TGroup():New(60,25,180,400,'DE-PARA',oPanel,,,.T.)

	oChkp1701 := TCheckBox():New( 70,30, "P17 - Unidade de Medida " , {|u| IF( PCOUNT()==0, lCheck01, lCheck01:=u )},oGroup2,140,20,,,,,,,,.T.,,,)
//oButton1 := TButton():New( 80, 30 , "Selecione arquivo...",oGroup2,{ || cArqCCT := cGetFile("Arquivos .CSV|*.CSV","Selecione o arquivo a ser importado",0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE) }, 60, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )
//oGet1   := TGet():New( 80, 95, { |u| If( PCount() > 0, cArqCCT := u, cArqCCT ) }, oGroup2, 280, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cArquCCT" )
//oChkp1701:cTooltip := 'Informar o arquivo de DE-PARA de Centro de Custo se selecionado.'

	oChkCCT02 := TCheckBox():New( 90,30, "CTT - Centro de Custo " , {|u| IF( PCOUNT()==0, lCheck02, lCheck02:=u )},oGroup2,140,20,,,,,,,,.T.,,,)

	oChkLOC03 := TCheckBox():New( 110,30, "NNR - Local de Estoque" , {|u| IF( PCOUNT()==0, lCheck03, lCheck03:=u )},oGroup2,140,20,,,,,,,,.T.,,,)
	oButton3 := TButton():New( 120, 30 , "Selecione arquivo...",oPanel,{ || cArqLOC := cGetFile("Arquivos .CSV|*.CSV","Selecione o arquivo a ser importado",0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE) }, 60, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGet3   := TGet():New( 120, 95, { |u| If( PCount() > 0, cArqLOC := u, cArqLOC ) }, oPanel, 280, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cArqLOC" )

	oChkSET04 := TCheckBox():New( 150,30, "P11 - Setor"            , {|u| IF( PCOUNT()==0, lCheck04, lCheck04:=u )},oGroup2,140,20,,,,,,,,.T.,,,)
	oButton4 := TButton():New( 160, 30 , "Selecione arquivo...",oPanel,{ || cArqSET := cGetFile("Arquivos .CSV|*.CSV","Selecione o arquivo a ser importado",0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE) }, 60, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGet4   := TGet():New( 160, 95, { |u| If( PCount() > 0, cArqSET := u, cArqSET ) }, oPanel, 280, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cArqSET" )

	RestArea(aArea2)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} ValStep2

Função responsável pela verificação se foi selecionado um arquivo (CSV).

@type function
@version  
@author Sato
@since 19/05/2025
@param cArquivo, character, param_description
@return logical, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValStep2(cArquivo As Character, lCheck03 as Logical, lCheck04 as Logical, cArqLOC As Character, cArqSET As Character) As Logical

	Local lRet As Logical

	lRet := .T.

	If Empty(cArquivo)
		lRet := .F.
		Help(' ',1,'Preenchimento' ,,'Selecione o Arquivo com a Lista de Pedidos para poder prosseguir.',2,0,)
	EndIf

	If lCheck03
		If Empty(cArqLOC)
			lRet := .F.
			Help(' ',1,'Preenchimento' ,,'Selecione o Arquivo de DE-PARA de Local de Estoque para poder prosseguir.',2,0,)
		EndIf
	EndIf

	If lCheck04
		If Empty(cArqSET)
			lRet := .F.
			Help(' ',1,'Preenchimento' ,,'Selecione o Arquivo de DE-PARA para poder prosseguir.',2,0,)
		EndIf
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3

Função que monta a tela de conferência dos dados dos Pedidos de Compras a serem integrados.

@type function
@version  
@author Sato
@since 26/05/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3( oPanel As Object, cArquivo As Character, lCheck01 as Logical, lCheck02 as Logical, lCheck03 as Logical, lCheck04 as Logical, cArqLOC As Character, cArqSET As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array )

	local oOK    As object
	local oNO    As object
	local oBrw   As object
	Local aArea3 As Array

	oOK := LoadBitmap(GetResources(), "br_verde")
	oNO := LoadBitmap(GetResources(), "br_vermelho")

	Default aListaPed := {}
	Default aDadosSC7 := {}
	Default aCampos   := {}

	aArea3 := GetArea()

	FWMsgRun(oPanel, {|oSay| Step3Proc(oSay, cArquivo, lCheck01, lCheck02, lCheck03, lCheck04, cArqLOC, cArqSET, @aListaPed, @aDadosSC7, @aCampos) }, "Processando", "Gerando dados para conferência...")

	oBrw  := TWBrowse():New( 000 , 000 , (oPanel:nClientWidth/2) , (oPanel:nClientHeight/2),,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oBrw:SetArray(aDadosSC7)

	oBrw:AddColumn(TcColumn():New( ""                    , {||If(aDadosSC7[oBrw:nAt][01],oOK,oNO)},,,, "CENTER", 20, .T., .F.,,,, .F., ) )                   // Status
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[02]) , {|| aDadosSC7[oBrw:nAt][02] },,,,'LEFT' ,GetSx3Cache(aCampos[02],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_FILIAL
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[03]) , {|| aDadosSC7[oBrw:nAt][03] },,,,'LEFT' ,GetSx3Cache(aCampos[03],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_NUM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[04]) , {|| aDadosSC7[oBrw:nAt][04] },,,,'LEFT' ,GetSx3Cache(aCampos[04],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_ITEM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[05]) , {|| aDadosSC7[oBrw:nAt][05] },,,,'LEFT' ,GetSx3Cache(aCampos[05],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_PRODUTO
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[06]) , {|| aDadosSC7[oBrw:nAt][06] },,,,'LEFT' ,GetSx3Cache(aCampos[06],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_UM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[07]) , {|| aDadosSC7[oBrw:nAt][07] },,,,'LEFT' ,GetSx3Cache(aCampos[07],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // P17_UM1
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[08]) , {|| aDadosSC7[oBrw:nAt][08] },,,,'LEFT' ,GetSx3Cache(aCampos[08],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_SEGUM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[09]) , {|| aDadosSC7[oBrw:nAt][09] },,,,'LEFT' ,GetSx3Cache(aCampos[09],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // P17_UM2
	oBrw:AddColumn(TCColumn():New( "Local DE"            , {|| aDadosSC7[oBrw:nAt][10] },,,,'LEFT' ,GetSx3Cache(aCampos[10],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_LOCAL DE
	oBrw:AddColumn(TCColumn():New( "Local Para"          , {|| aDadosSC7[oBrw:nAt][11] },,,,'LEFT' ,GetSx3Cache(aCampos[11],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_LOCAL PARA
	oBrw:AddColumn(TCColumn():New( "Setor DE"            , {|| aDadosSC7[oBrw:nAt][12] },,,,'LEFT' ,GetSx3Cache(aCampos[12],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XCODSET DE
	oBrw:AddColumn(TCColumn():New( "Setor PARA"          , {|| aDadosSC7[oBrw:nAt][13] },,,,'LEFT' ,GetSx3Cache(aCampos[13],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XCODSET PARA
	oBrw:AddColumn(TCColumn():New( "Centro Custo DE"     , {|| aDadosSC7[oBrw:nAt][14] },,,,'LEFT' ,GetSx3Cache(aCampos[14],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_CC DE
	oBrw:AddColumn(TCColumn():New( "Centro Custo PARA"   , {|| aDadosSC7[oBrw:nAt][15] },,,,'LEFT' ,GetSx3Cache(aCampos[15],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_CC PARA
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[16]) , {|| aDadosSC7[oBrw:nAt][16] },,,,'LEFT' ,GetSx3Cache(aCampos[16],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XORIG
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[17]) , {|| aDadosSC7[oBrw:nAt][17] },,,,'LEFT' ,GetSx3Cache(aCampos[17],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XNUM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[18]) , {|| aDadosSC7[oBrw:nAt][18] },,,,'LEFT' ,GetSx3Cache(aCampos[18],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XFRONT
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[19]) , {|| aDadosSC7[oBrw:nAt][19] },,,,'LEFT' ,GetSx3Cache(aCampos[19],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XID
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[20]) , {|| aDadosSC7[oBrw:nAt][20] },,,,'LEFT' ,GetSx3Cache(aCampos[20],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XDTINT
	oBrw:AddColumn(TCColumn():New( "Descrição do Erro"   , {|| aDadosSC7[oBrw:nAt][21] },,,,'LEFT' ,250,.F.,.F.,,,,.F.,))                                    // DESCRICAO DO ERRO

	RestArea(aArea3)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} ValStep3

Função que verifica se os Campos e os dados são válidos

@type function
@version  
@author Sato
@since 11/29/2022
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return logical, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValStep3( aListaPed As Array, aDadosSC7 As Array, aCampos As Array ) As Logical

	Local lRet  As Logical

	lRet := .T.

	If Len(aListaPed) = 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
	EndIf

	If Len(aDadosSC7) = 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
	EndIf

	If Len(aCampos) = 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
	EndIf

/*
If aScan(aDadosSC7,{|x| x[1] == .F.}) > 0
    lRet := .F.
    Help(' ',1,'Inválido' ,,'Arquivo de dados com ERRO.',2,0,)
EndIf
*/

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step4

Função que executa o processamento dos dados contidos no arquivo de correção

@type function
@version  
@author Sato
@since 12/02/2022
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step4( oPanel As Object, cArquivo As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array, aLogs As Array, cArqConf As Character, aConfer As Array )

	Local aArea4 As Array

	Default cArquivo  := ""
	Default aListaPed := {}
	Default aDadosSC7 := {}
	Default aCampos   := {}
	Default aLogs     := {}
	Default cArqConf  := ""
	Default aConfer   := {}

	aArea4 := GetArea()

	FWMsgRun(oPanel, {|oSay| Step4Proc(oSay, cArquivo, aListaPed, aDadosSC7, aCampos, @aLogs, @cArqConf, @aConfer) }, "Processando", "Processando os Pedidos de Compras...")

	FWAlertSuccess("Finalizado o processo de Leitura e Upload de Pedido de Compras", "Upload de Pedido de Compras")

	RestArea(aArea4)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValStep4

Função que verifica se o arquivo de LOg esta vazio

@type function
@version  
@author Sato
@since 12/09/2022
@param aLogs, array, param_description
@return logical, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValStep4( aLogs As Array ) As Logical

	Local lRet  As Logical

	lRet := .T.

	If Len(aLogs) = 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de Log inválido.',2,0,)
	EndIf

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step5

Função que apresenta a tela definalização do processamento

@type function
@version  
@author Sato
@since 11/28/2022
@param oPanel, variant, param_description
@param cArquivo, character, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
Static Function Step5( oPanel As Objecto, cArquivo As Character, aLogs As Array, cArqConf As Character, aConfer As Array)

	Default aLogs     := {}
	Default cArquivo  := ""

	FWMsgRun(oPanel, {|oSay| GeraCSV(oSay, aLogs, cArquivo) }, "Processando", "Gerando arquivo de Logs...")

	FWMsgRun(oPanel, {|oSay| GeraCSV(oSay, aConfer, cArqConf) }, "Processando", "Gerando arquivo de Conferência...")

	oFont:= TFont():New(,,-25,.T.,.T.,,,,,)

	oSayTop := TSay():New(10,15,{|| "Finalizado o processo de Upload dos Pedidos de Compras."},oPanel,,oFont,,,,.T.,CLR_BLUE,)
	oSayBottom1 := TSay():New(35,10,{|| "Consulte o arquivo de log no mesmo diretório onde esta o arquivo do Upload."},oPanel,,,,,,.T.,CLR_BLUE,)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3Proc

Rotina responsável por realizar a leitura do arquivo CSV.

@type function
@version  
@author Sato
@since 26/05/2025
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3Proc(oSay As Object, cArquivo As Character, lCheck01 as Logical, lCheck02 as Logical, lCheck03 as Logical, lCheck04 as Logical, cArqLOC As Character, cArqSET As Character, aListaPed AS Array, aDadosSC7 As Array, aCampos As Array )

	Local cBuffer   as Character
	Local aLinha    as Array
	Local nContLin  as Numeric

	Local aDeParaLoc as Array
	Local aDeParaSet as Array

	Default aListaPed := {}
	Default aDadosSC7 := {}
	Default aCampos   := {}

	cBuffer     := ""
	aLinha      := {}
	nContLin    := 0

	aDeParaLoc  := {}
	aDeParaSet  := {}
	aListaPed   := {}

	aCampos := {"STATUS","C7_FILIAL", "C7_NUM", "C7_ITEM", "C7_PRODUTO", "C7_UM", "P17_UM1", "C7_SEGUM", "P17_UM2", "C7_LOCAL", "C7_LOCAL", "C7_XCODSET", "C7_XCODSET", "C7_CC", "C7_CC", "C7_XORIG", "C7_XNUM", "C7_XFRONT", "C7_XID", "C7_XDTINT", "ERRO"}

	FT_FUSE(cArquivo)
	FT_FGOTOP()

	While !FT_FEOF()

		// Capturar dados  
		cBuffer := FT_FREADLN() //LENDO LINHA
		nContLin++
		aLinha := Separa(";"+Upper(cBuffer), ";")
		//aLinha := Separa( Upper(";"+cBuffer)+";", ";")

		If Empty(aLinha)
			Exit
		EndIf

		If nContLin > 2
			AADD( aListaPed, aLinha )
		EndIf

		FT_FSKIP()

	Enddo

	FT_FUSE()



	FT_FUSE(cArqLOC)
	FT_FGOTOP()
	nContLin := 0

	While !FT_FEOF()

		// Capturar dados
		cBuffer := FT_FREADLN() //LENDO LINHA
		nContLin++
		aLinha := Separa( Upper(cBuffer), ";")

		If Empty(aLinha)
			Exit
		EndIf

		If nContLin > 1
			AADD( aDeParaLoc, aLinha )
		EndIf

		FT_FSKIP()

	Enddo

	FT_FUSE()


	FT_FUSE(cArqSET)
	FT_FGOTOP()
	nContLin := 0

	While !FT_FEOF()

		// Capturar dados
		cBuffer := FT_FREADLN() //LENDO LINHA
		nContLin++
		aLinha := Separa( Upper(cBuffer), ";")

		If Empty(aLinha)
			Exit
		EndIf

		If nContLin > 1
			AADD( aDeParaSet, aLinha )
		EndIf

		FT_FSKIP()

	Enddo

	FT_FUSE()


	ValidaPC(aListaPed, aDadosSC7, lCheck01, lCheck02, lCheck03, lCheck04, aDeParaLoc, aDeParaSet)

Return .t.



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPC

Rotina responsável por realizar a pré validação dos Pedidos de Compra a serem integrados.

@type function
@version  
@author Sato
@since 26/05/2025
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValidaPC(aListaPed As Array, aDadosSC7 As Array, lCheck01 as Logical, lCheck02 as Logical, lCheck03 as Logical, lCheck04 as Logical, aDeParaLoc As Array, aDeParaSet As Array)

	local aArea := getarea()
	Local nX := 1
	Local nY := 1
	Local lFlag := .T.
	Local cDesc := ""

	Local cFilPed := ""
	Local cNumPed := ""
//Local nCont   := 0
	Local cFilP17 := ""
	Local nPosPed := 0

	Default aListaPed  = {}
	Default aDadosSC7  = {}
	Default lCheck01   = .F.
	Default lCheck02   = .F.
	Default lCheck03   = .F.
	Default lCheck04   = .F.
	Default aDeParaLoc = {}
	Default aDeParaSet = {}

	For nX := 1 To Len(aListaPed)

		// 01 - C7_FILIAL
		cFilPed := aListaPed[nX,2]
		If !EMPTY(cFilPed)
        /* // Não utilizar esta validação pois ela mata os dados da sessão impossibilitando usar o xFilial ou FwxFilial
        If !FWFilialStatus(cFilPed)
            cDesc += "Filial não encadastrada ou bloqueada para uso.|"
            lFlag := .F.
        EndIf
        */
			cCodEmp := FWCodEmp()
			/*/If !FwFilExist(cCodEmp, cFilPed)
				cDesc += "Filial não cadastrada.|"
				lFlag := .F.
			EndIf/*/

		Else
			cDesc += "C7_FILIAL => Campo Filial é obrigatório.|"
			lFlag := .F.
		EndIF

		// 02 - C7_NUM
		If !EMPTY(aListaPed[nX,3])
			cNumPed := aListaPed[nX,3]
			dbSelectArea("SC7")
			SC7->( dbSetOrder(1) )              //1 - C7_FILIAL+C7_NUM+C7_ITEM_C7_SEQUEN   // 3 - C7_FILIAL+C7_FORNECE_C7_LOJA+C7_NUM
			SC7->( dbGoTop() )
			IF SC7->( dbSeek(cFilPed+cNumPed) )
				Do While SC7->C7_FILIAL == cFilPed .and. SC7->C7_NUM == cNumPed
					//If nCont > 1
					aAdd(aDadosSC7, {.T., SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_ITEM, SC7->C7_PRODUTO, SC7->C7_UM, space(GetSx3Cache("P17_UM1","X3_TAMANHO")), SC7->C7_SEGUM, space(GetSx3Cache("P17_UM2","X3_TAMANHO")), ALLTRIM(SC7->C7_LOCAL), space(GetSx3Cache("C7_LOCAL","X3_TAMANHO")), ALLTRIM(SC7->C7_XCODSET), space(GetSx3Cache("C7_XCODSET","X3_TAMANHO")), ALLTRIM(SC7->C7_CC), space(GetSx3Cache("C7_CC","X3_TAMANHO")), SC7->C7_XORIG, SC7->C7_XNUM, SC7->C7_XFRONT, SC7->C7_XID, SC7->C7_XDTINT, space(50)})
					//aAdd(aDadosSC7, {.T., space(GetSx3Cache("C7_FILIAL","X3_TAMANHO")), space(GetSx3Cache("C7_NUM","X3_TAMANHO")), SC7->C7_ITEM, SC7->C7_PRODUTO, SC7->C7_UM, space(GetSx3Cache("P17_UM1","X3_TAMANHO")), SC7->C7_SEGUM, space(GetSx3Cache("P17_UM2","X3_TAMANHO")), ALLTRIM(SC7->C7_LOCAL), space(GetSx3Cache("C7_LOCAL","X3_TAMANHO")), ALLTRIM(SC7->C7_XCODSET), space(GetSx3Cache("C7_XCODSET","X3_TAMANHO")), ALLTRIM(SC7->C7_CC), space(GetSx3Cache("C7_CC","X3_TAMANHO")), SC7->C7_XORIG, SC7->C7_XNUM, SC7->C7_XFRONT, SC7->C7_XID, SC7->C7_XDTINT, space(50)})
					//EndIf
					If SC7->C7_CONAPRO == 'L' .and. SC7->C7_ENCER <> 'E' .and. SC7->C7_RESIDUO == ' ' .and. SC7->C7_QUJE == 0  .and. SC7->C7_QTDACLA == 0
						If lCheck01         //Verifica se irá trocar das Unidades de Medidas do produto
							cFilP17 := space(GetSx3Cache("P17_FILIAL","X3_TAMANHO"))+SC7->C7_PRODUTO+cFilPed

							//aMed := GetAdvFVal("P17", {"P17_COD","P17_UM1","P17_CONV1","P17_UM2","P17_CONV2"}, space(GetSx3Cache("P17_FILIAL","X3_TAMANHO"))+aDadosSC7[nX,5]+cFilPed, 1 )         // P17_FILIAL+P17_COD+P17_FTRATA

							dbSelectArea("P17")
							P17->( dbSetOrder(1) )          // P17_FILIAL+P17_COD+P17_FTRATA
							P17->( dbGoTop() )
							IF P17->( dbSeek(cFilP17) )
								If P17_BLOQ == 'N'
									If SC7->C7_UM <> P17_UM1
										If P17_CONV1 == 1
											aDadosSC7[LEN(aDadosSC7),7] := P17->P17_UM1
										Else
											cDesc += ALLTRIM(SC7->C7_PRODUTO)+" - Produto com Fator de Conversão diferente de 1 x 1 na tabela P17. | "
											lFlag := .F.
										EndIf
									EndIf
									If SC7->C7_SEGUM <> P17_UM2
										If P17_CONV2 == 1
											aDadosSC7[LEN(aDadosSC7),9] := P17->P17_UM2
										Else
											cDesc += ALLTRIM(SC7->C7_PRODUTO)+" - Produto com Fator de Conversão diferente de 1 x 1 na tabela P17. | "
											lFlag := .F.
										EndIf
									EndIf
								Else
									cDesc += ALLTRIM(SC7->C7_PRODUTO)+" - Produto bloqueado na tabela P17. | "
									lFlag := .F.
								EndIf
							Else
								cDesc += ALLTRIM(SC7->C7_PRODUTO)+" - Produto não encontrado na tabela P17. | "
								lFlag := .F.
							EndIf
							dbSelectArea("SC7")
						EndIf

						// 10 - C7_LOCAL
						If lCheck03         //Verifica se irá fazer o DE-PARA de Local de Estoque
							If aScan(aDeParaLoc, {|x| x[1] == ALLTRIM(SC7->C7_LOCAL)}) > 0
								aDadosSC7[LEN(aDadosSC7),10] := ALLTRIM(SC7->C7_LOCAL)
								aDadosSC7[LEN(aDadosSC7),11] := aDeParaLoc[ aScan(aDeParaLoc, {|x| x[1] == ALLTRIM(SC7->C7_LOCAL)}) ][2]
								If lCheck02         //Verifica se irá fazer o DE-PARA de Centro de Custo
									aDadosSC7[LEN(aDadosSC7),14] := ALLTRIM(SC7->C7_CC)
									aDadosSC7[LEN(aDadosSC7),15] := aDeParaLoc[ aScan(aDeParaLoc, {|x| x[1] == ALLTRIM(SC7->C7_LOCAL)}) ][3]
								EndIf
							Else
								aDadosSC7[LEN(aDadosSC7),10] := ALLTRIM(SC7->C7_LOCAL)
								aDadosSC7[LEN(aDadosSC7),14] := ALLTRIM(SC7->C7_CC)
							EndIf
						EndIf

						// 10 - C7_XCODSET
						If lCheck04         //Verifica se irá fazer o DE-PARA de Setor
							If aScan(aDeParaSet, {|x| x[1] == ALLTRIM(SC7->C7_XCODSET)}) > 0
								aDadosSC7[LEN(aDadosSC7),12] := ALLTRIM(SC7->C7_XCODSET)
								aDadosSC7[LEN(aDadosSC7),13] := aDeParaSet[ aScan(aDeParaSet, {|x| x[1] == ALLTRIM(SC7->C7_XCODSET)}) ][2]
								If lCheck02         //Verifica se irá fazer o DE-PARA de Centro de Custo
									aDadosSC7[LEN(aDadosSC7),14] := ALLTRIM(SC7->C7_CC)
									aDadosSC7[LEN(aDadosSC7),15] := aDeParaSet[ aScan(aDeParaSet, {|x| x[1] == ALLTRIM(SC7->C7_XCODSET)}) ][3]
								EndIf
							Else
								aDadosSC7[LEN(aDadosSC7),12] := ALLTRIM(SC7->C7_XCODSET)
								aDadosSC7[LEN(aDadosSC7),14] := ALLTRIM(SC7->C7_CC)
							EndIf
						EndIf
					Else
						If SC7->C7_ENCER == 'E'             // PEDIDO ENCERRADO
							cDesc += "Pedido de Compra encerrado."
							lFlag := .F.
						EndIf
						If SC7->C7_CONAPRO == 'B'           // PEDIDO LIBERADO
							cDesc += "Pedido de Compra bloqueado."
							lFlag := .F.
						EndIf
						If SC7->C7_RESIDUO <> ' '           // PEDIDO ELIMINADO RESIDUO
							cDesc += "Pedido de Compra eliminaod residuo."
							lFlag := .F.
						EndIf
						If SC7->C7_QUJE > 0                 // PEDIDO PARCIAL
							cDesc += "Pedido de Compra recebido parcial."
							lFlag := .F.
						EndIf
						If SC7->C7_QTDACLA > 0              // PEDIDO EM RECEBIMENTO
							cDesc += "Pedido de Compra em recebimento."
							lFlag := .F.
						EndIf
					EndIf

					If !lFlag
						aDadosSC7[LEN(aDadosSC7),1] := .F.
						aDadosSC7[LEN(aDadosSC7),21] := OEMToANSI( cDesc )
						lFlag := .F.
						cDesc := ""

						aListaPed[nX,1] := .F.
					Else
						aDadosSC7[LEN(aDadosSC7),1] := .T.
						aDadosSC7[LEN(aDadosSC7),21] := ""

						aListaPed[nX,1] := .T.
					EndIf

					SC7->( dbSkip() )
				End
			Else
				cDesc += "Pedido de Compra não encontrado."

				aAdd(aDadosSC7, {.F., cFilPed, cNumPed, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", cDesc })

				aListaPed[nX,1] := .F.
			EndIf
		Else
			cDesc += "C7_NUM => Campo Número do Pedido é obrigatório."

			aAdd(aDadosSC7, {.F., cFilPed, cNumPed, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", cDesc })

			aListaPed[nX,1] := .F.
		EndIf

		nPosPed := aScan(aDadosSC7, {|x| x[3] == ALLTRIM(cNumPed)})
		If nPosPed > 0
			For nY := nPosPed To Len(aDadosSC7)
				If aDadosSC7[nPosPed,3] == cNumPed
					If aListaPed[nX,1] == .T.
						aDadosSC7[nY,1] := .T.
					Else
						aDadosSC7[nY,1] := .F.
					EndIf
				Else
					Exit
				EndIf
			Next nY
		EndIf

		lFlag := .T.
		cDesc := ""

	Next nX

	restarea( aArea )

Return .t.



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step4Proc

Rotina responsável por realizar o cadastro dos Pedidos de Compra automaticamente.

@type function
@version  
@author Sato
@since 12/05/2024
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step4Proc(oSay As Object, cArquivo As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array, aLogs As Array, cArqConf As Character, aConfer As Array)

	Local nX       := 1
	Local nY       := 1

	Local cDrive   := ""
	Local cDir     := ""
	Local cNome    := ""
	Local cExt     := ""

	Local cFilPed  := ""
	Local cNumPed  := ""

	Local cCpoConf := ""
	Local cLinConf := ""

	Default cArquivo  := ""
	Default aListaPed := {}
	Default aDadosSC7 := {}
	Default aCampos   := {}
	Default aLogs     := {}
	Default cArqConf  := ""
	Default aConfer   := {}

	AADD(aLogs, "FILIAL;NUMERO;STATUS" )

	For nX := 1 To len(aListaPed)

		cFilPed := aListaPed[nX,2]
		cNumPed := aListaPed[nX,3]

		If aListaPed[nX,1] == .T.
			dbSelectArea("SC7")
			SC7->( dbSetOrder(1) )           //1 - C7_FILIAL+C7_NUM+C7_ITEM_C7_SEQUEN   // 3 - C7_FILIAL+C7_FORNECE_C7_LOJA+C7_NUM
			SC7->( dbGoTop() )
			IF SC7->( dbSeek(cFilPed+cNumPed) )
				Do While SC7->C7_FILIAL == cFilPed .and. SC7->C7_NUM == cNumPed
					SC7->( RecLock("SC7",.F.) )
					// ALTERANDO OS CAMPOS DE DE-PARA
					// LOCAL DE ESTOQUE
					If ALLTRIM(SC7->C7_LOCAL) <> ALLTRIM(aDadosSC7[nX,11]) .and. !empty(aDadosSC7[nX,11])
						SC7->C7_LOCAL := aDadosSC7[nX,11]
					EndIf

					// SETOR
					If ALLTRIM(SC7->C7_XCODSET) <> ALLTRIM(aDadosSC7[nX,13]) .and. !empty(aDadosSC7[nX,13])
						SC7->C7_XCODSET := aDadosSC7[nX,13]
					EndIf

					// CENTRO DE CUSTO
					If ALLTRIM(SC7->C7_CC) <> ALLTRIM(aDadosSC7[nX,15]) .and. !empty(aDadosSC7[nX,15])
						SC7->C7_CC := aDadosSC7[nX,15]
					EndIf

					// ALTERANDO OS CAMPOS DO PRDOUTO
					// UNIDADE DE MEDIDA -
					If ALLTRIM(SC7->C7_UM) <> ALLTRIM(aDadosSC7[nX,7]) .and. !empty(aDadosSC7[nX,7])
						SC7->C7_UM := aDadosSC7[nX,7]
					EndIf

					// UNIDADE DE MEDIDA -
					If ALLTRIM(SC7->C7_SEGUM) <> ALLTRIM(aDadosSC7[nX,9]) .and. !empty(aDadosSC7[nX,9])
						SC7->C7_SEGUM := aDadosSC7[nX,9]
					EndIf

					// LIMPANDO OS CAMPOS PARA PODER SER INTEGRADO NOVAMENTE
					SC7->C7_ORIGEM  := space( GetSx3Cache("C7_ORIGEM","X3_TAMANHO") )
					SC7->C7_XNUM    := space( GetSx3Cache("C7_XNUM","X3_TAMANHO") )
					SC7->C7_XFRONT  := space( GetSx3Cache("C7_XFRONT","X3_TAMANHO") )
					SC7->C7_XID     := space( GetSx3Cache("C7_XID","X3_TAMANHO") )
					//SC7->C7_XDTINT  := CTOD( space( GetSx3Cache("C7_XDTINT","X3_TAMANHO") ) )
					IF EMPTY(SC7->C7_XINFPAC)
						SC7->C7_XINFPAC := "Pedido reenviado para o Front no Rollout realizado no dia 01/07/2025."
					Else
						SC7->C7_XINFPAC := ALLTRIM(SC7->C7_XINFPAC)+" | Pedido reenviado para o Front no Rollout realizado no dia 01/07/2025."
					EndIf

					SC7->( MsUnlock() )

					SC7->( dbSkip() )
				End

				// Função responsável pelo envio do Pedido para o Barramento
				u_F07022RE(cNumPed, 'I')

				AADD(aLogs, cFilPed+";"+cNumPed+";Pedido enviado para o Barramento." )
			EndIf
		Else
			AADD(aLogs, cFilPed+";"+cNumPed+";Pedido não enviado para o Barramento." )
		EndIf

	Next nX

// Montando arquivo de conferencia
	SplitPath( cArquivo, cDrive, cDir, cNome, cExt )
	cArqConf  := cDrive+cDir+"CONFERENCIA"+cExt

// Monta o Cabecalho do arquivo de conferencia
	cCpoConf := ""
	For nX := 1 To len(aCampos)
		cCpoConf += aCampos[nx]+";"
	Next nX
	cCpoConf := SubStr( cCpoConf, 1, Len(cCpoConf)-1 )
	aAdd(aConfer, cCpoConf )


// Monta os itens do arquivo de conferencia
	cLinConf := ""
	For nX := 1 To len(aDadosSC7)
		For nY := 1 To len(aCampos)
			DO CASE
			CASE aCampos[nY] == "STATUS"
				If aDadosSC7[nX][nY] = .T.
					cLinConf += "Enviado;"
				Else
					cLinConf += "Não Enviado;"
				EndIf
			CASE aCampos[nY] == "C7_XDTINT"
				//cLinConf += DtoC(aDadosSC7[nX][nY])+";"
				cLinConf += DtoC(date())+";"
			OTHERWISE
				cLinConf += aDadosSC7[nX][nY]+";"
			ENDCASE
		Next nY
		cLinConf := SubStr( cLinConf, 1, Len(cLinConf)-1 )
		aAdd(aConfer, cLinConf )
		cLinConf := ""
	Next nX

Return .t.




//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraCSV

Função responsável por gerar o arquivo de Log

@type function
@version  
@author Sato
@since 12/05/2024
@param oSay, object, param_description
@param aLogs, array, param_description
@param cArquivo, character, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function GeraCSV(oSay As Object, aLogs As Array, cArquivo As Character)

	Local nFile
	Local cDrive
	Local cDir
	Local cNome
	Local cExt

	Local cArq
	Local cPath
	Local nX

	SplitPath( cArquivo, cDrive, cDir, cNome, cExt )

	If!ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não iNTSalado!")
		Return
	EndIf

	cArq  := cNome+"_LOG"+cExt

	cPath := cDrive+cDir

	nFile  := FCreate(cPath+cArq)

	If nFile==-1
		MsgAlert("Nao conseguiu criar o arquivo!")
		Return
	EndIf

	For nX:=1 TO LEN(aLogs)
		FWrite(nFile,aLogs[nX]+Chr(13)+Chr(10))
	Next nX

	FClose(nFile)

	shellExecute("Open", cPath,"Null" , "C:\", 1 )

Return
