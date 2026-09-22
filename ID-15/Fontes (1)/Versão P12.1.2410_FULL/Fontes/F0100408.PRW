#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0100408
Tela de Tipo de Requisição.
@author 	alexandre.arume
@since 		18/08/2016
@Project	MAN00000462901_EF_004
/*/
User Function F0100408()

	Local oBrowse := FWmBrowse():New()

	oBrowse:SetAlias("P02")
	oBrowse:SetMenuDef("F0100408")
	oBrowse:SetDescription("Tipo de Requisição")
	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
@author 	alexandre.arume
@since 		18/08/2016
@Project	MAN00000462901_EF_004
/*/
Static Function MenuDef()

Return FWMVCMenu("F0100408")

/*/{Protheus.doc} ModelDef
@author 	alexandre.arume
@since 		18/08/2016
@version 	1.0
@Project	MAN00000462901_EF_004
/*/
Static Function ModelDef()

	Local oStru := FwFormStruct(1, "P02")

	oStru:RemoveField('P02_FILIAL')

	oModel := MPFormModel():New('M0100408', { |oModel| F0100408A( oModel ) }, , , )
	oModel:AddFields('P02MASTER', , oStru, , , )
	oModel:SetDescription('Tipo de Requisição')
	oModel:GetModel('P02MASTER'):SetDescription('Dados do Tipo de Requisição')
	oModel:GetModel("P02MASTER"):SetPrimaryKey({"P02_FILIAL", "P02_COD"})

Return oModel


/*/{Protheus.doc} ViewDef
@author 	alexandre.arume
@since 		18/08/2016
@Project	MAN00000462901_EF_004
/*/
Static Function ViewDef()

	Local oModel   	:= FWLoadModel('F0100408')
	Local oStru 	:= FwFormStruct(2, "P02")
	Local oView		:= Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_P02', oStru, 'P02MASTER')
	oView:CreateHorizontalBox('TELA' , 100)
	oView:SetOwnerView('VIEW_P02', 'TELA')

Return oView


/*/{Protheus.doc} F0100408A
Atualização dos campos de integração Onergy
@author 	Jean.Silvano
@since 		02/10/2024
@Project	MAN00000462901_EF_004
/*/
Static Function F0100408A(oModel)
	Local _aArea := GetArea()
	Local _lRet := .T.
	Local oHeadModel := oModel:GetModel( 'P02MASTER' )
    Local IS_INSERT   := oModel:GetOperation() == MODEL_OPERATION_INSERT
    Local IS_UPDATE   := oModel:GetOperation() == MODEL_OPERATION_UPDATE

	if IS_INSERT .OR. IS_UPDATE
		oHeadModel:SetValue("P02_ZONERG", .T. )
		oHeadModel:SetValue("P02_ZINTOG", "1" )
	Endif

	RestArea(_aArea)

Return(_lRet)
