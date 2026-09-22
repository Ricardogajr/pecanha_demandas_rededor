#include "tbiconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} REDSCH1
//Rotina para importar pedidos de compras do sistema Bionexo.
//(Busca carrinho de compras pedido de compras) = WDG - Libera Pedidos
@author Ricardo
@since 06/06/2017
@version 1.0
@type function
/*/

User Function REDSCH1(aPedidos)

	//cTime := "HORA INICIAL " + Time() + " " + CRLF
	Private aRet := { "1", "OK"}
	Private aItensSc := {}
	Private cItensSc := ""


	fExec(aPedidos)
	//cTime += "HORA FINAL " + Time() + " " + CRLF

	//MemoWrite( "C:\\Temp\\testtime.txt", cTime )
Return aRet

Static Function fExec(aPedidos)

	Local aLinha 	:= {}
	Local nY 		:= 00
	Local cMsg		:= ""
	Local cNumPc	:= ""
	Local aTransf	:= {}
	Local aPedAux	:= {}
	Local aTemp		:= {}
	Local aTemp2    := {}
	Local aFor		:= {}
	Local nX		:= 00
	Local cForne 	:= ""
	Local cLoja 	:= ""
	Local lErro		:= .F.
	Local nXIDBIO 	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cXIDBIO"})
	Local nXITBIO 	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cXITBIO"})
	Local nCGC	  	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cCGC"})
	Local nFILIAL 	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cFilAtu"})
	Local nNUMSC 	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cNUMSC"})
	Local nITEMSC 	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cITEMSC"})
	Local nPRODUTO 	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cPRODUTO"})
	Local nQTSEGUM  := aScan(aPedidos[1], {|x| AllTrim(x[1]) == "nQTSEGUM"})
	Local nPRECO	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "nPRECO"})
	Local nOBS		:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cOBS"})
	Local nCONDPAG	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cCONDPAG"})
	Local nDatPrf	:= aScan(aPedidos[1], {|x| AllTrim(x[1]) == "cDATPRF"})
	Local lFree := .T.
	Local cChaveBio := ""
	Local nTent := 0
	Local lEst := .F.
	Local lnEst := .F.
	Local cProdP17 := ""
	Local cProds := "|"

//	U_WsLogBio("REDSCH1", 1)
	//Correção Duplicidade Bionexo
	//Lucas Miranda	- Inicio
	cChaveBio := aPedidos[1][nFILIAL][2] + aPedidos[1][nXIDBIO][2]
	lFree := MayIUseCode(cChaveBio)

	If !lFree
		nTent := 0
		While !(lFree := MayIUseCode(cChaveBio))
			Sleep(2000)
			If ++nTent > 50
				aRet := { "2", " Controle de semáforo - Já existe uma integração desta filial/ID Bionexo em execução."}
				Exit
			Endif
		Enddo
		If lFree
			Sleep(2000)
		Endif
	Endif
	//Fim


	For nX := 01 To Len(aPedidos)
		//Verifica se é um carrinho que foi gerado via integração.
		If ValType(aPedidos[nX][nITEMSC][2]) != "C"
			//U_WsLogBio("REDSCH1", 2,"ESTE ITEM "+ aPedidos[nX][nXIDBIO][2] + "/" + aPedidos[nX][nXITBIO][2] +" DO PDC NÃO FOI GERADO VIA PROTHEUS")
			Loop
		EndIf

		aFor 		:= U_GetForn(aPedidos[nX][nCGC][2])
		cLocalSc 	:= U_GetLocalSc(aPedidos[nX][nFILIAL][2], aPedidos[nX][nNUMSC][2], aPedidos[nX][nITEMSC][2])
		cEstoque	:= U_GetEstoq(aPedidos[nX][nFILIAL][2], aPedidos[nX][nPRODUTO][2])
		cUMed     	:= Posicione("SB1", 01, xFilial("SB1") + PadR(aPedidos[nX][nPRODUTO][2], TamSx3("B1_COD")[1]), "B1_SEGUM" )

		If aFor[01]//Verifica se encontrou o fornecedor.
			cForne 	:= aFor[02]//Codigo Fornecedor
			cLoja 	:= aFor[03]//Loja Fornecedor
		Else
			//U_REDA006(aPedidos[nX][nFILIAL][2], "2", aPedidos[nX][nNUMSC][2], aPedidos[nX][nITEMSC][2],,"Fornecedor não existe : " + aPedidos[nX][nCGC][2], aPedidos[nX][nXIDBIO][2])
//				U_WsLogBio("REDSCH1", 2,"FORNECEDOR NAO EXISTE: " + aPedidos[nX][nCGC][2])
			aRet 	:= { "2", "FORNECEDOR NAO EXISTE: " + aPedidos[nX][nCGC][2]}
			Loop
		EndIf

		aChaveSc := StrTokArr(aPedidos[nX][nITEMSC][2], ";")
		cPed := ""
		cXIDBio := aPedidos[1][nXIDBIO][2]
		For nY := 01 To Len(aChaveSc)
			If !U_fBuscaSolic(aChaveSc[nY], cXIDBio)
				aRet := { "2", " SOLICITAÇÃO NÃO FOI ENCONTRADA/OU JÁ ESTA TOTALMENTE ATENDIDA. "}
				Exit
			/*/Else
				If SC1->C1_QUANT < aPedidos[nX][nQTSEGUM][2]
					aRet := { "2", "A QUANTIDADE ENVIADA NO XML É MAIOR DO QUE A QUANTIDADE DA SC. CHAVE SC: " + aChaveSc[nY]}
					Exit
				EndIf/*/
			EndIf
		Next nY

		If aRet[1] == "2"
			Return
		EndIf

		//SubStr(aPedidos[nX][nITEMSC][2], TamSx3("C7_FILIAL")[1] + TamSx3("C7_NUMSC")[1] + 1, TamSx3("C7_ITEMSC")[1])
		aItensSc := StrTokArr(aPedidos[nX][nITEMSC][2], ";")
		If Len(aItensSc) > 1
			cItensSc := SubStr(aItensSC[01], TamSx3("C7_FILIAL")[1] + TamSx3("C7_NUMSC")[1] + 1, TamSx3("C7_ITEMSC")[1])
			cNumSc := 	SubStr(aItensSC[01], TamSx3("C7_FILIAL")[1] + 1, TamSx3("C7_NUMSC")[1])
		ElseIf Len(aItensSc) == 1
			cItensSc 	:= SubStr(aPedidos[nX][nITEMSC][2], TamSx3("C7_FILIAL")[1] + TamSx3("C7_NUMSC")[1] + 1, TamSx3("C7_ITEMSC")[1])
			cNumSc 		:= SubStr(aPedidos[nX][nITEMSC][2], TamSx3("C7_FILIAL")[1] + 1, TamSx3("C7_NUMSC")[1])
		EndIf
		aConv := U_FConvUmBio(aPedidos[nX][nPRODUTO][2], aPedidos[nX][nQTSEGUM][2], aPedidos[nX][nPRECO][2], "P")
		aAdd(aTransf, {	aPedidos[nX][nFILIAL][2],;
			cLocalSc,;
			cForne,;
			cLoja,;
			aPedidos[nX][nXIDBIO][2],;
			cEstoque,;
			cItensSc,;
			aPedidos[nX][nPRODUTO][2],;
			cUMed,;
			aConv[01],;//aPedidos[nX][nQTSEGUM][2],;
			aConv[02],;//aPedidos[nX][nPRECO][2],;
			NoAcento(AnsiToOem(AllTrim(aPedidos[nX][nOBS][2]))),;//cSemAcento := NoAcento(AnsiToOem(AllTrim(cGet)))
		aPedidos[nX][nCONDPAG][2],;
			cNumSc,;
			aPedidos[nX][nXITBIO][2],;
			aItensSc,;
			aPedidos[nX][nDatPrf][2]})

	Next nX
	// Ordenar o array de acordo com a chave abaixo:
	//Filial+LocalEst+Fornecedor+Loja+XIDBIO+cESTOQUE

	If Len(aTransf) == 0
		If Len(aRet) == 0
			cMsg := "NÃO FOI INCLUÍDO NENHUM ITEM DO CARRINHO NO PROTHEUS, POR FAVOR, VERIFICAR O LOG DO SISTEMA"
			//U_WsLogBio("REDSCH1", 2, cMsg)
			aRet := { "2", cMsg}
			//U_REDA006(aPedidos[01][nFILIAL][2], "2", aPedidos[01][nNUMSC][2],,,cMsg, aPedidos[01][nXIDBIO][2])
		EndIf
	EndIf

	aPedAux := aSort(aTransf,,, {|x,y| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] < y[1]+y[2]+y[3]+y[4]+y[5]+y[6]})

	For nY := 1 To Len(aPedAux)
		If Len(aTemp) > 0
			If 	aScan(aTemp,{|x| Alltrim(x[1]) == AllTrim(aPedAux[nY][1])}) == 0	.OR.;
					aScan(aTemp,{|x| Alltrim(x[2]) == AllTrim(aPedAux[nY][2])}) == 0	.OR.;
					aScan(aTemp,{|x| Alltrim(x[3]) == AllTrim(aPedAux[nY][3])}) == 0	.OR.;
					aScan(aTemp,{|x| Alltrim(x[4]) == AllTrim(aPedAux[nY][4])}) == 0	.OR.;
					aScan(aTemp,{|x| Alltrim(x[6]) == AllTrim(aPedAux[nY][6])}) == 0  //.OR. nY == Len(aPedAux)

				fImporta(aTemp)

				aTemp := {}
				If POSICIONE( "P17", 1, xFilial("P17")+aPedAux[nY][8]+Space(TamSx3("P17_COD")[1]-Len(aPedAux[nY][8]))+aPedAux[nY][1], "P17_ESTOQ" ) == "S"
					aAdd(aTemp, aPedAux[nY])
				EndIf
			Else
				If POSICIONE( "P17", 1, xFilial("P17")+aPedAux[nY][8]+Space(TamSx3("P17_COD")[1]-Len(aPedAux[nY][8]))+aPedAux[nY][1], "P17_ESTOQ" ) == "S"
					aAdd(aTemp, aPedAux[nY])
				EndIf
			EndIf
		Else
			If POSICIONE( "P17", 1, xFilial("P17")+aPedAux[nY][8]+Space(TamSx3("P17_COD")[1]-Len(aPedAux[nY][8]))+aPedAux[nY][1], "P17_ESTOQ" ) == "S"
				aAdd(aTemp, aPedAux[nY])
			EndIf
		EndIf
	Next nY

	//For para não estocáveis
	For nY := 1 To Len(aPedAux)
		If Len(aTemp2) > 0
			If 	aScan(aTemp2,{|x| Alltrim(x[1]) == AllTrim(aPedAux[nY][1])}) == 0	.OR.;
					aScan(aTemp2,{|x| Alltrim(x[2]) == AllTrim(aPedAux[nY][2])}) == 0	.OR.;
					aScan(aTemp2,{|x| Alltrim(x[3]) == AllTrim(aPedAux[nY][3])}) == 0	.OR.;
					aScan(aTemp2,{|x| Alltrim(x[4]) == AllTrim(aPedAux[nY][4])}) == 0	.OR.;
					aScan(aTemp2,{|x| Alltrim(x[6]) == AllTrim(aPedAux[nY][6])}) == 0  //.OR. nY == Len(aPedAux)


				fImporta(aTemp2)

				aTemp2 := {}
				If POSICIONE( "P17", 1, xFilial("P17")+aPedAux[nY][8]+Space(TamSx3("P17_COD")[1]-Len(aPedAux[nY][8]))+aPedAux[nY][1], "P17_ESTOQ" ) == "N"
					aAdd(aTemp2, aPedAux[nY])
				EndIf
			Else
				If POSICIONE( "P17", 1, xFilial("P17")+aPedAux[nY][8]+Space(TamSx3("P17_COD")[1]-Len(aPedAux[nY][8]))+aPedAux[nY][1], "P17_ESTOQ" ) == "N"
					aAdd(aTemp2, aPedAux[nY])
				EndIf
			EndIf
		Else
			If POSICIONE( "P17", 1, xFilial("P17")+aPedAux[nY][8]+Space(TamSx3("P17_COD")[1]-Len(aPedAux[nY][8]))+aPedAux[nY][1], "P17_ESTOQ" ) == "N"
				aAdd(aTemp2, aPedAux[nY])
			EndIf
		EndIf
	Next nY

	If Len(aTemp) > 0
		fImporta(aTemp)
	EndIf

	If Len(aTemp2) > 0
		fImporta(aTemp2)
	EndIf

Return
/***************************************************
			Posições do array apedidos
****************************************************
01 - cCC7FILIAL,;
02 - cCC7FILIAL, cCC7NUMSC, cCC7ITEM),;
03 - cCC7FORNECE,;
04 - cCC7LOJA,;		
05 - cCC7XIDBIO,;
06 - cCC7ITEM,;
07 - cCC7PRODUTO,;
08 - cCC7SEGUM,;
09 - cCC7DESCRI,;
10 - nNC7QTSEGUM,;
11 - nNC7PRECO,;
12 - cCC7OBS,;
13 - cCC7CONDPAG,;
14 - cCC7NUMSC,;
15 - cCC7XITBIO
****************************************************/		

