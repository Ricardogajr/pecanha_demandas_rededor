#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://spon010108393:86/ws0101/W0500308.apw?WSDL
Gerado em        03/28/18 09:59:10
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TPCSWRM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW0500308
------------------------------------------------------------------------------- */

WSCLIENT WSW0500308

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD APRSOLQDRO
	WSMETHOD APRSOLVAGA
	WSMETHOD BSCNTRCUSTO
	WSMETHOD BSCPARAMETR
	WSMETHOD BSCSOLQDRO
	WSMETHOD BSCSOLVAGS
	WSMETHOD BUSCDEPTO
	WSMETHOD CANCSOLIC
	WSMETHOD GETDEPARTMENTD
	WSMETHOD GETDEPTO
	WSMETHOD GETPOSTOSD
	WSMETHOD INFFXSL
	WSMETHOD INFSOLVG
	WSMETHOD INSSOLQDRO
	WSMETHOD INSTSOLICT
	WSMETHOD MINHSOLICT
	WSMETHOD PEGMNEM
	WSMETHOD REPSOLQDRO
	WSMETHOD REPSOLVAGA
	WSMETHOD RETINFUSR
	WSMETHOD SOLICAPRP
	WSMETHOD VERAPRVSIT
	WSMETHOD VERIFICAPOSTO
	WSMETHOD VERPOSTSOL
	WSMETHOD VGDESCDET

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSAUMENTQDRO             AS W0500308_SOLICITQDR
	WSDATA   cAPRSOLQDRORESULT         AS string
	WSDATA   oWSSOLICITACAO            AS W0500308_SOLICITVAG
	WSDATA   cAPRSOLVAGARESULT         AS string
	WSDATA   cCFILP                    AS string
	WSDATA   cCDEPTO                   AS string
	WSDATA   oWSBSCNTRCUSTORESULT      AS W0500308_CENTROCUSTO
	WSDATA   lBSCPARAMETRRESULT        AS boolean
	WSDATA   cCODSOLIC                 AS string
	WSDATA   cMATRICUL                 AS string
	WSDATA   cVISAO                    AS string
	WSDATA   cFILIALS                  AS string
	WSDATA   oWSBSCSOLQDRORESULT       AS W0500308_QDRDADOS
	WSDATA   oWSBSCSOLVAGSRESULT       AS W0500308_VAGDADOS
	WSDATA   cFILPOSTO                 AS string
	WSDATA   cCODPOSTO                 AS string
	WSDATA   nBUSCDEPTORESULT          AS integer
	WSDATA   cCFSOLICITACAO            AS string
	WSDATA   cCCSOLICITACAO            AS string
	WSDATA   cCMOTIVCANCELD            AS string
	WSDATA   cCFLSOLICITANT            AS string
	WSDATA   cCMTSOLICITANT            AS string
	WSDATA   cCANCSOLICRESULT          AS string
	WSDATA   cPARTICIPANTID            AS string
	WSDATA   cVISION                   AS string
	WSDATA   cFILTERVALUE              AS string
	WSDATA   nPAGE                     AS integer
	WSDATA   cFILTERFIELD              AS string
	WSDATA   cCONTROLPOST              AS string
	WSDATA   oWSGETDEPARTMENTDRESULT   AS W0500308__DEPARTMENTDATA
	WSDATA   cFILIALAP                 AS string
	WSDATA   cMATRICAP                 AS string
	WSDATA   cGETDEPTORESULT           AS string
	WSDATA   cCOMPANYID                AS string
	WSDATA   cDEPARTMENTID             AS string
	WSDATA   cPOSTID                   AS string
	WSDATA   cREQUESTTYPE              AS string
	WSDATA   cEMPLOYEEFIL              AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   cFILPOTVIS                AS string
	WSDATA   cPOSTOVIS                 AS string
	WSDATA   oWSGETPOSTOSDRESULT       AS W0500308__POSTDATA
	WSDATA   cCODVAGA                  AS string
	WSDATA   oWSINFFXSLRESULT          AS W0500308__FAIXSAL
	WSDATA   oWSINFSOLVGRESULT         AS W0500308_INFRH3
	WSDATA   oWSINSSOLQDRORESULT       AS W0500308_ARETSOLICT
	WSDATA   oWSINSTSOLICTRESULT       AS W0500308_ARETSOLICT
	WSDATA   cTPSOLIC                  AS string
	WSDATA   oWSMINHSOLICTRESULT       AS W0500308_AMNHVGSL
	WSDATA   lLRET                     AS boolean
	WSDATA   cPEGMNEMRESULT            AS string
	WSDATA   cREPSOLQDRORESULT         AS string
	WSDATA   cREPSOLVAGARESULT         AS string
	WSDATA   cFILUSR                   AS string
	WSDATA   cMATRIC                   AS string
	WSDATA   cRETINFUSRRESULT          AS string
	WSDATA   oWSSOLICAPRPRESULT        AS W0500308_AAPREPVAG
	WSDATA   cEMPFUN                   AS string
	WSDATA   cTPSIT                    AS string
	WSDATA   oWSVERAPRVSITRESULT       AS W0500308_APROVS
	WSDATA   cFILIALPOSTO              AS string
	WSDATA   lVERIFICAPOSTORESULT      AS boolean
	WSDATA   cCPOSTO                   AS string
	WSDATA   nNOCUP                    AS integer
	WSDATA   nNQNTD                    AS integer
	WSDATA   lVERPOSTSOLRESULT         AS boolean
	WSDATA   oWS_IDVAGA                AS W0500308_IDVAGA
	WSDATA   cVGDESCDETRESULT          AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSOLICITQDR             AS W0500308_SOLICITQDR
	WSDATA   oWSSOLICITVAG             AS W0500308_SOLICITVAG
	WSDATA   oWSIDVAGA                 AS W0500308_IDVAGA

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW0500308
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160707 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW0500308
	::oWSAUMENTQDRO      := W0500308_SOLICITQDR():New()
	::oWSSOLICITACAO     := W0500308_SOLICITVAG():New()
	::oWSBSCNTRCUSTORESULT := W0500308_CENTROCUSTO():New()
	::oWSBSCSOLQDRORESULT := W0500308_QDRDADOS():New()
	::oWSBSCSOLVAGSRESULT := W0500308_VAGDADOS():New()
	::oWSGETDEPARTMENTDRESULT := W0500308__DEPARTMENTDATA():New()
	::oWSGETPOSTOSDRESULT := W0500308__POSTDATA():New()
	::oWSINFFXSLRESULT   := W0500308__FAIXSAL():New()
	::oWSINFSOLVGRESULT  := W0500308_INFRH3():New()
	::oWSINSSOLQDRORESULT := W0500308_ARETSOLICT():New()
	::oWSINSTSOLICTRESULT := W0500308_ARETSOLICT():New()
	::oWSMINHSOLICTRESULT := W0500308_AMNHVGSL():New()
	::oWSSOLICAPRPRESULT := W0500308_AAPREPVAG():New()
	::oWSVERAPRVSITRESULT := W0500308_APROVS():New()
	::oWS_IDVAGA         := W0500308_IDVAGA():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSOLICITQDR      := ::oWSAUMENTQDRO
	::oWSSOLICITVAG      := ::oWSSOLICITACAO
	::oWSIDVAGA          := ::oWS_IDVAGA
Return

WSMETHOD RESET WSCLIENT WSW0500308
	::oWSAUMENTQDRO      := NIL 
	::cAPRSOLQDRORESULT  := NIL 
	::oWSSOLICITACAO     := NIL 
	::cAPRSOLVAGARESULT  := NIL 
	::cCFILP             := NIL 
	::cCDEPTO            := NIL 
	::oWSBSCNTRCUSTORESULT := NIL 
	::lBSCPARAMETRRESULT := NIL 
	::cCODSOLIC          := NIL 
	::cMATRICUL          := NIL 
	::cVISAO             := NIL 
	::cFILIALS           := NIL 
	::oWSBSCSOLQDRORESULT := NIL 
	::oWSBSCSOLVAGSRESULT := NIL 
	::cFILPOSTO          := NIL 
	::cCODPOSTO          := NIL 
	::nBUSCDEPTORESULT   := NIL 
	::cCFSOLICITACAO     := NIL 
	::cCCSOLICITACAO     := NIL 
	::cCMOTIVCANCELD     := NIL 
	::cCFLSOLICITANT     := NIL 
	::cCMTSOLICITANT     := NIL 
	::cCANCSOLICRESULT   := NIL 
	::cPARTICIPANTID     := NIL 
	::cVISION            := NIL 
	::cFILTERVALUE       := NIL 
	::nPAGE              := NIL 
	::cFILTERFIELD       := NIL 
	::cCONTROLPOST       := NIL 
	::oWSGETDEPARTMENTDRESULT := NIL 
	::cFILIALAP          := NIL 
	::cMATRICAP          := NIL 
	::cGETDEPTORESULT    := NIL 
	::cCOMPANYID         := NIL 
	::cDEPARTMENTID      := NIL 
	::cPOSTID            := NIL 
	::cREQUESTTYPE       := NIL 
	::cEMPLOYEEFIL       := NIL 
	::cREGISTRATION      := NIL 
	::cFILPOTVIS         := NIL 
	::cPOSTOVIS          := NIL 
	::oWSGETPOSTOSDRESULT := NIL 
	::cCODVAGA           := NIL 
	::oWSINFFXSLRESULT   := NIL 
	::oWSINFSOLVGRESULT  := NIL 
	::oWSINSSOLQDRORESULT := NIL 
	::oWSINSTSOLICTRESULT := NIL 
	::cTPSOLIC           := NIL 
	::oWSMINHSOLICTRESULT := NIL 
	::lLRET              := NIL 
	::cPEGMNEMRESULT     := NIL 
	::cREPSOLQDRORESULT  := NIL 
	::cREPSOLVAGARESULT  := NIL 
	::cFILUSR            := NIL 
	::cMATRIC            := NIL 
	::cRETINFUSRRESULT   := NIL 
	::oWSSOLICAPRPRESULT := NIL 
	::cEMPFUN            := NIL 
	::cTPSIT             := NIL 
	::oWSVERAPRVSITRESULT := NIL 
	::cFILIALPOSTO       := NIL 
	::lVERIFICAPOSTORESULT := NIL 
	::cCPOSTO            := NIL 
	::nNOCUP             := NIL 
	::nNQNTD             := NIL 
	::lVERPOSTSOLRESULT  := NIL 
	::oWS_IDVAGA         := NIL 
	::cVGDESCDETRESULT   := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSOLICITQDR      := NIL
	::oWSSOLICITVAG      := NIL
	::oWSIDVAGA          := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW0500308
