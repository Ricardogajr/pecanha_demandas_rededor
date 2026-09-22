#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

 
/*/{Protheus.doc} F473CAGR
//Utilizado para gravação complementar no cancelamento da Efetivação da Conciliação Automática (FINA473).
@authora Thais Paiva
@since 02/06/2021
@version undefined
@param 
@return return, return_description .T.
/*/

  
User Function F473CAGR()
Local cUsrAlt		:= ""
Local nRecno
Local _aArea := GetArea()
Local _DtMov := SIG->IG_DTMOVI

cUsrAlt := USRFULLNAME(__cuserid)

nRecno := PARAMIXB

SE5->(DbGoto(nRecno))
RecLock("SE5", .F. )
If Empty(_DtMov) .AND. !Empty(Alltrim(SE5->E5_XLOGMOV))
	//Início - 12912589 - Thais Paiva
    SE5->E5_XLOGALT := "" 
    SE5->E5_XHORALT  := TIME() 
    SE5->E5_XDATALT  := CTOD("//")
Else
    SE5->E5_XLOGALT := cUsrAlt
	SE5->E5_XHORALT  := TIME() 
    SE5->E5_XDATALT  := DATE()
	//Fim - 12912589 - Thais Paiva
EndIf
MsUnlock()

RestArea(_aArea)
Return
