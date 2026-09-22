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

	Public aPELinhas := PARAMIXB[1]
	Public nPEValor := PARAMIXB[2]
	Public cPECondicao := PARAMIXB[3]
	Public nPEValIPI := PARAMIXB[4]
	Public dPEDEmissao := PARAMIXB[5]
	Public nPEValSol := PARAMIXB[6]


	If INCLUI
		If Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"SA2->A2_XDTFIX") == "1"
			If (!Empty(M->E2_VENCTO) .And. xfDtExce <> "1")
				If M->E2_VENCTO <> U_VENCDPFX(aPELinhas,nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)[1][1]
					If xfDtExce == "2"
						Alert("A data de vencimento só pode ser alterada em casos de exceção de data fixa!")
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
