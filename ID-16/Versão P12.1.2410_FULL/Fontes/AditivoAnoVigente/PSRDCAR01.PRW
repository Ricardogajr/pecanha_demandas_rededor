#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} PSFGeraSP
description Rotina responsável por gerar a SP.
@author  Ricardo Junior	
@since   01/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
user function RDCAR01() 
	Private aRet := {}

	if !fPergunt()
		Return
	endif

	Processa( {|| geraSP() }, "Aguarde...", "Gerando registros...",.F.)
Return
Static function geraSP()
	Local aArea  	:= GetArea()
	Local aCabec 	:= {}
	Local aItem  	:= {}
	Local nOpc	 	:= 3
	Local cAliasSE2 := GetNextAlias()
	Local cQuery 	:= ""
	Local nTotal 	:= 0
	local aError 	:= {}
	local _nJuros 	:=  0
	local _nDescres :=  0
	local _nMulta 	:=  0
	local _nTotValor:=  0
	Local cXCondSP	:=SuperGetMV("MV_XCONDSP",, "001")
	Local cXTPRIMP:=Padr(SuperGetMv("MV_XTPRIMP",,"HML"), TamSx3("C7_XTIPO")[01])
	Local cXPRDEST:=superGetMV("MV_XPRDEST",,"")
	Private cDirLog := "\SIGADOC\KITMIGRACAO\LOGS\"//SuperGetMV("MV_XDIRSP",,"C:\temp\log")
	Private dDtBKP := ""//Lucas Miranda de Aguiar - Melhoria data Fixa
	Private lChange := .T.//Lucas Miranda de Aguiar - Melhoria data Fixa
	
	cDataDe := DToS(aRet[1])
	cDataAte := DToS(aRet[2])

	if Empty(cDataDe) .Or. Empty(cDataAte)
		Alert("As datas não estão preenchidas")
		Return
	endif

	cQuery += " SELECT SE2.E2_FILIAL,SE2.E2_FORNECE,SE2.E2_LOJA,SE2.E2_PREFIXO,SE2.E2_NUM  FROM "+RetSqlName("SE2")+" SE2 " + CRLF
	cQuery += " WHERE E2_XMIGLT != ' '  			" + CRLF
	cQuery += " AND E2_FILIAL  = '"+cFilAnt+"'  	" + CRLF
	cQuery += " AND SE2.D_E_L_E_T_ = ' '  			" + CRLF
	cQuery += " AND E2_FILIAL||E2_NUM||E2_PREFIXO||E2_FORNECE||E2_LOJA NOT IN  " + CRLF
	cQuery += " (SELECT C7_FILIAL||C7_XDOC||C7_XSERIE||C7_FORNECE||C7_LOJA FROM "+RetSqlName("SC7")+" SC7P  " + CRLF
	cQuery += " WHERE SC7P.D_E_L_E_T_   = ' ' 		" + CRLF
	cQuery += " AND SC7P.C7_FILIAL = SE2.E2_FILIAL 	" + CRLF
	cQuery += " AND SC7P.C7_XDOC   = SE2.E2_NUM 	" + CRLF
	cQuery += " AND SC7P.C7_XSERIE = SE2.E2_PREFIXO " + CRLF
	cQuery += " AND SC7P.C7_FORNECE= SE2.E2_FORNECE " + CRLF
	cQuery += " AND SC7P.C7_LOJA   = SE2.E2_LOJA) 	" + CRLF
	cQuery += " AND E2_BAIXA       = ' ' 			" + CRLF
	cQuery += " GROUP BY SE2.E2_FILIAL,SE2.E2_NUM, SE2.E2_PREFIXO, SE2.E2_FORNECE, SE2.E2_LOJA " + CRLF
	cQuery += " ORDER BY SE2.E2_FILIAL,SE2.E2_NUM, SE2.E2_PREFIXO, SE2.E2_FORNECE, SE2.E2_LOJA " + CRLF

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSE2, .T., .T.)
	Count To nTotal

	ProcRegua(nTotal)
	(cAliasSE2)->(DbGoTop())

	if (cAliasSE2)->(Eof())
		MsgInfo("Não foram encontrados registros !")
		Return
	endif

	if !MsgYesNo('Foram encontrados '+ cValToChar(nTotal) +' titulos migrados em aberto. Deseja confirmar a geração da Solicitação de pagamento?', 'PSRDCAR01' )
		Return
	endif

	While (cAliasSE2)->(!Eof())
		Incproc("Numero do titulo: " + (cAliasSE2)->E2_NUM)

		lBloqueia   := .F.
		DbSelectArea("SE2")
		SE2->(DbSetOrder(06))
		cChave := (cAliasSE2)->E2_FILIAL+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM
		If SE2->(DbSeek(cChave))
			aAdd(aCabec, {"C7_EMISSAO", SE2->E2_EMISSAO, Nil})
			aAdd(aCabec, {"C7_FORNECE", SE2->E2_FORNECE, Nil})
			aAdd(aCabec, {"C7_LOJA"   , SE2->E2_LOJA,    Nil})
			aAdd(aCabec, {"C7_COND"   , cXCondSP, Nil})
			AAdd(aCabec, {"C7_XTIPO",   cXTPRIMP, Nil})
			AAdd(aCabec, {"C7_XESPECI", PadR("NF", TamSx3("C7_XESPECI")[1]), Nil})
			AAdd(aCabec, {"C7_XTPSP",   "2",            Nil})
			AAdd(aCabec, {"C7_XDOC", 	SE2->E2_NUM,     Nil})
			AAdd(aCabec, {"C7_XSERIE" , SE2->E2_PREFIXO, Nil})
			AAdd(aCabec, {"C7_XDTEMI" , SE2->E2_EMISSAO, Nil})
			AAdd(aCabec, {"C7_XDTVEN" , SE2->E2_VENCREA, Nil})
			AAdd(aCabec, {"C7_XNATURE", SE2->E2_NATUREZ, Nil})
			AAdd(aCabec, {"C7_XRATSP" , "N" ,  Nil})

			cProduto := cXPRDEST
			AAdd(aItem, {"C7_ITEM"	 , "0001", 	 Nil})
			AAdd(aItem, {"C7_PRODUTO", cProduto, Nil})
			AAdd(aItem, {"C7_UM" 	 , "UN",     Nil})
			AAdd(aItem, {"C7_QUANT"  , 1,        Nil})
			AAdd(aItem, {"C7_LOCAL"  , "PADRAO",           	    Nil})
			AAdd(aItem, {"C7_OBS" 	 , "SP GERADA APARTIR DO TITULO DE CARGA", Nil})
			AAdd(aItem, {"C7_CC"	 , SE2->E2_CCUSTO,	Nil})//PadR((cAliasSE2)->E2_CCD, 					TamSx3("C7_CC")[01]),  Nil})
	
			While SE2->(!Eof()) .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == cChave
				if (DToS(SE2->E2_VENCREA) < cDataDe .Or. DToS(SE2->E2_VENCREA) > cDataAte) .And. Empty(E2_BAIXA) .And. !lBloqueia
				//if (DToS(SE2->E2_VENCREA) > cDataDe) .And. Empty(E2_BAIXA) .And. !lBloqueia
					lBloqueia := .T.
				endif
				_nJuros 	+= SE2->E2_JUROS
				_nDescres 	+= SE2->E2_DECRESC
				_nMulta 	+= SE2->E2_MULTA
				_nTotValor 	+= SE2->E2_VALOR
				SE2->(DbSkip())
			EndDo
		Endif
		AAdd(aItem, {"C7_PRECO"  , _nTotValor,   Nil})
		AAdd(aItem, {"C7_TOTAL"  , _nTotValor,   Nil})
		AAdd(aItem, {"C7_XJURMUL", _nJuros,   Nil})
		AAdd(aItem, {"C7_XDESFIN", _nDescres, Nil})
		AAdd(aItem, {"C7_XMULTA" , _nMulta,  Nil})

		_nJuros 	:= 0
		_nDescres 	:= 0
		_nMulta 	:= 0
		_nTotValor 	:= 0

		aAdd(aError, U_RDCAR02(aCabec, aItem, nOpc, lBloqueia))

		aCabec := {}
		aItem  := {}
		(cAliasSE2)->(DbSkip())
	EndDo

	GeraLog(aError)

	MsgInfo("Rotina finalizada com sucesso! Arquivos gerados na pasta ["+cDirLog+"]")
	RestArea(aArea)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaDirMA
description cria estrutura de diretorios
@author  Ricardo Junior
@since   26/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function fCriaDirMA(cPath)

	if ExistDir( cPath )
		return
	else
		FWMakeDir( cPath, .T.)
	endif

return
//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLog
description Gerar arquivo de log
@author  Ricardo Junior
@since   26/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function GeraLog(aMessage)
	local cArqLog	:= "Log_" + FwTimeStamp(1) + ".txt"
	local cPath 	:= ""
	local nHandle  	:= 00
	local nX,nY		:= 00

	//fCriaDirMA(cDirLog)

	cPath := cDirLog + cArqLog

	nHandle := fcreate(cPath, 0)
	If nHandle  >= 0
		fWrite(nHandle, Replicate("#",71) +CRLF)
		fWrite(nHandle, "Data: " + FwTimeStamp(1) + CRLF )
		fWrite(nHandle, "Total Registros: " + cValToChar(Len(aMessage)) + CRLF )
		fWrite(nHandle, "Usuário: " + cUserName + CRLF )
		fWrite(nHandle, Replicate("#",71)+CRLF)
		For nY := 01 To Len(aMessage)
			for nX := 01 To Len(aMessage[nY])//Ultima posição do log
				if ValType(aMessage[nY][nX]) == "C"
					fWrite(nHandle, aMessage[nY][nX] + CRLF)
				endif
			Next nx
		next nY
	endif
	fclose(nHandle)
return


static Function fPergunt()

	Local aArea 	:= GetArea()
	Local aPergs 	:= {}
	Local dDataDe  	:= Date()
	Local dDataAte 	:= Date()

	aAdd(aPergs, {1, "Data Vencimento DE?",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Vencimento ATE?",  dDataAte,  "", ".T.", "", ".T.", 80,  .F.})

	If !ParamBox(aPergs ,"Carga M&A",aRet)
		Return(.F.)
	Endif
	RestArea(aArea)
Return .T.

Static Function fBuscaSC7(cFil, cDoc, cSerie, cFornece, cLoja)
	Local cAliasSC7 := GetNextAlias()
	Local cQuery    := ""
	Local lRet	    := .F.

	cQuery += " SELECT R_E_C_N_O_"
	cQuery += " FROM " + RetSqlName("SC7")
	cQuery += " WHERE C7_FILIAL = '"+cFil+"'
	cQuery += " AND C7_XDOC  = '" + cDoc + "'"
	cQuery += " AND C7_XSERIE  = '" + cSerie + "'"
	cQuery += " AND C7_FORNECE = '" + cFornece + "'"
	cQuery += " AND C7_LOJA    = '" + cLoja + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSC7, .T., .T.)

	If (cAliasSC7)->(R_E_C_N_O_) > 0
		SC7->(DbGoTo((cAliasSC7)->(R_E_C_N_O_)))
		lRet := .T.
	EndIf

	(cAliasSC7)->(DbCloseArea())
Return lRet
