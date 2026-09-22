#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} F0700101
Cadastro de Setores
@type 		function
@author 	alexandre.arume
@since 		17/01/2017
@version 	1.0
@project	MAN000007423041_EF_001
@return ${return}, ${return_description}

/*/
User Function F0700101()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('P11')
	oBrowse:SetDescription('Cadastro de Setores')
	oBrowse:Activate()

Return Nil


/*/{Protheus.doc} MenuDef
Menu de op��es
@type 		function
@author 	alexandre.arume
@since 		17/01/2017
@version 	1.0
@project	MAN000007423041_EF_001
@return 	aRotina, Array com as op��es.
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0700101' OPERATION 2 ACCESS 0

	//Aadd(aRot , {"Visualizar"    , "VIEWDEF.F0700101"        , 0, 2})

Return aRotina


/*/{Protheus.doc} ModelDef
Defini��o do modelo.
@type 		function
@author 	alexandre.arume
@since 		17/01/2017
@version 	1.0
@project	MAN000007423041_EF_001
@return 	oModel, Modelo de dados
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruP11 	:= FWFormStruct( 1, 'P11', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= Nil

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('F01001M', { |oModel| F0700101A( oModel) }, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( 'P11MASTER', /*cOwner*/, oStruP11, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Modelo de Dados de Setor' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'P11MASTER' ):SetDescription( 'Dados de Setor' )

	oModel:SetPrimaryKey( {"P11_FILIAL", "P11_COD"} )

Return oModel

/*/{Protheus.doc} ViewDef
View da tela de Cadastro de Setores.
@type 		function
@author 	alexandre.arume
@since 		17/01/2017
@version 	1.0
@project	MAN000007423041_EF_001
@return 	oView, Objeto da view
/*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   	:= FWLoadModel( 'F0700101' )
	// Cria a estrutura a ser usada na View
	Local oStruP11 	:= FWFormStruct( 2, 'P11' )
	Local oView		:= Nil
	Local cCampos 	:= {}

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_P11', oStruP11, 'P11MASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_P11', 'TELA' )

Return oView


/*/{Protheus.doc} F0700101A
Atualiza��o dos campos de integra��o Onergy
@author 	Jean.Silvano
@since 		02/10/2024
@Project	MAN00000462901_EF_004
/*/
Static Function F0700101A(oModel)
	Local _aArea := GetArea()
	Local _lRet := .T.
	Local oHeadModel := oModel:GetModel( 'P11MASTER' )
    Local IS_INSERT   := oModel:GetOperation() == MODEL_OPERATION_INSERT
    Local IS_UPDATE   := oModel:GetOperation() == MODEL_OPERATION_UPDATE

	if IS_INSERT .OR. IS_UPDATE
		oHeadModel:SetValue("P11_ZONERG", .T. )
		oHeadModel:SetValue("P11_ZINTOG", "1" )
	Endif

	RestArea(_aArea)

Return(_lRet)
