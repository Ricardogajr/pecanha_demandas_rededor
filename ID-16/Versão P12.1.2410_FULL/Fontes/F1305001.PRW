#Include 'Protheus.ch'

/*{Protheus.doc} F1305001
Função responsável pela alteração da segunda unidade de medida
@type function
@since 02/05/2018
@version 12.7
@project MAN0000007423048_EF_050
*/
User Function F1305001()

	Local aProdutos := {}
	Local lEnd		:= .F.
	Private cRegLog := ""
	Private oProcess
	Private lEnd 	:= .F.
	Private nHdl	:= 0
	
	Pergunte("FSW1305001",.T.)

	If FILE(MV_PAR01)

		//Carrega linhas do arquivo
		If ((nHandle := FT_FUse(Alltrim( MV_PAR01 ))) == -1)
			MsgInfo("Nao foi possivel abrir o arquivo "+ MV_PAR01 +"!!! Processo Interrompido.")
			Return
		Endif
	    
		ProcRegua( FT_FLastRec() )
		
		FT_FGoTop()   

		While !FT_FEof()
	
			IncProc()
			aAdd( aProdutos,FT_FReadLn() )

			FT_FSkip()
		End
		
		//Fecha o arquivo	
		FT_FUse()
		
		//Fecha o binário
		FClose( nHandle )
		
        oProcess := MsNewProcess():New( { | lEnd | ProcProd( @lEnd, aProdutos ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
        oProcess:Activate()		
		
	Else
		MsgInfo("Arquivo não encontrado!")
	EndIf
	
Return

Static Function ProcProd( lEnd, aProdutos )
	Local nX        := 0
	
	oProcess:SetRegua1( Len(aProdutos) )
	
	For nX := 1 to Len(aProdutos)
		If nX > 1
			U_F1305002(PADR(aProdutos[nX],TamSX3("B1_COD")[1]," "))
		EndIf
	Next nX
	
	U_F1305003(.T.)
Return

/*{Protheus.doc} F1305002
Função responsável pela processamento da alteração da segunda unidade de medida
@type function
@since 02/05/2018
@version 12.7
@Param	cProduto, caracter, Código do produto
@project MAN0000007423048_EF_050
*/
User Function F1305002(cProduto)

	Local aArea 	:= GetArea()
	Local nX		:= 1
	Local nTotReg	:= 0
	
	DbSelectArea("SB1") //Cadastro de Produtos
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProduto))
		
		oProcess:IncRegua1("Atualizando Produto [" + cProduto + "]... " )
		
		cSegUn := SB1->B1_SEGUM
		
		RecLock("SB1",.F.)
		SB1->B1_SEGUM := SB1->B1_UM
		SB1->B1_CONV  := 1
		SB1->(MsUnLock())
		
		U_F1305003(.F.,"SB1",,,cProduto,cSegUn,,SB1->B1_SEGUM,)
		
		DbSelectArea("P17") //Tratamento por filial
		P17->(DbSetOrder(1))
		If P17->(DbSeek(xFilial("P17")+cProduto))
			nX := 1
			nTotReg := DefReg2("P17", "P17_FILIAL", "P17_COD" , cProduto)
			oProcess:SetRegua2( nTotReg )			
			While P17->(!EOF()) .AND. P17->(P17_FILIAL+P17_COD) == xFilial("P17")+cProduto
				oProcess:IncRegua2("Alterando P17: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(P17->(Recno())) + "" )
				
				cUm2 := P17->P17_UM2
				
				RecLock("P17",.F.)
				P17->P17_UM2   := P17->P17_UM1
				P17->P17_CONV1 := 1
				P17->P17_COMP  := 1
				P17->(MsUnLock())
				
				U_F1305003(.F.,"P17",,,cProduto,cUm2,,P17->P17_UM2,)
				
				nX++
			P17->(DbSkip())
			End
				
		EndIf		
				
		DbSelectArea("SC1") //Solicitações de Compra
		SC1->(DbSetOrder(2))
		If SC1->(DbSeek(xFilial("SC1")+cProduto))
			nX := 1
			nTotReg := DefReg2("SC1", "C1_FILIAL", "C1_PRODUTO" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SC1->(!EOF()) .AND. SC1->(C1_FILIAL+C1_PRODUTO) == xFilial("SC1")+cProduto
				
				oProcess:IncRegua2("Alterando SC1: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SC1->(Recno())) + "" )
				
				cSegUm := SC1->C1_SEGUM
				cQtdSeg := STR(SC1->C1_QTSEGUM)
			
				If SC1->C1_QUJE == SC1->C1_QUANT .AND. Empty(SC1->C1_RESIDUO) //Atendida
					lRet := .T.
//				ElseIf SC1->C1_QUJE == 0 .AND. Empty(SC1->C1_RESIDUO) //Pendente
//					lRet := .T.
				ElseIf !Empty(SC1->C1_RESIDUO) //Eliminadas Resíduo
					lRet := .T.
				Else
					lRet := .F.
				EndIf
				
				If lRet
					RecLock("SC1",.F.)
					SC1->C1_SEGUM   := SC1->C1_UM
					SC1->C1_QTSEGUM := SC1->C1_QUANT
					SC1->(MsUnLock())
					U_F1305003(.F.,"SC1",SC1->C1_NUM,SC1->C1_ITEM,cProduto,cSegUm,cQtdSeg,SC1->C1_SEGUM,STR(SC1->C1_QTSEGUM))
				EndIf
				
				nX++
				SC1->(DbSkip())
			End
		EndIf
		
		DbSelectArea("SC7") //Pedido de Compra
		SC7->(DbSetOrder(2))
		If SC7->(DbSeek(xFilial("SC7")+cProduto))
			nX := 1
			nTotReg := DefReg2("SC7", "C7_FILIAL", "C7_PRODUTO" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SC7->(!EOF()) .AND. SC7->(C7_FILIAL+C7_PRODUTO) == xFilial("SC7")+cProduto
				
				oProcess:IncRegua2("Alterando SC7: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SC7->(Recno())) + "" )
				
				cSegUm := SC7->C7_SEGUM
				cQtdSeg := STR(SC7->C7_QTSEGUM)
			
				If !Empty(SC7->C7_ENCER) .AND. Empty(SC7->C7_RESIDUO) //Atendida
					lRet := .T.
//				ElseIf SC7->C7_QUJE == 0 .AND. Empty(SC7->C7_RESIDUO) //Pendente
//					lRet := .T.
				ElseIf !Empty(SC7->C7_RESIDUO) //Eliminadas Resíduo
					lRet := .T.
				Else
					lRet := .F.
				EndIf
				
				If lRet
					RecLock("SC7",.F.)
					SC7->C7_SEGUM    := SC7->C7_UM
					SC7->C7_QTSEGUM := SC7->C7_QUANT
					SC7->(MsUnLock())
					U_F1305003(.F.,"SC7",SC7->C7_NUM,SC7->C7_ITEM,cProduto,cSegUm,cQtdSeg,SC7->C7_SEGUM,STR(SC7->C7_QTSEGUM))	
				EndIf
				
				nX++
				SC7->(DbSkip())
			End	
		EndIf
		
		DbSelectArea("SCY") //Histórico Pedidos de Compras
		SCY->(DbSetOrder(2))
		If SCY->(DbSeek(xFilial("SCY")+cProduto))
			nX := 1
			nTotReg := DefReg2("SCY", "CY_FILIAL", "CY_PRODUTO" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SCY->(!EOF()) .AND. SCY->(CY_FILIAL+CY_PRODUTO) == xFilial("SCY")+cProduto
				
				oProcess:IncRegua2("Alterando SCY: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SCY->(Recno())) + "" )
				
				cSegUm  := SCY->CY_SEGUM
				cQtdSeg := STR(SCY->CY_QTSEGUM)
			
				RecLock("SCY",.F.)
				SCY->CY_SEGUM   := SCY->CY_UM
				SCY->CY_QTSEGUM := SCY->CY_QUANT
				SCY->(MsUnLock())
				U_F1305003(.F.,"SC7",SCY->CY_NUM,SCY->CY_ITEM,cProduto,cSegUm,cQtdSeg,SCY->CY_SEGUM,STR(SCY->CY_QTSEGUM))
				
				nX++
				SCY->(DbSkip())
			End
		EndIf
		
		DbSelectArea("SC6") //Itens dos Pedidos de Venda
		SC6->(DbSetOrder(2))
		If SC6->(DbSeek(xFilial("SC6")+cProduto))
			nX := 1
			nTotReg :=  DefReg2("SC6", "C6_FILIAL", "C6_PRODUTO" , cProduto) 
			oProcess:SetRegua2( nTotReg )
			While SC6->(!EOF()) .AND. SC6->(C6_FILIAL+C6_PRODUTO) == xFilial("SC6")+cProduto
				
				oProcess:IncRegua2("Alterando SC6: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SC6->(Recno())) + "" )
				
				cSegUm := SC6->C6_SEGUM
				cQtdSeg := STR(SC6->C6_UNSVEN)
			
				If SC6->C6_QTDVEN == SC6->C6_QTDENT //Atendida
					lRet := .T.
				ElseIf SC6->C6_QTDVEN == 0 //Pendente
					lRet := .T.
				Else
					lRet := .F.
				EndIf
				
				If lRet
					RecLock("SC6",.F.)
					SC6->C6_SEGUM  := SC6->C6_UM
					SC6->C6_UNSVEN := SC6->C6_QTDVEN
					SC6->(MsUnLock())
					U_F1305003(.F.,"SC6",SC6->C6_NUM,SC6->C6_ITEM,cProduto,cSegUm,cQtdSeg,SC6->C6_SEGUM,STR(SC6->C6_UNSVEN))	
				EndIf
				
				nX++
				SC6->(DbSkip())
			End			
		EndIf
		
		DbSelectArea("SC8") //Cotações
		SC8->(DbSetOrder(9))
		If SC8->(DbSeek(xFilial("SC8")+cProduto))
			nX := 1
			nTotReg := DefReg2("SC8", "C8_FILIAL", "C8_PRODUTO" , cProduto)
			oProcess:SetRegua2( nTotReg )
			
			While SC8->(!EOF()) .AND. SC8->(C8_FILIAL+C8_PRODUTO) == xFilial("SC8")+cProduto
				
				oProcess:IncRegua2("Alterando SC8: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SC8->(Recno())) + "" )
				
				cSegUm := SC8->C8_SEGUM
				cQtdSeg := STR(SC8->C8_QTSEGUM)
			
				If !Empty(SC8->C8_NUMPED) //Atendida
					lRet := .T.
				ElseIf Empty(SC8->C8_NUMPED) //Pendente
					lRet := .T.
				Else
					lRet := .F.
				EndIf
				
				If lRet
					RecLock("SC8",.F.)
					SC8->C8_SEGUM   := SC8->C8_UM
					SC8->C8_QTSEGUM := SC8->C8_QUANT
					SC8->(MsUnLock())
					U_F1305003(.F.,"SC8",SC8->C8_NUM,SC8->C8_ITEM,cProduto,cSegUm,cQtdSeg,SC8->C8_SEGUM,STR(SC8->C8_QTSEGUM))	
				EndIf
				
				nX++
				SC1->(DbSkip())
			End	
		EndIf
		
		DbSelectArea("SD1") //Itens das notas fiscais de entrada
		SD1->(DbSetOrder(2))
		If SD1->(DbSeek(xFilial("SD1")+cProduto))
			nX := 1
			nTotReg := DefReg2("SD1", "D1_FILIAL", "D1_COD" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SD1->(!EOF()) .AND. SD1->(D1_FILIAL+D1_COD) == xFilial("SD1")+cProduto
				
				oProcess:IncRegua2("Alterando SD1: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SD1->(Recno())) + "" )
				
				cSegUm  := SD1->D1_SEGUM
				cQtdSeg := STR(SD1->D1_QTSEGUM)
			
				RecLock("SD1",.F.)
				SD1->D1_SEGUM   := SD1->D1_UM
				SD1->D1_QTSEGUM := SD1->D1_QUANT
				SD1->(MsUnLock())
				U_F1305003(.F.,"SD1",SD1->D1_DOC+SD1->D1_SERIE,SD1->D1_ITEM,cProduto,cSegUm,cQtdSeg,SD1->D1_SEGUM,STR(SD1->D1_QTSEGUM))
				
				nX++
				SD1->(DbSkip())
			End		
		EndIf
		
		DbSelectArea("SD2") //Itens de venda da nota fiscal
		SD2->(DbSetOrder(1))
		If SD2->(DbSeek(xFilial("SD2")+cProduto))
			nX	:= 1
			nTotReg := DefReg2("SD2", "D2_FILIAL", "D2_COD" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SD2->(!EOF()) .AND. SD2->(D2_FILIAL+D2_COD) == xFilial("SD2")+cProduto
				
				oProcess:IncRegua2("Alterando SD2: " + cValToChar(nX) + " de  " + cValToChar(nTotReg) + " Recno: " + cValToChar(SD2->(Recno())) + "" )
				
				cSegUm  := SD2->D2_SEGUM
				cQtdSeg := STR(SD2->D2_QTSEGUM)
			
				RecLock("SD2",.F.)
				SD2->D2_SEGUM   := SD2->D2_UM
				SD2->D2_QTSEGUM := SD2->D2_QUANT
				SD2->(MsUnLock())
				U_F1305003(.F.,"SD2",SD2->D2_DOC+SD2->D2_SERIE,SD2->D2_ITEM,cProduto,cSegUm,cQtdSeg,SD2->D2_SEGUM,STR(SD2->D2_QTSEGUM))
				
				nX++
				SD2->(DbSkip())
			End		
		EndIf
		
		DbSelectArea("SD3") //Movimentações interna
		SD3->(DbSetOrder(3))
		If SD3->(DbSeek(xFilial("SD3")+cProduto))
			nX := 1
			nTotReg := DefReg2("SD3", "D3_FILIAL", "D3_COD" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SD3->(!EOF()) .AND. SD3->(D3_FILIAL+D3_COD) == xFilial("SD3")+cProduto
				
				oProcess:IncRegua2("Alterando SD3: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SD3->(Recno())) + "" )
				
				cSegUm  := SD3->D3_SEGUM
				cQtdSeg := STR(SD3->D3_QTSEGUM)
			
				RecLock("SD3",.F.)
				SD3->D3_SEGUM   := SD3->D3_UM
				SD3->D3_QTSEGUM := SD3->D3_QUANT
				SD3->(MsUnLock())
				U_F1305003(.F.,"SD3",SD3->D3_DOC,SD3->D3_ITEM,cProduto,cSegUm,cQtdSeg,SD3->D3_SEGUM,STR(SD3->D3_QTSEGUM))
				
				nX++
				SD3->(DbSkip())
			End			
		EndIf
		
		DbSelectArea("SB9") //Saldos iniciais
		SB9->(DbSetOrder(1))
		If SB9->(DbSeek(xFilial("SB9")+cProduto))
			nX := 1
			nTotReg := DefReg2("SB9", "B9_FILIAL", "B9_COD" , cProduto)
			oProcess:SetRegua2( nTotReg )
			While SB9->(!EOF()) .AND. SB9->(B9_FILIAL+B9_COD) == xFilial("SB9")+cProduto
				
				oProcess:IncRegua2("Alterando SB9: " + cValToChar(nX) + " de " + cValToChar(nTotReg) + " Recno: " + cValToChar(SB9->(Recno())) + "" )
				
				cQtdSeg := STR(SB9->B9_QISEGUM)
			
				RecLock("SB9",.F.)
				SB9->B9_QISEGUM := SB9->B9_QINI
				SB9->(MsUnLock())
				U_F1305003(.F.,"SB9",SB9->B9_LOCAL,,cProduto,,cQtdSeg,,STR(SB9->B9_QISEGUM))
				
				nX++
				SB9->(DbSkip())
			End			
		EndIf
		
	Else
		U_F1305003(.F.,"SB1",,,cProduto,,,,,"Não encontrado produto")
	EndIf
	
	RestArea(aArea)

Return

/*{Protheus.doc} F1305003
Função responsável pela geração do LOG de processamento
@type function
@since 03/05/2018
@version 12.7
@Param lFim, lógico, Finaliza o LOG ou continua
@Param cTabela, caracter, tabela do registro
@Param cNum, caracter, código de identificação da tabela
@Param cItem, caracter, item do registro
@Param cProduto, caracter, Código do produto
@Param cUniAnt, caracter, unidade antiga
@Param cQtdAnt, caracter, quantidade antiga
@Param cUniAlt, caracter, unidade alterada
@Param cQtdAlt, caracter, quantidade alterada
@project MAN0000007423048_EF_050
*/
User Function F1305003(lFim,cTabela,cNum,cItem,cProduto,cUniAnt,cQtdAnt,cUniAlt,cQtdAlt)

	Local aArea   := GetArea()
	Local cArqGrv := "\system\"+"LogProc"+ DTOS(dDataBase)+".txt"
	Local cRegLog := ""
	
	Default cTabela := ""
	Default cNum    := ""
	Default cItem   := ""
	Default cUniAnt := ""
	Default cQtdAnt := ""
	Default cUniAlt := ""
	Default cQtdAlt := ""
	
	If nHdl == 0
		If( nHdl := fCreate( cArqGrv ) )	== -1
			MsgAlert("Erro ao criar o arquivo " + cArqGrv + cValToChar( fError() ) ) 							
		EndIf	
	EndIf

	If lFim
		
		fclose(nHdl)                  
    	MsgAlert("Processo concluído! arquivo gerado" + cArqGrv + "")	
	
	Else
		cRegLog += cTabela + " - " + cNum + " " + cItem + " Produto:" + cProduto + " - Unidade Antiga:" + cUniAnt + " - Quantidade Antiga:" + cQtdAnt + " - Unidade Alterada:" + cUniAlt + " - Quantidade Alterada:" + cQtdAlt + CRLF
		fWrite( nHdl, cRegLog)
	EndIf
	
	RestArea(aArea)

Return

Static Function DefReg2(cTabela, cFiltrb, cCampPrd , cProd)

    Local cQuery   := ""
    Local cAlsQry  := GetNextAlias()
    Local nRet := 0

    cQuery := "SELECT COUNT(1) QTDPROD " + CRLF
    cQuery += "FROM " + RetSqlName("" + cTabela + "") + " SB1 " + CRLF
    cQuery += "WHERE " + CRLF
    cQuery += "  " + cFiltrb + " = '" + XFilial("" + cTabela + "") + "' AND " + CRLF
    cQuery += "  " + cCampPrd + " = '" + cProd + "' AND " + CRLF    
    cQuery += "  D_E_L_E_T_ = ' ' " + CRLF
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlsQry, .T., .T.)

    nRet := (cAlsQry)->QTDPROD

    (cAlsQry)->(DbCloseArea())

Return nRet