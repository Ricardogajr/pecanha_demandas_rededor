#Include "Protheus.ch"

/*/{Protheus.doc} F1304301
Realiza a inclusão do Pedido de Compra com os produtos/quantidades obitidos através na nota fiscal de entrada.

@project    MAN0000007423048_EF_043
@@type      User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@param      aItens, array, itens da nota fiscal de entrada
@param      cNovIdInt, character, novo id de integração gerado para esta integração
@param      dData, date, data que a movimentação deverá ser realizada
@return     lOk, se a movimentação ocorreu com sucesso ou não
/*/
User Function F1304301(aItens, cNovIdInt, dData)

	Local aArea         := {}
	Local aItemPed      := {}
	Local aItensPed     := {} 
	Local aLog          := {}
	Local aPedido       := {}
	Local aItSC         := {}
	Local aSCNUM        := {}

	Local cCompGener    := ""
	Local cErro         := ""
	Local cGrpCompra    := ""

	Local lOk           := .T.

	Local nErro         := 0
	Local nItem         := 0

	Local nQtdLinha     := 0
	Local nTipo         := 0
	Local nZ            := 0
	Local nX := 1
	Local cPedSC7       := ""
	Local cCodUser      :=RetCodUsr()
	Local aValfre       := {}
	Private lMsErroAuto     := .F.

	Default aItens      := {}
	Default cNovIdInt   := ""
	Default dData       := GetMv("MV_ULMES") + 1

	aArea       := {FWGetArea(), SC7->(FWGetArea())}
	nQtdLinha   := Len(aItens)

	SC7->(DbSetOrder(1))
    /*
    aItens:
    1. SD1->D1_COD
    2. SD1->D1_QUANT
    3. SD1->D1_LOCAL
    4. SD1->D1_CC
    5. SD1->D1_DTDIGIT
    6. SD1->D1_CUSTO
    7. SD1->D1_PEDIDO
    8. SD1->D1_ITEMPC
    */
	cCompGener  := GetMv("FS_COMPGEN")
	cGrpCompra  := SY1->Y1_GRUPCOM //posicionado na rotina que chamou esta função

	For nItem := 1 To nQtdLinha
		If SC7->(DbSeek(FwXFilial("SC7") + aItens[nItem][7] + aItens[nItem][8]))
			If nItem == 1

				nTipo := SC7->C7_TIPO
				AAdd(aPedido, {"C7_FORNECE",    SC7->C7_FORNECE,    Nil})
				AAdd(aPedido, {"C7_LOJA",       SC7->C7_LOJA,       Nil})
				AAdd(aPedido, {"C7_COND",       SC7->C7_COND,       Nil})
				AAdd(aPedido, {"C7_FILENT",     SC7->C7_FILENT,     Nil})
				AAdd(aPedido, {"C7_COMPRA",     cCompGener,         Nil})
				AAdd(aPedido, {"C7_GRUPCOM",    cGrpCompra,         Nil})
				AAdd(aPedido, {"C7_USER",       cCodUser    ,       Nil})
				AAdd(aPedido, {"C7_CONTATO",    SC7->C7_CONTATO,    Nil})
				AAdd(aPedido, {"C7_EMISSAO",    dData,              Nil})
				AAdd(aPedido, {"C7_TPFRETE",    SC7->C7_TPFRETE,    Nil})
				AAdd(aPedido, {"C7_FRETE",      SC7->C7_FRETE,      Nil})
				AAdd(aPedido, {"C7_XIDEXNF",    cNovIdInt,          Nil})
				AAdd(aPedido, {"C7_CONAPRO",    "L",                Nil})
			EndIf

			aItemPed := {}

			AAdd(aItemPed, {"C7_ITEM",      StrZero(nItem, TamSX3("C7_ITEM")[1]),   Nil})
			AAdd(aItemPed, {"C7_PRODUTO",   SC7->C7_PRODUTO,                        Nil})
			AAdd(aItemPed, {"C7_QUANT",     aItens[nItem][2],                       Nil})
			AAdd(aItemPed, {"C7_PRECO",     SC7->C7_PRECO,                          Nil})
			//AAdd(aItemPed, {"C7_TOTAL",     SC7->C7_TOTAL,                          Nil})
			AAdd(aItemPed, {"C7_TES",       SC7->C7_TES,                            Nil})
			//AAdd(aItemPed, {"C7_RESIDUO",   SC7->C7_RESIDUO,                        Nil}) Thais Paiva - 10694451
			AAdd(aItemPed, {"C7_RESIDUO",   "",                        				Nil})
			AAdd(aItemPed, {"C7_UM",        SC7->C7_UM,                             Nil})
			//AAdd(aItemPed, {"C7_NUMSC",     SC7->C7_NUMSC,                          Nil})
			//AAdd(aItemPed, {"C7_ITEMSC",    SC7->C7_ITEMSC,                         Nil})
			AAdd(aItemPed, {"C7_LOCAL",     SC7->C7_LOCAL,                          Nil})
			AAdd(aItemPed, {"C7_OBS",       SC7->C7_OBS,                            Nil})
			AAdd(aItemPed, {"C7_DATPRF",    dData,                                  Nil})
			//AAdd(aItemPed, {"C7_DATPRF",    SC7->C7_EMISSAO,                        Nil})
			//AAdd(aItemPed, {"C7_DATPRF",    SC7->C7_DATPRF,                         Nil})
			AAdd(aItemPed, {"C7_CONAPRO",    "L",                                   Nil})
			AAdd(aItemPed, {"C7_XIDEXNF",   cNovIdInt,                              Nil})
			aAdd(aItemPed, {"C7_QTDSOL",	aItens[nItem][2], 						Nil})
			AAdd(aItemPed, {"C7_VLDESC",    SC7->C7_VLDESC,                         Nil}) //Thais Paiva - 10694451
			AAdd(aItemPed, {"C7_XDESFIN",   SC7->C7_XDESFIN,                        Nil}) //Thais Paiva - 10694451
			AADD(aValfre, {SC7->C7_VALFRE, SC7->C7_PRODUTO})
			AADD(aItSC,SC7->C7_ITEMSC)
			AADD(aSCNUM,SC7->C7_NUMSC)
			/// AJUSTE PARA AGLUTINAR OS MESMOS PRODUTOS EM UM ITEM APENAS NO PEDIDO [VALIDAÇÃO NÃO PERMITE ITENS REPETIDOS NUM MESMO PEDIDO]
			nAchou := 0
			nZ     := 0
			For nZ:= 1 To Len(aItensPed)
				nAchou := AScan(aItensPed[nZ], { |x| AllTrim(x[2]) == AllTrim(SC7->C7_PRODUTO)})
				IF nAchou > 0
					Exit
				Endif
			Next
			IF nAchou == 0
				AAdd(aItensPed, AClone(aItemPed))
			ElseIf nZ > 0
				aItensPed[nZ,3,nAchou] += aItens[nItem][2]
			Endif

			FwFreeObj(aItemPed)
			aItemPed := Nil
		EndIf
	Next nItem

	MsExecAuto({|tipo, cabec, itens, operacao| MATA120(tipo, cabec, itens, operacao)}, nTipo, aPedido, aItensPed, 3)

	If lMsErroAuto
		cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - Pedido de Compra | " + CRLF
		aLog := GetAutoGRLog()
		For nErro := 1 To Len(aLog)
			cErro += aLog[nErro] + CRLF
		Next nErro
		lOk := .F.
	Else
		cPedSC7 := SC7->C7_NUM
		If SC7->(DbSeek(FwXFilial("SC7") + cPedSC7 ))
			While SC7->(!(EoF())) .And. SC7->C7_FILIAL == FwXFilial("SC7") .And. SC7->C7_NUM == cPedSC7
				SC7->(Reclock("SC7",.F.))
				SC7->C7_USER := ""
				SC7->C7_VALFRE := aValFre[aScan(aValFre,{|x| x[2]== SC7->C7_PRODUTO}),1]
				If !Empty(aSCNUM) .And. !Empty(aItSC)
					SC7->C7_NUMSC := aSCNUM[nX]
					SC7->C7_ITEMSC := aItSC[nX]
				EndIf
				SC7->(MsUnlock())
				nX++
				SC7->(DBSkip())
			Enddo
		Endif
	EndIf

	If !(lOk)
		U_F1303703(cErro, .F.)
	EndIf

	AEval(aArea, {|area| RestArea(area)})

	FwFreeObj(aPedido)
	FwFreeObj(aItensPed)

	aPedido := Nil
	aItensPed := Nil

Return lOk
