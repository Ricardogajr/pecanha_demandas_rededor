#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#DEFINE K_SH_F5       -14   //   Shift-F5
/*/{Protheus.doc} SUPRIM01
    
    Tela de monitoramento dos Grupos x Filiais
	
    @type Function - User function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 1.0
	@example
	u_SUPRIM01()
/*/
User Function SUPRIM01()
    Local cTitulo := "Grupos x Filiais"
    Local aArea   := FWGetArea()
    Local oBrowse

    If ! ( CHKFILE ("P42") .And. CHKFILE ("P43") )
        MsgAlert("Atenção, Existe um erro no dicionario nas tabelas P42, P43 !")
        Return .F.
    EndIf

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de GRUPOS de Picking
    oBrowse:SetAlias("P42")

    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas1
    oBrowse:AddLegend( "P42->P42_ATIVO == 'S'", "GREEN",	"S=Ativo"   ,"1")
    oBrowse:AddLegend( "P42->P42_ATIVO == 'N'", "RED"  ,	"N=Inativo" ,"1")

    //Ativa a Browse
    oBrowse:Activate()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} MenuDef
	Criação do menu MVC
	@type Function - Static Function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function MenuDef()
    Local aRot := {}

    //Adicionando opções
    aadd(aRot,{"Visualizar","VIEWDEF.SUPRIM01",0,2})  //ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.SUPRIM01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    aadd(aRot,{"Alterar","VIEWDEF.SUPRIM01",0,4})  //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.SUPRIM01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4

Return aRot
/*/{Protheus.doc} ModelDef
	Criação do modelo de dados MVC
	@type Function - Static Function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function ModelDef()
    Local oModel 		:= Nil
    Local oStPai 		:= FWFormStruct(1, 'P42') // Cabeçalho - Ean Picking
    Local oStFilho		:= FWFormStruct(1, 'P43') // Itens da Coleta
    Local aP43Rel		:= {}
    Local bLinePost		:= { |oModelGrid| P43LINPOS(oModelGrid) }
    //Blocos de código nas validações
    Local bP43VldPos := {|| P43Pos() } //Validação ao clicar no Confirmar

    //Definições dos campos
    oStPai:SetProperty('P42_ATIVO', MODEL_FIELD_WHEN,  FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                        //Modo de Edição
    oStPai:SetProperty('P42_DESCR', MODEL_FIELD_WHEN,  FwBuildFeature(STRUCT_FEATURE_WHEN,    'INCLUI')) 
    oStFilho:SetProperty('P43_GRUPO', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'u_IniGrupo()'))
    oStFilho:SetProperty('P43_USRIID', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'RETCODUSR()'))
    oStFilho:SetProperty('P43_USRIID', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'RETCODUSR()'))
    oStFilho:SetProperty('P43_USRINO', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'USRRETNAME(RETCODUSR())'))
    oStFilho:SetProperty('P43_USRIDT', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'DDATABASE'))
    oStFilho:SetProperty('P43_USRIHR', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'TIME()'))

    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('MMSUPRIM01' ,/*bP42VldPre*/ ,/*bP42VldPos*/ , /*bP42VldCom*/ , /*bP42VldCan*/  )
    oModel:AddFields('MD_P42MASTER', ,oStPai) 
    oModel:AddGrid('MD_P43DETAIL','MD_P42MASTER',oStFilho,/*bLinePre*/ , bLinePost, /*bPreVal*/, bP43VldPos/*bPosVal*/, /*BLoad*/ )

    //Fazendo o relacionamento entre o Filho e Pai
    aAdd(aP43Rel, {'P43_FILIAL','P42_FILIAL'})
    aAdd(aP43Rel, {'P43_GRUPO' ,'P42_GRUPO'})

    //Monta os dados dos itens
    oModel:SetRelation('MD_P43DETAIL', aP43Rel, P43->(IndexKey(1)))            //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel('MD_P43DETAIL'):SetUniqueLine({"P43_FILIAL","P43_GRUPO","P43_FILAUT"})   //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})                                                                                                                                                                                                                      

    //Setando as descrições
    oModel:SetDescription("Grupos - P42 x P43 - Itens - Operador: " + cUserName )
    oModel:GetModel('MD_P42MASTER'):SetDescription('Grupos')
    oModel:GetModel('MD_P43DETAIL'):SetDescription('Filiais')

