#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TBICONN.CH'
#include 'topconn.ch'

/*/{Protheus.doc} REDSCH2
//Rotina para importar Contratos de compras do sistema Bionexo
//(Busca carrinho de compras contrato) = WFG - Gerar Contratos para todas as empresas
@author Ricardo
@since 06/06/2017
@version 1.0
@type function
/*/
*--------------------------------*
user function REDSCH2(aCotacao)
*--------------------------------*
	Local nX := 00
	Local nY := 00
	Local nJ := 00
	Local cLocal 	:= ""
	Local cObs 		:= ""
	Local aforn 	:= {}
	Local aCotacoes := {}
	Local aTransf 	:= {}
	Local aTemp 	:= {}
	Local aHead 	:= {"C8_NUM",;
						"C8_ITEM",;
						"C8_FILIAL",;
						"",;
						"C8_FORNECE",;
						"C8_LOJA",;
						"C8_TPDOC",;
						"C8_XIDBIO",;
						"C8_COND",;
						"",;
						"C8_ITEMSC",;
						"C8_OBS",;
						"C8_PRECO",;
						"C8_PRODUTO",;
						"C8_QTSEGUM",;
						"C8_SEGUM",;
						"C8_NUMSC",;
						"C8_TOTAL",; 
						"C8_NUMPRO",; 
						"C8_PRAZO",; 
						"C8_FILENT",; 
						"C8_EMISSAO",;
						"C8_GRUPCOM",; 
						"C8_QUANT",;
						"C8_UM",;
						"C8_FORNOME",;
						"C8_VALIDA",;
						"C8_DATPRF",;
						"C8_XCTBIO" }//C8_XCTBIO

	Local nXIDBIO 	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cXIDBIO"})
	Local nCGC	  	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cCGC"})
	Local nFilial 	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cFILIAL"}) 
	Local nNUMSC 	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cNUMSC"})
	Local nITEMSC 	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cITEMSC"})
	Local nPRODUTO 	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cPRODUTO"})
	Local nQTSEGUM  := aScan(aCotacao[1], {|x| AllTrim(x[1]) == "nQTSEGUM"})
	Local nPRECO	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "nPRECO"})
	Local nOBS		:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cOBS"})
	Local nCONDPAG	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cCONDPAG"})
	Local nPrazo	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "nPrazo"})
	Local nStatus   := aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cStatus"})
	Local nTipo     := aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cTipo"})
	Local nCtBio	:= aScan(aCotacao[1], {|x| AllTrim(x[1]) == "cXCTBIO"})
	
	Private aRet := {"1", "OK"}
	
	For nX := 01 To Len(aCotacao)
			
		//Verifica se é um carrinho que foi gerado via integração.
		If ValType(aCotacao[nX][nItemSc][2]) != "C"
			//U_WsLogBio("REDSCH2", 2,"O PDC "+ aCotacao[nX][nXIdBio][2] +" NÃO FOI GERADO VIA PROTHEUS")
			aRet[1] := "2"
			aRet[2] := "O PDC "+ aCotacao[nX][nXIdBio][2] +" NÃO FOI GERADO VIA PROTHEUS"
			Return aRet
		EndIf
		
		aCotacao[nX][nProduto][2] := GetProdSc(Separa(aCotacao[nX][nItemSc][2],";",.F.)[01])
		
		cFilSC1 := Substr(aCotacao[nX][nItemSc][2],01, 08)
		cNumSC1 := Substr(aCotacao[nX][nItemSc][2],09, 06)
		cItemSC1 := Substr(aCotacao[nX][nItemSc][2],15, 04) 
		
		cLocal 	:= U_GetLocalSc(cFilSC1, cNumSC1, cItemSC1)
		aforn 	:= U_GetForn(aCotacao[nX][nCGC][2])
		
		If !aforn[1]
			cObs := "Não foi encontrado fornecedor para o CNPJ " + aCotacao[nX][nCGC][2]
			U_REDA006(aCotacao[nX][nFilial][2],;
							"1",;
							aCotacao[nX][nNumSc][2],; 
							aCotacao[nX][nItemSc][2], ,; 
							cObs,; 
							aCotacao[nX][nXIdBio][2] )
            aRet := {"2",  cObs}									    
			Loop
		EndIf
		
		nConv 	:= Posicione("SB1", 1, xFilial("SB1") + aCotacao[nX][nProduto][2], "B1_CONV")
		aConv 	:= U_FConvUmBio(aCotacao[nX][nPRODUTO][2], aCotacao[nX][nQTSEGUM][2], aCotacao[nX][nPRECO][2], "P")
		nQuant2 := aConv[01] / nConv
		nTotal 	:= aConv[01] * aConv[02]
		aAdd(aTransf, {	"",;
		 				"",; 
		 				aCotacao[nX][nFilial][2],;//aCotacao[nX][nFilial][2],;
		 				cLocal,;
		 				aforn[2],;
		 				aforn[3],;
		 				"2",;
		 				aCotacao[nX][nXIdBio][2],;
		 				aCotacao[nX][nCondPag][2],;
		 				Posicione("SB1", 1, aCotacao[nX][nFilial][2] + aCotacao[nX][nProduto][2], "B1_DESC"),;
		 				"",;//ITEMSC
		 				aCotacao[nX][nItemSc][2],;//OBS
		 				aConv[02],;//aCotacao[nX][nPreco][2],;
		 				aCotacao[nX][nProduto][2],;
		 				nQuant2,;//aCotacao[nX][nQtSegum][2],;
		 				Posicione("SB1", 1, xFilial("SB1") + aCotacao[nX][nProduto][2], "B1_SEGUM"),;
		 				"",;//aCotacao[nX][nNumSc][2] NUMSC
		 				nTotal,;
		 				"01",; 
		 				nPrazo,;
		 				cFilAnt,; 
		 				dDatabase,;
		 				"",;//U_GetGrpCom(aCotacao[nX][nItemSc][2]),;
		 				aConv[01],;
		 				Posicione("SB1", 1, xFilial("SB1") + aCotacao[nX][nProduto][2], "B1_UM"),;
		 				Posicione("SA2", 1, xFilial("SA2") + aforn[2] + aforn[3], "A2_NOME"),;
		 				dDataBase + nPrazo,; 
		 				dDataBase + nPrazo,;
		 				aCotacao[nX][nCtBio][2] })
	Next nX

	// Ordenar o array de acordo com a chave abaixo:
	//Filial+ContratoBio+LocalEst+Fornecedor+GERACTR+XIDBIO 
	aCotacoes := aSort(aTransf,,, {|x,y| x[3]+x[29]+x[4]+x[5]+x[6]+x[7]+x[8] < y[3]+x[29]+y[4]+y[5]+y[6]+y[7]+y[8]})
	//U_WsLogBio("REDSCH2", 2, "TAMANHO DE ACOTACOES " + cValToChar(Len(aCotacoes)))
	//VarInfo("aCotacoes", aCotacoes)
	For nY := 1 To Len(aCotacoes)
		//U_WsLogBio("REDSCH2", 2, "FOR NY IGUAL " + cValToChar(nY))
		
		If Len(aTemp) > 0
			//U_WsLogBio("REDSCH2", 2, "ENTROU NO ATEMP " + cValToChar(Len(aTemp)))
			//VarInfo("aTemp", aTemp)		
			// Se achar alguma quebra, de acordo com a regra, entra para executar a importação
			// Regra para quebra de cotação: Filial+ContratoBio+LocalEst+Fornecedor+GERACTR+XIDBIO 
			If  aScan(aTemp,{|x| Alltrim(x[3]) 	== AllTrim(aCotacoes[nY][3])}) 	== 0	.OR.;
				aScan(aTemp,{|x| Alltrim(x[4]) 	== AllTrim(aCotacoes[nY][4])}) 	== 0	.OR.;
				aScan(aTemp,{|x| Alltrim(x[5]) 	== AllTrim(aCotacoes[nY][5])}) 	== 0	.OR.;
				aScan(aTemp,{|x| Alltrim(x[6]) 	== AllTrim(aCotacoes[nY][6])}) 	== 0	.OR.;
				aScan(aTemp,{|x| Alltrim(x[7]) 	== AllTrim(aCotacoes[nY][7])}) 	== 0	.OR.;
				aScan(aTemp,{|x| Alltrim(x[8]) 	== AllTrim(aCotacoes[nY][8])}) 	== 0 	.OR.;
				aScan(aTemp,{|x| Alltrim(x[29]) == AllTrim(aCotacoes[nY][29])}) == 0
				
				//U_WsLogBio("REDSCH2", 2, "ENTROU NO ASCAN " + VarInfo("aCotacoes - ASCAN", aCotacoes[nY]) )
				//Executa a importação 	
				fImporta(aHead,aTemp)

				//limpa o aTemp e preenche com a posição atual
				aTemp := {}
				aAdd(aTemp, aCotacoes[nY])
			Else
				//U_WsLogBio("REDSCH2", 2, "ELSE DO ASCAN")
				aAdd(aTemp, aCotacoes[nY])
			EndIf
		Else
			//U_WsLogBio("REDSCH2", 2, "ELSE DO ATEMP")
			aAdd(aTemp, aCotacoes[nY])
		EndIf
	Next
	
	fImporta(aHead, aTemp)
	//RpcClearEnv()
