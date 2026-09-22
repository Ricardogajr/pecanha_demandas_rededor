#Include "Protheus.ch"


/*{Protheus.doc} MSCHKCOND
FunÃ§Ã£o responsÃ¡vel por validar as condiÃ§Ãµes de pagamento de acordo com o parÃ¢metro de processamento
@author		Lucas Miranda de Aguiar - Miranda Solution
@since		14/06/2025
@version	P12.2210
*/ 

User Function MSCHKCOND(cCond,cForn,cLoja,lIntegNf,aDatasInt,lContrat,dDataKT)

	Local nDtProc := 0
	Local aRet := {.T.,"OK"}
	Local nX := 01
	Local aParamDatas := StrToKarr(GetNewPar("MV_DTFIXA","5;10;15;20;25;30"), ";")
	Local lValDtFix := GetNewPar("MS_VLDDTF",.T.)
	Local lValCommon := GetNewPar("MS_VLDDTNF",.F.)
	Local nVerValInt := GetNewPar("MS_VLDTINT",2) //versão da validação do vencimento para integração
	Local nTamFor	:= TamSX3("A2_COD")[1]
	Local nTamLoja	:= TamSX3("A2_LOJA")[1]
	Local lDatafixa := .F.
	Local aDatasCommon := {}
	Local dDataFixa := NIL
	Local nY := 01
	Local nDifContrat := 0
	Local nH := 01
	Local aRetAux := {}
	Local dDataCorrig := NIL

	Default cCond := ""
	Default lIntegNf := .F.
	Default aDatasInt := {}
	Default cForn := ""
	Default cLoja := ""
	Default lContrat := .F.
	Default dDataKt := ""

	If !GetNewPar("MS_VALCOND",.T.)
		Return {.T.,"OK"}//Chave para ativar ou desativar a validaÃ§Ã£o da condiÃ§Ã£o de pgto.
	EndIf

	If Empty(cForn) .Or. Empty(cLoja)
		aRet[1] := .F.
		aRet[2] := "Fornecedor ou loja não informado, favor informar o código do fornecedor/loja antes da condição de pagamento!"
		Return aRet
	EndIf

	If Posicione("SA2",1,xFilial("SA2")+Padr(cForn,nTamFor)+Padr(cLoja,nTamLoja),"SA2->A2_XDTFIX") == "1"
		lDatafixa := .T.
	Else
		lDatafixa := .F.
	EndIf

	If lDatafixa
		nDtProc := GetNewPar("MV_XDTPROC",30)//Parametro de datas de processamento para data fixa
	Else
		nDtProc := GetNewPar("MS_DTPNFIX",30)//Parametro de datas de processamento para nÃ£o data fixa
	EndIf

	If lIntegNf .And. nVerValInt == 1 //Versão 01
		If (lDatafixa .And. lValDtFix) .Or. (!lDatafixa .And. lValCommon)
			For nX := 01 To Len(aDatasInt)
				If nX <> 01 //a primeira posiÃ§Ã£o do array de datas vai ser a data de emissão para referencia
					If nDtProc > DateDiffDay(aDatasInt[1], Iif(lDatafixa,U_DTFORNFIX(aDatasInt[nX],"",0,aDatasInt[1]),aDatasInt[nX]))
						aRet[1] := .F.
						aRet[2] := "Uma ou mais parcelas estão com a data de vencimento menor do que o prazo mínimo de " + cValtoChar(nDtProc) + " dias a partir da emissão do documento. Favor revisar o documento."
						Exit
					EndIf
					If aRet[1]
						For nY := 01 To Len(aDatasInt)
							If (nX <> nY) .And. (Iif(lDatafixa,U_DTFORNFIX(aDatasInt[nY],"",0,aDatasInt[1]),aDatasInt[nY]) == Iif(lDatafixa,U_DTFORNFIX(aDatasInt[nX],"",0,aDatasInt[1]),aDatasInt[nX]))
								aRet[1] := .F.
								aRet[2] := "Uma ou mais parcelas estão com a data de vencimento geradas para o mesmo dia, verifique se a condição de pagamento está correta de acordo com as novas regras do Data Fixa."
								Exit
							EndIf
						Next nY
					EndIf
				EndIf
			Next nX
		EndIf
	ElseIf lIntegNf .And. nVerValInt == 2 //Versão 02
		If (lDatafixa .And. lValDtFix) .Or. (!lDatafixa .And. lValCommon)
			For nX := 01 To Len(aDatasInt)
				If nX <> 01 //a primeira posiÃ§Ã£o do array de datas vai ser a data de emissão para referencia
					dDataFixa := U_DTFORNFIX(aDatasInt[nX][1],"",0,aDatasInt[1])
					If nDtProc > DateDiffDay(aDatasInt[1], Iif(lDatafixa,dDataFixa,aDatasInt[nX][1]))
						dDataCorrig := DaySum(aDatasInt[nX][1],nDtProc-DateDiffDay(aDatasInt[1], aDatasInt[nX][1]))
						If lDatafixa
							dDataCorrig := U_DTFORNFIX(dDataCorrig,"",0,aDatasInt[1])
						EndIf
						AADD(aRetAux,{dDataCorrig,aDatasInt[nX][2]})
					EndIf
				EndIf
			Next nX
			If !Empty(aRetAux)
				aRet[1] := .F.
				aRet[2] := aRetAux
			EndIf
		EndIf
	Else
		If (lDatafixa .And. lValDtFix) .Or. (!lDatafixa .And. lValCommon)
			aDatasCommon := Condicao(100, cCond , , Date() , , , , )
			For nX := 01 To Len(aDatasCommon)
				If nX == 01 .And. !Empty(dDataKT)//Tratativa SP KT
					If nDtProc > DateDiffDay(Date() - 1, dDataKT)
						aRet[1] := .F.
						aRet[2] := "Uma ou mais parcelas estão com a data de vencimento menor do que o prazo mínimo de " + cValtoChar(nDtProc) + " dias a partir da emissão do documento. Favor revisar o documento."
						Exit
					Else
					Loop
					EndIf
				EndIf

				If nDtProc > DateDiffDay(Date() - 1, Iif((lDatafixa .And. !lContrat),U_DTFORNFIX(aDatasCommon[nX][1],cCond),aDatasCommon[nX][1]))
					aRet[1] := .F.
					aRet[2] := "Uma ou mais parcelas estão com a data de vencimento menor do que o prazo mínimo de " + cValtoChar(nDtProc) + " dias a partir da emissão do documento. Favor revisar o documento."
					Exit
				EndIf
				If lContrat
					If aRet[1]
						For nH := 1 To Len(aParamDatas) - 1
							nDifContrat := Val(aParamDatas[nH+1]) - Val(aParamDatas[nH])
						Next nH
						For nY := 01 To Len(aDatasCommon)
							If (nX <> nY) .And. DateDiffDay(aDatasCommon[nX][1],aDatasCommon[nY][1]) < nDifContrat
								aRet[1] := .F.
								aRet[2] := "A Condição de pagamento utilizada tem uma diferença menor que " + cValToChar(nDifContrat) + " dias entre as parcelas e não poderá ser utilizada para criação de contratos."
								Exit
							EndIf
						Next nY
					EndIf
				Else
					If aRet[1]
						For nY := 01 To Len(aDatasCommon)
							If (nX <> nY) .And. (Iif(lDatafixa,U_DTFORNFIX(aDatasCommon[nX][1],cCond),aDatasCommon[nX][1]) == Iif(lDatafixa,U_DTFORNFIX(aDatasCommon[nY][1],cCond),aDatasCommon[nY][1]))
								aRet[1] := .F.
								aRet[2] := "Uma ou mais parcelas estão com a data de vencimento geradas para o mesmo dia, verifique se a condição de pagamento está de acordo com as novas regras do Data Fixa."
								Exit
							EndIf
						Next nY
					EndIf
				EndIf
			Next nX
		EndIf

	EndIf

Return aRet
