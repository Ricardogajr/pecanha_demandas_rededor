#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} REPP12SIMP
description: WebServices de replica para o P12 Simplificado
@author  Ricardo Junior
@since   26/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------

WSRESTFUL REPP12SIMP DESCRIPTION "Metodo disponível para replica de cadastros do P12 Full para o P12 Simplificado." FORMAT APPLICATION_JSON_TYPE

	WSMETHOD POST DESCRIPTION "Metodo POST."  PATH "/"

END WSRESTFUL

WSMETHOD POST WSSERVICE REPP12SIMP
	local aArea := GetArea()
	local cjson := Self:GetContent()
	private cErrorL := ""
	::SetContentType("application/json;charset=utf-8")
	::SetHeader("Accept","application/json;charset=utf-8")

	if cJson == Nil
		cmsgError := "Mensagem null"
		fGravaP19("1",cmsgError, .F.)
		//SetRestFault(001,cmsgError,.T.)
		::setResponse('{"status":"ERROR", "message": "'+cmsgError+'"}')
		return .T.
	else
		cjson := DecodeUTF8(cjson)

		if cJson == Nil
			cmsgError := "Erro conversao DecodeUTF8"
			fGravaP19("1",cmsgError, .F.)
			//SetRestFault(002,cmsgError,.T.)
			::setResponse('{"status":"ERROR", "message": "'+cmsgError+'"}')
			return .T.
		else
			if cJson == "{}"
				cmsgError := "JSON invalido"
				fGravaP19("1",cmsgError, .F.)
				//	SetRestFault(003,cmsgError,.T.)
				::setResponse('{"status":"ERROR", "message": "'+cmsgError+'"}')
				return .T.
			endif
		endif
	endif

	aMessage := U_P12SIMP01(cjson)
	::setResponse('{"status":"'+aMessage[1]+'", "message": "'+aMessage[2]+'"}')

//if aMessage[1] != "OK"
//	Return .F.
//endif

	RestArea(aArea)
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} P12SIM01
description: Monta array para executar reclock
@author  Ricardo Junior
@since   26/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
user function P12SIMP01(cBody)
	private nRecnoP19 := 0
	private cTabela := ""
	private cIndice := ""
	default cBody := ""

	oJson := JsonObject():New()
	ret := oJson:FromJson(cBody)

	fGravaP19("1", cBody)

	if ValType(ret) == "C"
		conout("Falha ao transformar texto em objeto json. Erro: " + ret)
		return
	endif

