/*/{Protheus.doc} A103VCTO
Função responsável por definir os valores e datas de vencimento das parcelas na duplicata
@type function
@author Lucas Miranda de Aguiar
@since 16/03/2021
@version 1.0 
@return aReturn - Retorna um array com os valores de cada parcelas e datas de vencimento
/*/ 
#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.CH"

User Function A103VCTO()

	Local aVencto := {} //Array com os vencimentos e valores para geração dos títulos.
	Local nX 		:= {}
	Local lPrimeira     := .T.
	Local cQuery := ""
	Local cAliasSC7 := GetNextAlias()

	Public aPELinhas := PARAMIXB[1]
	Public nPEValor := PARAMIXB[2]
	Public cPECondicao := PARAMIXB[3]
	Public nPEValIPI := PARAMIXB[4]
	Public dPEDEmissao := PARAMIXB[5]
	Public nPEValSol := PARAMIXB[6]


	If INCLUI
		If FWIsInCallStack("U_S0100401") //Verifica se é da rotina de SP.
			
			cQuery += " SELECT Count(C7_XDOC) PEDIDOS"
			cQuery += " FROM " + RetSqlName("SC7")
			cQuery += " WHERE C7_XDOC  = '" + cNfiscal+ "'"
			cQuery += " AND C7_XSERIE  = '" + cSerie + "'"
			cQuery += " AND C7_FORNECE = '" + CA100FOR + "'"
			cQuery += " AND C7_LOJA    = '" + cLoja + "'"
			cQuery += " AND C7_XTPSP IN ('2', '3') "
			cQuery += " AND C7_XDTEXCE = '1' "
			cQuery += " AND D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasSC7, .T., .T.)
			If (cAliasSC7)->(PEDIDOS) > 0
				If Type("__ADTVENCTO") == "A"
					For nX := 01 To Len(__ADTVENCTO)
						aAdd(aVencto, { __ADTVENCTO[nX][1], __ADTVENCTO[nX][2]})
					Next nX
					__ADTVENCTO := Nil
				Endif
				Return aVencto
			endif
		Endif
		If Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"SA2->A2_XDTFIX") == "1"
			If (!Empty(M->E2_VENCTO) .And. xfDtExce <> "1")
				If M->E2_VENCTO <> U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)[1][1]
					If xfDtExce == "2"
						Alert("A data de vencimento só pode ser alterada em casos de exceção de data fixa!")
						RunTrigger(2,n,nil,,'E2_VENCTO')
						M->E2_VENCTO := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)[1][1]
					EndIf
					If ExistTrigger('E2_VENCTO') // verifica se existe trigger para este campo
						RunTrigger(2,n,nil,,'E2_VENCTO')
						M->E2_VENCTO := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)[1][1]
					Endif
				EndIf
			ElseIf xfDtExce <> "1"
				aVencto := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
			EndIf
		EndIf
	EndIf

	If (ALTERA .And. SF1->F1_XSOLPAG <> "1")
		If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
			If !Empty(M->E2_VENCTO)
				If M->E2_VENCTO <> U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)[1][1]
					If xfDtExce <> "1" 
						Alert("A data de vencimento só pode ser alterada em casos de exceção de data fixa!")
					EndIf
					If ExistTrigger('E2_VENCTO') // verifica se existe trigger para este campo
						RunTrigger(2,n,nil,,'E2_VENCTO')
					Endif
				EndIf
			Else
				aVencto := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
			EndIf
		EndIf
	ElseIf (ALTERA .And. SF1->F1_XSOLPAG == "1")
		aVencto := U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
	EndIf
Return aVencto
