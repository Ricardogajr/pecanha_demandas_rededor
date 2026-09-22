#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://spon010108393:86/ws0101/W0500307.apw?WSDL
Gerado em        01/25/18 10:53:55
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QSKHPON ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW0500307
------------------------------------------------------------------------------- */

WSCLIENT WSW0500307

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BSCDADOS
	WSMETHOD BUSCATRM
	WSMETHOD BUSCOBSER
	WSMETHOD CHKRH3
	WSMETHOD FUNRH3
	WSMETHOD GRVDTDLG
	WSMETHOD INFPEGSUP
	WSMETHOD INFRH3
	WSMETHOD INFRH4C
	WSMETHOD INFRH4D
	WSMETHOD INFRH4F
	WSMETHOD INFRH4FE
	WSMETHOD INFRH4I
	WSMETHOD INFSOLVG
	WSMETHOD VALAPRSOL
	WSMETHOD VALSESMT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cFILRH3                   AS string
	WSDATA   cCODRH3                   AS string
	WSDATA   oWSBSCDADOSRESULT         AS W0500307__RETDADOS
	WSDATA   cCODRH4                   AS string
	WSDATA   oWSBUSCATRMRESULT         AS W0500307_TREINA
	WSDATA   oWSBUSCOBSERRESULT        AS W0500307__INFHIS
	WSDATA   lCHKRH3RESULT             AS boolean
	WSDATA   oWSFUNRH3RESULT           AS W0500307_FUNCIO
	WSDATA   cDATADESLIG               AS string
	WSDATA   lGRVDTDLGRESULT           AS boolean
	WSDATA   oWS_SUPERINF              AS W0500307_SUPERINF
	WSDATA   oWSINFPEGSUPRESULT        AS W0500307_SUPEML
	WSDATA   cMATRICULA                AS string
	WSDATA   cFILTRO                   AS string
	WSDATA   cCAMPO                    AS string
	WSDATA   cVALOR                    AS string
	WSDATA   cFILFUN                   AS string
	WSDATA   oWSINFRH3RESULT           AS W0500307__ACOMPASOL
	WSDATA   oWSINFRH4CRESULT          AS W0500307_SLCARSAL
	WSDATA   oWSINFRH4DRESULT          AS W0500307_SOLDES
	WSDATA   oWSINFRH4FRESULT          AS W0500307_INFH4
	WSDATA   oWSINFRH4FERESULT         AS W0500307_INFFER
	WSDATA   cINFRH4IRESULT            AS string
	WSDATA   oWSINFSOLVGRESULT         AS W0500307_INFRH3SU
	WSDATA   lVALAPRSOLRESULT          AS boolean
	WSDATA   lVALSESMTRESULT           AS boolean

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSSUPERINF               AS W0500307_SUPERINF

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW0500307
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160707 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW0500307
	::oWSBSCDADOSRESULT  := W0500307__RETDADOS():New()
	::oWSBUSCATRMRESULT  := W0500307_TREINA():New()
	::oWSBUSCOBSERRESULT := W0500307__INFHIS():New()
	::oWSFUNRH3RESULT    := W0500307_FUNCIO():New()
	::oWS_SUPERINF       := W0500307_SUPERINF():New()
	::oWSINFPEGSUPRESULT := W0500307_SUPEML():New()
	::oWSINFRH3RESULT    := W0500307__ACOMPASOL():New()
	::oWSINFRH4CRESULT   := W0500307_SLCARSAL():New()
	::oWSINFRH4DRESULT   := W0500307_SOLDES():New()
	::oWSINFRH4FRESULT   := W0500307_INFH4():New()
	::oWSINFRH4FERESULT  := W0500307_INFFER():New()
	::oWSINFSOLVGRESULT  := W0500307_INFRH3SU():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSUPERINF        := ::oWS_SUPERINF
Return

WSMETHOD RESET WSCLIENT WSW0500307
	::cFILRH3            := NIL 
	::cCODRH3            := NIL 
	::oWSBSCDADOSRESULT  := NIL 
	::cCODRH4            := NIL 
	::oWSBUSCATRMRESULT  := NIL 
	::oWSBUSCOBSERRESULT := NIL 
	::lCHKRH3RESULT      := NIL 
	::oWSFUNRH3RESULT    := NIL 
	::cDATADESLIG        := NIL 
	::lGRVDTDLGRESULT    := NIL 
	::oWS_SUPERINF       := NIL 
	::oWSINFPEGSUPRESULT := NIL 
	::cMATRICULA         := NIL 
	::cFILTRO            := NIL 
	::cCAMPO             := NIL 
	::cVALOR             := NIL 
	::cFILFUN            := NIL 
	::oWSINFRH3RESULT    := NIL 
	::oWSINFRH4CRESULT   := NIL 
	::oWSINFRH4DRESULT   := NIL 
	::oWSINFRH4FRESULT   := NIL 
	::oWSINFRH4FERESULT  := NIL 
	::cINFRH4IRESULT     := NIL 
	::oWSINFSOLVGRESULT  := NIL 
	::lVALAPRSOLRESULT   := NIL 
	::lVALSESMTRESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSSUPERINF        := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW0500307
Local oClone := WSW0500307():New()
	oClone:_URL          := ::_URL 
	oClone:cFILRH3       := ::cFILRH3
	oClone:cCODRH3       := ::cCODRH3
	oClone:oWSBSCDADOSRESULT :=  IIF(::oWSBSCDADOSRESULT = NIL , NIL ,::oWSBSCDADOSRESULT:Clone() )
	oClone:cCODRH4       := ::cCODRH4
	oClone:oWSBUSCATRMRESULT :=  IIF(::oWSBUSCATRMRESULT = NIL , NIL ,::oWSBUSCATRMRESULT:Clone() )
	oClone:oWSBUSCOBSERRESULT :=  IIF(::oWSBUSCOBSERRESULT = NIL , NIL ,::oWSBUSCOBSERRESULT:Clone() )
	oClone:lCHKRH3RESULT := ::lCHKRH3RESULT
	oClone:oWSFUNRH3RESULT :=  IIF(::oWSFUNRH3RESULT = NIL , NIL ,::oWSFUNRH3RESULT:Clone() )
	oClone:cDATADESLIG   := ::cDATADESLIG
	oClone:lGRVDTDLGRESULT := ::lGRVDTDLGRESULT
	oClone:oWS_SUPERINF  :=  IIF(::oWS_SUPERINF = NIL , NIL ,::oWS_SUPERINF:Clone() )
	oClone:oWSINFPEGSUPRESULT :=  IIF(::oWSINFPEGSUPRESULT = NIL , NIL ,::oWSINFPEGSUPRESULT:Clone() )
	oClone:cMATRICULA    := ::cMATRICULA
	oClone:cFILTRO       := ::cFILTRO
	oClone:cCAMPO        := ::cCAMPO
	oClone:cVALOR        := ::cVALOR
	oClone:cFILFUN       := ::cFILFUN
	oClone:oWSINFRH3RESULT :=  IIF(::oWSINFRH3RESULT = NIL , NIL ,::oWSINFRH3RESULT:Clone() )
	oClone:oWSINFRH4CRESULT :=  IIF(::oWSINFRH4CRESULT = NIL , NIL ,::oWSINFRH4CRESULT:Clone() )
	oClone:oWSINFRH4DRESULT :=  IIF(::oWSINFRH4DRESULT = NIL , NIL ,::oWSINFRH4DRESULT:Clone() )
	oClone:oWSINFRH4FRESULT :=  IIF(::oWSINFRH4FRESULT = NIL , NIL ,::oWSINFRH4FRESULT:Clone() )
	oClone:oWSINFRH4FERESULT :=  IIF(::oWSINFRH4FERESULT = NIL , NIL ,::oWSINFRH4FERESULT:Clone() )
	oClone:cINFRH4IRESULT := ::cINFRH4IRESULT
	oClone:oWSINFSOLVGRESULT :=  IIF(::oWSINFSOLVGRESULT = NIL , NIL ,::oWSINFSOLVGRESULT:Clone() )
	oClone:lVALAPRSOLRESULT := ::lVALAPRSOLRESULT
	oClone:lVALSESMTRESULT := ::lVALSESMTRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSSUPERINF   := oClone:oWS_SUPERINF
