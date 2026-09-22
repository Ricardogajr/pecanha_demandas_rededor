#Include 'Protheus.ch'

/*
{Protheus.doc} F0201001()
JOB para a execução da query.
@Author     Mick William da Silva
@Since      22/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_010     
@Param  	aParams, Vetor Padrão Scheduler {Empresa,Filial,Usuário}
@Menu		Rotina para colocar em Scheduler
*/ 
User Function F0201001(aParams)

Local cCodEmp := ""
Local cCodFil := ""

DEFAULT aParams := {"01","01",.T.}
 
cCodEmp := aParams[1]
cCodFil := aParams[2]
 
//-- Verifica se já existe um Job em execução com o mesmo nome.
If LockByName("F0201001",.F.,.F. )
	Conout('','Rotina para exportação de dados de compras core.')
	ConOut('','[INICIANDO JOB ] - F0201001' )
	Conout('','[] [' + DtoC(Date()) + ' - ' + Time() + ']')
	
	Conout('','Inicio Thread: ' + cValToChar(ThreadID()) )
	
	RpcSetEnv(cCodEmp,cCodFil,,,'COM')
	JOB02010()
	
	//-- Fecha Ambiente
	RpcClearEnv()
	
	Conout('','Final Thread: ' + cValToChar(ThreadID()) )
	
	ConOut( '[FIM DA EXPORTAÇÃO ] - F0201001 - F0201001 ' )
	Conout( '[F0201001] [' + DtoC(Date()) + ' - ' + Time() + '] ')
	UnLockByName("F0201001",.F.,.F. )
Else
	Conout('Já existe um Job com mesmo nome em execução!')
EndIf
	
Return
 
/*
{Protheus.doc} JOB02010()
Query para exportação de dados de compras core.
@Author     Mick William da Silva
@Since      22/06/2016
@Version    P12.7
@Project    MAN00000463301_EF_010   
*/
Static Function JOB02010()
	
Local nQtdMes 		:= SuperGetMv('FS_XMESES',,3)
Local dDTFIM  		:= DtoS(MonthSub(dDataBase,nQtdMes))
Local cQuery  		:= ''
Local cDesc	  		:= ''
Local cE2Dta  		:= ''
Local cAlsSC7 		:= ''
Local cAlsSD1 		:= ''
Local cAlsSC1 		:= ''
Local cAliasSE2		:= ''
Local cAliasSC8		:= ''
Local cAliasSCR		:= ''
Local TMPSCR		:= ''
Local TMPSD1		:= ''
Local TMPSE2		:= ''
Local dDtPCLib		:= CToD('  /  /  ')
Local cAprovSC		:= ''
Local cUltUser		:= ''
Local nRet			:=	0 
Local cPedCompras	:= ''
Local nTOTVALLIQ	:=	0
Local nPorcento		:=	0
Local nTOTAL		:=	0
Local nVALPAG		:=	0
Local nRecnoSM0		:=	0

cQuery := " SELECT C7_FILIAL,C7_NUM,C7_COMPRA,C7_PRODUTO,C7_DESCRI,C7_FORNECE,C7_LOJA,C7_DATPRF, " 
cQuery += " C7_UM,C7_PRECO,C7_IPI,C7_FRETE,C7_TPFRETE,C7_GRUPCOM,C7_ACCPROC,C7_XCOMP,"
cQuery += " C7_XDTVEN,C7_XCODSET,C7_XFATOR,"
cQuery += " C7_QUANT,C7_QUJE,C7_COND,C7_TOTAL,C7_NUMSC,C7_ITEM,C7_CC,C7_LOCAL,C7_CONTRA,C7_NUMCOT, "
cQuery += " C7_XPEDBIO,C7_XPADRON, C7_XCARAC, C7_XTPROC,C7_XEMERG " 			 				
cQuery += " FROM " + RETSQLNAME('SC7') + " SC7 "		
cQuery += " WHERE SC7.D_E_L_E_T_= ' ' AND SC7.C7_EMISSAO BETWEEN '" + dDTFIM + "' AND '" + DtoS(dDataBase) + "' "
cQuery += " ORDER BY SC7.C7_NUM "

cQuery := ChangeQuery(cQuery)

