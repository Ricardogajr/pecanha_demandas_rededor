#Include "Protheus.ch"

/*/{Protheus.doc} User Function F2000401
    Executa a movimentacao bancaria.
    @type  Function
    @author Gianluca Moreira
    @since 10/06/2021   
    /*/
User Function F2000401(oWSIn, oWSOut)
	Local aAreaSM0 := SM0->(GetArea())
	Local aAreas   := {aAreaSM0, GetArea()}
	Local aDesfaz  := {} //Caso seja necessário fazer rollback
	Local cEmpBkp  := cEmpAnt
	Local cFilBpk  := cFilAnt
	Local cEmpWs   := ''
	Local cFilWs   := ''
	Local cRet     := ''
	Local cOper    := ''
	Local lDesarma := .F.
	Local lEstorno := .F.
	Local nMov     := 0
	Local nDesfaz  := 0
	Local cOpDesfaz := ''
	Local cEmpDesf  := ''
	Local cFilDesf  := ''
	Local cTime    := Time()
	Local lGrpHblt := .F.
	Local dDtBkp    := dDataBase
	Local cMVTCONT  := ""
	Local lFree := .T.
	Local nTent := 0
	Local tTempoI := Time()

	Private cIdInt    := ''
	Private nRegLog   := 0
	Private _nTimeOut := SuperGetMV('FS_N200041',, 120)*1000 //ms
	Private _nTimeSt  := TimeCounter()
	Private cUserName := ""

	Conout('F2000400 - Integ XRT Movimento Bco - Iniciando... '+FwTimeStamp(2))

	//Tratamento de semáforo
	/*/While !GlbNmLock("F2000400")
	If TimeCounter()-_nTimeSt > _nTimeOut
		GrvXmlVaz(oWsOut)
		Return
	EndIf
	Sleep(500)
	EndDo/*/

	If !PreValid(oWsIn, oWsOut)
		Conout('F2000400 - Erro na Pre validacao... '+FwTimeStamp(2))
		//GlbNmUnlock("F2000400")
		Return
	EndIf

	Conout('F2000400 - Pre validou... '+FwTimeStamp(2))


	__cUserId := "005026"
	cUserName := "Integrador"
	For nMov := 1 To Len(oWsIn:Movimentos)
		cEmpWs   := oWSIn:Movimentos[nMov]:EMP
		cFilWs   := oWSIn:Movimentos[nMov]:FIL
		cOper    := Upper(AllTrim(oWSIn:Movimentos[nMov]:OPERAC))
		lEstorno := oWSIn:Movimentos[nMov]:ESTORNO == '1'

		cIdInt 	:= ''
		nRegLog := 0

		Conout('F2000400 - Laco principal '+FwTimeStamp(2))
		cEmpAnt := cEmpWs
		cFilAnt := cFilWs
		cMVTCONT := oWSIn:Movimentos[nMov]:FK5_XCDXRT
		lFree := MayIUseCode(cMVTCONT)

		If !lFree
			nTent := 0
			While !(lFree := MayIUseCode(cMVTCONT))
				nTent++
				Conout("Esperando integração do código -> " + cMVTCONT)
				Sleep(2000)
				if nTent > 3
					cRet    := "A Chave "+cMVTCONT+" não foi incluída. Controle de Semáforo."
					XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., cRet)
					Loop
				endif
			enddo
		endif

		If lDesarma
			cRet    := 'Erro em outra linha do Par. Revertendo todas as alterações...'
			XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., cRet)
			Loop
		EndIf
		//If !FWFilExist("01", cFilWs)
		if !ExistCpo("SM0",cEmpWs+cFilWs)
			Conout('F2000401 - Integ XRT - Empresa '+cEmpWs+' Filial '+cFilWs+' não encontrada')
			cRet    := 'Empresa '+cEmpWs+' Filial '+cFilWs+' não encontrada'
			lDesarma := .T.
			XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., cRet)
			Loop
		EndIf

		If cEmpAnt != cEmpWs .Or. cFilAnt != cFilWs
           /*/ RpcSetType(3)
			If !RpcSetEnv(cEmpWs, cFilWs, 'Administrador',,'FIN')
				Conout('F2000400 - Integ XRT - Falha ao preparar ambiente')
				cRet := 'Falha ao preparar ambiente'
				lDesarma := .T.
				XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., cRet)
				Loop
            EndIf/*/
				cEmpAnt := cEmpWs
				cFilAnt := cFilWs
				SM0->(DbSeek(cEmpAnt+cFilAnt))
			EndIf

			Conout('F2000400 - logou empresa '+cEmpAnt+cFilAnt+''+FwTimeStamp(2))

			cIdInt 	:= U_GetIntegID()
			//nRegLog := U_F07LOG01(cIdInt, {oWSIn:Movimentos[nMov]}, 'U_F2000400')

			dDataBase := SToD(oWSIn:Movimentos[nMov]:E5_DATA)
			If cOper == 'FINANCEIRO'
				If !lEstorno
					If !IncMvBco(oWSIn:Movimentos[nMov], oWsOut, aDesfaz)
						lDesarma := .T.
					EndIf
				Else
					If !EstMvBco(oWSIn:Movimentos[nMov], oWsOut, aDesfaz)
						lDesarma := .T.
					EndIf
				EndIf
			ElseIf cOper == 'BAIXA'
				If !lEstorno
					If !BaixaOpFin(oWSIn:Movimentos[nMov], oWsOut, aDesfaz)
						lDesarma := .T.
					EndIf
				Else
					If !EstBxOpFin(oWSIn:Movimentos[nMov], oWsOut, aDesfaz)
						lDesarma := .T.
					EndIf
				EndIf
			Else
				Conout('F2000400 - Integ XRT - Operacao Invalida '+cOper)
				cRet := 'Operacao Invalida '+cOper
				lDesarma := .T.
				XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., cRet)
				Loop
			EndIf

			Conout('F2000400 - encerrou empresa '+cEmpAnt+cFilAnt+' '+FwTimeStamp(2))

			cIdInt 	:= ''
			nRegLog := 0
		Next nMov

		dDataBase := dDtBkp

		//Grava erro em todas as linhas para retornar
		If lDesarma
			For nMov := 1 To Len(oWsOut:ITENS)
				oWsOut:ITENS[nMov]:RETSTATUS := EncodeUTF8('E')
				If Empty(oWsOut:ITENS[nMov]:RETMSG)
					oWsOut:ITENS[nMov]:RETMSG := 'Erro em outra linha do Par. Revertendo todas as alterações...'
				EndIf
				Conout('F2000400 - '+oWsOut:ITENS[nMov]:RETMSG)
			Next nMov

			//Devido a particularidade do banco de dados ORACLE, não é possível desarmar transação
			//onde foi executada rotina automática que também usa transação, pois os dados já são
			//efetivados em banco de dados, ignorando a transação aberta anteriormente.
			//Por conta disso, caso seja necessário desarmar, deve-se executar todo o processo
			//inverso.
			//Para mais informações, veja:
			//https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020775851-MP-ADVPL-BEGIN-TRANSACTION
			//
			//Para o processo inverso, foram adicionadas as variaveis aDesfaz e aRet dentro das rotinas,
			//que coletam as informações de execuções bem sucedidas, no caso de haver necessidade
			//de desfazer a movimentação.

			For nDesfaz := 1 To Len(aDesfaz)
				cOpDesfaz := aDesfaz[nDesfaz, 1]
				cEmpDesf  := aDesfaz[nDesfaz, 2]
				cFilDesf  := aDesfaz[nDesfaz, 3]

				If cEmpAnt != cEmpDesf .Or. cFilAnt != cFilDesf
                /*/RpcSetType(3)
                RpcSetEnv(cEmpDesf, cFilDesf, "Administrador","", "FIN" )       /*/         
					cEmpAnt := cEmpDesf
					cFilAnt := cFilDesf
					SM0->(DbSeek(cEmpAnt+cFilAnt))
				EndIf

				If cOpDesfaz == 'INCMVBCO'
					DesfIncBco(aDesfaz[nDesfaz])
				ElseIf cOpDesfaz == 'ESTMVBCO'
					DesfEstBco(aDesfaz[nDesfaz])
				ElseIf cOpDesfaz == 'BAIXAOPFIN'
					DesfBxaOpf(aDesfaz[nDesfaz])
				ElseIf cOpDesfaz == 'ESTBXOPFIN'
					DesfEstBxa(aDesfaz[nDesfaz])
				EndIf
			Next nDesfaz
		EndIf

		//Restaura ambiente
		If cEmpAnt != cEmpBkp .Or. cFilAnt != cFilBpk
        /*/RpcSetType(3)
        RpcSetEnv(cEmpBkp, cFilBpk, "Administrador","", "FIN" )/*/
			cEmpAnt := cEmpBkp
			cFilAnt := cFilBpk
			SM0->(DbSeek(cEmpAnt+cFilAnt))
		EndIf

		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aDesfaz)

		Conout('F2000400 - encerrando... '+FwTimeStamp(2))

		//Destrava o semáforo
		//GlbNmUnlock("F2000400")
		Conout("Tempo total de processamento da função F2000400: " + Elaptime(tTempoI,Time()))
		Return

/*/{Protheus.doc} PreValid
    Pré valida alguns dados das rotinas automáticas
    @type  Static Function
    @author Gianluca Moreira
    @since 13/07/2021
    @version version
    /*/
