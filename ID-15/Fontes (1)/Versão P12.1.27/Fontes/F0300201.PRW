#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TopConn.ch'
#Include 'Report.Ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} F0300201

Cadastro de Plano de Açõe Pesquisa de Clima

@author Everson S P Junior
@since 12/07/2016
@version P12.7
@Project MAN0000004_EF_002

/*/
//--------------------------------------------------------------------
User Function F0300201()
	Local oBrowse
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'PA4' )
	oBrowse:SetDescription( 'Controle de Pesquisa de Clima' )
	oBrowse:AddLegend("PA4_XSTART == '1'", "GREEN",  "Iniciado")
	oBrowse:AddLegend("PA4_XSTART == '2'", "YELLOW", "Suspenso")
	oBrowse:AddLegend("PA4_XSTART == '3'", "Red",    "Cancelado")
	oBrowse:AddLegend("PA4_XSTART == '4'", "Blue",   "Concluido")
	oBrowse:Activate()
	
Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Consultar'  Action 'VIEWDEF.F0300201' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.F0300201' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.F0300201' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.F0300201' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.F0300201' OPERATION 9 ACCESS 0
	ADD OPTION aRotina Title 'Relatorio'  Action 'U_F0300202'       OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE '&Legenda'   ACTION 'U_F0300207'       OPERATION 6 ACCESS 0
	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cadastro de Plano de Açõe Pesquisa de Clima

@author Everson S P Junior
@since 12/07/2016
@version P12.7
@Project MAN0000004_EF_002

/*/
//--------------------------------------------------------------------
Static Function ModelDef()
	Local oStruPA4 := FWFormStruct( 1, 'PA4', /*bAvalCampo*/, /*lViewUsado*/ )
	
	//oStruPA4:RemoveField( 'PA4_FILIAL' )
	
	oModel := MPFormModel():New( 'MF0300201', /*bPreValidacao*/,{|oModel|TudoOk(oModel)}, /*bCommit*/, /*bCancel*/ )
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'PA4MASTER', /*cOwner*/, oStruPA4, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Modelo de Dados de Autor/Interprete' )
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'PA4MASTER' ):SetDescription( 'Controle de Pesquisa de Clima' )
	oModel:SetPrimaryKey( { "PA4_FILIAL","PA4_XCOD","DTOS(PA4_XDTIN)"   } )
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cadastro de Plano de Açõe Pesquisa de Clima

@author Everson S P Junior
@since 12/07/2016
@version P12.7
@Project MAN0000004_EF_002

/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'F0300201' )
	Local oStruPA4 := FWFormStruct( 2, 'PA4' )
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_PA4', oStruPA4, 'PA4MASTER' )
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_PA4', 'TELA' )
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} TudoOk

Tudo ok Cadastro de Plano de Açõe Pesquisa de Clima

@author Everson S P Junior
@since 12/07/2016
@version P12.7
@Project MAN0000004_EF_002

/*/
//--------------------------------------------------------------------
Static Function TudoOk(oMdl)
	Local lRet 		:= .T.
	Local nOperation:= oMdl:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		If PA4->(DbSeek(xFilial("PA4") + oMdl:GetValue("PA4MASTER","PA4_XCOD") + dTos(oMdl:GetValue("PA4MASTER","PA4_XDTIN"))))
			lRet := .F.
			Help( ,, 'Help',, 'Registro já existe! (Filial, Cod.Pesquisa e Data Inicio.)', 1, 0 )
		EndIf
	EndIf
	
Return lRet
