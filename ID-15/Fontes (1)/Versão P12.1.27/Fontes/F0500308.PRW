#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0500308()
Solicitação de Incentivo Acadêmico
@Author     Henrique Madureira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_003
@Menu		 SIGATRM - Treinamento
@Param
@Return
*/
User Function F0500308()
	
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PA7')
	oBrowse:SetDescription('Controle Solicitação Portal')
	oBrowse:Activate()
	
Return

Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE '&Incluir'    ACTION 'VIEWDEF.F0500308' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE '&Alterar'    ACTION 'VIEWDEF.F0500308' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0500308' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE '&Excluir'    ACTION 'VIEWDEF.F0500308' OPERATION 5 ACCESS 0
	
Return aRotina


Static Function ModelDef()
	
	Local oStruPA7 := FWFormStruct( 1, 'PA7', /*bAvalCampo*/,.F. )
	Local oModel
	
	oModel := MPFormModel():New('F01003', ,{|oModel| MontAlt(oModel) } ,  , /*bCancel*/ )
	oModel:AddFields( 'PA7MASTER', /*cOwner*/, oStruPA7, , /*{|| MontAlt(oModel) }*/, /*bCarga*/ )
	oModel:SetDescription( 'Controle Solicitação Portal' )
	oModel:SetPrimaryKey({"PA7_CODIGO"})
	oModel:GetModel( 'PA7MASTER' ):SetDescription( 'Solicitação Portal' )
	
Return oModel

//============================================================================================

Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'F0500308' )
	Local oStruPA7 := FWFormStruct( 2, 'PA7' )
	Local oView
	Local cCampos := {}
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_PA7', oStruPA0, 'PA7MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_PA7', 'TELA' )
	
Return oView

//============================================================================================
