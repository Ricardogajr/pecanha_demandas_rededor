#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:91/ws/W0200301.apw?WSDL
Gerado em        05/23/17 08:28:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XRAMKNJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSW0200301
------------------------------------------------------------------------------- */

WSCLIENT WSW0200301

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ANASOLI
	WSMETHOD BUSCATRM
	WSMETHOD CRIAENTRE
	WSMETHOD INFINSTI
	WSMETHOD INFPA3
	WSMETHOD INFTRM
	WSMETHOD INSEREPA3
	WSMETHOD INSERESOLI
	WSMETHOD LISTASOLICITA
	WSMETHOD PARAMENTRE
	WSMETHOD PEGSUPER
	WSMETHOD PEGVIINV
	WSMETHOD RETINVFU
	WSMETHOD RETORNAPA3
	WSMETHOD SOLITRM
	WSMETHOD STATUTRMIN
	WSMETHOD VALSUPER
	WSMETHOD VISSUPER

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCODRH4                   AS string
	WSDATA   cFIRH3H4                  AS string
	WSDATA   oWSANASOLIRESULT          AS W0200301__RH4VAL
	WSDATA   lLPROC                    AS boolean
	WSDATA   oWSBUSCATRMRESULT         AS W0200301__TREINAMENTO
	WSDATA   cFILMATSUP                AS string
	WSDATA   cCODMATSUP                AS string
	WSDATA   cCALENDRA2                AS string
	WSDATA   cCURSORA2                 AS string
	WSDATA   cTURMARA2                 AS string
	WSDATA   oWSCRIAENTRERESULT        AS W0200301_PARTICIPANTE
	WSDATA   oWSINFINSTIRESULT         AS W0200301__INSTITU
	WSDATA   cCODSOL                   AS string
	WSDATA   oWSINFPA3RESULT           AS W0200301_INCENTIVO
	WSDATA   cCODTRM                   AS string
	WSDATA   cCODCUR                   AS string
	WSDATA   cFILTRM                   AS string
	WSDATA   oWSINFTRMRESULT           AS W0200301_TREINAMENTO
	WSDATA   cNOME                     AS string
	WSDATA   cMATRICULA                AS string
	WSDATA   cSETOR                    AS string
	WSDATA   cCCUSTO                   AS string
	WSDATA   cUNIDADE                  AS string
	WSDATA   cCARGO                    AS string
	WSDATA   cTELEFONE                 AS string
	WSDATA   cRAMAL                    AS string
	WSDATA   cEMAIL                    AS string
	WSDATA   cTPCURSO                  AS string
	WSDATA   cINSTITUICAO              AS string
	WSDATA   cNOMECURSO                AS string
	WSDATA   cDTINICIO                 AS string
	WSDATA   cDTTERMINO                AS string
	WSDATA   cDURACAO                  AS string
	WSDATA   cMENSALIDADE              AS string
	WSDATA   cINVANOVIG                AS string
	WSDATA   cVLTOTCURSO               AS string
	WSDATA   cBENCONCEDI               AS string
	WSDATA   cOBSERVACAO               AS string
	WSDATA   cSTATUS                   AS string
	WSDATA   cFILSOLICIIN              AS string
	WSDATA   cMATSOLICIIN              AS string
	WSDATA   cFILFUN                   AS string
	WSDATA   oWSINSEREPA3RESULT        AS W0200301__RETSL
	WSDATA   cMATRI                    AS string
	WSDATA   cNOMESOL                  AS string
	WSDATA   cCALENSOL                 AS string
	WSDATA   cCURSOSOL                 AS string
	WSDATA   cTURMASOL                 AS string
	WSDATA   cDTSOLIC                  AS string
	WSDATA   cOBSERV                   AS string
	WSDATA   oWSINSERESOLIRESULT       AS W0200301__RETSL
	WSDATA   cEMPLOYEEFIL              AS string
	WSDATA   oWSLISTASOLICITARESULT    AS W0200301_INCENTIVOITENS
	WSDATA   cASSUNTO                  AS string
	WSDATA   cBODY                     AS string
	WSDATA   cMATRICU                  AS string
	WSDATA   lPARAMENTRERESULT         AS boolean
	WSDATA   cSOLICI                   AS string
	WSDATA   cLOCALSOL                 AS string
	WSDATA   cOBS                      AS string
	WSDATA   oWSPEGSUPERRESULT         AS W0200301__RETSL
	WSDATA   cFILATU                   AS string
	WSDATA   cMATATU                   AS string
	WSDATA   oWSPEGVIINVRESULT         AS W0200301__SUPEMAIL
	WSDATA   cFILAPRIN                 AS string
	WSDATA   oWSRETINVFURESULT         AS W0200301_ACESSO
	WSDATA   oWSRETORNAPA3RESULT       AS W0200301__SOLICITACAO
	WSDATA   cCODMATRI                 AS string
	WSDATA   oWSSOLITRMRESULT          AS W0200301__TREISOLICI
	WSDATA   cCALENDARIO               AS string
	WSDATA   lSTATUTRMINRESULT         AS boolean
	WSDATA   lVALSUPERRESULT           AS boolean
	WSDATA   cRADEPART                 AS string
	WSDATA   cTIPO                     AS string
	WSDATA   oWSVISSUPERRESULT         AS W0200301__SUPERIOR

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSW0200301
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSW0200301
	::oWSANASOLIRESULT   := W0200301__RH4VAL():New()
	::oWSBUSCATRMRESULT  := W0200301__TREINAMENTO():New()
	::oWSCRIAENTRERESULT := W0200301_PARTICIPANTE():New()
	::oWSINFINSTIRESULT  := W0200301__INSTITU():New()
	::oWSINFPA3RESULT    := W0200301_INCENTIVO():New()
	::oWSINFTRMRESULT    := W0200301_TREINAMENTO():New()
	::oWSINSEREPA3RESULT := W0200301__RETSL():New()
	::oWSINSERESOLIRESULT := W0200301__RETSL():New()
	::oWSLISTASOLICITARESULT := W0200301_INCENTIVOITENS():New()
	::oWSPEGSUPERRESULT  := W0200301__RETSL():New()
	::oWSPEGVIINVRESULT  := W0200301__SUPEMAIL():New()
	::oWSRETINVFURESULT  := W0200301_ACESSO():New()
	::oWSRETORNAPA3RESULT := W0200301__SOLICITACAO():New()
	::oWSSOLITRMRESULT   := W0200301__TREISOLICI():New()
	::oWSVISSUPERRESULT  := W0200301__SUPERIOR():New()
Return

