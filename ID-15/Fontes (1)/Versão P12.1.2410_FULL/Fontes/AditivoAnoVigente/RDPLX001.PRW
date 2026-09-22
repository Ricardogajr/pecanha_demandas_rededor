#include "PROTHEUS.ch"
#include "RESTFUL.ch"

/*/{Protheus.doc} RDPLX001
WebServices Restfull integração de solicitação de compras com a Plannexo.
@type function
@author Ricardo Junior
@since 01/12/2022
@version 1.0
@return 
/*/ 
WsRestful RDPLX001 Description "WebService REST Plannexo - Solicitação de compras"

	WsMethod POST Description "Cadastra Solicitação de compras" WsSyntax "/api/plannexo/v1/RDPLX001"

End WsRestful

WsMethod POST WsService RDPLX001
	Local cJson     := ::GetContent()
	Local oParser   := JsonObject():New()
	Local nX 		:= 01
	Local nA		:= 00
	Local lRetorno 	:= .T.
	Local oResponse := Nil
	Local cMsgErrX  := ""
	Local lErro 	:= .F.
	Local bBlock 	:= ErrorBlock({|e|ChkErr(e)})
	Private INCLUI  := .T.
	Private lMsErroAuto := .F.
	Private nRecnoP51 := 0
	Private cMethod := "POST"
	Private cInd := ""
	Private _aMsgErr := {}
	private CUSERNAME := "INT"
	Private cErrorL := ""
	Public pIncObsSC := ""
	Private cIdPlan   := ""
	Private cQtdItens := ""
	Private cSolicit  := ""
	Private cTimeI    := Time()

	cSegun := cValToChar(SECONDS())
	::SetContentType('application/json')

	ret := oParser:FromJson(cJson)

	RpcSetEnv("01", "01010001",,, "COM", "U_RDPLX001")

	cIdPlan := oParser:C1XIDPLAN
	cQtdItens := cValToChar(Len(oParser:C1ITENS))	

	if ValType(ret) != "C"
		fGravaP51("1", cjson,,cIdPlan,cQtdItens,cSolicit)
		lRet := fValidJson(oParser)
		if !lRet
			cMsgErrX := "Algum campo do JSON está inválido ou estrutura vazia.  JSON: " + cJson
			SetRestFault(500,cMsgErrX)
			fGravaP51("2", cMsgErrX, .F.,cIdPlan,cQtdItens,cSolicit)
			return .F.
		endif
		SetMaxCodes( 9999999 )
		//Chave para controle de semáforo.
		cChvPlan := oParser:C1FILIAL + oParser:C1XIDPLAN
		lFree := MayIUseCode(cChvPlan)
		If !lFree
			nTent := 0
			Sleep(2000)
			While !(lFree := MayIUseCode(cChvPlan))
				nTent++
				Conout("Esperando integração do código -> " + cChvPlan)
				Sleep(2000)
				if nTent > 5
					cMsgErrX := "A Chave "+cChvPlan+" não foi incluída. Controle de Semáforo."
					fGravaP51("2", cMsgErrX, .F.,cIdPlan,cQtdItens,cSolicit)
					SetRestFault(500,cMsgErrX)
					Break
				endif
			enddo
		endif
		if !Empty(cMsgErrX)
			Return .F.
		endif
		Sleep(2000) //Espera por 2 segundos para possibilitar a finalização da outra thread
		//cUserJson := RetCodUsr(oParser:C1USER)
		aDadosUsr := FWSFLOADUSER(oParser:C1USER)
		if Len(aDadosUsr) > 0
			cUserJson := aDadosUsr[2]
		else
			cMsgErrX := "Usuário não existe no sistema P12"
			fGravaP51("2", cMsgErrX, .F.,cIdPlan,cQtdItens,cSolicit)
			SetRestFault(500,cMsgErrX)
			Return .F.
		endif

		__cUserID := cUserJson
		cFilBkp := cFilAnt
		cFilAnt := oParser:C1FILIAL
		cNumSc := GetSx8Num("SC1","C1_NUM")
		cSolicit := cNumSc

		//Valida a existencia da solicitação
		aRetExist := SCExist(cFilAnt, oParser:C1XIDPLAN)
		if aRetExist[1]
			oResponse	:=	JsonObject():New()
			oResponse["C1XIDPLAN"] 	:= oParser:C1XIDPLAN
			oResponse["C1FILIAL"] 	:= cFilAnt
			oResponse["C1NUM"] 		:= aRetExist[2]
			oResponse["cMessage"] 	:= cSegun+ cValToChar(ThreadID()) + ": Solicitação de compras já existe."
			cJsonResp := oResponse:ToJson()
			fGravaP51("2", cJsonResp, .F.,cIdPlan,cQtdItens,cSolicit)
			::setStatus(409)
			::SetResponse(cJsonResp)
			cFilAnt := cFilBkp
			Return .T.
		endif

		aCabecalho := {;
			{ "C1_NUM" ,cNumSc, NIL},;
			{ "C1_FILENT" , cFilAnt , NIL},;
			{ "C1_SOLICIT" , oParser:C1USER  , NIL},;
			{ "C1_EMISSAO" , SToD(oParser:C1EMISSAO) , NIL}}
		dDataBkp := dDataBase
		dDataBase := SToD(oParser:C1EMISSAO)


		aItens := {}
		for nX := 01 To Len(oParser:C1ITENS)
			nVunit := fbscUpr(cFilAnt, oParser:C1ITENS[nX]:C1PRODUTO,oParser:C1ITENS[nX]:C1LOCAL)///Posicione("SBZ",1,cFilAnt+oParser:C1ITENS[nX]:C1PRODUTO, "BZ_UPRC")
			//Regra solicitada pela RedeDor. Caso não tenha valor, preencher com 1.
			if nVunit == 0
				nVunit := 1
			endif

			aAdd(aItens, {;
				{"C1_FILIAL", cFilAnt , NIL},;
				{"C1_ITEM", StrZero(nX,4), NIL},;
				{"C1_XIDPLAN" , oParser:C1XIDPLAN , NIL},;
				{"C1_PRODUTO", PadR(oParser:C1ITENS[nX]:C1PRODUTO, TamSx3("C1_PRODUTO")[1]), NIL},;
				{"C1_QUANT", oParser:C1ITENS[nX]:C1QUANT, NIL},;
				{"C1_LOCAL", PadR(oParser:C1ITENS[nX]:C1LOCAL, TamSx3("C1_LOCAL")[1]), NIL},;
				{"C1_XTPSC", oParser:C1ITENS[nX]:C1XTPSC, NIL},;
				{"C1_XMOTIVO", oParser:C1ITENS[nX]:C1XMOTIVO, NIL},;
				{"C1_XCODSET", oParser:C1ITENS[nX]:C1XCODSET, NIL},;
				{"C1_OBS", oParser:C1ITENS[nX]:C1OBS, NIL},;
				{"C1_USER", cUserJson, NIL},;
				{"C1_VUNIT", nVunit, NIL},;
				{"C1_CC", posicione("NNR",1,cFilAnt+PadR(oParser:C1ITENS[nX]:C1LOCAL, TamSx3("C1_LOCAL")[1]),"NNR_XCUSTO"), NIL},;
				{"C1_DATPRF", StoD(oParser:C1ITENS[nX]:C1DATPRF), NIL}})
		Next nX

		MSExecAuto({|X,Y,Z| Mata110(X,Y,Z)}, aCabecalho, aItens, 3) //insere a SC no novo numero
		DbSeek(xFilial("SC1")+cNumSc)
		cRetNum := SC1->C1_NUM
		cUsrIn := SC1->C1_XUSRIN
		If lMsErroAuto
			//Adicionando para tratativas de erro via PE.
			nA := 0
			cMsgAux := ""
			For nA := 01 To Len(_aMsgErr)
				cMsgAux += _aMsgErr[nA] + "|" + CRLF
			Next nA
			cMsgErrX := EncodeUTF8(Replace(Replace(cMsgAux + MostraErro("C:\temp"), CRLF, ' '), '"', ''))
			SetRestFault(500,cMsgErrX)
			fGravaP51("2", cMsgErrX, .F.,cIdPlan,cQtdItens,cSolicit)
			DisarmTransaction()
			cFilAnt := cFilBkp
			Return .F.
		Else
			ConfirmSx8()
			aRetExist := SCExist(cFilAnt, oParser:C1XIDPLAN,cRetNum)
			if !aRetExist[1]
				cMsgErrX := "Solicitacao de compras nao gravada! Reenviar."
				SetRestFault(500,cMsgErrX)
				fGravaP51("2", cMsgErrX, .F.,cIdPlan,cQtdItens,cSolicit)
				DisarmTransaction()
				lRetorno := .F.
				cFilAnt := cFilBkp
			EndIf
		EndIf

		dDataBase := dDataBkp

		if lRetorno
			oResponse	:=	JsonObject():New()
			oResponse["C1NUM"] := cRetNum
			oResponse["C1XUSRIN"] := cUsrIn
			cJsonResp := oResponse:ToJson()
			::SetResponse(cJsonResp)
			fGravaP51("2", cJsonResp, .T.,cIdPlan,cQtdItens,cSolicit)
			cFilAnt := cFilBkp
		endif
	Else
		fGravaP51("1", "Erro na estrutura. Arquivo inválido! JSON: [" + cJson + "]",,cIdPlan,cQtdItens,cSolicit)
		SetRestFault(400,"Erro na estrutura. Arquivo inválido! JSON: [" + cJson + "]")
		Return .F.
	EndIf
	cFilAnt := cFilBkp
