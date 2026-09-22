#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:81/ws/W1302400.apw?WSDL
Gerado em        01/11/18 10:41:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VICBVQT ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW1302400
------------------------------------------------------------------------------- */

WSCLIENT WSW1302400

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BUSCARCL
	WSMETHOD BUSCARCX

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cFILGES                   AS string
	WSDATA   cMATRICU                  AS string
	WSDATA   cVISAO                    AS string
	WSDATA   cFILPOSTO                 AS string
	WSDATA   cCODPOSTO                 AS string
	WSDATA   cFILTRO                   AS string
	WSDATA   cCAMPO                    AS string
	WSDATA   cLISTA                    AS string
	WSDATA   oWSBUSCARCLRESULT         AS W1302400__ESTRUTURA
	WSDATA   oWSBUSCARCXRESULT         AS W1302400__ESTRUTURA_FUNC

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW1302400
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW1302400
	::oWSBUSCARCLRESULT  := W1302400__ESTRUTURA():New()
	::oWSBUSCARCXRESULT  := W1302400__ESTRUTURA_FUNC():New()
Return

WSMETHOD RESET WSCLIENT WSW1302400
	::cFILGES            := NIL 
	::cMATRICU           := NIL 
	::cVISAO             := NIL 
	::cFILPOSTO          := NIL 
	::cCODPOSTO          := NIL 
	::cFILTRO            := NIL 
	::cCAMPO             := NIL 
	::cLISTA             := NIL 
	::oWSBUSCARCLRESULT  := NIL 
	::oWSBUSCARCXRESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW1302400
Local oClone := WSW1302400():New()
	oClone:_URL          := ::_URL 
	oClone:cFILGES       := ::cFILGES
	oClone:cMATRICU      := ::cMATRICU
	oClone:cVISAO        := ::cVISAO
	oClone:cFILPOSTO     := ::cFILPOSTO
	oClone:cCODPOSTO     := ::cCODPOSTO
	oClone:cFILTRO       := ::cFILTRO
	oClone:cCAMPO        := ::cCAMPO
	oClone:cLISTA        := ::cLISTA
	oClone:oWSBUSCARCLRESULT :=  IIF(::oWSBUSCARCLRESULT = NIL , NIL ,::oWSBUSCARCLRESULT:Clone() )
	oClone:oWSBUSCARCXRESULT :=  IIF(::oWSBUSCARCXRESULT = NIL , NIL ,::oWSBUSCARCXRESULT:Clone() )
Return oClone

// WSDL Method BUSCARCL of Service WSW1302400

