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

	Local aAreaSC7      := SC7->(GetArea())

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

	SC7->(RestArea(aAreaSC7))

Return

/*/{Protheus.doc} F0702207

    Garante replicação do campo C7_XNUM na alteração de Pedidos

    @type function user
    @Author Cleiton Genuino da Silva
    @Since 26/06/2023
/*/
User Function F0702207(cNumPEd)

	Local aAreaSC7      := SC7->(GetArea())

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(XFilial("SC7")+cNumPEd))
	Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cNumPEd
		RecLock("SC7",.F.)
		SC7->C7_XNUM        := cPedFront
		SC7->C7_XDTINT      := dDtTranf
		SC7->(MsUnLock())
		SC7->(DbSkip())
	End Do

	SC7->(RestArea(aAreaSC7))

Return

/* {Protheus.doc} F07022CZ
Rotina para alimentar o campo C7_DATPRF (Previsão de entrega).
@Author Paulo Krüger
@Since 15/12/2017
@Return Nil*/

User Function F07022CZ(cFilori, cNumPEd)

Local aAreaSC7      := SC7->(GetArea())
Local aAreaSBZ      := SBZ->(GetArea())
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

SC7->(RestArea(aAreaSC7))
SBZ->(RestArea(aAreaSBZ))

Return
/*/{Protheus.doc} F07022CY

    Rotina para limpar os campos de integração no momento da gravação quando a opcao for copia
    
    @type function user
    @Author Alex Sandro Valario
    @Since 30/08/2017
/*/
User Function F07022CY(cNumPEd)

    Local aAreaSC7      := SC7->(GetArea())

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

    SC7->(RestArea(aAreaSC7))

Return

/*/{Protheus.doc} DTPrograma
    
    Rotina Alimenta campo C7_DATPRF com a data digitada na SC
    @type function user
    @Author Cleiton Genuino da Silva
    @Since 26/06/2023
    @param cFilori, character, Filial de origem para varedura da data calculada
    @param cNumPEd, character, Numero do pedido de origem para varedura da data calculada

/*/
User Function DTPrograma( cFilori, cNumPEd )
	Local aAreaSC1      := {}                  as array
	Local aAreaSC7      := {}                  as array
	Local cAlias        := GetNextAlias()      as character
	Local cDtProgramada := GetMv("MV_XDTPLAM") as character //Se o tipo estiver contido neste parametro não altera a data de entrega mantém a da SC C1_DATPRF
	Local cTmpAlias     := ''                  as character
	Default cFilori     := ''
	Default cNumPEd     := ''

	If IsInCallStack( 'U_F1200709' ) //Caso não venha de medição automática

		If select( 'SC1' ) <= 0
			DBSELECTAREA( 'SC1' )
		EndIf
		aAreaSC1            := SC1->(GetArea())
		SC1->(DbSetOrder(6)) // C1_FILIAL + C1_PEDIDO + C1_ITEMPED + C1_PRODUTO	Num. Pedido + Item Pedido + Produto

		If select( 'SC7' ) <= 0
			DBSELECTAREA( 'SC7' )
		EndIf
		aAreaSC7 := SC7->(GetArea())
		SC7->(DbSetOrder(01)) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN

		BeginSql alias cAlias
			SELECT
				C7_FILIAL,
				C7_NUM,
				C7_ITEM,
				C7_NUMSC,
				C7_PRODUTO,
				C7_MEDICAO,
				SC7.R_E_C_N_O_ as C7RECNO
			FROM
				%Table:SC7% SC7
			WHERE
				C7_FILIAL = %exp:cFilori%
				AND C7_NUM = %exp:cNumPEd%
				AND SC7.%NotDel% 
		EndSql

		While (cAlias)->(!EOF())
			
			If SC7->(DbSeek((cAlias)->C7_FILIAL + (cAlias)->C7_NUM + (cAlias)->C7_ITEM )) .And. !Empty(SC7->C7_NUMSC) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
				If SC1->(DbSeek((cAlias)->C7_FILIAL + (cAlias)->C7_NUM + (cAlias)->C7_ITEM + (cAlias)->C7_PRODUTO  ))  .And. !Empty(SC1->C1_XTPSC) .And. Alltrim(SC1->C1_XTPSC) $ cDtProgramada
					If RecLock( 'SC7' ,.F.)
						SC7->C7_DATPRF := IIF( SC1->C1_DATPRF <= dDataBase, DTSBZPrograma((cAlias)->C7_FILIAL,(cAlias)->C7_PRODUTO), SC1->C1_DATPRF )
						SC7->(MsUnLock())
					EndIf
				EndIf
			ElseIf !Empty((cAlias)->C7_MEDICAO)
				cTmpAlias := GetNextAlias()
				BeginSql alias cTmpAlias
				SELECT
					C1_DATPRF,
					C1_XNUMMED,
					SC1.R_E_C_N_O_ AS C1RECNO
				FROM
					%Table:SC1% SC1
				WHERE
					C1_FILIAL = %exp:(cAlias)->C7_FILIAL%
					AND C1_XNUMMED = %exp:(cAlias)->C7_MEDICAO%
					AND SC1.%NotDel% 
				EndSql

				If (cTmpAlias)->(!EOF()) .And. (cTmpAlias)->C1RECNO > 0 .And. (cAlias)->C7RECNO > 0 
				
					SC1->(DbGoTo((cTmpAlias)->C1RECNO))	
					SC7->(DbGoTo((cAlias)->C7RECNO))		

					If SC1->(!EOF())  .And. SC1->(Recno()) == (cTmpAlias)->C1RECNO .And. SC7->(!EOF())  .And. SC7->(Recno()) == (cAlias)->C7RECNO
						If !Empty(SC1->C1_XTPSC) .And. Alltrim(SC1->C1_XTPSC) $ cDtProgramada 
							If RecLock( 'SC7' ,.F.)
								SC7->C7_DATPRF := IIF( SC1->C1_DATPRF <= dDataBase, DTSBZPrograma((cAlias)->C7_FILIAL,(cAlias)->C7_PRODUTO), SC1->C1_DATPRF ) 
								SC7->(MsUnLock())
							EndIf
						EndIf					
					EndIf 

				EndIf
				(cTmpAlias)->(DbCloseArea())
			EndIf
			(cAlias)->(dbskip())
		Enddo

		SC7->(RestArea(aAreaSC7))
		SC1->(RestArea(aAreaSC1))
		(cAlias)->(DbCloseArea())
		

	EndIf

Return
/*/{Protheus.doc} DTSBZPrograma

	Rotina para alimentar o campo C7_DATPRF (Previsão de entrega)
	Caso a data da SC esteja menor que a data base.
	
	@type function user
	@Author Cleiton Genuino da Silva
	@Since 24/07/2023
	@param cFilori		, character, Filial de busca na tabela SBZ
	@param cValProduto	, character, Código do produto a ser validado na SBZ

/*/
Static Function DTSBZPrograma(cFilori, cValProduto)
	Local aAreaSBZ      := SBZ->(GetArea()) as array
	Local dData         := dDataBase        as date
	Local nSBZDPRZ      := 0                as numeric
	Default cFilori     := ''
	Default cValProduto := ''


	If select('SBZ') <= 0
		DBSELECTAREA('SBZ')
	EndIf
	SBZ->(DbSetOrder(01)) // BZ_FILIAL + BZ_COD

	If SBZ->(DbSeek(cFilori + cValProduto))
		
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

	dData := DataValida(dDataBase + 01 + nSBZDPRZ)

	SBZ->(RestArea(aAreaSBZ))

Return dData
