#Include "Protheus.ch"

#DEFINE DEF_DOCUMENTO  01 //[01] Número do Documento
#DEFINE DEF_TIPO_DOC   02 //[02] Tipo de Documento
#DEFINE DEF_VALOR_DOC  03 //[03] Valor do Documento
#DEFINE DEF_APROVADOR  04 //[04] Código do Aprovador
#DEFINE DEF_USUARIO    05 //[05] Código do Usuário
#DEFINE DEF_GRP_APROV  06 //[06] Grupo do Aprovador
#DEFINE DEF_APROV_SUP  07 //[07] Aprovador Superior
#DEFINE DEF_MOEDA_DOC  08 //[08] Moeda do Documento
#DEFINE DEF_TX_MOEDA   09 //[09] Taxa da Moeda
#DEFINE DEF_DT_EMISSAO 10 //[10] Data de Emissão do Documento
#DEFINE DEF_NIVEL      13 //[13] Nivel

/*/{Protheus.doc} FLGREPRO
Rotina que realiza o reprocessamento das mensagens com erro na P20 para o FLUIG

@project
@type       User Function
@author     Lucas Miranda
@since      27/11/2019
@version    1.0.0
@return     Erro(1) ou Sucesso(2)
/*/
User Function FLGREPRO(cEmpCon, cFilCon,ckey)

	Local aDocument     := {}
	Local aRetorno      := {}

	Local cAliasQry     := ""
	Local cFilialBkp    := ""
	Local cQuery        := ""

	Local lEnviar       := .F.
	Local lOk           := .T.
	Local lEnviou       := .F.

	Local nOperation    := 0
	Local nSM0Recno     := 0
	Local cNumSCR		:= ""
	Local cTipoSCR		:= ""
	Local cFilSCR		:= ""

	Local oAttach       := Nil
	

	Local cStatus 	:= "1"
	Local cRotina 	:= "U_FLUIGP20"
	Local cAlias  	:= "SCR"
	Local cTipo     := ""
	Local cIndkey 	:= ""
	Local cInput	:= ""
	Local cOpera	:= ""
	
	Private cOutput 	:= ""
	Private oCardData	:= Nil
	Private cNomeFil	:= ""

	Default cEmpCon     := ""
	Default cFilCon     := ""
	Default ckey     	:= ""

	If !(Select("SX2") > 0)
		RpcSetEnv(cEmpCon, cFilCon)
		If !(Select("SX2") > 0)
			lOk         := .F.
			Conout("Erro na abertura de ambiente em JOB")
		EndIf
	EndIf

	cNumSCR  := SubStr(ckey,23,6)
	cTipoSCR := SubStr(ckey,30,2)
	cFilSCR  := SubStr(ckey,14,8)
	
	If AllTrim(cTipoSCR) == "SP"
		cTipoSCR := "PC"
	EndIF

	If lOk
		SCR->(DbGoTop())
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(cFilSCR + cTipoSCR + cNumSCR))

			While SCR->(!(EoF())) .And.;
			AllTrim(SCR->CR_FILIAL) == AllTrim(cFilSCR) .And. AllTrim(SCR->CR_TIPO) == AllTrim(cTipoSCR) .And.;
			AllTrim(SCR->CR_NUM) == AllTrim(cNumSCR)

				If (SCR->CR_XFLINTE == "1" .Or. Empty(SCR->CR_XFLINTE))  .And. SCR->CR_STATUS $ "02" .And. Empty(SCR->CR_XIDFLG)
					nOperation := 1
					lEnviar := .T.
					AAdd(aDocument, SCR->CR_NUM)            // DEF_DOCUMENTO  01 - [01] Número do Documento
					AAdd(aDocument, SCR->CR_TIPO)           // DEF_TIPO_DOC   02 - [02] Tipo de Documento
					AAdd(aDocument, SCR->CR_TOTAL)          // DEF_VALOR_DOC  03 - [03] Valor do Documento
					AAdd(aDocument, SCR->CR_APROV)          // DEF_APROVADOR  04 - [04] Código do Aprovador
					AAdd(aDocument, SCR->CR_USER)           // DEF_USUARIO    05 - [05] Código do Usuário
					AAdd(aDocument, SCR->CR_GRUPO)          // DEF_GRP_APROV  06 - [06] Grupo do Aprovador
					AAdd(aDocument, "") //não será necessário       // DEF_APROV_SUP  07 - [07] Aprovador Superior
					AAdd(aDocument, SCR->CR_MOEDA)          // DEF_MOEDA_DOC  08 - [08] Moeda do Documento
					AAdd(aDocument, SCR->CR_TXMOEDA)        // DEF_TX_MOEDA   09 - [09] Taxa da Moeda
					AAdd(aDocument, SCR->CR_EMISSAO)  		// DEF_DT_EMISSAO 10 - [10] Data de Emissão do Documento
					AAdd(aDocument, "")                             //                   -
					AAdd(aDocument, "")                             //                   -
					AAdd(aDocument, SCR->CR_NIVEL)          // DEF_NIVEL      13 - [13] Nivel
				ElseIf SCR->CR_XFLINTE == "2" .And. !(Empty(SCR->CR_XIDFLG)) .And. SCR->CR_STATUS $ "03|04|05|06"
					nOperation  := 4
					lEnviar     := .T.
				EndIf

				If lEnviar
					cLoginApr := Identity(SCR->CR_USER)
					cNomeFil  := NomFil(SCR->CR_FILIAL)
					If nOperation == 1
						oCardData   := CardDataBO(aDocument, cLoginApr)
					EndIf
					oAttach     := U_F1701102(, Identity(SCR->CR_USER),, AllTrim(SCR->CR_NUM),,, SCR->CR_TIPO)
					aRetorno    := U_F1700101(.T., aDocument, nOperation, Val(SCR->CR_XIDFLG),,, oAttach)
					If Empty(aRetorno)
						Conout("FLUIG aRetorno vazio.(Não voltou resposta nenhuma do FLUIG.)")
					Else
					
							cTipo := AllTrim(aDocument[2])
							cInput := "U_FLUIGP20(,,,"+ AllTrim(SCR->CR_NUM) +")"
							If cTipo == "PC"							
								If !SolitPagto(AllTrim(aDocument[1]), cTipo)
									cOpera := SuperGetMv("FS_PCFLG", .F., "app_pedido_compras")
								Else
									cOpera := SuperGetMv("FS_SPFLG", .F., "app_solicitacao_pagamentos")
								EndIf
							ElseIf cTipo == "SC"					
								cOpera := SuperGetMv("FS_SCFLG", .F., "app_solicitacao_compras")
							EndIf
							cIndkey := "FLUIG|"+AllTrim(cFilSCR) + "|" + AllTrim(aDocument[1]) + "|" + AllTrim(aDocument[2])+ "|" + AllTrim(aDocument[13])+"|"+ AllTrim(cOpera)
					
						If AllTrim(aRetorno[2]) != ""
							cStatus := "2"
							lEnviou := .T.
							RecLock("SCR", .F.)
							SCR->CR_XFLINTE := "2"
							SCR->CR_XIDFLG  := aRetorno[2]
							SCR->(MsUnlock())
						EndIf
					EndIf
					ASize(aDocument, 0)
					aDocument := {}
					lEnviar := .F.
					FwFreeObj(oAttach)
				EndIf
				SCR->(DbSkip())

			End
			U_F07Log03(cRotina,AllTrim(cInput),cOutput,cStatus,cAlias,1,cIndKey)
		End

		SCR->(DbCloseArea())
		//Restaura valor original da variável cFilAnt
		If !(Empty(cFilialBkp))
			cFilAnt     := cFilialBkp
			cFilialBkp  := ""
			SM0->(DbGoTo(nSM0Recno))
		EndIf
	EndIf