Return oModel
/*/{Protheus.doc} ViewDef
	Criação da visão MVC
	@type Function - Static Function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function ViewDef()
    Local oView		:= Nil
    Local oModel	:= FWLoadModel('SUPRIM01')
    Local oStPai	:= FWFormStruct(2, 'P42')
    Local oStFilho	:= FWFormStruct(2, 'P43')

    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_P42',oStPai,'MD_P42MASTER')
    oView:AddGrid('VIEW_P43',oStFilho,'MD_P43DETAIL')

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('BOX_SUPERIOR',30)
    oView:CreateHorizontalBox('BOX_GRID1',70)

    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_P42','BOX_SUPERIOR')
    oView:SetOwnerView('VIEW_P43','BOX_GRID1')

    //Habilitando título
    oView:EnableTitleView('VIEW_P42','Grupo de Filias')
    oView:EnableTitleView('VIEW_P43','Filias')

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

    //Filtro no Grid do tipo Filho em MVC
    oView:SetViewProperty("VIEW_P43", "GRIDFILTER", {.T.})

    //Botão de legenda
    oView:AddUserButton( 'Legenda do grid'        , 'Legendas'        , {|oView| TT002()} )
    oView:AddUserButton( 'Refresh Shift + F5'     , 'Refresh do grid' , {|oView| TT004()} )

    //Botão de legenda
    oView:SetViewProperty("VIEW_P43", "GRIDDOUBLECLICK", {{|| .T.}})

    //Remove os campos de Código
    oStPai:RemoveField('P42_OK')

    SetKey(K_SH_F5,  { || TT004() })     //Shift + F5

Return oView
/*/{Protheus.doc} TT002
	Legenda do grid Splash
	@type Function - Static Function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 12.1.2210
/*/
Static Function TT002()

    // Cria a legenda que identifica a estrutura
    oLegend := FWLegend():New()

    // Adiciona descrição para cada legenda
    oLegend:Add( { || }, 'BR_VERDE'    , 'Status Item = S , Ativo e será conciderado no contrato' )
    oLegend:Add( { || }, 'BR_VERMELHO' , 'Status Item = N , Inativo e não será conciderado no contrato' )   

    // Ativa a Legenda
    oLegend:Activate()

    // Exibe a Tela de Legendas
    oLegend:View()

Return
/*/{Protheus.doc} TT004
	Refresh do grid
	@type Function - Static Function
	@author Cleiton Genuino
	@since 02/07/2020
	@version 1.0
/*/
Static Function TT004()

    Local oView      := FwViewActive()
    Local oModel     := FwModelActive()
    Local oModelGrid := oModel:GetModel( "MD_P43DETAIL" )
    Local nLine      := oModelGrid:GetLine()
    Local nOpc       := oModel:GetOperation()

    If nOpc == MODEL_OPERATION_VIEW
        oView:Refresh('VIEW_P43')
        FWMsgRun( , {|oSay| XTT004(oSay,oModel,oView,oModelGrid,nLine) }, "Processando", "Aguarde...")
    ENDIF

Return nil
/*/{Protheus.doc} XTT004
    Função Static de refresh linha DeActivate
    @type function
    @author Cleiton Genuino
    @since 08/06/2020
    @version 1.0
/*/
Static Function XTT004(oSay,oModel,oView,oModelGrid,nLine)
    If oModel != nil .and. oModel:IsActive() .And. nLine > 0

        oModel:DeActivate()
        oSay:cCaption := "Aguarde refresh linha DeActivate"

        oModel:Activate()
        oView:Refresh('VIEW_P43')
        oModelGrid:SetLine(nLine)
        oSay:cCaption := "Aguarde refresh linha Activate"
    EndIf
Return nil
/*/{Protheus.doc} P43LINPOS
    Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
    @type function
    @author Cleiton Genuino
    @since 08/06/2020
    @version 1.0