Local oClone := WSW0500308():New()
	oClone:_URL          := ::_URL 
	oClone:oWSAUMENTQDRO :=  IIF(::oWSAUMENTQDRO = NIL , NIL ,::oWSAUMENTQDRO:Clone() )
	oClone:cAPRSOLQDRORESULT := ::cAPRSOLQDRORESULT
	oClone:oWSSOLICITACAO :=  IIF(::oWSSOLICITACAO = NIL , NIL ,::oWSSOLICITACAO:Clone() )
	oClone:cAPRSOLVAGARESULT := ::cAPRSOLVAGARESULT
	oClone:cCFILP        := ::cCFILP
	oClone:cCDEPTO       := ::cCDEPTO
	oClone:oWSBSCNTRCUSTORESULT :=  IIF(::oWSBSCNTRCUSTORESULT = NIL , NIL ,::oWSBSCNTRCUSTORESULT:Clone() )
	oClone:lBSCPARAMETRRESULT := ::lBSCPARAMETRRESULT
	oClone:cCODSOLIC     := ::cCODSOLIC
	oClone:cMATRICUL     := ::cMATRICUL
	oClone:cVISAO        := ::cVISAO
	oClone:cFILIALS      := ::cFILIALS
	oClone:oWSBSCSOLQDRORESULT :=  IIF(::oWSBSCSOLQDRORESULT = NIL , NIL ,::oWSBSCSOLQDRORESULT:Clone() )
	oClone:oWSBSCSOLVAGSRESULT :=  IIF(::oWSBSCSOLVAGSRESULT = NIL , NIL ,::oWSBSCSOLVAGSRESULT:Clone() )
	oClone:cFILPOSTO     := ::cFILPOSTO
	oClone:cCODPOSTO     := ::cCODPOSTO
	oClone:nBUSCDEPTORESULT := ::nBUSCDEPTORESULT
	oClone:cCFSOLICITACAO := ::cCFSOLICITACAO
	oClone:cCCSOLICITACAO := ::cCCSOLICITACAO
	oClone:cCMOTIVCANCELD := ::cCMOTIVCANCELD
	oClone:cCFLSOLICITANT := ::cCFLSOLICITANT
	oClone:cCMTSOLICITANT := ::cCMTSOLICITANT
	oClone:cCANCSOLICRESULT := ::cCANCSOLICRESULT
	oClone:cPARTICIPANTID := ::cPARTICIPANTID
	oClone:cVISION       := ::cVISION
	oClone:cFILTERVALUE  := ::cFILTERVALUE
	oClone:nPAGE         := ::nPAGE
	oClone:cFILTERFIELD  := ::cFILTERFIELD
	oClone:cCONTROLPOST  := ::cCONTROLPOST
	oClone:oWSGETDEPARTMENTDRESULT :=  IIF(::oWSGETDEPARTMENTDRESULT = NIL , NIL ,::oWSGETDEPARTMENTDRESULT:Clone() )
	oClone:cFILIALAP     := ::cFILIALAP
	oClone:cMATRICAP     := ::cMATRICAP
	oClone:cGETDEPTORESULT := ::cGETDEPTORESULT
	oClone:cCOMPANYID    := ::cCOMPANYID
	oClone:cDEPARTMENTID := ::cDEPARTMENTID
	oClone:cPOSTID       := ::cPOSTID
	oClone:cREQUESTTYPE  := ::cREQUESTTYPE
	oClone:cEMPLOYEEFIL  := ::cEMPLOYEEFIL
	oClone:cREGISTRATION := ::cREGISTRATION
	oClone:cFILPOTVIS    := ::cFILPOTVIS
	oClone:cPOSTOVIS     := ::cPOSTOVIS
	oClone:oWSGETPOSTOSDRESULT :=  IIF(::oWSGETPOSTOSDRESULT = NIL , NIL ,::oWSGETPOSTOSDRESULT:Clone() )
	oClone:cCODVAGA      := ::cCODVAGA
	oClone:oWSINFFXSLRESULT :=  IIF(::oWSINFFXSLRESULT = NIL , NIL ,::oWSINFFXSLRESULT:Clone() )
	oClone:oWSINFSOLVGRESULT :=  IIF(::oWSINFSOLVGRESULT = NIL , NIL ,::oWSINFSOLVGRESULT:Clone() )
	oClone:oWSINSSOLQDRORESULT :=  IIF(::oWSINSSOLQDRORESULT = NIL , NIL ,::oWSINSSOLQDRORESULT:Clone() )
	oClone:oWSINSTSOLICTRESULT :=  IIF(::oWSINSTSOLICTRESULT = NIL , NIL ,::oWSINSTSOLICTRESULT:Clone() )
	oClone:cTPSOLIC      := ::cTPSOLIC
	oClone:oWSMINHSOLICTRESULT :=  IIF(::oWSMINHSOLICTRESULT = NIL , NIL ,::oWSMINHSOLICTRESULT:Clone() )
	oClone:lLRET         := ::lLRET
	oClone:cPEGMNEMRESULT := ::cPEGMNEMRESULT
	oClone:cREPSOLQDRORESULT := ::cREPSOLQDRORESULT
	oClone:cREPSOLVAGARESULT := ::cREPSOLVAGARESULT
	oClone:cFILUSR       := ::cFILUSR
	oClone:cMATRIC       := ::cMATRIC
	oClone:cRETINFUSRRESULT := ::cRETINFUSRRESULT
	oClone:oWSSOLICAPRPRESULT :=  IIF(::oWSSOLICAPRPRESULT = NIL , NIL ,::oWSSOLICAPRPRESULT:Clone() )
	oClone:cEMPFUN       := ::cEMPFUN
	oClone:cTPSIT        := ::cTPSIT
	oClone:oWSVERAPRVSITRESULT :=  IIF(::oWSVERAPRVSITRESULT = NIL , NIL ,::oWSVERAPRVSITRESULT:Clone() )
	oClone:cFILIALPOSTO  := ::cFILIALPOSTO
	oClone:lVERIFICAPOSTORESULT := ::lVERIFICAPOSTORESULT
	oClone:cCPOSTO       := ::cCPOSTO
	oClone:nNOCUP        := ::nNOCUP
	oClone:nNQNTD        := ::nNQNTD
	oClone:lVERPOSTSOLRESULT := ::lVERPOSTSOLRESULT
	oClone:oWS_IDVAGA    :=  IIF(::oWS_IDVAGA = NIL , NIL ,::oWS_IDVAGA:Clone() )
	oClone:cVGDESCDETRESULT := ::cVGDESCDETRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSOLICITQDR := oClone:oWSAUMENTQDRO
	oClone:oWSSOLICITVAG := oClone:oWSSOLICITACAO
	oClone:oWSIDVAGA     := oClone:oWS_IDVAGA
Return oClone

// WSDL Method APRSOLQDRO of Service WSW0500308

