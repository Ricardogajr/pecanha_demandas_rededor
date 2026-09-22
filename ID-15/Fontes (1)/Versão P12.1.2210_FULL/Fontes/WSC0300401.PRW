#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:91/ws/W0300401.apw?WSDL
Gerado em        05/23/17 08:29:08
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _ZFEATSS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW0300401
------------------------------------------------------------------------------- */

WSCLIENT WSW0300401

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GRAVACAO
	WSMETHOD INFCALEN
	WSMETHOD INFFUNC
	WSMETHOD LOGFUNC
	WSMETHOD RETACAO
	WSMETHOD VISSUPER

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cFILRESP                  AS string
	WSDATA   cMAT                      AS string
	WSDATA   cCHECK                    AS string
	WSDATA   cDTINICIO                 AS string
	WSDATA   cDTFIM                    AS string
	WSDATA   cITEMAD                   AS string
	WSDATA   cITEMOBJ                  AS string
	WSDATA   cPERIODO                  AS string
	WSDATA   lGRAVACAORESULT           AS boolean
	WSDATA   oWSINFCALENRESULT         AS W0300401__PERIOD
	WSDATA   cMATR                     AS string
	WSDATA   cDEPART                   AS string
	WSDATA   oWSINFFUNCRESULT          AS W0300401__INFSRA
	WSDATA   cMATRICU                  AS string
	WSDATA   oWSLOGFUNCRESULT          AS W0300401_INFFUNCIO
	WSDATA   oWSRETACAORESULT          AS W0300401__ACAO
	WSDATA   cRAMATRIC                 AS string
	WSDATA   cMATRICULA                AS string
	WSDATA   oWSVISSUPERRESULT         AS W0300401__TREESUP

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW0300401
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW0300401
	::oWSINFCALENRESULT  := W0300401__PERIOD():New()
	::oWSINFFUNCRESULT   := W0300401__INFSRA():New()
	::oWSLOGFUNCRESULT   := W0300401_INFFUNCIO():New()
	::oWSRETACAORESULT   := W0300401__ACAO():New()
	::oWSVISSUPERRESULT  := W0300401__TREESUP():New()
Return

WSMETHOD RESET WSCLIENT WSW0300401
	::cFILRESP           := NIL 
	::cMAT               := NIL 
	::cCHECK             := NIL 
	::cDTINICIO          := NIL 
	::cDTFIM             := NIL 
	::cITEMAD            := NIL 
	::cITEMOBJ           := NIL 
	::cPERIODO           := NIL 
	::lGRAVACAORESULT    := NIL 
	::oWSINFCALENRESULT  := NIL 
	::cMATR              := NIL 
	::cDEPART            := NIL 
	::oWSINFFUNCRESULT   := NIL 
	::cMATRICU           := NIL 
	::oWSLOGFUNCRESULT   := NIL 
	::oWSRETACAORESULT   := NIL 
	::cRAMATRIC          := NIL 
	::cMATRICULA         := NIL 
	::oWSVISSUPERRESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW0300401
Local oClone := WSW0300401():New()
	oClone:_URL          := ::_URL 
	oClone:cFILRESP      := ::cFILRESP
	oClone:cMAT          := ::cMAT
	oClone:cCHECK        := ::cCHECK
	oClone:cDTINICIO     := ::cDTINICIO
	oClone:cDTFIM        := ::cDTFIM
	oClone:cITEMAD       := ::cITEMAD
	oClone:cITEMOBJ      := ::cITEMOBJ
	oClone:cPERIODO      := ::cPERIODO
	oClone:lGRAVACAORESULT := ::lGRAVACAORESULT
	oClone:oWSINFCALENRESULT :=  IIF(::oWSINFCALENRESULT = NIL , NIL ,::oWSINFCALENRESULT:Clone() )
	oClone:cMATR         := ::cMATR
	oClone:cDEPART       := ::cDEPART
	oClone:oWSINFFUNCRESULT :=  IIF(::oWSINFFUNCRESULT = NIL , NIL ,::oWSINFFUNCRESULT:Clone() )
	oClone:cMATRICU      := ::cMATRICU
	oClone:oWSLOGFUNCRESULT :=  IIF(::oWSLOGFUNCRESULT = NIL , NIL ,::oWSLOGFUNCRESULT:Clone() )
	oClone:oWSRETACAORESULT :=  IIF(::oWSRETACAORESULT = NIL , NIL ,::oWSRETACAORESULT:Clone() )
	oClone:cRAMATRIC     := ::cRAMATRIC
	oClone:cMATRICULA    := ::cMATRICULA
	oClone:oWSVISSUPERRESULT :=  IIF(::oWSVISSUPERRESULT = NIL , NIL ,::oWSVISSUPERRESULT:Clone() )