Static Function PreValid(oWsIn, oWsOut)
	Local aAreaSM0 := SM0->(GetArea())
	Local aAreaSED := SED->(GetArea())
	Local aAreaSA6 := SA6->(GetArea())
	Local aAreaCTT := CTT->(GetArea())
	Local aAreas   := {aAreaSM0, aAreaSED, aAreaSA6, aAreaCTT, GetArea()}
	Local aRet     := {}
	Local cEmpBkp  := cEmpAnt
	Local cFilBpk  := cFilAnt
	Local cEmpWs   := ''
	Local cFilWs   := ''
	Local cChave   := ''
	Local cRet     := ''
	Local lRet     := .T.
	Local nRet     := 0
	Local nMov     := 0
	Local lGrpHblt := .F.

	SED->(DbSetOrder(1)) //ED_FILIAL + ED_CODIGO
	SA6->(DbSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
	CTT->(DbSetOrder(1)) //CTT_FILIAL + CTT_CUSTO

	For nMov := 1 To Len(oWsIn:Movimentos)
		cEmpWs   := oWSIn:Movimentos[nMov]:EMP
		cFilWs   := oWSIn:Movimentos[nMov]:FIL
		cOper    := Upper(AllTrim(oWSIn:Movimentos[nMov]:OPERAC))
		lEstorno := oWSIn:Movimentos[nMov]:ESTORNO == '1'
		AAdd(aRet, 'Pre validando dados - Erro em outra linha do Par...')
		nRet := Len(aRet)
		//If !FWFilExist("01", cFilWs)
		If !ExistCpo("SM0",cEmpWs+cFilWs)
			Conout('F2000401 - Integ XRT - Empresa '+cEmpWs+' Filial '+cFilWs+' não encontrada')
			cRet := 'Empresa '+cEmpWs+' Filial '+cFilWs+' não encontrada'
			aRet[nRet] := cRet
			lRet := .F.
			Loop
		EndIf

		If cEmpAnt != cEmpWs .Or. cFilAnt != cFilWs
            /*/RpcSetType(3)
			If !RpcSetEnv(cEmpWs, cFilWs, 'Administrador',,'FIN')
				Conout('F2000400 - Integ XRT - Falha ao preparar ambiente')
				cRet := 'Falha ao preparar ambiente'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
            EndIf/*/
				cEmpAnt := cEmpWs
				cFilAnt := cFilWs
				SM0->(DbSeek(cEmpAnt+cFilAnt))
			EndIf

			If lEstorno .And. Empty(oWSIn:Movimentos[nMov]:CHVORIG)
				cRet := 'Codigo do registro a estornar nao informado'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			If cOper != 'FINANCEIRO' .And. cOper != 'BAIXA'
				cRet := 'Operacao Invalida '+cOper
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

			//Integração não habilitada neste grupo
			If !lGrpHblt
				cRet := 'Empresa/Filial: '+cEmpAnt+'/'+cFilAnt+' não habilitada para integracao.'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			If oWsIn:Movimentos[nMov]:E5_VALOR <= 0
				cRet := 'Valor: '+cValToChar(oWsIn:Movimentos[nMov]:E5_VALOR)+' inválido.'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			cChave := AvKey(oWsIn:Movimentos[nMov]:E5_NATUREZ, 'ED_CODIGO')
			If cOper == 'FINANCEIRO' .And. !SED->(DbSeek(FWXFilial('SED')+cChave))
				cRet := 'Natureza: '+cValToChar(cChave)+' inválida.'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			cChave := AvKey(oWsIn:Movimentos[nMov]:E5_BANCO,   'A6_COD')
			cChave += AvKey(oWsIn:Movimentos[nMov]:E5_AGENCIA, 'A6_AGENCIA')
			cChave += AvKey(oWsIn:Movimentos[nMov]:E5_CONTA,   'A6_NUMCON')
			If !SA6->(DbSeek(FWXFilial('SA6')+cChave))
				cRet := 'Banco/Agencia/Conta: '+cValToChar(cChave)+' inválidos.'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			cChave := AvKey(oWsIn:Movimentos[nMov]:E5_CCD, 'CTT_CUSTO')
			If !Empty(cChave) .And. !CTT->(DbSeek(FWXFilial('CTT')+cChave))
				cRet := 'Centro de Custo Débito: '+cValToChar(cChave)+' inválido.'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf

			cChave := AvKey(oWsIn:Movimentos[nMov]:E5_CCC, 'CTT_CUSTO')
			If !Empty(cChave) .And. !CTT->(DbSeek(FWXFilial('CTT')+cChave))
				cRet := 'Centro de Custo Crédito: '+cValToChar(cChave)+' inválido.'
				aRet[nRet] := cRet
				lRet := .F.
				Loop
			EndIf
		Next nMov

		If !lRet
			For nMov := 1 To Len(aRet)
				cEmpWs   := oWSIn:Movimentos[nMov]:EMP
				cFilWs   := oWSIn:Movimentos[nMov]:FIL

				//If !FWFilExist("01", cFilWs)
				If !ExistCpo("SM0",cEmpWs+cFilWs)
					cEmpAnt := cEmpBkp
					cFilAnt := cFilBpk
					SM0->(DbSeek(cEmpAnt+cFilAnt))
					XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., aRet[nMov])
					Loop
				EndIf

				If cEmpAnt != cEmpWs .Or. cFilAnt != cFilWs
                /*/RpcSetType(3)
					If !RpcSetEnv(cEmpWs, cFilWs, 'Administrador',,'FIN')
						cEmpAnt := cEmpBkp
						cFilAnt := cFilBpk
						SM0->(DbSeek(cEmpAnt+cFilAnt))
						XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., aRet[nMov])
						Loop
                EndIf/*/
						cEmpAnt := cEmpWs
						cFilAnt := cFilWs
						SM0->(DbSeek(cEmpAnt+cFilAnt))
					EndIf

					XMLRetorno(oWSIn:Movimentos[nMov], oWsOut, .F., aRet[nMov])
				Next nMov
			EndIf

			//Restaura ambiente
			If cEmpAnt != cEmpBkp .Or. cFilAnt != cFilBpk
       /*/ RpcSetType(3)
        RpcSetEnv(cEmpBkp, cFilBpk, "Administrador","", "FIN" )/*/
				cEmpAnt := cEmpBkp
				cFilAnt := cFilBpk
				SM0->(DbSeek(cEmpAnt+cFilAnt))
			EndIf

			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aRet)
			Return lRet


/*/{Protheus.doc} IncMvBco
    Inclui um movimento bancario
    @type  Static Function
    @author Gianluca Moreira
    @since 10/06/2021
    /*/
Static Function IncMvBco(oMov, oWsOut, aRet)
	Local aAreaSE5 := SE5->(GetArea())
	Local aAreaFK5 := FK5->(GetArea())
	Local aAreas   := {aAreaSE5, aAreaFK5, GetArea()}
	Local aFINA100 := {}
	Local aFINA380 := {}
	Local lRet     := .T.
	Local nOpc     := 0
	Local cCtbOn   := SuperGetMV('FS_C200040',, '')
	Local nRecSE5  := 0
	Local nRet     := 0
	Local lXrTreta := .F.

	Conout('F2000400 - Inicio lancto bancario '+FwTimeStamp(2))

	//RecnoSE5, RecnoFK5, lConcilou
	AAdd(aRet, {'INCMVBCO', cEmpAnt, cFilAnt, 0, 0, .F.})
	nRet := Len(aRet)

	nOpc := IIf(oMov:E5_RECPAG == 'P', 3, 4)
	If Empty(oMov:FK5_XPCXRT) .Or. Empty(oMov:FK5_XCDXRT)
		XMLRetorno(oMov, oWsOut, .F., 'Codigo e/ou Par Contabil nao informados')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA100)
		Return .F.
	EndIf

	FK5->(DBOrderNickName('FSW2000404')) //FK5_FILIAL+FK5_XCDXRT+FK5_XPCXRT
	SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
	If FK5->(DbSeek(FWXFilial('FK5')+AvKey(oMov:FK5_XCDXRT, 'FK5_XCDXRT')+AvKey(oMov:FK5_XPCXRT, 'FK5_XPCXRT')))
		If SE5->(DbSeek(FWXFilial('SE5')+FK5->FK5_IDMOV))
			XMLRetorno(oMov, oWsOut, .T., 'Movimento ja incluso anteriormente.')
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			lRet := .T.
			Return lRet //Ja incluso anteriormente, nao precisa desarmar a transacao.
		EndIf
	EndIf

	AAdd(aFINA100, {'E5_FILIAL',  FWXFilial('SE5'),   Nil})
	AAdd(aFINA100, {"E5_DATA",    SToD(oMov:E5_DATA), Nil})
	AAdd(aFINA100, {"E5_MOEDA",   oMov:E5_MOEDA,      Nil})
	AAdd(aFINA100, {"E5_VALOR",   oMov:E5_VALOR,      Nil})
	AAdd(aFINA100, {"E5_NATUREZ", oMov:E5_NATUREZ,    Nil})
	AAdd(aFINA100, {"E5_BANCO",   oMov:E5_BANCO,      Nil})
	AAdd(aFINA100, {"E5_AGENCIA", oMov:E5_AGENCIA,    Nil})
	AAdd(aFINA100, {"E5_CONTA",   oMov:E5_CONTA,      Nil})
	If !Empty(oMov:E5_CCD)
		AAdd(aFINA100, {"E5_CCUSTO", oMov:E5_CCD,     Nil})
	EndIf
	If !Empty(oMov:E5_CCC)
		AAdd(aFINA100, {"E5_CCUSTO", oMov:E5_CCC,     Nil})
	EndIf
	AAdd(aFINA100, {"E5_BENEF",   oMov:E5_BENEF,      Nil})
	AAdd(aFINA100, {"E5_HISTOR",  oMov:E5_HISTOR,     Nil})
	AAdd(aFINA100, {"E5_XPCXRT",  oMov:FK5_XPCXRT,    Nil})
	AAdd(aFINA100, {"E5_XCODXRT", oMov:FK5_XCDXRT,    Nil})
	AAdd(aFINA100, {"E5_XINTXRT", 'Sim',              Nil})
	aFINA100 := FWVetByDic(aFINA100, 'SE5')

	If !Empty(cCtbOn)
		AAdd(aFINA100, {"NCTBONLINE", Val(cCtbOn),    Nil})
	EndIf

	Private lMsErroAuto   := .F.
	Private lMsHelpAuto   := .F.
	Private lAutoErrNoFile:= .T.

	Conout('F2000400 - Antes ExecAuto '+FwTimeStamp(2))
	DbSelectArea("SE8")
	DbSetOrder(1)
	SetFunName('FINA100')
	MSExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aFINA100, nOpc)

	Conout('F2000400 - Depois ExecAuto '+FwTimeStamp(2))

	If lMsErroAuto
		cRet := cMontaErr()
		lRet := .F.
	Else
	Conout("Inicio xRTRETA "+TIME())
		lXrTreta := fXRTRETA(oMov)
	Conout("FIM XRTRETA " +TIME())

		If lXrTreta
			lRet := .F.
			cRet := 'O movimento não foi integrado, favor realizar o reprocessamento do MVTCONTADOR'
		Else
			nRecSE5 := SE5->(Recno())
			aRet[nRet, 4] := nRecSE5 //Caso seja necessário estornar este movimento
			If SE5->E5_TABORI == 'FK5' .And. SE5->E5_MOVFKS == 'S'
				FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
				If FK5->(DbSeek(FWXFilial('FK5')+SE5->E5_IDORIG))
					aRet[nRet, 5] := FK5->(Recno()) //Caso seja necessário estornar este movimento
					If RecLock('FK5', .F.)
						FK5->FK5_XPCXRT := oMov:FK5_XPCXRT
						FK5->FK5_XCDXRT := oMov:FK5_XCDXRT
						FK5->(MsUnlock())
						lRet := .T.
						cRet := ''
					Else
						lRet := .F.
						cRet := 'Nao foi possivel obter acesso exclusivo para gravar o registro FK5.'
					EndIf
				Else
					lRet := .F.
					cRet := 'Movimento FK5 nao encontrado'
				EndIf
			Else
				lRet := .F.
				cRet := 'Movimento FK5 nao integrado automaticamente'
			EndIf

			//Conciliacao
			If lRet
				AAdd(aFINA380, {nRecSE5, .T., .T., ''})
				U_F2000310(aFINA380)
				If !aFINA380[1, 3]
					lRet := .F.
					cRet := 'Falha na conciliacao: '+aFINA380[1, 4]
				EndIf
				aRet[nRet, 6] := lRet //Caso seja necessário estornar este movimento
			EndIf
		EndIf
	EndIf

	Conout('F2000400 - Encerrando lancto... '+FwTimeStamp(2))

	XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE5)
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA100)
Return lRet

