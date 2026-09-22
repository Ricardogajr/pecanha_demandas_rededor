#Include "Protheus.ch"
#INCLUDE "ApWebSrv.ch"
#INCLUDE "FwMVCDef.ch"

Static cCodMat      := ""
Static oTempTable   := ""

/*/{Protheus.doc} F1206401
Cadastro de Hospital x Clínicas.
 
@project
@type       User Function
@author     Rafael Riego
@since      10/12/2018
@version    1.0 
@return     Nil
/*/
User Function F1206401()

	Local oBrowse := Nil

	DbSelectArea("P30")
	DbSelectArea("P33")
	oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("P30")
//    oBrowse:SetDescription("Hospital x Clínicas")
	oBrowse:SetDescription("Rdsl Amarração de Unidades")

	oBrowse:Activate()

	If ValType(oTempTable) == "O"
		FwFreeObj(oTempTable)
		oTempTable := Nil
	EndIf

	cCodMat := ""

Return Nil

User Function F1206EX()

	Local cCod := P30->P30_COD
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()
	Local lOk  := .T.

	If MsgYesNo("Deseja deletar a matriz " + P30->P30_CODFIL + " ?")

		cQuery  := "SELECT P30_COD"
		cQuery  += "    FROM " + RetSQLName("P30") + " P30 "
		cQuery  += "    INNER JOIN  " + RetSQLName("P31") + " P31 ON"
		cQuery  += " P31.P31_FILIAL = P30.P30_FILIAL AND P31.P31_COD = P30.P30_COD AND P31.D_E_L_E_T_ = ' '"
		cQuery  += "WHERE P30.P30_FILIAL = '" + FwXFilial("P30") + "' "
		cQuery  += "  AND P31.P31_FILIAL = '" + FwXFilial("P31") + "' "
		cQuery  += "  AND P30.P30_COD = '" +cCod+ "' "
		cQuery  += "  AND P30.D_E_L_E_T_ = ' ' "


		cQuery := ChangeQuery(cQuery)

		cAliasQry := MPSysOpenQuery(cQuery)

		If (cAliasQry)->(!(EoF()))
			lOk := .F.
		EndIf

		If lOk
			Reclock("P30",.F.)
			P30->(DbDelete())
			P30->(MsUnLock())
			MsgInfo("Matriz deletada com sucesso!")
		Else
			Alert("Não é possível deletar uma matriz com filiais vinculadas!")
		EndIf

		(cAliasQry)->(DbCloseArea())
	EndIf


Return

