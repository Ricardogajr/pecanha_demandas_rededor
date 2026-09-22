#Include "Protheus.ch"
#INCLUDE "ApWebSrv.ch"
#INCLUDE "FwMVCDef.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#Include 'TopConn.Ch'



/*/{Protheus.doc] MSFUNCCAD
Código fonte para funções diversas das melhorias na P33,P31,P30 e P17
@type       Static Function
@author     Lucas Miranda
@since      13/02/2025
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view 
@return     Nil

/*/

User Function MSFUNCCAD()

Return



/////////////////////////////////BLOCO DE FONTE PARA AMARRAÇÃO FILIAL X FRONT INICIO//////////////////////////////////////////////////////////////////
/*/{Protheus.doc} XMSFRONTS
Browse de marcação para alteração/visualização dos campos para alteração.

@project
@type       Static Function
@author     Lucas Miranda
@since      13/02/2025
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     Nil
/*/
User Function XMSFRONTS(oDbTree, oModel, oView)

	//Local aCriaTMP      := {}
	Local aEstrutura    := {}
	Local aColunas      := {}
	Local aIndice       := {}
	Local aP30Campos    := {}
	Local aRetorno      := {}
	Local aTamTela      := {}
	Local cRet 		    := ""

	Local cAliasTMP     := GetNextAlias() //"" Thais Paiva 166765526
	Local cP31Prefix    := ""

	Local oDialog       := Nil
	Local oMrkBrowse    := Nil
	Local oModelP30     := Nil

	Default oDbTree     := Nil
	Default oModel      := FwModelActive()
	Default oView       := FwViewActive()

	cP31Prefix := "P30"

	oModelP30 := oModel:GetModel("P31DETAIL")

	AADD(aP30Campos,"P30_OK")
	AADD(aP30Campos,"P30_NFRONT")
	//aP30Campos  := RetCampos(cP31Prefix)

	AAdd(aIndice, {"DEFAULT", {"P30_NFRONT"}})

	aTamTela := FwGetDialogSize()

	DEFINE MSDIALOG oDialog TITLE "Seleção de front" FROM aTamTela[1], aTamTela[2] To aTamTela[3] / 1.5, aTamTela[4] / 1.5 COLORS 0, 16777215 PIXEL

	oMrkBrowse := FwMarkBrowse():New()

	aRetorno    := CriaColuna(cP31Prefix)

	aEstrutura  := aRetorno[1]
	aColunas    := aRetorno[2]

	oModelP30:SeekLine({{"P30_NFRONT", oDbTree:GetCargo()}}, .F., .T.)

	//If ValType(oTempTable) != "O" Thais Paiva 166765526//If ValType(oTempTable) != "O" Thais Paiva 166765526
	oTempTable := FwTemporaryTable():New()
	CriaTMP(cAliasTMP, aIndice, aEstrutura)
	//EndIf Thais Paiva 166765526

	//cAliasTMP   := oTempTable:GetAlias() Thais Paiva 166765526

	oMrkBrowse:SetOwner(oDialog)
	oMrkBrowse:SetTemporary(.T.)
	oMrkBrowse:SetDescription("Seleção de front")
	oMrkBrowse:SetAlias(cAliasTMP)
	oMrkBrowse:SetColumns(aColunas)
	oMrkBrowse:SetFieldMark("P30_OK")
	oMrkBrowse:SetMark("X", cAliasTMP, "P30_OK")
	//oMrkBrowse::SetValid( { || fvldmark(oMrkBrowse,cAliasTMP) } )

	//Desabilita tudo o que não for necessário
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:DisableFilter()
	oMrkBrowse:DisableConfig()
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableSaveConfig()
	oMrkBrowse:SetWalkThru(.F.)
	oMrkBrowse:SetAmbiente(.F.)

	LoadMkBrow(cAliasTMP, aP30Campos, oModel, oMrkBrowse)

	//ajustar confirmar para gravação do markbrowse no modelo de dados
	If oModel:GetOperation() == MODEL_OPERATION_VIEW
		oMrkBrowse:AddButton("Fechar",   {|| CloseBrowse()},, 2)
	Else
		If IsIncallStack("U_XFCVF")
			oMrkBrowse:AddButton("Confirmar",  {|| cRet := GrvModelMk(cAliasTMP, oModel,, oDbTree), CloseBrowse()},, 4)
		Else
			oMrkBrowse:AddButton("Confirmar",  {|| GrvModelMk(cAliasTMP, oModel,, oDbTree), CloseBrowse()},, 4)
			oMrkBrowse:AddButton("Cancelar",   {|| CloseBrowse()},, 2)
		EndIf

	EndIf

	oMrkBrowse:Activate()

	ACTIVATE MSDIALOG oDialog CENTERED

	oTempTable:Delete() //Thais Paiva - 04/12/2020
	If IsIncallStack("U_XFCVF")
		Return cRet
	Else
		Return Nil
	EndIf




