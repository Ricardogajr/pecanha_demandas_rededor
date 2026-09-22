#Include "Protheus.ch"
#Include "rwmake.ch"
#include "totvs.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} RDNFUPLOAD

Função responsável pela realização de Upload das Notas Fiscais.

@type function
@version  
@author Sato
@since 25/04/2025
@return array, return_description
/*/
//------------------------------------------------------------------------------

User Function RDNFUPLOAD() As Array
//User Function F0703301()

	Local oWizard       As Object
	Local oStep1        As Object
	Local oStep2        As Object
	Local oStep3        As Object
	Local oStep4        As Object
	Local oStep5        As Object

	Local cDirlocal     As Character
	Local lProcessar    As Logical
	Local lCancel		As Logical
	Local aRetTela      As Array
	Local aAux          As Array
	Local aAuxBco       As Array
	Local aBancos       As Array

	Local cArquivo      As Character
	Local aDadosNF      As Array
	Local aCampos       As Array
	Local aLogs         As Array

	Local cFilBkp := ''

	cArquivo    := ""
	aDadosNF    := {}
	aCampos     := {}
	aLogs       := {}

	cDirlocal   := ""
	lProcessar  := .F.
	aRetTela    := {}
	aAux        := {}
	aAuxBco     := {}
	aBancos     := {}
	lCancel		:= .F.

	cFilBkp     := cFilAnt

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
	oStep2 := oWizard:AddStep( 'Step2', { | oPanel | Step2( oPanel, @cArquivo ) } )
	oStep2:SetStepDescription( "Seleção de Arquivo" )      	        // Define o título do "Passo" | "Seleção de Arquivo"
	oStep2:SetNextTitle( "Próximo" )						        // Define o título do botão de avanço | "Próximo"
	oStep2:SetNextAction( { || ValStep2( cArquivo ) } )	            // Define o bloco ao clicar no botão Próximo
	oStep2:SetCancelAction( { || lCancel := .T. } )			        // Define o bloco ao clicar no botão Cancelar

/*
    "Conferência dos Dados"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
*/
	oStep3 := oWizard:AddStep( 'Step3', { | oPanel | Step3( oPanel, cArquivo, @aDadosNF, @aCampos ) } )
	oStep3:SetStepDescription( "Conferência dos Dados" )            // Define o título do "Passo" | "Conferência dos Dados"
	oStep3:SetNextTitle( "Próximo" )								// Define o título do botão de avanço | "Próximo"
	oStep3:SetNextAction( { || ValStep3( aDadosNF, aCampos ) } )    // Define o bloco ao clicar no botão Próximo
	oStep3:SetCancelAction( { || lCancel := .T. } )					// Define o bloco ao clicar no botão Cancelar

/*
    "Processamento das correções"
*/
	oStep4 := oWizard:AddStep( 'Step4', { | oPanel | Step4( oPanel, cArquivo, aDadosNF, aCampos, @aLogs ) } )
	oStep4:SetStepDescription( "Processamento das Notas" )          // Define o título do "Passo" | "Processamento das correções"
	oStep4:SetNextTitle( "Próximo" )                                // Define o título do botão de avanço | "Próximo"
	oStep4:SetNextAction( { || ValStep4( aLogs ) } )                // Define o bloco ao clicar no botão Próximo
	oStep4:SetCancelAction( { || lCancel := .T. } )                 // Define o bloco ao clicar no botão Cancelar

