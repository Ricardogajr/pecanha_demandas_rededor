#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
{Protheus.doc} F0201102()
Tela MVC de cadastro do grupo de produtos.
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
@Menu		Compras\Atualizações\Cadastros\Grupo Produtos
*/
User Function F0201102()

	Local oBrowse

	Private cTitulo := "Grp.Produtos"
      
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("P03")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
     
Return
 
/*
{Protheus.doc} MenuDef()
Rotina de Definição de Meunu
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
*/
Static Function MenuDef()

Return FWMVCMenu( "F0201102" )

/*
{Protheus.doc} ModelDef()
Definicao modelo MVC
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
*/
Static Function ModelDef()

	Local oModel := Nil
	Local oStP03 := FWFormStruct(1, "P03")
     
	oModel:=MPFormModel():New("M0201102",/*bPre*/,/*bPosVal*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMP03",/*cOwner*/,oStP03)
	oModel:SetPrimaryKey({'P03_FILIAL','P03_GRUPO'})
	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)
	oModel:GetModel("FORMP03"):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel

/*
{Protheus.doc} ViewDef()
View modelo MVC
@Author     Tiago Paulo Silva
@Since      10/05/2016
@Version    P12.7
@Project    MAN00000463301_EF_011
*/
Static Function ViewDef()

	Local oModel := FWLoadModel("F0201102")
	Local oStP03 := FWFormStruct(2, "P03")
	Local oView := Nil
 
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_P03", oStP03, "FORMP03")
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView('VIEW_P03', 'Dados do Grupo de Produtos' )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_P03","TELA")

Return oView
