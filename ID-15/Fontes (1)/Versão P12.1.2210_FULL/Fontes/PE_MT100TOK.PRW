#Include "PROTHEUS.CH"

static lSegVez := .F.

/*/{Protheus.doc} MT100TOK
Validação final do Pedido de Compra
@author izac.ciszevski
@since 01/06/2017
@Project    MAN0000007423044_EF_003 
/*/
User Function MT100TOK()

	Local lValido    := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.) 
	Local lFilSimp := U_VALSIMP(cFilAnt)

	If FwIsInCallStack("ClaAut") .OR. FwIsInCallStack("fExecClass") .OR. FwIsInCallStack("U_xKPTInbAll")
		Return .T.
	EndIf
	
	if lFilSimp
		//Valida se é geração de nota fiscal pela SP e pela Liberação.
		if FwIsInCallStack("MATA094") .Or. (FwIsInCallStack("U_S0100401") .Or. FwIsInCallStack("U_F0100401"))  .Or. FwIsInCallStack("U_XMATA094")
			if SC7->C7_XTPSP != "1"
				Return .T.    
			endif
		endif
	endif

	lValido := U_F1000303()// Valida a solicitação de pagamento

	If lExecPECli .And. lValido .And. FindFunction('U_FSPE0019')
		lValido := U_FSPE0019()
	EndIf

	If lExecPECli .And. lValido .And. FindFunction('U_FSPE0020')
		If (!(FwIsInCallStack("U_F0703301")) .AND. !(FwIsInCallStack("U_F0703302"))  .AND. !(FwIsInCallStack("U_RDNFUPLOAD"))) .AND. !(FwIsInCallStack("U_xKPTInbAll"))
			lValido := U_FSPE0020()
		endif
	EndIf

	If lValido
		lValido := U_F0702904() //Verifica ítens estocáveis
	EndIf

	//Não executa caso a rotina de Exclusão de Nota Fiscal de Entrada esteja na pilha de chamada
	If lValido .And. !(FwIsInCallStack("U_F1303701")) .And. !(FwIsInCallStack("U_F1303702"))
		//Se vier de integração
		If FwIsInCallStack("U_F0703301") .Or. FwIsInCallStack("U_F0703302") .OR. !(FwIsInCallStack("U_xKPTInbAll")) .Or. (FwIsInCallStack("U_RDNFUPLOAD"))
			If !(U_F1303806())
				lValido := .F.
				Help("", 1, "HELP", "Semaforo", "Arquivo de semaforo em utilização. Não é possível prosseguir com a rotina.", 1, 0,,,,,,;
					{""})
			EndIf
		Else
			lValido := U_F1303804()
		EndIf
	EndIf

	if !lFilSimp
		//Início - 11904582 - Thais Paiva
		If !FwIsInCallStack("U_F0703301") .And. !(FwIsInCallStack("U_xKPTInbAll")) .And. !(FwIsInCallStack("U_RDNFUPLOAD"))
			If lValido .AND. (MaFisRet( , "NF_FRETE") > 0)
				lValido := CALCFRETE()
			EndIf
		EndIf
		//Fim - 11904582 - Thais Paiva
	endif

Return lValido

//Início - 11904582 - Thais Paiva
Static Function CALCFRETE()
	Local _aAreaFre := GetArea()
	Local nPosPc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
	Local nPosItPc	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
	Local nPosfre   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALFRE"})
	Local _nQtdIt := 0
	Local nValFrt  := MaFisRet( , "NF_FRETE")
	Local _aPedido := {}
	Local _nFrePed := 0
	Local _nValFPed := 0
	Local _nItPed := 0
	Local cPedido := ""
	Local _nAi := 0
	Local _nP := 0
	Local _nAc := 0
//Local _nVlBRut := MaFisRet( , "NF_TOTAL")
	Local _lRet := .T.
