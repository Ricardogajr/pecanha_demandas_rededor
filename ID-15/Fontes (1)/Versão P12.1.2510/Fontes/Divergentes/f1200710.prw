#INCLUDE 'PROTHEUS.CH'
#DEFINE	 RECSOLICIT	01	//RECNO da SC
#DEFINE	 FILSOLICIT	02	//Filial da SC 
#DEFINE	 NUMSOLICIT	03	//Numero da SC 
#DEFINE	 ITMSOLICIT	04	//Item da SC 
#DEFINE	 PRDSOLICIT	05	//Produto 
#DEFINE	 DESSOLICIT	06	//Descrição produto 
#DEFINE	 QTDSOLICIT	07	//Quantidade 
#DEFINE	 PRCSOLICIT	08	//Preço total
#DEFINE	 VLTOTSOLIC	09	//Valor total 
#DEFINE	 LOCALSOLIC	10	//Local de estoque 
#DEFINE	 EMISSSOLIC	11	//Emissao 
#DEFINE	 FORNCSOLIC	12	//Fornecedor 
#DEFINE	 LOJAFSOLIC	13	//Loja do fornecedor 
#DEFINE	 GRPCOSOLIC	14	//Grupo de compras 
#DEFINE	 OBSERSOLIC	15	//Observações 
#DEFINE	 VLUNISOLIC	16	//Valor unitario
#DEFINE	 CCUSTSOLIC	17	//Centro de custo 
#DEFINE	 XTIPOSOLIC	18	//Tipo de solicitacao 
#DEFINE	 FLGGCSOLIC	19	//Flag da solicitacao 
#DEFINE	 CONTASOLIC	20	//Conta contabil 
#DEFINE	 ITEMCSOLIC	21	//Item contabil 
#DEFINE	 CLASSSOLIC	22	//Classe de valor
#DEFINE	 QTDAGSOLIC 23	//Quantidade aglutinada
#DEFINE	 VLRAGSOLIC 24	//Valor aglutinado
#DEFINE	 IDINTSOLIC 25	//ID de integração
#DEFINE	 FLAGGSOLIC 26  //Flag GCT
#DEFINE	 STATMSOLIC 27	//Status da medição
#DEFINE	 OBSMDSOLIC 28	//Observacoes da medição
#DEFINE	 NUMMDSOLIC 29	//Numero da medição
#DEFINE	 ITMMDSOLIC	30	//Item da medição
#DEFINE	 ORMEDSOLIC	31	//Origem da medição
#DEFINE	 DTMEDSOLIC	32	//Data da medição
#DEFINE	 HRMEDSOLIC	33	//Hora da medição
#DEFINE	 FILCTSOLIC	34	//Filial do contrato
#DEFINE	 CONTRSOLIC	35	//Numero do contrato
#DEFINE  RVCTRSOLIC	36	//Revisao do contrato
#DEFINE	 DINCTSOLIC	37	//Data inicial do contrato
#DEFINE	 DFICTSOLIC	38	//Data final do contrato
#DEFINE	 VGCTRSOLIC 39	//Vigencia do contrato
#DEFINE	 NUMPCSOLIC	40	//Num do PC
#DEFINE	 ITMPCSOLIC	41	//Item do PC
#DEFINE	 USERCSOLIC	42	//Código do usuário
#DEFINE	 SETORSOLIC 43  //Setor
#DEFINE	 MOTIVSOLIC 44  //Motivo
#DEFINE	 CHAVESOLIC	45	//Filial + Produto + Local de Estoque + Centro de Custo
#DEFINE	 JAUSESOLIC	46	//já em uso
#DEFINE	 DATAPSOLIC	47	//Data planejada
/*/{Protheus.doc} F1200710
	
	Atualiza informações na Solicitação de Compras.

	@type function User
	@author 	Cleiton Genuino da Silva
	@since 		24/09/2023
	@version 	12.1.2210
	@Obs    Data programada 

/*/