/*/{Protheus.doc} DesfIncBco
    Desfaz a inclusão de uma movimentação bancária
    @type  Static Function
    @author Gianluca Moreira
    @since 07/07/2021
    /*/
Static Function DesfIncBco(aMov)
	Local aAreaSE5  := SE5->(GetArea())
	Local aAreaFK5  := FK5->(GetArea())
	Local aAreaFKA  := FKA->(GetArea())
	Local aAreas    := {aAreaSE5, aAreaFK5, aAreaFKA, GetArea()}
	Local aFINA100  := {}
	Local aFINA380  := {}
	Local cCtbOn    := SuperGetMV('FS_C200040',, '')
	Local lRet      := .T.
	Local nRecSE5   := aMov[4]
	Local nRecFK5   := aMov[5]
	Local lConcilou := aMov[6]
	Local dDtBkp    := dDataBase

	//Se conciliou, desconcilia
	If lConcilou
		SE5->(DbGoto(nRecSE5))
		dDataBase := SE5->E5_DATA
		AAdd(aFINA380, {nRecSE5, .F., .T., ''})
		U_F2000310(aFINA380)
		If !aFINA380[1, 3]
			lRet := .F.
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			dDataBase := dDtBkp
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			Return lRet
		EndIf
	EndIf

	//Apaga campos customizados
	If nRecFK5 > 0
		FK5->(DbGoto(nRecFK5))
		If RecLock('FK5', .F.)
			FK5->FK5_XPCXRT := ''
			FK5->FK5_XCDXRT := ''
			FK5->(MsUnlock())
		EndIf
	EndIf

	If nRecSE5 > 0
		SE5->(DbGoto(nRecSE5))
		dDataBase := SE5->E5_DATA
		If RecLock('SE5', .F.)
			SE5->E5_XPCXRT  := ''
			SE5->E5_XCODXRT := ''
			SE5->E5_XINTXRT := ''
			SE5->(MsUnlock())
		EndIf

		//Exclui movimento bancário
		AAdd(aFINA100, {"E5_DATA",    SE5->E5_DATA,    Nil})
		AAdd(aFINA100, {"E5_MOEDA",   SE5->E5_MOEDA,   Nil})
		AAdd(aFINA100, {"E5_VALOR",   SE5->E5_VALOR,   Nil})
		AAdd(aFINA100, {"E5_NATUREZ", SE5->E5_NATUREZ, Nil})
		AAdd(aFINA100, {"E5_BANCO",   SE5->E5_BANCO,   Nil})
		AAdd(aFINA100, {"E5_AGENCIA", SE5->E5_AGENCIA, Nil})
		AAdd(aFINA100, {"E5_CONTA",   SE5->E5_CONTA,   Nil})
		AAdd(aFINA100, {"E5_HISTOR",  SE5->E5_HISTOR,  Nil})
		AAdd(aFINA100, {"E5_TIPOLAN", SE5->E5_TIPOLAN, Nil})
		AAdd(aFINA100, {"E5_XPCXRT",  SE5->E5_XPCXRT , Nil})
		AAdd(aFINA100, {"E5_XCODXRT", SE5->E5_XCODXRT, Nil})
		AAdd(aFINA100, {"E5_XINTXRT", 'Sim',           Nil})
		aFINA100 := FWVetByDic(aFINA100, 'SE5')

		/*/If !Empty(cCtbOn)
		AAdd(aFINA100, {"NCTBONLINE", Val(cCtbOn),    Nil})
		EndIf/*/

		Private lMsErroAuto   := .F.
		Private lMsHelpAuto   := .F.
		Private lAutoErrNoFile:= .T.

		SetFunName('FINA100')
		MSExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aFINA100, 5) //Exclusão

		If lMsErroAuto
			lRet := .F.
		EndIf
	EndIf

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA100)
	dDataBase := dDtBkp
Return lRet

/*/{Protheus.doc} EstMvBco
    Estorna um movimento bancario
    @type  Static Function
    @author Gianluca Moreira
    @since 10/06/2021
    /*/
Static Function EstMvBco(oMov, oWsOut, aRet)
	Local aAreaSE5  := SE5->(GetArea())
	Local aAreaFK5  := FK5->(GetArea())
	Local aAreaFKA  := FKA->(GetArea())
	Local aAreas    := {aAreaSE5, aAreaFK5, aAreaFKA, GetArea()}
	Local aFINA100  := {}
	Local aFINA380  := {}
	Local cCtbOn    := SuperGetMV('FS_C200040',, '')
	Local cIdProc   := ''
	Local lRet      := .T.
	Local nRecSE5   := 0
	Local nRecSE5Es := 0
	Local nRet      := 0

	//RecnoSE5Ori, RecnoFK5Ori, lDesconcilou, nRecnoSE5Est, nRecnoFK5Est
	AAdd(aRet, {'ESTMVBCO', cEmpAnt, cFilAnt, 0, 0, .F., 0, 0})
	nRet := Len(aRet)

	If Empty(oMov:FK5_XPCXRT) .Or. Empty(oMov:FK5_XCDXRT)
		XMLRetorno(oMov, oWsOut, .F., 'Codigo e/ou Par Contabil nao informados')
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA100)
		Return .F.
	EndIf

	If Empty(oMov:CHVORIG)
		XMLRetorno(oMov, oWsOut, .F., 'Codigo do registro a estornar nao informada')
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA100)
		Return .F.
	EndIf

	FK5->(DBOrderNickName('FSW2000404')) //FK5_FILIAL+FK5_XCDXRT+FK5_XPCXRT
	SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
	If FK5->(DbSeek(FWXFilial('FK5')+AvKey(oMov:FK5_XCDXRT, 'FK5_XCDXRT')+AvKey(oMov:FK5_XPCXRT, 'FK5_XPCXRT')))
		If SE5->(DbSeek(FWXFilial('SE5')+FK5->FK5_IDMOV))
			XMLRetorno(oMov, oWsOut, .T., 'Movimento(s) ja estornado(s) anteriormente.')
			lRet := .T.
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			Return lRet //Estorno já lançado, não precisa lançar de novo
		EndIf
	EndIf

	If FK5->(DbSeek(FWXFilial('FK5')+AvKey(oMov:CHVORIG, 'FK5_XCDXRT')))
		If !SE5->(DbSeek(FWXFilial('SE5')+FK5->FK5_IDMOV))
			XMLRetorno(oMov, oWsOut, .F., 'Movimento origem nao encontrado.')
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			Return .F.
		EndIf
	Else
		XMLRetorno(oMov, oWsOut, .F., 'Movimento origem nao encontrado.')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA100)
		Return .F.
	EndIf

	nRecSE5 := SE5->(Recno())

	//Desconcilia
	AAdd(aFINA380, {nRecSE5, .F., .T., ''})
	U_F2000310(aFINA380)
	If !aFINA380[1, 3]
		lRet := .F.
		cRet := 'Falha na desconciliacao: '+aFINA380[1, 4]
		XMLRetorno(oMov, oWsOut, lRet, cRet)
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA100)
		Return lRet
	EndIf

	aRet[nRet, 4] := SE5->(Recno()) //Recno do SE5 original
	aRet[nRet, 5] := FK5->(Recno()) //Recno do FK5 original
	aRet[nRet, 6] := .T. //Desconciliou o registro

	AAdd(aFINA100, {"E5_DATA",    SE5->E5_DATA,    Nil})
	AAdd(aFINA100, {"E5_MOEDA",   SE5->E5_MOEDA,   Nil})
	AAdd(aFINA100, {"E5_VALOR",   SE5->E5_VALOR,   Nil})
	AAdd(aFINA100, {"E5_NATUREZ", SE5->E5_NATUREZ, Nil})
	AAdd(aFINA100, {"E5_BANCO",   SE5->E5_BANCO,   Nil})
	AAdd(aFINA100, {"E5_AGENCIA", SE5->E5_AGENCIA, Nil})
	AAdd(aFINA100, {"E5_CONTA",   SE5->E5_CONTA,   Nil})
	AAdd(aFINA100, {"E5_HISTOR",  SE5->E5_HISTOR,  Nil})
	AAdd(aFINA100, {"E5_TIPOLAN", SE5->E5_TIPOLAN, Nil})
	AAdd(aFINA100, {"E5_XPCXRT",  SE5->E5_XPCXRT , Nil})
	AAdd(aFINA100, {"E5_XCODXRT", SE5->E5_XCODXRT, Nil})
	AAdd(aFINA100, {"E5_XINTXRT", 'Sim',           Nil})
	aFINA100 := FWVetByDic(aFINA100, 'SE5')

	If !Empty(cCtbOn)
		AAdd(aFINA100, {"NCTBONLINE", Val(cCtbOn),    Nil})
	EndIf

	Private lMsErroAuto   := .F.
	Private lMsHelpAuto   := .F.
	Private lAutoErrNoFile:= .T.

	SetFunName('FINA100')
	MSExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aFINA100, 6) //Cancelamento

	If lMsErroAuto
		cRet := cMontaErr()
		lRet := .F.
	Else
		//Desmarca a desconciliação, pois a nova inclusão terá de ser conciliada de qualquer forma
		aRet[nRet, 6] := .F.

		lRet := .F.
		cRet := 'Movimento de estorno não encontrado.'
		//Grava os campos customizados no estorno
		SE5->(DbGoto(nRecSE5)) //Registro do lançamento original
		FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
		FKA->(DbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG

		If !FK5->(DbSeek(FWXFilial('FK5')+SE5->E5_IDORIG))
			XMLRetorno(oMov, oWsOut, lRet, cRet)
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			Return lRet
		EndIf

		If !FKA->(DbSeek(FWXFilial('FKA')+'FK5'+FK5->FK5_IDMOV))
			XMLRetorno(oMov, oWsOut, lRet, cRet)
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			Return lRet
		EndIf

		cIdProc := FKA->FKA_IDPROC
		FKA->(DbSetOrder(2)) //FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
		If !FKA->(DbSeek(FWXFilial('FKA')+cIdProc))
			XMLRetorno(oMov, oWsOut, lRet, cRet)
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA100)
			Return lRet
		EndIf

		While !FKA->(EoF()) .And. FKA->(FKA_FILIAL+FKA_IDPROC) == FWXFilial('FKA')+cIdProc
			If FKA->FKA_TABORI != 'FK5'
				FKA->(DbSkip())
				Loop
			EndIf
			If FK5->(DbSeek(FWXFilial('FK5')+FKA->FKA_IDORIG))
				If FK5->FK5_TPDOC != 'ES'
					FKA->(DbSkip())
					Loop
				EndIf

				SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
				If SE5->(DbSeek(FWXFilial('SE5')+FK5->FK5_IDMOV))
					nRecSE5Es := SE5->(Recno())
					aRet[nRet, 7] := SE5->(Recno()) //Caso seja necessário desfazer o estorno
					aRet[nRet, 8] := FK5->(Recno())
					If RecLock('FK5', .F.)
						FK5->FK5_XPCXRT := oMov:FK5_XPCXRT
						FK5->FK5_XCDXRT := oMov:FK5_XCDXRT
						FK5->(MsUnlock())
						If RecLock('SE5', .F.)
							SE5->E5_XPCXRT  := oMov:FK5_XPCXRT
							SE5->E5_XCODXRT := oMov:FK5_XCDXRT
							SE5->E5_XINTXRT := 'Sim'
							SE5->(MsUnlock())
							lRet := .T.
							cRet := ''
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			FKA->(DbSkip())
		EndDo
	EndIf

	XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE5Es)
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA100)
Return lRet

