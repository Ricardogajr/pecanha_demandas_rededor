#INCLUDE "Totvs.ch"
#INCLUDE "FwMVCDef.ch"
#INCLUDE "RestFul.ch"

User Function WSXKPTInbound() ; Return // "dummy" function - Internal Use
/*/{Protheus.doc} WSXKPTInbound
@type           : WebService REST (API)
@Sample         : oRest():New()
@description	: WebService padrao Rest - Responsavel por realizar o processamento dos IDs pendentes
@Param			: Nulo
@return			: Nulo.
@ --------------|-------------------------
@author			: Joalisson Laurentino - 1198975-3610
@since			: 01/09/2024
/*/
WSRESTFUL WSXKPTInbound DESCRIPTION 'Serviço para processamento dos IDs pendentes TaxFy/Onergy'	FORMAT 'application/json'

	WSMETHOD POST DESCRIPTION "Executa os IDs enviado para cada processo." WSSYNTAX "/api/com/v1/WSXKPTInbound" PATH "/api/com/v1/WSXKPTInbound"

END WSRESTFUL

WSMETHOD POST WSSERVICE WSXKPTInbound
    Local lEnd		  := .F.
	Local oGrid	 	  := Nil
    Local lActiveLog  := SuperGetMv("KPT_MNTLOG",,.T.)
    Local cObjJson    := ""
	Local cIDOnergy   := ""

	Private aRet        := {.F.,""}
	Private cPostParams := ""
	Private lLogado     := .F.
	Private cBody       := ""
	Private cLogMsg     := "INICIO: "+ Strtran(time(),':',':') +" | "

	Self:SetContentType("application/json")

	cBody := Self:GetContent()

	oRetorno := JsonObject():New()
    cObjJson := oRetorno:FromJson(cBody)
    If ValType(cObjJson) == "U"
		cId       := oRetorno["id"]
		cIDOnergy := oRetorno["id-onergy"] 
		
		If cId $ "SC701;SC702;SC703"
			aRet[1] := .T.
			aRet[2] := "id-onergy atualizado com sucesso no P12"
			cPostParams := "id-onergy atualizado com sucesso no P12"
			
			cC7_FILIAL	:= oRetorno["header"]["C7_FILIAL"]
			cC7_NUM 	:= oRetorno["header"]["C7_NUM"]

			DbSelectarea("SC7")
			DbSetorder(1)
			If SC7->(DbSeek(cC7_FILIAL+cC7_NUM))
				DbSelectarea("ZKT")
				ZKT->(DbSetOrder(2))
				If ZKT->(MsSeek(SC7->C7_ZIDONGY))
					If RecLock('ZKT',.F.)
						ZKT->ZKT_RETURN := "ID Onergy: "+cIDOnergy+" ID AWS: "+ZKT->ZKT_RETURN
						ZKT->ZKT_ONERGY := cIDOnergy
						ZKT->(MsUnlock())
					EndIf
				EndIf

				While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == cC7_FILIAL+cC7_NUM
					SC7->(RecLock("SC7",.F.))
						SC7->C7_ZINTOGY := '2' //1-Pendente | 2-Integrado
						SC7->C7_ZIDONGY := cIDOnergy
					SC7->(MsUnlock())
				SC7->(DbSKip())
				EndDo
			EndIf
			SC7->(DBCloseArea())
		Else 
			cFilOri   := oRetorno["tenantId"]
			cCallBack := oRetorno["callback"]			
			cRotina   := oRetorno["rotina"]  
			cIDOnergy := oRetorno["id-onergy"]  
			
			U_xKPTGrvLog(lActiveLog,cFilOri,cId,cRotina,cIDOnergy,"TAXFY","PROTHEUS",cBody,,"1",/*dDtProc*/,/*cHrProc*/,cCallBack)

			aRet := U_xKPTExcAll(oGrid,lEnd,lLogado,.F.,"",cIDOnergy,cPostParams)
		EndIf
    Else
        U_xKPTGrvLog(lActiveLog,cFilAnt,"ERRO","ERRO","","TAXFY","PROTHEUS",cObjJson,cValtoChar(cBody),"3")
        U_xKPTLogMsg("xExecInb - Falha ao popular JsonObject. Erro: " + cObjJson)
    EndIf
	
	If !aRet[1]
		self:setStatus(400)
		self:setResponse(aRet[2])
	Else
		::SetResponse(aRet[2])
	EndIf
Return aRet[1]