/*/{Protheus.doc} LoadMkBrow
Carrega a tabela temporária para uso no browse de marcação.

@project
@type       Static Function
@author     Lucas Miranda
@since      13/02/2025
@param      cAliasTMP, character, alias temporário para gravação
@param      aCampos, array, array contendo os campos que serão carregados
@param      oModel, object, modelo de dados
@param      oMrkBrowse, object, object do browse de marcação a ser carregado
@return     Nil
/*/
Static Function LoadMkBrow(cAliasTMP, aCampos, oModel, oMrkBrowse)

	Local cMarca    := ""
	Local nCampo    := 0
	Local cQuery    := ""
	Local cAliasP33 := ""


	Default cAliasTMP   := oTempTable:GetAlias()
	Default aCampos     := {}
	Default oModel      := FwModelActive()

	cQuery := " SELECT P33_NOMFR FROM "+RetSqlName("P33")+" WHERE D_E_L_E_T_ = ' ' AND P33_NOMFR <> ' '  GROUP BY P33_NOMFR"

	cQuery := ChangeQuery(cQuery)

	cAliasP33 := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasTMP)

	(cAliasTMP)->(DbGoTop())

	cMarca := oMrkBrowse:Mark()

	While (cAliasP33)->(!EOF())
		Reclock(cAliasTMP, .T.)
		(cAliasTMP)->P30_OK     := ""
		(cAliasTMP)->P30_NFRONT  := (cAliasP33)->P33_NOMFR
		(cAliasTMP)->(MsUnlock())
		(cAliasP33)->(DbSkip())
	Enddo

	Reclock(cAliasTMP, .T.)
	(cAliasTMP)->P30_OK     := ""
	(cAliasTMP)->P30_NFRONT  := "ADM P12 FULL"
	(cAliasTMP)->(MsUnlock())

	Reclock(cAliasTMP, .T.)
	(cAliasTMP)->P30_OK     := ""
	(cAliasTMP)->P30_NFRONT  := "ADM P12 SIMP"
	(cAliasTMP)->(MsUnlock())


	(cAliasP33)->(DbCloseArea())

Return Nil


/*/{Protheus.doc} CriaTMP
Cria tabela temporária para uso no browse de marcação.

@project
@type       Static Function
@author     Lucas Miranda
@since      13/02/2025
@param      cAliasTMP, character, alias temporário para gravação
@param      aIndice, array, indice do alias temporário
@param      aEstrutura, array, array contendo a estrutura do alias temporário
@return     Nil
/*/
Static Function CriaTMP(cAliasTMP, aIndice, aEstrutura)

	Local nIndice   := 0
	Local nLenIndic := 0

	Default cAliasTMP   := GetNextAlias()
	Default aIndice     := {}
	Default aEstrutura  := {}

	oTempTable := FwTemporaryTable():New(cAliasTMP, aEstrutura)

	nLenIndic := Len(aIndice)

	For nIndice := 1 To nLenIndic
		oTempTable:AddIndex(aIndice[nIndice][1], aIndice[nIndice][2])
	Next nIndice

	oTempTable:Create()

Return Nil


