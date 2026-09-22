#Include "Protheus.ch"

/*/{Protheus.doc} F1304201
Realiza a movimentação interna para efetuar as saídas dos produtos da nota fiscal.

@project    MAN0000007423048_EF_042
@@type      User Function
@author     Rafael Riego
@since      10/05/2018 
@version    12.1.7
@param      aItens, array, itens da nota fiscal de entrada
@param      cNovIdInt, character, novo id de integração gerado para esta integração
@param      dData, date, data que a movimentação deverá ser realizada
@param      nSF1Recno, numeric, recno do registro da tabela SF1
@return     lOk, se a movimentação ocorreu com sucesso ou não
/*/
User Function F1304201(aItens, cNovIdInt, dData, nSF1Recno, cDocNum)

	Local aArea         := {}
	Local aLog          := {}
	Local aMovimento    := {}

	Local cErro         := ""
	Local cTipoMov      := ""

	Local lCustoZero    := .F.
	Local lOk           := .T.

	Local nErro         := 0
	Local nItem         := 0
	Local nQtdLinha     := 0
	Local _atotitem ,_aCab1

	Private lMsErroAuto     := .F.

	Default aItens      := {}
	Default cNovIdInt   := ""
	Default dData       := GetMv("MV_ULMES") + 1
	Default nSF1Recno   := 0
	Default cDocNum     := ""

	cTipoMov    := GetMv("FS_TMSAIAS")

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

	aArea := {GetArea(), SD3->(GetArea()), SF5->(GetArea()), SF1->(GetArea())}

	If !(Empty(cTipoMov))
		nQtdLinha := Len(aItens)

		SF5->(DbSetOrder(1))
		If !(SF5->(DbSeek(FwXFilial("SF5") + cTipoMov)))
			cErro := "Tipo de Movimento " + cTipoMov + " não cadastrado."
			lOk := .F.
		ElseIf SF5->F5_TIPO <> "R"
			cErro := cTipoMov + " não é um Tipo de Movimento de Saída."
			lOk := .F.
		EndIf

		If lOk
			If nSF1Recno <> 0
				SF1->(DbGoTo(nSF1Recno))
			EndIf
			For nItem := 1 To nQtdLinha
				aMovimento := {}

				//Verifica se neste trecho deve ser verificado a cada interação do laço
				If aItens[nItem][6] == 0 .And. SF5->F5_VAL == "S"
					lCustoZero := .T.
					If Empty(SF5->F5_XTMNVAL)
						lOk := .F.
						cErro := "Tipo de Movimento não valorizado não informado para o TM " + cTipoMov + "."
					Else
						cTipoMov := SF5->F5_XTMNVAL
						If !(SF5->(DbSeek(FwXFilial("SF5") + cTipoMov)))
							cErro := "Tipo de Movimento não valorizado " + cTipoMov + " não cadastrado."
							lOk := .F.
						ElseIf SF5->F5_VAL == "S"
							cErro := "Tipo de Movimento não valorizado " + cTipoMov + " configurado incorretamente (F5_VAL)."
							lOk := .F.
						EndIf
					EndIf
				EndIf

				If lOk
				/*/	_aCab1 := {{"D3_DOC" ,cDocNum, NIL},;
					{"D3_TM" ,cTipoMov , NIL},;
						{"D3_CC" ,aItens[nItem][4], NIL},;
						{"D3_EMISSAO" ,dData, NIL}}




					AAdd(aMovimento, {"D3_TM",      cTipoMov,           Nil})
					AAdd(aMovimento, {"D3_COD",     aItens[nItem][1],   Nil})
					AAdd(aMovimento, {"D3_QUANT",   aItens[nItem][2],   Nil})
					AAdd(aMovimento, {"D3_LOCAL",   aItens[nItem][3],   Nil})
					AAdd(aMovimento, {"D3_EMISSAO", dData,              Nil})
					If !(Empty(cDocNum))
						AAdd(aMovimento, {"D3_DOC",     cDocNum,            Nil})
					EndIf
					If !lCustoZero
						AAdd(aMovimento, {"D3_CC",      aItens[nItem][4],   Nil})
						AAdd(aMovimento, {"D3_CUSTO1",  aItens[nItem][6],   Nil})
					EndIf
					AAdd(aMovimento, {"D3_XIDEXNF",  cNovIdInt,         Nil})
					//dados da nota
					AAdd(aMovimento, {"D3_XNOTA",   SF1->F1_DOC,        Nil})
					AAdd(aMovimento, {"D3_XSERIE",  SF1->F1_SERIE,      Nil})
					AAdd(aMovimento, {"D3_XFORN",   SF1->F1_FORNECE,    Nil})
					AAdd(aMovimento, {"D3_XLJFOR",  SF1->F1_LOJA,       Nil})



					//MsExecAuto({| movimentacao, operacao| MATA240(movimentacao, operacao)}, aMovimento, 3)
					aadd(_atotitem,aMovimento)

					MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
					FwFreeObj(aMovimento)
					aMovimento := Nil
					If lMsErroAuto
						cErro += "INCONSISTENCIA DE ROTINA AUTOMATICA - Movimento Interno | " + CRLF
						aLog := GetAutoGRLog()
						For nErro := 1 To Len(aLog)
							cErro += aLog[nErro] + CRLF
						Next nErro
						lOk := .F.
						Exit
					Else

						Reclock("SD3",.F.)
						SD3->D3_XCONTA := SF5->F5_XCONTA
						SD3->D3_TEATF := SF5->F5_TEATF
						SD3->(MsUnLock())
					EndIf
					/*/
					 DbSelectArea("SD3")
					Reclock("SD3",.T.)
					SD3->D3_FILIAL := CFILANT
					SD3->D3_XCONTA := SF5->F5_XCONTA
					SD3->D3_TEATF := SF5->F5_TEATF
					SD3->D3_DOC := cDocNum
					SD3->D3_TM  := cTipoMov
					SD3->D3_CC  := aItens[nItem][4]
					SD3->D3_EMISSAO := dData
					SD3->D3_TM      := cTipoMov
					SD3->D3_COD     := aItens[nItem][1]
					SD3->D3_QUANT   := aItens[nItem][2]
					SD3->D3_LOCAL   := aItens[nItem][3]
					SD3->D3_EMISSAO := dData
					If !(Empty(cDocNum))
						SD3->D3_DOC     := cDocNum
					EndIf
					If !lCustoZero
						SD3->D3_CC      := aItens[nItem][4]
						SD3->D3_CUSTO1  := aItens[nItem][6]
					EndIf
					SD3->D3_XIDEXNF  := cNovIdInt
					SD3->D3_XNOTA    := SF1->F1_DOC
					SD3->D3_XSERIE   := SF1->F1_SERIE 
					SD3->D3_XFORN    := SF1->F1_FORNECE
					SD3->D3_XLJFOR   := SF1->F1_LOJA
					SD3->(MsUnLock()) 
				Else
					Exit 
				EndIf
			Next nItem
		EndIf
	Else
		lOk := .F.
		cErro := "Parâmetro 'FS_TMSAIAS' vazio. Impossível prosseguir com a execução."
	EndIf

	If !(lOk)
		U_F1303703(cErro, .F.)
	EndIf

	AEval(aArea, {|area| RestArea(area)})

Return lOk
