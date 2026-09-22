#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} F0701301
Cadastro SIMPRO
@author izac.ciszevski
@since 27/12/2016
@Project MAN0000007423041_EF_13
/*/
User Function F0701301()
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('P16')
	oBrowse:SetDescription('Cadastro SIMPRO')
	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.F0701301' OPERATION 2 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oStruMod := FWFormStruct(1, 'P16')
	Local oModel   := MPFormModel():New('M0701301') //Model com 7 caracteres

	oModel:AddFields('MASTER', , oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Cadastro SIMPRO')
	oModel:GetModel('MASTER'):SetDescription('Cadastro SIMPRO')
Return oModel

Static Function ViewDef()
	Local oModel 	:= FWLoadModel('F0701301')
	Local oStruView := FWFormStruct(2, 'P16')
	Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
Return oView