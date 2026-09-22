#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0801601()
Tela de cadastro de e-mails 
@Author     Henrique Madureira
@Since      30/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_016
@Return	 
*/
User Function F0801601()
Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('PAF')
	oBrowse:SetDescription('Mensagem de E-mails')
	oBrowse:Activate()
	
Return

/*
{Protheus.doc} MenuDef()
Criação do Menu de Incentivo Acadêmico
@Author     Henrique Madureira
@Since      30/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_016
@Return		aRotina, Opção de Menu
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	//ADD OPTION aRotina TITLE '&Visualizar' ACTION 'VIEWDEF.F0801601' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE '&Incluir'    ACTION 'VIEWDEF.F0801601' OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE '&Alterar'    ACTION 'VIEWDEF.F0801601' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE '&Excluir'    ACTION 'VIEWDEF.F0801601' OPERATION 5 ACCESS 0
		aRotina:={{"&Visualizar"					,'VIEWDEF.F0801601'				,0,1},;
				  {"&Incluir"						,'VIEWDEF.F0801601'				,0,2},;
				  {"&Alterar"						,'VIEWDEF.F0801601'				,0,3},;
				  {"&Excluir"						,'VIEWDEF.F0801601'				,0,4}}
Return aRotina

/*
{Protheus.doc} ModelDef()
Modelo de Dados do Incentivo Acadêmico
@Author     Henrique Madureira
@Since      19/05/2017
@Version    30/05/2017
@Project    MAN0000007423042_EF_016
@Return     oModel, Modelo de Dados
*/
Static Function ModelDef()
	
	Local oStruPAF := FWFormStruct( 1, 'PAF', /*bAvalCampo*/,.F. )
	Local oModel
	
	aAux := FwStruTrigger ( 'PAF_TIPO', 'PAF_TIPDES', 'Posicione("PA7",1,xFilial("PA7") + M->PAF_TIPO,"PA7_DESCR")' , .F. )
	oStruPAF:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAF_TIPO', 'PAF_SUBGRP', '' , .F. )
	oStruPAF:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAF_TIPO', 'PAF_GRPDES', '' , .F. )
	oStruPAF:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	aAux := FwStruTrigger ( 'PAF_SUBGRP', 'PAF_GRPDES', 'Posicione("PA7",1,xFilial("PA7") + M->PAF_TIPO + M->PAF_SUBGRP,"PA7_DESSUB")' , .F. )
	oStruPAF:AddTrigger( aAux[1] , aAux[2] , aAux[3], aAux[4])
	
	oModel := MPFormModel():New('M0801601', , , /*bCommit*/, /*bCancel*/ )
	
	oStruPAF:SetProperty('PAF_TIPO',MODEL_FIELD_VALID, {|| FsVldCdAl("PAF_TIPO") })
	oStruPAF:SetProperty('PAF_SUBGRP',MODEL_FIELD_VALID, {|| FsVldCdAl("PAF_SUBGRP")})
	
	oStruPAF:SetProperty( 'PAF_TIPO' , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT })
	oStruPAF:SetProperty( 'PAF_SUBGRP' , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT })
	
	oStruPAF:SetProperty( 'PAF_SUBGRP' , MODEL_FIELD_WHEN, {|| !(Empty(M->PAF_TIPO)) })
	
	oModel:AddFields( 'PAFMASTER', /*cOwner*/, oStruPAF, , /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( 'Mensagem de E-mails' )
	oModel:SetPrimaryKey({""})
	oModel:GetModel( 'PAFMASTER' ):SetDescription( 'Mensagem de E-mails' )
	
	
Return oModel

/*
{Protheus.doc} FsVldCdAl()
Validações de campos do Cadastro de Alçada
@Author     Bruno de Oliveira
@Since      08/03/2017
@Version    P12.1.07
@Project    MAN0000007423042_EF_004
@Param		lRet, permite ou não continuar
*/
Static Function FsVldCdAl(cCampo)
	
	Local aArea    := GetArea()
	Local oModel   := FwModelActive()
	Local oMdlPAF  := oModel:GetModel("PAFMASTER")
	Local cTpSolic := oMdlPAF:GetValue("PAF_TIPO")
	Local cSubGrp  := oMdlPAF:GetValue("PAF_SUBGRP")
	Local lRet     := .T.
	
	If cCampo == "PAF_TIPO"
		
		PA7->(DbSetOrder(1))
		If !PA7->(DbSeek(xFilial("PA7") + cTpSolic))
			Help("",1, "FsVldTpSl",, "Não existe este tipo de solicitação!" , 1, 0)
			lRet := .F.
		EndIf
		
	ElseIf cCampo == "PAF_SUBGRP"
		
		PA7->(DbSetOrder(1))
		If !PA7->(DbSeek(xFilial("PA7") + cTpSolic + cSubGrp))
			Help("",1, "FsVldTpSl",, "Não existe subgrupo para este tipo de solicitação!" , 1, 0)
			lRet := .F.
		EndIf
		
		If lRet
			PAF->(DbSetOrder(4))
			If PAF->(DbSeek(xFilial("PAF") + cTpSolic + cSubGrp))
				Help("",1, "FsVldTpSl",, "Já existe um cadastro de E-mail para esse tipo de solicitação e subgrupo!" , 1, 0)
				lRet := .F.
			EndIf
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return lRet

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
	
	Local oModel   := FWLoadModel( 'F0801601' )
	Local oStruPAF := FWFormStruct( 2, 'PAF' )
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_PAF', oStruPAF, 'PAFMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_PAF', 'TELA' )
	
Return oView