Static Function CriaColuna(cPrefixo)

	Local aColunas      := {}
	Local aEstrutura    := {}
	Local aRetorno      := {}

	Local nQtdColuna    := {}

	Local nCampo        := 0

	Default cPrefixo    := "P31"

	If cPrefixo == "P31"
		AAdd(aEstrutura, {"P31_OK",    "C",    001,    0})
		AAdd(aEstrutura, {"P31_CAMPO", "C",    010,    0})
		AAdd(aEstrutura, {"P31_DESC",  "C",    100,    0})
	Else
		AAdd(aEstrutura, {"P30_OK",    "C",    001,    0})
		AAdd(aEstrutura, {"P30_NFRONT", "C",   100,    0})

	EndIf
	For nCampo := 1 To Len(aEstrutura)
		If !(aEstrutura[nCampo][1] $ cPrefixo + "_OK") //não duplicar campo _OK
			AAdd(aColunas, FwBrwColumn():New())

			nQtdColuna := Len(aColunas)

			aColunas[nQtdColuna]:SetData( &("{||" + aEstrutura[nCampo][1] + "}") )
			If aEstrutura[nCampo][1] == cPrefixo + "_CAMPO"
				aColunas[nQtdColuna]:SetTitle("Campo")
			Else
				aColunas[nQtdColuna]:SetTitle("Descrição")
			EndIf
			aColunas[nQtdColuna]:SetType(aEstrutura[nCampo][2])
			aColunas[nQtdColuna]:SetSize(aEstrutura[nCampo][3])
			aColunas[nQtdColuna]:SetDecimal(aEstrutura[nCampo][4])
			aColunas[nQtdColuna]:SetPicture("@!")
		EndIf
	Next nCampo

	AAdd(aRetorno, aEstrutura)
	AAdd(aRetorno, aColunas)

Return aRetorno

/*/{Protheus.doc} GrvModelMk
Efetua a gravação dos dados do Browse de marcação para o modelo de dados.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cAliasTMP, character, alias temporário para gravação
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@param      oDbTree, object, arvore do registro
@return     Nil
/*/
Static Function GrvModelMk(cAliasTMP, oModel, oView, oDbTree)

	Local oModelP30     := Nil
	Local cFilName      := ""
	Local cMatriz       := ""
	Local cP30Replic    := ""
	Local cP30Corp    := ""
	Local cReplica      := ""
	Local cFront      := ""
	Private cFrt := ""

	Default cAliasTMP   := oTempTable:GetAlias()
	Default oModel      := FwModelActive()
	Default oView       := FwViewActive()
	Default oDbTree     := Nil

	If IsIncallStack("U_XFCVF")
		Return (cAliasTMP)->P30_NFRONT
	EndIf
	If !(oModel:GetOperation() == MODEL_OPERATION_VIEW)
		oModelP30   := oModel:GetModel("P30MASTER")

		cP30Replic := AllTrim(oModelP30:GetValue("P30_REPLIC"))
		cP30Corp := IIF(Empty(AllTrim(oModelP30:GetValue("P30_CORP"))),"0",AllTrim(oModelP30:GetValue("P30_CORP"))) //Thais Paiva - 166765526

		If cP30Corp == "2"
			cP30Corp := "1"
		Else
			cP30Corp := "2"
		EndIf

		cMatriz     := oDbTree:GetCargo()
		cFilName    := FwFilName(FwCodEmp(), cMatriz)
		(cAliasTMP)->(DbGoTop())

		While (cAliasTMP)->(!(EoF()))
			If !Empty((cAliasTMP)->P30_OK)
				If AllTrim((cAliasTMP)->P30_NFRONT) == "P12 SIMP"
					If AllTrim(Posicione("P33",1,FwXFilial("P33")+oModelP30:GetValue("P30_CODFIL"),"P33_SIMP")) != "S"
						Alert("A filial selecionada não pertence ao P12 Simplificado! A operação não será executada!")
						oView:lModify           := .T.
						oView:oModel:lModify    := .T.
						Return Nil
					Else
						oModelP30:SetValue("P30_NFRONT", (cAliasTMP)->P30_NFRONT)
						Exit
					EndIf
				Else
					oModelP30:SetValue("P30_NFRONT", (cAliasTMP)->P30_NFRONT)
					Exit
				EndIf


			EndIf
			(cAliasTMP)->(DbSkip())
		End

		oView:lModify           := .T.
		oView:oModel:lModify    := .T.
	EndIf

	cReplica := "Replica produto para Filial(ais) vinculada(s): " + IIf(cP30Replic == "1", "Sim", "Não")
	cFront := "Nome Front: " + Iif(!Empty(oModelP30:GetValue("P30_NFRONT")) ,oModelP30:GetValue("P30_NFRONT"),"Não Informado")

	oDbTree:ChangePrompt(cMatriz + " - " + cFilName + " - (Matriz) - " + cReplica + " - " + cFront)
