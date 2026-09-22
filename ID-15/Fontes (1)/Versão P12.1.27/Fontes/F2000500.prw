#Include "Totvs.ch"

Static cErroRot := "" // contem o errorlog do controle de erros

/*/{Protheus.doc} F2000501

Funcao principal do WS de Lançamentos Contábeis - XRT

@type function
@version  
@author fabio.cazarini
@since 18/06/2021
@param oDados, object, param_description
@return return_type, return_description
/*/
User Function F2000501(oWSIn, oWsOut)
	Local cEmpBkp   := ''
	Local cFilBkp   := ''
	Local cEmpWs    := ''
	Local cFilWs    := ''
	Local cRetVld   := ''
	Local nX        := 1
	Local lSucesso  := .F.
	Local aCab      := {}
	Local aItem     := {}
	Local aItens    := {}

	Local cLote     := ""
	Local cSubLote  := ""
	Local cDoc      := ""
	Local dDataLan  := Ctod("//")

	Local cLinha    := ""
	Local cEstorno  := ""
	Local cChvOrig  := ""
	Local cPcXRT    := ""
	Local cCdXRT    := ""
	Local cDC       := ""
	Local cCredit   := ""
	Local cCCC      := ""
	Local cItemC    := ""
	Local cDebito   := ""
	Local cCCD      := ""
	Local cItemD    := ""
	Local cHist     := ""
	Local cMoedLC   := ""
	Local nValor    := 0
	Local lValido   := .T.
	Local lRet      := .F.
	Local cLinErro  := ""
	Local cFilP19   := ""
	Local lGrpHblt  := .F.
	Local nDebito   := 0
	Local nCredito  := 0

	Private cIdInP19    := ""
	Private nRLogP19    := 0
	Private _nTimeOut := SuperGetMV('FS_N200051',, 120)*1000 //ms
	Private _nTimeSt  := TimeCounter()
	Private cUserName := ""

	//Tratamento de semáforo
	/*/While !GlbNmLock("F2000500")
		If TimeCounter()-_nTimeSt > _nTimeOut
			GrvXmlVaz(oWsOut)
			Return
		EndIf
		Sleep(500) 
	EndDo/*/