Return oClone

// WSDL Method GRAVACAO of Service WSW0300401

WSMETHOD GRAVACAO WSSEND cFILRESP,cMAT,cCHECK,cDTINICIO,cDTFIM,cITEMAD,cITEMOBJ,cPERIODO WSRECEIVE lGRAVACAORESULT WSCLIENT WSW0300401
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRAVACAO xmlns="http://localhost:91/">'
cSoap += WSSoapValue("FILRESP", ::cFILRESP, cFILRESP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MAT", ::cMAT, cMAT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHECK", ::cCHECK, cCHECK , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTINICIO", ::cDTINICIO, cDTINICIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTFIM", ::cDTFIM, cDTFIM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ITEMAD", ::cITEMAD, cITEMAD , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ITEMOBJ", ::cITEMOBJ, cITEMOBJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PERIODO", ::cPERIODO, cPERIODO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRAVACAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/GRAVACAO",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0300401.apw")

::Init()
::lGRAVACAORESULT    :=  WSAdvValue( oXmlRet,"_GRAVACAORESPONSE:_GRAVACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFCALEN of Service WSW0300401

WSMETHOD INFCALEN WSSEND NULLPARAM WSRECEIVE oWSINFCALENRESULT WSCLIENT WSW0300401
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFCALEN xmlns="http://localhost:91/">'
cSoap += "</INFCALEN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INFCALEN",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0300401.apw")

::Init()
::oWSINFCALENRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFCALENRESPONSE:_INFCALENRESULT","_PERIOD",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFFUNC of Service WSW0300401

WSMETHOD INFFUNC WSSEND cMATR,cDEPART WSRECEIVE oWSINFFUNCRESULT WSCLIENT WSW0300401
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFFUNC xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATR", ::cMATR, cMATR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DEPART", ::cDEPART, cDEPART , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFFUNC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INFFUNC",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0300401.apw")

::Init()
::oWSINFFUNCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFFUNCRESPONSE:_INFFUNCRESULT","_INFSRA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LOGFUNC of Service WSW0300401

WSMETHOD LOGFUNC WSSEND cMATRICU WSRECEIVE oWSLOGFUNCRESULT WSCLIENT WSW0300401
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LOGFUNC xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICU", ::cMATRICU, cMATRICU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LOGFUNC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/LOGFUNC",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0300401.apw")

::Init()
::oWSLOGFUNCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LOGFUNCRESPONSE:_LOGFUNCRESULT","INFFUNCIO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETACAO of Service WSW0300401

WSMETHOD RETACAO WSSEND NULLPARAM WSRECEIVE oWSRETACAORESULT WSCLIENT WSW0300401
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETACAO xmlns="http://localhost:91/">'
cSoap += "</RETACAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/RETACAO",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0300401.apw")

::Init()
::oWSRETACAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETACAORESPONSE:_RETACAORESULT","_ACAO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VISSUPER of Service WSW0300401

WSMETHOD VISSUPER WSSEND cRAMATRIC,cMATRICULA WSRECEIVE oWSVISSUPERRESULT WSCLIENT WSW0300401
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VISSUPER xmlns="http://localhost:91/">'
cSoap += WSSoapValue("RAMATRIC", ::cRAMATRIC, cRAMATRIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VISSUPER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/VISSUPER",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0300401.apw")

::Init()
::oWSVISSUPERRESULT:SoapRecv( WSAdvValue( oXmlRet,"_VISSUPERRESPONSE:_VISSUPERRESULT","_TREESUP",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure _PERIOD

WSSTRUCT W0300401__PERIOD
	WSDATA   oWSINFRDU                 AS W0300401_ARRAYOFPERI
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401__PERIOD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401__PERIOD
Return

WSMETHOD CLONE WSCLIENT W0300401__PERIOD
	Local oClone := W0300401__PERIOD():NEW()
	oClone:oWSINFRDU            := IIF(::oWSINFRDU = NIL , NIL , ::oWSINFRDU:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401__PERIOD
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_INFRDU","ARRAYOFPERI",NIL,"Property oWSINFRDU as s0:ARRAYOFPERI on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSINFRDU := W0300401_ARRAYOFPERI():New()
		::oWSINFRDU:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure _INFSRA

WSSTRUCT W0300401__INFSRA
	WSDATA   oWSREGISTRO               AS W0300401_ARRAYOFINFFUNCIO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401__INFSRA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401__INFSRA
Return

WSMETHOD CLONE WSCLIENT W0300401__INFSRA
	Local oClone := W0300401__INFSRA():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401__INFSRA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFINFFUNCIO",NIL,"Property oWSREGISTRO as s0:ARRAYOFINFFUNCIO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0300401_ARRAYOFINFFUNCIO():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure INFFUNCIO

WSSTRUCT W0300401_INFFUNCIO
	WSDATA   cADMISSAO                 AS string
	WSDATA   cCARGO                    AS string
	WSDATA   cCENCUSTO                 AS string
	WSDATA   cCODPARTI                 AS string
	WSDATA   cDEPARTAMENTO             AS string
	WSDATA   cFILIALFUN                AS string
	WSDATA   cMATRICULA                AS string
	WSDATA   cNOME                     AS string
	WSDATA   cSITUACAO                 AS string
	WSDATA   cTEM                      AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_INFFUNCIO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_INFFUNCIO
Return

WSMETHOD CLONE WSCLIENT W0300401_INFFUNCIO
	Local oClone := W0300401_INFFUNCIO():NEW()
	oClone:cADMISSAO            := ::cADMISSAO
	oClone:cCARGO               := ::cCARGO
	oClone:cCENCUSTO            := ::cCENCUSTO
	oClone:cCODPARTI            := ::cCODPARTI
	oClone:cDEPARTAMENTO        := ::cDEPARTAMENTO
	oClone:cFILIALFUN           := ::cFILIALFUN
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cNOME                := ::cNOME
	oClone:cSITUACAO            := ::cSITUACAO
	oClone:cTEM                 := ::cTEM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_INFFUNCIO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cADMISSAO          :=  WSAdvValue( oResponse,"_ADMISSAO","string",NIL,"Property cADMISSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCARGO             :=  WSAdvValue( oResponse,"_CARGO","string",NIL,"Property cCARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCENCUSTO          :=  WSAdvValue( oResponse,"_CENCUSTO","string",NIL,"Property cCENCUSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODPARTI          :=  WSAdvValue( oResponse,"_CODPARTI","string",NIL,"Property cCODPARTI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPARTAMENTO      :=  WSAdvValue( oResponse,"_DEPARTAMENTO","string",NIL,"Property cDEPARTAMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIALFUN         :=  WSAdvValue( oResponse,"_FILIALFUN","string",NIL,"Property cFILIALFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATRICULA         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,"Property cMATRICULA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSITUACAO          :=  WSAdvValue( oResponse,"_SITUACAO","string",NIL,"Property cSITUACAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTEM               :=  WSAdvValue( oResponse,"_TEM","string",NIL,"Property cTEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _ACAO

WSSTRUCT W0300401__ACAO
	WSDATA   oWSINFRDW                 AS W0300401_ARRAYOFACAO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401__ACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401__ACAO
Return

WSMETHOD CLONE WSCLIENT W0300401__ACAO
	Local oClone := W0300401__ACAO():NEW()
	oClone:oWSINFRDW            := IIF(::oWSINFRDW = NIL , NIL , ::oWSINFRDW:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401__ACAO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_INFRDW","ARRAYOFACAO",NIL,"Property oWSINFRDW as s0:ARRAYOFACAO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSINFRDW := W0300401_ARRAYOFACAO():New()
		::oWSINFRDW:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure _TREESUP

WSSTRUCT W0300401__TREESUP
	WSDATA   oWSREGISTRO               AS W0300401_ARRAYOFTREESUP
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401__TREESUP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401__TREESUP
Return

WSMETHOD CLONE WSCLIENT W0300401__TREESUP
	Local oClone := W0300401__TREESUP():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401__TREESUP
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFTREESUP",NIL,"Property oWSREGISTRO as s0:ARRAYOFTREESUP on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0300401_ARRAYOFTREESUP():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFPERI

WSSTRUCT W0300401_ARRAYOFPERI
	WSDATA   oWSPERI                   AS W0300401_PERI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_ARRAYOFPERI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_ARRAYOFPERI
	::oWSPERI              := {} // Array Of  W0300401_PERI():New()
Return

WSMETHOD CLONE WSCLIENT W0300401_ARRAYOFPERI
	Local oClone := W0300401_ARRAYOFPERI():NEW()
	oClone:oWSPERI := NIL
	If ::oWSPERI <> NIL 
		oClone:oWSPERI := {}
		aEval( ::oWSPERI , { |x| aadd( oClone:oWSPERI , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_ARRAYOFPERI
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PERI","PERI",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPERI , W0300401_PERI():New() )
			::oWSPERI[len(::oWSPERI)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFINFFUNCIO

WSSTRUCT W0300401_ARRAYOFINFFUNCIO
	WSDATA   oWSINFFUNCIO              AS W0300401_INFFUNCIO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_ARRAYOFINFFUNCIO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_ARRAYOFINFFUNCIO
	::oWSINFFUNCIO         := {} // Array Of  W0300401_INFFUNCIO():New()
Return

WSMETHOD CLONE WSCLIENT W0300401_ARRAYOFINFFUNCIO
	Local oClone := W0300401_ARRAYOFINFFUNCIO():NEW()
	oClone:oWSINFFUNCIO := NIL
	If ::oWSINFFUNCIO <> NIL 
		oClone:oWSINFFUNCIO := {}
		aEval( ::oWSINFFUNCIO , { |x| aadd( oClone:oWSINFFUNCIO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_ARRAYOFINFFUNCIO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INFFUNCIO","INFFUNCIO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSINFFUNCIO , W0300401_INFFUNCIO():New() )
			::oWSINFFUNCIO[len(::oWSINFFUNCIO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFACAO

WSSTRUCT W0300401_ARRAYOFACAO
	WSDATA   oWSACAO                   AS W0300401_ACAO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_ARRAYOFACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_ARRAYOFACAO
	::oWSACAO              := {} // Array Of  W0300401_ACAO():New()
Return

WSMETHOD CLONE WSCLIENT W0300401_ARRAYOFACAO
	Local oClone := W0300401_ARRAYOFACAO():NEW()
	oClone:oWSACAO := NIL
	If ::oWSACAO <> NIL 
		oClone:oWSACAO := {}
		aEval( ::oWSACAO , { |x| aadd( oClone:oWSACAO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_ARRAYOFACAO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ACAO","ACAO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSACAO , W0300401_ACAO():New() )
			::oWSACAO[len(::oWSACAO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTREESUP

WSSTRUCT W0300401_ARRAYOFTREESUP
	WSDATA   oWSTREESUP                AS W0300401_TREESUP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_ARRAYOFTREESUP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_ARRAYOFTREESUP
	::oWSTREESUP           := {} // Array Of  W0300401_TREESUP():New()
Return

WSMETHOD CLONE WSCLIENT W0300401_ARRAYOFTREESUP
	Local oClone := W0300401_ARRAYOFTREESUP():NEW()
	oClone:oWSTREESUP := NIL
	If ::oWSTREESUP <> NIL 
		oClone:oWSTREESUP := {}
		aEval( ::oWSTREESUP , { |x| aadd( oClone:oWSTREESUP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_ARRAYOFTREESUP
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TREESUP","TREESUP",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTREESUP , W0300401_TREESUP():New() )
			::oWSTREESUP[len(::oWSTREESUP)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure PERI

WSSTRUCT W0300401_PERI
	WSDATA   cRDUCODIGO                AS string
	WSDATA   cRDUDATFIM                AS string
	WSDATA   cRDUDATINI                AS string
	WSDATA   cRDUDESC                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_PERI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_PERI
Return

WSMETHOD CLONE WSCLIENT W0300401_PERI
	Local oClone := W0300401_PERI():NEW()
	oClone:cRDUCODIGO           := ::cRDUCODIGO
	oClone:cRDUDATFIM           := ::cRDUDATFIM
	oClone:cRDUDATINI           := ::cRDUDATINI
	oClone:cRDUDESC             := ::cRDUDESC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_PERI
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRDUCODIGO         :=  WSAdvValue( oResponse,"_RDUCODIGO","string",NIL,"Property cRDUCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRDUDATFIM         :=  WSAdvValue( oResponse,"_RDUDATFIM","string",NIL,"Property cRDUDATFIM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRDUDATINI         :=  WSAdvValue( oResponse,"_RDUDATINI","string",NIL,"Property cRDUDATINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRDUDESC           :=  WSAdvValue( oResponse,"_RDUDESC","string",NIL,"Property cRDUDESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ACAO

WSSTRUCT W0300401_ACAO
	WSDATA   cRDWCODOBJ                AS string
	WSDATA   cRDWDESCIT                AS string
	WSDATA   cRDWITEM                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_ACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_ACAO
Return

WSMETHOD CLONE WSCLIENT W0300401_ACAO
	Local oClone := W0300401_ACAO():NEW()
	oClone:cRDWCODOBJ           := ::cRDWCODOBJ
	oClone:cRDWDESCIT           := ::cRDWDESCIT
	oClone:cRDWITEM             := ::cRDWITEM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_ACAO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRDWCODOBJ         :=  WSAdvValue( oResponse,"_RDWCODOBJ","string",NIL,"Property cRDWCODOBJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRDWDESCIT         :=  WSAdvValue( oResponse,"_RDWDESCIT","string",NIL,"Property cRDWDESCIT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRDWITEM           :=  WSAdvValue( oResponse,"_RDWITEM","string",NIL,"Property cRDWITEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TREESUP

WSSTRUCT W0300401_TREESUP
	WSDATA   cQBMATRESP                AS string
	WSDATA   cRAEMAIL                  AS string
	WSDATA   cRANOME                   AS string
	WSDATA   cRD4TREE                  AS string
	WSDATA   cSRADEPTO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0300401_TREESUP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0300401_TREESUP
Return

WSMETHOD CLONE WSCLIENT W0300401_TREESUP
	Local oClone := W0300401_TREESUP():NEW()
	oClone:cQBMATRESP           := ::cQBMATRESP
	oClone:cRAEMAIL             := ::cRAEMAIL
	oClone:cRANOME              := ::cRANOME
	oClone:cRD4TREE             := ::cRD4TREE
	oClone:cSRADEPTO            := ::cSRADEPTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0300401_TREESUP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cQBMATRESP         :=  WSAdvValue( oResponse,"_QBMATRESP","string",NIL,"Property cQBMATRESP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAEMAIL           :=  WSAdvValue( oResponse,"_RAEMAIL","string",NIL,"Property cRAEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRANOME            :=  WSAdvValue( oResponse,"_RANOME","string",NIL,"Property cRANOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRD4TREE           :=  WSAdvValue( oResponse,"_RD4TREE","string",NIL,"Property cRD4TREE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSRADEPTO          :=  WSAdvValue( oResponse,"_SRADEPTO","string",NIL,"Property cSRADEPTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


