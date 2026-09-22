#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:91/ws/W0801101.apw?WSDL
Gerado em        05/23/17 08:29:42
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SOAMXJV ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW0801101
------------------------------------------------------------------------------- */

WSCLIENT WSW0801101

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BUSCAFERIAS
	WSMETHOD GETPERIODABERT
	WSMETHOD INSERESOLI
	WSMETHOD TEMSOLIABERT
	WSMETHOD VLDFERIAS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cMATRICULA                AS string
	WSDATA   oWSBUSCAFERIASRESULT      AS W0801101__RETFERIAS
	WSDATA   cEMPLOYEEFIL              AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   cTYPEOFPROG               AS string
	WSDATA   oWSGETPERIODABERTRESULT   AS W0801101_VACATPROG
	WSDATA   cMATRI                    AS string
	WSDATA   cNOMESOL                  AS string
	WSDATA   cDTINI                    AS string
	WSDATA   cDTFIM                    AS string
	WSDATA   cDURACAO                  AS string
	WSDATA   cABONO                    AS string
	WSDATA   cP13SL                    AS string
	WSDATA   cFILSOLICIIN              AS string
	WSDATA   cMATSOLICIIN              AS string
	WSDATA   cFILFUN                   AS string
	WSDATA   cOBS                      AS string
	WSDATA   oWSINSERESOLIRESULT       AS W0801101__RETSLFER
	WSDATA   lTEMSOLIABERTRESULT       AS boolean
	WSDATA   cLIMDIAS                  AS string
	WSDATA   lVLDFERIASRESULT          AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW0801101
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW0801101
	::oWSBUSCAFERIASRESULT := W0801101__RETFERIAS():New()
	::oWSGETPERIODABERTRESULT := W0801101_VACATPROG():New()
	::oWSINSERESOLIRESULT := W0801101__RETSLFER():New()
Return

WSMETHOD RESET WSCLIENT WSW0801101
	::cMATRICULA         := NIL 
	::oWSBUSCAFERIASRESULT := NIL 
	::cEMPLOYEEFIL       := NIL 
	::cREGISTRATION      := NIL 
	::cTYPEOFPROG        := NIL 
	::oWSGETPERIODABERTRESULT := NIL 
	::cMATRI             := NIL 
	::cNOMESOL           := NIL 
	::cDTINI             := NIL 
	::cDTFIM             := NIL 
	::cDURACAO           := NIL 
	::cABONO             := NIL 
	::cP13SL             := NIL 
	::cFILSOLICIIN       := NIL 
	::cMATSOLICIIN       := NIL 
	::cFILFUN            := NIL 
	::cOBS               := NIL 
	::oWSINSERESOLIRESULT := NIL 
	::lTEMSOLIABERTRESULT := NIL 
	::cLIMDIAS           := NIL 
	::lVLDFERIASRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW0801101
Local oClone := WSW0801101():New()
	oClone:_URL          := ::_URL 
	oClone:cMATRICULA    := ::cMATRICULA
	oClone:oWSBUSCAFERIASRESULT :=  IIF(::oWSBUSCAFERIASRESULT = NIL , NIL ,::oWSBUSCAFERIASRESULT:Clone() )
	oClone:cEMPLOYEEFIL  := ::cEMPLOYEEFIL
	oClone:cREGISTRATION := ::cREGISTRATION
	oClone:cTYPEOFPROG   := ::cTYPEOFPROG
	oClone:oWSGETPERIODABERTRESULT :=  IIF(::oWSGETPERIODABERTRESULT = NIL , NIL ,::oWSGETPERIODABERTRESULT:Clone() )
	oClone:cMATRI        := ::cMATRI
	oClone:cNOMESOL      := ::cNOMESOL
	oClone:cDTINI        := ::cDTINI
	oClone:cDTFIM        := ::cDTFIM
	oClone:cDURACAO      := ::cDURACAO
	oClone:cABONO        := ::cABONO
	oClone:cP13SL        := ::cP13SL
	oClone:cFILSOLICIIN  := ::cFILSOLICIIN
	oClone:cMATSOLICIIN  := ::cMATSOLICIIN
	oClone:cFILFUN       := ::cFILFUN
	oClone:cOBS          := ::cOBS
	oClone:oWSINSERESOLIRESULT :=  IIF(::oWSINSERESOLIRESULT = NIL , NIL ,::oWSINSERESOLIRESULT:Clone() )
	oClone:lTEMSOLIABERTRESULT := ::lTEMSOLIABERTRESULT
	oClone:cLIMDIAS      := ::cLIMDIAS
	oClone:lVLDFERIASRESULT := ::lVLDFERIASRESULT
