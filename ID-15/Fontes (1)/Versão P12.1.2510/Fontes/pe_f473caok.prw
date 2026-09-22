#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

 
/*/{Protheus.doc} F473CAOK
//Utilizado para validação complementar para permitir ou não o cancelamento da Efetivação da Concliliação Automática.
@authora Thais Paiva
@since 02/06/2021
@version undefined
@param 
@return return, return_description .T.
/*/

  
User Function F473CAOK()
Local cUsrAlt		:= ""
Local nRecno
Local _aArea := GetArea()

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
Return .T.
