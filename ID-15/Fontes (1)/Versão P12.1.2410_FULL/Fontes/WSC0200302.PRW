#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:91/ws/W0200302.apw?WSDL
Gerado em        05/31/17 15:39:15
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KCKMTOJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW0200302
------------------------------------------------------------------------------- */

WSCLIENT WSW0200302

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BUSCAMAT
	WSMETHOD BUSCARH3

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cMATRICU                  AS string
	WSDATA   cFILIFUN                  AS string
	WSDATA   lBUSCAMATRESULT           AS boolean
	WSDATA   cFILGES                   AS string
	WSDATA   cDTINI                    AS string
	WSDATA   cDTFIM                    AS string
	WSDATA   cMAT                      AS string
	WSDATA   cSTATUS                   AS string
	WSDATA   cSERVICO                  AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   nPAGE                     AS integer
	WSDATA   oWSBUSCARH3RESULT         AS W0200302__ACOMPANHA

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW0200302
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW0200302
	::oWSBUSCARH3RESULT  := W0200302__ACOMPANHA():New()
Return

WSMETHOD RESET WSCLIENT WSW0200302
	::cMATRICU           := NIL 
	::cFILIFUN           := NIL 
	::lBUSCAMATRESULT    := NIL 
	::cFILGES            := NIL 
	::cDTINI             := NIL 
	::cDTFIM             := NIL 
	::cMAT               := NIL 
	::cSTATUS            := NIL 
	::cSERVICO           := NIL 
	::cCODIGO            := NIL 
	::nPAGE              := NIL 
	::oWSBUSCARH3RESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW0200302
Local oClone := WSW0200302():New()
	oClone:_URL          := ::_URL 
	oClone:cMATRICU      := ::cMATRICU
	oClone:cFILIFUN      := ::cFILIFUN
	oClone:lBUSCAMATRESULT := ::lBUSCAMATRESULT
	oClone:cFILGES       := ::cFILGES
	oClone:cDTINI        := ::cDTINI
	oClone:cDTFIM        := ::cDTFIM
	oClone:cMAT          := ::cMAT
	oClone:cSTATUS       := ::cSTATUS
	oClone:cSERVICO      := ::cSERVICO
	oClone:cCODIGO       := ::cCODIGO
	oClone:nPAGE         := ::nPAGE
	oClone:oWSBUSCARH3RESULT :=  IIF(::oWSBUSCARH3RESULT = NIL , NIL ,::oWSBUSCARH3RESULT:Clone() )
Return oClone

// WSDL Method BUSCAMAT of Service WSW0200302

WSMETHOD BUSCAMAT WSSEND cMATRICU,cFILIFUN WSRECEIVE lBUSCAMATRESULT WSCLIENT WSW0200302
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCAMAT xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICU", ::cMATRICU, cMATRICU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIFUN", ::cFILIFUN, cFILIFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCAMAT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/BUSCAMAT",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200302.apw")

