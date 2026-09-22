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

/*/{Protheus.doc} F2001031
    Funções para gravar dados na PX0, criado para melhorar a performance da integração.
    @type  Static Function
    @author Lucas Miranda
    @since 11/05/2023
    /*/
User Function F2001031()
	Local aAreaSE2  := ""//SE2->(GetArea())
	Local aAreaPX0  := ""//PX0->(GetArea())
	Local aAreas    := ""//{aAreaPX0, aAreaSE2, GetArea()}
	Local cQuery    := ''
	Local cChave    := ''
	Local cAlSE2    := ''
	Local nRecPX0   := 0
	Local nPeriodo  := ""//SuperGetMV('FS_N200014',, 90)
	//Local cWsCall := 'S_F2001031'

	/*/Default cEmpAux     := FwCodEmp()
	Default cFilAux     := FwCodFil()
/*/
	//Tratamento de semáforo
	/*/if !GlbNmLock(cWsCall)
		Conout("THREAD: " + cValToChar(threadID()) + " a Rotina(F2001031) esta em uso e não será chamada.")
		Return
	else
		Conout("THREAD: " + cValToChar(threadID()) + " a Rotina(F2001031) não esta em uso e será chamada.")
	EndIf
	RpcSetEnv(cEmpAux, cFilAux,,, "FIN", "U_F2001031")/*/

	 aAreaSE2  := SE2->(GetArea())
	 aAreaPX0  := PX0->(GetArea())
	 aAreas    := {aAreaPX0, aAreaSE2, GetArea()}
	 nPeriodo  := SuperGetMV('FS_N200014',, 90)
	/*/If nTitAtu >= nTitMax
	U_LimpaArr(aAreas)
Return
	EndIf/*/

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
	cQuery += " SE2.R_E_C_N_O_ SE2Rec, E2_FILIAL FIL "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	//cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	//Não enviar com data de pagamento retroativa
	cQuery += " WHERE "
	cQuery += "    (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
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
	cQuery += "  Where PX0.PX0_FILIAL = SE2.E2_FILIAL"
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	//cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		cFilAnt := (cAlSE2)->FIL
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		/*/If GravaXML(oWsOut, nRecPX0)
		++nTitAtu
		EndIf/*/
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		/*/If TimeCounter()-_nTimeSt > _nTimeOut*0.70
		Exit
		EndIf/*/
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos que nao sao impostos '+FwTimeStamp(2))

	/*/If nTitAtu >= nTitMax .Or. (TimeCounter()-_nTimeSt > _nTimeOut*0.70)
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return
	EndIf/*/

	//Segunda Consulta - Títulos aglutinados gerados pela FINA290
	cQuery := " Select  SE2.R_E_C_N_O_ SE2Rec, SE2.E2_FILIAL FIL "
	cQuery += "   From "+RetSqlName('SE2')+" SE2  "
	cQuery += "   Join "+RetSqlName('SE2')+" SE2B "
	cQuery += "     On SE2B.E2_FILIAL  = SE2.E2_FILIAL "
	cQuery += "    And SE2B.E2_FATPREF = SE2.E2_PREFIXO "
	cQuery += "    And SE2B.E2_FATURA  = SE2.E2_NUM "
	cQuery += "    And SE2B.E2_TIPOFAT = SE2.E2_TIPO "
	cQuery += "    And SE2B.E2_FATFOR  = SE2.E2_FORNECE "
	cQuery += "    And SE2B.E2_FATLOJ  = SE2.E2_LOJA "
	cQuery += "    And SE2B.E2_FLAGFAT = 'S' "
	//cQuery += "    And SE2B.E2_TIPO In ('ISS', 'INS') "
	cQuery += "    And SE2B.D_E_L_E_T_ = ' ' "
	//cQuery += "  Where SE2.E2_FILIAL   = '"+FWXFilial('SE2')+"' "
	cQuery += "    WHERE (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
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
	cQuery += "  Where PX0.PX0_FILIAL = SE2.E2_FILIAL "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	//cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		cFilAnt := (cAlSE2)->FIL
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		/*/If GravaXML(oWsOut, nRecPX0)
		++nTitAtu
		EndIf/*/
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		/*/If TimeCounter()-_nTimeSt > _nTimeOut*0.70
		Exit
		EndIf/*/
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos aglutinados FINA290 '+FwTimeStamp(2))

	/*/If nTitAtu >= nTitMax .Or. (TimeCounter()-_nTimeSt > _nTimeOut*0.70)
	AEval(aAreas, {|x| RestArea(x)})
Return
	EndIf/*/

	//Terceira Consulta - Títulos aglutinados gerados por demais rotinas
	cQuery := " Select SE2.R_E_C_N_O_ SE2Rec, SE2.E2_FILIAL FIL "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	//cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	//Não enviar com data de pagamento retroativa
	cQuery += "    WHERE (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
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
	cQuery += "  Where PX0.PX0_FILIAL = SE2.E2_FILIAL "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	//cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		cFilAnt := (cAlSE2)->FIL
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		/*/If GravaXML(oWsOut, nRecPX0)
		++nTitAtu
		EndIf/*/
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		/*/If TimeCounter()-_nTimeSt > _nTimeOut*0.70
		Exit
		EndIf/*/
	EndDo

	(cAlSE2)->(DbCloseArea())

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos aglutinados - demais rotinas '+FwTimeStamp(2))

	cQuery := " Select "
	cQuery += " SE2.R_E_C_N_O_ SE2Rec, SE2.E2_FILIAL FIL "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	//cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	//Não enviar com data de pagamento retroativa
	cQuery += "    WHERE (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
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
	cQuery += "      SE5.E5_FILIAL  = SE2.E2_FILIAL "
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
	cQuery += "  Where PX0.PX0_FILIAL = SE2.E2_FILIAL "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	//cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		cFilAnt := (cAlSE2)->FIL
		nRecPX0 := U_F2000100('SE2', INCLUI_PREV)
		/*/If GravaXML(oWsOut, nRecPX0)
		++nTitAtu
		EndIf/*/
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		/*/If TimeCounter()-_nTimeSt > _nTimeOut*0.70
		Exit
		EndIf/*/
	EndDo

	(cAlSE2)->(DbCloseArea())

	GeraRecusa()//Gera as recusas na PX0
	GrvChq()// grava o cheque

	Conout('F2000103 - Integ XRT Titulos AP - Leu titulos de adiantamento '+FwTimeStamp(2))

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)

	cFilAnt := cFilAux
	GlbNmUnlock(cWsCall)

	RpcClearEnv()
