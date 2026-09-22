#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} F0700002
Monitor Integração Log de Entrada
@author Alex Sandro 
@since 27/12/2016
@param cFiltro, caracter, filtro de browse
@Project MAN0000007423041_EF_000 - Log de Entrada
/*/
User Function F0700002(cFiltro)
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias('P19')
	oBrowse:SetDescription('Monitor Integração Log de Entrada')
	oBrowse:AddLegend( "P19_STATUS == '1'", "YELLOW", "Criado"  )
	oBrowse:AddLegend( "P19_STATUS == '2'", "GREEN", "Sucessso"  )
	oBrowse:AddLegend( "P19_STATUS == '3'", "RED", "Falha"  )
    oBrowse:SetMenuDef("F0700002")
	
	If ! cFiltro == NIL
		oBrowse:SetFilterDefault ( cFiltro )
	EndIf
	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.F0700002' OPERATION 2 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oStruMod 	:= FWFormStruct(1,'P19')
	Local oModel	:= MPFormModel():New('M0700002') //Model com 7 caracteres

	oModel:AddFields('MASTER',, oStruMod)
	oModel:SetPrimaryKey({})
	oModel:SetDescription('Monitor Integração Log de Entrada')
	oModel:GetModel('MASTER'):SetDescription('Monitor Integração Log de Entrada')
Return oModel

Static Function ViewDef()
	Local oModel 	:= FWLoadModel('F0700002')
	Local oStruView := FWFormStruct(2,'P19')
	Local oView		:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW_MASTER', 'SUPERIOR')
Return oView
