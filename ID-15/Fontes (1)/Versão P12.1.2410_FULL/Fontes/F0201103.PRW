#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
{Protheus.doc} F0201103()
Tela MVC de cadastro dos subgrupos de produtos.
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
@Menu		Compras\Atualizacoes\Cadastros\SubGrupo Produtos
*/
User Function F0201103()

	Local aArea   := GetArea()
	Local oBrowse
	Private cTitulo := "Sub Grupo de Produtos"
      
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("P04")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
     
	RestArea(aArea)

Return Nil
 
/*
{Protheus.doc} MenuDef()
Definição de Menus.
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
*/
Static Function MenuDef()

Return FWMVCMenu( "F0201103" )

/*
{Protheus.doc} ModelDef()
Definição de Modelo.
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
*/
Static Function ModelDef()

	Local oModel := Nil
	Local oStP04 := FWFormStruct(1, "P04")
     
	oModel:=MPFormModel():New("M0201103",/*bPre*/,/*bPosVal*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMP04",/*cOwner*/,oStP04)
	oModel:SetPrimaryKey({'P04_FILIAL','P04_SUBGRP'})
	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
	oModel:GetModel("FORMP04"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel

/*
{Protheus.doc} ViewDef()
View de Modelo.
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
*/
Static Function ViewDef()

	Local oModel := FWLoadModel("F0201103")
	Local oStP04 := FWFormStruct(2, "P04")
	Local oView := Nil
 
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_P04", oStP04, "FORMP04")
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView('VIEW_P04', 'Dados do Grupo de Produtos' )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_P04","TELA")

Return oView

