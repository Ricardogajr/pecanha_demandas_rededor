#include "totvs.ch"

/* {Protheus.doc} A100BL01
Ponto de Entrada p/ gravação de movimentação na transf. entre contas
@type function
@author paulo.dias
@since 09/11/2021
@version 12.1.27
@project DOR09748161 
@return */

User Function A100BL01()

Local aAreaE5 := SE5->(GetArea())
Local cUsrAlt := UsrFullName(__cUserId)
 Conout("Entrou ponto de entrada A100BL01 " + Time())
RecLock("SE5", .F. )
SE5->E5_XLOGMOV  := cUsrAlt
SE5->E5_XHORMOV  := TIME() 
SE5->E5_XDATMOV  := Date()
SE5->(MsUnlock())


RestArea(aAreaE5)
Conout("Saiu ponto de entrada A100BL01 " + Time())
Return 
