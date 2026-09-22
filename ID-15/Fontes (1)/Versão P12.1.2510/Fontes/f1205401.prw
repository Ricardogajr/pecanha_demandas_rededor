#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F1205401()
Tela de visualização da tabela de preço
@Author  Fabrica de Software
@Since   10/07/2018
@Project MAN0000007423048_EF_054
@Param   oViewFather, objeto do modelo principal
@Return  lRet
*/
User Function F1205401(oViewFather)

	Local oStructAIA := FWFormStruct( 2 , "AIA" )
	Local oStructAIB := FWFormStruct( 2 , "AIB", {|cCampo| AllTrim(cCampo)+"|" $ "AIB_FILIAL|AIB_CODFOR|AIB_LOJFOR|AIB_CODTAB|AIB_ITEM|AIB_CODPRO|AIB_DESCRI|AIB_XREFER|AIB_PRCCOM|AIB_XDESFI|AIB_XCONTR|AIB_DATVIG|"} )
	Local oExecView  := FWViewExec():New()
	Local oModel     := oViewFather:GetModel()
	Local cTipRev    := SuperGetMV("FS_TRPREVT",.F.,"015")
	Local oView      := Nil
	Local lRet       := .T.
	Local cRevisao   := oViewFather:GetModel("CN9MASTER"):GetValue("CN9_TIPREV")
	Local cSituac    := oViewFather:GetModel("CN9MASTER"):GetValue("CN9_SITUAC")

	n := 0

	oStructAIA:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

	oStructAIB:RemoveField("AIB_XCONTR")
	oStructAIB:RemoveField("AIB_DATVIG")

	oView := FWFormView():New(oViewFather)
	oView:SetModel(oModel)

	oView:AddGrid("VIEW_AIB", oStructAIB, "AIBDETAIL")

	oView:CreateHorizontalBox("BOTTON", 100)

	oView:SetOwnerView("VIEW_AIB", "BOTTON")

	oView:EnableTitleView("VIEW_AIB" , "Itens da Tabela de Preço" )

	oView:AddIncrementField("VIEW_AIB","AIB_ITEM")

	oView:SetOperation(oViewFather:GetOperation())

	//Proteção para execução com View ativa.
	If Empty(cRevisao) .AND. cSituac == "09"
		MsgAlert("Necessário informar o tipo de revisão.")
	Else
		If oModel != Nil .And. oModel:IsActive()
			oExecView:SetModel(oModel)
			oExecView:SetView(oView)
			oExecView:SetTitle("Tabela de Preço")
			oExecView:SetReduction(30)
			oExecView:SetCloseOnOk({|| U_F1205412() })
			oExecView:OpenView(.F.)
			oExecView:SetOperation(oViewFather:GetOperation())
			If oExecView:GetButtonPress() == VIEW_BUTTON_OK
				lRet := U_F1205405()
			EndIf
		EndIf
	EndIf

Return lRet

