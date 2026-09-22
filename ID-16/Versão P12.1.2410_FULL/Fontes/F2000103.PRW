#Include 'TOTVS.ch'
#INCLUDE 'FILEIO.CH'

#Define INCLUI_PREV 01
#Define ALTERA_PREV 02
#Define EXCLUI_PREV 03
#Define ENVBAN_PREV 04
#Define REJBAN_PREV 05
#Define BAIXAT_PREV 06
#Define ESTBXA_PREV 07
#Define GRVCHQ_PREV 08
#Define ESTCHQ_PREV 09
#Define ENVBAN_REAL 21
#Define REJBAN_REAL 22
#Define BAIXAT_REAL 23
#Define ESTBXA_REAL 24
#Define GRVCHQ_REAL 31
#Define ESTCHQ_REAL 32
#Define PAGADT_REAL 41
#Define RECADT_REAL 42

/*/{Protheus.doc} User Function F2000103
    WebService de consulta de títulos pendentes de integração

    @type  Function
    @author Gianluca Moreira
    @since 17/05/2021
    /*/
User Function F2000103(oWsIn, oWsOut, cWsCall, cTemp)
	Local aSM0     := U_F2000133()//FWLoadSM0(.T.)
	Local cEFArq   := ''
	Local cEmpAtu  := ''
	Local cFilAtu  := ''
	Local cEmpBkp  := cEmpAnt
	Local cFilBkp  := cFilAnt
	Local nTitMax  := SuperGetMV('FS_N010010', , 100)
	Local nTitAtu  := 0
	Local nFilAtu  := 0
	Local nFilIni  := 0
	Local nLenSM0  := Len(aSM0)

	Local oFile    := Nil
	Local lRestart := .F.

	Private _nTimeOut := SuperGetMV('FS_N010011',, 120)*1000 //ms
	Private _nTimeSt  := TimeCounter()

	Default cWsCall := 'EMPINIPREV'

	//Tratamento de semáforo
	While !GlbNmLock(cWsCall)
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			GrvXmlVaz(oWsOut)
			Return
		EndIf
		Sleep(500)
	EndDo

	Conout('F2000103 - Integ XRT Titulos AP - Inicio '+FwTimeStamp(2))

	If nLenSM0 <= 0
		Conout('F2000103 - Integ XRT Titulos AP - Nao encontrou empresas habilitadas. Emp. Atual: '+cEmpAnt+cFilAnt+' - '+FwTimeStamp(2))
		GrvXmlVaz(oWsOut)
		Return
	EndIf

	//Busca qual empresa foi a última consultada
	If !File(cWsCall+'.TXT')
		oFile := FWFileWriter():New(cWsCall+'.TXT')
		If oFile:Create()
			cEmpAtu := aSM0[1, 1]
			cFilAtu := aSM0[1, 2]
			oFile:Write(cEmpAtu+cFilAtu)
			oFile:Close()
		EndIf
	EndIf

	If File(cWsCall+'.TXT')
		oFile := FWFileReader():New(cWsCall+'.TXT')
		If oFile:Open(FO_READWRITE)
			cEFArq := oFile:GetLine()
			oFile:Close()
		EndIf
	EndIf

	nFilIni := AScan(aSM0, {|x| AllTrim(x[1]+x[2]) == AllTrim(cEFArq) })

	If nFilIni > 0
		nFilAtu := nFilIni
	Else
		nFilAtu := 1
		nFilIni := 1
	EndIf

	Conout('F2000103 - Integ XRT Titulos AP - Leu arquivo '+FwTimeStamp(2))

	//Begin Transaction
	While nTitAtu < nTitMax
		//Chegou ao limite por chamada - encerra
		If nTitAtu >= nTitMax
			Exit
		EndIf

		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf

		cEmpAtu := aSM0[nFilAtu, 1]
		cFilAtu := aSM0[nFilAtu, 2]

		Conout('F2000103 - Integ XRT Titulos AP - Antes de logar empresa '+cEmpAnt+cFilAnt+' '+FwTimeStamp(2))

           /*/ If cEmpAnt != cEmpAtu .Or. cFilAnt != cFilAtu
		If !RpcSetEnv(cEmpAtu, cFilAtu, 'Administrador',,'FIN')
			Conout('F2000103 - Integ XRT '+cValToChar(cTemp)+' - Falha ao preparar ambiente')
			//DisarmTransaction()
			//Break
		EndIf
		cEmpAnt := cEmpAtu
		cFilAnt := cFilAtu
		SM0->(DbSeek(cEmpAnt+cFilAnt))
            EndIf/*/
		cEmpAnt := cEmpAtu
		cFilAnt := cFilAtu

		Conout('F2000103 - Integ XRT Titulos AP - logou empresa '+cEmpAnt+cFilAnt+' '+FwTimeStamp(2))

		Conout('F2000103 - Integ XRT Titulos AP - validou empresa '+FwTimeStamp(2))

		//A ordem da chamada não deve ser alterada
		If cTemp == '1' //Previstos

			StartJob("U_F200010C", GetEnvServer(), .F., cEmpAnt, cFilAnt) // grava borderô via thread
			//StartJob("U_F2001031", GetEnvServer(), .F., cEmpAnt, cFilAnt) // grava pendentes via thread
			//GrvBor(  oWsOut, @nTitAtu, nTitMax)  //grava borderô

			//GeraRecusa(oWsOut, @nTitAtu, nTitMax) //Gera recusa ao título - Função transferida para o fonte F2001031 que está executando em outra thread para performar
			GetPend( oWsOut, @nTitAtu, nTitMax, '1') //Somente previstos pendentes
			//GeraPrev(oWsOut, @nTitAtu, nTitMax)   //Gera previstos não integrados - Função transferida para o fonte F2001031 que está executando em outra thread para performar
		Else //Realizados
			//GrvChq(  oWsOut, @nTitAtu, nTitMax) //Grava o cheque - Função transferida para o fonte F2001031 que está executando em outra thread para performar
			GetPend( oWsOut, @nTitAtu, nTitMax, '2') //Somente realizados pendentes
		EndIf

		Conout('F2000103 - Integ XRT Titulos AP - Montou XML. Verifica prox emp. '+FwTimeStamp(2))

		//Chegou ao limite por chamada - encerra
		If nTitAtu >= nTitMax
			Exit
		EndIf

		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf

		//Chegou ao final - reinicia
		++nFilAtu
		If nFilAtu > nLenSM0
			lRestart := .T.
			nFilAtu := 1
		EndIf

		//Verificou todas as empresas numa única chamada - encerra
		If lRestart .And. nFilAtu == nFilIni
			Exit
		EndIf
	EndDo

	If nTitAtu == 0
		GrvXmlVaz(oWsOut)
	EndIf

	oWsOut:QTDTIT := nTitAtu

	//TimeOut - desarma
	//If TimeCounter()-_nTimeSt > _nTimeOut*0.95
	//    Conout('F2000103 - Integ XRT '+cValToChar(cTemp)+'- Timeout atingido')
	//    DisarmTransaction()
	//    Break
	//EndIf

	If cEmpAnt != cEmpBkp .Or. cFilAnt != cFilBkp
		If !RpcSetEnv(cEmpBkp, cFilBkp, 'Administrador',,'FIN')
			Conout('F2000103 - Integ XRT '+cValToChar(cTemp)+'- Falha ao preparar ambiente')
			//DisarmTransaction()
			//Break
		EndIf
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		SM0->(DbSeek(cEmpAnt+cFilAnt))
	EndIf

	//Guarda qual empresa foi a última consultada
	If !File(cWsCall+'.TXT')
		oFile := FWFileWriter():New(cWsCall+'.TXT')
		If oFile:Create()
			oFile:Write(cEmpAtu+cFilAtu)
			oFile:Close()
		EndIf
	Else
		oFile := FWFileWriter():New(cWsCall+'.TXT')
		If oFile:Open(FO_READWRITE)
			If oFile:Clear(.T.)
				oFile:GoTop()
				oFile:Write(cEmpAtu+cFilAtu)
				oFile:Close()
			EndIf
		EndIf
	EndIf
	//End Transaction

	Conout('F2000103 - Integ XRT Titulos AP - Encerrando... '+FwTimeStamp(2))

	//Destrava o semáforo
	GlbNmUnlock(cWsCall)

	U_LimpaArr(aSM0)
