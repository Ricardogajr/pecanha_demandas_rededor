#INCLUDE "AE_SV006_AP6.ch"
#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_SV006_AP6ºAutor  ³Armando / Willy     º Data ³  09/06/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Vizualização da Solicitação de Viagem.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_SV006(_cCodLHQ)

	Local _cRotZD		:= Substr(FunName(),2)
	Local _nRow			:= 0
	Local _nAux			:= 0
	Local nAprov 		:= _cCodLHQ
	Local lOk 			:= .F.
	Local lReprov 		:= .F.
	Local lAprov 		:= .F.
	Local aAreaLHT		:= LHT->(GetArea())
	Local cTipoAp		:= ""
	Local cTitMens		:= OemToAnsi(STR0001) //"Aprovação de solicitação"
	Local cUsLogin		:= Alltrim(Substr(UsrRetName(__cUserID),1,TamSX3("LHT_LOGIN")[1]))
	Private aMemos 	:= {{"LHP_CODMOT","LHP_MOTMEM","LHP_CODOBS","LHP_OBSMEM"}}
	Private _lRetLHQ 	:= .F.
	Private _aAreaLHP1

	ChkTemplate("CDV")
	If AllTrim(_cRotZD) == "AE_DESPV" .Or. AllTrim(_cRotZD) == "DESPVA"
		_aAreaLHP1:= GetArea()
		dbSelectArea("LHP")
		LHP->(dbSetOrder(1))
		LHP->(MsSeek(xFilial('LHP') + _cCodLHQ))
		_lRetLHQ := .T.
	Endif
//Verificando se a solicitacao nao esta iniciada e/ou para aprovacao, caso nao esteja finalizar
	If !LHP->LHP_FLAG $ "DM" .AND. !LHP->LHP_FLAG1 $ "DM"
		MsgAlert(OemToAnsi(STR0002),cTitMens) //"Esta solicitação já passou do processo de aprovação!"
		Return(Nil)
	Endif
