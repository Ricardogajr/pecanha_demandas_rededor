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
{Protheus.doc} F1200101()
Rotina de medição de contratos multifiliais (relacionamento de entidades).
@Author		Paulo Krüger
@Since		14/08/2017
@Version	P12.7
@Project    MAN0000007423046_EF_001
@Param		cFilOri, Filial.
@Param		cCodPro, Código do produto.
@Param		cId, Id de Integração
*/

User Function F1200101(cFilOri, cCodPro, cId, lValIni)
	Local aItSolComp  := {} as array
	Local cAlias01    := '' as character
	Local cDataBase   := '' as character
	Local cFilP17     := '' as character
	Local cProdBloq   := '' as character
	Local cQuery01    := '' as character
	Local cSitContr   := '' as character
	Local nPos        := 0  as numeric
	Private aWBrowse1 := {} as array
	Default cCodPro   := ''
	Default cFilOri   := ''
	Default cId       := ''
	Default lValIni   := .T.

cDatabase 	:= DTOS(dDataBase)
cSitContr	:= '05'
cProdBloq	:= 'S'
cFilP17		:= xFilial('P17')
cAlias01	:= GetNextAlias()
ASORT(aProdSel,,, { |x, y| x[IDINTSOLIC] < y[IDINTSOLIC] })	
If lValIni .And. ( nPos := ASCAN(aProdSel, {|aVal| aVal[IDINTSOLIC] == cId}) ) == 0
	Return {}
EndIf