Return

/*/{Protheus.doc} GetPend
    Obtém os registros pendentes de integração da PX0 - PREVISTO
    @type  Static Function
    @author Gianluca Moreira
    @since 17/05/2021
    /*/
Static Function GetPend(oWsOut, nTitAtu, nTitMax, cTemp)
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aAreaSE2, GetArea()}
	Local cQuery    := ''
	Local cAlPX0    := ''

	Default cTemp = ''

	If nTitAtu >= nTitMax
		Return
	EndIf

	Conout('F2000103 - Integ XRT Titulos AP - Leitura de títulos pendentes... '+FwTimeStamp(2))

	cQuery := " Select R_E_C_N_O_ PX0Rec, PX0_FILIAL FIL From "+RetSqlName('PX0')
	//cQuery += " Where  PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += " Where "
	If cTemp == '1' //Previstos
		cQuery += " (PX0_STTIT = '2' Or PX0_STTIT = '3') "
	ElseIf cTemp == '2' //Realizados
		cQuery += " PX0_STTIT = '1' "
	EndIf
	cQuery += "    And PX0_STXRT In ('1', '3') "//Pendentes ou com falha de comunicação
	cQuery += "    And D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery += " ORDER BY R_E_C_N_O_"
	cQuery := ChangeQuery(cQuery)

	cAlPX0 := MPSysOpenQuery(cQuery)

	While !(cAlPX0)->(EoF())
		cFilAnt := (cAlPX0)->FIL
		If GravaXML(oWsOut, (cAlPX0)->PX0Rec)
			++nTitAtu
		EndIf
		(cAlPX0)->(DbSkip())

		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	(cAlPX0)->(DbCloseArea())

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return