/*/{Protheus.doc} DesfEstBco
    Desfaz o estorno bancário, em caso de falha na rotina
    @type  Static Function
    @author Gianluca Moreira
    @since 07/07/2021
    /*/
Static Function DesfEstBco(aMov)
	Local aAreaSE5  := SE5->(GetArea())
	Local aAreaFK5  := FK5->(GetArea())
	Local aAreas    := {aAreaSE5, aAreaFK5, GetArea()}
	Local aFINA100  := {}
	Local aFINA380  := {}
	Local lRet      := .T.
	Local nOpc      := 0
	Local cCtbOn    := SuperGetMV('FS_C200040',, '')
	Local nRecSE5   := 0
	Local nSE5Ori   := aMov[4]
	Local nFK5Ori   := aMov[5]
	Local lDesconc  := aMov[6]
	Local nSE5Est   := aMov[7]
	Local nFK5Est   := aMov[8]
	Local cParCont  := ''
	Local cCodXRT   := ''
	Local cIdP19    := ''
	Local dDtBkp    := dDataBase

	//Apenas desconciliou o registro, mas houve falha no estorno, então reconcilia
	If lDesconc
		SE5->(DbGoto(nSE5Ori))
		dDataBase := SE5->E5_DATA
		AAdd(aFINA380, {nSE5Ori, .T., .T., ''})
		U_F2000310(aFINA380)
		If !aFINA380[1, 3]
			lRet := .F.
		EndIf
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA100)
		dDataBase := dDtBkp
		Return lRet
	EndIf

	//Caso tenha efetivado o estorno, é preciso lançar novamente o registro
	//depois de limpar os campos customizados
	If nSE5Ori > 0
		SE5->(DbGoto(nSE5Ori))
		dDataBase := SE5->E5_DATA
		cParCont := SE5->E5_XPCXRT
		cCodXRT  := SE5->E5_XCODXRT
		cIdP19   := SE5->E5_XIDP19
		If RecLock('SE5', .F.)
			SE5->E5_XPCXRT  := ''
			SE5->E5_XCODXRT := ''
			SE5->E5_XINTXRT := ''
			SE5->(MsUnlock())
		EndIf
	EndIf
	If nFK5Ori > 0
		FK5->(DbGoto(nFK5Ori))
		If RecLock('FK5', .F.)
			FK5->FK5_XPCXRT := ''
			FK5->FK5_XCDXRT := ''
			FK5->(MsUnlock())
		EndIf
	EndIf
	If nSE5Est > 0
		SE5->(DbGoto(nSE5Est))
		If RecLock('SE5', .F.)
			SE5->E5_XPCXRT  := ''
			SE5->E5_XCODXRT := ''
			SE5->E5_XINTXRT := ''
			SE5->(MsUnlock())
		EndIf
	EndIf
	If nFK5Est > 0
		FK5->(DbGoto(nFK5Est))
		If RecLock('FK5', .F.)
			FK5->FK5_XPCXRT := ''
			FK5->FK5_XCDXRT := ''
			FK5->(MsUnlock())
		EndIf
	EndIf

	If nSE5Ori > 0
		SE5->(DbGoto(nSE5Ori))
		nOpc := IIf(SE5->E5_RECPAG == 'P', 3, 4)

		AAdd(aFINA100, {'E5_FILIAL',  FWXFilial('SE5'),   Nil})
		AAdd(aFINA100, {"E5_DATA",    SE5->E5_DATA,       Nil})
		AAdd(aFINA100, {"E5_MOEDA",   SE5->E5_MOEDA,      Nil})
		AAdd(aFINA100, {"E5_VALOR",   SE5->E5_VALOR,      Nil})
		AAdd(aFINA100, {"E5_NATUREZ", SE5->E5_NATUREZ,    Nil})
		AAdd(aFINA100, {"E5_BANCO",   SE5->E5_BANCO,      Nil})
		AAdd(aFINA100, {"E5_AGENCIA", SE5->E5_AGENCIA,    Nil})
		AAdd(aFINA100, {"E5_CONTA",   SE5->E5_CONTA,      Nil})
		AAdd(aFINA100, {"E5_CCUSTO",  SE5->E5_CCUSTO,     Nil})
		AAdd(aFINA100, {"E5_BENEF",   SE5->E5_BENEF,      Nil})
		AAdd(aFINA100, {"E5_HISTOR",  SE5->E5_HISTOR,     Nil})
		AAdd(aFINA100, {"E5_XPCXRT",  cParCont,           Nil})
		AAdd(aFINA100, {"E5_XCODXRT", cCodXRT,            Nil})
		AAdd(aFINA100, {"E5_XINTXRT", 'Sim',              Nil})
		AAdd(aFINA100, {"E5_XIDP19",  cIdP19,             Nil})

		aFINA100 := FWVetByDic(aFINA100, 'SE5')

		If !Empty(cCtbOn)
			AAdd(aFINA100, {"NCTBONLINE", Val(cCtbOn),    Nil})
		EndIf

		Private lMsErroAuto   := .F.
		Private lMsHelpAuto   := .F.
		Private lAutoErrNoFile:= .T.

		SetFunName('FINA100')
		MSExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aFINA100, nOpc)

		If lMsErroAuto
			lRet := .F.
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
		Else
			nRecSE5 := SE5->(Recno())

			If SE5->E5_TABORI == 'FK5' .And. SE5->E5_MOVFKS == 'S'
				FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
				If FK5->(DbSeek(FWXFilial('FK5')+SE5->E5_IDORIG))
					If RecLock('FK5', .F.)
						FK5->FK5_XPCXRT := cParCont
						FK5->FK5_XCDXRT := cCodXRT
						FK5->(MsUnlock())
						lRet := .T.
						cRet := ''
					Else
						lRet := .F.
						cRet := 'Nao foi possivel obter acesso exclusivo para gravar o registro FK5.'
					EndIf
				Else
					lRet := .F.
					cRet := 'Movimento FK5 nao encontrado'
				EndIf
			Else
				lRet := .F.
				cRet := 'Movimento FK5 nao integrado automaticamente'
			EndIf

			//Conciliacao
			If lRet
				AAdd(aFINA380, {nRecSE5, .T., .T., ''})
				U_F2000310(aFINA380)
				If !aFINA380[1, 3]
					lRet := .F.
					cRet := 'Falha na conciliacao: '+aFINA380[1, 4]
				EndIf
			EndIf
		EndIf

	EndIf

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA100)
	dDataBase := dDtBkp
Return lRet

/*/{Protheus.doc} BaixaOpFin
    Realiza a baixa de um título a pagar de operação financeira
    @type  Static Function
    @author Gianluca Moreira
    @since 14/06/2021
    /*/
