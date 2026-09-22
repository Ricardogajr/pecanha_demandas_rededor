#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "SIGACUSA.CH"

Static __lNoErro // Variavel nao deve ser removida !!!
Static lxProxNum
Static lFProxNum
Static __lD1D2D3
Static cMoeda330C  //Moedas para calculo do custo medio - Sempre processa moeda 1
Static cProdutoLog //Produtos a serem verificados no log de diferenca de saldo -
//deve ser colocado "/" apos cada produto para separacao dos codigos

Static aOpcCache    := {}
Static __aPrepared  := {}
Static __lCusaVLib
Static lA330ISMOD // Utilizado para testar a existencia da funcao A330ISMOD do fonte MATA330.PRX
Static _aTamSX3

Static __lSeekMOD   := nil
Static __cQryMOD    := nil
Static __cEmpOld    := nil
Static __cFilOld    := nil
Static __oProdMOD
Static __cEmpFilOld
Static __lChkNum    := .F.
Static __RpoRelease := nil

User Function XProxNum(lSave,lShowFinal)

	Local cAliasNum      := Alias()
	Local lFalhou
	Local cTexto         := STR0125 //"O parametro MV_DOCSEQ nao foi conseguiu ser travado. O numero sequencial do movimento sera "
	Local nTentativas    := 0
	Local nTam           := TamSx3("D3_NUMSEQ")[1]
	Local cNumSeq        := Replicate("0",nTam)
	Local cLockKey       := 'MV_DOCSEQ_' +cEmpAnt+cFilAnt //+cFilAnt
	Local nTotTentativas := 120000 //- numero de tentativa para pegar o SX6
	Local nWaitTime      := 275 //- tempo em milesegundos


	If ValType(lShowFinal) != "L"
		lShowFinal := .T.
	Endif

	IF ValType(lSave) != "L"
		lSave := .t.
	Endif

	lFalhou := .T.

	IF lSave
		__lNoErro := nil

		//- garante que não haja outro processo

		While nTentativas <= nTotTentativas
			If LockByName(cLockKey,.F.,.F.,.F.)
				lFalhou := .F.
				Exit
			EndIf
			nTentativas++
			Sleep(nWaitTime)//- segura 1 segundo
		EndDo
	

		//- indica que não foi possivel exclusividade da chave
		If lFalhou
			If IsTelNet()
				VTAlert(cTexto+cNumSeq, STR0130) //"Prob. MV_DOCSEQ"
			Else
				MsgAlert(cTexto+cNumSeq)
			EndIf
			If !Empty(cAliasNum)
				DbSelectArea(cAliasNum)
			EndIf

			Return nil
		EndIf

		//- VALIDA apenas uma vez na chamada
		IF !__lChkNum
			_CheckSeque()
			__lChkNum := .T.
		Endif

		cNumSeq := Soma1(Substr(GETMV("MV_DOCSEQ"),1,nTam))

		//- efetua a gravação do valor da chave
		PutMV("MV_DOCSEQ",cNumSeq)


		//- Libera a chave para uso
		UnLockByName(cLockKey,.F.,.F.,.F.)
	Else
		//- pega o valor corrente, não podendo estar em CACHE
		cNumSeq := Soma1(Substr(GETMV("MV_DOCSEQ"),1,nTam))
	Endif

	If !Empty(cAliasNum)
		DbSelectArea(cAliasNum)
	EndIf

Return cNumSeq



Static Function _CheckSeque()
	Local cGreat  := Space(Len(Criavar("D1_NUMSEQ")))
	Local cText
	Local cAlias  := Alias()
	Local nTam    := TamSx3("D3_NUMSEQ")[1]
	Local cNumSeq := Replicate("0",nTam)
	Local cQuery   as Character
	Local aBindSeq as array


//- ENCONTRA O MAIS NUMSEQ ENTRE AS TABELAS
	cQuery := "SELECT MAX(NUMSEQ) NUMSEQ FROM ("
//- busca o maior do SD1
	cQuery += " SELECT MAX(D1_NUMSEQ) NUMSEQ FROM "
	cQuery += RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "
	cQuery += " UNION ALL "
//- busca o maior do SD2
	cQuery += " SELECT MAX(D2_NUMSEQ) NUMSEQ FROM "
	cQuery += RetSqlName("SD2")
	cQuery += " WHERE D2_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "
	cQuery += " UNION ALL "
//- busca o maior do SD3
	cQuery += " SELECT MAX(D3_NUMSEQ) NUMSEQ FROM "
	cQuery += RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "
	cQuery += " AND D3_EMISSAO >= ?"
	cQuery += ") MAIOR"
	cQuery := ChangeQuery(cQuery)

	aBindSeq := {}

	AAdd(aBindSeq,FWxFilial('SD1'))
	AAdd(aBindSeq,' ')
	AAdd(aBindSeq,FWxFilial('SD2'))
	AAdd(aBindSeq,' ')
	AAdd(aBindSeq,FWxFilial('SD3'))
	AAdd(aBindSeq,' ')
	AAdd(aBindSeq, "TO_CHAR(SYSDATE - INTERVAL '1' DAY, 'YYYYMMDD')")

	dbUseArea( .T., "TOPCONN", TcGenQry2(,,cQuery,aBindSeq), "_QPROXSEQ", .T., .T. )

	If _QPROXSEQ->(!Eof())
		cGreat := _QPROXSEQ->NUMSEQ
	EndIf

	_QPROXSEQ->(dbCloseArea())

	aSize(aBindSeq,0)
	aBindSeq := nil

	cNumSeq := Soma1(Substr(GETMV("MV_DOCSEQ"),1,nTam))

//- valida se o gravado nas tabelas é maior que a chave do MV_DOCSEQ
	If cGreat >= cNumSeq
		cText := STR0128+cGreat+"." //"Problema no conteudo do parametro MV_DOCSEQ. O valor correto deveria ser: " + cNext
		cNumSeq := Soma1(Substr(cGreat,1,nTam))
		PutMV("MV_DOCSEQ",cNumSeq)
	EndIf

	__lNoErro := .T.

	If !Empty(cAlias)
		dbSelectArea(cAlias)
	EndIf

Return Nil
