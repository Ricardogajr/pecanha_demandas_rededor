#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#define F24CONSUMO    1
#define F24COMPRA     2
#define F24P12TOFRONT 1
#define F24FRONTTOP12 2

Static cMsgETL    := ""
Static oDbApData  := NIL

/*{Protheus.doc} F0703001
JOB de Integração Fechamento de Estoque

@author Alex Sandro Valario
@since  30/15/2016
@param aParm
@project MAN0000007423041_EF_030
@version P12.1.7
@return Nil  
*/
User Function F0703001(aParam)

	// 	Local cEmpIni := If(ValType(aParam) == "A", aParam[1, 1], cEmpAnt)
	//	Local cFilIni := IF(ValType(aParam) == "A", aParam[1, 2], cFilAnt)
	Local aP26    := {}
	Local lProcT  := .F.
	Local lThreads:= .F.

	Local cCritica  := ""
	Local cPilhaCha := ""
	Local bBlock    := ErrorBlock( { |e| ChecErro(e,@cCritica,@cPilhaCha) } )

	Private cEmpIni := If(ValType(aParam) == "A", aParam[1, 1], cEmpAnt)
	Private cFilIni := IF(ValType(aParam) == "A", aParam[1, 2], cFilAnt)
	Private cArq 	:= "Fechamento_Estoque_"+Dtos(dDatabase)+".log"
	//Private aB9 := {}

	If IsBlind()
		RPCSetType(3)
		RpcSetEnv(aParam[1,1],aParam[1,2])
	Else
		If !MsgYesNo("Favor verificar os parâmetros MV_ULMES E FS_ULMES antes de realizar o fechamento da unidade." + Chr(13) + Chr(10) + "MV_ULMES:  " + DtoC(GetMV("MV_ULMES")) + Chr(13) + Chr(10) + "FS_ULMES: " + DtoC(GetMV("FS_ULMES")) +  Chr(13) + Chr(10) + "Deseja realizar o fechemanto de estoque da unidade " + cFilAnt + " - " + AllTrim(FWFilialName()) + "?")
			Return
		EndIf
	Endif


	If !LockByName("F0703001" + cEmpIni + cFilIni, .F., .F.)
		Return
	EndIf

	//SUPERGETMV(“MV_DIAS”, .T., “15”)

	lProcT  := GetMV('FS_030PTF',,.F.)  // Processa todas filiais
	If lProcT
		lThreads:= GetMV('FS_030DPT',,.F.)  // Distribui o processamento em Treads para cada Filial
	EndIf

	Begin Sequence

		CriaArq() // cria a tabela no banco caso não exista

		If ! BuscaMov(aP26, lProcT)  // Caso não tenha
			cMsgETL := "Não achou P26 - Filial: " + cFilAnt
			U_FCRTLOG(cArq,cMsgETL)
			AutoGrLog(cMsgETL)
			Break
		EndIf


		MsgRun("Processando fechamento de estoque da filial " + cFilAnt + "...","Processando...",{|| ProcFecha( aP26, lThreads)})

		Recover

		If ! Empty(cMsgETL)
			AutoGrLog('')
			FErase(NomeAutoLog())
			AutoGrLog(cMsgETL) 
			FRename(NomeAutoLog(),"ETL030_"+NomeAutoLog())
			If oDbApData:HasConnection()
				TerminoETL()
			EndIf
		EndIf
	End Sequence
	UnLockByName("F0703001" + cEmpIni+ cFilIni , .F., .F.)

Return

Static Function CriaArq()
	Local cTbl     := "F0703001"
	Local aTblStru := {}
	Local aTblIndex:= {}
	Local cMsg     := ""

	AAdd(aTblStru, {"P26_FILIAL", "VARCHAR", 008})
	AAdd(aTblStru, {"P26_CODFEC", "VARCHAR", 019})   // AAAA-MM-DD HH:MM:SS
	AAdd(aTblStru, {"P26_DTFECH", "VARCHAR", 010})   //DD/MM/AAAA
	AAdd(aTblStru, {"P26_OPER"  , "VARCHAR", 001})   // F=Fechamento; E=Estorno
	AAdd(aTblStru, {"P26_QTDTOT", "VARCHAR", 007})
	AAdd(aTblStru, {"P26_STATUS", "VARCHAR", 001})   // 1= Disponivel para processamento; 2=Processando; 3=Processado OK; 4=Processado Erro
	AAdd(aTblStru, {"P26_PROCTB", "VARCHAR", 019})   // AAAA-MM-DD HH:MM:SS
	AAdd(aTblStru, {"P26_DTEXFE", "VARCHAR", 010})   //DD/MM/AAAA
	AAdd(aTblStru, {"P26_HREXFE", "VARCHAR", 008})   //HH:MM:SS
	AAdd(aTblStru, {"P26_USER"  , "VARCHAR", 030})
	AAdd(aTblStru, {"P27_IDORIG", "VARCHAR", 019})   // Id do Front
	AAdd(aTblStru, {"P27_PRODUT", "VARCHAR", 015})
	AAdd(aTblStru, {"P27_QTDPRO", "VARCHAR", 014})
	AAdd(aTblStru, {"P27_LOCAL" , "VARCHAR", 006})
	AAdd(aTblStru, {"P27_VLTOTP", "VARCHAR", 015})
	AAdd(aTblStru, {"P27_OBSERV", "VARCHAR", 200})
	AAdd(aTblStru, {"P27_DTPROC", "VARCHAR", 010})   //DD/MM/AAAA
	AAdd(aTblStru, {"P27_HRPROC", "VARCHAR", 008})   //HH:MM:SS
	AAdd(aTblStru, {"P27_IDFRON", "VARCHAR", 001})

	aTblIndex := {"P26_FILIAL", "P26_CODFEC", "P26_STATUS"}

	InicioETL()
	CriaETL(cTbl, aTblStru, aTblIndex)
	TerminoETL()

	If ! Empty(cMsg)
		cMsgETL := cMsg
		Break
	EndIf

Return

