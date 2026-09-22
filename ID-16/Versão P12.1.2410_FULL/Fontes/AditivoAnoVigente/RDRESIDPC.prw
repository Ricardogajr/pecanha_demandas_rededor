#Include "Protheus.ch"
#Include "rwmake.ch"
#include "totvs.ch"

#DEFINE CRLF Chr(13)+Chr(10)

//------------------------------------------------------------------------------
/*/{Protheus.doc} RDRESIDPC

Função responsável pela realização da Eliminação dos Resíduos dos Pedidos de Compras.

@type function
@version  
@author Sato 
@since 26/06/2025
@return array, return_description
/*/
//------------------------------------------------------------------------------
User Function RDRESIDPC() As Array

Local oWizard       As Object
Local oStep1        As Object
Local oStep2        As Object
Local oStep3        As Object
Local oStep4        As Object
Local oStep5        As Object

Local lCancel		As Logical
Local cArquivo      As Character
Local cObsRes       As Character
Local lIntegra      As Logical
Local aListaPed     As Array
Local aDadosSC7     As Array
Local aCampos       As Array
Local aLogs         As Array
Local aArea         As Array

Local cArqConf      As Character
Local aConfer       As Array

Local cFilBkp       As Character

lCancel		:= .F.
cArquivo    := ""
cObsRes     := ""
lIntegra    := .T.
aListaPed   := {}
aDadosSC7   := {}
aCampos     := {}
aLogs       := {}

cArqConf    := ""
aConfer     := {}

aArea       := FwGetArea()

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
oStep2 := oWizard:AddStep( 'Step2', { | oPanel | Step2( oPanel, @cArquivo, @cObsRes ) } )
oStep2:SetStepDescription( "Seleção de Arquivo" )      	        // Define o título do "Passo" | "Seleção de Arquivo"
oStep2:SetNextTitle( "Próximo" )						        // Define o título do botão de avanço | "Próximo"
oStep2:SetNextAction( { || ValStep2( cArquivo, cObsRes ) } )	// Define o bloco ao clicar no botão Próximo
oStep2:SetCancelAction( { || lCancel := .T. } )			        // Define o bloco ao clicar no botão Cancelar

/*
"Conferência dos Dados"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
*/
oStep3 := oWizard:AddStep( 'Step3', { | oPanel | Step3( oPanel, cArquivo, cObsRes, @aListaPed, @aDadosSC7, @aCampos ) } )
oStep3:SetStepDescription( "Conferência dos Dados" )            // Define o título do "Passo" | "Conferência dos Dados"
oStep3:SetNextTitle( "Próximo" )								// Define o título do botão de avanço | "Próximo"
oStep3:SetNextAction( { || ValStep3( aListaPed, aDadosSC7, aCampos ) } )   // Define o bloco ao clicar no botão Próximo
oStep3:SetCancelAction( { || lCancel := .T. } )					// Define o bloco ao clicar no botão Cancelar
oStep3:SetPrevAction( { || .F. } )                              // Define o bloco ao clicar no botão Voltar

/*
"Processamento das correções"
*/
oStep4 := oWizard:AddStep( 'Step4', { | oPanel | Step4( oPanel, cArquivo, cObsRes, aListaPed, aDadosSC7, aCampos, @aLogs, @cArqConf, @aConfer ) } )
oStep4:SetStepDescription( "Processamento dos Pedidos" )        // Define o título do "Passo" | "Processamento das correções"
oStep4:SetNextTitle( "Próximo" )                                // Define o título do botão de avanço | "Próximo"
oStep4:SetNextAction( { || ValStep4( aLogs ) } )                // Define o bloco ao clicar no botão Próximo
oStep4:SetCancelAction( { || lCancel := .T. } )                 // Define o bloco ao clicar no botão Cancelar
oStep4:SetPrevAction( { || .F. } )                              // Define o bloco ao clicar no botão Voltar

