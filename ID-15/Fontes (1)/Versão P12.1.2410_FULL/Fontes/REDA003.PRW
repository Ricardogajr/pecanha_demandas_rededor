#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'TopConn.Ch' //Thais Paiva - 9474856
#Include 'Totvs.Ch' //Thais Paiva - 9474856

/*/{Protheus.doc} REDA003
//Rotina de eliminar residuo.
@author Ricardo
@since 08/06/2017
@version 1.0
@type function
/*/ 

User Function REDA003()

	Local aStru		:= {}
	Local aCpoBro 	:= {}
	Local cFilSc7	:= PadR(SC7->C7_FILIAL, TamSx3("C7_FILIAL")[01])
	Local cNum		:= PadR(SC7->C7_NUM, TamSx3("C7_NUM")[01])
	Local cArq      := ""
	Private lSemSCOri	:= .F.
	Private cMark   := GetMark()
	Private bMarkAll:= {|| REDA3MKALL() }
	Private bElimPed:= {|| Processa({|| fElimPed() }, "Aguarde...", "Gerando SC...",.F.) }
	Private lMsErroAuto := .F.
	Private lMsg		:= .F.
	Private aItens 		:= {}
	Private nRecno 		:= SC7->(Recno())
	Private cScs		:= ""

	aRotinaBkp := aRotina

	aRotina := {}

	If Aviso("Atenção", "Deseja eliminar residuo deste pedido de compras e gerar uma nova Solicitação de compras?", {"Sim", "Não"}) == 2
		Return
	ElseIf !Empty(SC7->C7_ENCER) .And. !Empty(SC7->C7_RESIDUO)
		Alert("Este pedido já foi eliminado por residuo e não poderá executar novamente esta rotina.")
		Return
		//ElseIf !Empty(SC7->C7_XIDBIO) .And. Empty(SC7->C7_ENCER) .And. Empty(SC7->C7_RESIDUO) .And. SC7->C7_QUJE != SC7->C7_QUANT
		//	Alert("Pedido Integrado com a Bionexo. Eliminaï¿½ï¿½o nï¿½o serï¿½ permitida!!")
		//	Return
	ElseIf SC7->C7_QUJE == SC7->C7_QUANT
		Alert("Este pedido já foi recebido e não poderá executar esta rotina.")
		Return
	ElseIf Empty(SC7->C7_NUMSC)
		If Aviso("Atenção", "Este pedido não tem uma solicitação de compras amarrada. Não será possivel eliminar residuos por esta rotina.", {"Ok"})
			Return
		EndIf
	ElseIf !Empty(SC7->C7_XIDEXNF)
		If Aviso("Atenção", "O documento " + SC7->C7_NUM + " é proveniente de devolução do mês fechado. Não será possivel eliminar residuos por esta rotina.", {"Ok"})
			Return
		EndIf
	ElseIf SC7->C7_CONAPRO == 'B'
		If Aviso("Atenção", "O documento " + SC7->C7_NUM + " está em processo de aprovação, a eliminação não é permitida. Use a rotina de exclusão", {"Ok"})
			Return
		EndIf
	EndIf

	aRotina   := {{ "Processar" ,"Eval(bElimPed)" , 0, 4}}

	aAdd(aStru,{"OK",			"C", 02		, 00})
	aAdd(aStru,{"C7_FILIAL",	"C", TamSx3("C7_FILIAL")[01], 00})
	aAdd(aStru,{"C7_NUM",		"C", TamSx3("C7_NUM")[01], 00})
	aAdd(aStru,{"C7_ITEM",		"C", TamSx3("C7_ITEM")[01], 00})
	aAdd(aStru,{"C7_PRODUTO",	"C", TamSx3("C7_PRODUTO")[01],00})
	aAdd(aStru,{"C7_DESCRI"	,	"C", 100,	00})
	aAdd(aStru,{"C7_UM",		"C", TamSx3("C7_UM")[01],	00})
	aAdd(aStru,{"C7_QUANT",		"N", TamSx3("C7_QUANT")[01], TamSx3("C7_QUANT")[02]})
	aAdd(aStru,{"C7_PRECO",		"N", TamSx3("C7_PRECO")[01], TamSx3("C7_PRECO")[02]})
	aAdd(aStru,{"C7_TOTAL",		"N", TamSx3("C7_TOTAL")[01], TamSx3("C7_TOTAL")[02]})
	aAdd(aStru,{"C7_NUMSC",		"C", TamSx3("C7_NUMSC")[01],00})
	aAdd(aStru,{"C7_ITEMSC",	"C", TamSx3("C7_ITEMSC")[01],00})
	aAdd(aStru,{"C7_LOCAL",		"C", TamSx3("C7_LOCAL")[01],00})
	aAdd(aStru,{"C7_CC",		"C", TamSx3("C7_CC")[01],00})

	//Início - Thais Paiva - Compatibilização P27
	//cArq := Criatrab( aStru, .T.)

	//DbUseArea(.T.,,cArq,"TTRB")
	oTempTable := FWTemporaryTable():New( "TTRB" )
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex( '01' , { "C7_FILIAL","C7_NUM","C7_ITEM" } )
	oTempTable:Create()

	cArq := oTempTable:GetRealName()
	//Fim - Thais Paiva - Compatibilização P27

	cChave := "C7_FILIAL+C7_NUM+C7_ITEM"

	//IndRegua("TTRB", cArq, cChave,,) - Thais Paiva

	DbSelectArea("SC7")
	SC7->(DbSetOrder(01))
	SC7->(DbGoTop())
	If DbSeek(cFilSc7 + cNum)
		DbSelectArea("TTRB")
		While  !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSc7	.And. SC7->C7_NUM == cNum
			If SC7->C7_QUJE < SC7->C7_QUANT .And. Empty(SC7->C7_ENCER) .And. Empty(SC7->C7_RESIDUO)
				RecLock("TTRB",.T.)
				TTRB->OK			:= ""
				TTRB->C7_FILIAL		:= SC7->C7_FILIAL
				TTRB->C7_NUM		:= SC7->C7_NUM
				TTRB->C7_ITEM		:= SC7->C7_ITEM
				TTRB->C7_PRODUTO	:= SC7->C7_PRODUTO
				TTRB->C7_DESCRI		:= Posicione("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_DESC")
				TTRB->C7_UM			:= SC7->C7_UM
				TTRB->C7_QUANT		:= SC7->C7_QUANT - SC7->C7_QUJE
				TTRB->C7_PRECO		:= SC7->C7_PRECO
				TTRB->C7_LOCAL		:= SC7->C7_LOCAL
				TTRB->C7_CC			:= SC7->C7_CC
				TTRB->C7_NUMSC		:= SC7->C7_NUMSC
				TTRB->C7_ITEMSC		:= SC7->C7_ITEMSC
				TTRB->(MsUnLock())
			EndIf
			SC7->(DbSkip())
		EndDo
	EndIf

	SC7->( DbGoTo(nRecno) )
	aCpoBro	:= {{ "OK",, 		  "",		"@!"},;
		{ "C7_NUM",,	"Código",	  "@!"},;
		{ "C7_ITEM",,	"Item",		  ""},;
		{ "C7_PRODUTO",,"Produto",	  "@!"},;
		{ "C7_DESCRI",,	"Descrição",  "@!"},;
		{ "C7_UM",,		"UM",		  "@!"},;
		{ "C7_QUANT",,	"Quantidade", "@E 999,999,999.99"},;
		{ "C7_PRECO",,	"Preco", 	  "@E 999,999,999.99"},;
		{ "C7_TOTAL",,	"Total", 	  "@E 999,999,999.99"},;
		{ "C7_NUMSC",,	"Numero SC",  "@!"},;
		{ "C7_ITEMSC",,	"Item SC", 	  "@!"}}

	DbSelectArea("TTRB")
	TTRB->(DbGoTop())

	MarkBrow("TTRB", "OK",,aCpoBro,.F., cMark,"U_REDA3MKALL()",,,,'U_REDA3MK()',,,,,,,,.F.)

	TTRB->(DbCloseArea())
	oTempTable:Delete() //Thais Paiva - 04/12/2020
	If File(cArq + GetDBExtension())
		FErase(cArq  + GetDBExtension())
	EndIf

	aRotina := aRotinaBkp
	U_WsLogBio("REDA003", 3)