/*/
Static Function P43LINPOS(oModelP43)
    Local cProblem   := ''
    Local cSolucao   := ''
    Local aArea      := FWGetArea()     
	Local oModel	:= FWModelActive()
    Local oModelPad  := oModel:GetModel("MD_P42MASTER") //FWModelActive()                
    Local cMdAtivo   := oModelPad:GetValue( 'P42_ATIVO' ) //as charater
    Local cGridAtivo := oModelP43:GetValue( 'P43_ATIVO' )   //               as charater
    Local cFilAut    := oModelP43:GetValue( 'P43_FILAUT' )    //             as charater
    Local cGrupo     := oModelP43:GetValue( 'P43_GRUPO' )       //           as charater
    Local lRet       := .T.                                       //         as logical

    If !oModelP43:IsDeleted() .And. cMdAtivo == 'S'
        P43->(DBSetOrder(3)) // P43_FILIAL + P43_FILAUT
        IF P43->(DBSeek(  xFilial('P43') + cFilAut )) .And. P43->P43_ATIVO == 'S' .And. cGridAtivo == 'S'
            lRet := .F.  
             cProblem := "A filial " + cFilAut + " já existe no grupo "+ P43->P43_GRUPO + CRLF
             cProblem += " e está ativo, somente um grupo pode conter a filial " + cFilAut + " ativo ! " + CRLF + CRLF
             cSolucao := " Desative a Filial no grupo " + Alltrim(P43->P43_GRUPO) + CRLF
             cSolucao +=  " e logo após ative a filial no grupo " + cGrupo + CRLF 
             oModelP43:GetModel():SetErrorMessage( , ,oModelP43:GetId(),'P43_FILAUT','P43_FILAUT', cProblem , cSolucao ) // FwHelpShow('SUPRIM01','P43_FILAUT',cProblem,cSolucao)
        EndIf
    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} IniGrupo
    
    Função que inicia o código sequencial da grid

    @type Function - Static Function
    @author Cleiton Genuino
    @since 12/05/2023
    @version 12.1.2210
/*/
User Function IniGrupo()
	Local aArea      := FWGetArea()
	Local oModelPad  := FWModelActive()
	Local nOpc       := oModelPad:GetOperation()
    Local cGrupo     := oModelPad:GetValue('MD_P42MASTER','P42_GRUPO') 

	If nOpc == MODEL_OPERATION_VIEW
		nTextOpc := 'visualizar'
	ElseIf nOpc == MODEL_OPERATION_INSERT
		nTextOpc := 'incluir'        
	ElseIf nOpc == MODEL_OPERATION_UPDATE
		nTextOpc := 'alterar'
	ElseIf nOpc == MODEL_OPERATION_DELETE
		nTextOpc := 'excluir'
	EndIF

	RestArea(aArea)

Return cGrupo
/*/{Protheus.doc} P43Pos
	Função chamada após validar o ok da rotina para os dados serem salvos
	@type Function - Static function
	@author Cleiton Genuino
	@since 12/05/2023
	@version 1.0
/*/
Static Function P43Pos()
	Local oModelPad  := FWModelActive()
	Local nOpc       := oModelPad:GetOperation()
	Local lRet       := .T.
	Local nTextOpc   := ""

	If nOpc == MODEL_OPERATION_VIEW
		nTextOpc := 'visualizar'
	ElseIf nOpc == MODEL_OPERATION_INSERT
		nTextOpc := 'incluir'
	ElseIf nOpc == MODEL_OPERATION_UPDATE
		nTextOpc := 'alterar'
		oModelPad:SetValue('MD_P43DETAIL',"P43_USRAID", RETCODUSR() ) 
		oModelPad:SetValue('MD_P43DETAIL',"P43_USRANO", USRRETNAME(RETCODUSR()) )
		oModelPad:SetValue('MD_P43DETAIL',"P43_USRADT", DATE() ) 
		oModelPad:SetValue('MD_P43DETAIL',"P43_USRAHR", SubStr( time(),1,5) ) 
	ElseIf nOpc == MODEL_OPERATION_DELETE
		nTextOpc := 'excluir'
	EndIF

Return lRet
