#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:91/ws/W1301200.apw?WSDL
Gerado em        01/08/18 10:24:38
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _UHXGQSP ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW1301200
------------------------------------------------------------------------------- */

WSCLIENT WSW1301200

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ALLNOVOACESSO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCODIGO                   AS string
	WSDATA   lALLNOVOACESSORESULT      AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW1301200
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171107 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW1301200
Return

WSMETHOD RESET WSCLIENT WSW1301200
	::cCODIGO            := NIL 
	::lALLNOVOACESSORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW1301200
Local oClone := WSW1301200():New()
	oClone:_URL          := ::_URL 
	oClone:cCODIGO       := ::cCODIGO
	oClone:lALLNOVOACESSORESULT := ::lALLNOVOACESSORESULT
Return oClone

// WSDL Method ALLNOVOACESSO of Service WSW1301200

WSMETHOD ALLNOVOACESSO WSSEND cCODIGO WSRECEIVE lALLNOVOACESSORESULT WSCLIENT WSW1301200
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALLNOVOACESSO xmlns="http://localhost:91/">'
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ALLNOVOACESSO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/ALLNOVOACESSO",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W1301200.apw")

::Init()
::lALLNOVOACESSORESULT :=  WSAdvValue( oXmlRet,"_ALLNOVOACESSORESPONSE:_ALLNOVOACESSORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



