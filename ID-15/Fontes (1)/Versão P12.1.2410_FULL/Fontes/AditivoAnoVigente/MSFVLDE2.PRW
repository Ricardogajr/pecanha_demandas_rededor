#Include "Protheus.ch"



User Function MSFVLDE2(cCampo)

	Default cCampo := ""

	Local lRet := .T.
	Local nValMax := GetNewPar("FS_MSFVLDE",100)
	Local cSegAlt := SE2->E2_XALTAD


	If ALTERA .AND. __CUSERID <> "005026"

		If cSegAlt == "S"

			If cCampo == "E2_DECRESC"

				If M->E2_DECRESC > SE2->E2_XODECRE + nValMax
					Alert("Não é permitido somar mais de R$" +cValToChar(nValMax)+ " no campo de decréscimo" + CRLF + "O valor inicial deste campo no título é de R$" +cValToChar(SE2->E2_XODECRE))
					M->E2_DECRESC := SE2->E2_DECRESC
					lRet := .F.
				ElseIf M->E2_DECRESC < SE2->E2_XODECRE - nValMax
					Alert("Não é permitido subtrair mais de R$" +cValToChar(nValMax)+ " no campo de decréscimo" + CRLF + "O valor inicial deste campo no título é de R$" +cValToChar(SE2->E2_XODECRE))
					M->E2_DECRESC := SE2->E2_DECRESC
					lRet := .F.
				EndIf
			ElseIf cCampo == "E2_ACRESC"
				If M->E2_ACRESC > SE2->E2_XOACRE + nValMax
					Alert("Não é permitido somar mais de R$" +cValToChar(nValMax)+ " no campo de acréscimo"+ CRLF + "O valor inicial deste campo no título é de R$" +cValToChar(SE2->E2_XOACRE))
					M->E2_ACRESC := SE2->E2_ACRESC
				ElseIf M->E2_ACRESC < SE2->E2_XOACRE - nValMax
					Alert("Não é permitido subtrair mais de R$" +cValToChar(nValMax)+ " no campo de acréscimo"+ CRLF + "O valor inicial deste campo no título é de R$" +cValToChar(SE2->E2_XOACRE))
					M->E2_ACRESC := SE2->E2_ACRESC
				EndIf
			EndIf
		Else
			If cCampo == "E2_DECRESC"

				If M->E2_DECRESC > SE2->E2_DECRESC + nValMax
					Alert("Não é permitido somar mais de R$" +cValToChar(nValMax)+ " no campo de decréscimo")
					M->E2_DECRESC := SE2->E2_DECRESC
					lRet := .F.
				ElseIf M->E2_DECRESC < SE2->E2_DECRESC - nValMax
					Alert("Não é permitido subtrair mais de R$" +cValToChar(nValMax)+ " no campo de decréscimo")
					M->E2_DECRESC := SE2->E2_DECRESC
					lRet := .F.
				EndIf
			ElseIf cCampo == "E2_ACRESC"
				If M->E2_ACRESC > SE2->E2_ACRESC + nValMax
					Alert("Não é permitido somar mais de R$" +cValToChar(nValMax)+ " no campo de acréscimo")
					M->E2_ACRESC := SE2->E2_ACRESC
				ElseIf M->E2_ACRESC < SE2->E2_ACRESC - nValMax
					Alert("Não é permitido subtrair mais de R$" +cValToChar(nValMax)+ " no campo de acréscimo")
					M->E2_ACRESC := SE2->E2_ACRESC
				EndIf
			EndIf

		EndIf

		If lRet .And. Empty(cSegAlt)
			M->E2_XOACRE		:= SE2->E2_ACRESC
			M->E2_XODECRE		:= SE2->E2_DECRESC
			M->E2_XALTAD		:= "S"
		EndIf
	EndIf
Return lRet