//Verificando se o usuario e aprovador
	cTipoAp := Posicione("LHT",4,xFilial("LHT") + cUsLogin,"LHT_FLAGAP+LHT_APFIN")
	If !Empty(cTipoAp)
		If cTipoAp == "22"	//Nao e aprovador
			MsgAlert(OemToAnsi(STR0003),cTitMens) //"Somente aprovadores podem utilizar a rotina de aprovação"
			Return Nil
		Else
			If IIf(ValType(_cCodLHQ) # "N", Val(_cCodLHQ), _cCodLHQ) == 1
				If Substr(cTipoAp,1,1) # "1"	//Nao e aprovador 1
					MsgAlert(OemToAnsi(STR0004),cTitMens) //"Somente aprovadores do nível 1 podem liberar a primeira aprovação!"
					Return Nil
				Endif
			Else
				If Substr(cTipoAp,2,1) # "1"	//Nao e aprovador 2
					MsgAlert(OemToAnsi(STR0005),cTitMens) //"Somente aprovadores do nível 2 podem liberar a segunda aprovação!"
					Return Nil
				Endif
			Endif
		Endif
	Else
		MsgAlert(STR0006 + AllTrim(__cUserID) + "-" + cUsLogin + STR0007) //"Este usuario ("###") não foi encontrado no cadastro de viajantes/aprovadores!"
		Return Nil
	Endif
//Verificando se a solicitacao já não foi aprovado e/ou reprovada
	If IIf(ValType(_cCodLHQ) # "N", Val(_cCodLHQ), _cCodLHQ) == 1	//Aprovador 1
		Do Case
		Case LHP->LHP_FLAG == "A"	//aprovado
			MsgAlert(OemToAnsi(STR0008),cTitMens) //"Esta solicitação já foi aprovada pelo aprovador 1!"
			Return Nil
		Case LHP->LHP_FLAG == "P"	//reprovado
			MsgAlert(OemToAnsi(STR0009),cTitMens) //"Esta solicitação foi reprovada pelo aprovador 1!"
			Return Nil
		EndCase
	Else
		//Verificar se o aprovador 1 jah aprovou, caso contrario, bloquear
		If !LHP->LHP_FLAG $ "AP" .OR. Empty(LHP->LHP_APROV)
			MsgAlert(STR0010) //"O aprovador 1 ainda não aprovou esta solicitação. Operação bloqueada."
			Return .F.
		Endif
		If (LHP->LHP_FLAG1 # "I" .AND. Empty(LHP->LHP_APROV))
			MsgAlert(STR0011) //"Verifique se a solicitação foi enviada para aprovação e se já foi aprovada pelo Aprovador 1!"
			Return .F.
		EndIf
		Do Case
		Case LHP->LHP_FLAG1 == "A"	//aprovado
			MsgAlert(OemToAnsi(STR0012),cTitMens) //"Esta solicitação já foi aprovada pelo aprovador 2!"
			Return Nil
		Case LHP->LHP_FLAG1 == "P"	//reprovado
			MsgAlert(OemToAnsi(STR0013),cTitMens) //"Esta solicitação foi reprovada pelo aprovador 2!"
			Return Nil
		EndCase
	Endif
	RestArea(aAreaLHT)

	If PtGetTheme() $ "MDI/TEMAP10"
		DEFINE MSDIALOG oPrincipal FROM  000,000 TO 520,720 TITLE STR0014 + LHP->LHP_CODIGO PIXEL //'Solicitação de Viagem  -  '
	Else
		DEFINE MSDIALOG oPrincipal FROM  000,000 TO 490,720 TITLE STR0014 + LHP->LHP_CODIGO PIXEL //'Solicitação de Viagem  -  '
	Endif

	_nRow := 32
	@ _nRow,002 TO _nRow+30,359 OF oPrincipal PIXEL
	_nRow+=2

	@ _nRow,006 SAY STR0015 OF oPrincipal PIXEL //'Solicitante / País'
	_cQuem := Substr(LHP->LHP_Quem,0,39)
	@ _nRow,048 MSGET _cQuem Size 82,07 When .F. OF oPrincipal PIXEL

	@ _nRow,135 SAY STR0016 OF oPrincipal PIXEL //'Antecedência'
	_cAntec := LHP->LHP_Antec
	@ _nRow,172 MSGET _cAntec Size 100,07 When .F. OF oPrincipal PIXEL

	_dEmissao := LHP->LHP_Emiss
	@ _nRow,278 SAY STR0017 OF oPrincipal PIXEL //'Data da Emissão'
	@ _nRow,322 MSGET _dEmissao Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

	_nRow+=14
	_aTpSol := {STR0018,STR0019} //'1-Administrativa'###'2-Viagem'
	@ _nRow,005 SAY STR0020 OF oPrincipal PIXEL //'Despesa'
	_cTP := If(FieldPos("LHP_TPSOL") > 0 .And. !Empty(LHP->LHP_TPSOL),_aTpSol[VAL(LHP->LHP_TPSOL)],_aTpSol[2])
	@ _nRow,037 ComboBox _cTP Items _aTpSol Size 100,07 OF oPrincipal PIXEL

	_aTpAprov := {STR0021,STR0022} //'1-Adiantamento'###'2-Reembolso'
	@ _nRow,140 SAY STR0023 OF oPrincipal PIXEL //'Tipo da Solicitação'
	_cTPAprov := If(FieldPos("LHP_TPAPRO") > 0 .And. !Empty(LHP->LHP_TPAPRO),_aTpAprov[VAL(LHP->LHP_TPAPRO)],_aTpAprov[1])
	@ _nRow,190 ComboBox _cTPAprov Items _aTpAprov Size 100,07 OF oPrincipal PIXEL

	_nRow+=18
	_nAux := _nRow
	_cFunc	:= LHP->LHP_Func
	_cNFunc := LHP->LHP_NFunc
	@ _nRow,005 SAY STR0024 OF oPrincipal PIXEL //"Colaborador"
	@ _nRow,110 SAY STR0025 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cFunc  Picture '@!' When .F. OF oPrincipal PIXEL
	@ _nRow,130 MSGET _cNFunc Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

	_nRow+=13
	_cSupImd  := LHP->LHP_SupImd
	dbSelectArea('LHT')
	LHT->(dbSetOrder(1))
	If LHT->(MsSeek(xFilial('LHT') + _cSupImd))
		_cNSupImd := LHT->LHT_Nome
	Else
		_cNSupImd := ''
	EndIf
	dbSelectArea('LHP')
	@ _nRow,005 SAY STR0026 OF oPrincipal PIXEL //'Aprovador I   '
	@ _nRow,110 SAY STR0025 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cSupImd  Picture '@!' When .F. OF oPrincipal PIXEL
	@ _nRow,130 MSGET _cNSupImd Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

	_nRow+=13

	_cDGRar  := LHP->LHP_DGRar
	_cNDGRar := ''
	If !Empty(Alltrim(LHP->LHP_DGRar))
		dbSelectArea('LHT')
		LHT->(dbSetOrder(1))
		If LHT->(MsSeek(xFilial('LHT') + _cDGRar))
			_cNDGRar := LHT->LHT_Nome
		Else
			_cNDGRar := ''
		EndIf
	EndIf
	dbSelectArea('LHP')

	@ _nRow,005 SAY STR0027 OF oPrincipal PIXEL //'Aprovador II'
	@ _nRow,110 SAY STR0025 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cDGRar  Picture '@!' When .F. OF oPrincipal PIXEL
	@ _nRow,130 MSGET _cNDGRar Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

	_nRow+=13
	_cEmpCli  := LHP->LHP_EmpCli
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial('SA1') + _cEmpCli))
		_cNEmpCli := SA1->A1_Nome
	Else
		_cNEmpCli := ''
	EndIf
	dbSelectArea('LHP')
	@ _nRow,005 SAY STR0028 OF oPrincipal PIXEL //'Empresa / Cliente'
	@ _nRow,110 SAY STR0025 OF oPrincipal PIXEL //'Nome'
	@ _nRow,055 MSGET _cEmpCli  Picture '@!' When .F. OF oPrincipal PIXEL
	@ _nRow,130 MSGET _cNEmpCli Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

	_nRow+=13
	_cLocal := LHP->LHP_Local
	@ _nRow,005 SAY STR0029 OF oPrincipal PIXEL //'Local da Viagem'
	@ _nRow,055 MSGET _cLocal  Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

	_cCC := LHP->LHP_CC
	@ _nAux+3,307 SAY 'CC' OF oPrincipal PIXEL
	@ _nAux+3,317 MSGET _cCC  Picture '@!' Size 40,07 When .F. OF oPrincipal PIXEL

	_nAux+=17
	_mMotivo := MSMM(LHP->LHP_CodMot,,,,3)
	@ _nAux,307 Button STR0030 Size 50,12 Action _mMotivo:= U_EditaTxt(STR0031, _mMotivo, .T.) OF oPrincipal PIXEL //"Motivo"###'Motivo da Viagem'

	_nAux+=15
	_mObs := MSMM(LHP->LHP_CodObs,,,,3)
	@ _nAux,307 Button STR0032 Size 50,12 Action _mObs:= U_EditaTxt(STR0033, _mObs, .T.) OF oPrincipal PIXEL //"Observações"###'Observações Gerais'

	_dSaida   := LHP->LHP_Saida
	_dChegada := LHP->LHP_Chegad
	@ _nRow,245 SAY STR0034 OF oPrincipal PIXEL //'Período'
	@ _nRow,310 SAY STR0035 OF oPrincipal PIXEL //'à'
	@ _nRow,270 MSGET _dSaida   Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL
	@ _nRow,320 MSGET _dChegada Picture '@D' Size 35,07 When .F. OF oPrincipal PIXEL

	_nRow +=13
	If(FieldPos("LHP_NRCHOS") > 0,_nNrHosp := LHP->LHP_NRCHOS,_nNrHosp:=0)
		@ _nRow,005 SAY STR0036 OF oPrincipal PIXEL //'Nr. Cheques Hospedagem'
		@ _nRow,070 MSGET _nNrHosp Picture '999' Size 40,07 OF oPrincipal PIXEL

		If(FieldPos("LHP_NRPER") > 0,_nNrEstad := LHP->LHP_NRPER,_nNrEstad:=0)
			@ _nRow,145 SAY STR0037 OF oPrincipal PIXEL //'Nr. Estadias'
			@ _nRow,178 MSGET _nNrEstad Picture '999' Size 40,07 OF oPrincipal PIXEL

			If(FieldPos("LHP_VooIda") > 0,_cVooIda := LHP->LHP_VooIda,_cVooIda:="")
				If(FieldPos("LHP_VooVta") > 0,_cVooVta := LHP->LHP_VooVta,_cVooVta:="")
					If(FieldPos("LHP_HoraId") > 0,_cHoraId := LHP->LHP_HoraId,_cHoraId:="")
						If(FieldPos("LHP_HoraVt") > 0,_cHoraVt := LHP->LHP_HoraVt,_cHoraVt:="")
							If(FieldPos("LHP_AirIda") > 0,_cAirIda := LHP->LHP_AirIda,_cAirIda:="")
								If(FieldPos("LHP_AirVta") > 0,_cAirVta := LHP->LHP_AirVta,_cAirVta:="")

									_nRow+=12
									_nAux := _nRow
									@ _nRow,003 TO _nRow+32,220 OF oPrincipal PIXEL

									_nRow+=5
									@ _nRow,007 SAY STR0038 OF oPrincipal PIXEL //'N.Voo Ida'
									@ _nRow,090 SAY STR0039 OF oPrincipal PIXEL //'Hora'
									@ _nRow,145 SAY STR0040 OF oPrincipal PIXEL //'Trans/Cia'
									@ _nRow,037 MSGET _cVooIda Picture '@!' Size 40,07 When .F. OF oPrincipal PIXEL
									@ _nRow,105 MSGET _cHoraId Picture '99:99' Size 30,07 When .F. OF oPrincipal PIXEL
									@ _nRow,173 MSGET _cAirIda Picture '@!' Size 40,07 When .F. OF oPrincipal PIXEL

									_nRow+=13
									@ _nRow,007 SAY STR0041 OF oPrincipal PIXEL //'N.Voo Ret'
									@ _nRow,090 SAY STR0039 OF oPrincipal PIXEL //'Hora'
									@ _nRow,145 SAY STR0040 OF oPrincipal PIXEL //'Trans/Cia'
									@ _nRow,037 MSGET _cVooVta Picture '@!' Size 40,07 When .F. OF oPrincipal PIXEL
									@ _nRow,105 MSGET _cHoraVt Picture '99:99' Size 30,07 When .F. OF oPrincipal PIXEL
									@ _nRow,173 MSGET _cAirVta Picture '@!' Size 40,07 When .F. OF oPrincipal PIXEL

									_nFatCli := LHP->LHP_FatCli
									_nFatFra := LHP->LHP_FatFra
									_nFatMic := LHP->LHP_FatMic
									@ _nAux,230 TO _nAux+32,359 OF oPrincipal PIXEL

									_nAux+=5
									@ _nAux,235 MSGET _nFatCli Picture '@E 999.99' Size 25,07 When .F. OF oPrincipal PIXEL
									@ _nAux,268 SAY STR0042 OF oPrincipal PIXEL //'Cliente'

									@ _nAux,295 MSGET _nFatMic Picture '@E 999.99' Size 25,07 When .F. OF oPrincipal PIXEL
									@ _nAux,328 SAY STR0043 OF oPrincipal PIXEL //'Não Fatura'

									_nAux+=13
									@ _nAux,235 MSGET _nFatFra Picture '@E 999.99' Size 25,07 When .F. OF oPrincipal PIXEL
									@ _nAux,268 SAY STR0044 OF oPrincipal PIXEL //'Franquia'

									_cSistem := LHP->LHP_Sistem
									@ _nAux,295 MSGET _cSistem Size 60,07 When .F. OF oPrincipal PIXEL

									_nRow+=15
									@ _nRow,003 TO _nRow+40,359 OF oPrincipal PIXEL

									ofont3:= TFont():New("Tahoma",14,14,.F. ,.T., ,.T., , .F.,.F.)
									_nRow+=5
									If LHP->LHP_Adiant
										If LHP->LHP_OkAdia
											oSay1:= TSay():New(_nRow,048,{||STR0045},oPrincipal,,ofont3,,,,.T.,CLR_HBLUE,CLR_WHITE,200,180) //'Ok'
											_lAdiant := STR0046 //'Adiantamento'
										Else
											_lAdiant := STR0047 //'SIM-Adiantamento'
										EndIf
									Else
										_lAdiant := STR0048 //'NÃO-Adiantamento'
									EndIf

									If LHP->LHP_Passag
										If LHP->LHP_OkPass
											oSay2:= TSay():New(_nRow,109,{||STR0045},oPrincipal,,ofont3,,,,.T.,CLR_HBLUE,CLR_WHITE,200,180) //'Ok'
											_lPassag := STR0049 //'Passagem'
										Else
											_lPassag := STR0050 //'SIM-Passagem Aérea'
										EndIf
									Else
										_lPassag := STR0051 //'NÃO-Passagem Aérea'
									EndIf

									If LHP->LHP_Hosped
										If LHP->LHP_OkHosp
											oSay3:= TSay():New(_nRow,176,{||STR0045},oPrincipal,,ofont3,,,,.T.,CLR_HBLUE,CLR_WHITE,200,180) //'Ok'
											_lHosped := STR0052 //'Hospedagem'
										Else
											_lHosped := STR0053 //'SIM-Hospedagem'
										EndIf
									Else
										_lHosped := STR0054 //'NÃO-Hospedagem'
									EndIf

									@ _nRow,008 SAY _lAdiant OF oPrincipal PIXEL
									@ _nRow,073 SAY _lPassag OF oPrincipal PIXEL
									@ _nRow,137 SAY _lHosped OF oPrincipal PIXEL

									_nRow+=3
									_nValorR := LHP->LHP_ValorR
									_nValorU := LHP->LHP_ValorU + LHP->LHP_VAdiM2
									@ _nRow,199 SAY STR0055 OF oPrincipal PIXEL //'Valor R$'
									@ _nRow,225 MSGET _oValorR VAR _nValorR Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

									@ _nRow,282 SAY STR0056 OF oPrincipal PIXEL //'Valor US$'
									@ _nRow,311 MSGET _oValorU VAR _nValorU Picture '@E 999,999.99' When .F. Size 40,07 OF oPrincipal PIXEL

									_nRow+=8
									_cPassag := LHP->LHP_HPass
									@ _nRow,007 SAY STR0057 OF oPrincipal PIXEL //'Obs.'
									@ _nRow,025 MSGET _cPassag Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

									_nRow+=8
									_cBanco  := LHP->LHP_Banco
									_cAgenci := LHP->LHP_Agenci
									_cConta  := LHP->LHP_Conta
									@ _nRow,199 SAY STR0058 OF oPrincipal PIXEL //'Banco'
									@ _nRow,218 MSGET _cBanco Picture '@!' When .F. Size 15,07 OF oPrincipal PIXEL
									@ _nRow,246 SAY STR0059 OF oPrincipal PIXEL //'Ag.'
									@ _nRow,257 MSGET _cAgenci Picture '@!' When .F. Size 20,07 OF oPrincipal PIXEL
									@ _nRow,293 SAY STR0060 OF oPrincipal PIXEL //'Conta'
									@ _nRow,311 MSGET _cConta Picture '@!' When .F. Size 40,07 OF oPrincipal PIXEL

									_nRow+=4
									_cHosped := LHP->LHP_HHosp
									@ _nRow,007 SAY STR0061 OF oPrincipal PIXEL //'Hotel'
									@ _nRow,025 MSGET _cHosped Picture '@!' Size 170,07 When .F. OF oPrincipal PIXEL

									_cSolPor := LHP->LHP_SolPor
									_cHrSolP := LHP->LHP_HrSolP
									_cAprov  := LHP->LHP_Aprov
									_cHrApv1 := LHP->LHP_HrApv1
									_cSolFin := LHP->LHP_SolFin
									_cHrSolF := LHP->LHP_HrSolF
									_cAprovF := LHP->LHP_AprovF
									_cHrApv2 := LHP->LHP_HrApv2

									_nRow+=15
									@ _nRow,003 TO _nRow+18,359 OF oPrincipal PIXEL
									_nRow+=5
									@ _nRow,007 SAY STR0062 OF oPrincipal PIXEL //'Solicitado por'
									@ _nRow,045 MSGET _cSolPor Picture '@!' Size 30,07 When .F. OF oPrincipal PIXEL

									If LHP->LHP_Flag == 'P'
										If LHP->LHP_Flag1 == 'P'
											@ _nRow,080 SAY STR0063 OF oPrincipal PIXEL //'Aprovado por '
											@ _nRow,119 MSGET _cAprov Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
										Else
											@ _nRow,080 SAY STR0064 OF oPrincipal PIXEL //'Reprovado por'
											@ _nRow,119 MSGET _cAprov Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
										Endif
									Else
										@ _nRow,080 SAY STR0063 OF oPrincipal PIXEL //'Aprovado por '
										@ _nRow,119 MSGET _cAprov Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
									Endif

									@ _nRow,154 SAY STR0065 OF oPrincipal PIXEL //'Solicitante Depto Viagem'
									@ _nRow,217 MSGET _cSolFin Picture '@!' Size 30,07 When .F. OF oPrincipal PIXEL

									If LHP->LHP_Flag1 == 'P'
										@ _nRow,254 SAY STR0066 OF oPrincipal PIXEL //'Reprovado Depto Financeiro'
										@ _nRow,327 MSGET _cAprovF Picture '@!' Size 20,073 When .F. OF oPrincipal PIXEL
									Else
										@ _nRow,254 SAY STR0067 OF oPrincipal PIXEL //'Aprovador Depto Financeiro'
										@ _nRow,327 MSGET _cAprovF Picture '@!' Size 20,07 When .F. OF oPrincipal PIXEL
									Endif

									_nRow+=15
									@ _nRow,003 TO _nRow+18,359 OF oPrincipal PIXEL
									_nRow+=5
									@ _nRow,007 SAY STR0068 OF oPrincipal PIXEL //'Solicitado às '
									@ _nRow,045 SAY _cHrSolP OF oPrincipal PIXEL

									If LHP->LHP_Flag == 'P'
										If LHP->LHP_Flag1 == 'P'
											@ _nRow,080 SAY STR0069 OF oPrincipal PIXEL //'Aprovado às  '
											@ _nRow,119 SAY _cHrApv1 OF oPrincipal PIXEL
										Else
											@ _nRow,080 SAY STR0070 OF oPrincipal PIXEL //'Reprovado às '
											@ _nRow,119 SAY _cHrApv1 OF oPrincipal PIXEL
										Endif
									Else
										@ _nRow,080 SAY STR0069 OF oPrincipal PIXEL //'Aprovado às  '
										@ _nRow,119 SAY _cHrApv1 OF oPrincipal PIXEL
									Endif

									@ _nRow,154 SAY STR0071 OF oPrincipal PIXEL //'Solicitado Depto Viagem às'
									@ _nRow,223 SAY _cHrSolF OF oPrincipal PIXEL

									If LHP->LHP_Flag1 == 'P'
										@ _nRow,254 SAY STR0072 OF oPrincipal PIXEL //'Reprovado Depto Financeiro às'
										@ _nRow,332 SAY _cHrApv2  OF oPrincipal PIXEL
									Else
										@ _nRow,254 SAY STR0073 OF oPrincipal PIXEL //'Aprovado Depto Financeiro às'
										@ _nRow,332 SAY _cHrApv2 OF oPrincipal PIXEL
									Endif

									ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {||lOk:=.T.,CloseWindow(oPrincipal)}, {||lOk:=.F.,CloseWindow(oPrincipal)})
									If lOk
										nOpc := Aviso(STR0074,STR0075,{STR0077,STR0076}) //"Aprovar"###"Deseja aprovar a solicitação?"###"SIM"###"NAO"
										If nOpc == 2
											lAprov  := .T.
										EndIf
									Else
										nOpc := Aviso(STR0078,STR0079,{STR0077,STR0076}) //"Reprovar"###"Deseja reprovar a solicitação?"###"SIM"###"NAO"
										If nOpc == 2
											lReprov := .T.
										EndIf
									EndIf
									If lAprov
										Do Case
										Case nAprov = 1
											If Val(Substr(cTipoAp,1,1)) # 1
												MsgInfo(STR0080) //"Colaborador não possui permissão para aprovação/reprovação"
											ElseIf Empty(LHP->LHP_DGRAR)
												dbSelectArea("LHP")
												LHP->(dbSetOrder(1))
												RecLock('LHP', .F.)
												LHP->LHP_FLAG   := "A"
												LHP->LHP_FLAG1  := "A"
												LHP->LHP_APROVF := LHP->LHP_SUPIMD
												LHP->LHP_HRAPV2 := Substr(Time(),1,5)
												LHP->LHP_DTAPR2 := date()
												LHP->LHP_APROV  := LHP->LHP_SUPIMD
												LHP->LHP_HRAPV1 := Substr(Time(),1,5)
												LHP->LHP_DTAPR1 := date()
												MsUnlock()
											Else
												dbSelectArea("LHP")
												LHP->(dbSetOrder(1))
												RecLock('LHP', .F.)
												LHP->LHP_FLAG   := "A"
												LHP->LHP_FLAG1  := "D"
												LHP->LHP_APROV  := LHP->LHP_SUPIMD
												LHP->LHP_HRAPV1 := Substr(Time(),1,5)
												LHP->LHP_DTAPR1 := date()
												MsUnlock()
											Endif
										Case nAprov = 2
											If Val(Substr(cTipoAp,2,1)) # 1
												MsgInfo(STR0080) //"Colaborador não possui permissão para aprovação/reprovação"
											ElseIf Empty(LHP->LHP_DGRAR)
												dbSelectArea("LHP")
												LHP->(dbSetOrder(1))
												RecLock('LHP', .F.)
												LHP->LHP_FLAG   := "A"
												LHP->LHP_FLAG1  := "A"
												LHP->LHP_APROVF := LHP->LHP_SUPIMD
												LHP->LHP_HRAPV2 := Substr(Time(),1,5)
												LHP->LHP_DTAPR2 := date()
												LHP->LHP_APROV  := LHP->LHP_SUPIMD
												LHP->LHP_HRAPV1 := Substr(Time(),1,5)
												LHP->LHP_DTAPR1 := date()
												MsUnlock()
											Else
												dbSelectArea("LHP")
												LHP->(dbSetOrder(1))
												RecLock('LHP', .F.)
												LHP->LHP_FLAG1  := "A"
												LHP->LHP_APROVF := LHP->LHP_DGRAR
												LHP->LHP_HRAPV2 := Substr(Time(),1,5)
												LHP->LHP_DTAPR2 := date()
												MsUnlock()
											Endif
										EndCase
									ElseIf lReprov
										Do Case
										Case nAprov = 1
											If Val(LHT->LHT_FLAGAP) <> 1
												MsgInfo(STR0080) //"Colaborador não possui permissão para aprovação/reprovação"
											Else
												dbSelectArea("LHP")
												LHP->(dbSetOrder(1))
												RecLock('LHP', .F.)
												LHP->LHP_FLAG   := 'P'
												LHP->LHP_FLAG1  := 'P'
												LHP->LHP_APROV  := LHP->LHP_SUPIMD
												LHP->LHP_HRAPV1 := Substr(Time(),1,5)
												LHP->LHP_DTAPR1 := Date()
												MsUnlock()
											Endif

										Case nAprov = 2
											If Val(LHT->LHT_APFIN) <> 1
												MsgInfo(STR0080) //"Colaborador não possui permissão para aprovação/reprovação"
											Else
												dbSelectArea("LHP")
												LHP->(dbSetOrder(1))
												RecLock('LHP', .F.)
												LHP->LHP_FLAG   := 'P'
												LHP->LHP_FLAG1  := 'P'
												LHP->LHP_APROVF := LHP->LHP_DGRAR
												LHP->LHP_HRAPV2 := Substr(Time(),1,5)
												LHP->LHP_DTAPR2 := Date()
												MsUnlock()
											Endif
										EndCase
									EndIf

									Return(Nil)
									*--------------------------------------------------------------------------------------


									*--------------------------------------------------------------------------------------