Static Function fImporta(aTemp)

	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local cNumPc	:= ""
	Local nX		:= 00
	Local nTotal	:= 00
	Local cFilBkp   := ""

	
	cNumPc	:= GetSX8Num("SC7","C7_NUM")
	
	cFilBkp   := cFilAnt
	
	cFilAnt   := aTemp[01][01]
	
	
	aAdd(aCabec,{"C7_EMISSAO",	dDataBase, 		Nil})
	aAdd(aCabec,{"C7_FORNECE",	aTemp[01][03], 	Nil})
	aAdd(aCabec,{"C7_LOJA",		aTemp[01][04], 	Nil})
	aAdd(aCabec,{"C7_COND",		aTemp[01][13], 	Nil})
	aAdd(aCabec,{"C7_CONTATO",	"", 		Nil})
	aAdd(aCabec,{"C7_FILENT",	cFilAnt, 	Nil})
	aAdd(aCabec,{"C7_CONAPRO",	"L", 							Nil})

	For nX := 01 To Len(aTemp)
		nTotal += aTemp[nX][10] * aTemp[nX][11]			
	Next nX 
	//VERIFICA SE É MENOR QUE 25MIL
	If nTotal <= SuperGetMv("MV_XPCBLQ",,25000)
		cCodCpr  := GetMv("FS_CPRINTE")
	Else
		cCodCpr  := Posicione("SC1", 01, PadR(aTemp[01][01], TamSx3("C1_FILIAL")[01]) + PadR(aTemp[01][14], TamSX3("C1_NUM")[01]) + PadR(aTemp[01][07], TamSx3("C1_ITEM")[1]), "C1_XCPBIO")		
	EndIf
	
	cIdUsr   := Posicione("SY1", 1, xFilial("SY1") + cCodCpr, "Y1_USER")
	cUserName := UsrRetName(cIdUsr)
	__CUSERID := cIdUsr 

	//Melhoria para enviar o código do usuário comprador da integração no campo C7_USER (APOS MUDANÇA NO MATA120)
	aAdd(aCabec,{"C7_USER",	cIdUsr, 							Nil})
	
	//U_WsLogBio("REDSCH1", 2, "APROVADOR " + cUserName )
	
	For nX := 1 To Len(aTemp)

		aLinha 		:= {}
		
		aGrpComp 	:= U_GetGrpCom(aTemp[nX][01], aTemp[nX][07], aTemp[nX][14])
		
		nConv 	:= Posicione("SB1", 01, xFilial("SB1") + aTemp[nX][8], "B1_CONV")
		nQuant  := aTemp[nX][10] / nConv 
		
		
		//U_WsLogBio("REDSCH1", 2, "cCodCpr: " + cCodCpr + " cIdUsr: " + cIdUsr + " cUserName: " + cUserName + " cFil" )
		//U_WsLogBio("REDSCH1", 2, "CFILANT " + cFilAnt )
	
		aAdd(aLinha,{"C7_PRODUTO",	aTemp[nX][08], 					Nil})
		aAdd(aLinha,{"C7_ITEM",		StrZero(nX, 4), 				Nil})
		//aAdd(aLinha,{"C7_QTSEGUM",	aTemp[nX][10],					Nil})
		aAdd(aLinha,{"C7_QUANT",	aTemp[nX][10],					Nil})
		aAdd(aLinha,{"C7_PRECO",	aTemp[nX][11],      			Nil})
		//aAdd(aLinha,{"C7_TOTAL",	noRound(aTemp[nX][10] * aTemp[nX][11], 02), 	Nil})
		aAdd(aLinha,{"C7_OBS",		aTemp[nX][12], 					Nil})		
		aAdd(aLinha,{"C7_NUMSC",	aTemp[nX][14], 					Nil})				
		aAdd(aLinha,{"C7_ITEMSC",	aTemp[nX][07], 					Nil})		
		aAdd(aLinha,{"C7_FILENT",	cFilAnt, 						Nil})		
		aAdd(aLinha,{"C7_LOCAL",	Posicione("SC1", 01, PadR(aTemp[nX][01], TamSx3("C1_FILIAL")[01]) + PadR(aTemp[nX][14], TamSX3("C1_NUM")[01]) + PadR(aTemp[nX][07], TamSx3("C1_ITEM")[1]), "C1_LOCAL"), 				Nil})
		aAdd(aLinha,{"C7_CC",	    Posicione("SC1", 01, PadR(aTemp[nX][01], TamSx3("C1_FILIAL")[01]) + PadR(aTemp[nX][14], TamSX3("C1_NUM")[01]) + PadR(aTemp[nX][07], TamSx3("C1_ITEM")[1]), "C1_CC"), 					Nil})
		aAdd(aLinha,{"C7_CONTA",	Posicione("SC1", 01, PadR(aTemp[nX][01], TamSx3("C1_FILIAL")[01]) + PadR(aTemp[nX][14], TamSX3("C1_NUM")[01]) + PadR(aTemp[nX][07], TamSx3("C1_ITEM")[1]), "C1_CONTA"), 				Nil})
		aAdd(aLinha,{"C7_DATPRF",	dDatabase + Val(aTemp[nX][17]), Nil})
		aAdd(aLinha,{"C7_XIDBIO",	aTemp[nX][05], 					Nil})		
		aAdd(aLinha,{"C7_XIDART",	aTemp[nX][15], 					Nil})		
		aAdd(aLinha,{"C7_XCODSET",	Posicione("SC1", 01, PadR(aTemp[nX][01], TamSx3("C1_FILIAL")[01]) + PadR(aTemp[nX][14], TamSX3("C1_NUM")[01]) + PadR(aTemp[nX][07], TamSx3("C1_ITEM")[1]), "C1_XCODSET"), 				Nil})
		aAdd(aLinha,{"C7_QTDSOL",	aTemp[nX][10], 					Nil})
		aAdd(aItens, aLinha)
		
	Next nX 
	
	//VarInfo("aItens", aItens)
	lMsErroAuto := .F.
	
	//U_WsLogBio("REDSCH1", 2, "ANTES DE EXECUTAR A INCLUSÃO DO PEDIDO DE COMPRAS.")                    
	
	MATA120(1, aCabec, aItens, 3)
	
	If !lMsErroAuto		
		cNumPed := SC7->C7_NUM
		cAprov	:= SC7->C7_APROV
		cMsg := "PEDIDO.: " + cNumPed + " foi incluído com sucesso!"
		//Foi necessario fazer o reclock nos campos XIDBIO e XITBIO. Por algum motivo os campos nao estavam sendo gravados via EXECAUTO. 
		For nX := 01 To Len(aTemp)
		    DbSelectArea("SC7")
		    SC7->(DbSetOrder(01))
		    cItemPC := StrZero(nX, 04)
		    //U_WsLogBio("REDSCH1", 2, "INDICE SC7 -> " + cFilAnt + PadR(cNumPed, TamSx3("C7_NUM")[1]) + PadR(cItemPC, TamSx3("C7_NUM")[1]))
			If SC7->(DbSeek(cFilAnt + PadR(cNumPed, TamSx3("C7_NUM")[1]) + PadR(cItemPC, TamSx3("C7_ITEM")[1])))		
				RecLock("SC7", .F.)				
				SC7->C7_XIDBIO 	:= aTemp[nX][5]
				SC7->C7_XIDART 	:= aTemp[nX][15]				
				//SC7->C7_DATPRF  := dDatabase + Val(aTemp[nX][17])
				//U_WsLogBio("REDSCH1", 2, "GRUPO APROVADOR: " + aGrpComp[1] )
				//U_WsLogBio("REDSCH1", 2, "GRUPO COMPRAS: " + aGrpComp[2] )
				//U_WsLogBio("REDSCH1", 2, "nTotal: " + cValToChar(nTotal))								
				
				If nTotal <= MVGetCus("MV_XPCBLQ",25000)
					//U_WsLogBio("REDSCH1", 2, "USER  " + SC7->C7_USER   )
					cCodCpr  		:= Posicione("SC1", 01, PadR(aTemp[01][01], TamSx3("C1_FILIAL")[01]) + PadR(aTemp[01][14], TamSX3("C1_NUM")[01]) + PadR(cItemPC, TamSx3("C1_ITEM")[1]), "C1_XCPBIO")
					SC7->C7_USER   	:= Posicione("SY1", 01, xFilial("SY1") + cCodCpr, "Y1_USER")
					//U_WsLogBio("REDSCH1", 2, "PEDIDO " + cNumPed + " LIBERADO " )
				Else
					//U_WsLogBio("REDSCH1", 2, "PEDIDO " + cNumPed + " BLOQUEADO " )
					fAtuSCR(cFilAnt, cNumPed, nTotal, cIdUsr)
				EndIf
				SC7->(MsUnlock())
				If fFinalSc(aTemp[nX][16], cNumPed, PadR(cItemPC, TamSx3("C1_ITEM")[1]) )
					//U_WsLogBio("REDSCH1", 2, "ATUALIZADA A SOLICITAÇÃO DE COMPRAS " + SC7->C7_FILIAL + SC7->C7_NUMSC + SC7->C7_ITEMSC )
				Else
					//U_WsLogBio("REDSCH1", 2, "NÃO FOI ATUALIZADA A SOLICITAÇÃO DE COMPRAS " + SC7->C7_FILIAL + SC7->C7_NUMSC + SC7->C7_ITEMSC )
				EndIf
			EndIf
		Next nX		
	Else
		//cIdProc := AllTrim(FWUUIDV4())
		cMsg := Mostraerro("\temp", "ERROR_" + Time() + ".log") 	
		//U_REDA006(cFilAnt, "2",,,,cMsg, aTemp[01][05])
		aRet := { "2", cMsg}		
	EndIf
	
	//U_WsLogBio("REDSCH1", 3, cMsg)
	cFilAnt := cFilBkp