Return lEnviou

User Function TSTJob2()

	While AlwaysTrue()
		Sleep(30000)
		U_FLGREPRO("01", "01010004")
	End

Return Nil

Static Function Identity(cCodUser)

	Local cIdentity := ""

	cIdentity := UsrRetCPF(cCodUser)

Return cIdentity

Static Function UsrRetCPF(cCodUser)

	Local aArea     := {}
	//Local aUser     := {}

	Local cFilUser  := ""
	Local cMatUser  := ""
	Local cFilMat   := ""

	Local nTamEmp   := 0
	Local nTamFil   := 0

	nTamEmp := Len(AllTrim(FwCodEmp()))
	nTamFil := Len(AllTrim(FwCodFil()))

	//Busca vinculo funcional
	PswOrder(1)
	If (PswSeek(cCodUser, .T.))
		cFilMat := PswRet()[1][22]

		cFilUser := SubStr(cFilMat, nTamEmp + 1, nTamFil)
		cMatUser := SubStr(cFilMat, nTamEmp + nTamFil + 1, 6)

		If !(Empty(cFilUser)) .And. !(Empty(cMatUser))
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(cFilUser + cMatUser))
				cIdentity := SRA->RA_CIC
			EndIf
		EndIf
	EndIf

Return cIdentity

