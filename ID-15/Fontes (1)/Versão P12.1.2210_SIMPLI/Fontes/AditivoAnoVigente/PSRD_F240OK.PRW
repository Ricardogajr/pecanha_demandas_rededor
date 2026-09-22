#Include 'Protheus.ch'
#Include 'TopConn.Ch'

User Function F240OK()

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaE2 := SE2->(GetArea())
	Local cNumBord := SEA->EA_NUMBOR

	If IsInCallStack("FA241Canc")
		U_FLJMUNIC() //  Muda a loja do fornecedor nos títulos de imposto.
	EndIf
	RestArea(aAreaE2)
	RestArea(aArea)
Return lRet