WSMETHOD BUSCARCL WSSEND cFILGES,cMATRICU,cVISAO,cFILPOSTO,cCODPOSTO,cFILTRO,cCAMPO,cLISTA WSRECEIVE oWSBUSCARCLRESULT WSCLIENT WSW1302400
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCARCL xmlns="http://localhost:81/">'
cSoap += WSSoapValue("FILGES", ::cFILGES, cFILGES , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICU", ::cMATRICU, cMATRICU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VISAO", ::cVISAO, cVISAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPOSTO", ::cFILPOSTO, cFILPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODPOSTO", ::cCODPOSTO, cCODPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTRO", ::cFILTRO, cFILTRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMPO", ::cCAMPO, cCAMPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LISTA", ::cLISTA, cLISTA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCARCL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/BUSCARCL",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/W1302400.apw")

::Init()
::oWSBUSCARCLRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCARCLRESPONSE:_BUSCARCLRESULT","_ESTRUTURA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BUSCARCX of Service WSW1302400

WSMETHOD BUSCARCX WSSEND cFILPOSTO,cCODPOSTO,cCAMPO,cFILTRO WSRECEIVE oWSBUSCARCXRESULT WSCLIENT WSW1302400
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCARCX xmlns="http://localhost:81/">'
cSoap += WSSoapValue("FILPOSTO", ::cFILPOSTO, cFILPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODPOSTO", ::cCODPOSTO, cCODPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMPO", ::cCAMPO, cCAMPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTRO", ::cFILTRO, cFILTRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCARCX>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/BUSCARCX",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/W1302400.apw")

::Init()
::oWSBUSCARCXRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCARCXRESPONSE:_BUSCARCXRESULT","_ESTRUTURA_FUNC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure _ESTRUTURA

WSSTRUCT W1302400__ESTRUTURA
	WSDATA   oWSREGISTRO               AS W1302400_ARRAYOFESTRUTURA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302400__ESTRUTURA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302400__ESTRUTURA
Return

WSMETHOD CLONE WSCLIENT W1302400__ESTRUTURA
	Local oClone := W1302400__ESTRUTURA():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302400__ESTRUTURA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFESTRUTURA",NIL,"Property oWSREGISTRO as s0:ARRAYOFESTRUTURA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W1302400_ARRAYOFESTRUTURA():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure _ESTRUTURA_FUNC

WSSTRUCT W1302400__ESTRUTURA_FUNC
	WSDATA   oWSREGISTRO_FUNC          AS W1302400_ARRAYOFESTRUTURA_FUNC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302400__ESTRUTURA_FUNC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302400__ESTRUTURA_FUNC
Return

WSMETHOD CLONE WSCLIENT W1302400__ESTRUTURA_FUNC
	Local oClone := W1302400__ESTRUTURA_FUNC():NEW()
	oClone:oWSREGISTRO_FUNC     := IIF(::oWSREGISTRO_FUNC = NIL , NIL , ::oWSREGISTRO_FUNC:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302400__ESTRUTURA_FUNC
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO_FUNC","ARRAYOFESTRUTURA_FUNC",NIL,"Property oWSREGISTRO_FUNC as s0:ARRAYOFESTRUTURA_FUNC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO_FUNC := W1302400_ARRAYOFESTRUTURA_FUNC():New()
		::oWSREGISTRO_FUNC:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFESTRUTURA

WSSTRUCT W1302400_ARRAYOFESTRUTURA
	WSDATA   oWSESTRUTURA              AS W1302400_ESTRUTURA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302400_ARRAYOFESTRUTURA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302400_ARRAYOFESTRUTURA
	::oWSESTRUTURA         := {} // Array Of  W1302400_ESTRUTURA():New()
Return

WSMETHOD CLONE WSCLIENT W1302400_ARRAYOFESTRUTURA
	Local oClone := W1302400_ARRAYOFESTRUTURA():NEW()
	oClone:oWSESTRUTURA := NIL
	If ::oWSESTRUTURA <> NIL 
		oClone:oWSESTRUTURA := {}
		aEval( ::oWSESTRUTURA , { |x| aadd( oClone:oWSESTRUTURA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302400_ARRAYOFESTRUTURA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ESTRUTURA","ESTRUTURA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSESTRUTURA , W1302400_ESTRUTURA():New() )
			::oWSESTRUTURA[len(::oWSESTRUTURA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFESTRUTURA_FUNC

WSSTRUCT W1302400_ARRAYOFESTRUTURA_FUNC
	WSDATA   oWSESTRUTURA_FUNC         AS W1302400_ESTRUTURA_FUNC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302400_ARRAYOFESTRUTURA_FUNC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302400_ARRAYOFESTRUTURA_FUNC
	::oWSESTRUTURA_FUNC    := {} // Array Of  W1302400_ESTRUTURA_FUNC():New()
Return

WSMETHOD CLONE WSCLIENT W1302400_ARRAYOFESTRUTURA_FUNC
	Local oClone := W1302400_ARRAYOFESTRUTURA_FUNC():NEW()
	oClone:oWSESTRUTURA_FUNC := NIL
	If ::oWSESTRUTURA_FUNC <> NIL 
		oClone:oWSESTRUTURA_FUNC := {}
		aEval( ::oWSESTRUTURA_FUNC , { |x| aadd( oClone:oWSESTRUTURA_FUNC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302400_ARRAYOFESTRUTURA_FUNC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ESTRUTURA_FUNC","ESTRUTURA_FUNC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSESTRUTURA_FUNC , W1302400_ESTRUTURA_FUNC():New() )
			::oWSESTRUTURA_FUNC[len(::oWSESTRUTURA_FUNC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ESTRUTURA

WSSTRUCT W1302400_ESTRUTURA
	WSDATA   cCODDEPART                AS string
	WSDATA   cCODFUNCAO                AS string
	WSDATA   cDEPARTAMENTO             AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   lEQUIPE                   AS boolean
	WSDATA   cFILIALES                 AS string
	WSDATA   cFUNCAO                   AS string
	WSDATA   cHANDOVER                 AS string
	WSDATA   nOCUPADO                  AS integer
	WSDATA   cPOSTO                    AS string
	WSDATA   nQUANTIDADE               AS integer
	WSDATA   nRESERVADO                AS integer
	WSDATA   cRESPONSAVEL              AS string
	WSDATA   cTIPO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302400_ESTRUTURA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302400_ESTRUTURA
Return

WSMETHOD CLONE WSCLIENT W1302400_ESTRUTURA
	Local oClone := W1302400_ESTRUTURA():NEW()
	oClone:cCODDEPART           := ::cCODDEPART
	oClone:cCODFUNCAO           := ::cCODFUNCAO
	oClone:cDEPARTAMENTO        := ::cDEPARTAMENTO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:lEQUIPE              := ::lEQUIPE
	oClone:cFILIALES            := ::cFILIALES
	oClone:cFUNCAO              := ::cFUNCAO
	oClone:cHANDOVER            := ::cHANDOVER
	oClone:nOCUPADO             := ::nOCUPADO
	oClone:cPOSTO               := ::cPOSTO
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:nRESERVADO           := ::nRESERVADO
	oClone:cRESPONSAVEL         := ::cRESPONSAVEL
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302400_ESTRUTURA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODDEPART         :=  WSAdvValue( oResponse,"_CODDEPART","string",NIL,"Property cCODDEPART as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODFUNCAO         :=  WSAdvValue( oResponse,"_CODFUNCAO","string",NIL,"Property cCODFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPARTAMENTO      :=  WSAdvValue( oResponse,"_DEPARTAMENTO","string",NIL,"Property cDEPARTAMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lEQUIPE            :=  WSAdvValue( oResponse,"_EQUIPE","boolean",NIL,"Property lEQUIPE as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cFILIALES          :=  WSAdvValue( oResponse,"_FILIALES","string",NIL,"Property cFILIALES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFUNCAO            :=  WSAdvValue( oResponse,"_FUNCAO","string",NIL,"Property cFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHANDOVER          :=  WSAdvValue( oResponse,"_HANDOVER","string",NIL,"Property cHANDOVER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nOCUPADO           :=  WSAdvValue( oResponse,"_OCUPADO","integer",NIL,"Property nOCUPADO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPOSTO             :=  WSAdvValue( oResponse,"_POSTO","string",NIL,"Property cPOSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","integer",NIL,"Property nQUANTIDADE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nRESERVADO         :=  WSAdvValue( oResponse,"_RESERVADO","integer",NIL,"Property nRESERVADO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cRESPONSAVEL       :=  WSAdvValue( oResponse,"_RESPONSAVEL","string",NIL,"Property cRESPONSAVEL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ESTRUTURA_FUNC

WSSTRUCT W1302400_ESTRUTURA_FUNC
	WSDATA   cADMISSAOFUN              AS string
	WSDATA   cDEPARTAMENTOFUN          AS string
	WSDATA   cDESCRICAOFIL             AS string
	WSDATA   cDESCRICAOFUN             AS string
	WSDATA   cFILIALMAT                AS string
	WSDATA   cMATRICULAFUN             AS string
	WSDATA   cNOMEFUN                  AS string
	WSDATA   cSALARIOFUN               AS string
	WSDATA   cSITUACAOFUN              AS string
	WSDATA   cSTATUSFUN                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W1302400_ESTRUTURA_FUNC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W1302400_ESTRUTURA_FUNC
Return

WSMETHOD CLONE WSCLIENT W1302400_ESTRUTURA_FUNC
	Local oClone := W1302400_ESTRUTURA_FUNC():NEW()
	oClone:cADMISSAOFUN         := ::cADMISSAOFUN
	oClone:cDEPARTAMENTOFUN     := ::cDEPARTAMENTOFUN
	oClone:cDESCRICAOFIL        := ::cDESCRICAOFIL
	oClone:cDESCRICAOFUN        := ::cDESCRICAOFUN
	oClone:cFILIALMAT           := ::cFILIALMAT
	oClone:cMATRICULAFUN        := ::cMATRICULAFUN
	oClone:cNOMEFUN             := ::cNOMEFUN
	oClone:cSALARIOFUN          := ::cSALARIOFUN
	oClone:cSITUACAOFUN         := ::cSITUACAOFUN
	oClone:cSTATUSFUN           := ::cSTATUSFUN
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W1302400_ESTRUTURA_FUNC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cADMISSAOFUN       :=  WSAdvValue( oResponse,"_ADMISSAOFUN","string",NIL,"Property cADMISSAOFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPARTAMENTOFUN   :=  WSAdvValue( oResponse,"_DEPARTAMENTOFUN","string",NIL,"Property cDEPARTAMENTOFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAOFIL      :=  WSAdvValue( oResponse,"_DESCRICAOFIL","string",NIL,"Property cDESCRICAOFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAOFUN      :=  WSAdvValue( oResponse,"_DESCRICAOFUN","string",NIL,"Property cDESCRICAOFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIALMAT         :=  WSAdvValue( oResponse,"_FILIALMAT","string",NIL,"Property cFILIALMAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATRICULAFUN      :=  WSAdvValue( oResponse,"_MATRICULAFUN","string",NIL,"Property cMATRICULAFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMEFUN           :=  WSAdvValue( oResponse,"_NOMEFUN","string",NIL,"Property cNOMEFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSALARIOFUN        :=  WSAdvValue( oResponse,"_SALARIOFUN","string",NIL,"Property cSALARIOFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSITUACAOFUN       :=  WSAdvValue( oResponse,"_SITUACAOFUN","string",NIL,"Property cSITUACAOFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUSFUN         :=  WSAdvValue( oResponse,"_STATUSFUN","string",NIL,"Property cSTATUSFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