Static Function BuscaMov(aP26, lProcT)
	Local cQuery    := ""
	Local cNewAlias := GetNextAlias()
	Local cFilAux   := ""
	Local aP26Aux   := {}
	Local dData     := GetNewPar("MV_ULMES","")
	Local cData 	:= ""

	If !Empty(dData)
		dData := LastDate(MonthSum(dData,1))
		cData := DtoC(dData)
	EndIf

	cQuery := " SELECT DISTINCT P26_FILIAL,P26_CODFEC, P26_DTFECH, P26_QTDTOT, P26_STATUS, P26_OPER "  // fazer versão para oracle
	cQuery += "  FROM F0703001 "
	cQuery += "  WHERE P26_STATUS = '1' "
	If ! lProcT
		cQuery += "    AND P26_FILIAL = '" + cFilIni + "' "
	EndIf
	cQuery += " AND P26_DTFECH = '"+cData+"' "
	cQuery += "  ORDER BY 1, 2, 5 "
	cQuery := ChangeQuery( cQuery )

	InicioETL() // Inicializa conexão
	SelecionaETL(cQuery, cNewAlias) // Executa a Query

	(cNewAlias)->(DbGotop())
	If (cNewAlias)->(Eof())

		(cNewAlias)->(DbCloseArea())
		TerminoETL() // Finaliza conexão

		cNewAlias := GetNextAlias()
		cQuery := " SELECT DISTINCT P26_FILIAL,P26_CODFEC, P26_DTFECH, P26_QTDTOT, P26_STATUS, P26_OPER "  // fazer versão para oracle
		cQuery += "  FROM F0703001 "
		cQuery += "  WHERE P26_STATUS = '1' "
		If ! lProcT
			cQuery += "    AND P26_FILIAL = '" + cFilIni + "' "
		EndIf
		cQuery += "  ORDER BY 1, 2, 5 "
		cQuery := ChangeQuery( cQuery )

		InicioETL() // Inicializa conexão
		SelecionaETL(cQuery, cNewAlias) // Executa a Query

	EndIf

	(cNewAlias)->(DbGotop())
	If (cNewAlias)->(! Eof())
		If ! (cNewAlias)->P26_FILIAL == cFilAux
			AAdd(aP26,{(cNewAlias)->P26_FILIAL, {}})
			cFilAux   := (cNewAlias)->P26_FILIAL
		EndIf
		(cNewAlias)->(AAdd(aP26Aux,{P26_CODFEC, P26_DTFECH, P26_QTDTOT, P26_OPER }))

		aP26[len(aP26),2] := aClone(aP26Aux)
	EndIf
	(cNewAlias)->(dbCloseArea())

	TerminoETL() // Finaliza conexão
Return .T.

Static Function ProcFecha(aP26, lThreads)
	Local nFil     := 0
	Local cFilProc := ""
	Local aCodFec  := {}
	Local lIsRun   := .F.

	For nFil := 1 to len(aP26)
		cFilProc := aP26[nFil, 1]
		aCodFec  := AClone(aP26[nFil, 2])
		If lThreads .and. len(aP26) > 1
			StartJob("U_F07030Executa", GetEnvServer(), .F., cEmpAnt, cFilProc , aCodFec, .T. )
		Else
			U_F07030Ex(cEmpAnt, cFilProc , aCodFec, .T.)
		EndIf
		Sleep(2000)
	Next
	While .t.
		lIsRun   := .F.
		For nFil := 1 to len(aP26)
			cFilProc := aP26[nFil, 1]
			If LockByName("F0703001" + cEmpAnt + cFilProc, .F., .F.)
				UnLockByName("F0703001" + cEmpAnt + cFilProc, .F., .F.)
			Else
				lIsRun := .T.
			EndIf
		Next
		If ! lIsRun
			Exit
		EndIf
		Sleep(1000)
	EndDo
Return

User Function F07030Executa(cEmp, cFil, aCodFec, lJob)
	Local cEmpBkp := ""
	Local cFilBkp := ""
	Local nCodFec := 0
	Local cCodFec := ""
	Local dDtFec  := ctod("")
	Local nQtdP26 := 0
	Local cOper   := ""
	Local aPergs  := {}

	Default cEmp     := cEmpAnt
	Default cFil     := cFilAnt
	Default aCodFec  := {}
	Default lJob     := .F. // Verificar

	If LockByName("F0703001" + cEmp + cFil, .F., .F.)
		If lJob .And. IsBlind()
			RpcSetEnv(cEmp, cFil, , ,"'EST", ,)
			FWMonitorMsg("Job F07030EX  "+ cEmp+ " " + cFil)
		Else
			If Empty(aCodFec)
				aCodFec := BuscaP26Prt()
			EndIf
			cEmpBkp := cEmpAnt
			cFilBkp := cFilAnt
		EndIf

		For nCodFec := 1 to len(aCodFec)
			cCodFec := aCodFec[nCodFec, 1]
			dDtFec  := CToD(aCodFec[nCodFec, 2])
			nQtdP26 := Val(aCodFec[nCodFec, 3])
			cOper   := Alltrim(aCodFec[nCodFec, 4])

			If cOper == "F"
				ProcFechamento(cCodFec, dDtFec, nQtdP26)
			Else
				ProcEstorno(cCodFec, dDtFec, nQtdP26)
			EndIf
		Next

		If lJob .And. IsBlind()
			RpcClearEnv()
		Else
			Aviso("Processo Finalizado","Processo finalizado.",{"Ok"})
			cEmpAnt := cEmpBkp
			cFilAnt := cFilBkp
		EndIf
		UnLockByName("F0703001" + cEmp + cFil, .F., .F.)
	Else
		If !Job
			Aviso("Atenção","A rotina já está em execução.",{"Ok"})
		EndIf
	EndIf
Return

Static Function BuscaP26Prt()
	Local cNewAlias := GetNextAlias()
	Local cQuery    := ""
	Local aP26Aux	:= {}

	cQuery := " SELECT DISTINCT P26_FILIAL,P26_CODFEC, P26_DTFECH, P26_QTDTOT, P26_STATUS, P26_OPER "
	cQuery += "  FROM " + RetSqlName("P26") + " P26"
	cQuery += "  WHERE P26_FILIAL = '" + xFilial("P26") + "' AND P26_STATUS = '1' AND P26.D_E_L_E_T_ = ' '"
	cQuery += "  ORDER BY 1, 2, 5 "
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cNewAlias)

	If (cNewAlias)->(! Eof())
		AAdd(aP26Aux,{(cNewAlias)->P26_CODFEC, (cNewAlias)->P26_DTFECH, (cNewAlias)->P26_QTDTOT, (cNewAlias)->P26_OPER })
	EndIf
	(cNewAlias)->(dbCloseArea())
Return