Conout("Inicio F2000500 " + Time())
	__cUserId := "005026" 
	cUserName := "Integrador"

	cErroRot    := ""                               // Variavel estática
	bErrBlq     := ErrorBlock( {|e| CtlErrEx(e)} )  // Controle de erros de execução

	BEGIN SEQUENCE
		If Len(oWSIn:ITENS) == 0
			Conout('F2000500 - Integ XRT - Nao foi enviado nenhum lancamento contabil')
			cRetVld := 'Nao foi enviado nenhum lancamento contabil'
			XMLRetorno(oWSIn, oWsOut, .F., cRetVld)
			BREAK
		Endif

		cEmpWs   := oWSIn:ITENS[1]:EMP
		cFilWs   := oWSIn:ITENS[1]:FIL

		If !ExistCpo("SM0",cEmpWs+cFilWs)
			Conout('F2000501 - Integ XRT - Empresa '+cEmpWs+' Filial '+cFilWs+' não encontrada')
			cRetVld    := 'Empresa '+cEmpWs+' Filial '+cFilWs+' não encontrada'
			XMLRetorno(oWSIn, oWsOut, .F., cRetVld)
			Break
		EndIf

		If cEmpAnt != cEmpWs .Or. cFilAnt != cFilWs
			cEmpBkp := cEmpAnt
			cFilBkp := cFilAnt

			/*/RpcClearEnv()
			If !RpcSetEnv(cEmpWs, cFilWs, 'Administrador',,'CTB')
				Conout('F2000500 - Integ XRT - Falha ao preparar ambiente')
				cRetVld := 'Falha ao preparar ambiente'
				XMLRetorno(oWSIn, oWsOut, .F., cRetVld)
				BREAK
			EndIf/*/
            cFilAnt := cFilWs
            cEmpAnt := cEmpWs
		EndIf

		lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
		//Integração não habilitada neste grupo
		If !lGrpHblt
			cRetVld := 'Empresa/Filial: '+cEmpAnt+'/'+cFilAnt+' não habilitada para integracao.'
			Conout('F2000501 - Integ XRT - '+cRetVld)
			XMLRetorno(oWSIn, oWsOut, .F., cRetVld)
			Break
		EndIf

		//Grava o Log - Em processamento
		cFilP19     := FwXFilial("P19")
		cIdInP19 	:= U_GetIntegID()
		//nRLogP19    := U_F07LOG01(cIdInP19, {oWSIn}, "U_F2000501")

		CT2->( DbOrderNickName("FWS2000502") )  // CT2_FILIAL+CT2_XCHVXRT
		CT1->( dbSetOrder(1) )                  // CT1_FILIAL+CT1_CONTA
		CTD->( dbSetOrder(1) )                  // CTD_FILIAL+CTD_ITEM
		CTT->( dbSetOrder(1) )                  // CTT_FILIAL+CTT_CUSTO

		// Pre-valida itens
		aItens  := {}
		cLinha  := StrZero(0, GetSx3Cache("CT2_LINHA","X3_TAMANHO"))
		For nX := 1 To Len(oWSIn:ITENS)
			lValido     := .T.
			cLinErro    := ""

			If Empty(dDataLan)
				dDataLan := SToD( oWSIn:ITENS[nX]:DDATALANC )
			Endif

			cEstorno    := Alltrim(oWSIn:ITENS[nX]:ESTORNO)      // 1=Estorno;2=Lancamento
			cChvOrig    := Alltrim(oWSIn:ITENS[nX]:CHVORIG)      // Caso seja estorno, contem a chave original da integração para localização do registro no sistema
			cChvOrig    := Padr(cChvOrig, GetSx3Cache("CT2_XCDXRT","X3_TAMANHO"))
			cPcXRT      := Alltrim(oWSIn:ITENS[nX]:CT2_XPCXRT)   // Par contábil do XRT, equivalente ao documento no Protheus. Se estorno, buscar o par origem
			cCdXRT      := Alltrim(oWSIn:ITENS[nX]:CT2_XCDXRT)   // Informar chave única da integração - Se existir, devolve mensagem de que o lançamento já foi incluso.
			cCdXRT      := Padr(cCdXRT, GetSx3Cache("CT2_XCDXRT","X3_TAMANHO"))
			cDC         := Alltrim(oWSIn:ITENS[nX]:CT2_DC)
			If Upper(cDC) == 'D'
				cDC := '1'
			ElseIf Upper(cDC) == 'C'
				cDC := '2'
			EndIf
			cCredit     := Alltrim(oWSIn:ITENS[nX]:CT2_CREDIT)
			cCCC        := Alltrim(oWSIn:ITENS[nX]:CT2_CCC)
			cItemC      := Alltrim(oWSIn:ITENS[nX]:CT2_ITEMC)
			cDebito     := Alltrim(oWSIn:ITENS[nX]:CT2_DEBITO)
			cCCD        := Alltrim(oWSIn:ITENS[nX]:CT2_CCD)
			cItemD      := Alltrim(oWSIn:ITENS[nX]:CT2_ITEMD)
			cHist       := Alltrim(oWSIn:ITENS[nX]:CT2_HIST)
			cMoedLC     := Alltrim(oWSIn:ITENS[nX]:CT2_MOEDLC)
			nValor      := Abs(oWSIn:ITENS[nX]:CT2_VALOR)

			If cDC $ '13'
				nDebito += nValor
			EndIf
			If cDC $ '23'
				nCredito += nValor
			EndIf

			If lValido
				If .not. (cEstorno $ "12")
					cLinErro    := "Estorno deve ser 1 ou 2"
					lValido     := .F.
				Endif
			Endif

			If lValido
				If cEstorno == "1"
					If Empty(cChvOrig)
						cLinErro    := "Estorno: Chave origem nao informada"
						lValido     := .F.
					Else
						If CT2->( !MsSeek( xFilial("CT2") + cChvOrig) )
							cLinErro    := "Estorno: chave origem nao existe"
							lValido     := .F.
						Endif
					Endif
				Endif
			Endif

			If lValido
				If CT2->( MsSeek( xFilial("CT2") + cCdXRT) )
					cLinErro    := "Chave XRT ja existente"
					lValido     := .F.
					lRet        := .T. //Grava erro no Protheus mas retorna sucesso ao XRT
				Endif
			Endif

			If lValido
				If .not. (cDC $ "1234") // 1=Debito;2=Credito;3=Partida Dobrada;4=Cont.Hist;5=Rateio;6=Lcto Padrao
					cLinErro    := "CT2_DC deve ser 1,2,3 ou 4"
					lValido     := .F.
				Endif
			Endif

			If lValido
				If Empty(cHist)
					cHist := Iif(cEstorno=="1", "ESTORNO ", "") + "ORIGEM XRT"
				Else
					If cEstorno=="1" .and. .not. ("ESTORNO" $ cHist) // se for estorno e a palavra ESTORNO não está contida no hitórico
						cHist := "ESTORNO " + cHist
					Endif
				Endif
			Endif

			If lValido
				If cDC $ "23" .and. Empty(cCredit)
					cLinErro    := "Conta de credito nao informada"
					lValido     := .F.
				Endif
			Endif

			If lValido
				If cDC $ "13" .and. Empty(cDebito)
					cLinErro    := "Conta de debito nao informada"
					lValido     := .F.
				Endif
			Endif

			If lValido
				If .not. Empty(cCredit)
					cCredit := Padr( cCredit, GetSx3Cache("CT2_CREDIT", "X3_TAMANHO") )
					If .not. CT1->( MsSeek(xFilial("CT1")+cCredit) )
						cLinErro    := "Conta de credito nao cadastrada"
						lValido     := .F.
					Endif
				Endif
			Endif

			If lValido
				If .not. Empty(cCCC)
					cCCC := Padr( cCCC, GetSx3Cache("CT2_CCC", "X3_TAMANHO") )
					If .not. CTT->( MsSeek(xFilial("CTT")+cCCC) )
						cLinErro    := "Centro de Custo de credito nao cadastrado"
						lValido     := .F.
					Endif
				Endif
			Endif

			If lValido
				If !Empty(cCredit) .And. CT1->CT1_CCOBRG == '1' .And. Empty(cCCC)
					cLinErro := 'Obrigatorio preenchimento da entidade contabil: C.Custo Credito'
					lValido  := .F.
				EndIf
			EndIf

			If lValido
				If .not. Empty(cItemC)
					cItemC := Padr( cItemC, GetSx3Cache("CT2_ITEMC", "X3_TAMANHO") )
					If .not. CTD->( MsSeek(xFilial("CTD")+cItemC) )
						cLinErro    := "Item contabil de credito nao cadastrado"
						lValido     := .F.
					Endif
				Endif
			Endif

			If lValido
				If !Empty(cCredit) .And. CT1->CT1_ITOBRG == '1' .And. Empty(cItemC)
					cLinErro := 'Obrigatorio preenchimento da entidade contabil: Item Credito'
					lValido  := .F.
				EndIf
			EndIf

			If lValido
				If .not. Empty(cDebito)
					cDebito := Padr( cDebito, GetSx3Cache("CT2_DEBITO", "X3_TAMANHO") )
					If .not. CT1->( MsSeek(xFilial("CT1")+cDebito) )
						cLinErro    := "Conta de debito nao cadastrada"
						lValido     := .F.
					Endif
				Endif
			Endif

			If lValido
				If .not. Empty(cCCD)
					cCCD := Padr( cCCD, GetSx3Cache("CT2_CCD", "X3_TAMANHO") )
					If .not. CTT->( MsSeek(xFilial("CTT")+cCCD) )
						cLinErro    := "Centro de Custo de debito nao cadastrado"
						lValido     := .F.
					Endif
				Endif
			Endif

			If lValido
				If !Empty(cDebito) .And. CT1->CT1_CCOBRG == '1' .And. Empty(cCCD)
					cLinErro := 'Obrigatorio preenchimento da entidade contabil: C.Custo Debito'
					lValido  := .F.
				EndIf
			EndIf

			If lValido
				If .not. Empty(cItemD)
					cItemD := Padr( cItemD, GetSx3Cache("CT2_ITEMD", "X3_TAMANHO") )
					If .not. CTD->( MsSeek(xFilial("CTD")+cItemD) )
						cLinErro    := "Item contabil de debito nao cadastrado"
						lValido     := .F.
					Endif
				Endif
			Endif

			If lValido
				If !Empty(cDebito) .And. CT1->CT1_ITOBRG == '1' .And. Empty(cItemD)
					cLinErro := 'Obrigatorio preenchimento da entidade contabil: Item Debito'
					lValido  := .F.
				EndIf
			EndIf

			If lValido
				If Empty(cMoedLC)
					cMoedLC := "01"
				Endif
			Endif

			If lValido
				If nValor == 0 .and. cDC <> "4"
					cLinErro    := "Valor nao informado (zero)"
					lValido     := .F.
				Endif
			Endif

			// envia retorno de invalidacao do WS
			If .not. lValido
				Conout('F2000500 - Integ XRT - Dados inconsistentes: ' + cLinErro)
				XMLRetorno(oWSIn, oWsOut, lRet, cLinErro, nX)
				BREAK
			Endif

			cLinha  := Soma1( cLinha )
			aItem := {}
			aAdd(aItem, {'CT2_FILIAL'   , xFilial("CT2")    , NIL} )
			aAdd(aItem, {'CT2_LINHA'    , cLinha            , NIL} )
			aAdd(aItem, {'CT2_MOEDLC'   , cMoedLC           , NIL} )
			aAdd(aItem, {'CT2_DC'       , cDC               , NIL} )
			aAdd(aItem, {'CT2_DEBITO'   , cDebito           , NIL} )
			aAdd(aItem, {'CT2_CCD'      , cCCD              , NIL} )
			aAdd(aItem, {'CT2_ITEMD'    , cItemD            , NIL} )
			aAdd(aItem, {'CT2_CREDIT'   , cCredit           , NIL} )
			aAdd(aItem, {'CT2_CCC'      , cCCC              , NIL} )
			aAdd(aItem, {'CT2_ITEMC'    , cItemC            , NIL} )
			aAdd(aItem, {'CT2_VALOR'    , nValor            , NIL} )
			aAdd(aItem, {'CT2_HIST'     , cHist             , NIL} )
			aAdd(aItem, {'CT2_XPCXRT'   , cPcXRT            , NIL} )
			aAdd(aItem, {'CT2_XCDXRT'   , cCdXRT            , NIL} )
			aAdd(aItem, {'CT2_IDINT'    , cFilP19+cIdInP19  , NIL} )

			aAdd(aItens, aItem )
		Next nX

		If nDebito != nCredito
			lValido := .F.
			cLinErro := 'Debito: '+Alltrim(Transform(nDebito, PesqPict("CT2", "CT2_VALOR")))
			cLinErro += ' e Credito: '+Alltrim(Transform(nCredito, PesqPict("CT2", "CT2_VALOR")))
			cLinErro += ' não batem.'
			Conout('F2000500 - Integ XRT - Dados inconsistentes: ' + cLinErro)
			XMLRetorno(oWSIn, oWsOut, lRet, cLinErro)
			BREAK
		EndIf

		cLote     := SuperGetMV("FS_C200050", .T. , "")
		If Empty(cLote)
			cLote := StrZero(1, GetSx3Cache("CT2_LOTE","X3_TAMANHO"))
		Endif
		cSubLote  := "001"
		cDoc      := ""

		If Empty(dDataLan)
			dDataLan := dDataBase
		Endif

		ProxDoc(dDataLan, cLote, cSubLote, @cDoc)

		aCab := {}
		aAdd(aCab, { 'DDATALANC'     , dDataLan     , NIL } )
		aAdd(aCab, { 'CLOTE'         , cLote        , NIL } )
		aAdd(aCab, { 'CSUBLOTE'      , cSubLote     , NIL } )
		aAdd(aCab, { 'CDOC'          , cDoc         , NIL } )
		aAdd(aCab, { 'CPADRAO'       , ''           , NIL } )
		aAdd(aCab, { 'NTOTINF'       , 0            , NIL } )
		aAdd(aCab, { 'NTOTINFLOT'    , 0            , NIL } )

		// Executa rotina automatica de contabilizacao CTBA102
		lSucesso := LancaCtb(oWSIn, oWsOut, aCab, aItens, @cRetVld)

	END SEQUENCE

	ErrorBlock(bErrBlq) // Controle de erros de execução
	If !lSucesso
		If !Empty(cErroRot) .and. Empty(cRetVld) // Se ocorreu erro de execucao
			Conout('F2000500 - Integ XRT - Erro interno')
			XMLRetorno(oWSIn, oWsOut, .F., cErroRot)
		Endif
	Endif

	// Limpa memória (arrays e objetos)
	ASize(aCab, 0)
	ASize(aItem, 0)
	ASize(aItens, 0)
	aCab    := Nil
	aItem   := Nil
	aItens  := Nil

	//Restaura ambiente
	If !Empty(cEmpBkp) .and. !Empty(cFilWs) .and. (cEmpAnt != cEmpBkp .Or. cFilAnt != cFilBkp)
		//RpcSetEnv(cEmpBkp, cFilBkp, "Administrador","", "FIN" )
        cFilAnt := cFilBkp
        cEmpAnt := cEmpBkp
	EndIf

	//Destrava o semáforo
	//GlbNmUnlock("F2000500")