Return aRet
*-----------------------------------------------------*
Static Function fFinalSc(aChave, cPedido, cItem)
*-----------------------------------------------------*
	Local aArea := GetArea()
	Local lRet  := .F.
	Local nX
	For nX := 01 To Len(aChave)
		DbSelectArea("SC1")
		SC1->(DbSetOrder(01))
		If SC1->(DbSeek(aChave[nX]))
			RecLock("SC1", .F.)
			SC1->C1_QUJE 	:= SC1->C1_QUANT
			SC1->C1_PEDIDO 	:= cPedido
			SC1->C1_ITEMPED := cItem			
			SC1->(MsUnlock())
			lRet := .T.	
		EndIf
	Next nX	
	RestArea(aArea)
Return lRet  

*-----------------------------------------------------------*
Static Function fAtuSCR(cFilSCR, cNumPed, nTotal, cCodCpr)
*-----------------------------------------------------------*
	Local nX := 01
	Local nValBlq 	 := SuperGetMv("MV_XPCBLQ",,25000)
	Local lAtualComp	 := .F.
	Local lPrim2 		 := .T.	


	cMsg := "ATUALIZANDO SCR : " + PadR(cFilSCR, TamSX3("CR_FILIAL")[01]) + PadR("PC", TamSx3("CR_TIPO")[01]) + PadR(cNumPed, TamSX3("CR_NUM")[01]) + CRLF
	
	DbSelectArea("SCR")
	SCR->(DbSetOrder(01))
	If SCR->(DbSeek(PadR(cFilSCR, TamSX3("CR_FILIAL")[01]) + PadR("PC", TamSx3("CR_TIPO")[01]) + PadR(cNumPed, TamSX3("CR_NUM")[01])))
		cMsg += "ENCONTROU O REGISTRO NA SCR" + CRLF
		While !SCR->(Eof()) .And. AllTrim(cFilSCR) == AllTrim(SCR->CR_FILIAL) .And. AllTrim(cNumPed) == AllTrim(SCR->CR_NUM)
			If AllTrim(SCR->CR_NIVEL) == "01" 
				If AllTrim(SCR->CR_USER) == AllTrim(cCodCpr)
					fAtuSCS(SCR->CR_FILIAL,SCR->CR_APROV,SCR->CR_USER,dDatabase,nValBlq,SCR->CR_MOEDA)
					RecLock("SCR", .F.)
					SCR->CR_STATUS  := "03"
					SCR->CR_LIBAPRO := SCR->CR_APROV
					SCR->CR_DATALIB := dDatabase
					SCR->CR_VALLIB	:= nValBlq
					SCR->CR_TIPOLIM := Posicione("SAK", 01, SCR->CR_FILIAL + SCR->CR_APROV, "AK_TIPO")
					SCR->(MsUnlock())
					lAtualComp := .T.
					cMsg += "ATUALIZOU O PRIMEIRO NIVEL " + CRLF

					
				Else			
					RecLock("SCR", .F.)
					SCR->CR_STATUS  := "05"
					cMsg += "USUARIO " + SCR->CR_USER + " NIVEL 01 NAO É COMPRADOR "  + CRLF
					SCR->(MsUnlock())					
				EndIf			
			EndIf	
			If AllTrim(SCR->CR_NIVEL) == "02"
				If !lAtualComp
					cMsg := " NAO FOI ENCONTRADO O COMPRADOR NO PRIMEIRO NIVEL"
					U_WsLogBio("REDSCH1", 2, cMsg)
					Exit
				EndIf
				If lPrim2
					fAtuSCS(SCR->CR_FILIAL,SCR->CR_APROV,SCR->CR_USER,dDatabase,nValBlq,SCR->CR_MOEDA)
					RecLock("SCR", .F.)
					SCR->CR_STATUS  := "03"
					SCR->CR_LIBAPRO := SCR->CR_APROV
					SCR->CR_DATALIB := dDatabase
					SCR->CR_VALLIB	:= nValBlq
					SCR->CR_TIPOLIM := Posicione("SAK", 01, SCR->CR_FILIAL + SCR->CR_APROV, "AK_TIPO")
					SCR->(MsUnlock())
					lPrim2 := .F.
					cMsg += "ATUALIZOU O SEGUNDO NIVEL " + CRLF
				Else			
					RecLock("SCR", .F.)
					SCR->CR_STATUS  := "05"
					SCR->(MsUnlock())					
				EndIf			
			EndIf				
			If AllTrim(SCR->CR_NIVEL) == "03" 
				RecLock("SCR", .F.)
				SCR->CR_STATUS  := "02"
				SCR->(MsUnlock())
			EndIf	
			SCR->(DbSkip())
		EndDo
	Else
		cMsg += "NAO ENCONTROU O REGISTRO NA SCR"			
	EndIf
	//U_WsLogBio("REDSCH1", 2, cMsg)