Return PrintJson(oJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintJson
description: Função para montar a estrutura com os dados.
@author  Ricardo Junior
@since   26/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function PrintJson(jsonObj)
	local i
	local lenJson
	Local aDados := {}
	local lInc	:= .T.
	local nX	:= 00
	local lDeletado := .F.

	private cInd := ""
	//private oError := ErrorBlock({|e| fTrataErro(e:Description)})

	lenJson := len(jsonObj)

	//Pega a Tabela informada no Json.
	aTabela := jsonObj:GetNames()
	//item := jsonObj[cTabela]
	//names := item:GetNames()
	for nX:=01 To Len(aTabela)
		if Upper(aTabela[nX]) $ "D_E_L_E_T_|R_E_C_N_O_|R_E_C_D_E_L_"
			Loop
		endif
		fGetTabela(aTabela[nX])
		exit
	next nX

	for i := 1 to len(aTabela)
		xValor := jsonObj[aTabela[i]]
		if Upper(aTabela[i]) $ "D_E_L_E_T_|R_E_C_N_O_|R_E_C_D_E_L_"
			aAdd(aDados, { Upper(aTabela[i]), cValToChar(xValor) })
			loop
		endif
		aAdd(aDados, { Upper(aTabela[i]), PadR(cValToChar(xValor), TamSX3(aTabela[i])[01]) })
	next i

	if cTabela == "SA2"
		nPosCNPJ := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "A2_CGC" })
		nPosCodFor := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "A2_COD" })
		nPosLojFor := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "A2_LOJA" })
		nPosPfis := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "A2_PFISICA" })
		cIndice := getCGCcor(aDados[nPosCodFor][2], aDados[nPosLojFor][2], aDados[nPosCNPJ][2],aDados[nPosPfis][2])
		if Empty(cIndice)
			lInc := .T.
		else
			&(cTabela)->(DbSetOrder(01))
			if &(cTabela)->(DbSeek(cIndice))
				lInc := .F.
			endif
		endif
	elseif cTabela == "CTD"
		nPosCodFor 	:= aScan(aDados, {|x| Upper(AllTrim(x[1])) == "CTD_ITEM" })
		cCodFor := SubStr(aDados[nPosCodFor][2],2,6)
		cCodLoj := SubStr(aDados[nPosCodFor][2],8,2)
		aRet := getCodFor(cCodFor, cCodLoj)
		If !Empty(aRet[01])
			aDados[nPosCodFor][2] := "F" + AllTrim(xFilial("SA2")) + aRet[1] + aRet[2]
			cIndice := xFilial("CTD") +"F"+AllTrim(xFilial("SA2"))+aRet[1]+aRet[2]
		Else
			return {"ERROR", fTrataErro("Codigo corporativo nao encontrado para o codigo !["+cTabela+"] "+ cCodFor)}
		Endif
	elseIf cTabela == "FIL"
		nPosCodFor := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "FIL_FORNEC" })
		nPosCodLoj := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "FIL_LOJA" })
		cCodFor := aDados[nPosCodFor][2]
		cCodLoj := aDados[nPosCodLoj][2]
		aRet := getCodFor(cCodFor, cCodLoj)
		If !Empty(aRet[01])
			aDados[nPosCodFor][2] := aRet[1]
			aDados[nPosCodLoj][2] := aRet[2]
			cIndice := fGetIndice(aDados)
		Else
			return {"ERROR", fTrataErro("Codigo corporativo nao encontrado para o codigo !["+cTabela+"] "+ cCodFor)}
		Endif
	else
		cIndice := fGetIndice(aDados)
	endif

	if Empty(cIndice) .And. cTabela != "SA2"
		return {"ERROR", fTrataErro('Nao foi possivel montar a chave!['+cTabela+']')}
	EndIf

