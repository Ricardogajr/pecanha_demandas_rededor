// #########################################################################################
// Projeto: Monkey
// Modulo : SIGAFIN
// Fonte  : status
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 17/07/22 | Rafael Yera Barchi| Verifica status do serviço da integração Protheus x Monkey
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} status
Verifica status do serviço da integração Protheus x Monkey

@author    Rafael Yera Barchi
@version   1.xx
@since     17/07/2022
/*/
//------------------------------------------------------------------------------------------
WSRESTFUL status DESCRIPTION "ATOS DATA status - Status do Serviço"

	WSDATA 		cResponse   AS STRING

	WSMETHOD 	GET 		DESCRIPTION "Verifica o status do serviço da integração Protheus x Monkey" WSSYNTAX "/status"

END WSRESTFUL



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} status
status - Método GET

@author    Rafael Yera Barchi
@version   1.xx
@since     17/07/2022

Exemplo de Requisição: 
//--- Início
null
//--- Fim

/*/
//------------------------------------------------------------------------------------------
WSMETHOD GET WSSERVICE status

	Local 	lReturn     := .T.
	Local 	lCheckAuth  := SuperGetMV("MK_CHKAUTH", , .F.)
	Local 	cResponse 	:= ""
	Local 	nHTTPCode 	:= 400
	Local   cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
	Local   cLogArq		:= "status"
	

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | status Início"))
	
	::SetContentType("application/JSON;charset=UTF-8")

	If lCheckAuth
		cUser := U_MNKRetUsr(::GetHeader("Authorization"))
	Else
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | status Executando sem autenticação"))
	EndIf

	If lCheckAuth .And. Empty(cUser)
		lReturn		:= .F.
		nHTTPCode 	:= 401
		cResponse 	:= '{ '
		cResponse 	+= '"status": "Usuário não autenticado"'
		cResponse 	+= '} '
	Else
		lReturn		:= .F.
		nHTTPCode 	:= 200
		cResponse 	:= '{ '
		cResponse 	+= '"status": "Integração Protheus x Monkey ativa"'
		cResponse 	+= '} '
	EndIf

	If !lReturn
		SetRestFault(nHTTPCode, EncodeUTF8(cResponse))
		::SetResponse(cResponse)
	Else
		::SetResponse(cResponse)
	EndIf

	MemoWrite(cLogDir + cLogArq + "_response.json", cResponse)

	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | status Fim"))
	FWLogMsg("INFO", , "MONKEY", "status", "999", "999", "Fim do Processo", 0, 0, {})

Return lReturn
//--< fim de arquivo >----------------------------------------------------------------------
