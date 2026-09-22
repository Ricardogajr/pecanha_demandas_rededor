#Include 'Protheus.ch'

/* {Protheus.doc} F090REST
Ponto de Entrada p/ gravação de log na rotina de baixa multi filiais
@type function
@author paulo.dias
@since 16/12/2021
@version 12.1.27
@project DOR09748161 
@return */
User Function F090REST()

Local cUsrAlt := UsrFullName(__cUserId) 

RecLock("SE5", .F. )
SE5->E5_XLOGMOV  := cUsrAlt
SE5->E5_XHORMOV  := TIME() 
SE5->E5_XDATMOV  := DATE() 
MsUnlock()


Return