Static Function BaixaOpFin(oMov, oWsOut, aRet)
	Local aAreaSE5 := SE5->(GetArea())
	Local aAreaFK5 := FK5->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaFK2 := FK2->(GetArea())
	Local aAreaFK7 := FK7->(GetArea())
	Local aAreas   := {aAreaSE5, aAreaFK5, aAreaSE2, aAreaFK2, aAreaFK7, GetArea()}
	Local aFINA080 := {}
	Local aFINA380 := {}
	Local cNaturez := ''
	Local cOpFin   := ''
	Local cChvFK7  := ''
	Local cBanco   := ''
	Local cAgencia := ''
	Local cConta   := ''
	Local dDtVenc  := CToD('')
	Local lRet     := .T.
	Local lCtbOn   := Nil
	Local cMotBx   := SuperGetMV('FS_C200041',, '')
	Local nRecFK2  := 0
	Local nRecSE2  := 0
	Local nRet     := 0

	//RecnoSE5, RecnoFK2, lConcilou, nRecnoSE2, cBanco, cAgencia, cConta
	AAdd(aRet, {'BAIXAOPFIN', cEmpAnt, cFilAnt, 0, 0, .F., 0, '', '', ''})
	nRet := Len(aRet)

	If Empty(oMov:FK5_XPCXRT) .Or. Empty(oMov:FK5_XCDXRT)
		XMLRetorno(oMov, oWsOut, .F., 'Codigo e/ou Par Contabil nao informados')
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		Return .F.
	EndIf

	FK2->(DBOrderNickName('FSW2000406')) //FK2_FILIAL+FK2_XCDXRT+FK2_XPCXRT
	If FK2->(DbSeek(FWXFilial('FK2')+AvKey(oMov:FK5_XCDXRT, 'FK2_XCDXRT')+AvKey(oMov:FK5_XPCXRT, 'FK2_XPCXRT')))
		XMLRetorno(oMov, oWsOut, .T., 'Baixa já realizada anteriormente.')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		lRet := .T.
		Return lRet //Ja incluso anteriormente, nao precisa desarmar a transacao.
	EndIf

	dDtVenc  := SToD(oMov:E5_DATA)
	cOpFin   := StrZero(Val(oMov:E2_XOPFXRT), TamSX3('E2_XOPFXRT')[1])
	cNaturez := AvKey(oMov:E5_NATUREZ, 'E5_NATUREZ')

	SE2->(DBOrderNickName('FSW2000400')) //E2_FILIAL+DTOS(E2_VENCREA)+E2_XOPFXRT+E2_NATUREZ
	//If !SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin+cNaturez))
	//Removida natureza da chave da operação financeira do título
	If !SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin))
		XMLRetorno(oMov, oWsOut, .F., 'Título de Operação Financeira não encontrado')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		Return .F.
	EndIf

	nRecSE2 := SE2->(Recno())

	cChvFK7 := FWXFilial('SE2')+'|'
	cChvFK7 += SE2->E2_PREFIXO+ '|'
	cChvFK7 += SE2->E2_NUM+     '|'
	cChvFK7 += SE2->E2_PARCELA+ '|'
	cChvFK7 += SE2->E2_TIPO+    '|'
	cChvFK7 += SE2->E2_FORNECE+ '|'
	cChvFK7 += SE2->E2_LOJA

	cBanco   := AvKey(oMov:E5_BANCO,   'A6_COD')
	cAgencia := AvKey(oMov:E5_AGENCIA, 'A6_AGENCIA')
	cConta   := AvKey(oMov:E5_CONTA,   'A6_NUMCON')

	aRet[nRet,  8] := cBanco
	aRet[nRet,  9] := cAgencia
	aRet[nRet, 10] := cConta

	Aadd(aFINA080, {"E2_FILIAL",  FWXFilial('SE2'),     Nil})
	Aadd(aFINA080, {"E2_PREFIXO", SE2->E2_PREFIXO,      Nil})
	Aadd(aFINA080, {"E2_NUM",     SE2->E2_NUM,          Nil})
	Aadd(aFINA080, {"E2_PARCELA", SE2->E2_PARCELA,      Nil})
	Aadd(aFINA080, {"E2_TIPO",    SE2->E2_TIPO,         Nil})
	Aadd(aFINA080, {"E2_FORNECE", SE2->E2_FORNECE,      Nil})
	Aadd(aFINA080, {"E2_LOJA",    SE2->E2_LOJA,         Nil})
	Aadd(aFINA080, {"AUTMOTBX",   cMotBx,               Nil})
	Aadd(aFINA080, {"AUTBANCO",   cBanco,               Nil})
	Aadd(aFINA080, {"AUTAGENCIA", cAgencia,             Nil})
	Aadd(aFINA080, {"AUTCONTA",   cConta,               Nil})
	Aadd(aFINA080, {"AUTDTBAIXA", SToD(oMov:E5_DATA),   Nil})
	Aadd(aFINA080, {"AUTDTDEB",   SToD(oMov:E5_DATA),   Nil})
	Aadd(aFINA080, {"AUTHIST",    oMov:E5_HISTOR,       Nil})
	Aadd(aFINA080, {"AUTVLRPG",   oMov:E5_VALOR,        Nil})

	If !Empty(SuperGetMV('FS_C200044',, ''))
		lCtbOn := SuperGetMV('FS_C200044',, '') == '1'
	EndIf

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private cHistBaixa     := oMov:E5_HISTOR

	SetFunName('FINA080')
	AcessaPerg("FINA080", .F.)
	MsExecauto({|a,b,c,d,e,f| FINA080(a,b,c,d,e,f)}, aFINA080, 3, .F.,,, lCtbOn)

	If lMsErroAuto
		cRet := cMontaErr()
		lRet := .F.
	Else //Grava os campos customizados
		lRet := .F.
		cRet := 'Movimento de baixa não encontrado.'
		FK7->(DbSetOrder(2)) //FK7_FILIAL+FK7_ALIAS+FK7_CHAVE
		FK2->(DbSetOrder(2)) //FK2_FILIAL+FK2_IDDOC+FK2_SEQ
		SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
		If FK7->(DbSeek(FWXFilial('FK7')+'SE2'+cChvFK7))
			If FK2->(DbSeek(FWXFilial('FK2')+FK7->FK7_IDDOC))
				//Procura o último movimento de baixa gerado (ordenado por sequência)
				While !FK2->(EoF()) .And. FK2->(FK2_FILIAL+FK2_IDDOC) == FWXFilial('FK2')+FK7->FK7_IDDOC
					If FK2->FK2_MOTBX == AvKey(cMotBx, 'FK2_MOTBX') .And. FK2->FK2_RECPAG == 'P' .And.;
							FK2->FK2_VALOR == oMov:E5_VALOR .And.;
							Empty(FK2->FK2_XPCXRT)
						nRecFK2 := FK2->(Recno())
					EndIf
					FK2->(DbSkip())
				EndDo
				If nRecFK2 > 0
					aRet[nRet, 5] := nRecFK2
					aRet[nRet, 7] := nRecSE2
					FK2->(DbGoto(nRecFK2))
					If SE5->(DbSeek(FWXFilial('SE5')+FK2->FK2_IDFK2))
						If RecLock('FK2', .F.)
							FK2->FK2_XPCXRT := oMov:FK5_XPCXRT
							FK2->FK2_XCDXRT := oMov:FK5_XCDXRT
							FK2->(MsUnlock())
							If RecLock('SE5', .F.)
								SE5->E5_XPCXRT  := oMov:FK5_XPCXRT
								SE5->E5_XCODXRT := oMov:FK5_XCDXRT
								SE5->E5_XINTXRT := 'Sim'
								SE5->(MsUnlock())
								lRet := .T.
								cRet := ''
								aRet[nRet, 4] := SE5->(Recno())
							Else
								lRet := .F.
								cRet := 'Não foi possível obter acesso de gravação na SE5.'
							EndIf
						Else
							lRet := .F.
							cRet := 'Não foi possível obter acesso de gravação na FK2.'
						EndIf
					Else
						lRet := .F.
						cRet := 'Movimento SE5 não gerado.'
					EndIf
				Else
					lRet := .F.
					cRet := 'Movimento FK2 não gerado.'
				EndIf
			Else
				lRet := .F.
				cRet := 'Movimento FK2 não gerado.'
			EndIf
		Else
			lRet := .F.
			cRet := 'Movimento FK2 não gerado.'
		EndIf

		//Conciliacao
		If lRet
			AAdd(aFINA380, {SE5->(Recno()), .T., .T., ''})
			U_F2000310(aFINA380)
			If !aFINA380[1, 3]
				lRet := .F.
				cRet := 'Falha na conciliacao: '+aFINA380[1, 4]
			EndIf
			aRet[nRet, 6] := lRet
		EndIf
	EndIf

	XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE2)
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA080)
Return lRet

/*/{Protheus.doc} DesfBxaOpf
    Desfaz a baixa de uma operação financeira
    @type  Static Function
    @author Gianluca Moreira
    @since 08/07/2021
    /*/