Return oClone

// WSDL Method BUSCAFERIAS of Service WSW0801101

WSMETHOD BUSCAFERIAS WSSEND cMATRICULA WSRECEIVE oWSBUSCAFERIASRESULT WSCLIENT WSW0801101
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCAFERIAS xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCAFERIAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/BUSCAFERIAS",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0801101.apw")

::Init()
::oWSBUSCAFERIASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCAFERIASRESPONSE:_BUSCAFERIASRESULT","_RETFERIAS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPERIODABERT of Service WSW0801101

WSMETHOD GETPERIODABERT WSSEND cEMPLOYEEFIL,cREGISTRATION,cTYPEOFPROG WSRECEIVE oWSGETPERIODABERTRESULT WSCLIENT WSW0801101
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPERIODABERT xmlns="http://localhost:91/">'
cSoap += WSSoapValue("EMPLOYEEFIL", ::cEMPLOYEEFIL, cEMPLOYEEFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TYPEOFPROG", ::cTYPEOFPROG, cTYPEOFPROG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETPERIODABERT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/GETPERIODABERT",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0801101.apw")

::Init()
::oWSGETPERIODABERTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPERIODABERTRESPONSE:_GETPERIODABERTRESULT","VACATPROG",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INSERESOLI of Service WSW0801101

WSMETHOD INSERESOLI WSSEND cMATRI,cNOMESOL,cDTINI,cDTFIM,cDURACAO,cABONO,cP13SL,cFILSOLICIIN,cMATSOLICIIN,cFILFUN,cOBS WSRECEIVE oWSINSERESOLIRESULT WSCLIENT WSW0801101
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INSERESOLI xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRI", ::cMATRI, cMATRI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NOMESOL", ::cNOMESOL, cNOMESOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTINI", ::cDTINI, cDTINI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTFIM", ::cDTFIM, cDTFIM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DURACAO", ::cDURACAO, cDURACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ABONO", ::cABONO, cABONO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("P13SL", ::cP13SL, cP13SL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILSOLICIIN", ::cFILSOLICIIN, cFILSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATSOLICIIN", ::cMATSOLICIIN, cMATSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILFUN", ::cFILFUN, cFILFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OBS", ::cOBS, cOBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INSERESOLI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INSERESOLI",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0801101.apw")

::Init()
::oWSINSERESOLIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INSERESOLIRESPONSE:_INSERESOLIRESULT","_RETSLFER",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TEMSOLIABERT of Service WSW0801101

WSMETHOD TEMSOLIABERT WSSEND cFILFUN,cMATRICULA WSRECEIVE lTEMSOLIABERTRESULT WSCLIENT WSW0801101
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TEMSOLIABERT xmlns="http://localhost:91/">'
cSoap += WSSoapValue("FILFUN", ::cFILFUN, cFILFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TEMSOLIABERT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/TEMSOLIABERT",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0801101.apw")

::Init()
::lTEMSOLIABERTRESULT :=  WSAdvValue( oXmlRet,"_TEMSOLIABERTRESPONSE:_TEMSOLIABERTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VLDFERIAS of Service WSW0801101

WSMETHOD VLDFERIAS WSSEND cMATRICULA,cFILSOLICIIN,cDTINI,cLIMDIAS WSRECEIVE lVLDFERIASRESULT WSCLIENT WSW0801101
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VLDFERIAS xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILSOLICIIN", ::cFILSOLICIIN, cFILSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTINI", ::cDTINI, cDTINI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIMDIAS", ::cLIMDIAS, cLIMDIAS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VLDFERIAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/VLDFERIAS",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0801101.apw")

::Init()
::lVLDFERIASRESULT   :=  WSAdvValue( oXmlRet,"_VLDFERIASRESPONSE:_VLDFERIASRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure _RETFERIAS

WSSTRUCT W0801101__RETFERIAS
	WSDATA   oWSREGISTRO               AS W0801101_ARRAYOFRETFERIAS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101__RETFERIAS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101__RETFERIAS
Return

WSMETHOD CLONE WSCLIENT W0801101__RETFERIAS
	Local oClone := W0801101__RETFERIAS():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101__RETFERIAS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFRETFERIAS",NIL,"Property oWSREGISTRO as s0:ARRAYOFRETFERIAS on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0801101_ARRAYOFRETFERIAS():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure VACATPROG

WSSTRUCT W0801101_VACATPROG
	WSDATA   oWSLISTOFPERIOD           AS W0801101_ARRAYOFPERDVACATIONPROG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101_VACATPROG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101_VACATPROG
Return

WSMETHOD CLONE WSCLIENT W0801101_VACATPROG
	Local oClone := W0801101_VACATPROG():NEW()
	oClone:oWSLISTOFPERIOD      := IIF(::oWSLISTOFPERIOD = NIL , NIL , ::oWSLISTOFPERIOD:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101_VACATPROG
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFPERIOD","ARRAYOFPERDVACATIONPROG",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFPERIOD := W0801101_ARRAYOFPERDVACATIONPROG():New()
		::oWSLISTOFPERIOD:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure _RETSLFER

WSSTRUCT W0801101__RETSLFER
	WSDATA   cCDAPROV                  AS string
	WSDATA   cCODSOL                   AS string
	WSDATA   cFLAPROV                  AS string
	WSDATA   lLRETORN                  AS boolean
	WSDATA   cMSGAVSO                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101__RETSLFER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101__RETSLFER
Return

WSMETHOD CLONE WSCLIENT W0801101__RETSLFER
	Local oClone := W0801101__RETSLFER():NEW()
	oClone:cCDAPROV             := ::cCDAPROV
	oClone:cCODSOL              := ::cCODSOL
	oClone:cFLAPROV             := ::cFLAPROV
	oClone:lLRETORN             := ::lLRETORN
	oClone:cMSGAVSO             := ::cMSGAVSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101__RETSLFER
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDAPROV           :=  WSAdvValue( oResponse,"_CDAPROV","string",NIL,"Property cCDAPROV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODSOL            :=  WSAdvValue( oResponse,"_CODSOL","string",NIL,"Property cCODSOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFLAPROV           :=  WSAdvValue( oResponse,"_FLAPROV","string",NIL,"Property cFLAPROV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lLRETORN           :=  WSAdvValue( oResponse,"_LRETORN","boolean",NIL,"Property lLRETORN as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cMSGAVSO           :=  WSAdvValue( oResponse,"_MSGAVSO","string",NIL,"Property cMSGAVSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFRETFERIAS

WSSTRUCT W0801101_ARRAYOFRETFERIAS
	WSDATA   oWSRETFERIAS              AS W0801101_RETFERIAS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101_ARRAYOFRETFERIAS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101_ARRAYOFRETFERIAS
	::oWSRETFERIAS         := {} // Array Of  W0801101_RETFERIAS():New()
Return

WSMETHOD CLONE WSCLIENT W0801101_ARRAYOFRETFERIAS
	Local oClone := W0801101_ARRAYOFRETFERIAS():NEW()
	oClone:oWSRETFERIAS := NIL
	If ::oWSRETFERIAS <> NIL 
		oClone:oWSRETFERIAS := {}
		aEval( ::oWSRETFERIAS , { |x| aadd( oClone:oWSRETFERIAS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101_ARRAYOFRETFERIAS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETFERIAS","RETFERIAS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRETFERIAS , W0801101_RETFERIAS():New() )
			::oWSRETFERIAS[len(::oWSRETFERIAS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFPERDVACATIONPROG

WSSTRUCT W0801101_ARRAYOFPERDVACATIONPROG
	WSDATA   oWSPERDVACATIONPROG       AS W0801101_PERDVACATIONPROG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101_ARRAYOFPERDVACATIONPROG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101_ARRAYOFPERDVACATIONPROG
	::oWSPERDVACATIONPROG  := {} // Array Of  W0801101_PERDVACATIONPROG():New()
Return

WSMETHOD CLONE WSCLIENT W0801101_ARRAYOFPERDVACATIONPROG
	Local oClone := W0801101_ARRAYOFPERDVACATIONPROG():NEW()
	oClone:oWSPERDVACATIONPROG := NIL
	If ::oWSPERDVACATIONPROG <> NIL 
		oClone:oWSPERDVACATIONPROG := {}
		aEval( ::oWSPERDVACATIONPROG , { |x| aadd( oClone:oWSPERDVACATIONPROG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101_ARRAYOFPERDVACATIONPROG
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PERDVACATIONPROG","PERDVACATIONPROG",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPERDVACATIONPROG , W0801101_PERDVACATIONPROG():New() )
			::oWSPERDVACATIONPROG[len(::oWSPERDVACATIONPROG)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RETFERIAS

WSSTRUCT W0801101_RETFERIAS
	WSDATA   cCOD                      AS string
	WSDATA   cFILIALS                  AS string
	WSDATA   cMATRICULA                AS string
	WSDATA   cNOME                     AS string
	WSDATA   cSTATUS                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101_RETFERIAS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101_RETFERIAS
Return

WSMETHOD CLONE WSCLIENT W0801101_RETFERIAS
	Local oClone := W0801101_RETFERIAS():NEW()
	oClone:cCOD                 := ::cCOD
	oClone:cFILIALS             := ::cFILIALS
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cNOME                := ::cNOME
	oClone:cSTATUS              := ::cSTATUS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101_RETFERIAS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCOD               :=  WSAdvValue( oResponse,"_COD","string",NIL,"Property cCOD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIALS           :=  WSAdvValue( oResponse,"_FILIALS","string",NIL,"Property cFILIALS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATRICULA         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,"Property cMATRICULA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PERDVACATIONPROG

WSSTRUCT W0801101_PERDVACATIONPROG
	WSDATA   nDAYS                     AS integer OPTIONAL
	WSDATA   cEMPLOYEEFILIAL           AS string
	WSDATA   cFINALDATE                AS string
	WSDATA   cIDBASE                   AS string OPTIONAL
	WSDATA   cIDCODE                   AS string OPTIONAL
	WSDATA   cINITIALDATE              AS string
	WSDATA   nPROPORTIONALDAYS         AS float OPTIONAL
	WSDATA   cREGISTRATION             AS string
	WSDATA   nRESIDUALDAYS             AS float OPTIONAL
	WSDATA   nSCHEDULEDAYS             AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0801101_PERDVACATIONPROG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0801101_PERDVACATIONPROG
Return

WSMETHOD CLONE WSCLIENT W0801101_PERDVACATIONPROG
	Local oClone := W0801101_PERDVACATIONPROG():NEW()
	oClone:nDAYS                := ::nDAYS
	oClone:cEMPLOYEEFILIAL      := ::cEMPLOYEEFILIAL
	oClone:cFINALDATE           := ::cFINALDATE
	oClone:cIDBASE              := ::cIDBASE
	oClone:cIDCODE              := ::cIDCODE
	oClone:cINITIALDATE         := ::cINITIALDATE
	oClone:nPROPORTIONALDAYS    := ::nPROPORTIONALDAYS
	oClone:cREGISTRATION        := ::cREGISTRATION
	oClone:nRESIDUALDAYS        := ::nRESIDUALDAYS
	oClone:nSCHEDULEDAYS        := ::nSCHEDULEDAYS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0801101_PERDVACATIONPROG
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nDAYS              :=  WSAdvValue( oResponse,"_DAYS","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cEMPLOYEEFILIAL    :=  WSAdvValue( oResponse,"_EMPLOYEEFILIAL","string",NIL,"Property cEMPLOYEEFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFINALDATE         :=  WSAdvValue( oResponse,"_FINALDATE","string",NIL,"Property cFINALDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIDBASE            :=  WSAdvValue( oResponse,"_IDBASE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIDCODE            :=  WSAdvValue( oResponse,"_IDCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cINITIALDATE       :=  WSAdvValue( oResponse,"_INITIALDATE","string",NIL,"Property cINITIALDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPROPORTIONALDAYS  :=  WSAdvValue( oResponse,"_PROPORTIONALDAYS","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cREGISTRATION      :=  WSAdvValue( oResponse,"_REGISTRATION","string",NIL,"Property cREGISTRATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nRESIDUALDAYS      :=  WSAdvValue( oResponse,"_RESIDUALDAYS","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nSCHEDULEDAYS      :=  WSAdvValue( oResponse,"_SCHEDULEDAYS","float",NIL,NIL,NIL,"N",NIL,NIL) 
Return


