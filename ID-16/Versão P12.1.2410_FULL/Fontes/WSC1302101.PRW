#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://spon010108393:86/ws0101/W1302100.apw?WSDL
Gerado em        03/12/18 18:03:37
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KSSSNTS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW1302100
------------------------------------------------------------------------------- */

WSCLIENT WSW1302100

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ALLBUSCDEPTO
	WSMETHOD ALLCNTRCUSTO
	WSMETHOD RETDEPARTAMENTOS
	WSMETHOD RETFILIAIS
	WSMETHOD RETFUNCRG
	WSMETHOD RETPOSTOS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCDEPTO                   AS string
	WSDATA   cFILPOSTO                 AS string
	WSDATA   cCODPOSTO                 AS string
	WSDATA   nALLBUSCDEPTORESULT       AS integer
	WSDATA   cCFILP                    AS string
	WSDATA   oWSALLCNTRCUSTORESULT     AS W1302100_CNTRCUSTO
	WSDATA   cFILREPOR                 AS string
	WSDATA   cFILTRO                   AS string
	WSDATA   cCAMPO                    AS string
	WSDATA   cOCUPADOS                 AS string
	WSDATA   nPAGE                     AS integer
	WSDATA   oWSRETDEPARTAMENTOSRESULT AS W1302100__ALLDEPART
	WSDATA   oWSRETFILIAISRESULT       AS W1302100__ALLFIL
	WSDATA   oWSRETFUNCRGRESULT        AS W1302100__ALLFUNCAO
	WSDATA   cEMPLOYEEFIL              AS string
	WSDATA   cDEPARTMENTID             AS string
	WSDATA   cFILTERFIELD              AS string
	WSDATA   cFILTERVALUE              AS string
	WSDATA   oWSRETPOSTOSRESULT        AS W1302100__ALLPOSTOS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW1302100
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160707 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW1302100
	::oWSALLCNTRCUSTORESULT := W1302100_CNTRCUSTO():New()
	::oWSRETDEPARTAMENTOSRESULT := W1302100__ALLDEPART():New()
	::oWSRETFILIAISRESULT := W1302100__ALLFIL():New()
	::oWSRETFUNCRGRESULT := W1302100__ALLFUNCAO():New()
	::oWSRETPOSTOSRESULT := W1302100__ALLPOSTOS():New()
Return

WSMETHOD RESET WSCLIENT WSW1302100
	::cCDEPTO            := NIL 
	::cFILPOSTO          := NIL 
	::cCODPOSTO          := NIL 
	::nALLBUSCDEPTORESULT := NIL 
	::cCFILP             := NIL 
	::oWSALLCNTRCUSTORESULT := NIL 
	::cFILREPOR          := NIL 
	::cFILTRO            := NIL 
	::cCAMPO             := NIL 
	::cOCUPADOS          := NIL 
	::nPAGE              := NIL 
	::oWSRETDEPARTAMENTOSRESULT := NIL 
	::oWSRETFILIAISRESULT := NIL 
	::oWSRETFUNCRGRESULT := NIL 
	::cEMPLOYEEFIL       := NIL 
	::cDEPARTMENTID      := NIL 
	::cFILTERFIELD       := NIL 
	::cFILTERVALUE       := NIL 
	::oWSRETPOSTOSRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW1302100
Local oClone := WSW1302100():New()
	oClone:_URL          := ::_URL 
	oClone:cCDEPTO       := ::cCDEPTO
	oClone:cFILPOSTO     := ::cFILPOSTO
	oClone:cCODPOSTO     := ::cCODPOSTO
	oClone:nALLBUSCDEPTORESULT := ::nALLBUSCDEPTORESULT
	oClone:cCFILP        := ::cCFILP
	oClone:oWSALLCNTRCUSTORESULT :=  IIF(::oWSALLCNTRCUSTORESULT = NIL , NIL ,::oWSALLCNTRCUSTORESULT:Clone() )
	oClone:cFILREPOR     := ::cFILREPOR
	oClone:cFILTRO       := ::cFILTRO
	oClone:cCAMPO        := ::cCAMPO
	oClone:cOCUPADOS     := ::cOCUPADOS
	oClone:nPAGE         := ::nPAGE
	oClone:oWSRETDEPARTAMENTOSRESULT :=  IIF(::oWSRETDEPARTAMENTOSRESULT = NIL , NIL ,::oWSRETDEPARTAMENTOSRESULT:Clone() )
	oClone:oWSRETFILIAISRESULT :=  IIF(::oWSRETFILIAISRESULT = NIL , NIL ,::oWSRETFILIAISRESULT:Clone() )
	oClone:oWSRETFUNCRGRESULT :=  IIF(::oWSRETFUNCRGRESULT = NIL , NIL ,::oWSRETFUNCRGRESULT:Clone() )
	oClone:cEMPLOYEEFIL  := ::cEMPLOYEEFIL
	oClone:cDEPARTMENTID := ::cDEPARTMENTID
	oClone:cFILTERFIELD  := ::cFILTERFIELD
	oClone:cFILTERVALUE  := ::cFILTERVALUE
	oClone:oWSRETPOSTOSRESULT :=  IIF(::oWSRETPOSTOSRESULT = NIL , NIL ,::oWSRETPOSTOSRESULT:Clone() )
