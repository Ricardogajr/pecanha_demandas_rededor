 /*/{Protheus.doc} XCADP34
@Description - Função de cadastro dos limites de multa/juros na tabela P35
@type  Function
@author Lucas Miranda
@since 22/07/2021
@version 1.0
/*/
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function XCADP35()

	Local oBrowse := FWmBrowse():New()

	oBrowse:SetAlias("P35")
	oBrowse:SetMenuDef("XCADP35")
	oBrowse:SetDescription("Valor limite Multa/Juros")
	oBrowse:Activate()

Return NIL

Static Function MenuDef()

Return FWMVCMenu("XCADP35")


Static Function ModelDef()

	Local oStru := FwFormStruct(1, "P35")

	oStru:RemoveField('P35_FILIAL')

	oModel := MPFormModel():New('MXCADP35',,,)
	oModel:AddFields('P35MASTER', , oStru, , , )
	oModel:SetDescription('Valor limite Multa/Juros')
	oModel:GetModel('P35MASTER'):SetDescription('Valor limite Multa/Juros')
	oModel:GetModel("P35MASTER"):SetPrimaryKey({"P35_FILIAL"})


Return oModel


Static Function ViewDef()

	Local oModel   	:= FWLoadModel('XCADP35')
	Local oStru 	:= FwFormStruct(2, "P35")
	Local oView		:= Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_P35', oStru, 'P35MASTER')
	oView:CreateHorizontalBox('TELA' , 100)
	oView:SetOwnerView('VIEW_P35', 'TELA')

Return oView