/*
"Finalização"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
*/
oStep5 := oWizard:AddStep( 'Step5', { | oPanel | Step5( oPanel, cArquivo, aLogs, cArqConf, aConfer) } )
oStep5:SetStepDescription( "Finalização" )                      // Define o título do "Passo" | "Finalização"
oStep5:SetNextAction( { || .T. } )	                            // Define o bloco ao clicar no botão Próximo
oStep5:SetCancelAction( { || lCancel := .F. } )					// Define o bloco ao clicar no botão Cancelar
oStep5:SetPrevAction( { || .F. } )                              // Define o bloco ao clicar no botão Voltar

oWizard:Activate()

oWizard:Destroy()

cFilAnt := cFilBkp

FwRestArea(aArea)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step1

Função responsável pela exibição da Tela de apresentação

@type function
@version  
@author Sato
@since 26/06/2025
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

oSayTop	:= TSay():New( 010,  10, { || "Eliminação de Residuo de Pedidos de Compra" }, oPanel,, oFont,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 030,  10, { || "Este programa tem como obejtivo realizar manualmente a Eliminação de Resíduo dos Pedidos de Compras." }, oPanel,,,,,, .T., CLR_BLUE, )

oSay1	:= TSay():New( 040,  10, { || "Para a realização da Eliminação de Resíduo dos Pedidos de Compras, é necessário a criação de um template no formato CSV com os seguintes campos:" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 050,  15, { || "- C7_FILIAL - Filial do Sistema;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 060,  15, { || "- C7_NUM - Número do Pedido;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 070,  15, { || "- C7_LOJA - Loja do fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 080,  15, { || "- C7_COND - Código da Condição de Pagto;" }, oPanel,,,,,, .T., CLR_BLUE, )
//oSay1	:= TSay():New( 090,  15, { || "- C7_FILENT - Filial para Entrega;" }, oPanel,,,,,, .T., CLR_BLUE, )
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

Função responsável pela Seleção do Arquivo de Upload e pela Justificativa de Eliminação de Resíduo dos Pedidos de Comrpas.

@type function
@version  
@author Sato
@since 02/07/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param cObsRes, character, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------

Static Function Step2( oPanel As Object, cArquivo As Character, cObsRes As Character)

Local aArea2    As Array
Local oButton   As Object
Local oGet1     As Object
Local oSay2     As Object
Local oGet2     As Object
Local nAltGet   As Numeric

Default cArquivo := ''

aArea2 := FWGetArea()

cObsRes := space(250)
nAltGet := 13

oButton := TButton():New( 50, 10 , "Selecione arquivo...",oPanel,{ || cArquivo := cGetFile("Arquivos .CSV|*.CSV","Selecione o arquivo a ser importado",0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE) }, 60, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )
oGet1   := TGet():New( 50, 75, { |u| If( PCount() > 0, cArquivo := u, cArquivo ) }, oPanel, 280, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cArquivo" )

oSay2 := TSay():New( 80, 10, {||'Observação : '},oPanel,,,,,,.T.,,,50,20)
oGet2 := TGet():New(  77, 55, { |u| If( PCount() > 0, cObsRes := u, cObsRes ) }, oPanel, 320, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cObsRes",,,,.F. )

FWRestArea(aArea2)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValStep2

Função responsável pela verificação se foi selecionado um arquivo (CSV) e se foi adicionada uma Observação.

@type function
@version  
@author Sato
@since 02/07/2025
@param cArquivo, character, param_description
@param cObsRes, character, param_description
@return logical, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValStep2(cArquivo As Character, cObsRes As Character) As Logical

Local lRet As Logical

lRet := .T.

If Empty(cArquivo)
    lRet := .F.
    Help(' ',1,'Preenchimento' ,,'Selecione um Arquivo para poder prosseguir.',2,0,)
EndIf

If Empty(cObsRes)
    lRet := .F.
    Help(' ',1,'Preenchimento' ,,'Informe o motivo da Eliminação de resíduo para poder prosseguir.',2,0,)
EndIf

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3

Função que monta a tela de conferência dos Pedidos de Compras a serem Eliminados Resíduo.

@type function
@version  
@author Sato
@since 02/07/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param cObsRes, character, param_description
@param aListaPed, array, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3( oPanel As Object, cArquivo As Character, cObsRes As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array )

local oOK    As object
local oNO    As object
local oBrw   As object

Default cArquivo    := ""
Default cObsRes     := ""
Default aListaPed   := {}
Default aDadosSC7   := {}
Default aCampos     := {}

oOK := LoadBitmap(GetResources(), "br_verde")
oNO := LoadBitmap(GetResources(), "br_vermelho")

FWMsgRun(oPanel, {|oSay| Step3Proc(oSay, cArquivo, @aListaPed, @aDadosSC7, @aCampos) }, "Processando", "Gerando dados para conferência...")

oBrw  := TWBrowse():New( 000 , 000 , (oPanel:nClientWidth/2) , (oPanel:nClientHeight/2),,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oBrw:SetArray(aDadosSC7)

////////////// TCColumn():New( < cTitulo >           , < bData >                              , [ cPicture ], [ uParam4 ], [ uParam5 ], [ cAlinhamento ], [ nLargura ], [ lBitmap ], [ lEdit ], [ uParam10 ], [ bValid ], [ uParam12 ], [ uParam13 ], [ uParam14 ] )

oBrw:AddColumn(TcColumn():New( ""                    , {||If(aDadosSC7[oBrw:nAt][01],oOK,oNO)},,,, "CENTER", 20, .T., .F.,,,, .F., ) )                   // Status
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[02]) , {|| aDadosSC7[oBrw:nAt][02] },,,,'LEFT' ,GetSx3Cache(aCampos[02],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_FILIAL
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[03]) , {|| aDadosSC7[oBrw:nAt][03] },,,,'LEFT' ,GetSx3Cache(aCampos[03],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_NUM
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[04]) , {|| aDadosSC7[oBrw:nAt][04] },,,,'LEFT' ,GetSx3Cache(aCampos[04],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_EMISSAO
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[05]) , {|| aDadosSC7[oBrw:nAt][05] },,,,'LEFT' ,GetSx3Cache(aCampos[05],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_ITEM
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[06]) , {|| aDadosSC7[oBrw:nAt][06] },,,,'LEFT' ,GetSx3Cache(aCampos[06],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_PRODUTO
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[07]) , {|| aDadosSC7[oBrw:nAt][07] },,,,'LEFT' ,GetSx3Cache(aCampos[07],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_CONAPRO
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[08]) , {|| aDadosSC7[oBrw:nAt][08] },,,,'LEFT' ,GetSx3Cache(aCampos[08],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_ENCER
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[09]) , {|| aDadosSC7[oBrw:nAt][09] },,,,'LEFT' ,GetSx3Cache(aCampos[09],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_RESIDUO
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[10]) , {|| aDadosSC7[oBrw:nAt][10] },,,,'LEFT' ,GetSx3Cache(aCampos[10],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_QUANT
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[11]) , {|| aDadosSC7[oBrw:nAt][11] },,,,'LEFT' ,GetSx3Cache(aCampos[11],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_QUJE
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[12]) , {|| aDadosSC7[oBrw:nAt][12] },,,,'LEFT' ,GetSx3Cache(aCampos[12],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_QTDACLA
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[13]) , {|| aDadosSC7[oBrw:nAt][13] },,,,'LEFT' ,GetSx3Cache(aCampos[13],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XORIG
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[14]) , {|| aDadosSC7[oBrw:nAt][14] },,,,'LEFT' ,GetSx3Cache(aCampos[14],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XNUM
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[15]) , {|| aDadosSC7[oBrw:nAt][15] },,,,'LEFT' ,GetSx3Cache(aCampos[15],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XFRONT
oBrw:AddColumn(TCColumn():New( "Descrição do Erro"   , {|| aDadosSC7[oBrw:nAt][16] },,,,'LEFT' ,150,.F.,.F.,,,,.F.,))                                    // DESCRICAO DO ERRO

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3Proc

Rotina responsável por realizar a leitura do arquivo CSV

@type function
@version  
@author Sato
@since 10/07/2025
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aListaPed, array, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3Proc(oSay As Object, cArquivo As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array )

Local cBuffer   as Character
Local aLinha    as Array
Local nContLin  as Numeric

Default aListaPed := {}
Default aDadosSC7 := {}
Default aCampos   := {}

cBuffer     := ""
aLinha      := {}
nContLin    := 0

aCampos := {"STATUS", "C7_FILIAL", "C7_NUM", "C7_EMISSAO", "C7_ITEM", "C7_PRODUTO", "C7_CONAPRO", "C7_ENCER", "C7_RESIDUO", "C7_QUANT", "C7_QUJE", "C7_QTDACLA", "C7_XORIG", "C7_XNUM", "C7_XFRONT", "ERRO"}

FT_FUSE(cArquivo)
FT_FGOTOP()

While !FT_FEOF()

    // Capturar dados
    cBuffer := FT_FREADLN() //LENDO LINHA
    nContLin++
    aLinha := Separa( Upper(";"+cBuffer)+";", ";")

    If nContLin > 2
        AADD( aListaPed, aLinha )
    EndIf

    FT_FSKIP()

Enddo

FT_FUSE()

ValDadosSC7(aListaPed, aDadosSC7)

Return .t.




//------------------------------------------------------------------------------
/*/{Protheus.doc} ValDadosSC7

Rotina responsável por realizar a pré validação dos dados do CSV

@type function
@version  
@author Sato
@since 05/07/2025
@param aListaPed, array, param_description
@param aDadosSC7, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValDadosSC7(aListaPed As Array, aDadosSC7 As Array)

Local nX := 1
Local nY := 1
Local lFlag := .T.
Local cDesc := ""

Local cFilPed  := ""
Local cNumPed  := ""
Local nPosPedD := 0
Local nPosPedL := 0
Local cFilP17  := ""

Default aListaPed  = {}
Default aDadosSC7  = {}

For nX := 1 To Len(aListaPed)

    // 01 - C7_FILIAL
    cFilPed := aListaPed[nX,2]
    If !EMPTY(cFilPed)
        cCodEmp := FWCodEmp()
        If !FwFilExist(cCodEmp, cFilPed)
            cDesc += "Filial não cadastrada."
            lFlag := .F.
        EndIf

    Else
        cNumPed := aListaPed[nX,3]
        cDesc += "C7_FILIAL => Campo Filial é obrigatório."
        lFlag := .F.
    EndIF

    // 02 - C7_NUM
    If lFlag
        If !EMPTY(aListaPed[nX,3])
            cNumPed := aListaPed[nX,3]
            dbSelectArea("SC7")
            SC7->( dbSetOrder(1) )              //1 - C7_FILIAL+C7_NUM+C7_ITEM_C7_SEQUEN   // 3 - C7_FILIAL+C7_FORNECE_C7_LOJA+C7_NUM
            SC7->( dbGoTop() )
            IF SC7->( dbSeek(cFilPed+cNumPed) )
                Do While SC7->C7_FILIAL == cFilPed .and. SC7->C7_NUM == cNumPed

                    aAdd(aDadosSC7, {.T., SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_EMISSAO, SC7->C7_ITEM, ALLTRIM(SC7->C7_PRODUTO), SC7->C7_CONAPRO, ALLTRIM(SC7->C7_ENCER), ALLTRIM(SC7->C7_RESIDUO), SC7->C7_QUANT, SC7->C7_QUJE, SC7->C7_QTDACLA, ALLTRIM(SC7->C7_XORIG), ALLTRIM(SC7->C7_XNUM), ALLTRIM(SC7->C7_XFRONT), space(15)})
                    
                    If SC7->C7_CONAPRO == 'L' .and. SC7->C7_ENCER <> 'E' .and. SC7->C7_RESIDUO == ' ' .and. (SC7->C7_QUJE < SC7->C7_QUANT) .and. SC7->C7_QTDACLA == 0 .and. SC7->C7_XORIG <> "2" .and. EMPTY(SC7->C7_XIDEXNF)
                        
                        cFilP17 := space(GetSx3Cache("P17_FILIAL","X3_TAMANHO"))+SC7->C7_PRODUTO+cFilPed

                        dbSelectArea("P17")
                        P17->( dbSetOrder(1) )          // P17_FILIAL+P17_COD+P17_FTRATA
                        P17->( dbGoTop() )
                        IF P17->( dbSeek(cFilP17) )
                            If P17_BLOQ == 'N'
                                If P17->P17_ESTOQ <> 'S'
                                    cDesc := "Produto não estocável."
                                    lFlag := .F.
                                EndIf
                            Else
                                cDesc := "Produto bloqueado na tabela P17."
                                lFlag := .F.
                            EndIf
                        Else
                            cDesc := "Produto não encontrado na tabela P17."
                            lFlag := .F.
                        EndIf
                    Else
                        lFlag := .F.
                        DO CASE
                        CASE SC7->C7_RESIDUO <> ' '           // PEDIDO ELIMINADO RESIDUO
                            cDesc += "Item do Pedido de Compra Eliminado Residuo."
                        CASE SC7->C7_ENCER == 'E'             // PEDIDO ENCERRADO
                            cDesc += "Item do Pedido de Compra Encerrado."
                        CASE SC7->C7_CONAPRO == 'B'           // PEDIDO BLOQUEADO
                            cDesc += "Item do Pedido de Compra Bloqueado."
                        CASE SC7->C7_CONAPRO == 'R'           // PEDIDO REPROVADO
                            cDesc += "Item do Pedido de Compra Reprovado."
                        CASE SC7->C7_QUJE > 0                 // PEDIDO PARCIAL
                            cDesc += "Item do Pedido de Compra Recebido Parcial."
                        CASE SC7->C7_QTDACLA > 0              // PEDIDO EM RECEBIMENTO
                            cDesc += "Item do Pedido de Compra em Recebimento."
                        CASE SC7->C7_XORIG == "2"             // PEDIDO EXTERNO
                            cDesc += "Item do Pedido de Compra Externo."
                        CASE ALLTRIM(SC7->C7_XIDEXNF) <> ""    // PEDIDO DEVOLUCAO DE MES FECHADO
                            cDesc += "Item do Pedido de Compra Devolução de Mês Fechado."
                        ENDCASE
                    EndIf

                    If !lFlag
                        aDadosSC7[LEN(aDadosSC7),1] := .F.
                        aDadosSC7[LEN(aDadosSC7),16] := cDesc
                        lFlag := .T.
                        cDesc := ""
                    Else
                        aDadosSC7[LEN(aDadosSC7),1] := .T.
                        aDadosSC7[LEN(aDadosSC7),16] := ""
                    EndIf

                    SC7->( dbSkip() )
                End
            Else
                cDesc := "Pedido de Compra não encontrado."

                aAdd(aDadosSC7, {.F., cFilPed, cNumPed, "", "", "", "", "", "", "", "", "", "", "", "", cDesc })

            EndIf
        Else
            cDesc := "C7_NUM => Campo Número do Pedido é obrigatório."

            aAdd(aDadosSC7, {.F., cFilPed, cNumPed, "", "", "", "", "", "", "", "", "", "", "", "", cDesc })

        EndIf

        nPosPedD := aScan(aDadosSC7, {|x| x[3] == ALLTRIM(cNumPed)})
        nPosPedL := aScan(aListaPed, {|x| x[3] == ALLTRIM(cNumPed)})
        If nPosPedD > 0
            For nY := nPosPedD To Len(aDadosSC7)
                If aDadosSC7[nPosPedD,3] == cNumPed
                    If aDadosSC7[nY,1] == .T.
                        cDesc := ""
                        Exit
                    Else
                        If cDesc <> aDadosSC7[nY,16]
                            cDesc += aDadosSC7[nY,16]
                        EndIf
                    EndIf
                Else
                    Exit
                EndIf
            Next nY
            If EMPTY(cDesc)
                aListaPed[nPosPedL,1] := .T.
            Else
                aListaPed[nPosPedL,1] := .F.
                aListaPed[nPosPedL,4] := substr(cDesc, AT("Pedido", cDesc), LEN(cDesc))
            EndIf
        EndIf
    Else
        aAdd(aDadosSC7, {.F., cFilPed, cNumPed, "", "", "", "", "", "", "", "", "", "", "", "", cDesc})
        aListaPed[nX,1] := .F.
        aListaPed[nX,4] := cDesc
    EndIf

    lFlag := .T.
    cDesc := ""

Next nX

Return




//------------------------------------------------------------------------------

/*/{Protheus.doc} ValStep3

Função que verifica se os arrays de  Campos e de Dados estão vázios.

@type function
@version  
@author Sato
@since 10/07/2025
@param aListaPed, array, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return logical, return_description
/*/
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

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step4

Função que realiza a chamada da função de Eliminação de Resíduo dos Pedidos de Compra.

@type function
@version  
@author Sato
@since 06/07/2025
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param cObsRes, character, param_description
@param aListaPed, array, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@param aLogs, array, param_description
@param cArqConf, character, param_description
@param aConfer, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step4( oPanel As Object, cArquivo As Character, cObsRes As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array, aLogs As Array, cArqConf As Character, aConfer As Array )

Default cArquivo  := ""
Default cObsRes   := ""
Default aListaPed := {}
Default aDadosSC7 := {}
Default aCampos   := {}
Default aLogs     := {}
Default cArqConf  := ""
Default aConfer   := {}

FWMsgRun(oPanel, {|oSay| Step4Proc(oSay, cArquivo, cObsRes, aListaPed, aDadosSC7, aCampos, @aLogs, @cArqConf, @aConfer) }, "Processando", "Processando os Pedidos de Compras...")

FWAlertSuccess("Finalizado o processo de Leitura e Upload de Pedido de Compras", "Upload de Pedido de Compras")

Return




//------------------------------------------------------------------------------
/*/{Protheus.doc} Step4Proc

Função que executa a Eliminação de Resíduo dos Pedidos de Compra e integrando com o Front.

@type function
@version  
@author Sato
@since 10/07/2025
@param oSay, object, param_description
@param cArquivo, character, param_description
@param cObsRes, character, param_description
@param aListaPed, array, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@param aLogs, array, param_description
@param cArqConf, character, param_description
@param aConfer, array, param_description
@return variant, return_description
/*/
Static Function Step4Proc(oSay As Object, cArquivo As Character, cObsRes As Character, aListaPed As Array, aDadosSC7 As Array, aCampos As Array, aLogs As Array, cArqConf As Character, aConfer As Array)

Local nX       := 1
Local nY       := 1

Local cDrive   := ""
Local cDir     := ""
Local cNome    := ""
Local cExt     := ""

Local cFilPed  := ""
Local cNumPed  := ""
Local cCodUser := ""
Local cNomUser := ""

Local cCpoConf := ""
Local cLinConf := ""

Default cArquivo  := ""
Default cObsRes   := ""
Default aListaPed := {}
Default aDadosSC7 := {}
Default aCampos   := {}
Default aLogs     := {}
Default cArqConf  := ""
Default aConfer   := {}

AADD(aLogs, "FILIAL;NUMERO;STATUS" )

cCodUser := RetCodUsr()
cNomUser := FwGetUserName(RetCodUsr())

For nX := 1 To len(aListaPed)

    cFilPed := aListaPed[nX,2]
    cNumPed := aListaPed[nX,3]
    
    If aListaPed[nX,1] == .T.

        dbSelectArea("SC7")
        SC7->( dbSetOrder(1) )           //1 - C7_FILIAL+C7_NUM+C7_ITEM_C7_SEQUEN   // 3 - C7_FILIAL+C7_FORNECE_C7_LOJA+C7_NUM
        SC7->( dbGoTop() )
        IF SC7->( dbSeek(cFilPed+cNumPed) )
            Do While SC7->C7_FILIAL == cFilPed .and. SC7->C7_NUM == cNumPed
                If SC7->C7_ENCER == ' '
                    SC7->( RecLock("SC7",.F.) )

                    // ATUALIANDO OS CAMPOS DA ELIMINACAO DE RESIDUO
                    SC7->C7_XDATRES := DATE()
                    SC7->C7_RESIDUO := "S"
                    SC7->C7_ENCER   := "E"
                    SC7->C7_XUSRRES := cNomUser
                    SC7->C7_XOBSRES := cObsRes
                    
                    SC7->( MsUnlock() )
                    
                EndIf
                SC7->( dbSkip() )
            End

            // Função responsável pelo envio do Pedido para o Barramento
            cFilAnt := cFilPed

            u_F07022RE(cNumPed, 'R')

            AADD(aLogs, cFilPed+";"+cNumPed+";Pedido Eliminado Residuo no Protheus e enviado para o Barramento para ser enviado para o Front." )

        EndIf
    Else
        AADD(aLogs, cFilPed+";"+cNumPed+";"+aListaPed[nX,4] )
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
            CASE aCampos[nY] == "C7_EMISSAO"
                If !EMPTY(aDadosSC7[nX][nY])
                    cLinConf += DtoC(aDadosSC7[nX][nY])+";"
                Else
                    cLinConf += aDadosSC7[nX][nY]+";"
                EndIf
            CASE aCampos[nY] == "C7_QUANT" .or. aCampos[nY] == "C7_QUJE" .or. aCampos[nY] == "C7_QTDACLA"
                cLinConf += cValToChar(aDadosSC7[nX][nY])+";"
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
/*/{Protheus.doc} ValStep4

Função que verifica se o arquivo de LOG esta vazio

@type function
@version  
@author Sato
@since 02/07/2025
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

Função que apresenta a tela de geração dos logs e conferências e finalização do processamento

@type function
@version  
@author Sato
@since 02/07/2025
@param oPanel, variant, param_description
@param cArquivo, character, param_description
@param aLogs, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step5( oPanel As Objecto, cArquivo As Character, aLogs As Array, cArqConf As Character, aConfer As Array )

Default aLogs     := {}
Default cArquivo  := ""

FWMsgRun(oPanel, {|oSay| GeraCSV(oSay, aLogs, cArquivo) }, "Processando", "Gerando arquivo de Logs...")

FWMsgRun(oPanel, {|oSay| GeraCSV(oSay, aConfer, cArqConf) }, "Processando", "Gerando arquivo de Conferência...")

oFont:= TFont():New(,,-25,.T.,.T.,,,,,)

oSayTop := TSay():New(10,15,{|| "Finalizado o processo Eliminação de Resíduo."},oPanel,,oFont,,,,.T.,CLR_BLUE,)
oSayBottom1 := TSay():New(35,10,{|| "Consulte o arquivo de log e o arquivo de conferência no mesmo diretório onde esta o arquivo do Upload."},oPanel,,,,,,.T.,CLR_BLUE,)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraCSV

Função responsável por gerar o arquivo de Log

@type function
@version  
@author Sato
@since 02/07/2025
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
