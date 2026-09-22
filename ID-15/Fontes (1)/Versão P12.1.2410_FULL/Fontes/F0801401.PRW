#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0801401()
Tela de visualização do histórico de aprovações 
@Author     Henrique Madureira
@Since      19/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_CV_014
@Return	 
*/
User Function F0801401()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PAE')
	oBrowse:SetDescription('Historico de Aprovações')
	oBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Criação do Menu de Incentivo Acadêmico
@Author     Henrique Madureira
@Since      19/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_CV_014
@Return		aRotina, Opção de Menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	//ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0801401' OPERATION 2 ACCESS 0
	aRotina:={{"&Visualizar"						,'VIEWDEF.F0801401'				,0,1}}
Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de Dados do Incentivo Acadêmico
@Author     Henrique Madureira
@Since      19/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_CV_014
@Return     oModel, Modelo de Dados
*/
Static Function ModelDef()
	
	Local oStruPA3 := FWFormStruct( 1, 'PAE', /*bAvalCampo*/,.F. )
	Local oModel
	
	
	oModel := MPFormModel():New('M0801401', , , /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'PAEMASTER', /*cOwner*/, oStruPA3, , /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( 'Historico de Aprovações' )
	oModel:SetPrimaryKey({""})
	oModel:GetModel( 'PAEMASTER' ):SetDescription( 'Historico de Aprovações' )
	
	
Return oModel

/*
{Protheus.doc} ViewDef()
Interface do Incentivo Acadêmico
@Author     Henrique Madureira
@Since      19/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_CV_014
@Return     oView, interface
*/
Static Function ViewDef()
	
	Local oModel   := FWLoadModel( 'F0801401' )
	Local oStruPA3 := FWFormStruct( 2, 'PAE' )
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_PAE', oStruPA3, 'PAEMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_PAE', 'TELA' )
	
Return oView