WSMETHOD RESET WSCLIENT WSW0200301
	::cCODRH4            := NIL 
	::cFIRH3H4           := NIL 
	::oWSANASOLIRESULT   := NIL 
	::lLPROC             := NIL 
	::oWSBUSCATRMRESULT  := NIL 
	::cFILMATSUP         := NIL 
	::cCODMATSUP         := NIL 
	::cCALENDRA2         := NIL 
	::cCURSORA2          := NIL 
	::cTURMARA2          := NIL 
	::oWSCRIAENTRERESULT := NIL 
	::oWSINFINSTIRESULT  := NIL 
	::cCODSOL            := NIL 
	::oWSINFPA3RESULT    := NIL 
	::cCODTRM            := NIL 
	::cCODCUR            := NIL 
	::cFILTRM            := NIL 
	::oWSINFTRMRESULT    := NIL 
	::cNOME              := NIL 
	::cMATRICULA         := NIL 
	::cSETOR             := NIL 
	::cCCUSTO            := NIL 
	::cUNIDADE           := NIL 
	::cCARGO             := NIL 
	::cTELEFONE          := NIL 
	::cRAMAL             := NIL 
	::cEMAIL             := NIL 
	::cTPCURSO           := NIL 
	::cINSTITUICAO       := NIL 
	::cNOMECURSO         := NIL 
	::cDTINICIO          := NIL 
	::cDTTERMINO         := NIL 
	::cDURACAO           := NIL 
	::cMENSALIDADE       := NIL 
	::cINVANOVIG         := NIL 
	::cVLTOTCURSO        := NIL 
	::cBENCONCEDI        := NIL 
	::cOBSERVACAO        := NIL 
	::cSTATUS            := NIL 
	::cFILSOLICIIN       := NIL 
	::cMATSOLICIIN       := NIL 
	::cFILFUN            := NIL 
	::oWSINSEREPA3RESULT := NIL 
	::cMATRI             := NIL 
	::cNOMESOL           := NIL 
	::cCALENSOL          := NIL 
	::cCURSOSOL          := NIL 
	::cTURMASOL          := NIL 
	::cDTSOLIC           := NIL 
	::cOBSERV            := NIL 
	::oWSINSERESOLIRESULT := NIL 
	::cEMPLOYEEFIL       := NIL 
	::oWSLISTASOLICITARESULT := NIL 
	::cASSUNTO           := NIL 
	::cBODY              := NIL 
	::cMATRICU           := NIL 
	::lPARAMENTRERESULT  := NIL 
	::cSOLICI            := NIL 
	::cLOCALSOL          := NIL 
	::cOBS               := NIL 
	::oWSPEGSUPERRESULT  := NIL 
	::cFILATU            := NIL 
	::cMATATU            := NIL 
	::oWSPEGVIINVRESULT  := NIL 
	::cFILAPRIN          := NIL 
	::oWSRETINVFURESULT  := NIL 
	::oWSRETORNAPA3RESULT := NIL 
	::cCODMATRI          := NIL 
	::oWSSOLITRMRESULT   := NIL 
	::cCALENDARIO        := NIL 
	::lSTATUTRMINRESULT  := NIL 
	::lVALSUPERRESULT    := NIL 
	::cRADEPART          := NIL 
	::cTIPO              := NIL 
	::oWSVISSUPERRESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSW0200301
Local oClone := WSW0200301():New()
	oClone:_URL          := ::_URL 
	oClone:cCODRH4       := ::cCODRH4
	oClone:cFIRH3H4      := ::cFIRH3H4
	oClone:oWSANASOLIRESULT :=  IIF(::oWSANASOLIRESULT = NIL , NIL ,::oWSANASOLIRESULT:Clone() )
	oClone:lLPROC        := ::lLPROC
	oClone:oWSBUSCATRMRESULT :=  IIF(::oWSBUSCATRMRESULT = NIL , NIL ,::oWSBUSCATRMRESULT:Clone() )
	oClone:cFILMATSUP    := ::cFILMATSUP
	oClone:cCODMATSUP    := ::cCODMATSUP
	oClone:cCALENDRA2    := ::cCALENDRA2
	oClone:cCURSORA2     := ::cCURSORA2
	oClone:cTURMARA2     := ::cTURMARA2
	oClone:oWSCRIAENTRERESULT :=  IIF(::oWSCRIAENTRERESULT = NIL , NIL ,::oWSCRIAENTRERESULT:Clone() )
	oClone:oWSINFINSTIRESULT :=  IIF(::oWSINFINSTIRESULT = NIL , NIL ,::oWSINFINSTIRESULT:Clone() )
	oClone:cCODSOL       := ::cCODSOL
	oClone:oWSINFPA3RESULT :=  IIF(::oWSINFPA3RESULT = NIL , NIL ,::oWSINFPA3RESULT:Clone() )
	oClone:cCODTRM       := ::cCODTRM
	oClone:cCODCUR       := ::cCODCUR
	oClone:cFILTRM       := ::cFILTRM
	oClone:oWSINFTRMRESULT :=  IIF(::oWSINFTRMRESULT = NIL , NIL ,::oWSINFTRMRESULT:Clone() )
	oClone:cNOME         := ::cNOME
	oClone:cMATRICULA    := ::cMATRICULA
	oClone:cSETOR        := ::cSETOR
	oClone:cCCUSTO       := ::cCCUSTO
	oClone:cUNIDADE      := ::cUNIDADE
	oClone:cCARGO        := ::cCARGO
	oClone:cTELEFONE     := ::cTELEFONE
	oClone:cRAMAL        := ::cRAMAL
	oClone:cEMAIL        := ::cEMAIL
	oClone:cTPCURSO      := ::cTPCURSO
	oClone:cINSTITUICAO  := ::cINSTITUICAO
	oClone:cNOMECURSO    := ::cNOMECURSO
	oClone:cDTINICIO     := ::cDTINICIO
	oClone:cDTTERMINO    := ::cDTTERMINO
	oClone:cDURACAO      := ::cDURACAO
	oClone:cMENSALIDADE  := ::cMENSALIDADE
	oClone:cINVANOVIG    := ::cINVANOVIG
	oClone:cVLTOTCURSO   := ::cVLTOTCURSO
	oClone:cBENCONCEDI   := ::cBENCONCEDI
	oClone:cOBSERVACAO   := ::cOBSERVACAO
	oClone:cSTATUS       := ::cSTATUS
	oClone:cFILSOLICIIN  := ::cFILSOLICIIN
	oClone:cMATSOLICIIN  := ::cMATSOLICIIN
	oClone:cFILFUN       := ::cFILFUN
	oClone:oWSINSEREPA3RESULT :=  IIF(::oWSINSEREPA3RESULT = NIL , NIL ,::oWSINSEREPA3RESULT:Clone() )
	oClone:cMATRI        := ::cMATRI
	oClone:cNOMESOL      := ::cNOMESOL
	oClone:cCALENSOL     := ::cCALENSOL
	oClone:cCURSOSOL     := ::cCURSOSOL
	oClone:cTURMASOL     := ::cTURMASOL
	oClone:cDTSOLIC      := ::cDTSOLIC
	oClone:cOBSERV       := ::cOBSERV
	oClone:oWSINSERESOLIRESULT :=  IIF(::oWSINSERESOLIRESULT = NIL , NIL ,::oWSINSERESOLIRESULT:Clone() )
	oClone:cEMPLOYEEFIL  := ::cEMPLOYEEFIL
	oClone:oWSLISTASOLICITARESULT :=  IIF(::oWSLISTASOLICITARESULT = NIL , NIL ,::oWSLISTASOLICITARESULT:Clone() )
	oClone:cASSUNTO      := ::cASSUNTO
	oClone:cBODY         := ::cBODY
	oClone:cMATRICU      := ::cMATRICU
	oClone:lPARAMENTRERESULT := ::lPARAMENTRERESULT
	oClone:cSOLICI       := ::cSOLICI
	oClone:cLOCALSOL     := ::cLOCALSOL
	oClone:cOBS          := ::cOBS
	oClone:oWSPEGSUPERRESULT :=  IIF(::oWSPEGSUPERRESULT = NIL , NIL ,::oWSPEGSUPERRESULT:Clone() )
	oClone:cFILATU       := ::cFILATU
	oClone:cMATATU       := ::cMATATU
	oClone:oWSPEGVIINVRESULT :=  IIF(::oWSPEGVIINVRESULT = NIL , NIL ,::oWSPEGVIINVRESULT:Clone() )
	oClone:cFILAPRIN     := ::cFILAPRIN
	oClone:oWSRETINVFURESULT :=  IIF(::oWSRETINVFURESULT = NIL , NIL ,::oWSRETINVFURESULT:Clone() )
	oClone:oWSRETORNAPA3RESULT :=  IIF(::oWSRETORNAPA3RESULT = NIL , NIL ,::oWSRETORNAPA3RESULT:Clone() )
	oClone:cCODMATRI     := ::cCODMATRI
	oClone:oWSSOLITRMRESULT :=  IIF(::oWSSOLITRMRESULT = NIL , NIL ,::oWSSOLITRMRESULT:Clone() )
	oClone:cCALENDARIO   := ::cCALENDARIO
	oClone:lSTATUTRMINRESULT := ::lSTATUTRMINRESULT
	oClone:lVALSUPERRESULT := ::lVALSUPERRESULT
	oClone:cRADEPART     := ::cRADEPART
	oClone:cTIPO         := ::cTIPO
	oClone:oWSVISSUPERRESULT :=  IIF(::oWSVISSUPERRESULT = NIL , NIL ,::oWSVISSUPERRESULT:Clone() )
