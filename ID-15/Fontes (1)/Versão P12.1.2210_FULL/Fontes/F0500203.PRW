#INCLUDE    'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cAliasPA5

// ------------------------------------------------------------------
// {Protheus.doc} F0500203
// Função que exibe o Browse com os registros da Solicitação de Vagas
// @author Fernando Carvalho
// @since 07/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

user function f0500203()

// ----------------------------------------------
    local   oBrowse
    local   cFiltro    := ''
// ----------------------------------------------
//  [ Chamado DOR06434893_TK_6401753 - Ini 1/3 ]
// ----------------------------------------------
    private cStatusPA5 := ''
// ----------------------------------------------
//  [ Chamado DOR06434893_TK_6401753 - Fim 1/3 ]
// ----------------------------------------------

    cAliasPA5 := getnextalias()
    oBrowse   := fwmbrowse():New()
    cFiltro   := "PA2_SIT $ 'AP/AG'" // somente para exibir as vagas

    oBrowse:SetAlias( 'PA2' )
    oBrowse:SetDescription( 'Mudança de Status de Indicadores' )
    oBrowse:SetFilterDefault( cFiltro )
    oBrowse:SetOnlyFields( { 'PA2_FILIAL' , 'PA2_CDCAND' , 'PA2_NMCAND' , 'PA2_STSVAG' } )
    oBrowse:DisableDetails()
    oBrowse:AddLegend( "PA2->PA2_SIT == 'AP'" , 'GREEN'	 , 'APROVADA'   )
    oBrowse:AddLegend( "PA2->PA2_SIT == 'AG'" , 'ORANGE' , 'AGUARDANDO' )
    oBrowse:Activate()

return NIL

// ------------------------------------------------------------------

static function menudef()
    local aRotina := {}
    ADD OPTION aRotina TITLE 'Monitoramento' ACTION 'VIEWDEF.F0500203' OPERATION 2  ACCESS 0
//  ADD OPTION aRotina TITLE 'Monitoramento' ACTION 'Monitoramento()'  OPERATION 2  ACCESS 0
return aRotina

// ------------------------------------------------------------------
//{Protheus.doc} ModelDef
// Menu da rotina de Solicitações de Vagas
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @return oModel - Objeto do modelo do MVC
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function modeldef()

// -[ Cria a estrutura a ser usada no Modelo de Dados ]----
    local oStrField := FieldModelo()
    local oStruPA5  := GridModelo()
    local oModel