Return oClone

// WSDL Method BSCDADOS of Service WSW0500307

WSMETHOD BSCDADOS WSSEND cFILRH3,cCODRH3 WSRECEIVE oWSBSCDADOSRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BSCDADOS xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BSCDADOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BSCDADOS",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSBSCDADOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BSCDADOSRESPONSE:_BSCDADOSRESULT","_RETDADOS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BUSCATRM of Service WSW0500307

WSMETHOD BUSCATRM WSSEND cCODRH4,cFILRH3 WSRECEIVE oWSBUSCATRMRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCATRM xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCATRM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BUSCATRM",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSBUSCATRMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCATRMRESPONSE:_BUSCATRMRESULT","TREINA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BUSCOBSER of Service WSW0500307

WSMETHOD BUSCOBSER WSSEND cFILRH3,cCODRH3 WSRECEIVE oWSBUSCOBSERRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCOBSER xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCOBSER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/BUSCOBSER",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSBUSCOBSERRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCOBSERRESPONSE:_BUSCOBSERRESULT","_INFHIS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CHKRH3 of Service WSW0500307

WSMETHOD CHKRH3 WSSEND cCODRH3,cFILRH3 WSRECEIVE lCHKRH3RESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CHKRH3 xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CHKRH3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/CHKRH3",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::lCHKRH3RESULT      :=  WSAdvValue( oXmlRet,"_CHKRH3RESPONSE:_CHKRH3RESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method FUNRH3 of Service WSW0500307

WSMETHOD FUNRH3 WSSEND cCODRH3,cFILRH3 WSRECEIVE oWSFUNRH3RESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FUNRH3 xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</FUNRH3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/FUNRH3",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSFUNRH3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_FUNRH3RESPONSE:_FUNRH3RESULT","FUNCIO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRVDTDLG of Service WSW0500307