Return 
Static Function MVGetCus(cParam1, cParam2)
Return SuperGetMv(cParam1,,cParam2)


/*/
Função para atualizar o saldo diário na tabela SCS.
Função criada para evitar erro na eliminação de resíduo, já que a integração não atualiza esse saldo automaticamente nos dois primeiros níveis que já vem aprovados do Bionexo.
Lucas Miranda de Aguiar - 07/08/2024
/*/
Static Function fAtuSCS(cFilCr,cUsrAprov,cUsrCr,dDataLib,nValLib,nMoeda)

Local aArea := GetArea()
Local nSldMax := 0

DbSelectArea("SCS")
SCS->(DbSetOrder(1))

If SCS->(DbSeek(cFilCr+cUsrCr+DtoS(dDataLib)))
	Reclock("SCS",.F.)
	SCS->CS_SALDO := SCS->CS_SALDO - nValLib
	SCS->(MsUnLock())
Else

	nSldMax := Posicione("SAK", 01, FwXFilial("SAK") + cUsrAprov, "AK_LIMITE" )
	Reclock("SCS",.T.)
	SCS->CS_FILIAL := cFilCr
	SCS->CS_COD 	:= cUsrCr
	SCS->CS_APROV  := cUsrAprov
	SCS->CS_DATA   := dDataLib
	SCS->CS_MOEDA  := nMoeda
	SCS->CS_SALDO  := nSldMax - nValLib

	SCS->(MsUnLock())
EndIf

RestArea(aArea)
Return
