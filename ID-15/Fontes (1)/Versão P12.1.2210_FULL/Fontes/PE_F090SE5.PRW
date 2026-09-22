#include 'totvs.ch'

/* {Protheus.doc} F090SE5
Ponto de Entrada p/ gravação de movimentação bancários processados
@type function
@author paulo.dias
@since 17/11/2021
@version 12.1.27
@project DOR09748161 
@return */


User Function F090SE5()
    Local aRecno := ParamIxb[1]
    Local nCntFor :=0
    Local cUsrAlt :=  UsrFullName(__cuserid)
 
    dbSelectArea("SE5")
    DbSetOrder(1)
    For nCntFor := 1 to Len(aRecno)
        SE5->(dbGoto(aRecno[nCntFor]))

        RecLock("SE5", .F. )
        SE5->E5_XLOGMOV  := cUsrAlt
        SE5->E5_XHORMOV  := TIME() 
        SE5->E5_XDATMOV  := DATE() 
        MsUnlock()    

    Next nCntFor
Return