//busca o primeiro indice conforme a tabela definida
	DBSelectArea(cTabela)
	if cTabela != "SA2"
		&(cTabela)->(DbSetOrder(01))
	endif

	if cTabela == "FIL"
		nPosRecno := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "R_E_C_N_O_" })
		nRecnoSimp := RecnoFull(aDados[nPosRecno][2])
		if nRecnoSimp > 0
			FIL->(DbGoTo(nRecnoSimp))
			lInc := .F.
		else
			lInc := .T.
		endif
	else
		if cTabela != "SA2"
			if &(cTabela)->(DbSeek(cIndice))
				lInc := .F.
			endif
		endif
	endif
	nPosDelete := aScan(aDados, {|x| Upper(AllTrim(x[1])) == "D_E_L_E_T_" })
	if nPosDelete > 0
		if !Empty(aDados[nPosDelete][2])
			lDeletado := .T.
			if lInc
				cMessage := "Registro descartado. Não existe na base e esta deletado! ["+cTabela+"]"+ cIndice
				fGravaP19("2",cMessage, .T.)
				return {"OK", cMessage }
			endif
			RecLock(cTabela, .F.)
			&(cTabela)->(DbDelete())
			(cTabela)->(MsUnlock())
			//cMessage := '"status": "OK", "message":"Registro deletado com sucesso! ['+cTabela+'] '+ cInd +'"'
			cMessage := "Registro deletado com sucesso! ["+cTabela+"] "+ cIndice
			fGravaP19("2",cMessage, .T.)
			return {"Ok", cMessage }
		endif
	endif

	Begin Sequence
		bBlock := ErrorBlock({|e|ChkErr(e)})
		if cTabela == "SA2"
			if lInc
				if IsDigit(aDados[nPosCodFor][02])
					cCodFornec := GETSX8NUM('SA2','A2_COD')
					lFree := MayIUseCode(cCodFornec) //Reservar nomes com o semáforo.
					If !lFree
						nTent := 0
						While !(lFree := MayIUseCode(cCodFornec))
							Sleep(2000) //Espera por 2 segundos
							cCodFornec := GETSX8NUM('SA2','A2_COD')
							conout("PEGOU PROXIMO NUMERO" + cCodFornec)
						Enddo
						if !Empty(cMessage)
							fGravaP19("3",cMessage, .F.)
							return {"ERROR", cMessage}
						endif
						If lFree
							Sleep(2000) //Espera por 2 segundos para possibilitar a finalização da outra thread
							(cTabela)->(MsUnlock())
							if cTabela == "SA2" .And. lInc
								ConfirmSx8()
							EndIf
						endif
					else
						conout("NAO PEGOU PROXIMO NUMERO " + cCodFornec)
					Endif
				EndIf
			else
				cCodFornec := aDados[nPosCodFor][02]
			endif
		endif
		Begin Transaction
			if RecLock(cTabela, lInc)
				for nX := 01 To Len(aDados)
					//Verifica se é o campo RECNO ou RECDEL e pula o loop.
					if(AllTrim(Upper(aDados[nX][01])) $ "R_E_C_N_O_|R_E_C_D_E_L_|D_E_L_E_T_")
						If cTabela == "FIL" .And. AllTrim(Upper(aDados[nX][01])) == "R_E_C_N_O_"
							FIL->FIL_XP12RC := Val(aDados[nX][02])
						endif
						loop
					endif
					//Tratativa para o fornecedor
					If aDados[nX][01] == "A2_COD" .And. cTabela == "SA2"
						if lInc
							SA2->A2_COD := cCodFornec
						endif
						SA2->A2_XCODCOR := fConvert(&(aDados[nX][01]), aDados[nX][02])
						loop
					elseIf aDados[nX][01] == "A2_LOJA" .And. cTabela == "SA2"
						SA2->A2_XLOJCOR := fConvert(&(aDados[nX][01]), aDados[nX][02])
						SA2->A2_LOJA  := fConvert(&(aDados[nX][01]), aDados[nX][02])
						loop
					endif
					&(aDados[nX][01]) := fConvert(&(aDados[nX][01]), aDados[nX][02])
				next nX
				(cTabela)->(MsUnlock())
				if cTabela == "SA2" .And. lInc
					ConfirmSx8()
					setItemConta(SA2->A2_COD+SA2->A2_LOJA)
				EndIf
				
			endif
		End Transaction

		If ValType(bBlock) != "U"
			ErrorBlock(bBlock)
			if !Empty(cErrorL)
				if InTransaction()
					DisarmTransaction()
				endIf
				cMessage := "ERRO NA GRAVACAO! ["+cTabela+"] "+ SubStr(cErrorL,1,100)
				fGravaP19("3",SubStr(cErrorL,1,150), .F.)
				FreeObj(oJson)
				return {"ERROR", cMessage }
			endif
		EndIf
	end sequence
	cMessage := "Registro "+iif(lInc, "incluido", "alterado")+" com sucesso! ["+cTabela+"] "+ &(IndexKey())
	fGravaP19("2",cMessage, .T.)
	FreeObj(oJson)
