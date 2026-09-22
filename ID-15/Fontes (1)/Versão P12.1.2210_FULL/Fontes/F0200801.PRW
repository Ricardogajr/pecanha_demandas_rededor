#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

#DEFINE nITEMA 01
#DEFINE nITEMB 02
#DEFINE nITEMC 03
#DEFINE nITEMD 04
#DEFINE nITEME 05
#DEFINE nITEMF 06
#DEFINE nITEMG 07
#DEFINE nITEMH 08
#DEFINE nITEMI 09
#DEFINE nITEMJ 10
#DEFINE nITEMK 11
#DEFINE nITEML 12
#DEFINE nITEMM 13
#DEFINE nITEMN 14
#DEFINE nITEMO 15
#DEFINE nITEMP 16
#DEFINE nITEMQ 17
#DEFINE nITEMR 18
#DEFINE nITEMS 19
#DEFINE nITEMT 20
#DEFINE nITEMU 21
#DEFINE nITEMV 22
#DEFINE nITEMX 23
#DEFINE nITEMY 24
#DEFINE nITEMZ 25
#DEFINE nITEMW 26
#DEFINE nITEMA2 27
#DEFINE nITEMB2 28
#DEFINE nITEMC2 29

/*
{Protheus.doc} F0200801()
Report Diretoria de Suprimentos e Diretoria Executiva de Serviços.
@Author     Luiz Enrique 
@Since      21/07/2016
@Version    P12.7
@Project    MAN00000463301_EF_008
@Return    
*/

User Function F0200801()

	Local   cProduto	:= ''
	Local	 cCategor	:= ''
	Local	 cmsg		:= ''
	Local 	 oReport
	Local	 lsair		:= .f.
	
	Private nSalC		:= 0
	Private nSalNC	:= 0
	Private nSalALM 	:= 0
	Private nPerc		:= 0
	Private nQtSKU	:= 0
	Private nQNSKU	:= 0
	Private nEstCo	:= 0
	Private vpTmpDB	:= ""
	Private cIndex	:= ""
	Private aStrCmp	:= {}
	Private nVTSCM	:= 0
	Private nVTSC3	:= 0
	Private nVTSC6	:= 0
	Private nVTSC9	:= 0
	Private nVTS12	:= 0
	Private nQTDPCS	:= 0
	Private nVALPCS	:= 0
	Private nGQTDPCS	:= 0
	Private nGVALPCS	:= 0
	Private nGCMD		:= 0
	Private nSalTM	:= 0
	Private nMeta		:= 0
	Private nIdeal	:= 0
	Private nMGIRPCS	:= 0
	Private nMtPCS	:= 0
	Private nDRPCS	:= 0
	Private nGRPCS	:= 0
	Private nNSPCS	:= 0
	Private nTDISM	:= 0
	Private nVLTOTM	:= 0
	Private nQTTOTM 	:= 0
	Private cFilBKP  	:= cFilAnt
	
	Private aMes		:= {}	//Aramzena os Totais mes a Mes (Periodo de 1 Ano)
	
	
	Do While .t.		
		If !Pergunte("FSW0200801",.T.)
			lsair:=.t.
			Exit
		Else
			IF Empty(MV_PAR02) .And. Empty(MV_PAR03)
				cmsg:="A Geração deste Relatório sem o filtro de Produto" + CRLF
				cmsg +="ou Categoria, poderá levar muito Tempo." + CRLF + CRLF
				cmsg +="Confirma o processamento sem estes filtros ?"
				If ! MsgYesNo(cmsg)
					Loop
				EndIf
				Exit
			Endif
			If !Empty(MV_PAR02)
				cProduto:= Padr(MV_PAR02,TamSx3("B1_COD")[1])
				SB1->(DbSetOrder(1))
				If !SB1->(DbSeek(xFilial("SB1") + cProduto))
					alert("Produto Inválido.")
					Loop
				Endif
			Endif
			If !Empty(MV_PAR03)
				cCategor:= Padr(MV_PAR03,TamSx3("ACV_CATEGO")[1])
				ACV->(DbSetOrder(1))
				If !ACV->(DbSeek(xFilial("ACV") + cCategor))
					alert("Categoria Inválida.")
					Loop
				Endif
			Endif
			IF !Empty(MV_PAR02) .And. !Empty(MV_PAR03)
				ACV->(DbSetOrder(5))
				If !ACV->(DbSeek(xFilial("ACV") + cProduto + cCategor))
					alert("Produto Inválido para a categoria Informada.")
					Loop
				Endif
			Endif
			Exit
		EndIf			
	Enddo
		
	If !lsair
		MsgRun(Time() + " - Processando Relatório. Aguarde.",,{|| GeraExcel()})
	Endif		
	
Return

Static Function GeraExcel()

Local aArea	:= GetArea()
Local dMesIni	:= Substr(DtoS(MV_PAR01),1,6) + "01"
Local dMesFim	:= DtoS(LastDate(MV_PAR01))
Local nDias	:= LastDate(MV_PAR01)- Stod(dMesIni) 
Local d3Mes	:= DtoS(MonthSub(StoD(dMesFim),3))
Local d6Mes	:= DtoS(MonthSub(StoD(dMesFim),6))
Local d9Mes	:= DtoS(MonthSub(StoD(dMesFim),9))
Local d12Mes	:= DtoS(MonthSub(StoD(dMesFim),12))
Local cFSALM	:= SuperGetMv("FS_ALM")
Local aTodfil	:= StrTokArr(MV_PAR04,';')
Local nQtds1	:= 0
Local nQtds2	:= 0
Local nQtdReq	:= 0
Local nCusReq	:= 0
Local nQtdDev	:= 0
Local nCusDev	:= 0
Local aSaldo	:= {}
Local nPolit	:= 0
Local nCMD		:= 0
Local nTotCMD	:= 0
Local nItCSa	:= 0
Local nForFil	:= 0
Local cXFil	:= ''
Local cProduto:= Padr(MV_PAR02,TamSx3("B1_COD")[1])
Local cChaveB2:= ''
Local cCategor:= Padr(MV_PAR03,TamSx3("ACV_CATEGO")[1])
Local aColMes	:= {}