Return Nil

Static Function fvldmark(oBrowse)

	Local nRec := (cAliasTMP)->(RECNO())
	Local lRet := .T.

	Default cAliasTMP   := oTempTable:GetAlias()


	(cAliasTMP)->(DbGoTop())

	While (cAliasTMP)->(!(EoF()))
		If !Empty((cAliasTMP)->P30_OK)
			Alert("Só pode marcar um unico registro!")
			lRet := .F.
			Exit
		EndIf
		(cAliasTMP)->(DbSkip())
	End

	(cAliasTMP)->(DbGoto(nRec))
Return lRet

//////////////////////////////////////////////BLOCO DE FONTE PARA AMARRAÇÃO FILIAL X FRONT FIM//////////////////////////////////////////////////////////////////











//////////////////////////////////////////////BLOCO DE FONTE PARA AMARRAÇÃO CAMPOS X FRONT INICIO//////////////////////////////////////////////////////////////////
/*/{Protheus.doc} XFCVF
Browse de marcação para visualização dos campos por FRONT.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     Nil
/*/
User Function XFCVF(oDbTree, oModel, oView)

	//Local aCriaTMP      := {}
	Local aEstrutura    := {}
	Local aColunas      := {}
	Local aIndice       := {}
	Local aP17Struct    := {}
	Local aP31Campos    := {}
	Local aRetorno      := {}
	Local aTamTela      := {}
	Local cFront        := ""

	Local cAliasTMP     := GetNextAlias() //"" Thais Paiva 166765526
	Local cMarca        := ""
	//Local cP17Prefix    := ""
	Local cP31Prefix    := ""

	Local oDialog       := Nil
	Local oMrkBrowse    := Nil
	Local oModelP31     := Nil

	Default oDbTree     := Nil
	Default oModel      := FwModelActive()
	Default oView       := FwViewActive()

	cFront := U_XMSFRONTS(oDbTree, oModel, oView)

	cP31Prefix := "P31"

	oModelP31 := oModel:GetModel("P31DETAIL")

	aP31Campos  := RetCampos(cP31Prefix)

	AAdd(aIndice, {"DEFAULT", {"P31_CAMPO"}})

	aTamTela := FwGetDialogSize()

	DEFINE MSDIALOG oDialog TITLE "Campos Visíveis" FROM aTamTela[1], aTamTela[2] To aTamTela[3] / 1.5, aTamTela[4] / 1.5 COLORS 0, 16777215 PIXEL

	oMrkBrowse := FwMarkBrowse():New()

	aRetorno    := CriaColuna(cP31Prefix)

	aEstrutura  := aRetorno[1]
	aColunas    := aRetorno[2]

	oModelP31:SeekLine({{"P31_CODFIL", oDbTree:GetCargo()}}, .F., .T.)

	//If ValType(oTempTable) != "O" Thais Paiva 166765526//If ValType(oTempTable) != "O" Thais Paiva 166765526
	oTempTable := FwTemporaryTable():New()
	CriaTMP(cAliasTMP, aIndice, aEstrutura)
	//EndIf Thais Paiva 166765526

	//cAliasTMP   := oTempTable:GetAlias() Thais Paiva 166765526

	oMrkBrowse:SetOwner(oDialog)
	oMrkBrowse:SetTemporary(.T.)
	oMrkBrowse:SetDescription("Campos Visíveis")
	oMrkBrowse:SetAlias(cAliasTMP)
	oMrkBrowse:SetColumns(aColunas)
	oMrkBrowse:SetFieldMark("P31_OK")
	oMrkBrowse:SetMark("X", cAliasTMP, "P31_OK")

	//Desabilita tudo o que não for necessário
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:DisableFilter()
	oMrkBrowse:DisableConfig()
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableSaveConfig()
	oMrkBrowse:SetWalkThru(.F.)
	oMrkBrowse:SetAmbiente(.F.)

	Load31Brw(cAliasTMP, aP31Campos, oModel, oMrkBrowse,cFront)

	//ajustar confirmar para gravação do markbrowse no modelo de dados
	If oModel:GetOperation() == MODEL_OPERATION_VIEW
		oMrkBrowse:AddButton("Fechar",   {|| CloseBrowse()},, 2)
	Else
		oMrkBrowse:AddButton("Confirmar",  {|| GrvFP31(cAliasTMP, oModel,, oDbTree,cFront), CloseBrowse()},, 4)
		oMrkBrowse:AddButton("Cancelar",   {|| CloseBrowse()},, 2)
	EndIf

	oMrkBrowse:Activate()

	ACTIVATE MSDIALOG oDialog CENTERED

	oTempTable:Delete() //Thais Paiva - 04/12/2020
