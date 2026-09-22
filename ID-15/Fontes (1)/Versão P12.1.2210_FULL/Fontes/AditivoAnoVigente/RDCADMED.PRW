#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} RDCADMED
Cadastro de médicos
@type function
@version 1.0 
@author Dell
@since 10/11/2022
@return variant, nulo
/*/
User Function RDCADMED()
	Local cTitulo := "Cadastro de Médicos PJ"
	Private oBrowse := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetAlias("P36")
	oBrowse:SetAmbiente(.T.)
	oBrowse:AddLegend("P36_STATUS =='1'", "GREEN", "Ativo")
	oBrowse:AddLegend("P36_STATUS !='1'", "RED", "Inativo")
	oBrowse:Activate()

Return
/*/{Protheus.doc} MenuDef
Menu def.
@type function
@version 1.0  
@author Ricardo Junior
@since 10/11/2022
@return variant, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.RDCADMED' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.RDCADMED' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.RDCADMED' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.RDCADMED' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Relatório'  Action 'U_RRDCADMED' OPERATION 10 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Model
@type function
@version 1.0
@author Ricardo Junior
@since 10/11/2022
@return variant, null
/*/
Static Function ModelDef()
	Local oModel  := Nil
	Local oStTMP1 := FWFormStruct(1, "P36")//Criação da estrutura de dados utilizada na interface
	Local oStTMP2 := FWFormStruct(1, "P37")//Criação da estrutura de dados utilizada na interface
	Local cAlias2 := "P37"

	//oStTMP2:SetProperty("P37_ITEM", MODEL_FIELD_INIT, {|| iniItem() })

	oModel := MPFormModel():New('MRDCADMED',, /*bPosValidacao*/, {|oModel| fcommit(oModel) } , /*bCancel*/ )

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORM1",, oStTMP1)

	//Atribuindo formulários para o modelo
	oModel:AddGrid("FORM2","FORM1", oStTMP2)

	aRela	:= {}
	aAdd(aRela,{ 'P37_FILIAL'	, 'P36_FILIAL'})
	aAdd(aRela,{ 'P37_CODIGO'	, 'P36_CODIGO'})

	oModel:SetRelation('FORM2', aRela, (cAlias2)->(IndexKey(1)))
	oModel:GetModel('FORM2'):SetUniqueLine({'P37_FILIAL', 'P37_CODIGO', 'P37_FILALO', 'P37_DTFIM'})


	oModel:SetPrimaryKey({'P36_FILIAL','P36_CPF'})
	
	oModel:GetModel('FORM2'):SetLPost({|oModel| fVldGrid() })

	//Adicionando descrição ao modelo
	oModel:SetDescription("Cadastro de médicos")
	oModel:GetModel('FORM1'):SetDescription( 'Dados do cabecalho' )
	oModel:GetModel('FORM2'):SetDescription( 'Dados do itens'  )

Return oModel

/*/{Protheus.doc} ViewDef
View
@type function
@version 1.0
@author Ricardo Junior
@since 10/11/2022
@return variant, Null
/*/
Static Function ViewDef()
	Local oView		:=  Nil
	Local oModel 	:= FWLoadModel("RDCADMED")
	Local oStruct1  :=  FWFormStruct(2,"P36")
	Local oStruct2  :=  FWFormStruct(2,"P37")

	oStruct2:SetProperty("P37_VALIDT", MVC_VIEW_LOOKUP, {|| ConsRDCAD("P37_VALIDT")})
	oStruct2:SetProperty("P37_STAFF", MVC_VIEW_LOOKUP, {|| ConsRDCAD("P37_STAFF")})
	oStruct2:SetProperty("P37_TREINA", MVC_VIEW_LOOKUP, {|| ConsRDCAD("P37_TREINA")})


	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("SUPERIOR", oStruct1, "FORM1")

	oView:AddGrid("GRID", oStruct2, "FORM2")

	oView:CreateHorizontalBox("SUPERIOR",60,,,)
	oView:CreateHorizontalBox("GRID",40,,,)

	oView:SetOwnerView('SUPERIOR', 'SUPERIOR')
	oView:SetOwnerView('GRID', 'GRID')

	oView:AddIncrementField( 'GRID'	,'P37_ITEM' )

	//Colocando título do formulário
	oView:EnableTitleView('SUPERIOR', 'Dados fixos do Funcionário.' )
	oView:EnableTitleView('GRID', 'Variável de Local de Trabalho' )

	oView:SetCloseOnOk({||.T.})
