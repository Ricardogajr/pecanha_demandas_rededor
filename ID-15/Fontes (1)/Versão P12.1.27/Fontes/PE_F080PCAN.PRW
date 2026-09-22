#include 'totvs.ch'

/* {Protheus.doc} F080PCAN
Ponto de Entrada p/ gravação de movimentação bancários processados para canc. de baixa
@type function
@author paulo.dias
@since 17/11/2021
@version 12.1.27
@project DOR09748161 
@return */

User Function F080PCAN() 
//Início - Thais Paiva - 12912589
Local cUsrAlt := USRFULLNAME(__cuserid)

If SE5->E5_RECPAG == 'R'
	RecLock("SE5", .F. )
	SE5->E5_XLOGMOV := cUsrAlt
	SE5->E5_XHORMOV := Time()
	SE5->E5_XDATMOV := Date()

	SE5->(MsUnLock())
EndIf
If !Empty(Alltrim(SE5->E5_XLOGALT)) .AND. SE5->E5_RECONC <> 'x'
	RecLock("SE5", .F. )
	SE5->E5_XLOGALT := ""
	SE5->E5_XHORALT := ""
	SE5->E5_XDATALT := ctod("//")

	SE5->(MsUnLock())
EndIf

//Fim - Thais Paiva - 12912589

Return