/*/{Protheus.doc} MenuDef
Montagem do Menu de ações.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@version    1.0
@return     aRotina, array contendo as opções do menu
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title "Visualizar"   Action "VIEWDEF.F1206401" OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"      Action "VIEWDEF.F1206401" OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"      Action "VIEWDEF.F1206401" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"	    Action "U_F1206EX()" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Montagem do modelo de dados da tabela P30 (Hospital x Clínicas).

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@version    1.0
@return     oModel, objeto MPFormModel, modelo de dados das tabelas P30
/*/
Static Function ModelDef()

	Local oModel    := Nil
	Local oStruP30  := Nil
	Local oStruP31  := Nil

    oModel      := MPFormModel():New("M1206401", /*bPreValidacao{|| TST001()}*/, /*/{|oModel| SetFront(oModel)}/*/, /*bCommit*/{|oModel| ReplicaFil(oModel)}, /*bCancel*/)

	oStruP30    := FwFormStruct(1, "P30")
	oStruP31    := FwFormStruct(1, "P31")
	cCodMat     := ""
	oModel:AddFields("P30MASTER", /*cOwner*/, oStruP30, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)
	oModel:AddGrid("P31DETAIL", "P30MASTER", oStruP31, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
	// Novo
	oModel:GetModel( "P31DETAIL" ):SetOptional(.T.)

	oModel:SetPrimaryKey({"FwXFilial('P30')", "P30_COD"})

	oModel:SetDescription("Rdsl Amarração de Unidades")

	oModel:SetRelation("P31DETAIL", {{"P31_FILIAL", "P30_FILIAL"}, {"P31_COD", "P30_COD"}}, P31->(IndexKey(1)))

	oModel:GetModel("P31DETAIL"):SetUniqueLine({"P31_FILIAL", "P31_CODFIL"})

	oModel:GetModel("P30MASTER"):SetDescription("Hospital")
	oModel:GetModel("P31DETAIL"):SetDescription("Clínicas")

	//Valida o Model para Ativa-lo
	oModel:SetVldActivate({|oModel| AtivaModel(oModel)})

Return oModel

/*/{Protheus.doc} ViewDef
Montagem da View.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@version    1.0
@return     oView, objeto FwFormView
/*/
Static Function ViewDef()

	Local oModel    := Nil
	Local oStruP30  := Nil
	Local oStruP31  := Nil
	Local oView     := Nil

	oModel      := FwLoadModel("F1206401")

	oStruP30    := FwFormStruct(2, "P30")
	oStruP31    := FwFormStruct(2, "P31")

	oView       := FwFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox("BOX", 100)

	oView:AddOtherObject("OBJ_TREE", {| painel, view, modelo| F12064TREE(painel, view, modelo)})

	oView:EnableTitleView("OBJ_TREE", "Hospital x Clínicas")

	oView:SetOwnerView("OBJ_TREE", "BOX")

Return oView

/*/{Protheus.doc} F12064TREE
Criação do Tree para manutenção dos dados.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@version    1.0
@param      oPanel, object, painel atual
@param      oView, object, objeto view
@param      oModel, object, modelo de dados
@return     Nil
/*/
Static Function F12064TREE(oPanel, oView, oModel)

	Local cFilMatriz    := ""

	Local oDbTree       := Nil
	Local oMenuPopUp    := Nil

	Default oPanel      := Nil
	Default oView       := FwViewActive()
	Default oModel      := FwModelActive()

	//Adiciona a Tree na View
	oDbTree := DbTree():New(0, 0, 500, 500, oPanel, {|| .T.}, {|| .T.}, .T.)

	oDbTree:Align := CONTROL_ALIGN_ALLCLIENT

	If oModel <> Nil
		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			oDbTree:BeginUpdate()
			If !(AddMatriz(@oDbTree, oModel))
				Help("", 1, "HELP", "Filial", "Para efetuar uma inclusão é necessário informar uma matriz.", 1, 0,,,,,,;
					{""})
			EndIf
		Else
			Processa({|| LoadTree(@oDbTree, oModel)}, "Carregando dados do Registro...", "")
		EndIf
	EndIf

	//Posição x, y em relação a Dialog
	oDbTree:BrClicked := {|tree, x, y| Menu(x, y, oDbTree, oModel, oView)}

Return Nil

/*/{Protheus.doc} ReplicaFil
Replica os dados da matriz para as filiais vinculadas.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@version    1.0
@param      oModel, object, modelo de dados
@return     .T., sempre verdadeiro
/*/
Static Function ReplicaFil(oModel)

	Local aArea         := {}
	//Local aCamposP31    := {}

	//Local cAliasP17     := ""
	Local cFilMatriz    := ""
	Local cQuery        := ""

	Local nCampo        := 0
	Local nFilial       := 0
	Local nLenModel     := 0
	Local nQtdCampo     := 0

	Local oModelP30     := Nil
	Local oModelP31     := Nil
	Local cFront := "" //Thais Paiva 166765526

	Default oModel  := FwModelActive()

	aArea       := {GetArea(), P17->(GetArea())}
	/*
    aCamposP31  := RetCampos("P31")

    oModelP30   := oModel:GetModel("P30MASTER")
    oModelP31   := oModel:GetModel("P31DETAIL")

    cFilMatriz  := oModelP30:GetValue("P30_CODFIL")

    nQtdCampo   := Len(aCamposP31)
    nLenModel   := oModelP31:Length()

    cQuery      := QryMatP17(cFilMatriz)

    cAliasP17   := GetNextAlias()

    MPSysOpenQuery(cQuery, cAliasP17)

    P17->(DbSetOrder(1))

    Begin Transaction
        While (cAliasP17)->(!(EoF()))
            For nFilial := 1 To nLenModel
                oModelP31:GoLine(nFilial)
                //Ignora linha deletada
                If oModelP31:IsDeleted()
                    Loop
                EndIf
                If P17->(DbSeek(FwXFilial("P17") + (cAliasP17)->P17_COD + oModelP31:GetValue("P31_CODFIL")))
                    Reclock("P17", .F.)
                    For nCampo := 1 To nQtdCampo
                        If oModelP31:GetValue(aCamposP31[nCampo]) == "2"
                            &("P17->" + MudaPrefix("P17", aCamposP31[nCampo])) := &("(cAliasP17)->" + MudaPrefix("P17", aCamposP31[nCampo]))
                        EndIf
                    Next nCampo
                    P17->(MsUnlock())
                EndIf
            Next nFilial
            (cAliasP17)->(DbSkip())
        End

        (cAliasP17)->(DbCloseArea())
    END TRANSACTION
	*/
	FwFormCommit(oModel)
	/*
    If ValType(oTempTable) == "O"
        If Select(oTempTable:GetAlias()) > 0
            (oTempTable:GetAlias())->(DbCloseArea())
        EndIf
        oTempTable:Delete()
        FwFreeObj(oTempTable)
        oTempTable := Nil
    EndIf
	*/
	AEval(aArea, {|area| RestArea(area)})

	oModelP30   := oModel:GetModel("P30MASTER") //Thais Paiva 166765526
	FRONTP31(oModelP30:GetValue("P30_COD"),oModelP30:GetValue("P30_CORP")) //Thais Paiva 166765526

Return .T.

/*/{Protheus.doc} MudaPrefix
Muda prefixo do campo conforme parametros informados.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cPrefixo, character, novo prefixo do campo
@param      cCampo, character, campo que terá seu prefixo modificado
@return     cCampo, campo com prefixo modificado
/*/
Static Function MudaPrefix(cPrefixo, cCampo)

	cCampo := cPrefixo + SubStr(cCampo, 4)

Return cCampo

/*/{Protheus.doc} QryMatP17
Query com todos os campos da tabela P17 referente a matriz replicação para as filiais vinculadas.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cMatriz, character, matriz do registro
@return     cQuery, query com campos tabela P17 referente a matriz.
/*/
/*Static Function QryMatP17(cMatriz)

    Local cQuery    := ""

    Default cMatriz := ""

    cQuery := " SELECT P17.* "
    cQuery += " FROM " + RetSQLName("P17") + " P17 "
    cQuery += " WHERE P17.D_E_L_E_T_ = ' '"
    cQuery += "   AND P17.P17_FILIAL = '" + FwXFilial("P17") + "' "
    cQuery += "   AND P17.P17_FTRATA = '" + cMatriz + "' "
    cQuery += " ORDER BY P17.P17_FILIAL, P17.P17_COD, P17.P17_FTRATA "

    cQuery := ChangeQuery(cQuery)

Return cQuery*/

/*/{Protheus.doc} AddMatriz
Adiciona matriz ao modelo de dados e a árvore do registro.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@return     lOk, sucesso ao adicionar matriz no modelo de dados e na arvore
/*/
Static Function AddMatriz(oDbTree, oModel)

    Local cFilName  := ""
    Local cMatriz   := ""
	Local cFront := "" //Thais Paiva - 166765526
    Local lOk       := .F.

    Local oModelP30 := Nil

    Default oModel    := FwModelActive()

    oModelP30 := oModel:GetModel("P30MASTER")

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        cMatriz := cCodMat
    Else
        cCodMat := oModelP30:GetValue("P30_CODFIL")
        cMatriz := oModelP30:GetValue("P30_CODFIL")
    EndIf
    oModelP30:SetValue("P30_CORP","2")

    cFilName := FwFilName(FwCodEmp(), cMatriz)

    If !(Empty(cMatriz)) .And. oModelP30:CanSetValue("P30_CODFIL") .And. oModelP30:SetValue("P30_CODFIL", cMatriz)
        cReplica := "Replica produto para Filial(ais) vinculada(s): " + IIf(oModelP30:GetValue("P30_REPLIC") == "1", "Sim", "Não")
		cFront := "Nome Front: " + Iif(!Empty(oModelP30:GetValue("P30_NFRONT")) ,oModelP30:GetValue("P30_NFRONT"),"Não Informado") //Thais Paiva - 166765526
        //oDbTree:AddTree(cMatriz + " - " + cFilName + " - (Matriz) - " + cReplica, .T., "PREDIO",,,, cMatriz) Thais Paiva - 166765526
		oDbTree:AddTree(cMatriz + " - " + cFilName + " - (Matriz) - " + cReplica + " - " + cFront, .T., "PREDIO",,,, cMatriz)
        lOk := .T.
    EndIf

Return lOk

/*/{Protheus.doc} AtivaModel
Rotina executada na ativação do modelo de dados.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oModel, object, modelo de dados
@return     lOk, sucesso ao ativar o modelo de dados
/*/
Static Function AtivaModel(oModel)

    Local lOk   := .T.

    Default oModel  := FwModelActive()

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        lOk := TelaFilial()
    EndIf

Return lOk

/*/{Protheus.doc} TelaFilial
Tela de login customizada para seleção de Filial.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@return     lOk, se a filial escolhida for a correta
/*/
Static Function TelaFilial()

    Local aArea         := {}

    Local cGetErro      := ""
    Local cGetFilial    := ""
    Local cTexto1       := ""

    Local lOk           := .F.

    Local nAltura       := 200
    Local nLargura      := 400

    Local oBtnConf      := Nil
    Local oDialog       := Nil
    Local oGetErro      := Nil
    Local oGetFilial    := Nil
    Local oSayFilial    := Nil
    Local oSayText1     := Nil

    aArea := {GetArea()}

    cGetFilial  := Space(Len(P30->P30_FILIAL))
//    cTexto1     := "Selecione uma Filial para se tornar uma matriz."
    cTexto1     := "Selecione uma Unidade para se tornar uma Matriz de Amarração."

    DEFINE MSDIALOG oDialog TITLE "Filial" FROM 000, 000  TO nAltura, nLargura COLORS 0, 16777215 PIXEL

    //Texto informativo
    @ 010, 006   SAY   oSayText1 PROMPT cTexto1 SIZE (nLargura / 2) - 12, 007 OF oDialog PIXEL

    //Say/Get da filial
    @ 053, 006   SAY   oSayFilial PROMPT "Filial Matriz:" SIZE 030, 007 OF oDialog PIXEL
    @ 060, 006   MSGET oGetFilial VAR    cGetFilial  SIZE (nLargura / 2) - 12, 007 OF oDialog COLORS 0, 16777215 PIXEL F3 "SM0"

    //Get de Log, pois se for Say, não da para definir a cor
    @ 040, 006   MSGET oGetErro VAR cGetErro SIZE (nLargura / 2) - 12, 007 OF oDialog COLORS 0, 16777215 NO BORDER PIXEL
    oGetErro:lActive := .F.
    oGetErro:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")

    //Botão de confirmação
    @ (nAltura / 2) - 18, 006 BUTTON oBtnConf PROMPT "Confirmar"    SIZE (nLargura / 2) - 12, 015 OF oDialog ;
        ACTION (lOk := ValidTdOk(oDialog, cGetFilial, @cGetErro, @oGetErro)) PIXEL
    oBtnConf:SetCSS("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")

    ACTIVATE MSDIALOG oDialog CENTERED

    If lOk .And. !(Empty(cGetFilial))
        cCodMat := AllTrim(cGetFilial)
    Else
        lOk     := .F.
        Help("", 1, "HELP", "Filial", "Para efetuar uma inclusão é necessário informar uma matriz.", 1, 0,,,,,,;
            {""})
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return lOk

/*/{Protheus.doc} ValidTdOk
Validação acionada no clique do botão confirmar.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDialog, object, objeto de tela
@param      oGetErro, object, objeto que mostra a mensagem de erro ao usuário presente na variável cGetErro
@param      cGetFilial, character, filial digitada pelo usuário
@param      cGetErro, character, mensagem de erro apresentada ao usuário
@return     lOk, verdadeiro caso a filial seja válida
/*/
Static Function ValidTdOk(oDialog, cGetFilial, cGetErro, oGetErro)

    Local lOk := .F.

    If Empty(cGetFilial)
        cGetErro := "Filial não pode estar em branco."
    ElseIf !(FwFilExist(FwCodEmp(), cGetFilial))
        cGetErro := "Filial inválida."
    ElseIf !(VldFilial2(cGetFilial))
        cGetErro := "Filial já vinculada a outro registro."
    Else
        lOk := .T.
    EndIf

    If !(lOk)
        oGetErro:Refresh()
    Else
        oDialog:End()
    EndIf

Return lOk

/*/{Protheus.doc} VldFilial
Validação acionada no clique do botão confirmar.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDialog, object, objeto de tela
@param      oGetErro, object, objeto que mostra a mensagem de erro ao usuário presente na variável cGetErro
@param      cGetFilial, character, filial digitada pelo usuário
@param      cGetErro, character, mensagem de erro apresentada ao usuário
@return     lOk, verdadeiro caso a filial seja válida
/*/
Static Function VldFilial(cNovFilial, nRecnoP30)

    Local cAliasQry := ""
    Local cQuery    := ""

    Local lOk   := .T.

    Default cNovFilial  := ""
    Default nRecnoP30   := Nil

    cQuery  := "SELECT P30.P30_CODFIL, P31.P31_CODFIL"
    cQuery  += "    FROM " + RetSQLName("P30") + " P30 "
    cQuery  += "    INNER JOIN  " + RetSQLName("P31") + " P31 ON"
    cQuery  += " P31.P31_FILIAL = P30.P30_FILIAL AND P31.P31_COD = P30.P30_COD"
    cQuery  += "WHERE P30.P30_FILIAL = '" + FwXFilial("P30") + "' "
    cQuery  += "  AND P31.P31_FILIAL = '" + FwXFilial("P31") + "' "
    cQuery  += "  AND (P30.P30_CODFIL = '" + cNovFilial + "' "
    cQuery  += "  OR P31.P31_CODFIL = '" + cNovFilial + "') "
    cQuery  += "  AND P30.D_E_L_E_T_ = ' ' "
    cQuery  += "  AND P31.D_E_L_E_T_ = ' ' "

    If !(Empty(nRecnoP30))
        cQuery  += "  AND P30.R_E_C_N_O_ <> " + CValToChar(nRecnoP30) + " "
    EndIf

    cQuery := ChangeQuery(cQuery)

    cAliasQry := MPSysOpenQuery(cQuery)

    If (cAliasQry)->(!(EoF()))
        lOk := .F.
    EndIf

    (cAliasQry)->(DbCloseArea())

Return lOk

/*/{Protheus.doc} Menu
Ativação do menu suspenso para habilitar as opções conforme a operação executada.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      nPosX, numeric, posição horizontal
@param      nPosY, numeric, posição vertical
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     Nil
/*/
Static Function Menu(nPosX, nPosY, oDbTree, oModel, oView)

    Local aMenuPopUp    := {}

    Local cFilMatriz    := ""

    Local nOperacao     := 0

    Local oMenuPopUp    := Nil

    Default oModel      := FwModelActive()
    Default oView       := FwViewActive()

    cFilMatriz := oDbTree:GetCargo()

    nOperacao := oModel:GetOperation()

    If !(Empty(cFilMatriz))
        MENU oMenuPopUp POPUP OF oDbTree

        If nOperacao == MODEL_OPERATION_VIEW
            If oDbTree:GetCargo() != cCodMat
                AAdd(aMenuPopUp,  MenuAddItem("Visualizar Campos Editáveis",,, .T.,,,, oMenuPopUp, {|| MarkCampos(oDbTree, oModel, oView)},,,,, {||.T.}))  //"Campos Alteráveis"
            EndIf
        ElseIf nOperacao == MODEL_OPERATION_INSERT
            If oDbTree:GetCargo() == cCodMat
                AAdd(aMenuPopUp,  MenuAddItem("Adicionar Amarração",,, .T.,,,, oMenuPopUp, {|| AddFilial(oDbTree, oModel)},,,,, {||.T.}))  //"Incluir Filial"
                AAdd(aMenuPopUp,  MenuAddItem("Altera Amarração",,, .T.,,,, oMenuPopUp, {|| SetReplic(oDbTree, oModel)},,,,, {||.T.}))  //"Altera Replicação"
				//AAdd(aMenuPopUp,  MenuAddItem("Altera Front",,, .T.,,,, oMenuPopUp, {|| SetFront(oDbTree, oModel)},,,,, {||.T.}))  //"Altera Front" Thais Paiva 16676552
                AAdd(aMenuPopUp,  MenuAddItem("Amarração Filial x Front",,, .T.,,,, oMenuPopUp, {|| U_XMSFRONTS(oDbTree, oModel)},,,,, {||.T.})) 
                AAdd(aMenuPopUp,  MenuAddItem("Amarração Campos Visíveis x Front",,, .T.,,,, oMenuPopUp, {|| U_XFCVF(oDbTree, oModel)},,,,, {||.T.})) 
                
            Else
                AAdd(aMenuPopUp,  MenuAddItem("Alterar Campos Editáveis",,, .T.,,,, oMenuPopUp, {|| MarkCampos(oDbTree, oModel, oView)},,,,, {||.T.}))  //"Campos Alteráveis"
                AAdd(aMenuPopUp,  MenuAddItem("Excluir Amarração",,, .T.,,,, oMenuPopUp, {|| RemoveFil(oDbTree)},,,,, {||.T.}))  //"Excluir"
               //AAdd(aMenuPopUp,  MenuAddItem("Amarração Filial x Front",,, .T.,,,, oMenuPopUp, {|| U_XMSFRONTS(oDbTree, oModel)},,,,, {||.T.})) 
            EndIf
        ElseIf nOperacao == MODEL_OPERATION_UPDATE
            If oDbTree:GetCargo() == cCodMat
                AAdd(aMenuPopUp,  MenuAddItem("Adicionar Amarração",,, .T.,,,, oMenuPopUp, {|| AddFilial(oDbTree, oModel)},,,,, {||.T.}))  //"Incluir Filial"
                AAdd(aMenuPopUp,  MenuAddItem("Altera Amarração",,, .T.,,,, oMenuPopUp, {|| SetReplic(oDbTree, oModel)},,,,, {||.T.}))  //"Altera Replicação"
				//AAdd(aMenuPopUp,  MenuAddItem("Altera Front",,, .T.,,,, oMenuPopUp, {|| SetFront(oDbTree, oModel)},,,,, {||.T.}))  //"Altera Front" Thais Paiva 16676552			
                AAdd(aMenuPopUp,  MenuAddItem("Amarração Filial x Front",,, .T.,,,, oMenuPopUp, {|| U_XMSFRONTS(oDbTree, oModel)},,,,, {||.T.})) 	
                AAdd(aMenuPopUp,  MenuAddItem("Amarração Campos Visíveis x Front",,, .T.,,,, oMenuPopUp, {|| U_XFCVF(oDbTree, oModel)},,,,, {||.T.})) 																														   
            Else
                AAdd(aMenuPopUp,  MenuAddItem("Alterar Campos Editáveis",,, .T.,,,, oMenuPopUp, {|| MarkCampos(oDbTree, oModel, oView)},,,,, {||.T.}))  //"Campos Alteráveis"
                AAdd(aMenuPopUp,  MenuAddItem("Excluir Amarração",,, .T.,,,, oMenuPopUp, {|| RemoveFil(oDbTree)},,,,, {||.T.}))  //"Excluir"
                //AAdd(aMenuPopUp,  MenuAddItem("Amarração Filial x Front",,, .T.,,,, oMenuPopUp, {|| U_XMSFRONTS(oDbTree, oModel)},,,,, {||.T.})) 
            EndIf
        EndIf

        ENDMENU

        oMenuPopUp:Activate(nPosX, nPosY - 180, oDbTree)
    EndIf

Return Nil

/*/{Protheus.doc} SetReplic
Atualiza se a matriz replica os dados ou não

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     Nil
/*/
Static Function SetReplic(oDbTree, oModel, oView)

    Local cFilName      := ""
    Local cMatriz       := ""
    Local cP30Replic    := ""
    Local cReplica      := ""
	Local cP30Corp    := ""//Thais Paiva - 166765526
    Local oModelP30 := Nil
	Local cFront      := "" //Thais Paiva - 166765526
	
    Default oModel  := FwModelActive()
    Default oView   := FwViewActive()

    oModelP30 := oModel:GetModel("P30MASTER")

    cP30Replic := AllTrim(oModelP30:GetValue("P30_REPLIC"))
	cP30Corp := IIF(Empty(AllTrim(oModelP30:GetValue("P30_CORP"))),"0",AllTrim(oModelP30:GetValue("P30_CORP"))) //Thais Paiva - 166765526

    If cP30Replic == "2"
        cP30Replic := "1"
    Else
        cP30Replic := "2"
    EndIf

    cMatriz     := oDbTree:GetCargo()
    cFilName    := FwFilName(FwCodEmp(), cMatriz)

    oModelP30:SetValue("P30_REPLIC", cP30Replic)

    cReplica := "Replica produto para Filial(ais) vinculada(s): " + IIf(cP30Replic == "1", "Sim", "Não")
	cFront := "Nome Front: " + Iif(!Empty(oModelP30:GetValue("P30_NFRONT")) ,oModelP30:GetValue("P30_NFRONT"),"Não Informado") //Thais Paiva - 166765526

    //oDbTree:ChangePrompt(cMatriz + " - " + cFilName + " - (Matriz) - " + cReplica) Thais Paiva - 166765526
	oDbTree:ChangePrompt(cMatriz + " - " + cFilName + " - (Matriz) - " + cReplica + " - " + cFront)

    oView:lModify           := .T.
    oView:oModel:lModify    := .T.

Return

/*/{Protheus.doc} MarkCampos
Browse de marcação para alteração/visualização dos campos para alteração.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     Nil
/*/
Static Function MarkCampos(oDbTree, oModel, oView)

    //Local aCriaTMP      := {}
    Local aEstrutura    := {}
    Local aColunas      := {}
    Local aIndice       := {}
    Local aP17Struct    := {}
    Local aP31Campos    := {}
    Local aRetorno      := {}
    Local aTamTela      := {}
	
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

    cP31Prefix := "P31"

    oModelP31 := oModel:GetModel("P31DETAIL")

    aP31Campos  := RetCampos(cP31Prefix)

    AAdd(aIndice, {"DEFAULT", {"P31_CAMPO"}})

    aTamTela := FwGetDialogSize()

    DEFINE MSDIALOG oDialog TITLE "Campos Alteráveis" FROM aTamTela[1], aTamTela[2] To aTamTela[3] / 1.5, aTamTela[4] / 1.5 COLORS 0, 16777215 PIXEL

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
    oMrkBrowse:SetDescription("Campos Alteráveis")
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

    LoadMkBrow(cAliasTMP, aP31Campos, oModel, oMrkBrowse)

    //ajustar confirmar para gravação do markbrowse no modelo de dados
    If oModel:GetOperation() == MODEL_OPERATION_VIEW
        oMrkBrowse:AddButton("Fechar",   {|| CloseBrowse()},, 2)
    Else
        oMrkBrowse:AddButton("Confirmar",  {|| GrvModelMk(cAliasTMP, oModel,, oDbTree), CloseBrowse()},, 4)
        oMrkBrowse:AddButton("Cancelar",   {|| CloseBrowse()},, 2)
    EndIf

    oMrkBrowse:Activate()

    ACTIVATE MSDIALOG oDialog CENTERED
    
	oTempTable:Delete() //Thais Paiva - 04/12/2020										   
Return Nil

/*/{Protheus.doc} RetCampos
Retorna os campos da estrutura conforme prefixo do alias informado.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cPrefixo, character, prefixo da tabela
@return     aCampos, array contendo os campos retornados
/*/
Static Function RetCampos(cPrefixo)

    Local aCampos       := {}
    Local aP17Struct    := {}

    Local cCampos       := ""

    Local nCampoP17     := 0
    Local nQtdCmpP17    := 0

    cCampos     := "P17_FILIAL|P17_COD|P17_FTRATA|P17_NFILIA|P17_FILNOM|P17_XUSRIN|P17_XUSRAL|P17_XMIGLT|"

    aP17Struct := P17->(DbStruct())

    nQtdCmpP17 := Len(aP17Struct)

    For nCampoP17 := 1 To nQtdCmpP17
        If !(aP17Struct[nCampoP17][1] $ cCampos) .And. (cPrefixo)->(FieldPos(MudaPrefix(cPrefixo, aP17Struct[nCampoP17][1]))) > 0
            AAdd(aCampos, MudaPrefix(cPrefixo, aP17Struct[nCampoP17][1]))
        EndIf
    Next nCampoP17

Return aCampos

/*/{Protheus.doc} CriaColuna
Retorna a estrutura e coluna para o browse de marcação.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      cPrefixo, character, prefixo da tabela
@return     aRetorno, array contendo [1] Estrutura e [2] Colunas FwBrwColumn
/*/
Static Function CriaColuna(cPrefixo)

    Local aColunas      := {}
    Local aEstrutura    := {}
    Local aRetorno      := {}

    Local nQtdColuna    := {}

    Local nCampo        := 0

    Default cPrefixo    := "P31"

    AAdd(aEstrutura, {"P31_OK",    "C",    001,    0})
    AAdd(aEstrutura, {"P31_CAMPO", "C",    010,    0})
    AAdd(aEstrutura, {"P31_DESC",  "C",    100,    0})

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

    Local cCampoP31     := ""

    Local oModelP31     := Nil

    Default cAliasTMP   := oTempTable:GetAlias()
    Default oModel      := FwModelActive()
    Default oView       := FwViewActive()
    Default oDbTree     := Nil

    If !(oModel:GetOperation() == MODEL_OPERATION_VIEW)
        oModelP31   := oModel:GetModel("P31DETAIL")

        (cAliasTMP)->(DbGoTop())

        If oModelP31:SeekLine({{"P31_CODFIL", oDbTree:GetCargo()}}, .F., .T.)
            While (cAliasTMP)->(!(EoF()))
                cCampoP31   := (cAliasTMP)->P31_CAMPO
                oModelP31:SetValue(cCampoP31, IIf(Empty((cAliasTMP)->P31_OK), "2", "1"))
                (cAliasTMP)->(DbSkip())
            End

            oView:lModify           := .T.
            oView:oModel:lModify    := .T.
        Else
            Help("", 1, "HELP", "Filial", "Filial não encontrada no registro.", 1, 0,,,,,,;
                {""})
        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} CriaTMP
