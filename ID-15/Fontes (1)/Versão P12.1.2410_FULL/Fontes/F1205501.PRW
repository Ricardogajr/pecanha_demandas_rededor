#Include 'Protheus.ch'

/*
{Protheus.doc} F1205501()
Busca a Raiz do CNPJ do fornecedor do cabeçalho
@Author  Fabrica de Software
@Since   24/08/2018
@Project MAN0000007423048_EF_055
@Param   lNfMedic, logico,
@Param   lConsMedic, logico,
@Param   aHeadSDE, array, cabeçalho SDE
@Param   aColsSDE, array, itens SDE
@Param   aHeadSEV, array, cabeçalho SEV
@Param   aColsSEV, array, itens SEV
*/
User Function F1205501(lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV)

	Local cRAIZ    := ""
	Local cQrySA2  := ""
	Local cAlias2  := GetNextAlias()
	Local cFornecs := ""
	Local nX       := 1
	Local cQrySC7  := ""
	Local cQryRet  := ""
	Local lContinua:=.T.

	If Empty(cA100For) .AND. Empty(cLoja) .AND. Empty(cTipo) .AND. Empty(cEspecie) .AND. Empty(cNFiscal) .AND. Empty(cSerie) //Impede de executar a rotina quando algum campo estiver em edicao
		lContinua:=.F.
		Help( , , 'Help', 'F1205501', 'Um ou mais campos do cabeçalho não foram preenchidos ', 1, 0 )
	EndIf

	If lContinua
		SA2->(DbSetOrder(1))
		If SA2->(MsSeek(xFilial("SA2")+cA100For+cLoja))
			cRAIZ := SubStr(SA2->A2_CGC,1,8)
		EndIf

		cQrySA2 := "SELECT A2_COD, A2_LOJA "
		cQrySA2 += "FROM " + RetSqlName("SA2") + " "
		cQrySA2 += "WHERE A2_CGC LIKE '" + cRAIZ + "%' "
		cQrySA2 += "AND D_E_L_E_T_ = ' ' "

		cQrySA2 := ChangeQuery(cQrySA2)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQrySA2), cAlias2, .T., .T.)

		While (cAlias2)->(!EOF())

			If nX == 1
				cFornecs := "'" + (cAlias2)->(A2_COD+A2_LOJA) + "'"
			Else
				cFornecs += ",'" + (cAlias2)->(A2_COD+A2_LOJA) + "'"
			EndIf

			nX++
			(cAlias2)->(DbSkip())
		End

		If !Empty(cFornecs)
			U_F1205502(cFornecs,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV) //Pedido de Compra
		EndIf

	EndIf

Return