/*
{Protheus.doc} F1205402()
Modelo de Dados da tabela de preço
@Author  Fabrica de Software
@Since   10/07/2018
@Project MAN0000007423048_EF_054
@Return  lRet
*/
User Function F1205402()

	Local oStructAIA  := FwFormStruct( 1 , "AIA" )
	Local oStructAIB  := FwFormStruct( 1 , "AIB", {|cCampo| AllTrim(cCampo)+"|" $ "AIB_FILIAL|AIB_CODFOR|AIB_LOJFOR|AIB_CODTAB|AIB_ITEM|AIB_CODPRO|AIB_DESCRI|AIB_XREFER|AIB_PRCCOM|AIB_XDESFI|AIB_XCONTR|AIB_DATVIG|"} )
	Local lRet        := .T.
	Local aAux1       := {}
	Local _nI         := 0 as numeric
	Local aAux2       := {}
	Local aSubModelos := PARAMIXB[1]:AALLSUBMODELS //9816749 - Thais Paiva
	Local _lAchou     := .F. //9816749 - Thais Paiva

	//Início - 9816749 - Thais Paiva
	For _nI := 1 To Len(aSubModelos)
		If Alltrim(aSubModelos[_nI]:CID) == "AIAMASTER"
			_lAchou := .T.
			Exit
		EndIf
	Next

	If !_lAchou
		//Fim - 9816749 - Thais Paiva
		oStructAIA:SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
		oStructAIB:SetProperty('AIB_CODPRO', MODEL_FIELD_OBRIGAT,.F.)
		oStructAIB:SetProperty('AIB_XCONTR', MODEL_FIELD_OBRIGAT,.F.)
		oStructAIB:SetProperty('AIB_CODPRO', MODEL_FIELD_VALID , {|| F1205411() })

		PARAMIXB[1]:AddFields("AIAMASTER", "CNADETAIL", oStructAIA, /*bPreValid*/, /*Pos-Validacao*/, /*Carga de Dados*/)
		PARAMIXB[1]:AddGrid("AIBDETAIL", "AIAMASTER", oStructAIB, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*Carga de Dados*/)

		PARAMIXB[1]:SetRelation("AIAMASTER", { {"AIA_FILIAL", "xFilial('AIA')"}, {"AIA_CODFOR", "CNA_FORNEC"}, {"AIA_LOJFOR", "CNA_LJFORN"}, {"AIA_CODTAB", "CNA_XTABPC"} , {"AIA_XCONTR", "CNA_CONTRA"} }, "AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB+AIA_XCONTR" )
		PARAMIXB[1]:SetRelation("AIBDETAIL", { {"AIB_FILIAL", "xFilial('AIB')"}, {"AIB_CODFOR", "AIA_CODFOR"}, {"AIB_LOJFOR", "AIA_LOJFOR"}, {"AIB_CODTAB", "AIA_CODTAB"} }, AIB->(IndexKey(1)) )

		PARAMIXB[1]:GetModel("AIBDETAIL"):SetDescription("Itens da Tabela de Preço")
		PARAMIXB[1]:GetModel("AIBDETAIL"):SetOptional(.T.)
		PARAMIXB[1]:GetModel("AIBDETAIL"):SetNoDeleteLine(.F.)

		aAux1 := FwStruTrigger("AIB_CODPRO","AIB_DESCRI","SB1->B1_DESC",.T.,"SB1",1,"xFilial('SB1')+M->AIB_CODPRO", , )
		aAux2 := FwStruTrigger("AIB_CODPRO","AIB_XREFER","SB1->B1_XREFER",.T.,"SB1",1,"xFilial('SB1')+M->AIB_CODPRO", , )

		//	PARAMIXB[1]:GetModel("AIBDETAIL"):SetUniqueLine( {"AIB_DESCRI"} )
		PARAMIXB[1]:GetModel("AIBDETAIL"):SetUniqueLine( {"AIB_CODPRO"} ) // ticket n° 10149401

		oStructAIB:AddTrigger( ;
			aAux1[1] , ;       // [01] Id do campo de origem
			aAux1[2] , ;       // [02] Id do campo de destino
			aAux1[3] , ;       // [03] Bloco de codigo de validação da execução do gatilho
			aAux1[4] )       // [04] Bloco de codigo de execução do gatilho

		oStructAIB:AddTrigger( ;
			aAux2[1] , ;       // [01] Id do campo de origem
			aAux2[2] , ;       // [02] Id do campo de destino
			aAux2[3] , ;       // [03] Bloco de codigo de validação da execução do gatilho
			aAux2[4] )       // [04] Bloco de codigo de execução do gatilho

	EndIf//9816749 - Thais Paiva

Return ( lRet )

