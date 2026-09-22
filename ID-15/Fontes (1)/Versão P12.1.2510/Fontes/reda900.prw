#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'TopConn.Ch' 
#Include 'Totvs.Ch' 
/*/{Protheus.doc} REDA900

Transferir saldo de pedido de compra, que foi atendido parcial, para novo pedido com indica��o de um novo fornecedor

Help A120CONTR ao incluir um pedido de compra | Para solucionar essa ocorr�ncia � necess�rio alterar o campo B1_CONTRAT para N�o ou Ambos no Cadastro do Produto (MATA010) ou habilitar o par�metro MV_PRODCTR

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
User Function REDA900(cNvCodForn,cNvLojForn)
	Local aCpoBro          := {}
	Local aStru            := {}                                                                                                                           as array
	Local cArq             := ""                                                                                                                           as character
	Local cFilSc7          := PadR(SC7->C7_FILIAL, TamSx3("C7_FILIAL")[01])                                                                                as character
	Local cNomFornec       := ''                                                                                                                           as character
	Local cNum             := PadR(SC7->C7_NUM, TamSx3("C7_NUM")[01])                                                                                      as character
	Local cNumPCGerado     := ''                                                                                                                           as character
	Local lOk              := .T.                                                                                                                          as logical
	Private aItens         := {}                                                                                                                           as array
	Private bElimPed       :={|| Processa({|| fElimPed(cNvCodForn,cNvLojForn,@cNumPCGerado)}, "Aguarde...", "Gerando PC...",.F.)} as array
	Private bMarkAll       :={|| REDA9MKALL() }                                                                                                            as array
	Private cMark          := GetMark()                                                                                                                    as character
	Private cScs           := ""                                                                                                                           as character
	Private lAutoErrNoFile := .T.                                                                                                                          as logical //Se .t. desviava o fluxo da mensagem de erro que seria enviada para a fun��o MostraErro() para a vari�vel
	Private lMsErroAuto    := .F.                                                                                                                          as logical //necess�rio a cria��o, pois sera //atualizado quando houver
	Private lMsg           := .F.                                                                                                                          as logical
	Private lMsHelpAuto    := .T.                                                                                                                          as logical // se .t. direciona as mensagens de help para o arq. de log
	Private lSemSCOri      := .F.                                                                                                                          as logical
	Private nRecno         := SC7->(Recno())                                                                                                               as numeric
	Default cNvCodForn     := ''
	Default cNvLojForn     := ''

	aRotinaBkp := aRotina

	aRotina := {}

	lOk := !Empty(cNvCodForn) .And. !Empty(cNvLojForn)

	If lOk

		aRotina := {{ "Processar" ,"Eval(bElimPed)" , 0, 4}}

		aadd(aStru, {"OK"        , "C", 02                      , 00})
		aadd(aStru, {"C7_FILIAL" , "C", TamSx3("C7_FILIAL")[01] , 00})
		aadd(aStru, {"C7_NUM"    , "C", TamSx3("C7_NUM")[01]    , 00})
		aadd(aStru, {"C7_ITEM"   , "C", TamSx3("C7_ITEM")[01]   , 00})
		aadd(aStru, {"C7_PRODUTO", "C", TamSx3("C7_PRODUTO")[01], 00})
		aadd(aStru, {"C7_DESCRI" , "C", 100                     , 00})
		aadd(aStru, {"C7_UM"     , "C", TamSx3("C7_UM")[01]     , 00})
		aadd(aStru, {"C7_QUANT"  , "N", TamSx3("C7_QUANT")[01]  , TamSx3("C7_QUANT")[02]})
		aadd(aStru, {"C7_PRECO"  , "N", TamSx3("C7_PRECO")[01]  , TamSx3("C7_PRECO")[02]})
		aadd(aStru, {"C7_TOTAL"  , "N", TamSx3("C7_TOTAL")[01]  , TamSx3("C7_TOTAL")[02]})
		aadd(aStru, {"C7_NUMSC"  , "C", TamSx3("C7_NUMSC")[01]  , 00})
		aadd(aStru, {"C7_ITEMSC" , "C", TamSx3("C7_ITEMSC")[01] , 00})
		aadd(aStru, {"C7_LOCAL"  , "C", TamSx3("C7_LOCAL")[01]  , 00})
		aadd(aStru, {"C7_CC"     , "C", TamSx3("C7_CC")[01]     , 00})
		aadd(aStru, {"C7_FORNECE", "C", TamSx3("C7_FORNECE")[01], 00})
		aadd(aStru, {"C7_XNOMFOR", "C", TamSx3("C7_XNOMFOR")[01], 00})
		aadd(aStru, {"C7_LOJA"   , "C", TamSx3("C7_LOJA")[01]   , 00})

		oTempTable := FWTemporaryTable():New( "TTRB" )
		oTemptable:SetFields( aStru )
		oTempTable:AddIndex( '01' , { "C7_FILIAL","C7_NUM","C7_ITEM" } )
		oTempTable:Create()

		cArq := oTempTable:GetRealName()
		cChave := "C7_FILIAL+C7_NUM+C7_ITEM"

		DbSelectArea("SC7")
		SC7->(DbSetOrder(01))
		SC7->(DbGoTop())
		If DbSeek(cFilSc7 + cNum)
			DbSelectArea("TTRB")
			While !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSc7 .And. SC7->C7_NUM == cNum
				If SC7->C7_QUJE < SC7->C7_QUANT .And. Empty(SC7->C7_ENCER) .And. Empty(SC7->C7_RESIDUO)

					cNomFornec  := GetAdvFVal("SA2", "A2_NOME", FwXFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, 1, SC7->C7_XNOMFOR, .T.)

					RecLock("TTRB",.T.)
					TTRB->OK := ""
					TTRB->C7_FILIAL  := SC7->C7_FILIAL
					TTRB->C7_NUM     := SC7->C7_NUM
					TTRB->C7_ITEM    := SC7->C7_ITEM
					TTRB->C7_PRODUTO := SC7->C7_PRODUTO
					TTRB->C7_DESCRI  := Posicione("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_DESC")
					TTRB->C7_UM      := SC7->C7_UM
					TTRB->C7_QUANT   := SC7->C7_QUANT - SC7->C7_QUJE
					TTRB->C7_PRECO   := SC7->C7_PRECO
					TTRB->C7_TOTAL   := (SC7->C7_QUANT - SC7->C7_QUJE) * SC7->C7_PRECO
					TTRB->C7_LOCAL   := SC7->C7_LOCAL
					TTRB->C7_CC      := SC7->C7_CC
					TTRB->C7_NUMSC   := SC7->C7_NUMSC
					TTRB->C7_ITEMSC  := SC7->C7_ITEMSC
					TTRB->C7_FORNECE := cNvCodForn
					TTRB->C7_XNOMFOR := cNomFornec
					TTRB->C7_LOJA    := cNvLojForn
					TTRB->(MsUnLock())
				EndIf
				SC7->(DbSkip())
			EndDo
		EndIf

		SC7->( DbGoTo(nRecno) )
		aCpoBro :={{ "OK",, "", "@!"},;
		{"C7_NUM"         , , "Numero PC" , "@!"},;
		{"C7_ITEM"        , , "Item"      , ""},;
		{"C7_PRODUTO"     , , "Produto"   , "@!"},;
		{"C7_DESCRI"      , , "Descri��o" , "@!"},;
		{"C7_UM"          , , "UM"        , "@!"},;
		{"C7_QUANT"       , , "Quantidade", "@E 999,999,999.99"},;
		{"C7_PRECO"       , , "Preco"     , "@E 999,999,999.99"},;
		{"C7_TOTAL"       , , "Total"     , "@E 999,999,999.99"},;
		{"C7_NUMSC"       , , "Numero SC" , "@!"},;
		{"C7_ITEMSC"      , , "Item SC"   , "@!"},;
		{"C7_FORNECE"     , , "Fornecedor", "@!"},;
		{"C7_LOJA"        , , "Loja"      , "@!"}}

		DbSelectArea("TTRB")
		TTRB->(DbGoTop())

		MarkBrow("TTRB","OK",,aCpoBro,.F., cMark,"U_REDA9MKALL()",,,,'U_REDA9MK()',,,,,,,,.F.)

		TTRB->(DbCloseArea())
		oTempTable:Delete()
		If File(cArq + GetDBExtension())
			FErase(cArq + GetDBExtension())
		EndIf

		aRotina := aRotinaBkp

	EndIf

Return lOk
/*/{Protheus.doc} REDA9MKALL