/*
{Protheus.doc} F1205502()
Busca os pedidos de compra de todos os fornecedores da RAIZ do CNPJ
@Author  Fabrica de Software
@Since   27/08/2018
@Project MAN0000007423048_EF_055
@Param   cFornecs, caracter, fornecedores com a mesma raiz de CNPJ
@Param   lNfMedic, logico,
@Param   lConsMedic, logico,
@Param   aHeadSDE, array, cabeçalho SDE
@Param   aColsSDE, array, itens SDE
@Param   aHeadSEV, array, cabeçalho SEV
@Param   aColsSEV, array, itens SEV
*/
User Function F1205502(cFornecs,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV)

	Local aArea      := GetArea()
	Local aAreaSA2   := SA2->(GetArea())
	Local aAreaSC7   := SC7->(GetArea())
	Local bSavSetKey := SetKey(VK_F4,Nil)
	Local bSavKeyF5  := SetKey(VK_F5,Nil)
	Local bSavKeyF6  := SetKey(VK_F6,Nil)
	Local bSavKeyF7  := SetKey(VK_F7,Nil)
	Local bSavKeyF8  := SetKey(VK_F8,Nil)
	Local bSavKeyF9  := SetKey(VK_F9,Nil)
	Local bSavKeyF10 := SetKey(VK_F10,Nil)
	Local bSavKeyF11 := SetKey(VK_F11,Nil)
	Local nSldPed    := 0
	Local nOpc       := 0
	Local cQuery     := ""
	Local cAliasSC7  := GetNextAlias()
	Local nF4For     := 0
	Local cNomeFor   := ""
	Local aTitCampos := {}
	Local aConteudos := {}
	Local bLine      := { || .T. }
	Local cLine      := ""
	Local lContinua  := .T.
	Local oDlg
	Local oSize
	Local oListBox
	Local cFilSC7    := xFilial("SC7")
	Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi("Visualiza Pedido"),OemToAnsi("Pedido")} }
	Local cRestNFE	 := '' //Thiago Marques - 23781643 - 12/06/2025

	PRIVATE aF4For     := {}
	PRIVATE aRecSC7    := {}
	PRIVATE oOk        := LoadBitMap(GetResources(), "LBOK")
	PRIVATE oNo        := LoadBitMap(GetResources(), "LBNO")

	DEFAULT lNfMedic   := .F.
	DEFAULT lConsMedic := .F.
	DEFAULT aHeadSDE   := {}
	DEFAULT aColsSDE   := {}

	If Type("InConPad") == "L" //Impede de executar a rotina quando a tecla F3 estiver ativa
		lContinua := !InConPad
	EndIf

	If lContinua

		If MaFisFound("NF")

			If cTipo == "N"

				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				SA2->(MsSeek(xFilial("SA2")+cA100For+cLoja))
				cNomeFor	:= SA2->A2_NOME

				DbSelectArea("SC7")

				SC7->(DbSetOrder(9))

				cQuery += " SELECT R_E_C_N_O_ RECSC7 "
				cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
				cQuery += " WHERE C7_FILENT = '"+ cFilSC7 +"' AND "

				cQuery += " C7_FORNECE||C7_LOJA IN (" + cFornecs + ") AND "

				cQuery += " (C7_QUANT-C7_QUJE-C7_QTDACLA) > 0 AND "
				cQuery += " C7_RESIDUO = ' ' AND "
				cQuery += " C7_TPOP <> 'P' AND "

				If SuperGetMV("MV_RESTNFE") == "S"
					cQuery += " C7_CONAPRO<>'B' AND "
				EndIf

				//Filtra os pedidos de compras de acordo com os contratos
				If lConsMedic
					If lNfMedic //Traz apenas os pedidos oriundos de medicoes
						cQuery += " C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
						cQuery += " C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "
					Else //Traz apenas os pedidos que nao possuem medicoes
						cQuery += " C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
						cQuery += " C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "
					EndIf
				EndIf

				cQuery += " SC7.D_E_L_E_T_ = ' '"
				cQuery += " ORDER BY " + SqlOrder( SC7->( IndexKey() ) )

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)

				cRestNFE := SuperGetMV("MV_RESTNFE") //Thiago Marques - 23781643 - 12/06/2025 - Atribuição incorreta das variaveis de empresa e filial

				Do While (cAliasSC7)->(!Eof())

					('SC7')->(MsGoto((cAliasSC7)->RECSC7))

					//Verifica o Saldo do Pedido de Compra
					nSldPed := ('SC7')->C7_QUANT-('SC7')->C7_QUJE-('SC7')->C7_QTDACLA

					//Verifica se nao ha residuos, se possui saldo em abto e se esta liberado por alcadas se houver controle
					If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And. If(/*SuperGetMV("MV_RESTNFE")*/cRestNFE=="S",('SC7')->C7_CONAPRO <> "B",.T.).And.;
							('SC7')->C7_TPOP <> "P" )

						If lConsMedic .And. lNfMedic
							nF4For := aScan(aF4For,{|x| x[5]==('SC7')->C7_FORNECE .And. x[6]==('SC7')->C7_LOJA .And. x[7]==('SC7')->C7_NUM})
						Else
							nF4For := aScan(aF4For,{|x| x[2]==('SC7')->C7_FORNECE .And. x[3]==('SC7')->C7_LOJA .And. x[4]==('SC7')->C7_NUM})
						EndIf

						If ( nF4For == 0 )
							If lConsMedic .And. lNfMedic
								aConteudos := {.F.,('SC7')->C7_MEDICAO,('SC7')->C7_CONTRA,('SC7')->C7_PLANILHA,('SC7')->C7_FORNECE, ('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
							Else
								aConteudos := {.F.,('SC7')->C7_FORNECE,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
							EndIf

							aAdd(aF4For , aConteudos )
							aAdd(aRecSC7, ('SC7')->(Recno()))
						EndIf
					EndIf

					(cAliasSC7)->(dbSkip())
				EndDo

				//Exibe os dados na Tela
				If !Empty(aF4For)

					If lConsMedic .And. lNfMedic //Exibe os campos de medicao do contrato

						aTitCampos := {" ",RetTitle("C7_MEDICAO"),RetTitle("C7_CONTRA"),RetTitle("C7_PLANILH"),OemToAnsi("Fornecedor"),OemToAnsi("Loja"),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")}
						If !Empty(aF4For)
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][8],aF4For[oListBox:nAT][9]"
						Else
							cLine := "{If(Empty(aF4For),oNO,oOK)," +Replicate("'',",6) +"''"
						EndIf

					Else

						aTitCampos := {" ",OemToAnsi("Fornecedor"),OemToAnsi("Loja"),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")}
						If !Empty(aF4For)
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6]"
						Else
							cLine := "{If(Empty(aF4For),oNO,oOK)," +Replicate("'',",4) +"''"
						EndIf

					EndIf

					cLine += " } "

					//Monta dinamicamente o bline do CodeBlock
					bLine := &( "{ || " + cLine + " }" )

					DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi("Selecionar Pedido de Compra"+" - <F5> ") Of oMainWnd PIXEL

					//Calcula dimensões
					oSize := FwDefSize():New(.T.,,,oDlg)
					oSize:AddObject( "CAB"		,  100, 20, .T., .T. ) // Totalmente dimensionavel
					oSize:AddObject( "LISTBOX" 	,  100, 80, .T., .T. ) // Totalmente dimensionavel

					oSize:lProp 	:= .T. // Proporcional
					oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

					oSize:Process() 	   // Dispara os calculos

					@ oSize:GetDimension("CAB","LININI")+2,oSize:GetDimension("CAB","COLINI")   SAY OemToAnsi("Fornecedor RAIZ") Of oDlg PIXEL SIZE 47 ,9
					@ oSize:GetDimension("CAB","LININI"),oSize:GetDimension("CAB","COLINI")+45  MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oDlg PIXEL SIZE 120,9

					oListBox := TWBrowse():New( oSize:GetDimension("LISTBOX","LININI"),oSize:GetDimension("LISTBOX","COLINI"),;
						oSize:GetDimension("LISTBOX","XSIZE")-24,oSize:GetDimension("LISTBOX","YSIZE")+1.4,;
						,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

					oListBox:SetArray(aF4For)

					If (!Empty(aF4For))
						oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1] }
					EndIf

					oListBox:bLine := bLine

					ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,nF4For := oListBox:nAt,oDlg:End())},{||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},,aButtons)

					If nOpc == 1
						If !Empty(aF4For)
							Processa({|| U_F1205503(aF4For,nOpc,@nSldPed,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV)})
						Else
							Help(" ",1,"A103F4")
						EndIf
					EndIf


				Else
					Help(" ",1,"A103F4")
				EndIf

				(cAliasSC7)->(dbCloseArea())
				DbSelectArea("SC7")

			Else
				Help('   ',1,'A103TIPON')
			EndIf

		Else
			Help('   ',1,'A103CAB')
		EndIf

	EndIf

	SetKey(VK_F4,bSavSetKey)
	SetKey(VK_F5,bSavKeyF5)
	SetKey(VK_F6,bSavKeyF6)
	SetKey(VK_F7,bSavKeyF7)
	SetKey(VK_F8,bSavKeyF8)
	SetKey(VK_F9,bSavKeyF9)
	SetKey(VK_F10,bSavKeyF10)
	SetKey(VK_F11,bSavKeyF11)
	RestArea(aAreaSA2)
	RestArea(aAreaSC7)
	RestArea(aArea)

