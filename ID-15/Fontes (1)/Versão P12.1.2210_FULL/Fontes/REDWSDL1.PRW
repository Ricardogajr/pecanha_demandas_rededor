#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.25.134.7:16199/REDWS1.apw?WSDL
Gerado em        03/12/18 13:42:49
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VFMLJRU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSREDWS1
------------------------------------------------------------------------------- */

WSCLIENT WSREDWS1

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD WASE
	WSMETHOD WASERET
	WSMETHOD WAU
	WSMETHOD WAURET
	WSMETHOD WBS
	WSMETHOD WBSRET
	WSMETHOD WDG
	WSMETHOD WDGRET
	WSMETHOD WFG
	WSMETHOD WFGRET

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSWSBASE                 AS REDWS1_STRBASE
	WSDATA   oWSWSSOLIC                AS REDWS1_ASTRWASE
	WSDATA   cWASERESULT               AS string
	WSDATA   oWSWSWASEENV              AS REDWS1_STRWASERET
	WSDATA   oWSWASERETRESULT          AS REDWS1_STRWASERET
	WSDATA   cWAURESULT                AS string
	WSDATA   oWSWSWAUENV               AS REDWS1_STRWAURET
	WSDATA   oWSWAURETRESULT           AS REDWS1_STRWAURET
	WSDATA   oWSWSCONF                 AS REDWS1_ASTRWBS
	WSDATA   cWBSRESULT                AS string
	WSDATA   oWSWSWBSENV               AS REDWS1_STRWBSRET
	WSDATA   oWSWBSRETRESULT           AS REDWS1_STRWBSRET
	WSDATA   cWDGRESULT                AS string
	WSDATA   oWSWSWDGENV               AS REDWS1_STRWDGENV
	WSDATA   oWSWSPEDIDO               AS REDWS1_LWDGENV
	WSDATA   oWSWDGRETRESULT           AS REDWS1_STRWDGRET
	WSDATA   cWFGRESULT                AS string
	WSDATA   oWSWSWFGENV               AS REDWS1_STRWFGENV
	WSDATA   oWSWSCONTRATO             AS REDWS1_LWFGENV
	WSDATA   oWSWFGRETRESULT           AS REDWS1_STRWFGRET

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSTRBASE                AS REDWS1_STRBASE
	WSDATA   oWSASTRWASE               AS REDWS1_ASTRWASE
	WSDATA   oWSSTRWASERET             AS REDWS1_STRWASERET
	WSDATA   oWSSTRWAURET              AS REDWS1_STRWAURET
	WSDATA   oWSASTRWBS                AS REDWS1_ASTRWBS
	WSDATA   oWSSTRWBSRET              AS REDWS1_STRWBSRET
	WSDATA   oWSSTRWDGENV              AS REDWS1_STRWDGENV
	WSDATA   oWSLWDGENV                AS REDWS1_LWDGENV
	WSDATA   oWSSTRWFGENV              AS REDWS1_STRWFGENV
	WSDATA   oWSLWFGENV                AS REDWS1_LWFGENV

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSREDWS1
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170624 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSREDWS1
	::oWSWSBASE          := REDWS1_STRBASE():New()
	::oWSWSSOLIC         := REDWS1_ASTRWASE():New()
	::oWSWSWASEENV       := REDWS1_STRWASERET():New()
	::oWSWASERETRESULT   := REDWS1_STRWASERET():New()
	::oWSWSWAUENV        := REDWS1_STRWAURET():New()
	::oWSWAURETRESULT    := REDWS1_STRWAURET():New()
	::oWSWSCONF          := REDWS1_ASTRWBS():New()
	::oWSWSWBSENV        := REDWS1_STRWBSRET():New()
	::oWSWBSRETRESULT    := REDWS1_STRWBSRET():New()
	::oWSWSWDGENV        := REDWS1_STRWDGENV():New()
	::oWSWSPEDIDO        := REDWS1_LWDGENV():New()
	::oWSWDGRETRESULT    := REDWS1_STRWDGRET():New()
	::oWSWSWFGENV        := REDWS1_STRWFGENV():New()
	::oWSWSCONTRATO      := REDWS1_LWFGENV():New()
	::oWSWFGRETRESULT    := REDWS1_STRWFGRET():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTRBASE         := ::oWSWSBASE
	::oWSASTRWASE        := ::oWSWSSOLIC
	::oWSSTRWASERET      := ::oWSWSWASEENV
	::oWSSTRWAURET       := ::oWSWSWAUENV
	::oWSASTRWBS         := ::oWSWSCONF
	::oWSSTRWBSRET       := ::oWSWSWBSENV
	::oWSSTRWDGENV       := ::oWSWSWDGENV
	::oWSLWDGENV         := ::oWSWSPEDIDO
	::oWSSTRWFGENV       := ::oWSWSWFGENV
	::oWSLWFGENV         := ::oWSWSCONTRATO
