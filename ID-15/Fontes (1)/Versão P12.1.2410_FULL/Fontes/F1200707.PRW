#INCLUDE 'PROTHEUS.CH'
#Include "TOTVS.ch" //Thais Paiva - 09/12/2020

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
/*/{Protheus.doc} F1200707
Lista Itens para medição.
@author 	Paulo Krüger
@since 		19/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Param		oMarca   , Contratos selecionados
@Param		aSelContr, Array com Itens agrupados
@Return		Nil
/*/

User function F1200707(oList,aSelContr)

Local cClasse       := ""  as character
Local cConta        := ""  as character
Local cDtProgramada := ""  as character
Local cId           := ""  as character
Local cItem         := ""  as character
Local cREF24        := ""  as character
Local cREF26        := ""  as character
Local cREF27        := ""  as character
Local cTpSoc        := ""  as character
Local cValCtr       := ""  as character
Local dComp         := ""  as character
Local lExibeTela    := .T. as logical
Local nI            := 0   as numeric
Local nPos          := 0   as numeric
Local nPosSC        := 0   as numeric
Local nQuant        := 0   as numeric
Local nValor        := 0   as numeric

//Quando chamado de Medição manual ou Job não exibe tela
If ISINCALLSTACK('U_F1200600') .OR. ISINCALLSTACK('U_F1200601')
	lExibeTela := .F.
EndIf		

cId		:=	aSelContr[01][01] 
cItemSc :=  aSelContr[01][09]
cTpSoc	:= SuperGetMv("FS_XTPNASC", .F., "11")
cDtProgramada := GetMv("MV_XDTPLAM") //Se o tipo estiver contido neste parametro não altera a data de entrega mantém a da SC C1_DATPRF

ASort(aProdSel,,, {|x, y| x[IDINTSOLIC]+x[XTIPOSOLIC] < y[IDINTSOLIC]+y[XTIPOSOLIC]})

If aSelContr[01][07] $ cTpSoc
	nPosSC := AScan(aProdSel,{|aVal| aVal[CHAVESOLIC] == aSelContr[01][08] + aSelContr[01][09]  })
Else		
	nPosSC := AScan(aProdSel,{|aVal| aVal[IDINTSOLIC] == cId  })
EndIf
nQuant	:=	aProdSel[nPosSC][QTDAGSOLIC]	
nValor	:=	aProdSel[nPosSC][VLRAGSOLIC]
cConta	:=	aProdSel[nPosSC][CONTASOLIC]	
cItem	:=	aProdSel[nPosSC][ITEMCSOLIC]
cClasse	:=	aProdSel[nPosSC][CLASSSOLIC]
dComp	:=	Substr(dToS(dDataBase),05,02) + '/' + Substr(dToS(dDataBase),01,04)

If oList <> Nil
	For nI := 01 To Len(oList:aArray)
		If oList:aArray[nI][01]
			nPos := nI
			Exit
		EndIf
	Next nI
Else
	nPos := 01
EndIf
//                    Filial da SC / Medição     ,Filial do Contrato         , Numero do contrato
cValCtr := U_F1200716(aSelContr[01][06][nPos][01],aSelContr[01][06][nPos][04], aSelContr[01][06][nPos][05]) //Valida contrato