Return
//------------------------------------------------------------------------
User Function REDA3MKALL()

	Local cMarkAux := ""

	DbSelectArea("TTRB")
	TTRB->(DbGotop())

	If Empty(TTRB->OK)
		cMarkAux := cMark
	EndIf

	While !TTRB->(Eof())
		RecLock("TTRB",.F.)
		TTRB->OK := cMarkAux
		TTRB->(MsUnlock())
		TTRB->(DbSkip())
	EndDo

Return

User Function REDA3MK()
	RecLock("TTRB",.F.)
	If Empty(TTRB->OK)
		TTRB->OK := cMark
	Else
		TTRB->OK := " "
	Endif
	TTRB->(MsUnlock())
Return
//---------------------------------------------------
Static Function fElimPed()

	Local cNumSc	:= ""
	Local cNumPc	:= ""
	Local cSeek		:= ""
	Local aPedidos:= {}

	cSeek := "!TTRB->(Eof()) .And. cNumSc == TTRB->C7_NUMSC"

	BEGIN TRANSACTION
		ProcRegua(TTRB->(RecCount()))
		TTRB->(DbGoTop())
		While !TTRB->(Eof())
			cNumSc := TTRB->C7_NUMSC
			cNumPc := TTRB->C7_NUM
			lValid := &(cSeek)
			While lValid
				If !Empty(TTRB->OK)
					incProc()
					aAdd(aPedidos, { 	TTRB->C7_FILIAL,;
						TTRB->C7_NUM,;
						TTRB->C7_ITEM,;
						TTRB->C7_NUMSC,;
						TTRB->C7_ITEMSC,;
						TTRB->C7_QUANT,;
						TTRB->C7_PRODUTO,;
						TTRB->C7_LOCAL,;
						TTRB->C7_CC})
				EndIf
				TTRB->(DbSkip())
				cNumSc := TTRB->C7_NUMSC
				lValid := &(cSeek)
			EndDo
			fGeraSC(aPedidos)
			aPedidos := {}
		EndDo

	END TRANSACTION

	If !lMsErroAuto
		U_F0702203(cNumPc, 8, 1, nRecno)
		Aviso("Atenção", iIf(Len(SubStr(cScs, 1, Len(cScs) - 02)) > 06, "Foram geradas as Solicitações de compras [ ", "Foi gerada a Solicitação de compras [ ") + SubStr(cScs, 1, Len(cScs) - 02) + " ]", {"Ok"})
	EndIf

	CloseBrowse()