Return Nil



/*/{Protheus.doc} GrvFP31
Efetua a gravação dos dados do Browse de marcação para o modelo de dados.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cAliasTMP, character, alias temporário para gravação
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@param      oDbTree, object, arvore do registro
@return     Nil
/*/
Static Function GrvFP31(cAliasTMP, oModel, oView, oDbTree,cFront)

	Local cCampoP31     := ""
	Default cAliasTMP   := oTempTable:GetAlias()
	Default oModel      := FwModelActive()
	Default oView       := FwViewActive()
	Default oDbTree     := Nil

	If !(oModel:GetOperation() == MODEL_OPERATION_VIEW)

		(cAliasTMP)->(DbGoTop())

		If AllTrim(cFront) == "ADM P12 FULL"
			cFront := "ADMP12F "
		EndIf
		P31->(DbSeek(xFilial("P31")+cFront))
		While (cAliasTMP)->(!(EoF()))

			cCampoP31   := (cAliasTMP)->P31_CAMPO
			Reclock("P31",.F.)
			P31->&(cCampoP31) := IIf(Empty((cAliasTMP)->P31_OK), "2", "1")
			P31->(MsUnLock())
			(cAliasTMP)->(DbSkip())
		End
		oView:lModify           := .T.
		oView:oModel:lModify    := .T.
	EndIf

Return Nil


/*/{Protheus.doc} LoadMkBrow
Carrega a tabela temporária para uso no browse de marcação.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cAliasTMP, character, alias temporário para gravação
@param      aCampos, array, array contendo os campos que serão carregados
@param      oModel, object, modelo de dados
@param      oMrkBrowse, object, object do browse de marcação a ser carregado
@return     Nil
/*/
Static Function Load31Brw(cAliasTMP, aCampos, oModel, oMrkBrowse,cFront)

	Local aRestRows := {}
	Local aArea     := {}
	Local aCampos   := {}

	Local cMarca    := ""

	Local lInclusao := .T.

	Local nCampo    := 0
	Local nLenALias := 0
	Local nQtdCampo := 0
	Local nX        := 0

	Local oModelP31 := Nil

	Default cAliasTMP   := oTempTable:GetAlias()
	Default aCampos     := {}
	Default oModel      := FwModelActive()

	oModelP31 := oModel:GetModel("P31DETAIL")

	aRestRows := FwSaveRows()
	DbSelectArea("P31")
	DbSetOrder(2)
	aCampos := FWSX3Util():GetAllFields( "P31" , .F. )

	If AllTrim(cFront) == "ADM P12 FULL"
		cFront := "ADMP12F "
	EndIf

	If !P31->(DbSeek(xFilial("P31")+cFront))
		Reclock("P31",.T.)
		For nX := 01 To Len(aCampos)
			If aCampos[nX] == "P31_FILIAL"
				P31->&(aCampos[nX]) := "        "
			ElseIf aCampos[nX] == "P31_COD"
				P31->&(aCampos[nX]) := "FRONT1"
			ElseIf aCampos[nX] == "P31_CODFIL"
				If AllTrim(cFront) == "ADM P12 FULL"
					P31->&(aCampos[nX]) := "ADMP12F"
				Else
					P31->&(aCampos[nX]) := cFront
				EndIf
			Else
				P31->&(aCampos[nX]) := "1"
			EndIf
		Next nX
		P31->(MsUnLock())
	EndIf

	DbSelectArea(cAliasTMP)

	Count To nLenALias

	(cAliasTMP)->(DbGoTop())

	aArea := {GetArea(), SX3->(GetArea())}

	cMarca := oMrkBrowse:Mark()


	If P31->(DbSeek(xFilial("P31")+cFront))

		For nX := 01 To Len(aCampos)
			If (AllTrim(aCampos[nX]) == "P31_COD" .Or. AllTrim(aCampos[nX]) == "P31_FILIAL" .Or. AllTrim(aCampos[nX]) == "P31_CODFIL" )
				Loop
			EndIf
			Reclock(cAliasTMP, .T.)
			(cAliasTMP)->P31_OK     := IIf(P31->&(aCampos[nX]) == "1", cMarca, "")
			(cAliasTMP)->P31_CAMPO  := aCampos[nX]
			(cAliasTMP)->P31_DESC   := GetSX3Cache(aCampos[nX], "X3_DESCRIC")
			(cAliasTMP)->(MsUnlock())
		Next nX

	EndIf

	FwRestRows(aRestRows)
	AEval(aArea, {|area| RestArea(area)})