/*/{Protheus.doc} GeraPrev
    Na chamada do WebService, gera os títulos previstos
    para os títulos a pagar em aberto nunca integrados
    ou que sofreram estorno da baixa
    @type  Static Function
    @author Gianluca Moreira
    @since 18/05/2021
    /*//*/
Static Function GeraPrev(oWsOut, nTitAtu, nTitMax)
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aAreaSE2, GetArea()}
	Local cQuery    := ''
	Local cChave    := ''
	Local cAlSE2    := ''
	Local nRecPX0   := 0
	Local nPeriodo  := SuperGetMV('FS_N200014',, 90)

	If nTitAtu >= nTitMax
		U_LimpaArr(aAreas)
		Return
	EndIf

	cChave := 'SE2.E2_FILIAL||'
	cChave += 'SE2.E2_PREFIXO||'
	cChave += 'SE2.E2_NUM||'
	cChave += 'SE2.E2_PARCELA||'
	cChave += 'SE2.E2_TIPO||'
	cChave += 'SE2.E2_FORNECE||'
	cChave += 'SE2.E2_LOJA'

	Conout('F2000103 - Integ XRT Titulos AP - Buscando Titulos previstos... '+FwTimeStamp(2))

	//Primeira consulta - Títulos que não são de impostos
	cQuery := " Select "
	cQuery += " SE2.R_E_C_N_O_ SE2Rec "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	//Não enviar com data de pagamento retroativa
	cQuery += "    And (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
	cQuery += "    And SE2.E2_TIPO <> '"+MVPAGANT+"' "
	cQuery += "    And SE2.E2_XSTRECU In ('C', ' ') " //Não Recusado
	//O título deve ter saldo (previsto) e estar liberado
	If GetMv("MV_CTLIPAG")
		cQuery += " AND (SE2.E2_DATALIB <> ' ' "
		cQuery += " OR (SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE <= "+ALLTRIM(STR(GetMv('MV_VLMINPG'),17,2))+")) "
	Endif
	cQuery += "    And SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE > 0 "
	//E não ter sido enviado ao banco
	//cQuery += "    And SE2.E2_XENVBCO In (' ', '2') "
	//Não é título de imposto não aglutinado
	cQuery += "    And SE2.E2_TITPAI  = ' ' "
	//Não foi gerado por rotinas de aglutinação de imposto
	cQuery += "    And SE2.E2_ORIGEM Not In ('FINA290M', 'FINA290', 'FINA378', 'FINA376', 'FINA870') "
	cQuery += "    And SE2.E2_NUMTIT Not In ('AGL_BRWS') "
	//Não foi gerada PX0 ainda ou não existe PX0 ativa
	cQuery += "    And Not Exists ( "
	cQuery += " Select PX0.R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')+" PX0 "
	cQuery += "  Where PX0.PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		If GravaXML(oWsOut, nRecPX0)
			++nTitAtu
		EndIf
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos que nao sao impostos '+FwTimeStamp(2))

	If nTitAtu >= nTitMax .Or. (TimeCounter()-_nTimeSt > _nTimeOut*0.70)
		AEval(aAreas, {|x| RestArea(x)})
		U_LimpaArr(aAreas)
		Return
	EndIf

	//Segunda Consulta - Títulos aglutinados gerados pela FINA290
	cQuery := " Select Distinct SE2.R_E_C_N_O_ SE2Rec "
	cQuery += "   From "+RetSqlName('SE2')+" SE2  "
	cQuery += "   Join "+RetSqlName('SE2')+" SE2B "
	cQuery += "     On SE2B.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	cQuery += "    And SE2B.E2_FATPREF = SE2.E2_PREFIXO "
	cQuery += "    And SE2B.E2_FATURA  = SE2.E2_NUM "
	cQuery += "    And SE2B.E2_TIPOFAT = SE2.E2_TIPO "
	cQuery += "    And SE2B.E2_FATFOR  = SE2.E2_FORNECE "
	cQuery += "    And SE2B.E2_FATLOJ  = SE2.E2_LOJA "
	cQuery += "    And SE2B.E2_FLAGFAT = 'S' "
	//cQuery += "    And SE2B.E2_TIPO In ('ISS', 'INS') "
	cQuery += "    And SE2B.D_E_L_E_T_ = ' ' "
	cQuery += "  Where SE2.E2_FILIAL   = '"+FWXFilial('SE2')+"' "
	cQuery += "    And (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
	cQuery += "    And SE2.E2_TIPO <> '"+MVPAGANT+"' "
	cQuery += "    And SE2.E2_XSTRECU In ('C', ' ') " //Não Recusado
	//O título deve ter saldo (previsto) e estar liberado
	If GetMv("MV_CTLIPAG")
		cQuery += " AND (SE2.E2_DATALIB <> ' ' "
		cQuery += " OR (SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE <= "+ALLTRIM(STR(GetMv('MV_VLMINPG'),17,2))+")) "
	Endif
	cQuery += "    And SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE > 0 "
	//cQuery += "    And SE2.E2_XENVBCO In (' ', '2') "
	cQuery += "    And SE2.E2_ORIGEM In ('FINA290M', 'FINA290') "
	cQuery += "    And Not Exists ( "
	cQuery += " Select PX0.R_E_C_N_O_ From "+RetSqlName('PX0')+" PX0 "
	cQuery += "  Where PX0.PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		If GravaXML(oWsOut, nRecPX0)
			++nTitAtu
		EndIf
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos aglutinados FINA290 '+FwTimeStamp(2))

	If nTitAtu >= nTitMax .Or. (TimeCounter()-_nTimeSt > _nTimeOut*0.70)
		AEval(aAreas, {|x| RestArea(x)})
		Return
	EndIf

	//Terceira Consulta - Títulos aglutinados gerados por demais rotinas
	cQuery := " Select SE2.R_E_C_N_O_ SE2Rec "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	//Não enviar com data de pagamento retroativa
	cQuery += "    And (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
	cQuery += "    And SE2.E2_TIPO <> '"+MVPAGANT+"' "
	cQuery += "    And SE2.E2_XSTRECU In ('C', ' ') " //Não Recusado
	//O título deve ter saldo (previsto) e estar liberado
	If GetMv("MV_CTLIPAG")
		cQuery += " AND (SE2.E2_DATALIB <> ' ' "
		cQuery += " OR (SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE <= "+ALLTRIM(STR(GetMv('MV_VLMINPG'),17,2))+")) "
	Endif
	cQuery += "    And SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE > 0 "
	//E não ter sido enviado ao banco
	//cQuery += "    And SE2.E2_XENVBCO In (' ', '2') "
	//Títulos agrupados
	cQuery += "    And SE2.E2_PREFIXO in ('AGL', 'AGP', 'AGI') "
	cQuery += "    And (SE2.E2_ORIGEM In ('FINA378', 'FINA376', 'FINA870') "
	cQuery += "     Or (SE2.E2_NUMTIT = 'AGL_BRWS' "
	cQuery += "    And  SE2.E2_ORIGEM = 'FINA050') "
	cQuery += "        ) "
	//Não foi gerada PX0 ainda ou não existe PX0 ativa
	cQuery += "    And Not Exists ( "
	cQuery += " Select PX0.R_E_C_N_O_ From "+RetSqlName('PX0')+" PX0 "
	cQuery += "  Where PX0.PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		If GravaXML(oWsOut, nRecPX0)
			++nTitAtu
		EndIf
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos aglutinados - demais rotinas '+FwTimeStamp(2))

	cQuery := " Select "
	cQuery += " SE2.R_E_C_N_O_ SE2Rec "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	//Não enviar com data de pagamento retroativa
	cQuery += "    And (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
	cQuery += "    And SE2.E2_TIPO = '"+MVPAGANT+"' "
	cQuery += "    And SE2.E2_XSTRECU In ('C', ' ') " //Não Recusado
	//O título deve ter saldo (previsto) e estar liberado
	If GetMv("MV_CTLIPAG")
		cQuery += " AND (SE2.E2_DATALIB <> ' ' "
		cQuery += " OR (SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE <= "+ALLTRIM(STR(GetMv('MV_VLMINPG'),17,2))+")) "
	Endif
	//E não ter movimentações geradas
	cQuery += " And (SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE - "
	cQuery += " (Select Coalesce(Sum(SE5.E5_VALOR), 0) AdtVlr From "+RetSqlName('SE5')+" SE5 "
	cQuery += " Where "
	cQuery += "      SE5.E5_FILIAL  = '"+FWXFilial('SE5')+"' "
	cQuery += " And  SE5.E5_PREFIXO = SE2.E2_PREFIXO "
	cQuery += " And  SE5.E5_NUMERO  = SE2.E2_NUM "
	cQuery += " And  SE5.E5_PARCELA = SE2.E2_PARCELA "
	cQuery += " And  SE5.E5_TIPO    = SE2.E2_TIPO "
	cQuery += " And  SE5.E5_CLIFOR  = SE2.E2_FORNECE "
	cQuery += " And  SE5.E5_LOJA    = SE2.E2_LOJA "
	cQuery += " And  SE5.E5_SITUACA = ' ' "
	cQuery += " And  SE5.D_E_L_E_T_ = ' ' "
	cQuery += " )"
	cQuery += " ) > 0"
	//cQuery += "    And SE2.E2_SALDO+SE2.E2_SDACRES-SE2.E2_SDDECRE > 0 "
	//E não ter sido enviado ao banco
	//cQuery += "    And SE2.E2_XENVBCO In (' ', '2') "
	//Não é título de imposto não aglutinado
	cQuery += "    And SE2.E2_TITPAI  = ' ' "
	//Não foi gerado por rotinas de aglutinação de imposto
	cQuery += "    And SE2.E2_ORIGEM Not In ('FINA290M', 'FINA290', 'FINA378', 'FINA376', 'FINA870') "
	cQuery += "    And SE2.E2_NUMTIT Not In ('AGL_BRWS') "
	//Não foi gerada PX0 ainda ou não existe PX0 ativa
	cQuery += "    And Not Exists ( "
	cQuery += " Select PX0.R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')+" PX0 "
	cQuery += "  Where PX0.PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		If GravaXML(oWsOut, nRecPX0)
			++nTitAtu
		EndIf
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos de adiantamento '+FwTimeStamp(2))

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return
/*/
/*/{Protheus.doc} GeraRecusa
    Na chamada do WebService, atualiza títulos que foram recusados
    para excluir no XRT
    @type  Static Function
    @author Gianluca Moreira
    @since 18/05/2021
    /*//*/
Static Function GeraRecusa(oWsOut, nTitAtu, nTitMax)
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aAreaSE2, GetArea()}
	Local cQuery    := ''
	Local cChave    := ''
	Local cAlSE2    := ''
	Local nRecPX0   := 0
	Local nPeriodo  := SuperGetMV('FS_N200014',, 90)

	If nTitAtu >= nTitMax
		U_LimpaArr(aAreas)
		Return
	EndIf

	cChave := 'SE2.E2_FILIAL||'
	cChave += 'SE2.E2_PREFIXO||'
	cChave += 'SE2.E2_NUM||'
	cChave += 'SE2.E2_PARCELA||'
	cChave += 'SE2.E2_TIPO||'
	cChave += 'SE2.E2_FORNECE||'
	cChave += 'SE2.E2_LOJA'

	Conout('F2000103 - Integ XRT Titulos AP - Buscando Titulos recusados... '+FwTimeStamp(2))

	cQuery := " Select "
	cQuery += " SE2.R_E_C_N_O_ SE2Rec "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	cQuery += "    And (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
	cQuery += "    And Exists ( "
	cQuery += " Select PX0.R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')+" PX0 "
	cQuery += "  Where PX0.PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.E2_XSTRECU = 'R' " //Recusado
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		nRecPX0 := U_F2000100('SE2', EXCLUI_PREV)
		If GravaXML(oWsOut, nRecPX0)
			++nTitAtu
		EndIf
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	(cAlSE2)->(DbCloseArea())
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return/*/