Cria tabela temporária para uso no browse de marcação.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
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
Static Function LoadMkBrow(cAliasTMP, aCampos, oModel, oMrkBrowse)

    Local aRestRows := {}
    Local aArea     := {}

    Local cMarca    := ""

    Local lInclusao := .T.

    Local nCampo    := 0
    Local nLenALias := 0
    Local nQtdCampo := 0

    Local oModelP31 := Nil

    Default cAliasTMP   := oTempTable:GetAlias()
    Default aCampos     := {}
    Default oModel      := FwModelActive()

    oModelP31 := oModel:GetModel("P31DETAIL")

    aRestRows := FwSaveRows()

    DbSelectArea(cAliasTMP)

    Count To nLenALias
    lInclusao := !(nLenALias == Len(aCampos))

    (cAliasTMP)->(DbGoTop())

    nQtdCampo := Len(aCampos)

    aArea := {GetArea(), SX3->(GetArea())}

    cMarca := oMrkBrowse:Mark()

    If lInclusao
        For nCampo := 1 To nQtdCampo
            SX3->(DbSetOrder(2))
            SX3->(DbSeek(aCampos[nCampo]))
            Reclock(cAliasTMP, .T.)
            (cAliasTMP)->P31_OK     := IIf(oModelP31:GetValue(aCampos[nCampo]) == "1", cMarca, "")
            (cAliasTMP)->P31_CAMPO  := aCampos[nCampo]
            (cAliasTMP)->P31_DESC   := X3Descric()
            (cAliasTMP)->(MsUnlock())
        Next nCampo
    Else
        (cAliasTMP)->(DbGoToP())
        While (cAliasTMP)->(!(EoF()))
            RecLock(cAliasTMP, .F.)
            (cAliasTMP)->P31_OK     := IIf(oModelP31:GetValue((cAliasTMP)->P31_CAMPO) == "1", cMarca, "")
            (cAliasTMP)->(MsUnlock())
            (cAliasTMP)->(DbSkip())
        End
    EndIf

    FwRestRows(aRestRows)
    AEval(aArea, {|area| RestArea(area)})

