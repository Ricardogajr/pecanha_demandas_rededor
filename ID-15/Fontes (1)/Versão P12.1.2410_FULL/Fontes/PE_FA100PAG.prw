#include "totvs.ch"

/* {Protheus.doc} FA100PAG
Ponto de Entrada p/ gravação da movimentação na rotina a Pagar (Movimentação Bancária)
@type function
@author paulo.dias
@since 09/11/2021
@version 12.1.27
@project DOR09748161 
@return */

User Function FA100PAG()


Local aAreaE5 := SE5->(GetArea())
Local cUsrAlt := UsrFullName(__cUserId)
 Conout("Entrou ponto de entrada FA100PAG " + Time())

RecLock("SE5", .F. )
SE5->E5_XLOGMOV  := cUsrAlt
SE5->E5_XHORMOV  := TIME() 
SE5->E5_XDATMOV  := Date()
SE5->(MsUnlock())

RestArea(aAreaE5)
Conout("Saiu ponto de entrada FA100PAG " + Time())
Return