/*/{Protheus.doc} GrvChq
    Como o cheque é gerado após a baixa, é preciso gravar antes de enviar ao XRT
    @type  Static Function
    @author Gianluca Moreira
    @since 28/05/2021
    /*/
/*/Static Function GrvChq(oWsOut, nTitAtu, nTitMax)
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaFK2  := FK2->(GetArea())
	Local aAreaFK5  := FK5->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aAreaFK2, aAreaFK5, aAreaSE2, GetArea()}
	Local cQuery    := ''
	Local cAlPX0    := ''
	Local cChvSE2   := ''
	Local cNumBor   := Space(Len(PX0->PX0_NUMBOR))
	Local cNumBco   := Space(Len(PX0->PX0_NUMBCO))

	If nTitAtu >= nTitMax
		Return
	EndIf

	Conout('F2000103 - Integ XRT Titulos AP - Consulta de realizados sem cheque/bordero '+FwTimeStamp(2))

	cQuery := " Select R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')
	cQuery += " Where  PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    And PX0_STTIT  = '1' " //Realizados
	cQuery += "    And PX0_NUMBCO = '"+cNumBco+"' "
	cQuery += "    And PX0_NUMBOR = '"+cNumBor+"' "
	cQuery += "    And PX0_STXRT In ('1', '3') "//Pendentes ou com falha de comunicação
	cQuery += "    And D_E_L_E_T_ = ' ' "
	cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlPX0 := MPSysOpenQuery(cQuery)

	SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
	FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
	While !(cAlPX0)->(EoF())
		PX0->(DbGoto((cAlPX0)->PX0Rec))
		If PX0->PX0_ORIGEM == 'FK2'
			If FK2->(DbSeek(RTrim(PX0->PX0_CHAVE)))
				cChvSE2 := U_F2000108(FK2->FK2_IDDOC)
			EndIf
		ElseIf PX0->PX0_ORIGEM == 'FK5'
			If FK5->(DbSeek(RTrim(PX0->PX0_CHAVE)))
				cChvSE2 := U_F2000211(FK5->FK5_IDMOV, FK5->FK5_IDDOC)
			EndIf
		Else
			cChvSE2 := RTrim(PX0->PX0_CHAVE)
		EndIf
		If !Empty(cChvSE2) .And. SE2->(DbSeek(cChvSE2))
			If RecLock('PX0', .F.)
				PX0->PX0_NUMBOR := SE2->E2_NUMBOR
				PX0->PX0_NUMBCO := SE2->E2_NUMBCO
				PX0->PX0_STXRT  := '1' //Pendente
				PX0->PX0_DTHR   := FwTimeStamp(1)
				PX0->(MsUnlock())
			EndIf
		EndIf

		(cAlPX0)->(DbSkip())

		//TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
			Exit
		EndIf
	EndDo

	Conout('F2000103 - Integ XRT Titulos AP - termino do ajuste de titulos realizados '+FwTimeStamp(2))

	(cAlPX0)->(DbCloseArea())

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return
/*/
/*/{Protheus.doc} GrvBor
    Grava borderô no título de temperatura 2, transformando-o em temperatura 1
    @type  Static Function
    @author Gianluca Moreira
    @since 28/05/2021
    /*/
