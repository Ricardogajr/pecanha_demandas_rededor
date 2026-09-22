#Include "Protheus.ch"
#Include "rwmake.ch"
#include "totvs.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} RDPCUPLOAD

Função responsável pela realização de Upload dos Pedidos de Compras.

@type function
@version  
@author Sato
@since 11/25/2024
@return array, return_description
/*///------------------------------------------------------------------------------
User Function RDPCUPLOAD() As Array

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
Local aDadosSC7     As Array
Local aCampos       As Array
Local aLogs         As Array

Local cFilBkp := ''

cArquivo    := ""
aDadosSC7   := {}
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

oWizard := FWWizardControl():New( /*oObjPai*/, { 560, 850 } )	// INTSancia a classe FWWizardControl

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
oStep3 := oWizard:AddStep( 'Step3', { | oPanel | Step3( oPanel, cArquivo, @aDadosSC7, @aCampos ) } )
oStep3:SetStepDescription( "Conferência dos Dados" )            // Define o título do "Passo" | "Conferência dos Dados"
oStep3:SetNextTitle( "Próximo" )								// Define o título do botão de avanço | "Próximo"
oStep3:SetNextAction( { || ValStep3( aDadosSC7, aCampos ) } )   // Define o bloco ao clicar no botão Próximo
oStep3:SetCancelAction( { || lCancel := .T. } )					// Define o bloco ao clicar no botão Cancelar

/*
    "Processamento das correções"
*/
oStep4 := oWizard:AddStep( 'Step4', { | oPanel | Step4( oPanel, cArquivo, aDadosSC7, aCampos, @aLogs ) } )
oStep4:SetStepDescription( "Processamento dos Pedidos" )        // Define o título do "Passo" | "Processamento das correções"
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
@since 11/26/2024
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

oSayTop	:= TSay():New( 010,  10, { || "Upload de Pedidos de Compras" }, oPanel,, oFont,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 030,  10, { || "Este programa tem como obejtivo realizar manualmente o upload de Pedidos de Compras." }, oPanel,,,,,, .T., CLR_BLUE, )

