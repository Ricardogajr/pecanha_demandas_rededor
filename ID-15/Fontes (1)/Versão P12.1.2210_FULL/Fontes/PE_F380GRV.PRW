#include 'protheus.ch' 
 
/*/{Protheus.doc} FA040GRV
//Ponto de entrada F380GRV (Confirma reconciliação bancária): será utilizado para gravar a informação no campo E5_XLOGALT sera executado apos confirmar 
a tela de reconciliacao bancaria e apos gravar a marcacao do registro selecionado (E5_RECONC).
@author ronaldo.carvalho
@since 04/05/2021
@version undefined
@param 
@return return, return_description
/*/

User Function F380GRV()
Local cUsrAlt		:= ""
Local _aArea := GetArea()
Local cRecAnt := TRB->E5_RECONC

cUsrAlt := USRFULLNAME(__cuserid)
                                         
RecLock("SE5",.F.)
//Realiza a gravação do usuario de alteração.
If TRB->E5_RECONC <> SE5->E5_RECONC
    SE5->E5_XLOGALT  := cUsrAlt
    SE5->E5_XHORALT  := TIME() // ticket n° 12543360
    SE5->E5_XDATALT  := DATE() // ticket n° 12543360
EndIf   
MsUnLock()

RestArea(_aArea)
Return()