//Declaração das Areas
Local cASB2	:= GetNextAlias()	//Alias para lista dos Saldos dos Produtos
Local cASB9	:= GetNextAlias()	//Alias para lista dos Saldos no Mes Em Questão
Local cASB9a	:= GetNextAlias()	//Alias para lista dos Custos nos utltimos 12 Meses 
Local cASD3S	:= GetNextAlias()	//Alias Para Lista das Saidas - Requisições
Local cASD3E	:= GetNextAlias()	//Alias Para Lista das Entradas - Devoluções
Local cASD3R	:= GetNextAlias()	//Alias para Analise dos Itens Sem Movimentação (Resquisição SD3)
Local cASD1S	:= GetNextAlias()	//Itens Sem Movimentação 

Local oFwMsEx := NIL
Local cArq 	:= ""
Local cDir 	:= GetSrvProfString("Startpath","")
Local cWorkSheet := "Rel_Supri_" + dMesFim
Local cTable 	:= "Diretoria de Suprimentos  -  Emissão: " + Dtoc(DDatabase) + " - " +  Time()
Local cDirTmp := GetTempPath()
Local nx		:= 0
Local nMes		:=0
Local cxMes	:= ''
Local cXMesAno:= ''
Local dDataCab:= Ddatabase
Local aProds	:= {}
Local nProds	:= 0
Local lSemCatg:= .f.// Produto sem categoria
Local cTxtCol1:= ''
Local dMaiorDT:= ''
Local lmesatu	:= .f.

//Inicializa Planilha			   
oFwMsEx := FWMsExcelEx():New()

//Aparencias:
//FWMsExcel():SetTitleSizeFont(12)
oFwMsEx:SetTitleSizeFont(12)
oFwMsEx:SetFontSize(10)
//oFwMsEx:SetTitleFrColor("#F5F5DC") 	// Cor da Fonte do Título
oFwMsEx:SetFrColorHeader("#FFD700")	// Cor do Fundo do Cabeçalho
//oFwMsEx:SetLineFrColor("#00008B")	// Cor da Linha 1

//Montagem da Estrutura
oFwMsEx:AddWorkSheet( cWorkSheet )
oFwMsEx:AddTable( cWorkSheet, cTable )	

//DEFINE AS COLUNAS DO RELATÓRIOS
//12 Meses retorativo a partir da Data base

If !Empty(MV_PAR02) 
	cTxtCol1:= "Produto: " + Alltrim (MV_PAR02)
Endif

If !Empty(MV_PAR03)
	cTxtCol1 += " Categoria: " + Alltrim (MV_PAR03)
Endif

oFwMsEx:AddColumn(cWorkSheet, cTable,"Total Geral: " + cTxtCol1, 1,1)

dDataCab:= Stod(dMesFim)
For nx:= 1 To 12
	cxMes:= MesExtenso(MONTH(dDataCab))
	cXMesAno:= cxMes + "/" + Alltrim(Str(Year(dDataCab))) 	
	oFwMsEx:AddColumn( cWorkSheet, cTable,cXMesAno, 2,2)
	dDataCab:=dDataCab - Last_Day(dDataCab)
Next

// Monta e Processa as Linhas do Relatório
	
MakeSqlExpr("FSW0200801")
	
ACV->(DbSetOrder(5))	//Filial + Produto + Categoria
ACU->(DbSetOrder(1))	//Filial + Categoria
SB1->(DbSetOrder(1))	//Filial + Produto
SB2->(DbSetOrder(1))	//Filial + Produto + Local
SB9->(DbSetOrder(1))	//Filial + Produto 
	
IF Empty(MV_PAR02)
	cProduto:= ''
Endif

aMes:={}