Return Nil

/*/{Protheus.doc} RemoveFil
Remove filial do modelo de dados e da arvore do registro.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     lOk, se obteve sucesso na remoção da filial do registro
/*/
Static Function RemoveFil(oDbTree, oModel, oView)

    Local aRestRows := {}

    Local oModelP31 := Nil
    Local lOk := .T.

    Default oModel  := FwModelActive()
    Default oView   := FwViewActive()

    oModelP31 := oModel:GetModel("P31DETAIL")

    aRestRows := FwSaveRows()

    If oModelP31:SeekLine({{"P31_CODFIL", oDbTree:GetCargo()}}, .F., .T.)
        If oModelP31:CanDeleteLine() .And. oModelP31:DeleteLine()
            oDbTree:DelItem()
            oView:lModify           := .T.
            oView:oModel:lModify    := .T.
        Else
            lOk :=.F.
            Help("", 1, "HELP", "Filial", "Não foi possível deletar filial selecionada.", 1, 0,,,,,,;
                {""})
        EndIf
    Else
        lOk := .F.
        Help("", 1, "HELP", "Filial", "Filial não encontrada na tabela.", 1, 0,,,,,,;
            {""})
    EndIf

    FwRestRows(aRestRows)

Return lOk

/*/{Protheus.doc} AddFilial
Adiciona filial do modelo de dados e da arvore do registro.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oDbTree, object, arvore do registro
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     lOk, se obteve sucesso na adição da filial do registro
/*/
Static Function AddFilial(oDbTree, oModel, oView)

    Local aArea     := {}