Marcar e desmarcar

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
User Function REDA9MKALL()

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

	DbSelectArea("TTRB")
	TTRB->(DbGotop())

Return
/*/{Protheus.doc} REDA9MK

Marcar e desmarcar

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
User Function REDA9MK()
	RecLock("TTRB",.F.)
	If Empty(TTRB->OK)
		TTRB->OK := cMark
	Else
		TTRB->OK := " "
	Endif
	TTRB->(MsUnlock())
Return
/*/{Protheus.doc} fElimPed

Gerar pedido atraves da temporaria

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
Static Function fElimPed(cNvCodForn,cNvLojForn,cNumPcGerado)

	Local aPedidos       := {}  as array
	Local cNumPc         := ''  as character
	Local cNumSC         := ''  as character
	Local cSeek          := ''  as character
	Local lOk            := .T. as logical
	Default cNumPcGerado := ''
	Default cNvCodForn   := ''
	Default cNvLojForn   := ''

	cSeek := "!TTRB->(Eof()) .And. cNumPC == TTRB->C7_NUM"

	BEGIN TRANSACTION
		ProcRegua(TTRB->(RecCount()))
		TTRB->(DbGoTop())
		While !TTRB->(Eof())
			cNumSC := TTRB->C7_NUMSC
			cNumPc := TTRB->C7_NUM
			lValid := &(cSeek)
			While lValid
				If !Empty(TTRB->OK)
					incProc()
					aAdd(aPedidos, { TTRB->C7_FILIAL,;
					TTRB->C7_NUM,;
					TTRB->C7_ITEM,;
					TTRB->C7_NUMSC,;
					TTRB->C7_ITEMSC,;
					TTRB->C7_QUANT,;
					TTRB->C7_PRODUTO,;
					TTRB->C7_LOCAL,;
					TTRB->C7_CC,;
					TTRB->C7_FORNECE,;
					TTRB->C7_LOJA})
				EndIf
				TTRB->(DbSkip())
				cNumPc := TTRB->C7_NUM
				lValid := &(cSeek)
			EndDo
			If len(aPedidos) > 0
				U_f900Gera(aPedidos,cNvCodForn,cNvLojForn,@cNumPcGerado)
			Else
				FimProcess(3,cNumPCGerado,"Selecione pelo menos um item para gera��o do novo pedido, foram gerado(s) [0] pedido(s) para o novo fornecedor : " + Alltrim(cNvCodForn) + ' Loja:' + Alltrim(cNvLojForn) )
				lOk := .F.
				EXIT
			EndIf
			aPedidos := {}
		EndDo

	END TRANSACTION

	If lOk
		If !lMsErroAuto
			U_F0702203(cNumPc, 8, 1, nRecno)
			Aviso("Aten��o", iIf(Len(SubStr(cScs, 1, Len(cScs) - 02)) > 06, "Foram geradas as Pedidos de compras [ ", "Foi gerada a Pedido de compras [ ") + SubStr(cScs, 1, Len(cScs) - 02) + " ]", {"Ok"})
		EndIf
	EndIf

	CloseBrowse()
