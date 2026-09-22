#INCLUDE "AE_AtuLogin_AP7.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_AtuLoginºAutor  ³ Willy              º Data ³  10/04/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Atualiza os logins do cadastros de viagens,para prestação º±±
±±º          ³  de contas.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_AtuLogin()

Local _cperg := STR0001 //"Deseja Atualizar o Login do Cadastro de Viagem, para as Prestações de Contas ?"

chktemplate("CDV")

If MsgYESNO(_cperg, STR0002) //"Atenção"
	MsgRun(STR0003,"",{|| CursorWait(), ExecLogin() ,CursorArrow()}) //'Atualizando Login, Aguarde...'
	MsgInfo(STR0004) //"Atualização do Login, Concluida com Sucesso !"
Endif

Return
*--------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------
Static Function ExecLogin()
*--------------------------------------------------------------------------------------

Local _aAreaLHQ:= GetArea()

DbSelectArea('LHQ')
DbSetOrder(4)
DbGotop()
Do While !Eof()
	DbSelectArea('LHT')
	DbSetOrder(1)
	If MsSeek(xFilial('LHT') + LHQ->LHQ_FUNC)
		RecLock('LHQ',.F.) 
		LHQ->LHQ_LOGIN := LHT->LHT_LOGIN
		MsUnLock('LHQ')
	EndIf
	DbSelectArea('LHQ')
	LHQ->(DbSkip())
EndDo

RestArea(_aAreaLHQ)

Return