Static Function NomFil(cFil)

	Local aAreaSM0 := SM0->(GetArea())
	Local cNomeFil := ""
	
	Default cFil := ""

	cNomeFil := AllTrim(Posicione("SM0",1,"01"+cFil,"M0_FILIAL"))

	RestArea(aAreaSM0)
	
Return cNomeFil


Static Function GrvXFluig(cFluigId, cStatus1)

	Local cUsrFlg := "2"

	Default cFluigId    := ""
	Default cStatus1    := ""

	RecLock("SCR", .F.)
	SCR->CR_XFLINTE := cStatus
	If !(Empty(cFluigId))
		SCR->CR_XIDFLG  := cFluigId
	EndIf
	SCR->(MsUnlock())

Return Nil

Static Function SolitPagto(cSCRNum, cSCRTipo)

	Local aArea         := {}

	Local lSolitPagt    := .F.

	aArea := {GetArea(), SC7->(GetArea())}

	SC7->(DbSetOrder(1))
	If SC7->(DbSeek(SCR->CR_FILIAL + PadR(cSCRNum, TamSX3("C7_NUM")[1])))
		If SC7->C7_XSOLPAG == "1"
			lSolitPagt  := .T.
		EndIf
	EndIf

	AEval(aArea, {|area| RestArea(area)})

Return lSolitPagt

/*/{Protheus.doc} CardDataBO
Monta o cardData para envio ao formulário do Fluig conforme tipo do documento.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@param      cLoginApr, character, login do aprovador
@return     lSolitPagt, se é solicitação de pagamento ou não
/*/
Static Function CardDataBO(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local oCardData     := Nil

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea())}

	If !(Empty(aDocument))
		If aDocument[2] == "SC"
			aCardData := CardDataSC(aDocument, cLoginApr)
		ElseIf aDocument[2] == "PC"
			If SolitPagto(aDocument[1], aDocument[2])
				aCardData := CardDataSP(aDocument, cLoginApr)
			Else
				aCardData := CardDataPC(aDocument, cLoginApr)
			EndIf
		ElseIf aDocument[2] == "CT"
			aCardData := CardDataCT(aDocument)
		ElseIf aDocument[2] == "MD"
			aCardData := CardDataMD(aDocument)
		ElseIf aDocument[2] == "RV"
			aCardData := CardDataRV(aDocument)
		EndIf

		oCardData := CardData(aCardData)

		FwFreeObj(aCardData)
		aCardData   := Nil
	EndIf

Return oCardData

