#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RDAGFIL
Cadastro de agrupadores de filial
@type function
@version 1.0 
@author Laura Peghini
@since 05/01/2026
@return variant, nulo
/*/
User Function RDAGFIL() 

Local cTitulo := "Cadastro de Grp.Beneficio x Filial"
Private oBrowse := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetAlias("PAO")
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

		aRotina:={{"Incluir"						,'VIEWDEF.RDAGFIL'				,0,3},;
				  {"Alterar"						,'VIEWDEF.RDAGFIL'				,0,4},;
				  {"Excluir"						,'VIEWDEF.RDAGFIL'				,0,5}}
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
Local oStTMP1 := FWFormStruct(1, "PAO")//Criação da estrutura de dados utilizada na interface
Local oStTMP2 := FWFormStruct(1, "PAQ")//Criação da estrutura de dados utilizada na interface
Local cAlias2 := "PAQ"

	oModel := MPFormModel():New('MRDAGFIL',, /*bPosValidacao*/, /*bCommit*/ , /*bCancel*/ )
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORM1",, oStTMP1)
	//Atribuindo formulários para o modelo
	oModel:AddGrid("FORM2","FORM1", oStTMP2)

		aRela	:= {}
	aAdd(aRela,{ 'PAQ_FILIAL'	, 'PAO_FILIAL'})
	aAdd(aRela,{ 'PAQ_CDAGRU'	, 'PAO_CDAGRU'})

	oModel:SetRelation('FORM2', aRela, (cAlias2)->(IndexKey(1)))
	oModel:GetModel('FORM2'):SetUniqueLine({'PAQ_FILIAL', 'PAQ_CDAGRU', 'PAQ_AGFILI'})

	oModel:SetPrimaryKey({'PAO_FILIAL','PAO_CDAGRU'})

	oModel:GetModel('FORM2'):SetLPost({|oModel| fVldGrid() })

	//Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro de Grp.Beneficio x Filial")
	oModel:GetModel('FORM1'):SetDescription( 'Grupo Beneficio' )
	oModel:GetModel('FORM2'):SetDescription( 'Filiais'  )

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
Local oModel 	:= FWLoadModel("RDAGFIL")
Local oStruct1  :=  FWFormStruct(2,"PAO")
Local oStruct2  :=  FWFormStruct(2,"PAQ")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("SUPERIOR", oStruct1, "FORM1")
	oView:AddGrid("GRID", oStruct2, "FORM2")
	oView:CreateHorizontalBox("SUPERIOR",20,,,)
	oView:CreateHorizontalBox("GRID",80,,,)

	oView:SetOwnerView('SUPERIOR', 'SUPERIOR')
	oView:SetOwnerView('GRID', 'GRID')

	oView:AddIncrementField( 'GRID'	,'PAQ_SEQ' )

	//Colocando título do formulário
	oView:EnableTitleView('SUPERIOR', 'Grupo Beneficio' )
	oView:EnableTitleView('GRID', 'Filiais' )

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} fVldGrid
Valida preenchimento de alguns campos
@type function
@version 1.0 
@author Laura Peghini
@since 07/01/2026
@return nil, Nulo
/*/
Static Function fVldGrid()

	Local oModel := FWModelActive()
	Local oModelGrid := oModel:GetModel("FORM2")
	Local nX := 0
	Local lRet := .T.
	Local aListChav := {}
	nLinhAtu := oModelGrid:GetLine()
	For nX :=01 To oModelGrid:Length()
		oModelGrid:GoLine(nX)
		cChave := oModelGrid:GetValue("PAQ_CDAGRU")+oModelGrid:GetValue("PAQ_AGFILI")
		if aSCan(aListChav, cChave) > 0 .And. !(oModelGrid:IsDeleted())
			Help(NIL, NIL, "JAEXIST", NIL, "Esta chave já existe cadastrada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Por favor, altere a Chave[P37_FILALO+P37_DTFIM]."})
			Return .F.
		endif
		aAdd(aListChav, cChave)
		if Empty(oModelGrid:GetValue("PAQ_AGFILI"))
			if oModelGrid:GetValue("PAQ_AGFILI") == "S" .And. !(oModelGrid:IsDeleted())
				Help(NIL, NIL, "PAQ_AGFILI", NIL, "Este campo deve ser informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
				lRet := .F.
				Exit
			endif
		endif	
	Next nX
	oModelGrid:GoLine(nLinhAtu)

Return lRet
