#Include "Protheus.CH"
#INCLUDE "totvs.ch" 
/*/{Protheus.doc} DTFORNFIX
Função responsável por definir as datas fixas para inclusão de NFS
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@param dData, data, Data de vencimento de origem
@return aReturn - Retorna um array com duas posições, sendo a primeira a data de vencimento para parcelamentos e a segunda
@a data de vencimento para pagamentos a vista.
/*/  

User Function DTFORNFIX(dData,cCondc,nParcelas,dDataEmi) 

	Local aArea := GetArea()
	Local dReturn := ""
	Local aDatas := {}
	Local cDatas := GetNewPar("MV_DTFIXA","10;20;30")

	Default dData := Date()
	Default cCondc := ""
	Default nParcelas := 1
	Default dDataEmi := Date()

	aDatas := StrToKarr(cDatas, ";")

	For nY := 1 To Len(aDatas)
		aDatas[nY] := Val(aDatas[nY])
	Next nY
	aSort(aDatas)

	If IsInCallStack("U_F0703301")
		dReturn := fDtInteg(aDatas,nParcelas,dData,dDataEmi) //Retorna a data fixa caso o documento seja criado via integração.
		//Esta rotina é necessária porque na integração não é informada a condição de pagamento e sim a quantidade de parcelas.
	Else
		dReturn := fDtCommon(aDatas,cCondc,dData)//Retorna a data fixa caso o documento seja criado no protheus.
	EndIf
	RestArea(aArea)
Return dReturn