oSay1	:= TSay():New( 040,  10, { || "Para a realização dos uploads, é necessário a criação de um template no formato CSV com os seguintes campos:" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 050,  15, { || "- C7_FILIAL - Filial do Sistema;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 060,  15, { || "- C7_FORNECE - Código do Fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 070,  15, { || "- C7_LOJA - Loja do fornecedor;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 080,  15, { || "- C7_COND - Código da Condição de Pagto;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 090,  15, { || "- C7_FILENT - Filial para Entrega;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 100,  15, { || "- C7_OBS - Observações;" }, oPanel,,,,,, .T., CLR_BLUE, )

oSay1	:= TSay():New( 050, 145, { || "- C7_ITEM - Item do pedido de compra;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 060, 145, { || "- C7_PRODUTO  - Código do produto;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 070, 145, { || "- C7_QUANT - Quantidade do Item;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 080, 145, { || "- C7_PRECO - Preço do Item;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 090, 145, { || "- C7_TPFRETE - Tipo Frete;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 100, 145, { || "- C7_FRETE - Valor Frete;" }, oPanel,,,,,, .T., CLR_BLUE, )

oSay1	:= TSay():New( 050, 275, { || "- C7_LOCAL - Local de Estoque;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 060, 275, { || "- C7_CC - Centro de Custo;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 070, 275, { || "- C7_XFRONT - Sigla do Fronte;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 080, 275, { || "- C7_XNUM - ID do Pedido de Compra no Fronte." }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 090, 275, { || "- C7_DESC1 - Desconto;" }, oPanel,,,,,, .T., CLR_BLUE, )
oSay1	:= TSay():New( 100, 275, { || "- C7_XDESFIN - Desc. Financeiro;" }, oPanel,,,,,, .T., CLR_BLUE, )

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
@since 11/26/2024
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
@since 11/27/2024
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

Função que monta a tela de conferência dos dados dos Pedidos de Compras a serem carregados.

@type function
@version  
@author Sato
@since 11/29/2022
@param oPanel, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3( oPanel As Object, cArquivo As Character, aDadosSC7 As Array, aCampos As Array )

local oOK   as object
local oNO   as object
local oBrw  as object

oOK := LoadBitmap(GetResources(), "br_verde")
oNO := LoadBitmap(GetResources(), "br_vermelho")

Default aDadosSC7   := {}
Default aCampos     := {}

FWMsgRun(oPanel, {|oSay| Step3Proc(oSay, cArquivo, @aDadosSC7, aCampos) }, "Processando", "Gerando dados para conferência...")

oBrw  := TWBrowse():New( 000 , 000 , (oPanel:nClientWidth/2) , (oPanel:nClientHeight/2),,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oBrw:SetArray(aDadosSC7)


////////////// TCColumn():New( < cTitulo >           , < bData >                              , [ cPicture ], [ uParam4 ], [ uParam5 ], [ cAlinhamento ], [ nLargura ], [ lBitmap ], [ lEdit ], [ uParam10 ], [ bValid ], [ uParam12 ], [ uParam13 ], [ uParam14 ] )

oBrw:AddColumn(TcColumn():New( ""                    , {||If(aDadosSC7[oBrw:nAt][01],oOK,oNO)},,,, "CENTER", 20, .T., .F.,,,, .F., ) )                  // Status
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[02]) , {|| aDadosSC7[oBrw:nAt][02] },,,,'LEFT' ,GetSx3Cache(aCampos[02],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_FILIAL
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[03]) , {|| aDadosSC7[oBrw:nAt][03] },,,,'LEFT' ,GetSx3Cache(aCampos[03],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XFRONT
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[04]) , {|| aDadosSC7[oBrw:nAt][04] },,,,'LEFT' ,GetSx3Cache(aCampos[04],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XNUM
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[05]) , {|| aDadosSC7[oBrw:nAt][05] },,,,'LEFT' ,GetSx3Cache(aCampos[05],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_FORNECE
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[06]) , {|| aDadosSC7[oBrw:nAt][06] },,,,'LEFT' ,GetSx3Cache(aCampos[06],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_LOJA
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[07]) , {|| aDadosSC7[oBrw:nAt][07] },,,,'LEFT' ,GetSx3Cache(aCampos[07],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_COND
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[08]) , {|| aDadosSC7[oBrw:nAt][08] },,,,'LEFT' ,GetSx3Cache(aCampos[08],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_FILENT
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[09]) , {|| aDadosSC7[oBrw:nAt][09] },,,,'LEFT' ,GetSx3Cache(aCampos[09],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_ITEM
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[10]) , {|| aDadosSC7[oBrw:nAt][10] },,,,'LEFT' ,GetSx3Cache(aCampos[10],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_PRODUTO
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[11]) , {|| aDadosSC7[oBrw:nAt][11] },,,,'RIGHT',GetSx3Cache(aCampos[11],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_QUANT
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[12]) , {|| aDadosSC7[oBrw:nAt][12] },,,,'RIGHT',GetSx3Cache(aCampos[12],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_PRECO
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[13]) , {|| aDadosSC7[oBrw:nAt][13] },,,,'LEFT' ,GetSx3Cache(aCampos[13],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_LOCAL
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[14]) , {|| aDadosSC7[oBrw:nAt][14] },,,,'LEFT' ,GetSx3Cache(aCampos[14],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_CC
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[15]) , {|| aDadosSC7[oBrw:nAt][15] },,,,'LEFT' ,GetSx3Cache(aCampos[15],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_TPFRETE
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[16]) , {|| aDadosSC7[oBrw:nAt][16] },,,,'RIGHT',GetSx3Cache(aCampos[16],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_FRETE
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[17]) , {|| aDadosSC7[oBrw:nAt][17] },,,,'RIGHT',GetSx3Cache(aCampos[17],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_DESC1
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[18]) , {|| aDadosSC7[oBrw:nAt][18] },,,,'RIGHT',GetSx3Cache(aCampos[18],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XDESFIN
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[19]) , {|| aDadosSC7[oBrw:nAt][19] },,,,'LEFT' ,GetSx3Cache(aCampos[19],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_XCODSET
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[20]) , {|| aDadosSC7[oBrw:nAt][20] },,,,'LEFT' ,GetSx3Cache(aCampos[20],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_IPI
oBrw:AddColumn(TCColumn():New( RetTitle(aCampos[21]) , {|| aDadosSC7[oBrw:nAt][21] },,,,'LEFT' ,GetSx3Cache(aCampos[21],"X3_TAMANHO"),.F.,.F.,,,,.F.,))  // C7_OBS
oBrw:AddColumn(TCColumn():New( "Descrição do Erro"   , {|| aDadosSC7[oBrw:nAt][22] },,,,'LEFT' ,250,.F.,.F.,,,,.F.,))                                    // DESCRICAO DO ERRO

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
Static Function ValStep3( aDadosSC7 As Array, aCampos As Array ) As Logical

Local lRet  As Logical

lRet := .T.

If Len(aDadosSC7) = 0
    lRet := .F.
    Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
EndIf

If Len(aCampos) = 0
    lRet := .F.
    Help(' ',1,'Inválido' ,,'Arquivo de dados inválido.',2,0,)
EndIf

If aScan(aDadosSC7,{|x| x[1] == .F.}) > 0
    lRet := .F.
    Help(' ',1,'Inválido' ,,'Arquivo de dados com ERRO.',2,0,)
EndIf

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
Static Function Step4( oPanel As Object, cArquivo As Character, aDadosSC7 As Array, aCampos As Array, aLogs As Array )

Default cArquivo  := ""
Default aDadosSC7 := {}
Default aCampos   := {}
Default aLogs     := {}

FWMsgRun(oPanel, {|oSay| Step4Proc(oSay, cArquivo, aDadosSC7, aCampos, @aLogs) }, "Processando", "Processando os Pedidos de Compras...")

FWAlertSuccess("Finalizado o processo de Leitura e Upload de Pedido de Compras", "Upload de Pedido de Compras")

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
Static Function Step5( oPanel As Objecto, cArquivo As Character, aLogs As Array )

Default aLogs     := {}
Default cArquivo  := ""

FWMsgRun(oPanel, {|oSay| GeraCSV(oSay, aLogs, cArquivo) }, "Processando", "Gerando arquivo de Logs...")

oFont:= TFont():New(,,-25,.T.,.T.,,,,,)

oSayTop := TSay():New(10,15,{|| "Finalizado o processo de Upload dos Pedidos de Compras."},oPanel,,oFont,,,,.T.,CLR_BLUE,)
oSayBottom1 := TSay():New(35,10,{|| "Consulte o arquivo de log no mesmo diretório onde esta o arquivo do Upload."},oPanel,,,,,,.T.,CLR_BLUE,)

Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} Step3Proc

Rotina responsável por realizar a leitura do arquivo CSV

@type function
@version  
@author Sato
@since 12/04/2022
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function Step3Proc(oSay As Object, cArquivo As Character, aDadosSC7 As Array, aCampos As Array )

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
    aLinha := Separa( Upper(";"+cBuffer)+";", ";")
    
    If nContLin > 1
        If Len(aCampos) = 0
            aLinha[1]  := "STATUS"
            aLinha[LEN(aLinha)] := "ERRO"
            aCampos := aClone(aLinha)
        Else
            AADD( aDadosSC7, aLinha )
        EndIf
    EndIf

    FT_FSKIP()   

Enddo

FT_FUSE() 

ValDadosSC7(aDadosSC7)

Return .t.



//------------------------------------------------------------------------------
/*/{Protheus.doc} ValDadosSC7

Rotina responsável por realizar a pré validação dos dados do CSV

@type function
@version  
@author Sato
@since 02/17/2025
@param oSay, object, param_description
@param cArquivo, character, param_description
@param aDadosSC7, array, param_description
@param aCampos, array, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function ValDadosSC7(aDadosSC7 As Array)

local aArea := getarea()
Local nX := 1
Local lFlag := .T.
Local cDesc := ""

Local cC7FilO  := ""
Local cC7Forn  := ""
Local cC7Cond  := ""
Local cC7FilE  := ""
Local cC7Qtde  := ""
Local cC7Prec  := ""
Local cC7Prod  := ""
Local cC7Loca  := ""
Local cC7CCus  := ""
Local cC7Frte  := ""
Local cC7Setor := ""

Default aDadosSC7 = {}

For nX := 1 To Len(aDadosSC7)
    // 01 - FLAG

    // 02 - C7_FILIAL
    cC7FilO := aDadosSC7[nX,2]
    If !EMPTY(cC7FilO)
        If !FWFilialStatus(cC7FilO)
            cDesc += "Filial não encadastrada ou bloqueada para uso.|"
            lFlag := .F.
        EndIf
        /*
        cCodEmp := FWCodEmp(cC7FilO)
        If !FwFilExist(cCodEmp,cC7FilO)
            cDesc += "Filial não cadastrada.|"
            lFlag := .F.
        EndIf
        */
    Else
        cDesc += "C7_FILIAL => Campo Filial é obrigatório.|"
        lFlag := .F.
    EndIF

    // 03 - C7_XFRONT   // 04 - C7_XNUM
    If aDadosSC7[nX,3] == 'NTS'
        If EMPTY(aDadosSC7[nX,4])
            cDesc += "C7_XNUM => Campo Pedido Front é obrigatório.|"
            lFlag := .F.
        EndIf
    ElseIf aDadosSC7[nX,3] == 'P12'
        If EMPTY(aDadosSC7[nX,4])
            cDesc += "C7_XNUM => Campo Pedido Controle é obrigatório.|"
            lFlag := .F.
        EndIf
    Else
        If EMPTY(aDadosSC7[nX,3])
            cDesc += "C7_XFRONT => Campo Nome Front é obrigatório.|"
            lFlag := .F.
        Else
            cDesc += "C7_XFRONT => Conteúdo do Campo Nome Front diferente de 'NTS' ou 'P12'.|"
            lFlag := .F.
        EndIf
        If EMPTY(aDadosSC7[nX,4])
            cDesc += "C7_XNUM => Campo Pedido Controle é obrigatório.|"
            lFlag := .F.
        EndIf
    EndIf

    // 05 - C7_FORNECE  // 06 - C7_LOJA
    cC7Forn := aDadosSC7[nX,5]+aDadosSC7[nX,6]
    If !EMPTY(aDadosSC7[nX,5]) .and. !EMPTY(aDadosSC7[nX,6])
        dbSelectArea("SA2")
        SA2->( dbSetOrder(1) )              // A2_FILIAL+A2_COD+A2_LOJA
        SA2->( dbGoTop() )
        IF SA2->( dbSeek(xFilial("SA2")+cC7Forn) )
            If SA2->A2_MSBLQL = '1'         // 1=Sim;2=Nao
                cDesc += "Fornecedor bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Fornecedor não cadastrado.|"
            lFlag := .F.
        EndIf
    Else
        If EMPTY(aDadosSC7[nX,5])
            cDesc += "C7_FORNECE => Campo Fornecedor é obrigatório.|"
            lFlag := .F.
        EndIf
        If EMPTY(aDadosSC7[nX,6])
            cDesc += "C7_LOJA => Campo Loja é obrigatório.|"
            lFlag := .F.
        EndIf
    EndIf

    // 07 - C7_COND
    cC7Cond := aDadosSC7[nX,7]
    If !EMPTY(cC7Cond)
        dbSelectArea("SE4")
        SE4->( dbSetOrder(1) )              // E4_FILIAL+E4_CODIGO
        SE4->( dbGoTop() )
        IF SE4->( dbSeek(xFilial("SE4")+cC7Cond) )
            If SE4->E4_MSBLQL = '1'           // 1=Inativo;2=Ativo
                cDesc += "Condição de Pagamento bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Condição de Pagamento não cadastrado.|"
            lFlag := .F.
        EndIf
    Else
        cDesc += "C7_COND => Campo Condição de Pagamento é obrigatório.|"
        lFlag := .F.
    EndIf

    // 08 - C7_FILENT
    cC7FilE := aDadosSC7[nX,8]
    If !EMPTY(cC7FilE)
        If !FWFilialStatus(cC7FilE)
            cDesc += "Filial de Entrega não encadastrada ou bloqueada para uso.|"
            lFlag := .F.
        EndIf
        /*
        cCodEmp := FWCodEmp(cC7FilE)
        If !FwFilExist(cCodEmp,cC7FilE)
            cDesc += "Filial de Entrega não cadastrada.|"
            lFlag := .F.
        EndIf
        */
    EndIF

    // 09 - C7_ITEM
    aDadosSC7[nX,9] := StrZero(Val(aDadosSC7[nX,9]), 4)

    // 10 - C7_PRODUTO
    /* VALIDAÇÃO PELA TABELA SB1
    If !EMPTY(cC7Prod)
        dbSelectArea("SB1")
        SB1->( dbSetOrder(1) )              // B1_FILIAL+B1_COD
        SB1->( dbGoTop() )
        IF SB1->( dbSeek(xFilial("SB1")+cC7Prod) )
            If SB1->B1_MSBLQL = '1'         // 1=Sim;2=Não
                cDesc += "Produto bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Produto não cadastrado.|"
            lFlag := .F.
        EndIf
    Else
        cDesc += "C7_PRODUTO => Campo Produto é obrigatório.|"
        lFlag := .F.
    EndIf
    */
    // VALIDAÇÃO DO PRODUTO PELA TABELA P17
    cC7Prod := aDadosSC7[nX,10]
    If !EMPTY(cC7Prod)
        dbSelectArea("P17")
        P17->( dbSetOrder(1) )              // P17_FILIAL+P17_COD+P17_FTRATA
        P17->( dbGoTop() )
        IF P17->( dbSeek(xFilial("P17")+PADR(cC7Prod,Len(P17_COD)," ")+cC7FilO) )
            If P17->P17_BLOQ = 'S'         // S=Sim;N=Não
                cDesc += "Produto bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Produto não cadastrado.|"
            lFlag := .F.
        EndIf
    Else
        cDesc += "C7_PRODUTO => Campo Produto é obrigatório.|"
        lFlag := .F.
    EndIf
    // VALIDAÇÃO PELA TABELA P21 - Veriifica se o Grupo de Compras do Pedido pode usar o Tipo do Produto em questão
    // SOMENTE PARA COMPRADOR DELEGADO
    /*
    If !EMPTY(cC7Prod)
        dbSelectArea("P21")
        P21->( dbSetOrder(2) )              // P21_FILIAL+P21_GRCOM+P21_TPPRD
        P21->( dbGoTop() )
        IF P21->( dbSeek(xFilial("P21")+cC7Prod) )
            If P21->B1_MSBLQL = '1'         // 1=Sim;2=Não
                cDesc += "Produto bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Produto não cadastrado.|"
            lFlag := .F.
        EndIf
    EndIf
    */

    // 11 - C7_QUANT
    cC7Qtde := VAL(STRTRAN(aDadosSC7[nX,11],",","."))
    If cC7Qtde <= 0
        cDesc += "C7_QUANT => Campo Qtd. Consumo é obrigatório.|"
        lFlag := .F.
    EndIf

    // 12 - C7_PRECO
    cC7Prec  := VAL(STRTRAN(aDadosSC7[nX,12],",","."))
    If cC7Prec <= 0
        cDesc += "C7_QUANT => Campo Prc. Unitario é obrigatório.|"
        lFlag := .F.
    EndIf

    // 13 - C7_LOCAL
    cC7Loca := aDadosSC7[nX,13]
    If !EMPTY(cC7Loca)
        dbSelectArea("NNR")
        NNR->( dbSetOrder(1) )              // NNR_FILIAL+NNR_CODIGO
        NNR->( dbGoTop() )
        IF NNR->( dbSeek(xFilial("NNR")+cC7Loca) )
            If NNR->NNR_MSBLQL = '1'        // 1=Sim;2=Não
                cDesc += "Local de Estoque bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Local de Estoque não cadastrado.|"
            lFlag := .F.
        EndIf
    Else
        cDesc += "C7_LOCAL => Campo Local de Estoque é obrigatório.|"
        lFlag := .F.
    EndIf

    // 14 - C7_CC
    cC7CCus := aDadosSC7[nX,14]
    If !EMPTY(cC7CCus)
        dbSelectArea("CTT")
        CTT->( dbSetOrder(1) )              // CTT_FILIAL+CTT_CUSTO
        CTT->( dbGoTop() )
        IF CTT->( dbSeek(xFilial("CTT")+cC7CCus) )
            If CTT->CTT_BLOQ = '1'          // 1=Bloqueado;2=Nao Bloqueado
                cDesc += "Centro de Custo bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Centro de Custo não cadastrado.|"
            lFlag := .F.
        EndIf
    Else
        cDesc += "C7_CC => Campo Centro de Custo é obrigatório.|"
        lFlag := .F.
    EndIf

    // 15 - C7_TPFRETE
    If !EMPTY(aDadosSC7[nX,15])
        cC7Frte := aDadosSC7[nX,15]
        iF !(cC7Frte $ "C|F|T|R|D|S")
            cDesc += "Tipo de Frete invalido.|"
            lFlag := .F.
        EndIf
    EndIf

    // 16 - C7_FRETE
    /*
    C - Cost, Insurance and Freight (CIF) - o Remetente se responsabiliza pelo pagamento
    F - Free On Board (FOB) - o Destinatario se responsabiliza pelo pagamento
    T - Por conta de Terceiros
    R - Por conta do Remetente
    D - Por conta do Destinatario
    S - Sem Frete
    */
    IF VAL(STRTRAN(aDadosSC7[nX,16],",",".")) < 0
        If !EMPTY(aDadosSC7[nX,15])
            cDesc += "C7_FRETE => Campo Valor Frete é obrigatório.|"
            lFlag := .F.
        EndIf
    EndIf

    // 17 - C7_DESC1

    // 18 - C7_XDESFIN

    // 19 - C7_XCODSET
    cC7Setor := aDadosSC7[nX,19]
    If !EMPTY(cC7Setor)
        dbSelectArea("P11")
        P11->( dbSetOrder(1) )              // P11_FILIAL+P11_COD
        P11->( dbGoTop() )
        IF P11->( dbSeek(xFilial("P11")+cC7Setor) )
            If P11->P11_MSBLQL = '1'          // 1=Bloqueado;2=Nao Bloqueado
                cDesc += "Setor bloqueado para uso.|"
                lFlag := .F.
            EndIf
        ELSE
            cDesc += "Setor não cadastrado.|"
            lFlag := .F.
        EndIf
    EndIf

    // 20 - C7_IPI

    // 21 - C7_OBS

    // 22 - DESCRIÇÃO
    If !lFlag
        If !EMPTY(cDesc)        // Remover o ultimo caracter da string
            cDesc := SubStr( cDesc, 1, Len(cDesc)-1 )
        EndIf
        aDadosSC7[nX,1] := .F.
        aDadosSC7[nX,Len(aDadosSC7[nX])] := OEMToANSI( cDesc )
    Else
        aDadosSC7[nX,1] := .T.
        aDadosSC7[nX,Len(aDadosSC7[nX])] := ""
    EndIf

    lFlag    := .T.
    cDesc    := ""
    cC7FilO  := ""
    cC7Forn  := ""
    cC7Cond  := ""
    cC7FilE  := ""
    cC7Prod  := ""
    cC7Loca  := ""
    cC7CCus  := ""
    cC7Frte  := ""
    cC7Setor := ""
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
Static Function Step4Proc(oSay As Object, cArquivo As Character, aDadosSC7 As Array, aCampos As Array, aLogs As Array)

Local aCabec  := {}
Local aItens  := {}
Local aLinha  := {}
Local aRatCC  := {}
Local aRatPrj := {}
Local aAdtPC  := {}

Local cCmpCab := ""
Local cNumPed := ""
Local nOpc    := 3
Local nX      := 1
Local nY      := 1
Local cRet    := ""

Local nPosFili := ''
Local nPosXnum := ''
Local nPosFront := ''
Local cIdPCCtrl := ''

Local aLogAuto := {}
Local cLogTxt  := ""
Local cArqLog  := ""  
Local nAux     := 0
Local cDrive   := ""
Local cDir     := ""
Local cNome    := ""
Local cExt     := ""

PRIVATE lMsErroAuto     := .F.
PRIVATE lAutoErrNoFile  := .T.
PRIVATE lMsHelpAuto     := .T.

SplitPath( cArquivo, cDrive, cDir, cNome, cExt )

//cArqLog  := "C:\TESTES\UPLOAD_PC\ARQLOG.txt" 
cArqLog  := cDrive+cDir+cNome+"_LOG_COMPLETO.txt"

AADD(aLogs, "FILIAL;ID NETSUITE;ID PROTHEUS;STATUS" )

nPosFili  := aScan(aCampos, {|x| AllTrim(Upper(x)) == "C7_FILIAL" })
nPosXnum  := aScan(aCampos, {|x| AllTrim(Upper(x)) == "C7_XNUM" })
nPosFront := aScan(aCampos, {|x| AllTrim(Upper(x)) == "C7_XFRONT" })

cIdPCCtrl := aDadosSC7[1][nPosXnum]
cFilAnt := PadR(aDadosSC7[1][nPosFili], TamSx3("C7_FILIAL")[01])

cCmpCab := "C7_NUM|C7_EMISSAO|C7_FORNECE|C7_LOJA|C7_COND|C7_FILENT|C7_TPFRETE|C7_FRETE|C7_DESC1"
cNumPed := GetSXENum("SC7","C7_NUM")

dbSelectArea("SC7")
SC7->( dbSetOrder(1) )
SC7->( dbGotop() )
While SC7->( dbSeek(xFilial("SC7")+cNumPed) )
    // ConfirmSX8()
    cNumPed := GetSXENum("SC7","C7_NUM")
EndDo

For nX := 1 To len(aDadosSC7)

    If cIdPCCtrl == aDadosSC7[nX][nPosXnum]

        If Len(aCabec) = 0
            aAdd(aCabec, {"C7_NUM" ,cNumPed})
            aadd(aCabec, {"C7_EMISSAO" ,dDataBase})
        EndIf

        For nY := 01 To Len(aDadosSC7[nX])
            If Len(aCabec) < 9
                If aCampos[nY] <> 'STATUS' .and. aCampos[nY] <> 'C7_FILIAL' .and. aCampos[nY] <> 'ERRO'
                    If aCampos[nY] $ cCmpCab
                        If aCampos[nY] $ 'C7_FRETE|C7_DESC1'
                            aAdd(aCabec, {aCampos[nY], VAL(STRTRAN(aDadosSC7[nX][nY],",","."))})
                        Else
                            aAdd(aCabec, {aCampos[nY], aDadosSC7[nX][nY]})
                        EndIf
                    else
                        If aCampos[nY] $ 'C7_QUANT|C7_PRECO|C7_XDESFIN|C7_IPI'
                            aAdd(aLinha, {aCampos[nY], VAL(STRTRAN(aDadosSC7[nX][nY],",",".")), Nil})
                        Else
                            If aDadosSC7[nX][nPosFront] == 'P12' 
                                If aCampos[nY] $ 'C7_XFRONT|C7_XNUM'
                                    aAdd(aLinha, {aCampos[nY], "", Nil})
                                Else
                                    aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                                EndIf
                            Else
                                aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                            EndIf
                        EndIf
                    EndIf
                EndIf
            Else
                If aCampos[nY] <> 'STATUS' .and. aCampos[nY] <> 'ERRO' .and. aCampos[nY] <> 'C7_FILIAL'
                    If !(aCampos[nY] $ cCmpCab)
                        If aCampos[nY] == 'C7_XFRONT' 
                            If aDadosSC7[nX][nY] == 'P12'
                                aAdd(aLinha, {aCampos[nY], "", Nil})
                            EndIf
                        Else
                            If aCampos[nY] $ 'C7_QUANT|C7_PRECO|C7_XDESFIN|C7_IPI'
                                aAdd(aLinha, {aCampos[nY], VAL(STRTRAN(aDadosSC7[nX][nY],",",".")), Nil})
                            Else
                                If aDadosSC7[nX][nPosFront] == 'P12' 
                                    If aCampos[nY] $ 'C7_XFRONT|C7_XNUM'
                                        aAdd(aLinha, {aCampos[nY], "", Nil})
                                    Else
                                        aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                                    EndIf
                                Else
                                    aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        next nY
        aadd(aItens,aLinha)
        aLinha := {}
    Else
                        
        MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,nOpc,.F.,aRatCC,aAdtPC,aRatPrj)
        //MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabec,aItens,nOpc,.F.)

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
            ConfirmSX8()
        EndIf

        AADD(aLogs, cFilAnt+";"+cIdPCCtrl+";"+cNumPed+";"+cRet )

        aCabec := {}
        aLinha := {}
        aItens := {}
        cRet   := ""

        cFilAnt := PadR(aDadosSC7[nX][nPosFili], TamSx3("C7_FILIAL")[01])

        cIdPCCtrl := aDadosSC7[nX][nPosXnum]

        If Len(aCabec) = 0
            cNumPed := GetSXENum("SC7","C7_NUM")
            dbSelectArea("SC7")
            SC7->( dbSetOrder(1) )
            SC7->( dbGotop() )
            While SC7->( dbSeek(xFilial("SC7")+cNumPed) )
                // ConfirmSX8()
                cNumPed := GetSXENum("SC7","C7_NUM")
            EndDo

            aAdd(aCabec, {"C7_NUM" ,cNumPed})
            aadd(aCabec, {"C7_EMISSAO" ,dDataBase})
        EndIf

        For nY := 01 To Len(aDadosSC7[nX])
            If Len(aCabec) < 9
                If aCampos[nY] <> 'STATUS' .and. aCampos[nY] <> 'ERRO' .and. aCampos[nY] <> 'C7_FILIAL'
                    If aCampos[nY] $ cCmpCab
                        If aCampos[nY] $ 'C7_FRETE|C7_DESC1'
                            aAdd(aCabec, {aCampos[nY], VAL(STRTRAN(aDadosSC7[nX][nY],",","."))})
                        Else
                            aAdd(aCabec, {aCampos[nY], aDadosSC7[nX][nY]})
                        EndIf
                    else
                        If aCampos[nY] $ 'C7_QUANT|C7_PRECO|C7_XDESFIN|C7_IPI'
                            aAdd(aLinha, {aCampos[nY], VAL(STRTRAN(aDadosSC7[nX][nY],",",".")), Nil})
                        Else
                            If aDadosSC7[nX][nPosFront] == 'P12' 
                                If aCampos[nY] $ 'C7_XFRONT|C7_XNUM'
                                    aAdd(aLinha, {aCampos[nY], "", Nil})
                                Else
                                    aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                                EndIf
                            Else
                                aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                            EndIf
                        EndIf
                    EndIf
                EndIf
            Else
                If aCampos[nY] <> 'STATUS' .and. aCampos[nY] <> 'ERRO' .and. aCampos[nY] <> 'C7_FILIAL'
                    If !(aCampos[nY] $ cCmpCab)
                        If aCampos[nY] == 'C7_XFRONT' 
                            If aDadosSC7[nX][nY] == 'P12'
                                aAdd(aLinha, {aCampos[nY], "", Nil})
                            EndIf
                        Else
                            If aCampos[nY] $ 'C7_QUANT|C7_PRECO|C7_XDESFIN|C7_IPI'
                                aAdd(aLinha, {aCampos[nY], VAL(STRTRAN(aDadosSC7[nX][nY],",",".")), Nil})
                            Else
                                If aDadosSC7[nX][nPosFront] == 'P12' 
                                    If aCampos[nY] $ 'C7_XFRONT|C7_XNUM'
                                        aAdd(aLinha, {aCampos[nY], "", Nil})
                                    Else
                                        aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                                    EndIf
                                Else
                                    aAdd(aLinha, {aCampos[nY], aDadosSC7[nX][nY], Nil})
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        next nY

        aadd(aItens,aLinha)
        aLinha := {}

    EndIf

Next nX

If Len(aCabec) > 0 .and. Len(aItens) > 0
    
    //MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,nOpc,.F.,aRatCC,aAdtPC,aRatPrj)
    MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabec,aItens,nOpc,.F.)

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
        
        //FERASE(cPath+cNomArqErro)
        
        lMsErroAuto := .F.
    Else
        cRet := "Incluido com sucesso"
        ConfirmSX8()
    EndIf

    AADD(aLogs, cFilAnt+";"+cIdPCCtrl+";"+cNumPed+";"+cRet )

    aCabec := {}
    aLinha := {}
    aItens := {}
    cRet   := ""

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