Return oClone

// WSDL Method ALLBUSCDEPTO of Service WSW1302100

WSMETHOD ALLBUSCDEPTO WSSEND cCDEPTO,cFILPOSTO,cCODPOSTO WSRECEIVE nALLBUSCDEPTORESULT WSCLIENT WSW1302100
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALLBUSCDEPTO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CDEPTO", ::cCDEPTO, cCDEPTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPOSTO", ::cFILPOSTO, cFILPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODPOSTO", ::cCODPOSTO, cCODPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ALLBUSCDEPTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/ALLBUSCDEPTO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W1302100.apw")

::Init()
::nALLBUSCDEPTORESULT :=  WSAdvValue( oXmlRet,"_ALLBUSCDEPTORESPONSE:_ALLBUSCDEPTORESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ALLCNTRCUSTO of Service WSW1302100

WSMETHOD ALLCNTRCUSTO WSSEND cCFILP,cCDEPTO WSRECEIVE oWSALLCNTRCUSTORESULT WSCLIENT WSW1302100
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALLCNTRCUSTO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CFILP", ::cCFILP, cCFILP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDEPTO", ::cCDEPTO, cCDEPTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ALLCNTRCUSTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/ALLCNTRCUSTO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W1302100.apw")

::Init()
::oWSALLCNTRCUSTORESULT:SoapRecv( WSAdvValue( oXmlRet,"_ALLCNTRCUSTORESPONSE:_ALLCNTRCUSTORESULT","CNTRCUSTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETDEPARTAMENTOS of Service WSW1302100

WSMETHOD RETDEPARTAMENTOS WSSEND cFILREPOR,cFILTRO,cCAMPO,cOCUPADOS,nPAGE WSRECEIVE oWSRETDEPARTAMENTOSRESULT WSCLIENT WSW1302100
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETDEPARTAMENTOS xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILREPOR", ::cFILREPOR, cFILREPOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTRO", ::cFILTRO, cFILTRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMPO", ::cCAMPO, cCAMPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OCUPADOS", ::cOCUPADOS, cOCUPADOS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETDEPARTAMENTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/RETDEPARTAMENTOS",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W1302100.apw")

::Init()
::oWSRETDEPARTAMENTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETDEPARTAMENTOSRESPONSE:_RETDEPARTAMENTOSRESULT","_ALLDEPART",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETFILIAIS of Service WSW1302100

WSMETHOD RETFILIAIS WSSEND cFILTRO,cCAMPO,nPAGE WSRECEIVE oWSRETFILIAISRESULT WSCLIENT WSW1302100
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETFILIAIS xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILTRO", ::cFILTRO, cFILTRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMPO", ::cCAMPO, cCAMPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETFILIAIS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/RETFILIAIS",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W1302100.apw")

::Init()
::oWSRETFILIAISRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETFILIAISRESPONSE:_RETFILIAISRESULT","_ALLFIL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETFUNCRG of Service WSW1302100

WSMETHOD RETFUNCRG WSSEND cFILTRO,cCAMPO,nPAGE WSRECEIVE oWSRETFUNCRGRESULT WSCLIENT WSW1302100
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETFUNCRG xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILTRO", ::cFILTRO, cFILTRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMPO", ::cCAMPO, cCAMPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETFUNCRG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/RETFUNCRG",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W1302100.apw")

::Init()
::oWSRETFUNCRGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETFUNCRGRESPONSE:_RETFUNCRGRESULT","_ALLFUNCAO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETPOSTOS of Service WSW1302100