Return .T.
/*/{Protheus.doc} f900Gera

Gerar Pedido atraves da temporaria

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0
@param aPedidos, array, Lista de pedidos selecionados para gera��o do pedido
@param cNvCodForn, character, Novo fornecedor selecionado
@param cNvLojForn, character, Nova loja do fornecedor selecionado
@param cNumPcGerado, character, Novo numero de pedido de compras gerado

/*/
USER Function f900Gera(aPedidos,cNvCodForn,cNvLojForn,cNumPCGerado)
	Local aArea          := fwGetArea() as array
	Local aAreaSC1       := {}          as array
	Local aCabec         := {}          as array
	Local aErr           := {}          as array
	Local aItens         := {}          as array
	Local aLinha         := {}          as array
	Local cErr           := ''          as character
	Local cError         := ''          as character
	Local cItemScOri     := ''          as character
	Local cMensagem      := ''          as character
	Local cSCOriNum      := ''          as character
	Local cSolic         := ''          as character
	Local lAux           := .T.         as logical
	Local lCabec         := .T.         as logical
	Local lOk            := .T.         as logical
	Local nM             := 0           as numeric
	Local nOpc           := 3           as numeric
	Local nX             := 0           as numeric
	Local nZ             := 0           as numeric
	Private aMsgErr      := {}          as array
	Default aPedidos     := ''
	Default cNumPCGerado := ''
	Default cNvCodForn   := ''
	Default cNvLojForn   := ''

	If select( 'SC1' ) <= 0
		DBSELECTAREA( 'SC1' )
	EndIf
	aAreaSC1 := SC1->(fwGetArea())
	SC1->(DbSetOrder(6)) // C1_FILIAL + C1_PEDIDO + C1_ITEMPED + C1_PRODUTO	Num. Pedido + Item Pedido + Produto

	For nX := 1 To Len(aPedidos)

		aLinha := {}

		cFilOri    := PadR(aPedidos[nX][1], TamSx3("C7_FILIAL")[01])
		cNumPCOri  := PadR(aPedidos[nX][2], TamSx3("C7_NUM")[01])
		cItemPcOri := PadR(aPedidos[nX][3], TamSx3("C7_ITEM")[01])

		DbSelectArea("SC7")
		SC7->(DbSetOrder(01)) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
		If SC7->(DbSeek(cFilOri + cNumPCOri + cItemPcOri))

			If SC1->(DbSeek(SC7->C7_FILIAL + SC7->C7_NUM + SC7->C7_ITEM + SC7->C7_PRODUTO)) 
				cSCOriNum := SC1->C1_NUM
				cItemScOri := SC1->C1_ITEM
			Else
				cSCOriNum := SC7->C7_NUMSC
			EndIf

			If lAux
				cSolic := SC7->C7_SOLICIT
				aAdd(aCabec,{"C7_SOLICIT", cSolic })
				lAux := .F.
			EndIf
			If lCabec
				lCabec := .F.  // Cabe�alho montado
				cNumPC := GetNextNum()
				aadd(aCabec, {"C7_NUM"    , cNumPC         , Nil})
				aadd(aCabec, {"C7_EMISSAO", dDataBase      , Nil}) // Data de Emissao
				aadd(aCabec, {"C7_FORNECE", cNvCodForn     , Nil}) // Fornecedor
				aadd(aCabec, {"C7_LOJA"   , cNvLojForn     , Nil}) // Loja do Fornecedor
				aadd(aCabec, {"C7_CONTATO", SC7->C7_CONTATO, Nil}) // Contato
				aadd(aCabec, {"C7_COND"   , SC7->C7_COND   , Nil}) // Condicao de Pagamento
				aadd(aCabec, {"C7_FILENT" , SC7->C7_FILENT , Nil}) // Filial de Entrega
				aadd(aCabec, {"C7_FRETE"  , SC7->C7_FRETE  , Nil})
				aadd(aCabec, {"C7_DESPESA", SC7->C7_DESPESA, Nil})
				aadd(aCabec, {"C7_SEGURO" , SC7->C7_SEGURO , Nil})
				aadd(aCabec, {"C7_DESC1"  , SC7->C7_DESC1  , Nil})
				aadd(aCabec, {"C7_DESC2"  , SC7->C7_DESC2  , Nil})
				aadd(aCabec, {"C7_DESC3"  , SC7->C7_DESC3  , Nil})
				aadd(aCabec, {"C7_MSG"    , SC7->C7_MSG    , Nil})
				aadd(aCabec, {"C7_REAJUST", SC7->C7_REAJUST, Nil})
				aadd(aCabec, {"C7_COMPRA" , SC7->C7_COMPRA , Nil})
				aadd(aCabec, {"C7_GRUPCOM", SC7->C7_GRUPCOM, Nil})
				aadd(aCabec, {"C7_USER"   , RetCodUr()    , Nil})
				aadd(aCabec, {"C7_TPFRETE", SC7->C7_TPFRETE, Nil})
			EndIf

			cLocal := FBuscaLoc(cFilOri,cNumPCOri,SC7->C7_PRODUTO,SC7->C7_LOCAL)
			aadd(aLinha, {"C7_XPEDORI", aPedidos[nX][2]                             , Nil}) //Pedido de Origem
			aadd(aLinha, {"C7_XITORI" , cItemPcOri                                  , Nil}) //item de PC origem
			aadd(aLinha, {"C7_XORIMED", SC7->C7_MEDICAO                             , Nil}) //Medi��o de origem
			aadd(aLinha, {"C7_XITEMED", SC7->C7_ITEMED                              , Nil}) //Item Medi��o de origem
			aadd(aLinha, {"C7_XIPCORI", aPedidos[nX][3]                             , Nil})
			aadd(aLinha, {"C7_XSCORI" , cSCOriNum                                   , Nil})
			aadd(aLinha, {"C7_ITEM"   , StrZero(nX, 4)                              , Nil})
			aadd(aLinha, {"C7_PRODUTO", SC7->C7_PRODUTO                             , Nil})
			aadd(aLinha, {"C7_QUANT"  , aPedidos[nX][6]                             , Nil})
			aadd(aLinha, {"C7_DATPRF" , dDataBase                              		, Nil})
			aadd(aLinha, {"C7_UM"     , SC7->C7_UM                                  , Nil})
			aadd(aLinha, {"C7_PRECO"  , SC7->C7_PRECO                               , Nil})
			aadd(aLinha, {"C7_TOTAL"  , aPedidos[nX][6]*SC7->C7_PRECO               , Nil})
			aadd(aLinha, {"C7_NUMSC"  , cSCOriNum                             		, Nil}) 
			aadd(aLinha, {"C7_CC"     , SC7->C7_CC                                  , Nil})
			aadd(aLinha, {"C7_DESCRI" , SC7->C7_DESCRI                              , Nil})
			aadd(aLinha, {"C7_LOCAL"  , cLocal                                      , Nil})
			aadd(aLinha, {"C7_ITEMSC" , cItemScOri                                  , Nil})
			aadd(aLinha, {"C7_OBS"    , SC7->C7_OBS                                 , Nil})
			aadd(aLinha, {"C7_TES"    , SC7->C7_TES                                 , Nil})
			aadd(aLinha, {"C7_RESIDUO", SC7->C7_RESIDUO                             , Nil})

			aadd(aItens,aLinha)

		EndIf
	Next nX

	If Len(aItens) == 0
		FimProcess(2,cNumPCGerado,"O Pedido nao foi encontrado.")
		lOk := .F.
	EndIf

	If lOk

		DbSelectArea("NNR")
		DbSetOrder(01)
		DbSeek(xFilial("NNR")+PADR(cLocal, TamSx3("C7_LOCAL")[01]))

		cUserBkp := cUserName
		cUserName := cSolic

		cCodUsrBkp:= __cUserId
		PswOrder(2)

		If !Empty(cSolic) // S� troca se o usu�rio da C7_SOLICIT estiver preenchido
			If PswSeek(cSolic,.T.)
				aUsr := PswRet(1)
				cUserId := aUsr[1][1]
			EndIf
		EndIf

		lAutoErrNoFile := .F.//Se .t. desviava o fluxo da mensagem de erro que seria enviada para a fun��o MostraErro() para a vari�vel
		lMsErroAuto    := .F.//necess�rio a cria��o, pois sera //atualizado quando houver
		lMsHelpAuto    := .T.//se .t. direciona as mensagens de help para o arq. de log

		MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCabec,aItens,nOpc,.F.) // 3- INclusao - Gera��o de um novo pedido
		cUserName := cUserBkp
		cUserId := cCodUsrBkp
		cScs += cNumPC + ", "
		If !lMsErroAuto
			ConfirmSX8()
			cNumPCGerado := SC7->C7_NUM
			FLagPed(aPedidos, aItens, cNumPC)
			//Aprova��o da SC caso seja bloqueada.
			// Pedido deve nascer com legenda Verde C7_QUJE==0 .And. C7_QTDACLA==0.And.Empty(C7_RESIDUO).AND.Empty(C7_CONTRA).AND. C7_CONAPRO<>'B'
			SC7->(DbGoTop())
			lAProv := .F.
			If SC7->(DbSeek(xFilial("SC7")+cNumPC))
				While !SC7->(Eof()) .And. AllTrim(SC7->C7_NUM) == AllTrim(cNumPC)
					If AllTrim(SC7->C7_CONAPRO) == "B"
						lAProv := .T.
						RecLock("SC7", .F.)
						SC7->C7_CONAPRO := "L"
						SC7->(MsUnlock())
					EndIf
					SC7->(DbSkip())
				EndDo
				If lAprov
					MaAlcDoc({cNumPC,"SC",0,SC7->C7_GRUPCOM,SC7->C7_USER,,,,,,},,4)
				EndIf
			EndIf

			DeletSCR(cNumPCGerado) 	//Exclui Documentos com Alcada
			DeletSCY(cNumPCGerado)	//Exclui Historico Pedidos de Compras
			FimProcess(1,cNumPCGerado)

		Else
			RollBackSX8()

			If lMsHelpAuto
				If (!IsBlind()) // COM INTERFACE GR�FICA
					MostraErro() // TELA
				Else // EM ESTADO DE JOB
					cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
					cMensagem := PadC("Automatic routine ended with error", 80)
					FWLogMsg("ERROR", "LAST", "COM", ProcName(2), , "00", cMensagem , , , {}, 2)
					FWLogMsg("ERROR", "LAST", "COM", ProcName(2), , "00", "Error: "+ cError , , , {}, 2)
				EndIf

			Else
				aErr := GetAutoGrLog()

				If Len(aMsgErr) > 0
					For nM := 1 to Len(aMsgErr)
						cErr += aMsgErr[nM] + CRLF
					Next nM
				EndIf

				For nZ := 1 To Len(aErr)
					If "INVALIDO" $ UPPER(aErr[nZ]) .OR. "ERRO" $ UPPER(aErr[nZ]) .OR. "INCONSISTENCIA" $ UPPER(aErr[nZ])
						cErr += aErr[nZ] + CRLF
					Else
						cErr := ArrTokStr(aErr)
					EndIf
				Next nZ
				Alert("O Pedido de compras n�o foi inclu�da."+CRLF+"Erro: " + cErr )
			EndIf

		EndIf

	EndIf

	fWRestArea(aArea)