Return


Static Function GeraRecusa()
	Local aAreaSE2  := SE2->(GetArea())
	Local aAreaPX0  := PX0->(GetArea())
	Local aAreas    := {aAreaPX0, aAreaSE2, GetArea()}
	Local cQuery    := ''
	Local cChave    := ''
	Local cAlSE2    := ''
	Local nRecPX0   := 0
	Local nPeriodo  := SuperGetMV('FS_N200014',, 90)

	/*/If nTitAtu >= nTitMax
	U_LimpaArr(aAreas)
Return
	EndIf/*/

	cChave := 'SE2.E2_FILIAL||'
	cChave += 'SE2.E2_PREFIXO||'
	cChave += 'SE2.E2_NUM||'
	cChave += 'SE2.E2_PARCELA||'
	cChave += 'SE2.E2_TIPO||'
	cChave += 'SE2.E2_FORNECE||'
	cChave += 'SE2.E2_LOJA'

	Conout('F2000103 - Integ XRT Titulos AP - Buscando Titulos recusados... '+FwTimeStamp(2))

	cQuery := " Select "
	cQuery += " SE2.R_E_C_N_O_ SE2Rec, E2_FILIAL FIL "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	//cQuery += "  Where SE2.E2_FILIAL  = '"+FWXFilial('SE2')+"' "
	cQuery += "    WHERE (SE2.E2_VENCREA Between '"+DToS(Date())+"' And '"+DToS(Date()+nPeriodo)+"') "
	cQuery += "    And Exists ( "
	cQuery += " Select PX0.R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')+" PX0 "
	cQuery += "  Where PX0.PX0_FILIAL = SE2.E2_FILIAL "
	cQuery += "    And (PX0.PX0_STTIT = '2' Or PX0.PX0_STTIT  = '3') " //Previstos
	cQuery += "    And PX0.PX0_ORIGEM = 'SE2' "
	cQuery += "    And Trim(Trailing ' ' From PX0.PX0_CHAVE)  = Trim(Trailing ' ' From "+cChave+") "
	cQuery += "    And PX0.PX0_EXC    = '2' "
	cQuery += "    And PX0.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
	cQuery += "    And SE2.E2_XSTRECU = 'R' " //Recusado
	cQuery += "    And SE2.D_E_L_E_T_ = ' ' "
	//cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlSE2 := MPSysOpenQuery(cQuery)

	While !(cAlSE2)->(EoF())
		SE2->(DbGoto((cAlSE2)->SE2Rec))
		cFilAnt := (cAlSE2)->FIL
		nRecPX0 := U_F2000100('SE2', EXCLUI_PREV)
		/*/If GravaXML(oWsOut, nRecPX0)
		++nTitAtu
		EndIf/*/
		(cAlSE2)->(DbSkip())
		//TimeOut - encerra
		/*/If TimeCounter()-_nTimeSt > _nTimeOut*0.70
		Exit
		EndIf/*/
	EndDo

	(cAlSE2)->(DbCloseArea())
	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return



Static Function GrvChq()
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

	/*/If nTitAtu >= nTitMax
Return
	EndIf/*/

	Conout('F2000103 - Integ XRT Titulos AP - Consulta de realizados sem cheque/bordero '+FwTimeStamp(2))

	cQuery := " Select R_E_C_N_O_ PX0Rec, PX0_FILIAL FIL From "+RetSqlName('PX0')
	//cQuery += " Where  PX0_FILIAL = '"+FWXFilial('PX0')+"' "
	cQuery += "    WHERE PX0_STTIT  = '1' " //Realizados
	cQuery += "    And PX0_NUMBCO = '"+cNumBco+"' "
	cQuery += "    And PX0_NUMBOR = '"+cNumBor+"' "
	cQuery += "    And PX0_STXRT In ('1', '3') "//Pendentes ou com falha de comunicação
	cQuery += "    And D_E_L_E_T_ = ' ' "
	//cQuery += "    And ROWNUM <= "+cValToChar(nTitMax-nTitAtu)
	cQuery := ChangeQuery(cQuery)

	cAlPX0 := MPSysOpenQuery(cQuery)

	SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
	FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
	While !(cAlPX0)->(EoF())
		PX0->(DbGoto((cAlPX0)->PX0Rec))
		cFilAnt := (cAlPX0)->FIL
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
		/*/If TimeCounter()-_nTimeSt > _nTimeOut*0.70
		Exit
		EndIf/*/
	EndDo

	Conout('F2000103 - Integ XRT Titulos AP - termino do ajuste de titulos realizados '+FwTimeStamp(2))

	(cAlPX0)->(DbCloseArea())

	AEval(aAreas, {|x| RestArea(x)})
	U_LimpaArr(aAreas)
Return