WSMETHOD APRSOLQDRO WSSEND oWSAUMENTQDRO WSRECEIVE cAPRSOLQDRORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<APRSOLQDRO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("AUMENTQDRO", ::oWSAUMENTQDRO, oWSAUMENTQDRO , "SOLICITQDR", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</APRSOLQDRO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/APRSOLQDRO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cAPRSOLQDRORESULT  :=  WSAdvValue( oXmlRet,"_APRSOLQDRORESPONSE:_APRSOLQDRORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method APRSOLVAGA of Service WSW0500308

WSMETHOD APRSOLVAGA WSSEND oWSSOLICITACAO WSRECEIVE cAPRSOLVAGARESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<APRSOLVAGA xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("SOLICITACAO", ::oWSSOLICITACAO, oWSSOLICITACAO , "SOLICITVAG", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</APRSOLVAGA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/APRSOLVAGA",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cAPRSOLVAGARESULT  :=  WSAdvValue( oXmlRet,"_APRSOLVAGARESPONSE:_APRSOLVAGARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BSCNTRCUSTO of Service WSW0500308

WSMETHOD BSCNTRCUSTO WSSEND cCFILP,cCDEPTO WSRECEIVE oWSBSCNTRCUSTORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BSCNTRCUSTO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CFILP", ::cCFILP, cCFILP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDEPTO", ::cCDEPTO, cCDEPTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BSCNTRCUSTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BSCNTRCUSTO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSBSCNTRCUSTORESULT:SoapRecv( WSAdvValue( oXmlRet,"_BSCNTRCUSTORESPONSE:_BSCNTRCUSTORESULT","CENTROCUSTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BSCPARAMETR of Service WSW0500308

WSMETHOD BSCPARAMETR WSSEND NULLPARAM WSRECEIVE lBSCPARAMETRRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BSCPARAMETR xmlns="http://spon010108393:86/">'
cSoap += "</BSCPARAMETR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BSCPARAMETR",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::lBSCPARAMETRRESULT :=  WSAdvValue( oXmlRet,"_BSCPARAMETRRESPONSE:_BSCPARAMETRRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BSCSOLQDRO of Service WSW0500308

WSMETHOD BSCSOLQDRO WSSEND cCODSOLIC,cMATRICUL,cVISAO,cFILIALS WSRECEIVE oWSBSCSOLQDRORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BSCSOLQDRO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODSOLIC", ::cCODSOLIC, cCODSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICUL", ::cMATRICUL, cMATRICUL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VISAO", ::cVISAO, cVISAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIALS", ::cFILIALS, cFILIALS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BSCSOLQDRO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BSCSOLQDRO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSBSCSOLQDRORESULT:SoapRecv( WSAdvValue( oXmlRet,"_BSCSOLQDRORESPONSE:_BSCSOLQDRORESULT","QDRDADOS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BSCSOLVAGS of Service WSW0500308

WSMETHOD BSCSOLVAGS WSSEND cCODSOLIC,cMATRICUL,cVISAO,cFILIALS WSRECEIVE oWSBSCSOLVAGSRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BSCSOLVAGS xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODSOLIC", ::cCODSOLIC, cCODSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICUL", ::cMATRICUL, cMATRICUL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VISAO", ::cVISAO, cVISAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIALS", ::cFILIALS, cFILIALS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BSCSOLVAGS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BSCSOLVAGS",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSBSCSOLVAGSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BSCSOLVAGSRESPONSE:_BSCSOLVAGSRESULT","VAGDADOS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BUSCDEPTO of Service WSW0500308

WSMETHOD BUSCDEPTO WSSEND cCDEPTO,cFILPOSTO,cCODPOSTO WSRECEIVE nBUSCDEPTORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCDEPTO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CDEPTO", ::cCDEPTO, cCDEPTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPOSTO", ::cFILPOSTO, cFILPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODPOSTO", ::cCODPOSTO, cCODPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCDEPTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BUSCDEPTO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::nBUSCDEPTORESULT   :=  WSAdvValue( oXmlRet,"_BUSCDEPTORESPONSE:_BUSCDEPTORESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CANCSOLIC of Service WSW0500308

WSMETHOD CANCSOLIC WSSEND cCFSOLICITACAO,cCCSOLICITACAO,cCMOTIVCANCELD,cCFLSOLICITANT,cCMTSOLICITANT WSRECEIVE cCANCSOLICRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CANCSOLIC xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CFSOLICITACAO", ::cCFSOLICITACAO, cCFSOLICITACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCSOLICITACAO", ::cCCSOLICITACAO, cCCSOLICITACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CMOTIVCANCELD", ::cCMOTIVCANCELD, cCMOTIVCANCELD , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFLSOLICITANT", ::cCFLSOLICITANT, cCFLSOLICITANT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CMTSOLICITANT", ::cCMTSOLICITANT, cCMTSOLICITANT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CANCSOLIC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/CANCSOLIC",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cCANCSOLICRESULT   :=  WSAdvValue( oXmlRet,"_CANCSOLICRESPONSE:_CANCSOLICRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETDEPARTMENTD of Service WSW0500308

WSMETHOD GETDEPARTMENTD WSSEND cPARTICIPANTID,cVISION,cFILTERVALUE,nPAGE,cFILTERFIELD,cCONTROLPOST WSRECEIVE oWSGETDEPARTMENTDRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETDEPARTMENTD xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("PARTICIPANTID", ::cPARTICIPANTID, cPARTICIPANTID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VISION", ::cVISION, cVISION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERVALUE", ::cFILTERVALUE, cFILTERVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERFIELD", ::cFILTERFIELD, cFILTERFIELD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CONTROLPOST", ::cCONTROLPOST, cCONTROLPOST , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETDEPARTMENTD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/GETDEPARTMENTD",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSGETDEPARTMENTDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETDEPARTMENTDRESPONSE:_GETDEPARTMENTDRESULT","_DEPARTMENTDATA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETDEPTO of Service WSW0500308

WSMETHOD GETDEPTO WSSEND cFILIALAP,cMATRICAP WSRECEIVE cGETDEPTORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETDEPTO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILIALAP", ::cFILIALAP, cFILIALAP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICAP", ::cMATRICAP, cMATRICAP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETDEPTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/GETDEPTO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cGETDEPTORESULT    :=  WSAdvValue( oXmlRet,"_GETDEPTORESPONSE:_GETDEPTORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPOSTOSD of Service WSW0500308

WSMETHOD GETPOSTOSD WSSEND cCOMPANYID,cDEPARTMENTID,cPOSTID,nPAGE,cFILTERFIELD,cFILTERVALUE,cREQUESTTYPE,cEMPLOYEEFIL,cREGISTRATION,cFILPOTVIS,cPOSTOVIS WSRECEIVE oWSGETPOSTOSDRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPOSTOSD xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("COMPANYID", ::cCOMPANYID, cCOMPANYID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DEPARTMENTID", ::cDEPARTMENTID, cDEPARTMENTID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("POSTID", ::cPOSTID, cPOSTID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PAGE", ::nPAGE, nPAGE , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERFIELD", ::cFILTERFIELD, cFILTERFIELD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERVALUE", ::cFILTERVALUE, cFILTERVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("REQUESTTYPE", ::cREQUESTTYPE, cREQUESTTYPE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPLOYEEFIL", ::cEMPLOYEEFIL, cEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPOTVIS", ::cFILPOTVIS, cFILPOTVIS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("POSTOVIS", ::cPOSTOVIS, cPOSTOVIS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETPOSTOSD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/GETPOSTOSD",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSGETPOSTOSDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPOSTOSDRESPONSE:_GETPOSTOSDRESULT","_POSTDATA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFFXSL of Service WSW0500308

WSMETHOD INFFXSL WSSEND cCODVAGA,cCFILP WSRECEIVE oWSINFFXSLRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFFXSL xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODVAGA", ::cCODVAGA, cCODVAGA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILP", ::cCFILP, cCFILP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFFXSL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFFXSL",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSINFFXSLRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFFXSLRESPONSE:_INFFXSLRESULT","_FAIXSAL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFSOLVG of Service WSW0500308

WSMETHOD INFSOLVG WSSEND cFILIALS,cCODSOLIC WSRECEIVE oWSINFSOLVGRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFSOLVG xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILIALS", ::cFILIALS, cFILIALS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODSOLIC", ::cCODSOLIC, cCODSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFSOLVG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFSOLVG",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSINFSOLVGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFSOLVGRESPONSE:_INFSOLVGRESULT","INFRH3",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INSSOLQDRO of Service WSW0500308

WSMETHOD INSSOLQDRO WSSEND oWSAUMENTQDRO WSRECEIVE oWSINSSOLQDRORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INSSOLQDRO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("AUMENTQDRO", ::oWSAUMENTQDRO, oWSAUMENTQDRO , "SOLICITQDR", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INSSOLQDRO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INSSOLQDRO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSINSSOLQDRORESULT:SoapRecv( WSAdvValue( oXmlRet,"_INSSOLQDRORESPONSE:_INSSOLQDRORESULT","ARETSOLICT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INSTSOLICT of Service WSW0500308

WSMETHOD INSTSOLICT WSSEND oWSSOLICITACAO WSRECEIVE oWSINSTSOLICTRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INSTSOLICT xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("SOLICITACAO", ::oWSSOLICITACAO, oWSSOLICITACAO , "SOLICITVAG", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INSTSOLICT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INSTSOLICT",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSINSTSOLICTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INSTSOLICTRESPONSE:_INSTSOLICTRESULT","ARETSOLICT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MINHSOLICT of Service WSW0500308

WSMETHOD MINHSOLICT WSSEND cMATRICUL,cTPSOLIC WSRECEIVE oWSMINHSOLICTRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MINHSOLICT xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("MATRICUL", ::cMATRICUL, cMATRICUL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TPSOLIC", ::cTPSOLIC, cTPSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</MINHSOLICT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/MINHSOLICT",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSMINHSOLICTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MINHSOLICTRESPONSE:_MINHSOLICTRESULT","AMNHVGSL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PEGMNEM of Service WSW0500308

WSMETHOD PEGMNEM WSSEND lLRET WSRECEIVE cPEGMNEMRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PEGMNEM xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("LRET", ::lLRET, lLRET , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PEGMNEM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/PEGMNEM",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cPEGMNEMRESULT     :=  WSAdvValue( oXmlRet,"_PEGMNEMRESPONSE:_PEGMNEMRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method REPSOLQDRO of Service WSW0500308

WSMETHOD REPSOLQDRO WSSEND oWSAUMENTQDRO WSRECEIVE cREPSOLQDRORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<REPSOLQDRO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("AUMENTQDRO", ::oWSAUMENTQDRO, oWSAUMENTQDRO , "SOLICITQDR", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</REPSOLQDRO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/REPSOLQDRO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cREPSOLQDRORESULT  :=  WSAdvValue( oXmlRet,"_REPSOLQDRORESPONSE:_REPSOLQDRORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method REPSOLVAGA of Service WSW0500308

WSMETHOD REPSOLVAGA WSSEND oWSSOLICITACAO WSRECEIVE cREPSOLVAGARESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<REPSOLVAGA xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("SOLICITACAO", ::oWSSOLICITACAO, oWSSOLICITACAO , "SOLICITVAG", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</REPSOLVAGA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/REPSOLVAGA",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cREPSOLVAGARESULT  :=  WSAdvValue( oXmlRet,"_REPSOLVAGARESPONSE:_REPSOLVAGARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETINFUSR of Service WSW0500308

WSMETHOD RETINFUSR WSSEND cFILUSR,cMATRIC WSRECEIVE cRETINFUSRRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETINFUSR xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILUSR", ::cFILUSR, cFILUSR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRIC", ::cMATRIC, cMATRIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETINFUSR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/RETINFUSR",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cRETINFUSRRESULT   :=  WSAdvValue( oXmlRet,"_RETINFUSRRESPONSE:_RETINFUSRRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SOLICAPRP of Service WSW0500308

WSMETHOD SOLICAPRP WSSEND cMATRICUL,cFILIALAP,cVISAO,cTPSOLIC WSRECEIVE oWSSOLICAPRPRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOLICAPRP xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("MATRICUL", ::cMATRICUL, cMATRICUL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIALAP", ::cFILIALAP, cFILIALAP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VISAO", ::cVISAO, cVISAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TPSOLIC", ::cTPSOLIC, cTPSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SOLICAPRP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/SOLICAPRP",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSSOLICAPRPRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SOLICAPRPRESPONSE:_SOLICAPRPRESULT","AAPREPVAG",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VERAPRVSIT of Service WSW0500308

WSMETHOD VERAPRVSIT WSSEND cFILIALAP,cMATRICAP,cCDEPTO,cVISAO,cEMPFUN,cTPSIT WSRECEIVE oWSVERAPRVSITRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VERAPRVSIT xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILIALAP", ::cFILIALAP, cFILIALAP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICAP", ::cMATRICAP, cMATRICAP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDEPTO", ::cCDEPTO, cCDEPTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VISAO", ::cVISAO, cVISAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPFUN", ::cEMPFUN, cEMPFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TPSIT", ::cTPSIT, cTPSIT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VERAPRVSIT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/VERAPRVSIT",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::oWSVERAPRVSITRESULT:SoapRecv( WSAdvValue( oXmlRet,"_VERAPRVSITRESPONSE:_VERAPRVSITRESULT","APROVS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VERIFICAPOSTO of Service WSW0500308

WSMETHOD VERIFICAPOSTO WSSEND cFILIALPOSTO,cCODPOSTO WSRECEIVE lVERIFICAPOSTORESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VERIFICAPOSTO xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILIALPOSTO", ::cFILIALPOSTO, cFILIALPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODPOSTO", ::cCODPOSTO, cCODPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VERIFICAPOSTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/VERIFICAPOSTO",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::lVERIFICAPOSTORESULT :=  WSAdvValue( oXmlRet,"_VERIFICAPOSTORESPONSE:_VERIFICAPOSTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VERPOSTSOL of Service WSW0500308

WSMETHOD VERPOSTSOL WSSEND cCPOSTO,cCDEPTO,nNOCUP,nNQNTD,cCFILP WSRECEIVE lVERPOSTSOLRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VERPOSTSOL xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CPOSTO", ::cCPOSTO, cCPOSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDEPTO", ::cCDEPTO, cCDEPTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NOCUP", ::nNOCUP, nNOCUP , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NQNTD", ::nNQNTD, nNQNTD , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILP", ::cCFILP, cCFILP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VERPOSTSOL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/VERPOSTSOL",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::lVERPOSTSOLRESULT  :=  WSAdvValue( oXmlRet,"_VERPOSTSOLRESPONSE:_VERPOSTSOLRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VGDESCDET of Service WSW0500308

WSMETHOD VGDESCDET WSSEND oWS_IDVAGA WSRECEIVE cVGDESCDETRESULT WSCLIENT WSW0500308
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VGDESCDET xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("_IDVAGA", ::oWS_IDVAGA, oWS_IDVAGA , "IDVAGA", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VGDESCDET>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/VGDESCDET",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500308.apw")

::Init()
::cVGDESCDETRESULT   :=  WSAdvValue( oXmlRet,"_VGDESCDETRESPONSE:_VGDESCDETRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure SOLICITQDR

WSSTRUCT W0500308_SOLICITQDR
	WSDATA   cALDEPREPOR               AS string OPTIONAL
	WSDATA   cALDEPTSOL                AS string OPTIONAL
	WSDATA   cALDESCDEPTSOL            AS string OPTIONAL
	WSDATA   cALDESCREPOR              AS string OPTIONAL
	WSDATA   cALDESCSOL                AS string OPTIONAL
	WSDATA   cALDESDPREPOR             AS string OPTIONAL
	WSDATA   cALFILREPOR               AS string OPTIONAL
	WSDATA   cALFILSOL                 AS string OPTIONAL
	WSDATA   cALPOSTREPOR              AS string OPTIONAL
	WSDATA   cCDCARGO                  AS string OPTIONAL
	WSDATA   cCDCENTCT                 AS string OPTIONAL
	WSDATA   cCDFUNCAO                 AS string OPTIONAL
	WSDATA   cCDPOST                   AS string OPTIONAL
	WSDATA   cCHAVSOLIC                AS string OPTIONAL
	WSDATA   cCODALCAD                 AS string OPTIONAL
	WSDATA   cCODDEPTO                 AS string OPTIONAL
	WSDATA   cCODMATRIC                AS string OPTIONAL
	WSDATA   cCODSOLIC                 AS string OPTIONAL
	WSDATA   dDATARESPOST              AS date OPTIONAL
	WSDATA   dDATASOLIC                AS date OPTIONAL
	WSDATA   cDESCCG                   AS string OPTIONAL
	WSDATA   cDESCDP                   AS string OPTIONAL
	WSDATA   cEMPAPROV                 AS string OPTIONAL
	WSDATA   cEMPRESA                  AS string OPTIONAL
	WSDATA   cFILAPROV                 AS string OPTIONAL
	WSDATA   cFILATU                   AS string OPTIONAL
	WSDATA   cFILIALQDR                AS string OPTIONAL
	WSDATA   cFILPOSTO                 AS string OPTIONAL
	WSDATA   cFILSOLIC                 AS string OPTIONAL
	WSDATA   cMATAPROV                 AS string OPTIONAL
	WSDATA   cMATATU                   AS string OPTIONAL
	WSDATA   cMATSOLIC                 AS string OPTIONAL
	WSDATA   cNOMESOLIC                AS string OPTIONAL
	WSDATA   nNVLAPROV                 AS integer OPTIONAL
	WSDATA   nNVLINICIAL               AS integer OPTIONAL
	WSDATA   cNVPOST                   AS string OPTIONAL
	WSDATA   cOBSERV                   AS string OPTIONAL
	WSDATA   cPARTICRH                 AS string OPTIONAL
	WSDATA   cPRXNIVEL                 AS string OPTIONAL
	WSDATA   cQNTQDRO                  AS string OPTIONAL
	WSDATA   cSALARIO                  AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cTPCONTR                  AS string OPTIONAL
	WSDATA   cTPPOSTO                  AS string OPTIONAL
	WSDATA   cVISAOORG                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_SOLICITQDR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_SOLICITQDR
Return

WSMETHOD CLONE WSCLIENT W0500308_SOLICITQDR
	Local oClone := W0500308_SOLICITQDR():NEW()
	oClone:cALDEPREPOR          := ::cALDEPREPOR
	oClone:cALDEPTSOL           := ::cALDEPTSOL
	oClone:cALDESCDEPTSOL       := ::cALDESCDEPTSOL
	oClone:cALDESCREPOR         := ::cALDESCREPOR
	oClone:cALDESCSOL           := ::cALDESCSOL
	oClone:cALDESDPREPOR        := ::cALDESDPREPOR
	oClone:cALFILREPOR          := ::cALFILREPOR
	oClone:cALFILSOL            := ::cALFILSOL
	oClone:cALPOSTREPOR         := ::cALPOSTREPOR
	oClone:cCDCARGO             := ::cCDCARGO
	oClone:cCDCENTCT            := ::cCDCENTCT
	oClone:cCDFUNCAO            := ::cCDFUNCAO
	oClone:cCDPOST              := ::cCDPOST
	oClone:cCHAVSOLIC           := ::cCHAVSOLIC
	oClone:cCODALCAD            := ::cCODALCAD
	oClone:cCODDEPTO            := ::cCODDEPTO
	oClone:cCODMATRIC           := ::cCODMATRIC
	oClone:cCODSOLIC            := ::cCODSOLIC
	oClone:dDATARESPOST         := ::dDATARESPOST
	oClone:dDATASOLIC           := ::dDATASOLIC
	oClone:cDESCCG              := ::cDESCCG
	oClone:cDESCDP              := ::cDESCDP
	oClone:cEMPAPROV            := ::cEMPAPROV
	oClone:cEMPRESA             := ::cEMPRESA
	oClone:cFILAPROV            := ::cFILAPROV
	oClone:cFILATU              := ::cFILATU
	oClone:cFILIALQDR           := ::cFILIALQDR
	oClone:cFILPOSTO            := ::cFILPOSTO
	oClone:cFILSOLIC            := ::cFILSOLIC
	oClone:cMATAPROV            := ::cMATAPROV
	oClone:cMATATU              := ::cMATATU
	oClone:cMATSOLIC            := ::cMATSOLIC
	oClone:cNOMESOLIC           := ::cNOMESOLIC
	oClone:nNVLAPROV            := ::nNVLAPROV
	oClone:nNVLINICIAL          := ::nNVLINICIAL
	oClone:cNVPOST              := ::cNVPOST
	oClone:cOBSERV              := ::cOBSERV
	oClone:cPARTICRH            := ::cPARTICRH
	oClone:cPRXNIVEL            := ::cPRXNIVEL
	oClone:cQNTQDRO             := ::cQNTQDRO
	oClone:cSALARIO             := ::cSALARIO
	oClone:cSTATUS              := ::cSTATUS
	oClone:cTPCONTR             := ::cTPCONTR
	oClone:cTPPOSTO             := ::cTPPOSTO
	oClone:cVISAOORG            := ::cVISAOORG
Return oClone

WSMETHOD SOAPSEND WSCLIENT W0500308_SOLICITQDR
	Local cSoap := ""
	cSoap += WSSoapValue("ALDEPREPOR", ::cALDEPREPOR, ::cALDEPREPOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALDEPTSOL", ::cALDEPTSOL, ::cALDEPTSOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALDESCDEPTSOL", ::cALDESCDEPTSOL, ::cALDESCDEPTSOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALDESCREPOR", ::cALDESCREPOR, ::cALDESCREPOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALDESCSOL", ::cALDESCSOL, ::cALDESCSOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALDESDPREPOR", ::cALDESDPREPOR, ::cALDESDPREPOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALFILREPOR", ::cALFILREPOR, ::cALFILREPOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALFILSOL", ::cALFILSOL, ::cALFILSOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ALPOSTREPOR", ::cALPOSTREPOR, ::cALPOSTREPOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CDCARGO", ::cCDCARGO, ::cCDCARGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CDCENTCT", ::cCDCENTCT, ::cCDCENTCT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CDFUNCAO", ::cCDFUNCAO, ::cCDFUNCAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CDPOST", ::cCDPOST, ::cCDPOST , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CHAVSOLIC", ::cCHAVSOLIC, ::cCHAVSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODALCAD", ::cCODALCAD, ::cCODALCAD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODDEPTO", ::cCODDEPTO, ::cCODDEPTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODMATRIC", ::cCODMATRIC, ::cCODMATRIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODSOLIC", ::cCODSOLIC, ::cCODSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATARESPOST", ::dDATARESPOST, ::dDATARESPOST , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATASOLIC", ::dDATASOLIC, ::dDATASOLIC , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCCG", ::cDESCCG, ::cDESCCG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCDP", ::cDESCDP, ::cDESCDP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPAPROV", ::cEMPAPROV, ::cEMPAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, ::cEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILAPROV", ::cFILAPROV, ::cFILAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILATU", ::cFILATU, ::cFILATU , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILIALQDR", ::cFILIALQDR, ::cFILIALQDR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILPOSTO", ::cFILPOSTO, ::cFILPOSTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILSOLIC", ::cFILSOLIC, ::cFILSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATAPROV", ::cMATAPROV, ::cMATAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATATU", ::cMATATU, ::cMATATU , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATSOLIC", ::cMATSOLIC, ::cMATSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOMESOLIC", ::cNOMESOLIC, ::cNOMESOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NVLAPROV", ::nNVLAPROV, ::nNVLAPROV , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NVLINICIAL", ::nNVLINICIAL, ::nNVLINICIAL , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NVPOST", ::cNVPOST, ::cNVPOST , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSERV", ::cOBSERV, ::cOBSERV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARTICRH", ::cPARTICRH, ::cPARTICRH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRXNIVEL", ::cPRXNIVEL, ::cPRXNIVEL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QNTQDRO", ::cQNTQDRO, ::cQNTQDRO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SALARIO", ::cSALARIO, ::cSALARIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPCONTR", ::cTPCONTR, ::cTPCONTR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPPOSTO", ::cTPPOSTO, ::cTPPOSTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VISAOORG", ::cVISAOORG, ::cVISAOORG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure SOLICITVAG

WSSTRUCT W0500308_SOLICITVAG
	WSDATA   cCATFUN                   AS string OPTIONAL
	WSDATA   cCHAVSOLIC                AS string OPTIONAL
	WSDATA   cCODALCAD                 AS string OPTIONAL
	WSDATA   cCODCARGO                 AS string OPTIONAL
	WSDATA   cCODCC                    AS string OPTIONAL
	WSDATA   cCODDEPTO                 AS string OPTIONAL
	WSDATA   cCODFUNC                  AS string OPTIONAL
	WSDATA   cCODMATRIC                AS string OPTIONAL
	WSDATA   cCODPOSTO                 AS string OPTIONAL
	WSDATA   cCODSOLVG                 AS string OPTIONAL
	WSDATA   cCUSTOVAGA                AS string OPTIONAL
	WSDATA   dDATABERTURA              AS date OPTIONAL
	WSDATA   dDATARESPOST              AS date OPTIONAL
	WSDATA   dDATASOLIC                AS date OPTIONAL
	WSDATA   dDATFECHAM                AS date OPTIONAL
	WSDATA   cDSCDEPTO                 AS string OPTIONAL
	WSDATA   cDSCVAGA                  AS string OPTIONAL
	WSDATA   cEMPAPROV                 AS string OPTIONAL
	WSDATA   cEMPRESA                  AS string OPTIONAL
	WSDATA   cFILAPROV                 AS string OPTIONAL
	WSDATA   cFILATU                   AS string
	WSDATA   cFILIALVG                 AS string OPTIONAL
	WSDATA   cFILPOSTO                 AS string OPTIONAL
	WSDATA   cFILSOLIC                 AS string OPTIONAL
	WSDATA   cHORMES                   AS string OPTIONAL
	WSDATA   cHORSEM                   AS string OPTIONAL
	WSDATA   cLRET                     AS string OPTIONAL
	WSDATA   cMATAPROV                 AS string OPTIONAL
	WSDATA   cMATATU                   AS string
	WSDATA   cMATSOLIC                 AS string OPTIONAL
	WSDATA   cNOMEAPROV                AS string OPTIONAL
	WSDATA   cNOMESOLIC                AS string OPTIONAL
	WSDATA   nNVLAPROV                 AS integer OPTIONAL
	WSDATA   nNVLINICIAL               AS integer OPTIONAL
	WSDATA   cPARTICRH                 AS string OPTIONAL
	WSDATA   cPRAZOVAGA                AS string OPTIONAL
	WSDATA   cPROCSELET                AS string OPTIONAL
	WSDATA   cPRXNIVEL                 AS string OPTIONAL
	WSDATA   cSALHORA                  AS string OPTIONAL
	WSDATA   cSOURCE                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cTPCONTR                  AS string OPTIONAL
	WSDATA   cTPRJ                     AS string OPTIONAL
	WSDATA   cTPVAGA                   AS string OPTIONAL
	WSDATA   cTURNOTAB                 AS string OPTIONAL
	WSDATA   cVAGA                     AS string OPTIONAL
	WSDATA   cVISAOORG                 AS string OPTIONAL
	WSDATA   cXOBS                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_SOLICITVAG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_SOLICITVAG
Return

WSMETHOD CLONE WSCLIENT W0500308_SOLICITVAG
	Local oClone := W0500308_SOLICITVAG():NEW()
	oClone:cCATFUN              := ::cCATFUN
	oClone:cCHAVSOLIC           := ::cCHAVSOLIC
	oClone:cCODALCAD            := ::cCODALCAD
	oClone:cCODCARGO            := ::cCODCARGO
	oClone:cCODCC               := ::cCODCC
	oClone:cCODDEPTO            := ::cCODDEPTO
	oClone:cCODFUNC             := ::cCODFUNC
	oClone:cCODMATRIC           := ::cCODMATRIC
	oClone:cCODPOSTO            := ::cCODPOSTO
	oClone:cCODSOLVG            := ::cCODSOLVG
	oClone:cCUSTOVAGA           := ::cCUSTOVAGA
	oClone:dDATABERTURA         := ::dDATABERTURA
	oClone:dDATARESPOST         := ::dDATARESPOST
	oClone:dDATASOLIC           := ::dDATASOLIC
	oClone:dDATFECHAM           := ::dDATFECHAM
	oClone:cDSCDEPTO            := ::cDSCDEPTO
	oClone:cDSCVAGA             := ::cDSCVAGA
	oClone:cEMPAPROV            := ::cEMPAPROV
	oClone:cEMPRESA             := ::cEMPRESA
	oClone:cFILAPROV            := ::cFILAPROV
	oClone:cFILATU              := ::cFILATU
	oClone:cFILIALVG            := ::cFILIALVG
	oClone:cFILPOSTO            := ::cFILPOSTO
	oClone:cFILSOLIC            := ::cFILSOLIC
	oClone:cHORMES              := ::cHORMES
	oClone:cHORSEM              := ::cHORSEM
	oClone:cLRET                := ::cLRET
	oClone:cMATAPROV            := ::cMATAPROV
	oClone:cMATATU              := ::cMATATU
	oClone:cMATSOLIC            := ::cMATSOLIC
	oClone:cNOMEAPROV           := ::cNOMEAPROV
	oClone:cNOMESOLIC           := ::cNOMESOLIC
	oClone:nNVLAPROV            := ::nNVLAPROV
	oClone:nNVLINICIAL          := ::nNVLINICIAL
	oClone:cPARTICRH            := ::cPARTICRH
	oClone:cPRAZOVAGA           := ::cPRAZOVAGA
	oClone:cPROCSELET           := ::cPROCSELET
	oClone:cPRXNIVEL            := ::cPRXNIVEL
	oClone:cSALHORA             := ::cSALHORA
	oClone:cSOURCE              := ::cSOURCE
	oClone:cSTATUS              := ::cSTATUS
	oClone:cTPCONTR             := ::cTPCONTR
	oClone:cTPRJ                := ::cTPRJ
	oClone:cTPVAGA              := ::cTPVAGA
	oClone:cTURNOTAB            := ::cTURNOTAB
	oClone:cVAGA                := ::cVAGA
	oClone:cVISAOORG            := ::cVISAOORG
	oClone:cXOBS                := ::cXOBS
Return oClone

WSMETHOD SOAPSEND WSCLIENT W0500308_SOLICITVAG
	Local cSoap := ""
	cSoap += WSSoapValue("CATFUN", ::cCATFUN, ::cCATFUN , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CHAVSOLIC", ::cCHAVSOLIC, ::cCHAVSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODALCAD", ::cCODALCAD, ::cCODALCAD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODCARGO", ::cCODCARGO, ::cCODCARGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODCC", ::cCODCC, ::cCODCC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODDEPTO", ::cCODDEPTO, ::cCODDEPTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODFUNC", ::cCODFUNC, ::cCODFUNC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODMATRIC", ::cCODMATRIC, ::cCODMATRIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODPOSTO", ::cCODPOSTO, ::cCODPOSTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODSOLVG", ::cCODSOLVG, ::cCODSOLVG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CUSTOVAGA", ::cCUSTOVAGA, ::cCUSTOVAGA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATABERTURA", ::dDATABERTURA, ::dDATABERTURA , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATARESPOST", ::dDATARESPOST, ::dDATARESPOST , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATASOLIC", ::dDATASOLIC, ::dDATASOLIC , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATFECHAM", ::dDATFECHAM, ::dDATFECHAM , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DSCDEPTO", ::cDSCDEPTO, ::cDSCDEPTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DSCVAGA", ::cDSCVAGA, ::cDSCVAGA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPAPROV", ::cEMPAPROV, ::cEMPAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, ::cEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILAPROV", ::cFILAPROV, ::cFILAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILATU", ::cFILATU, ::cFILATU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILIALVG", ::cFILIALVG, ::cFILIALVG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILPOSTO", ::cFILPOSTO, ::cFILPOSTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILSOLIC", ::cFILSOLIC, ::cFILSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HORMES", ::cHORMES, ::cHORMES , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HORSEM", ::cHORSEM, ::cHORSEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LRET", ::cLRET, ::cLRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATAPROV", ::cMATAPROV, ::cMATAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATATU", ::cMATATU, ::cMATATU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATSOLIC", ::cMATSOLIC, ::cMATSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOMEAPROV", ::cNOMEAPROV, ::cNOMEAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOMESOLIC", ::cNOMESOLIC, ::cNOMESOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NVLAPROV", ::nNVLAPROV, ::nNVLAPROV , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NVLINICIAL", ::nNVLINICIAL, ::nNVLINICIAL , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARTICRH", ::cPARTICRH, ::cPARTICRH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRAZOVAGA", ::cPRAZOVAGA, ::cPRAZOVAGA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PROCSELET", ::cPROCSELET, ::cPROCSELET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRXNIVEL", ::cPRXNIVEL, ::cPRXNIVEL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SALHORA", ::cSALHORA, ::cSALHORA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SOURCE", ::cSOURCE, ::cSOURCE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::cSTATUS, ::cSTATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPCONTR", ::cTPCONTR, ::cTPCONTR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPRJ", ::cTPRJ, ::cTPRJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPVAGA", ::cTPVAGA, ::cTPVAGA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TURNOTAB", ::cTURNOTAB, ::cTURNOTAB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VAGA", ::cVAGA, ::cVAGA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VISAOORG", ::cVISAOORG, ::cVISAOORG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XOBS", ::cXOBS, ::cXOBS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure CENTROCUSTO

WSSTRUCT W0500308_CENTROCUSTO
	WSDATA   cCODCC                    AS string
	WSDATA   cDESCC                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_CENTROCUSTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_CENTROCUSTO
Return

WSMETHOD CLONE WSCLIENT W0500308_CENTROCUSTO
	Local oClone := W0500308_CENTROCUSTO():NEW()
	oClone:cCODCC               := ::cCODCC
	oClone:cDESCC               := ::cDESCC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_CENTROCUSTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODCC             :=  WSAdvValue( oResponse,"_CODCC","string",NIL,"Property cCODCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCC             :=  WSAdvValue( oResponse,"_DESCC","string",NIL,"Property cDESCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure QDRDADOS

WSSTRUCT W0500308_QDRDADOS
	WSDATA   cALDPRPR                  AS string OPTIONAL
	WSDATA   cALDPTSL                  AS string OPTIONAL
	WSDATA   cALDSCDPTSL               AS string OPTIONAL
	WSDATA   cALDSCRPR                 AS string OPTIONAL
	WSDATA   cALDSCSL                  AS string OPTIONAL
	WSDATA   cALDSDPRPR                AS string OPTIONAL
	WSDATA   cALFLRPR                  AS string OPTIONAL
	WSDATA   cALFLSL                   AS string OPTIONAL
	WSDATA   cALPSTRPR                 AS string OPTIONAL
	WSDATA   cCDCARG                   AS string OPTIONAL
	WSDATA   cCDCCTT                   AS string OPTIONAL
	WSDATA   cCDDEPT                   AS string OPTIONAL
	WSDATA   cCDFUNC                   AS string OPTIONAL
	WSDATA   cCODPST                   AS string OPTIONAL
	WSDATA   cDSCARG                   AS string OPTIONAL
	WSDATA   cDSCCTT                   AS string OPTIONAL
	WSDATA   cDSDEPT                   AS string OPTIONAL
	WSDATA   cDSFUNC                   AS string OPTIONAL
	WSDATA   cFILQDR                   AS string OPTIONAL
	WSDATA   cOBSERV                   AS string OPTIONAL
	WSDATA   cORIGSL                   AS string OPTIONAL
	WSDATA   cQNTQDR                   AS string OPTIONAL
	WSDATA   cSALARI                   AS string OPTIONAL
	WSDATA   cSTATUSS                  AS string OPTIONAL
	WSDATA   cTPCONT                   AS string OPTIONAL
	WSDATA   cTPPOST                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_QDRDADOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_QDRDADOS
Return

WSMETHOD CLONE WSCLIENT W0500308_QDRDADOS
	Local oClone := W0500308_QDRDADOS():NEW()
	oClone:cALDPRPR             := ::cALDPRPR
	oClone:cALDPTSL             := ::cALDPTSL
	oClone:cALDSCDPTSL          := ::cALDSCDPTSL
	oClone:cALDSCRPR            := ::cALDSCRPR
	oClone:cALDSCSL             := ::cALDSCSL
	oClone:cALDSDPRPR           := ::cALDSDPRPR
	oClone:cALFLRPR             := ::cALFLRPR
	oClone:cALFLSL              := ::cALFLSL
	oClone:cALPSTRPR            := ::cALPSTRPR
	oClone:cCDCARG              := ::cCDCARG
	oClone:cCDCCTT              := ::cCDCCTT
	oClone:cCDDEPT              := ::cCDDEPT
	oClone:cCDFUNC              := ::cCDFUNC
	oClone:cCODPST              := ::cCODPST
	oClone:cDSCARG              := ::cDSCARG
	oClone:cDSCCTT              := ::cDSCCTT
	oClone:cDSDEPT              := ::cDSDEPT
	oClone:cDSFUNC              := ::cDSFUNC
	oClone:cFILQDR              := ::cFILQDR
	oClone:cOBSERV              := ::cOBSERV
	oClone:cORIGSL              := ::cORIGSL
	oClone:cQNTQDR              := ::cQNTQDR
	oClone:cSALARI              := ::cSALARI
	oClone:cSTATUSS             := ::cSTATUSS
	oClone:cTPCONT              := ::cTPCONT
	oClone:cTPPOST              := ::cTPPOST
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_QDRDADOS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cALDPRPR           :=  WSAdvValue( oResponse,"_ALDPRPR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALDPTSL           :=  WSAdvValue( oResponse,"_ALDPTSL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALDSCDPTSL        :=  WSAdvValue( oResponse,"_ALDSCDPTSL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALDSCRPR          :=  WSAdvValue( oResponse,"_ALDSCRPR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALDSCSL           :=  WSAdvValue( oResponse,"_ALDSCSL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALDSDPRPR         :=  WSAdvValue( oResponse,"_ALDSDPRPR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALFLRPR           :=  WSAdvValue( oResponse,"_ALFLRPR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALFLSL            :=  WSAdvValue( oResponse,"_ALFLSL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALPSTRPR          :=  WSAdvValue( oResponse,"_ALPSTRPR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCDCARG            :=  WSAdvValue( oResponse,"_CDCARG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCDCCTT            :=  WSAdvValue( oResponse,"_CDCCTT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCDDEPT            :=  WSAdvValue( oResponse,"_CDDEPT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCDFUNC            :=  WSAdvValue( oResponse,"_CDFUNC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCODPST            :=  WSAdvValue( oResponse,"_CODPST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDSCARG            :=  WSAdvValue( oResponse,"_DSCARG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDSCCTT            :=  WSAdvValue( oResponse,"_DSCCTT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDSDEPT            :=  WSAdvValue( oResponse,"_DSDEPT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDSFUNC            :=  WSAdvValue( oResponse,"_DSFUNC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILQDR            :=  WSAdvValue( oResponse,"_FILQDR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOBSERV            :=  WSAdvValue( oResponse,"_OBSERV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cORIGSL            :=  WSAdvValue( oResponse,"_ORIGSL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cQNTQDR            :=  WSAdvValue( oResponse,"_QNTQDR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSALARI            :=  WSAdvValue( oResponse,"_SALARI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUSS           :=  WSAdvValue( oResponse,"_STATUSS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTPCONT            :=  WSAdvValue( oResponse,"_TPCONT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTPPOST            :=  WSAdvValue( oResponse,"_TPPOST","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure VAGDADOS

WSSTRUCT W0500308_VAGDADOS
	WSDATA   cCATFUN                   AS string
	WSDATA   cCODCARGO                 AS string
	WSDATA   cCODCC                    AS string
	WSDATA   cCODSOLIC                 AS string
	WSDATA   cCUSTVG                   AS string
	WSDATA   cDEPTO                    AS string
	WSDATA   cDESCCC                   AS string
	WSDATA   cDESCDPT                  AS string
	WSDATA   cDESCFU                   AS string
	WSDATA   cDESCR                    AS string
	WSDATA   cDESCRCARGO               AS string
	WSDATA   cDSCCATEG                 AS string
	WSDATA   cDSCFILPT                 AS string
	WSDATA   cDSCTURNO                 AS string
	WSDATA   cDTABT                    AS string
	WSDATA   cDTFCH                    AS string
	WSDATA   cFILVAG                   AS string
	WSDATA   cFLPOST                   AS string
	WSDATA   cFUNCAO                   AS string
	WSDATA   cHORMES                   AS string
	WSDATA   cHORSEM                   AS string
	WSDATA   cNOMESOL                  AS string
	WSDATA   cOBSERDET                 AS string
	WSDATA   cPOSTO                    AS string
	WSDATA   cPRAZO                    AS string
	WSDATA   cPROCS                    AS string
	WSDATA   cRET                      AS string
	WSDATA   cSALHORA                  AS string
	WSDATA   cSTATUSS                  AS string
	WSDATA   cTPCONTR                  AS string
	WSDATA   cTPVAGA                   AS string
	WSDATA   cTURNOTAB                 AS string
	WSDATA   cVAGA                     AS string
	WSDATA   cXOBS                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_VAGDADOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_VAGDADOS
Return

WSMETHOD CLONE WSCLIENT W0500308_VAGDADOS
	Local oClone := W0500308_VAGDADOS():NEW()
	oClone:cCATFUN              := ::cCATFUN
	oClone:cCODCARGO            := ::cCODCARGO
	oClone:cCODCC               := ::cCODCC
	oClone:cCODSOLIC            := ::cCODSOLIC
	oClone:cCUSTVG              := ::cCUSTVG
	oClone:cDEPTO               := ::cDEPTO
	oClone:cDESCCC              := ::cDESCCC
	oClone:cDESCDPT             := ::cDESCDPT
	oClone:cDESCFU              := ::cDESCFU
	oClone:cDESCR               := ::cDESCR
	oClone:cDESCRCARGO          := ::cDESCRCARGO
	oClone:cDSCCATEG            := ::cDSCCATEG
	oClone:cDSCFILPT            := ::cDSCFILPT
	oClone:cDSCTURNO            := ::cDSCTURNO
	oClone:cDTABT               := ::cDTABT
	oClone:cDTFCH               := ::cDTFCH
	oClone:cFILVAG              := ::cFILVAG
	oClone:cFLPOST              := ::cFLPOST
	oClone:cFUNCAO              := ::cFUNCAO
	oClone:cHORMES              := ::cHORMES
	oClone:cHORSEM              := ::cHORSEM
	oClone:cNOMESOL             := ::cNOMESOL
	oClone:cOBSERDET            := ::cOBSERDET
	oClone:cPOSTO               := ::cPOSTO
	oClone:cPRAZO               := ::cPRAZO
	oClone:cPROCS               := ::cPROCS
	oClone:cRET                 := ::cRET
	oClone:cSALHORA             := ::cSALHORA
	oClone:cSTATUSS             := ::cSTATUSS
	oClone:cTPCONTR             := ::cTPCONTR
	oClone:cTPVAGA              := ::cTPVAGA
	oClone:cTURNOTAB            := ::cTURNOTAB
	oClone:cVAGA                := ::cVAGA
	oClone:cXOBS                := ::cXOBS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_VAGDADOS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCATFUN            :=  WSAdvValue( oResponse,"_CATFUN","string",NIL,"Property cCATFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODCARGO          :=  WSAdvValue( oResponse,"_CODCARGO","string",NIL,"Property cCODCARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODCC             :=  WSAdvValue( oResponse,"_CODCC","string",NIL,"Property cCODCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODSOLIC          :=  WSAdvValue( oResponse,"_CODSOLIC","string",NIL,"Property cCODSOLIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCUSTVG            :=  WSAdvValue( oResponse,"_CUSTVG","string",NIL,"Property cCUSTVG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPTO             :=  WSAdvValue( oResponse,"_DEPTO","string",NIL,"Property cDEPTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCCC            :=  WSAdvValue( oResponse,"_DESCCC","string",NIL,"Property cDESCCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCDPT           :=  WSAdvValue( oResponse,"_DESCDPT","string",NIL,"Property cDESCDPT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCFU            :=  WSAdvValue( oResponse,"_DESCFU","string",NIL,"Property cDESCFU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCR             :=  WSAdvValue( oResponse,"_DESCR","string",NIL,"Property cDESCR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRCARGO        :=  WSAdvValue( oResponse,"_DESCRCARGO","string",NIL,"Property cDESCRCARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDSCCATEG          :=  WSAdvValue( oResponse,"_DSCCATEG","string",NIL,"Property cDSCCATEG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDSCFILPT          :=  WSAdvValue( oResponse,"_DSCFILPT","string",NIL,"Property cDSCFILPT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDSCTURNO          :=  WSAdvValue( oResponse,"_DSCTURNO","string",NIL,"Property cDSCTURNO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDTABT             :=  WSAdvValue( oResponse,"_DTABT","string",NIL,"Property cDTABT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDTFCH             :=  WSAdvValue( oResponse,"_DTFCH","string",NIL,"Property cDTFCH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILVAG            :=  WSAdvValue( oResponse,"_FILVAG","string",NIL,"Property cFILVAG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFLPOST            :=  WSAdvValue( oResponse,"_FLPOST","string",NIL,"Property cFLPOST as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFUNCAO            :=  WSAdvValue( oResponse,"_FUNCAO","string",NIL,"Property cFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHORMES            :=  WSAdvValue( oResponse,"_HORMES","string",NIL,"Property cHORMES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHORSEM            :=  WSAdvValue( oResponse,"_HORSEM","string",NIL,"Property cHORSEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMESOL           :=  WSAdvValue( oResponse,"_NOMESOL","string",NIL,"Property cNOMESOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBSERDET          :=  WSAdvValue( oResponse,"_OBSERDET","string",NIL,"Property cOBSERDET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPOSTO             :=  WSAdvValue( oResponse,"_POSTO","string",NIL,"Property cPOSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPRAZO             :=  WSAdvValue( oResponse,"_PRAZO","string",NIL,"Property cPRAZO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPROCS             :=  WSAdvValue( oResponse,"_PROCS","string",NIL,"Property cPROCS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRET               :=  WSAdvValue( oResponse,"_RET","string",NIL,"Property cRET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSALHORA           :=  WSAdvValue( oResponse,"_SALHORA","string",NIL,"Property cSALHORA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUSS           :=  WSAdvValue( oResponse,"_STATUSS","string",NIL,"Property cSTATUSS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTPCONTR           :=  WSAdvValue( oResponse,"_TPCONTR","string",NIL,"Property cTPCONTR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTPVAGA            :=  WSAdvValue( oResponse,"_TPVAGA","string",NIL,"Property cTPVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTURNOTAB          :=  WSAdvValue( oResponse,"_TURNOTAB","string",NIL,"Property cTURNOTAB as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVAGA              :=  WSAdvValue( oResponse,"_VAGA","string",NIL,"Property cVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXOBS              :=  WSAdvValue( oResponse,"_XOBS","string",NIL,"Property cXOBS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _DEPARTMENTDATA

WSSTRUCT W0500308__DEPARTMENTDATA
	WSDATA   oWSLISTOFDEPARTMENT       AS W0500308_ARRAYOFDTDEPARTMENT OPTIONAL
	WSDATA   nPAGESTOTAL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308__DEPARTMENTDATA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308__DEPARTMENTDATA
Return

WSMETHOD CLONE WSCLIENT W0500308__DEPARTMENTDATA
	Local oClone := W0500308__DEPARTMENTDATA():NEW()
	oClone:oWSLISTOFDEPARTMENT  := IIF(::oWSLISTOFDEPARTMENT = NIL , NIL , ::oWSLISTOFDEPARTMENT:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308__DEPARTMENTDATA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFDEPARTMENT","ARRAYOFDTDEPARTMENT",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFDEPARTMENT := W0500308_ARRAYOFDTDEPARTMENT():New()
		::oWSLISTOFDEPARTMENT:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure _POSTDATA

WSSTRUCT W0500308__POSTDATA
	WSDATA   oWSLISTOFPOSTS            AS W0500308_ARRAYOFDTPOSTOS OPTIONAL
	WSDATA   nPAGESTOTAL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308__POSTDATA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308__POSTDATA
Return

WSMETHOD CLONE WSCLIENT W0500308__POSTDATA
	Local oClone := W0500308__POSTDATA():NEW()
	oClone:oWSLISTOFPOSTS       := IIF(::oWSLISTOFPOSTS = NIL , NIL , ::oWSLISTOFPOSTS:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308__POSTDATA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFPOSTS","ARRAYOFDTPOSTOS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFPOSTS := W0500308_ARRAYOFDTPOSTOS():New()
		::oWSLISTOFPOSTS:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure _FAIXSAL

WSSTRUCT W0500308__FAIXSAL
	WSDATA   oWSREGISTRO               AS W0500308_ARRAYOFFAIXSAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308__FAIXSAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308__FAIXSAL
Return

WSMETHOD CLONE WSCLIENT W0500308__FAIXSAL
	Local oClone := W0500308__FAIXSAL():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308__FAIXSAL
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFFAIXSAL",NIL,"Property oWSREGISTRO as s0:ARRAYOFFAIXSAL on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0500308_ARRAYOFFAIXSAL():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure INFRH3

WSSTRUCT W0500308_INFRH3
	WSDATA   cRH3FILAPR                AS string
	WSDATA   cRH3FILINI                AS string
	WSDATA   cRH3MATAPR                AS string
	WSDATA   cRH3MATINI                AS string
	WSDATA   cRH3VISAO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_INFRH3
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_INFRH3
Return

WSMETHOD CLONE WSCLIENT W0500308_INFRH3
	Local oClone := W0500308_INFRH3():NEW()
	oClone:cRH3FILAPR           := ::cRH3FILAPR
	oClone:cRH3FILINI           := ::cRH3FILINI
	oClone:cRH3MATAPR           := ::cRH3MATAPR
	oClone:cRH3MATINI           := ::cRH3MATINI
	oClone:cRH3VISAO            := ::cRH3VISAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_INFRH3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRH3FILAPR         :=  WSAdvValue( oResponse,"_RH3FILAPR","string",NIL,"Property cRH3FILAPR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3FILINI         :=  WSAdvValue( oResponse,"_RH3FILINI","string",NIL,"Property cRH3FILINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3MATAPR         :=  WSAdvValue( oResponse,"_RH3MATAPR","string",NIL,"Property cRH3MATAPR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3MATINI         :=  WSAdvValue( oResponse,"_RH3MATINI","string",NIL,"Property cRH3MATINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3VISAO          :=  WSAdvValue( oResponse,"_RH3VISAO","string",NIL,"Property cRH3VISAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARETSOLICT

WSSTRUCT W0500308_ARETSOLICT
	WSDATA   cCDSOLIC                  AS string
	WSDATA   cDATASOL                  AS string
	WSDATA   cLRETORN                  AS string
	WSDATA   cMSGAVSO                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARETSOLICT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARETSOLICT
Return

WSMETHOD CLONE WSCLIENT W0500308_ARETSOLICT
	Local oClone := W0500308_ARETSOLICT():NEW()
	oClone:cCDSOLIC             := ::cCDSOLIC
	oClone:cDATASOL             := ::cDATASOL
	oClone:cLRETORN             := ::cLRETORN
	oClone:cMSGAVSO             := ::cMSGAVSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARETSOLICT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDSOLIC           :=  WSAdvValue( oResponse,"_CDSOLIC","string",NIL,"Property cCDSOLIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATASOL           :=  WSAdvValue( oResponse,"_DATASOL","string",NIL,"Property cDATASOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLRETORN           :=  WSAdvValue( oResponse,"_LRETORN","string",NIL,"Property cLRETORN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMSGAVSO           :=  WSAdvValue( oResponse,"_MSGAVSO","string",NIL,"Property cMSGAVSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure AMNHVGSL

WSSTRUCT W0500308_AMNHVGSL
	WSDATA   oWSAMNHVAG                AS W0500308_ARRAYOFMNHVGSOLIC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_AMNHVGSL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_AMNHVGSL
Return

WSMETHOD CLONE WSCLIENT W0500308_AMNHVGSL
	Local oClone := W0500308_AMNHVGSL():NEW()
	oClone:oWSAMNHVAG           := IIF(::oWSAMNHVAG = NIL , NIL , ::oWSAMNHVAG:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_AMNHVGSL
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AMNHVAG","ARRAYOFMNHVGSOLIC",NIL,"Property oWSAMNHVAG as s0:ARRAYOFMNHVGSOLIC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSAMNHVAG := W0500308_ARRAYOFMNHVGSOLIC():New()
		::oWSAMNHVAG:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AAPREPVAG

WSSTRUCT W0500308_AAPREPVAG
	WSDATA   oWSAAPREP                 AS W0500308_ARRAYOFAPREPVAGA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_AAPREPVAG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_AAPREPVAG
Return

WSMETHOD CLONE WSCLIENT W0500308_AAPREPVAG
	Local oClone := W0500308_AAPREPVAG():NEW()
	oClone:oWSAAPREP            := IIF(::oWSAAPREP = NIL , NIL , ::oWSAAPREP:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_AAPREPVAG
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AAPREP","ARRAYOFAPREPVAGA",NIL,"Property oWSAAPREP as s0:ARRAYOFAPREPVAGA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSAAPREP := W0500308_ARRAYOFAPREPVAGA():New()
		::oWSAAPREP:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure APROVS

WSSTRUCT W0500308_APROVS
	WSDATA   cEMPAPROV                 AS string OPTIONAL
	WSDATA   cFILAPROV                 AS string OPTIONAL
	WSDATA   cMATAPROV                 AS string OPTIONAL
	WSDATA   cNOMEAPROV                AS string OPTIONAL
	WSDATA   nNVLAPROV                 AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_APROVS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_APROVS
Return

WSMETHOD CLONE WSCLIENT W0500308_APROVS
	Local oClone := W0500308_APROVS():NEW()
	oClone:cEMPAPROV            := ::cEMPAPROV
	oClone:cFILAPROV            := ::cFILAPROV
	oClone:cMATAPROV            := ::cMATAPROV
	oClone:cNOMEAPROV           := ::cNOMEAPROV
	oClone:nNVLAPROV            := ::nNVLAPROV
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_APROVS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEMPAPROV          :=  WSAdvValue( oResponse,"_EMPAPROV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILAPROV          :=  WSAdvValue( oResponse,"_FILAPROV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMATAPROV          :=  WSAdvValue( oResponse,"_MATAPROV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOMEAPROV         :=  WSAdvValue( oResponse,"_NOMEAPROV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNVLAPROV          :=  WSAdvValue( oResponse,"_NVLAPROV","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure IDVAGA

WSSTRUCT W0500308_IDVAGA
	WSDATA   cQ3CARGO                  AS string
	WSDATA   cQ3CC                     AS string
	WSDATA   cQ3FILIAL                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_IDVAGA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_IDVAGA
Return

WSMETHOD CLONE WSCLIENT W0500308_IDVAGA
	Local oClone := W0500308_IDVAGA():NEW()
	oClone:cQ3CARGO             := ::cQ3CARGO
	oClone:cQ3CC                := ::cQ3CC
	oClone:cQ3FILIAL            := ::cQ3FILIAL
Return oClone

WSMETHOD SOAPSEND WSCLIENT W0500308_IDVAGA
	Local cSoap := ""
	cSoap += WSSoapValue("Q3CARGO", ::cQ3CARGO, ::cQ3CARGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Q3CC", ::cQ3CC, ::cQ3CC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Q3FILIAL", ::cQ3FILIAL, ::cQ3FILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFDTDEPARTMENT

WSSTRUCT W0500308_ARRAYOFDTDEPARTMENT
	WSDATA   oWSDTDEPARTMENT           AS W0500308_DTDEPARTMENT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARRAYOFDTDEPARTMENT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARRAYOFDTDEPARTMENT
	::oWSDTDEPARTMENT      := {} // Array Of  W0500308_DTDEPARTMENT():New()
Return

WSMETHOD CLONE WSCLIENT W0500308_ARRAYOFDTDEPARTMENT
	Local oClone := W0500308_ARRAYOFDTDEPARTMENT():NEW()
	oClone:oWSDTDEPARTMENT := NIL
	If ::oWSDTDEPARTMENT <> NIL 
		oClone:oWSDTDEPARTMENT := {}
		aEval( ::oWSDTDEPARTMENT , { |x| aadd( oClone:oWSDTDEPARTMENT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARRAYOFDTDEPARTMENT
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DTDEPARTMENT","DTDEPARTMENT",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDTDEPARTMENT , W0500308_DTDEPARTMENT():New() )
			::oWSDTDEPARTMENT[len(::oWSDTDEPARTMENT)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFDTPOSTOS

WSSTRUCT W0500308_ARRAYOFDTPOSTOS
	WSDATA   oWSDTPOSTOS               AS W0500308_DTPOSTOS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARRAYOFDTPOSTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARRAYOFDTPOSTOS
	::oWSDTPOSTOS          := {} // Array Of  W0500308_DTPOSTOS():New()
Return

WSMETHOD CLONE WSCLIENT W0500308_ARRAYOFDTPOSTOS
	Local oClone := W0500308_ARRAYOFDTPOSTOS():NEW()
	oClone:oWSDTPOSTOS := NIL
	If ::oWSDTPOSTOS <> NIL 
		oClone:oWSDTPOSTOS := {}
		aEval( ::oWSDTPOSTOS , { |x| aadd( oClone:oWSDTPOSTOS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARRAYOFDTPOSTOS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DTPOSTOS","DTPOSTOS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDTPOSTOS , W0500308_DTPOSTOS():New() )
			::oWSDTPOSTOS[len(::oWSDTPOSTOS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFFAIXSAL

WSSTRUCT W0500308_ARRAYOFFAIXSAL
	WSDATA   oWSFAIXSAL                AS W0500308_FAIXSAL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARRAYOFFAIXSAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARRAYOFFAIXSAL
	::oWSFAIXSAL           := {} // Array Of  W0500308_FAIXSAL():New()
Return

WSMETHOD CLONE WSCLIENT W0500308_ARRAYOFFAIXSAL
	Local oClone := W0500308_ARRAYOFFAIXSAL():NEW()
	oClone:oWSFAIXSAL := NIL
	If ::oWSFAIXSAL <> NIL 
		oClone:oWSFAIXSAL := {}
		aEval( ::oWSFAIXSAL , { |x| aadd( oClone:oWSFAIXSAL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARRAYOFFAIXSAL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FAIXSAL","FAIXSAL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFAIXSAL , W0500308_FAIXSAL():New() )
			::oWSFAIXSAL[len(::oWSFAIXSAL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFMNHVGSOLIC

WSSTRUCT W0500308_ARRAYOFMNHVGSOLIC
	WSDATA   oWSMNHVGSOLIC             AS W0500308_MNHVGSOLIC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARRAYOFMNHVGSOLIC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARRAYOFMNHVGSOLIC
	::oWSMNHVGSOLIC        := {} // Array Of  W0500308_MNHVGSOLIC():New()
Return

WSMETHOD CLONE WSCLIENT W0500308_ARRAYOFMNHVGSOLIC
	Local oClone := W0500308_ARRAYOFMNHVGSOLIC():NEW()
	oClone:oWSMNHVGSOLIC := NIL
	If ::oWSMNHVGSOLIC <> NIL 
		oClone:oWSMNHVGSOLIC := {}
		aEval( ::oWSMNHVGSOLIC , { |x| aadd( oClone:oWSMNHVGSOLIC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARRAYOFMNHVGSOLIC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_MNHVGSOLIC","MNHVGSOLIC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSMNHVGSOLIC , W0500308_MNHVGSOLIC():New() )
			::oWSMNHVGSOLIC[len(::oWSMNHVGSOLIC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFAPREPVAGA

WSSTRUCT W0500308_ARRAYOFAPREPVAGA
	WSDATA   oWSAPREPVAGA              AS W0500308_APREPVAGA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARRAYOFAPREPVAGA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARRAYOFAPREPVAGA
	::oWSAPREPVAGA         := {} // Array Of  W0500308_APREPVAGA():New()
Return

WSMETHOD CLONE WSCLIENT W0500308_ARRAYOFAPREPVAGA
	Local oClone := W0500308_ARRAYOFAPREPVAGA():NEW()
	oClone:oWSAPREPVAGA := NIL
	If ::oWSAPREPVAGA <> NIL 
		oClone:oWSAPREPVAGA := {}
		aEval( ::oWSAPREPVAGA , { |x| aadd( oClone:oWSAPREPVAGA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARRAYOFAPREPVAGA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_APREPVAGA","APREPVAGA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSAPREPVAGA , W0500308_APREPVAGA():New() )
			::oWSAPREPVAGA[len(::oWSAPREPVAGA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure DTDEPARTMENT

WSSTRUCT W0500308_DTDEPARTMENT
	WSDATA   cDEPARTMENT               AS string
	WSDATA   cDEPARTMENTEMP            AS string
	WSDATA   cDEPARTMENTFILIAL         AS string
	WSDATA   cDESCRDEPARTMENT          AS string OPTIONAL
	WSDATA   cFILPOSTOVIS              AS string OPTIONAL
	WSDATA   cKEYVISION                AS string OPTIONAL
	WSDATA   cPOSTOVIS                 AS string OPTIONAL
	WSDATA   nTOTALREGISTROS           AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_DTDEPARTMENT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_DTDEPARTMENT
Return

WSMETHOD CLONE WSCLIENT W0500308_DTDEPARTMENT
	Local oClone := W0500308_DTDEPARTMENT():NEW()
	oClone:cDEPARTMENT          := ::cDEPARTMENT
	oClone:cDEPARTMENTEMP       := ::cDEPARTMENTEMP
	oClone:cDEPARTMENTFILIAL    := ::cDEPARTMENTFILIAL
	oClone:cDESCRDEPARTMENT     := ::cDESCRDEPARTMENT
	oClone:cFILPOSTOVIS         := ::cFILPOSTOVIS
	oClone:cKEYVISION           := ::cKEYVISION
	oClone:cPOSTOVIS            := ::cPOSTOVIS
	oClone:nTOTALREGISTROS      := ::nTOTALREGISTROS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_DTDEPARTMENT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDEPARTMENT        :=  WSAdvValue( oResponse,"_DEPARTMENT","string",NIL,"Property cDEPARTMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPARTMENTEMP     :=  WSAdvValue( oResponse,"_DEPARTMENTEMP","string",NIL,"Property cDEPARTMENTEMP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPARTMENTFILIAL  :=  WSAdvValue( oResponse,"_DEPARTMENTFILIAL","string",NIL,"Property cDEPARTMENTFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRDEPARTMENT   :=  WSAdvValue( oResponse,"_DESCRDEPARTMENT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILPOSTOVIS       :=  WSAdvValue( oResponse,"_FILPOSTOVIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cKEYVISION         :=  WSAdvValue( oResponse,"_KEYVISION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPOSTOVIS          :=  WSAdvValue( oResponse,"_POSTOVIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTOTALREGISTROS    :=  WSAdvValue( oResponse,"_TOTALREGISTROS","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure DTPOSTOS

WSSTRUCT W0500308_DTPOSTOS
	WSDATA   cCC                       AS string
	WSDATA   cCODCARGO                 AS string
	WSDATA   cCODDEPTO                 AS string
	WSDATA   cCODFUNCAO                AS string
	WSDATA   cCODSTATUS                AS string OPTIONAL
	WSDATA   cDESCFIL                  AS string OPTIONAL
	WSDATA   cDESCRCARGO               AS string
	WSDATA   cDESCRCC                  AS string
	WSDATA   cDESCRDEPTO               AS string
	WSDATA   cDESCRFUNCAO              AS string
	WSDATA   cDESCRTIPO                AS string
	WSDATA   cNOVACONTR                AS string OPTIONAL
	WSDATA   nOCUPADO                  AS integer
	WSDATA   oWSOCUPANTES              AS W0500308_ARRAYOF_OCUPANTES OPTIONAL
	WSDATA   lPOSSUISOLIC              AS boolean OPTIONAL
	WSDATA   cPOSTFILIAL               AS string
	WSDATA   cPOSTO                    AS string
	WSDATA   cPOSTOEMP                 AS string
	WSDATA   nQTD                      AS integer
	WSDATA   nRESERV                   AS integer
	WSDATA   cRESPONSAVEL              AS string OPTIONAL
	WSDATA   nSALARIO                  AS float
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cTIPO                     AS string
	WSDATA   cTIPOCONTRATO             AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_DTPOSTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_DTPOSTOS
Return

WSMETHOD CLONE WSCLIENT W0500308_DTPOSTOS
	Local oClone := W0500308_DTPOSTOS():NEW()
	oClone:cCC                  := ::cCC
	oClone:cCODCARGO            := ::cCODCARGO
	oClone:cCODDEPTO            := ::cCODDEPTO
	oClone:cCODFUNCAO           := ::cCODFUNCAO
	oClone:cCODSTATUS           := ::cCODSTATUS
	oClone:cDESCFIL             := ::cDESCFIL
	oClone:cDESCRCARGO          := ::cDESCRCARGO
	oClone:cDESCRCC             := ::cDESCRCC
	oClone:cDESCRDEPTO          := ::cDESCRDEPTO
	oClone:cDESCRFUNCAO         := ::cDESCRFUNCAO
	oClone:cDESCRTIPO           := ::cDESCRTIPO
	oClone:cNOVACONTR           := ::cNOVACONTR
	oClone:nOCUPADO             := ::nOCUPADO
	oClone:oWSOCUPANTES         := IIF(::oWSOCUPANTES = NIL , NIL , ::oWSOCUPANTES:Clone() )
	oClone:lPOSSUISOLIC         := ::lPOSSUISOLIC
	oClone:cPOSTFILIAL          := ::cPOSTFILIAL
	oClone:cPOSTO               := ::cPOSTO
	oClone:cPOSTOEMP            := ::cPOSTOEMP
	oClone:nQTD                 := ::nQTD
	oClone:nRESERV              := ::nRESERV
	oClone:cRESPONSAVEL         := ::cRESPONSAVEL
	oClone:nSALARIO             := ::nSALARIO
	oClone:cSTATUS              := ::cSTATUS
	oClone:cTIPO                := ::cTIPO
	oClone:cTIPOCONTRATO        := ::cTIPOCONTRATO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_DTPOSTOS
	Local oNode14
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCC                :=  WSAdvValue( oResponse,"_CC","string",NIL,"Property cCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODCARGO          :=  WSAdvValue( oResponse,"_CODCARGO","string",NIL,"Property cCODCARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODDEPTO          :=  WSAdvValue( oResponse,"_CODDEPTO","string",NIL,"Property cCODDEPTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODFUNCAO         :=  WSAdvValue( oResponse,"_CODFUNCAO","string",NIL,"Property cCODFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODSTATUS         :=  WSAdvValue( oResponse,"_CODSTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCFIL           :=  WSAdvValue( oResponse,"_DESCFIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRCARGO        :=  WSAdvValue( oResponse,"_DESCRCARGO","string",NIL,"Property cDESCRCARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRCC           :=  WSAdvValue( oResponse,"_DESCRCC","string",NIL,"Property cDESCRCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRDEPTO        :=  WSAdvValue( oResponse,"_DESCRDEPTO","string",NIL,"Property cDESCRDEPTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRFUNCAO       :=  WSAdvValue( oResponse,"_DESCRFUNCAO","string",NIL,"Property cDESCRFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRTIPO         :=  WSAdvValue( oResponse,"_DESCRTIPO","string",NIL,"Property cDESCRTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOVACONTR         :=  WSAdvValue( oResponse,"_NOVACONTR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nOCUPADO           :=  WSAdvValue( oResponse,"_OCUPADO","integer",NIL,"Property nOCUPADO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode14 :=  WSAdvValue( oResponse,"_OCUPANTES","ARRAYOF_OCUPANTES",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSOCUPANTES := W0500308_ARRAYOF_OCUPANTES():New()
		::oWSOCUPANTES:SoapRecv(oNode14)
	EndIf
	::lPOSSUISOLIC       :=  WSAdvValue( oResponse,"_POSSUISOLIC","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cPOSTFILIAL        :=  WSAdvValue( oResponse,"_POSTFILIAL","string",NIL,"Property cPOSTFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPOSTO             :=  WSAdvValue( oResponse,"_POSTO","string",NIL,"Property cPOSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPOSTOEMP          :=  WSAdvValue( oResponse,"_POSTOEMP","string",NIL,"Property cPOSTOEMP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQTD               :=  WSAdvValue( oResponse,"_QTD","integer",NIL,"Property nQTD as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nRESERV            :=  WSAdvValue( oResponse,"_RESERV","integer",NIL,"Property nRESERV as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cRESPONSAVEL       :=  WSAdvValue( oResponse,"_RESPONSAVEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSALARIO           :=  WSAdvValue( oResponse,"_SALARIO","float",NIL,"Property nSALARIO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPOCONTRATO      :=  WSAdvValue( oResponse,"_TIPOCONTRATO","string",NIL,"Property cTIPOCONTRATO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure FAIXSAL

WSSTRUCT W0500308_FAIXSAL
	WSDATA   cFAIXA                    AS string
	WSDATA   cNIVEL                    AS string
	WSDATA   cVALOR                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_FAIXSAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_FAIXSAL
Return

WSMETHOD CLONE WSCLIENT W0500308_FAIXSAL
	Local oClone := W0500308_FAIXSAL():NEW()
	oClone:cFAIXA               := ::cFAIXA
	oClone:cNIVEL               := ::cNIVEL
	oClone:cVALOR               := ::cVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_FAIXSAL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFAIXA             :=  WSAdvValue( oResponse,"_FAIXA","string",NIL,"Property cFAIXA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNIVEL             :=  WSAdvValue( oResponse,"_NIVEL","string",NIL,"Property cNIVEL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVALOR             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,"Property cVALOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure MNHVGSOLIC

WSSTRUCT W0500308_MNHVGSOLIC
	WSDATA   cCDSOLIC                  AS string
	WSDATA   cDATASOL                  AS string
	WSDATA   cFILCDSL                  AS string
	WSDATA   cSTATUS                   AS string
	WSDATA   cSTATVGS                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_MNHVGSOLIC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_MNHVGSOLIC
Return

WSMETHOD CLONE WSCLIENT W0500308_MNHVGSOLIC
	Local oClone := W0500308_MNHVGSOLIC():NEW()
	oClone:cCDSOLIC             := ::cCDSOLIC
	oClone:cDATASOL             := ::cDATASOL
	oClone:cFILCDSL             := ::cFILCDSL
	oClone:cSTATUS              := ::cSTATUS
	oClone:cSTATVGS             := ::cSTATVGS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_MNHVGSOLIC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDSOLIC           :=  WSAdvValue( oResponse,"_CDSOLIC","string",NIL,"Property cCDSOLIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATASOL           :=  WSAdvValue( oResponse,"_DATASOL","string",NIL,"Property cDATASOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILCDSL           :=  WSAdvValue( oResponse,"_FILCDSL","string",NIL,"Property cFILCDSL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATVGS           :=  WSAdvValue( oResponse,"_STATVGS","string",NIL,"Property cSTATVGS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure APREPVAGA

WSSTRUCT W0500308_APREPVAGA
	WSDATA   cACAOSOL                  AS string
	WSDATA   cCODAPRP                  AS string
	WSDATA   cDTSOLIC                  AS string
	WSDATA   cFILSOLC                  AS string
	WSDATA   cSTATSOL                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_APREPVAGA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_APREPVAGA
Return

WSMETHOD CLONE WSCLIENT W0500308_APREPVAGA
	Local oClone := W0500308_APREPVAGA():NEW()
	oClone:cACAOSOL             := ::cACAOSOL
	oClone:cCODAPRP             := ::cCODAPRP
	oClone:cDTSOLIC             := ::cDTSOLIC
	oClone:cFILSOLC             := ::cFILSOLC
	oClone:cSTATSOL             := ::cSTATSOL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_APREPVAGA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cACAOSOL           :=  WSAdvValue( oResponse,"_ACAOSOL","string",NIL,"Property cACAOSOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODAPRP           :=  WSAdvValue( oResponse,"_CODAPRP","string",NIL,"Property cCODAPRP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDTSOLIC           :=  WSAdvValue( oResponse,"_DTSOLIC","string",NIL,"Property cDTSOLIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILSOLC           :=  WSAdvValue( oResponse,"_FILSOLC","string",NIL,"Property cFILSOLC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATSOL           :=  WSAdvValue( oResponse,"_STATSOL","string",NIL,"Property cSTATSOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOF_OCUPANTES

WSSTRUCT W0500308_ARRAYOF_OCUPANTES
	WSDATA   oWS_OCUPANTES             AS W0500308__OCUPANTES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308_ARRAYOF_OCUPANTES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308_ARRAYOF_OCUPANTES
	::oWS_OCUPANTES        := {} // Array Of  W0500308__OCUPANTES():New()
Return

WSMETHOD CLONE WSCLIENT W0500308_ARRAYOF_OCUPANTES
	Local oClone := W0500308_ARRAYOF_OCUPANTES():NEW()
	oClone:oWS_OCUPANTES := NIL
	If ::oWS_OCUPANTES <> NIL 
		oClone:oWS_OCUPANTES := {}
		aEval( ::oWS_OCUPANTES , { |x| aadd( oClone:oWS_OCUPANTES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308_ARRAYOF_OCUPANTES
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"__OCUPANTES","_OCUPANTES",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWS_OCUPANTES , W0500308__OCUPANTES():New() )
			::oWS_OCUPANTES[len(::oWS_OCUPANTES)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure _OCUPANTES

WSSTRUCT W0500308__OCUPANTES
	WSDATA   cFILIAL                   AS string OPTIONAL
	WSDATA   cMATRICULA                AS string OPTIONAL
	WSDATA   cNOME                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500308__OCUPANTES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500308__OCUPANTES
Return

WSMETHOD CLONE WSCLIENT W0500308__OCUPANTES
	Local oClone := W0500308__OCUPANTES():NEW()
	oClone:cFILIAL              := ::cFILIAL
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cNOME                := ::cNOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500308__OCUPANTES
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFILIAL            :=  WSAdvValue( oResponse,"_FILIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMATRICULA         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


