#Include 'Protheus.ch'
/*=====================================================================================================================================*
Fonte:      MT094LOK 
Função:     Ponto de Entrada executado na rotina de Aprovação de Documentos:
			Validar a continuação da liberação de documentos caso tenha multa e juros ultrapassando o limite estabelecido na P35
Analista:   Diego Fraidemberge Mariano - EZ4
Data:       06/09/2024
Empresa:    Rede D'Or
*=====================================================================================================================================*/
User Function MT094LOK()
Local aAreaCNE   := CNE->(GetArea())
Local nMulta := 999999
Local nJuros := 999999
Local lRet := .F.
Local lContinua := .F.

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

If SCR->CR_TIPO == "MD"
    DBSELECTAREA("CNE")
    DBSETORDER(4)
    If CNE->(DBSEEK(XFILIAL("CNE")+SCR->CR_NUM))
        If !lContinua
            lContinua := fValidProc()
            If (CNE->CNE_XMULTA >= nMulta .Or. CNE->CNE_XJUROS >= nJuros) .AND. lContinua .AND. SCR->CR_USER == RetCodUsr()
                cMsgMulJur := "Esta medição possui valor de Multa ou Juros lançados. "  + Chr(13) + Chr(10)
                cMsgMulJur += "CODIGO DA FILIAL: " +  CNE->CNE_FILIAL + Chr(13) + Chr(10)
                cMsgMulJur += "NUMERO DA MD: " + cValToChar(SCR->CR_NUM) + Chr(13) + Chr(10)
                cMsgMulJur += "MULTA: R$ " + cValToChar(TRANSFORM(CNE->CNE_XMULTA, "@E 99,999,999,999.99")) + Chr(13) + Chr(10)
                cMsgMulJur += "JUROS: R$ " + cValToChar(TRANSFORM(CNE->CNE_XJUROS, "@E 99,999,999,999.99"))  + Chr(13) + Chr(10)
                cMsgMulJur += "Deseja confirmar essa aprovação?"
                If !MsgYesNo(cMsgMulJur)   
                    lRet := .F.               
                Else                    
                    lRet := .T.
                EndIf
            Else
                lRet := .T.
            EndIf  
        EndIf
    EndIf
Else
    lRet := .T.
EndIf    

RestArea(aAreaCNE)

Return lRet

Static Function fValidProc()

	Local lContinua := .F.
	Local lMulta := .F.
	Local lJuros := .F.
	Local nXMulta := ""
	Local nXJuros := ""
	Local nMulta	:= 9999999
	Local nJuros	:= 9999999

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
	DbSelectArea("CNE")
	DbSetOrder(4)
	DbGoTop()
//CNE -> CNE posiciona pela CNE_NUMMED
	If CNE->(dbSeek(SCR->CR_FILIAL+Posicione("CNE",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CNE_NUMMED")))
		While CNE->(!EOF()) .And. AllTrim(CNE->CNE_FILIAL) == AllTrim(Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_FILIAL")) .And. AllTrim(CNE->CNE_NUMMED) == AllTrim(Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_NUMMED"))
			lMulta := .F.
			lJuros := .F.
			If Valtype(nXMulta) == "N"
				If Empty(cValToChar(nXMulta))
					nXMulta := CNE->CNE_XMULTA
				EndIf	
			ElseIf Valtype(nXMulta) == "C"
				nXMulta := CNE->CNE_XMULTA
			EndIf
			If Valtype(nXJuros) == "N"
				If Empty(cValToChar(nXJuros))
					nXJuros := CNE->CNE_XJUROS
				EndIf	
			ElseIf Valtype(nXJuros) == "C"
				nXJuros := CNE->CNE_XJUROS
			EndIf			
			
			If nXMulta >= nMulta
				lMulta := .T.
			EndIf
			If nXJuros >= nJuros
				lJuros := .T.
			EndIf
			DbSelectArea("P34")
			DbSetOrder(2)
			DbGoTop()
			If P34->(DbSeek(xFilial("P34")+CNE->CNE_PRODUTO))
				If lMulta
					If P34->P34_MULTA <> "1"
						lContinua := .T.
					EndIf
				EndIf
				If lJuros
					If P34->P34_JUROS <> "1"
						lContinua := .T.
					EndIf
				EndIf
			Else
				If (lJuros .Or. lMulta)
					lContinua := .T.
				EndIf
			EndIf
			If lContinua
				Exit
			EndIf
			CNE->(DbSkip())
		EndDo
	EndIf

Return lContinua
