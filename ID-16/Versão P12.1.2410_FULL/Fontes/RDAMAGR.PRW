#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} RDAMAGR
Amarração função com os agrupadores de filial e função
@type function
@version 1.0 
@author Laura Peghini
@since 06/01/2026
@return variant, nulo
/*/
User Function RDAMAGR() 

Local cTitulo := "Grupo Beneficio"
Private oBrowse := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetAlias("PAS")
	oBrowse:SetAmbiente(.T.)
	oBrowse:Activate()

Return
/*/{Protheus.doc} MenuDef
Menu def.
@type function
@version 1.0  
@author Laura Peghini
@since 07/01/2026
@return variant, aRotina
/*/
Static Function MenuDef()

Local aRotina := {}

		aRotina:={{"Visualizar"						,'VIEWDEF.RDAMAGR'				,0,2},;
				  {"Incluir"						,'VIEWDEF.RDAMAGR'				,0,3},;
				  {"Alterar"						,'VIEWDEF.RDAMAGR'				,0,4},;
				  {"Excluir"						,'VIEWDEF.RDAMAGR'				,0,5}}
Return aRotina

/*/{Protheus.doc} ModelDef
Model
@type function
@version 1.0
@author Laura Peghini
@since 07/01/2026
@return variant, null
/*/
Static Function ModelDef()
	
Local oModel  := Nil
Local oStTMP1 := FWFormStruct(1, "PAS")//Criação da estrutura de dados utilizada na interface
Local oStTMP2 := FWFormStruct(1, "PAR")//Criação da estrutura de dados utilizada na interface
Local cAlias2 := "PAR"

	oStTMP1:SetProperty('PAS_GRPBEN', MODEL_FIELD_OBRIGAT, .F. )                                                                          //Campo Obrigatório
	oStTMP1:SetProperty('PAS_CDAGRU', MODEL_FIELD_OBRIGAT, .F. )                                                                          //Campo Obrigatório

	oModel := MPFormModel():New('MRDAMAGR',, /*bPosValidacao*/, {|oModel| fcommit(oModel) } , /*bCancel*/ )

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORM1",, oStTMP1)

	//Atribuindo formulários para o modelo
	oModel:AddGrid("FORM2","FORM1", oStTMP2)

	aRela	:= {}
	aAdd(aRela,{ 'PAR_FILIAL'	, 'PAS_FILIAL'})
	aAdd(aRela,{ 'PAR_GRPBEN'	, 'PAS_GRPBEN'})
    aAdd(aRela,{ 'PAR_CDAGRU'	, 'PAS_CDAGRU'})

	oModel:SetRelation('FORM2', aRela, (cAlias2)->(IndexKey(1)))
	oModel:GetModel('FORM2'):SetUniqueLine({'PAR_FILIAL', 'PAR_GRPBEN', 'PAR_CDAGRU', 'PAR_FUNCAO'})


	oModel:SetPrimaryKey({'PAS_FILIAL','PAS_GRPBEN','PAS_CDAGRU'})
	
	oModel:GetModel('FORM2'):SetLPost({|oModel| fVldGrid() })

	//Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro de Grupo Beneficio")
	oModel:GetModel('FORM1'):SetDescription( 'Dados do cabecalho' )
	oModel:GetModel('FORM2'):SetDescription( 'Dados do itens'  )

Return oModel

/*/{Protheus.doc} ViewDef
View
@type function
@version 1.0
@author Laura Peghini
@since 07/01/2026
@return variant, Null
/*/
Static Function ViewDef()

Local oView		:=  Nil
Local oModel 	:= FWLoadModel("RDAMAGR")
Local oStruct1  :=  FWFormStruct(2,"PAS")
Local oStruct2  :=  FWFormStruct(2,"PAR")


	oView := FWFormView():New()
	oView:SetModel(oModel)
*
	oView:AddField("SUPERIOR", oStruct1, "FORM1")

	oView:AddGrid("GRID", oStruct2, "FORM2")

	oView:CreateHorizontalBox("SUPERIOR",40,,,)
	oView:CreateHorizontalBox("GRID",60,,,)

	oView:SetOwnerView('SUPERIOR', 'SUPERIOR')
	oView:SetOwnerView('GRID', 'GRID')

	oView:AddIncrementField( 'GRID'	,'PAR_SEQ' )

	//Colocando título do formulário
	oView:EnableTitleView('SUPERIOR', 'Grp. Beneficio e Filial' )
	oView:EnableTitleView('GRID', 'Qualificador e Função' )

	oView:SetCloseOnOk({||.T.})