Return .T.
//---------------------------------------------------
Static Function fGeraSC(aPedidos)

	Local aArea := GetArea()
	Local aCabec := {}
	Local aLinha := {}
	Local nX     := 00
	Local nY	 := 00
	Local lAux	 := .T.
	Local aAux   := {}
	Local cCodLocal := ""
	Local cCodCC	:= ""
	Local cSolic := ""
	Local _nM := 0 //Thais Paiva 9474856
	Local nZ := 0
	Local _cErr := ""
	Local _aErr := {}
	Local cUserOrig := ""
	Private lAutoErrNoFile:= .T.
	Private _aMsgErr := {} //Thais Paiva 9474856

	cNumSC := GetSX8Num("SC1","C1_NUM")


	aAdd(aCabec,{"C1_NUM"    , cNumSC})
	aAdd(aCabec,{"C1_EMISSAO", dDataBase})
	aItens := {}
	nTotalSC := 00
	For nX := 01 To Len(aPedidos)

		aLinha := {}

		cFilOri 	:= PadR(aPedidos[nX][1], TamSx3("C1_FILIAL")[01])
		cNumScOri 	:= PadR(aPedidos[nX][4], TamSx3("C1_NUM")[01])
		cItemScOri  := PadR(aPedidos[nX][5], TamSx3("C1_ITEM")[01])

		DbSelectArea("SC1")
		SC1->(DbSetOrder(01))
		If SC1->(DbSeek(cFilOri + cNumScOri + cItemScOri))
			If lAux
				cSolic := SC1->C1_SOLICIT
				cUserOrig := SC1->C1_USER
				aAdd(aCabec,{"C1_SOLICIT", cSolic })
				aAdd(aCabec,{"C1_USER", cUserOrig})
				lAux := .F.
			EndIf
			//cLocal := SC1->C1_LOCAL Thais Paiva - 9474856
			cLocal := FBuscaLoc(cFilOri,cNumScOri,SC1->C1_PRODUTO,SC1->C1_LOCAL)
			aAdd(aLinha,{"C1_ITEM"   , StrZero(nX, 4),	Nil})
			aAdd(aLinha,{"C1_PRODUTO", SC1->C1_PRODUTO,	Nil})
			aAdd(aLinha,{"C1_QUANT",   aPedidos[nX][6],	Nil})
			//aAdd(aLinha,{"C1_APROV",   "L",				Nil})
			aAdd(aLinha,{"C1_VUNIT",   SC1->C1_VUNIT,	Nil})
			aAdd(aLinha,{"C1_XTPSC",   SC1->C1_XTPSC,	Nil})
			aAdd(aLinha,{"C1_XMOTIVO", SC1->C1_XMOTIVO,	Nil})
			//aAdd(aLinha,{"C1_LOCAL",   PADR("0831", TamSx3("C1_LOCAL")[01]),	Nil})
			//aAdd(aLinha,{"C1_CC",	   "01030601001",		Nil})//Esse conteudo é fixo pois existem gatilhos que estão impactando o EXECAUTO. PONTO DE ENTRADA QUE CORRIGE ESSE VALOR É O RD_MT110GRV
			aAdd(aLinha,{"C1_CC",	   SC1->C1_CC,		Nil})
			aAdd(aLinha,{"C1_DESCRI",  SC1->C1_DESCRI,	Nil})
			aAdd(aLinha,{"C1_XPEDORI", aPedidos[nX][2],	Nil})
			aAdd(aLinha,{"C1_XIPCORI", aPedidos[nX][3],	Nil})
			aAdd(aLinha,{"C1_XSCORI",  cNumScOri,		Nil})
			aAdd(aLinha,{"C1_XITORI",  cItemScOri,		Nil})
			aAdd(aLinha,{"C1_LOCAL",   cLocal,	Nil}) //Thais Paiva - 9474856
			aAdd(aLinha,{"C1_USER", cUserOrig})
			/*
			If !Empty(SC1->C1_XCODSET)
				aAdd(aLinha,{"C1_LOCAL",   cLocal,	Nil})
				aAdd(aLinha,{"C1_XCODSET", SC1->C1_XCODSET,		Nil})
			EndIf
			*/
			nTotalSC += SC1->C1_VUNIT
			aAdd(aItens,aLinha)
		EndIf
	Next nX

	If Len(aItens) == 0
		Alert("A Solicitação não foi encontrada.")
		Return
	EndIf

	ConfirmSX8()

	DbSelectArea("NNR")
	DbSetOrder(01)
	DbSeek(xFilial("NNR")+PADR("0831", TamSx3("C1_LOCAL")[01]))

	cUserBkp  := cUserName
	cUserName := cSolic

	cCodUsrBkp:= __cUserId
	__cUserId := cUserOrig
	/*/PswOrder(2)
	If PswSeek(cSolic,.T.)
		_aUsr       := PswRet(1)
		__cUserId   := _aUsr[1][1]
	EndIf/*/

		MSExecAuto({|x,y| mata110(x,y)}, aCabec, aItens)
		cUserName := cUserBkp
		__cUserId := cCodUsrBkp
		cScs += cNumSC + ", "
		If !lMsErroAuto
			FLagPed(aPedidos, aItens, cNumSC)
			//Aprovação da SC caso seja bloqueada.
			SC1->(DbGoTop())
			lAProv := .F.
			If SC1->(DbSeek(xFilial("SC1")+cNumSC))
				While !SC1->(Eof()) .And. AllTrim(SC1->C1_NUM) == AllTrim(cNumSC)
					If AllTrim(SC1->C1_APROV) == "B"
						lAProv := .T.
						RecLock("SC1", .F.)
						SC1->C1_APROV := "L"
						SC1->(MsUnlock())
					EndIf
					RecLock("SC1", .F.)
					SC1->C1_XDATRES := StoD("")
					SC1->(MsUnlock())
					SC1->(DbSkip())
				EndDo
				If lAprov
					MaAlcDoc({cNumSC,"SC",0,SC1->C1_GRUPCOM,SC1->C1_USER,,,,,,},,4)
				EndIf
			EndIf
		Else
			//Mostraerro()
			_aErr := GetAutoGrLog()

			If Len(_aMsgErr) > 0 //Início Thais Paiva 9474856
				For _nM := 1 to Len(_aMsgErr)
					_cErr += _aMsgErr[_nM] + CRLF
				Next _nM
			EndIf //Fim Thais Paiva 9474856

			For nZ := 1 To Len(_aErr)
				//Início Thais Paiva 9474856
				If "INVALIDO" $ UPPER(_aErr[nZ]) .OR. "ERRO" $ UPPER(_aErr[nZ]) .OR. "INCONSISTENCIA" $ UPPER(_aErr[nZ])
					_cErr += _aErr[nZ] + CRLF
				EndIf
				//Fim Thais Paiva 9474856
			Next nZ

			//Alert("A Solicitação de compras não foi incluída.") Thais Paiva 9474856
			//Alert("Erro: " + _cErr ) 	Thais Paiva 9474856
			Alert("A Solicitação de compras não foi incluída."+CRLF+"Erro: " + _cErr )
		EndIf

		RestArea(aArea)
		Return