return {"OK", cMessage }
//-------------------------------------------------------------------
/*/{Protheus.doc} fGetIndice
description pega o indice das tabelas tratadas.
@author  Ricardo Junior
@since   26/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function fGetIndice(aDados)
	Local aArea		:= GetArea()
	Local cIndice 	:= ""
	Local nX		:= 0

	DbSelectArea(cTabela)
	&(cTabela)->(DbSetOrder(01))
	aCamposInd := StrTokArr( IndexKey(), "+" )
	for nx := 01 To Len(aCamposInd)
		If aScan(aDados, {|x| Upper(AllTrim(x[1])) == aCamposInd[nX] }) == 0
			cIndice += Space(TamSx3(aCamposInd[nX])[1])//Tratativa para pegar os campos que não foram enviados para
		endIf
		cIndice += PadR(aDados[aScan(aDados, {|x| Upper(AllTrim(x[1])) == aCamposInd[nX] })][02], TamSx3(aCamposInd[nX])[01])
	next nx
	RestArea(aArea)
Return cIndice
//-------------------------------------------------------------------
/*/{Protheus.doc} fConvert
description Converte o campo para o tipo do campo da base.
@author  Ricardo Junior
@since   26/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function fConvert(cCampo, cConteudo)
	Local xConteudo := Nil
	do case
	case Valtype(cCampo) == "D"
		xConteudo := SToD(cConteudo)
	Case ValType(cCampo) == "N"
		xConteudo := Val(cConteudo)
	Case ValType(cCampo) == "L"
		xConteudo := iIf(AllTrim(cCampo)=="F", .F., .T.)
	OtherWise
		xConteudo := cConteudo
	endcase
Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaP19
description Função para gravar os dados das entradas das integrações na P19
@author  Ricard Junior
@since   08/02/21
@version 1.0
/*/
//-------------------------------------------------------------------
static function fGravaP19(cTipo, cBody, lSucesso)
	local aArea := GetArea()
	default lSucesso := .F.
	DbSelectArea("P19")
	if cTipo == "1"
		Reclock("P19", .T.)
		P19_FILIAL := ""
		P19_DTHRI := FwTimeStamp()
		P19_ID := FWUUIDV4()
		P19_ROTINA := "P12SIMP01"
		P19_INDKEY := "Em processamento... " + Substr(cBody, 1, 10)
		P19_INPUT := cBody
		P19_STATUS := "1"
		P19->(MsUnlock())
		nRecnoP19 := P19->(Recno())
		return
	endif
	if nRecnoP19 > 0
		DbSelectArea("P19")
		P19->(DbGoTo(nRecnoP19))
		Reclock("P19", .F.)
		P19_DTHRF := FwTimeStamp()
		P19_OUTPUT := cBody
		P19_STATUS := If(lSucesso,"2","3")
		P19_INDKEY := cTabela+"|"+cIndice
		P19->(MsUnlock())
	endif
	RestArea(aArea)
return
//-------------------------------------------------------------------
/*/{Protheus.doc} fTrataErro
description Função responsável por tratar a mensagem de erro e gravar P19
@author  Ricardo Junior
@since   08/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static Function fTrataErro(cError)
	fGravaP19("2",cError, .F.)
	RollbackSx8()
Return cError

Static Function fGetTabela(cCampo)

	cTabela := SubStr(cCampo, 01, At("_", cCampo) -1)

	If Len(cTabela) == 2
		cTabela := "S"+cTabela
	EndIf
	cTabela := UPPER(cTabela)
Return

/*
Static function GetIndCNPJ(cChave)

	Local cQuery    := ""
	Local cAliasSA2 := GetNextAlias()
	Local cCodigo   := ""


	cQuery += " SELECT A2_FILIAL||A2_COD||A2_LOJA CHAVE"
	cQuery += " FROM " + RetSqlName("SA2")
	cQuery += " WHERE A2_FILIAL||A2_PFISICA  = '" + cChave +"' "
	cQuery += " AND D_E_L_E_T_ = ' '"

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSA2, .T., .T.)

	If Select(cAliasSA2) > 0
		cCodigo := (cAliasSA2)->CHAVE
	Endif
Return cCodigo
*/

static function getCodFor(cCod, cLoja)
	Local cQuery    := ""
	Local cAliasSA2 := GetNextAlias()
	Local aCod      := {"", ""}


	cQuery += " SELECT A2_COD, A2_LOJA "
	cQuery += " FROM " + RetSqlName("SA2")
	cQuery += " WHERE A2_XCODCOR  = '" + cCod +"' "
	cQuery += " AND A2_XLOJCOR  = '" + cLoja +"' "
	cQuery += " AND D_E_L_E_T_ = ' '"

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSA2, .T., .T.)

	If Select(cAliasSA2) > 0
		aCod := {(cAliasSA2)->A2_COD, (cAliasSA2)->A2_LOJA }
	Endif

	If Select(cAliasSA2) > 0
		(cAliasSA2)->(DbCloseArea())
	endif

return aCod