Return oView 

/*/{Protheus.doc} fcommit
Função de commit
@type function
@version 1.0 
@author Laura Peghini
@since 07/01/2026
@param oModel, object, param_description
@return true, Retorna sempre verdadeiro
/*/
Static Function fcommit(oModel)

Local oHeadModel := oModel:GetModel("FORM1")
Local oGridModel := oModel:GetModel("FORM2")
Local nX := 01
Local nOpc :=  oModel:GetOperation()
Local lRet := .T.
Local aListChav := {}
	
	nLinhAtu := oGridModel:GetLine()

	If MODEL_OPERATION_DELETE != nOpc
		oGridModel:GoLine(nLinhAtu)
		//Valida chave duplicada
		For nX := 01 To oGridModel:Length()
			oGridModel:GoLine(nX)
			cChave :=oGridModel:GetValue("PAR_GRPBEN")+oGridModel:GetValue("PAR_CDAGRU")+oGridModel:GetValue("PAR_FUNCAO")
			if aSCan(aListChav, cChave) > 0 .And. !(oGridModel:IsDeleted())
				Help(NIL, NIL, "JAEXIST", NIL, "Esta chave já existe cadastrada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Por favor, altere a Chave [PAR_GRPBEN+PAR_CDAGRU+PAR_AGRFUN+PAR_FUNCAO] na Linha {"+cValToChar(nX)+"}."})
				Return .F.
			endif
			aAdd(aListChav, cChave)
			if Empty(oGridModel:GetValue("PAR_AGRFUN"))
				if oGridModel:GetValue("PAR_AGRFUN") == "S" .And. !(oGridModel:IsDeleted())
					Help(NIL, NIL, "PAR_AGRFUN", NIL, "Este campo deve ser informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
					lRet := .F.
					Exit
				endif
			endif
			if Empty(oGridModel:GetValue("PAR_FUNCAO"))
				if oGridModel:GetValue("PAR_FUNCAO") == "S" .And. !(oGridModel:IsDeleted())
					Help(NIL, NIL, "PAR_FUNCAO", NIL, "Este campo deve ser informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
					lRet := .F.
					Exit
				endif
			endif
		Next nX
		oGridModel:GoLine(nLinhAtu)
	else
		if Aviso("Atenção", "Deseja Excluir o registro", {"Sim", "Não"}) == 1
			If Aviso("Atenção", "Ao confirmar você irá excluir todo o histórico médico, deseja continuar?", {"Não", "Sim"}) == 1
				lRet := .F.
				Help(" ",1,"RDAMAGR",,"Foi cancelada a operação",2,1)
				Return lRet
			endif
		else
			lRet := .F.
			Help(" ",1,"RDAMAGR",,"Foi cancelada a operação",2,1)
			Return lRet
		endif
	EndIf
	oGridModel:GoLine(nLinhAtu)
	FWFormCommit(oModel)

Return lRet


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
	Local cGrpFun := ""

	nLinhAtu := oModelGrid:GetLine()
	For nX :=01 To oModelGrid:Length()
		oModelGrid:GoLine(nX) 
		cChave := oModelGrid:GetValue("PAR_GRPBEN")+oModelGrid:GetValue("PAR_CDAGRU")+oModelGrid:GetValue("PAR_FUNCAO")
		if aSCan(aListChav, cChave) > 0 .And. !(oModelGrid:IsDeleted())
			Help(NIL, NIL, "JAEXIST", NIL, "Esta chave já existe cadastrada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Por favor, altere a Chave[P37_FILALO+P37_DTFIM]."})
			Return .F.
		endif
		aAdd(aListChav, cChave)
		if Empty(oModelGrid:GetValue("PAR_FUNCAO"))
			if oModelGrid:GetValue("PAR_FUNCAO") == "S" .And. !(oModelGrid:IsDeleted())
				Help(NIL, NIL, "PAR_FUNCAO", NIL, "Este campo deve ser informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
				lRet := .F.
				Exit
			endif
		endif
		if Empty(oModelGrid:GetValue("PAR_AGRFUN"))
			if !Empty(oModelGrid:GetValue("PAR_AGRFUN")) .And. !(oModelGrid:IsDeleted())
				Help(NIL, NIL, "PAR_AGRFUN", NIL, "Este campo deve ser informado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
				lRet := .F.
				Exit
			endif
		endif	
	Next nX
	oModelGrid:GoLine(nLinhAtu)

Return lRet
