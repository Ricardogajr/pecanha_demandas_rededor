#INCLUDE "Ver_Atraso_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VER_ATRASOºAutor  ³ Willy              º Data ³  14/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Menu para Selecionar as Ferramentas de Verificação de      º±±
±±º          ³ Atraso e Atualização de Login de Usuário no Sist. Viagem.   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VerAtraso()

Local oFerramenta
Local oSBtn1
Local oSBtn2
Local oSay3
Local oSay4
Local oGrp6

ChkTemplate("CDV")

oFerramenta := MSDIALOG():Create() 
oFerramenta:cName := "oFerramenta"
oFerramenta:cCaption := STR0001 //"Manutenção"
oFerramenta:nLeft := 0
oFerramenta:nTop := 0
oFerramenta:nWidth := 276
oFerramenta:nHeight := 265
oFerramenta:lShowHint := .F.
oFerramenta:lCentered := .T.

oSBtn1 := SBUTTON():Create(oFerramenta)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "oSBtn1"
oSBtn1:cMsg := STR0002 //"Verifica Atraso na Prestação de Contas !"
oSBtn1:nLeft := 176
oSBtn1:nTop := 61
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 4
oSBtn1:bAction := {|| AtuAtraso() }

oSBtn2 := SBUTTON():Create(oFerramenta)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "oSBtn2"
oSBtn2:cMsg := STR0003 //"Atualiza Login de Usuário !"
oSBtn2:nLeft := 176
oSBtn2:nTop := 131
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 5
oSBtn2:bAction := {|| U_AE_AtuLogin() }

oSay3 := TSAY():Create(oFerramenta)
oSay3:cName := "oSay3"
oSay3:cCaption := STR0004 //"Verifica Atraso."
oSay3:nLeft := 35
oSay3:nTop := 63
oSay3:nWidth := 140
oSay3:nHeight := 22
oSay3:lShowHint := .F.
oSay3:lReadOnly := .F.
oSay3:Align := 0
oSay3:lVisibleControl := .T.
oSay3:lWordWrap := .F.
oSay3:lTransparent := .F.

oSay4 := TSAY():Create(oFerramenta)
oSay4:cName := "oSay4"
oSay4:cCaption := STR0005 //"Atualiza Login."
oSay4:nLeft := 36
oSay4:nTop := 129
oSay4:nWidth := 136
oSay4:nHeight := 21
oSay4:lShowHint := .F.
oSay4:lReadOnly := .F.
oSay4:Align := 0
oSay4:lVisibleControl := .T.
oSay4:lWordWrap := .F.
oSay4:lTransparent := .F.

oGrp6 := TGROUP():Create(oFerramenta)
oGrp6:cName := "oGrp6"
oGrp6:cCaption := STR0006 //"Ferramentas"
oGrp6:nLeft := 23
oGrp6:nTop := 14
oGrp6:nWidth := 226
oGrp6:nHeight := 199
oGrp6:lShowHint := .F.
oGrp6:lReadOnly := .F.
oGrp6:Align := 0
oGrp6:lVisibleControl := .T.

oFerramenta:Activate()

Return (NIL)
*--------------------------------------------------------------------------------------

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuATRASO_AP6ºAutor  ³ Willy           º Data ³  14/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Verifica status da solicitação, com relação a prestação   º±±
±±º          ³  de contas em atraso.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuAtraso()

Local _cperg := STR0007 //"Deseja Verificar Atraso na Prestação de Contas ?"
If MsgYESNO(_cperg, STR0008) //"Atenção"
	MsgRun(STR0009,"",{|| CursorWait(), OkProcLHQ() ,CursorArrow()}) //'Verificando Atraso, Aguarde...'
	MsgInfo(STR0010) //"Verificação de Atraso, Concluida com Sucesso !"
Endif

Return