If Select('cAlsSC7') > 0
	cAlsSC7->(dBCloseArea())
EndIf
 
cAlsSC7 := GetNextAlias()
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlsSC7, .F., .T.)

(cAlsSC7)->(dBGoTop())

If (cAlsSC7)->(!Eof())
		
	//Limpa registros anteriores referentes ao Pedido de Compra posicionado.
	While (cAlsSC7)->(!Eof())
		If P99->(DbSeek((cAlsSC7)->C7_FILIAL + (cAlsSC7)->C7_NUM + (cAlsSC7)->C7_ITEM ))
			While P99->P99_FILIAL == (cAlsSC7)->C7_FILIAL .and. P99->P99_NUMPC	= (cAlsSC7)->C7_NUM
				RecLock("P99",.F.)
				P99->(dBDelete())
				P99->(MsUnlock())
				P99->(dBSkip())
			EndDo
		EndIf
 
		//Alimenta tabela P99.
		RecLock('P99',.T.)
 		
		P99->P99_FILIAL	:=	(cAlsSC7)->C7_FILIAL
		P99->P99_UM		:=	(cAlsSC7)->C7_UM
		P99->P99_PRECO	:=	(cAlsSC7)->C7_PRECO
		P99->P99_IPI	:=	(cAlsSC7)->C7_IPI	
		P99->P99_DATPRF	:=	STOD((cAlsSC7)->C7_DATPRF)
		P99->P99_FRETE	:=	(cAlsSC7)->C7_FRETE
		P99->P99_TPFRET :=	(cAlsSC7)->C7_TPFRETE
		P99->P99_GRPCOM	:=	(cAlsSC7)->C7_GRUPCOM
		P99->P99_ACCPRO	:=	(cAlsSC7)->C7_ACCPROC
		P99->P99_DTVENC :=	STOD((cAlsSC7)->C7_XDTVEN)
		P99->P99_CODSET	:=	(cAlsSC7)->C7_XCODSET
		P99->P99_FATOR	:=	(cAlsSC7)->C7_XFATOR
		P99->P99_COMPRA	:=	(cAlsSC7)->C7_XCOMP
		P99->P99_COND	:=	(cAlsSC7)->C7_COND
		P99->P99_CONTRA	:=	(cAlsSC7)->C7_CONTRA
		P99->P99_SETOR	:=	(cAlsSC7)->C7_XCODSET
		P99->P99_FORNEC	:=	(cAlsSC7)->C7_FORNECE
		P99->P99_NUMPC	:=	(cAlsSC7)->C7_NUM
		P99->P99_SOLIC	:=	(cAlsSC7)->C7_NUMSC
		P99->P99_ITEM	:=	(cAlsSC7)->C7_ITEM
		P99->P99_PROD	:=	(cAlsSC7)->C7_PRODUTO
		P99->P99_QTTOT	:=	(cAlsSC7)->C7_QUANT
		P99->P99_TOTAL	:=	(cAlsSC7)->C7_TOTAL
		P99->P99_CARACT	:=	(cAlsSC7)->C7_XCARAC 
		P99->P99_EMERG	:=	(cAlsSC7)->C7_XEMERG
		P99->P99_PADRO	:=	(cAlsSC7)->C7_XPADRON
		P99->P99_PEDBIO	:=	(cAlsSC7)->C7_XPEDBIO
		P99->P99_TPPROC	:=	(cAlsSC7)->C7_XTPROC
		P99->P99_QUJE	:=	(cAlsSC7)->C7_QUJE 
		P99->P99_CC		:=	(cAlsSC7)->C7_CC
		P99->P99_DESCRI	:=	(cAlsSC7)->C7_DESCRI
		P99->P99_DTPREV	:=	StoD((cAlsSC7)->C7_DATPRF)
		P99->P99_QTPEN	:=	(cAlsSC7)->C7_QUANT  - (cAlsSC7)->C7_QUJE
		P99->P99_PENDEN	:=	If(((cAlsSC7)->C7_QUANT - (cAlsSC7)->C7_QUJE)>0,'1','2')
		P99->P99_TPCOMP	:=	If(Empty((cAlsSC7)->C7_CONTRA),'SPOT' ,'CONTRATO')

		//Posiciona Cadastro de Setores 
		P11->(DbSetOrder(01))
		If P11->(DbSeek((cAlsSC7)->C7_FILIAL + (cAlsSC7)->C7_XCODSET))
			P99->P99_DESSET := P11->P11_DESC
		EndIf
		
		//Posiciona Cadastro de Produtos		
		SB1->(DbSetOrder(01))
		If SB1->(DbSeek(xFilial('SB1') + (cAlsSC7)->C7_PRODUTO))
			P99->P99_GRPPRO :=	SB1->B1_XGRPPRO
			P99->P99_SUBGRP	:=	SB1->B1_XSUBGRP
			P99->P99_GRUPO 	:=	SB1->B1_GRUPO
			P99->P99_MATSER	:=	SB1->B1_XMATSER
			P99->P99_CLASSE	:=	Alltrim(SB1->B1_XSUBGRP)

			//Posiciona Cadastro RDSL - TIPO
			SBM->(DbSetOrder(01))
			If SBM->(DbSeek(xFilial('SBM') + SB1->B1_GRUPO))
				P99->P99_NEST	:=	SBM->BM_XESTOQ
				P99->P99_BMDESC	:= 	SBM->BM_DESC
			EndIf

			//Posiciona Cadastro de Sub Grupo de Produtos
			P04->(DbSetOrder(01))
			If P04->(DbSeek(xFilial('P04') + SB1->B1_XSUBGRP))
				P99->P99_P4DESC	:= 	P04->P04_DESC  
			EndIf

		EndIf
		
		//Posiciona Cadastro de Fornecedores
		SA2->(DbSetOrder(01))
		If SA2->(DbSeek(xFilial('SA2') + (cAlsSC7)->C7_FORNECE + (cAlsSC7)->C7_LOJA))
			P99->P99_RSOCIA	:=	SA2->A2_NOME
			P99->P99_NREDUZ	:=	SA2->A2_NREDUZ
			P99->P99_CGC	:=	SA2->A2_CGC
			P99->P99_FCOND	:=	AllTrim(SA2->A2_COND)
			P99->P99_OBS	:=	If(P99->P99_FCOND == (cAlsSC7)->C7_COND, 'A condição de pagamento da NF confere com a OC','A condição de pagamento da NF não confere com a OC')
		EndIf
		
		//Posiciona Cadastro de Centros de Custos
		CTT->(DbSetOrder(01))
		If CTT->(DbSeek(xFilial('CTT') + (cAlsSC7)->C7_CC))
			P99->P99_DESCC 	:=	CTT->CTT_DESC01
		EndIf

		//Posiciona Cadastro de Indicadores de Produtos
		SBZ->(DbSetOrder(01))
		If SBZ->(DbSeek((cAlsSC7)->C7_FILIAL + (cAlsSC7)->C7_PRODUTO))
			P99->P99_LEADT	:=	STR(SBZ->BZ_PE)
		EndIf

		//Posiciona ítens de Nota de Entrada.
		cQuery := " SELECT D1_EMISSAO,D1_XDTENTR,F1_DTDIGIT,F1_DOC,F1_SERIE,F1_EMISSAO,F1_DTLANC,D1_TOTAL,"
		cQuery += " F1_ESPECIE,F1_COND,F1_FILIAL,F1_PREFIXO,F1_DUPL,F1_XDTVNF,F1_FORNECE,F1_LOJA "		  
		cQuery += " FROM " + RETSQLNAME('SD1') + " SD1 " 																			 		
		cQuery += " LEFT JOIN " + RETSQLNAME('SF1') + " SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE "	 
		cQuery += " AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA " 															 
		cQuery += " WHERE SD1.D_E_L_E_T_=' ' AND SF1.D_E_L_E_T_=' '  " 															 
		cQuery += " AND SD1.D1_FILIAL='" + (cAlsSC7)->C7_FILIAL + "' AND SD1.D1_PEDIDO='" + (cAlsSC7)->C7_NUM + "' AND SD1.D1_COD='" + (cAlsSC7)->C7_PRODUTO + "' "		
		cQuery += " AND SD1.D1_ITEM='" + (cAlsSC7)->C7_ITEM + "' "
		cQuery := ChangeQuery(cQuery) 
		
		If Select('cAlsSD1') > 0
			cAlsSD1->(dBCloseArea())
		EndIf
		cAlsSD1 := GetNextAlias()
			
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlsSD1, .F., .T.)

		If (cAlsSD1)->(!Eof())
			P99->P99_DOC	:=	(cAlsSD1)->F1_DOC
			P99->P99_SERIE	:=	(cAlsSD1)->F1_SERIE
			P99->P99_ESPECI :=	(cAlsSD1)->F1_ESPECIE	
			P99->P99_DTDIGI	:=	StoD((cAlsSD1)->F1_DTDIGIT)
			P99->P99_DTLANC	:=	StoD((cAlsSD1)->F1_DTLANC)
			P99->P99_DTEMNF	:=	StoD((cAlsSD1)->F1_EMISSAO)
			P99->P99_DTETT	:=	StoD((cAlsSD1)->D1_XDTENTR)
			P99->P99_DTVNF	:=	StoD((cAlsSD1)->F1_XDTVNF)
			P99->P99_DTVOC	:=	If(!Empty((cAlsSC7)->C7_DATPRF) .And. !Empty((cAlsSD1)->F1_DTDIGIT), (DateDiffDay(StoD((cAlsSC7)->C7_DATPRF), StoD((cAlsSD1)->F1_DTDIGIT))),0)

			//Posiciona Títulos a Pagar.
			If Select('cAliasSE2') > 0
				cAliasSE2->(dBCloseArea())
			EndIf
			
			cAliasSE2 := GetNextAlias()
			BeginSql Alias 'cAliasSE2'
			SELECT	MIN(SE2.E2_BAIXA) DTBAIXA
			FROM	%table:SE2% SE2
			WHERE		SE2.%notDel%
					AND	SE2.E2_FILIAL	=	%exp:(cAlsSD1)->F1_FILIAL%
					AND	SE2.E2_PREFIXO	=	%exp:(cAlsSD1)->F1_PREFIXO%
					AND	SE2.E2_NUM		=	%exp:(cAlsSD1)->F1_DUPL%
					AND	SE2.E2_BAIXA	<>	%exp:''%	
			EndSql
			If !cAliasSE2->(Eof())
				cE2Dta	:=	Stod(cAliasSE2->(DTBAIXA))	
			EndIf	
			
			If Select('cAliasSE2') > 0
				cAliasSE2->(dBCloseArea())
			EndIf

			P99->P99_BAIXA	:= cE2Dta
			
			// Obtem Valor Total Baixado no Contas a Pagar			
			cQuery := "SELECT SUM(E2_VALLIQ) TOTVALLIQ FROM " + RetSQLName("SE2") + " SE2"
			cQuery += " Where E2_FILIAL = '" + (cAlsSD1)->F1_FILIAL + "'"
			cQuery += " And SE2.D_E_L_E_T_ = ' '"
			cQuery += " And SE2.E2_NUM  = '" 		+ (cAlsSD1)->F1_DOC 		+"'"
			cQuery += " And SE2.E2_PREFIXO  = '" 	+ (cAlsSD1)->F1_SERIE 		+"'"
			cQuery += " And SE2.E2_FORNECE = '" 	+ (cAlsSD1)->F1_FORNECE 	+"'"
			cQuery += " And SE2.E2_LOJA  = '" 		+ (cAlsSD1)->F1_LOJA   		+"'"					
			cQuery := ChangeQuery( cQuery )
			
			If Select('TMPSE2') > 0
				TMPSE2->(dBCloseArea())
			EndIf
			TMPSE2 := GetNextAlias()

			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), TMPSE2, .F., .F. )
			
			nTOTVALLIQ:= (TMPSE2)->TOTVALLIQ
			(TMPSE2)->( dbCloseArea())
			
			//Calcula Valor Pago baseado no Percentual equivalente a cada item pela soma de todos			
			nPorcento	:= (cAlsSD1)->D1_TOTAL / nTOTAL
			nVALPAG		:= (nTOTVALLIQ * nPorcento) / 100
			P99->P99_VALPAG	:=	nVALPAG
		EndIf
		(cAlsSD1)->(dbCloseArea())
			
		//Posiciona ítens de Solicitações de Compra
		cQuery := " SELECT C1_FILIAL,C1_NUM,C1_DATPRF,C1_EMISSAO,C1_SOLICIT,C1_APROV,C1_TPSC,C1_EMISSAO,C1_VUNIT, C1_QUANT, C1_ITEM,  "
		cQuery += " C1_XTOTAL,C1_XTPSC,C1_XMOTIVO,C1_XPRAZO,C1_XSETOR,C1_UNIDREQ,"
		cQuery += " C1_NOMAPRO,C1_GERACTR, C1_XUSERSC " 									 		  
		cQuery += " FROM " + RETSQLNAME('SC1') + " SC1 " 																			 		
		cQuery += " WHERE SC1.D_E_L_E_T_=' ' " 																					 
		cQuery += " AND SC1.C1_FILIAL='" + (cAlsSC7)->C7_FILIAL + "' AND SC1.C1_PRODUTO='" + (cAlsSC7)->C7_PRODUTO + "' AND SC1.C1_NUM='" + (cAlsSC7)->C7_NUMSC + "' "	
		cQuery += " AND SC1.C1_ITEM='" + (cAlsSC7)->C7_ITEM + "' "			 														 
		cQuery := ChangeQuery(cQuery) 
		
		If Select('cAlsSC1') > 0
			cAlsSC1->(dBCloseArea())
		EndIf
		cAlsSC1 := GetNextAlias()

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlsSC1, .F., .T.)
			
		If (cAlsSC1)->(!Eof())
			P99->P99_APROV	:=	(cAlsSC1)->C1_APROV
			P99->P99_COLICI	:=	(cAlsSC1)->C1_SOLICIT
			P99->P99_TPCOM	:=	(cAlsSC1)->C1_TPSC
			P99->P99_QTDSC	:= 	(cAlsSC1)->C1_QUANT 
			P99->P99_VUNSC	:= 	(cAlsSC1)->C1_VUNIT 
			P99->P99_TOTSC	:=	(cAlsSC1)->C1_XTOTAL     
			P99->P99_TPSC	:=	(cAlsSC1)->C1_XTPSC
			P99->P99_DESCTP	:=	POSICIONE('SX5',1,XFILIAL('SX5')+'ZX' + (cAlsSC1)->C1_XTPSC,'X5_DESCRI')
			P99->P99_MOTIVO	:=	(cAlsSC1)->C1_XMOTIVO
			P99->P99_DESMOT	:=	POSICIONE('SX5',1,XFILIAL('SX5')+'ZZ' + (cAlsSC1)->C1_XMOTIVO,'X5_DESCRI')             
			P99->P99_PRAZO	:=	(cAlsSC1)->C1_XPRAZO
			P99->P99_UNIREQ	:= 	(cAlsSC1)->C1_UNIDREQ
			P99->P99_NOMAPR	:=	(cAlsSC1)->C1_NOMAPRO
			P99->P99_GERACT :=	(cAlsSC1)->C1_GERACTR
			P99->P99_DTSOL	:=	StoD((cAlsSC1)->C1_EMISSAO)
			P99->P99_DTVSOL	:=	StoD((cAlsSC1)->C1_DATPRF)
			P99->P99_DTEMSC	:=	StoD((cAlsSC1)->C1_EMISSAO)
			P99->P99_NOMCOM	:= 	(cAlsSC1)->C1_XUSERSC

			//Posiciona ítens de Cotações
			If Select('cAliasSC8') > 0
				cAliasSC8->(dBCloseArea())
			EndIf
			
			cAliasSC8 := GetNextAlias()
			BeginSql Alias 'cAliasSC8'
			SELECT	MIN(SC8.C8_PRECO) VALCOT
			FROM	%table:SC8% SC8
			WHERE		SC8.%notDel%
					AND	SC8.C8_FILIAL	=	%exp:(cAlsSC1)->C1_FILIAL%
					AND	SC8.C8_NUMSC	=	%exp:(cAlsSC1)->C1_NUM%
					AND	SC8.C8_ITEMSC	=	%exp:(cAlsSC1)->C1_ITEM%
			EndSql
			If !cAliasSC8->(Eof())
				P99->P99_MPVPP	:= cAliasSC8->(VALCOT)
			EndIf	
			
			cAliasSC8->(dBCloseArea())

			//Posiciona Aprovações de Solicitações de Compras.
			If Select('cAliasSCR') > 0
				cAliasSCR->(dBCloseArea())
			EndIf
			
			cAliasSCR := GetNextAlias()
			BeginSql Alias 'cAliasSCR'
			SELECT MAX(R_E_C_N_O_) NRECNO 
			FROM	%table:SCR% SCR
			WHERE		SCR.%notDel%
					AND	SCR.CR_FILIAL	=	%exp:(cAlsSC1)->C1_FILIAL%
					AND	SCR.CR_NUM		=	%exp:(cAlsSC1)->C1_NUM%
					AND	SCR.CR_TIPO		=	%exp:'SC'%			
					AND	SCR.CR_STATUS	=	%exp:'03'% OR CR_STATUS = %exp:'05'%
			EndSql
			If !cAliasSCR->(Eof())
				SCR->(DbGoTop(cAliasSCR->(NRECNO)))
				cAprovSC	:=	SCR->CR_APROV
			EndIf	
				
			cAliasSCR->(dBCloseArea())

			P99->P99_USERLI := cAprovSC 

		EndIf
		(cAlsSC1)->(dbCloseArea())

		//Obtem o último aprovador do Pedido de Compras           
		cPedCompras:= Padr((cAlsSC7)->C7_NUM,TamSx3("CR_NUM")[1])
        
		cQuery := "SELECT MAX(R_E_C_N_O_) NRECNO FROM " + RetSQLName("SCR") + " SCR"
		cQuery += " Where CR_FILIAL = '" + xFilial("SCR") + "'"
		cQuery += " And SCR.D_E_L_E_T_ = ' '"
		cQuery += " And CR_STATUS  = '03' Or CR_STATUS = '05'"
		cQuery += " And CR_NUM = '" + cPedCompras +"'"
		cQuery += " And CR_TIPO = 'PC'"			
		cQuery := ChangeQuery( cQuery )
		
		If Select('TMPSCR') > 0
			TMPSCR->(dBCloseArea())
		EndIf
		TMPSCR	:= GetNextAlias()
						
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), TMPSCR, .F., .F. )
		
		nRet:= (TMPSCR)->NRECNO
		(TMPSCR)->( dbCloseArea())
		
		If !Empty(nRet)
			DbSelectArea("SCR")
			SCR->(DbGoTo(nRet))
			cUltUser:= SCR->CR_USER
			dDtPCLib:= SCR->CR_DATALIB
			
			P99->P99_USERLI :=	cUltUser
			P99->P99_DTPED	:=	dDtPCLib
		EndIf

		//Obtem o Total em valor dos Itens Recebidos em relação ao PC
		cQuery := "SELECT SUM(D1_TOTAL) As nTOTAL FROM " + RetSQLName("SD1") + " SD1"
		cQuery += " WHERE SD1.D_E_L_E_T_=' '" 															 
		cQuery += " AND SD1.D1_FILIAL='" + (cAlsSC7)->C7_FILIAL + "' AND SD1.D1_PEDIDO='" + (cAlsSC7)->C7_NUM + "'"								
		cQuery := ChangeQuery(cQuery)
		
		If Select('TMPSD1') > 0
			TMPSD1->(dBCloseArea())
		EndIf
		TMPSD1	:= GetNextAlias()
					
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), TMPSD1, .F., .T.) 
		
		nTOTAL:= (TMPSD1)->nTOTAL
		(TMPSD1)->( dbCloseArea())

		//Posiciona Filial.
		aAreaSM0	:= SM0->(GetArea())
		nRecnoSM0	:= SM0->(RECNO())
		SM0->(DbSetOrder(01))
		If SM0->(DbSeek(cEmpAnt + (cAlsSC7)->C7_FILIAL))
			P99->P99_ESTENT	:=	SM0->M0_ESTENT 
		EndIf
		RestArea(aAreaSM0)
		SM0->(DbGoTo(nRecnoSM0))
		
		P99->(MsUnlock())

		(cAlsSC7)->(dbSkip())
		
	EndDo

Else
	cDesc := 'Não Existem registros a processar!'
	Conout(cDesc)
EndIf

(cAlsSC7)->(dbCloseArea())
	
Return