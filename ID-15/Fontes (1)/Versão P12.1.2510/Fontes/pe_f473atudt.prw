#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

 
/*/{Protheus.doc} F473ATUDT
//Permite escolher se a data de disponibilidade será atualizada ou não. 
Pois no padrão a data de disponibilidade é atualizada automaticamente. 
Caso o F473ATUDT seja alterado para retornar .F. (False) a data de 
disponibilidade não será atualizada. 
@authora Thais Paiva
@since 02/06/2021
@version undefined
@param 
@return return, return_description .T.
/*/

  
User Function F473ATUDT
Local _aAreaE5 := GetArea()
Local cUsrAlt := USRFULLNAME(__cuserid)
Local nRecE5 := 0 //12912589 - Thais Paiva
Local oModel   := FwModelActive() //12912589 - Thais Paiva
Local oModelDet	:= oModel:GetModel('CONDETAIL') //12912589 - Thais Paiva

nRecE5	 := oModelDet:GetValue("RECSE5")

If SIG->IG_VLRMOV > 0 .AND. !Empty(SIG->IG_DTMOVI) .AND. SIG->IG_STATUS == '4'
    DbSelectArea("SE5")
    DbSetOrder(20)
    If DbSeek(SIG->IG_FILIAL+SIG->IG_SEQMOV)
        Reclock( "SE5", .F. )
		SE5->E5_XLOGALT := cUsrAlt
		 //Início - 12912589 - Thais Paiva
		SE5->E5_XHORALT  := TIME() 
        SE5->E5_XDATALT  := DATE()
		//Fim - 12912589 - Thais Paiva
        SE5->(MsUnLock())
    Else
		//Início - 12912589 - Thais Paiva
        //DbSetOrder(21)
        //If DbSeek(FK5->FK5_FILIAL+FK5->FK5_IDMOV)
		If nRecE5 > 0
			SE5->(DbGoTo(nRecE5))
            Reclock( "SE5", .F. )
            SE5->E5_XLOGALT := cUsrAlt
			SE5->E5_XHORALT  := TIME() 
            SE5->E5_XDATALT  := DATE()
			//Fim - 12912589 - Thais Paiva
            SE5->(MsUnLock())
        EndIf
    EndIf
EndIf

RestArea(_aAreaE5)

Return .T.