/*
Static Function GrvBor(oWsOut, nTitAtu, nTitMax)
    Local aAreaSE2  := SE2->(GetArea())
    Local aAreaFK2  := FK2->(GetArea())
    Local aAreaFK5  := FK5->(GetArea())
    Local aAreaPX0  := PX0->(GetArea())
    Local aAreas    := {aAreaPX0, aAreaFK2, aAreaFK5, aAreaSE2, GetArea()} 
    Local cQuery    := ''
    Local cAlPX0    := ''
    Local cChvSE2   := ''
    Local cNumBor   := Space(Len(PX0->PX0_NUMBOR))

	If nTitAtu >= nTitMax
        Return
	EndIf

    Conout('F2000103 - Integ XRT Titulos AP - Consulta de previstos sem bordero '+FwTimeStamp(2))

    cQuery := " Select R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')
    cQuery += " Where  PX0_FILIAL = '"+FWXFilial('PX0')+"' "
    cQuery += "    And PX0_STTIT  = '3' " //Temp 2
    cQuery += "    And PX0_NUMBOR = '"+cNumBor+"' "
    cQuery += "    And D_E_L_E_T_ = ' ' "
    cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
    cQuery += "    ORDER BY PX0_DTHR ASC"
    cQuery := ChangeQuery(cQuery)

    cAlPX0 := MPSysOpenQuery(cQuery)
    cFwTmStamp := FwTimeStamp(1)
    SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
    FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
	While !(cAlPX0)->(EoF())
        PX0->(DbGoto((cAlPX0)->PX0Rec))
		If PX0->PX0_ORIGEM == 'FK2'
			If FK2->(DbSeek(RTrim(PX0->PX0_CHAVE)))
                cChvSE2 := U_F2000108(FK2->FK2_IDDOC)
			EndIf
		ElseIf PX0->PX0_ORIGEM == 'FK5'
			If FK5->(DbSeek(RTrim(PX0->PX0_CHAVE)))
                cChvSE2 := U_F2000211(FK5->FK5_IDMOV, FK5->FK5_IDDOC)
			EndIf
		Else
            cChvSE2 := RTrim(PX0->PX0_CHAVE)
		EndIf
		If !Empty(cChvSE2) .And. SE2->(DbSeek(cChvSE2))
			If !Empty(SE2->E2_NUMBOR)
                U_F2000100('SE2', ALTERA_PREV) //Atualiza os dados do título
			EndIf
		EndIf
        
        RecloCk("PX0",.F.)
        PX0->PX0_DTHR  := cFwTmStamp
        PX0->(MsUnlock())

        (cAlPX0)->(DbSkip())
        
        //TimeOut - encerra
		If TimeCounter()-_nTimeSt > _nTimeOut*0.70
            Exit
		EndIf
	EndDo

    Conout('F2000103 - Integ XRT Titulos AP - termino do ajuste de titulos previstos '+FwTimeStamp(2))

    (cAlPX0)->(DbCloseArea())

    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return
*/