Return lOk
/*/{Protheus.doc} RetCodUr

	Busca o usu�rio logado

	@type function user
	@author Cleiton Genuino da Silva
	@since 24/08/2023
	@version 1.0

/*/
Static Function RetCodUr()
return RetCodUsr()
/*/{Protheus.doc} FLagPed

Flegando pedido marcando como residuo

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
Static Function FLagPed(aPedidos, aItens, cDoc)

	Local aArea := fwGetArea() as array
	Local nX    := 00        as numeric

	DbSelectArea("SC7")
	SC7->(DbSetOrder(01))
	For nX := 01 To Len(aPedidos)
		If SC7->(DbSeek(aPedidos[nX][01]+aPedidos[nX][02]+aPedidos[nX][03]))
			RecLock("SC7", .F.)
			SC7->C7_ENCER := "E"
			SC7->C7_RESIDUO := "S"
			SC7->C7_XSCRES := cDoc
			SC7->C7_XITRES := aItens[nX][01][02]
			SC7->(MsUnlock())
		EndIf
	Next nX

	fwrestarea(aArea)
Return
/*/{Protheus.doc} FBuscaLoc

Busca Local do Estoque	

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
Static Function FBuscaLoc(cFilSC, cNumPC, cProduto, cLocOri)
	Local aAreaLoc := fwGetArea() as array
	Local cLocEst  := ""        as character
	Local lRetLoc  := .F.       as logical

	If !Empty(Alltrim(cLocOri))
		DbSelectArea("NNR")
		DbSetOrder(1)
		If DbSeek(cFilSC+cLocOri)
			If NNR->NNR_MSBLQL <> '1'
				cLocEst := cLocOri
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
					cLocEst := NNR->NNR_CODIGO
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
				cLocEst := NNR->NNR_CODIGO
				lRetLoc := .T.
			EndIf
		EndIf
	EndIf

	fwrestarea(aAreaLoc)