/*
    "Finalização"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
*/
	oStep5 := oWizard:AddStep( 'Step5', { | oPanel | Step5( oPanel, cArquivo, aLogs) } )
	oStep5:SetStepDescription( "Finalização" )                      // Define o título do "Passo" | "Finalização"
	oStep5:SetNextAction( { || .T. } )	                            // Define o bloco ao clicar no botão Próximo
	oStep5:SetCancelAction( { || lCancel := .T. } )					// Define o bloco ao clicar no botão Cancelar

	oWizard:Activate()

	oWizard:Destroy()

	cFilAnt := cFilBkp

	aRetTela := { {}, {}, {}, {}, {}, lCancel }

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

	oSayTop	:= TSay():New( 010,  10, { || "Upload de Notas Fiscais" }, oPanel,, oFont,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 030,  10, { || "Este programa tem como obejtivo realizar manualmente o upload de Notas Fiscais." }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay1	:= TSay():New( 040,  10, { || "Para a realização dos uploads, é necessário a criação de um template no formato CSV com os seguintes campos:" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 050,  15, { || "- F1_FILIAL - Filial do Sistema;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 060,  15, { || "- F1_DOC - Número da NF;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 070,  15, { || "- F1_SERIE - Série da NF;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 080,  15, { || "- F1_FORNECE - Código do Fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 090,  15, { || "- F1_LOJA - Loja do Fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 100,  15, { || "- F1_EMISSAO - Data de Emissão;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 110,  15, { || "- F1_ESPECIE - Especie da NF;" }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay1	:= TSay():New( 050, 125, { || "- F1_COND - Condição de Pagamento;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 060, 125, { || "- F1_DESPESA - Despesas;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 070, 125, { || "- F1_DESCONT - Descontos;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 080, 125, { || "- F1_SEGURO - Seguros;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 090, 125, { || "- F1_FRETE - Fretes;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 100, 125, { || "- xxx;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 110, 125, { || "- xxx;" }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay1	:= TSay():New( 050, 230, { || "- D1_ITEM - Item da NF;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 060, 230, { || "- D1_COD - Código do Produto;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 070, 230, { || "- D1_UM - Unidade de Medida;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 080, 230, { || "- D1_LOCAL - local de Estoque;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 090, 230, { || "- D1_QUANT - Quantidade do Item;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 100, 230, { || "- D1_VUNIT - Valor Unitário;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 110, 230, { || "- D1_TES - Tipo de Entrada;" }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay1	:= TSay():New( 050, 325, { || "- D1_PEDIDO - Número do Pedido;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay1	:= TSay():New( 060, 325, { || "- D1_ITEMPC - Item do Pedido." }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 070, 325, { || "- xxx;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 080, 325, { || "- xxx;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 090, 325, { || "- xxx;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 100, 325, { || "- xxx;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 110, 325, { || "- xxx." }, oPanel,,,,,, .T., CLR_BLUE, )

	oSay2	:= TSay():New( 125, 10, { || "Importante: " }, oPanel,, oFontV,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 135, 10, { || "Os dados do arquivo CSV (template) utilizados como base dos uploads, deverão seguir algumas premissas:" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 145, 15, { || "- Utilizar ponto e vírgula (;) como separador de colunas;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 155, 15, { || "- Utilizar vírgula (,) como separador da parte decimal em campos numéricos;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 165, 15, { || "- Utilizar 4 dígitos para especificar o ano em campos tipo 'data'. Ex.: dd/mm/aaaa;" }, oPanel,,,,,, .T., CLR_BLUE, )
	oSay2	:= TSay():New( 175, 15, { || "- Não conter caracteres especiais;" }, oPanel,,,,,, .T., CLR_BLUE, )

/*
oSay2	:= TSay():New( 145,  10, { || "Importante: " }, oPanel,, oFontV,,,, .T., CLR_BLUE, )
oSay2	:= TSay():New( 155,  10, { || "Os dados do arquivo CSV (template) utilizados como base dos uploads, deverão seguir algumas premissas:" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay2	:= TSay():New( 165,  15, { || "- Utilizar ponto e vírgula (;) como separador de colunas;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay2	:= TSay():New( 175,  15, { || "- Utilizar vírgula (,) como separador da parte decimal em campos numéricos;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay2	:= TSay():New( 165, 220, { || "- Utilizar 4 dígitos para especificar o ano em campos tipo 'data'. Ex.: dd/mm/aaaa;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay2	:= TSay():New( 175, 220, { || "- Não conter caracteres especiais;" }, oPanel,,,,,, .T., CLR_BLUE, )
*/
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Step2

Função responsável pela Seleção do Arquivo de Upload de Notas Fiscais.

@type function
@version  
@author Sato
@since 19/05/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step2( oPanel As Object, cArquivo As Character)

	Local aArea	    As Array
	Local oButton   As Object
	Local oGet1     As Object
	Local nAltGet   As Numeric

	aArea := GetArea()

	nAltGet := 13

	oButton := TButton():New( 70, 10 , "Selecione arquivo...",oPanel,{ || cArquivo := cGetFile("Arquivos .CSV|*.CSV","Selecione o arquivo a ser importado",0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE) }, 60, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGet1   := TGet():New( 70, 75, { |u| If( PCount() > 0, cArquivo := u, cArquivo ) }, oPanel, 280, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cArquivo" )

	RestArea(aArea)

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
Static Function ValStep2(cArquivo As Character) As Logical

	Local lRet As Logical

	lRet := .T.

	If Empty(cArquivo)
		lRet := .F.
		Help(' ',1,'Preenchimento' ,,'Selecione um Arquivo para poder prosseguir.',2,0,)
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3

Função que monta a tela de pré Validação dos dados das Notas Fiscais a serem carregados.

@type function
@version  
@author Sato
@since 19/05/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param aDadosNF, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3( oPanel As Object, cArquivo As Character, aDadosNF As Array, aCampos As Array )

	local oOK   as object
	local oNO   as object
	local oBrw  as object

	oOK := LoadBitmap(GetResources(), "br_verde")
	oNO := LoadBitmap(GetResources(), "br_vermelho")

	Default aDadosNF := {}
	Default aCampos  := {}

	FWMsgRun(oPanel, {|oSay| Step3Proc(oSay, cArquivo, @aDadosNF, aCampos) }, "Processando", "Gerando dados para conferência...")

	oBrw  := TWBrowse():New( 000 , 000 , (oPanel:nClientWidth/2) , (oPanel:nClientHeight/2),,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oBrw:SetArray(aDadosNF)

////////////// TCColumn():New( < cTitulo >           , < bData >                              , [ cPicture ], [ uParam4 ], [ uParam5 ], [ cAlinhamento ], [ nLargura ], [ lBitmap ], [ lEdit ], [ uParam10 ], [ bValid ], [ uParam12 ], [ uParam13 ], [ uParam14 ] )

	oBrw:AddColumn(TcColumn():New( ""                    , {||If(aDadosNF[oBrw:nAt][01],oOK,oNO)},,,, "CENTER", 20, .T., .F.,,,, .F., ) )                  // Status
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[02]) , {|| aDadosNF[oBrw:nAt][02] },,,,'LEFT' ,GetSx3Cache(aCampos[02],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_FILIAL
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[03]) , {|| aDadosNF[oBrw:nAt][03] },,,,'LEFT' ,GetSx3Cache(aCampos[03],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_DOC
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[04]) , {|| aDadosNF[oBrw:nAt][04] },,,,'LEFT' ,GetSx3Cache(aCampos[04],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_SERIE
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[05]) , {|| aDadosNF[oBrw:nAt][05] },,,,'LEFT' ,GetSx3Cache(aCampos[05],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_FORNECE
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[06]) , {|| aDadosNF[oBrw:nAt][06] },,,,'LEFT' ,GetSx3Cache(aCampos[06],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_LOJA
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[07]) , {|| aDadosNF[oBrw:nAt][07] },,,,'LEFT' ,GetSx3Cache(aCampos[07],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_EMISSAO
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[08]) , {|| aDadosNF[oBrw:nAt][08] },,,,'LEFT' ,GetSx3Cache(aCampos[08],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_ESPECIE
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[09]) , {|| aDadosNF[oBrw:nAt][09] },,,,'LEFT' ,GetSx3Cache(aCampos[09],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_COND
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[10]) , {|| aDadosNF[oBrw:nAt][10] },,,,'LEFT' ,GetSx3Cache(aCampos[10],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_EST
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[11]) , {|| aDadosNF[oBrw:nAt][11] },,,,'RIGHT',GetSx3Cache(aCampos[11],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_DESPESA
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[12]) , {|| aDadosNF[oBrw:nAt][12] },,,,'RIGHT',GetSx3Cache(aCampos[12],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_DESCONT
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[13]) , {|| aDadosNF[oBrw:nAt][13] },,,,'LEFT' ,GetSx3Cache(aCampos[13],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_SEGURO
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[14]) , {|| aDadosNF[oBrw:nAt][14] },,,,'LEFT' ,GetSx3Cache(aCampos[14],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // F1_FRETE
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[15]) , {|| aDadosNF[oBrw:nAt][15] },,,,'LEFT' ,GetSx3Cache(aCampos[15],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_ITEM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[16]) , {|| aDadosNF[oBrw:nAt][16] },,,,'RIGHT',GetSx3Cache(aCampos[16],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_COD
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[17]) , {|| aDadosNF[oBrw:nAt][17] },,,,'RIGHT',GetSx3Cache(aCampos[17],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_UM
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[18]) , {|| aDadosNF[oBrw:nAt][18] },,,,'RIGHT',GetSx3Cache(aCampos[18],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_LOCAL
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[19]) , {|| aDadosNF[oBrw:nAt][19] },,,,'LEFT' ,GetSx3Cache(aCampos[19],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_QUANT
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[20]) , {|| aDadosNF[oBrw:nAt][20] },,,,'LEFT' ,GetSx3Cache(aCampos[20],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_VUNIT
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[21]) , {|| aDadosNF[oBrw:nAt][21] },,,,'LEFT' ,GetSx3Cache(aCampos[21],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_TES
//oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[22]) , {|| aDadosNF[oBrw:nAt][22] },,,,'LEFT' ,GetSx3Cache(aCampos[22],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_CC
//oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[23]) , {|| aDadosNF[oBrw:nAt][23] },,,,'LEFT' ,GetSx3Cache(aCampos[23],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_CONTA
//oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[24]) , {|| aDadosNF[oBrw:nAt][24] },,,,'LEFT' ,GetSx3Cache(aCampos[24],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_CF
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[22]) , {|| aDadosNF[oBrw:nAt][22] },,,,'LEFT' ,GetSx3Cache(aCampos[22],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_PEDIDO
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[23]) , {|| aDadosNF[oBrw:nAt][23] },,,,'LEFT' ,GetSx3Cache(aCampos[23],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_ITEMPC
	oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[24]) , {|| aDadosNF[oBrw:nAt][24] },,,,'LEFT' ,GetSx3Cache(aCampos[24],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // D1_CF
	oBrw:AddColumn(TCColumn():New( "Descrição do Erro"   , {|| aDadosNF[oBrw:nAt][25] },,,,'LEFT' ,250,.F.,.F.,,,,.F.,))                                    // DESCRICAO DO ERRO

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} ValStep3

Função que verifica se os arrays de Dados e de Campos tem dados e se os dados são válidos

@type function
@version  
@author Sato
@since 19/05/2025
@param aDadosNF, array, param_description
@param aCampos, array, param_description
@return logical, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValStep3( aDadosNF As Array, aCampos As Array ) As Logical

	Local lRet  As Logical

	lRet := .T.

	If Len(aDadosNF) = 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
	EndIf

	If Len(aCampos) = 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
	EndIf

	If aScan(aDadosNF,{|x| x[1] == .F.}) > 0
		lRet := .F.
		Help(' ',1,'Inválido' ,,'Arquivo de dados com ERRO.',2,0,)
	EndIf

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step4

Função que executa o processamento dos dados contidos no arquivo de Upload de Notas Fiscais

@type function
@version  
@author Sato
@since 19/05/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param aDadosNF, array, param_description
@param aCampos, array, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step4( oPanel As Object, cArquivo As Character, aDadosNF As Array, aCampos As Array, aLogs As Array )

	Default cArquivo := ""
	Default aDadosNF := {}
	Default aCampos  := {}
	Default aLogs    := {}

	FWMsgRun(oPanel, {|oSay| Step4Proc(oSay, cArquivo, aDadosNF, aCampos, @aLogs) }, "Processando", "Processando as Notas Fiscais...")

	FWAlertSuccess("Finalizado o processo de Leitura e Upload de Notas Fiscais", "Upload de Notas Fiscais")

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValStep4

Função que verifica se o arquivo de Log esta vazio

@type function
@version  
@author Sato
@since 19/05/2025
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

Função que realiza a geração do arquivo de Log

@type function
@version  
@author Sato
@since 19/05/2025
@param oPanel, variant, param_description
@param cArquivo, character, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
Static Function Step5( oPanel As Objecto, cArquivo As Character, aLogs As Array )

	Default aLogs     := {}
	Default cArquivo  := ""

	FWMsgRun(oPanel, {|oSay| GeraCSV(oSay, aLogs, cArquivo) }, "Processando", "Gerando arquivo de Logs...")

	oFont:= TFont():New(,,-25,.T.,.T.,,,,,)

	oSayTop := TSay():New(10,15,{|| "Finalizado o processo de Upload das Notas Fiscais."},oPanel,,oFont,,,,.T.,CLR_BLUE,)
	oSayBottom1 := TSay():New(35,10,{|| "Consulte o arquivo de log no mesmo diretório onde esta o arquivo do Upload."},oPanel,,,,,,.T.,CLR_BLUE,)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3Proc

Rotina responsável por realizar a leitura do arquivo CSV

@type function
@version  
@author Sato
@since 19/05/2025
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosNF, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3Proc(oSay As Object, cArquivo As Character, aDadosNF As Array, aCampos As Array )

	Local cBuffer   as Character
	Local aLinha    as Array
	Local nContLin  as Numeric

	cBuffer     := ""
	aLinha      := {}
	nContLin    := 0

	FT_FUSE(cArquivo)
	FT_FGOTOP()

	While !FT_FEOF()

		// Capturar dados
		cBuffer := FT_FREADLN() //LENDO LINHA
		nContLin++
		//aLinha := Separa( Upper(cBuffer), ";")
		aLinha := Separa( Upper(";"+cBuffer)+";;", ";")

		If nContLin > 1
			If Len(aCampos) = 0
				aLinha[01] := "STATUS"
				aLinha[LEN(aLinha)-1] := "D1_CF"
				aLinha[LEN(aLinha)] := "ERRO"
				aCampos := aClone(aLinha)
			Else
				AADD( aDadosNF, aLinha )
			EndIf
		EndIf

		FT_FSKIP()

	Enddo

	FT_FUSE()

	ValDadosNF(aDadosNF, aCampos)

Return .t.



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValDadosNF

Função responsável por realizar as pré validações dos dados do arquivo de Upload de Notas Fiscais

@type function
@version  
@author Sato
@since 19/05/2025
@param aDadosNF, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValDadosNF(aDadosNF As Array, aCampos As Array)

	local aArea := getarea()
	Local nX := 1
	Local nY := 2
	Local lFlag := .T.
	Local cDesc := ""

	Local nPosFil  := 0
	Local nPosNota := 0
	Local nPosSeri := 0
	Local nPosForn := 0
	Local nPosLoja := 0
	Local nPosEmis := 0
	Local nPosEspe := 0
	Local nPosCond := 0
	Local nPosUF   := 0
	Local nPosDesp := 0
	Local nPosDesc := 0
	Local nPosSegu := 0
	Local nPosFret := 0

	Local nPosItem := 0
	Local nPosProd := 0
	Local nPosUnid := 0
	Local nPosLoca := 0
	Local nPosQtde := 0
	Local nPosValu := 0
	Local nPosTes  := 0
	Local nPosNPed := 0
	Local nPosIPed := 0
	Local nPosCFis := 0

	Local cCnpj01   := ""
	Local cCnpj02   := ""
	Local cCodFis   := ""
	Local cEstPC    := ""
	Local cEstNF    := ""

	Local cNFForn  := ""

	Local aFilSF1 := {}

	Default aDadosNF = {}
	Default aCampos = {}

	nPosFil  := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_FILIAL" })       // Filial
	nPosNota := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_DOC" })          // Numero NF
	nPosSeri := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_SERIE" })        // Serie NF
	nPosForn := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_FORNECE" })      // Fornecedor
	nPosLoja := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_LOJA" })         // Loja
	nPosEmis := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_EMISSAO" })      // Data Emissão
	nPosEspe := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_ESPECIE" })      // Especie
	nPosCond := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_COND" })         // Cond. Pagto
	nPosUF   := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_EST" })          // UF Origem
	nPosDesp := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_DESPESA" })      // Vlr. Despesas
	nPosDesc := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_DESCONT" })      // Descontos
	nPosSegu := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_SEGURO" })       // Valor Seguro
	nPosFret := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_FRETE" })        // Valor Frete

	nPosItem := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_ITEM" })         // Item
	nPosProd := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_COD" })          // Produto
	nPosUnid := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_UM" })           // Unid. Consumo
	nPosLoca := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_LOCAL" })        // Local Estoque
	nPosQtde := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_QUANT" })        // Qtd Consumo
	nPosValu := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_VUNIT" })        // Vlr. Unitario
	nPosTes  := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_TES" })          // Tipo Entrada
	nPosNPed := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_PEDIDO" })       // Num. Pedido
	nPosIPed := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_ITEMPC" })       // Item Pedido
	nPosCFis := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_CF" })           // Cod. Fiscal

	For nX := 1 To Len(aDadosNF)
 
		dbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(ADADOSNF[nX][aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_FILIAL" }) ]+ADADOSNF[nX][aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_PEDIDO" }) ]+ADADOSNF[nX][aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_ITEMPC" }) ]))
		If Val(ADADOSNF[nX][aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_QUANT" }) ]) > (SC7->C7_QUANT - SC7->C7_QUJE)
			cDesc += "O pedido " + SC7->C7_NUM + " da filial " + SC7->C7_FILIAL + " não tem saldo disponível no item " + SC7->C7_ITEM + " |"
			lFlag := .F.
		EndIf


		// 01 - FLAG
		// 02 - F1_FILIAL
		If !EMPTY(aDadosNF[nX,nPosFil])
			If !FWFilialStatus(cEmpAnt,aDadosNF[nX,nPosFil])
				cDesc += "Filial não encadastrada ou bloqueada para uso.|"
				lFlag := .F.
			EndIf
        /*
        cCodEmp := FWCodEmp(cNFFilO)
        If !FwFilExist(cCodEmp,cNFFilO)
            cDesc += "Filial não cadastrada.|"
            lFlag := .F.
        EndIf
        */
		Else
			cDesc += "F1_FILIAL => Campo Filial é obrigatório.|"
			lFlag := .F.
		EndIF

		// 03 - F1_DOC
		If EMPTY(aDadosNF[nX,nPosNota])
			cDesc += "F1_DOC => Campo Numero NF é obrigatório.|"
			lFlag := .F.
		EndIf

		// 04 - F1_SERIE
		If EMPTY(aDadosNF[nX,nPosSeri])
			cDesc += "F1_SERIE => Campo Série NF é obrigatório.|"
			lFlag := .F.
		EndIf

		// 05 - F1_FORNECE              // 06 - F1_LOJA
		If !EMPTY(aDadosNF[nX,nPosForn])
			cNFForn := aDadosNF[nX,5]+'01'
			dbSelectArea("SA2")                 // COMPARTILHADA
			SA2->( dbSetOrder(1) )              // A2_FILIAL+A2_COD+A2_LOJA
			SA2->( dbGoTop() )
			IF SA2->( dbSeek(xFilial("SA2")+cNFForn) )
				If SA2->A2_MSBLQL = '1'         // 1=Sim;2=Nao
					cDesc += "Fornecedor bloqueado para uso.|"
					lFlag := .F.
				EndIf
				aDadosNF[nX,nPosLoja] := SA2->A2_LOJA
				aDadosNF[nX,nPosUF]   := SA2->A2_EST
			ELSE
				cDesc += "Fornecedor não cadastrado.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "F1_FORNECE => Campo Fornecedor é obrigatório.|"
			lFlag := .F.
		EndIf

		// 07 - F1_EMISSAO
		If EMPTY(aDadosNF[nX,nPosEmis])
			cDesc += "F1_EMISSAO => Campo Data de Emissão é obrigatório.|"
			lFlag := .F.
		EndIf

		// 08 - F1_ESPECIE
		If !EMPTY(aDadosNF[nX,nPosEspe])
			If !(upper(aDadosNF[nX,nPosEspe]) == 'NF')
				cDesc += "Espécie inválida.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "F1_ESPECIE => Campo Espécie é obrigatório.|"
			lFlag := .F.
		EndIf

		// 09 - F1_COND
		If !EMPTY(aDadosNF[nX,nPosCond])
			dbSelectArea("SE4")                 // COMPARTILHADA
			SE4->( dbSetOrder(1) )              // E4_FILIAL+E4_CODIGO
			SE4->( dbGoTop() )
			IF SE4->( dbSeek(xFilial("SE4")+aDadosNF[nX,nPosCond]) )
				If SE4->E4_MSBLQL = '1'           // 1=Inativo;2=Ativo
					cDesc += "Condição de Pagamento bloqueado para uso.|"
					lFlag := .F.
				EndIf
			ELSE
				cDesc += "Condição de Pagamento não cadastrado.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "F1_COND => Campo Condição de Pagamento é obrigatório.|"
			lFlag := .F.
		EndIf

		// 10 - F1_EST
		// 11 - F1_DESPESA
		// 12 - F1_DESCONT
		// 13 - F1_SEGURO
		// 14 - F1_FRETE

		// 15 - D1_ITEM
		If !EMPTY(aDadosNF[nX,nPosItem])
			aDadosNF[nX,nPosItem] := StrZero(Val(aDadosNF[nX,nPosItem]), 4)
		Else
			cDesc += "D1_ITEM => Campo Item é obrigatório.|"
			lFlag := .F.
		EndIf

		// 16 - D1_COD
		If !EMPTY(aDadosNF[nX,nPosProd])
			dbSelectArea("P17")                 // COMPARTILHADA
			P17->( dbSetOrder(1) )              // P17_FILIAL+P17_COD+P17_FTRATA
			P17->( dbGoTop() )
			IF P17->( dbSeek(xFilial("P17")+PADR(aDadosNF[nX,nPosProd],Len(P17_COD)," ")+aDadosNF[nX,2]) )
				If P17->P17_BLOQ = 'S'         // S=Sim;N=Não
					cDesc += "Produto bloqueado para uso.|"
					lFlag := .F.
				EndIf
			ELSE
				cDesc += "Produto não cadastrado.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "D1_COD => Campo Produto é obrigatório.|"
			lFlag := .F.
		EndIf

		// 17 - D1_UM
		If EMPTY(aDadosNF[nX,nPosUnid])
			cDesc += "D1_UM => Campo Unidade de Consumo é obrigatório.|"
			lFlag := .F.
		EndIf

		// 18 - D1_LOCAL
		If !EMPTY(aDadosNF[nX,nPosLoca])
			dbSelectArea("NNR")                 // EXCLUSIVA
			NNR->( dbSetOrder(1) )              // NNR_FILIAL+NNR_CODIGO
			NNR->( dbGoTop() )
			IF NNR->( dbSeek(aDadosNF[nX,2]+aDadosNF[nX,nPosLoca]) )
				If NNR->NNR_MSBLQL = '1'        // 1=Sim;2=Não
					cDesc += "Local de Estoque bloqueado para uso.|"
					lFlag := .F.
				EndIf
			ELSE
				cDesc += "Local de Estoque não cadastrado.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "D1_LOCAL => Campo Local de Estoque é obrigatório.|"
			lFlag := .F.
		EndIf

		// 19 - D1_QUANT
		If !EMPTY(aDadosNF[nX,nPosQtde])
			If Val(aDadosNF[nX,nPosQtde]) <= 0
				cDesc += "Qtd de Consumo inválida.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "D1_QUANT => Campo Qtd de Consumo é obrigatório.|"
			lFlag := .F.
		EndIf

		// 20 - D1_VUNIT
		If !EMPTY(aDadosNF[nX,nPosValu])
			If Val(aDadosNF[nX,nPosValu]) <= 0
				cDesc += "Valor Unitário inválida.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "D1_VUNIT => Campo Valor Unitário é obrigatório.|"
			lFlag := .F.
		EndIf

		// 21 - D1_TES
		If !EMPTY(aDadosNF[nX,nPosTes])
			dbSelectArea("SF4")                 // COMPARTILHADA
			SF4->( dbSetOrder(1) )              // F4_FILIAL+F4_CODIGO
			SF4->( dbGoTop() )
			IF SF4->( dbSeek(xFilial("SF4")+aDadosNF[nX,nPosTes]) )
				If SF4->F4_MSBLQL = '1'        // 1=Sim;2=Não
					cDesc += "Tipo de Entrada bloqueado para uso.|"
					lFlag := .F.
				EndIf
				cCodFis := ALLTRIM(SF4->F4_CF)
			ELSE
				cDesc += "Tipo de Entrada não cadastrado.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "D1_TES => Campo Tipo de Entrada é obrigatório.|"
			lFlag := .F.
		EndIf

		// 22 - D1_PEDIDO
		If !EMPTY(aDadosNF[nX,nPosNPed])
			dbSelectArea("SC7")                 // EXCLUSIVA
			SC7->( dbSetOrder(1) )              // C7_FILIAL+C7_NUM+C7_ITEM_C7_SEQUEN
			SC7->( dbGoTop() )
			IF SC7->( dbSeek(aDadosNF[nX,2]+aDadosNF[nX,nPosNPed]+aDadosNF[nX,nPosIPed]) )
				If SC7->C7_ENCER = 'E'        // 1=Sim;2=Não
					cDesc += "Item ja consumido em outra Nota Fiscal.|"
					lFlag := .F.
				EndIf
				If ALLTRIM(SC7->C7_PRODUTO) <> ALLTRIM(aDadosNF[nX,nPosProd])
					cDesc += "Código do Produto diferente do Pedido.|"
					lFlag := .F.
				EndIf
				If SC7->C7_FORNECE <> ALLTRIM(aDadosNF[nX,nPosForn])
					cCnpj01 := substr(GetAdvFVal("SA2", "A2_CGC", xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1),1,8)
					cCnpj02 := substr(GetAdvFVal("SA2", "A2_CGC", xFilial("SA2")+aDadosNF[nX,nPosForn]+aDadosNF[nX,nPosLoja],1),1,8)
					If cCnpj01 <> cCnpj02
						cDesc += "Código do Fornecedor e Raiz do CNPJ diferentes.|"
						lFlag := .F.
					Else
						cEstPC := GetAdvFVal("SA2", "A2_EST", xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1)
						cEstNF := GetAdvFVal("SA2", "A2_EST", xFilial("SA2")+aDadosNF[nX,nPosForn]+aDadosNF[nX,nPosLoja],1)
						If cEstPC == cEstNF
							aDadosNF[nX,nPosCFis] := cCodFis
						Else
							cCodFis := "2"+substr(cCodFis,2)
							aDadosNF[nX,nPosCFis] := cCodFis
						EndIf
					EndIf
				Else
					aDadosNF[nX,nPosCFis] := cCodFis
				EndIf
				If SC7->C7_COND <> ALLTRIM(aDadosNF[nX,nPosCond])
					cDesc += "Condição de Pagamento diferente do Pedido.|"
					lFlag := .F.
				EndIf
				If SC7->C7_DESC1 <> VAL(STRTRAN(aDadosNF[nX][nPosDesc],",","."))
					cDesc += "Desconto diferente do Pedido.|"
					lFlag := .F.
				EndIf
				If SC7->C7_VALFRE <> VAL(STRTRAN(aDadosNF[nX][nPosFret],",","."))
					cDesc += "Frete diferente do Pedido.|"
					lFlag := .F.
				EndIf
				If SC7->C7_QUANT < VAL(STRTRAN(aDadosNF[nX][nPosQtde],",","."))
					cDesc += "Quantidade maior que o Pedido.|"
					lFlag := .F.
				EndIf
			ELSE
				cDesc += "Pedido ou Item do Pedido não encontrado.|"
				lFlag := .F.
			EndIf
		Else
			cDesc += "D1_PEDIDO => Campo Número Pedido é obrigatório.|"
			lFlag := .F.
		EndIf

		// 23 - D1_ITEMPC
		If EMPTY(aDadosNF[nX,nPosIPed])
			cDesc += "D1_ITEMPC => Campo Item Pedido é obrigatório.|"
			lFlag := .F.
		EndIf

		// 24 - DESCRIÇÃO
		If !lFlag
			If !EMPTY(cDesc)        // Remover o ultimo caracter da string
				cDesc := SubStr( cDesc, 1, Len(cDesc)-1 )
			EndIf
			aDadosNF[nX,1] := .F.
			//aDadosNF[nX,24] := ANSIToOEM( cDesc )     // não converter acentos
			aDadosNF[nX,Len(aDadosNF[nX])] := OEMToAnsi( cDesc )
		Else
			aFilSF1 := aClone(fVldNF(aDadosNF[nX][3], aDadosNF[nX][4], aDadosNF[nX][5], aDadosNF[nX][6], aDadosNF[nX][6]))
			IF aFilSF1[1]
				lFlag := .F.
				If Len(aFilSF1) < 3
					cDesc += "Nota Fiscal já cadastrada na Filial - " + aFilSF1[2]
					cDesc := SubStr( cDesc, 1, Len(cDesc) )
				Else
					cDesc += "Nota Fiscal já cadastrada nas Filiais :"
					For nY := 2 To Len(aFilSF1)
						cDesc += " " + aFilSF1[nY] + ","
					Next nY
					cDesc := SubStr( cDesc, 1, Len(cDesc)-1 )
				EndIf
			Else
				lFlag := .T.
				cDesc := ""
			EndIf
			aDadosNF[nX,1] := lFlag
			//aDadosNF[nX,24] := ANSIToOEM( cDesc )
			aDadosNF[nX,Len(aDadosNF[nX])] := OEMToAnsi( cDesc )
		EndIf

		lFlag   := .T.
		cDesc   := ""

	Next nX

	restarea( aArea )

Return .t.


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVldNF

Função responsável pela verificar se a NOta Fiscal ja foi cadastrada no Protheus em alguma filial.

@type function
@version  
@author Sato
@since 19/05/2025
@param cDoc, character, param_description
@param cSerie, character, param_description
@param cFornec, character, param_description
@param cLoja, character, param_description
@param cEmissao, character, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function fVldNF(cDoc as Character, cSerie as Character, cFornec as Character, cLoja as Character, cEmissao as Character)

	Local aArea := GetArea()
	Local cQry := ""
	Local aFiliais := {}
	Local cAliasSF1 := GetNextAlias()

	Default cDoc     := ""
	Default cSerie   := ""
	Default cFornec  := ""
	Default cLoja    := ""
	Default cEmissao := ""

	cQry := "SELECT F1_FILIAL FROM " + RETSQLNAME("SF1")
	cQry += "   WHERE F1_DOC = '" + cDoc + "' "
	cQry += "     AND F1_SERIE = '" + cSerie + "' "
	cQry += "     AND F1_FORNECE = '" + cFornec + "' "
	cQry += "     AND F1_LOJA = '" + cLoja + "' "
	cQry += "     AND F1_EMISSAO = '" + DtoS(Ctod(cEmissao)) + "' "
	cQry += "     AND D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSF1,.F.,.T.)

	If !( (cAliasSF1)->( Eof() ) )
		aAdd(aFiliais, .T.)
		(cAliasSF1)->( dbGoTop() )
		Do While (cAliasSF1)->( !eof() )
			aAdd(aFiliais, (cAliasSF1)->F1_FILIAL)
			(cAliasSF1)->( dbskip() )
		EndDo
	Else
		aAdd(aFiliais, .F.)
	EndIf

	RestArea(aArea)

Return aFiliais



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step4Proc

Rotina responsável por realizar o cadastro das Notas Fiscais automaticamente.

@type function
@version  
@author Sato
@since 12/05/2024
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosNF, array, param_description
@param aCampos, array, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step4Proc(oSay As Object, cArquivo As Character, aDadosNF As Array, aCampos As Array, aLogs As Array)

	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local nOpc := 3
	Local nX := 0
	Local nY := 0

	Local cCmpSF1 := ""
	Local cCmpSD1 := ""
	Local cChave  := ""
	Local cRet    := ""

	Local nPosFili := 0
	Local nPosNota := 0
	Local nPosSeri := 0
	Local nPosForn := 0
	Local nPosLoja := 0

	Local nPosQtde := 0
	Local nPosValu := 0

	Local cNota   := ''
	Local cSerie  := ''
	Local cFornec := ''
	Local cLoja   := ''

	Local aLogAuto := {}
	Local cLogTxt  := ""
	Local cArqLog  := ""
	Local nAux     := 0
	Local cDrive   := ""
	Local cDir     := ""
	Local cNome    := ""
	Local cExt     := ""

	Local nItem    := 0
	Local nTotal   := 0

	PRIVATE lMsErroAuto     := .F.
	PRIVATE lAutoErrNoFile  := .T.
	PRIVATE lMsHelpAuto     := .T.

	Public xfDtExce := "1"

	SplitPath( cArquivo, cDrive, cDir, cNome, cExt )

//cArqLog  := "C:\TESTES\UPLOAD_PC\ARQLOG.txt" 
	cArqLog  := cDrive+cDir+cNome+"_LOG_COMPLETO.txt"

	AADD(aLogs, "FILIAL;NOTA;SERIE;FORNECEDOR;LOJA;STATUS" )

	nPosFili := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_FILIAL" })       // Filial
	nPosNota := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_DOC" })          // Numero NF
	nPosSeri := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_SERIE" })        // Serie NF
	nPosForn := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_FORNECE" })      // Fornecedor
	nPosLoja := aScan(aCampos, {|x| AllTrim(Upper(x)) == "F1_LOJA" })         // Loja

	nPosQtde := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_QUANT" })        // Qtd Consumo
	nPosValu := aScan(aCampos, {|x| AllTrim(Upper(x)) == "D1_VUNIT" })        // Vlr. Unitario

	cFilAnt := PadR(aDadosNF[1][nPosFili], TamSx3("F1_FILIAL")[01])

	cNota   := aDadosNF[1][nPosNota]
	cSerie  := aDadosNF[1][nPosSeri]
	cFornec := aDadosNF[1][nPosForn]
	cLoja   := aDadosNF[1][nPosLoja]

	cChave  := cFilAnt+cNota+cSerie+cFornec+cLoja

	cCmpSF1 := "F1_FILIAL|F1_DOC|F1_SERIE|F1_FORNECE|F1_LOJA|F1_EMISSAO|F1_ESPECIE|F1_COND|F1_EST|F1_DESPESA|F1_DESCONT|F1_SEGURO|F1_FRETE"
	cCmpSD1 := "D1_ITEM|D1_COD|D1_UM|D1_LOCAL|D1_QUANT|D1_VUNIT|D1_TES|D1_PEDIDO|D1_ITEMPC"

//cCodFis := MaTesInt(1, '051', cFornec, cLoja, If(cTipo$"DB","C","F"),M->D1_COD,"D1_TES",,cUfOrig) 

	For nX := 1 To len(aDadosNF)

		If cNota == aDadosNF[nX][nPosNota]

			If nX > nItem
				nItem := nX
				nTotal := VAL(STRTRAN(aDadosNF[nX][nPosQtde],",",".")) * VAL(STRTRAN(aDadosNF[nX][nPosValu],",","."))
			EndIf

			For nY := 1 To Len(aDadosNF[nX])
				If aCampos[nY] <> 'STATUS' .and. aCampos[nY] <> 'ERRO'
					If aCampos[nY] $ cCmpSF1
						If Len(aCab) = 0
							aadd(aCab, {"F1_TIPO"    , "N"       , NIL})
							aadd(aCab, {"F1_FORMUL"  , "N"       , NIL})
							aadd(aCab, {"F1_MOEDA"   , 1         , Nil})
							aadd(aCab, {"F1_TXMOEDA" , 1         , Nil})
							aadd(aCab, {"F1_STATUS"  , "A"       , Nil})
							AADD(aCab, {"F1_NUMTRIB" , 'N'       , Nil})
							AADD(aCab, {"F1_RECISS"  , "2"       , Nil})
							AAdd(aCab, {"F1_NFORIG"  , cNota     , NIL})
							AAdd(aCab, {"F1_SERORIG" , cSerie    , NIL})
							aadd(aCab, {"F1_DTDIGIT" , DDATABASE , NIL})
							AADD(aCab, {"F1_DTLANC"  , DDATABASE , Nil})
							AADD(aCab, {"F1_RECBMTO" , DDATABASE , Nil})
							AADD(aCab, {"F1_VALMERC" , nTotal    , Nil})
							AADD(aCab, {"F1_VALBRUT" , nTotal    , Nil})
						Else
							Do Case
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "C"
								aAdd(aCab, {aCampos[nY], aDadosNF[nX][nY], Nil})
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "N"
								aAdd(aCab, {aCampos[nY], VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "D"
								aAdd(aCab, {aCampos[nY], CtoD(aDadosNF[nX][nY]), Nil})
							EndCase
						EndIf
					else
						If Len(aItem) = 0

							aAdd(aItem, {'D1_DOC'    , cNota         , Nil})
							aadd(aItem, {"D1_SERIE"  , cSerie        , NIL})
							aadd(aItem, {"D1_RATEIO" , "2"           , NIL})
							//AAdd(aItem, {"D1_SEGURO" , 0             , Nil})
							////AAdd(aItem, {"D1_VALDESC", 0             , Nil})
							//AAdd(aItem, {"D1_NFORI"  , cNota         , Nil})
							//AAdd(aItem, {"D1_SERIORI", cSerie        , NIL})
							//AAdd(aItem, {"D1_ITEMORI", "0001"        , NIL})
							AAdd(aItem, {"D1_CUSTO"  , nTotal        , Nil})
							////AAdd(aItem, {"D1_QTDPEDI", 1             , Nil})
							//AAdd(aItem, {"D1_XDTVALI", DATE() + 90   , Nil})
							//AAdd(aItem, {"D1_XLOTECT", "D1_XLOTECT"  , Nil})   /// verifica a existencia de gatilho
							////AAdd(aItem, {"D1_IPI"    , 0             , Nil})
							////AAdd(aItem, {"D1_BASEIPI", 0             , Nil})
							////AAdd(aItem, {"D1_VALIPI" , 0             , Nil})
							////AAdd(aItem, {"D1_PICM"   , 0             , Nil})
							////AAdd(aItem, {"D1_BASEICM", 0             , Nil})
							////AAdd(aItem, {"D1_VALICM" , 0             , Nil})
							////AAdd(aItem, {"D1_ESTCRED", 0             , Nil})
							////AAdd(aItem, {"D1_ICMSCOM", 0             , Nil})
							////AAdd(aItem, {"D1_VALACRS", 0             , Nil})
							////AAdd(aItem, {"D1_MARGEM" , 0             , Nil})
							////AAdd(aItem, {"D1_ALIQSOL", 0             , Nil})
							////AAdd(aItem, {"D1_BRICMS" , 0             , Nil})
							////AAdd(aItem, {"D1_ICMSRET", 0             , Nil})
							////AAdd(aItem, {"D1_BASEPIS", 0             , Nil})
							////AAdd(aItem, {"D1_ALQPIS" , 0             , Nil})
							////AAdd(aItem, {"D1_VALPIS" , 0             , Nil})
							////AAdd(aItem, {"D1_BASECOF", 0             , Nil})
							////AAdd(aItem, {"D1_ALQCOF" , 0             , Nil})
							////AAdd(aItem, {"D1_VALCOF" , 0             , Nil})
							////AAdd(aItem, {"D1_BASECSL", 0             , Nil})
							////AAdd(aItem, {"D1_ALQCSL" , 0             , Nil})
							////AAdd(aItem, {"D1_VALCSL" , 0             , Nil})
							////AAdd(aItem, {"D1_BASIMP6", 0             , Nil})
							////AAdd(aItem, {"D1_ALQIMP6", 0             , Nil})
							////AAdd(aItem, {"D1_VALIMP6", 0             , Nil})
							////AAdd(aItem, {"D1_BASIMP5", 0             , Nil})
							////AAdd(aItem, {"D1_ALQIMP5", 0             , Nil})
							////AAdd(aItem, {"D1_VALIMP5", 0             , Nil})
							////AAdd(aItem, {"D1_BASEIRR", 0             , Nil})
							////AAdd(aItem, {"D1_ALIQIRR", 0             , Nil})
							////AAdd(aItem, {"D1_VALIRR" , 0             , Nil})
							////AAdd(aItem, {"D1_ABATMAT", 0             , Nil})
							//AAdd(aItem,{"D1_BASEISS", 0             , Nil})
							//AAdd(aItem,{"D1_ALIQISS", 0             , Nil})
							//AAdd(aItem,{"D1_VALISS" , 0             , Nil})
							AAdd(aItem, {"D1_BASEISS", nTotal        , Nil})
							////AAdd(aItem, {"D1_ALIQISS", 0             , Nil})
							////AAdd(aItem, {"D1_VALISS" , 0             , Nil})
							////AAdd(aItem, {"D1_BASEINS", 0             , Nil})
							////AAdd(aItem, {"D1_ALIQINS", 0             , Nil})
							////AAdd(aItem, {"D1_VALINS" , 0             , Nil})
							////AAdd(aItem, {"D1_ALIQCF3", 0             , Nil})
							////AAdd(aItem, {"D1_BASECF3", 0             , Nil})
							////AAdd(aItem, {"D1_VALCF3" , 0             , Nil})
							////AAdd(aItem, {"D1_CRDZFM" , 0             , Nil})
							aAdd(aItem, {'D1_FORNECE', cFornec       , Nil})
							aAdd(aItem, {'D1_LOJA'   , cLoja         , Nil})


                        /*
                        aadd(aItem, {"D1_FILIAL", "04470001" , NIL})
                        aadd(aItem, {"D1_ITEM", "0001" , NIL})
                        aadd(aItem, {"D1_COD", "100013" , NIL}) 
                        aadd(aItem, {"D1_UM", "UN" , NIL})
                        aadd(aItem, {"D1_SEGUM", "UN" , NIL})
                        aadd(aItem, {"D1_QUANT", 10 , NIL})
                        aadd(aItem, {"D1_VUNIT", 700 , NIL})
                        aadd(aItem, {"D1_TOTAL", 7000 , NIL})
                        aadd(aItem, {"D1_TES", "036" , NIL})
                        aadd(aItem, {"D1_CF", "2556 " , NIL})
                        aadd(aItem, {"D1_CONTA", "410303001006" , NIL})
                        aadd(aItem, {"D1_CC", "01030601001" , NIL})
                        aadd(aItem, {"D1_PEDIDO", "023810" , NIL})
                        aadd(aItem, {"D1_ITEMPC", "0001" , NIL})
                        aadd(aItem, {"D1_FORNECE", "012465" , NIL})
                        aadd(aItem, {"D1_LOCAL", "PADRAO" , NIL})
                        aadd(aItem, {"D1_DOC", "555555555" , NIL})
                        aadd(aItem, {"D1_EMISSAO", "20250605" , NIL})
                        aadd(aItem, {"D1_DTDIGIT", "20250605" , NIL})
                        aadd(aItem, {"D1_GRUPO", "0045" , NIL})
                        aadd(aItem, {"D1_TIPO", "N" , NIL})
                        aadd(aItem, {"D1_SERIE", "555" , NIL})
                        aadd(aItem, {"D1_TP", "MC" , NIL})
                        aadd(aItem, {"D1_QTSEGUM", 10 , NIL})
                        aadd(aItem, {"D1_BASEIPI", 7000 , NIL})
                        aadd(aItem, {"D1_CUSTO", 7000 , NIL})
                        aadd(aItem, {"D1_QTDPEDI", 10 , NIL})
                        aadd(aItem, {"D1_RATEIO", "2" , NIL})
                        aadd(aItem, {"D1_XRETINS", "1162" , NIL})
                        aadd(aItem, {"D1_STSERV", "1" , NIL})
                        aadd(aItem, {"D1_RGESPST", "2" , NIL})
                        aadd(aItem, {"D1_GARANTI", "N" , NIL})
                        aadd(aItem, {"D1_ALQCSL", 1 , NIL})
                        aadd(aItem, {"D1_ALQPIS", 0.65 , NIL})
                        aadd(aItem, {"D1_SDOC", "555" , NIL})
                        aadd(aItem, {"D1_XLOTECT", "F         " , NIL})
                        aadd(aItem, {"D1_XCONSIG", "2" , NIL})
                        aadd(aItem, {"D1_SLDEXP", 10 , NIL})
                        aadd(aItem, {"D1_LOJA", "01" , NIL})
                        */
						Else
							Do Case
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "C"
								aAdd(aItem, {aCampos[nY], aDadosNF[nX][nY], Nil})

								If aCampos[nY] == 'D1_UM'
									aAdd(aItem, {'D1_SEGUM ', aDadosNF[nX][nY], Nil})
								EndIf

							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "N"
								aAdd(aItem, {aCampos[nY], VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})

								If aCampos[nY] == 'D1_QUANT'
									aAdd(aItem, {'D1_QTSEGUM', VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})
									AAdd(aItem, {"D1_QTDPEDI", VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})
								EndIf

								If aCampos[nY] == 'D1_VUNIT'
									aAdd(aItem, {'D1_TOTAL', nTotal , Nil})
								EndIf
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "D"
								aAdd(aItem, {aCampos[nY], CtoD(aDadosNF[nX][nY]), Nil})
							EndCase
						EndIf
					EndIf
				EndIf
			next nY

			aadd(aItens,aItem)

			aItem := {}
		Else
			//3-Inclusão / 4-Classificação / 5-Exclusão
			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)
			//MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,nOpc,.F.,aRatCC,aAdtPC,aRatPrj)

			If lMsErroAuto
				aLogAuto := GetAutoGRLog()

				For nAux := 1 To Len(aLogAuto)
					cLogTxt += aLogAuto[nAux] + CHR(13) + CHR(10)
					If nAux <= 1
						cRet := StrTran(aLogAuto[nAux], CHR(13) + CHR(10), " - ")
					EndIf
				Next nAux

				cLogTxt += CHR(13) + CHR(10) + CHR(13) + CHR(10)

				MemoWrite(cArqLog, cLogTxt)

				lMsErroAuto := .F.
			Else
				cRet := "Incluido com sucesso"
			EndIf

			AADD(aLogs, cFilAnt+";"+cNota+";"+cSerie+";"+cFornec+";"+cLoja+";"+cRet )

			aCab    := {}
			aItem   := {}
			aItens  := {}
			cRet    := ""
			cNota   := ""
			cSerie  := ""
			cFornec := ""
			cLoja   := ""

			cFilAnt := PadR(aDadosNF[nX][nPosFili], TamSx3("C7_FILIAL")[01])

			cNota   := aDadosNF[nX][nPosNota]
			cSerie  := aDadosNF[nX][nPosSeri]
			cFornec := aDadosNF[nX][nPosForn]
			cLoja   := aDadosNF[nX][nPosLoja]

			If nX > nItem
				nItem := nX
				nTotal := VAL(STRTRAN(aDadosNF[nX][nPosQtde],",",".")) * VAL(STRTRAN(aDadosNF[nX][nPosValu],",","."))
			EndIf

			For nY := 1 To Len(aDadosNF[nX])
				If aCampos[nY] <> 'STATUS' .and. aCampos[nY] <> 'ERRO'
					If aCampos[nY] $ cCmpSF1
						If Len(aCab) = 0
							aadd(aCab, {"F1_TIPO"    , "N"       , NIL})
							aadd(aCab, {"F1_FORMUL"  , "N"       , NIL})
							aadd(aCab, {"F1_MOEDA"   , 1         , Nil})
							aadd(aCab, {"F1_TXMOEDA" , 1         , Nil})
							aadd(aCab, {"F1_STATUS"  , "A"       , Nil})
							AADD(aCab, {"F1_NUMTRIB" , 'N'       , Nil})
							AADD(aCab, {"F1_RECISS"  , "2"       , Nil})
							AAdd(aCab, {"F1_NFORIG"  , cNota     , NIL})
							AAdd(aCab, {"F1_SERORIG" , cSerie    , NIL})
							aadd(aCab, {"F1_DTDIGIT" , DDATABASE , NIL})
							AADD(aCab, {"F1_DTLANC"  , DDATABASE , Nil})
							AADD(aCab, {"F1_RECBMTO" , DDATABASE , Nil})
							AADD(aCab, {"F1_VALMERC" , nTotal    , Nil})
							AADD(aCab, {"F1_VALBRUT" , nTotal    , Nil})
						Else
							Do Case
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "C"
								aAdd(aCab, {aCampos[nY], aDadosNF[nX][nY], Nil})
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "N"
								aAdd(aCab, {aCampos[nY], VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "D"
								aAdd(aCab, {aCampos[nY], CtoD(aDadosNF[nX][nY]), Nil})
							EndCase
						EndIf
					else
						If Len(aItem) = 0
							aAdd(aItem, {'D1_DOC'    , cNota         , Nil})
							aadd(aItem, {"D1_SERIE"  , cSerie        , NIL})
							aadd(aItem, {"D1_RATEIO" , "2"           , NIL})
							//AAdd(aItem, {"D1_SEGURO" , 0             , Nil})
							AAdd(aItem, {"D1_VALDESC", 0             , Nil})
							//AAdd(aItem, {"D1_NFORI"  , cNota         , Nil})
							//AAdd(aItem, {"D1_SERIORI", cSerie        , NIL})
							//AAdd(aItem, {"D1_ITEMORI", "0001"        , NIL})
							AAdd(aItem, {"D1_CUSTO"  , nTotal        , Nil})
							AAdd(aItem, {"D1_QTDPEDI", 1             , Nil})
							//AAdd(aItem, {"D1_XDTVALI", DATE() + 90   , Nil})
							//AAdd(aItem, {"D1_XLOTECT", "D1_XLOTECT"  , Nil})   /// verifica a existencia de gatilho
							AAdd(aItem, {"D1_IPI"    , 0             , Nil})
							AAdd(aItem, {"D1_BASEIPI", 0             , Nil})
							AAdd(aItem, {"D1_VALIPI" , 0             , Nil})
							AAdd(aItem, {"D1_PICM"   , 0             , Nil})
							AAdd(aItem, {"D1_BASEICM", 0             , Nil})
							AAdd(aItem, {"D1_VALICM" , 0             , Nil})
							AAdd(aItem, {"D1_ESTCRED", 0             , Nil})
							AAdd(aItem, {"D1_ICMSCOM", 0             , Nil})
							AAdd(aItem, {"D1_VALACRS", 0             , Nil})
							AAdd(aItem, {"D1_MARGEM" , 0             , Nil})
							AAdd(aItem, {"D1_ALIQSOL", 0             , Nil})
							AAdd(aItem, {"D1_BRICMS" , 0             , Nil})
							AAdd(aItem, {"D1_ICMSRET", 0             , Nil})
							AAdd(aItem, {"D1_BASEPIS", 0             , Nil})
							AAdd(aItem, {"D1_ALQPIS" , 0             , Nil})
							AAdd(aItem, {"D1_VALPIS" , 0             , Nil})
							AAdd(aItem, {"D1_BASECOF", 0             , Nil})
							AAdd(aItem, {"D1_ALQCOF" , 0             , Nil})
							AAdd(aItem, {"D1_VALCOF" , 0             , Nil})
							AAdd(aItem, {"D1_BASECSL", 0             , Nil})
							AAdd(aItem, {"D1_ALQCSL" , 0             , Nil})
							AAdd(aItem, {"D1_VALCSL" , 0             , Nil})
							AAdd(aItem, {"D1_BASIMP6", 0             , Nil})
							AAdd(aItem, {"D1_ALQIMP6", 0             , Nil})
							AAdd(aItem, {"D1_VALIMP6", 0             , Nil})
							AAdd(aItem, {"D1_BASIMP5", 0             , Nil})
							AAdd(aItem, {"D1_ALQIMP5", 0             , Nil})
							AAdd(aItem, {"D1_VALIMP5", 0             , Nil})
							AAdd(aItem, {"D1_BASEIRR", 0             , Nil})
							AAdd(aItem, {"D1_ALIQIRR", 0             , Nil})
							AAdd(aItem, {"D1_VALIRR" , 0             , Nil})
							AAdd(aItem, {"D1_ABATMAT", 0             , Nil})
							//AAdd(aItem,{"D1_BASEISS", 0             , Nil})
							//AAdd(aItem,{"D1_ALIQISS", 0             , Nil})
							//AAdd(aItem,{"D1_VALISS" , 0             , Nil})
							AAdd(aItem, {"D1_BASEISS", nTotal        , Nil})
							AAdd(aItem, {"D1_ALIQISS", 0             , Nil})
							AAdd(aItem, {"D1_VALISS" , 0             , Nil})
							AAdd(aItem, {"D1_BASEINS", 0             , Nil})
							AAdd(aItem, {"D1_ALIQINS", 0             , Nil})
							AAdd(aItem, {"D1_VALINS" , 0             , Nil})
							AAdd(aItem, {"D1_ALIQCF3", 0             , Nil})
							AAdd(aItem, {"D1_BASECF3", 0             , Nil})
							AAdd(aItem, {"D1_VALCF3" , 0             , Nil})
							AAdd(aItem, {"D1_CRDZFM" , 0             , Nil})
							aAdd(aItem, {'D1_FORNECE', cFornec       , Nil})
							aAdd(aItem, {'D1_LOJA'   , cLoja         , Nil})
						Else
							Do Case
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "C"
								aAdd(aItem, {aCampos[nY], aDadosNF[nX][nY], Nil})

								If aCampos[nY] == 'D1_UM'
									aAdd(aItem, {'D1_SEGUM ', aDadosNF[nX][nY], Nil})
								EndIf

							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "N"
								aAdd(aItem, {aCampos[nY], VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})

								If aCampos[nY] == 'D1_QUANT'
									aAdd(aItem, {'D1_QTSEGUM', VAL(STRTRAN(aDadosNF[nX][nY],",",".")), Nil})
								EndIf

								If aCampos[nY] == 'D1_VUNIT'
									aAdd(aItem, {'D1_TOTAL', nTotal , Nil})
								EndIf
							Case GetSx3Cache(aCampos[nY],"X3_TIPO") == "D"
								aAdd(aItem, {aCampos[nY], CtoD(aDadosNF[nX][nY]), Nil})
							EndCase
						EndIf
					EndIf
				EndIf
			next nY

			aadd(aItens,aItem)

			aItem := {}

		EndIf

	Next nX

	If Len(aCab) > 0 .and. Len(aItens) > 0


		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)


		If lMsErroAuto

			aLogAuto := GetAutoGRLog()

			For nAux := 1 To Len(aLogAuto)
				cLogTxt += aLogAuto[nAux] + CHR(13) + CHR(10)
				If nAux <= 1
					cRet := StrTran(aLogAuto[nAux], CHR(13) + CHR(10), " - ")
				EndIf
			Next nAux

			cLogTxt += CHR(13) + CHR(10) + CHR(13) + CHR(10)

			MemoWrite(cArqLog, cLogTxt)

			lMsErroAuto := .F.

		Else
			cRet := "Incluido com sucesso"
		EndIf

		AADD(aLogs, cFilAnt+";"+cNota+";"+cSerie+";"+cFornec+";"+cLoja+";"+cRet )

	EndIf

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

/*/If!ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
Return
EndIf/*/

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