Conout("Fim F2000500 " + Time())
Return Nil


/*/{Protheus.doc} LancaCtb

Executa rotina automatica de contabilizacao CTBA102

@type function
@version  
@author fabio.cazarini
@since 22/06/2021
@param oWSIn, object, objeto recebido 
@param oWsOut, object, objeto retornado
@param aCab, array, cabecalho do execauto
@param aItens, array, itens do execauto
@param cRetVld, character, retorno de erro do execauto

@return logical, sucesso?
/*/
Static Function LancaCtb(oWSIn, oWsOut, aCab, aItens, cRetVld)
	Local cLog      := ""
	Local lSucesso  := .T.
	Local aErroAuto := {}
	Local nCount    := 0
	Local nItemErr  := 0
	Local cLinhaEr  := ""
	Local nX        := 0
	Local nCT2Lin   := 0

	Private lMsErroAuto     := .F.
	Private lAutoErrNoFile  := .T.
	Private lMsHelpAuto     := .T.
	Private CTF_LOCK        := 0
	Private lSubLote        := .T.

	cRetVld := ""
Conout("Antes ExecAuto CTBA102 " + Time())
	MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)
Conout("Depois ExecAuto CTBA102 " + Time())
	If lMsErroAuto
		lSucesso    := .F.
		aErroAuto   := GetAutoGRLog()
		For nCount := 1 To Len(aErroAuto)
			cLog += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + CRLF

			// identificar em qual CT2_LINHA ocorreu o erro
			If Empty(cLinhaEr) .and. "CT2_LINHA" $ aErroAuto[nCount]
				// "Numero Linha          CT2_LINHA    := 002"
				cLinhaEr := Alltrim(SubStr(aErroAuto[nCount], at("=", aErroAuto[nCount])+1))
			Endif
		Next nCount

		If Empty(cLog)
			cLog := "Erro desconhecido!"
		Else
			If !Empty(cLinhaEr) // CT2_LINHA em que ocorreu o erro
				nCT2Lin := aScan( aItens[1], {|x| x[1]=="CT2_LINHA"} ) // qual o elemento da array ITEM com o campo CT2_LINHA

				For nX := 1 To Len(aItens)
					If aItens[nX][nCT2Lin][2] == cLinhaEr
						nItemErr := nX
						Exit
					Endif
				Next nX
			Endif
		Endif

		cRetVld := cLog
	EndIf

	XMLRetorno(oWSIn, oWsOut, lSucesso, cLog, nItemErr)

	ASize(aErroAuto, 0)
	aErroAuto := Nil