For nMes:= 1 To 12	//Processa 1 Ano Retroativo(mes a mes), a Partir da Data Base (Parametro)

	nQtSKU	:= 0	// SKU's Controlados PCS
	nSalC	:= 0	// Soma de Estoque Controlados PCS
	nQNSKU	:= 0	// SKU's Não Controlados PCS
	nSalNC	:= 0	// Soma de Estoque Não Controlados PCS
	nEstCo	:= 0	// Soma de Estoque Consignado
	nPerc	:= 0	// % Inventário Controlado PCS
	n1Digit:= 0	// % Meta Inventário Controlado PCS (Digitado pelo usuário)
	nVLTOTM:= 0	// Valor Total Comprado no Mês
	nGVALPCS:=0	// Valor Total Consumido no Mês
	nVTSCM	:= 0	// Valor Total Sem Consumo no Mês
	nVTSC3	:= 0	// Valor Total Sem Consumo 3 Meses
	nVTSC6	:= 0	// Valor Total Sem Consumo 6 Meses
	nVTSC9	:= 0	// Valor Total Sem Consumo 9 Meses
	nVTS12	:= 0	// Valor Total Sem Consumo 12 Meses
	nVALPCS:= 0	// Valor Total Consumido PCS
	nSalALM:= 0	// Inventário Controlado PCS Almox
	nSalTM	:= 0	// Inventário Médio Controlado PCS
	nIdeal	:= 0	// Inventário Ideal Controlado PCS
	nMeta	:= 0	// Meta dos PCS
	nDRPCS	:= 0	// DOS Realizado PCS	
	nDOSUNI:= 0	// DOS Unidade (Pendente de definição)
	nMGIRPCS:=0	// Meta Grio PCS
	nGRPCS	:= 0	// Giro Realizado PCS
	n2Digit:= 0	// % Meta Nível de Serviço PCS (Digitado pelo usuário)
	nNSPCS	:= 0	// % Nível de Serviço PCS
	n3Digit:= 0	// % Meta Ordens Perfeitas PCS (Digitado pelo usuário)
	n4Digit:= 0	// % Ordens Perfeitas PCS (Digitado pelo usuário)
	n5Digit:= 0	// Faturamento Mensal (Digitado pelo usuário)
	nTDISM	:= 0	// Total de Itens Sem Movimento
	
	nItCSa	:= 0	// Para Definir % de Nivel de Serviço PCS
	nQTDPCS:= 0
	nGQTDPCS:=0
	nGCMD	:= 0
	nQTTOTM:= 0
	
		
	//Laço das Filiais
	For nForFil:= 1 To Len(aTodfil)
	
		cXFil:= Padr(aTodfil[nForFil],TamSx3("B2_FILIAL")[1]) 
		aProds:={}
		
		If Empty(cProduto)// Considera Todos os Produtos do Estoque
		
			cQuery:=" SELECT B2_FILIAL,B2_COD "
			cQuery +=" FROM " + RETSQLNAME('SB2') + " "
			cQuery +=" WHERE B2_FILIAL = '" + cXFil + "' "
			cQuery +=" GROUP BY B2_FILIAL,B2_COD "
			cQuery +=" ORDER BY B2_COD "	
					
			TCQUERY cQuery NEW ALIAS (cASB2)
			
			While (cASB2)->(!EOF() .AND. (cASB2)->B2_FILIAL == cXFil)
				AAdd(aProds,{Padr((cASB2)->B2_COD,TamSx3("B1_COD")[1])})		
				(cASB2)->(DbSkip())
			EndDo
			(cASB2)->(DbCloseArea())
				
		Else //Considera somente o Produto Parametrizado
			AAdd(aProds,{cProduto})
		Endif
		
		//Laço dos Produtos do Estoque
		For nProds:= 1 To Len (aProds)
								
			cChaveB2:= cXFil + aProds [nProds,1] 
		
			IF !SB2->(DbSeek(cChaveB2))
				Loop
			Endif
			
			If xFilial("SB1") <> Space(TamSx3("B2_FILIAL")[1])
				If !SB1->(DbSeek(SB2->B2_FILIAL + SB2->B2_COD))
					Loop
				Endif
			Else
				If !SB1->(DbSeek(xFilial("SB1") + SB2->B2_COD))
					Loop
				Endif
			Endif
			
			lSemCatg:= .f.
			IF !Empty(MV_PAR03)		
				If !ACV->(DbSeek(SB2->B2_FILIAL + SB2->B2_COD + cCategor))
					Loop
				Endif				
			Else
				If !ACV->(DbSeek(SB2->B2_FILIAL + SB2->B2_COD))
					lSemCatg:= .t.
				Endif
			Endif	
			
			If !lSemCatg			
				ACU->(DbSeek(SB2->B2_FILIAL + ACV->ACV_CATEGO))
			Endif

			cProd	:= SB2->B2_COD
			lPCS	:=.F.
			
			//O Saldo inicial do Mes Subsequente é o Saldo do Mes em Questão
			cDxMesIni:= DtoS(MonthSum(Stod(DMesIni),1))			
			cDxMesFim:= DtoS(LastDate(Stod(cDxMesIni)))
			
			cQuery:=" SELECT B9_FILIAL,B9_LOCAL,B9_COD,SUM (B9_QINI) QTDMES "
			cQuery +=" FROM " + RETSQLNAME('SB9') + " "
			cQuery +=" WHERE B9_COD ='" + SB1->B1_COD + "' AND "
			cQuery +=" B9_FILIAL = '" + cXFil + "' AND "
			cQuery +=" B9_DATA BETWEEN '" + cDxMesIni + "' AND '" + cDxMesFim + "' AND D_E_L_E_T_=' ' "
			cQuery +=" GROUP BY B9_FILIAL,B9_LOCAL,B9_COD "
			
			TCQUERY cQuery NEW ALIAS (cASB9)
			
			If ACU->ACU_MSBLQL = '2' .And. ACU->ACU_CTRLP ='1' .And. !lSemCatg
			
				lPCS:=.T.	//SKU's Controlados pelo PCS no Mes Em Questão
						
				If MONTH(Stod(dMesIni)) <> MONTH(dDatabase) 
					
					//Se o Mes em Questão NAO FOR o Mes da Data Base, Baseia-se no SB9 para obter Saldos										
					If !(cASB9)->(EOF())
							
						While (cASB9)->(!EOF() .AND. B9_FILIAL + B9_COD == cXFil + cProd)
								
							nSalC:= nSalC + (cASB9)->QTDMES //Soma de Estoque Controlado PCS
							If (cASB9)->QTDMES > 0
								nItCSa:= nItCSa + 1 			//Para Definir % de Nivel de Serviço PCS
							Endif
							
							//Estoque Controlado PCS Almox
							IF Alltrim((cASB9)->B9_LOCAL) == Alltrim(cFSALM)
								nSalALM := nSalALM + (cASB9)->QTDMES	
							EndIf
							
							//Soma de Estoque Consignado	
							IF SB1->B1_XCONSIG == '1'
								nEstCo:= nEstCo + (cASB9)->QTDMES
							EndIf
							
							(cASB9)->(DbSkip())
							
						EndDo					
														
					Endif 
																
				Else
				
					//Se o Mes em Questão FOR o Mes da Data Base, Baseia-se no SB2 para obter Saldos	
					While SB2->(!EOF() .AND. B2_FILIAL + B2_COD == cXFil + cProd)
					
						nSldB2:= SaldoSb2()
						nSalC:= nSalC + nSldB2
						
						If nSldB2 > 0
							nItCSa:= nItCSa + 1 //Para Definir % de Nivel de Serviço PCS
						Endif
						
						//Estoque Controlado PCS Almox
						IF Alltrim(SB2->B2_LOCAL) == Alltrim(cFSALM)
							nSalALM := nSalALM + nSldB2
						EndIf
				
						//Soma de Estoque Consignado	
						IF SB1->B1_XCONSIG == '1'
							nEstCo:= nEstCo + nSldB2
						EndIf
						
						SB2->(DbSkip())
						
					EndDo				
									
				Endif
					
				nQtSKU:= nQtSKU + 1
				
				// % Nível de Serviço PCS
				nNSPCS := (nItCSa * 100) / nQtSKU 
														
			Elseif ACU->ACU_CTRLP <> '1' .Or. lSemCatg //SKU's NÃO Controlados PCS ou SEM categoria	
				
				//Se o Mes em Questão NAO FOR o Mes da Data Base, Baseia-se no SB9 para obter Saldos
				If MONTH(Stod(dMesIni)) <> MONTH(dDatabase)
										
					If !(cASB9)->(EOF())
					
						While (cASB9)->(!EOF() .AND. B9_FILIAL + B9_COD == cXFil + cProd)
								
							nSalNC:= nSalNC + (cASB9)->QTDMES 	//Soma de Estoque Controlado PCS
							
							If (cASB9)->QTDMES > 0
								nItCSa:= nItCSa + 1 				//Para Definir % de Nivel de Serviço PCS
							Endif
							
							//Soma de Estoque Consignado	
							IF SB1->B1_XCONSIG == '1'
								nEstCo:= nEstCo + (cASB9)->QTDMES
							EndIf
						
							(cASB9)->(DbSkip())
						EndDo						
														
					Endif	
					
				Else
				
					//Se o Mes em Questão FOR o Mes da Data Base, Baseia-se no SB2 para obter Saldo
					While SB2->(!EOF() .AND. B2_FILIAL + B2_COD == cXFil + cProd)
					
						nSldB2:= SaldoSb2()
						nSalNC := nSalNC + nSldB2 
						
						//Soma de Estoque Consignado	
						IF SB1->B1_XCONSIG == '1'
							nEstCo:= nEstCo + nSldB2
						EndIf
						
						SB2->(DbSkip())
					EndDo				
						
				Endif
				
				nQNSKU:= nQNSKU + 1 		
				
			Endif
			
			If lPCS	//PRODUTO EM QUESTÃO CONTROLADO PELO PCS
			
				(cASB9)->(DbGOTOP())
						
				//----------------------------------------------------------------------------------------	
				//Estoque Médio Controlado PCS
				
				//SALDO FINAL do Mes em questão = Saldo do mes Subsequente (SB9)
				nQtds2:=0
								
				If !(cASB9)->(EOF())	
							
					While (cASB9)->(!EOF() .AND. B9_FILIAL + B9_COD == cXFil + cProd)		
						nQtds2:= nQtds2 + (cASB9)->QTDMES 
						(cASB9)->(DbSkip())
					EndDo
					
				Else	
					//Caso Não exista SB9 (Saldos Iniciais,(Mes subsequente) Roda-se o CalcEst para o Ultimo Dia		
					cQuery:=" SELECT B2_FILIAL,B2_COD, B2_LOCAL "
					cQuery +=" FROM " + RETSQLNAME('SB2') + " "
					cQuery +=" WHERE B2_COD ='" + SB1->B1_COD + "' AND D_E_L_E_T_=' ' "
					cQuery +=" AND B2_FILIAL = '" + cXFil + "'"	
											
					TCQUERY cQuery NEW ALIAS (cASB2)
											
					While !(cASB2)->(Eof())					
						aSaldo:= CalcEst((cASB2)->B2_COD,(cASB2)->B2_LOCAL, StoD(dMesFim),(cASB2)->B2_FILIAL) //Saldo Final do Mês
						nQtds2:= aSaldo[1]		
						(cASB2)->(dbSkip())
					EndDo	
					(cASB2)->(DbCloseArea())
								
				Endif
				
				(cASB9)->(DbCloseArea())
				
				//SALDO INICAL do Mes em questão = Saldo do mes Anterior (SB9)
				nQtds1:=0
				
				cDxMesIni:= DtoS(MonthSuB(Stod(DMesIni),1))		
				cDxMesFim:= DtoS(LastDate(Stod(cDxMesIni)))
				
				cQuery:=" SELECT B9_FILIAL,B9_LOCAL,B9_COD,SUM (B9_QINI) QTDMES "
				cQuery +=" FROM " + RETSQLNAME('SB9') + " "
				cQuery +=" WHERE B9_COD ='" + SB1->B1_COD + "' AND "
				cQuery +=" B9_FILIAL = '" + cXFil + "' AND "
				cQuery +=" B9_DATA BETWEEN '" + cDxMesIni + "' AND '" + cDxMesFim + "' AND D_E_L_E_T_=' ' "
				cQuery +=" GROUP BY B9_FILIAL,B9_LOCAL,B9_COD "
				
				TCQUERY cQuery NEW ALIAS (cASB9)
								
				If !(cASB9)->(EOF())				
					While (cASB9)->(!EOF() .AND. B9_FILIAL + B9_COD == cXFil + cProd)		
						nQtds1:= nQtds1 + (cASB9)->QTDMES 
						(cASB9)->(DbSkip())
					EndDo
				Else
					//Caso Não exista SB9 (Saldos Iniciais,(Mes Anterior) Roda-se o CalcEst para o Primeiro Dia			
					cQuery:=" SELECT B2_FILIAL,B2_COD, B2_LOCAL "
					cQuery +=" FROM " + RETSQLNAME('SB2') + " "
					cQuery +=" WHERE B2_COD ='" + SB1->B1_COD + "' AND D_E_L_E_T_=' ' "
					cQuery +=" AND B2_FILIAL = '" + cXFil + "'"	
							
					TCQUERY cQuery NEW ALIAS (cASB2)	
														
					While !(cASB2)->(Eof())
						aSaldo:= CalcEst((cASB2)->B2_COD,(cASB2)->B2_LOCAL, StoD(dMesIni),(cASB2)->B2_FILIAL) //Saldo Inicial do Mês
						nQtds1:= aSaldo[1]
						(cASB2)->(dbSkip())
					EndDo			
					(cASB2)->(DbCloseArea())
					
				Endif			
				
				nSalTM:= nSalTM + ((nQtds1 + nQtds2)/2) //Calcula Estoque Médio Controlado PCS						
							
				//----------------------------------------------------------------------------------------
				//% Estoque Controlado PCS
				nPerc:= (nSalC*100)/(nSalC + nSalNC)
			
			Endif
			
			(cASB9)->(DbCloseArea())
				
			//----------------------------------------------------------------------------------------
			//Define Totais (Quantidade e Custo) de Saidas - Requisições
			nQtdReq:=0
			nCusReq:=0
			cQuery:=" SELECT D3_COD,SUM(D3_QUANT) TOTQTD, SUM (D3_CUSTO1) TOTCUSTO "
			cQuery +=" FROM " + RETSQLNAME('SD3') + " "
			cQuery +=" WHERE D3_COD = '" + SB1->B1_COD + "' AND "
			cQuery +=" D3_FILIAL = '" + cXFil + "' AND "
			cQuery +=" (D3_CF = 'RE0' OR D3_CF = 'RE1') AND " 
			cQuery +=" D3_EMISSAO BETWEEN '" + dMesIni + "' AND '" + dMesFim + "' AND D_E_L_E_T_=' ' "
			cQuery +=" GROUP BY D3_COD "
					
			TCQUERY cQuery NEW ALIAS (cASD3S)
				
			If !(cASD3S)->(EOF())
				nQtdReq:= (cASD3S)->TOTQTD
				nCusReq:= (cASD3S)->TOTCUSTO
			Endif
			
			(cASD3S)->(DbCloseArea())	
			//----------------------------------------------------------------------------------------
			
			//Define Totais (Quantidade e Custo) de Entradas - devoluções
			nQtdDev:=0
			nCusDev:=0
			cQuery:=" SELECT D3_COD,SUM(D3_QUANT) TOTQTD, SUM (D3_CUSTO1) TOTCUSTO "
			cQuery +=" FROM " + RETSQLNAME('SD3') + " "
			cQuery +=" WHERE D3_COD ='" + SB1->B1_COD + "' AND "
			cQuery +=" D3_FILIAL = '" + cXFil + "' AND "
			cQuery +=" (D3_CF = 'DE0' OR D3_CF = 'DE1') AND " 
			cQuery +=" D3_EMISSAO BETWEEN '" + dMesIni + "' AND '" + dMesFim + "' AND D_E_L_E_T_=' ' "
			cQuery +=" GROUP BY D3_COD "
						
			TCQUERY cQuery NEW ALIAS ((cASD3E))
				
			If !(cASD3E)->(EOF())
				nQtdDev:= (cASD3E)->TOTQTD
				nCusDev:= (cASD3E)->TOTCUSTO
			Endif
			
			(cASD3E)->(DbCloseArea())	
			//----------------------------------------------------------------------------------------	
			
			If lPCS
				//QUANTIDADE TOTAL Consumido PCS - Total das Requisições Menos as Devoluções	
				nQTDPCS:= nQTDPCS + (nQtdReq - nQtdDev)
				//CONSUMO MÉDIO Diário Somente PCS
				nCMD:= nQTDPCS/nDias
				//VALOR TOTAL Consumido PCS - Total das Requisições Menos as Devoluções	
				nVALPCS:= nVALPCS + (nCusReq - nCusDev)
					
				//----------------------------------------------------------------------------------------	
				//META (nMeta) e Inventário Ideal Controlado PCS (nIdeal)							
				nConsumoDia:= (nQtdReq - nQtdDev) / nDias
				CustoUni	:=	(nCusReq - nCusDev) / (nQtdReq - nQtdDev) 
				nPolit		:= Posicione("SBZ",1,xFilial("SBZ") + SB1->B1_COD,"BZ_ESTSEG") + Posicione("SBZ",1,xFilial("SBZ") + SB1->B1_COD,"BZ_PE") + Posicione("SBZ",1,xFilial("SBZ") + SB1->B1_COD,"BZ_XFREQAN")
				
				nMeta:= (nConsumoDia * CustoUni) * nPolit
				nIdeal:= nIdeal + (nMeta * nConsumoDia)
					
				//----------------------------------------------------------------------------------------
				//Giro Realizado PCS
				nGRPCS:= nGRPCS + (nQTDPCS / nSalTM)	
				//DOS Realizado PCS
				nDRPCS:= nSalC / nCMD
				//Meta Grio PCS
				nMGIRPCS:= nMGIRPCS + (nQTDPCS / nIdeal)			
			Endif
			
			//----------------------------------------------------------------------------------------
			//QUANTIDADE TOTAL Consumido Geral - Total das Requisições Menos as Devoluções	
			nGQTDPCS:= nGQTDPCS + (nQtdReq - nQtdDev)
			//Consumo MÉDIO Diário de Todos	
			nGCMD:= nGCMD + (nGQTDPCS/nDias)
			//VALOR TOTAL Consumido Geral - Total das Requisições Menos as Devoluções	
			nGVALPCS:= nGVALPCS + (nCusReq - nCusDev)
				
							
			//----------------------------------------------------------------------------------------
			//Itens Sem Movimentação (Resquisição SD3)
			cQuery:=" SELECT MAX(D3_EMISSAO) MAIORDT "
			cQuery +=" FROM " + RETSQLNAME('SD3') + " "
			cQuery +=" WHERE D3_COD ='" + SB1->B1_COD + "' AND D3_EMISSAO BETWEEN '" + d12Mes + "' AND '" + dMesFim + "' AND D_E_L_E_T_=' ' "
			cQuery +=" AND D3_FILIAL = '" + cXFil + "'"
			cQuery +=" AND (D3_CF = 'RE0' OR D3_CF = 'RE1')"
			cQuery +=" ORDER BY D3_EMISSAO "
			
			TCQUERY cQuery NEW ALIAS (cASD3R)

			dMaiorDT:= Dtos(MonthSub(dDatabase,36)) // Inicializa Data do Maior Movimento para 3 anos Atras
			
			If !(cASD3R)->(EOF())
				dMaiorDT:= (cASD3R)->MAIORDT
			Endif
			
			(cASD3R)->(DbCloseArea())
			
			//Valor Total Sem Consumo no Mes Atual
			If MONTH(Stod(dMesIni)) == MONTH(dDatabase)
				If (dMaiorDT < dMesIni)							
					SB2->(DbSeek(cChaveB2))		
					While SB2->(!EOF() .AND. B2_FILIAL + B2_COD== cXFil + SB1->B1_COD)				
						nVTSCM	:= nVTSCM + SB2->B2_VATU1  
						nTDISM := nTDISM + SB2->B2_QATU   
						SB2->(dbSkip())
					EndDo
				Endif
			Endif			
			
			//Sem Consumo nos ultimos: 3 Meses - 6 Meses - 9 Meses e 12 Meses
			
			//Analisa Saldo Inicial do Mes Subsequente ao Mes onde ocorreu a ultima Movimentação do Produto
			dB9ini:=	Substr(dMaiorDT,1,6) + "01" 
			dB9ini:=	DtoS(MonthSum(Stod(dB9ini),1))
			dB9Fim:= 	DtoS(LastDate(StoD(dB9ini)))
				
			cQuery:=" SELECT SUM(B9_VINI1) nValB9, SUM(B9_QINI) nQtdB9 "
			cQuery +=" FROM " + RETSQLNAME('SB9') + " "
			cQuery +=" WHERE B9_DATA BETWEEN '" + dB9ini + "' AND '" + dB9Fim + "' AND D_E_L_E_T_=' ' "
			cQuery +=" AND B9_COD ='" + SB1->B1_COD + "' "
			cQuery +=" AND B9_FILIAL = '" + cXFil + "'"
				
			TCQUERY cQuery NEW ALIAS (cASB9a)
			
			If !(cASB9a)->(Eof()) .And. (cASB9a)->nValB9 > 0																	
				//Valor Total Sem Consumo 3 Meses
				If (dMaiorDT < d3Mes)
					nVTSC3	:= nVTSC3 + (cASB9a)->nValB9
				Endif		
				//Valor Total Sem Consumo 6 Meses
				If (dMaiorDT < d6Mes)
					nVTSC6	:= nVTSC6 + (cASB9a)->nValB9
				Endif
				//Valor Total Sem Consumo 9 Meses
				If (dMaiorDT < d9Mes)
					nVTSC9	:= nVTSC9 + (cASB9a)->nValB9
				Endif
				//Valor Total Sem Consumo 12 Meses
				If (dMaiorDT < d12Mes)
					nVTS12	:= nVTS12 + (cASB9a)->nValB9
				Endif
				
				nTDISM:= nTDISM + (cASB9a)->nQtdB9			
			Endif
			
			(cASB9a)->(DbCloseArea())
			
			//Valor Total Comprado no Mes
			//----------------------------------------------------------------------------------------
			cQuery:=" SELECT SUM(D1_TOTAL) VALTOT, SUM(D1_QUANT) QTDTOT "
			cQuery +=" FROM " + RETSQLNAME('SD1') + " "
			cQuery +=" WHERE D1_EMISSAO BETWEEN '" + dMesIni + "' AND '" + dMesFim + "' AND D_E_L_E_T_=' ' "
			cQuery +=" AND D1_COD ='" + SB1->B1_COD + "' "
			cQuery +=" AND D1_FILIAL = '" + cXFil + "'"
			
			TCQUERY cQuery NEW ALIAS (cASD1S)
			
			If !(cASD1S)->(Eof())					
				nVLTOTM	:= nVLTOTM + (cASD1S)->VALTOT
				nQTTOTM 	:= nQTTOTM + (cASD1S)->QTDTOT
			EndIf							
										
			(cASD1S)->(DbCloseArea())			
			//----------------------------------------------------------------------------------------
			
		Next nProds
						
	Next nForFil
	
	AAdd(aMes,{nQtSKU,nSalC,nQNSKU,nSalNC,nEstCo,nPerc,n1Digit,nVLTOTM,nGVALPCS,nVTSCM,nVTSC3,;
				nVTSC6,nVTSC9,nVTS12,nVALPCS,nSalALM,nSalTM,nIdeal,nMeta,nDRPCS,nDOSUNI,nMGIRPCS,;
				nGRPCS,n2Digit,nNSPCS,n3Digit,n4Digit,n5Digit,nTDISM	})	
	
	//Define Mes anterior. Próximo mes a ser processado até 12 meses.			
 	dMesIni	:= DtoS(MonthSub(StoD(dMesIni),1))
 	dMesFim	:= DtoS(LastDate(StoD(dMesIni)))
 	nDias		:= StoD(dMesFim)- StoD(dMesIni)
 	d3Mes		:= DtoS(MonthSub(StoD(dMesFim),3))
 	d6Mes		:= DtoS(MonthSub(StoD(dMesFim),6))
 	d9Mes		:= DtoS(MonthSub(StoD(dMesFim),9))
 	d12Mes		:= DtoS(MonthSub(StoD(dMesFim),12))				
	
