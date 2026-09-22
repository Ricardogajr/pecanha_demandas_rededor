#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSBLQFOR
description: API de Integração de bloqueio de fornecedor
@author  Ricardo Junior
@since   24/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------

WSRESTFUL WSBLQFOR DESCRIPTION "Bloqueio de fornecedor" FORMAT APPLICATION_JSON_TYPE
	public data cStatus as character
	public data cMsg as character

	WSMETHOD POST DESCRIPTION "Metodo para atualizar status do fornecedor" WSSYNTAX "/fornecedor/"

END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} POST
description: Metodo POST para atualização do status do fornecedor
@author  Ricardo Junior
@since   24/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE WSBLQFOR
	Local lPost := .T. as logical
	Local cJson := ::GetContent() as character
	local oParseJSON := Nil
	Local oError := ErrorBlock({|e| setErrorMsg(e:Description, 500)})
	private nRecnoP19 := 0
	private cIndice := ""
	
	::cStatus := "ERRO"
	::cMsg := ""

	::SetContentType("application/json;charset=utf-8")
	::SetHeader("Accept","application/json;charset=utf-8")

	FWJsonDeserialize(cJson, @oParseJSON)

	if!(oParseJSON:A2_MSBLQL$"1|2")
		cMsgError := "Status do bloqueio invalido"
		fGravaP19("1",cmsgError, .F.)		
		::SetResponse('{"status":"ERRO", "descricao":"'+cmsgError+'"}')
		return .T.
	endif

	fGravaP19("1",cJson, .F.)
	cIndice := xFilial("SA2") + PadR(oParseJSON:A2_COD, TamSx3("A2_COD")[01])+ PadR(oParseJSON:A2_LOJA, TamSx3("A2_LOJA")[01])
	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(01))
	if SA2->(DbSeek(cIndice))
		RecLock("SA2",.F.)
		SA2->A2_MSBLQL := oParseJSON:A2_MSBLQL
		SA2->(MsUnlock())
		::cStatus := "OK"
		::cMsg := "O Fornecedor "+ AllTrim(SA2->A2_NOME) + " foi "+IIF(oParseJSON:A2_MSBLQL=="1", "Bloqueado", "Desbloqueado")
	else
		::cMsg := "Fornecedor nao encontrado!"
		fGravaP19("2",::cMsg, .F.)
		//setErrorMsg(::cMsg, 204)
		::SetResponse('{"status":"ERRO", "descricao":"'+::cMsg+'"}')
		return .T.
	endif
	::SetResponse('{"status":"'+::cStatus+'", "descricao":"'+::cMsg+'"}')
	fGravaP19("2",::cMsg, .T.)
	ErrorBlock(oError)
Return lPost

//-------------------------------------------------------------------
/*/{Protheus.doc} setErrorMsg
description: retornar o setrespfault
@author  Ricardo Junior
@since   24/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function setErrorMsg(cMsg, nCod)
	default cMsg := "Não foi passada a mensagem para a função [setErrorMsg]"
	default nCod := 500
	SetRestFault(nCod, cMsg)
Return .F.

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
	Local cTabela := "SA2"
	default lSucesso := .F.
	DbSelectArea("P19")
	if cTipo == "1"
		Reclock("P19", .T.)
		P19_FILIAL := xFilial()
		P19_DTHRI := FwTimeStamp()
		P19_ID := FWUUIDV4()
		P19_ROTINA := "WSBLQFOR"
		P19_INDKEY := "Em processamento... " + Substr(cBody, 1, 10)
		P19_INPUT := cBody
		P19_STATUS := "1"
		P19->(MsUnlock())
		nRecnoP19 := P19->(Recno())
		return
	endif
	if nRecnoP19 > 0
		P19->(DbGoTop())
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