Return lSucesso


/*/{Protheus.doc} XMLRetorno

Monta XML de retorno

@type function
@version  
@author fabio.cazarini
@since 18/06/2021
@param oWSIn, object, objeto recebido
@param oWsOut, object, objeto retornado
@param lSucesso, logical, sucesso?
@param cLog, character, mensagem de retorno ao XRT
@param nItemErr, numeric, item do objeto oWSIn em que ocorreu erro
/*/    
Static Function XMLRetorno(oWSIn, oWsOut, lSucesso, cLog, nItemErr)
	Local cIndKey   := ''
	Local nIndOrd   := 1
	Local cTab      := 'CT2'
	Local nItem     := 1

	Default nItemErr := 0

	while At("  ",cLog) > 0
		cLog := StrTran(cLog,"  "," ")
	Enddo

	cLog := Left(AllTrim(cLog), 250)

	Conout('F2000500 - '+cLog)

	If Len(oWSIn:ITENS) == 0
		AAdd(oWsOut:ITENS, WSClassNew('W20005RETIt'))

		oWsOut:ITENS[nItem]:RETSTATUS  := EncodeUTF8(IIf(lSucesso, 'C', 'E'))
		oWsOut:ITENS[nItem]:RETMSG     := EncodeUTF8(FwNoAccent(cLog))
		oWsOut:ITENS[nItem]:CT2_XCDXRT := ""
	Else
		cIndKey := FWXFilial('CT2')
		cIndKey += Padr( oWSIn:ITENS[1]:CT2_XCDXRT, GetSx3Cache('CT2_XCDXRT', 'X3_TAMANHO') )

		CT2->( DbOrderNickName("FWS2000502") )  // CT2_FILIAL+CT2_XCDXRT
		nIndOrd := CT2->( IndexOrd() )

		For nItem := 1 To Len(oWSIn:ITENS)
			AAdd(oWsOut:ITENS, WSClassNew('W20005RETIt'))

			If lSucesso
				oWsOut:ITENS[nItem]:RETSTATUS  := EncodeUTF8('C')
				oWsOut:ITENS[nItem]:RETMSG     := EncodeUTF8(FwNoAccent(cLog))
			Else
				oWsOut:ITENS[nItem]:RETSTATUS  := EncodeUTF8('E')
				If nItemErr > 0 .and. nItemErr <> nItem
					oWsOut:ITENS[nItem]:RETMSG     := EncodeUTF8(FwNoAccent("Nao processado. Erro na linha com a chave XRT " + oWSIn:ITENS[nItemErr]:CT2_XCDXRT))
				Else
					oWsOut:ITENS[nItem]:RETMSG     := EncodeUTF8(FwNoAccent(cLog))
				Endif
			Endif
			oWsOut:ITENS[nItem]:CT2_XCDXRT := EncodeUTF8(oWSIn:ITENS[nItem]:CT2_XCDXRT)
		Next nItem
	Endif

	//Grava o Log - Sucesso ou falha
	//U_F07LOG02(nRLogP19, cLog, lSucesso, cTab, nIndOrd, cIndKey)

