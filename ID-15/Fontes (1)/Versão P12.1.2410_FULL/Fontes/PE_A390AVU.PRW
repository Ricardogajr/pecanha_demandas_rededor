#include 'totvs.ch'

/* {Protheus.doc} A390AVU
Ponto de Entrada p/ gravação de movimentação na inclusão de tit. no Contas a Pagar
@type function
@author paulo.dias
@since 17/11/2021
@version 12.1.27
@project DOR09748161 
@return */


User Function A390AVU()

Local cUsrAlt :=  UsrFullName(__cuserid)
                                         
RecLock("SEF",.F.)
SEF->EF_XLOGMOV := cUsrAlt
SEF->EF_XDATMOV := DATE()
SEF->EF_XHORMOV := TIME() 

MsUnLock()

Return