Static Function DesfBxaOpf(aMov)
	Local aAreaSE5  := SE5->(GetArea())
	Local aAreaFK5  := FK5->(GetArea())
	Local aAreaFK2  := FK2->(GetArea())
	Local aAreas    := {aAreaSE5, aAreaFK5, aAreaFK2, GetArea()}
	Local aFINA080  := {}
	Local aFINA380  := {}
	Local lCtbOn    := Nil
	Local lRet      := .T.
	Local cSeqBxa   := ''
	Local cSeq      := ''
	Local cNum      := ''
	Local cPrefixo  := ''
	Local cParcela  := ''
	Local cFornece  := ''
	Local cTipo     := ''
	Local cLoja     := ''
	Local nTotAdto  := 0
	Local aBaixa    := {}
	Local nBaixa    := 0
	Local nTmSeq    := ''
	Local nOpBaixa  := 0
	Local lBaixaAbat := .F.
	Local nRecSE5   := aMov[4]
	Local nRecFK2   := aMov[5]
	Local lConcilou := aMov[6]
	Local nRecSE2   := aMov[7]
	Local cBanco    := aMov[8]
	Local cAgencia  := aMov[9]
	Local cConta    := aMov[10]
	Local dDtBkp    := dDataBase

	Private aBaixaSE5 := {}

	//Se conciliou, desconcilia
	If lConcilou
		SE5->(DbGoto(nRecSE5))
		dDataBase := SE5->E5_DATA
		AAdd(aFINA380, {nRecSE5, .F., .T., ''})
		U_F2000310(aFINA380)
		If !aFINA380[1, 3]
			lRet := .F.
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA080)
			U_LimpaArr(aBaixa)
			U_LimpaArr(aBaixaSE5)
			dDataBase := dDtBkp
			Return lRet
		EndIf
	EndIf

	//Apaga campos customizados
	If nRecSE5 > 0
		SE5->(DbGoto(nRecSE5))
		dDataBase := SE5->E5_DATA
		If RecLock('SE5', .F.)
			SE5->E5_XPCXRT  := ''
			SE5->E5_XCODXRT := ''
			SE5->E5_XINTXRT := ''
			SE5->(MsUnlock())
		EndIf
	EndIf

	If nRecFK2 > 0 .And. nRecSE2 > 0
		FK2->(DbGoto(nRecFK2))
		If RecLock('FK2', .F.)
			FK2->FK2_XPCXRT := ''
			FK2->FK2_XCDXRT := ''
			FK2->(MsUnlock())
		EndIf

		SE2->(DbGoto(nRecSE2))

		cSeqBxa  := FK2->FK2_SEQ
		nTmSeq   := Len(cSeqBxa)
		cPrefixo := SE2->E2_PREFIXO
		cNum     := SE2->E2_NUM
		cParcela := SE2->E2_PARCELA
		cFornece := SE2->E2_FORNECE
		cTipo    := SE2->E2_TIPO
		cLoja    := SE2->E2_LOJA

		//Procura a ordem da sequência da baixa
		aBaixa := Sel080Baixa( "VL /BA /CP /", cPrefixo, cNum, cParcela, cTipo, @nTotAdto, @lBaixaAbat, cFornece, cLoja)

		For nBaixa := 1 To Len(aBaixaSE5)
			//cSeq := SubStr(aBaixa[nBaixa], Len(aBaixa[nBaixa])-nTmSeq+1, nTmSeq)
			cSeq := aBaixaSE5[nBaixa, 9]
			If cSeq == cSeqBxa
				nOpBaixa := nBaixa
				Exit
			EndIf
		Next nBaixa

		If nOpBaixa <= 0
			//XMLRetorno(oMov, oWsOut, .F., 'Sequencia de baixa a estornar não encontrada. Verifique se houve estorno manual.', nRecSE2)
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA080)
			U_LimpaArr(aBaixa)
			U_LimpaArr(aBaixaSE5)
			dDataBase := dDtBkp
			Return .F.
		EndIf

		SE5->(DbGoto(nRecSE5))
		SE2->(DbGoto(nRecSE2))
		FK2->(DbGoto(nRecFK2))

		Aadd(aFINA080, {"E2_FILIAL",  FWXFilial('SE2'),  Nil})
		Aadd(aFINA080, {"E2_PREFIXO", SE2->E2_PREFIXO,   Nil})
		Aadd(aFINA080, {"E2_NUM",     SE2->E2_NUM,       Nil})
		Aadd(aFINA080, {"E2_PARCELA", SE2->E2_PARCELA,   Nil})
		Aadd(aFINA080, {"E2_TIPO",    SE2->E2_TIPO,      Nil})
		Aadd(aFINA080, {"E2_FORNECE", SE2->E2_FORNECE,   Nil})
		Aadd(aFINA080, {"E2_LOJA",    SE2->E2_LOJA,      Nil})
		Aadd(aFINA080, {"AUTMOTBX",   FK2->FK2_MOTBX,    Nil})
		Aadd(aFINA080, {"AUTBANCO",   cBanco,            Nil})
		Aadd(aFINA080, {"AUTAGENCIA", cAgencia,          Nil})
		Aadd(aFINA080, {"AUTCONTA",   cConta,            Nil})
		Aadd(aFINA080, {"AUTDTBAIXA", FK2->FK2_DATA,     Nil})
		Aadd(aFINA080, {"AUTDTDEB", FK2->FK2_DTDISP, Nil})
		Aadd(aFINA080, {"AUTHIST",    FK2->FK2_HISTOR,   Nil})
		Aadd(aFINA080, {"AUTVLRPG",   FK2->FK2_VALOR,    Nil})

		If !Empty(SuperGetMV('FS_C200044',, ''))
			lCtbOn := SuperGetMV('FS_C200044',, '') == '1'
		EndIf

		Private lMsErroAuto    := .F.
		Private lMsHelpAuto    := .F.
		Private lAutoErrNoFile := .T.
		Private cHistBaixa     := FK2->FK2_HISTOR

		SetFunName('FINA080')
		AcessaPerg("FINA080", .F.)
		MsExecauto({|a,b,c,d,e,f| FINA080(a,b,c,d,e,f)}, aFINA080, 5, .F., nOpBaixa,, lCtbOn)

		If lMsErroAuto
			lRet := .F.
		EndIf
	EndIf

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA080)
	U_LimpaArr(aBaixa)
	U_LimpaArr(aBaixaSE5)
	dDataBase := dDtBkp
Return lRet

/*/{Protheus.doc} EstBxOpFin
    Realiza o estorno de uma baixa num título de operação financeira
    @type  Static Function
    @author Gianluca Moreira
    @since 16/06/2021
    /*/