//    Local aFilial   := {}

    Local cFilRet   := ""

    Local lOk       := .T.

    Local oModelP31 := Nil

    Default oModel  := FwModelActive()
    Default oView   := FwViewActive()

    aArea := {GetArea(), SM0->(GetArea()), P30->(GetArea())}

    lOk := ConPad1(,,, "SM0",,, .T., "cRetorno",, "")

    If lOk
        cFilRet := AllTrim(SM0->M0_CODFIL)
        If oDbTree:TreeSeek(cFilRet)
            lOk := .F.
            Help("", 1, "HELP", "Filial", "Filial já se encontra vinculada.", 1, 0,,,,,,;
                {"Selecione uma Filial que ainda não esteja vinculada."})
        ElseIf !(VldFilial(cFilRet, P30->(Recno())))
            lOk := .F.
            Help("", 1, "HELP", "Filial", "Filial já se encontra vinculada a outro registro.", 1, 0,,,,,,;
                {"Selecione uma Filial que ainda não foi utilizada."})
        EndIf
    EndIf

    If lOk
        oModelP30 := oModel:GetModel("P30MASTER")
        oModelP31 := oModel:GetModel("P31DETAIL")

        If !(oModelP31:IsEmpty() .And. oModelP31:Length() == 1)
            oModelP31:AddLine()
        EndIf
        oModelP31:SetValue("P31_COD", oModelP30:GetValue("P30_COD"))
        oModelP31:SetValue("P31_CODFIL", cFilRet)
		oModelP31:SetValue("P31_CORP", oModelP30:GetValue("P30_CORP")) //Thais Paiva 166765526
        oDbTree:AddItem(cFilRet + " - " + FwFilName(FwCodEmp(), cFilRet) + " - (Filial)", cFilRet, "PREDIO",,,, 2)

        oView:lModify           := .T.
        oView:oModel:lModify    := .T.
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return Nil

