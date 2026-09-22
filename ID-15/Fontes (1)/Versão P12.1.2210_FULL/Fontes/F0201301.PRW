#Include 'Protheus.ch'
#Include 'FwCommand.ch'

/*
{Protheus.doc} F0201301()
Holerite Eletrônico Santander 
@Author     Bruno de Oliveira
@Since      19/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Menu		SIGAGPE
@Return 	lRet
*/
User Function F0201301()

	Local aArea		:= GetArea()
	Local cPerg		:= "FSW0201301"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cCadastro	:= OemToAnsi("Processo de Geração de Holerite Eletrônico Banco Santander")

	AjustPerg(cPerg)

	Pergunte(cPerg,.F.)
			
	AAdd(aSays,OemToAnsi("Este programa realiza o processo de geração do Holerite Eletrônico do Banco"))
	AAdd(aSays,OemToAnsi("Santander"))
	
	AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If((MsgYesNo("Confirma configuração dos parâmetros?","Atenção")),FechaBatch(),nOpca:=0) }} )
	AAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		
	FormBatch(cCadastro,aSays,aButtons)

	If nOpca == 1
		If VldPergnt(mv_par10,mv_par11,mv_par02,mv_par12,mv_par13)
			Processa({|| FSGerArq(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09,mv_par10,mv_par11,mv_par12,mv_par13,mv_par14),"Gerando Holerite Eletrônico"})
		EndIf
	EndIf

	RestArea(aArea)

Return

/*
{Protheus.doc} FSGerArq()
Geração de Holerite Eletrônico Santander 
@Author   	Bruno de Oliveira
@Since    	19/04/2016
@Version  	P12.1.07
@Project  	MAN00000463301_EF_013
@Param		cRecibo, caracter, roteiro de cálculo
@Param		cFil, caracter, Filial da empresa
@Param		cCCT, caracter, Centro de Custo
@Param		cMatric, caracter, Matricula
@Param		cProcesso, caracter, Processo do período
@Param		cNSeman, caracter, semana do período
@Param		cNome, caracter, nome do funcionário
@Param		cSituac, caracter, situação do funcionário
@Param		cCategor, caracter, categoria do funcionário
@Param		cCaminho, caracter, caminho do arquivo
@Param		dDtLibPg, date, Data da liberação do Pagamento
@Param		cRefOpLte, caracter, referencia da operação do Lote		
@Param		cBncAgConv, caracter, Banco + Agencia + Convenio
@Param		cLote, caracter, número do Lote
@Param		dDataGer, date, data de geração
@Return 	lRet
*/
Static Function FSGerArq(cRecibo,cFil,cCCT,cMatric,cProcesso,cNSeman,cNome,cSituac,cCategor,cArq,dDtLibPg,cRefOpLte,cLote,dDataGer)

	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cAcessaSRA := &("{ || " + ChkRH("GPER030 ","SRA","2") + "}")
	Local cSitFol    := ""
	Local cCateg     := ""
	Local nX
	Local cAliasMov  := ""
	Local cBncAgConv := SuperGetMv("FS_CONVEN",.F.,,cFil)
	Local cCCorrEmp  := SuperGetMv("FS_CONTCC",.F.,,cFil)
	Local cCaminho   := SuperGetMv("FS_ROTARQ",.F.,,cFil)

	Private nAteLim   := 0
	Private nBaseFgts := 0
	Private nFgts     := 0
	Private nBaseIr   := 0
	Private nBaseIrFe := 0
	Private nBaseInss := 0
	Private nSeqLan   := 0
	Private cLinP12   := ""
	Private aProvent  := {}
	Private aDescont  := {}
	Private aBaseP    := {}
	Private aCodFol   := {}
	Private nTotProv  := 0
	Private nTotDesc  := 0
	Private nTotRegt  := 0
	Private lCrdArq   := .F.

	nTFil	:= TAMSX3("RA_FILIAL")[1]
	nTCC	:= TAMSX3("RA_CC")[1]
	nTMatri:= TAMSX3("RA_MAT")[1]
	nTProc	:= TAMSX3("RA_PROCES")[1]

	If !Empty(cSituac)
	
		For nX := 1 To Len(cSituac)
	
			cPosSit := SubsTr(cSituac,nX,1)
			If cPosSit != "*"
				cSitFol += "'" + cPosSit + "',"
			EndIf
	
		Next nX

		If Empty(cSitFol)
			cSitFol := " "
		EndIf
		cSitFol := SubStr(cSitFol,1,Len(cSitFol)-1)
	EndIf

	If !Empty(cCategor)
	
		For nX := 1 To Len(cCategor)
	
			cPosCat := SubsTr(cCategor,nX,1)
			If cPosCat != "*"
				cCateg += "'" + cPosCat + "',"
			EndIf
	
		Next nX

		If Empty(cCateg)
			cCateg := " "
		EndIf
		cCateg := SubStr(cCateg,1,Len(cCateg)-1)
	EndIf

	cAliasSRA := GetNextAlias()
	MakeSqlExpr("FSW0201301")

	cQuery := "SELECT DISTINCT"
	cQuery += " RA_FILIAL,RA_MAT,RA_CC,RA_SITFOLH,RA_PROCES,RA_NOME,RA_DEMISSA,RA_CODFUNC "
	cQuery += "FROM "
	cQuery += "	" + RetSqlName("SRA") + " SRA "

	If 	cRecibo = 'FER' .OR. cRecibo == "RES"
		cQuery += "," + RetSqlName("SRR") + " SRR "
	EndIf

