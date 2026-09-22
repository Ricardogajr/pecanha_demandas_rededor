#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} F0701001
Cadastro BRASINDICE
@author izac.ciszevski
@since 27/12/2016
@Project MAN0000007423041_EF_010
/*/
User Function F0701001()
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('P14')
	oBrowse:SetDescription('Cadastro BRASINDICE')
	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	
	//ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.F0701001' OPERATION 2 ACCESS 0
		aRotina:={{"Visualizar"					,'VIEWDEF.F0701001'				,0,1}}
Return aRotina

Static Function ModelDef()
	Local oStruMod := FWFormStruct(1, 'P14')
	Local oModel   := MPFormModel():New('M0701001') //Model com 7 caracteres

	oModel:AddFields('MASTER', , oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Cadastro BRASINDICE')
	oModel:GetModel('MASTER'):SetDescription('Cadastro BRASINDICE')
Return oModel

Static Function ViewDef()
	Local oModel 	:= FWLoadModel('F0701001')
	Local oStruView := FWFormStruct(2, 'P14')
	Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
Return oView