Return

WSMETHOD RESET WSCLIENT WSREDWS1
	::oWSWSBASE          := NIL 
	::oWSWSSOLIC         := NIL 
	::cWASERESULT        := NIL 
	::oWSWSWASEENV       := NIL 
	::oWSWASERETRESULT   := NIL 
	::cWAURESULT         := NIL 
	::oWSWSWAUENV        := NIL 
	::oWSWAURETRESULT    := NIL 
	::oWSWSCONF          := NIL 
	::cWBSRESULT         := NIL 
	::oWSWSWBSENV        := NIL 
	::oWSWBSRETRESULT    := NIL 
	::cWDGRESULT         := NIL 
	::oWSWSWDGENV        := NIL 
	::oWSWSPEDIDO        := NIL 
	::oWSWDGRETRESULT    := NIL 
	::cWFGRESULT         := NIL 
	::oWSWSWFGENV        := NIL 
	::oWSWSCONTRATO      := NIL 
	::oWSWFGRETRESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSTRBASE         := NIL
	::oWSASTRWASE        := NIL
	::oWSSTRWASERET      := NIL
	::oWSSTRWAURET       := NIL
	::oWSASTRWBS         := NIL
	::oWSSTRWBSRET       := NIL
	::oWSSTRWDGENV       := NIL
	::oWSLWDGENV         := NIL
	::oWSSTRWFGENV       := NIL
	::oWSLWFGENV         := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSREDWS1