Return oView

/*/{Protheus.doc} fcommit
Função de commit
@type function
@version 1.0 
@author Ricardo Junior
@since 17/11/2022
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
		oHeadModel:LoadValue("P36_STATUS", "2")
		//Verifica a data FIm e atualiza o status(ativo ou inativo)
		For nX := 01 To oGridModel:Length()
			oGridModel:GoLine(nX)
			If Empty(oGridModel:GetValue("P37_DTFIM")) .And. !(oGridModel:IsDeleted())
				oHeadModel:LoadValue("P36_STATUS", "1")
				Exit
			endif
		next nX
		oGridModel:GoLine(nLinhAtu)
		//Valida chave duplicada
		For nX := 01 To oGridModel:Length()
			oGridModel:GoLine(nX)
			cChave :=oGridModel:GetValue("P37_FILALO")+DToS(oGridModel:GetValue("P37_DTFIM"))
			if aSCan(aListChav, cChave) > 0 .And. !(oGridModel:IsDeleted())
				Help(NIL, NIL, "JAEXIST", NIL, "Esta chave já existe cadastrada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Por favor, altere a Chave [P37_FILALO+P37_DTFIM] na Linha {"+cValToChar(nX)+"}."})
				Return .F.
			endif
			aAdd(aListChav, cChave)
		Next nX
		oGridModel:GoLine(nLinhAtu)
	else
		if Aviso("Atenção", "Deseja Excluir o registro", {"Sim", "Não"}) == 1
			If Aviso("Atenção", "Ao confirmar você irá excluir todo o histórico médico, deseja continuar?", {"Não", "Sim"}) == 1
				lRet := .F.
				Help(" ",1,"RDCADMED",,"Foi cancelada a operação",2,1)
				Return lRet
			endif
		else
			lRet := .F.
			Help(" ",1,"RDCADMED",,"Foi cancelada a operação",2,1)
			Return lRet
		endif
	EndIf
	oGridModel:GoLine(nLinhAtu)
	FWFormCommit(oModel)
Return lRet


/*/{Protheus.doc} RRdcadMed
Relatório em Excel.
@type function
@version 1.0 
@author Ricardo Junior
@since 17/11/2022
@return nil, Nulo
/*/
User Function RRdcadMed()
	Local oExcel := FWMsExcelEx():New()
	Local cAtivo := ""
	Local aPergs := {}
	Local aCombo := {"1=ativo", "2=inativo", "3=ambos"}
	Local cQuery := ""
	Local aRet := {}
	Local P36Struct := P36->(DbStruct())
	Local P37Struct := P37->(DbStruct())
	Local cAlias := GetNextAlias()
	Local aStruct := {}
	Local aStrAlias := {}
	Local nX := 0
	Local nY := 0

	aAdd(aPergs, {2, "Status", 1, aCombo, 50, "", .F.})

	If !ParamBox(aPergs, "Informe os parâmetros", aRet)
		Return
	EndIf

	cQuery += " SELECT * FROM " + RetSqlName("P36") + " P36" + CRLF
	cQuery += " INNER JOIN " + RetSqlName("P37") +  " P37" + CRLF
	cQuery += " ON P36.P36_FILIAL = P37.P37_FILIAL " + CRLF
	cQuery += " AND P36.P36_CODIGO = P37.P37_CODIGO "+ CRLF
	cQuery += " WHERE P36.D_E_L_E_T_ = ' '  "+ CRLF
	cQuery += " AND   P37.D_E_L_E_T_ = ' '  "+ CRLF

	cAtivo := cValToChar(MV_PAR01)
	if cAtivo $ "1|2"
		cQuery += " AND P36.P36_STATUS = '" + cAtivo +"' "+ CRLF
	endif

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAlias,.F.,.T.)

	if (cAlias)->(Eof())
		Alert("Nenhum dado foi encontrado.")
		Return
	endif

	For nX := 01 To Len(P36Struct)
		aAdd(aStruct, P36Struct[nX][1])
		aAdd(aStrAlias, "(cAlias)->"+P36Struct[nX][1])
	Next nX

	For nX := 01 To Len(P37Struct)
		aAdd(aStruct, P37Struct[nX][1])
		aAdd(aStrAlias, "(cAlias)->"+P37Struct[nX][1])
	Next nX

	oExcel:AddworkSheet("CADMED")
	oExcel:AddTable("CADMED","Lista")

	For nX := 01 To Len(aStruct)
		if GetSX3Cache(aStruct[nX], "X3_TIPO") == "N"
			nTipo := 2
		elseif GetSX3Cache(aStruct[nX], "X3_TIPO") == "D"
			nTipo := 4
		else
			nTipo := 1
		endif

		oExcel:AddColumn("CADMED","Lista",GetSX3Cache(aStruct[nX], "X3_TITULO"),2, nTipo)
	Next nX

	oExcel:SetCelBold(.T.)
	oExcel:SetCelFont('Arial')
	oExcel:SetCelItalic(.T.)
	oExcel:SetCelUnderLine(.T.)
	oExcel:SetCelSizeFont(10)

	//Lista itens
	While !(cAlias)->(Eof())
		aStr := {}
		For nX := 01 To Len(aStrAlias)
			cRet := ""
			cCampo := SubStr(aStrAlias[nX],11,100)
			if cCampo $ "P37_STAFF"
				aOpcoes := {"PSA", "PSI", "UI", "UTI ADULTO", "UTI", "PED/NEO", "CEMED"}
				cChave := Replace(&(aStrAlias[nX]),"*","")
				For nY := 01 To Len(aOpcoes)
					if cValToChar(nY) $ cChave
						cRet += aOpcoes[nY] + "|"
					endif
				Next nY
				aAdd(aStr, cRet)
			elseif cCampo == "P37_VALIDT" .Or. cCampo == "P37_TREINA"
				aOpcoes := { "Não se aplica", "ACLS", "ATLS", "PALS", "BLS" }
				cChave := Replace(&(aStrAlias[nX]),"*","")
				For nY := 01 To Len(aOpcoes)
					if cValToChar(nY) $ cChave
						cRet += aOpcoes[nY] + "|"
					endif
				Next nY
				aAdd(aStr, cRet)
			else
				aAdd(aStr, &(aStrAlias[nX]))
			endif
		Next nX
		oExcel:AddRow("CADMED","Lista",aStr)
		(cAlias)->(DbSkip())
	EndDo

	oExcel:Activate()
	cFile := GetTempPath()+"RDCADMED"+FWTimeStamp(4)+".xml"
	oExcel:GetXMLFile(cFile)

	ShellExecute("open", "excel.exe", cFile, "", 3)
Return


/*/{Protheus.doc} ConsRDCAD
Monta consulta padrão multiseleção
@type function
@version 1.0 
@author Ricardo Junior
@since 17/11/2022
@return nil, Nulo
/*/
Static Function ConsRDCAD(cCampo)
	Local aOpcoes   := {}
	Local cOpcoes   := ""
	Local nTamKey   := 1
	Local nElemRet  := 10
	Local cF3 		:= ""
	Local uVarRet   := Nil
	Local cTitulo   := ""
	Local nX 		:= 01

	if cCampo == "P37_TREINA"
		cTitulo := "Treinamento"
		aOpcoes := { "Não se aplica", "ACLS", "ATLS", "PALS", "BLS" }
	elseif cCampo == "P37_STAFF"
		cTitulo := "Staff"
		aOpcoes := {"PSA", "PSI", "UI", "UTI ADULTO", "UTI", "PED/NEO", "CEMED"}
	elseif cCampo == "P37_VALIDT"
		cTitulo := "Validade Treinamento"
		aOpcoes := { "Não se aplica", "ACLS", "ATLS", "PALS", "BLS" }
	endif

	for nX :=  1 To Len(aOpcoes)
		cOpcoes += cValToChar(nX)
	next Nx

	f_Opcoes( 	@uVarRet    ,;    		//Variavel de Retorno
	cTitulo     ,;    		//Titulo da Coluna com as opcoes
	aOpcoes    ,;    		//Opcoes de Escolha (Array de Opcoes)
	cOpcoes    ,;    		//String de Opcoes para Retorno
	NIL         ,;    		//Nao Utilizado
	NIL         ,;    		//Nao Utilizado
	.F.         ,;    		//Se a Selecao sera de apenas 1 Elemento por vez
	nTamKey     ,;    		//Tamanho da Chave
	nElemRet    ,;    		//No maximo de elementos na variavel de retorno
	.T.         ,;    		//Inclui Botoes para Selecao de Multiplos Itens
	.F.         ,;    		//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
	NIL         ,;    		//Qual o Campo para a Montagem do aOpcoes
	.F.         ,;    		//Nao Permite a Ordenacao
	.F.         ,;    		//Nao Permite a Pesquisa
	.F.         ,;    		//Forca o Retorno Como Array
	cF3        )

	cReadVar := Readvar()

	SetMemVar(cReadVar,uVarRet)
Return uVarRet
/*/{Protheus.doc} fDupl
Retorna mensagem de linha duplicada.
@type function
@version 1.0 
@author Ricardo Junior
@since 17/11/2022
@return nil, Nulo
/*/
Static function fDupl(oModel)
	Alert("Médico já possui o vinculo sem data de término.")
return .F.

/*/{Protheus.doc} fVldGrid
Valida preenchimento de alguns campos
@type function
@version 1.0 
@author Ricardo Junior
@since 17/11/2022
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
		dData := oModelGrid:GetValue("P37_DTFIM")
		cChave := oModelGrid:GetValue("P37_FILALO")+DToS(dData)
		if aSCan(aListChav, cChave) > 0 .And. !(oModelGrid:IsDeleted())
			Help(NIL, NIL, "JAEXIST", NIL, "Esta chave já existe cadastrada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Por favor, altere a Chave[P37_FILALO+P37_DTFIM]."})
			Return .F.
		endif
		aAdd(aListChav, cChave)
		if Empty(oModelGrid:GetValue("P37_QEQUIP"))
			if oModelGrid:GetValue("P37_EQUIP") == "S" .And. !(oModelGrid:IsDeleted())
				Help(NIL, NIL, "P37_QEQUIP", NIL, "Este campo deve ser informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
				lRet := .F.
				Exit
			endif
		endif
		if Empty(oModelGrid:GetValue("P37_RQE2"))
			if !Empty(oModelGrid:GetValue("P37_ESP2")) .And. !(oModelGrid:IsDeleted())
				Help(NIL, NIL, "P37_RQE2", NIL, "Este campo deve ser informado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
				lRet := .F.
				Exit
			endif
		endif
		if Empty(oModelGrid:GetValue("P37_RQE3"))
			if !Empty(oModelGrid:GetValue("P37_ESP3")) .And. !(oModelGrid:IsDeleted())
				Help(NIL, NIL, "P37_RQE3", NIL, "Este campo deve ser informado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Coloque algum conteudo no campo."})
				lRet := .F.
				Exit
			endif
		endif		
	Next nX
	oModelGrid:GoLine(nLinhAtu)
Return lRet