Return lRetorno

Static Function fValidJson(oParser)
	Local lRet := .T.
	Local nX, nY, nZ := 0
	Private cCampo := ""
	Private aCampos := {"C1FILIAL","C1XIDPLAN","C1EMISSAO", "C1ITENS", "C1USER"}
	private aCmpIt := {"C1ITEM",;
		"C1PRODUTO",;
		"C1QUANT",;
		"C1XTPSC",;
		"C1XMOTIVO",;
		"C1LOCAL",;
		"C1XCODSET",;
		"C1DATPRF",;
		"C1OBS",;
		"C1XITPLAN"}

	Default oParser := NIL

	aJsonName := oParser:GetNames()

	if Len(aJsonName) == 0
		Return .F.
	endif

	For nX := 01 To Len(aJsonName)
		if ValType(oParser[aJsonName[nX]]) == "A"
			if aScan(aCmpIt, aJsonName[nX]) > 0 .Or. aScan(aCampos, aJsonName[nX]) > 0
				for nY := 01 To Len(oParser[aJsonName[nX]])
					For nZ := 01 To Len(aCmpIt)
						if !oParser[aJsonName[nX]][nY]:hasProperty(aCmpIt[nZ])
							lRet := .F.
							Exit
						endif
					Next nX
					if !lRet
						Exit
					endif
				next nY
			else
				lRet := .F.
				Exit
			endif
		else
			if !oParser:hasProperty(aCampos[nX])
				lRet := .F.
				Exit
			endif
		endif
		if !lRet
			Exit
		endif
	Next nX