::Init()
::lBUSCAMATRESULT    :=  WSAdvValue( oXmlRet,"_BUSCAMATRESPONSE:_BUSCAMATRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BUSCARH3 of Service WSW0200302

WSMETHOD BUSCARH3 WSSEND cFILGES,cMATRICU,cDTINI,cDTFIM,cMAT,cSTATUS,cSERVICO,cCODIGO,nPAGE WSRECEIVE oWSBUSCARH3RESULT WSCLIENT WSW0200302
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCARH3 xmlns="http://localhost:91/">'
cSoap += WSSoapValue("FILGES", ::cFILGES, cFILGES , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICU", ::cMATRICU, cMATRICU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTINI", ::cDTINI, cDTINI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTFIM", ::cDTFIM, cDTFIM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MAT", ::cMAT, cMAT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("STATUS", ::cSTATUS, cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SERVICO", ::cSERVICO, cSERVICO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCARH3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/BUSCARH3",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200302.apw")

::Init()
::oWSBUSCARH3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCARH3RESPONSE:_BUSCARH3RESULT","_ACOMPANHA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure _ACOMPANHA

WSSTRUCT W0200302__ACOMPANHA
	WSDATA   oWSREGISTRO               AS W0200302_ARRAYOFACOMPANHA
	WSDATA   nPAGESTOTAL               AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200302__ACOMPANHA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200302__ACOMPANHA
Return

WSMETHOD CLONE WSCLIENT W0200302__ACOMPANHA
	Local oClone := W0200302__ACOMPANHA():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200302__ACOMPANHA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFACOMPANHA",NIL,"Property oWSREGISTRO as s0:ARRAYOFACOMPANHA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0200302_ARRAYOFACOMPANHA():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,"Property nPAGESTOTAL as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFACOMPANHA

WSSTRUCT W0200302_ARRAYOFACOMPANHA
	WSDATA   oWSACOMPANHA              AS W0200302_ACOMPANHA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200302_ARRAYOFACOMPANHA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200302_ARRAYOFACOMPANHA
	::oWSACOMPANHA         := {} // Array Of  W0200302_ACOMPANHA():New()
Return

WSMETHOD CLONE WSCLIENT W0200302_ARRAYOFACOMPANHA
	Local oClone := W0200302_ARRAYOFACOMPANHA():NEW()
	oClone:oWSACOMPANHA := NIL
	If ::oWSACOMPANHA <> NIL 
		oClone:oWSACOMPANHA := {}
		aEval( ::oWSACOMPANHA , { |x| aadd( oClone:oWSACOMPANHA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200302_ARRAYOFACOMPANHA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ACOMPANHA","ACOMPANHA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSACOMPANHA , W0200302_ACOMPANHA():New() )
			::oWSACOMPANHA[len(::oWSACOMPANHA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ACOMPANHA

WSSTRUCT W0200302_ACOMPANHA
	WSDATA   cAPRACOM                  AS string
	WSDATA   cCODACOM                  AS string
	WSDATA   cDATACOM                  AS string
	WSDATA   cMATACOM                  AS string
	WSDATA   cNOMACOM                  AS string
	WSDATA   cSERACOM                  AS string
	WSDATA   cSTAACOM                  AS string
	WSDATA   cSTSBCOM                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200302_ACOMPANHA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200302_ACOMPANHA
Return

WSMETHOD CLONE WSCLIENT W0200302_ACOMPANHA
	Local oClone := W0200302_ACOMPANHA():NEW()
	oClone:cAPRACOM             := ::cAPRACOM
	oClone:cCODACOM             := ::cCODACOM
	oClone:cDATACOM             := ::cDATACOM
	oClone:cMATACOM             := ::cMATACOM
	oClone:cNOMACOM             := ::cNOMACOM
	oClone:cSERACOM             := ::cSERACOM
	oClone:cSTAACOM             := ::cSTAACOM
	oClone:cSTSBCOM             := ::cSTSBCOM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200302_ACOMPANHA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAPRACOM           :=  WSAdvValue( oResponse,"_APRACOM","string",NIL,"Property cAPRACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODACOM           :=  WSAdvValue( oResponse,"_CODACOM","string",NIL,"Property cCODACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATACOM           :=  WSAdvValue( oResponse,"_DATACOM","string",NIL,"Property cDATACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATACOM           :=  WSAdvValue( oResponse,"_MATACOM","string",NIL,"Property cMATACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMACOM           :=  WSAdvValue( oResponse,"_NOMACOM","string",NIL,"Property cNOMACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERACOM           :=  WSAdvValue( oResponse,"_SERACOM","string",NIL,"Property cSERACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTAACOM           :=  WSAdvValue( oResponse,"_STAACOM","string",NIL,"Property cSTAACOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTSBCOM           :=  WSAdvValue( oResponse,"_STSBCOM","string",NIL,"Property cSTSBCOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return
