#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
 
/*/{Protheus.doc} F473EFGR
//Ponto de entrada F473EFGR será utilizado para gravar a informação no campo E5_XLOGALT  no momento da Efetivação da Concliliação Automática (FINA473).
@author ronaldo.carvalho / Thais Paiva
@since 04/05/2021
@version undefined
@param 
@return return, return_description
/*/

  
User Function F473EFGR()
Local _aArea := GetArea()
Local cUsrAlt		:= ""
Local nRecno

cUsrAlt := USRFULLNAME(__cuserid)

nRecno := PARAMIXB

SE5->(DbGoto(nRecno))
RecLock("SE5", .F. )
SE5->E5_XLOGALT := cUsrAlt
//Início - 12912589 - Thais Paiva
SE5->E5_XHORALT  := TIME() 
SE5->E5_XDATALT  := DATE()
//Fim - 12912589 - Thais Paiva
MsUnlock()

RestArea(_aArea)
Return