return aRet
*------------------------*
Static Function fImporta(aCabec,aTemp)	
*------------------------*
	Local cNumCotacao := ""
	Local nY 		:= 00
	Local nX 		:= 00
	Local nJ 		:= 01
	Local cTipo 	:= ""
	Local lCotinua 	:= .F.
	Local nPosFil 	:= 0
	Local nPosSC  	:= 0
	Local nPosIt  	:= 0
	Local nPosIdBio := 0
	Local _aReturn	:= {} //Thais Paiva - Compatibilização P27
	Local lRet	:= .T. //Thais Paiva - Compatibilização P27
	
	cFilBkp := cFilAnt
	//cFilAnt := SuperGetMv("MV_XFILCTR",,"01010004")
	
	cNumCotacao := GetSxENum("SC8","C8_NUM")
	
	// cadastrar tabela de preços
	If Len(aTemp) > 0
		lCotinua := xComa010(aCabec, aTemp, cNumCotacao) 
	EndIf
	
	If lCotinua
			nPosFil 	:= aScan(aCabec, "C8_FILIAL")
			nPosSC  	:= aScan(aCabec, "C8_NUMSC" )
			nPosIt  	:= aScan(aCabec, "C8_ITEMSC")
			nPosIdBio  	:= aScan(aCabec, "C8_XIDBIO")
			nPosQuant  	:= aScan(aCabec, "C8_QUANT")
		
		VarInfo("fImporta - aTemp", aTemp)
		//Incluindo a cotação
		BEGIN TRANSACTION
		For nY := 01 To Len(aTemp)
			DbSelectArea("SC8")		
			RecLock("SC8",.T.)			
			// Número da cotação
			&("SC8->"+aCabec[1]) := cNumCotacao
			// Item da cotação	
			&("SC8->"+aCabec[2]) := StrZero(nY,4)
			//U_WsLogBio("REDSCH1", 2, "CRIANDO A COTACAO: " + cNumCotacao)						
			For nX := 3 To Len(aCabec)
				If !Empty(aCabec[nX])
					cTipo := POSICIONE("SX3",2,aCabec[nX],"X3_TIPO")
					FieldPut(FieldPos(aCabec[nX]), aTemp[nY][nX])									
				EndIf
			Next nX			
			SC8->(MsUnLock())
			//U_WsLogBio("REDSCH1", 2, "COTACAO CRIADA COM SUCESSO: " + cNumCotacao)									
			aAreaSC8 := SC8->(GetArea())
			aItensSC := StrTokArr(aTemp[nY][12], ";")
			DbSelectArea("SC1")
			SC1->(DbSetOrder(01))
			For nZ := 01 To Len(aItensSC)				
				//U_WsLogBio("REDSCH1", 2, "FOR DE AITENSSC: " + aItensSC[nZ])													
				If SC1->(DbSeek(AllTrim(aItensSC[nZ])))
					If SC1->C1_QUJE > 0
						aRet[1] := "2"
						aRet[2] := "A Filial:"+ SC1->C1_FILIAL +" Numero:"+SC1->C1_NUM+" Item:"+C1_ITEM +" já esta atendido"
						DisarmTransaction()
						Break
					EndIf
					RecLock("SC1", .F.)
					SC1->C1_QUJE    := aTemp[nY][24]//Quantidade
					//SC1->C1_XENVBIO := "2"
					SC1->C1_GERACTR := "1"
					SC1->C1_XINFPAC	:= AllTrim(SC1->C1_XINFPAC) + " COTACAO: "+ aTemp[nY][nPosFil] + cNumCotacao
					SC1->C1_COTACAO := "XXXXXX"
					SC1->(MsUnLock())
					//U_WsLogBio("REDSCH1", 2, "ENCONTROU A SOLICITACAO " + aItensSC[nZ] + " E ATUALIZOU OS FLAGS")					
				Else
					//Início - Thais Paiva - Compatibilização P27
					//Return { "2",  "NAO ENCONTROU SOLICITACAO " + aItensSC[nZ] + " E NAO ATUALIZOU O STATUS."} 
					lRet := .F.
					_aReturn := { "2",  "NAO ENCONTROU SOLICITACAO " + aItensSC[nZ] + " E NAO ATUALIZOU O STATUS."}
					EXIT
					//Fim - Thais Paiva - Compatibilização P27
					//U_WsLogBio("REDSCH1", 2, "ENCONTROU A SOLICITACAO " + aItensSC[nZ] + " E ATUALIZOU OS FLAGS")		
				EndIf
			Next nZ
			RestArea(aAreaSC8)						
			//Início - Thais Paiva - Compatibilização P27
			If !lRet
				EXIT
			EndIf
			//Fim - Thais Paiva - Compatibilização P27
		Next nY
		//Início - Thais Paiva - Compatibilização P27
		If !lRet
			RollbackSx8()
		Else
		//Fim - Thais Paiva - Compatibilização P27
			ConfirmSX8()	
		EndIf //Thais Paiva - Compatibilização P27
		END TRANSACTION
	EndIf
	cFilAnt := cFilBkp
