#Include 'Protheus.ch'
#Include 'TopConn.Ch'

User Function F240OK()

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaE2 := SE2->(GetArea())
	Local cNumBord := SEA->EA_NUMBOR
 
	If IsInCallStack("FA241Canc")

		U_FLJMUNIC() //  Muda a loja do fornecedor nos títulos de imposto.

		Public aCntrlJM := {}

		DbSelectArea("SE2")
		DbSetOrder(15)

		If SE2->(DbSeek(xFilial("SE2")+cNumBord))

			While SE2->(!Eof()) .And. SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_NUMBOR == cNumBord

				If SE2->E2_MULTA > 0 .Or. SE2->E2_JUROS > 0

					Aadd( aCntrlJM, { SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),;
						SE2->E2_JUROS ,;
						SE2->E2_MULTA })

				EndIf

				SE2->(DbSkip())

			End

		EndIf

	EndIf
	RestArea(aAreaE2)
	RestArea(aArea)
Return lRet