Static Function EstBxOpFin(oMov, oWsOut, aRet)
	Local aAreaSE5 := SE5->(GetArea())
	Local aAreaFK5 := FK5->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaFK2 := FK2->(GetArea())
	Local aAreaFK7 := FK7->(GetArea())
	Local aAreas   := {aAreaSE5, aAreaFK5, aAreaSE2, aAreaFK2, aAreaFK7, GetArea()}
	Local aFINA080 := {}
	Local aFINA380 := {}
	Local cNaturez := ''
	Local cOpFin   := ''
	Local cSeqBxa  := ''
	Local cSeq     := ''
	Local cNum     := ''
	Local cPrefixo := ''
	Local cParcela := ''
	Local cFornece := ''
	Local cTipo    := ''
	Local cLoja    := ''
	Local cBanco   := ''
	Local cAgencia := ''
	Local cConta   := ''
	Local nTotAdto := 0
	Local aBaixa   := {}
	Local nBaixa   := 0
	Local nTmSeq   := ''
	Local nOpBaixa := 0
	Local lBaixaAbat := .F.
	Local dDtVenc  := CToD('')
	Local lRet     := .T.
	Local lCtbOn   := Nil
	Local cMotBx   := SuperGetMV('FS_C200041',, '')
	Local nRecFK2  := 0
	Local nRecSE2  := 0
	Local nRecSE5  := 0
	Local nRet     := 0

	Private aBaixaSE5 := {}

	//RecnoSE5Ori, RecnoFK2Ori, lDesconcilou, nRecnoSE2, cBanco, cAgencia, cConta, nRecnoSE5Est, nRecnoFK2Est
	AAdd(aRet, {'ESTBXOPFIN', cEmpAnt, cFilAnt, 0, 0, .F., 0, '', '', '', 0, 0})
	nRet := Len(aRet)

	If Empty(oMov:FK5_XPCXRT) .Or. Empty(oMov:FK5_XCDXRT)
		XMLRetorno(oMov, oWsOut, .F., 'Codigo e/ou Par Contabil nao informados')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		Return .F.
	EndIf

	If Empty(oMov:CHVORIG)
		XMLRetorno(oMov, oWsOut, .F., 'Codigo do registro a estornar nao informado')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		Return .F.
	EndIf

	FK2->(DBOrderNickName('FSW2000406')) //FK2_FILIAL+FK2_XCDXRT+FK2_XPCXRT
	If FK2->(DbSeek(FWXFilial('FK2')+AvKey(oMov:FK5_XCDXRT, 'FK2_XCDXRT')+AvKey(oMov:FK5_XPCXRT, 'FK2_XPCXRT')))
		XMLRetorno(oMov, oWsOut, .T., 'Baixa já estornada anteriormente.')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		lRet := .T. //Estorno já realizado, não é necessário desarmar
		Return lRet
	EndIf

	dDtVenc  := SToD(oMov:E5_DATA)
	cOpFin   := StrZero(Val(oMov:E2_XOPFXRT), TamSX3('E2_XOPFXRT')[1])
	cNaturez := AvKey(oMov:E5_NATUREZ, 'E5_NATUREZ')

	SE2->(DBOrderNickName('FSW2000400')) //E2_FILIAL+DTOS(E2_VENCREA)+E2_XOPFXRT+E2_NATUREZ
	//Removida natureza da chave da operação financeira do título
	//If !SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin+cNaturez))
	If !SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin))
		XMLRetorno(oMov, oWsOut, .F., 'Título de Operação Financeira não encontrado')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		Return .F.
	EndIf

	FK2->(DBOrderNickName('FSW2000406')) //FK2_FILIAL+FK2_XCDXRT+FK2_XPCXRT
	SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
	If FK2->(DbSeek(FWXFilial('FK2')+AvKey(oMov:CHVORIG, 'FK2_XCDXRT')))
		If !SE5->(DbSeek(FWXFilial('SE5')+FK2->FK2_IDFK2))
			XMLRetorno(oMov, oWsOut, .F., 'Movimento origem nao encontrado.')
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA080)
			U_LimpaArr(aBaixa)
			U_LimpaArr(aBaixaSE5)
			Return .F.
		EndIf
	Else
		XMLRetorno(oMov, oWsOut, .F., 'Movimento origem nao encontrado.')
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		Return .F.
	EndIf

	nRecSE5  := SE5->(Recno())
	nRecSE2  := SE2->(Recno())
	nRecFK2  := FK2->(Recno())
	cSeqBxa  := FK2->FK2_SEQ
	nTmSeq   := Len(cSeqBxa)
	cPrefixo := SE2->E2_PREFIXO
	cNum     := SE2->E2_NUM
	cParcela := SE2->E2_PARCELA
	cFornece := SE2->E2_FORNECE
	cTipo    := SE2->E2_TIPO
	cLoja    := SE2->E2_LOJA
	cBanco   := AvKey(oMov:E5_BANCO,   'A6_COD')
	cAgencia := AvKey(oMov:E5_AGENCIA, 'A6_AGENCIA')
	cConta   := AvKey(oMov:E5_CONTA,   'A6_NUMCON')

	//Procura a ordem da sequência da baixa
	aBaixa := Sel080Baixa( "VL /BA /CP /", cPrefixo, cNum, cParcela, cTipo, @nTotAdto, @lBaixaAbat, cFornece, cLoja)

	For nBaixa := 1 To Len(aBaixaSE5)
		//cSeq := SubStr(aBaixa[nBaixa], Len(aBaixa[nBaixa])-nTmSeq+1, nTmSeq)
		cSeq := aBaixaSE5[nBaixa, 9]
		If cSeq == cSeqBxa
			nOpBaixa := nBaixa
			Exit
		EndIf
	Next nBaixa

	If nOpBaixa <= 0
		XMLRetorno(oMov, oWsOut, .F., 'Sequencia de baixa a estornar não encontrada. Verifique se houve estorno manual.', nRecSE2)
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		Return .F.
	EndIf

	SE5->(DbGoto(nRecSE5))
	SE2->(DbGoto(nRecSE2))
	FK2->(DbGoto(nRecFK2))

	//Desconcilia
	AAdd(aFINA380, {nRecSE5, .F., .T., ''})
	U_F2000310(aFINA380)
	If !aFINA380[1, 3]
		lRet := .F.
		cRet := 'Falha na desconciliacao: '+aFINA380[1, 4]
		XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE2)
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		U_LimpaArr(aBaixa)
		U_LimpaArr(aBaixaSE5)
		Return lRet
	EndIf

	aRet[nRet,  4] := nRecSE5
	aRet[nRet,  5] := nRecFK2
	aRet[nRet,  6] := .T. //Desconciliou
	aRet[nRet,  7] := nRecSE2
	aRet[nRet,  8] := cBanco
	aRet[nRet,  9] := cAgencia
	aRet[nRet, 10] := cConta

	Aadd(aFINA080, {"E2_FILIAL", FWXFilial('SE2'),      Nil})
	Aadd(aFINA080, {"E2_PREFIXO", SE2->E2_PREFIXO,      Nil})
	Aadd(aFINA080, {"E2_NUM",     SE2->E2_NUM,          Nil})
	Aadd(aFINA080, {"E2_PARCELA", SE2->E2_PARCELA,      Nil})
	Aadd(aFINA080, {"E2_TIPO",    SE2->E2_TIPO,         Nil})
	Aadd(aFINA080, {"E2_FORNECE", SE2->E2_FORNECE,      Nil})
	Aadd(aFINA080, {"E2_LOJA",    SE2->E2_LOJA,         Nil})
	Aadd(aFINA080, {"AUTMOTBX",   cMotBx,               Nil})
	Aadd(aFINA080, {"AUTBANCO",   cBanco,               Nil})
	Aadd(aFINA080, {"AUTAGENCIA", cAgencia,             Nil})
	Aadd(aFINA080, {"AUTCONTA",   cConta,               Nil})
	Aadd(aFINA080, {"AUTDTBAIXA", SToD(oMov:E5_DATA),   Nil})
	Aadd(aFINA080, {"AUTDTDEB", SToD(oMov:E5_DATA), Nil})
	Aadd(aFINA080, {"AUTHIST",    oMov:E5_HISTOR,       Nil})
	Aadd(aFINA080, {"AUTVLRPG",   oMov:E5_VALOR,        Nil})

	If !Empty(SuperGetMV('FS_C200044',, ''))
		lCtbOn := SuperGetMV('FS_C200044',, '') == '1'
	EndIf

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private cHistBaixa     := oMov:E5_HISTOR

	SetFunName('FINA080')
	AcessaPerg("FINA080", .F.)
	MsExecauto({|a,b,c,d,e,f| FINA080(a,b,c,d,e,f)}, aFINA080, 5, .F., nOpBaixa,, lCtbOn)

	If lMsErroAuto
		cRet := cMontaErr()
		lRet := .F.
	Else
		lRet := .F.
		cRet := 'Movimento de estorno não encontrado.'
		//Grava os campos customizados no estorno
		FK2->(DbGoto(nRecFK2)) //Registro do lançamento original
		FKA->(DbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
		FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2

		If !FKA->(DbSeek(FWXFilial('FKA')+'FK2'+FK2->FK2_IDFK2))
			XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE2)
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA080)
			U_LimpaArr(aBaixa)
			U_LimpaArr(aBaixaSE5)
			Return lRet
		EndIf

		cIdProc := FKA->FKA_IDPROC
		FKA->(DbSetOrder(2)) //FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
		If !FKA->(DbSeek(FWXFilial('FKA')+cIdProc))
			XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE2)
			AEval(aAreas, {|x| RestArea(x)})
			U_LimpaArr(aAreas)
			U_LimpaArr(aFINA380)
			U_LimpaArr(aFINA080)
			U_LimpaArr(aBaixa)
			U_LimpaArr(aBaixaSE5)
			Return lRet
		EndIf

		//Cada mov. de baixa/estorno é gravado com o mesmo processo na FKA
		//Numa nova baixa é gerado novo processo

		While !FKA->(EoF()) .And. FKA->(FKA_FILIAL+FKA_IDPROC) == FWXFilial('FKA')+cIdProc
			If FKA->FKA_TABORI != 'FK2'
				FKA->(DbSkip())
				Loop
			EndIf
			If FK2->(DbSeek(FWXFilial('FK2')+FKA->FKA_IDORIG))
				If FK2->FK2_TPDOC != 'ES'
					FKA->(DbSkip())
					Loop
				EndIf

				SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
				If SE5->(DbSeek(FWXFilial('SE5')+FK2->FK2_IDFK2))
					aRet[nRet, 11] := SE5->(Recno())
					aRet[nRet, 12] := FK2->(Recno())
					aRet[nRet,  6] := .F. //Desliga o Flag da desconciliação, pois será necessário refazer a baixa e conciliar
					If RecLock('FK2', .F.)
						FK2->FK2_XPCXRT := oMov:FK5_XPCXRT
						FK2->FK2_XCDXRT := oMov:FK5_XCDXRT
						FK2->(MsUnlock())
						If RecLock('SE5', .F.)
							SE5->E5_XPCXRT  := oMov:FK5_XPCXRT
							SE5->E5_XCODXRT := oMov:FK5_XCDXRT
							SE5->E5_XINTXRT := 'Sim'
							SE5->(MsUnlock())
							lRet := .T.
							cRet := ''
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			FKA->(DbSkip())
		EndDo
	EndIf

	XMLRetorno(oMov, oWsOut, lRet, cRet, nRecSE2)
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA080)
	U_LimpaArr(aBaixa)
	U_LimpaArr(aBaixaSE5)
Return lRet

/*/{Protheus.doc} DesfEstBxa
    Baixa novamente um título que teve a baixa estornada
    @type  Static Function
    @author Gianluca Moreira
    @since 08/07/2021
    /*/
