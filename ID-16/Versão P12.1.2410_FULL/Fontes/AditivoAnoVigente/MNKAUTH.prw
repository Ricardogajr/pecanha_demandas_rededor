// #########################################################################################
// Projeto: Monkey
// Modulo : Integração API
// Fonte  : MNKAUTH
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/09/20 | Rafael Yera Barchi| Autenticação na API
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#Include "Totvs.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNKAUTH
//Autenticação na API
@author Rafael Yera Barchi
@since 13/09/2020
@version 1.00

@type class
/*/
//------------------------------------------------------------------------------------------
User Function MNKAUTH()

    Local 	nN            	as numeric
    Local 	cURL          	as char
    Local 	cPostParms    	as char
    Local 	aHeadStr      	as array
    Local 	cHeaderGet    	as char
    Local 	cRetPost      	as char
    Local 	aNames        	as array
    Local 	oToken        	as object
    Local 	aRet          	as array
//	Local 	cMK_URL 		:= AllTrim(SuperGetMV("MK_URLCON"	, , "https://sap-proxy.monkeyecx.com/service/Authentication_v1.wsdl"))
//	Local 	cUsuario  		:= AllTrim(SuperGetMV("MK_USERCON"	, , "sapproxy.monkeyecx@gmail.com")) 
//  Local 	cSenhaUsr   	:= AllTrim(SuperGetMV("MK_PASSCON"	, , "Sapproxy2020!123"))  
//	Local 	cAuthBasic  	:= AllTrim(Encode64(cUsuario + ":" + cSenhaUsr))
    
	Private cTokenMK 	:= "" 

    aRet := {}
    
    //URL da API
    cURL := "https://hmg-zuul.monkeyecx.com/uaa/oauth/token"

    cPostParms := "client_secret=3b339cd0-b740-4b3e-bf2c-8f97e352f582"
    cPostParms += "&client_id=DP7jzMmfEH"
    cPostParms += "&grant_type=password"
    cPostParms += "&password=Sapproxy2020!123"
    cPostParms += "&username=sapproxy.monkeyecx@gmail.com"
    cPostParms += "&program=UNIPAR"

    //Header do POST
    aHeadStr := {"Content-Type: application/x-www-form-urlencoded"}

    //Efetua o POST na API
    cRetPost := HTTPPost(cURL, /*cGetParms*/, cPostParms, /*nTimeOut*/, aHeadStr, @cHeaderGet)

    //Exibe o retorno do POST e também o header de retorno
    ConOut("Retorno do POST:", cRetPost)
    ConOut("Header do POST:", cHeaderGet)

    //Transforma o retorno em um JSON
    oToken := JsonObject():New()
    oToken:FromJson(cRetPost)

    aNames := oToken:GetNames()
    VarInfo("Conteudo oToken:GetNames", aNames)

    //Exibe os dados com base no JSON
    For nN := 1 To Len(aNames)
        ConOut(aNames[nN])
        ConOut(oToken[aNames[nN]])
        AAdd(aRet, {aNames[nN], oToken[aNames[nN]]})
    Next nN

Return aRet



user function MNKAUT2(cTokenMK)
	Local lRet    := Nil
	Local cMsg    := ""
	Local oWsdl   := Nil
	Local cMsgRet := ""
    Local cMK_URL	:= alltrim(SuperGetMV("MK_URLCON"	, , "https://sap-proxy.monkeyecx.com/service/Authentication_v1.wsdl"))
	Local cUsuario  :=  alltrim(SuperGetMV("MK_USERCON"	, , "sapproxy.monkeyecx@gmail.com")) 
    Local cSenhaUsr   := alltrim(SuperGetMV("MK_PASSCON"	, , "Sapproxy2020!123"))  
	Local cAuthBasic  := Alltrim(Encode64(cUsuario + ":" + cSenhaUsr))
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T. //Desabilita o Uso de Segurança no WS
	xRet := oWsdl:ParseURL(cMK_URL)
	if xRet == .F.
		conout("Erro ParseURL: " + oWsdl:cError)
		Return
	endif

	xRet := oWsdl:ListOperations()
	If Len( xRet ) == 0
		conout( "Erro: " + oWsdl:cError )
	EndIf

	// Define a operação
	xRet := oWsdl:SetOperation("Login")
	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return
	endif

	lRet := oWsdl:AddHttpHeader( "Authorization" , "Basic "+cAuthBasic)
	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return
	endif

	cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+ CRLF
	cMsg += 'xmlns:v1="http://monkey.com.br/ecx/plugin/authentication/v1">'+ CRLF
	cMsg += '   <soapenv:Header/>'+ CRLF
	cMsg += '   <soapenv:Body>'+ CRLF
	cMsg += '      <v1:LoginRequest>'+ CRLF
	cMsg += '         <v1:program>UNIPAR</v1:program>'+ CRLF
	cMsg += '         <v1:clientId>DP7jzMmfEH</v1:clientId>'+ CRLF
	cMsg += '         <v1:clientSecret>3b339cd0-b740-4b3e-bf2c-8f97e352f582</v1:clientSecret>'+ CRLF
	cMsg += '      </v1:LoginRequest>'+ CRLF
	cMsg += '   </soapenv:Body>'+ CRLF
	cMsg += '</soapenv:Envelope>'+ CRLF

	lRet := oWsdl:SendSoapMsg(cMsg)
	If !lRet
		ConOut("[WSMNK03] - Erro SendSoapMsg: " + oWsdl:cError)
		ConOut("[WSMNK03] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
        lRet := .F.
	Else
		cMsgRet := oWsdl:GetSoapResponse()
      //RmiXGetTag(cXml, cTagIni, lTag)
        cTokenMK := GetTag(cMsgRet,"<ns2:accessToken>",.F.)
		If Empty(Alltrim(cTokenMK))
			ConOut("[WSMNK02] - Erro GetTag: Conectou mas nao pegou o Token")
			lRet := .F.
		Else
        	lRet := .T.
		Endif	
		conout( cMsgRet )
	EndIf

Return(lRet)

Static Function GetTag(cXml, cTagIni, lTag)
   Local cRet := ""
	Local cTagFim := ""
	Local nAtIni  := 0
	Local nAtFim  := 0
	Local nTamTag := 0

	Default lTag  := .T.

	cTagFim := StrTran(cTagIni, "<", "</")

	//Localização das tags na string do XML
	nAtIni := At( Lower(cTagIni), Lower(cXml) )
	nAtFim := At( Lower(cTagFim), Lower(cXml) )

	//Pega o valor entre a tag inicial e final
	If nAtIni > 0 .And. nAtFim > 0
		nTamTag := Len(cTagIni)
		cRet	:= SubStr(cXml, nAtIni + nTamTag, nAtFim - nAtIni - nTamTag)
	Endif

	//Retorna a tag com o conteudo
	If !Empty(cRet) .And. lTag
		cRet := cTagIni + cRet + cTagFim
	EndIf

Return(cRet)
