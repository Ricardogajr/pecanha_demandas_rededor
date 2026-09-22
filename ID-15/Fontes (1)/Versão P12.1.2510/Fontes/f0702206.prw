#INCLUDE "TOTVS.ch"
Static cPedFront    := ""
Static dDtTranf     := ctod("")
/*/{Protheus.doc} F0702206
    
    Garante replicação do campo C7_XNUM na alteração de Pedidos

    @type function user
    @Author Cleiton Genuino da Silva
    @Since 26/06/2023
/*/
User Function F0702206()

	Local aAreaSC7      := SC7->(fwGetArea())

	cPedFront           := ""
	dDtTranf            := ctod("")

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(XFilial("SC7")+cA120Num))
	Do While ! SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cA120Num
		If Empty(cPedFront)
			cPedFront           := SC7->C7_XNUM
		EndIf
		If Empty(dDtTranf)
			dDtTranf            := SC7->C7_XDTINT
		EndIf

		If ! Empty(cPedFront) .and. ! Empty(dDtTranf)
			Exit
		EndIf
		SC7->(DbSkip())
	End Do

	SC7->(fwRestArea(aAreaSC7))

Return

/*/{Protheus.doc} F0702207

    Garante replicação do campo C7_XNUM na alteração de Pedidos

    @type function user
    @Author Cleiton Genuino da Silva
    @Since 26/06/2023
/*/
User Function F0702207(cNumPEd)

	Local aAreaSC7      := SC7->(fwGetArea())

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(XFilial("SC7")+cNumPEd))
	Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cNumPEd
		RecLock("SC7",.F.)
		SC7->C7_XNUM        := cPedFront
		SC7->C7_XDTINT      := dDtTranf
		SC7->(MsUnLock())
		SC7->(DbSkip())
	End Do

	SC7->(fwRestArea(aAreaSC7))

Return

/* {Protheus.doc} F07022CZ
Rotina para alimentar o campo C7_DATPRF (Previsão de entrega).
@Author Paulo Krüger
@Since 15/12/2017
@Return Nil*/

User Function F07022CZ(cFilori, cNumPEd)

	Local aAreaSC7      := SC7->(fwGetArea())
	Local aAreaSBZ      := SBZ->(fwGetArea())
	Local nSBZDPRZ      := 0

If !IsInCallStack( 'U_F1200709' ) //Caso não venha de medição automática
	Return
EndIf

SC7->(DbSetOrder(01))
SC7->(DbSeek(cFilori + cNumPEd))

While !SC7->(Eof()) .And. SC7->C7_FILIAL + SC7->C7_NUM == cFilori + cNumPEd

	SBZ->(DbSetOrder(01))
	If SBZ->(DbSeek(SC7->C7_FILIAL + SC7->C7_PRODUTO))
		If SBZ->BZ_TIPE == 'H' //Hora
			nSBZDPRZ            := ROUND(SBZ->BZ_PE / 24, -1)
		ElseIf SBZ->BZ_TIPE == 'D' //Dia
			nSBZDPRZ            := SBZ->BZ_PE
		ElseIf SBZ->BZ_TIPE == 'S' //Semana
			nSBZDPRZ            := SBZ->BZ_PE * 7
		ElseIf SBZ->BZ_TIPE == 'M' //Mes
			nSBZDPRZ            := SBZ->BZ_PE * 30
		ElseIf SBZ->BZ_TIPE == 'A' //Ano
			nSBZDPRZ            := SBZ->BZ_PE * 360
		EndIf
	EndIf

	RecLock( 'SC7' ,.F.)
	SC7->C7_DATPRF  := DataValida(dDataBase + 01 + nSBZDPRZ)
	SC7->(MsUnLock())
	SC7->(DbSkip())

EndDo

	SC7->(fwRestArea(aAreaSC7))
	SBZ->(fwRestArea(aAreaSBZ))