Return cLocEst
/*/{Protheus.doc} GetNextNum

Retorna o proximo numero valido na SC7

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0

/*/
Static Function GetNextNum()
	Local aArea  := fwGetArea() as array
	Local cNumPC := ''        as character

	DbSelectArea("SC7")
	SC7->(DbSetOrder(01)) // C7_FILIAL + C7_NUM

	cNumPC := GetSX8Num("SC7","C7_NUM")

	While SC7->(dbSeek(xFilial("SC7")+ PadR( cNumPC , TamSx3('C7_NUM')[1] ) ))
		ConfirmSX8()
		cNumPC := GetSX8Num("SC7","C7_NUM")
	EndDo

	fwrestarea(aArea)

Return cNumPC
/*/{Protheus.doc} DeletSCR
	
	Exclui Documentos com Alcada

	@type function user
	@author Cleiton Genuino da Silva
	@since 28/06/2023
	@version 1.0
	@param cPedido, character, Pedido gerado pela transaferencia de fornecedor

/*/
Static Function DeletSCR(cNumPedido)
	Local aArea        := fwGetArea()        as array
	Local aAreaSCR     := SCR->(fwGetArea()) as array
	Local lOk          := .F.              as logical
	Default cNumPedido := ""

	DbSelectArea("SCR")
	SCR->(DbSetOrder(1)) // CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL
	If SCR->(DbSeek(FWxFilial("SCR") + "PC" + cNumPedido))
		While SCR->(!(EoF())) .And. SCR->CR_FILIAL == FWxFilial("SCR") .And. SCR->CR_TIPO == "PC" .And. Alltrim(SCR->CR_NUM) == Alltrim(cNumPedido)
			If RecLock("SCR", .F.)
				SCR->(DbDelete())
				SCR->(MsUnLock())
				SCR->(DbSkip())
			EndIf
		End
		lOk := .T.
	EndIf

	fwrestarea(aArea)
	fwrestarea(aAreaSCR)