*--------------------------------------------------------------------------------------
Static Function OkProcLHQ()
*--------------------------------------------------------------------------------------
Local _aAreaLHQ:= GetArea() , _cLHQFLAG
Local _cFuncLHQ , _dDtChegad
Local _nDiasV:= GetMV('MV_DATRASO') // 3 Dias

DbSelectArea('LHQ')
DbSetOrder(4)
MSseek(xFilial('LHQ'))
Do While cFilAnt == xFilial('LHQ')
	
	If LHQ->LHQ_Flag $ 'CBZK'
		LHQ->(dbSkip())      
		If Eof()
		   Exit
		Else
	       Loop
		Endif	
	EndIf
	
	If !Empty(LHQ->LHQ_DFECHA)
		LHQ->(dbSkip())
		If Eof()
		   Exit
		Else
		   Loop
		Endif
	EndIf
	
	If Dow(DataValida(LHQ->LHQ_Chegad)) == 6
		_nDiasV+= 2
	Endif
	
	If DataValida(LHQ->LHQ_Chegad + _nDiasV) < dDataBase
		_cFuncLHQ  := LHQ->LHQ_FUNC
		_cLHQFLAG  := ' '
		_dDtChegad := DataValida(LHQ->LHQ_Chegad)
		
		If Dow(_dDtChegad) == 6
			_dDtChegad := DataValida(_dDtChegad + 2)
		Endif
		
		LHQ->(dbSkip())          
		
		If _cFuncLHQ == LHQ->LHQ_FUNC
			If DataValida(LHQ->LHQ_Saida) <= _dDtChegad
				If LHQ->LHQ_Flag == 'C' .Or. LHQ->LHQ_Flag == 'B';
					.Or. LHQ->LHQ_Flag == 'P' .Or. LHQ->LHQ_Flag == 'Z'
					_cLHQFLAG := 'P'
					LHQ->(dbSkip(-1))
				Else
					LHQ->(dbSkip(-1))
					If Empty(LHQ->LHQ_Saida)
						_cLHQFLAG :=  'M'
					Else
						If Empty(LHQ->LHQ_Emiss)
							_cLHQFLAG :=  'V'
						Else
							If Empty(LHQ->LHQ_Impres)
								_cLHQFLAG := 'D'
							Else
								_cLHQFLAG := 'L'
							Endif
						Endif
					EndIf
				Endif
			Else
				LHQ->(dbSkip(-1))
				_cLHQFLAG := 'P'
			Endif
		Else
			LHQ->(dbSkip(-1))
			If _dDtChegad < dDataBase
				_cLHQFLAG := 'P'
			Else
				If Empty(LHQ->LHQ_Saida)
					_cLHQFLAG := 'M'
				Else
					If Empty(LHQ->LHQ_Emiss)
						_cLHQFLAG := 'V'
					Else
						If Empty(LHQ->LHQ_Impres)
							_cLHQFLAG := 'D'
						Else
							_cLHQFLAG := 'L'
						Endif
					Endif
				EndIf
			Endif
		Endif		
		RecLock('LHQ',.F.)
		LHQ->LHQ_FLAG := _cLHQFLAG
		MsUnLock('LHQ')
	Else
		If LHQ->LHQ_FLAG == 'P'
			RecLock('LHQ',.F.)
			If Empty(LHQ->LHQ_Saida)
				LHQ->LHQ_FLAG := 'M'
			Else
				If Empty(LHQ->LHQ_Emiss)
					LHQ->LHQ_FLAG := 'V'
				Else
					If Empty(LHQ->LHQ_Impres)
						LHQ->LHQ_FLAG := 'D'
					Else
						LHQ->LHQ_FLAG := 'L'
					Endif
				Endif
			EndIf
			MsUnLock('LHQ')
		Endif
	EndIf
	LHQ->(dbSkip())
	If Eof()
	   Exit
	Else
	   Loop
	Endif
EndDo

RestArea(_aAreaLHQ)

Return(Nil)