Return
/*/{Protheus.doc} F07022CY

    Rotina para limpar os campos de integração no momento da gravação quando a opcao for copia
    
    @type function user
    @Author Alex Sandro Valario
    @Since 30/08/2017
/*/
User Function F07022CY(cNumPEd)

    Local aAreaSC7      := SC7->(fwGetArea())

    SC7->(DbSetOrder(1))
    SC7->(DbSeek(XFilial("SC7")+cNumPEd))
    Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cNumPEd
        SC7->(RecLock("SC7",.F.))
        SC7->C7_XNUM        := ""
        SC7->C7_XDTINT      := ctod("")
        SC7->C7_XID         := ""
        SC7->C7_XORIG       := ""
        SC7->C7_XFRONT      := ""
        SC7->(MsUnLock())
        SC7->(DbSkip())
    End Do

    SC7->(fwRestArea(aAreaSC7))

Return

/*/{Protheus.doc} DTPrograma
    
    Rotina Alimenta campo C7_DATPRF com a data digitada na SC
    @type function user
    @Author Cleiton Genuino da Silva
    @Since 26/06/2023
    @param cFilori, character, Filial de origem para varedura da data calculada
    @param cNumPEd, character, Numero do pedido de origem para varedura da data calculada

/*/
User Function DTPrograma( cFilCNE, cPedido )
	Local aAreaCNE      := CNE->(GetArea())    as array
	Local aAreaSC1      := SC1->(GetArea())    as array
	Local aAreaSC7      := SC7->(GetArea())    as array
	Local cCNE_PRODUT   := ''                  as character
	Local cCNE_XITSC    := ''                  as character
	Local cCNE_XNUMSC   := ''                  as character
	Local cDtProgramada := GetMv("MV_XDTPLAM") as character //Se o tipo estiver contido neste parametro não altera a data de entrega mantém a da SC C1_DATPRF
	Local lPedido       := .F.                 as logical
	Default cFilCNE     := xFilial("CNE")
	Default cPedido     := ''

	//Calcula o Desconto Por item e o valor total do pedido
	SC7->(DbSetOrder(1))
	lPedido := SC7->(DbSeek(cFilCNE+cPedido))

	If select( 'SC1' ) <= 0
		DBSELECTAREA( 'SC1' )
	EndIf

	SC1->(DbSetOrder(2)) //	C1_FILIAL + C1_PRODUTO + C1_NUM + C1_ITEM + C1_FORNECE + C1_LOJA

	If !Empty(SC7->C7_MEDICAO) .And. lPedido

		Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == cFilCNE+cPedido

			cCNE_XNUMSC  := POSICIONE("CNE",1,cFilCNE + SC7->(C7_CONTRA + C7_CONTREV + C7_PLANILH + C7_MEDICAO + C7_ITEMED), "CNE_XNUMSC")
			cCNE_XITSC   := POSICIONE("CNE",1,cFilCNE + SC7->(C7_CONTRA + C7_CONTREV + C7_PLANILH + C7_MEDICAO + C7_ITEMED), "CNE_XITSC")
			cCNE_PRODUT  := POSICIONE("CNE",1,cFilCNE + SC7->(C7_CONTRA + C7_CONTREV + C7_PLANILH + C7_MEDICAO + C7_ITEMED), "CNE_PRODUT")

			IF !Empty(cCNE_PRODUT) .And. !Empty(cCNE_XNUMSC) .And. !Empty(cCNE_XITSC) .And.  SC1->(DbSeek(XFilial("SC1")+SC1->(cCNE_PRODUT+cCNE_XNUMSC+cCNE_XITSC)))

				If !Empty(SC1->C1_XTPSC) .And. Alltrim(SC1->C1_XTPSC) $ cDtProgramada .And. SC1->C1_DATPRF > dDataBase

					If RecLock( 'SC7' ,.F.)
						SC7->C7_DATPRF :=  SC1->C1_DATPRF
						SC7->(MsUnLock())
					EndIf
				Else
					lPedido := .F.
				EndIf

			EndIf
			SC7->(DbSkip())
		End Do

	EndIf

	RestArea(aAreaSC1)
	RestArea(aAreaSC7)
	RestArea(aAreaCNE)

Return(lPedido)