Return lRet

/*/{Protheus.doc} fGravaP51
description Função para gravar os dados das entradas das integrações na P51
@author  Ricard Junior
@since   08/02/21
@version 1.0

Função alterada para uma nova tabela, anteriormente utilizavamos a P19, mas para tornar a visualização mais fácil, mudamos para a nova tabela P51
Alterado por Lucas Miranda de Aguiar 28/04/2025
/*/
static function fGravaP51(cTipo, cBody, lSucesso, cIdPlan, cQtdItens, cSolicit)
	local aArea := GetArea()
	default lSucesso := .F.
	DbSelectArea("P51")
	if cTipo == "1"
		Reclock("P51", .T.)
		P51_FILIAL := cFilAnt
		P51_DTINI := DtoC(Date()) + " " + Time()
		P51_IDPLAN := cIdPlan
		P51_ITENS := cQtdItens
		P51_JSON := cBody
		P51_STATUS := "1"
		P51->(MsUnlock())
		nRecnoP51 := P51->(Recno())
		RestArea(aArea)
		return
	endif
	DbSelectArea("P51")
	P51->(DbGoTo(nRecnoP51))
	Reclock("P51", .F.)
	P51_DTFIM := DtoC(Date()) + " " + Time()
	P51_RESULT := cBody
	P51_STATUS := If(lSucesso,"2","3")
	P51_NUMSC := cSolicit
	P51_TEMPO := ElapTime(cTimeI,Time())
	P51->(MsUnlock())
	RestArea(aArea)
return

Static Function SCExist(cFil, cIdPlan,cNumInt)
	Local aArea := GetArea()
	Local cQuery := ""
	Local lRet := .F.
	Local cAlias := GetNextAlias()
	Local cNum := ""

	Default cNumInt := ""

	cQuery := " SELECT C1_NUM FROM " + RetSqlName("SC1") + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND C1_FILIAL = '"+cFil+"' " + CRLF
	cQuery += " AND C1_XIDPLAN = '"+cIdPlan+"' " + CRLF
	If !Empty(cNumInt)
		cQuery += " AND C1_NUM = '"+cNumInt+"' "
	EndIf

	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

	If !(cAlias)->(Eof())
		lRet := .T.
		cNum := (cAlias)->C1_NUM
	endif

	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return { lRet, cNum}


Static Function fbscUpr(cFil, cProd, cLocal)
	Local nUPRC := 0
	Local cAlias := GetNextAlias()

	cQuery := " SELECT BZ_UPRC FROM " + RetSqlName("SBZ") + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND BZ_FILIAL = '"+cFil+"'" + CRLF
	cQuery += " AND BZ_COD = '"+cProd+"'" + CRLF
	cQuery += " AND BZ_LOCPAD = '"+cLocal+"'" + CRLF

	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

	If !(cAlias)->(Eof())
		nUPRC := (cAlias)->BZ_UPRC
	endif

	(cAlias)->(DbCloseArea())
Return nUPRC


Static Function ChkErr(oErroArq)

	Local nI:= 0

	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf

	nI := 2

	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	End
	If SELECT("P51") <= 0
		DbSelectArea("P51")
	EndIf
	fGravaP51("2", cErrorL, .F.,cIdPlan,cQtdItens,cSolicit)
	SetRestFault(500,cErrorL)
	Break
Return