static function getCGCcor(cCod, cLoja, cCGC, cpfisica)
	Local cQuery    := "" 
	Local cAliasSA2 := GetNextAlias()
	Local cIndice   := ""


	cQuery += " SELECT SEQUEN, A2_FILIAL, A2_COD, A2_LOJA FROM ( " + CRLF
	cQuery += " SELECT 1 AS SEQUEN, A2_FILIAL, A2_COD, A2_LOJA " + CRLF
	cQuery += " FROM " + RetSqlName("SA2") + CRLF
	cQuery += " WHERE 
	//A2_CGC = '"+ cCGC +"' " + CRLF
	cQuery += " A2_FILIAL   = '" + xFilial("SA2") +"' " + CRLF
	cQuery += " AND A2_XCODCOR  = '" + cCod +"' " + CRLF
	cQuery += " AND A2_XLOJCOR  = '" + cLoja +"' " + CRLF
	cQuery += " AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " UNION " + CRLF
	cQuery += " SELECT 2 AS SEQUEN,A2_FILIAL, A2_COD, A2_LOJA " + CRLF
	cQuery += " FROM " + RetSqlName("SA2") + CRLF
	cQuery += " WHERE A2_CGC = '"+ cCGC +"' " + CRLF
	cQuery += " AND A2_FILIAL   = '" + xFilial("SA2") +"' " + CRLF
	cQuery += " AND A2_TIPO   = 'X' " + CRLF
	cQuery += " AND A2_PFISICA  = '"+cpfisica+"' " + CRLF
	cQuery += " AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " UNION " + CRLF
	cQuery += " SELECT 3 AS SEQUEN,A2_FILIAL, A2_COD, A2_LOJA " + CRLF
	cQuery += " FROM " + RetSqlName("SA2") + CRLF
	cQuery += " WHERE A2_CGC = '"+ cCGC +"' " + CRLF
	cQuery += " AND A2_FILIAL   = '" + xFilial("SA2") +"' " + CRLF
	cQuery += " AND A2_XCODCOR  = ' ' " + CRLF
	cQuery += " AND A2_COD  != ' ' " + CRLF
	cQuery += " AND D_E_L_E_T_ = ' ' ) ORDER BY SEQUEN" + CRLF

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSA2, .T., .T.)

	If Select(cAliasSA2) > 0
		cIndice := (cAliasSA2)->A2_FILIAL + (cAliasSA2)->A2_COD +  (cAliasSA2)->A2_LOJA
	Endif

	If Select(cAliasSA2) > 0
		(cAliasSA2)->(DbCloseArea())
	endif

return cIndice

Static function RecnoFull(nRecno)
	Local cQuery    := ""
	Local cAliasFil := GetNextAlias()
	Local nRecSimp  := 0


	cQuery += " SELECT R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("FIL")
	cQuery += " WHERE FIL_FILIAL = '"+xFilial("FIL")+"'"
	cQuery += " AND FIL_XP12RC  = " + cValToChar(nRecno) +" "
	cQuery += " AND D_E_L_E_T_ = ' '"

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasFil, .T., .T.)

	If Select(cAliasFil) > 0
		nRecSimp := (cAliasFil)->R_E_C_N_O_
	Endif

	If Select(cAliasFil) > 0
		(cAliasFil)->(DbCloseArea())
	endif
Return nRecSimp

Static Function ChkErr(oErroArq)

	Local nI:= 0

	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf

	nI := 2

	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	Enddo

/*	Desabilitado porque não estava retornando a mensagem de erro. A função DisarmTransaction foi colocada na linha 129.
	If InTransaction()
		c'	ErrorL +="Transacao aberta desarmada"
		DisarmTransaction()
	EndIf
*/	
	Break

Return

static function setItemConta(cChaveSA2)
	Local aArea := GetArea()
	Local aAreaSA2 := SA2->(GetArea())
	Local aAreaCTD := CTD->(GetArea())

	DbSelectArea("SA2")
	SA2->(DbSetOrder(01))
	SA2->(DbSeek(xFilial("SA2")+cChaveSA2))

	cCodItem := "F"+AllTrim(xFilial("SA2"))+cChaveSA2
	DbSelectArea("CTD")
	CTD->(DbSetOrder(1))
	if !DbSeek(xFilial("CTD")+cCodItem)
		RecLock("CTD",.T.)
		Replace CTD_FILIAL With xFilial("CTD"),;
			CTD_ITEM   With cCodItem      ,;
			CTD_DESC01 With SA2->A2_NOME   ,;
			CTD_CLASSE With "2"            ,;
			CTD_NORMAL With "0"            ,;
			CTD_DTEXIS With ctod("01/01/2000"),;
			CTD_BLOQ   With '2'
		CTD->(MsUnlock())
	endif

	RestArea(aAreaCTD)
	RestArea(aAreaSA2)
	RestArea(aArea)
Return