/*/{Protheus.doc} GravaXML
    Preenche uma linha no objeto do XML com o título posicionado da PX0
    @type  Static Function
    @author Gianluca Moreira
    @since 17/05/2021
    /*/
Static Function GravaXML(oWsOut, nRecPX0)
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aAreaSE2, GetArea()}
	Local lRet      := .F.
	Local jDados    := JSonObject():New()
	Local nUlt      := 0
	Local cChave    := ''
	Local cIdP20    := ''
	Local nTemp     := 0
	Local cNumBco   := ''
	Local cNumBor   := ''
	Local cInstrum  := ''

	If nRecPX0 <= 0
		Return lRet
	EndIf

	PX0->(DbGoto(nRecPX0))
	//cTemp  := IIf(PX0->PX0_STTIT == '1', '+1', '-1')
	If PX0->PX0_STTIT == '1'
		nTemp := -1
	ElseIf PX0->PX0_STTIT == '2'
		nTemp := 1
	ElseIf PX0->PX0_STTIT == '3'
		nTemp := 2
	EndIf

	cChave := PX0->PX0_FILIAL+PX0->PX0_CHVXRT
	If jDados:FromJson(PX0->PX0_DADOS) == Nil
		AAdd(oWsOut:TITULOS, WSClassNew('W20001TIT'))
		nUlt := Len(oWsOut:TITULOS)

		cNumBco := PX0->PX0_NUMBCO
		cNumBor := PX0->PX0_NUMBOR

		//Após alinhamento, entende-se que devemos enviar o número do borderô ou cheque
		//como instrumento no XRT para consolidar os lançamentos num mesmo borderô
		//ou cheque
		cInstrum := IIf(!Empty(cNumBor), cNumBor, cNumBco)

		oWsOut:TITULOS[nUlt]:EMPFIL         := EncodeUTF8(cEmpAnt+'.'+cFilAnt)
		oWsOut:TITULOS[nUlt]:CHAVE          := EncodeUTF8(StrTran(cEmpAnt+cFilAnt+RTrim(PX0->PX0_CHAVE)+PX0->(PX0_CHVXRT), ' ', '_'))
		oWsOut:TITULOS[nUlt]:E2_XCHVXRT     := EncodeUTF8(cEmpAnt+cFilAnt+PX0->(PX0_CHVXRT))
		oWsOut:TITULOS[nUlt]:ORIGEM_SISTEMA := EncodeUTF8('AP_PROTHEUS')
		oWsOut:TITULOS[nUlt]:STATUSTIT      := nTemp
		oWsOut:TITULOS[nUlt]:A2_NOME        := PrepTag(jDados['A2_NOME'], 55)
		oWsOut:TITULOS[nUlt]:A2_CGC         := PrepTag(jDados['A2_CGC'])
		oWsOut:TITULOS[nUlt]:E2_NATUREZ     := EncodeUTF8(IIf(Empty(jDados['E2_NATUREZ']), ' ', jDados['E2_NATUREZ']))
		oWsOut:TITULOS[nUlt]:E2_TIPO        := PrepTag(jDados['E2_TIPO'])
		oWsOut:TITULOS[nUlt]:E2_VENCREA     := PrepTag(jDados['E2_VENCREA'])
		oWsOut:TITULOS[nUlt]:E5_DATA        := PrepTag(jDados['E5_DATA'])
		oWsOut:TITULOS[nUlt]:E2_SALDO       := PX0->PX0_VALOR
		oWsOut:TITULOS[nUlt]:E2_PORTADO     := PrepTag(jDados['E2_PORTADO'], 6)
		oWsOut:TITULOS[nUlt]:E2_XAGEPOR     := PrepTag(jDados['E2_XAGEPOR'], 7)
		oWsOut:TITULOS[nUlt]:E2_XCONPOR     := PrepTag(jDados['E2_XCONPOR'], 20)
		oWsOut:TITULOS[nUlt]:E2_FORMPAG     := PrepTag(jDados['E2_FORMPAG'])
		oWsOut:TITULOS[nUlt]:E2_NUMBOR      := PrepTag(cInstrum, 15)
		oWsOut:TITULOS[nUlt]:E2_HIST        := PrepTag(jDados['E2_HIST'], 160)
		oWsOut:TITULOS[nUlt]:E2_MOEDA       := IIf(Empty(jDados['E2_MOEDA']), 0, jDados['E2_MOEDA'])
		oWsOut:TITULOS[nUlt]:E2_TXMOEDA     := IIf(Empty(jDados['E2_TXMOEDA']), 0, jDados['E2_TXMOEDA'])
		oWsOut:TITULOS[nUlt]:F1_NOTA        := PrepTag(jDados['F1_NOTA'], 12)
		oWsOut:TITULOS[nUlt]:E2_XOPFXRT     := PrepTag(jDados['E2_XOPFXRT'])
		oWsOut:TITULOS[nUlt]:E2_NUMBCO      := EncodeUTF8(PX0->PX0_NUMBCO) //Não utilizado

		lRet := .T.
	EndIf

	If lRet
		cIdP20 := U_F07Log03("U_F2000103", oWsOut:TITULOS[nUlt], 'OK', "2", "PX0", 3, cChave)
	Else
		U_F07Log03("U_F2000103", oWsOut:TITULOS[nUlt], 'Falha', "1", "PX0", 3, cChave)
	EndIf

	If lRet .And. RecLock('PX0', .F.)
		PX0->PX0_STXRT := '5' //Enviado ao barramento
		PX0->PX0_STINT := '1' //Integrado
		PX0->PX0_IDP20 := FWXFilial('PX0')+cIdP20
		PX0->PX0_DTHR  := FwTimeStamp(1)
		PX0->(MsUnlock())
	EndIf

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return lRet

