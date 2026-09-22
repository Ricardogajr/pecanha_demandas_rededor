#INCLUDE "totvs.ch"
#INCLUDE "RESTFUL.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} DORWSATVG
description: WebServices Rest de fechamento da vaga.
@type function
@version 1.0 
@author Laura Peghini
@since 12/01/2026
@return variant, return_description
/*/ 

WSRESTFUL DORWSATVG DESCRIPTION "Metodo disponÌ≠vel para Atualiza Vaga" FORMAT APPLICATION_JSON_TYPE

	WSMETHOD POST DESCRIPTION "Metodo para fechamento da Vaga." 	WSSYNTAX "/api/admdig/v1/dorwsatvg"  PATH "/api/admdig/v1/dorwsatvg" PRODUCES APPLICATION_JSON
	
END WSRESTFUL


WSMETHOD POST WSSERVICE DORWSATVG

Local aArea 	:= GetArea()
Local cjson 	:= Self:GetContent()
Local oJson 	:= JsonObject():New()
Local lRet      := .T.
Local aRetUsr   := {}

Private cRetJson 	:= ""
Private cRequisit 	:= ""

	::SetContentType("application/json;charset=utf-8")
	::SetHeader("Accept","application/json;charset=utf-8")

	oJson:FromJson(cjson)

	//Loga na empresa e filial.
	RpcSetEnv("01", oJson["FILIAL"])

	cRequisit := oJson["REQUISITANTE"]
	aRetUsr := U_ValidUsa()

	If aRetUsr[1]
        If !Empty(oJson["VAGA"])
			DbSelectArea("SQS")				
			SQS->(DbSetOrder(1))
			If SQS->(DbSeek(oJson["FILIAL"] + oJson["VAGA"]))
                RecLock("SQS",.F.)
                    SQS->QS_VAGAFEC := SQS->QS_VAGAFEC + 1
                    If SQS->QS_VAGAFEC >= SQS->QS_NRVAGA
                        SQS->QS_DTFECH := STOD(oJson["DTFECH"])
                        lRet := .T.
                    EndIf
	            MsUnlock()
                fResp(.T., 'Vaga ajustada.')
            Else
                fResp(.F., "", 'Vaga n„o encontrada.')
            EndIf
            SQS->(DbCloseArea())
        Else
            fResp(.F., "", 'Vaga n„o informada.')
        EndIf	
	Else
		fResp(.F., "", 'Usu·rio n„o tem permiss„o.')	
	EndIf

	::setResponse(cRetJson)

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} fResp
Retornar a String de resposta para o Cavok
@type function
@version  1.0
@author Laura Peghini
@since 15/05/2025
@param cCod, character, c√≥digo do cliente
@param cLoja, character, loja do cliente
@param cMsgError, character, Mensagem de erro
@return nil
/*/
Static Function fResp(lRet, cMsgError)
	Default cCod  := ""
	Default cLoja := ""
	Default cMsgError := ""

	cMsgError := EncodeUTF8(Replace(Replace(cMsgError, CRLF, ''), '"', ''))
	oJson := JsonObject():new()
	oJson["STATUS"] := lRet
	oJson["MSG"] := AllTrim(cMsgError)
	cRetJson := oJson:toJson()

Return