Static Function ProcFechamento(cCodFec, dDtFec, nQtdP26)
	Local lProcessa := .F.
	Local cMsg      := ""
	Local cLog      := ""
	Local lProcCont	:= GetMV('FS_030CTB',,.T.)  // Processa Contábil // Está como falso verificar com Ronaldo Ricardo
	Local cCritica  := ""
	Local cPilhaCha := ""
	Local bBlock    := ErrorBlock( { |e| ChecErro(e,@cCritica,@cPilhaCha) } )
	Local nX := 1
	Local cQuery := ""
	Local cAliasB2 := GetNextAlias()


	U_FCRTLOG(cArq,"Início - Filial: "+cFilAnt+" ProcFechamento")
	AutoGrLog("")
	FErase(NomeAutoLog())

	If lProcCont
		U_FCRTLOG(cArq,"Início - Realizando Contabilização - MATA331")
		AutoGrLog("Realizando Contabilização  - MATA331")
		ExecMata331( dDtFec )
		U_FCRTLOG(cArq,"Fim    - Realizando Contabilização - MATA331")
	EndIf

	Begin Transaction
		Begin Sequence

			U_FCRTLOG(cArq,"Início - Alteração de Status para 2")
			AutoGrLog("Processando Fechamento " + cCodFec + " em " + DToC(date()) )
			AtuStatus("2", cCodFec, "")
			U_FCRTLOG(cArq,"Fim    - Alteração de Status para 2")

			U_FCRTLOG(cArq,"Início - Verifica quantidade P26")
			AutoGrLog("Verificando quantidade para "+ Alltrim(Str(nQtdP26)) + " Itens")
			VerQtdP26(cCodFec, nQtdP26, @cMsg)
			U_FCRTLOG(cArq,"Fim    - Verifica quantidade P26")

			U_FCRTLOG(cArq,"Início - Atualiza P26 e 27")
			AutoGrLog("Atualizando tabelas de monitoramento Protheus (P26 e P27)")
			AtuP26(cCodFec)
			U_FCRTLOG(cArq,"Fim    - Atualiza P26 e 27")

			U_FCRTLOG(cArq,"Início - Atualizando tabelas de Saldo Protheus (SB2)")
			AutoGrLog("Atualizando tabelas de Saldo Protheus (SB2)")
			AtuSB2(cCodFec, dDtFec, @cMsg)
			U_FCRTLOG(cArq,"Fim    - Atualizando tabelas de Saldo Protheus (SB2)")

			U_FCRTLOG(cArq,"Inicio - Atualizando a tabela de saldos iniciais do Protheus (SB9)")
			AutoGrLog("Atualizando tabelas de Saldos Iniciais do Protheus (SB9)")
			AtuSB9(cCodFec, dDtFec, @cMsg)
			U_FCRTLOG(cArq,"Fim - Atualizando a tabela de saldos iniciais do Protheus (SB9)")

			lProcessa := .T.
			U_FCRTLOG(cArq,"lProcessa - .T.")

			Recover
			lProcessa:= .F.
			U_FCRTLOG(cArq,"lProcessa - .F.")
		End Sequence

		ErrorBlock(bBlock)

		IF !Empty(cCritica)
			U_FCRTLOG(cArq,"Ocorreu o erro: "+cCritica)
			U_FCRTLOG(cArq,"Pilha de Chamada:"+cPilhaCha)
			AutoGrLog("Ocorreu o erro: "+cCritica)
			AutoGrLog("Pilha de Chamada:"+cPilhaCha)
			cMsg := "Ocorreu o erro: "+cCritica
		Endif

		If lProcessa

			//U_FCRTLOG(cArq,"Início - Virada de saldo MATA280")
			//AutoGrLog("Executando Virada de Saldo MATA280 (SB9)")
			//ExecMata280(dDtFec, @cMsg)
			//U_FCRTLOG(cArq,"Fim    - Virada de saldo MATA280")

			AutoGrLog("Processamento finalizando com sucesso.")

			AtuStatus("3", cCodFec, "Processado OK")
			lProcessa:= .T.
			U_FCRTLOG(cArq,"Fim do Processamento OK")
		Endif

		If !lProcessa
			DisarmTransaction()

			AutoGrLog("Processamento finalizado com DIVERGENCIAS:")
			AutoGrLog(cMsg)
			U_FCRTLOG(cArq,"Fim do Processamento com DIVERGENCIAS")

			AtuStatus("4", cCodFec , cMsg )

			If ! Empty(cMsgETL)
				AutoGrLog("Processamento finalizado com ERRO:")
				AutoGrLog(cMsgETL)
				U_FCRTLOG(cArq,"Fim do Processamento com ERRO")
				If oDbApData:HasConnection()
					TerminoETL()
				EndIf
			EndIf

			cLog := MemoRead(NomeAutoLog())

			FRename(NomeAutoLog(),"ETL030_"+NomeAutoLog())
		Else
			cLog := MemoRead(NomeAutoLog())

			FErase(NomeAutoLog())
		EndIf

	End Transaction

	If lProcessa
		PutMV("FS_ULMES",dDtFec) //Chamado DOR07646016 - Lucas Miranda de Aguiar 06/01/2022
		PutMV("MV_ULMES",dDtFec)
	EndIf

	PreparaEmail(cLog)

	U_FCRTLOG(cArq,"Fim - Filial: "+cFilAnt+" ProcFechamento")

Return lProcessa


Static Function ProcEstorno(cCodFec, dDtFec, nQtdP26)
	Local lProcessa := .F.
	Local cLog      := ""
	Local dDtUlMes  := GetMv("MV_ULMES")
	Local cCritica  := ""
	Local cPilhaCha := ""
	Local bBlock    := ErrorBlock( { |e| ChecErro(e,@cCritica,@cPilhaCha) } )

	Private  cMsg  := ""

	AutoGrLog('')
	FErase(NomeAutoLog())

	Begin Transaction
		Begin Sequence

			AutoGrLog("Processando ESTORNO " + cCodFec + " em " + DToC(date()) )
			AtuStatus("2", cCodFec, "")

			AutoGrLog("Verificando se a data fechamento é a ultima.")
			If dDtUlMes <> dDtFec
				cMsg := "Data de integração [" + DToC(dDtFec) + "] não corresponde ao ultimo fechamento [" + DToC(dDtUlMes) + "]."
				Break
			EndIf

			AutoGrLog("Verificando quantidade para "+ Alltrim(Str(nQtdP26)) + " Itens")
			VerQtdP26(cCodFec, nQtdP26, @cMsg)

			AutoGrLog("Atualizando tabelas de monitoramento Protheus (P26 e P27)")
			lProcessa := AtuP26(cCodFec)
			IF !lProcessa
				AutoGrLog("Erro na conversa de unidade")
				Break
			Endif

			AutoGrLog("Estorno do ultimo fechamento")
			U_F0703002(.T.)

			AutoGrLog("Processamento finalizando com sucesso.")
			AtuStatus("3", cCodFec, "Processado OK")
			lProcessa:= .T.
			Recover
			lProcessa:= .F.

		End Sequence

		ErrorBlock(bBlock)

		IF !Empty(cCritica)
			AutoGrLog("Ocorreu o erro: "+cCritica)
			AutoGrLog("Pilha de Chamada:"+cPilhaCha)
			cMsg := "Ocorreu o erro: "+cCritica
		Endif

		If !lProcessa
			DisarmTransaction()

			AutoGrLog("Processamento finalizado com DIVERGENCIAS:")
			AutoGrLog(cMsg)

			AtuStatus("4", cCodFec , cMsg )
			If ! Empty(cMsgETL)
				AutoGrLog("Processamento finalizado com ERRO:")
				AutoGrLog(cMsgETL)
				U_FCRTLOG(cArq,cMsgETL)
				If oDbApData:HasConnection()
					TerminoETL()
				EndIf
			EndIf
			cLog := MemoRead(NomeAutoLog())
			FRename(NomeAutoLog(),"ETL030_"+NomeAutoLog())
		Else
			cLog := MemoRead(NomeAutoLog())
			FErase(NomeAutoLog())
		EndIf
	End Transaction

	PreparaEmail(cLog, .T.)