WSMETHOD RETPOSTOS WSSEND cEMPLOYEEFIL,cDEPARTMENTID,nPAGE,cFILTERFIELD,cFILTERVALUE WSRECEIVE oWSRETPOSTOSRESULT WSCLIENT WSW1302100
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETPOSTOS xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("EMPLOYEEFIL", ::cEMPLOYEEFIL, cEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DEPARTMENTID", ::cDEPARTMENTID, cDEPARTMENTID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERFIELD", ::cFILTERFIELD, cFILTERFIELD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERVALUE", ::cFILTERVALUE, cFILTERVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETPOSTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/RETPOSTOS",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W1302100.apw")

::Init()
::oWSRETPOSTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETPOSTOSRESPONSE:_RETPOSTOSRESULT","_ALLPOSTOS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CNTRCUSTO

WSSTRUCT W1302100_CNTRCUSTO
	WSDATA   cCODCC                    AS string
	WSDATA   cDESCC                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_CNTRCUSTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_CNTRCUSTO
Return

WSMETHOD CLONE WSCLIENT W1302100_CNTRCUSTO
	Local oClone := W1302100_CNTRCUSTO():NEW()
	oClone:cCODCC               := ::cCODCC
	oClone:cDESCC               := ::cDESCC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_CNTRCUSTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODCC             :=  WSAdvValue( oResponse,"_CODCC","string",NIL,"Property cCODCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCC             :=  WSAdvValue( oResponse,"_DESCC","string",NIL,"Property cDESCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _ALLDEPART

WSSTRUCT W1302100__ALLDEPART
	WSDATA   oWSLISTOFALLDEPART        AS W1302100_ARRAYOFALLDEPART
	WSDATA   nPAGESTOTAL               AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100__ALLDEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100__ALLDEPART
Return

WSMETHOD CLONE WSCLIENT W1302100__ALLDEPART
	Local oClone := W1302100__ALLDEPART():NEW()
	oClone:oWSLISTOFALLDEPART   := IIF(::oWSLISTOFALLDEPART = NIL , NIL , ::oWSLISTOFALLDEPART:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100__ALLDEPART
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFALLDEPART","ARRAYOFALLDEPART",NIL,"Property oWSLISTOFALLDEPART as s0:ARRAYOFALLDEPART on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFALLDEPART := W1302100_ARRAYOFALLDEPART():New()
		::oWSLISTOFALLDEPART:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,"Property nPAGESTOTAL as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure _ALLFIL

WSSTRUCT W1302100__ALLFIL
	WSDATA   oWSLISTOFALLFIL           AS W1302100_ARRAYOFALLFIL
	WSDATA   nPAGESTOTAL               AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100__ALLFIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100__ALLFIL
Return

WSMETHOD CLONE WSCLIENT W1302100__ALLFIL
	Local oClone := W1302100__ALLFIL():NEW()
	oClone:oWSLISTOFALLFIL      := IIF(::oWSLISTOFALLFIL = NIL , NIL , ::oWSLISTOFALLFIL:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100__ALLFIL
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFALLFIL","ARRAYOFALLFIL",NIL,"Property oWSLISTOFALLFIL as s0:ARRAYOFALLFIL on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFALLFIL := W1302100_ARRAYOFALLFIL():New()
		::oWSLISTOFALLFIL:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,"Property nPAGESTOTAL as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure _ALLFUNCAO

WSSTRUCT W1302100__ALLFUNCAO
	WSDATA   oWSLISTOFALLFUNCAO        AS W1302100_ARRAYOFALLFUNCAO
	WSDATA   nPAGESTOTAL               AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100__ALLFUNCAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100__ALLFUNCAO
Return

WSMETHOD CLONE WSCLIENT W1302100__ALLFUNCAO
	Local oClone := W1302100__ALLFUNCAO():NEW()
	oClone:oWSLISTOFALLFUNCAO   := IIF(::oWSLISTOFALLFUNCAO = NIL , NIL , ::oWSLISTOFALLFUNCAO:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100__ALLFUNCAO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFALLFUNCAO","ARRAYOFALLFUNCAO",NIL,"Property oWSLISTOFALLFUNCAO as s0:ARRAYOFALLFUNCAO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFALLFUNCAO := W1302100_ARRAYOFALLFUNCAO():New()
		::oWSLISTOFALLFUNCAO:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,"Property nPAGESTOTAL as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure _ALLPOSTOS

WSSTRUCT W1302100__ALLPOSTOS
	WSDATA   oWSLISTOFALLPOSTOS        AS W1302100_ARRAYOFALLPOSTOS OPTIONAL
	WSDATA   nPAGESTOTAL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100__ALLPOSTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100__ALLPOSTOS
Return

WSMETHOD CLONE WSCLIENT W1302100__ALLPOSTOS
	Local oClone := W1302100__ALLPOSTOS():NEW()
	oClone:oWSLISTOFALLPOSTOS   := IIF(::oWSLISTOFALLPOSTOS = NIL , NIL , ::oWSLISTOFALLPOSTOS:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100__ALLPOSTOS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFALLPOSTOS","ARRAYOFALLPOSTOS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFALLPOSTOS := W1302100_ARRAYOFALLPOSTOS():New()
		::oWSLISTOFALLPOSTOS:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFALLDEPART

WSSTRUCT W1302100_ARRAYOFALLDEPART
	WSDATA   oWSALLDEPART              AS W1302100_ALLDEPART OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ARRAYOFALLDEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ARRAYOFALLDEPART
	::oWSALLDEPART         := {} // Array Of  W1302100_ALLDEPART():New()
Return

WSMETHOD CLONE WSCLIENT W1302100_ARRAYOFALLDEPART
	Local oClone := W1302100_ARRAYOFALLDEPART():NEW()
	oClone:oWSALLDEPART := NIL
	If ::oWSALLDEPART <> NIL 
		oClone:oWSALLDEPART := {}
		aEval( ::oWSALLDEPART , { |x| aadd( oClone:oWSALLDEPART , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ARRAYOFALLDEPART
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALLDEPART","ALLDEPART",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALLDEPART , W1302100_ALLDEPART():New() )
			::oWSALLDEPART[len(::oWSALLDEPART)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALLFIL

WSSTRUCT W1302100_ARRAYOFALLFIL
	WSDATA   oWSALLFIL                 AS W1302100_ALLFIL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ARRAYOFALLFIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ARRAYOFALLFIL
	::oWSALLFIL            := {} // Array Of  W1302100_ALLFIL():New()
Return

WSMETHOD CLONE WSCLIENT W1302100_ARRAYOFALLFIL
	Local oClone := W1302100_ARRAYOFALLFIL():NEW()
	oClone:oWSALLFIL := NIL
	If ::oWSALLFIL <> NIL 
		oClone:oWSALLFIL := {}
		aEval( ::oWSALLFIL , { |x| aadd( oClone:oWSALLFIL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ARRAYOFALLFIL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALLFIL","ALLFIL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALLFIL , W1302100_ALLFIL():New() )
			::oWSALLFIL[len(::oWSALLFIL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALLFUNCAO

WSSTRUCT W1302100_ARRAYOFALLFUNCAO
	WSDATA   oWSALLFUNCAO              AS W1302100_ALLFUNCAO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ARRAYOFALLFUNCAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ARRAYOFALLFUNCAO
	::oWSALLFUNCAO         := {} // Array Of  W1302100_ALLFUNCAO():New()
Return

WSMETHOD CLONE WSCLIENT W1302100_ARRAYOFALLFUNCAO
	Local oClone := W1302100_ARRAYOFALLFUNCAO():NEW()
	oClone:oWSALLFUNCAO := NIL
	If ::oWSALLFUNCAO <> NIL 
		oClone:oWSALLFUNCAO := {}
		aEval( ::oWSALLFUNCAO , { |x| aadd( oClone:oWSALLFUNCAO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ARRAYOFALLFUNCAO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALLFUNCAO","ALLFUNCAO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALLFUNCAO , W1302100_ALLFUNCAO():New() )
			::oWSALLFUNCAO[len(::oWSALLFUNCAO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALLPOSTOS

WSSTRUCT W1302100_ARRAYOFALLPOSTOS
	WSDATA   oWSALLPOSTOS              AS W1302100_ALLPOSTOS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ARRAYOFALLPOSTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ARRAYOFALLPOSTOS
	::oWSALLPOSTOS         := {} // Array Of  W1302100_ALLPOSTOS():New()
Return

WSMETHOD CLONE WSCLIENT W1302100_ARRAYOFALLPOSTOS
	Local oClone := W1302100_ARRAYOFALLPOSTOS():NEW()
	oClone:oWSALLPOSTOS := NIL
	If ::oWSALLPOSTOS <> NIL 
		oClone:oWSALLPOSTOS := {}
		aEval( ::oWSALLPOSTOS , { |x| aadd( oClone:oWSALLPOSTOS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ARRAYOFALLPOSTOS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALLPOSTOS","ALLPOSTOS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALLPOSTOS , W1302100_ALLPOSTOS():New() )
			::oWSALLPOSTOS[len(::oWSALLPOSTOS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ALLDEPART

WSSTRUCT W1302100_ALLDEPART
	WSDATA   cDEPARTMENT               AS string
	WSDATA   cDESCRDEPARTMENT          AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ALLDEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ALLDEPART
Return

WSMETHOD CLONE WSCLIENT W1302100_ALLDEPART
	Local oClone := W1302100_ALLDEPART():NEW()
	oClone:cDEPARTMENT          := ::cDEPARTMENT
	oClone:cDESCRDEPARTMENT     := ::cDESCRDEPARTMENT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ALLDEPART
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDEPARTMENT        :=  WSAdvValue( oResponse,"_DEPARTMENT","string",NIL,"Property cDEPARTMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRDEPARTMENT   :=  WSAdvValue( oResponse,"_DESCRDEPARTMENT","string",NIL,"Property cDESCRDEPARTMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALLFIL

WSSTRUCT W1302100_ALLFIL
	WSDATA   cDESCRICAO                AS string
	WSDATA   cFILIAIS                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ALLFIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ALLFIL
Return

WSMETHOD CLONE WSCLIENT W1302100_ALLFIL
	Local oClone := W1302100_ALLFIL():NEW()
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cFILIAIS             := ::cFILIAIS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ALLFIL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIAIS           :=  WSAdvValue( oResponse,"_FILIAIS","string",NIL,"Property cFILIAIS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALLFUNCAO

WSSTRUCT W1302100_ALLFUNCAO
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ALLFUNCAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ALLFUNCAO
Return

WSMETHOD CLONE WSCLIENT W1302100_ALLFUNCAO
	Local oClone := W1302100_ALLFUNCAO():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ALLFUNCAO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALLPOSTOS

WSSTRUCT W1302100_ALLPOSTOS
	WSDATA   cDESCRCARGO               AS string
	WSDATA   cDESCRFUNCAO              AS string
	WSDATA   cDESCRTIPO                AS string
	WSDATA   nOCUPADO                  AS integer
	WSDATA   cPOSTFILIAL               AS string
	WSDATA   cPOSTO                    AS string
	WSDATA   nQTD                      AS integer
	WSDATA   cRESPONSAVEL              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302100_ALLPOSTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302100_ALLPOSTOS
Return

WSMETHOD CLONE WSCLIENT W1302100_ALLPOSTOS
	Local oClone := W1302100_ALLPOSTOS():NEW()
	oClone:cDESCRCARGO          := ::cDESCRCARGO
	oClone:cDESCRFUNCAO         := ::cDESCRFUNCAO
	oClone:cDESCRTIPO           := ::cDESCRTIPO
	oClone:nOCUPADO             := ::nOCUPADO
	oClone:cPOSTFILIAL          := ::cPOSTFILIAL
	oClone:cPOSTO               := ::cPOSTO
	oClone:nQTD                 := ::nQTD
	oClone:cRESPONSAVEL         := ::cRESPONSAVEL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302100_ALLPOSTOS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRCARGO        :=  WSAdvValue( oResponse,"_DESCRCARGO","string",NIL,"Property cDESCRCARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRFUNCAO       :=  WSAdvValue( oResponse,"_DESCRFUNCAO","string",NIL,"Property cDESCRFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRTIPO         :=  WSAdvValue( oResponse,"_DESCRTIPO","string",NIL,"Property cDESCRTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nOCUPADO           :=  WSAdvValue( oResponse,"_OCUPADO","integer",NIL,"Property nOCUPADO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPOSTFILIAL        :=  WSAdvValue( oResponse,"_POSTFILIAL","string",NIL,"Property cPOSTFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPOSTO             :=  WSAdvValue( oResponse,"_POSTO","string",NIL,"Property cPOSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQTD               :=  WSAdvValue( oResponse,"_QTD","integer",NIL,"Property nQTD as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cRESPONSAVEL       :=  WSAdvValue( oResponse,"_RESPONSAVEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


