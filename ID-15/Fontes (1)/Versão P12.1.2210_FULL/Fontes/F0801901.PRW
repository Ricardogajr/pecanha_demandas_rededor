#Include 'Protheus.ch'

/*
{Protheus.doc} F0801901()
Validação na repetição de postos na visão
@Author     Bruno de Oliveira
@Since      09/06/2016
@Param		cFil, caracter, Filial da visão
@Param		cVisao, caracter, Código da visão
@Param		aDados, array, itens da visão
@Version    P12.1.07
@Project    MAN0000007423042_EF_019
*/
User Function F0801901(cFil,cVisao,aDados)

	Local aAreaRDK := RDK->(GetArea())
	Local lRet     := .T.
	Local aItens   := {}
	Local cItens   := ""
	Local cHierarq := ""
	Local nPos     := 0
	Local nX       := 0
	
	cHierarq := Posicione("RDK",1,cFil+cVisao,"RDK_HIERAR")
	
	If cHierarq == "2"
	
		ASort(aDados, , , { | x,y | x[3]+x[4]+x[1] < y[3]+y[4]+y[1] } )
		
		For nX := 1 to Len(aDados)
			
			If !aDados[nX][9]
				nPos := AScan(aItens,{|x| x[1] == aDados[nX][3]+aDados[nX][4] })
				If nPos > 0
					cItens += "Linha " + aItens[nPos][2]+ " e " + aDados[nX][1] + " - " + aDados[nX][3] + " - " + aDados[nX][4] + ";" + CRLF
				Else
					AAdd(aItens,{aDados[nX][3]+aDados[nX][4],aDados[nX][1]})	
				EndIf
			EndIf
		
		Next nX
		
		If !Empty(cItens)
			Msgalert("Não é permitido salvar a visão devido repetição de postos nas linhas: " + CRLF + " (Itens - Filial - Posto) " + CRLF + cItens,"Atenção")
			lRet := .F.
		EndIf
	
	EndIf
	
	RestArea(aAreaRDK)

Return lRet