Return Nil


/*/{Protheus.doc} CtlErrEx

Controle de erro

@type       function
@author     fabio.cazarini
@since      22/06/2021
@param      oErroArq, object, Objeto com o erro
/*/
Static Function CtlErrEx(oErroArq)
	Local nI := 2

	If oErroArq:GenCode > 0
		cErroRot := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + " | "
	EndIf
	Do While (!Empty(ProcName(ni)))
		cErroRot += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") | "
		ni ++
	EndDo
	If Intransact()
		cErroRot += "Transacao desarmada | "
		Disarmtransaction()
	EndIf
	BREAK

Return Nil

/*/{Protheus.doc} GrvXmlVaz
    Grava o XML vazio caso estoure timeout
    @type  Static Function
    @author Gianluca Moreira
    @since 24/05/2021
    /*/
Static Function GrvXmlVaz(oWsOut)
	Local nUlt := 0

	AAdd(oWsOut:ITENS, WSClassNew('W20005RETIt'))
	nUlt := Len(oWsOut:ITENS)
	oWsOut:ITENS[nUlt]:RETSTATUS  := EncodeUTF8('')
	oWsOut:ITENS[nUlt]:RETMSG     := EncodeUTF8('')
	oWsOut:ITENS[nUlt]:CT2_XCDXRT := EncodeUTF8('')
Return
