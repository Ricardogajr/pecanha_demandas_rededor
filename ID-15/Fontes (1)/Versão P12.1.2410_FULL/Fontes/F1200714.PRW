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
/*
{Protheus.doc} F1200714()
Grava loga na tabela P07
@Author		Paulo Krüger
@Since		14/08/2017
@Version	P12.7
@Project    MAN0000007423046
@Param		
*/

User Function F1200714()

Local nI := 0


DbSelectArea('P07')
P07->(DBSetOrder(01))

For nI := 01 To Len(aProdSel)
		
	RecLock('P07',.T.)
	P07_COD 	:= GetSxENum('P07','P07_COD')
	P07_FILIAL	:= aProdSel[nI][FILSOLICIT]
	P07_CONTR	:= aProdSel[nI][CONTRSOLIC]
	P07_SOLCO	:= aProdSel[nI][NUMSOLICIT]
	P07_TIPSOL	:= aProdSel[nI][XTIPOSOLIC]
	P07_SETSOL	:= aProdSel[nI][SETORSOLIC]
	P07_CCSOL	:= aProdSel[nI][CCUSTSOLIC]
	P07_SOLIC	:= Alltrim(UsrRetName(aProdSel[nI][USERCSOLIC]))
	P07_MOTSOL 	:= POSICIONE('SX5',01,xFilial('SX5') + 'ZZ' + aProdSel[nI][MOTIVSOLIC],'X5_DESCRI')                                                                                                                                                                                             
	P07_ITEMSC	:= aProdSel[nI][ITMSOLICIT]
	P07_FORNEC	:= aProdSel[nI][FORNCSOLIC]
	P07_LOJFOR	:= aProdSel[nI][LOJAFSOLIC]
	P07_DESCFO	:= Alltrim(Posicione('SA2',1,xFilial('SA2') + aProdSel[nI][FORNCSOLIC] + aProdSel[nI][LOJAFSOLIC],'A2_NOME'))
	P07_DESCR	:= aProdSel[nI][OBSMDSOLIC]
	P07_DTMED	:= If(Empty(aProdSel[nI][DTMEDSOLIC]),CTOD('  /  /  '),aProdSel[nI][DTMEDSOLIC])
	P07_DTVIGI	:= If(Empty(aProdSel[nI][DINCTSOLIC]),CTOD('  /  /  '),aProdSel[nI][DINCTSOLIC])
	P07_DTVIGF	:= If(Empty(aProdSel[nI][DFICTSOLIC]),CTOD('  /  /  '),aProdSel[nI][DFICTSOLIC])
		
	ConfirmSX8()
	P07->(MsUnlock())
Next nI	
Return