/*/{Protheus.doc} LoadTree
Carrega o objeto Tree conforme modelo de dados.

@project
@type       Static Function
@author     Rafael Riego
@since      10/12/2018
@param      oModel, object, modelo de dados
@param      oView, object, objeto view
@return     oDbTree, arvore do registro
/*/
Static Function LoadTree(oDbTree, oModel)

    //Local aRegistros    := {}

    Local cAliasQry     := ""
    Local cFilName      := ""
    Local cReplica      := ""
    Local cQuery        := ""
	Local cFront	    := "" //Thais Paiva 166765526
    Local lOk           := .T.
	Local cP30Corp		:= "" //Thais Paiva 166765526
    Local nFilial       := 0
    Local nLenModel     := 0

    Local oModelP30     := Nil
    Local oModelP31     := Nil

    Default oDbTree := Nil
    Default oModel  := FwModelActive()

    oModelP30 := oModel:GetModel("P30MASTER")
    oModelP31 := oModel:GetModel("P31DETAIL")

    oDbTree:BeginUpdate()

    cCodMat := oModelP30:GetValue("P30_CODFIL")
    

    cFilName := FwFilName(FwCodEmp(), cCodMat)
	
	cP30Corp := IIF(Empty(AllTrim(oModelP30:GetValue("P30_CORP"))),"0",AllTrim(oModelP30:GetValue("P30_CORP"))) //Thais Paiva - 166765526
	
    cReplica := "Replica produto para Filial(ais) vinculada(s): " + IIf(oModelP30:GetValue("P30_REPLIC") == "1", "Sim", "Não")
    cFront := "Nome Front: " + Iif(!Empty(oModelP30:GetValue("P30_NFRONT")) ,oModelP30:GetValue("P30_NFRONT"),"Não Informado") //Thais Paiva 166765526
    //oDbTree:AddTree(cCodMat + " - " + cFilName + " - (Matriz) - " + cReplica, .T., "PREDIO",,,, cCodMat) Thais Paiva 166765526
	oDbTree:AddTree(cCodMat + " - " + cFilName + " - (Matriz) - " + cReplica + " - " + cFront, .T., "PREDIO",,,, cCodMat)

    nLenModel := oModelP31:Length()

    For nFilial := 1 To nLenModel
        oModelP31:GoLine(nFilial)
        cFilName := FwFilName(FwCodEmp(), oModelP31:GetValue("P31_CODFIL"))

        oDbTree:AddItem(oModelP31:GetValue("P31_CODFIL") + " - " + cFilName + " - (Filial)", oModelP31:GetValue("P31_CODFIL"), "PREDIO",,,, 2)
    Next nFilial

    oDbTree:EndUpdate()