Next 	
	
oFwMsEx:AddRow( cWorkSheet, cTable, { "SKU's Controlados PCS", 				aMes[01,nITEMA],aMes[02,nITEMA],aMes[03,nITEMA],aMes[04,nITEMA],aMes[05,nITEMA],aMes[06,nITEMA],aMes[07,nITEMA],aMes[08,nITEMA],aMes[09,nITEMA],aMes[10,nITEMA],aMes[11,nITEMA],aMes[12,nITEMA] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Estoque Total Controlados PCS", 		aMes[01,nITEMB],aMes[02,nITEMB],aMes[03,nITEMB],aMes[04,nITEMB],aMes[05,nITEMB],aMes[06,nITEMB],aMes[07,nITEMB],aMes[08,nITEMB],aMes[09,nITEMB],aMes[10,nITEMB],aMes[11,nITEMB],aMes[12,nITEMB] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "SKU's Não Controlados PCS", 			aMes[01,nITEMC],aMes[02,nITEMC],aMes[03,nITEMC],aMes[04,nITEMC],aMes[05,nITEMC],aMes[06,nITEMC],aMes[07,nITEMC],aMes[08,nITEMC],aMes[09,nITEMC],aMes[10,nITEMC],aMes[11,nITEMC],aMes[12,nITEMC] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Estoque Total Não Controlados PCS",	aMes[01,nITEMD],aMes[02,nITEMD],aMes[03,nITEMD],aMes[04,nITEMD],aMes[05,nITEMD],aMes[06,nITEMD],aMes[07,nITEMD],aMes[08,nITEMD],aMes[09,nITEMD],aMes[10,nITEMD],aMes[11,nITEMD],aMes[12,nITEMD] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Estoque Total de Consignados", 		aMes[01,nITEME],aMes[02,nITEME],aMes[03,nITEME],aMes[04,nITEME],aMes[05,nITEME],aMes[06,nITEME],aMes[07,nITEME],aMes[08,nITEME],aMes[09,nITEME],aMes[10,nITEME],aMes[11,nITEME],aMes[12,nITEME] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "% do Estoque Controlado PCS",			aMes[01,nITEMF],aMes[02,nITEMF],aMes[03,nITEMF],aMes[04,nITEMF],aMes[05,nITEMF],aMes[06,nITEMF],aMes[07,nITEMF],aMes[08,nITEMF],aMes[09,nITEMF],aMes[10,nITEMF],aMes[11,nITEMF],aMes[12,nITEMF] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "% Meta do Estoque Controlado PCS", 	aMes[01,nITEMG],aMes[02,nITEMG],aMes[03,nITEMG],aMes[04,nITEMG],aMes[05,nITEMG],aMes[06,nITEMG],aMes[07,nITEMG],aMes[08,nITEMG],aMes[09,nITEMG],aMes[10,nITEMG],aMes[11,nITEMG],aMes[12,nITEMG] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Comprado no Mês", 			aMes[01,nITEMH],aMes[02,nITEMH],aMes[03,nITEMH],aMes[04,nITEMH],aMes[05,nITEMH],aMes[06,nITEMH],aMes[07,nITEMH],aMes[08,nITEMH],aMes[09,nITEMH],aMes[10,nITEMH],aMes[11,nITEMH],aMes[12,nITEMH] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Consumido no Mês", 		aMes[01,nITEMI],aMes[02,nITEMI],aMes[03,nITEMI],aMes[04,nITEMI],aMes[05,nITEMI],aMes[06,nITEMI],aMes[07,nITEMI],aMes[08,nITEMI],aMes[09,nITEMI],aMes[10,nITEMI],aMes[11,nITEMI],aMes[12,nITEMI] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Sem Consumo no Mês", 		aMes[01,nITEMJ],aMes[02,nITEMJ],aMes[03,nITEMJ],aMes[04,nITEMJ],aMes[05,nITEMJ],aMes[06,nITEMJ],aMes[07,nITEMJ],aMes[08,nITEMJ],aMes[09,nITEMJ],aMes[10,nITEMJ],aMes[11,nITEMJ],aMes[12,nITEMJ] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Sem Consumo 3 Meses", 		aMes[01,nITEMK],aMes[02,nITEMK],aMes[03,nITEMK],aMes[04,nITEMK],aMes[05,nITEMK],aMes[06,nITEMK],aMes[07,nITEMK],aMes[08,nITEMK],aMes[09,nITEMK],aMes[10,nITEMK],aMes[11,nITEMK],aMes[12,nITEMK] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Sem Consumo 6 Meses", 		aMes[01,nITEML],aMes[02,nITEML],aMes[03,nITEML],aMes[04,nITEML],aMes[05,nITEML],aMes[06,nITEML],aMes[07,nITEML],aMes[08,nITEML],aMes[09,nITEML],aMes[10,nITEML],aMes[11,nITEML],aMes[12,nITEML] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Sem Consumo 9 Meses", 		aMes[01,nITEMM],aMes[02,nITEMM],aMes[03,nITEMM],aMes[04,nITEMM],aMes[05,nITEMM],aMes[06,nITEMM],aMes[07,nITEMM],aMes[08,nITEMM],aMes[09,nITEMM],aMes[10,nITEMM],aMes[11,nITEMM],aMes[12,nITEMM] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Sem Consumo 12 Meses", 	aMes[01,nITEMN],aMes[02,nITEMN],aMes[03,nITEMN],aMes[04,nITEMN],aMes[05,nITEMN],aMes[06,nITEMN],aMes[07,nITEMN],aMes[08,nITEMN],aMes[09,nITEMN],aMes[10,nITEMN],aMes[11,nITEMN],aMes[12,nITEMN] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Valor Total Consumido PCS", 			aMes[01,nITEMO],aMes[02,nITEMO],aMes[03,nITEMO],aMes[04,nITEMO],aMes[05,nITEMO],aMes[06,nITEMO],aMes[07,nITEMO],aMes[08,nITEMO],aMes[09,nITEMO],aMes[10,nITEMO],aMes[11,nITEMO],aMes[12,nITEMO] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Estoque Amoxerifado Controlado PCS",	aMes[01,nITEMP],aMes[02,nITEMP],aMes[03,nITEMP],aMes[04,nITEMP],aMes[05,nITEMP],aMes[06,nITEMP],aMes[07,nITEMP],aMes[08,nITEMP],aMes[09,nITEMP],aMes[10,nITEMP],aMes[11,nITEMP],aMes[12,nITEMP] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Estoque Médio Controlado PCS", 		aMes[01,nITEMQ],aMes[02,nITEMQ],aMes[03,nITEMQ],aMes[04,nITEMQ],aMes[05,nITEMQ],aMes[06,nITEMQ],aMes[07,nITEMQ],aMes[08,nITEMQ],aMes[09,nITEMQ],aMes[10,nITEMQ],aMes[11,nITEMQ],aMes[12,nITEMQ] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Estoque Ideal Controlado PCS", 		aMes[01,nITEMR],aMes[02,nITEMR],aMes[03,nITEMR],aMes[04,nITEMR],aMes[05,nITEMR],aMes[06,nITEMR],aMes[07,nITEMR],aMes[08,nITEMR],aMes[09,nITEMR],aMes[10,nITEMR],aMes[11,nITEMR],aMes[12,nITEMR] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Meta dos PCS"	, 							aMes[01,nITEMS],aMes[02,nITEMS],aMes[03,nITEMS],aMes[04,nITEMS],aMes[05,nITEMS],aMes[06,nITEMS],aMes[07,nITEMS],aMes[08,nITEMS],aMes[09,nITEMS],aMes[10,nITEMS],aMes[11,nITEMS],aMes[12,nITEMS] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "DOS Realizado PCS", 						aMes[01,nITEMT],aMes[02,nITEMT],aMes[03,nITEMT],aMes[04,nITEMT],aMes[05,nITEMT],aMes[06,nITEMT],aMes[07,nITEMT],aMes[08,nITEMT],aMes[09,nITEMT],aMes[10,nITEMT],aMes[11,nITEMT],aMes[12,nITEMT] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "DOS Unidade", 							aMes[01,nITEMU],aMes[02,nITEMU],aMes[03,nITEMU],aMes[04,nITEMU],aMes[05,nITEMU],aMes[06,nITEMU],aMes[07,nITEMU],aMes[08,nITEMU],aMes[09,nITEMU],aMes[10,nITEMU],aMes[11,nITEMU],aMes[12,nITEMU] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Meta Giro PCS", 							aMes[01,nITEMV],aMes[02,nITEMV],aMes[03,nITEMV],aMes[04,nITEMV],aMes[05,nITEMV],aMes[06,nITEMV],aMes[07,nITEMV],aMes[08,nITEMV],aMes[09,nITEMV],aMes[10,nITEMV],aMes[11,nITEMV],aMes[12,nITEMV] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Giro Realizado PCS", 					aMes[01,nITEMX],aMes[02,nITEMX],aMes[03,nITEMX],aMes[04,nITEMX],aMes[05,nITEMX],aMes[06,nITEMX],aMes[07,nITEMX],aMes[08,nITEMX],aMes[09,nITEMX],aMes[10,nITEMX],aMes[11,nITEMX],aMes[12,nITEMX] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "% Meta Nível de Serviço PCS", 			aMes[01,nITEMY],aMes[02,nITEMY],aMes[03,nITEMY],aMes[04,nITEMY],aMes[05,nITEMY],aMes[06,nITEMY],aMes[07,nITEMY],aMes[08,nITEMY],aMes[09,nITEMY],aMes[10,nITEMY],aMes[11,nITEMY],aMes[12,nITEMY] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "% Nível de Serviço PCS", 				aMes[01,nITEMZ],aMes[02,nITEMZ],aMes[03,nITEMZ],aMes[04,nITEMZ],aMes[05,nITEMZ],aMes[06,nITEMZ],aMes[07,nITEMZ],aMes[08,nITEMZ],aMes[09,nITEMZ],aMes[10,nITEMZ],aMes[11,nITEMZ],aMes[12,nITEMZ] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "% Meta Ordens Perfeitas PCS", 			aMes[01,nITEMW],aMes[02,nITEMW],aMes[03,nITEMW],aMes[04,nITEMW],aMes[05,nITEMW],aMes[06,nITEMW],aMes[07,nITEMW],aMes[08,nITEMW],aMes[09,nITEMW],aMes[10,nITEMW],aMes[11,nITEMW],aMes[12,nITEMW] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "% Ordens Perfeitas PCS", 				aMes[01,nITEMA2],aMes[02,nITEMA2],aMes[03,nITEMA2],aMes[04,nITEMA2],aMes[05,nITEMA2],aMes[06,nITEMA2],aMes[07,nITEMA2],aMes[08,nITEMA2],aMes[09,nITEMA2],aMes[10,nITEMA2],aMes[11,nITEMA2],aMes[12,nITEMA2] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Faturamento Mensal", 					aMes[01,nITEMB2],aMes[02,nITEMB2],aMes[03,nITEMB2],aMes[04,nITEMB2],aMes[05,nITEMB2],aMes[06,nITEMB2],aMes[07,nITEMB2],aMes[08,nITEMB2],aMes[09,nITEMB2],aMes[10,nITEMB2],aMes[11,nITEMB2],aMes[12,nITEMB2] } )
oFwMsEx:AddRow( cWorkSheet, cTable, { "Total de Itens sem Movimentações",		aMes[01,nITEMC2],aMes[02,nITEMC2],aMes[03,nITEMC2],aMes[04,nITEMC2],aMes[05,nITEMC2],aMes[06,nITEMC2],aMes[07,nITEMC2],aMes[08,nITEMC2],aMes[09,nITEMC2],aMes[10,nITEMC2],aMes[11,nITEMC2],aMes[12,nITEMC2] } )
	
	/*---- Finaliza a linha----*/
oFwMsEx:Activate()
		
//cArq := CriaTrab( NIL, .F. ) + ".xml" //cWorkSheet
cArq := cWorkSheet + "RDor.xml" 
MsgRun("Gerando Relatório: " + Alltrim(cArq) + ". Aguarde.",,{|| oFwMsEx:GetXMLFile(cArq)})

If __CopyFile( cArq, cDirTmp + cArq )
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( cDirTmp + cArq )
	oExcelApp:SetVisible(.T.)			
	MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + cDir )			
Else
	MsgInfo( "Arquivo não copiado para: " + Alltrim(cDirTmp + cArq) )
Endif

oFwMsEx:DeActivate()

RestArea(aArea)
		
Return
