#include 'totvs.ch'

/* {Protheus.doc} FA050FIN
Ponto de Entrada p/ gravação de movimentação na inclusão de tit. no Contas a Pagar
@type function
@author paulo.dias
@since 17/11/2021
@version 12.1.27
@project DOR09748161 
@return */

User Function FA050FIN()

Local cUsrAlt := UsrFullName(__cUserId) 

DbSelectArea("SE5")
DbSetOrder(7)
If DbSeek(xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
    RecLock("SE5", .F. )
    SE5->E5_XLOGMOV  := cUsrAlt
    SE5->E5_XHORMOV  := TIME() 
    SE5->E5_XDATMOV  := DATE() 
    MsUnlock()
EndIf 

Return 