Return lOk
/*/{Protheus.doc} DeletSCY
	
	Verifica se existe vers�o do PC no hist�rico de altera��es (SCY) e exclui.

	@type function user
	@author Cleiton Genuino da Silva
	@since 28/06/2023
	@version 1.0
	@param cPedido, character, Pedido gerado pela transaferencia de fornecedor

/*/
Static Function DeletSCY(cNumPedido)
	Local aArea        := fwGetArea()        as array
	Local aAreaSCY     := SCY->(fwGetArea()) as array
	Local lOk          := .F.              as logical
	Default cNumPedido := ""

	DbSelectArea("SCY")
	SCY->(DbSetOrder(1)) // CY_FILIAL + CY_NUM + CY_ITEM + CY_VERSAO + CY_SEQUEN
	If SCY->(DbSeek(XFilial("SCY") + cNumPedido)) 
		While SCR->(!(EoF())) .And. SCY->CY_FILIAL == FWxFilial("SCY") .And. Alltrim(SCY->CY_NUM) == Alltrim(cNumPedido)
			If Reclock("SCY", .F.)
				SCY->(DbDelete())
				SCY->(MsUnlock())
				SCY->(DbSkip())
			EndIf
		End
		lOk := .T.
	EndIf

	fwrestarea(aArea)
	fwrestarea(aAreaSCY)

Return lOk
/*/{Protheus.doc} FimProcess

Alerta do fim da execu��o

@type function user
@author Cleiton Genuino da Silva
@since 28/06/2023
@version 1.0
@param cPedido, character, Pedido gerado pela transaferencia de fornecedor

/*/
Static Function FimProcess(nMsg,cPedido,cMensagem)
	Local lok := .T. as logical 
	Default cMensagem := ''
	Default cPedido   := ''
	Default nMsg   	  := 1

	If !Empty(cPedido) .And. nMsg == 1
		FWAlertSuccess("Gerado com sucesso", "Foi gerado o pedido de compra com sucesso : " + cPedido + CRLF + cMensagem)
	EndIf

	If nMsg == 2
		FWAlertError("Erro de execu��o", "Verifique : "  + CRLF + cMensagem)
	EndIf

	If nMsg == 3
		FWAlertWarning("Alerta de uso", "Verifique : "  + CRLF + cMensagem)
	EndIf

Return lOk 
