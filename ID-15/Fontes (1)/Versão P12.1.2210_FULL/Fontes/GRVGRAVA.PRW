#Include 'Protheus.ch'

/*
{Protheus.doc}  GRVGRAVA()
Ponto de entrada para gravação complementar na rotina de Solicitação de Viagem
@Author  Ramon Teodoro e Silva	
@Since   02/08/2019       
@Version P12.7
*/

User Function GRVGRAVA()

RecLock("LHP",.F.)
LHP->LHP_XUSINC := __cUserID
LHP->(MsUnlock())

Return