User Function EditaTxt(_cTitulo, _cTexto, _lEdita)
	*--------------------------------------------------------------------------------------
	Local _cTextoOld := _cTexto
	Local _cTextoNew := '' , oEditaTexto

	ChkTemplate("CDV")

	DEFINE MSDIALOG oEditaTexto FROM  000,000 TO 200,365 TITLE OemToAnsi(_cTitulo) PIXEL

	@ 005,005 GET _oTexto VAR _cTexto MEMO When _lEdita Size 175,075 OF oEditaTexto PIXEL

	DEFINE SBUTTON FROM 084,120 TYPE 1 ENABLE OF oEditaTexto ACTION (nOpca:=1,_cTextoNew:= TextoOk(_cTexto,oEditaTexto))
	DEFINE SBUTTON FROM 084,150 TYPE 2 ENABLE OF oEditaTexto ACTION (nOpca:=0,_cTextoNew:= TextoOk(_cTextoOld,oEditaTexto))

	ACTIVATE MSDIALOG oEditaTexto CENTERED

Return(_cTextoNew)
	*--------------------------------------------------------------------------------------


	*--------------------------------------------------------------------------------------
Static Function TextoOK(_cQualTexto,oEditaTexto)
	*--------------------------------------------------------------------------------------
	oEditaTexto:End()

Return(_cQualTexto)
	*--------------------------------------------------------------------------------------

	*----------------------------------------------------------------------------------------
Static Function CloseWindow(oPrincipal)

	oPrincipal:End()

	If _lRetLHQ
		RestArea(_aAreaLHP1)
	Endif

Return(Nil)