If Empty(cValCtr)
	While aProdSel[nPosSC][IDINTSOLIC] == cId
		aProdSel[nPosSC][CONTRSOLIC] :=	aSelContr[01][06][nPos][05]
		aProdSel[nPosSC][RVCTRSOLIC] :=	aSelContr[01][06][nPos][06]
		aProdSel[nPosSC][FILCTSOLIC] :=	aSelContr[01][06][nPos][04]
		aProdSel[nPosSC][DINCTSOLIC] := STOD(aSelContr[01][06][nPos][08])
		aProdSel[nPosSC][DFICTSOLIC] := STOD(aSelContr[01][06][nPos][09])
		aProdSel[nPosSC][FORNCSOLIC] :=	aSelContr[01][06][nPos][02]
		aProdSel[nPosSC][LOJAFSOLIC] := aSelContr[01][06][nPos][03]
		If nPosSC < Len(aProdSel)
			nPosSC := nPosSC + 01
		Else
			Exit
		EndIf
	EndDo 
	
	iF aSelContr[01][07] $ cDtProgramada // DATA PROGRAMADA
		//[24]Contrato + Fornecedor + Loja + Local de estoque + Produto estocavel +  Data programada aSelContr[01][10]
		cREF24 := aSelContr[01][06][nPos][05] + aSelContr[01][06][nPos][02] + aSelContr[01][06][nPos][03] + aSelContr[01][04] + aSelContr[01][10]
	ELSE
		//[24]Contrato + Fornecedor + Loja + Local de estoque + Produto estocavel 
		cREF24 := iif(aSelContr[01][07] $ cTpSoc,aSelContr[01][08],aSelContr[01][06][nPos][05] + aSelContr[01][06][nPos][02] + aSelContr[01][06][nPos][03] + aSelContr[01][04] + aSelContr[01][06][nPos][14])
	ENDIF

	// CNE_XNUMSC + CNE_XITSC - Numero da SC + Item da Solicitacao
	cREF26 := aSelContr[01][08] //+ "|" + aSelContr[01][09] // [08] Numero da solicitacao + [09]Item da Solicitacao
	cREF27 := aSelContr[01][09] // [09]Item da Solicitacao

	Aadd(aListMedic,{	aSelContr[01][06][nPos][05]	,	;	//[01]Contrato
						aSelContr[01][06][nPos][06]	,	;	//[02]Revisao do contrato
						aSelContr[01][06][nPos][07]	,	;	//[03]Vigencia do contrato
						dComp						,	; 	//[04]Competencia	
						aSelContr[01][06][nPos][10]	,	;	//[05]Numero da planilha
						aSelContr[01][06][nPos][02]	,	;	//[06]Fornecedor
						aSelContr[01][06][nPos][03]	,	;	//[07]Loja do fornecedor
						aSelContr[01][02]			,	;	//[08]Filial da Solicitacao de Compra
						aSelContr[01][03]			,	;	//[09]Codigo do Produto
						nQuant						,	;	//[10]Quantidade
						aSelContr[01][06][nPos][13]	,	;	//[11]Preco de tabela
						nValor						,	;	//[12]Valor total
						dDataBase					,	;	//[13]Data da medicao
						aSelContr[01][05]			,	;	//[14]Centro de custo
						cConta						,	;	//[15]Conta contabil
						cItem						,	;	//[16]Item contabil
						cClasse						,	;	//[17]Classe de valor
						cId + IIf(aSelContr[01][07] $ cTpSoc, aSelContr[01][08] + aSelContr[01][09], ""),	;	//[18]Id de Integracao
						aSelContr[01][06][nPos][04]	,	;   //[19]Filial do contrato
						aSelContr[01][04] 			,	;	//[20]Local de estoque
						aSelContr[01][06][nPos][14] ,	;	//[21]Produto estocavel						
						iif(aSelContr[01][07] $ cTpSoc,aSelContr[01][08],aSelContr[01][06][nPos][05] + aSelContr[01][06][nPos][14] + aSelContr[01][04]), ;  	//[22]Contrato + Produto estocavel + Local de estoque
						aSelContr[01][06][nPos][05] + aSelContr[01][06][nPos][14] + aSelContr[01][03], ; //[23]Contrato + Produto estocavel + Código do Produto
						cREF24,;//[24]Contrato + Fornecedor + Loja + Local de estoque + Produto estocavel +  Data programada aSelContr[01][10]
						aSelContr[01][06][nPos][05] + aSelContr[01][06][nPos][02] + aSelContr[01][06][nPos][03] + aSelContr[01][04] + aSelContr[01][06][nPos][14] + aSelContr[01][10],	;//[25]Contrato + Fornecedor + Loja + Local de estoque + Produto estocavel +  Data programada aSelContr[01][10]
						aSelContr[01][07],;//[26] Tipo da solicitacao
						cREF26,;//[27] Numero da solicitacao
						cREF27})//[28] Item da Solicitacao
						
Else
	If lExibeTela
		Alert(cValCtr)
		U_F1200713(cId, cValCtr, nPosSC)
	Else //Thais Paiva - 10355882
		conout(cValCtr)	//Thais Paiva - 10355882
	EndIf	
EndIf

Return