Return lProcessa

Static Function AtuStatus(cStatus, cCodFec, cMsg)  // 1= Disponivel para processamento; 2=Processando; 3=Processado OK; 4=Processado Erro
	Local cCommand := ""
	Local cOwner   := ""
	Default cMsg   := ""

	cOwner   := GetMV('FS_OWNER', , '')
	cCommand := " UPDATE "+cOwner+"F0703001 "
	cCommand += "    SET P26_STATUS = '" + cStatus + "' "

	If cStatus == "2"
		cCommand += "       , P26_PROCTB = '"+ FwTimeStamp() + "' "
	EndIf
	If cStatus == "3"
		cCommand += "      , P26_DTEXFE = '"+ Dtoc(Date()) + "' "
		cCommand += "      , P26_HREXFE = '"+ Time() + "' "
	Endif
	If cStatus $ "34"
		cCommand += "      , P27_DTPROC = '"+ Dtoc(Date()) + "' "
		cCommand += "      , P27_HRPROC = '"+ Time() + "' "
	EndIf
	If ! Empty(cMsg)
		cCommand += "      , P27_OBSERV = '"+ cMsg + "' "
	EndIf
	cCommand +=  " WHERE P26_CODFEC = '"+ cCodFec + "' "
	cCommand += "    AND P26_FILIAL = '"+ cFilAnt + "' "

	InicioETL()
	AlteraETL(cCommand)
	TerminoETL()

Return

Static Function VerQtdP26(cCodFec, nQtdP26, cMsg)
	Local cQuery    := ""
	Local cNewAlias := GetNextAlias()
	Local nQtdTmp   := 0

	cQuery := " SELECT COUNT(*) AS QTDP26"  // fazer versão para oracle
	cQuery += " FROM F0703001"
	cQuery += " WHERE P26_FILIAL = '" + cFilAnt + "' AND P26_CODFEC = '" + cCodFec + "'"

	InicioETL() // Inicializa conexão
	SelecionaETL(cQuery, cNewAlias) // Executa a Query

	(cNewAlias)->(DbGotop())
	nQtdTmp := (cNewAlias)->QTDP26
	(cNewAlias)->(dbCloseArea())
	TerminoETL() // Finaliza conexão

	If nQtdTmp <> nQtdP26
		cMsg := "Quantidade de registros não conferem."
		Break
	EndIf

Return

Static Function AtuP26(cCodFec)
	Local cQuery    := ""
	Local cNewAlias := GetNextAlias()
	Local cNewCod   := ""

	Local P17_UM1   := ""
	Local nQUANT 	:= 0
	Local cUM    	:= ""
	Local aConv 	:= {}

	cQuery := " SELECT P26_FILIAL, P26_CODFEC, P26_DTFECH, P26_OPER,  P26_QTDTOT, P26_STATUS, P26_PROCTB, P26_DTEXFE, P26_HREXFE, P26_USER,"
	cQuery += "        P27_IDORIG, P27_PRODUT, P27_QTDPRO, P27_LOCAL, P27_VLTOTP, P27_OBSERV, P27_DTPROC, P27_HRPROC "
	cQuery += " FROM F0703001"
	cQuery += " WHERE P26_FILIAL = '" + cFilAnt +  "' AND P26_CODFEC = '" + cCodFec + "'"
	cQuery += " ORDER By 1, 2, 5"
	cQuery := ChangeQuery( cQuery )

	ChkFile("P26")
	ChkFile("P27")

	InicioETL() // Inicializa conexão
	SelecionaETL(cQuery, cNewAlias) // Executa a Query

	(cNewAlias)->(DbGotop())
	While (cNewAlias)->(! Eof())

		//Aadd(aB9,{(cNewAlias)->P26_FILIAL,(cNewAlias)->P27_PRODUT,(cNewAlias)->P27_LOCAL,CTOD((cNewAlias)->P26_DTFECH),(cNewAlias)->P27_QTDPRO,(cNewAlias)->P27_VLTOTP,Val((cNewAlias)->P27_VLTOTP)/Val((cNewAlias)->P27_QTDPRO)})

		If ! (cNewAlias)->P26_CODFEC == cNewCod
			P26->(RecLock("P26", .T.))
			P26->P26_FILIAL := xFilial("P26")
			P26->P26_CODFEC := (cNewAlias)->P26_CODFEC
			P26->P26_DTFECH := CToD((cNewAlias)->P26_DTFECH)
			P26->P26_OPER   := (cNewAlias)->P26_OPER
			P26->P26_QTDTOT := Val((cNewAlias)->P26_QTDTOT)
			P26->P26_STATUS := (cNewAlias)->P26_STATUS
			P26->P26_PROCTB := (cNewAlias)->P26_PROCTB
			P26->P26_DTEXFE := CToD((cNewAlias)->P26_DTEXFE)
			P26->P26_HREXFE := (cNewAlias)->P26_HREXFE
			P26->P26_USER   := (cNewAlias)->P26_USER
			P26->(MsUnLock())
			P26->(DbCommit())
			cNewCod := (cNewAlias)->P26_CODFEC
		EndIf

		_aArea := FWGetArea()

		P17->(DbSetOrder(1))
		IF ! P17->(DbSeek ( xFilial("P17") + P27->P27_PRODUT + P27->P27_FILIAL ))
			cMsgETL := "F0703001 Produto não encontrado em P17: "+ P27->P27_PRODUT + "Filial" + P27->P27_FILIAL
			U_FCRTLOG(cArq,cMsgETL)
			Break
		Endif

		RestArea(_aArea)

		P27->(RecLock("P27", .T.))
		P27->P27_FILIAL := xFilial("P27")
		P27->P27_CODFEC := (cNewAlias)->P26_CODFEC
		P27->P27_IDORIG := (cNewAlias)->P27_IDORIG
		P27->P27_PRODUT := (cNewAlias)->P27_PRODUT
		IF Val((cNewAlias)->P27_QTDPRO) <> 0
			aConv := U_F07024X((cNewAlias)->P27_PRODUT, xFilial("P27") , Val((cNewAlias)->P27_QTDPRO), F24CONSUMO , F24FRONTTOP12, P17_UM1)
			If !Empty(aConv[3])
				cMsg := "ERRO| " + aConv[3]
				Return ( .F. )
			EndIf
			nQUANT := aConv[1]
		ELSE
			nQUANT := Val((cNewAlias)->P27_QTDPRO)
		Endif
		P27->P27_QTDPRO := nQUANT
		P27->P27_LOCAL  := (cNewAlias)->P27_LOCAL
		P27->P27_VLTOTP := Val((cNewAlias)->P27_VLTOTP)
		P27->P27_OBSERV := (cNewAlias)->P27_OBSERV
		P27->P27_DTPROC := Date()
		P27->P27_HRPROC := Time()
		P27->(MsUnLock())
		P27->(DbCommit())
		(cNewAlias)->(DbSkip())
	End
	(cNewAlias)->(dbCloseArea())

	TerminoETL() // Finaliza conexão

