#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0201402()
Rotina que cria a tela de visualização do log de alteração
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Return
*/
User Function F0201402()
	
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PA1')
	oBrowse:SetDescription('Log Alterações Cad. Contraindícados' )
	oBrowse:AddLegend( "PA1_XTIPO == '1'", "GREEN" , "Incluido"  )
	oBrowse:AddLegend( "PA1_XTIPO == '2'", "BLUE"  , "Alteração" )
	oBrowse:AddLegend( "PA1_XTIPO == '3'", "RED"   , "Exclusão"  )
	oBrowse:AddLegend( "PA1_XTIPO == '4'", "BLACK" , "Importado" )
	oBrowse:Activate()
	
Return

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0201402' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE '&Legenda'    ACTION 'U_F0201405()'         OPERATION 6 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruPA2 := FWFormStruct( 1, 'PA1', /*bAvalCampo*/,.F. )
	Local oModel
	
	oModel := MPFormModel():New('F01402', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'PA1MASTER', /*cOwner*/, oStruPA2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( 'Log Alterações' )
	oModel:SetPrimaryKey({""})
	oModel:GetModel( 'PA1MASTER' ):SetDescription( 'Log Alterações' )
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'F0201402' )
	Local oStruPA2 := FWFormStruct( 2, 'PA1' )
	Local oView
	Local cCampos := {}
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_PA1', oStruPA2, 'PA1MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_PA1', 'TELA' )
	
Return oView

//============================================================================================