WSMETHOD GRVDTDLG WSSEND cDATADESLIG,cFILRH3,cCODRH3 WSRECEIVE lGRVDTDLGRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVDTDLG xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("DATADESLIG", ::cDATADESLIG, cDATADESLIG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRVDTDLG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/GRVDTDLG",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::lGRVDTDLGRESULT    :=  WSAdvValue( oXmlRet,"_GRVDTDLGRESPONSE:_GRVDTDLGRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFPEGSUP of Service WSW0500307

WSMETHOD INFPEGSUP WSSEND oWS_SUPERINF WSRECEIVE oWSINFPEGSUPRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFPEGSUP xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("_SUPERINF", ::oWS_SUPERINF, oWS_SUPERINF , "SUPERINF", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFPEGSUP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFPEGSUP",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFPEGSUPRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFPEGSUPRESPONSE:_INFPEGSUPRESULT","SUPEML",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFRH3 of Service WSW0500307

WSMETHOD INFRH3 WSSEND cMATRICULA,cFILTRO,cCAMPO,cVALOR,cFILFUN WSRECEIVE oWSINFRH3RESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFRH3 xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTRO", ::cFILTRO, cFILTRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMPO", ::cCAMPO, cCAMPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VALOR", ::cVALOR, cVALOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILFUN", ::cFILFUN, cFILFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFRH3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFRH3",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFRH3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFRH3RESPONSE:_INFRH3RESULT","_ACOMPASOL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFRH4C of Service WSW0500307

WSMETHOD INFRH4C WSSEND cCODRH4,cFILRH3 WSRECEIVE oWSINFRH4CRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFRH4C xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFRH4C>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFRH4C",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFRH4CRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFRH4CRESPONSE:_INFRH4CRESULT","SLCARSAL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFRH4D of Service WSW0500307

WSMETHOD INFRH4D WSSEND cCODRH4,cFILRH3 WSRECEIVE oWSINFRH4DRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFRH4D xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFRH4D>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFRH4D",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFRH4DRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFRH4DRESPONSE:_INFRH4DRESULT","SOLDES",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFRH4F of Service WSW0500307

WSMETHOD INFRH4F WSSEND cCODRH4,cFILRH3 WSRECEIVE oWSINFRH4FRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFRH4F xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFRH4F>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFRH4F",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFRH4FRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFRH4FRESPONSE:_INFRH4FRESULT","INFH4",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFRH4FE of Service WSW0500307

WSMETHOD INFRH4FE WSSEND cCODRH4,cFILRH3 WSRECEIVE oWSINFRH4FERESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFRH4FE xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFRH4FE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFRH4FE",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFRH4FERESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFRH4FERESPONSE:_INFRH4FERESULT","INFFER",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFRH4I of Service WSW0500307

WSMETHOD INFRH4I WSSEND cCODRH4,cFILRH3 WSRECEIVE cINFRH4IRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFRH4I xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFRH4I>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFRH4I",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::cINFRH4IRESULT     :=  WSAdvValue( oXmlRet,"_INFRH4IRESPONSE:_INFRH4IRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFSOLVG of Service WSW0500307

WSMETHOD INFSOLVG WSSEND cCODRH3,cFILRH3 WSRECEIVE oWSINFSOLVGRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFSOLVG xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFSOLVG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/INFSOLVG",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::oWSINFSOLVGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFSOLVGRESPONSE:_INFSOLVGRESULT","INFRH3SU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VALAPRSOL of Service WSW0500307

WSMETHOD VALAPRSOL WSSEND cMATRICULA,cFILFUN,cCODRH3,cFILRH3 WSRECEIVE lVALAPRSOLRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VALAPRSOL xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILFUN", ::cFILFUN, cFILFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VALAPRSOL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/VALAPRSOL",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::lVALAPRSOLRESULT   :=  WSAdvValue( oXmlRet,"_VALAPRSOLRESPONSE:_VALAPRSOLRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VALSESMT of Service WSW0500307

WSMETHOD VALSESMT WSSEND cFILRH3,cCODRH3 WSRECEIVE lVALSESMTRESULT WSCLIENT WSW0500307
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VALSESMT xmlns="http://spon010108393:86/">'
cSoap += WSSoapValue("FILRH3", ::cFILRH3, cFILRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODRH3", ::cCODRH3, cCODRH3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VALSESMT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://spon010108393:86/VALSESMT",; 
	"DOCUMENT","http://spon010108393:86/",,"1.031217",; 
	"http://spon010108393:86/ws0101/W0500307.apw")

::Init()
::lVALSESMTRESULT    :=  WSAdvValue( oXmlRet,"_VALSESMTRESPONSE:_VALSESMTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure _RETDADOS

WSSTRUCT W0500307__RETDADOS
	WSDATA   cCARSLTD                  AS string
	WSDATA   cDECSLTD                  AS string
	WSDATA   cDESCCAR                  AS string
	WSDATA   cDESCCTT                  AS string
	WSDATA   cDESCFIL                  AS string
	WSDATA   cDESCFLS                  AS string
	WSDATA   cFILINIS                  AS string
	WSDATA   cFILSLTD                  AS string
	WSDATA   cFILSOLI                  AS string
	WSDATA   cMATRFLS                  AS string
	WSDATA   cMATSLTD                  AS string
	WSDATA   cNOMEFLS                  AS string
	WSDATA   cNOMSLTD                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307__RETDADOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307__RETDADOS
Return

WSMETHOD CLONE WSCLIENT W0500307__RETDADOS
	Local oClone := W0500307__RETDADOS():NEW()
	oClone:cCARSLTD             := ::cCARSLTD
	oClone:cDECSLTD             := ::cDECSLTD
	oClone:cDESCCAR             := ::cDESCCAR
	oClone:cDESCCTT             := ::cDESCCTT
	oClone:cDESCFIL             := ::cDESCFIL
	oClone:cDESCFLS             := ::cDESCFLS
	oClone:cFILINIS             := ::cFILINIS
	oClone:cFILSLTD             := ::cFILSLTD
	oClone:cFILSOLI             := ::cFILSOLI
	oClone:cMATRFLS             := ::cMATRFLS
	oClone:cMATSLTD             := ::cMATSLTD
	oClone:cNOMEFLS             := ::cNOMEFLS
	oClone:cNOMSLTD             := ::cNOMSLTD
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307__RETDADOS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCARSLTD           :=  WSAdvValue( oResponse,"_CARSLTD","string",NIL,"Property cCARSLTD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDECSLTD           :=  WSAdvValue( oResponse,"_DECSLTD","string",NIL,"Property cDECSLTD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCCAR           :=  WSAdvValue( oResponse,"_DESCCAR","string",NIL,"Property cDESCCAR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCCTT           :=  WSAdvValue( oResponse,"_DESCCTT","string",NIL,"Property cDESCCTT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCFIL           :=  WSAdvValue( oResponse,"_DESCFIL","string",NIL,"Property cDESCFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCFLS           :=  WSAdvValue( oResponse,"_DESCFLS","string",NIL,"Property cDESCFLS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILINIS           :=  WSAdvValue( oResponse,"_FILINIS","string",NIL,"Property cFILINIS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILSLTD           :=  WSAdvValue( oResponse,"_FILSLTD","string",NIL,"Property cFILSLTD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILSOLI           :=  WSAdvValue( oResponse,"_FILSOLI","string",NIL,"Property cFILSOLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATRFLS           :=  WSAdvValue( oResponse,"_MATRFLS","string",NIL,"Property cMATRFLS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATSLTD           :=  WSAdvValue( oResponse,"_MATSLTD","string",NIL,"Property cMATSLTD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMEFLS           :=  WSAdvValue( oResponse,"_NOMEFLS","string",NIL,"Property cNOMEFLS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMSLTD           :=  WSAdvValue( oResponse,"_NOMSLTD","string",NIL,"Property cNOMSLTD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TREINA

WSSTRUCT W0500307_TREINA
	WSDATA   cCALEND                   AS string
	WSDATA   cCURSO                    AS string
	WSDATA   cNOME                     AS string
	WSDATA   cOBS                      AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_TREINA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_TREINA
Return

WSMETHOD CLONE WSCLIENT W0500307_TREINA
	Local oClone := W0500307_TREINA():NEW()
	oClone:cCALEND              := ::cCALEND
	oClone:cCURSO               := ::cCURSO
	oClone:cNOME                := ::cNOME
	oClone:cOBS                 := ::cOBS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_TREINA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCALEND            :=  WSAdvValue( oResponse,"_CALEND","string",NIL,"Property cCALEND as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCURSO             :=  WSAdvValue( oResponse,"_CURSO","string",NIL,"Property cCURSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBS               :=  WSAdvValue( oResponse,"_OBS","string",NIL,"Property cOBS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _INFHIS

WSSTRUCT W0500307__INFHIS
	WSDATA   oWSREGISTRO               AS W0500307_ARRAYOFINFHIS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307__INFHIS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307__INFHIS
Return

WSMETHOD CLONE WSCLIENT W0500307__INFHIS
	Local oClone := W0500307__INFHIS():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307__INFHIS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFINFHIS",NIL,"Property oWSREGISTRO as s0:ARRAYOFINFHIS on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0500307_ARRAYOFINFHIS():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure FUNCIO

WSSTRUCT W0500307_FUNCIO
	WSDATA   cCODMAFUN                 AS string
	WSDATA   cNOMMAFUN                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_FUNCIO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_FUNCIO
Return

WSMETHOD CLONE WSCLIENT W0500307_FUNCIO
	Local oClone := W0500307_FUNCIO():NEW()
	oClone:cCODMAFUN            := ::cCODMAFUN
	oClone:cNOMMAFUN            := ::cNOMMAFUN
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_FUNCIO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODMAFUN          :=  WSAdvValue( oResponse,"_CODMAFUN","string",NIL,"Property cCODMAFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMMAFUN          :=  WSAdvValue( oResponse,"_NOMMAFUN","string",NIL,"Property cNOMMAFUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SUPERINF

WSSTRUCT W0500307_SUPERINF
	WSDATA   cCODMASUP                 AS string
	WSDATA   cEMPAPROV                 AS string
	WSDATA   cFILMASUP                 AS string
	WSDATA   cFILSOLIC                 AS string
	WSDATA   cNVLAPROV                 AS string
	WSDATA   cOBS                      AS string
	WSDATA   cSOLICI                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_SUPERINF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_SUPERINF
Return

WSMETHOD CLONE WSCLIENT W0500307_SUPERINF
	Local oClone := W0500307_SUPERINF():NEW()
	oClone:cCODMASUP            := ::cCODMASUP
	oClone:cEMPAPROV            := ::cEMPAPROV
	oClone:cFILMASUP            := ::cFILMASUP
	oClone:cFILSOLIC            := ::cFILSOLIC
	oClone:cNVLAPROV            := ::cNVLAPROV
	oClone:cOBS                 := ::cOBS
	oClone:cSOLICI              := ::cSOLICI
Return oClone

WSMETHOD SOAPSEND WSCLIENT W0500307_SUPERINF
	Local cSoap := ""
	cSoap += WSSoapValue("CODMASUP", ::cCODMASUP, ::cCODMASUP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPAPROV", ::cEMPAPROV, ::cEMPAPROV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILMASUP", ::cFILMASUP, ::cFILMASUP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILSOLIC", ::cFILSOLIC, ::cFILSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NVLAPROV", ::cNVLAPROV, ::cNVLAPROV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBS", ::cOBS, ::cOBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SOLICI", ::cSOLICI, ::cSOLICI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure SUPEML

WSSTRUCT W0500307_SUPEML
	WSDATA   cMSGRET                   AS string
	WSDATA   cQBMATRESP                AS string
	WSDATA   cRAEMAIL                  AS string
	WSDATA   cRANOME                   AS string
	WSDATA   lTIPRET                   AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_SUPEML
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_SUPEML
Return

WSMETHOD CLONE WSCLIENT W0500307_SUPEML
	Local oClone := W0500307_SUPEML():NEW()
	oClone:cMSGRET              := ::cMSGRET
	oClone:cQBMATRESP           := ::cQBMATRESP
	oClone:cRAEMAIL             := ::cRAEMAIL
	oClone:cRANOME              := ::cRANOME
	oClone:lTIPRET              := ::lTIPRET
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_SUPEML
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMSGRET            :=  WSAdvValue( oResponse,"_MSGRET","string",NIL,"Property cMSGRET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cQBMATRESP         :=  WSAdvValue( oResponse,"_QBMATRESP","string",NIL,"Property cQBMATRESP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAEMAIL           :=  WSAdvValue( oResponse,"_RAEMAIL","string",NIL,"Property cRAEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRANOME            :=  WSAdvValue( oResponse,"_RANOME","string",NIL,"Property cRANOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lTIPRET            :=  WSAdvValue( oResponse,"_TIPRET","boolean",NIL,"Property lTIPRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure _ACOMPASOL

WSSTRUCT W0500307__ACOMPASOL
	WSDATA   oWSACOMPANHA              AS W0500307_ARRAYOFACOMPASOL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307__ACOMPASOL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307__ACOMPASOL
Return

WSMETHOD CLONE WSCLIENT W0500307__ACOMPASOL
	Local oClone := W0500307__ACOMPASOL():NEW()
	oClone:oWSACOMPANHA         := IIF(::oWSACOMPANHA = NIL , NIL , ::oWSACOMPANHA:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307__ACOMPASOL
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ACOMPANHA","ARRAYOFACOMPASOL",NIL,"Property oWSACOMPANHA as s0:ARRAYOFACOMPASOL on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSACOMPANHA := W0500307_ARRAYOFACOMPASOL():New()
		::oWSACOMPANHA:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure SLCARSAL

WSSTRUCT W0500307_SLCARSAL
	WSDATA   cRACC                     AS string
	WSDATA   cRACLVL                   AS string
	WSDATA   cRACODFUNC                AS string
	WSDATA   cRADEPTO                  AS string
	WSDATA   cRAFILIAL                 AS string
	WSDATA   cRAHRSDIA                 AS string
	WSDATA   cRAHRSEMAN                AS string
	WSDATA   cRAHRSMES                 AS string
	WSDATA   cRAITEM                   AS string
	WSDATA   cRAPOSTO                  AS string
	WSDATA   cRAPROCES                 AS string
	WSDATA   cRAREGRA                  AS string
	WSDATA   cRASALARIO                AS string
	WSDATA   cRASEQTURN                AS string
	WSDATA   cRATIPOALT                AS string
	WSDATA   cRATNOTRAB                AS string
	WSDATA   cTMPCCATU                 AS string
	WSDATA   cTMPCLVL                  AS string
	WSDATA   cTMPD_CC_D                AS string
	WSDATA   cTMPD_CCAT                AS string
	WSDATA   cTMPD_DEPD                AS string
	WSDATA   cTMPD_DEPT                AS string
	WSDATA   cTMPD_F_PP                AS string
	WSDATA   cTMPD_FILI                AS string
	WSDATA   cTMPD_FUNC                AS string
	WSDATA   cTMPD_MOT                 AS string
	WSDATA   cTMPD_TURN                AS string
	WSDATA   cTMPDEPTOA                AS string
	WSDATA   cTMPDESCTU                AS string
	WSDATA   cTMPFAIXAT                AS string
	WSDATA   cTMPFILIAL                AS string
	WSDATA   cTMPFUNCAO                AS string
	WSDATA   cTMPH_D_AT                AS string
	WSDATA   cTMPH_M_AT                AS string
	WSDATA   cTMPH_S_AT                AS string
	WSDATA   cTMPITEM                  AS string
	WSDATA   cTMPMETIRO                AS string
	WSDATA   cTMPN_F_D                 AS string
	WSDATA   cTMPNIVELT                AS string
	WSDATA   cTMPOBSINC                AS string
	WSDATA   cTMPPERCSA                AS string
	WSDATA   cTMPPOSTO                 AS string
	WSDATA   cTMPPROCES                AS string
	WSDATA   cTMPREGRA                 AS string
	WSDATA   cTMPS_TURN                AS string
	WSDATA   cTMPSALATU                AS string
	WSDATA   cTMPTABELA                AS string
	WSDATA   cTMPTIPO                  AS string
	WSDATA   cTMPTURNAT                AS string
	WSDATA   cTMPVLSALA                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_SLCARSAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_SLCARSAL
Return

WSMETHOD CLONE WSCLIENT W0500307_SLCARSAL
	Local oClone := W0500307_SLCARSAL():NEW()
	oClone:cRACC                := ::cRACC
	oClone:cRACLVL              := ::cRACLVL
	oClone:cRACODFUNC           := ::cRACODFUNC
	oClone:cRADEPTO             := ::cRADEPTO
	oClone:cRAFILIAL            := ::cRAFILIAL
	oClone:cRAHRSDIA            := ::cRAHRSDIA
	oClone:cRAHRSEMAN           := ::cRAHRSEMAN
	oClone:cRAHRSMES            := ::cRAHRSMES
	oClone:cRAITEM              := ::cRAITEM
	oClone:cRAPOSTO             := ::cRAPOSTO
	oClone:cRAPROCES            := ::cRAPROCES
	oClone:cRAREGRA             := ::cRAREGRA
	oClone:cRASALARIO           := ::cRASALARIO
	oClone:cRASEQTURN           := ::cRASEQTURN
	oClone:cRATIPOALT           := ::cRATIPOALT
	oClone:cRATNOTRAB           := ::cRATNOTRAB
	oClone:cTMPCCATU            := ::cTMPCCATU
	oClone:cTMPCLVL             := ::cTMPCLVL
	oClone:cTMPD_CC_D           := ::cTMPD_CC_D
	oClone:cTMPD_CCAT           := ::cTMPD_CCAT
	oClone:cTMPD_DEPD           := ::cTMPD_DEPD
	oClone:cTMPD_DEPT           := ::cTMPD_DEPT
	oClone:cTMPD_F_PP           := ::cTMPD_F_PP
	oClone:cTMPD_FILI           := ::cTMPD_FILI
	oClone:cTMPD_FUNC           := ::cTMPD_FUNC
	oClone:cTMPD_MOT            := ::cTMPD_MOT
	oClone:cTMPD_TURN           := ::cTMPD_TURN
	oClone:cTMPDEPTOA           := ::cTMPDEPTOA
	oClone:cTMPDESCTU           := ::cTMPDESCTU
	oClone:cTMPFAIXAT           := ::cTMPFAIXAT
	oClone:cTMPFILIAL           := ::cTMPFILIAL
	oClone:cTMPFUNCAO           := ::cTMPFUNCAO
	oClone:cTMPH_D_AT           := ::cTMPH_D_AT
	oClone:cTMPH_M_AT           := ::cTMPH_M_AT
	oClone:cTMPH_S_AT           := ::cTMPH_S_AT
	oClone:cTMPITEM             := ::cTMPITEM
	oClone:cTMPMETIRO           := ::cTMPMETIRO
	oClone:cTMPN_F_D            := ::cTMPN_F_D
	oClone:cTMPNIVELT           := ::cTMPNIVELT
	oClone:cTMPOBSINC           := ::cTMPOBSINC
	oClone:cTMPPERCSA           := ::cTMPPERCSA
	oClone:cTMPPOSTO            := ::cTMPPOSTO
	oClone:cTMPPROCES           := ::cTMPPROCES
	oClone:cTMPREGRA            := ::cTMPREGRA
	oClone:cTMPS_TURN           := ::cTMPS_TURN
	oClone:cTMPSALATU           := ::cTMPSALATU
	oClone:cTMPTABELA           := ::cTMPTABELA
	oClone:cTMPTIPO             := ::cTMPTIPO
	oClone:cTMPTURNAT           := ::cTMPTURNAT
	oClone:cTMPVLSALA           := ::cTMPVLSALA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_SLCARSAL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRACC              :=  WSAdvValue( oResponse,"_RACC","string",NIL,"Property cRACC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRACLVL            :=  WSAdvValue( oResponse,"_RACLVL","string",NIL,"Property cRACLVL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRACODFUNC         :=  WSAdvValue( oResponse,"_RACODFUNC","string",NIL,"Property cRACODFUNC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRADEPTO           :=  WSAdvValue( oResponse,"_RADEPTO","string",NIL,"Property cRADEPTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAFILIAL          :=  WSAdvValue( oResponse,"_RAFILIAL","string",NIL,"Property cRAFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAHRSDIA          :=  WSAdvValue( oResponse,"_RAHRSDIA","string",NIL,"Property cRAHRSDIA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAHRSEMAN         :=  WSAdvValue( oResponse,"_RAHRSEMAN","string",NIL,"Property cRAHRSEMAN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAHRSMES          :=  WSAdvValue( oResponse,"_RAHRSMES","string",NIL,"Property cRAHRSMES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAITEM            :=  WSAdvValue( oResponse,"_RAITEM","string",NIL,"Property cRAITEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAPOSTO           :=  WSAdvValue( oResponse,"_RAPOSTO","string",NIL,"Property cRAPOSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAPROCES          :=  WSAdvValue( oResponse,"_RAPROCES","string",NIL,"Property cRAPROCES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAREGRA           :=  WSAdvValue( oResponse,"_RAREGRA","string",NIL,"Property cRAREGRA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRASALARIO         :=  WSAdvValue( oResponse,"_RASALARIO","string",NIL,"Property cRASALARIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRASEQTURN         :=  WSAdvValue( oResponse,"_RASEQTURN","string",NIL,"Property cRASEQTURN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRATIPOALT         :=  WSAdvValue( oResponse,"_RATIPOALT","string",NIL,"Property cRATIPOALT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRATNOTRAB         :=  WSAdvValue( oResponse,"_RATNOTRAB","string",NIL,"Property cRATNOTRAB as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPCCATU          :=  WSAdvValue( oResponse,"_TMPCCATU","string",NIL,"Property cTMPCCATU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPCLVL           :=  WSAdvValue( oResponse,"_TMPCLVL","string",NIL,"Property cTMPCLVL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_CC_D         :=  WSAdvValue( oResponse,"_TMPD_CC_D","string",NIL,"Property cTMPD_CC_D as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_CCAT         :=  WSAdvValue( oResponse,"_TMPD_CCAT","string",NIL,"Property cTMPD_CCAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_DEPD         :=  WSAdvValue( oResponse,"_TMPD_DEPD","string",NIL,"Property cTMPD_DEPD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_DEPT         :=  WSAdvValue( oResponse,"_TMPD_DEPT","string",NIL,"Property cTMPD_DEPT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_F_PP         :=  WSAdvValue( oResponse,"_TMPD_F_PP","string",NIL,"Property cTMPD_F_PP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_FILI         :=  WSAdvValue( oResponse,"_TMPD_FILI","string",NIL,"Property cTMPD_FILI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_FUNC         :=  WSAdvValue( oResponse,"_TMPD_FUNC","string",NIL,"Property cTMPD_FUNC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_MOT          :=  WSAdvValue( oResponse,"_TMPD_MOT","string",NIL,"Property cTMPD_MOT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPD_TURN         :=  WSAdvValue( oResponse,"_TMPD_TURN","string",NIL,"Property cTMPD_TURN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDEPTOA         :=  WSAdvValue( oResponse,"_TMPDEPTOA","string",NIL,"Property cTMPDEPTOA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDESCTU         :=  WSAdvValue( oResponse,"_TMPDESCTU","string",NIL,"Property cTMPDESCTU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPFAIXAT         :=  WSAdvValue( oResponse,"_TMPFAIXAT","string",NIL,"Property cTMPFAIXAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPFILIAL         :=  WSAdvValue( oResponse,"_TMPFILIAL","string",NIL,"Property cTMPFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPFUNCAO         :=  WSAdvValue( oResponse,"_TMPFUNCAO","string",NIL,"Property cTMPFUNCAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPH_D_AT         :=  WSAdvValue( oResponse,"_TMPH_D_AT","string",NIL,"Property cTMPH_D_AT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPH_M_AT         :=  WSAdvValue( oResponse,"_TMPH_M_AT","string",NIL,"Property cTMPH_M_AT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPH_S_AT         :=  WSAdvValue( oResponse,"_TMPH_S_AT","string",NIL,"Property cTMPH_S_AT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPITEM           :=  WSAdvValue( oResponse,"_TMPITEM","string",NIL,"Property cTMPITEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPMETIRO         :=  WSAdvValue( oResponse,"_TMPMETIRO","string",NIL,"Property cTMPMETIRO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPN_F_D          :=  WSAdvValue( oResponse,"_TMPN_F_D","string",NIL,"Property cTMPN_F_D as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPNIVELT         :=  WSAdvValue( oResponse,"_TMPNIVELT","string",NIL,"Property cTMPNIVELT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPOBSINC         :=  WSAdvValue( oResponse,"_TMPOBSINC","string",NIL,"Property cTMPOBSINC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPPERCSA         :=  WSAdvValue( oResponse,"_TMPPERCSA","string",NIL,"Property cTMPPERCSA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPPOSTO          :=  WSAdvValue( oResponse,"_TMPPOSTO","string",NIL,"Property cTMPPOSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPPROCES         :=  WSAdvValue( oResponse,"_TMPPROCES","string",NIL,"Property cTMPPROCES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPREGRA          :=  WSAdvValue( oResponse,"_TMPREGRA","string",NIL,"Property cTMPREGRA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPS_TURN         :=  WSAdvValue( oResponse,"_TMPS_TURN","string",NIL,"Property cTMPS_TURN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPSALATU         :=  WSAdvValue( oResponse,"_TMPSALATU","string",NIL,"Property cTMPSALATU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPTABELA         :=  WSAdvValue( oResponse,"_TMPTABELA","string",NIL,"Property cTMPTABELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPTIPO           :=  WSAdvValue( oResponse,"_TMPTIPO","string",NIL,"Property cTMPTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPTURNAT         :=  WSAdvValue( oResponse,"_TMPTURNAT","string",NIL,"Property cTMPTURNAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPVLSALA         :=  WSAdvValue( oResponse,"_TMPVLSALA","string",NIL,"Property cTMPVLSALA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SOLDES

WSSTRUCT W0500307_SOLDES
	WSDATA   cNVUSUARIO                AS string
	WSDATA   cP10CODRES                AS string
	WSDATA   cP10DTDEMI                AS string
	WSDATA   cP10DTSOLI                AS string
	WSDATA   cP10FILIAL                AS string
	WSDATA   cP10MATRIC                AS string
	WSDATA   cP10MOTIVO                AS string
	WSDATA   cSUBGRPALC                AS string
	WSDATA   cTMPDESRES                AS string
	WSDATA   cTMPMATRIC                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_SOLDES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_SOLDES
Return

WSMETHOD CLONE WSCLIENT W0500307_SOLDES
	Local oClone := W0500307_SOLDES():NEW()
	oClone:cNVUSUARIO           := ::cNVUSUARIO
	oClone:cP10CODRES           := ::cP10CODRES
	oClone:cP10DTDEMI           := ::cP10DTDEMI
	oClone:cP10DTSOLI           := ::cP10DTSOLI
	oClone:cP10FILIAL           := ::cP10FILIAL
	oClone:cP10MATRIC           := ::cP10MATRIC
	oClone:cP10MOTIVO           := ::cP10MOTIVO
	oClone:cSUBGRPALC           := ::cSUBGRPALC
	oClone:cTMPDESRES           := ::cTMPDESRES
	oClone:cTMPMATRIC           := ::cTMPMATRIC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_SOLDES
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNVUSUARIO         :=  WSAdvValue( oResponse,"_NVUSUARIO","string",NIL,"Property cNVUSUARIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cP10CODRES         :=  WSAdvValue( oResponse,"_P10CODRES","string",NIL,"Property cP10CODRES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cP10DTDEMI         :=  WSAdvValue( oResponse,"_P10DTDEMI","string",NIL,"Property cP10DTDEMI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cP10DTSOLI         :=  WSAdvValue( oResponse,"_P10DTSOLI","string",NIL,"Property cP10DTSOLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cP10FILIAL         :=  WSAdvValue( oResponse,"_P10FILIAL","string",NIL,"Property cP10FILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cP10MATRIC         :=  WSAdvValue( oResponse,"_P10MATRIC","string",NIL,"Property cP10MATRIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cP10MOTIVO         :=  WSAdvValue( oResponse,"_P10MOTIVO","string",NIL,"Property cP10MOTIVO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSUBGRPALC         :=  WSAdvValue( oResponse,"_SUBGRPALC","string",NIL,"Property cSUBGRPALC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDESRES         :=  WSAdvValue( oResponse,"_TMPDESRES","string",NIL,"Property cTMPDESRES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPMATRIC         :=  WSAdvValue( oResponse,"_TMPMATRIC","string",NIL,"Property cTMPMATRIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure INFH4

WSSTRUCT W0500307_INFH4
	WSDATA   cPA2CARGO                 AS string
	WSDATA   cPA2CC                    AS string
	WSDATA   cPA2DEPART                AS string
	WSDATA   cPA2DESCAR                AS string
	WSDATA   cPA2DESCC                 AS string
	WSDATA   cPA2DESCTU                AS string
	WSDATA   cPA2DESDEP                AS string
	WSDATA   cPA2DESFIL                AS string
	WSDATA   cPA2DTADMI                AS string
	WSDATA   cPA2FILCAN                AS string
	WSDATA   cPA2HRMES                 AS string
	WSDATA   cPA2SALHR                 AS string
	WSDATA   cPA2STSVAG                AS string
	WSDATA   cPA2TURNO                 AS string
	WSDATA   cPA5CDCAND                AS string
	WSDATA   cPA5CDVAGA                AS string
	WSDATA   cPA5CPFCAN                AS string
	WSDATA   cPA5DTAPRV                AS string
	WSDATA   cPA5FILIAL                AS string
	WSDATA   cPA5LOGTOR                AS string
	WSDATA   cPA5NMCAND                AS string
	WSDATA   cPA5SLFECH                AS string
	WSDATA   cPA5VLVAGA                AS string
	WSDATA   cTMPCARGOVG               AS string
	WSDATA   cTMPCCVAGA                AS string
	WSDATA   cTMPDESCVG                AS string
	WSDATA   cTMPDPTVAGA               AS string
	WSDATA   cTMPDSCCGVG               AS string
	WSDATA   cTMPDSCDVAGA              AS string
	WSDATA   cTMPDSCVAGA               AS string
	WSDATA   cTMPFILVAGA               AS string
	WSDATA   cTMPMATCOLA               AS string
	WSDATA   cTMPNMVAGA                AS string
	WSDATA   cTMPNOMECOLA              AS string
	WSDATA   cTMPNOMTOR                AS string
	WSDATA   cTMPSALARIO               AS string
	WSDATA   cTMPTIPOFAP               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_INFH4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_INFH4
Return

WSMETHOD CLONE WSCLIENT W0500307_INFH4
	Local oClone := W0500307_INFH4():NEW()
	oClone:cPA2CARGO            := ::cPA2CARGO
	oClone:cPA2CC               := ::cPA2CC
	oClone:cPA2DEPART           := ::cPA2DEPART
	oClone:cPA2DESCAR           := ::cPA2DESCAR
	oClone:cPA2DESCC            := ::cPA2DESCC
	oClone:cPA2DESCTU           := ::cPA2DESCTU
	oClone:cPA2DESDEP           := ::cPA2DESDEP
	oClone:cPA2DESFIL           := ::cPA2DESFIL
	oClone:cPA2DTADMI           := ::cPA2DTADMI
	oClone:cPA2FILCAN           := ::cPA2FILCAN
	oClone:cPA2HRMES            := ::cPA2HRMES
	oClone:cPA2SALHR            := ::cPA2SALHR
	oClone:cPA2STSVAG           := ::cPA2STSVAG
	oClone:cPA2TURNO            := ::cPA2TURNO
	oClone:cPA5CDCAND           := ::cPA5CDCAND
	oClone:cPA5CDVAGA           := ::cPA5CDVAGA
	oClone:cPA5CPFCAN           := ::cPA5CPFCAN
	oClone:cPA5DTAPRV           := ::cPA5DTAPRV
	oClone:cPA5FILIAL           := ::cPA5FILIAL
	oClone:cPA5LOGTOR           := ::cPA5LOGTOR
	oClone:cPA5NMCAND           := ::cPA5NMCAND
	oClone:cPA5SLFECH           := ::cPA5SLFECH
	oClone:cPA5VLVAGA           := ::cPA5VLVAGA
	oClone:cTMPCARGOVG          := ::cTMPCARGOVG
	oClone:cTMPCCVAGA           := ::cTMPCCVAGA
	oClone:cTMPDESCVG           := ::cTMPDESCVG
	oClone:cTMPDPTVAGA          := ::cTMPDPTVAGA
	oClone:cTMPDSCCGVG          := ::cTMPDSCCGVG
	oClone:cTMPDSCDVAGA         := ::cTMPDSCDVAGA
	oClone:cTMPDSCVAGA          := ::cTMPDSCVAGA
	oClone:cTMPFILVAGA          := ::cTMPFILVAGA
	oClone:cTMPMATCOLA          := ::cTMPMATCOLA
	oClone:cTMPNMVAGA           := ::cTMPNMVAGA
	oClone:cTMPNOMECOLA         := ::cTMPNOMECOLA
	oClone:cTMPNOMTOR           := ::cTMPNOMTOR
	oClone:cTMPSALARIO          := ::cTMPSALARIO
	oClone:cTMPTIPOFAP          := ::cTMPTIPOFAP
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_INFH4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPA2CARGO          :=  WSAdvValue( oResponse,"_PA2CARGO","string",NIL,"Property cPA2CARGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2CC             :=  WSAdvValue( oResponse,"_PA2CC","string",NIL,"Property cPA2CC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DEPART         :=  WSAdvValue( oResponse,"_PA2DEPART","string",NIL,"Property cPA2DEPART as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DESCAR         :=  WSAdvValue( oResponse,"_PA2DESCAR","string",NIL,"Property cPA2DESCAR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DESCC          :=  WSAdvValue( oResponse,"_PA2DESCC","string",NIL,"Property cPA2DESCC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DESCTU         :=  WSAdvValue( oResponse,"_PA2DESCTU","string",NIL,"Property cPA2DESCTU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DESDEP         :=  WSAdvValue( oResponse,"_PA2DESDEP","string",NIL,"Property cPA2DESDEP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DESFIL         :=  WSAdvValue( oResponse,"_PA2DESFIL","string",NIL,"Property cPA2DESFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2DTADMI         :=  WSAdvValue( oResponse,"_PA2DTADMI","string",NIL,"Property cPA2DTADMI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2FILCAN         :=  WSAdvValue( oResponse,"_PA2FILCAN","string",NIL,"Property cPA2FILCAN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2HRMES          :=  WSAdvValue( oResponse,"_PA2HRMES","string",NIL,"Property cPA2HRMES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2SALHR          :=  WSAdvValue( oResponse,"_PA2SALHR","string",NIL,"Property cPA2SALHR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2STSVAG         :=  WSAdvValue( oResponse,"_PA2STSVAG","string",NIL,"Property cPA2STSVAG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA2TURNO          :=  WSAdvValue( oResponse,"_PA2TURNO","string",NIL,"Property cPA2TURNO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5CDCAND         :=  WSAdvValue( oResponse,"_PA5CDCAND","string",NIL,"Property cPA5CDCAND as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5CDVAGA         :=  WSAdvValue( oResponse,"_PA5CDVAGA","string",NIL,"Property cPA5CDVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5CPFCAN         :=  WSAdvValue( oResponse,"_PA5CPFCAN","string",NIL,"Property cPA5CPFCAN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5DTAPRV         :=  WSAdvValue( oResponse,"_PA5DTAPRV","string",NIL,"Property cPA5DTAPRV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5FILIAL         :=  WSAdvValue( oResponse,"_PA5FILIAL","string",NIL,"Property cPA5FILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5LOGTOR         :=  WSAdvValue( oResponse,"_PA5LOGTOR","string",NIL,"Property cPA5LOGTOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5NMCAND         :=  WSAdvValue( oResponse,"_PA5NMCAND","string",NIL,"Property cPA5NMCAND as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5SLFECH         :=  WSAdvValue( oResponse,"_PA5SLFECH","string",NIL,"Property cPA5SLFECH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPA5VLVAGA         :=  WSAdvValue( oResponse,"_PA5VLVAGA","string",NIL,"Property cPA5VLVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPCARGOVG        :=  WSAdvValue( oResponse,"_TMPCARGOVG","string",NIL,"Property cTMPCARGOVG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPCCVAGA         :=  WSAdvValue( oResponse,"_TMPCCVAGA","string",NIL,"Property cTMPCCVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDESCVG         :=  WSAdvValue( oResponse,"_TMPDESCVG","string",NIL,"Property cTMPDESCVG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDPTVAGA        :=  WSAdvValue( oResponse,"_TMPDPTVAGA","string",NIL,"Property cTMPDPTVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDSCCGVG        :=  WSAdvValue( oResponse,"_TMPDSCCGVG","string",NIL,"Property cTMPDSCCGVG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDSCDVAGA       :=  WSAdvValue( oResponse,"_TMPDSCDVAGA","string",NIL,"Property cTMPDSCDVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPDSCVAGA        :=  WSAdvValue( oResponse,"_TMPDSCVAGA","string",NIL,"Property cTMPDSCVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPFILVAGA        :=  WSAdvValue( oResponse,"_TMPFILVAGA","string",NIL,"Property cTMPFILVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPMATCOLA        :=  WSAdvValue( oResponse,"_TMPMATCOLA","string",NIL,"Property cTMPMATCOLA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPNMVAGA         :=  WSAdvValue( oResponse,"_TMPNMVAGA","string",NIL,"Property cTMPNMVAGA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPNOMECOLA       :=  WSAdvValue( oResponse,"_TMPNOMECOLA","string",NIL,"Property cTMPNOMECOLA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPNOMTOR         :=  WSAdvValue( oResponse,"_TMPNOMTOR","string",NIL,"Property cTMPNOMTOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPSALARIO        :=  WSAdvValue( oResponse,"_TMPSALARIO","string",NIL,"Property cTMPSALARIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPTIPOFAP        :=  WSAdvValue( oResponse,"_TMPTIPOFAP","string",NIL,"Property cTMPTIPOFAP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure INFFER

WSSTRUCT W0500307_INFFER
	WSDATA   cOBS                      AS string
	WSDATA   cR8DATAFIM                AS string
	WSDATA   cR8DATAINI                AS string
	WSDATA   cR8DURACAO                AS string
	WSDATA   cR8FILIAL                 AS string
	WSDATA   cR8MAT                    AS string
	WSDATA   cSTATUSS                  AS string
	WSDATA   cTMP1P13SL                AS string
	WSDATA   cTMPABONO                 AS string
	WSDATA   cTMPNOME                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_INFFER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_INFFER
Return

WSMETHOD CLONE WSCLIENT W0500307_INFFER
	Local oClone := W0500307_INFFER():NEW()
	oClone:cOBS                 := ::cOBS
	oClone:cR8DATAFIM           := ::cR8DATAFIM
	oClone:cR8DATAINI           := ::cR8DATAINI
	oClone:cR8DURACAO           := ::cR8DURACAO
	oClone:cR8FILIAL            := ::cR8FILIAL
	oClone:cR8MAT               := ::cR8MAT
	oClone:cSTATUSS             := ::cSTATUSS
	oClone:cTMP1P13SL           := ::cTMP1P13SL
	oClone:cTMPABONO            := ::cTMPABONO
	oClone:cTMPNOME             := ::cTMPNOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_INFFER
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cOBS               :=  WSAdvValue( oResponse,"_OBS","string",NIL,"Property cOBS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cR8DATAFIM         :=  WSAdvValue( oResponse,"_R8DATAFIM","string",NIL,"Property cR8DATAFIM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cR8DATAINI         :=  WSAdvValue( oResponse,"_R8DATAINI","string",NIL,"Property cR8DATAINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cR8DURACAO         :=  WSAdvValue( oResponse,"_R8DURACAO","string",NIL,"Property cR8DURACAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cR8FILIAL          :=  WSAdvValue( oResponse,"_R8FILIAL","string",NIL,"Property cR8FILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cR8MAT             :=  WSAdvValue( oResponse,"_R8MAT","string",NIL,"Property cR8MAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUSS           :=  WSAdvValue( oResponse,"_STATUSS","string",NIL,"Property cSTATUSS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMP1P13SL         :=  WSAdvValue( oResponse,"_TMP1P13SL","string",NIL,"Property cTMP1P13SL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPABONO          :=  WSAdvValue( oResponse,"_TMPABONO","string",NIL,"Property cTMPABONO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPNOME           :=  WSAdvValue( oResponse,"_TMPNOME","string",NIL,"Property cTMPNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure INFRH3SU

WSSTRUCT W0500307_INFRH3SU
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

WSMETHOD NEW WSCLIENT W0500307_INFRH3SU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_INFRH3SU
Return

WSMETHOD CLONE WSCLIENT W0500307_INFRH3SU
	Local oClone := W0500307_INFRH3SU():NEW()
	oClone:cRH3FILAPR           := ::cRH3FILAPR
	oClone:cRH3FILINI           := ::cRH3FILINI
	oClone:cRH3MATAPR           := ::cRH3MATAPR
	oClone:cRH3MATINI           := ::cRH3MATINI
	oClone:cRH3VISAO            := ::cRH3VISAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_INFRH3SU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRH3FILAPR         :=  WSAdvValue( oResponse,"_RH3FILAPR","string",NIL,"Property cRH3FILAPR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3FILINI         :=  WSAdvValue( oResponse,"_RH3FILINI","string",NIL,"Property cRH3FILINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3MATAPR         :=  WSAdvValue( oResponse,"_RH3MATAPR","string",NIL,"Property cRH3MATAPR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3MATINI         :=  WSAdvValue( oResponse,"_RH3MATINI","string",NIL,"Property cRH3MATINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRH3VISAO          :=  WSAdvValue( oResponse,"_RH3VISAO","string",NIL,"Property cRH3VISAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFINFHIS

WSSTRUCT W0500307_ARRAYOFINFHIS
	WSDATA   oWSINFHIS                 AS W0500307_INFHIS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_ARRAYOFINFHIS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_ARRAYOFINFHIS
	::oWSINFHIS            := {} // Array Of  W0500307_INFHIS():New()
Return

WSMETHOD CLONE WSCLIENT W0500307_ARRAYOFINFHIS
	Local oClone := W0500307_ARRAYOFINFHIS():NEW()
	oClone:oWSINFHIS := NIL
	If ::oWSINFHIS <> NIL 
		oClone:oWSINFHIS := {}
		aEval( ::oWSINFHIS , { |x| aadd( oClone:oWSINFHIS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_ARRAYOFINFHIS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INFHIS","INFHIS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSINFHIS , W0500307_INFHIS():New() )
			::oWSINFHIS[len(::oWSINFHIS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFACOMPASOL

WSSTRUCT W0500307_ARRAYOFACOMPASOL
	WSDATA   oWSACOMPASOL              AS W0500307_ACOMPASOL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_ARRAYOFACOMPASOL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_ARRAYOFACOMPASOL
	::oWSACOMPASOL         := {} // Array Of  W0500307_ACOMPASOL():New()
Return

WSMETHOD CLONE WSCLIENT W0500307_ARRAYOFACOMPASOL
	Local oClone := W0500307_ARRAYOFACOMPASOL():NEW()
	oClone:oWSACOMPASOL := NIL
	If ::oWSACOMPASOL <> NIL 
		oClone:oWSACOMPASOL := {}
		aEval( ::oWSACOMPASOL , { |x| aadd( oClone:oWSACOMPASOL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_ARRAYOFACOMPASOL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ACOMPASOL","ACOMPASOL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSACOMPASOL , W0500307_ACOMPASOL():New() )
			::oWSACOMPASOL[len(::oWSACOMPASOL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure INFHIS

WSSTRUCT W0500307_INFHIS
	WSDATA   lLRET                     AS boolean
	WSDATA   cPAEDCCAPR                AS string
	WSDATA   cPAEFUNAPR                AS string
	WSDATA   cPAENOMEAP                AS string
	WSDATA   cPAEOBS                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_INFHIS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_INFHIS
Return

WSMETHOD CLONE WSCLIENT W0500307_INFHIS
	Local oClone := W0500307_INFHIS():NEW()
	oClone:lLRET                := ::lLRET
	oClone:cPAEDCCAPR           := ::cPAEDCCAPR
	oClone:cPAEFUNAPR           := ::cPAEFUNAPR
	oClone:cPAENOMEAP           := ::cPAENOMEAP
	oClone:cPAEOBS              := ::cPAEOBS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_INFHIS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lLRET              :=  WSAdvValue( oResponse,"_LRET","boolean",NIL,"Property lLRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cPAEDCCAPR         :=  WSAdvValue( oResponse,"_PAEDCCAPR","string",NIL,"Property cPAEDCCAPR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPAEFUNAPR         :=  WSAdvValue( oResponse,"_PAEFUNAPR","string",NIL,"Property cPAEFUNAPR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPAENOMEAP         :=  WSAdvValue( oResponse,"_PAENOMEAP","string",NIL,"Property cPAENOMEAP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPAEOBS            :=  WSAdvValue( oResponse,"_PAEOBS","string",NIL,"Property cPAEOBS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ACOMPASOL

WSSTRUCT W0500307_ACOMPASOL
	WSDATA   cCODIGO                   AS string
	WSDATA   cCODSOLI                  AS string
	WSDATA   cDESCENTCUS               AS string
	WSDATA   cDESFILRH3                AS string
	WSDATA   cDESSUBST                 AS string
	WSDATA   cFILRH3                   AS string
	WSDATA   cMATRIC                   AS string
	WSDATA   cSOLDATA                  AS string
	WSDATA   cSOLICITA                 AS string
	WSDATA   cSTATUS                   AS string
	WSDATA   cTPSOLIC                  AS string
	WSDATA   cVISAO                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0500307_ACOMPASOL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0500307_ACOMPASOL
Return

WSMETHOD CLONE WSCLIENT W0500307_ACOMPASOL
	Local oClone := W0500307_ACOMPASOL():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCODSOLI             := ::cCODSOLI
	oClone:cDESCENTCUS          := ::cDESCENTCUS
	oClone:cDESFILRH3           := ::cDESFILRH3
	oClone:cDESSUBST            := ::cDESSUBST
	oClone:cFILRH3              := ::cFILRH3
	oClone:cMATRIC              := ::cMATRIC
	oClone:cSOLDATA             := ::cSOLDATA
	oClone:cSOLICITA            := ::cSOLICITA
	oClone:cSTATUS              := ::cSTATUS
	oClone:cTPSOLIC             := ::cTPSOLIC
	oClone:cVISAO               := ::cVISAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0500307_ACOMPASOL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODSOLI           :=  WSAdvValue( oResponse,"_CODSOLI","string",NIL,"Property cCODSOLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCENTCUS        :=  WSAdvValue( oResponse,"_DESCENTCUS","string",NIL,"Property cDESCENTCUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESFILRH3         :=  WSAdvValue( oResponse,"_DESFILRH3","string",NIL,"Property cDESFILRH3 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESSUBST          :=  WSAdvValue( oResponse,"_DESSUBST","string",NIL,"Property cDESSUBST as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILRH3            :=  WSAdvValue( oResponse,"_FILRH3","string",NIL,"Property cFILRH3 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATRIC            :=  WSAdvValue( oResponse,"_MATRIC","string",NIL,"Property cMATRIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSOLDATA           :=  WSAdvValue( oResponse,"_SOLDATA","string",NIL,"Property cSOLDATA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSOLICITA          :=  WSAdvValue( oResponse,"_SOLICITA","string",NIL,"Property cSOLICITA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTPSOLIC           :=  WSAdvValue( oResponse,"_TPSOLIC","string",NIL,"Property cTPSOLIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVISAO             :=  WSAdvValue( oResponse,"_VISAO","string",NIL,"Property cVISAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