cQuery01 += "SELECT	CASE WHEN AIB.AIB_CODPRO IS NOT NULL THEN AIB.AIB_CODPRO ELSE 'NE' END PRDTABPREC, " + CRLF 
cQuery01 += "       CASE WHEN AIB.AIB_PRCCOM IS NOT NULL THEN AIB.AIB_PRCCOM ELSE  0   END PRCTABPREC, " + CRLF
cQuery01 += "       CASE WHEN AIB.AIB_ITEM   IS NOT NULL THEN AIB.AIB_ITEM   ELSE 'NE' END ITMTABPREC, " + CRLF
cQuery01 += "       CASE WHEN AIA.AIA_CODFOR IS NOT NULL THEN AIA.AIA_CODFOR ELSE 'NE' END CODFORNECE, " + CRLF 
cQuery01 += "       CASE WHEN AIA.AIA_LOJFOR IS NOT NULL THEN AIA.AIA_LOJFOR ELSE 'NE' END LOJFORNECE, " + CRLF
cQuery01 += "       CASE WHEN AIA.AIA_CODTAB IS NOT NULL THEN AIA.AIA_CODTAB ELSE 'NE' END CODTABPREC, " + CRLF 
cQuery01 += "       CASE WHEN CN9.CN9_FILIAL IS NOT NULL THEN CN9.CN9_FILIAL ELSE 'NE' END FILCONTRAT, " + CRLF 
cQuery01 += "       CASE WHEN CN9.CN9_NUMERO IS NOT NULL THEN CN9.CN9_NUMERO ELSE 'NE' END NUMCONTRAT, " + CRLF 
cQuery01 += "       CASE WHEN CN9.CN9_DTINIC IS NOT NULL THEN CN9.CN9_DTINIC ELSE 'NE' END DTICONTRAT, " + CRLF 
cQuery01 += "       CASE WHEN CN9.CN9_DTFIM  IS NOT NULL THEN CN9.CN9_DTFIM  ELSE 'NE' END DTFCONTRAT, " + CRLF
cQuery01 += "       CASE WHEN CN9.CN9_REVISA IS NOT NULL THEN CN9.CN9_REVISA ELSE 'NE' END REVCONTRAT, " + CRLF 
cQuery01 += "       CASE WHEN CN9.CN9_VIGE   IS NOT NULL THEN CN9.CN9_VIGE   ELSE  0   END VIGCONTRAT, " + CRLF 	  
cQuery01 += "       CASE WHEN CNA.CNA_NUMERO IS NOT NULL THEN CNA.CNA_NUMERO ELSE 'NE' END NUMPLANILH, " + CRLF 
cQuery01 += "       CASE WHEN P17.P17_ESTOQ  IS NOT NULL THEN P17.P17_ESTOQ  ELSE 'NE' END PRODESTOCA, " + CRLF 	  
cQuery01 += "       CASE WHEN P17.P17_BLOQ   IS NOT NULL THEN P17.P17_BLOQ   ELSE 'NE' END PRODBLOQUE, " + CRLF
cQuery01 += "       ''																	   FILAUTORIZ  " + CRLF
cQuery01 += "FROM " + RetSqlName('AIB') + " AIB " + CRLF
cQuery01 += "       LEFT  JOIN " + RetSqlName('AIA') + " AIA	ON		AIA.AIA_FILIAL = AIB.AIB_FILIAL " + CRLF 
cQuery01 += "                  					AND		AIA.AIA_CODTAB = AIB.AIB_CODTAB " + CRLF 
cQuery01 += "                  					AND     AIA.AIA_CODFOR = AIB.AIB_CODFOR " + CRLF 
cQuery01 += "                  					AND     AIA.AIA_LOJFOR = AIB.AIB_LOJFOR " + CRLF 
cQuery01 += "									AND 	AIA.D_E_L_E_T_  = '' " + CRLF
cQuery01 += "       							AND 	(AIA_DATATE 	>= '" + cDatabase + "' OR AIA_DATATE = ' ')" + CRLF 
cQuery01 += "       LEFT  JOIN " + RetSqlName('CN9') + " CN9	ON		CN9.CN9_FILIAL = AIB.AIB_FILIAL " + CRLF 
cQuery01 += "                  					AND		CN9.CN9_NUMERO = AIB.AIB_XCONTR " + CRLF
cQuery01 += "       							AND 	CN9.D_E_L_E_T_  = '' " + CRLF
cQuery01 += "       							AND 	CN9.CN9_SITUAC	= '" + cSitContr + "' " + CRLF 
cQuery01 += "       INNER  JOIN	(SELECT MAX(CN9A.CN9_REVISA) 	MAXREV, " + CRLF 
cQuery01 += "                          		CN9A.CN9_FILIAL		FILCN9, " + CRLF 
cQuery01 += "                          		CN9A.CN9_NUMERO		NUMCN9  " + CRLF 
cQuery01 += "                   FROM   " + RetSqlName('CN9') + " CN9A "  + CRLF  
cQuery01 += "                   WHERE  CN9A.D_E_L_E_T_ = '' " + CRLF 
cQuery01 += "					AND CN9A.CN9_DTFIM >= '"+cDataBase+" '" +CRLF
cQuery01 += "                   GROUP  BY CN9A.CN9_FILIAL,  " + CRLF 
cQuery01 += "                             CN9A.CN9_NUMERO) CONTRAT	ON		CONTRAT.FILCN9 	= CN9.CN9_FILIAL " + CRLF 
cQuery01 += "                  											AND CONTRAT.NUMCN9 	= CN9.CN9_NUMERO " + CRLF 
cQuery01 += "                  											AND CONTRAT.MAXREV 	= CN9.CN9_REVISA " + CRLF 
cQuery01 += "       LEFT	JOIN " + RetSqlName('CNA') + " CNA	ON		CNA.CNA_FILIAL		= CN9.CN9_FILIAL " + CRLF 
cQuery01 += "               					   					AND		CNA.CNA_CONTRA	= CN9.CN9_NUMERO " + CRLF 
cQuery01 += "                  										AND		CNA.CNA_REVISA	= CN9.CN9_REVISA " + CRLF
cQuery01 += "                  										AND		CNA.D_E_L_E_T_	= '' " + CRLF
cQuery01 += "       LEFT 	JOIN " + RetSqlName('P17') + " P17	 ON			P17.P17_FILIAL	= '" + cFilP17 + "' " + CRLF
cQuery01 += "       												AND		P17.P17_FTRATA	= '" + cFilOri + "' " + CRLF
cQuery01 += "       												AND		P17.P17_COD		= 	AIB.AIB_CODPRO " + CRLF
cQuery01 += "       												AND		P17.P17_BLOQ   	<> '" + cProdBloq + "' "  + CRLF
cQuery01 += "       												AND		P17.D_E_L_E_T_	= '' " + CRLF
cQuery01 += "WHERE		AIB.AIB_CODPRO = '" + cCodPro + "' " + CRLF
cQuery01 += "		AND AIB.AIB_CODTAB = CNA.CNA_XTABPC " + CRLF
cQuery01 += "		AND AIB.AIB_FILIAL = '" + cFilOri + "' " + CRLF 
cQuery01 += "		AND AIB.D_E_L_E_T_  = '' " + CRLF
cQuery01 += "UNION " + CRLF 
cQuery01 += "SELECT AIB.AIB_CODPRO	PRDTABPREC, " + CRLF 
cQuery01 += "       AIB.AIB_PRCCOM	PRCTABPREC, " + CRLF
cQuery01 += "       AIB.AIB_ITEM	ITMTABPREC, " + CRLF
cQuery01 += "       CASE WHEN AIA.AIA_CODFOR IS NOT NULL THEN AIA.AIA_CODFOR ELSE 'NE' END CODFORNECE, " + CRLF 
cQuery01 += "       CASE WHEN AIA.AIA_LOJFOR IS NOT NULL THEN AIA.AIA_LOJFOR ELSE 'NE' END LOJFORNECE, " + CRLF 
cQuery01 += "       CASE WHEN AIA.AIA_CODTAB IS NOT NULL THEN AIA.AIA_CODTAB ELSE 'NE' END CODTABPREC, " + CRLF 
cQuery01 += "       CN9.CN9_FILIAL FILCONTRAT, " + CRLF 
cQuery01 += "       CN9.CN9_NUMERO NUMCONTRAT, " + CRLF 
cQuery01 += "       CN9.CN9_DTINIC DTICONTRAT, " + CRLF 
cQuery01 += "       CN9.CN9_DTFIM  DTFCONTRAT, " + CRLF 
cQuery01 += "       CN9.CN9_REVISA REVCONTRAT, " + CRLF 
cQuery01 += "       CN9.CN9_VIGE   VIGCONTRAT, " + CRLF 
cQuery01 += "       CASE WHEN CNA.CNA_NUMERO IS NOT NULL THEN CNA.CNA_NUMERO ELSE 'NE' END NUMPLANILH, " + CRLF 
cQuery01 += "       CASE WHEN P17.P17_ESTOQ  IS NOT NULL THEN P17.P17_ESTOQ  ELSE 'NE' END PRODESTOCA, " + CRLF 
cQuery01 += "       CASE WHEN P17.P17_BLOQ   IS NOT NULL THEN P17.P17_BLOQ   ELSE 'NE' END PRODBLOQUE, " + CRLF 
cQuery01 += "       CPD.CPD_FILAUT														   FILAUTORIZ  " + CRLF
cQuery01 += "FROM   " + RetSqlName('CN9') + " CN9 " + CRLF 
cQuery01 += "INNER JOIN (SELECT Max(CN9A.CN9_REVISA) MAXREV, " + CRLF 
cQuery01 += "                   CN9A.CN9_FILIAL      FILCN9, " + CRLF 
cQuery01 += "                   CN9A.CN9_NUMERO      NUMCN9 " + CRLF 
cQuery01 += "            FROM   " + RetSqlName('CN9') + " CN9A " + CRLF 
cQuery01 += "            WHERE  CN9A.D_E_L_E_T_ = ' ' " + CRLF 
cQuery01 += "            GROUP  BY CN9A.CN9_FILIAL, " + CRLF 
cQuery01 += "                      CN9A.CN9_NUMERO) CONTRAT	ON 		CONTRAT.MAXREV = CN9.CN9_REVISA " + CRLF 
cQuery01 += "													AND CONTRAT.FILCN9 = CN9.CN9_FILIAL " + CRLF 
cQuery01 += "													AND CONTRAT.NUMCN9 = CN9.CN9_NUMERO " + CRLF
cQuery01 += "LEFT JOIN " + RetSqlName('CNA') + " CNA	ON 		CNA.CNA_FILIAL = CN9.CN9_FILIAL " + CRLF 
cQuery01 += "                 			AND CNA.CNA_CONTRA = CN9.CN9_NUMERO " + CRLF 
cQuery01 += "                 			AND CNA.CNA_REVISA = CN9.CN9_REVISA " + CRLF 
cQuery01 += "                 			AND CNA.D_E_L_E_T_ = ' ' " + CRLF 
cQuery01 += "INNER JOIN " + RetSqlName('AIB') + " AIB	ON		AIB.AIB_FILIAL = CN9.CN9_FILIAL " + CRLF
cQuery01 += "							AND AIB.AIB_XCONTR = CN9.CN9_NUMERO " + CRLF 
cQuery01 += "							AND AIB.AIB_CODPRO = '" + cCodPro + "' " + CRLF
cQuery01 += "							AND AIB.AIB_CODTAB = CNA.CNA_XTABPC " + CRLF 
cQuery01 += "INNER JOIN " + RetSqlName('CPD') + " CPD  ON 		CPD.CPD_FILIAL = CN9.CN9_FILIAL " + CRLF
cQuery01 += "                           AND CPD.CPD_FILAUT = '" + cFilOri + "' " + CRLF 
cQuery01 += "							AND CPD.CPD_CONTRA = AIB.AIB_XCONTR " + CRLF 
cQuery01 += "LEFT  JOIN " + RetSqlName('AIA') + " AIA  ON		AIA.AIA_FILIAL = AIB.AIB_FILIAL " + CRLF 
cQuery01 += "							AND AIA.AIA_CODTAB = AIB.AIB_CODTAB " + CRLF 
cQuery01 += "							AND AIA.AIA_CODFOR = AIB.AIB_CODFOR " + CRLF 
cQuery01 += "							AND AIA.AIA_LOJFOR = AIB.AIB_LOJFOR " + CRLF 
cQuery01 += "							AND AIA.D_E_L_E_T_ = ' ' " + CRLF 
cQuery01 += "							AND 	(AIA_DATATE 	>= '" + cDatabase + "' OR AIA_DATATE = ' ')" + CRLF 
cQuery01 += "LEFT JOIN " + RetSqlName('P17') + " P17   ON 		P17.P17_FILIAL = '        ' " + CRLF 
cQuery01 += "							AND P17.P17_FTRATA	= '" + cFilOri + "' " + CRLF
cQuery01 += "							AND P17.P17_COD = AIB.AIB_CODPRO " + CRLF 
cQuery01 += "							AND P17.P17_BLOQ <> 'S' " + CRLF 
cQuery01 += "							AND P17.D_E_L_E_T_ = ' ' " + CRLF 
cQuery01 += "WHERE		CN9.D_E_L_E_T_ = ' ' " + CRLF 
cQuery01 += "		AND CN9.CN9_SITUAC = '05' " + CRLF
cQuery01 += "       AND CN9.CN9_DTFIM >=  '"+cDatabase+"'" + CRLF
cQuery01 += "		AND CN9.CN9_FILIAL <> '" + cFilOri + "' " + CRLF 
cQuery01 += "       AND CPD.D_E_L_E_T_ = ' ' " + CRLF 
cQuery01 += "       AND AIB.D_E_L_E_T_ = ' ' " + CRLF