Return oClone

// WSDL Method ANASOLI of Service WSW0200301

WSMETHOD ANASOLI WSSEND cCODRH4,cFIRH3H4 WSRECEIVE oWSANASOLIRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ANASOLI xmlns="http://localhost:91/">'
cSoap += WSSoapValue("CODRH4", ::cCODRH4, cCODRH4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FIRH3H4", ::cFIRH3H4, cFIRH3H4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ANASOLI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/ANASOLI",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSANASOLIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ANASOLIRESPONSE:_ANASOLIRESULT","_RH4VAL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BUSCATRM of Service WSW0200301

WSMETHOD BUSCATRM WSSEND lLPROC WSRECEIVE oWSBUSCATRMRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BUSCATRM xmlns="http://localhost:91/">'
cSoap += WSSoapValue("LPROC", ::lLPROC, lLPROC , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BUSCATRM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/BUSCATRM",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSBUSCATRMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BUSCATRMRESPONSE:_BUSCATRMRESULT","_TREINAMENTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CRIAENTRE of Service WSW0200301

WSMETHOD CRIAENTRE WSSEND cFILMATSUP,cCODMATSUP,cCALENDRA2,cCURSORA2,cTURMARA2 WSRECEIVE oWSCRIAENTRERESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRIAENTRE xmlns="http://localhost:91/">'
cSoap += WSSoapValue("FILMATSUP", ::cFILMATSUP, cFILMATSUP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODMATSUP", ::cCODMATSUP, cCODMATSUP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CALENDRA2", ::cCALENDRA2, cCALENDRA2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CURSORA2", ::cCURSORA2, cCURSORA2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TURMARA2", ::cTURMARA2, cTURMARA2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRIAENTRE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/CRIAENTRE",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSCRIAENTRERESULT:SoapRecv( WSAdvValue( oXmlRet,"_CRIAENTRERESPONSE:_CRIAENTRERESULT","PARTICIPANTE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFINSTI of Service WSW0200301

WSMETHOD INFINSTI WSSEND NULLPARAM WSRECEIVE oWSINFINSTIRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFINSTI xmlns="http://localhost:91/">'
cSoap += "</INFINSTI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INFINSTI",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSINFINSTIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFINSTIRESPONSE:_INFINSTIRESULT","_INSTITU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFPA3 of Service WSW0200301

WSMETHOD INFPA3 WSSEND cCODSOL,cFIRH3H4 WSRECEIVE oWSINFPA3RESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFPA3 xmlns="http://localhost:91/">'
cSoap += WSSoapValue("CODSOL", ::cCODSOL, cCODSOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FIRH3H4", ::cFIRH3H4, cFIRH3H4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFPA3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INFPA3",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSINFPA3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFPA3RESPONSE:_INFPA3RESULT","INCENTIVO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INFTRM of Service WSW0200301

WSMETHOD INFTRM WSSEND cCODTRM,cCODCUR,cFILTRM WSRECEIVE oWSINFTRMRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INFTRM xmlns="http://localhost:91/">'
cSoap += WSSoapValue("CODTRM", ::cCODTRM, cCODTRM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODCUR", ::cCODCUR, cCODCUR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTRM", ::cFILTRM, cFILTRM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INFTRM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INFTRM",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSINFTRMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INFTRMRESPONSE:_INFTRMRESULT","TREINAMENTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INSEREPA3 of Service WSW0200301

WSMETHOD INSEREPA3 WSSEND cNOME,cMATRICULA,cSETOR,cCCUSTO,cUNIDADE,cCARGO,cTELEFONE,cRAMAL,cEMAIL,cTPCURSO,cINSTITUICAO,cNOMECURSO,cDTINICIO,cDTTERMINO,cDURACAO,cMENSALIDADE,cINVANOVIG,cVLTOTCURSO,cBENCONCEDI,cOBSERVACAO,cSTATUS,cFILSOLICIIN,cMATSOLICIIN,cFILFUN WSRECEIVE oWSINSEREPA3RESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INSEREPA3 xmlns="http://localhost:91/">'
cSoap += WSSoapValue("NOME", ::cNOME, cNOME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SETOR", ::cSETOR, cSETOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCUSTO", ::cCCUSTO, cCCUSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UNIDADE", ::cUNIDADE, cUNIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CARGO", ::cCARGO, cCARGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TELEFONE", ::cTELEFONE, cTELEFONE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("RAMAL", ::cRAMAL, cRAMAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMAIL", ::cEMAIL, cEMAIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TPCURSO", ::cTPCURSO, cTPCURSO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("INSTITUICAO", ::cINSTITUICAO, cINSTITUICAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NOMECURSO", ::cNOMECURSO, cNOMECURSO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTINICIO", ::cDTINICIO, cDTINICIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTTERMINO", ::cDTTERMINO, cDTTERMINO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DURACAO", ::cDURACAO, cDURACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MENSALIDADE", ::cMENSALIDADE, cMENSALIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("INVANOVIG", ::cINVANOVIG, cINVANOVIG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLTOTCURSO", ::cVLTOTCURSO, cVLTOTCURSO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("BENCONCEDI", ::cBENCONCEDI, cBENCONCEDI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OBSERVACAO", ::cOBSERVACAO, cOBSERVACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("STATUS", ::cSTATUS, cSTATUS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILSOLICIIN", ::cFILSOLICIIN, cFILSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATSOLICIIN", ::cMATSOLICIIN, cMATSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILFUN", ::cFILFUN, cFILFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INSEREPA3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INSEREPA3",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSINSEREPA3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_INSEREPA3RESPONSE:_INSEREPA3RESULT","_RETSL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INSERESOLI of Service WSW0200301

WSMETHOD INSERESOLI WSSEND cMATRI,cNOMESOL,cCALENSOL,cCURSOSOL,cTURMASOL,cDTSOLIC,cOBSERV,cFILSOLICIIN,cMATSOLICIIN,cFILFUN WSRECEIVE oWSINSERESOLIRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INSERESOLI xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRI", ::cMATRI, cMATRI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NOMESOL", ::cNOMESOL, cNOMESOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CALENSOL", ::cCALENSOL, cCALENSOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CURSOSOL", ::cCURSOSOL, cCURSOSOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TURMASOL", ::cTURMASOL, cTURMASOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DTSOLIC", ::cDTSOLIC, cDTSOLIC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OBSERV", ::cOBSERV, cOBSERV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILSOLICIIN", ::cFILSOLICIIN, cFILSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATSOLICIIN", ::cMATSOLICIIN, cMATSOLICIIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILFUN", ::cFILFUN, cFILFUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INSERESOLI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/INSERESOLI",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSINSERESOLIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_INSERESOLIRESPONSE:_INSERESOLIRESULT","_RETSL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LISTASOLICITA of Service WSW0200301

WSMETHOD LISTASOLICITA WSSEND cEMPLOYEEFIL WSRECEIVE oWSLISTASOLICITARESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LISTASOLICITA xmlns="http://localhost:91/">'
cSoap += WSSoapValue("EMPLOYEEFIL", ::cEMPLOYEEFIL, cEMPLOYEEFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LISTASOLICITA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/LISTASOLICITA",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSLISTASOLICITARESULT:SoapRecv( WSAdvValue( oXmlRet,"_LISTASOLICITARESPONSE:_LISTASOLICITARESULT","INCENTIVOITENS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PARAMENTRE of Service WSW0200301

WSMETHOD PARAMENTRE WSSEND cASSUNTO,cBODY,cMATRICU WSRECEIVE lPARAMENTRERESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PARAMENTRE xmlns="http://localhost:91/">'
cSoap += WSSoapValue("ASSUNTO", ::cASSUNTO, cASSUNTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("BODY", ::cBODY, cBODY , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICU", ::cMATRICU, cMATRICU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PARAMENTRE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/PARAMENTRE",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::lPARAMENTRERESULT  :=  WSAdvValue( oXmlRet,"_PARAMENTRERESPONSE:_PARAMENTRERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PEGSUPER of Service WSW0200301

WSMETHOD PEGSUPER WSSEND cMATRICULA,cSOLICI,cLOCALSOL,cFIRH3H4,cOBS WSRECEIVE oWSPEGSUPERRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PEGSUPER xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SOLICI", ::cSOLICI, cSOLICI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOCALSOL", ::cLOCALSOL, cLOCALSOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FIRH3H4", ::cFIRH3H4, cFIRH3H4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OBS", ::cOBS, cOBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PEGSUPER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/PEGSUPER",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSPEGSUPERRESULT:SoapRecv( WSAdvValue( oXmlRet,"_PEGSUPERRESPONSE:_PEGSUPERRESULT","_RETSL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PEGVIINV of Service WSW0200301

WSMETHOD PEGVIINV WSSEND cMATRICULA,cSOLICI,cLOCALSOL,cFIRH3H4,cOBS,cFILATU,cMATATU WSRECEIVE oWSPEGVIINVRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PEGVIINV xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SOLICI", ::cSOLICI, cSOLICI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOCALSOL", ::cLOCALSOL, cLOCALSOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FIRH3H4", ::cFIRH3H4, cFIRH3H4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OBS", ::cOBS, cOBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILATU", ::cFILATU, cFILATU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATATU", ::cMATATU, cMATATU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PEGVIINV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/PEGVIINV",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSPEGVIINVRESULT:SoapRecv( WSAdvValue( oXmlRet,"_PEGVIINVRESPONSE:_PEGVIINVRESULT","_SUPEMAIL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETINVFU of Service WSW0200301

WSMETHOD RETINVFU WSSEND cMATRICULA,cFILAPRIN WSRECEIVE oWSRETINVFURESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETINVFU xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILAPRIN", ::cFILAPRIN, cFILAPRIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETINVFU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/RETINVFU",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSRETINVFURESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETINVFURESPONSE:_RETINVFURESULT","ACESSO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETORNAPA3 of Service WSW0200301

WSMETHOD RETORNAPA3 WSSEND cMATRICU WSRECEIVE oWSRETORNAPA3RESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETORNAPA3 xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICU", ::cMATRICU, cMATRICU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETORNAPA3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/RETORNAPA3",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSRETORNAPA3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETORNAPA3RESPONSE:_RETORNAPA3RESULT","_SOLICITACAO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SOLITRM of Service WSW0200301

WSMETHOD SOLITRM WSSEND cCODMATRI WSRECEIVE oWSSOLITRMRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOLITRM xmlns="http://localhost:91/">'
cSoap += WSSoapValue("CODMATRI", ::cCODMATRI, cCODMATRI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SOLITRM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/SOLITRM",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSSOLITRMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SOLITRMRESPONSE:_SOLITRMRESULT","_TREISOLICI",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method STATUTRMIN of Service WSW0200301

WSMETHOD STATUTRMIN WSSEND cMATRICULA,cCALENDARIO WSRECEIVE lSTATUTRMINRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<STATUTRMIN xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CALENDARIO", ::cCALENDARIO, cCALENDARIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</STATUTRMIN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/STATUTRMIN",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::lSTATUTRMINRESULT  :=  WSAdvValue( oXmlRet,"_STATUTRMINRESPONSE:_STATUTRMINRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VALSUPER of Service WSW0200301

WSMETHOD VALSUPER WSSEND cMATRICULA,cSOLICI,cSTATUS,cLOCALSOL WSRECEIVE lVALSUPERRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VALSUPER xmlns="http://localhost:91/">'
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SOLICI", ::cSOLICI, cSOLICI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("STATUS", ::cSTATUS, cSTATUS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOCALSOL", ::cLOCALSOL, cLOCALSOL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VALSUPER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/VALSUPER",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::lVALSUPERRESULT    :=  WSAdvValue( oXmlRet,"_VALSUPERRESPONSE:_VALSUPERRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VISSUPER of Service WSW0200301

WSMETHOD VISSUPER WSSEND cRADEPART,cMATRICULA,cTIPO WSRECEIVE oWSVISSUPERRESULT WSCLIENT WSW0200301
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VISSUPER xmlns="http://localhost:91/">'
cSoap += WSSoapValue("RADEPART", ::cRADEPART, cRADEPART , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VISSUPER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:91/VISSUPER",; 
	"DOCUMENT","http://localhost:91/",,"1.031217",; 
	"http://localhost:91/ws/W0200301.apw")

::Init()
::oWSVISSUPERRESULT:SoapRecv( WSAdvValue( oXmlRet,"_VISSUPERRESPONSE:_VISSUPERRESULT","_SUPERIOR",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure _RH4VAL

WSSTRUCT W0200301__RH4VAL
	WSDATA   cOBS                      AS string
	WSDATA   cRA3CALEND                AS string
	WSDATA   cRA3CURSO                 AS string
	WSDATA   cRA3MAT                   AS string
	WSDATA   cTMPNOME                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__RH4VAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__RH4VAL
Return

WSMETHOD CLONE WSCLIENT W0200301__RH4VAL
	Local oClone := W0200301__RH4VAL():NEW()
	oClone:cOBS                 := ::cOBS
	oClone:cRA3CALEND           := ::cRA3CALEND
	oClone:cRA3CURSO            := ::cRA3CURSO
	oClone:cRA3MAT              := ::cRA3MAT
	oClone:cTMPNOME             := ::cTMPNOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__RH4VAL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cOBS               :=  WSAdvValue( oResponse,"_OBS","string",NIL,"Property cOBS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRA3CALEND         :=  WSAdvValue( oResponse,"_RA3CALEND","string",NIL,"Property cRA3CALEND as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRA3CURSO          :=  WSAdvValue( oResponse,"_RA3CURSO","string",NIL,"Property cRA3CURSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRA3MAT            :=  WSAdvValue( oResponse,"_RA3MAT","string",NIL,"Property cRA3MAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTMPNOME           :=  WSAdvValue( oResponse,"_TMPNOME","string",NIL,"Property cTMPNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _TREINAMENTO

WSSTRUCT W0200301__TREINAMENTO
	WSDATA   oWSTRM                    AS W0200301_ARRAYOFTREINAMENTO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__TREINAMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__TREINAMENTO
Return

WSMETHOD CLONE WSCLIENT W0200301__TREINAMENTO
	Local oClone := W0200301__TREINAMENTO():NEW()
	oClone:oWSTRM               := IIF(::oWSTRM = NIL , NIL , ::oWSTRM:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__TREINAMENTO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_TRM","ARRAYOFTREINAMENTO",NIL,"Property oWSTRM as s0:ARRAYOFTREINAMENTO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSTRM := W0200301_ARRAYOFTREINAMENTO():New()
		::oWSTRM:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure PARTICIPANTE

WSSTRUCT W0200301_PARTICIPANTE
	WSDATA   cEMAIL                    AS string
	WSDATA   cNOME                     AS string
	WSDATA   cTREINA                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_PARTICIPANTE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_PARTICIPANTE
Return

WSMETHOD CLONE WSCLIENT W0200301_PARTICIPANTE
	Local oClone := W0200301_PARTICIPANTE():NEW()
	oClone:cEMAIL               := ::cEMAIL
	oClone:cNOME                := ::cNOME
	oClone:cTREINA              := ::cTREINA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_PARTICIPANTE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,"Property cEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTREINA            :=  WSAdvValue( oResponse,"_TREINA","string",NIL,"Property cTREINA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _INSTITU

WSSTRUCT W0200301__INSTITU
	WSDATA   oWSREGISTRO               AS W0200301_ARRAYOFINSTITU
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__INSTITU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__INSTITU
Return

WSMETHOD CLONE WSCLIENT W0200301__INSTITU
	Local oClone := W0200301__INSTITU():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__INSTITU
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFINSTITU",NIL,"Property oWSREGISTRO as s0:ARRAYOFINSTITU on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0200301_ARRAYOFINSTITU():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure INCENTIVO

WSSTRUCT W0200301_INCENTIVO
	WSDATA   cBENEFCONCEDIDO           AS string
	WSDATA   cCONTACT                  AS string
	WSDATA   cCURSENAME                AS string
	WSDATA   cDURACAO                  AS string
	WSDATA   cENDDATE                  AS string
	WSDATA   cINSTALLMENTAMOUNT        AS string
	WSDATA   cINSTITUTENAME            AS string
	WSDATA   cMONTHLYPAYMENT           AS string
	WSDATA   cOBSERVATION              AS string
	WSDATA   cPHONE                    AS string
	WSDATA   cRAMAL                    AS string
	WSDATA   cSTARTDATE                AS string
	WSDATA   cTIPO                     AS string
	WSDATA   cVLINVESANOVIG            AS string
	WSDATA   cVLTOTCURSO               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_INCENTIVO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_INCENTIVO
Return

WSMETHOD CLONE WSCLIENT W0200301_INCENTIVO
	Local oClone := W0200301_INCENTIVO():NEW()
	oClone:cBENEFCONCEDIDO      := ::cBENEFCONCEDIDO
	oClone:cCONTACT             := ::cCONTACT
	oClone:cCURSENAME           := ::cCURSENAME
	oClone:cDURACAO             := ::cDURACAO
	oClone:cENDDATE             := ::cENDDATE
	oClone:cINSTALLMENTAMOUNT   := ::cINSTALLMENTAMOUNT
	oClone:cINSTITUTENAME       := ::cINSTITUTENAME
	oClone:cMONTHLYPAYMENT      := ::cMONTHLYPAYMENT
	oClone:cOBSERVATION         := ::cOBSERVATION
	oClone:cPHONE               := ::cPHONE
	oClone:cRAMAL               := ::cRAMAL
	oClone:cSTARTDATE           := ::cSTARTDATE
	oClone:cTIPO                := ::cTIPO
	oClone:cVLINVESANOVIG       := ::cVLINVESANOVIG
	oClone:cVLTOTCURSO          := ::cVLTOTCURSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_INCENTIVO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBENEFCONCEDIDO    :=  WSAdvValue( oResponse,"_BENEFCONCEDIDO","string",NIL,"Property cBENEFCONCEDIDO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCONTACT           :=  WSAdvValue( oResponse,"_CONTACT","string",NIL,"Property cCONTACT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCURSENAME         :=  WSAdvValue( oResponse,"_CURSENAME","string",NIL,"Property cCURSENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDURACAO           :=  WSAdvValue( oResponse,"_DURACAO","string",NIL,"Property cDURACAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cENDDATE           :=  WSAdvValue( oResponse,"_ENDDATE","string",NIL,"Property cENDDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTALLMENTAMOUNT :=  WSAdvValue( oResponse,"_INSTALLMENTAMOUNT","string",NIL,"Property cINSTALLMENTAMOUNT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTITUTENAME     :=  WSAdvValue( oResponse,"_INSTITUTENAME","string",NIL,"Property cINSTITUTENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMONTHLYPAYMENT    :=  WSAdvValue( oResponse,"_MONTHLYPAYMENT","string",NIL,"Property cMONTHLYPAYMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBSERVATION       :=  WSAdvValue( oResponse,"_OBSERVATION","string",NIL,"Property cOBSERVATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPHONE             :=  WSAdvValue( oResponse,"_PHONE","string",NIL,"Property cPHONE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAMAL             :=  WSAdvValue( oResponse,"_RAMAL","string",NIL,"Property cRAMAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTARTDATE         :=  WSAdvValue( oResponse,"_STARTDATE","string",NIL,"Property cSTARTDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVLINVESANOVIG     :=  WSAdvValue( oResponse,"_VLINVESANOVIG","string",NIL,"Property cVLINVESANOVIG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVLTOTCURSO        :=  WSAdvValue( oResponse,"_VLTOTCURSO","string",NIL,"Property cVLTOTCURSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TREINAMENTO

WSSTRUCT W0200301_TREINAMENTO
	WSDATA   cCALENDARIO               AS string
	WSDATA   cCURSO                    AS string
	WSDATA   cFILTRM                   AS string
	WSDATA   cHORARIO                  AS string
	WSDATA   cINICIO                   AS string
	WSDATA   cRESERVADO                AS string
	WSDATA   cTERMINO                  AS string
	WSDATA   cTREINAMENTO              AS string
	WSDATA   cTURMA                    AS string
	WSDATA   cVAGAS                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_TREINAMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_TREINAMENTO
Return

WSMETHOD CLONE WSCLIENT W0200301_TREINAMENTO
	Local oClone := W0200301_TREINAMENTO():NEW()
	oClone:cCALENDARIO          := ::cCALENDARIO
	oClone:cCURSO               := ::cCURSO
	oClone:cFILTRM              := ::cFILTRM
	oClone:cHORARIO             := ::cHORARIO
	oClone:cINICIO              := ::cINICIO
	oClone:cRESERVADO           := ::cRESERVADO
	oClone:cTERMINO             := ::cTERMINO
	oClone:cTREINAMENTO         := ::cTREINAMENTO
	oClone:cTURMA               := ::cTURMA
	oClone:cVAGAS               := ::cVAGAS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_TREINAMENTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCALENDARIO        :=  WSAdvValue( oResponse,"_CALENDARIO","string",NIL,"Property cCALENDARIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCURSO             :=  WSAdvValue( oResponse,"_CURSO","string",NIL,"Property cCURSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILTRM            :=  WSAdvValue( oResponse,"_FILTRM","string",NIL,"Property cFILTRM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHORARIO           :=  WSAdvValue( oResponse,"_HORARIO","string",NIL,"Property cHORARIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINICIO            :=  WSAdvValue( oResponse,"_INICIO","string",NIL,"Property cINICIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRESERVADO         :=  WSAdvValue( oResponse,"_RESERVADO","string",NIL,"Property cRESERVADO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTERMINO           :=  WSAdvValue( oResponse,"_TERMINO","string",NIL,"Property cTERMINO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTREINAMENTO       :=  WSAdvValue( oResponse,"_TREINAMENTO","string",NIL,"Property cTREINAMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTURMA             :=  WSAdvValue( oResponse,"_TURMA","string",NIL,"Property cTURMA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVAGAS             :=  WSAdvValue( oResponse,"_VAGAS","string",NIL,"Property cVAGAS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _RETSL

WSSTRUCT W0200301__RETSL
	WSDATA   cCDAPROV                  AS string
	WSDATA   cFLAPROV                  AS string
	WSDATA   lLRETORN                  AS boolean
	WSDATA   cMSGAVSO                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__RETSL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__RETSL
Return

WSMETHOD CLONE WSCLIENT W0200301__RETSL
	Local oClone := W0200301__RETSL():NEW()
	oClone:cCDAPROV             := ::cCDAPROV
	oClone:cFLAPROV             := ::cFLAPROV
	oClone:lLRETORN             := ::lLRETORN
	oClone:cMSGAVSO             := ::cMSGAVSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__RETSL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDAPROV           :=  WSAdvValue( oResponse,"_CDAPROV","string",NIL,"Property cCDAPROV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFLAPROV           :=  WSAdvValue( oResponse,"_FLAPROV","string",NIL,"Property cFLAPROV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lLRETORN           :=  WSAdvValue( oResponse,"_LRETORN","boolean",NIL,"Property lLRETORN as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cMSGAVSO           :=  WSAdvValue( oResponse,"_MSGAVSO","string",NIL,"Property cMSGAVSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure INCENTIVOITENS

WSSTRUCT W0200301_INCENTIVOITENS
	WSDATA   cBENEFCONCEDIDO           AS string
	WSDATA   cCONTACT                  AS string
	WSDATA   cCURSENAME                AS string
	WSDATA   cDURACAO                  AS string
	WSDATA   cENDDATE                  AS string
	WSDATA   cINSTALLMENTAMOUNT        AS string
	WSDATA   cINSTITUTENAME            AS string
	WSDATA   oWSITENS                  AS W0200301_ARRAYOFITENSCURSO
	WSDATA   cMONTHLYPAYMENT           AS string
	WSDATA   cOBSERVATION              AS string
	WSDATA   cPHONE                    AS string
	WSDATA   cRAMAL                    AS string
	WSDATA   cSTARTDATE                AS string
	WSDATA   cVLINVESANOVIG            AS string
	WSDATA   cVLTOTCURSO               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_INCENTIVOITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_INCENTIVOITENS
Return

WSMETHOD CLONE WSCLIENT W0200301_INCENTIVOITENS
	Local oClone := W0200301_INCENTIVOITENS():NEW()
	oClone:cBENEFCONCEDIDO      := ::cBENEFCONCEDIDO
	oClone:cCONTACT             := ::cCONTACT
	oClone:cCURSENAME           := ::cCURSENAME
	oClone:cDURACAO             := ::cDURACAO
	oClone:cENDDATE             := ::cENDDATE
	oClone:cINSTALLMENTAMOUNT   := ::cINSTALLMENTAMOUNT
	oClone:cINSTITUTENAME       := ::cINSTITUTENAME
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
	oClone:cMONTHLYPAYMENT      := ::cMONTHLYPAYMENT
	oClone:cOBSERVATION         := ::cOBSERVATION
	oClone:cPHONE               := ::cPHONE
	oClone:cRAMAL               := ::cRAMAL
	oClone:cSTARTDATE           := ::cSTARTDATE
	oClone:cVLINVESANOVIG       := ::cVLINVESANOVIG
	oClone:cVLTOTCURSO          := ::cVLTOTCURSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_INCENTIVOITENS
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBENEFCONCEDIDO    :=  WSAdvValue( oResponse,"_BENEFCONCEDIDO","string",NIL,"Property cBENEFCONCEDIDO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCONTACT           :=  WSAdvValue( oResponse,"_CONTACT","string",NIL,"Property cCONTACT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCURSENAME         :=  WSAdvValue( oResponse,"_CURSENAME","string",NIL,"Property cCURSENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDURACAO           :=  WSAdvValue( oResponse,"_DURACAO","string",NIL,"Property cDURACAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cENDDATE           :=  WSAdvValue( oResponse,"_ENDDATE","string",NIL,"Property cENDDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTALLMENTAMOUNT :=  WSAdvValue( oResponse,"_INSTALLMENTAMOUNT","string",NIL,"Property cINSTALLMENTAMOUNT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTITUTENAME     :=  WSAdvValue( oResponse,"_INSTITUTENAME","string",NIL,"Property cINSTITUTENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFITENSCURSO",NIL,"Property oWSITENS as s0:ARRAYOFITENSCURSO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSITENS := W0200301_ARRAYOFITENSCURSO():New()
		::oWSITENS:SoapRecv(oNode8)
	EndIf
	::cMONTHLYPAYMENT    :=  WSAdvValue( oResponse,"_MONTHLYPAYMENT","string",NIL,"Property cMONTHLYPAYMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBSERVATION       :=  WSAdvValue( oResponse,"_OBSERVATION","string",NIL,"Property cOBSERVATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPHONE             :=  WSAdvValue( oResponse,"_PHONE","string",NIL,"Property cPHONE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAMAL             :=  WSAdvValue( oResponse,"_RAMAL","string",NIL,"Property cRAMAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTARTDATE         :=  WSAdvValue( oResponse,"_STARTDATE","string",NIL,"Property cSTARTDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVLINVESANOVIG     :=  WSAdvValue( oResponse,"_VLINVESANOVIG","string",NIL,"Property cVLINVESANOVIG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVLTOTCURSO        :=  WSAdvValue( oResponse,"_VLTOTCURSO","string",NIL,"Property cVLTOTCURSO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _SUPEMAIL

WSSTRUCT W0200301__SUPEMAIL
	WSDATA   oWSREGISTRO               AS W0200301_ARRAYOFSUPEMAIL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__SUPEMAIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__SUPEMAIL
Return

WSMETHOD CLONE WSCLIENT W0200301__SUPEMAIL
	Local oClone := W0200301__SUPEMAIL():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__SUPEMAIL
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFSUPEMAIL",NIL,"Property oWSREGISTRO as s0:ARRAYOFSUPEMAIL on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0200301_ARRAYOFSUPEMAIL():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ACESSO

WSSTRUCT W0200301_ACESSO
	WSDATA   cADMISSAO                 AS string OPTIONAL
	WSDATA   cCARGO                    AS string OPTIONAL
	WSDATA   cCENCUSTO                 AS string OPTIONAL
	WSDATA   cDEPARTAME                AS string OPTIONAL
	WSDATA   cMATRICULA                AS string OPTIONAL
	WSDATA   cNMCARGO                  AS string OPTIONAL
	WSDATA   cNMCENTRO                 AS string OPTIONAL
	WSDATA   cNMDEPART                 AS string OPTIONAL
	WSDATA   cNOME                     AS string OPTIONAL
	WSDATA   cNOMEFIL                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ACESSO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ACESSO
Return

WSMETHOD CLONE WSCLIENT W0200301_ACESSO
	Local oClone := W0200301_ACESSO():NEW()
	oClone:cADMISSAO            := ::cADMISSAO
	oClone:cCARGO               := ::cCARGO
	oClone:cCENCUSTO            := ::cCENCUSTO
	oClone:cDEPARTAME           := ::cDEPARTAME
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cNMCARGO             := ::cNMCARGO
	oClone:cNMCENTRO            := ::cNMCENTRO
	oClone:cNMDEPART            := ::cNMDEPART
	oClone:cNOME                := ::cNOME
	oClone:cNOMEFIL             := ::cNOMEFIL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ACESSO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cADMISSAO          :=  WSAdvValue( oResponse,"_ADMISSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCARGO             :=  WSAdvValue( oResponse,"_CARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCENCUSTO          :=  WSAdvValue( oResponse,"_CENCUSTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDEPARTAME         :=  WSAdvValue( oResponse,"_DEPARTAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMATRICULA         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNMCARGO           :=  WSAdvValue( oResponse,"_NMCARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNMCENTRO          :=  WSAdvValue( oResponse,"_NMCENTRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNMDEPART          :=  WSAdvValue( oResponse,"_NMDEPART","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOMEFIL           :=  WSAdvValue( oResponse,"_NOMEFIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure _SOLICITACAO

WSSTRUCT W0200301__SOLICITACAO
	WSDATA   oWSREGISTRO               AS W0200301_ARRAYOFSOLICITACAO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__SOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__SOLICITACAO
Return

WSMETHOD CLONE WSCLIENT W0200301__SOLICITACAO
	Local oClone := W0200301__SOLICITACAO():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__SOLICITACAO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFSOLICITACAO",NIL,"Property oWSREGISTRO as s0:ARRAYOFSOLICITACAO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0200301_ARRAYOFSOLICITACAO():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure _TREISOLICI

WSSTRUCT W0200301__TREISOLICI
	WSDATA   oWSTRMSL                  AS W0200301_ARRAYOFTREISOLICI
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__TREISOLICI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__TREISOLICI
Return

WSMETHOD CLONE WSCLIENT W0200301__TREISOLICI
	Local oClone := W0200301__TREISOLICI():NEW()
	oClone:oWSTRMSL             := IIF(::oWSTRMSL = NIL , NIL , ::oWSTRMSL:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__TREISOLICI
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_TRMSL","ARRAYOFTREISOLICI",NIL,"Property oWSTRMSL as s0:ARRAYOFTREISOLICI on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSTRMSL := W0200301_ARRAYOFTREISOLICI():New()
		::oWSTRMSL:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure _SUPERIOR

WSSTRUCT W0200301__SUPERIOR
	WSDATA   oWSREGISTRO               AS W0200301_ARRAYOFSUPERIOR
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301__SUPERIOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301__SUPERIOR
Return

WSMETHOD CLONE WSCLIENT W0200301__SUPERIOR
	Local oClone := W0200301__SUPERIOR():NEW()
	oClone:oWSREGISTRO          := IIF(::oWSREGISTRO = NIL , NIL , ::oWSREGISTRO:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301__SUPERIOR
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_REGISTRO","ARRAYOFSUPERIOR",NIL,"Property oWSREGISTRO as s0:ARRAYOFSUPERIOR on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSREGISTRO := W0200301_ARRAYOFSUPERIOR():New()
		::oWSREGISTRO:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFTREINAMENTO

WSSTRUCT W0200301_ARRAYOFTREINAMENTO
	WSDATA   oWSTREINAMENTO            AS W0200301_TREINAMENTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFTREINAMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFTREINAMENTO
	::oWSTREINAMENTO       := {} // Array Of  W0200301_TREINAMENTO():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFTREINAMENTO
	Local oClone := W0200301_ARRAYOFTREINAMENTO():NEW()
	oClone:oWSTREINAMENTO := NIL
	If ::oWSTREINAMENTO <> NIL 
		oClone:oWSTREINAMENTO := {}
		aEval( ::oWSTREINAMENTO , { |x| aadd( oClone:oWSTREINAMENTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFTREINAMENTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TREINAMENTO","TREINAMENTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTREINAMENTO , W0200301_TREINAMENTO():New() )
			::oWSTREINAMENTO[len(::oWSTREINAMENTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFINSTITU

WSSTRUCT W0200301_ARRAYOFINSTITU
	WSDATA   oWSINSTITU                AS W0200301_INSTITU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFINSTITU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFINSTITU
	::oWSINSTITU           := {} // Array Of  W0200301_INSTITU():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFINSTITU
	Local oClone := W0200301_ARRAYOFINSTITU():NEW()
	oClone:oWSINSTITU := NIL
	If ::oWSINSTITU <> NIL 
		oClone:oWSINSTITU := {}
		aEval( ::oWSINSTITU , { |x| aadd( oClone:oWSINSTITU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFINSTITU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INSTITU","INSTITU",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSINSTITU , W0200301_INSTITU():New() )
			::oWSINSTITU[len(::oWSINSTITU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFITENSCURSO

WSSTRUCT W0200301_ARRAYOFITENSCURSO
	WSDATA   oWSITENSCURSO             AS W0200301_ITENSCURSO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFITENSCURSO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFITENSCURSO
	::oWSITENSCURSO        := {} // Array Of  W0200301_ITENSCURSO():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFITENSCURSO
	Local oClone := W0200301_ARRAYOFITENSCURSO():NEW()
	oClone:oWSITENSCURSO := NIL
	If ::oWSITENSCURSO <> NIL 
		oClone:oWSITENSCURSO := {}
		aEval( ::oWSITENSCURSO , { |x| aadd( oClone:oWSITENSCURSO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFITENSCURSO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITENSCURSO","ITENSCURSO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITENSCURSO , W0200301_ITENSCURSO():New() )
			::oWSITENSCURSO[len(::oWSITENSCURSO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSUPEMAIL

WSSTRUCT W0200301_ARRAYOFSUPEMAIL
	WSDATA   oWSSUPEMAIL               AS W0200301_SUPEMAIL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFSUPEMAIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFSUPEMAIL
	::oWSSUPEMAIL          := {} // Array Of  W0200301_SUPEMAIL():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFSUPEMAIL
	Local oClone := W0200301_ARRAYOFSUPEMAIL():NEW()
	oClone:oWSSUPEMAIL := NIL
	If ::oWSSUPEMAIL <> NIL 
		oClone:oWSSUPEMAIL := {}
		aEval( ::oWSSUPEMAIL , { |x| aadd( oClone:oWSSUPEMAIL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFSUPEMAIL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SUPEMAIL","SUPEMAIL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSUPEMAIL , W0200301_SUPEMAIL():New() )
			::oWSSUPEMAIL[len(::oWSSUPEMAIL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSOLICITACAO

WSSTRUCT W0200301_ARRAYOFSOLICITACAO
	WSDATA   oWSSOLICITACAO            AS W0200301_SOLICITACAO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFSOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFSOLICITACAO
	::oWSSOLICITACAO       := {} // Array Of  W0200301_SOLICITACAO():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFSOLICITACAO
	Local oClone := W0200301_ARRAYOFSOLICITACAO():NEW()
	oClone:oWSSOLICITACAO := NIL
	If ::oWSSOLICITACAO <> NIL 
		oClone:oWSSOLICITACAO := {}
		aEval( ::oWSSOLICITACAO , { |x| aadd( oClone:oWSSOLICITACAO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFSOLICITACAO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SOLICITACAO","SOLICITACAO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSOLICITACAO , W0200301_SOLICITACAO():New() )
			::oWSSOLICITACAO[len(::oWSSOLICITACAO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTREISOLICI

WSSTRUCT W0200301_ARRAYOFTREISOLICI
	WSDATA   oWSTREISOLICI             AS W0200301_TREISOLICI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFTREISOLICI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFTREISOLICI
	::oWSTREISOLICI        := {} // Array Of  W0200301_TREISOLICI():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFTREISOLICI
	Local oClone := W0200301_ARRAYOFTREISOLICI():NEW()
	oClone:oWSTREISOLICI := NIL
	If ::oWSTREISOLICI <> NIL 
		oClone:oWSTREISOLICI := {}
		aEval( ::oWSTREISOLICI , { |x| aadd( oClone:oWSTREISOLICI , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFTREISOLICI
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TREISOLICI","TREISOLICI",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTREISOLICI , W0200301_TREISOLICI():New() )
			::oWSTREISOLICI[len(::oWSTREISOLICI)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSUPERIOR

WSSTRUCT W0200301_ARRAYOFSUPERIOR
	WSDATA   oWSSUPERIOR               AS W0200301_SUPERIOR OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ARRAYOFSUPERIOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ARRAYOFSUPERIOR
	::oWSSUPERIOR          := {} // Array Of  W0200301_SUPERIOR():New()
Return

WSMETHOD CLONE WSCLIENT W0200301_ARRAYOFSUPERIOR
	Local oClone := W0200301_ARRAYOFSUPERIOR():NEW()
	oClone:oWSSUPERIOR := NIL
	If ::oWSSUPERIOR <> NIL 
		oClone:oWSSUPERIOR := {}
		aEval( ::oWSSUPERIOR , { |x| aadd( oClone:oWSSUPERIOR , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ARRAYOFSUPERIOR
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SUPERIOR","SUPERIOR",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSUPERIOR , W0200301_SUPERIOR():New() )
			::oWSSUPERIOR[len(::oWSSUPERIOR)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure INSTITU

WSSTRUCT W0200301_INSTITU
	WSDATA   cRA0DESC                  AS string
	WSDATA   cRA0ENTIDA                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_INSTITU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_INSTITU
Return

WSMETHOD CLONE WSCLIENT W0200301_INSTITU
	Local oClone := W0200301_INSTITU():NEW()
	oClone:cRA0DESC             := ::cRA0DESC
	oClone:cRA0ENTIDA           := ::cRA0ENTIDA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_INSTITU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRA0DESC           :=  WSAdvValue( oResponse,"_RA0DESC","string",NIL,"Property cRA0DESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRA0ENTIDA         :=  WSAdvValue( oResponse,"_RA0ENTIDA","string",NIL,"Property cRA0ENTIDA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ITENSCURSO

WSSTRUCT W0200301_ITENSCURSO
	WSDATA   cBENEFITCODE              AS string
	WSDATA   cBENEFITNAME              AS string
	WSDATA   nSALARYTO                 AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_ITENSCURSO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_ITENSCURSO
Return

WSMETHOD CLONE WSCLIENT W0200301_ITENSCURSO
	Local oClone := W0200301_ITENSCURSO():NEW()
	oClone:cBENEFITCODE         := ::cBENEFITCODE
	oClone:cBENEFITNAME         := ::cBENEFITNAME
	oClone:nSALARYTO            := ::nSALARYTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_ITENSCURSO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBENEFITCODE       :=  WSAdvValue( oResponse,"_BENEFITCODE","string",NIL,"Property cBENEFITCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cBENEFITNAME       :=  WSAdvValue( oResponse,"_BENEFITNAME","string",NIL,"Property cBENEFITNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSALARYTO          :=  WSAdvValue( oResponse,"_SALARYTO","float",NIL,"Property nSALARYTO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure SUPEMAIL

WSSTRUCT W0200301_SUPEMAIL
	WSDATA   cQBMATRESP                AS string
	WSDATA   cRAEMAIL                  AS string
	WSDATA   cRANOME                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_SUPEMAIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_SUPEMAIL
Return

WSMETHOD CLONE WSCLIENT W0200301_SUPEMAIL
	Local oClone := W0200301_SUPEMAIL():NEW()
	oClone:cQBMATRESP           := ::cQBMATRESP
	oClone:cRAEMAIL             := ::cRAEMAIL
	oClone:cRANOME              := ::cRANOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_SUPEMAIL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cQBMATRESP         :=  WSAdvValue( oResponse,"_QBMATRESP","string",NIL,"Property cQBMATRESP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAEMAIL           :=  WSAdvValue( oResponse,"_RAEMAIL","string",NIL,"Property cRAEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRANOME            :=  WSAdvValue( oResponse,"_RANOME","string",NIL,"Property cRANOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SOLICITACAO

WSSTRUCT W0200301_SOLICITACAO
	WSDATA   cCOD                      AS string
	WSDATA   cCODPA3                   AS string
	WSDATA   cFILIALS                  AS string
	WSDATA   cFILPA3                   AS string
	WSDATA   cMATRICULA                AS string
	WSDATA   cNOME                     AS string
	WSDATA   cSTATUS                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_SOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_SOLICITACAO
Return

WSMETHOD CLONE WSCLIENT W0200301_SOLICITACAO
	Local oClone := W0200301_SOLICITACAO():NEW()
	oClone:cCOD                 := ::cCOD
	oClone:cCODPA3              := ::cCODPA3
	oClone:cFILIALS             := ::cFILIALS
	oClone:cFILPA3              := ::cFILPA3
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cNOME                := ::cNOME
	oClone:cSTATUS              := ::cSTATUS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_SOLICITACAO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCOD               :=  WSAdvValue( oResponse,"_COD","string",NIL,"Property cCOD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODPA3            :=  WSAdvValue( oResponse,"_CODPA3","string",NIL,"Property cCODPA3 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIALS           :=  WSAdvValue( oResponse,"_FILIALS","string",NIL,"Property cFILIALS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILPA3            :=  WSAdvValue( oResponse,"_FILPA3","string",NIL,"Property cFILPA3 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMATRICULA         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,"Property cMATRICULA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TREISOLICI

WSSTRUCT W0200301_TREISOLICI
	WSDATA   cCODIGOTRM                AS string
	WSDATA   cDATATRM                  AS string
	WSDATA   cFILIALTRM                AS string
	WSDATA   cSTATUSTRM                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT W0200301_TREISOLICI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_TREISOLICI
Return

WSMETHOD CLONE WSCLIENT W0200301_TREISOLICI
	Local oClone := W0200301_TREISOLICI():NEW()
	oClone:cCODIGOTRM           := ::cCODIGOTRM
	oClone:cDATATRM             := ::cDATATRM
	oClone:cFILIALTRM           := ::cFILIALTRM
	oClone:cSTATUSTRM           := ::cSTATUSTRM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_TREISOLICI
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOTRM         :=  WSAdvValue( oResponse,"_CODIGOTRM","string",NIL,"Property cCODIGOTRM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATATRM           :=  WSAdvValue( oResponse,"_DATATRM","string",NIL,"Property cDATATRM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIALTRM         :=  WSAdvValue( oResponse,"_FILIALTRM","string",NIL,"Property cFILIALTRM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUSTRM         :=  WSAdvValue( oResponse,"_STATUSTRM","string",NIL,"Property cSTATUSTRM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SUPERIOR

WSSTRUCT W0200301_SUPERIOR
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

WSMETHOD NEW WSCLIENT W0200301_SUPERIOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT W0200301_SUPERIOR
Return

WSMETHOD CLONE WSCLIENT W0200301_SUPERIOR
	Local oClone := W0200301_SUPERIOR():NEW()
	oClone:cQBMATRESP           := ::cQBMATRESP
	oClone:cRAEMAIL             := ::cRAEMAIL
	oClone:cRANOME              := ::cRANOME
	oClone:cRD4TREE             := ::cRD4TREE
	oClone:cSRADEPTO            := ::cSRADEPTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT W0200301_SUPERIOR
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cQBMATRESP         :=  WSAdvValue( oResponse,"_QBMATRESP","string",NIL,"Property cQBMATRESP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRAEMAIL           :=  WSAdvValue( oResponse,"_RAEMAIL","string",NIL,"Property cRAEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRANOME            :=  WSAdvValue( oResponse,"_RANOME","string",NIL,"Property cRANOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRD4TREE           :=  WSAdvValue( oResponse,"_RD4TREE","string",NIL,"Property cRD4TREE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSRADEPTO          :=  WSAdvValue( oResponse,"_SRADEPTO","string",NIL,"Property cSRADEPTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