Return Nil

//////////////////////////////////////////////BLOCO DE FONTE PARA AMARRAÇÃO CAMPOS X FRONT FIM//////////////////////////////////////////////////////////////////


/*/{Protheus.doc} xfGetFr
Carrega a tabela temporária para uso no browse de marcação.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cAliasTMP, character, alias temporário para gravação
@param      aCampos, array, array contendo os campos que serão carregados
@param      oModel, object, modelo de dados
@param      oMrkBrowse, object, object do browse de marcação a ser carregado
@return     Nil
/*/

User Function xfGetFr(cProd)

	Local cQuery := ""
	Local cAliasP30 := GetNextAlias()
	Local aRet := {}
	Local lAdm := .F.
	Local lP12S := .F.


	//cQuery := " SELECT TRIM(P30_NFRONT) AS FRONT FROM "+RetSqlName("P30")+" WHERE D_E_L_E_T_ = ' ' AND P30_NFRONT <> ' '  GROUP BY P30_NFRONT ORDER BY P30_NFRONT DESC"


	cQuery := " SELECT TRIM(P30_NFRONT) AS FRONT FROM "+RetSqlName("P30")+" A WHERE A.D_E_L_E_T_ = ' ' AND P30_NFRONT <> ' '"
	cQuery += " AND EXISTS(SELECT 1 FROM P17010 WHERE D_E_L_E_T_ = ' ' AND "
	cQuery += " (P17_FTRATA IN (SELECT P30_CODFIL FROM " +RetSqlName("P30")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND P30_NFRONT = A.P30_NFRONT) "
	cQuery += " OR P17_FTRATA IN (SELECT P31_CODFIL FROM P31010 WHERE P31_COD = A.P30_COD)) "
	cQuery += " AND P17_COD = '" +cProd+"')"
	cQuery += " GROUP BY P30_NFRONT ORDER BY P30_NFRONT DESC
	cQuery := ChangeQuery(cQuery)

	cAliasP30 := MPSysOpenQuery(cQuery)

	While (cAliasP30)->(!EOF())
		If AllTrim((cAliasP30)->FRONT) == "ADM P12 FULL"
			lAdm := .T.
		ElseIf	AllTrim((cAliasP30)->FRONT) == "ADM P12 SIMP"
			lP12S := .T.
		Else
			AAdd(aRet,(cAliasP30)->FRONT)
		EndIf
		(cAliasP30)->(DbSkip())
	EndDo

	If lAdm
		AAdd(aRet,"ADM P12 FULL")
	EndIf
 
	If lP12S
		AAdd(aRet,"ADM P12 SIMP")
	EndIf

Return aRet


User Function MSGATP33(cCampo)

	Local cRet := ""
	Local oObJ := FWModelActive()

	If oObJ:getoperation() == 5
		Return .T.
	EndIf

	If ValType(cCampo) == "O"
		oObJ:SetValue("FORMP33","P33_XUSRAL",DtoS(Date()) + " " + Time())
	Return .T.
	EndIf

	If cCampo == "P33_NOMFIL"
		cRet := Posicione("SM0",1, cEmpAnt + M->P33_FILPS, "M0_FILIAL")
	ElseIf cCampo == "P33_CGC"
		cRet := Posicione("SM0",1, cEmpAnt + M->P33_FILPS, "M0_CGC")
	ElseIf cCampo == "P33_XUSRIN"
		If INCLUI
			cRet := DtoS(Date()) + " " + Time()
		EndIf
	ElseIf cCampo == "P33_XUSRAL"
		cRet := DtoS(Date()) + " " + Time()
	EndIf


Return cRet