Static Function FLagPed(aPedidos, aItens, cDoc)

	Local nX	:= 00
	Local aArea := GetArea()

	DbSelectArea("SC7")
	SC7->(DbSetOrder(01))
	For nX := 01 To Len(aPedidos)
		If SC7->(DbSeek(aPedidos[nX][01]+aPedidos[nX][02]+aPedidos[nX][03]))
			RecLock("SC7", .F.)
			SC7->C7_ENCER 	:= "E"
			SC7->C7_RESIDUO	:= "S"
			SC7->C7_XSCRES	:= cDoc
			SC7->C7_XITRES  := aItens[nX][01][02]
			SC7->(MsUnlock())
		EndIf
	Next nX

	RestArea(aArea)
Return

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | FBuscaLoc | AUTORA| Thais Paiva              | DATA | 07/10/2021   |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Buscal Local do Estoque										   |//
//+--------------------------------------------------------------------------------+//
//| CHAMADO    | 9474856				 										   |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

Static Function FBuscaLoc(cFilSC, cNumSc, cProduto, cLocOri)
	Local _cLocEst := ""
	Local _aAreaLoc := GetArea()
	Local lRetLoc := .F.

	If !Empty(Alltrim(cLocOri))
		DbSelectArea("NNR")
		DbSetOrder(1)
		If DbSeek(cFilSC+cLocOri)
			If NNR->NNR_MSBLQL <> '1'
				_cLocEst := cLocOri
				lRetLoc := .T.
			EndIf
		EndIf
	EndIf

	If !lRetLoc
		DbSelectArea("SBZ")
		DbSetOrder(1)
		If DbSeek(cFilSC+cProduto)
			DbSelectArea("NNR")
			DbSetOrder(1)
			If DbSeek(SBZ->BZ_FILIAL+SBZ->BZ_LOCPAD)
				If NNR->NNR_MSBLQL <> '1'
					_cLocEst := NNR->NNR_CODIGO
					lRetLoc := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If !lRetLoc
		DbSelectArea("NNR")
		DbSetOrder(4)
		If DbSeek(cFilSC+"1")
			If NNR->NNR_MSBLQL <> '1'
				_cLocEst := NNR->NNR_CODIGO
				lRetLoc := .T.
			EndIf
		EndIf
	EndIf

	RestArea(_aAreaLoc)
Return _cLocEst