cQuery01 := ChangeQuery(cQuery01)
Conout("Criação da tabela temporária F1200101 " + Time())
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery01),cAlias01, .F., .T.)
Conout("Fim Criação da tabela temporária F1200101 " + Time())
If (cAlias01)->(Eof()) 
	cObs := 'Tabela de preco nao encontrada'
	U_F1200713(cId, cObs, nPos)
Else
	While (cAlias01)->(!Eof())
		If !Empty(cId)
			If	(cAlias01)->ITMTABPREC	==	'NE' 
				cObs := 'Item de tabela de preco nao encontrado'
				U_F1200713(cId, cObs, nPos)
				(cAlias01)->(DbSkip())
			EndIf
			If	(cAlias01)->CODTABPREC	==	'NE'
				cObs := 'Tabela de preco nao encontrada'
				U_F1200713(cId, cObs, nPos)
				(cAlias01)->(DbSkip())
			EndIf
			If	(cAlias01)->NUMCONTRAT	==	'NE'
				cObs := 'Contrato nao encontrado'
				U_F1200713(cId, cObs, nPos)
				(cAlias01)->(DbSkip())
			EndIf
			If	(cAlias01)->NUMPLANILH	==	'NE'
				cObs := 'Planilha de contrato nao encontrada'
				U_F1200713(cId, cObs, nPos)
				(cAlias01)->(DbSkip())
			EndIf
			If	(cAlias01)->PRODBLOQUE  ==	'S'
				cObs := 'Produto bloqueado'
				U_F1200713(cId, cObs, nPos)
				(cAlias01)->(DbSkip())
			EndIf
		EndIf
		Aadd(aItSolComp,{	cFilOri					,;	//[01] Filial da SC
							(cAlias01)->(CODFORNECE),;	//[02] Fornecedor 
							(cAlias01)->(LOJFORNECE),;	//[03] Loja fornecedor
							(cAlias01)->(FILCONTRAT),;	//[04] Filial do contrato 
							(cAlias01)->(NUMCONTRAT),;	//[05] Contrato 
							(cAlias01)->(REVCONTRAT),;	//[06] Revisao do contrato 
							(cAlias01)->(VIGCONTRAT),;	//[07] Vigencia do contrato	
							(cAlias01)->(DTICONTRAT),;	//[08] Data inicial do contrato 
							(cAlias01)->(DTFCONTRAT),;	//[09] Data final do contrato
							(cAlias01)->(NUMPLANILH),;	//[10] Numero da planilha do contrato
							(cAlias01)->(CODTABPREC),;	//[11] Codigo da tabela de preco
							(cAlias01)->(ITMTABPREC),;	//[12] Item da tabela de preco
							(cAlias01)->(PRCTABPREC),;	//[13] Preco de tabela
							(cAlias01)->(PRODESTOCA),;	//[14] Produto estocavel
							(cAlias01)->(FILAUTORIZ)})  //[15] Filial autorizada
		(cAlias01)->(DbSkip())
	EndDo
EndIf
(cAlias01)->(DbCloseArea())

Return aItSolComp