/*/{Protheus.doc} fUsrDtFixa
Função responsável por validar se o usuário pode criar uma exceção de data fixa
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return lRet - Retorna true ou false.
/*/ 
User Function fUsrDtFixa()

	Local aArea := GetArea()
	Local lRet := .F.
	Local aGrupos := {}
	Local nX := 1
	Local cGrupos := GetNewPar("MV_XGPDTF","")

	aGrupos := UsrRetGrp()

	For nX := 1 To Len(aGrupos)

		If aGrupos[nX] $ cGrupos
			lRet := .T.
			Exit
		EndIf

	Next nX

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} fDtInteg
Função responsável por retornar os dias de vencimento da(s) parcela(s) do título na integração de NF
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return dData - Retorna a data de vencimento
/*/ 
Static Function fDtInteg(aDatas,nParcelas,dData,dDataEmi)

	Local aArea := GetArea()
	Local cDatas := GetNewPar("MV_DTFIXA","5;10;15;20;25;30")
	Local nDtProc := GetNewPar("MV_XDTPROC",0)
	Local dDataParc := ""
	Local dDataFix := ""
	Local nX := 1
	Local cDia := ""
	Local cMes := ""
	Local cAno := ""
	Local cDt := ""
	Local dReturn := ""

	Default aDatas := {}
	Default nParcelas := 1
	Default dData := Date()
	Default dDataEmi := Date()

	If dData <> cToD(dDataEmi)
		For nX := 1 To Len(aDatas)

			If Day2Str(dData) $ cDatas
				If Lastday(dData,3) == dData
					dDataParc := dData
					dReturn := dDataParc
					Exit
				Else
					dDataParc := Lastday(dData,3)
					dReturn := dDataParc
					Exit
				EndIf
			Else
				If Val(Day2Str(dData)) > aDatas[nX] .And. Val(Day2Str(dData)) < aDatas[nX + 1]
					cDia := cValToChar(aDatas[nX + 1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(cToD(cDt),3)
					dReturn := dDataParc
					Exit
				ElseIf Val(Day2Str(dData)) > aDatas[Len(aDatas)]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(MonthSum(cToD(cDt),1),3)
					dReturn := dDataParc
					Exit
				ElseIf Val(Day2Str(dData)) < aDatas[1]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(cToD(cDt),3)
					dReturn := dDataParc
					Exit
				EndIf

			EndIf

		Next nX
	Else
		dDataFix := DaySum(dData,nDtProc)

		For nX := 1 To Len(aDatas)

			If Day2Str(dDataFix) $ cDatas
				If Lastday(dDataFix,3) == dDataFix
					dReturn := dDataFix
					Exit
				Else
					dReturn := Lastday(dDataFix,3)
					Exit
				EndIf
			Else
				If Val(Day2Str(dDataFix)) > aDatas[nX] .And. Val(Day2Str(dDataFix)) < aDatas[nX + 1]
					cDia := cValToChar(aDatas[nX + 1])
					cMes := cValToChar(Month(dDataFix))
					cAno := cValToChar(Year(dDataFix))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataFix := Lastday(cToD(cDt),3)
					dReturn := dDataFix
					Exit
				ElseIf Val(Day2Str(dData)) > aDatas[Len(aDatas)]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(MonthSum(cToD(cDt),1),3)
					dReturn := dDataParc
					Exit
				ElseIf Val(Day2Str(dData)) < aDatas[1]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(cToD(cDt),3)
					dReturn := dDataParc
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
	RestArea(aArea)
Return dReturn


/*/{Protheus.doc} fDtCommon
Função responsável por retornar os dias de vencimento da(s) parcela(s) no processo pelo Protheus
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return dData - Retorna a data de vencimento
/*/ 
Static Function fDtCommon(aDatas,cCondc,dData)

	Local aArea := GetArea()
	Local cDatas := GetNewPar("MV_DTFIXA","05;10;15;20;25;30")
	Local nDtProc := GetNewPar("MV_XDTPROC",0)
	Local dDataParc := ""
	Local dDataFix := ""
	Local nX := 1
	Local cDia := ""
	Local cMes := ""
	Local cAno := ""
	Local cDt := ""
	Local dReturn := ""

	Default aDatas := {}
	Default cCondc := ""
	Default dData := Date()

	If AllTrim(Posicione("SE4",1,XFilial("SE4")+cCondc,"E4_COND")) <> "00"
		For nX := 1 To Len(aDatas)

			If Day2Str(dData) $ cDatas
				If Lastday(dData,3) == dData
					dDataParc := dData
					dReturn := dDataParc
					Exit
				Else
					dDataParc := Lastday(dData,3)
					dReturn := dDataParc
					Exit
				EndIf
			Else
				If Val(Day2Str(dData)) > aDatas[nX] .And. Val(Day2Str(dData)) < aDatas[nX + 1]
					cDia := cValToChar(aDatas[nX + 1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(cToD(cDt),3)
					dReturn := dDataParc
					Exit
				ElseIf Val(Day2Str(dData)) > aDatas[Len(aDatas)]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(MonthSum(cToD(cDt),1),3)
					dReturn := dDataParc
					Exit
				ElseIf Val(Day2Str(dData)) < aDatas[1]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dData))
					cAno := cValToChar(Year(dData))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(cToD(cDt),3)
					dReturn := dDataParc
					Exit
				EndIf
			EndIf
		Next nX
	Else
		dDataFix := DaySum(dData,nDtProc)

		For nX := 1 To Len(aDatas)
			If Day2Str(dDataFix) $ cDatas
				If Lastday(dDataFix,3) == dDataFix
					dReturn := dDataFix
					Exit
				Else
					dReturn := Lastday(dDataFix,3)
					Exit
				EndIf
			Else
				If Val(Day2Str(dDataFix)) > aDatas[nX] .And. Val(Day2Str(dDataFix)) < aDatas[nX + 1]
					cDia := cValToChar(aDatas[nX + 1])
					cMes := cValToChar(Month(dDataFix))
					cAno := cValToChar(Year(dDataFix))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataFix := Lastday(cToD(cDt),3)
					dReturn := dDataFix
					Exit
				ElseIf Val(Day2Str(dDataFix)) > aDatas[Len(aDatas)]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dDataFix))
					cAno := cValToChar(Year(dDataFix))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(MonthSum(cToD(cDt),1),3)
					dReturn := dDataParc
					Exit
				ElseIf Val(Day2Str(dDataFix)) < aDatas[1]
					cDia := cValToChar(aDatas[1])
					cMes := cValToChar(Month(dDataFix))
					cAno := cValToChar(Year(dDataFix))
					cDt := cDia+"/"+cMes+"/"+cAno
					dDataParc := Lastday(cToD(cDt),3)
					dReturn := dDataParc
					Exit
				EndIf
			EndIf
		Next nX
	EndIf

	RestArea(aArea)
Return dReturn

/*/{Protheus.doc} CKDUPFIX
Função responsável por verificar se o fornecedor é data fixa, se for retorna .T.
para bloquear o acols de duplicata na inclusão/classificação de NF.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return lRet
/*/ 
User Function CKDUPFIX()

	Local lRet := .F.
	Local lDtFixaEx := U_fUsrDtFixa() //Lucas Miranda de Aguiar - Melhoria data fixa
	Public xfDtExce := ""

	If (ALTERA .AND. SF1->F1_XSOLPAG == "1")
		If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
			If SF1->F1_XDTEXCE <> "1"
				lRet := .T.
			EndIf
			If !lDtFixaEx
				lRet := .T.
			EndIf
		EndIF
	ElseIf INCLUI
		xfDtExce := "2"
	ElseIf ALTERA
		If !Empty(SF1->F1_XDTEXCE)
			xfDtExce := SF1->F1_XDTEXCE
		Else
			xfDtExce := "2"
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} VENCDPFX
Função responsável por alterar a data de vencimento das parcelas do titulo de acordo com as datas fixas.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return lRet
/*/ 
User Function VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)

	Local nPerc := 0
	Local dVenc := {}
	Local aVencto := {}
	Local lPrimeiro := .T.

	Default aPELinhas := {}
	Default nPEValor := 0
	Default cPECondicao := ""
	Default nPEValIPI := 0
	Default dPEDEmissao := ""
	Default nPEValSol := 0

	If ALTERA
		If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
			For nX := 1 to Len(Condicao(100, cPECondicao , , dPEDEmissao , , , , ))

				nPerc := Condicao(100, cPECondicao , , dPEDEmissao , , , , )[nX][2]
				if SF1->F1_XDTEXCE == "1" .And. lPrimeiro
					dVenc := SF1->F1_XDTVNF	
					lPrimeiro := .F.
				else
					dVenc := U_DTFORNFIX(DataValida(Condicao(100, cPECondicao , , dPEDEmissao , , , , )[nX][1]),cPECondicao)
				Endif
				nValParc := (nPerc*nPEValor)/100

				Aadd(aVencto,{dVenc,nValParc})
			Next nX
		EndIf
	ElseIf INCLUI
		If Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"SA2->A2_XDTFIX") == "1"
			For nX := 1 to Len(Condicao(100, cPECondicao , , dPEDEmissao , , , , ))

				nPerc := Condicao(100, cPECondicao , , dPEDEmissao , , , , )[nX][2]
				dVenc := U_DTFORNFIX(DataValida(Condicao(100, cPECondicao , , dPEDEmissao , , , , )[nX][1]),cPECondicao)
				nValParc := (nPerc*nPEValor)/100

				Aadd(aVencto,{dVenc,nValParc})
			Next nX
		EndIf
	EndIf