Return(.T.)

Static Function AtuSB2(cCodFec, dDtFec, cMsg)
	Local nRecSB2 := 1
	Local nCalcEst := 0


	P26->(DbSetOrder(1))
	If ! P26->(DbSeek(xFilial("P26") + cCodFec))
		cMsg := "Codigo de Fechamento não encontrado em P26"
		U_FCRTLOG(cArq,cMsg)
		Break
	EndIf

	_aArea := FWGetArea()

	P17->(DbSetOrder(1))
	IF ! P17->(DbSeek ( xFilial("P17") + P27->P27_PRODUT + P27->P27_FILIAL ))
		cMsg := "F0703001 Produto não encontrado em P17: "+ P27->P27_PRODUT + "Filial" + P27->P27_FILIAL
		U_FCRTLOG(cArq,cMsg)
		Break
	ENDIF

	RestArea(_aArea)

	P27->(DbSetOrder(1))
	If ! P27->(DbSeek(xFilial("P27") + cCodFec))
		cMsg := "Codigo de Fechamento não encontrado em P27"
		U_FCRTLOG(cArq,cMsg)
		Break
	EndIf

	SB2->(DbSetOrder(1))

	cAliasNew   := GetNextAlias()

	cQuery := " SELECT P27_FILIAL,P27_PRODUT,P27_LOCAL,P27_QTDPRO    ,P27_VLTOTP     ,'P27' AS TIPO FROM "+RetSqlName('P27')+" P27"
	cQuery += " WHERE P27_FILIAL = '"+xFilial('P27')+"' AND P27_CODFEC = '"+cCodFec+"' AND P27.D_E_L_E_T_ = ' '"
	cQuery += " UNION"
	cQuery += " SELECT B2_FILIAL,B2_COD     ,B2_LOCAL,0 AS P27_QTDPRO,0 AS P27_VLTOTP,'SB2' AS TIPO FROM "+RetSqlName('SB2')+" SB2"
	cQuery += " LEFT JOIN "+RetSqlName('P27')+" P27 ON ( P27.P27_FILIAL = SB2.B2_FILIAL AND P27.P27_PRODUT = SB2.B2_COD"
	cQuery += " AND P27.P27_LOCAL = SB2.B2_LOCAL AND P27_CODFEC = '"+cCodFec+"' AND P27.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE B2_FILIAL = '"+xFilial('SB2')+"' AND SB2.D_E_L_E_T_ = ' ' AND P27.P27_PRODUT IS NULL"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

	U_FCRTLOG(cArq,"Início - While no SB2")

	While (cAliasNew)->(!Eof())

		If !SB2->(DbSeek( (cAliasNew)->P27_FILIAL + (cAliasNew)->P27_PRODUT + (cAliasNew)->P27_LOCAL ))
			SB2->(CriaSB2((cAliasNew)->P27_PRODUT, (cAliasNew)->P27_LOCAL))
			U_FCRTLOG(cArq,"Produto criado no SB2 - Filial: "+(cAliasNew)->P27_FILIAL+" - Produto: "+(cAliasNew)->P27_PRODUT+" - Local: "+(cAliasNew)->P27_LOCAL)
		Endif

		IF !SB1->( dbSeek(xFilial("SB1") + SB2->B2_COD) )
			cMsg := "F0703001: ERRO Linha 745: " + cFilAnt + "-" + "NAO ACHOU CODIGO " + SB2->B2_COD + "-" + "LOCAL " + SB2->B2_LOCAL
			U_FCRTLOG(cArq,cMsg)
			Break
		Endif

		U_FCRTLOG(cArq,"Início - Update SB2 "+StrZero(nRecSB2,10)+" - Filial: "+SB2->B2_FILIAL+" - Produto: "+SB2->B2_COD+" - Local: "+SB2->B2_LOCAL)

		If SB2->(DbSeek( (cAliasNew)->P27_FILIAL + (cAliasNew)->P27_PRODUT + (cAliasNew)->P27_LOCAL ))
			nCalcEst := CalcEst((cAliasNew)->P27_PRODUT, (cAliasNew)->P27_LOCAL, dDtFec + 1)[ 1 ]
			If ValType(nCalcEst) <> "N"
				nCalcEst := 0
			EndIf
			SB2->(RecLock("SB2",.F.))
			SB2->B2_QFIM  := (cAliasNew)->P27_QTDPRO
			SB2->B2_VFIM1 := (cAliasNew)->P27_VLTOTP
			If SB2->B2_QFIM != 0
				SB2->B2_CMFIM1 := SB2->B2_VFIM1 / ABS(SB2->B2_QFIM)
				If !Empty(SB1->B1_CONV)
					SB2->B2_QFIM2 := ConvUm(SB2->B2_COD, SB2->B2_QFIM, 0, 2)
				Else
					SB2->B2_QFIM2 := SB2->B2_QTSEGUM
				EndIf
			Else
				SB2->B2_CMFIM1 := 0
				SB2->B2_QFIM2  := 0
			EndIf
			SB2->B2_XDATA  := P26->P26_DTFECH
			SB2->B2_XFLAG  := "F" // F-Fechamento E-Estorno
			SB2->B2_XQTDE  := nCalcEst//CalcEst((cAliasNew)->P27_PRODUT, (cAliasNew)->P27_LOCAL, dDtFec + 1)[ 1 ]
			IF (cAliasNew)->TIPO == "P27"
				IF SB2->B2_VFIM1 > 0
					SB2->B2_XVLTOT := SB2->B2_XQTDE * (SB2->B2_VFIM1 / SB2->B2_QFIM)
				Endif
			Else
				SB2->B2_XVLTOT := 0
			Endif
			SB2->(MsUnLock())
			SB2->(DbCommit())
		Endif

		U_FCRTLOG(cArq,"Fim    - UpDate SB2 "+StrZero(nRecSB2,10)+" - Filial: "+SB2->B2_FILIAL+" - Produto: "+SB2->B2_COD+" - Local: "+SB2->B2_LOCAL)

		(cAliasNew)->(DbSkip());nRecSB2++

	EndDo

	(cAliasNew)->(DBCloseArea())

	U_FCRTLOG(cArq,"Fim - While no SB2")