// -[ Cria o objeto do Modelo de Dados ]-------------------
    oModel := MPFormModel():New('F050203' , /*bPreValidacao*/ , /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
    oModel:AddFields( 'FIELD' , /*cOwner*/ , oStrField , /*bPreVld*/ , /*bPosVld*/ , {|oModel|CargaField( oModel ) } /*bLoad*/ )
    oModel:AddGrid( 'GRID' , 'FIELD' , oStruPA5 , , , , , {|oModel|CargaGrid( oModel ) } )
    oModel:GetModel( 'FIELD' ):SetPrimaryKey( {} )
    oModel:GetModel( 'GRID'  ):SetNoInsertLine()
    oModel:SetDescription( 'Mudança de Status de Indicadores' )

//  Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'FIELD' ):SetDescription( 'Consulta de Indicadores' )
    oModel:SetPrimaryKey({ 'PA5_FILIAL+PA5_XNRSOL+PA5_XDATA' })
    oModel:SetVldActivate( { |oModel| ValidModel( oModel ) } )

return oModel

// ------------------------------------------------------------------
// {Protheus.doc} FieldModelo
// Retorna a estrutura da Field da Tela para o Modelo
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------
static function fieldmodelo()

    local oStructModelField := FWformModelStruct():New()

    oStructModelField:AddTable( 'PA5' , , 'Consulta de Indicadores' )

    oStructModelField:AddField( 'Filial Solic'   , 'Filial Solic'   , 'PA5_XUNIDA' , 'C' , tamsx3( 'PA5_XUNIDA' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Num Solic'      , 'Num Solic'      , 'PA5_XNRSOL' , 'C' , tamsx3( 'PA5_XNRSOL' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Desc Solic'     , 'Desc Solic'     , 'PA5_XDESOL' , 'C' , tamsx3( 'PA5_XDESOL' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Função'         , 'Função'         , 'PA5_FUNCAO' , 'C' , tamsx3( 'PA5_FUNCAO' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Matr. Solici'   , 'Matr. Solici'   , 'PA5_XMAT'   , 'C' , tamsx3( 'PA5_XMAT'   )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Nome Solicit'   , 'Nome Solicit'   , 'PA5_XNOME'  , 'C' , tamsx3( 'PA5_XNOME'  )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Departamento'   , 'Departamento'   , 'PA5_XSETOR' , 'C' , tamsx3( 'PA5_XSETOR' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Cargo'          , 'Cargo'          , 'PA5_XCARGO' , 'C' , tamsx3( 'PA5_XCARGO' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelField:AddField( 'Centro Custo'   , 'Centro Custo'   , 'PA5_XCC'    , 'C' , tamsx3( 'PA5_XCC'    )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
//  oStructModelField:AddField( 'Conta Orçament' , 'Conta Orçament' , 'PA5_XCONTA' , 'C' , tamsx3( 'PA5_XCONTA' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )

return oStructModelField

// ------------------------------------------------------------------
// {Protheus.doc} GridModelo
// Retorna a estrutura da Grid da Tela para o MOdelo
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function gridmodelo()

    local oStructModelGrid := FWformModelStruct():New()

    oStructModelGrid:AddTable( 'PA5' , , 'Consulta de Indicadores' )

    oStructModelGrid:AddField( 'Matr. Aprovado'   , 'Matr. Aprovado'   , 'PA5_XMATAP' , 'C' , tamsx3( 'PA5_XMATAP' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Nome Aprovador'   , 'Nome Aprovador'   , 'PA5_XAPROV' , 'C' , tamsx3( 'PA5_XAPROV' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Departamento'     , 'Departamento'     , 'PA5_XSEAPV' , 'C' , tamsx3( 'PA5_XSEAPV' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Filial Aprovador' , 'Filial Aprovador' , 'PA5_XUNAPR' , 'C' , tamsx3( 'PA5_XUNAPR' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Cargo Aprovador'  , 'Cargo Aprovador'  , 'PA5_XCARAP' , 'C' , tamsx3( 'PA5_XCARAP' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Cod. Evento'      , 'Cod. Evento'      , 'PA5_XCODEV' , 'C' , tamsx3( 'PA5_XCODEV' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Des. Evento'      , 'Des. Evento'      , 'PA5_XDESEV' , 'C' , tamsx3( 'PA5_XDESEV' )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Status'           , 'Status'           , 'PA5_XSTAT'  , 'C' , tamsx3( 'PA5_XSTAT'  )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Valor Solicitado' , 'Valor Solicitado' , 'PA5_XEMPEN' , 'N' , tamsx3( 'PA5_XEMPEN' )[1] , 2 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Data'             , 'Data'             , 'PA5_XDATA'  , 'D' , tamsx3( 'PA5_XDATA'  )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )
    oStructModelGrid:AddField( 'Hora'             , 'Hora'             , 'PA5_XHORA'  , 'C' , tamsx3( 'PA5_XHORA'  )[1] , 0 , {|| .T.} , {|| .F.} , NIL , .F. , NIL , NIL , NIL , .T. )

return oStructModelGrid

// ------------------------------------------------------------------
// {Protheus.doc} ViewDef
// Retorna a View da rotina
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function viewdef()

    local oModel
    local oView    := FWFormView():New()
    local oStruCab := FieldView()
    local oStrGrid := GridView()

    oModel         := FWLoadModel( 'F0500203' )
    oView:SetModel( oModel )

    oView:AddField( 'TELA' , oStruCab , 'FIELD' )
    oView:AddGrid(  'ITEM' , oStrGrid , 'GRID'  )

//  adiciona uma função para incluir os botões da rotina
    oView:AddOtherObject( 'BOTOESDIR' , {|oPanel,oView| TBUTTONUSER( oPanel , oView ) } )

    oView:CreateHorizontalBox( 'BOXTELA' , 40 )
    oView:CreateHorizontalBox( 'BOXPA5'  , 45 )
    oView:CreateHorizontalBox( 'BOXBOT'  , 15 )

    oView:CreateVerticalBox( 'BOXBOTESQ' , 000 , 'BOXBOT' )
    oView:CreateVerticalBox( 'BOXBOTDIR' , 100 , 'BOXBOT' )

//  Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'TELA'      , 'BOXTELA'   )
    oView:SetOwnerView( 'ITEM'      , 'BOXPA5'    )
    oView:SetOwnerView( 'BOTOESDIR' , 'BOXBOTDIR' )

//  oView:EnableTitleView( 'ITEM' , 'Consulta de Indicadores' )

    oView:EnableControlBar( .F. )

//  oView:setUseCursor( .F. )
//  oView:SetCloseOnOk( {||.T.} )

    oView:SetViewCanActivate( {|oView| .T. } )

return oView

// ------------------------------------------------------------------
// {Protheus.doc} FieldView
// Retorna a estrutura da Field da Tela para a View
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function fieldview()

    local oStructViewField := FWformViewStruct():New()

    oStructViewField:AddField( 'PA5_XUNIDA' , '001' , 'Filial Solic'   , 'Filial Solic'   , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XNRSOL' , '002' , 'Num Solic'      , 'Num Solic'      , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XDESOL' , '003' , 'Desc Solic'     , 'Desc Solic'     , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_FUNCAO' , '004' , 'Função'         , 'Função'         , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XMAT'   , '005' , 'Matr. Solici'   , 'Matr. Solici'   , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XNOME'  , '006' , 'Nome Solicit'   , 'Nome Solicit'   , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XSETOR' , '007' , 'Departamento'   , 'Departamento'   , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XCARGO' , '008' , 'Cargo'          , 'Cargo'          , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewField:AddField( 'PA5_XCC'    , '009' , 'Centro Custo'   , 'Centro Custo'   , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )
//  oStructViewField:AddField( 'PA5_XCONTA' , '010' , 'Conta Orçament' , 'Conta Orçament' , NIL , 'GET' , '@!' , NIL , '' ,	.T. , NIL , NIL , NIL , 0 , '' , .T. )

return oStructViewField

// ------------------------------------------------------------------
// {Protheus.doc} GridView
// Retorna a estrutura da Grid da Tela para a View
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function gridview()

    local oStructViewGrid := FWformViewStruct():New()
    local cP              := '@E 99,999,999.99'
    
//  Descrição da Solicitação
    oStructViewGrid:AddField( 'PA5_XSTAT'  , '001' , 'Status'           , 'Status'           ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XMATAP' , '002' , 'Matr. Aprovado'   , 'Matr. Aprovado'   ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XAPROV' , '003' , 'Nome Aprovador'   , 'Nome Aprovador'   ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XSEAPV' , '004' , 'Departamento'     , 'Departamento'     ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XUNAPR' , '005' , 'Filial Aprovador' , 'Filial Aprovador' ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XCARAP' , '006' , 'Cargo Aprovador'  , 'Cargo Aprovador'  ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XCODEV' , '007' , 'Cod. Evento'      , 'Cod. Evento'      ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XDESEV' , '008' , 'Des. Evento'      , 'Des. Evento'      ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XEMPEN' , '009' , 'Valor Solicitado' , 'Valor Solicitado' ,NIL , 'GET' , cP   , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XDATA'  , '010' , 'Data'             , 'Data'             ,NIL , 'GET' , '@D' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )
    oStructViewGrid:AddField( 'PA5_XHORA'  , '011' , 'Hora'             , 'Hora'             ,NIL , 'GET' , '@!' , NIL , '' , .T. , NIL , NIL , NIL , 0 , '' , .T. )

return oStructViewGrid

// ----------------------------------------------
//  [ Chamado DOR06434893_TK_6401753 - Ini 2/3 ]
// ----------------------------------------------
// ------------------------------------------------------------------
// {Protheus.doc} TBUTTONUSER
// Função que cria os botões da Tela (Antiga EnchoiceBar)
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------
//
//static function TBUTTONUSER( oPanel , oView )
//
//    local oBtnRP   := NIL
//    local oBtnVP   := NIL
//    local oBtnIP   := NIL
//    local oRadio   := NIL
//    local oBold    := NIL
//    local oModel   := FWModelActive() // Retorna o model ativo.
//    local oMdField := oModel:GetModel( 'FIELD' )
//    local nOpc     := oModel:GetOperation()
//    local nWidth   := oPanel:nCLientWidth / 2
//    local nRec     := PA2->( recno() )
//
//    DEFINE FONT oBold NAME 'Arial' SIZE 0 , -12 BOLD
//
//    oPanel:Align := CONTROL_ALIGN_RIGHT
//    oPanel:oFont := oBold
//	
//    if ! ( PA2->PA2_SIT == 'AG' )
//
////      linha 1
//// --------------------------------------------------------    
////      @ 05,nWidth-460 BUTTON oBtnVP PROMPT "Desistente Docs/Exame" SIZE 90,15 FONT oPanel:oFont ACTION U_F0500206("DesDocsExame"    ,oMdField,oView) OF oPanel PIXEL
////      @ 05,nWidth-350 BUTTON oBtnIP PROMPT "Doc. Inconsistente"    SIZE 90,15 FONT oPanel:oFont ACTION U_F0500206("DocsInconsist"   ,oMdField,oView) OF oPanel PIXEL
////      @ 05,nWidth-240 BUTTON oBtnIP PROMPT "Inapto"                SIZE 90,15 FONT oPanel:oFont ACTION U_F0500206("Inapto"          ,oMdField,oView) OF oPanel PIXEL
////      @ 05,nWidth-130 BUTTON oBtnIP PROMPT "Contrato Assinado"     SIZE 90,15 FONT oPanel:oFont ACTION U_F0500206("AssinaturaContra",oMdField,oView) OF oPanel PIXEL
//// --------------------------------------------------------
//        @ 05 , nWidth - 460 BUTTON oBtnVP PROMPT 'Desistente Docs/Exame' SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'DesDocsExame'     , oMdField , oView , nRec ) OF oPanel PIXEL
//        @ 05 , nWidth - 350 BUTTON oBtnIP PROMPT 'Doc. Inconsistente'    SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'DocsInconsist'    , oMdField , oView , nRec ) OF oPanel PIXEL
//        @ 05 , nWidth - 240 BUTTON oBtnIP PROMPT 'Inapto'                SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'Inapto'           , oMdField , oView , nRec ) OF oPanel PIXEL
//        @ 05 , nWidth - 130 BUTTON oBtnIP PROMPT 'Contrato Assinado'     SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'AssinaturaContra' , oMdField , oView , nRec ) OF oPanel PIXEL
//// --------------------------------------------------------
//
////      linha 2
//// --------------------------------------------------------
//////    @ 25,nWidth-460 BUTTON oBtnIP PROMPT "Historico Motivo"        SIZE 90,15 FONT oPanel:oFont ACTION HistMotiv()                                   OF oPanel PIXEL
////      @ 25,nWidth-460 BUTTON oBtnRP PROMPT "Enc. Célula de Cadastro" SIZE 90,15 FONT oPanel:oFont ACTION U_F0500206("Encaminhamento"  ,oMdField,oView) OF oPanel PIXEL
////      @ 25,nWidth-350 BUTTON oBtnIP PROMPT "Desistente Contrato"     SIZE 90,15 FONT oPanel:oFont ACTION U_F0500206("DesistContrato"  ,oMdField,oView) OF oPanel PIXEL
//// --------------------------------------------------------
////      @ 25 , nWidth - 460 BUTTON oBtnIP PROMPT 'Historico Motivo'        SIZE 90 , 15 FONT oPanel:oFont ACTION HistMotiv()                                              OF oPanel PIXEL
//        @ 25 , nWidth - 460 BUTTON oBtnRP PROMPT 'Enc. Célula de Cadastro' SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'Encaminhamento' , oMdField , oView , nRec ) OF oPanel PIXEL
//        @ 25 , nWidth - 350 BUTTON oBtnIP PROMPT 'Desistente Contrato'     SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'DesistContrato' , oMdField , oView , nRec ) OF oPanel PIXEL
//
//    endif
//
////  @25,nWidth-240 BUTTON oBtnIP PROMPT "Vaga Suspensa"  SIZE 90,15 FONT oPanel:oFont 	ACTION U_F0500206("VagaSuspensa" ,oMdField,oView) OF oPanel PIXEL
////  @25,nWidth-130 BUTTON oBtnIP PROMPT "Vaga Cancelada" SIZE 90,15 FONT oPanel:oFont 	ACTION U_F0500206("VagaCancelada",oMdField,oView) OF oPanel PIXEL
////  @25,nWidth-130 BUTTON oBtnRP PROMPT "Vaga Reaberta"  SIZE 90,15 FONT oPanel:oFont 	ACTION U_F0500206("VagaReaberta" ,oMdField,oView) OF oPanel PIXEL
//
//return
//
// ------------------------------------------------------------------

static function TBUTTONUSER( oPanel , oView )

    local oBtnRP   := NIL
    local oBtnVP   := NIL
    local oBtnIP   := NIL
    local oRadio   := NIL
    local oBold    := NIL
    local oModel   := FWModelActive() // Retorna o model ativo.
    local oMdField := oModel:GetModel( 'FIELD' )
    local nOpc     := oModel:GetOperation()
    local nWidth   := oPanel:nCLientWidth / 2
    local nRec     := PA2->( recno() )

    DEFINE FONT oBold NAME 'Arial' SIZE 0 , -12 BOLD

    oPanel:Align := CONTROL_ALIGN_RIGHT
    oPanel:oFont := oBold
	
    if ! ( PA2->PA2_SIT == 'AG' )
    
        if cStatusPA5 == 'EM EXAME/DOCTO'
            @ 05 , nWidth - 460 BUTTON oBtnVP PROMPT 'Desistente Docs/Exame'   SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'DesDocsExame'     , oMdField , oView , nRec ) OF oPanel PIXEL
            @ 05 , nWidth - 240 BUTTON oBtnIP PROMPT 'Inapto'                  SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'Inapto'           , oMdField , oView , nRec ) OF oPanel PIXEL
            @ 25 , nWidth - 460 BUTTON oBtnRP PROMPT 'Enc. Célula de Cadastro' SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'Encaminhamento'   , oMdField , oView , nRec ) OF oPanel PIXEL        
        endif

        if cStatusPA5 == 'EM CADASTRO'
            @ 05 , nWidth - 350 BUTTON oBtnIP PROMPT 'Doc. Inconsistente'      SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'DocsInconsist'    , oMdField , oView , nRec ) OF oPanel PIXEL
//          @ 25 , nWidth - 460 BUTTON oBtnRP PROMPT 'Enc. Célula de Cadastro' SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'Encaminhamento'   , oMdField , oView , nRec ) OF oPanel PIXEL
        endif
    
        if cStatusPA5 == 'EM ASS.CONTRATO'
            @ 05 , nWidth - 130 BUTTON oBtnIP PROMPT 'Contrato Assinado'       SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'AssinaturaContra' , oMdField , oView , nRec ) OF oPanel PIXEL
            @ 25 , nWidth - 350 BUTTON oBtnIP PROMPT 'Desistente Contrato'     SIZE 90 , 15 FONT oPanel:oFont ACTION u_f0500206( 'DesistContrato'   , oMdField , oView , nRec ) OF oPanel PIXEL
        endif

    endif

return
// ----------------------------------------------
//  [ Chamado DOR06434893_TK_6401753 - Fim 2/3 ]
// ----------------------------------------------
// ------------------------------------------------------------------

// ------------------------------------------------------------------
// {Protheus.doc} ExecQuery
// Cria e abre o Alias Temporario para que seja utilizado nos blocos de Load da View e do Model
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function execquery()

    local cQuery := ''

    cQuery += "     SELECT PA5.R_E_C_N_O_ RECNO , " + CRLF
    cQuery += "            PA5.PA5_XNRSOL       , " + CRLF
    cQuery += "            PA5.PA5_XDESOL       , " + CRLF
    cQuery += "            PA5.PA5_XUNIDA       , " + CRLF
    cQuery += "            PA5.PA5_XCODEV       , " + CRLF
    cQuery += "            PA5.PA5_XDESEV       , " + CRLF
    cQuery += "            PA5.PA5_FUNCAO       , " + CRLF
    cQuery += "            PA5.PA5_XMAT         , " + CRLF
    cQuery += "            PA5.PA5_XNOME        , " + CRLF
    cQuery += "            PA5.PA5_XSETOR       , " + CRLF
    cQuery += "            PA5.PA5_XCARGO       , " + CRLF
    cQuery += "            PA5.PA5_XMATAP       , " + CRLF
    cQuery += "            PA5.PA5_XAPROV       , " + CRLF
    cQuery += "            PA5.PA5_XSEAPV       , " + CRLF
    cQuery += "            PA5.PA5_XUNAPR       , " + CRLF
    cQuery += "            PA5.PA5_XCARAP       , " + CRLF
    cQuery += "            PA5.PA5_XCC          , " + CRLF
    cQuery += "            PA5.PA5_XCONTA       , " + CRLF
    cQuery += "            PA5.PA5_XSTAT        , " + CRLF
    cQuery += "            PA5.PA5_XEMPEN       , " + CRLF
    cQuery += "            PA5.PA5_XDATA        , " + CRLF
    cQuery += "            PA5.PA5_XHORA          " + CRLF
    cQuery += "       FROM " + retsqlname( 'PA5' ) + " PA5 " + CRLF
    cQuery += " INNER JOIN " + retsqlname( 'PA2' ) + " PA2 " + CRLF
    cQuery += "         ON PA2.PA2_SOL    = PA5_XNRSOL "     + CRLF
    cQuery += "        AND PA2.D_E_L_E_T_ = ''         "     + CRLF
    cQuery += "      WHERE PA5.PA5_FILIAL = '" + PA2->PA2_FILIAL + "' " + CRLF
    cQuery += "        AND PA5.PA5_XNRSOL = '" + PA2->PA2_SOL    + "' " + CRLF
    cQuery += "        AND PA5.D_E_L_E_T_ = '' "                        + CRLF
    if select( cAliasPA5 ) <> 0
        (cAliasPA5)->( dbclosearea() )
    endif
    cQuery := ChangeQuery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasPA5 , .T. , .T. )

return

// ------------------------------------------------------------------
// {Protheus.doc} CargaField
// Carrega e retorna os dados da Field
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function cargafield( oModel )

    local aResult := {}
    local oView

    execquery() // Abre o arquivo temporário

    dbselectarea( cAliasPA5 )
    (cAliasPA5)->( dbgotop() )

    aadd( aResult , {} )
    aadd( aResult , 1  )

    if (cAliasPA5)->(! eof() )

        aResult[1] := { (cAliasPA5)->(PA5_XUNIDA) , ;
                        (cAliasPA5)->(PA5_XNRSOL) , ;
                        (cAliasPA5)->(PA5_XDESOL) , ;
                        (cAliasPA5)->(PA5_FUNCAO) , ;
                        (cAliasPA5)->(PA5_XMAT  ) , ;
                        (cAliasPA5)->(PA5_XNOME ) , ;
                        (cAliasPA5)->(PA5_XSETOR) , ;
                        (cAliasPA5)->(PA5_XCARGO) , ;
                        (cAliasPA5)->(PA5_XCC   )   }
    else
        aResult[1] := { '' , '' , '' , '' , '' , '' , '' , '' , '' }
    endif

return aResult

// ------------------------------------------------------------------
// {Protheus.doc} CargaGrid
// Carrega e retorna os dados do Modelo
// @author Fernando Carvalho
// @since 11/11/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function cargagrid( oModel )

    local aResult := {}
    local nLoop   := 0

    dbselectarea( cAliasPA5 )
    (cAliasPA5)->( dbgotop() )

    aResult := FwLoadByAlias( oModel , cAliasPA5 )

    for nLoop := 1 to len( aResult )
        aResult[nLoop,2,10] := stod( aResult[nLoop,2,10] )
    next nLoop

// ----------------------------------------------
//  [ Chamado DOR06434893_TK_6401753 - Ini 3/3 ]
// ----------------------------------------------
    cStatusPA5 := alltrim( aResult[len(aResult)][2][8] )
// ----------------------------------------------
//  [ Chamado DOR06434893_TK_6401753 - Fim 3/3 ]
// ----------------------------------------------

return aResult

// ------------------------------------------------------------------
// [ Função para encerrar a Grid ]
// ------------------------------------------------------------------

static function sair()
    local oView := FwViewActive()
    (cAliasPA5)->( dbclosearea() )
    oView:ButtonCancelAction() // Necessário para encerrar a View
return

// ------------------------------------------------------------------
// {Protheus.doc} ValidModel
// Valida se existe informações para serem exibidas na View
// @author Fernando Carvalho
// @since 14/12/2016
// @version 12.7
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function validmodel()

    local lRet := .F.

    execquery() // Abre o arquivo temporário
    dbselectarea( cAliasPA5 )
    (cAliasPA5)->(dbgotop() )

    if (cAliasPA5)->(! eof() )
        lRet := .T.
    else
//      Alert( 'Não há indicadores para ser exibido.' )
        help( '' , 1 , 'Help' , 'Sem registro na PA5' , 'Não há indicador para ser exibido.' , 3 , 0 )
    endif

return lRet

// ------------------------------------------------------------------

user function stsvaga()

    local cRet    := ''
    local cStatus := ''

    cStatus := posicione( 'SQS' , 1 , PA2->PA2_FILIAL + PA2->PA2_CDVAGA,  'QS_XSTATUS' )

//  Jamer Nunes Pedroso - 20/05/2017
    cRet := u_f0200327( cStatus )

// 1=Aprovada;2=Em Recrutamento;3=Em Movimentação (RI);4=Em Admissão;5=Cancelada;6=Suspensa;7=Concluída  

// ------
//  Do Case
//      Case cStatus == '1'
//          cRet := 'Aprovada'
//      Case cStatus == '2'
//          cRet := 'Em Recrutamento'
//      Case cStatus == '3'
//          cRet := 'Em Movimentação (RI)'
//      Case cStatus == '4'
//          cRet := 'Em Admissão'
//      Case cStatus == '5'
//          cRet := 'Cancelada'
//      Case cStatus == '6'
//          cRet := 'Suspensa'
//      Case cStatus == '7'
//          cRet := 'Concluída'	
//      OtherWise
//          cRet := ''
//  EndCase
// ------

return cRet

//-------------------------------------------------------------------
// [ fim de f0500203.prw ]
//-------------------------------------------------------------------