User Function F1200710(aId, cObs, cFlagGCT, cStatMed, cNumMed, cOriMed, dDataMed, cHoramed, cContrat, cRevisa, cPedCom)
	Local aAreaSC7   := SC7->(GetArea()) as array
	Local cAlias01   := ''               as character
	Local cItemMed   := ''               as character
	Local cItemPC    := ''               as character
	Local cProdPC    := ""               as character
	Local cTpSoc     := ""               as character
	Local lAtuSC7    := .F.              as logical
	Local nI         := 0                as numeric
	Local nPos       := 0                as numeric
	Local nPos2      := 0                as numeric
	Local nRecSC7    := 0                as numeric
	Default aId      := {}
	Default cContrat := ''
	Default cFlagGCT := ''
	Default cHoramed := ''
	Default cNummed  := ''
	Default cObs     := ''
	Default cOriMed  := ''
	Default cPedCom  := ''
	Default cRevisa  := ''
	Default cStatMed := ''
	Default dDataMed := CTOD( '  /  /  ' )

	If Empty(cObs)
		cObs := 'Medição gerada com sucesso'
	EndIf

	cTpSoc        := SuperGetMv("FS_XTPNASC", .F., "11")
	cDtProgramada := GetMv("MV_XDTPLAM") //Se o tipo estiver contido neste parametro não altera a data de entrega mantém a da SC C1_DATPRF

	ASort(aProdSel,,, {|x, y| x[IDINTSOLIC]+x[CHAVESOLIC] < y[IDINTSOLIC]+y[CHAVESOLIC]})

	For nI := 01 To Len(aId)
		lAtuSC7 :=	.F.
		lOpme 	:= .T.

		nPos 	:= AScan(aProdSel	, {|aVal| aVal[IDINTSOLIC] + aVal[CHAVESOLIC] == aId[nI]})
		If nPos == 0
			lOpme := .F.
			nPos  := AScan(aProdSel	, {|aVal| aVal[IDINTSOLIC] == aId[nI]})
		EndIf

		If nPos > 0
			If lOpme
				nPos2 := AScan(aProdSel	, {|aVal| aVal[IDINTSOLIC] + aVal[CHAVESOLIC] == aId[nI]},nPos + 1 )
			Else
				nPos2 := AScan(aProdSel	, {|aVal| aVal[IDINTSOLIC] == aId[nI]},nPos + 1 )
			EndIf

			If nPos2 == 0
				lAtuSC7 := .T.
			EndIf
		Endif
		While aProdSel[nPos][IDINTSOLIC] + IIf(aProdSel[nPos][XTIPOSOLIC] $ cTpSoc, aProdSel[nPos][CHAVESOLIC], "") == aId[nI]
			//Retorna Item da medição
			cAlias01 := GetNextAlias()
			BeginSql Alias cAlias01
				SELECT	CNE.CNE_ITEM CITEMMED
				FROM	%Table:CNE% CNE
				WHERE 		CNE.%notDel%
						AND CNE.CNE_FILIAL	= %Exp:aProdSel[nPos][02]%
						AND CNE.CNE_NUMMED	= %Exp:cNumMed%
						AND	CNE.CNE_PRODUT	= %Exp:aProdSel[nPos][05]%
			EndSql
			(cAlias01)->(DbGoTop())
			cItemMed := (cAlias01)->CITEMMED
			(cAlias01)->(DbCloseArea())


			//Retorna item do PC
			cAlias02 := GetNextAlias()
			BeginSql Alias cAlias02
				SELECT	SC7.C7_ITEM	CITEMPC, R_E_C_N_O_ RECNOSC7, SC7.C7_PRODUTO CPRODC7
				FROM	%Table:SC7% SC7
				WHERE 		SC7.%notDel%
						AND SC7.C7_FILIAL	= %Exp:aProdSel[nPos][02]%
						AND SC7.C7_NUM		= %Exp:cPedCom%
						AND	SC7.C7_PRODUTO	= %Exp:aProdSel[nPos][05]%
			EndSql
			(cAlias02)->(DbGoTop())
			cItemPC := (cAlias02)->CITEMPC
			nRecSC7	:= (cAlias02)->RECNOSC7
			cProdPC := (cAlias02)->CPRODC7
			(cAlias02)->(DbCloseArea())

			aProdSel[nPos][FLAGGSOLIC]	:=	cFlagGCT
			aProdSel[nPos][STATMSOLIC]	:=	cStatMed
			aProdSel[nPos][OBSMDSOLIC]	:=	cObs
			aProdSel[nPos][NUMMDSOLIC]	:=	cNumMed
			aProdSel[nPos][ITMMDSOLIC]	:=	cItemMed
			aProdSel[nPos][ORMEDSOLIC]	:=	cOriMed
			aProdSel[nPos][DTMEDSOLIC]	:=	dDataMed
			aProdSel[nPos][HRMEDSOLIC]	:=	cHoramed
			aProdSel[nPos][CONTRSOLIC]	:=	cContrat
			aProdSel[nPos][RVCTRSOLIC]	:=	cRevisa
			aProdSel[nPos][NUMPCSOLIC]	:=	cPedCom
			aProdSel[nPos][ITMPCSOLIC]	:=	cItemPC

			SC1->(DbSetOrder(01))
			If SC1->(DbSeek(aProdSel[nPos][FILSOLICIT] + aProdSel[nPos][NUMSOLICIT] + aProdSel[nPos][ITMSOLICIT])) .and. alltrim(SC1->C1_PRODUTO) == alltrim(cProdPC)

				Reclock('SC1',.F.)
				SC1->C1_FLAGGCT	:=	cFlagGCT
				SC1->C1_XITMED	:=	cStatMed
				SC1->C1_XOBSMED	:=	SUBSTR(cObs,001,254)
				SC1->C1_XNUMMED	:=	cNumMed
				SC1->C1_XITEMED	:=	cItemMed
				SC1->C1_XORIMED	:=	cOriMed
				SC1->C1_XDTMED	:=	dDataMed
				SC1->C1_XHRMED	:=	cHoramed
				SC1->C1_XCONTR	:=	cContrat
				SC1->C1_XREVISA	:=	cRevisa
				SC1->C1_PEDIDO	:=	cPedCom
				SC1->C1_ITEMPED	:=	cItemPC
				SC1->(MsUnlock())

				If (aProdSel[nPos][XTIPOSOLIC] $ cTpSoc) .or. (aProdSel[nPos][XTIPOSOLIC] $ cDtProgramada) //pedido do tipo 11 e Data programada
					SC7->(DbGoTo(nRecSC7))
					If SC7->(!EOF())  .and. SC7->(Recno()) == nRecSC7
						If RecLock("SC7",.F.)
							SC7->C7_XCODSET := SC1->C1_XCODSET
							SC7->C7_XINFPAC := SC1->C1_XINFPAC
							SC7->C7_OBS     := SC1->C1_OBS
							SC7->C7_NUMSC   := SC1->C1_NUM
							SC7->C7_ITEMSC  := SC1->C1_ITEM
							SC7->C7_LOCAL	:= SC1->C1_LOCAL

							//Limpa C7 user (somente em caso de schedule)
							If ISINCALLSTACK('U_F1200600')
								SC7->C7_USER := ''
							EndIf
							SC7->(MsUnlock())
						EndIf
					EndIf
				Else
					If lAtuSC7 .And. nRecSC7 > 0
						SC7->(DbGoTo(nRecSC7))
						If SC7->(!EOF())  .and. SC7->(Recno()) == nRecSC7
							If RecLock("SC7",.F.)
								SC7->C7_XCODSET := SC1->C1_XCODSET
								SC7->C7_XINFPAC := SC1->C1_XINFPAC
								SC7->C7_LOCAL	:= SC1->C1_LOCAL

								//Limpa C7 user (somente em caso de schedule)
								If ISINCALLSTACK('U_F1200600')
									SC7->C7_USER := ''
								EndIf
								SC7->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf

			EndIf

			If nPos < Len(aProdSel)
				nPos := nPos + 01
			Else
				Exit
			EndIf

		EndDo
	Next nI
	aId := {}

	RestArea(aAreaSC7)

Return