Static Function CardData(aCardData)

	Local aFormulari    := {}

	Local nCardData     := 0
	Local nTamCardDt    := 0

	Default aCardData   := {}

	nTamCardDt := Len(aCardData)

	For nCardData := 1 To nTamCardDt
		AAdd(aFormulari, WSClassNew("ECMWorkflowEngineServiceService_stringArray"))
		aFormulari[nCardData]:cItem   := AClone(aCardData[nCardData])
	Next nCardData

	oCardData   := WSClassNew("ECMWorkflowEngineServiceService_stringArrayArray")

	oCardData:oWSItem := AClone(aFormulari)

Return oCardData

Static Function CardDataSC(aDocument)

	Local aArea         := {}
	Local aCardData     := {}

	Local cCodFornec    := ""
	Local cDescricao    := ""
	Local cFilialSC1    := ""
	Local cScNum		:= ""
	Local cFornecedor   := ""
	Local cLinhaDesc    := ""
	Local cLoginApr     := ""
	Local cNomeAprv     := ""
	Local nItemCod      := 0
	Local nItemDesc     := 0
	Local nItemQuant    := 0
	Local nItemVUnit	:= 0
	Local nItemSubTot   := 0
	Local nQtdCount		:= 0


	Default aDocument   := {}

	aArea := {GetArea(), SCR->(GetArea()), SC1->(GetArea())}

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cLoginApr := Identity(SCR->CR_USER)

	SC1->(DbSetOrder(1))
	cFilialSC1 := SCR->CR_FILIAL
	If SC1->(DbSeek(cFilialSC1 + PadR(SCR->CR_NUM, TamSX3("C1_NUM")[1])))

		cCodFornec  := SC1->C1_FORNECE
		cFornecedor := AllTrim(GetAdvFVal("SA2", "A2_NOME", FwXFilial("SA2") + cCodFornec + SC1->C1_LOJA, 1 , "NOME NÃO ENCONTRADO"))
		cScNum	:= SC1->C1_NUM
		
		cDescricao := "Solicitante: " + AllTrim(SCR->CR_XCOMSOL) + CRLF 
		cDescricao += "FILIAL: " + cFilialSC1 + " -  " + cNomeFil + CRLF //+ "|"
		//cDescricao += " FORN: " + AllTrim(SC1->C1_FORNECE) + " - " + cFornecedor + CRLF + CRLF
		cDescricao += "ITENS: " + CRLF

		While !(SC1->(EoF())) .And. SC1->C1_FILIAL == cFilialSC1 .And. SC1->C1_NUM == cScNum
			cLinhaDesc := "Produto: " + AllTrim(SC1->C1_DESCRI) + " | " + "QUANTIDADE: " + CValToChar(SC1->C1_QUANT) + " | " + "VALOR: " + AllTrim(Transform(SC1->C1_XTOTAL, AllTrim(X3Picture("C1_XTOTAL")))) + CRLF
			cDescricao  += cLinhaDesc
			nQtdCount := nQtdCount + 1
			AAdd(aCardData, {"itemCodigo___"       +cValToChar(nItemCod := nItemCod + 1),         AllTrim(SC1->C1_PRODUTO)})
			AAdd(aCardData, {"itemDescricao___"    +cValToChar(nItemDesc := nItemDesc + 1),       AllTrim(SC1->C1_DESCRI)})
			AAdd(aCardData, {"itemQuantidade___"   +cValToChar(nItemQuant := nItemQuant + 1),     CValToChar(SC1->C1_QUANT)})
			AAdd(aCardData, {"itemValorUnitario___"+cValToChar(nItemVUnit := nItemVUnit + 1),     CValToChar(SC1->C1_VUNIT)})
			AAdd(aCardData, {"itemSubTotal___"     +cValToChar(nItemSubTot := nItemSubTot + 1),   AllTrim(Transform(SC1->C1_XTOTAL, AllTrim(X3Picture("C1_XTOTAL"))))})
			SC1->(DbSkip())
		End
		cDescricao += CRLF + "Solicitação de Compra"
	EndIf

	AAdd(aCardData, {"txt_empresa",             FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_codigofornecedor",    cCodFornec})
	AAdd(aCardData, {"txt_nomefornecedor",      cFornecedor})
	AAdd(aCardData, {"txt_tipo",                aDocument[2]})
	AAdd(aCardData, {"txt_documento",           AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",               aDocument[13]})
	AAdd(aCardData, {"txt_descricao",           cDescricao})
	AAdd(aCardData, {"txt_data",                DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",          AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",      cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador",     cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",         aDocument[5]})
	AAdd(aCardData, {"txt_totalItens",   	cValToChar(nQtdCount)})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataPC
Monta o cardData para pedido de compras.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataPC(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cCodFornec    := ""
	Local cDescricao    := ""
	Local cFilialSC7    := ""
	Local cFornecedor   := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""
	Local cNumPedCom    := ""
	Local nItemCod      := 0
	Local nItemDesc     := 0
	Local nItemQuant    := 0
	Local nItemVUnit	:= 0
	Local nItemSubTot   := 0
	Local nQtdCount		:= 0

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), SC7->(GetArea())}

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cNumPedCom := PadR(aDocument[1], TamSX3("C7_NUM")[1])

	SC7->(DbSetOrder(1))
	cFilialSC7 := SCR->CR_FILIAL
	If SC7->(DbSeek(cFilialSC7 + cNumPedCom))

		cCodFornec  := AllTrim(SC7->C7_FORNECE)
		cFornecedor := AllTrim(SC7->C7_XNOMFOR)
		If cFornecedor == ""
			cFornecedor := "Fornecedor em branco"
		EndIf
		
		cDescricao := "Solicitante: " + AllTrim(SCR->CR_XCOMSOL) + CRLF
		cDescricao += "FILIAL: " + cFilialSC7 + " - " + cNomeFil + CRLF + "|"
		cDescricao += " FORN: " + cCodFornec + " - " + cFornecedor + CRLF + CRLF
		cDescricao += "ITENS: " + CRLF

		While !(SC7->(EoF())) .And. SC7->C7_FILIAL == cFilialSC7 .And. SC7->C7_NUM == cNumPedCom
			cLinhaDesc  := AllTrim(SC7->C7_DESCRI) + ": QTE: " + CValToChar(SC7->C7_QUANT) + ": VALOR: " + AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL")))) + CRLF
			cDescricao  += cLinhaDesc
			nQtdCount := nQtdCount + 1
			AAdd(aCardData, {"itemCodigo___"       +cValToChar(nItemCod := nItemCod + 1),         AllTrim(SC7->C7_PRODUTO)})
			AAdd(aCardData, {"itemDescricao___"    +cValToChar(nItemDesc := nItemDesc + 1),       AllTrim(SC7->C7_DESCRI)})
			AAdd(aCardData, {"itemQuantidade___"   +cValToChar(nItemQuant := nItemQuant + 1),     CValToChar(SC7->C7_QUANT)})
			AAdd(aCardData, {"itemValorUnitario___"+cValToChar(nItemVUnit := nItemVUnit + 1),     CValToChar(SC7->C7_PRECO)})
			AAdd(aCardData, {"itemSubTotal___"     +cValToChar(nItemSubTot := nItemSubTot + 1),   AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL"))))})
			SC7->(DbSkip())
		End
	EndIf

	AAdd(aCardData, {"txt_empresa",             FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_codigofornecedor",    cCodFornec})
	AAdd(aCardData, {"txt_nomefornecedor",      cFornecedor})
	AAdd(aCardData, {"txt_tipo",                aDocument[2]})
	AAdd(aCardData, {"txt_documento",           AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",               aDocument[13]})
	AAdd(aCardData, {"txt_descricao",           cDescricao})
	AAdd(aCardData, {"txt_data",                DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",          AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",      cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador",     cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",         aDocument[5]})
	AAdd(aCardData, {"txt_totalItens",   	cValToChar(nQtdCount)})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataSP
Monta o cardData para solicitação de pagamento.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataSP(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cCodFornec    := ""
	Local cDescricao    := ""
	Local cFilialSC7    := ""
	Local cFornecedor   := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""
	Local cNumPedCom    := ""
	Local nItemCod      := 0
	Local nItemDesc     := 0
	Local nItemQuant    := 0
	Local nItemVUnit	:= 0
	Local nItemSubTot   := 0
	Local nQtdCount		:= 0

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), SC7->(GetArea())}

	/*/If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf/*/

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cNumPedCom  := PadR(aDocument[DEF_DOCUMENTO], TamSX3("C7_NUM")[1])

	SC7->(DbSetOrder(1))
	cFilialSC7 := SCR->CR_FILIAL
	If SC7->(DbSeek(cFilialSC7 + cNumPedCom))

		cCodFornec  := AllTrim(SC7->C7_FORNECE)
		cFornecedor := AllTrim(SC7->C7_XNOMFOR)
		If cFornecedor == ""
			cFornecedor := "Fornecedor em branco"
		EndIf
		
		cDescricao := "Solicitante: " + AllTrim(SCR->CR_XCOMSOL) + CRLF
		cDescricao += "FILIAL: " + cFilialSC7 + " - " + cNomeFil + CRLF
		cDescricao += "FORNECEDOR: " + cCodFornec + " - " + cFornecedor + CRLF + CRLF
		cDescricao += "ITENS: " + CRLF

		While !(SC7->(EoF())) .And. SC7->C7_FILIAL == cFilialSC7 .And. SC7->C7_NUM == cNumPedCom
			cLinhaDesc := AllTrim(SC7->C7_DESCRI) + ": QTE: " + CValToChar(SC7->C7_QUANT) + ": VALOR: " + AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL")))) + CRLF
			cDescricao  += cLinhaDesc
			nQtdCount := nQtdCount + 1
			AAdd(aCardData, {"itemCodigo___"       +cValToChar(nItemCod := nItemCod + 1),         AllTrim(SC7->C7_PRODUTO)})
			AAdd(aCardData, {"itemDescricao___"    +cValToChar(nItemDesc := nItemDesc + 1),       AllTrim(SC7->C7_DESCRI)})
			AAdd(aCardData, {"itemQuantidade___"   +cValToChar(nItemQuant := nItemQuant + 1),     CValToChar(SC7->C7_QUANT)})
			AAdd(aCardData, {"itemValorUnitario___"+cValToChar(nItemVUnit := nItemVUnit + 1),     CValToChar(SC7->C7_PRECO)})
			AAdd(aCardData, {"itemSubTotal___"     +cValToChar(nItemSubTot := nItemSubTot + 1),   AllTrim(Transform(SC7->C7_TOTAL, AllTrim(X3Picture("C7_TOTAL"))))})
			SC7->(DbSkip())
		End
	EndIf

	AAdd(aCardData, {"txt_empresa",             FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_codigofornecedor",    cCodFornec})
	AAdd(aCardData, {"txt_nomefornecedor",      cFornecedor})
	AAdd(aCardData, {"txt_tipo",                aDocument[2]})
	AAdd(aCardData, {"txt_documento",           AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",               aDocument[13]})
	AAdd(aCardData, {"txt_descricao",           cDescricao})
	AAdd(aCardData, {"txt_data",                DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",          AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",      cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador",     cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",         aDocument[5]})
	AAdd(aCardData, {"txt_totalItens",   	cValToChar(nQtdCount)})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataCT
Monta o cardData para contratos.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataCT(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cDescricao    := ""
	Local cFilialCN9    := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), SC7->(GetArea())}
	/*
	IF TYPE("nSCRRecno") == 'N'
	If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf
	Endif
	*/
	cLoginApr := Identity(SCR->CR_USER)

	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cDescricao += CRLF + "Atualização de Contrato"

	AAdd(aCardData, {"txt_empresa",         FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_tipo",            aDocument[2]})
	AAdd(aCardData, {"txt_documento",       AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",           aDocument[13]})
	AAdd(aCardData, {"txt_descricao",       cDescricao})
	AAdd(aCardData, {"txt_data",            DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",      AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",  cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador", cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",     aDocument[5]})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataCT
Monta o cardData para medição de contrato.

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataMD(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cDescricao    := ""
	Local cFilialCN9    := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), CN9->(GetArea())}
	/*
	IF TYPE("nSCRRecno") == "N"
	If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf
	Endif
	*/
	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))

	cLoginApr := Identity(SCR->CR_USER)

	cDescricao += CRLF + "Medição de Contrato"

	AAdd(aCardData, {"txt_empresa",         FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_tipo",            aDocument[2]})
	AAdd(aCardData, {"txt_documento",       AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",           aDocument[DEF_NIVEL]})
	AAdd(aCardData, {"txt_descricao",       cDescricao})
	AAdd(aCardData, {"txt_data",            DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",      AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",  cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador", cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",     aDocument[5]})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*/{Protheus.doc} CardDataRV
Monta o cardData para revisão de contratos..

@project
@type       Static Function
@author     Rafael Riego
@since      01/11/2018
@version    12.1.17
@param      aDocument, array, informações da alçada
@return     aCardData, array contendo as informação do cardData
/*/
Static Function CardDataRV(aDocument, cLoginApr)

	Local aArea         := {}
	Local aCardData     := {}

	Local cDescricao    := ""
	Local cFilialCN9    := ""
	Local cLinhaDesc    := ""
	Local cNomeAprv     := ""

	Default aDocument   := {}
	Default cLoginApr   := ""

	aArea := {GetArea(), SCR->(GetArea()), CN9->(GetArea())}
	/*
	IF Type("nSCRRecno")=="N"
	If !(Empty(nSCRRecno))
	SCR->(DbSeek(nSCRRecno))
	EndIf
	Endif
	*/
	cNomeAprv := AllTrim(UsrFullName(SCR->CR_USER))
	cLoginApr := Identity(SCR->CR_USER)

	//TODO não existe valor referente a essa informação
	cDescricao += CRLF + "Revisão de Contratos"

	AAdd(aCardData, {"txt_empresa",         FwCodEmp()})
	AAdd(aCardData, {"txt_filial",              AllTrim(SCR->CR_FILIAL)})
	AAdd(aCardData, {"txt_nomefilial",          cNomeFil})
	AAdd(aCardData, {"txt_tipo",            aDocument[2]})
	AAdd(aCardData, {"txt_documento",       AllTrim(aDocument[1])})
	AAdd(aCardData, {"txt_nivel",           aDocument[DEF_NIVEL]})
	AAdd(aCardData, {"txt_descricao",       cDescricao})
	AAdd(aCardData, {"txt_data",            DToC(aDocument[10])})
	AAdd(aCardData, {"txt_valortotal",      AllTrim(Transform(aDocument[3], AllTrim(X3Picture("CR_TOTAL"))))})
	AAdd(aCardData, {"txt_nome_aprovador",  cNomeAprv})
	AAdd(aCardData, {"txt_login_aprovador", cLoginApr})
	AAdd(aCardData, {"txt_cod_usuario",     aDocument[5]})

	AEval(aArea, {|area| RestArea(area)})

Return aCardData

/*Static Function SchedDef()

Local aParam := {   "P"         ,;
"ParamDef"  ,;
"SCR"       ,;
{}          ,;
"Integração Fluig"}

Return aParam*/