Return oDbTree

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | SetFront   | AUTORA| Thais Paiva            | DATA | 27/03/2023    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Monta os campos da estrutura Tratamento por Filial 	   |//
//+--------------------------------------------------------------------------------+//
//| CHAMADO    | 16676552 - INC0022878   										   |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
Static Function SetFront(oModel)

   // Local cFilName      := ""
    //Local cMatriz       := ""
    //Local cP30Replic    := ""
	Local cP30Corp    := "1"
    //Local cReplica      := ""
	//Local cFront      := ""

    Local oModelP30 := Nil

    Default oModel  := FwModelActive()
    //Default oView   := FwViewActive()

    oModelP30 := oModel:GetModel("P30MASTER")
    oModelP30:SetValue("P30_CORP", cP30Corp)

   /*/ cP30Replic := AllTrim(oModelP30:GetValue("P30_REPLIC"))
	cP30Corp := IIF(Empty(AllTrim(oModelP30:GetValue("P30_CORP"))),"0",AllTrim(oModelP30:GetValue("P30_CORP"))) //Thais Paiva - 166765526
	
	If cP30Corp == "2" 
        cP30Corp := "1"
    Else
        cP30Corp := "2"
    EndIf

    cMatriz     := oDbTree:GetCargo()
    cFilName    := FwFilName(FwCodEmp(), cMatriz)

    oModelP30:SetValue("P30_CORP", cP30Corp)

    cReplica := "Replica produto para Filial(ais) vinculada(s): " + IIf(cP30Replic == "1", "Sim", "Não")
	cFront := "Nome Front: " + Iif(!Empty(oModelP30:GetValue("P30_NFRONT")) ,oModelP30:GetValue("P30_NFRONT"),"Não Informado")

	oDbTree:ChangePrompt(cMatriz + " - " + cFilName + " - (Matriz) - " + cReplica + " - " + cFront)

    oView:lModify           := .T.
    oView:oModel:lModify    := .T.
/*/
Return .T.

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | FRONTP31    | AUTORA| Thais Paiva           | DATA | 27/03/2023    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Ajustar campo P31_CORP conforme campo P30_CORP		       |//
//+--------------------------------------------------------------------------------+//
//| CHAMADO    | 16676552 - INC0022878   										   |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
Static Function FRONTP31(_cCodP30,cFront)
Local _aArea := GetArea()

DbSelectArea("P31")
DbSetOrder(1)
If DbSeek(FwXFilial("P31")+_cCodP30)
	While P31->(!EOF()) .AND. Alltrim(P31->P31_COD) == _cCodP30
		If P31->P31_CORP <> cFront
			RecLock("P31",.F.)
			P31->P31_CORP := cFront
			P31->(MsUnlock())
		EndIf
		P31->(DbSkip())
	EndDo
EndIf

RestArea(_aArea)
Return 

Static Function VldFilial2(cNovFilial)

    Local cAliasQry := ""
    Local cQuery    := ""

    Local lOk   := .T.

    Default cNovFilial  := ""

    cQuery  := "SELECT P30.P30_CODFIL"
    cQuery  += "    FROM " + RetSQLName("P30") + " P30 "
    cQuery  += "WHERE 
    cQuery  += "  P30.P30_CODFIL = '" + cNovFilial + "' "
    cQuery  += "  AND P30.D_E_L_E_T_ = ' ' "


    cQuery := ChangeQuery(cQuery)

    cAliasQry := MPSysOpenQuery(cQuery)

    If (cAliasQry)->(!(EoF()))
        lOk := .F.
    EndIf

    (cAliasQry)->(DbCloseArea())

Return lOk