/*/{Protheus.doc} PrepTag
    Prepara a tag a ser enviada ao XRT
    @type  Static Function
    @author Gianluca Moreira
    @since 11/08/2021
    /*/
Static Function PrepTag(cTexto, nTamanho)
	Local cRet := ''

	Default nTamanho := 0

	cRet := cTexto
	If Empty(cTexto)
		cRet := ' '
	Else
		cRet := FwNoAccent(AllTrim(cRet))
		cRet := StrTran(cRet, 'ç', 'c')
		cRet := StrTran(cRet, 'Ç', 'C')
		If nTamanho > 0
			cRet := Left(cRet, nTamanho)
		EndIf
	EndIf

Return EncodeUTF8(cRet)

/*/{Protheus.doc} GrvXmlVaz
    Grava o XML vazio caso não encontre títulos
    @type  Static Function
    @author Gianluca Moreira
    @since 24/05/2021
    /*/
Static Function GrvXmlVaz(oWsOut)
	AAdd(oWsOut:TITULOS, WSClassNew('W20001TIT'))
	oWsOut:TITULOS[1]:EMPFIL         := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:CHAVE          := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_XCHVXRT     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:ORIGEM_SISTEMA := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:STATUSTIT      := 0
	oWsOut:TITULOS[1]:A2_NOME        := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:A2_CGC         := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_NATUREZ     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_TIPO        := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_VENCREA     := EncodeUTF8('1900-01-01T00:00:00.000')
	oWsOut:TITULOS[1]:E5_DATA        := EncodeUTF8('1900-01-01T00:00:00.000')
	oWsOut:TITULOS[1]:E2_SALDO       := 0
	oWsOut:TITULOS[1]:E2_PORTADO     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_XAGEPOR     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_XCONPOR     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_FORMPAG     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_NUMBOR      := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_HIST        := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_MOEDA       := 0
	oWsOut:TITULOS[1]:E2_TXMOEDA     := 0
	oWsOut:TITULOS[1]:F1_NOTA        := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_XOPFXRT     := EncodeUTF8(' ')
	oWsOut:TITULOS[1]:E2_NUMBCO      := EncodeUTF8(' ')

	oWsOut:QTDTIT := 0
Return


/*/{Protheus.doc} LimpaArr
Limpa o array em todos os níveis.

@Project    0000038959 - P01039/08
@type       User Function
@author     Rafael Riego
@since      29/03/2019
@version    1.0
@param      aArray, array, array a ser destruído
@return     lEstornou, verdadeiro = estornou todos os itens;falso = ocorreu erro no estorno de algum item
/*/
User Function LimpaArr(aArray)

	Local nLenArray := 0
	Local nPosArray := 0

	If ValType(aArray) == "A"
		nLenArray := Len(aArray)
		For nPosArray := 1 To nLenArray
			If ValType(aArray[nPosArray]) == "A"
				U_LimpaArr(aArray[nPosArray])
			ElseIf ValType(aArray[nPosArray]) == "O"
				FwFreeObj(aArray[nPosArray])
			EndIf
		Next nPosArray
		FwFreeObj(aArray)
		ASize(aArray, 0)
		aArray := Nil
	EndIf

Return Nil
