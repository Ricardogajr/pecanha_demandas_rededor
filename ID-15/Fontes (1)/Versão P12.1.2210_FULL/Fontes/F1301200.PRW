#Include 'Protheus.ch'
#include "APWEBSRV.CH"

User Function F1301200()
Return

WsService W1301200 Description "WebService Server de Acesso"
	WSDATA codigo              AS String
	WSDATA RET              AS BOOLEAN
	WSMETHOD AllNovoAcesso     DESCRIPTION "Novo Acesso"
EndWsService

WsMethod AllNovoAcesso WsReceive codigo WsSend RET WsService W1301200

Return .T.