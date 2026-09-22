#INCLUDE 'Protheus.ch'

/*{Protheus.doc} F1200902
Pto.Entrada existente na Funçao A120TudOk(), responsável pela validação de todos os itens da GetDados do Pedido de Compras / Autorização de Entrega.

@author	Ademar Fernandes
@since	15/08/2017
@project	MAN0000007423046_EF_009 
*/
User Function F1200902()
	Local nX 
	Local lRet       := .T.
	Local cMyCod     := ""
	Local aMyCols    := {}
	Local aRet 		 := {}

	Local lSolicPag  := IsInCallStack("U_F0100401")
	Local lSolicPgS  := IsInCallStack("U_S0100401") 
	Local lIntegraPC := IsInCallStack("U_F0702601")
	Local lContrat   := IsInCallStack("U_F1200701")

	Local nPosCODPro := GdFieldPos("C7_PRODUTO")

	Local nPosDelete := Len(aHeader)+1

	Local nPosDtEntr := GdFieldPos("C7_DATPRF")

	nX := N

	If !lSolicPag .And. !lIntegraPC .And. !lSolicPgS

		aMyCols := aClone(aCols)
		aSort( aMyCols,,,{ |x,y| x[nPosCODPro] < y[nPosCODPro] } )
		cMyCod := aCols[01,nPosCODPro]


		nX := N
		If !aCols[n,nPosDelete]	//-Linha Deletada?

			If !( lRet := U_F0900103( GDFieldGet ( "C7_PRODUTO" ,N,.F.,,) ))
				lRet := .T. //Exit
			EndIf

			If lRet
//				If n > 1 .And. cMyCod == GDFieldGet ( "C7_PRODUTO" ,N,.F.,,)
				nPos := Ascan(aCols,{|x| x[nPosCODPro] == GDFieldGet ( "C7_PRODUTO" ,N,.F.,,) }) //Verifica duplicidade de produtos em medições/pedidos de compra == GDFieldGet ( "C7_PRODUTO" ,N,.F.,,)})
				If nPos > 0 .AND. n <> nPos
					If P17->(Posicione("P17", 1, xFilial("P17") + GDFieldGet ( "C7_PRODUTO" ,N,.F.,,) + cFilAnt, "P17_ESTOQ")) == "S"
						lRet := .F.
						Help("",1,"Mesmo produto em duas ou mais linhas.",,"Não é permitido o mesmo código de produto em duas ou mais linhas diferentes.",1,0,,,,,,{"Posicione o cursor no item duplicado e tecle DELETE para eliminar a linha."})
						//Exit
					EndIf
				EndIf
			Endif
			If SCR->CR_NUM <> Nil .OR. SCR->CR_NUM <> " "
				If lRet	.AND. Posicione("CND",1,xFilial("CND")+AllTrim(Posicione("CNE",4,xFilial("CNE")+AllTrim(SCR->CR_NUM),"CNE_CONTRA")),"CND_XCTSER") <> "1"

					cMyCod := aMyCols[n,nPosCODPro]
					If !Empty(GDFieldGet ( "C7_DATPRF",N,.F.,,)) .AND. DTOS(GDFieldGet ( "C7_DATPRF",N,.F.,,)) < DTOS(DA120EMIS)
						lRet := .F.
						Help("",1,"Pedido de Compra - Data de Entrega",,"Não é permitido data de entrega menor que a data de emissão.",1,0,,,,,,{"Data de Entrega precisa ser maior ou igual a data de emissão"})
						//Exit
					EndIf
				Endif
			Else
				If lRet
					cMyCod := aMyCols[n,nPosCODPro]
					If !Empty(GDFieldGet ( "C7_DATPRF",N,.F.,,)) .AND. DTOS(GDFieldGet ( "C7_DATPRF",N,.F.,,)) < DTOS(DA120EMIS)
						lRet := .F.
						Help("",1,"Pedido de Compra - Data de Entrega",,"Não é permitido data de entrega menor que a data de emissão.",1,0,,,,,,{"Data de Entrega precisa ser maior ou igual a data de emissão"})
						//Exit
					EndIf
				Endif
			EndIf

			If !lContrat .And. !Isblind()
				If nXDesFin > 100 .And. lRet
					Help("",1,"Pedido de Compra - Desconto Financeiro",,"Não é permitido desconto financeiro maior que 100%",1,0,,,,,,{"Desconto financeiro não pode ultrapassar o valor de 100%"})
					lRet := .F.
				EndIf
			EndIf

			If !lContrat .And. !Isblind()
				aRet := U_MSCHKCOND(CCONDICAO,CA120FORN,CA120LOJ)

				If !aRet[1]
					Help( , , 'Help', 'MSCHKCOND', aRet[2], 1, 0, , , , , , {"Revise a condição de pagamento escolhida."})
					lRet := aRet[1]
				EndIf

			EndIf
		Else
			cMyCod := ""
		EndIf
	EndIf

Return lRet
