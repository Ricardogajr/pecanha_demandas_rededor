#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:81/ws/W1303701.apw?WSDL
Gerado em        06/05/18 16:49:12
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SRNSNYO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW1303701
------------------------------------------------------------------------------- */

WSCLIENT WSW1303701

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DELDOCDEV
	WSMETHOD UPSERTDOCDEV

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCIDINTEG                 AS string
	WSDATA   cDELDOCDEVRESULT          AS string
	WSDATA   oWSOCABDOCENT             AS W1303701_CABECALHODOCUMENTOENTRADA
	WSDATA   cCDATA                    AS string
	WSDATA   cUPSERTDOCDEVRESULT       AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSCABECALHODOCUMENTOENTRADA AS W1303701_CABECALHODOCUMENTOENTRADA

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW1303701
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW1303701
	::oWSOCABDOCENT      := W1303701_CABECALHODOCUMENTOENTRADA():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCABECALHODOCUMENTOENTRADA := ::oWSOCABDOCENT
Return

WSMETHOD RESET WSCLIENT WSW1303701
	::cCIDINTEG          := NIL 
	::cDELDOCDEVRESULT   := NIL 
	::oWSOCABDOCENT      := NIL 
	::cCDATA             := NIL 
	::cUPSERTDOCDEVRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCABECALHODOCUMENTOENTRADA := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW1303701
Local oClone := WSW1303701():New()
	oClone:_URL          := ::_URL 
	oClone:cCIDINTEG     := ::cCIDINTEG
	oClone:cDELDOCDEVRESULT := ::cDELDOCDEVRESULT
	oClone:oWSOCABDOCENT :=  IIF(::oWSOCABDOCENT = NIL , NIL ,::oWSOCABDOCENT:Clone() )
	oClone:cCDATA        := ::cCDATA
	oClone:cUPSERTDOCDEVRESULT := ::cUPSERTDOCDEVRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSCABECALHODOCUMENTOENTRADA := oClone:oWSOCABDOCENT
Return oClone

// WSDL Method DELDOCDEV of Service WSW1303701

WSMETHOD DELDOCDEV WSSEND cCIDINTEG WSRECEIVE cDELDOCDEVRESULT WSCLIENT WSW1303701
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DELDOCDEV xmlns="http://localhost:81/">'
cSoap += WSSoapValue("CIDINTEG", ::cCIDINTEG, cCIDINTEG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DELDOCDEV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/DELDOCDEV",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/W1303701.apw")

::Init()
::cDELDOCDEVRESULT   :=  WSAdvValue( oXmlRet,"_DELDOCDEVRESPONSE:_DELDOCDEVRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method UPSERTDOCDEV of Service WSW1303701

WSMETHOD UPSERTDOCDEV WSSEND oWSOCABDOCENT,cCDATA WSRECEIVE cUPSERTDOCDEVRESULT WSCLIENT WSW1303701
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UPSERTDOCDEV xmlns="http://localhost:81/">'
cSoap += WSSoapValue("OCABDOCENT", ::oWSOCABDOCENT, oWSOCABDOCENT , "CABECALHODOCUMENTOENTRADA", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDATA", ::cCDATA, cCDATA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UPSERTDOCDEV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/UPSERTDOCDEV",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/W1303701.apw")

::Init()
::cUPSERTDOCDEVRESULT :=  WSAdvValue( oXmlRet,"_UPSERTDOCDEVRESPONSE:_UPSERTDOCDEVRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CABECALHODOCUMENTOENTRADA

WSSTRUCT W1303701_CABECALHODOCUMENTOENTRADA
	WSDATA   cCDOC                     AS string
	WSDATA   cCFILIALDOC               AS string
	WSDATA   cCFORNECEDOR              AS string
	WSDATA   cCLOJA                    AS string
	WSDATA   cCSERIE                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1303701_CABECALHODOCUMENTOENTRADA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1303701_CABECALHODOCUMENTOENTRADA
Return

WSMETHOD CLONE WSCLIENT W1303701_CABECALHODOCUMENTOENTRADA
	Local oClone := W1303701_CABECALHODOCUMENTOENTRADA():NEW()
	oClone:cCDOC                := ::cCDOC
	oClone:cCFILIALDOC          := ::cCFILIALDOC
	oClone:cCFORNECEDOR         := ::cCFORNECEDOR
	oClone:cCLOJA               := ::cCLOJA
	oClone:cCSERIE              := ::cCSERIE
Return oClone

WSMETHOD SOAPSEND WSCLIENT W1303701_CABECALHODOCUMENTOENTRADA
	Local cSoap := ""
	cSoap += WSSoapValue("CDOC", ::cCDOC, ::cCDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CFILIALDOC", ::cCFILIALDOC, ::cCFILIALDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CFORNECEDOR", ::cCFORNECEDOR, ::cCFORNECEDOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CLOJA", ::cCLOJA, ::cCLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CSERIE", ::cCSERIE, ::cCSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