//Return Thais Paiva - Compatibilização P27
Return Iif(lRet,"",_aReturn)

*---------------------------------------------------------*
Static Function xComa010(aCabx, aTemp, cNumCotacao)
*---------------------------------------------------------*
	Local PARAMIXB1 := 3
	Local PARAMIXB2 := {}
	Local PARAMIXB3 := {}
	Local aCabec 	:= {} 
	Local aItens	:= {}
	Local alinha	:= {}
	Local nX 	  := 0
	Local nPosFil := 0
	Local nPosSC  := 0
	Local nPosIt  := 0
	Local nPosIdBio   := 0
	Local nPosCodFor  := 0
	Local nPosLojFor  := 0
	Local nPosCodPro  := 0
	Local nPospreco   := 0
	Local cMsg    := ""
	Local cCodTab := ""
	Local cFilTabela := SuperGetMv("MV_XFILCTR",,"01010004")
	PRIVATE lMsErroAuto := .F.
	
	cFilBkp := cFilAnt
	cFilAnt := cFilTabela
	
	nPosFil    := aScan(aCabx, "C8_FILIAL"	)
	nPosSC     := aScan(aCabx, "C8_NUMSC"	)
	nPosIt     := aScan(aCabx, "C8_ITEMSC"	)
	nPosIdBio  := aScan(aCabx, "C8_XIDBIO"	)
	nPosCtBio  := aScan(aCabx, "C8_XCTBIO"	)
	nPosCodFor := aScan(aCabx, "C8_FORNECE"	)
	nPosLojFor := aScan(aCabx, "C8_LOJA"	)
	nPosCodPro := aScan(aCabx, "C8_PRODUTO"	)
	nPospreco  := aScan(aCabx, "C8_PRECO"	)

	cCodTab := GetSx8Num("AIA","AIA_CODTAB")
	ConfirmSX8()
	
	aAdd(aCabec,{"AIA_FILIAL", cFilTabela ,nil})
	aAdd(aCabec,{"AIA_CODFOR", aTemp[1][nPosCodFor],})	
	aAdd(aCabec,{"AIA_LOJFOR", aTemp[1][nPosLojFor],})	
	aAdd(aCabec,{"AIA_CODTAB", cCodTab			   ,})	
	aAdd(aCabec,{"AIA_DESCRI", "Contrato Bionexo: " + aTemp[1][nPosCtBio],})	
	aAdd(aCabec,{"AIA_DATDE" , dDatabase,})	
	aAdd(aCabec,{"AIA_DATATE", dDatabase + 365,		nil})			
	aAdd(aCabec,{"AIA_XIDBIO", aTemp[1][nPosIdBio],	nil})	
	aAdd(aCabec,{"AIA_XNUMCO", cNumCotacao,			nil})			
	
	For nX := 1 To Len(aTemp)

		aAdd(aLinha,{"AIB_FILIAL", cFilTabela,		nil})	
		aAdd(aLinha,{"AIB_CODPRO", aTemp[nX][nPosCodPro],})	
		aAdd(aLinha,{"AIB_DESCRI", POSICIONE("SB1",1,xFilial("SB1")+aTemp[nX][nPosCodPro],"B1_DESC"),})	
		aAdd(aLinha,{"AIB_PRCCOM", aTemp[nX][nPospreco],})	
		aAdd(aLinha,{"AIB_DATVIG", dDataBase,				nil})
		aAdd(aLinha,{"AIB_CODTAB", cCodTab,				nil})
		
		aAdd(aItens, aLinha)
		aLinha	:= {}

	Next

	PARAMIXB2 := aCabec
	PARAMIXB3 := aItens
	
	MSExecAuto({|x,y,z| coma010(x,y,z)},PARAMIXB1,PARAMIXB2,PARAMIXB3)		

	If lMsErroAuto		
		cPath := GetSrvProfString("StartPath", "")
		cMsg := MostraErro(cPath, "ERROR_.log")//Mostraerro("C:\temp\", "ERROR_" + Time() + ".log")
		For nX := 1 To Len(aTemp)
			U_REDA006(aTemp[nX][nPosFil], "1",aTemp[nX][nPosSC],aTemp[nX][nPosIt],,cMsg, aTemp[nX][nPosIdBio] )									   
		Next
		aRet := {"2",  cMsg}
		ROLLBACKSX8()
	Else
		ConfirmSX8()
	EndIf	
	cFilAnt := cFilBkp 	
Return !lMsErroAuto
*----------------------------------------------------------*
Static Function GetProdSc(cChave)
*----------------------------------------------------------*
	Local cCod := ""
	Local aArea  := GetArea()
	
	DbSelectArea("SC1")
	SC1->(DbSetOrder(01))
	If SC1->(DbSeek(cChave))
		cCod := AllTrim(SC1->C1_PRODUTO)
	EndIf
	RestArea(aArea)
	
Return cCod