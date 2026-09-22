#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} F0701601
Cadastro TUSS
@author izac.ciszevski
@since 27/12/2016
@Project MAN0000007423041_EF_13
/*/
User Function F0701601()
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('P15')
	oBrowse:SetDescription('Cadastro TUSS')
	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	
	//ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.F0701601' OPERATION 2 ACCESS 0
	aRotina:={{"Visualizar"						,'VIEWDEF.F0701601'					,0,1}}

Return aRotina

Static Function ModelDef()
	Local oStruMod := FWFormStruct(1, 'P15')
	Local oModel   := MPFormModel():New('M0701601') //Model com 7 caracteres

	oModel:AddFields('MASTER',, oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Cadastro TUSS')
	oModel:GetModel('MASTER'):SetDescription('Cadastro TUSS')
Return oModel

Static Function ViewDef()
	Local oModel 	:= FWLoadModel('F0701601')
	Local oStruView := FWFormStruct(2, 'P15')
	Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
Return oView