Return

Static Function ExecMata331(dDtFec)
	Local aListaFil := {.F.,cFilAnt}
	Local lBat		:= .T.

	/*Início - Thais Paiva - Compatibilização P27
	GrvSX1("MTA330    " + "01", DToC(dDtFec))			//Data de limite final - Data de Fechamento
	GrvSX1("MTA330    " + "02", 2)						//Mostra Lançamentos contábeis - Não
	GrvSX1("MTA330    " + "03", 1)						//Aglutina Lançamentos contábeis - Sim
	GrvSX1("MTA330    " + "04", 2)						//Atualiza Arquivos de Movimentos - Não
	GrvSX1("MTA330    " + "05", 0)						//% de Aumento da MOD - 0
	GrvSX1("MTA330    " + "06", 1)						//Centro de Custo - Contábil
	GrvSX1("MTA330    " + "07", "               ")		//Conta Contábil a Inibir de - Branco
	GrvSX1("MTA330    " + "08", "               ")		//Conta Contábil a Inibir Até - Branco
	GrvSX1("MTA330    " + "09", 1)						//Apagar Estornos - Não
	GrvSX1("MTA330    " + "10", 1)						//Gerar Lançamento Contábil - Sim
	GrvSX1("MTA330    " + "11", 2)						//Gerar Estrutura pela Movimentação - Não
	GrvSX1("MTA330    " + "12", 3)						//Contabilização on line por - Ambas
	GrvSX1("MTA330    " + "13", 2)						//Calcula mão de obra - Não
	GrvSX1("MTA330    " + "14", 2)						//Método de Apropriação - Mensal
	GrvSX1("MTA330    " + "15", 2)						//Recálculo nível de estrutura - Não    
	GrvSX1("MTA330    " + "16", 2)						//Mostra Sequencia de cálculo - Custo médio
	GrvSX1("MTA330    " + "17", 2)						//Sequencia de Processamento de Fifo - Custo médio
	GrvSX1("MTA330    " + "18", 2)						//Movimentos Internos Valorizados - Depois
	GrvSX1("MTA330    " + "19", 2)						//Recálculo de Custo de transporte - Não
	GrvSX1("MTA330    " + "20", 2)    					//Cálculo de Custo por - Filial Corrente
	GrvSX1("MTA330    " + "21", 2)						//Calcular em Partes - Não    
	Fim - Thais Paiva - Compatibilização P27*/
	//forço para não exibir o lançamento contabil
	ACESSAPERG("MTA330", .F.)
	MV_PAR02 := 2  

	MATA331(lBat,aListaFil)

Return


Static Function GrvSB2()

Return 

Static Function ExecMata280(dDtFec, cMsg)

	Local dDataMes := GetMv("MV_ULMES")

	Local nPar01   := GetMv("FS_EF70302",,2)  // Gera copia dos dados
	Local nPar02   := GetMv("FS_EF70303",,2)  // Gera Sld Inicial para MOD  
	Local nPar03   := GetMv("FS_EF70304",,2)  // Seleciona Filial
	Local nPar04   := GetMv("FS_EF70305",,2)  // Atualiza saldo atual da MOD

	Private lMsErroAuto := .F.

	If dDtFec <= dDataMes // Data do fechamento está menor que MV_ULMES
		cMsg := "Data de fechamento : "+DTOC(dDtFec) +" anterior a periodo já fechado (MV_ULMES) : "+DTOC(dDataMes)
		U_FCRTLOG(cArq,cMsg)		
		Break
	EndIf

	//GrvSX1("MTA330    " + "01", DToC(dDtFec)) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "01", AllTrim(Str(nPar01))) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "02", AllTrim(Str(nPar02))) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "03", AllTrim(Str(nPar03))) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "04", AllTrim(Str(nPar04))) Thais Paiva - Compatibilização P27

	// Ticket #9409444 05/08/2020 - Eduardo Williams - Atualização das variáveis MV para utlização pela MATA280
	// Início 
	
	Pergunte("MTA330",.f.)
	SetMVValue("MTA330","MV_PAR01",dDtFec)

	Pergunte('MTA280',.f.)
	SetMVValue("MTA280", "MV_PAR01", nPar01)
	SetMVValue("MTA280", "MV_PAR02", nPar02)
	SetMVValue("MTA280", "MV_PAR03", nPar03)
	SetMVValue("MTA280", "MV_PAR04", nPar04)

	MATA280(.T.,dDtFec)

Return

/*Início - Thais Paiva - Compatibilização P27
Static Function GrvSX1(cChave, cConteudo)
	Local aArea    := FWGetArea()
	Local aAreaSX1 := SX1->(FWGetArea("SX1"))

	If ValType(cConteudo) == "N"
		cConteudo := AllTrim(Str(cConteudo))
	EndIf

	SX1->(DbSetOrder(1))
	If SX1->(DbSeek(cChave))
		SX1->(RecLock("SX1", .F.))
		SX1->X1_CNT01 := cConteudo
		SX1->(MsUnLock())
	EndIf

	RestArea(aAreaSX1)
	RestArea(aArea)
Return
Thais Paiva - Compatibilização P27*/

Static Function PreparaEmail(cLog,  lEstorno)
	Local cSMTP     := AllTrim(GetMV("MV_RELSERV"))  // smtp.ig.com.br ou 200.181.100.51
	Local cConta    := AllTrim(GetMV("MV_RELACNT"))  // fulano@ig.com.br
	Local cPass     := AllTrim(GetMV("MV_RELPSW" ))  // 123abc
	Local cContaDes := AllTrim(GetMv("FS_EF70301"))
	Local cAssunto  := "Termino do Fechamento de Estoque Especifico da filial:" + cFilAnt
	Local cMensagem := "" 
	Local cRet      := ""
	Default lEstorno := .F.


	cMensagem := "<html>"
	cMensagem += "<head><title>" + AllTrim(cAssunto) + "</title></head>"

	cMensagem += "<body>" 
	cMensagem += "<br>"
	cMensagem += "Sr(a)(s),<br>"
	cMensagem += "<br>"
	If ! lEstorno
		cMensagem += "O Fechamento Especifico de Estoque foi finalizado em " + Dtoc(dDataBase) + " às " + Left(Time(),5) + " <br>"
	Else
		cMensagem += "O Estorno do Fechamento Especifico de Estoque foi finalizado em " + Dtoc(dDataBase) + " às " + Left(Time(),5) + " <br>"
	EndIf
	cMensagem += "<br>"
	cMensagem += "Log:<br>"
	cMensagem += StrTran( cLog, CRLF , "<br>" )
	cMensagem += "</body>"
	cMensagem += "</html>"

	cRet := EnviaEmail(cSMTP, cConta, cPass, cContaDes, cAssunto, cMensagem)