//If cRecibo = '132'
//	cQuery += "," + RetSqlName("SRI") + " SRI "
//EndIf

	If cRecibo = 'FOL' .OR. cRecibo = '131' .OR. cRecibo = 'ADI' .OR. cRecibo == "PLR" .OR. cRecibo == "132"
		cQuery += "," + RetSqlName("SRC") + " SRC "
	EndIf

	cQuery += "WHERE "
	cQuery += "SRA.RA_FILIAL = '" + cFil + "' AND "

	If !Empty(cMatric)
		cQuery += MV_PAR04 + " AND " //Range Matricula
	EndIf

	If !Empty(cCCT)
		cQuery += MV_PAR03 + " AND " //Range Centro de Custo
	EndIf

	If !Empty(cProcesso)
		cQuery += MV_PAR05 + " AND " // Range Processo
	EndIf

	If !Empty(cNome)
		cQuery += MV_PAR07 + " AND " //Range Nome
	EndIf

	cQuery += " SRA.RA_CTDEPSA <> '            ' AND"

	If !Empty(cSitFol)
		cQuery += " SRA.RA_SITFOLH IN (" + cSitFol + ") AND"
	EndIf

	If !Empty(cCateg)
		cQuery += " SRA.RA_CATFUNC IN (" + cCateg + ") AND"
	EndIf

	If cRecibo = 'FER' .OR. cRecibo == "RES"
		cQuery += "	SRR.RR_ROTEIR = '" + cRecibo + "'"
		cQuery += "	AND SRR.RR_MAT = SRA.RA_MAT"
		cQuery += "	AND SRR.D_E_L_E_T_ = ' ' AND"
	EndIf

	If cRecibo = 'FOL' .OR. cRecibo = '131' .OR. cRecibo = 'ADI' .OR. cRecibo == "PLR" .OR. cRecibo == "132"
		cQuery += "	SRC.RC_ROTEIR = '" + cRecibo + "'"
		cQuery += "	AND SRC.RC_MAT = SRA.RA_MAT"
		cQuery += "	AND SRC.D_E_L_E_T_ = ' ' AND"
	EndIf

	cQuery += "	SRA.D_E_L_E_T_ = ' ' "

	cQuery 	   := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA)

	aPerAtual := {}
	cFilRCH := cFil//xFilial("RCH")
	cPerAt := ""

	If fGetPerAtual(@aPerAtual,cFilRCH,(cAliasSRA)->RA_PROCES,cRecibo)
		cPerAt := aPerAtual[1][1]
	EndIf

	If ! (cAliasSRA)->(EOF()) .OR. cPerAt != ""
		nArq := FCreate(cCaminho + cArq)
		lCrdArq := .T.
		If nArq == -1
			lCrdArq := .F.
			Help(" ",1,"FSGerArq",,"Não foi possível criar o arquivo em :" + Alltrim(cCaminho) + ", verifique caminho e nome do arquivo. Operação cancelada.",1,0)
			RestArea(aArea)
			Return
		EndIf
		ProcRegua((cAliasSRA)->(LASTREC()))
		FsHeadEmp(cRecibo,dDtLibPg,cRefOpLte,cBncAgConv,cLote,cCCorrEmp,cPerAt,cFil,dDataGer)
	EndIf

	While ! (cAliasSRA)->(EOF()) .AND. cPerAt != ""

		FsHeadComp((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cBncAgConv,(cAliasSRA)->RA_CODFUNC)

		Fp_CodFol(@aCodFol,(cAliasSRA)->RA_Filial)

		IncProc((cAliasSRA)->RA_FILIAL + "-" + (cAliasSRA)->RA_MAT + "-" + (cAliasSRA)->RA_NOME)

		If cRecibo == "ADI" .OR. cRecibo == "FOL"
	
			FBscMovPer((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cRecibo,(cAliasSRA)->RA_PROCES,cPerAt,cNSeman,aCodFol)
		
			nVlProv := FRegDetPrv((cAliasSRA)->RA_MAT)
			nVlDesc := FRegDetDsc((cAliasSRA)->RA_MAT)
			FsTrailFun(nVlProv,nVlDesc,(cAliasSRA)->RA_MAT)
		ElseIf cRecibo == "131" .OR. cRecibo == "PLR" .OR. cRecibo == "132"

			FBscMovPer((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cRecibo,(cAliasSRA)->RA_PROCES,cPerAt,"",aCodFol)
		
			nVlProv := FRegDetPrv((cAliasSRA)->RA_MAT)
			nVlDesc := FRegDetDsc((cAliasSRA)->RA_MAT)
			FsTrailFun(nVlProv,nVlDesc,(cAliasSRA)->RA_MAT)
		ElseIf cRecibo == "FER" .OR. cRecibo == "RES"
	
			FBscMovFer((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cRecibo,(cAliasSRA)->RA_PROCES,cPerAt,"",aCodFol)
		
			nVlProv := FRegDetPrv((cAliasSRA)->RA_MAT)
			nVlDesc := FRegDetDsc((cAliasSRA)->RA_MAT)
			FsTrailFun(nVlProv,nVlDesc,(cAliasSRA)->RA_MAT)
		EndIf

		(cAliasSRA)->(DbSkip())
	End

	FsTrailEmp(cBncAgConv,cFil)

	RestArea(aArea)

Return

/*
{Protheus.doc} FsHeadEmp()
Cabeçalho da Empresa
@Author     Bruno de Oliveira
@Since      22/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cRecibo, caracter, Roteiro de cálculo
@Param		dDtLiPg, date, Data de liberação Pagamento
@Param		cRefOpLte, caracter, referencia da Operação do Lote
@Param		cBncAgConv, caracter, Banco + Agencia + Convenio
@Param		cLote, caracter, número do lote
@Param		cCCorrEmp, caracter, Conta Corrente da Empresa
@Param		cPerAt, caracter, Período Atual
@Param		cFil, caracter, filial do perguntes
@Param		dDataGer, date, data da geração
@Return 	
*/
Static Function FsHeadEmp(cRecibo,dDtLibPg,cRefOpLte,cBncAgConv,cLote,cCCorrEmp,cPerAt,cFil,dDataGer)

	Local aArea   := GetArea()
	Local nLoteMg := SuperGetMv("MQ_CONTGP2",.F.,1,cFil)
	Local aDdsEmp := FWArrFilAtu(cEmpAnt,cFil)
	Local nAux    := 0

	Do case
	Case cRecibo == "ADI" // Adiantamento
		cTpPgt := "J"
	Case cRecibo == "FOL" // Pagto Mensal
		cTpPgt := "P"
	Case cRecibo == "131" // 1 Parcela 13
		cTpPgt := "A"
	Case cRecibo == "132" // 2 Parcela 13
		cTpPgt := "B"
	Case cRecibo == "FER" // Ferias
		cTpPgt := "G"
	Case cRecibo == "PLR" // PLR
		cTpPgt := "R"
	EndCase

	If cRefOpLte == 1
		cRefOper := "T"
	ElseIf cRefOpLte == 2
		cRefOper := "A"
	ElseIf cRefOpLte == 3
		cRefOper := "S"
	EndIf

	cLinP12 := PADR("0",1)														// 0001-0001 Tipo de registro = 0
	cLinP12 += "E"																// 0002-0002 Tipo de Transmissão "E" (Envio)
	cLinP12 += PADR(cBncAgConv,20)												// 0003-0022 Número do Convênio da Empresa ,Composto por: Banco + Agência + convênio
	cLinP12 += PADR(cRefOper,1)													// 0023-0023 Tipo de arquivo (T=CARGA,A=ALTERACAO,S=SUBSTIRUICAO)
	cLinP12 += StrZero(nLoteMg,6)												// 0024-0029 Sequencia de envio do arquivo
	If cRefOper == 'T'
		cLinP12 += StrZero(nLoteMg,6)											// 0030-0035 Número do Lote
	
		Pergunte('FSW0201301',.F.)
		MV_PAR13 := nLoteMg

	Else
		cLinP12 += StrZero(VAL(cLote),6)									// 0030-0035 Número do Lote
	EndIf
	cLinP12 += FwNoAccent(Alltrim(aDdsEmp[6]) + space(47 - Len(Alltrim(aDdsEmp[6]))))	// 0036-0082 Nome da Empresa
	cLinP12 += aDdsEmp[18]														// 0083-0096 CNPJ empresa=03311116000130
	cLinP12 += PadR(cPerAt,6)													// 0097-0102 Data de Referencia do Pagamento - Mes/Ano de Pagamento (AAAAMM)
	cLinP12 += PadR(DTOS(dDtLibPg),8)											// 0103-0110 Data de crédito (AAAAMMDD)
	cLinP12 += PadR(DTOS(dDtLibPg),8)											// 0111-0118 Data de liberacao do consulta comprovante (AAAAMMDD)
	cLinP12 += PadR(DTOS(dDataGer),8)											// 0119-0126 Data da geração do arquivo (AAAAMMDD)
	cLinP12 += SubStr(TIME(),1,2) + SUBSTR(TIME(),4,2) + SUBSTR(TIME(),7,2)	// 0127-0132 Hora da geração do arquivo
	cLinP12 += cCCorrEmp														// 0133-0152 Banco da Empresa
	cLinP12 += cTpPgt																// 0153-0153 Tipo do pagamento
	cLinP12 += Space(247)														// 0154-0400 Livre para futuras utilizações

	cLinP12 += Chr(13) + Chr(10)
	FWrite(nArq, cLinP12, Len(cLinP12))
	nTotRegt++
	cLinP12 := ""

	RestArea(aArea)

Return

/*
{Protheus.doc} FsHeadComp()
Cabeçalho do Funcionário
@Author     Bruno de Oliveira
@Since      22/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cFilQry, caracter, Filial da Empresa
@Param		cMatricFun, caracter, Matricula do Funcionário
@Param		cBncAgConv, caracter, Banco + Agencia + Convenio
@param		cCodFunc, caractere, Codigo da função
@Return 	
*/
Static Function FsHeadComp(cFilQry,cMatricFun,cBncAgConv,cCodFunc)

	Local aArea		:= GetArea()
	Local aAreaSRA	:= SRA->(GetArea())

	Local cFunc      := ""
	Local cFilSRJ    := ""
	Local cFilSRJOri := xFilial("SRJ")
	Local nTamFilTot := Len(cFilSRJOri)
	Local nTamFilSRA := Len(AllTrim(cFilQry))
	Local nTamFilSRJ := Len(AllTrim(cFilSRJOri))
	
	If nTamFilSRJ > nTamFilSRA
		cFunc := "ER.COMPART. SRJ"
	ElseIf nTamFilSRJ == nTamFilSRA 
		cFilSRJ := cFilQry
	ElseIf nTamFilSRJ == 0 
		cFilSRJ := cFilSRJOri
	Else
		cFilSRJ := PadR(Left(cFilQry,nTamFilSRJ),nTamFilTot)
	EndIf
	
	If Empty(cFunc)
		cFunc := Posicione("SRJ",1,cFilSRJ + cCodFunc,"RJ_DESC")
	EndIf

	nSeqLan := 0

	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	SRA->(DbSeek(cFilQry + cMatricFun))

	cLinP12 += PadR("1",1)																				// 0001-0001 Tipo de registro = 1
	cLinP12 += PadR(cBncAgConv,20)																		// 0002-0021 Número do Convênio da Empresa ,Composto por: Banco + Agência + convênio
	cLinP12 += Padr("00000000000000" + SubStr(cMatricFun,1,6),20)										// 0022-0041 Matricula do funcionario
	cLinP12 += Padr(SRA->RA_CIC,11)																		// 0042-0052 CPF funcionario
	cLinP12 += Padr(Alltrim(SRA->RA_NOME),47)		  													// 0053-0099 Nome funcionario
	cLinP12 += StrZero(Val(SubStr(SRA->RA_BCDEPSA,1,3)),4)											// 0100-0103 Banco do funcionario Deve ser 0008 ou 0033 ou 0353 (INCLUIR COM 3 CARACTERES)
	cLinP12 += StrZero(Val(SubStr(SRA->RA_BCDEPSA,4,4)),4)											// 0104-0107 Numero da agencia do funcionario ANGENCIA COM 4 CARACTERES
	cLinP12 += STRZERO(VAL(SUBSTR(SRA->RA_CTDEPSA, 1, LEN(ALLTRIM(SRA->RA_CTDEPSA)) )),12)	// 0108-0119 Numero da conta do funcionario
	cLinP12 += Padr("HISTORICO DE DEBITOS",35)														// 0120-0154 Cabeçalho Débito
	cLinP12 += Padr("HISTORICO DE CREDITOS",35)														// 0155-0189 Cabeçalho Crédito
	cLinP12 += Padr("LIQUIDO A RECEBER",35)															// 0190-0224 Cabeçalho LIQUIDO A RECEBER
	cLinP12 += Space(1)																					// 0225-0225 Bloqueio de visualização e impressão do Holerite
	cLinP12 += Space(15)																					// 0226-0240 livre para futuras utilizações
	cLinP12 += "000000000000"																			// 0241-0252 livre para futuras utilizações
	cLinP12 += Substr(cFunc,1,15)																// 0253-0267 Descricao do cargo do funcionario
	cLinP12 += "N"																						// 0268-0268 Indicador de matrícula 'S' MAIS DE UMA , 'N' SOMENTE UMA
	cLinP12 += Space(132)																				// 0269-0400 Livre para futuras utilizações

	cLinP12 += Chr(13) + Chr(10)
	FWrite(nArq, cLinP12, Len(cLinP12))
	nTotRegt++
	cLinP12 := ""

	RestArea(aAreaSRA)
	RestArea(aArea)

Return

/*
{Protheus.doc} FBscMovPer()
Busca os Movimentos do Periodo
@Author     Bruno de Oliveira
@Since      22/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cFilQry, caracter, Filial do sistema
@Param		cMat, caracter, matricula do funcionário
@Param		cRecibo, caracter, Roteiro de Cálculo
@Param		cProcess, caracter, Processo do período
@Param		cPerAtu, caracter, Período Atual
@Param		cNSeman, caracter, Numero da Semana
@Param		aCodFol, array, código das verbas
@Return 	
*/
Static Function FBscMovPer(cFilQry,cMat,cRecibo,cProcess,cPerAtu,cNSeman,aCodFol)

	Local aArea   := GetArea()
	Local cQuery  := ""
	Local cFilSRV := xFilial("SRV")
	Local cIRfSem := SuperGetMv("MV_IREFSEM",,"S")
	Local cAlias1 := ''

	nAteLim	:= 0
	nBaseFgts	:= 0
	nFgts		:= 0
	nBaseIr	:= 0
	nBaseInss	:= 0
	nBaseIrFe	:= 0
	aProvent	:= {}
	aDescont	:= {}
	aBaseP		:= {}

	cAlias1 := GetNextAlias()

	cQuery := "SELECT "
	cQuery += "RC_FILIAL,RC_MAT,RC_PD,RC_VALOR,RC_SEMANA,RC_PROCES,RC_PERIODO,RC_ROTEIR,"
	cQuery += "RC_QTDSEM,RC_HORAS,RV_TIPOCOD,RV_DESC "
	cQuery += "FROM "
	cQuery += "	" + RetSqlName("SRC") + " SRC "
	cQuery += "LEFT JOIN "
	cQuery += " " + RetSqlName("SRV") + " SRV "
	cQuery += "ON (SRV.RV_COD = SRC.RC_PD "
	cQuery += "AND 	SRV.D_E_L_E_T_ = ' ') "
	cQuery += "WHERE "
	cQuery += "SRC.RC_FILIAL = '" + cFilQry + "' AND "
	cQuery += "SRC.RC_MAT = '" + cMat + "' AND "
	cQuery += "SRC.RC_PROCES = '" + cProcess + "' AND "
	cQuery += "SRC.RC_ROTEIR = '" + cRecibo + "' AND "
	cQuery += "SRC.RC_PERIODO = '" + cPerAtu + "' AND "

	If !Empty(cNSeman)
		cQuery += "SRC.RC_SEMANA = '" + cNSeman + "' AND "
	EndIf

	cQuery += " SRC.D_E_L_E_T_ = ' ' "

	cQuery 	   := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)

	While ! (cAlias1)->(EOF())
		nHoras := 0
		nValor := 0
		nHoras := If((cAlias1)->RC_QTDSEM > 0 .And. cIRfSem == 'S', (cAlias1)->RC_QTDSEM, (cAlias1)->RC_HORAS)
		nValor := (cAlias1)->RC_VALOR
	
		If (cAlias1)->RV_TIPOCOD == "1" //Provento
	
			nPos := AScan(aProvent,{ |X| X[1] == (cAlias1)->RC_PD })
			If nPos == 0
				AAdd(aProvent,{(cAlias1)->RC_PD,(cAlias1)->RV_DESC,nHoras,nValor })
			Else
				aProvent[nPos,3] += nHoras
				aProvent[nPos,4] += nValor
			Endif

		ElseIf (cAlias1)->RV_TIPOCOD == "2" //Desconto
		
			nPos := AScan(aDescont,{ |X| X[1] == (cAlias1)->RC_PD })
			If nPos == 0
				AAdd(aDescont,{(cAlias1)->RC_PD,(cAlias1)->RV_DESC,nHoras,nValor })
			Else
				aDescont[nPos,3] += nHoras
				aDescont[nPos,4] += nValor
			EndIf
	
		ElseIf (cAlias1)->RV_TIPOCOD == "3" //Base(Provento)
	
			nPos := AScan(aBaseP,{ |X| X[1] == (cAlias1)->RC_PD })
			If nPos == 0
				AAdd(aBaseP,{(cAlias1)->RC_PD,(cAlias1)->RV_DESC,nHoras,nValor })
			Else
				aBaseP[nPos,3] += nHoras
				aBaseP[nPos,4] += nValor
			Endif
	
		EndIf

		If cRecibo = "ADI"
			If (cAlias1)->RC_PD == aCodFol[10,1]
				nBaseIr := (cAlias1)->RC_VALOR
			EndIf
		ElseIf (cAlias1)->RC_PD == aCodFol[835,1]
			nBaseIr += (cAlias1)->RC_VALOR

		ElseIf (cAlias1)->RC_PD == aCodFol[27,1]
			nBaseIr += (cAlias1)->RC_VALOR
		
		ElseIf (cAlias1)->RC_PD == aCodFol[19,1]
			nAteLim += (cAlias1)->RC_VALOR
		
		ElseIf (cAlias1)->RC_PD == aCodFol[13,1]
			nAteLim += (cAlias1)->RC_VALOR
		// BASE FGTS SAL, 13.SAL E DIF DISSIDIO E DIF DISSIDIO 13
		ElseIf (cAlias1)->RC_PD $ aCodFol[108,1] + '*' + aCodFol[17,1] + '*' + aCodFol[337,1] + '*' + aCodFol[398,1]
			nBaseFgts += (cAlias1)->RC_VALOR
		// VALOR FGTS SAL, 13.SAL E DIF DISSIDIO E DIF.DISSIDIO 13
		ElseIf (cAlias1)->RC_PD $ aCodFol[109,1] + '*' + aCodFol[18,1] + '*' + aCodFol[339,1] + '*' + aCodFol[400,1]
			nFgts += (cAlias1)->RC_VALOR
		ElseIf (cAlias1)->RC_PD == aCodFol[15,1]
			nBaseIr += (cAlias1)->RC_VALOR
		ElseIf (cAlias1)->RC_PD == aCodFol[16,1]
			nBaseIrFe += (cAlias1)->RC_VALOR
		EndIf
	
		(cAlias1)->(DbSkip())
	End
	(cAlias1)->(DbCloseArea())
	RestArea(aArea)

Return

//===============================================================================================================================

/*
{Protheus.doc} FBscMovFer()
Busca os Movimentos do Periodo
@Author     Henrique Madureira
@Since      18/05/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cFilQry, caracter, Filial do sistema
@Param		cMat, caracter, matricula do funcionário
@Param		cRecibo, caracter, Roteiro de Cálculo
@Param		cProcess, caracter, Processo do período
@Param		cPerAtu, caracter, Período Atual
@Param		cNSeman, caracter, Numero da Semana
@Param		aCodFol, array, código das verbas
@Return 	
*/
Static Function FBscMovFer(cFilQry,cMat,cRecibo,cProcess,cPerAtu,cNSeman,aCodFol)

	Local aArea   := GetArea()
	Local cQuery  := ""
	Local cFilSRV := xFilial("SRV")
	Local cIRfSem := SuperGetMv("MV_IREFSEM",,"S")
	Local cAlias1 := ''

	nAteLim	:= 0
	nBaseFgts	:= 0
	nFgts		:= 0
	nBaseIr	:= 0
	nBaseInss	:= 0
	nBaseIrFe	:= 0
	aProvent	:= {}
	aDescont	:= {}
	aBaseP		:= {}

	cAlias1 := GetNextAlias()

	cQuery := "SELECT "
	cQuery += "RR_FILIAL,RR_MAT,RR_PD,RR_VALOR,RR_SEMANA,RR_PROCES,RR_PERIODO,RR_ROTEIR,"
	cQuery += "RR_HORAS,RV_TIPOCOD,RV_DESC "
	cQuery += "FROM "
	cQuery += "	" + RetSqlName("SRR") + " SRR "
	cQuery += "LEFT JOIN "
	cQuery += " " + RetSqlName("SRV") + " SRV "
	cQuery += "ON (SRV.RV_COD = SRR.RR_PD "
	cQuery += "AND 	SRV.D_E_L_E_T_ = ' ') "
	cQuery += "WHERE "
	cQuery += "SRR.RR_FILIAL = '" + cFilQry + "' AND "
	cQuery += "SRR.RR_MAT = '" + cMat + "' AND "
	cQuery += "SRR.RR_PROCES = '" + cProcess + "' AND "
	cQuery += "SRR.RR_ROTEIR = '" + cRecibo + "' AND "
	cQuery += "SRR.RR_PERIODO = '" + cPerAtu + "' AND "

	If !Empty(cNSeman)
		cQuery += "SRR.RR_SEMANA = '" + cNSeman + "' AND "
	EndIf

	cQuery += " SRR.D_E_L_E_T_ = ' ' "

	cQuery 	   := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)

	While ! (cAlias1)->(EOF())

		nHoras := (cAlias1)->RR_HORAS
		nValor := (cAlias1)->RR_VALOR
	
		If (cAlias1)->RV_TIPOCOD == "1" //Provento
	
			nPos := AScan(aProvent,{ |X| X[1] == (cAlias1)->RR_PD })
			If nPos == 0
				AAdd(aProvent,{(cAlias1)->RR_PD,(cAlias1)->RV_DESC,nHoras,nValor })
			Else
				aProvent[nPos,3] += nHoras
				aProvent[nPos,4] += nValor
			Endif

		ElseIf (cAlias1)->RV_TIPOCOD == "2" //Desconto
		
			nPos := AScan(aDescont,{ |X| X[1] == (cAlias1)->RR_PD })
			If nPos == 0
				AAdd(aDescont,{(cAlias1)->RR_PD,(cAlias1)->RV_DESC,nHoras,nValor })
			Else
				aDescont[nPos,3] += nHoras
				aDescont[nPos,4] += nValor
			EndIf
	
		ElseIf (cAlias1)->RV_TIPOCOD == "3" //Base(Provento)
	
			nPos := AScan(aBaseP,{ |X| X[1] == (cAlias1)->RR_PD })
			If nPos == 0
				AAdd(aBaseP,{(cAlias1)->RR_PD,(cAlias1)->RV_DESC,nHoras,nValor })
			Else
				aBaseP[nPos,3] += nHoras
				aBaseP[nPos,4] += nValor
			Endif
	
		EndIf

		If (cAlias1)->RR_PD == aCodFol[13,1]
			nAteLim += (cAlias1)->RR_VALOR
		// BASE FGTS SAL, 13.SAL E DIF DISSIDIO E DIF DISSIDIO 13
		ElseIf (cAlias1)->RR_PD $ aCodFol[108,1] + '*' + aCodFol[17,1] + '*' + aCodFol[337,1] + '*' + aCodFol[398,1]
			nBaseFgts += (cAlias1)->RR_VALOR
		// VALOR FGTS SAL, 13.SAL E DIF DISSIDIO E DIF.DISSIDIO 13
		ElseIf (cAlias1)->RR_PD $ aCodFol[109,1] + '*' + aCodFol[18,1] + '*' + aCodFol[339,1] + '*' + aCodFol[400,1]
			nFgts += (cAlias1)->RR_VALOR
		ElseIf (cAlias1)->RR_PD == aCodFol[16,1]
			nBaseIr += (cAlias1)->RR_VALOR
		EndIf
	
		(cAlias1)->(DbSkip())
	End
	(cAlias1)->(dbCloseArea())
	RestArea(aArea)

Return

/*
{Protheus.doc} FRegDetPrv()
Registro Detalhe lançamento de Provento
@Author     Bruno de Oliveira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cMatric, caracter, Matricula do Funcionário
@Return 	nVlProv, Valor total dos Proventos
*/
Static Function FRegDetPrv(cMatric)

	Local aArea	:= GetArea()
	Local cVlProv	:= ""
	Local nVlProv	:= 0
	Local nX		:= 0

	For nX := 1 To Len(aProvent)

		If Str(aProvent[nX,4]) $ ","
			cVlProv := StrZero(StrTran(aProvent[nX,4],",",,1,),9)
		Else
			cVlProv := StrZero(aProvent[nX,4]*100,9)
		EndIf

		nSeqLan++
	
		cLinP12 += "2"												// 0001-0001 Tipo de registro = 2
		cLinP12 += Padr("00000000000000" + SubStr(cMatric,1,6),20)	// 0002-0021 Matricula do funcionario
		cLinP12 += StrZero(nSeqLan,3)								// 0022-0024 NUmero sequencial do lançamento
		cLinP12 += PadL(AllTrim(aProvent[nX,1]),7,"0")				// 0025-0031 Codigo de lancamento definido pela empresa ? Completado com Zeros à Esquerda.
		cLinP12 += PadR(aProvent[nX,2],23)							// 0032-0054 Descricao do lancamento
		cLinP12 += Space(3)											// 0055-0057 Livre para futuras utilizações
		cLinP12 += PadL(cVlProv,9)									// 0058-0066 Valor do lançamento, valor em reais no formato 9(07)V99. Se inexistente, preencher com zeros.
		cLinP12 += PadR(aProvent[nX,2],23) + Space(57)				// 0067-0146 Repetir descrição do lançamento + 57 espacos direita
		cLinP12 += "C"												// 0147-0147 D = DEBITO , C = CREDITO
		cLinP12 += Space(9)											// 0148-0156 Unidade de trabalho ,Se inexistente, preencher com brancos
		cLinP12 += "00000"											// 0157-0161 Qtde trabalhadas
		cLinP12 += Space(1)											// 0162-0162 Livre para futuras utilizações
		cLinP12 += "00010101"										// 0163-0170 Campo de uso privativo do banco
		cLinP12 += "00010101"										// 0171-0178 Campo de uso privativo do banco
		cLinP12 += Space(222)										// 0179-0400 Livre para futuras utilizações
	
		cLinP12 += Chr(13) + Chr(10)
		FWrite(nArq, cLinP12, Len(cLinP12))
		nTotRegt++
		cLinP12 	:= ""

		nVlProv := nVlProv + aProvent[nX,4]
		
	Next nX

	RestArea(aArea)

Return nVlProv

/*
{Protheus.doc} FRegDetDsc()
Registro Detalhe lançamento de Desconto
@Author     Bruno de Oliveira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cMatric, caracter, matricula do funcionário
@Return 	nVlDesc, Valor total dos Descontos
*/
Static Function FRegDetDsc(cMatric)

	Local aArea	:= GetArea()
	Local cVlDesc	:= ""
	Local nVlDesc	:= 0
	Local nX		:= 0

	For nX := 1 to Len(aDescont)

		If Str(aDescont[nX,4]) $ ","
			cVlDesc := StrZero(StrTran(aDescont[nX,4],",",,1,),9)
		Else
			cVlDesc := StrZero(aDescont[nX,4]*100,9)
		EndIf
	
		nSeqLan++
	
		cLinP12 += PadR("2",1)										// 0001-0001 Tipo de registro = 2
		cLinP12 += Padr("00000000000000" + SubStr(cMatric,1,6),20)	// 0002-0021 Matricula do funcionario
		cLinP12 += StrZero(nSeqLan,3)								// 0022-0024 Numero sequencial do lançamento
		cLinP12 += PadL(AllTrim(aDescont[nX,1]),7,"0")				// 0025-0031 Codigo de lancamento definido pela empresa
		cLinP12 += PadR(aDescont[nX,2],23)							// 0032-0054 Descricao do lancamento
		cLinP12 += Space(3)											// 0055-0057 Livre para futuras utilizações
		cLinP12 += PadL(cVlDesc,9)									// 0058-0066 Valor do lancamento, valor em reais no formato 9(07)V99. Se inexistente, preencher com zeros.
		cLinP12 += PadR(aDescont[nX,2],23) + Space(57)				// 0067-0146 Repetir Descrição de Lançamento + 57 espacos direita
		cLinP12 += "D"												// 0147-0147 D = DEBITO , C = CREDITO
		cLinP12 += Space(9)											// 0148-0156 Unidade de trabalho ,Se inexistente, preencher com brancos
		cLinP12 += "00000"											// 0157-0161 Qtde trabalhadas
		cLinP12 += Space(1)											// 0162-0162 Livre para futuras utilizações
		cLinP12 += "00010101"										// 0163-0170 Campo de uso privativo do Banco
		cLinP12 += "00010101"										// 0171-0178 Campo de uso privatico do Banco
		cLinP12 += Space(222)										// 0179-0400 reservado
	
		cLinP12 += Chr(13) + Chr(10)
		FWrite(nArq, cLinP12, Len(cLinP12))
		nTotRegt++
		cLinP12 	:= ""

		nVlDesc := nVlDesc + aDescont[nX,4]

	Next nX

	RestArea(aArea)

Return nVlDesc

/*
{Protheus.doc} FsTrailFun()
Trailler Funcionário
@Author     Bruno de Oliveira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		nVlProv, numerico, valor do Provento
@Param		nVlDesc, numerico, valor do Desconto
@Param		cMatric, caracter, matricula do funcionário
@Return 	
*/
Static Function FsTrailFun(nVlProv,nVlDesc,cMatric)

	Local aArea	:= GetArea()
	Local nLiquid	:= 0

	cLinP12 += PadR("3",1)										// 0001-0001 Tipo de registro = 3
	cLinP12 += Padr("00000000000000" + SubStr(cMatric,1,6),20)// 0002-0021 Matricula do funcionario
	cLinP12 += StrZero(nVlDesc*100,15)							// 0022-0036 Total valor a Débito
	cLinP12 += StrZero(nVlProv*100,15)							// 0037-0051 Total valor a Crédito
	cLinP12 += StrZero((nVlProv-nVlDesc)*100,15)				// 0052-0066 Total valor Líquido
	cLinP12 += StrZero(nSeqLan,10)								// 0067-0076 Total de registros lançados para o funcionário
	cLinP12 += PadR("BASE IRRF",9)								// 0077-0085 Mensagem do Comprovante
	cLinP12 += PadR(TRANSFORM(nBaseIr,"@E 999,999.99"),10)	// 0086-0095 Base IRRF Deverá conter (exemplo ‘999.999,99’) Alinhar à direita COM ESPAÇOS A ESQ ,Verificar a picture
	cLinP12 += Space(9)											// 0096-0104 reservado
	cLinP12 += PadR("BASE INSS",9)								// 0105-0113 mensagem
	cLinP12 += PadR(TRANSFORM(nAteLim,"@E 999,999.99"),10)	// 0114-0123 valor base INSS
	cLinP12 += PadR("BASE FGTS",9)								// 0124-0132 mensagem
	cLinP12 += PadR(TRANSFORM(nBaseFgts,"@E 999,999.99"),10)// 0133-0142 Valor base FGTS verificar picture
	cLinP12 += Space(9)											// 0143-0151 RESERVADO
	cLinP12 += PadR("FGTS MES ",9)								// 0152-0160 FGTS do mês
	cLinP12 += PadR(TRANSFORM((nFgts),"@E 999,999.99"),10)	// 0161-0170 Valor FGTS do mês
	cLinP12 += Space(230)										// 0171-0400 reservado

	cLinP12 += Chr(13) + Chr(10)
	FWrite(nArq, cLinP12, Len(cLinP12))
	nTotRegt++
	cLinP12 := ""
    
	nTotProv := nTotProv + nVlProv
	nTotDesc := nTotDesc + nVlDesc
	//nTotRegt += nSeqLan
	

	RestArea(aArea)

Return

/*
{Protheus.doc} FsTrailEmp()
Trailler Empresa
@Author     Bruno de Oliveira
@Since      25/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cBncAgConv, caracter, Banco + Agencia + Convenio
@Param		cFIL, caracter, filial do pergunte
@Return 	
*/
Static Function FsTrailEmp(cBncAgConv,cFil)

	Local aArea 	:= GetArea()
	Local nLotP12 := SuperGetMv("MQ_CONTGP2",.F.,1,cFil)

	nTotRegt++
	cLinP12 += PadR("9",1)									// 0001-0001 Tipo de registro = 9
	cLinP12 += PADR(cBncAgConv,20)							// 0002-0021 Número do Convênio da Empresa ,Composto por: Banco + Agência + convênio
	cLinP12 += StrZero(Val(SM0->M0_CGC),14)				// 0022-0035 CNPJ empresa=03311116000130
	cLinP12 += StrZero(nTotDesc*100,15)					// 0036-0050 Total dos débitos
	cLinP12 += StrZero(nTotProv*100,15)					// 0051-0065 Total dos créditos
	cLinP12 += StrZero((nTotProv-nTotDesc)*100,15)		// 0066-0080 Total valor Líquido
	cLinP12 += StrZero(nTotRegt,10)							// 0081-0090 Total de Registros do Arquivo
	cLinP12 += Space(310)									// 0091-0400 Reservado

	cLinP12 += Chr(13) + Chr(10)
	If lCrdArq
		FWrite(nArq, cLinP12, Len(cLinP12))
		cLinP12 	:= ""
		FClose(nArq)
		nLotP12 := nLotP12 + 1
		/* Início - Thais Paiva - Compatibilização P27
		DbSelectArea("SX6")
		SX6->(DbSetOrder(1))
		If SX6->(DbSeek(cFil + "MQ_CONTGP2"))
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD := AllTrim(STR(nLotP12))
			SX6->(MsUnLock())
		EndIf*/
		If FWSX6Util():ExistsParam( "MQ_CONTGP2" )
			PutMV("MQ_CONTGP2",nLotP12)
		EndIf
		//Fim - Thais Paiva - Compatibilização P27
		MsgInfo("Arquivo gerado")
	Else
		MsgInfo("Arquivo não foi gerado, verificar parâmetros")
	EndIf

	RestArea(aArea)

Return

/*
{Protheus.doc} VldPergnt()
Validação dos perguntes
@Author     Bruno de Oliveira
@Since      27/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cPerg, caracter, Pergunta a ser criada
@Param		cFIL, caracter, filial do pergunte
@Return 	
*/
Static Function VldPergnt(cArq,dDtLbPgto,cFil,nTipo,cLote)

	Local aArea 		:= GetArea()
	Local lRet 		:= .T.
	Local cCaminho	:= SuperGetMv("FS_ROTARQ",.F.,,cFil)
	Local cParaCon	:= SuperGetMv("FS_CONVEN",.F.,,cFil)
	Local cConCorr	:= SuperGetMv("FS_CONTCC",.F.,,cFil)

	If Empty(cCaminho)
		Help(" ",1,"VldPergnt",,"Não foi informado o Caminho do arquivo, verificar parâmetro FS_ROTARQ",1,0)
		lRet := .F.
	ElseIf Empty(dDtLbPgto)
		Help(" ",1,"VldPergnt",,"Data de liberação do pagamento não foi informada",1,0)
		lRet := .F.
	ElseIf nTipo == 2 .AND. EMPTY(cLote)
		Help(" ",1,"VldPergnt",,"Data de liberação do pagamento não foi informada",1,0)
		lRet := .F.
	ElseIf Empty(cArq)
		Help(" ",1,"VldPergnt",,"Não foi informado nome do arquivo",1,0)
		lRet := .F.
	ElseIf Empty(cParaCon)
		Help(" ",1,"VldPergnt",,"Informe o numero do convênio, verificar parâmetro FS_CONVEN",1,0)
		lRet := .F.
	ElseIf Empty(cConCorr)
		Help(" ",1,"VldPergnt",,"Informe o número do banco, agência e conta, verificar parâmetro FS_CONTCC",1,0)
		lRet := .F.
	EndIf

	If lRet
		If !Empty(cCaminho)
			If File(cCaminho + cArq)
				If MsgNoYes("Já existe um arquivo com esse nome, deseja substituir?")
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*
{Protheus.doc} AjustPerg()
Criação do Pergunte 
@Author     Bruno de Oliveira
@Since      19/04/2016
@Version    P12.1.07
@Project    MAN00000463301_EF_013
@Param		cPerg, caracter, Pergunta a ser criada
@Return 	
*/
Static Function AjustPerg(cPerg)

	Local aArea := GetArea()

	RestArea(aArea)

Return
