#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F1000303
Valida a origem do documento. Documentos de solicitação de pagamento só podem
ser manipulados por rotina específica (F1000301). 
@author izac.ciszevski
@since 01/06/2017s
@project MAN0000007423044_EF_003
@project MAN0000007423044_EF_004

/*/
User Function F1000303()
	
	Local lSolPag  := FwIsInCallStack("U_F1000301")
	Local lValido  := .T.
	Local nX       := 0
	Local cItens   := ""
	Local nPosPed  := AScan(aHeader,{|Header| AllTrim(Upper(Header[2])) == Upper("D1_PEDIDO") })

	If FwIsInCallStack("fExecClass")
		Return .T.
	EndIf
	
	if !U_VALSIMP(SC7->C7_FILIAL)
		If nPosPed > 0
			For nX := 1 To Len(aCols)
				lValido := .T.
				If !aCols[nX][Len(aCols[nX])] //Se não estiver deletado
					If SC7->(DbSeek(FwXFilial("SC7") + aCols[nX][nPosPed]))
						If lSolPag
							lValido := SC7->C7_XSOLPAG == "1" // Origem Solicitação de Pagamento
						Else
							lValido := SC7->C7_XSOLPAG != "1" // Outra Origem
						EndIf
					EndIf
			
					If !lValido
						cItens += STR(nX) + ","
					EndIf
				EndIf
			
			Next nX
		Else
			lValido := .F.
			Help(,,"HELP",,"Usuario sem acesso ao campo D1_PEDIDO", 2, 0)
		EndIf
		
		If !Empty(cItens)
			Help("" ,1 , "Alerta!", , "O(s) Item(s) " + cItens + " " + Iif(lSolPag,"não","") + " é(são) proveniente(s) de Solicitação de Pagamento e Pedidos de Compra." +;
									"Este Documento não será confirmado.", 2, 0)
			lValido := .F.
		EndIf
	endif

Return lValido