Return cRet



Static Function EnviaEmail(cSMTP, cConta, cPass, cContaDes, cAssunto, cMensagem)
	Local lConSMTP  := .F.
	Local lEnvEmail := .F.
	Local cError    := ""
	Local cRet      := ""  

	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP
	If lConSMTP
		Send Mail From cConta To cContaDes Subject cAssunto Body  cMensagem  Result lEnvEmail

		If !lEnvEmail // Erro no envio do email
			Get Mail Error cError
			cRet := "Erro no envio do email: " + cError
		EndIf
		Disconnect SMTP Server
	Else // Erro na conexao com o SMTP Server
		Get Mail Error cError
		cRet := "Erro na conexão SMTP: " + cError
	EndIf

Return cRet


//=====================================================================================================
/*
Funções para tratamento de ETL
*/ 

Static Function InicioETL()
	Local cDBMS   := GETMV("FS_DBMS")
	Local cBanco  := GETMV("FS_DTBASE")
	Local cServer := GETMV("FS_SERVER")
	Local nPort	  := Val(GETMV("FS_PORT"))

	If Empty(cDBMS) .Or. Empty(cBanco) .Or. Empty(cServer) .Or. Empty(nPort)
		cMsgETL := "Parametros de conexao nao preenchidos FS_DBMS|FS_DTBASE|FS_SERVER|FS_PORT"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	If ValType(oDbApData) == "O" .And. oDbApData:HasConnection()
		cMsgETL := "Conexão com o ApData ja esta Ativa"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	oDbApData := FWDBAccess():New(cDBMS + "/" + cBanco, cServer, nPort)
	oDbApData:SetConsoleError( .T. )

	If !oDbApData:OpenConnection()
		cMsgETL := "Falha Conexão com a base Externa - Erro: " + AllTrim( oDbApData:ErrorMessage() )
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

Return

Static Function TerminoETL()

	If ValType(oDbApData) == "O" .And. ! oDbApData:HasConnection()
		cMsgETL := "Conexao com o ApData nao esta Ativa"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf
	oDbApData:CloseConnection()
	oDbApData:Finish()
	oDbApData := Nil

Return

