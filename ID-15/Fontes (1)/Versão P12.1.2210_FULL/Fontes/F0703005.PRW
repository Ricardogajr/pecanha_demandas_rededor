#INCLUDE 'TOTVS.CH'

/*{Protheus.doc} F0703005 
Recalculo de consumo médio dos produtos no mês.
@author Paulo Krüger
@since  06/12/2017
@project MAN0000007423041_EF_030
@Param	cFilOri - Filial
@Param	dData - Data deprocessamento
@Param	cProd - Código do produto ( Se não informado, considera todos os produtos movimentados no período)
@Param	cLocal - Local de Estoque ( Se não informado, considera todos os locais de estoque no período)
@version P12.1.7
@return Nil
*/

User Function F0703005(cFilOri, dData, cProd, cLocal,cRegLog)

Local	dDataIni	:=	''
Local	dDataFim	:=	''
Local	cDataIni	:=	''
Local	cDataFim	:=	''
Local	cConsumo	:=	''
Local	nDiasMov	:=	0
Local	cMesAnoRef	:=	''
Local	lExibeTela	:=	.F.
Local	nTotReg		:=	0
Local	cFilialSF5	:=	''

Private	cAlias01	:=	''

Default cFilOri		:=	''
Default dData		:=	CTOD('  /  /  ')
Default cProd		:=	''
Default cLocal		:=	''
Default cRegLog 	:=  ''

dDataIni	:=	FirstDate(dData)
dDataFim	:=	LastDate(dData)
cDataIni	:=	DToS(dDataIni) 
cDataFim	:=	DToS(dDataFim)
nDiasMov	:=	LastDate(dData) - FirstDate(dData)
nCustMed	:=	0
cMesAnoRef	:=	SubStr(DToS(dData),05,02) + SubStr(DToS(dData),01,04)
cConsumo	:=	'S'
cAlias01	:=	GetNextAlias()
cQuery01	:=	''
lExibeTela	:=	IsInCallStack('U_F0703004') //Passa por tela de parametrização
cFilialSF5	:=  xFilial('SF5')

//cQuery01	:=	" SELECT SUM(CASE WHEN SUBSTR(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END) / " + ALLTRIM(STR(nDiasMov)) + " CONSUMO, " + CRLF
// CORRECAO
cQuery01	:=	" SELECT SUM(CASE WHEN SUBSTRING(D3_CF,01,01) = 'D' THEN (SD3.D3_QUANT * (-1)) ELSE SD3.D3_QUANT END)  " + " CONSUMO, " + CRLF
cQuery01	+=	" SD3.D3_COD	CODPRO, " + CRLF 
cQuery01	+=	" SD3.D3_LOCAL	LOCEST  " + CRLF
cQuery01	+=	" FROM " + RetSqlName('SD3') + " SD3 INNER JOIN " + RetSqlName('SF5') + " SF5 " + CRLF
cQuery01	+=	" ON 			SF5.F5_FILIAL	= '" + cFilialSF5 + "'" + CRLF
cQuery01	+=	" 		AND		SF5.F5_CODIGO	= SD3.D3_TM     " + CRLF
cQuery01	+=	" WHERE			SD3.D_E_L_E_T_	= '' " 		+ CRLF
cQuery01	+=	" 		AND		SF5.D_E_L_E_T_	= '' " 		+ CRLF
cQuery01	+=	" 		AND		SD3.D3_FILIAL	= '" + cFilOri	+ "' " + CRLF 
cQuery01	+= 	"		AND		SD3.D3_ESTORNO	= '' " + CRLF
If !Empty(cProd)
	cQuery01	+=	" 		AND		SD3.D3_COD		= '" + cProd	+ "' " + CRLF
EndIf
If !Empty(cLocal)
	cQuery01	+=	" 		AND		SD3.D3_LOCAL	= '" + cLocal	+ "' " + CRLF
EndIf
cQuery01	+=	" 		AND		SD3.D3_EMISSAO >= '" + cDataIni	+ "' " + CRLF
cQuery01	+=	" 		AND		SD3.D3_EMISSAO <= '" + cDataFim + "' " + CRLF
cQuery01	+=	" 		AND		SF5.F5_XCONSUM	= '" + cConsumo + "' " + CRLF
cQuery01	+=	" GROUP BY SD3.D3_COD, SD3.D3_LOCAL "  

cQuery01 := ChangeQuery(cQuery01) 
DbUseArea(.T., 'TOPCONN', TcGenQry(NIL, NIL, cQuery01), 'cAlias01', .F., .T.)

cAlias01->(DbGoTop())

While cAlias01->(!Eof())
	nTotReg += 01
	cAlias01->(DbSkip())
Enddo		

cAlias01->(DbGoTop()) 

If lExibeTela
	Processa( {|| fProcesP28(cFilOri, cMesAnoRef, dDataFim, lExibeTela, nTotReg, @cRegLog)}, 'Aguarde...', 'Atualizando mes '+cMesAnoRef+' tabela P28 (Consumo Médio no Mês).',.F.)
Else
				  fProcesP28(cFilOri, cMesAnoRef, dDataFim, lExibeTela, nTotReg, @cRegLog)
EndIf

cAlias01->(DbCloseArea())

Return


/*{Protheus.doc} fProcesP28 
Atualiza tabela P28
@author Paulo Krüger
@since  13/12/2017
@project MAN0000007423041_EF_030
@Param	cFilOri - Filial
@Param	cMesAnoRef - Mes/Ano do período em referência
@Param	dDataFim - Data final do período
@Param	lExibeTela - Exibe tela de processamento
@Param	nTotReg - Total de registros a serem processados
@version P12.1.7
@return Nil
*/ 

Static Function fProcesP28(cFilOri, cMesAnoRef, dDataFim, lExibeTela, nTotReg,cRegLog)

Local nCustMed 	:= 0 
//Default cRegLog := ""

If lExibeTela
	ProcRegua(nTotReg)
EndIf

P28->(DbSetOrder(01)) 

cAlias01->(DbGoTop()) 

While cAlias01->(!Eof()) 

	If lExibeTela
		IncProc()
	EndIf
	
	nCustMed := U_F0703006(cFilOri, cAlias01->CODPRO, cAlias01->LOCEST, dDataFim) * cAlias01->CONSUMO	//Custo Médio do mês de referência.

	If P28->(DbSeek(cFilOri + cAlias01->CODPRO + cAlias01->LOCEST + cMesAnoRef))
		P28->(RecLock('P28',.F.))
	Else
		P28->(RecLock('P28',.T.))
		P28->P28_FILIAL	:=	cFilOri				//Filial 
		P28->P28_CODPRD	:=	cAlias01->CODPRO	//Código do Produto 
		P28->P28_DATREF	:=	cMesAnoRef			//Data Base (Mês/ano referência) 
		P28->P28_LOCAL	:=	cAlias01->LOCEST	//Local de Estoque 
	EndIf
	P28->P28_CONSUM	:= cAlias01->CONSUMO	//Consumo (Saídas subtraidas das entradas) do mês de referência.
	P28->P28_CUSMED	:= nCustMed
	P28->(MsUnLock())
	
	cRegLog += "Filial: " + cFilOri + " Produto: " + cAlias01->CODPRO + " Armazem: " + cAlias01->LOCEST + " Mes/Ano referência: " + cMesAnoRef + " Consumo: " + ALLTRIM(STR(cAlias01->CONSUMO)) + " Custo Medio: " + ALLTRIM(STR(nCustMed)) 
	cRegLog += CRLF

	cAlias01->(DbSkip())

EndDo
	
Return