//Local _nVlDup := 0
	Local _nVlFrNF := 0
	Local _cDocUtili := ""
	Local _nDifFre := 0
	Local _aNumDoc := {}
	Local cNumDoc := ""
	Local cNumSerie := ""

	For _nAi := 1 to Len(aCols)
		If !aCols[_nAi][Len(aCols[_nAi])]
			If  Alltrim(cPedido) <> Alltrim(aCols[_nAi][nPosPc])
				aadd(_aPedido,Alltrim(aCols[_nAi][nPosPc]))
				cPedido := Alltrim(aCols[_nAi][nPosPc])
			EndIf
			_nQtdIt++
		EndIf
	Next _nAi

	If !Empty(cPedido)
		_aAreaNF := GetArea()
		SD1->(DbSetOrder(22))
		SF1->(DbSetOrder(1))
		SC7->(DbSetOrder(1))

		For _nP := 1 to Len(_aPedido)
			SD1->(DbGoTop())
			If SD1->(DbSeek(xFilial("SD1")+_aPedido[_nP]))
				While SD1->(!EOF()) .AND. Alltrim(SD1->D1_FILIAL) == Alltrim(xFilial("SD1")) .AND. Alltrim(SD1->D1_PEDIDO) == Alltrim(_aPedido[_nP])
					If (aScan(_aNumDoc,{|x| AllTrim(x) == Alltrim(SD1->D1_DOC)+Alltrim(SD1->D1_SERIE)})) == 0
						aadd(_aNumDoc,Alltrim(SD1->D1_DOC)+Alltrim(SD1->D1_SERIE))
						cNumDoc := Alltrim(SD1->D1_DOC)
						cNumSerie := Alltrim(SD1->D1_SERIE)
						SF1->(DbSeek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
						_nVlFrNF += SF1->F1_FRETE
						If Empty(Alltrim(_cDocUtili))
							_cDocUtili := "Nº "+SD1->D1_DOC+" Série: "+SD1->D1_SERIE+" / Pedido: "+_aPedido[_nP]
						Else
							_cDocUtili += CRLF+"Nº "+SD1->D1_DOC+" Série: "+SD1->D1_SERIE+" / Pedido: "+_aPedido[_nP]
						EndIf
						_cDocUtili += " / Vlr Frete: "+Transform(SF1->F1_FRETE,"@E 999,999,999.99")
					EndIf
					SD1->(DbSkip())
				EndDo
			Endif

			SC7->(DbSeek(xFilial("SC7")+_aPedido[_nP]))
			While SC7->(!EOF()) .AND. Alltrim(SC7->C7_FILIAL) == Alltrim(xFilial("SC7")) .AND. Alltrim(SC7->C7_NUM) == Alltrim(_aPedido[_nP])
				_nFrePed += SC7->C7_VALFRE
				_nItPed := _nItPed+1
				SC7->(DbSkip())
			EndDo

		Next _nP

		RestArea(_aAreaNF)

		If _nVlFrNF > 0
			If _nVlFrNF >= _nFrePed .AND. !Empty(_cDocUtili) .AND. nValFrt > 0

				MSGALERT( "Valor do Frete do já utilizado: "+CRLF+_cDocUtili, "Valor Frete" )

				For _nAc := 1 to Len(aCols)
					If !aCols[_nAc][Len(aCols[_nAc])]
						N := _nAc //Atualiza linha
						aCols[N][nPosfre] := 0
						A103Trigger('D1_VALFRE')
						If ExistTrigger('D1_VALFRE')
							RunTrigger(2,_nAc,nil,,'D1_VALFRE')
							MaColsToFIs(aHeader,aCols,_nAc,"MT100") //Grava o gatilho no campo caso possua a função MaFisRef
						EndIf
					EndIf
				Next _nAc

				MSGALERT( "Valor do Frete do Documento de Entrada será zerado.", "Novo Valor Frete" )
				lSegVez := .T.
				_lRet := .F.

			ElseIf _nVlFrNF < _nFrePed .AND. _nVlFrNF > 0 .AND. !Empty(_cDocUtili) .AND. (_nFrePed-_nVlFrNF) <> nValFrt

				MSGALERT( "Valor do Frete já utilizado: "+CRLF+_cDocUtili, "Valor Frete" )

				_nDifFre := _nFrePed-_nVlFrNF

				_nValFPed := _nDifFre/_nQtdIt

				For _nAc := 1 to Len(aCols)
					If !aCols[_nAc][Len(aCols[_nAc])]
						N := _nAc //Atualiza linha
						aCols[N][nPosfre] := _nValFPed
						A103Trigger('D1_VALFRE')
						If ExistTrigger('D1_VALFRE')
							RunTrigger(2,_nAc,nil,,'D1_VALFRE')
							MaColsToFIs(aHeader,aCols,_nAc,"MT100") //Grava o gatilho no campo caso possua a função MaFisRef
						EndIf
					EndIf
				Next _nAc

				MSGALERT( "Valor do Frete do Documento de Entrada foi corrigido para: "+Transform(_nDifFre,"@E 999,999,999.99"), "Novo Valor Frete" )
				lSegVez := .T.
				_lRet := .F.
			ElseIf !lSegVez
				cMsg := "Valor do Frete já foi utilizado no(s) Documento(s) de Entrada: "+CRLF+_cDocUtili+CRLF
				cMsg += "A diferença do frete é de "+Transform(_nFrePed-_nVlFrNF,"@E 999,999,999.99")+"."+CRLF
				cMsg += "Não será necessário corrigir o Valor do Frete."
				MSGALERT( cMsg, "Valor Frete" )
				lSegVez := .T.
			EndIf

		Else
			If nValFrt < _nFrePed

				MSGALERT( "Valor do Frete do Documento de Entrada será corrigido de acordo com o Valor do Pedido de Compras.", "Valor Frete" )

				If _nQtdIt == _nItPed

					For _nAc := 1 to Len(aCols)
						If !aCols[_nAc][Len(aCols[_nAc])]
							N := _nAc //Atualiza linha
							aCols[N][nPosfre] := Posicione("SC7",1,xFilial("SC7")+aCols[n][nPosPc]+aCols[n][nPosItPc],"C7_VALFRE")
							A103Trigger('D1_VALFRE')
							If ExistTrigger('D1_VALFRE')
								RunTrigger(2,_nAc,nil,,'D1_VALFRE')
								MaColsToFIs(aHeader,aCols,_nAc,"MT100") //Grava o gatilho no campo caso possua a função MaFisRef
							EndIf
						Endif
					Next _nAc

				Else
					_nValFPed := _nFrePed/_nQtdIt

					For _nAc := 1 to Len(aCols)
						If !aCols[_nAc][Len(aCols[_nAc])]
							N := _nAc //Atualiza linha
							aCols[N][nPosfre] := _nValFPed
							A103Trigger('D1_VALFRE')
							If ExistTrigger('D1_VALFRE')
								RunTrigger(2,_nAc,nil,,'D1_VALFRE')
								MaColsToFIs(aHeader,aCols,_nAc,"MT100") //Grava o gatilho no campo caso possua a função MaFisRef
							EndIf
						EndIf
					Next _nAc

				EndIf

				_nDifFre := _nFrePed-nValFrt

				MSGALERT( "Valor do Frete do Documento de Entrada foi corrigido para: "+Transform(_nFrePed,"@E 999,999,999.99"), "Novo Valor Frete" )

				_lRet := .F.

			EndIf

		EndIf

	EndIf

	RestArea(_aAreaFre)

Return _lRet
//Fim - 11904582 - Thais Paiva