/*
{Protheus.doc} F1205403()
Importação de dados para tabela de preço
@Author Fabrica de Software
@Since 10/07/2018
@Project MAN0000007423048_EF_054
@Param   oViewFather, objeto do modelo principal
*/
User Function F1205403(oViewPrinc)

	Local cArquivo :=  ""
	Local aDados   := {}
	Local oMdlAIB  := oViewPrinc:GetModel("AIBDETAIL")
	Local oMdlCNA  := oViewPrinc:GetModel("CNADETAIL")
	Local oMdlCN9  := oViewPrinc:GetModel("CN9MASTER")
	Local nX       := 0
	Local nQtd     := 0
	Local nHandle  := 0
	Local cContrat := oMdlCNA:GetValue("CNA_CONTRA")
	Local nOperAtu := oViewPrinc:GetOperation()
	Local aSaveLines := FWSaveRows()
	Local nY := 0
	Local cItem := ""

	If nOperAtu == 1
		MsgInfo("Não é permitido está ação na visualização!!")
		Return
	EndIf

	If oMdlCN9:GETVALUE("CN9_TIPREV") == "002"
		Help(NIL, NIL, "Importação de tabela de preço.", NIL, "Não é permitido fazer importação de tabela de preço em revisões do tipo 002.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor utilizar a revisão do tipo 015!"})
		Return
	EndIf

	cArquivo := cGetFile( '*.CSV|*.CSV' , 'Escolha o arquivo', 0, '\', .F., GETF_LOCALHARD,.F., .T. )

	If !Empty(cArquivo)

		If File(cArquivo)

			If ((nHandle := FT_FUse(Alltrim( cArquivo ))) == -1) //Carrega linhas do arquivo
				MsgInfo("Nao foi possivel abrir o arquivo "+ cArquivo+"! Processo Interrompido.")
				Return
			EndIf

			ProcRegua( FT_FLastRec() )

			FT_FGoTop()

			While !FT_FEof()

				IncProc()
				cInfLin := FT_FReadLn()
				aAdd( aDados, StrTokArr2( cInfLin, ";", .T. ))

				FT_FSkip()

			Enddo

			For nX := 1 to Len(aDados)

				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+Alltrim(aDados[nX][2])))

					nQtd := oMdlAIB:Length()
					oMdlAIB:GoLine(nQtd)
					oMdlAIB:lUpdateLine := .T.

					While !Empty(oMdlAIB:GetValue("AIB_CODPRO"))
						nQtd := oMdlAIB:AddLine(.T.)
						oMdlAIB:GoLine(nQtd)
					EndDo

					For nY := 01 To Len(oMdlAIB:ADATAMODEL)
						If !Empty(oMdlAIB:ADATAMODEL[nY][1][1][2])
							cItem := oMdlAIB:ADATAMODEL[nY][1][1][2]
						EndIf
					Next nY


					If Empty(cItem)
						cItem := StrZero(nQtd,4)
					else
						cItem := Soma1(cItem)
					EndIf
					oMdlAIB:SetValue("AIB_ITEM"  ,cItem)
					oMdlAIB:SetValue("AIB_CODPRO",Alltrim(aDados[nX][2]))
					oMdlAIB:SetValue("AIB_XREFER",Alltrim(aDados[nX][3]))
					oMdlAIB:SetValue("AIB_PRCCOM",VAL(aDados[nX][4]))
					oMdlAIB:SetValue("AIB_XDESFI",VAL(aDados[nX][5]))
					oMdlAIB:SetValue("AIB_XCONTR",cContrat)

				EndIf

			Next nX

			FWRestRows( aSaveLines )

		EndIf

	EndIf

Return

/*
{Protheus.doc} F1205404()
ViewDef da tabela de preço
@Author  Fabrica de Software
@Since   10/07/2018
@Project MAN0000007423048_EF_054
@Param   nOper, operação do modelo
@Return  aButtons, botões novos
*/
User Function F1205404(nOper)

	Local aButtons := {}

	If !(IsInCallStack("U_F1205401"))
		aButtons := {"Tabela de Preço", "CLIPS", { |oView| U_F1205401(oView) }, "Tabela de Preço" }
	Else
		aButtons := {"Importar Tabela", "CLIPS", { |oView| U_F1205403(oView) }, "Importar Tabela" }
	EndIf