Static Function DesfEstBxa(aMov)
	Local aAreaSE5 := SE5->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaFK2 := FK2->(GetArea())
	Local aAreas   := {aAreaSE5, aAreaSE2, aAreaFK2, GetArea()}
	Local aFINA080 := {}
	Local aFINA380 := {}
	Local cNaturez := ''
	Local cChvFK7  := ''
	Local lRet     := .T.
	Local lCtbOn   := Nil
	Local cMotBx   := ''
	Local nValor   := 0
	Local nRecFK2  := 0
	Local nSE5Ori   := aMov[4]
	Local nFK2Ori   := aMov[5]
	Local lDesconc  := aMov[6]
	Local nRecSE2   := aMov[7]
	Local cBanco    := aMov[8]
	Local cAgencia  := aMov[9]
	Local cConta    := aMov[10]
	Local nSE5Est   := aMov[11]
	Local nFK2Est   := aMov[12]
	Local cParCont  := ''
	Local cCodXRT   := ''
	Local dDtBkp   := dDataBase

	//Apenas desconciliou o registro, mas houve falha no estorno, então reconcilia
	If lDesconc
		SE5->(DbGoto(nSE5Ori))
		dDataBase := SE5->E5_DATA
		AAdd(aFINA380, {nSE5Ori, .T., .T., ''})
		U_F2000310(aFINA380)
		If !aFINA380[1, 3]
			lRet := .F.
		EndIf
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		U_LimpaArr(aFINA380)
		U_LimpaArr(aFINA080)
		dDataBase := dDtBkp
		Return lRet
	EndIf

	//Caso tenha efetivado o estorno, é preciso lançar novamente o registro
	//depois de limpar os campos customizados
	If nSE5Ori > 0
		SE5->(DbGoto(nSE5Ori))
		dDataBase := SE5->E5_DATA
		If RecLock('SE5', .F.)
			SE5->E5_XPCXRT  := ''
			SE5->E5_XCODXRT := ''
			SE5->E5_XINTXRT := ''
			SE5->(MsUnlock())
		EndIf
	EndIf

	If nFK2Ori > 0
		FK2->(DbGoto(nFK2Ori))
		cParCont := FK2->FK2_XPCXRT
		cCodXRT  := FK2->FK2_XCDXRT
		If RecLock('FK2', .F.)
			FK2->FK2_XPCXRT := ''
			FK2->FK2_XCDXRT := ''
			FK2->(MsUnlock())
		EndIf
	EndIf

	If nSE5Est > 0
		SE5->(DbGoto(nSE5Est))
		If RecLock('SE5', .F.)
			SE5->E5_XPCXRT  := ''
			SE5->E5_XCODXRT := ''
			SE5->E5_XINTXRT := ''
			SE5->(MsUnlock())
		EndIf
	EndIf

	If nFK2Est > 0
		FK2->(DbGoto(nFK2Est))
		If RecLock('FK2', .F.)
			FK2->FK2_XPCXRT := ''
			FK2->FK2_XCDXRT := ''
			FK2->(MsUnlock())
		EndIf
	EndIf

	If nSE5Ori > 0 .And. nFK2Ori > 0
		FK2->(DbGoto(nFK2Ori))
		SE2->(DbGoto(nRecSE2))

		cChvFK7 := FWXFilial('SE2')+'|'
		cChvFK7 += SE2->E2_PREFIXO+ '|'
		cChvFK7 += SE2->E2_NUM+     '|'
		cChvFK7 += SE2->E2_PARCELA+ '|'
		cChvFK7 += SE2->E2_TIPO+    '|'
		cChvFK7 += SE2->E2_FORNECE+ '|'
		cChvFK7 += SE2->E2_LOJA

		cNaturez := SE2->E2_NATUREZ
		cMotBx   := FK2->FK2_MOTBX
		nValor   := FK2->FK2_VALOR

		Aadd(aFINA080, {"E2_FILIAL",  FWXFilial('SE2'),  Nil})
		Aadd(aFINA080, {"E2_PREFIXO", SE2->E2_PREFIXO,   Nil})
		Aadd(aFINA080, {"E2_NUM",     SE2->E2_NUM,       Nil})
		Aadd(aFINA080, {"E2_PARCELA", SE2->E2_PARCELA,   Nil})
		Aadd(aFINA080, {"E2_TIPO",    SE2->E2_TIPO,      Nil})
		Aadd(aFINA080, {"E2_FORNECE", SE2->E2_FORNECE,   Nil})
		Aadd(aFINA080, {"E2_LOJA",    SE2->E2_LOJA,      Nil})
		Aadd(aFINA080, {"AUTMOTBX",   FK2->FK2_MOTBX,    Nil})
		Aadd(aFINA080, {"AUTBANCO",   cBanco,            Nil})
		Aadd(aFINA080, {"AUTAGENCIA", cAgencia,          Nil})
		Aadd(aFINA080, {"AUTCONTA",   cConta,            Nil})
		Aadd(aFINA080, {"AUTDTBAIXA", FK2->FK2_DATA,     Nil})
		Aadd(aFINA080, {"AUTDTDEB", FK2->FK2_DTDISP, Nil})
		Aadd(aFINA080, {"AUTHIST",    FK2->FK2_HISTOR,   Nil})
		Aadd(aFINA080, {"AUTVLRPG",   FK2->FK2_VALOR,    Nil})

		If !Empty(SuperGetMV('FS_C200044',, ''))
			lCtbOn := SuperGetMV('FS_C200044',, '') == '1'
		EndIf

		Private lMsErroAuto    := .F.
		Private lMsHelpAuto    := .F.
		Private lAutoErrNoFile := .T.
		Private cHistBaixa     := FK2->FK2_HISTOR

		SetFunName('FINA080')
		AcessaPerg("FINA080", .F.)
		MsExecauto({|a,b,c,d,e,f| FINA080(a,b,c,d,e,f)}, aFINA080, 3, .F.,,, lCtbOn)

		If lMsErroAuto
			//cRet := cMontaErr()
			lRet := .F.
		Else //Grava os campos customizados
			lRet := .F.
			cRet := 'Movimento de baixa não encontrado.'
			FK7->(DbSetOrder(2)) //FK7_FILIAL+FK7_ALIAS+FK7_CHAVE
			FK2->(DbSetOrder(2)) //FK2_FILIAL+FK2_IDDOC+FK2_SEQ
			SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
			If FK7->(DbSeek(FWXFilial('FK7')+'SE2'+cChvFK7))
				If FK2->(DbSeek(FWXFilial('FK2')+FK7->FK7_IDDOC))
					//Procura o último movimento de baixa gerado (ordenado por sequência)
					While !FK2->(EoF()) .And. FK2->(FK2_FILIAL+FK2_IDDOC) == FWXFilial('FK2')+FK7->FK7_IDDOC
						If FK2->FK2_MOTBX == AvKey(cMotBx, 'FK2_MOTBX') .And. FK2->FK2_RECPAG == 'P' .And.;
								FK2->FK2_NATURE == cNaturez .And. FK2->FK2_VALOR == nValor .And.;
								Empty(FK2->FK2_XPCXRT)
							nRecFK2 := FK2->(Recno())
						EndIf
						FK2->(DbSkip())
					EndDo
					If nRecFK2 > 0
						FK2->(DbGoto(nRecFK2))
						If SE5->(DbSeek(FWXFilial('SE5')+FK2->FK2_IDFK2))
							If RecLock('FK2', .F.)
								FK2->FK2_XPCXRT := cParCont
								FK2->FK2_XCDXRT := cCodXRT
								FK2->(MsUnlock())
								If RecLock('SE5', .F.)
									SE5->E5_XPCXRT  := cParCont
									SE5->E5_XCODXRT := cCodXRT
									SE5->E5_XINTXRT := 'Sim'
									SE5->(MsUnlock())
									lRet := .T.
									cRet := ''
								Else
									lRet := .F.
									cRet := 'Não foi possível obter acesso de gravação na SE5.'
								EndIf
							Else
								lRet := .F.
								cRet := 'Não foi possível obter acesso de gravação na FK2.'
							EndIf
						Else
							lRet := .F.
							cRet := 'Movimento SE5 não gerado.'
						EndIf
					Else
						lRet := .F.
						cRet := 'Movimento FK2 não gerado.'
					EndIf
				Else
					lRet := .F.
					cRet := 'Movimento FK2 não gerado.'
				EndIf
			Else
				lRet := .F.
				cRet := 'Movimento FK2 não gerado.'
			EndIf

			//Conciliacao
			If lRet
				AAdd(aFINA380, {SE5->(Recno()), .T., .T., ''})
				U_F2000310(aFINA380)
				If !aFINA380[1, 3]
					lRet := .F.
					cRet := 'Falha na conciliacao: '+aFINA380[1, 4]
				EndIf
			EndIf
		EndIf
	EndIf

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
	U_LimpaArr(aFINA380)
	U_LimpaArr(aFINA080)
	dDataBase := dDtBkp
Return lRet

/*/{Protheus.doc} XMLRetorno
    Preenche o item do XML de retorno
    @type  Static Function
    @author Gianluca Moreira
    @since 10/06/2021
    /*/
Static Function XMLRetorno(oMov, oWsOut, lSucesso, cErro, nRecSE)
	//Local cIdInt   := ''
	Local nUlt     := 0
	//Local nRegLog  := 0
	Local cIndKey  := ''
	Local cTab     := ''
	Local cOper    := Upper(AllTrim(oMov:OPERAC))

	Default nRecSE := 0
	If Type('nRegLog') == 'U' .Or. (Type('nRegLog') == 'N' .And. nRegLog <= 0)
		cIdInt 	:= U_GetIntegID()
		nRegLog := U_F07LOG01(cIdInt, {oMov}, 'U_F2000400')
	EndIf

	AAdd(oWsOut:ITENS, WSClassNew('W20004RETIT'))
	nUlt := Len(oWsOut:ITENS)
	oWsOut:ITENS[nUlt]:RETSTATUS  := EncodeUTF8(IIf(lSucesso, 'C', 'E'))
	oWsOut:ITENS[nUlt]:RETMSG     := EncodeUTF8(FwNoAccent(Left(cErro, 250)))
	oWsOut:ITENS[nUlt]:FK5_XCDXRT := EncodeUTF8(oMov:FK5_XCDXRT)

	//Grava o Log
	If cOper == 'FINANCEIRO'
		cIndKey := FWXFilial('SE5')
		cIndKey += AvKey(oMov:FK5_XPCXRT, 'FK5_XPCXRT')
		cIndKey += AvKey(oMov:FK5_XCDXRT, 'FK5_XCDXRT')
		cTab    := 'SE5'
	ElseIf cOper == 'BAIXA'
		cIndKey := FWXFilial('SE2')
		cIndKey += oMov:E5_DATA
		cIndKey += AvKey(oMov:E2_XOPFXRT, 'E2_XOPFXRT')
		cIndKey += AvKey(oMov:E5_NATUREZ, 'E5_NATUREZ')
		cTab    := 'SE2'
	Else
		Return
	EndIf

	//cIdInt 	:= U_GetIntegID()
	//nRegLog := U_F07LOG01(cIdInt, {oMov}, 'U_F2000400')
	//U_F07LOG02(nRegLog, cErro, lSucesso, cTab, 1, cIndKey)
	If nRecSE > 0
		If cTab == 'SE2'
			SE2->(DbGoto(nRecSE))
			If RecLock('SE2', .F.)
				SE2->E2_XIDP19 := FWXFilial('SE2')+cIdInt
				SE2->(MsUnlock())
			EndIf
		ElseIf cTab == 'SE5'
			SE5->(DbGoto(nRecSE))
			If RecLock('SE5', .F.)
				SE5->E5_XIDP19 := FWXFilial('SE5')+cIdInt
				SE5->(MsUnlock())
			EndIf
		EndIf
	EndIf
Return

Static Function cMontaErr()
	Local aCpos := {}
	Local aErro := GetAutoGRLog()
	Local cErro := ''
	Local nI    := 0
	Local nLin  := 0

	AAdd(aCpos, '< -- Invalido')

	If !Empty(aErro)
		If Len(aErro) > 0
			cErro += aErro[1]+CRLF
		EndIf
		If Len(aErro) > 1
			cErro += aErro[2]+CRLF
		EndIf

		For nI := 1 To Len(aCpos)
			nLin := AScan(aErro, {|x| aCpos[nI] $ x})
			If nLin > 0
				cErro += aErro[nLin] + CRLF
			EndIf
		Next nI
	EndIf

	while At("  ",cErro) > 0
		cErro := StrTran(cErro,"  "," ")
	Enddo

	If Empty(cErro)
		cErro := 'Erro desconhecido!'
	EndIf
	U_LimpaArr(aCpos)
	U_LimpaArr(aErro)
Return Left(cErro, 250)

/*/{Protheus.doc} GrvXmlVaz
    Grava o XML vazio caso estoure timeout
    @type  Static Function
    @author Gianluca Moreira
    @since 24/05/2021
    /*/
Static Function GrvXmlVaz(oWsOut)
	Local nUlt := 0

	AAdd(oWsOut:ITENS, WSClassNew('W20004RETIT'))
	nUlt := Len(oWsOut:ITENS)
	oWsOut:ITENS[nUlt]:RETSTATUS  := EncodeUTF8('')
	oWsOut:ITENS[nUlt]:RETMSG     := EncodeUTF8('')
	oWsOut:ITENS[nUlt]:FK5_XCDXRT := EncodeUTF8('')
Return


//?????????????????????????????????????????????????????
//?????????????????????????????????????????????????????
//Deus, atendei ao meu pedido, vinde em meu socorro, vinde ajudar-me. Confundidos sejam e envergonhados os que buscam a minha alma.					  
Static Function fXRTRETA(oMov)

	Local cQuery := ""
	Local cAliasE5 := GetNextAlias()
	Local lTreta := .F.
	Local cMVT := oMov:FK5_XCDXRT
	Local cFil := FWXFilial('SE5')
	Local cData := oMov:E5_DATA

	cQuery := "SELECT E5_XCODXRT FROM " + RetSqlName("SE5")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND E5_XCODXRT = '"+cMVT+"' AND E5_FILIAL = '"+cFil+"' AND E5_DATA = '"+cData+"'"


	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasE5, .T., .T.)
	If (cAliasE5)->(EOF())
		lTreta := .T.
	EndIf

	(cAliasE5)->(DbCloseArea())

Return lTreta
