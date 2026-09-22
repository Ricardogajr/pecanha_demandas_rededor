#INCLUDE "AE_Wf001.ch"
#INCLUDE "Protheus.ch"


/*-----------------------------------------------------------------------------+
* Programa  * WF001  º Business Inteligence            * Data ³  12/02/2003    *
*------------------------------------------------------------------------------*
* Autores: Luciana / Willy                                                     *
* Objetivo  * Arquivo de Controle de Processos do Workflow de Solicitação de   *
*           * Viagem				                                           *
+------------------------------------------------------------------------------+
| Parametros| _nOpcao =  1   - Envio                                           |
|           |            2   - Retorno da Liberacao                            |
|           |            3   - Time-out                                        |
*---------------------------------------------------------------------------- */
/*+----------------------------------------------------------------------------+
| OPCAO     | _cOpcao =  SC   - 1º Fase - Envio da Solicitação de Viagem       |
|           |            SCV  - 2º Fase - Envio ao Depto de Viagem             |
|           |            SCA  - 3º Fase - Envio ao Financeiro - Agencia        |
*-----------------------------------------------------------------------------*/

User Function AEWF001(_nOpcao, _nRecno, _ltimeSup, _cOpcao, oProcess)

	Local _aAreaLHPW	:= GetArea()
	Local _lTimeout 	:= .T.
	Local _lReturn  	:= .T.
	Local _lGeraTimeout	:= .F.
	Local _lWFANAC1 	:= .F.
	Local _nDiasVia 	:= 0
	Local _cAprovFin	:= " "
	Local _nQuem
	Local _aArea 
	Local aAreaSA2
	Local _cCodFornec	:= Space(TamSx3("A2_COD")[1])
	Local _cLoja		:= "01"
	Local _aFornec		:= {}
	Local _cErro 		:= .F.
	Local _lEnvAgencia	:= .T.
	Local _lEnvFinan	:= .T.
	Local _cUsLogin		:= Space(15)
	Local _cCodLojaF 	:= Space(TamSx3("A2_Loja")[1])
	Local _cBanco 		:= Space(TamSx3("A2_Banco")[1])
	Local _cAgencia 	:= Space(TamSX3("A2_Agencia")[1])
	Local _cConta 		:= Space(TamSX3("A2_Numcon")[1])
	Local _dVencRea 	:= Date()
	Local cParcela		:= AllTrim(SuperGetMV("MV_PARADIA",.F.,""))
	Local cParcela02	:= StrZero(0,TamSX3("E2_PARCELA")[1]) 
	Local _lGeraFin	:= GetMv("MV_GERAFIN")
	Local cPasta	:= "\messenger\emp"+ cEmpAnt + "\"
	Local cArqHTM	:= CriaTrab( NIL , .F. ) + ".htm" 
	Local nHdl		:= Fcreate(cPasta+ "\" +cArqHTM)
	Local cBuffer	:= ""

	Private lMSErroAuto	:= .F.
	Private _cProcesso 	:= Space(TamSx3("LHP_CODIGO")[1])

	ChkTemplate("CDV")

	//Abertura dos arquivos a serem usados
	ChkFile("LHP")
	ChkFile("LHT")
	Do Case
		Case _nOpcao == 1 // Envio
		//Se nao for Agencia, seta "SUP" para processo, devido
		//a semelhanca nos dois processos , tanto do 1º quanto do 2º.
		//Envia para o primeiro aprovador.
		If _cOpcao <> "SCA"
			_aDest := U_AEDefDest(_nRecno,"",_nOpcao,"SUP",_cOpcao)
		Endif
		If _cOpcao == "SC"        // 1º Fase
			_csubject := STR0001 //"Processo de Liberação - Solicitação de Viagem "
		Elseif _cOpcao == "SCA"  // 3º Fase
			DbSelectArea("LHP")
			LHP->(dbSetOrder(1))
			LHP->(DbGoTo(_nRecno))
			_cSubject := LHP->LHP_CODIGO + STR0002			
		Else                     // 2º Fase
			_cSubject := STR0003 //"Processo de Liberação - Autorizador Financeiro Depto Viagem"
		Endif
		RecLock('LHP', .F.)
		//Status definido como envio
		LHP->LHP_Status := '1'
		//Se for Departamento de Viagem atualiza os dois campos
		If _cOpcao == "SCV"
			If GetMv("MV_EAUTOM2")
				LHP->LHP_SOLFIN := LHP->LHP_SOLPOR				
			Else
				LHP->LHP_SolFin := SubStr(cUsuario,7,15)
			EndIf
			LHP->LHP_HrSolF := Time()
			LHP->LHP_DTSOL2 := dDataBase
		ElseIf _cOpcao == "SC"
			LHP->LHP_DTSOL1 := dDataBase //Data da Primeira Solicitacao de Aprovacao
			LHP->LHP_HrSolP := Time() //Hora da Primeira Solicitacao de Aprovacao
		Endif
		MsUnlock()
		If _cOpcao <> "SCA"
			//Se nao for Agencia envia normalmente para os outros 2 processos
			oProcess  := U_AEMontaEml("H1", _nRecno, _aDest[1],_aDest[3], "1",_cOpcao, oProcess,cPasta,cArqHtm)
		Else
			If LHP->LHP_ADIANT == .T. .AND. LHP->LHP_HOSPED == .F. .AND. LHP->LHP_PASSAG == .F.
				U_AEMailFin(_nRecNo,"ADI") // Envia e-mail simples, sem os campos de hosp/pass
			Else                               
				//Se nao envia e-mail para Agencia com os campos abertos para digitacao
				oProcess  := U_AEMontaEml("H5", _nRecno,          ,         , "1",_copcao, oProcess,cPasta,cArqHtm)
			Endif
			//Todos os e-mails da 3º Fase (Agencia) nao possuem time-out
			_lTimeout := .F.
		Endif
		If GetMv("MV_EAUTOM2")
			_cAprovacao := "S"		
		Else
			_cAprovacao := ""					
		EndIf
		Case _nOpcao == 2 // Retorno (Liberação e Rejeição)
		_cStatus    := oProcess:oHtml:RetByName("STATUS")
		_nRecNo 	:= oProcess:oHtml:RetByName("LHP_RECNO")
		_cOpcao 	:= oProcess:oHtml:RetByName("LHP_OPCAO")

		If _cOpcao <> "SCA" //1 e 2 º Processo - Identifica resposta
			_cAprovador := oProcess:oHtml:RetByName("APROVADOR")
			_cAprovacao := oProcess:oHtml:RetByName("Aprovacao")
		Else                //3 º Processo - Nao Identifica resposta e seta "S"
			_cAprovacao := "S"   //Aprovacao Financeiro (MV_WFAGTUR)
		Endif                                                 
		_cRet		:= oProcess:cRetFrom
		_nRecNo     := Val(_nRecNo)

		//Verifica quem respondeu o e-mail para enviar um informativo do resultado
		dbSelectArea("LHP")
		LHP->(dbSetOrder(1))
		LHP->(dbGoTo(_nRecno))
		_nDiasVia := LHP->LHP_Chegad - LHP->LHP_Saida
		If LHP->LHP_FatMic == 100 .AND. _nDiasVia >= GetMv("MV_DIAPROV")
			_lWFANAC1:= .T.
		EndIf
		If AllTrim(_cStatus) <> AllTrim(LHP->LHP_STATUS)
			Return
		Endif

		If _cOpcao == "SC"       // 1º Fase
			If	AllTrim(_cAprovador) == AllTrim(LHP->LHP_SUPIMD)
				_aDest := U_AEDefDest(_nRecNo,_cAprovacao,_nOpcao,"SUP",_cOpcao)
			Else
				_aDest := U_AEDefDest(_nRecNo,_cAprovacao,_nOpcao,"GAR",_cOpcao)
			Endif

		ElseIf _cOpcao == "SCV"  // 2º Fase
			_aDest := U_AEDefDest(_nRecNo,_cAprovacao,_nOpcao,"SUP",_cOpcao)
		EndIf

		If _cAprovacao == "S"
			_lReturn  := .F.
			_lTimeout := .F.
			If _cOpcao == "SCA"
				_aArWLHQ:= GetArea()
				dbSelectArea('LHQ')
				LHQ->(dbSetOrder(1))
				If LHQ->(MsSeek(xFilial('LHQ') + LHP->LHP_Codigo))
					RecLock('LHQ',.F.)
					LHQ->LHQ_HorSai := oProcess:oHtml:RetByName("LHP_HORAID")
					LHQ->LHQ_HorChg := oProcess:oHtml:RetByName("LHP_HORAVT")
					MsUnLock('LHQ')
				EndIf
				RestArea(_aArWLHQ)
			EndIf
			RecLock('LHP',.F.)
			//3º Fase , atualiza Base de Dados
			If _cOpcao == "SCA"
				LHP->LHP_VOOIDA := oProcess:oHtml:RetByName("LHP_VOOIDA")
				LHP->LHP_HORAID := oProcess:oHtml:RetByName("LHP_HORAID")
				LHP->LHP_AIRIDA := oProcess:oHtml:RetByName("LHP_AIRIDA")
				LHP->LHP_VOOVTA := oProcess:oHtml:RetByName("LHP_VOOVTA")
				LHP->LHP_HORAVT := oProcess:oHtml:RetByName("LHP_HORAVT")
				LHP->LHP_AIRVTA := oProcess:oHtml:RetByName("LHP_AIRVTA")
				LHP->LHP_VLHOSP := VAL(oProcess:oHtml:RetByName("LHP_VLHOSP"))
				LHP->LHP_HHOSP	:= oProcess:oHtml:RetByName("LHP_HHOSP")
				LHP->LHP_VLPASS := VAL(oProcess:oHtml:RetByName("LHP_VLPASS"))
				LHP->LHP_HPASS	:= oProcess:oHtml:RetByName("LHP_HPASS")
				If LHP->LHP_PASSAG == .T. .AND. LHP->LHP_HOSPED == .T.
					LHP->LHP_OKPASS := .T.
					LHP->LHP_OKHOSP := .T.
				ElseIF LHP->LHP_HOSPED == .T.
					LHP->LHP_OKHOSP := .T.
				ElseIF LHP->LHP_PASSAG == .T.
					LHP->LHP_OKPASS := .T.
				EndIf
				//Envia e-mail para o Financeiro (Colaborador/Solicitante) no retorno
				//do e-mail da Agencia, nao importando se Status do Adiantamento
				//estiver .F.
				//Ponto de Entrada 
				If ExistBlock("RetAgViag")
					ExecBlock("RetAgViag", .F., .F.,{ _nRecNo })
				EndIf

				U_AEMailFin(_nRecNo,"ALL") // Envia e-mail completo
				oProcess:lTimeOut := .F.
				oProcess:bTimeOut := {}
				oProcess:bReturn  := ""
			Endif
			//Atualiza Flag para aprovada
			_cSubject := STR0004 //'Solicitação Aprovada Inválida. Pois o Código da Solicitação está Preenchido !'
			If _cOpcao == "SC"
				If Empty(LHP->LHP_Codigo)
					LHP->LHP_Flag  := 'A'       //Atualiza Flag aprovada 1º Fase
					LHP->LHP_Flag1 := 'D'       //Altera Flag da proxima Fase para "Aguardando"
					LHP->LHP_Aprov := _aDest[3] //Atualiza Quem Aprovou 1º Fase
					LHP->LHP_HRAPV1:= Time()    //Que horas aprovou 1º Fase
					LHP->LHP_DTAPR1:= dDataBase //Data da Aprovacao
					_cSubject     := STR0005 //"Solicitação de Viagem Aprovada"
				Endif
			ElseIf _cOpcao == "SCV"
				If Empty(LHP->LHP_Codigo)
					LHP->LHP_Flag1 := 'A'       //Atualiza Flag aprovada 2º Fase
					LHP->LHP_AprovF:= _aDest[3] //Atualiza Quem Aprovou 2º Fase
					LHP->LHP_HRAPV2:= Time()    //Que horas aprovou 2º Fase
					LHP->LHP_DTAPR2:= dDataBase //Data da Aprovacao
					_cSubject      := STR0006 //"Solicitação de Viagem Aprovada - Depto de Viagens"
				Endif
			ElseIf _cOpcao == "SCA"
				LHP->LHP_Flag1 := 'E' // Se for Agencia atualiza Flag para E
				Return
			Endif
			MsUnLock('LHP')
			_aDest := U_AEDefDest(_nRecNo,_cAprovacao,_nOpcao,"FUNC",_copcao)
			oProcess:Finish()
			IF _cOpcao <> "SCA"
				oProcess  := U_AEMontaEml("H2", _nRecNo,_aDest[1], _aDest[3],"1" ,_copcao,oProcess,cPasta,cArqHtm)
			Endif
		Else
			_lReturn  := .F.
			_lTimeout := .F.
			//Atualiza Flag para reprovada
			RecLock('LHP', .F.)
			_cSubject := STR0007 //'Solicitação Reprovada Inválida, pois o Código da Solicitação está Preenchido !'
			If _cOpcao == "SC"
				If Empty(LHP->LHP_Codigo)
					LHP->LHP_Flag := 'P' 
					LHP->LHP_Flag1 := 'P'
					LHP->LHP_Aprov:= _aDest[3]
					LHP->LHP_HRAPV1:= TIME()
					LHP->LHP_DTAPR1:= dDataBase //Data da Reprovacao
					_cSubject     := STR0008 //"Solicitação de Viagem Reprovada"
				Endif
			Else
				If Empty(LHP->LHP_Codigo)
					LHP->LHP_Flag  := 'P'
					LHP->LHP_Flag1 := 'P'
					LHP->LHP_AprovF:= _aDest[3]
					LHP->LHP_HRAPV2:= TIME()
					LHP->LHP_DTAPR2:= dDataBase //Data da Reprovacao
					_cSubject      := STR0009 //"Solicitação de Viagem Reprovada - Depto de Viagens"
				Endif
			Endif
			MsUnLock('LHP')
			oProcess:Finish() //Incluido em 05/05/04
			IF _cOpcao <> "SCA"
				oProcess  := U_AEMontaEml("H2",_nRecNo,_aDest[1], _aDest[3] ,"1",_cOpcao,oProcess,cPasta,cArqHtm)
			Endif
		Endif
		Case _nOpcao == 3 // Time-out
		If _lTimeSup == .F.
			_aDest := U_AEDefDest(_nRecno,"",_nOpcao,"GAR",_cOpcao)
			dbSelectArea("LHP")
			LHP->(dbSetOrder(1))
			LHP->(dbGoTo(_nRecno))
			If _cOpcao == "SC" .And. LHP->LHP_Flag == 'I'
				_lGeraTimeout:= .T.
			ElseIf _cOpcao == "SCV" .And. LHP->LHP_Flag1 == 'I'
				_lGeraTimeout:= .T.
			EndIf
			RecLock('LHP',.F.)
			//Status definido como time-out do superior
			LHP->LHP_Status := '2'
			MsUnlock()
			//E-mail de situacao da Solicitação de Viagem, envia e-mail para o aprovador
			//anterior avisando que o e-mail nao obteve resposta
			U_AEMAILCONF(_nRecNo,  "2", "SUP",_cOpcao,oProcess)
			If _cOpcao == "SC"  // 1º Fase
				_csubject := STR0010 //"Processo de Liberação - Solicitação de Viagem - Aprovador II"
			Else                // 2º Fase , pois a 3º Fase nao possui Time-out
				_csubject := STR0011 //"Processo de Liberação - Depto Viagem 2 Autorizador"
			EndIf
			oProcess  := U_AEMontaEml("H3",_nRecNo,_aDest[1],_aDest[3], "2", _cOpcao,oProcess,cPasta,cArqHtm)
		Else
			_aDest := U_AEDefDest(_nRecNo,"",_nOpcao,"FUNC",_cOpcao)
			LHP->(dbSelectArea("LHP"))
			LHP->(dbSetOrder(1))
			LHP->(dbGoTo(_nRecno))
			If _cOpcao == "SC" .And. LHP->LHP_Flag == 'I'
				_lGeraTimeout:= .T.
			ElseIf _cOpcao == "SCV" .And. LHP->LHP_Flag1 == 'I'
				_lGeraTimeout:= .T.
			EndIf
			RecLock('LHP',.F.)
			//Status definido como time-out do Gar
			LHP->LHP_Status := '3'
			MsUnlock()
			U_AEMAILCONF(_nRecNo,  "3", "GAR",_copcao,oProcess)
			_cSubject := STR0012 //"Processo de Liberação Finalizado sem Resposta - Solicitante"
			oProcess  := U_AEMontaEml("H4",_nRecNo,_aDest[1], _aDest[3], "3" , _cOpcao,oProcess,cPasta,cArqHtm)
			_lReturn  := .F.
			_ltimeout := .F.
			//Atualiza Flag para situacao de nao respondida
			If Empty(LHP->LHP_Codigo)
				RecLock('LHP',.F.)
				If _cOpcao == "SC"
					If LHP->LHP_Flag == 'I'
						LHP->LHP_Flag := 'D'
					Endif
				Else
					If LHP->LHP_Flag1 == 'I'
						LHP->LHP_Flag1 := 'D'
					Endif
				Endif
				MsUnLock('LHP')
			Endif
		Endif
	EndCase

	If _cOpcao == "SCA"   // 3º Fase
		_cMailTo := GetMV("MV_WFAGTUR")
		If ExistBlock("PE1WF001")
			_cMailTo := ExecBlock("PE1WF001", .F., .F.)
		EndIf
	Else
		_cMailTo := _aDest[1] // As Demais Fases
	Endif

	If oProcess <> NIL
		If _ltimeout
			IF _aDest[2] = "GAR"
				_lTimeSup:= .T.
			EndIF
			oProcess:bTimeOut := {}
			//Calcula com o conteudo do parametro o estouro do time-out
			aInterv := U_AEcalchora(AllTrim(GETMV("MV_WFTEMP")))
			aHoras := U_AEConsisteData(aInterv[1])
			//Adiciona linha na tabela de Agendamento (SXM)
			aAdd(oProcess:bTimeOut, {'U_AEWF001(3,' + AllTrim(str(_nRecNo)) + "," + IIF(_ltimeSup,".T.",".F.") + ",'" + _cOpcao + "')" , aHoras[1] , aHoras[2] ,aHoras[3]})
		Else
			oProcess:lTimeOut := .F.
			oProcess:bTimeOut := {}
		Endif
		If _lReturn
			//Grava Retorno
			oProcess:bReturn  := "U_AEWF001(2,,,)"
		Else
			//Nao possui Retorno
			oProcess:bReturn  := ""
		Endif
		oProcess:cSubject := _csubject
		oProcess:cTo      := _cMailTo
		If ExistBlock("CUSU_ENV")
			ExecBlock("CUSU_ENV",.F.,.F.,{_nOpcao,oProcess})
		Else
			oProcess:Start()
			cBuffer := oProcess:oHtml:HtmlCode()		
			If File(cPasta + cArqHtm)    
				FClose(nHdl)
				FOpen(cPasta + cArqHtm,2)	   	
				If nHdl > -1
					FWrite(nHdl,cBuffer,Len(cBuffer))
					FClose(nHdl)
				EndIf
			EndIf		
		EndIf
	Endif

	//Envio automatico de e-mail para o segundo aprovador
	If _cOpcao == "SC" .And. _nOpcao == 2 .And. _cAprovacao == "S"
		If GetMv("MV_EAUTOM2")
			RecLock('LHP', .F.)
			LHP->LHP_Flag  := 'M'
			LHP->LHP_FLAG1 := 'I'
			LHP->(MsUnLock())
			_nRecno := LHP->(RECNO())
			U_AEWF001(1,_nRecno,.F.,"SCV",NIL)
		EndIf
	EndIf

	//Envio automatico de e-mail para a agencia de viagens e o financeiro 
	If _cOpcao == "SCV" .And. _nOpcao == 2	.And. _cAprovacao == "S"
		If ExistBlock("PE_APRV2")
			ExecBlock("PE_APRV2", .F., .F.)
		EndIf
		If GetMv("MV_EAUTOM3")
			//Valida se o colaborador esta cadastrado como fornecedor
			aAreaSA2 := SA2->(GetArea())
			DbSelectArea('SA2')
			DbOrderNickName('SA2CDV6')
			If !MsSeek(xFilial('SA2') + LHP->LHP_Func)
				//Procurar dados no cadastro de colaborador
				DbSelectArea('LHT')
				DbSetOrder(1)
				If MsSeek(xFilial('LHT') + LHP->LHP_Func)
					_cBanco	  := LefT(LHT->LHT_BCDEPS, 3)
					_cAgencia := Right(LHT->LHT_BCDEPS, 5)
					_cConta   := LHT->LHT_CTDEPS
				EndIf

				//Rotina automatica para cadastro do colaborador como fornecedor
				_cCodFornec := GetSxEnum("SA2", "A2_COD")
				_aFornec := {	{"A2_FILIAL", 	xFilial("SA2"), 	Nil},;
				{"A2_COD", 		_cCodFornec, 		Nil},;
				{"A2_LOJA", 	_cLoja, 			Nil},;
				{"A2_NOME", 	LHP->LHP_NFUNC, 	Nil},;
				{"A2_NREDUZ", 	LHP->LHP_NFUNC, 	Nil},;
				{"A2_BANCO", 	_cBanco,		 	Nil},;
				{"A2_AGENCIA",	_cAgencia, 			Nil},;
				{"A2_NUMCON", 	_cConta,		 	Nil},;
				{"A2_END", 		STR0013, 	Nil},; //"Colaborador CDV"
				{"A2_MUN", 		STR0013, 	Nil},; //"Colaborador CDV"
				{"A2_EST", 		STR0014, 				Nil},; //"SP"
				{"A2_TIPO", 	"F", 				Nil},;
				{"A2_MAT", 		LHP->LHP_FUNC,		Nil} }

				MsExecAuto( {|x, y| Mata020(x, y)}, _aFornec, 3) //3 = Opcao de inclusao

				If lMSErroAuto //Se ocorreu erro na inclusao do fornecedor
					RollBackSX8()
					_cErro := .T.
				Else
					ConfirmSX8()
				EndIf
			EndIf
			_cCodFornec	:= SA2->A2_Cod
			_cCodLojaF	:= SA2->A2_Loja
			_cBanco   	:= SA2->A2_Banco
			_cAgencia	:= SA2->A2_Agencia
			_cConta  	:= SA2->A2_Numcon
			//Restauro a Area do SA2
			RestArea(aAreaSA2)
			If ! _cErro
				dbSelectArea('LHT')
				LHT->(dbSetOrder(1))
				LHT->(MsSeek(xFilial('LHT') + LHP->LHP_Func))
				_cUsLogin := AllTrim(LHT->LHT_LOGIN)
			EndIf		

			//Criar o codigo do processo para essa solicitação.....
			If ! _cErro
				dbSelectArea('LHP')
				_cProcesso := GetSxeNum('LHP','LHP_CODIGO')
				//Valida percentual a faturar
				If LHP->LHP_FatCLi + LHP->LHP_FatFra + LHP->LHP_FatMic <> 100
					_cErro := .F.
				Endif
			Endif
			If ! _cErro
				//Gravar dados e enviar
				Begin Transaction
					RecLock('LHP', .F.)
					LHP->LHP_Codigo:= _cProcesso
					LHP->LHP_OkAdia:= .T.
					LHP->LHP_FLAG  := 'E'
					LHP->LHP_FLAG1 := 'E'
					MsUnLock('LHP')

					_aAreaLHQ := GetArea()

					dbSelectArea('LHQ')
					LHQ->(dbSetOrder(1))
					RecLock('LHQ',.T.)
					LHQ->LHQ_Filial	:= xFilial('LHQ')
					LHQ->LHQ_Codigo	:= _cProcesso
					LHQ->LHQ_EmpCli	:= LHP->LHP_EmpCLi
					LHQ->LHQ_Func	:= LHP->LHP_Func
					LHQ->LHQ_SupImd	:= LHP->LHP_SupImd
					LHQ->LHQ_Saida	:= LHP->LHP_Saida
					LHQ->LHQ_HoraId	:= LHP->LHP_HoraId
					LHQ->LHQ_Chegad	:= LHP->LHP_Chegad
					LHQ->LHQ_HoraVt	:= LHP->LHP_HoraVt
					LHQ->LHQ_CC		:= LHP->LHP_CC
					LHQ->LHQ_FatCli	:= LHP->LHP_FatCLi
					LHQ->LHQ_FatFra	:= LHP->LHP_FatFra
					LHQ->LHQ_FatMic	:= LHP->LHP_FatMic
					LHQ->LHQ_Flag	:= 'V'
					LHQ->LHQ_DGRar	:= LHP->LHP_DGRar
					LHQ->LHQ_SolPor	:= LHP->LHP_SolPor
					LHQ->LHQ_Login	:= _cUsLogin
					MsUnLock('LHQ')

					If LHP->LHP_Saida - 1 <= dDatabase + 1
						_dVencRea := DataValida(dDatabase + 1)
					Else
						If Dow(LHP->LHP_Saida) == 2 .And. LHP->LHP_Emiss < LHP->LHP_Saida - 2
							_dVencRea := DataValida(LHP->LHP_Saida - 3)
						Else
							_dVencRea := DataValida(LHP->LHP_Saida - 1)
						Endif
					Endif

					If LHP->LHP_ValorR > 0
						aGrvSe2 := {{ "E2_Filial"	, xFilial("SE2")					, Nil },;
						{ "E2_CCUsto"	, LHP->LHP_CC						, Nil },;
						{ "E2_PREFIXO"	, AllTrim(GetMV('MV_PREADIA')), Nil },;
						{ "E2_PARCELA"	, cParcela							, Nil },; 			
						{ "E2_NUM"		, _cProcesso						, Nil },;
						{ "E2_TIPO"		, AllTrim(GetMV('MV_TIPADIA')), Nil },;
						{ "E2_NATUREZ"	, GetMv('MV_U_NATUR')			, Nil },;
						{ "E2_FORNECE"	, _cCodFornec						, Nil },;
						{ "E2_LOJA"   	, _cCodLojaF						, Nil },;
						{ "E2_NOMFOR"	, LHP->LHP_NFunc			 		, Nil },;
						{ "E2_EMISSAO"	, dDataBase							, Nil },;
						{ "E2_VENCTO"	, _dVencRea							, Nil },;
						{ "E2_VENCREA"	, _dVencRea							, Nil },;
						{ "E2_VALOR"  	, LHP->LHP_ValorR					, Nil },;
						{ "E2_SALDO"  	, LHP->LHP_ValorR					, Nil },;
						{ "E2_MOEDA"	, 1									, Nil },;
						{ "E2_VLCRUZ" 	, LHP->LHP_ValorR					, Nil },;
						{ "E2_ORIGEM" 	, 'FINA050'							, Nil },;
						{ "E2_EMIS1" 	, dDataBase							, Nil },;
						{ "E2_VENCORI" , _dVencRea							, Nil },;
						{ "E2_RATEIO" 	, 'N'									, Nil },;
						{ "E2_OCORREN" , '01'								, Nil },;
						{ "E2_FLUXO" 	, 'S'									, Nil },;
						{ "E2_PORTADO"	, _cBanco							, Nil },;
						{ "E2_DESDOBR" , 'N'									, Nil } }

						If AllTrim(GetMV('MV_TIPADIA')) $ MVPAGANT
							AADD(aGrvSe2,{"AUTBANCO"	,_cBanco						, Nil })
							AADD(aGrvSe2,{"AUTAGENCIA"	,_cAgencia					, Nil })
							AADD(aGrvSe2,{"AUTCONTA"	,_cConta						, Nil })				
						EndIf						

						If ExistBlock("GRAVASE2") 
							aGrvSe2 := ExecBlock("GRAVASE2", .F., .F.,{_cProcesso, aGrvSe2})
						EndIf						

						MsExecAuto({ | x,y,z | Fina050(x,y,z) }, aGrvSe2,, 3) // 3- Opcao de Inclusao
						If lMSErroAuto
							DisarmTransaction()
							MSUNLOCKALL()
							MsgInfo(STR0015+CHR(13)+CHR(10)+STR0016) //'Ocorreu um erro na gravação do Adiantamento.'###'Verifique a mensagem de erro e caso necessário abra um chamado no help desk para que esse erro seja corrigido.'
							If (!IsBlind()) // COM INTERFACE GRÁFICA
								MostraErro() // TELA
							Else // EM ESTADO DE JOB
								cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

								ConOut(PadC("Automatic routine ended with error", 80))
								ConOut("Error: "+ cError)
							EndIf

							break 
						Endif

						//Apos a gravacao do titulo. gravar referencia do titulo de PA gerado na despesa de viagem
						If _lGeraFin .AND. LHP->(FieldPos("LHP_DOCUME")) # 0
							Reclock("LHP",.F.,.T.)
							LHP->LHP_DOCUME	:= (xFilial("SE2") + PadR(AllTrim(GetMV('MV_PREADIA')),TamSX3("E2_PREFIXO")[1]) + PadR(_cProcesso,TamSX3("E2_NUM")[1]) + ;
							PadR(AllTrim(GetMV('MV_PARADIA')),TamSX3("E2_PARCELA")[1]) + ;
							PadR(AllTrim(GetMV('MV_TIPADIA')),TamSX3("E2_TIPO")[1]) + _cCodFornec + _cCodLojaF)
							MsUnlock("LHP")
						Endif			
					EndIf
					//Viagem internacional
					If LHP->LHP_EINTER
						If LHP->LHP_ValorU > 0
							If LHP->LHP_ValorR > 0	
								//Caso jah tenha sido gravado um titulo para valores em Reais, manter o mesmo processo e alterar apenas a parcela, 
								//para facilitar a rastreabilidade
								If Empty(cParcela)
									cParcela02 := Soma1(cParcela02,Len(cParcela02))
								Else                           
									cParcela02 := Soma1(AllTrim(cParcela),Len(cParcela02))
								Endif
							Else
								cParcela02 := cParcela
							Endif

							aGrvSe2 := {{ "E2_Filial"	, xFilial("SE2")				, Nil },;
							{ "E2_CCUsto"	, LHP->LHP_CC					, Nil },;
							{ "E2_PREFIXO"	, AllTrim(GetMV('MV_PREADIA'))	, Nil },;
							{ "E2_NUM"		, _cProcesso					, Nil },;
							{ "E2_TIPO"		, AllTrim(GetMV('MV_TIPADIA'))	, Nil },;
							{ "E2_NATUREZ"	, GetMv('MV_U_NATUR')			, Nil },;
							{ "E2_FORNECE"	, _cCodFornec					, Nil },;
							{ "E2_LOJA"   	, _cCodLojaF					, Nil },;
							{ "E2_NOMFOR"	, LHP->LHP_NFunc			 	, Nil },;
							{ "E2_EMISSAO"	, dDataBase						, Nil },;
							{ "E2_VENCTO"	, _dVencRea						, Nil },;
							{ "E2_VENCREA"	, _dVencRea						, Nil },;
							{ "E2_VALOR"  	, LHP->LHP_ValorU				, Nil },;
							{ "E2_SALDO"  	, LHP->LHP_ValorU				, Nil },;
							{ "E2_MOEDA"	, 2								, Nil },;
							{ "E2_VLCRUZ" 	, xMoeda(LHP->LHP_ValorU,2,1,dDataBase), Nil },;
							{ "E2_PARCELA"	, cParcela02					, Nil },; 			
							{ "E2_ORIGEM" 	, 'FINA050'						, Nil },;
							{ "E2_Emis1" 	, dDataBase						, Nil },;
							{ "E2_VencOri" 	, _dVencRea						, Nil },;
							{ "E2_Rateio" 	, 'N'							, Nil },;
							{ "E2_Ocorren" 	, '01'							, Nil },;
							{ "E2_Fluxo" 	, 'S'							, Nil },;
							{ "E2_Desdobr" 	, 'N'							, Nil } }

							If ExistBlock("GRVSE2_U") 
								aGrvSe2 := ExecBlock("GRVSE2_U", .F., .F.,{_cProcesso, aGrvSe2})
							EndIf													

							MsExecAuto({ | x,y,z | Fina050(x,y,z) }, aGrvSe2,, 3) // 3- Opcao de Inclusao
							If lMSErroAuto
								DisarmTransaction()
								MSUNLOCKALL()
								MsgInfo(STR0017+CHR(13)+CHR(10)+STR0016) //'Ocorreu um erro na gravação do Contas a Pagar.'###'Verifique a mensagem de erro e caso necessário abra um chamado no help desk para que esse erro seja corrigido.'
								If (!IsBlind()) // COM INTERFACE GRÁFICA
									MostraErro() // TELA
								Else // EM ESTADO DE JOB
									cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

									ConOut(PadC("Automatic routine ended with error", 80))
									ConOut("Error: "+ cError)
								EndIf
								break

							Endif         
							ConfirmSX8()

							//Apos a gravacao do titulo. gravar referencia do titulo de PA gerado na solicitacao de viagem
							If LHP->(FieldPos("LHP_DOCUME")) # 0
								Reclock("LHP",.F.,.T.)
								LHP->LHP_DOCUME	:= (xFilial("SE2") + PadR(AllTrim(GetMV('MV_PREADIA')),TamSX3("E2_PREFIXO")[1]) + PadR(_cProcesso,TamSX3("E2_NUM")[1]) + ;
								PadR(AllTrim(GetMV('MV_PARADIA')),TamSX3("E2_PARCELA")[1]) + ;
								PadR(AllTrim(GetMV('MV_TIPADIA')),TamSX3("E2_TIPO")[1]) + _cCodFornec + _cCodLojaF)
								MsUnlock("LHP")
							Endif			
						EndIf
					EndIf
					ConfirmSX8()
					RestArea(_aAreaLHQ)
					U_AEWF001(1,_nRecno,.F.,"SCA",NIL)
				End Transaction
			EndIf
		EndIf
	EndIf

	RestArea(_aAreaLHPW)

Return
