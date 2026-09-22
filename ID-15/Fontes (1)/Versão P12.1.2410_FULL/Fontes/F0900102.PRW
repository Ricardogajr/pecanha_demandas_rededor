#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0900102()
Cadastro de amarração de grupo de comrpas x tipo de produtos
@Author     Alex Sandro Valario
@Since      12/05/2017
@project MAN0000007423043_EF_001
@Menu	Grupo de compras x tipo de produtos	 
@Return
*/
User Function F0900102()
	
	Local oBrowse 
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('P21')
	oBrowse:SetDescription('Grupo de compras x tipo de produtos')
	oBrowse:Activate()
	
Return

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE '&Incluir'    ACTION 'VIEWDEF.F0900102' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE '&Alterar'    ACTION 'VIEWDEF.F0900102' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0900102' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE '&Excluir'    ACTION 'VIEWDEF.F0900102' OPERATION 5 ACCESS 0
	
Return aRotina


Static Function ModelDef()
	
	Local oStruP21 := FWFormStruct( 1, 'P21', /*bAvalCampo*/,.F. )
	Local oModel
	
	oModel := MPFormModel():New('F09001', , ,  , /*bCancel*/ )
	oModel:AddFields( 'P21MASTER', /*cOwner*/, oStruP21, , , /*bCarga*/ )
	oModel:SetDescription( 'Grupo de compras x tipo de produtos' )
	oModel:SetPrimaryKey({"P21_TPPRD","P21_GRCOM"})
	oModel:GetModel( 'P21MASTER' ):SetDescription( 'Grupo de compras x tipo de produtos' )
	
Return oModel

//============================================================================================

Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'F0900102' )
	Local oStruP21 := FWFormStruct( 2, 'P21' )
	Local oView
	Local cCampos := {}
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_P21', oStruP21, 'P21MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_P21', 'TELA' )
	
Return oView

//============================================================================================
