#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} MT094LOK()
Valida se a SP tem multa ou juros e exibe mensagem de confirmação na tela.
@author 	Lucas Aguiar
@since 		25/05/2021
@version 	P12.7
@Return 	lRet
/*/

User Function MT094LOK()

	Local aArea := GetArea()
	Local lRet	:= .T.
	Local lContinua := .F.

	Local nMulta := 99999999
	Local nJuros := 99999999

	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())

		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo


	If SCR->CR_TIPO == "PC"
		DbSelectArea("SC7")
		DbSetOrder(1)
		If SC7->(DbSeek(xFilial("SCR")+AllTrim(SCR->CR_NUM)))
			If SC7->C7_XSOLPAG == "1"
				If (SC7->C7_XMULTA >= nMulta .Or. SC7->C7_XJURMUL >= nJuros)
					If !(SC7->C7_XMULTA == 0.00 .And. SC7->C7_XJURMUL == 0.00)
						lContinua := U_XAPRVMULJUR()
						If lContinua
							cMsgMulJur := "Esta solicitação de pagamento possui valor de Multa ou Juros lançados. "  + Chr(13) + Chr(10)
							cMsgMulJur += "CODIGO DA FILIAL: " + cValToChar(SC7->C7_FILIAL) + Chr(13) + Chr(10)
							cMsgMulJur += "NUMERO DA SP: " + cValToChar(SC7->C7_NUM) + Chr(13) + Chr(10)
							cMsgMulJur += "MULTA: R$ " + cValToChar(TRANSFORM(SC7->C7_XMULTA, "@E 99,999,999,999.99")) + Chr(13) + Chr(10)
							cMsgMulJur += "JUROS: R$ " + cValToChar(TRANSFORM(SC7->C7_XJURMUL, "@E 99,999,999,999.99"))  + Chr(13) + Chr(10)
							cMsgMulJur += "Deseja confirmar essa aprovação?"
							//Pergunta se deseja aprovar SP com multa/Juros
							If !MsgYesNo(cMsgMulJur)
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return(lRet)