Return aButtons

/*
{Protheus.doc} F1205405()
Gravação da tabela de preço vinculada ao contrato
@author  Fabrica de Software
@since   10/07/2018
@project MAN0000007423048_EF_054
*/
User Function F1205405()

	Local oMdl := FwModelActive()
	Local oMdlAIA := oMdl:GetModel("AIAMASTER")
	Local oMdlAIB := oMdl:GetModel("AIBDETAIL")
	Local oMdlCNA := oMdl:GetModel("CNADETAIL")
	Local oMdlCN9 := oMdl:GetModel("CN9MASTER")
	Local cTabPrc := oMdlCNA:GetValue("CNA_XTABPC")
	Local cTipRev := SuperGetMV("FS_TRPREVT",.F.,"015")
	Local nI      := 0
	Local nJ      := 0

	Begin Sequence

		If oMdl:GetOperation() == 3
			If !Empty(oMdlCN9:GetValue("CN9_TIPREV"))
				If oMdlCN9:GetValue("CN9_TIPREV") == cTipRev
					cTabPrc := ""
				Else
					Return
				EndIf
			EndIf
		EndIf

		DbSelectArea("AIA")
		AIA->(DbSetOrder(1))
		If Empty(cTabPrc)

			oMdlCNA:LoadValue("CNA_CONTRA",oMdlCN9:GetValue("CN9_NUMERO"))

			If AIA->(DBSeek(xFilial("AIA")+oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN")))
				cCodTabPrc := GetSX8NUM("AIA","AIA_CODTAB",oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN"))
				While AIA->(DbSeek(xFilial("AIA")+oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN")+cCodTabPrc))
					cCodTabPrc := GetSX8NUM("AIA","AIA_CODTAB",oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN"))
				EndDo
			Else
				cCodTabPrc := GetSX8NUM("AIA","AIA_CODTAB")
			EndIf

			oMdlAIA:LoadValue("AIA_CODTAB",cCodTabPrc)
			oMdlAIA:LoadValue("AIA_CODFOR",oMdlCNA:GetValue("CNA_FORNEC"))
			oMdlAIA:LoadValue("AIA_LOJFOR",oMdlCNA:GetValue("CNA_LJFORN"))
			oMdlAIA:LoadValue("AIA_DESCRI","Tabela-"+cCodTabPrc)
			oMdlAIA:LoadValue("AIA_DATDE",oMdlCN9:GetValue("CN9_DTINIC"))
			oMdlAIA:LoadValue("AIA_DATATE",oMdlCN9:GetValue("CN9_DTFIM"))
			oMdlAIA:LoadValue("AIA_CONDPG",oMdlCN9:GetValue("CN9_CONDPG"))
			oMdlAIA:LoadValue("AIA_XCONTR",oMdlCN9:GetValue("CN9_NUMERO"))

			For nI := 1 to oMdlAIB:Length()

				oMdlAIB:GoLine(nI)

				oMdlAIB:LoadValue("AIB_DATVIG",oMdlCN9:GetValue("CN9_DTFIM"))
				oMdlAIB:LoadValue("AIB_XCONTR",oMdlCN9:GetValue("CN9_NUMERO"))

			Next nI

			oMdlCNA:LoadValue("CNA_XTABPC",cCodTabPrc)

		Else

			For nJ := 1 to oMdlAIB:Length()

				oMdlAIB:GoLine(nJ)

				oMdlAIB:LoadValue("AIB_DATVIG",oMdlCN9:GetValue("CN9_DTFIM"))
				oMdlAIB:LoadValue("AIB_XCONTR",oMdlCN9:GetValue("CN9_NUMERO"))


			Next nJ

		EndIf

	End Sequence

Return

/*
{Protheus.doc} F1205406()
Carrega os itens tabela de preço
@author  Fabrica de Software
@since   30/07/2018
@project MAN0000007423048_EF_054
@Param   oMdl, Modelo de dados ativo
*/
User Function F1205406()

	Local aArea   := AIB->(GetArea())
	Local oMdl    := FwModelActive()
	Local cTbPrec := oMdl:GetModel("CNADETAIL"):GetValue("CNA_XTABPC")
	Local cFornec := oMdl:GetModel("CNADETAIL"):GetValue("CNA_FORNEC")
	Local cLjForn := oMdl:GetModel("CNADETAIL"):GetValue("CNA_LJFORN")
	Local oMdlAIB := oMdl:GetModel("AIBDETAIL")
	Local cRevisao := oMdl:GetModel("CN9MASTER"):GetValue("CN9_TIPREV")
	Local cTipRev  := SuperGetMV("FS_TRPREVT",.F.,"015")
	Local aDados  := {}
	Local aRet    := {}
	Local nX      := 0
	Local nI      := 0
	Local nY      := 0

	n := 0

	If !Empty(cTbPrec)
		DbSelectArea("AIB")
		AIB->(DbSetOrder(1))
		AIB->(DbSeek(xFilial("AIB")+cFornec+cLjForn+cTbPrec))
		While AIB->(!EOF()) .AND. AIB->(AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB) == xFilial("AIB")+cFornec+cLjForn+cTbPrec
			aAdd(aDados,{AIB->AIB_FILIAL,AIB->AIB_ITEM,AIB->AIB_CODPRO,AIB->AIB_XREFER,AIB->AIB_PRCCOM,AIB->AIB_XDESFI,AIB->AIB_XCONTR})
			AIB->(DbSkip())
		End
		oMdlAIB:lUpDateLine := .T.
		For nI := 1 to oMdlAIB:Length()

			If !Empty(oMdlAIB:GetValue("AIB_CODPRO"))
				oMdlAIB:GoLine(nI)
				oMdlAIB:DeleteLine()
			EndIf

		Next nI

		For nY := 1 to Len(aDados)

			oMdlAIB:GoLine(nY)

			If oMdlAIB:IsDeleted()
				oMdlAIB:UnDeleteLine()
			EndIf

			For nX := 1 to Len(aDados[nY])

				If nX > 1
					If nX == 2
						oMdlAIB:LoadValue("AIB_ITEM"  ,Alltrim(aDados[nY][nX]))
					ElseIf nX == 3
						oMdlAIB:LoadValue("AIB_CODPRO",Alltrim(aDados[nY][nX]))
						oMdlAIB:LoadValue("AIB_DESCRI",Posicione("SB1",1,xFilial("SB1")+Alltrim(aDados[nY][nX]),"B1_DESC"))
					ElseIf nX == 4
						oMdlAIB:LoadValue("AIB_XREFER",Alltrim(aDados[nY][nX]))
					ElseIf nX == 5
						oMdlAIB:LoadValue("AIB_PRCCOM",aDados[nY][nX])
					ElseIf nX == 6
						oMdlAIB:LoadValue("AIB_XDESFI",aDados[nY][nX])
					ElseIf nX == 7
						oMdlAIB:LoadValue("AIB_XCONTR",Alltrim(aDados[nY][nX]))
					EndIf
				EndIf

			Next nX

			If nY == Len(aDados)
				oMdlAIB:GoLine(nY)
			Else
				oMdlAIB:AddLine(.T.)
			EndIf

		Next nY

	EndIf

	If !Empty(cRevisao) .AND. Alltrim(cRevisao) <> Alltrim(cTipRev)
		aAdd(aRet,{'AIBDETAIL',{'AIB_FILIAL','AIB_ITEM','AIB_CODPRO','AIB_DESCRI','AIB_XREFER','AIB_PRCCOM','AIB_XDESFI','AIB_XCONTR','AIB_DATVIG'}})
		MtBCMod(oMdl,aRet,{||.F.},'2')
	EndIf

	RestArea(aArea)

Return .T.

/*
{Protheus.doc} F1205407()
Carrega os itens tabela de preço
@author  Fabrica de Software
@since   31/07/2018
@project MAN0000007423048_EF_054
@Param   oMdl, Modelo de dados ativo
*/
User Function F1205407()

	Local aRet := {}
	Local oMdl := FwModelActive()
	Local cRevisao := oMdl:GetModel("CN9MASTER"):GetValue("CN9_TIPREV")
	Local cTipRev  := SuperGetMV("FS_TRPREVT",.F.,"015")
	Local aCampMdl := {}

	If !Empty(cRevisao) .AND. Alltrim(cRevisao) == Alltrim(cTipRev)
		aAdd(aRet,'AIAMASTER')
		aAdd(aRet,'AIBDETAIL')

		MtBCMod(oMdl,aRet,{||.T.},)
	ELSE
		aAdd(aRet,{'AIBDETAIL',{'AIB_FILIAL','AIB_ITEM','AIB_CODPRO','AIB_DESCRI','AIB_XREFER','AIB_PRCCOM','AIB_XDESFI','AIB_XCONTR','AIB_DATVIG'}})

		MtBCMod(oMdl,aRet,{||.T.},'2')
	EndIf

	aAdd(aCampMdl,{'CN9MASTER',{'CN9_XENVPC','CN9_XEMAIL','CN9_CONDPG','CN9_DESCPG','CN9_XFATMI'}})
	MtBCMod(oMdl,aCampMdl,{||.T.},'2')

	aRet := {}

Return aRet

/*
{Protheus.doc} F1205408()
Carrega os itens tabela de preço
@author  Fabrica de Software
@since   31/07/2018
@project MAN0000007423048_EF_054
@Param   oMdl, Modelo de dados ativo
*/
User Function F1205408()

	Local oMdl := FwModelActive()
	Local oMdlAIA := oMdl:GetModel("AIAMASTER")
	Local oMdlAIB := oMdl:GetModel("AIBDETAIL")
	Local oMdlCNA := oMdl:GetModel("CNADETAIL")
	Local oMdlCN9 := oMdl:GetModel("CN9MASTER")
	Local cSituac := oMdlCN9:GetValue("CN9_SITUAC")
	Local lRet    := .T.
	Local nI      := 0
	Local nJ      := 0
	Local aRet    := {}

	If oMdl:GetOperation() == 3 .AND. cSituac == "09"

		aAdd(aRet,'AIAMASTER')
		aAdd(aRet,'AIBDETAIL')

		MtBCMod(oMdl,aRet,{||.T.},)

		oMdlCNA:LoadValue("CNA_CONTRA",oMdlCN9:GetValue("CN9_NUMERO"))

		If AIA->(DBSeek(xFilial("AIA")+oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN")))
			cCodTabPrc := GetSX8NUM("AIA","AIA_CODTAB",oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN"))
			While AIA->(DbSeek(xFilial("AIA")+oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN")+cCodTabPrc))
				cCodTabPrc := GetSX8NUM("AIA","AIA_CODTAB",oMdlCNA:GetValue("CNA_FORNEC")+oMdlCNA:GetValue("CNA_LJFORN"))
			EndDo
		Else
			cCodTabPrc := GetSX8NUM("AIA","AIA_CODTAB")
		EndIf

		oMdlCNA:LoadValue("CNA_XTABPC",cCodTabPrc)

		oMdlAIA:LoadValue("AIA_CODTAB",cCodTabPrc)
		oMdlAIA:LoadValue("AIA_CODFOR",oMdlCNA:GetValue("CNA_FORNEC"))
		oMdlAIA:LoadValue("AIA_LOJFOR",oMdlCNA:GetValue("CNA_LJFORN"))
		oMdlAIA:LoadValue("AIA_DESCRI","Tabela-"+cCodTabPrc)
		oMdlAIA:LoadValue("AIA_DATDE",oMdlCN9:GetValue("CN9_DTINIC"))
		oMdlAIA:LoadValue("AIA_DATATE",oMdlCN9:GetValue("CN9_DTFIM"))
		oMdlAIA:LoadValue("AIA_CONDPG",oMdlCN9:GetValue("CN9_CONDPG"))
		oMdlAIA:LoadValue("AIA_XCONTR",oMdlCN9:GetValue("CN9_NUMERO"))

		For nI := 1 to oMdlAIB:Length()

			oMdlAIB:GoLine(nI)

			If !Empty(oMdlAIB:GetValue("AIB_CODPRO"))
				oMdlAIB:LoadValue("AIB_DATVIG",oMdlCN9:GetValue("CN9_DTFIM"))
				oMdlAIB:LoadValue("AIB_XCONTR",oMdlCN9:GetValue("CN9_NUMERO"))
			EndIf
		Next nI

	EndIf

Return lRet

/*
{Protheus.doc} F1205409()
Botão para Sobrepor a Tabela existe
@Author  Fabrica de Software
@Since   18/04/2019
@Project MAN0000007423048_EF_054
@Param   nOper, operação do modelo
@Return  aButtons, botões novos
*/
User Function F1205409(nOper)

	Local aButtons := {}

	aButtons := {"Sobrepor Tabela", "CLIPS", { |oView| U_F1205410(oView) }, "Sobrepor Tabela" }

Return aButtons


/*
{Protheus.doc} F1205410()
Importação de dados para tabela de preço - Sobrepor os dados da tabela.
@Author Fabrica de Software
@Since 18/04/2019
@Project MAN0000007423048_EF_054
@Param   oViewFather, objeto do modelo principal
*/
User Function F1205410(oViewPrinc)

	Local cArquivo   := ""
	Local aDados     := {}
	Local aProd      := {}
	Local oMdlAIB    := oViewPrinc:GetModel("AIBDETAIL")
	Local oMdlCNA    := oViewPrinc:GetModel("CNADETAIL")
	Local oMdlCN9    := oViewPrinc:GetModel("CN9MASTER")
	Local nI         := 0
	Local nX         := 0
	Local nQtd       := 0
	Local nHandle    := 0
	Local cContrat   := oMdlCNA:GetValue("CNA_CONTRA")
	Local nOperAtu   := oViewPrinc:GetOperation()
	Local aSaveLines := FWSaveRows()

	If nOperAtu == 1
		MsgInfo("Não é permitido está ação na visualização!!")
		Return
	EndIf


	If oMdlCN9:GETVALUE("CN9_TIPREV") == "002"
		Help(NIL, NIL, "Sobreposição de tabela de preço.", NIL, "Não é permitido fazer sobreposição de tabela de preço em revisões do tipo 002.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor utilizar a revisão do tipo 015!"})
		Return
	EndIf


	cArquivo := cGetFile( '*.CSV|*.CSV' , 'Escolha o arquivo', 0, '\', .F., GETF_LOCALHARD,.F., .T. )

	If !Empty(cArquivo)

		If File(cArquivo)

			If ((nHandle := FT_FUse(Alltrim( cArquivo ))) == -1) //Carrega linhas do arquivo
				MsgInfo("Nao foi possivel abrir o arquivo "+ cArquivo+"! Processo Interrompido.")
				Return
			EndIf

			ProcRegua( FT_FLastRec() )

			FT_FGoTop()

			While !FT_FEof()

				IncProc()
				cInfLin := FT_FReadLn()
				aAdd( aDados, StrTokArr2( cInfLin, ";", .T. ))

				FT_FSkip()

			Enddo

			//Deleta os registros existentes
			For nI := 1 to oMdlAIB:Length()
				oMdlAIB:GoLine(nI)
				oMdlAIB:DeleteLine()
			Next nI

			For nX := 1 to Len(aDados)

				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+Alltrim(aDados[nX][2])))
					nQtd := oMdlAIB:AddLine(.T.)
					oMdlAIB:GoLine(nQtd)
					oMdlAIB:lUpdateLine := .T.
					oMdlAIB:SetValue("AIB_ITEM"  ,StrZero(nQtd,4))
					oMdlAIB:SetValue("AIB_CODPRO",Alltrim(aDados[nX][2]))
					oMdlAIB:SetValue("AIB_XREFER",Alltrim(aDados[nX][3]))
					oMdlAIB:SetValue("AIB_PRCCOM",VAL(aDados[nX][4]))
					oMdlAIB:SetValue("AIB_XDESFI",VAL(aDados[nX][5]))
					oMdlAIB:SetValue("AIB_XCONTR",cContrat)
				Endif

			Next nX

			oMdlAIB:SetNoDeleteLine(.T.)

			FWRestRows( aSaveLines )

		EndIf

	EndIf

Return

/*
{Protheus.doc} F1205411()
Função para validar se o produto já foi informado.
@Author Fabrica de Software
@Since 18/04/2019
@Project MAN0000007423048_EF_054
@Param   oViewFather, objeto do modelo principal
*/
Static Function F1205411()

	Local lRet     := .T.
	Local oMdl     := FwModelActive()
	Local oMdlAIB  := oMdl:GetModel("AIBDETAIL")
	Local nLinAtu  := oMdlAIB:nLine
	Local nX       := 0
	Local cProdAtu := ""

	oMdlAIB:GoLine(nLinAtu)
	cProdAtu := oMdlAIB:GetValue("AIB_CODPRO")

	For nX := 1 to oMdlAIB:Length()
		oMdlAIB:GoLine(nX)
		IF !oMdlAIB:IsDeleted()
			If nLinAtu <> nX .And. !Empty(oMdlAIB:GetValue("AIB_CODPRO")) .And. cProdAtu == oMdlAIB:GetValue("AIB_CODPRO")
				lRet := .F.
				Exit
			Endif
		Endif
	Next nX

	oMdlAIB:GoLine(nLinAtu)

Return(lRet)

/*
{Protheus.doc} F1205412()
Função na validação do botão confimar.
@Author Fabrica de Software
@Since 18/04/2019
@Project MAN0000007423048_EF_054
@Param   oViewFather, objeto do modelo principal
*/
User Function F1205412()

	Local lRet     := .T.
	Local oMdl     := FwModelActive()
	Local oMdlAIB  := oMdl:GetModel("AIBDETAIL")
	Local nLinAtu  := oMdlAIB:nLine
	Local cProdAtu := ""
	Local nX       := 0
	Local nY       := 0

	Public _lxAltAIB := .F.

	IF IsInCallStack('buttonokaction') //buttonokaction - função utilizada quando for pressionado o botão confirmar.
		For nY := 1 to oMdlAIB:Length()
			oMdlAIB:GoLine(nY)
			cProdAtu := oMdlAIB:GetValue("AIB_CODPRO")
			IF !oMdlAIB:IsDeleted()
				IF Empty(oMdlAIB:GetValue("AIB_CODPRO"))
					Help( , , 'Help', 'F1205412', 'O produto não foi informado!', 1, 0 )
					lRet := .F.
				Endif
				IF lRet
					For nX := 1 to oMdlAIB:Length()
						oMdlAIB:GoLine(nX)
						IF !oMdlAIB:IsDeleted()
							If nY <> nX
								IF !Empty(oMdlAIB:GetValue("AIB_CODPRO")) .And. cProdAtu == oMdlAIB:GetValue("AIB_CODPRO")
									Help( , , 'Help', 'F1205411', 'O produto '+cProdAtu+' está duplicado na tabela de preço.', 1, 0 )
									lRet := .F.
								Endif
							Endif
						Else
							_lxAltAIB := .T.
						Endif
					Next nX
				Endif
			Endif
		Next nY
		oMdlAIB:GoLine(nLinAtu)
	Endif

	oMdlAIB:SetNoDeleteLine(.F.)

Return(lRet)
