#INCLUDE "AE_LibAtraso_AP7.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_LibAtraso_Ap7 ºAutor  ³ Willy       º Data ³  17/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Libera Atraso na Prestacao de Contas.                     º±±
±±º          ³  Bloqueio por Atraso na Prestacao de Contas.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LibAtraso()

Local _cPerg1 		:= STR0001 //"Deseja Liberar Atraso da Prestação de Contas desse Colaborador?"
Local _cPerg2 		:= STR0002 //"Deseja Bloquear por Atraso a Prestação de Contas desse Colaborador?"
Local _aAreaLHQ2	:= GetArea()

ChkTemplate("CDV") 

If LHQ->LHQ_FLAG == "K"
	MsgInfo(STR0003) //"Esta solicitação está cancelada e não pode ser alterada."
	Return
EndIf                  
If LHQ->LHQ_FLAG == "Z"
	MsgInfo(STR0004) //"Esta solicitação está fechada e não pode ser alterada."
	Return
EndIf
If LHQ->LHQ_FLAG == "C"
	MsgInfo(STR0005) //"Esta solicitação está autorizada e liberada e não pode ser alterada."
	Return
EndIf
If LHQ->LHQ_FLAG == "B"
	MsgInfo(STR0006) //"Prestação de contas sem solicitação não podem ser bloqueadas."
	Return
EndIf
	
If !LHQ->LHQ_FLAG == "P"
	If MsgYESNO(_cPerg2, STR0007) //"Atenção"
		dbSelectArea("LHQ")
		RecLock("LHQ",.F.)
		LHQ->LHQ_FLAG := "P"
		MsUnLock("LHQ")
		MsgInfo(STR0008) //"Bloqueio por Atraso, concluido com Sucesso!"
	Endif
Else
	If MsgYESNO(_cPerg1, "Atenção")
		dbSelectArea("LHQ")
		RecLock("LHQ",.F.)
		If Empty(LHQ->LHQ_SAIDA)
			LHQ->LHQ_FLAG := "M"
		Else
			If Empty(LHQ->LHQ_EMISS)
				LHQ->LHQ_FLAG := "V"
			Else
				If Empty(LHQ->LHQ_IMPRESS)
					LHQ->LHQ_FLAG := "D"
				Else
					LHQ->LHQ_FLAG := "L"
				Endif
			Endif
		EndIf
		MsUnLock("LHQ")
		MsgInfo(STR0009) //"Liberação de Atraso, concluida com Sucesso!"
	Endif
EndIf
RestArea(_aAreaLHQ2)

Return(Nil)
