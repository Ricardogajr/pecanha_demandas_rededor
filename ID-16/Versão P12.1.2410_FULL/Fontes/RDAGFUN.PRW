#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RDAGFUN
Cadastro de agrupadores de função
@type function
@version 1.0 
@author Laura Peghini
@since 05/01/2026
@return variant, nulo
/*/
User Function RDAGFUN() 

Local cTitulo := "Cadastro de Qualificador de Função"
Private oBrowse := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetAlias("PAP")
	oBrowse:SetAmbiente(.T.)
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Menu def.
@type function
@version 1.0  
@author Laura Peghini
@since 05/01/2026
@return variant, aRotina
/*/
Static Function MenuDef()
	
Local aRotina := {}

		aRotina:={{"Incluir"						,'VIEWDEF.RDAGFUN'				,0,3},;
				  {"Alterar"						,'VIEWDEF.RDAGFUN'				,0,4},;
				  {"Excluir"						,'VIEWDEF.RDAGFUN'				,0,5}}
Return aRotina

/*/{Protheus.doc} ModelDef
Model
@type function
@version 1.0
@author Laura Peghini
@since 05/01/2026
@return variant, null
/*/
Static Function ModelDef()
	
Local oModel  := Nil
Local oStTMP1 := FWFormStruct(1, "PAP")//Criação da estrutura de dados utilizada na interface

	oModel := MPFormModel():New('MRDAGFUN',, /*bPosValidacao*/, /*bCommit*/  , /*bCancel*/ )
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORM1",, oStTMP1)
	oModel:SetPrimaryKey({'PAP_FILIAL','PAP_CDFUNC'})
	//Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro de Qualificador de Função")
	oModel:GetModel('FORM1'):SetDescription( 'Qualificador de Função' )

Return oModel 

/*/{Protheus.doc} ViewDef 
View
@type function
@version 1.0
@author Laura Peghini
@since 05/01/2026
@return variant, Null
/*/
Static Function ViewDef()

Local oView		:=  Nil
Local oModel 	:= FWLoadModel("RDAGFUN")
Local oStruct1  :=  FWFormStruct(2,"PAP")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("SUPERIOR", oStruct1, "FORM1")
	oView:CreateHorizontalBox("SUPERIOR",100,,,)
	oView:SetOwnerView('SUPERIOR', 'SUPERIOR')
	//Colocando título do formulário
	oView:EnableTitleView('SUPERIOR', 'Qualificador de Função' )
	oView:SetCloseOnOk({||.T.})

Return oView