Return(.T.)

/*
{Protheus.doc} F1205503()
Importa os pedidos para os itens do documento de entrada
@Author  Fabrica de Software
@Since   27/08/2018
@Project MAN0000007423048_EF_055
@Param   aF4For, array, pedidos selecionados
@Param   nOpc, numerico, 
@Param   nSldPed, numerico, saldo do pedido
@Param   lNfMedic, logico,
@Param   lConsMedic, logico,
@Param   aHeadSDE, array, cabeçalho SDE
@Param   aColsSDE, array, itens SDE
@Param   aHeadSEV, array, cabeçalho SEV
@Param   aColsSEV, array, itens SEV
*/
User Function F1205503(aF4For,nOpc,nSldPed,lNfMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV)

	Local nx         := 0
	Local cSeek      := ""
	Local cFilialOri := ""
	Local cItem		 := StrZero(1,Len(SD1->D1_ITEM))
	Local lZeraCols  := .T.
	Local aRateio    := {0,0,0}
	Local aColsBkp   := Aclone(Acols)
	Local cPrdNCad   := ""
	Local nSavNF  	 := MaFisSave()
	Local lPrjCni    := If(FindFunction("ValidaCNI"),ValidaCNI(),.F.)
	Local cSeekTXPC	 := ""
	Local nC7IPI := 0
	Local cRestNFE	 := '' //Thiago Marques - 23781643 - 12/06/2025

	DEFAULT lNfMedic   := .F.
	DEFAULT aHeadSDE   := {}
	DEFAULT aColsSDE   := {}

	If ( nOpc == 1 )

		If lPrjCni
			U_COMA120(@aF4For,lNfMedic,.T.)
		EndIf

		cRestNFE := SuperGetMV("MV_RESTNFE") //Thiago Marques - 23781643 - 12/06/2025 - Realizando apenas uma busca do parâmetro e removendo do loop

		For nx := 1 to Len(aF4For)

			If aF4For[nx][1]

				If lNfMedic
					cForns := aF4For[nx][5]
					cLjFns := aF4For[nx][6]
					cPedid := aF4For[nx][7]
				Else
					cForns := aF4For[nx][2]
					cLjFns := aF4For[nx][3]
					cPedid := aF4For[nx][4]
				EndIF

				DbSelectArea("SA2") //Posiciona Fornecedor
				SA2->(DbSetOrder(1))
				SA2->(MsSeek(xFilial("SA2")+cForns+cLjFns))

				DbSelectArea("SC7") //Posiciona Pedido de Compra
				SC7->(DbSetOrder(9))
				SC7->(MsSeek(xFilial("SC7")+cForns+cLjFns+cPedid))
				If lZeraCols
					aCols		:= {}
					lZeraCols	:= .F.
					MaFisClear()
				EndIf

				// Grava Lote do PMS e o codigo de RDA
				If Type("lUsouLtPLS")<>"U" .And. !lUsouLtPLS .And. !Empty(SC7->C7_LOTPLS)
					lUsouLtPLS 	:= .T.
					cLotPLS		:= SC7->C7_LOTPLS
					cCodRDA		:= SC7->C7_CODRDA
					cOPeLot		:= SC7->C7_PLOPELT
				Endif

				// Muda ordem para trazer ordenado por item
				If SC7->(!Eof())
					cSeek      := xFilial("SC7")+cPedid
					cFilialOri := SC7->C7_FILIAL
					sc7->(DbSetOrder(14))
					dbSeek(cSeek)
				EndIf

				While ( SC7->(!Eof()) .And. SC7->C7_FILENT+SC7->C7_NUM == cSeek )

					If SC7->(C7_FILIAL+C7_FORNECE+C7_LOJA) == cFilialOri+cForns+cLjFns .And. If(/*SuperGetMV("MV_RESTNFE")*/cRestNFE=="S",SC7->C7_CONAPRO <> "B",.T.) // Verifica se o fornecedor esta correto

						DbSelectArea("SB1") // Verifica se o Produto existe Cadastrado na Filial de Entrada
						SB1->(DbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1") + SC7->C7_PRODUTO))
						IF SB1->(!Eof())
							DbSelectArea("SC7")


							nC7IPI := SC7->C7_IPI
							nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
							If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
								NfePC2Acol(SC7->(RecNo()),,nSlDPed,cItem,,@aRateio,aHeadSDE,@aColsSDE)

								MaFisAlt("IT_ALIQIPI",nC7IPI,Val(cItem))
								MaFisToCols(aHeader,aCols,,"MT100")

								cItem := SomaIt(cItem)
							EndIf
						Else
							cPrdNCad += "Pedido"+": "+SC7->C7_NUM+"  "+"Produto"+": "+SC7->C7_PRODUTO+CHR(10)
						EndIf
					EndIf

					If SC7->C7_MOEDA != 1
						cSeekTXPC := cSeek
					EndIf

					DbSelectArea("SC7")
					dbSkip()
				EndDo
			EndIf
		Next

		//Exibe Lista dos Produtos não Cadastrados na Filial de Entrega
		If Len(cPrdNCad)>0 .And. !l103Auto
			Aviso("A103ProcPC","No Pedido de Compra selecionado, existem produto(s) que não possuem cadastro na Filial de Entrada da Nota Fiscal."+CHR(10)+"Favor verificar o(s) produto(s) que estejam nesta condição para que o Pedido seja carregado totalmente!"+CHR(10)+cPrdNCad,{"Ok"})
		EndIf

		If Len(Acols) = 0 //Restaura o Acols caso o mesmo estiver vazio
			aCols:= aColsBKP
			MaFisRestore(nSavNF)
		EndIf

		If Type( "oGetDados" ) == "O" //Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas
			oGetDados:lNewLine:=.F.
			oGetDados:oBrowse:Refresh()
		EndIf

	EndIf

Return

/*
{Protheus.doc} F1205504()
Adicionar botão
@Author  Fabrica de Software
@Since   27/08/2018
@Project MAN0000007423048_EF_055
@Param   aButtons, array, outros botões
@Return  aButtons, novo botão.
*/
User Function F1205504(aButtons)

	Local lConsMedic := .F.
	Local aHeadSDE   := {}
	Local aColsSDE   := {}
	Local aHeadSEV   := {}
	Local aColsSEV   := {}

	lConsMedic := A103GCDisp()

	aadd(aButtons, {'Ped. RAIZ CNPJ', {|| U_F1205501(lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV) }, 'Ped. RAIZ CNPJ'})

Return aButtons

/*
{Protheus.doc} F1205505()
Query para selecionar Itens do Pedido de Compras
@Author  Fabrica de Software
@Since   28/08/2018
@Project MAN0000007423048_EF_055
@Param   cQuery, caracter, consulta padrão
@Param   nOpc  , numerico, Tipo 1-Pedido; 2-Item Pedido
@Return  cQryRet, acrescimo da consulta customizada.
*/
User Function F1205505(cQuery,nOpc)

	Local lConsMedic := A103GCDisp()
	Local cQryRet    := ""
	Local cRAIZ      := ""
	Local cQrySA2    := ""
	Local cAlias2    := GetNextAlias()
	Local cFornecs   := ""
	Local nX         := 1
	Local cFilSC7    := xFilial("SC7")
	Local aEstruSC7  := SC7->( dbStruct() )
	Local nAuxCNT    := 0
	Local cQTeste    := ""

	If nOpc == 2 //Item Pedido

		SA2->(DbSetOrder(1))
		If SA2->(MsSeek(xFilial("SA2")+cA100For+cLoja))
			cRAIZ := SubStr(SA2->A2_CGC,1,8)
		EndIf

		cQrySA2 := "SELECT A2_COD, A2_LOJA "
		cQrySA2 += "FROM " + RetSqlName("SA2") + " "
		cQrySA2 += "WHERE A2_CGC LIKE '" + cRAIZ + "%' "
		cQrySA2 += "AND D_E_L_E_T_ = ' ' "

		cQrySA2 := ChangeQuery(cQrySA2)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQrySA2), cAlias2, .T., .T.)

		While (cAlias2)->(!EOF())

			If nX == 1
				cFornecs := "'" + (cAlias2)->(A2_COD+A2_LOJA) + "'"
			Else
				cFornecs += ",'" + (cAlias2)->(A2_COD+A2_LOJA) + "'"
			EndIf

			nX++
			(cAlias2)->(DbSkip())
		End

		If !Empty(cFornecs)

			cQTeste := SubStr(cQuery,1,At("C7_OBRIGA",cQuery)-1) + SubStr(cQuery,At("C7_DIREITO",cQuery)+LEN("C7_DIREITO,"))
			cQryRet := SubStr(cQTeste,1,At("ORDER",cQTeste)-1)

			cQryRet += "UNION "
			cQryRet += "SELECT "
			For nAuxCNT := 1 To Len( aEstruSC7 )
				If !(aEstruSC7[nAuxCNT,1] $ "C7_OBRIGA C7_DIREITO")
					cQryRet += aEstruSC7[ nAuxCNT, 1 ]
					cQryRet += ","
				EndIf
			Next
			cQryRet += "R_E_C_N_O_ RECSC7"
			cQryRet += "FROM " + RetSqlName("SC7") + " SC7 "
			cQryRet += "WHERE C7_FILENT = '"+ cFilSC7 +"' AND "

			cQryRet += "C7_FORNECE+C7_LOJA IN (" + cFornecs + ") AND "

			cQryRet += "C7_RESIDUO = ' ' AND "
			cQryRet += "C7_TPOP <> 'P' AND "

			If SuperGetMV("MV_RESTNFE") == "S"
				cQryRet += "C7_CONAPRO<>'B' AND "
			EndIf

			//Filtra os pedidos de compras de acordo com os contratos
			If lConsMedic
				If lNfMedic //Traz apenas os pedidos oriundos de medicoes
					cQryRet += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
					cQryRet += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "
				Else //Traz apenas os pedidos que nao possuem medicoes
					cQryRet += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
					cQryRet += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "
				EndIf
			EndIf

			cQryRet += "SC7.D_E_L_E_T_ = ' '"
			cQryRet += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) )

		Else
			cQryRet := cQuery
		EndIf

	Else
		cQryRet := cQuery
	EndIf

Return cQryRet