Local oClone := WSREDWS1():New()
	oClone:_URL          := ::_URL 
	oClone:oWSWSBASE     :=  IIF(::oWSWSBASE = NIL , NIL ,::oWSWSBASE:Clone() )
	oClone:oWSWSSOLIC    :=  IIF(::oWSWSSOLIC = NIL , NIL ,::oWSWSSOLIC:Clone() )
	oClone:cWASERESULT   := ::cWASERESULT
	oClone:oWSWSWASEENV  :=  IIF(::oWSWSWASEENV = NIL , NIL ,::oWSWSWASEENV:Clone() )
	oClone:oWSWASERETRESULT :=  IIF(::oWSWASERETRESULT = NIL , NIL ,::oWSWASERETRESULT:Clone() )
	oClone:cWAURESULT    := ::cWAURESULT
	oClone:oWSWSWAUENV   :=  IIF(::oWSWSWAUENV = NIL , NIL ,::oWSWSWAUENV:Clone() )
	oClone:oWSWAURETRESULT :=  IIF(::oWSWAURETRESULT = NIL , NIL ,::oWSWAURETRESULT:Clone() )
	oClone:oWSWSCONF     :=  IIF(::oWSWSCONF = NIL , NIL ,::oWSWSCONF:Clone() )
	oClone:cWBSRESULT    := ::cWBSRESULT
	oClone:oWSWSWBSENV   :=  IIF(::oWSWSWBSENV = NIL , NIL ,::oWSWSWBSENV:Clone() )
	oClone:oWSWBSRETRESULT :=  IIF(::oWSWBSRETRESULT = NIL , NIL ,::oWSWBSRETRESULT:Clone() )
	oClone:cWDGRESULT    := ::cWDGRESULT
	oClone:oWSWSWDGENV   :=  IIF(::oWSWSWDGENV = NIL , NIL ,::oWSWSWDGENV:Clone() )
	oClone:oWSWSPEDIDO   :=  IIF(::oWSWSPEDIDO = NIL , NIL ,::oWSWSPEDIDO:Clone() )
	oClone:oWSWDGRETRESULT :=  IIF(::oWSWDGRETRESULT = NIL , NIL ,::oWSWDGRETRESULT:Clone() )
	oClone:cWFGRESULT    := ::cWFGRESULT
	oClone:oWSWSWFGENV   :=  IIF(::oWSWSWFGENV = NIL , NIL ,::oWSWSWFGENV:Clone() )
	oClone:oWSWSCONTRATO :=  IIF(::oWSWSCONTRATO = NIL , NIL ,::oWSWSCONTRATO:Clone() )
	oClone:oWSWFGRETRESULT :=  IIF(::oWSWFGRETRESULT = NIL , NIL ,::oWSWFGRETRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSTRBASE    := oClone:oWSWSBASE
	oClone:oWSASTRWASE   := oClone:oWSWSSOLIC
	oClone:oWSSTRWASERET := oClone:oWSWSWASEENV
	oClone:oWSSTRWAURET  := oClone:oWSWSWAUENV
	oClone:oWSASTRWBS    := oClone:oWSWSCONF
	oClone:oWSSTRWBSRET  := oClone:oWSWSWBSENV
	oClone:oWSSTRWDGENV  := oClone:oWSWSWDGENV
	oClone:oWSLWDGENV    := oClone:oWSWSPEDIDO
	oClone:oWSSTRWFGENV  := oClone:oWSWSWFGENV
	oClone:oWSLWFGENV    := oClone:oWSWSCONTRATO
Return oClone

// WSDL Method WASE of Service WSREDWS1

WSMETHOD WASE WSSEND oWSWSBASE,oWSWSSOLIC WSRECEIVE cWASERESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WASE xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSBASE", ::oWSWSBASE, oWSWSBASE , "STRBASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("WSSOLIC", ::oWSWSSOLIC, oWSWSSOLIC , "ASTRWASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WASE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WASE",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::cWASERESULT        :=  WSAdvValue( oXmlRet,"_WASERESPONSE:_WASERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WASERET of Service WSREDWS1

WSMETHOD WASERET WSSEND oWSWSWASEENV WSRECEIVE oWSWASERETRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WASERET xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSWASEENV", ::oWSWSWASEENV, oWSWSWASEENV , "STRWASERET", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WASERET>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WASERET",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::oWSWASERETRESULT:SoapRecv( WSAdvValue( oXmlRet,"_WASERETRESPONSE:_WASERETRESULT","STRWASERET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WAU of Service WSREDWS1

WSMETHOD WAU WSSEND oWSWSBASE,oWSWSSOLIC WSRECEIVE cWAURESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WAU xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSBASE", ::oWSWSBASE, oWSWSBASE , "STRBASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("WSSOLIC", ::oWSWSSOLIC, oWSWSSOLIC , "ASTRWASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WAU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WAU",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::cWAURESULT         :=  WSAdvValue( oXmlRet,"_WAURESPONSE:_WAURESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WAURET of Service WSREDWS1

WSMETHOD WAURET WSSEND oWSWSWAUENV WSRECEIVE oWSWAURETRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WAURET xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSWAUENV", ::oWSWSWAUENV, oWSWSWAUENV , "STRWAURET", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WAURET>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WAURET",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::oWSWAURETRESULT:SoapRecv( WSAdvValue( oXmlRet,"_WAURETRESPONSE:_WAURETRESULT","STRWAURET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WBS of Service WSREDWS1

WSMETHOD WBS WSSEND oWSWSBASE,oWSWSCONF WSRECEIVE cWBSRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WBS xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSBASE", ::oWSWSBASE, oWSWSBASE , "STRBASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("WSCONF", ::oWSWSCONF, oWSWSCONF , "ASTRWBS", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WBS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WBS",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::cWBSRESULT         :=  WSAdvValue( oXmlRet,"_WBSRESPONSE:_WBSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WBSRET of Service WSREDWS1

WSMETHOD WBSRET WSSEND oWSWSWBSENV WSRECEIVE oWSWBSRETRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WBSRET xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSWBSENV", ::oWSWSWBSENV, oWSWSWBSENV , "STRWBSRET", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WBSRET>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WBSRET",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::oWSWBSRETRESULT:SoapRecv( WSAdvValue( oXmlRet,"_WBSRETRESPONSE:_WBSRETRESULT","STRWBSRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WDG of Service WSREDWS1

WSMETHOD WDG WSSEND oWSWSBASE WSRECEIVE cWDGRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WDG xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSBASE", ::oWSWSBASE, oWSWSBASE , "STRBASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WDG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WDG",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::cWDGRESULT         :=  WSAdvValue( oXmlRet,"_WDGRESPONSE:_WDGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WDGRET of Service WSREDWS1

WSMETHOD WDGRET WSSEND oWSWSWDGENV,oWSWSPEDIDO WSRECEIVE oWSWDGRETRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WDGRET xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSWDGENV", ::oWSWSWDGENV, oWSWSWDGENV , "STRWDGENV", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("WSPEDIDO", ::oWSWSPEDIDO, oWSWSPEDIDO , "LWDGENV", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WDGRET>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WDGRET",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::oWSWDGRETRESULT:SoapRecv( WSAdvValue( oXmlRet,"_WDGRETRESPONSE:_WDGRETRESULT","STRWDGRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WFG of Service WSREDWS1

WSMETHOD WFG WSSEND oWSWSBASE WSRECEIVE cWFGRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WFG xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSBASE", ::oWSWSBASE, oWSWSBASE , "STRBASE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WFG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WFG",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::cWFGRESULT         :=  WSAdvValue( oXmlRet,"_WFGRESPONSE:_WFGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WFGRET of Service WSREDWS1

WSMETHOD WFGRET WSSEND oWSWSWFGENV,oWSWSCONTRATO WSRECEIVE oWSWFGRETRESULT WSCLIENT WSREDWS1
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WFGRET xmlns="http://int.totvs.com.br/">'
cSoap += WSSoapValue("WSWFGENV", ::oWSWSWFGENV, oWSWSWFGENV , "STRWFGENV", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("WSCONTRATO", ::oWSWSCONTRATO, oWSWSCONTRATO , "LWFGENV", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WFGRET>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://int.totvs.com.br/WFGRET",; 
	"DOCUMENT","http://int.totvs.com.br/",,"1.031217",; 
	"http://10.25.134.7:16199/REDWS1.apw")

::Init()
::oWSWFGRETRESULT:SoapRecv( WSAdvValue( oXmlRet,"_WFGRETRESPONSE:_WFGRETRESULT","STRWFGRET",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STRBASE

WSSTRUCT REDWS1_STRBASE
	WSDATA   cA2CGC                    AS string OPTIONAL
	WSDATA   cC7NUM                    AS string OPTIONAL
	WSDATA   cCANCELAMENTO             AS string OPTIONAL
	WSDATA   CFIL	                   AS string OPTIONAL
	WSDATA   cLOGIN                    AS string OPTIONAL
	WSDATA   cOPERACAO                 AS string OPTIONAL
	WSDATA   cPARAMETROS               AS string OPTIONAL
	WSDATA   cPASSWORD                 AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRBASE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRBASE
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRBASE
	Local oClone := REDWS1_STRBASE():NEW()
	oClone:cA2CGC               := ::cA2CGC
	oClone:cC7NUM               := ::cC7NUM
	oClone:cCANCELAMENTO        := ::cCANCELAMENTO
	oClone:cFIL	             	:= ::cFIL
	oClone:cLOGIN               := ::cLOGIN
	oClone:cOPERACAO            := ::cOPERACAO
	oClone:cPARAMETROS          := ::cPARAMETROS
	oClone:cPASSWORD            := ::cPASSWORD
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRBASE
	Local cSoap := ""
	cSoap += WSSoapValue("A2CGC", ::cA2CGC, ::cA2CGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7NUM", ::cC7NUM, ::cC7NUM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CANCELAMENTO", ::cCANCELAMENTO, ::cCANCELAMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILIAL", ::cFIL	, ::cFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOGIN", ::cLOGIN, ::cLOGIN , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OPERACAO", ::cOPERACAO, ::cOPERACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARAMETROS", ::cPARAMETROS, ::cPARAMETROS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, ::cPASSWORD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XIDPROC", ::cXIDPROC, ::cXIDPROC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ASTRWASE

WSSTRUCT REDWS1_ASTRWASE
	WSDATA   oWSLSOLIC                 AS REDWS1_ARRAYOFSTRWASE
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_ASTRWASE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_ASTRWASE
Return

WSMETHOD CLONE WSCLIENT REDWS1_ASTRWASE
	Local oClone := REDWS1_ASTRWASE():NEW()
	oClone:oWSLSOLIC            := IIF(::oWSLSOLIC = NIL , NIL , ::oWSLSOLIC:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_ASTRWASE
	Local cSoap := ""
	cSoap += WSSoapValue("LSOLIC", ::oWSLSOLIC, ::oWSLSOLIC , "ARRAYOFSTRWASE", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWASERET

WSSTRUCT REDWS1_STRWASERET
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWASERET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWASERET
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWASERET
	Local oClone := REDWS1_STRWASERET():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWASERET
	Local cSoap := ""
	cSoap += WSSoapValue("MSGRET", ::cMSGRET, ::cMSGRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XIDPROC", ::cXIDPROC, ::cXIDPROC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT REDWS1_STRWASERET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMSGRET            :=  WSAdvValue( oResponse,"_MSGRET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXIDPROC           :=  WSAdvValue( oResponse,"_XIDPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRWAURET

WSSTRUCT REDWS1_STRWAURET
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWAURET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWAURET
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWAURET
	Local oClone := REDWS1_STRWAURET():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWAURET
	Local cSoap := ""
	cSoap += WSSoapValue("MSGRET", ::cMSGRET, ::cMSGRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XIDPROC", ::cXIDPROC, ::cXIDPROC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT REDWS1_STRWAURET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMSGRET            :=  WSAdvValue( oResponse,"_MSGRET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXIDPROC           :=  WSAdvValue( oResponse,"_XIDPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ASTRWBS

WSSTRUCT REDWS1_ASTRWBS
	WSDATA   oWSACONF                  AS REDWS1_ARRAYOFSTRWBS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_ASTRWBS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_ASTRWBS
Return

WSMETHOD CLONE WSCLIENT REDWS1_ASTRWBS
	Local oClone := REDWS1_ASTRWBS():NEW()
	oClone:oWSACONF             := IIF(::oWSACONF = NIL , NIL , ::oWSACONF:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_ASTRWBS
	Local cSoap := ""
	cSoap += WSSoapValue("ACONF", ::oWSACONF, ::oWSACONF , "ARRAYOFSTRWBS", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWBSRET

WSSTRUCT REDWS1_STRWBSRET
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWBSRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWBSRET
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWBSRET
	Local oClone := REDWS1_STRWBSRET():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWBSRET
	Local cSoap := ""
	cSoap += WSSoapValue("MSGRET", ::cMSGRET, ::cMSGRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XIDPROC", ::cXIDPROC, ::cXIDPROC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT REDWS1_STRWBSRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMSGRET            :=  WSAdvValue( oResponse,"_MSGRET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXIDPROC           :=  WSAdvValue( oResponse,"_XIDPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRWDGENV

WSSTRUCT REDWS1_STRWDGENV
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWDGENV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWDGENV
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWDGENV
	Local oClone := REDWS1_STRWDGENV():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWDGENV
	Local cSoap := ""
	cSoap += WSSoapValue("MSGRET", ::cMSGRET, ::cMSGRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XIDPROC", ::cXIDPROC, ::cXIDPROC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure LWDGENV

WSSTRUCT REDWS1_LWDGENV
	WSDATA   oWSLISTAWDG               AS REDWS1_ARRAYOFSTRWDG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_LWDGENV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_LWDGENV
Return

WSMETHOD CLONE WSCLIENT REDWS1_LWDGENV
	Local oClone := REDWS1_LWDGENV():NEW()
	oClone:oWSLISTAWDG          := IIF(::oWSLISTAWDG = NIL , NIL , ::oWSLISTAWDG:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_LWDGENV
	Local cSoap := ""
	cSoap += WSSoapValue("LISTAWDG", ::oWSLISTAWDG, ::oWSLISTAWDG , "ARRAYOFSTRWDG", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWDGRET

WSSTRUCT REDWS1_STRWDGRET
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWDGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWDGRET
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWDGRET
	Local oClone := REDWS1_STRWDGRET():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT REDWS1_STRWDGRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMSGRET            :=  WSAdvValue( oResponse,"_MSGRET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXIDPROC           :=  WSAdvValue( oResponse,"_XIDPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRWFGENV

WSSTRUCT REDWS1_STRWFGENV
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWFGENV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWFGENV
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWFGENV
	Local oClone := REDWS1_STRWFGENV():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWFGENV
	Local cSoap := ""
	cSoap += WSSoapValue("MSGRET", ::cMSGRET, ::cMSGRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XIDPROC", ::cXIDPROC, ::cXIDPROC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure LWFGENV

WSSTRUCT REDWS1_LWFGENV
	WSDATA   oWSLISTAWFG               AS REDWS1_ARRAYOFSTRWFG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_LWFGENV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_LWFGENV
Return

WSMETHOD CLONE WSCLIENT REDWS1_LWFGENV
	Local oClone := REDWS1_LWFGENV():NEW()
	oClone:oWSLISTAWFG          := IIF(::oWSLISTAWFG = NIL , NIL , ::oWSLISTAWFG:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_LWFGENV
	Local cSoap := ""
	cSoap += WSSoapValue("LISTAWFG", ::oWSLISTAWFG, ::oWSLISTAWFG , "ARRAYOFSTRWFG", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWFGRET

WSSTRUCT REDWS1_STRWFGRET
	WSDATA   cMSGRET                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cXIDPROC                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWFGRET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWFGRET
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWFGRET
	Local oClone := REDWS1_STRWFGRET():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cSTATUS              := ::cSTATUS
	oClone:cXIDPROC             := ::cXIDPROC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT REDWS1_STRWFGRET
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMSGRET            :=  WSAdvValue( oResponse,"_MSGRET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXIDPROC           :=  WSAdvValue( oResponse,"_XIDPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFSTRWASE

WSSTRUCT REDWS1_ARRAYOFSTRWASE
	WSDATA   oWSSTRWASE                AS REDWS1_STRWASE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_ARRAYOFSTRWASE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_ARRAYOFSTRWASE
	::oWSSTRWASE           := {} // Array Of  REDWS1_STRWASE():New()
Return

WSMETHOD CLONE WSCLIENT REDWS1_ARRAYOFSTRWASE
	Local oClone := REDWS1_ARRAYOFSTRWASE():NEW()
	oClone:oWSSTRWASE := NIL
	If ::oWSSTRWASE <> NIL 
		oClone:oWSSTRWASE := {}
		aEval( ::oWSSTRWASE , { |x| aadd( oClone:oWSSTRWASE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_ARRAYOFSTRWASE
	Local cSoap := ""
	aEval( ::oWSSTRWASE , {|x| cSoap := cSoap  +  WSSoapValue("STRWASE", x , x , "STRWASE", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFSTRWBS

WSSTRUCT REDWS1_ARRAYOFSTRWBS
	WSDATA   oWSSTRWBS                 AS REDWS1_STRWBS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_ARRAYOFSTRWBS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_ARRAYOFSTRWBS
	::oWSSTRWBS            := {} // Array Of  REDWS1_STRWBS():New()
Return

WSMETHOD CLONE WSCLIENT REDWS1_ARRAYOFSTRWBS
	Local oClone := REDWS1_ARRAYOFSTRWBS():NEW()
	oClone:oWSSTRWBS := NIL
	If ::oWSSTRWBS <> NIL 
		oClone:oWSSTRWBS := {}
		aEval( ::oWSSTRWBS , { |x| aadd( oClone:oWSSTRWBS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_ARRAYOFSTRWBS
	Local cSoap := ""
	aEval( ::oWSSTRWBS , {|x| cSoap := cSoap  +  WSSoapValue("STRWBS", x , x , "STRWBS", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFSTRWDG

WSSTRUCT REDWS1_ARRAYOFSTRWDG
	WSDATA   oWSSTRWDG                 AS REDWS1_STRWDG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_ARRAYOFSTRWDG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_ARRAYOFSTRWDG
	::oWSSTRWDG            := {} // Array Of  REDWS1_STRWDG():New()
Return

WSMETHOD CLONE WSCLIENT REDWS1_ARRAYOFSTRWDG
	Local oClone := REDWS1_ARRAYOFSTRWDG():NEW()
	oClone:oWSSTRWDG := NIL
	If ::oWSSTRWDG <> NIL 
		oClone:oWSSTRWDG := {}
		aEval( ::oWSSTRWDG , { |x| aadd( oClone:oWSSTRWDG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_ARRAYOFSTRWDG
	Local cSoap := ""
	aEval( ::oWSSTRWDG , {|x| cSoap := cSoap  +  WSSoapValue("STRWDG", x , x , "STRWDG", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFSTRWFG

WSSTRUCT REDWS1_ARRAYOFSTRWFG
	WSDATA   oWSSTRWFG                 AS REDWS1_STRWFG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_ARRAYOFSTRWFG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_ARRAYOFSTRWFG
	::oWSSTRWFG            := {} // Array Of  REDWS1_STRWFG():New()
Return

WSMETHOD CLONE WSCLIENT REDWS1_ARRAYOFSTRWFG
	Local oClone := REDWS1_ARRAYOFSTRWFG():NEW()
	oClone:oWSSTRWFG := NIL
	If ::oWSSTRWFG <> NIL 
		oClone:oWSSTRWFG := {}
		aEval( ::oWSSTRWFG , { |x| aadd( oClone:oWSSTRWFG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_ARRAYOFSTRWFG
	Local cSoap := ""
	aEval( ::oWSSTRWFG , {|x| cSoap := cSoap  +  WSSoapValue("STRWFG", x , x , "STRWFG", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure STRWASE

WSSTRUCT REDWS1_STRWASE
	WSDATA   cC1FILIAL                 AS string
	WSDATA   cC1ITEM                   AS string
	WSDATA   cC1MOEDA                  AS string
	WSDATA   cC1NUM                    AS string
	WSDATA   cC1OBS                    AS string
	WSDATA   cC1PRODUTO                AS string
	WSDATA   cC1QTSEGUM                AS string
	WSDATA   cC1XIDBIO                 AS string OPTIONAL
	WSDATA   cC1XTPSC                  AS string
	WSDATA   cTITPDC                   AS string OPTIONAL
	WSDATA   cXCONDPAG                 AS string
	WSDATA   cXDTCOTA                  AS string
	WSDATA   cXHRCOTA                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWASE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWASE
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWASE
	Local oClone := REDWS1_STRWASE():NEW()
	oClone:cC1FILIAL            := ::cC1FILIAL
	oClone:cC1ITEM              := ::cC1ITEM
	oClone:cC1MOEDA             := ::cC1MOEDA
	oClone:cC1NUM               := ::cC1NUM
	oClone:cC1OBS               := ::cC1OBS
	oClone:cC1PRODUTO           := ::cC1PRODUTO
	oClone:cC1QTSEGUM           := ::cC1QTSEGUM
	oClone:cC1XIDBIO            := ::cC1XIDBIO
	oClone:cC1XTPSC             := ::cC1XTPSC
	oClone:cTITPDC              := ::cTITPDC
	oClone:cXCONDPAG            := ::cXCONDPAG
	oClone:cXDTCOTA             := ::cXDTCOTA
	oClone:cXHRCOTA             := ::cXHRCOTA
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWASE
	Local cSoap := ""
	cSoap += WSSoapValue("C1FILIAL", ::cC1FILIAL, ::cC1FILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1ITEM", ::cC1ITEM, ::cC1ITEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1MOEDA", ::cC1MOEDA, ::cC1MOEDA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1NUM", ::cC1NUM, ::cC1NUM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1OBS", ::cC1OBS, ::cC1OBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1PRODUTO", ::cC1PRODUTO, ::cC1PRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1QTSEGUM", ::cC1QTSEGUM, ::cC1QTSEGUM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1XIDBIO", ::cC1XIDBIO, ::cC1XIDBIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C1XTPSC", ::cC1XTPSC, ::cC1XTPSC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TITPDC", ::cTITPDC, ::cTITPDC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XCONDPAG", ::cXCONDPAG, ::cXCONDPAG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XDTCOTA", ::cXDTCOTA, ::cXDTCOTA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XHRCOTA", ::cXHRCOTA, ::cXHRCOTA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWBS

WSSTRUCT REDWS1_STRWBS
	WSDATA   cC7ITEM                   AS string
	WSDATA   cC7OBS                    AS string
	WSDATA   cC7PRODUTO                AS string
	WSDATA   nC7QTSEGUM                AS float
	WSDATA   cC7XIDBIO                 AS string
	WSDATA   cC7XITBIO                 AS string
	WSDATA   cC7XNUMEXT                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWBS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWBS
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWBS
	Local oClone := REDWS1_STRWBS():NEW()
	oClone:cC7ITEM              := ::cC7ITEM
	oClone:cC7OBS               := ::cC7OBS
	oClone:cC7PRODUTO           := ::cC7PRODUTO
	oClone:nC7QTSEGUM           := ::nC7QTSEGUM
	oClone:cC7XIDBIO            := ::cC7XIDBIO
	oClone:cC7XITBIO            := ::cC7XITBIO
	oClone:cC7XNUMEXT           := ::cC7XNUMEXT
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWBS
	Local cSoap := ""
	cSoap += WSSoapValue("C7ITEM", ::cC7ITEM, ::cC7ITEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7OBS", ::cC7OBS, ::cC7OBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7PRODUTO", ::cC7PRODUTO, ::cC7PRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7QTSEGUM", ::nC7QTSEGUM, ::nC7QTSEGUM , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7XIDBIO", ::cC7XIDBIO, ::cC7XIDBIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7XITBIO", ::cC7XITBIO, ::cC7XITBIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7XNUMEXT", ::cC7XNUMEXT, ::cC7XNUMEXT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWDG

WSSTRUCT REDWS1_STRWDG
	WSDATA   cA2CGC                    AS string OPTIONAL
	WSDATA   cC7CONDPAG                AS string OPTIONAL
	WSDATA   cC7DATPRF                 AS string OPTIONAL
	WSDATA   cC7FILIAL                 AS string OPTIONAL
	WSDATA   cC7ITEM                   AS string OPTIONAL
	WSDATA   cC7NUMSC                  AS string OPTIONAL
	WSDATA   cC7OBS                    AS string OPTIONAL
	WSDATA   nC7PRECO                  AS float OPTIONAL
	WSDATA   cC7PRODUTO                AS string OPTIONAL
	WSDATA   nC7QTSEGUM                AS float OPTIONAL
	WSDATA   cC7XIDBIO                 AS string OPTIONAL
	WSDATA   cC7XITBIO                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWDG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWDG
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWDG
	Local oClone := REDWS1_STRWDG():NEW()
	oClone:cA2CGC               := ::cA2CGC
	oClone:cC7CONDPAG           := ::cC7CONDPAG
	oClone:cC7DATPRF            := ::cC7DATPRF
	oClone:cC7FILIAL            := ::cC7FILIAL
	oClone:cC7ITEM              := ::cC7ITEM
	oClone:cC7NUMSC             := ::cC7NUMSC
	oClone:cC7OBS               := ::cC7OBS
	oClone:nC7PRECO             := ::nC7PRECO
	oClone:cC7PRODUTO           := ::cC7PRODUTO
	oClone:nC7QTSEGUM           := ::nC7QTSEGUM
	oClone:cC7XIDBIO            := ::cC7XIDBIO
	oClone:cC7XITBIO            := ::cC7XITBIO
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWDG
	Local cSoap := ""
	cSoap += WSSoapValue("A2CGC", ::cA2CGC, ::cA2CGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7CONDPAG", ::cC7CONDPAG, ::cC7CONDPAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7DATPRF", ::cC7DATPRF, ::cC7DATPRF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7FILIAL", ::cC7FILIAL, ::cC7FILIAL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7ITEM", ::cC7ITEM, ::cC7ITEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7NUMSC", ::cC7NUMSC, ::cC7NUMSC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7OBS", ::cC7OBS, ::cC7OBS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7PRECO", ::nC7PRECO, ::nC7PRECO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7PRODUTO", ::cC7PRODUTO, ::cC7PRODUTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7QTSEGUM", ::nC7QTSEGUM, ::nC7QTSEGUM , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7XIDBIO", ::cC7XIDBIO, ::cC7XIDBIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C7XITBIO", ::cC7XITBIO, ::cC7XITBIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure STRWFG

WSSTRUCT REDWS1_STRWFG
	WSDATA   cA2CGC                    AS string OPTIONAL
	WSDATA   cC8CONDPAG                AS string OPTIONAL
	WSDATA   cC8FILIAL                 AS string OPTIONAL
	WSDATA   cC8ITEMSC                 AS string OPTIONAL
	WSDATA   cC8NUMSC                  AS string OPTIONAL
	WSDATA   cC8OBS                    AS string OPTIONAL
	WSDATA   nC8PRAZO                  AS float OPTIONAL
	WSDATA   nC8PRECO                  AS float OPTIONAL
	WSDATA   cC8PRODUTO                AS string OPTIONAL
	WSDATA   nC8QTSEGUM                AS float OPTIONAL
	WSDATA   cC8XCTBIO                 AS string OPTIONAL
	WSDATA   cC8XIDBIO                 AS string OPTIONAL
	WSDATA   cTIPO                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT REDWS1_STRWFG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT REDWS1_STRWFG
Return

WSMETHOD CLONE WSCLIENT REDWS1_STRWFG
	Local oClone := REDWS1_STRWFG():NEW()
	oClone:cA2CGC               := ::cA2CGC
	oClone:cC8CONDPAG           := ::cC8CONDPAG
	oClone:cC8FILIAL            := ::cC8FILIAL
	oClone:cC8ITEMSC            := ::cC8ITEMSC
	oClone:cC8NUMSC             := ::cC8NUMSC
	oClone:cC8OBS               := ::cC8OBS
	oClone:nC8PRAZO             := ::nC8PRAZO
	oClone:nC8PRECO             := ::nC8PRECO
	oClone:cC8PRODUTO           := ::cC8PRODUTO
	oClone:nC8QTSEGUM           := ::nC8QTSEGUM
	oClone:cC8XCTBIO            := ::cC8XCTBIO
	oClone:cC8XIDBIO            := ::cC8XIDBIO
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPSEND WSCLIENT REDWS1_STRWFG
	Local cSoap := ""
	cSoap += WSSoapValue("A2CGC", ::cA2CGC, ::cA2CGC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8CONDPAG", ::cC8CONDPAG, ::cC8CONDPAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8FILIAL", ::cC8FILIAL, ::cC8FILIAL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8ITEMSC", ::cC8ITEMSC, ::cC8ITEMSC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8NUMSC", ::cC8NUMSC, ::cC8NUMSC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8OBS", ::cC8OBS, ::cC8OBS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8PRAZO", ::nC8PRAZO, ::nC8PRAZO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8PRECO", ::nC8PRECO, ::nC8PRECO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8PRODUTO", ::cC8PRODUTO, ::cC8PRODUTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8QTSEGUM", ::nC8QTSEGUM, ::nC8QTSEGUM , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8XCTBIO", ::cC8XCTBIO, ::cC8XCTBIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C8XIDBIO", ::cC8XIDBIO, ::cC8XIDBIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