Return aVencto

/*/{Protheus.doc} DTVALF1
Função responsável por validar se o campo D1_XPRIVEN pode ou não ser alterado.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return lRet
/*/ 
User Function DTVALF1()

	Local aArea := GetArea()
	Local lRet := .T.

//VALIDA SE É SOLICITAÇÃO DE PAGAMENTO
	If (ALTERA .And. SF1->F1_XSOLPAG == "1")
		If Empty(SF1->F1_FORNECE) .Or. Empty(SF1->F1_LOJA)
			lRet := .F.
		EndIf
		If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
			If SF1->F1_XDTEXCE <> "1"
				lRet := .F.
			EndIf
		EndIf
	EndIf
//FIM

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} DTFXSE2
Função responsável por gravar o usuário que validou o banco de conhecimento caso o fornecedor 
trabalhe com datas de vencimento fixas.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return lRet
/*/ 
User Function DTFXSE2()

	Local aArea := GetArea()
	Local cFunc := funname()
	Local cUpdate := ""

	If (cFunc == 'FINA750' .Or. cFunc == 'FINA050')
		If Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_XDTFIX") == "1"
			Reclock("SE2",.F.)
			SE2->E2_XVALNOM := FwGetUserName(RetCodUsr())
			SE2->(MsUnlock())
		EndIf
	/*/ElseIf funname() == 'F0100401'
		If Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"SA2->A2_XDTFIX") == "1"
			Reclock("SC7",.F.)
			SC7->C7_XVALNOM := FwGetUserName(RetCodUsr())
			SC7->(MsUnlock())
		EndIf/*/
		ElseIf cFunc == 'MATA103'
			If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
				Reclock("SF1",.F.)
				SF1->F1_XVALNOM := FwGetUserName(RetCodUsr())
				SF1->(MsUnlock())

				cUpdate := " UPDATE " + retsqlname("SE2") +  " SET E2_XVALNOM = '"+FwGetUserName(RetCodUsr())+"'"
				cUpdate += " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '" + SF1->F1_FILIAL + "'"
				cUpdate += " AND E2_NUM = '" + SF1->F1_DOC + "'"
				cUpdate += " AND E2_PREFIXO = '"+SF1->F1_SERIE+"'"
				cUpdate += " AND E2_FORNECE = '"+SF1->F1_FORNECE+"'"
				cUpdate += " AND E2_LOJA = '"+SF1->F1_LOJA+"'"
				If TcSQLExec( cUpdate ) != 0
					Conout("Erro ao tentar atualizar a tabela SE2" + CRLF + TcSQLError())
				Else
					SE2->(dbCommit())
				EndIf
			EndIf
		EndIf
		RestArea(aArea)
		Return

/*/{Protheus.doc} MSGDTFIX
Função responsável por alertar o usuário que realizar a inclusão do banco de conhecimento em documentos em que
o fornecedor trabalhe com data de conhecimento fixa
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return NIL
/*/ 
User Function MSGDTFIX()

	Local aArea := GetArea()
	Local cWarn := ""

	DbSelectArea("SA2")
	DbSetOrder(1)

	If (funname() == 'FINA750' .OR. funname() == 'FINA050')
		If Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_XDTFIX") == "1"
			cWarn := "O fornecedor desta nota fiscal, controla datas fixas de vencimentos de titulos no sistema Protheus 12. "
			cWarn += "A data de vencimento da primeira parcela de pagamento desta nota é "+Dtoc(SE2->E2_VENCREA)+". "
			cWarn += "O campo que informa que este vencimento é uma execeção de data fixa 1 = SIM ou 2 = NÃO, esta preenchido neste título a pagar com o conteudo "+ SE2->E2_XDTEXCE + "."
			MsgInfo(cWarn,"Título com fornecedor que utiliza data de pagamento fixa.")
		EndIf
	/*/ElseIf funname() == 'F0100401'
		If Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"SA2->A2_XDTFIX") == "1"
			cWarn := "O fornecedor desta solicitação de pagamentos, controla datas fixas de vencimentos de titulos no sistema Protheus 12. "
			cWarn += "A data de vencimento da primeira parcela de pagamento desta nota é "+Dtoc(SC7->C7_XDTVEN)+". "
			cWarn += "O campo que informa que este vencimento é uma execeção de data fixa 1 = SIM ou 2 = NÃO, esta preenchido neste título a pagar com o conteudo "+ SC7->C7_XDTEXCE + "."
			MsgInfo(cWarn,"Título com fornecedor que utiliza data de pagamento fixa.")
		EndIf/*/
		ElseIf funname() == 'MATA103'
			If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
				//DbSelectArea("SD1")
				//SD1->(DbSetOrder(1))
				//If SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
				dbSelectArea("SE2")
				SE2->(dbSetOrder(6))
				If SE2->(dbSeek(SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
					cWarn := "O fornecedor desta nota fiscal, controla datas fixas de vencimentos de titulos no sistema Protheus 12. "
					cWarn += "A data de vencimento da primeira parcela de pagamento desta nota é "+Dtoc(SE2->E2_VENCREA)+". "
					cWarn += "O campo que informa que este vencimento é uma execeção de data fixa 1 = SIM ou 2 = NÃO, esta preenchido neste título a pagar com o conteudo "+ SF1->F1_XDTEXCE + "."
					MsgInfo(cWarn,"Título com fornecedor que utiliza data de pagamento fixa.")
				EndIf
			EndIf
		EndIf
		RestArea(aArea)
		Return


/*/{Protheus.doc} fValdFix
Função responsável por validar se o campo C7_XDTVEN vai ser editavel ou não.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return NIL
/*/ 
User Function fValdFix()

	Local aArea := GetArea()
	Local oModel   := FwModelActive()
	Local oModeCab := oModel:GetModel("MODEL_SC7p")
	Local cFornece := oModeCab:GetValue("C7_FORNECE")
	Local cLoja := oModeCab:GetValue("C7_LOJA")
	Local cXDtExce := AllTrim(oModeCab:GetValue("C7_XDTEXCE"))
	Local cXTpSp := AllTrim(oModeCab:GetValue("C7_XTPSP"))
	Local lRet := .F.

	if cXTpSp $ "4|5" //Se for GPE já sai logo.
		Return .T.
	endif
	
	If !Empty(cFornece) .And. !Empty(cLoja)
		If AllTrim(Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"SA2->A2_XDTFIX")) == "1"
			If cXDtExce <> "1"
				lRet := .F.
			Else
				if cXTpSp $ "2|3" //Se é material estocável ou não estocável.
					lRet := .F.
				else
					lRet := .T.
				endif
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} fVldEx
Função responsável por validar se o campo C7_XDTEXCE vai ser editavel ou não.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return NIL
/*/ 
User Function fVldEx()

	Local aArea := GetArea()
	Local oModel   := FwModelActive()
	Local oModeCab := oModel:GetModel("MODEL_SC7p")
	Local cFornece := oModeCab:GetValue("C7_FORNECE")
	Local cLoja := oModeCab:GetValue("C7_LOJA")
	Local lDtFix := U_fUsrDtFixa()
	Local lRet := .F.

	If !Empty(cFornece) .And. !Empty(cLoja)
		If Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"SA2->A2_XDTFIX") == "1" .And. lDtFix
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} XPrivenFix
Gatilho do campo E2_VENCTO na inclusão de NF.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return NIL
/*/ 
User Function XPrivenFix()

	Local aArea := GetArea()
	Local aData := {}
	Local dData := ""
	Local nX := 01

	If IsInCallStack("MATA103")
		If INCLUI
			If xfDtExce <> "1"//Se não for exceção de data fixa.
				If Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"SA2->A2_XDTFIX") == "1"
					aData := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
					For nX := 01 To Len(ACOLS)
						If ACOLS[nX][2] == M->E2_VENCTO
							dData := aData[nX][1]
							M->E2_VENCTO := dData
						EndIf
						//If aPELinhas[nX][2] == aData[nX][1]
						//	dData := aData[nX][1]
						//		M->E2_VENCTO := dData
						//	EndIf
					Next nX
				Else
					dData := M->E2_VENCTO
				EndIf
			Else
				//dData := aPELinhas[1][2]
				dData := M->E2_VENCTO
			EndIf
		EndIf

		If (ALTERA .And. SF1->F1_XSOLPAG <> "1")
			If xfDtExce <> "1"//Se não for exceção de data fixa
				If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
					aData := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
					For nX := 01 To Len(ACOLS)
						If ACOLS[nX][2] == M->E2_VENCTO
							dData := aData[nX][1]
							M->E2_VENCTO := dData
						EndIf
						//If aPELinhas[nX][2] == aData[nX][1]
						//	dData := aData[nX][1]
						//		M->E2_VENCTO := dData
						//	EndIf
					Next nX
				Else
					dData := M->E2_VENCTO
				EndIf
			Else
				//dData := aPELinhas[1][2]
				dData := M->E2_VENCTO
			EndIf
		ElseIf (ALTERA .AND. SF1->F1_XSOLPAG == "1")
			//dData := aPELinhas[1][2]
			dData := M->E2_VENCTO
		EndIf
	Else
		dData := M->E2_VENCTO
	EndIf
	RestArea(aArea)

Return dData


User Function fxDtFX1()

	Private oDlg       := NIL
	Private oDesc      := NIL
	Private XoCodigo    := NIL
	Private XcDesc      := SPACE(40)
	Private XcCodigo    := SPACE(08)
	Private XaStatusP   := {}

	If INCLUI
		If (Empty(CA100FOR) .Or. Empty(CLOJA))
			Alert("Os campos de fornecedor e loja precisam ser preenchidos antes de executar essa ação!")
			Return
		EndIf
		If Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"SA2->A2_XDTFIX") <> "1"
			Alert("O fornecedor não trabalha com datas fixas de vencimento!")
			Return
		EndIf
	EndIf

	If ALTERA
		If (Empty(SF1->F1_FORNECE) .Or. Empty(SF1->F1_LOJA))
			Alert("Os campos de fornecedor e loja precisam ser preenchidos antes de executar essa ação!")
			Return
		EndIf
		If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") <> "1"
			Alert("O fornecedor não trabalha com datas fixas de vencimento!")
			Return
		EndIf
	EndIf

	If (Empty(xfDtExce) .Or. xfDtExce == "2")
		AAdd(XaStatusP,"Não")
		AAdd(XaStatusP,"Sim")
	ElseIf xfDtExce == "1"
		AAdd(XaStatusP,"Sim")
		AAdd(XaStatusP,"Não")
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Exceção de data fixa" FROM 0,0 TO 140,360 OF oMainWnd PIXEL

	@ 16,10 SAY RetTitle("F1_XDTEXCE") SIZE 45,09             OF oDlg PIXEL
	//@ 14,50 MSGET oCodigo VAR cCodigo SIZE 45,09 F3 "" OF oDlg PIXEL
	//@ 14,50 MSCOMBOBOX oCodigo VAR cCodigo ITEMS aStatusP SIZE 45, 09 OF oDlg PIXEL //COLORS 0, 16777215
	@ 14,50 MSCOMBOBOX oCodigo VAR XcCodigo ITEMS XaStatusP SIZE 45, 09 OF oDlg PIXEL

	DEFINE SBUTTON FROM 50,143 TYPE 1 ACTION {||fXdtexce()}ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return



Static Function fXdtexce()

	Local XcCod := ""

	If AllTrim(XcCodigo) == "Sim"
		XcCod := "1"
		MsgInfo("Exceção de data fixa habilitada!")
	ElseIf AllTrim(XcCodigo) == "Não"
		XcCod := "2"
		MsgInfo("Exceção de data fixa desabilitada!")
	EndIf

	If INCLUI
		M->F1_XDTEXCE := XcCod
		xfDtExce := XcCod
	ElseIf ALTERA
		SF1->F1_XDTEXCE := XcCod
		xfDtExce := XcCod
	EndIf
	oDlg:End()

Return






/*/{Protheus.doc} XPrVen1
Gatilho do campo D1_XPRIVEN na inclusão de NF.
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0
@return NIL
/*/ /*/
User Function XPrVen1()

	Local aArea := GetArea()
	Local aData := {}
	Local dData := ""

	If INCLUI .And. Empty(M->D1_XPRIVEN)
		If xfDtExce <> "1"
			If Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"SA2->A2_XDTFIX") == "1"
				aData := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
				dData := ADATA[1][1]
				M->D1_XPRIVEN := dData
			EndIf
		Else
			dData := aPELinhas[1][2]
		EndIf
	ElseIf !Empty(M->D1_XPRIVEN)
		dData := M->D1_XPRIVEN
	EndIf

	If ALTERA .And. SF1->F1_XSOLPAG <> "1"
		If xfDtExce <> "1"
			If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
				aData := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
				dData := ADATA[1][1]
				SE2->E2_VENCTO := dData
			EndIf
		Else
			dData := aPELinhas[1][2]
		EndIf
	EndIf

	If dData := ""
		If INCLUI
			dData := M->D1_XPRIVEN
		ElseIf ALTERA
			dData := SD1->D1_XPRIVEN
		EndIf
	EndIf
	RestArea(aArea)

Return dData
/*/