Static Function CriaETL(cTbl, aTblStru, aTblIndex)
	Local cCommand := ""
	Local cOwner   := GetMV('FS_OWNER',,'')
	Local cOwner := ""
	Local nCampos  := 0
	Local nIndice  := 0

	If Empty(cTbl)
		cMsgETL := "Tabela nao informada nos parametros"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf
	If Len(aTblStru) == 0
		cMsgETL :=  "Array de Estrutura da tabela " + cTbl + " nao informado nos parametros"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf
	If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()
		cMsgETL := "Conexao com o ApData nao esta Ativa"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	If oDbApData:FileExists(cTbl)
		Return
	EndIf

	cCommand := "CREATE TABLE " + cOwner + cTbl + "( "
	For nCampos := 1 To Len(aTblStru)
		cCommand += aTblStru[nCampos, 1] + " "
		If aTblStru[nCampos, 2] == "VARCHAR"
			If TcGetDb() == "ORACLE"
				cCommand += "VARCHAR2(" + StrZero(aTblStru[nCampos, 3], 3) + ")"
			Else
				cCommand += "VARCHAR(" + StrZero(aTblStru[nCampos, 3], 3) + ")"
			EndIf
		Else
			cCommand += aTblStru[nCampos, 2]
		EndIf
		If nCampos < Len(aTblStru)
			cCommand += ", "
		EndIf
	Next
	cCommand += ")"

	oDbApData:SQLExec(cCommand)
	If oDbApData:HasError()
		cMsgETL := "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	cCommand := "CREATE INDEX T_" + cTbl + "_IDX ON " + cOwner + cTbl + " ("
	For nIndice := 1 to Len(aTblIndex)
		cCommand += aTblIndex[nIndice]
		If nIndice < Len(aTblIndex)
			cCommand += ", "
		EndIf
	Next
	cCommand += ")"

	oDbApData:SQLExec(cCommand)
	If oDbApData:HasError()
		cMsgETL += "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na criacao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())
		U_FCRTLOG(cArq,cMsgETL)
		Break
	Endif

Return

Static Function SelecionaETL(cQuery, cNewAlias)
	If Empty(cQuery)
		cMsgETL := "Parametro de query vazio"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf
	If Empty(cNewAlias)
		cMsgETL := "Parametro de Alias nao informado"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	Endif

	If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()
		cMsgETL := "Conexao com o ApData nao esta Ativa"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	If Select(cNewAlias) > 0
		(cNewAlias)->(dbCloseArea())
	Endif

	oDbApData:NewAlias( cQuery , cNewAlias )
	If oDbApData:HasError()
		cMsgETL := "Erro na selecao dos dados na tabela " + cNewAlias + " - " + AllTrim(oDbApData:ErrorMessage())
		U_FCRTLOG(cArq,cMsgETL)
		Break
	Endif

Return

Static Function AlteraETL(cCommand)

	If Empty(cCommand)
		cMsgETL := "Parametro de script vazio"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	Endif

	If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()
		cMsgETL := "Conexao com o ApData nao esta Ativa"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	If !oDbApData:SQLExec(cCommand)
		cMsgETL := "Erro na atualizacao dos dados - Erro: [" + AllTrim(oDbApData:ErrorMessage()) + "]"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	Endif

Return

Static Function InsereETL(cTbl, aCampos)
	Local cCommand     := ""
	Local cOwner       := GetMV('FS_OWNER',,'')
	Local cListaCampos := ""
	Local cListaValores:= ""
	Local nCampos      := 0

	If Empty(aCampos)
		cMsgETL := "Array com campos e conteudos não informados"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	Endif

	If ValType(oDbApData) == "O" .And. !oDbApData:HasConnection()
		cMsgETL := "Conexao com o ApData nao esta Ativa"
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

	For nCampos := 1 to Len(aCampos)
		cListaCampos  += aCampos[nCampos, 1]
		cListaValores += "'" + aCampos[nCampos, 2] + "'"
		If nCampos < Len(aCampos)
			cListaCampos  += ", "
			cListaValores += ", "
		EndIf
	Next
	cCommand := "INSERT INTO " + cOwner + cTbl + " (" + cListaCampos + ") VALUES (" + cListaValores + ") "

	oDbApData:SQLExec(cCommand)
	If oDbApData:HasError()
		cMsgETL += "Erro: [" + AllTrim(Str(oDbApData:SqlError())) + "] na insercao da tabela: " + cTbl + " - " + AllTrim(oDbApData:ErrorMessage())
		U_FCRTLOG(cArq,cMsgETL)
		Break
	EndIf

Return



// ================== funcao de teste e de inserção de dados
/*
User Function TST030()
Local cEmp   := "99"
Local cFil   := "01"
Local cUser  := "Admin"
Local cSenha := ""
Local aParam := {{cEmp, cFil}}

XX := RpcSetEnv(cEmp, cFil, cUser, cSenha, "EST", , )
U_F0703001(aParam)
RpcClearEnv()

Return

User Function TST030Inc()
Local cTbl      :="F0703001"
Local aCampos   := {} 
Local cEmp      := "99"
Local cFil      := "01"
Local cUser     := "Admin"
Local cSenha    := ""
Local cCodFec   := FwTimeStamp() 
Local nQtdTot   := 3
Local nInc      := 0

XX := RpcSetEnv(cEmp, cFil, cUser, cSenha, "EST", , )

InicioETL() // Inicializa conexão   

ChkFile("SB1") 

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial('SB1') + "0000000001     "))
	While SB1->( ! Eof())
		If ++nInc > nQtdTot
Exit 
		EndIf

aCampos := {}
AAdd(aCampos, {"P26_FILIAL", "01"                    })
AAdd(aCampos, {"P26_CODFEC", cCodFec                 })   // AAAA-MM-DD HH:MM:SS
AAdd(aCampos, {"P26_DTFECH", dtoc(dDataBase)         })   //DD/MM/AAAA
AAdd(aCampos, {"P26_OPER"  , "F"                     })   // F=Fechamento; E=Estorno
AAdd(aCampos, {"P26_QTDTOT", Alltrim(Str(nQtdTot))   })   
AAdd(aCampos, {"P26_STATUS", "1"                     })  // 1= Disponivel para processamento; 2=Processando; 3=Processado OK; 4=Processado Erro
AAdd(aCampos, {"P26_PROCTB", " "                     })  // AAAA-MM-DD HH:MM:SS
AAdd(aCampos, {"P26_DTEXFE", " "                     })  //DD/MM/AAAA
AAdd(aCampos, {"P26_HREXFE", " "                     })  //HH:MM:SS
AAdd(aCampos, {"P26_USER"  , "MANE"                  })               
AAdd(aCampos, {"P27_IDORIG", "334197"                })  // Id do Front
AAdd(aCampos, {"P27_PRODUT", SB1->B1_COD             })
AAdd(aCampos, {"P27_QTDPRO", "10"                    })
AAdd(aCampos, {"P27_LOCAL" , "01"                    })
AAdd(aCampos, {"P27_VLTOTP", "1000"                  })
AAdd(aCampos, {"P27_OBSERV", " "                     })
AAdd(aCampos, {"P27_DTPROC", " "                     })  //DD/MM/AAAA
AAdd(aCampos, {"P27_HRPROC", " "                     })  //HH:MM:SS
AAdd(aCampos, {"P27_IDFRON", " "                     })

InsereETL(cTbl, aCampos) // Executa a Query

SB1->(DbSkip())
	End
TerminoETL() // Finaliza conexão

RpcClearEnv()

Return
*/





// Funcao criada para testar a MATA280 segregada
User  Function ExMt280(dDtFec, cMsg)

	// U_ExMt280(CTOD("31/03/2018"), "")

	Local dDataMes := GetMv("MV_ULMES")
	//    Local dDataMes := CTOD("28/02/2018") // Alterado para testes

	Local nPar01   := GetMv("FS_EF70302",,2)  // Gera copia dos dados
	Local nPar02   := GetMv("FS_EF70303",,2)  // Gera Sld Inicial para MOD
	Local nPar03   := GetMv("FS_EF70304",,2)  // Seleciona Filial
	Local nPar04   := GetMv("FS_EF70305",,2)  // Atualiza saldo atual da MOD

	Private lMsErroAuto := .F.

	If dDtFec <= dDataMes // Data do fechamento está menor que MV_ULMES
		cMsg := "Data de fechamento : "+DTOC(dDtFec) +" anterior a periodo já fechado (MV_ULMES) : "+DTOC(dDataMes)
		Break
	EndIf

	//GrvSX1("MTA330    " + "01", DToC(dDtFec)) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "01", AllTrim(Str(nPar01))) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "02", AllTrim(Str(nPar02))) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "03", AllTrim(Str(nPar03))) Thais Paiva - Compatibilização P27
	//GrvSX1("MTA280    " + "04", AllTrim(Str(nPar04))) Thais Paiva - Compatibilização P27

	//	// ALERT("MATA280")
	MATA280(.T.,dDtFec) // Voltar apos testes


Return

	ErrorBlock(bBlock)
	IF !Empty(cCritica)
		Conout("Ocorreu o erro: "+cCritica)
		ConOut("Pilha de Chamada:"+cPilhaCha)
	Endif
Return( NIL )

Static Function ChecErro(e,cCritica,cPilhaCha)
	If e:gencode > 0
		cCritica  := e:DESCRIPTION
		cPilhaCha := e:ERRORSTACK
	Endif
	Break
Return


Static Function AtuSB9(cCodFec,dDtFec,cMsg)

	Local cQuery := ""

	cQuery := " INSERT INTO " + RetSqlName("SB9")
	cQuery += " (B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, B9_QINI, B9_QISEGUM,B9_VINI1,B9_CM1,B9_MCUSTD,R_E_C_N_O_) "
	cQuery += " (SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_XDATA, B2_QFIM, B2_QFIM, B2_VFIM1, B2_CM1,'1',(SELECT MAX(R_E_C_N_O_) FROM " +RetSqlName("SB9") + " ) + ROW_NUMBER() OVER(ORDER BY B2_FILIAL) "
	cQuery += " FROM " +RetSqlName("SB2") + " WHERE B2_FILIAL = '"+xFilial("SB2")+ "' AND B2_XDATA = '"+DtoS(dDtFec)+"'  AND D_E_L_E_T_ = ' ' "
	cQuery += " AND NOT EXISTS (SELECT 1 FROM " +RETSQLNAME("SB9")+ " B9 WHERE B9.D_E_L_E_T_ = ' ' AND B9_DATA = B2_XDATA AND B9_COD = B2_COD AND B9_LOCAL = B2_LOCAL))"

	If TCSQLExec(cQuery) <> 0
		Alert("Erro ao atualizar a tabela SB9, favor exibir essa mensagem ao admin do sistema. " + TCSqlError())
		cMsg := "Erro ao atualizar a tabela SB9, favor exibir essa mensagem ao admin do sistema. " + TCSqlError()
		U_FCRTLOG(cArq,cMsg)
		Break
	EndIf

Return
