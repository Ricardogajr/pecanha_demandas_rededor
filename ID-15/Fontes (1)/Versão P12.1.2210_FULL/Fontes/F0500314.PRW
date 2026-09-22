#Include 'Protheus.ch'

/*/{Protheus.doc} F0500314
Retorna contagem dos postos reservados
@author henrique.toyada
@since 08/05/2017
@project MAN00000463301_EF_003
@version 1.0
@param cDepto, departamento a verificar
@param cFilPost, filial do posto a verificar
@param cPosto, Posto a verificar
@return nTotal, Total de reservas 
/*/
User Function F0500314(cDepto,cFilPost,cPosto)
	Local cAlias1   := GetNextAlias()
	Local cGRPSOL   := SuperGetMv("FS_GRPSOL",,"002001/006003/006005/006006/006007/006008/006010/")
	Local cQ1grpSol := " ( "
	Local cQuery    := ""
	Local nQ        := 0
	Local nTotal    := 0
	Local lNOracle  := TCGetDB() == 'ORACLE'
	
	For nQ := 1 to Len(Alltrim(cGRPSOL))
		cQ1grpSol += "( RH3_XTPCTM IN ('"+Subs(cGRPSOL,nQ,3)
		nQ += 3
		cQ1grpSol += "') AND PAB_GRPSOL IN ('"+Subs(cGRPSOL,nQ,3)+"') ) "
		nQ += 3
			If ( nQ+1 ) <= Len(Alltrim(cGRPSOL))
				cQ1grpSol += " OR "
			EndIf
	Next nQ
	cQ1grpSol += " ) "
	cQ1grpSol := Iif(Alltrim(cQ1grpSol) == " (  ) ", "", cQ1grpSol)
	
	Default cDepto := ""
	Default cPosto := ""
	
	If lNOracle
		cQuery := "SELECT COUNT( * ) RESERVADOS FROM "
		cQuery +="(SELECT "
		cQuery +=" RH4F.RH4_CAMPO RH4f_DEF, RH4p.RH4_CAMPO RH4p_DEF, RPAD(RH4f.RH4_VALNOV,8,' ') FILIAL, RPAD(RH4p.RH4_VALNOV,9,' ') POSTO, RH3b.RH3_XTPCTM, "
		cQuery +=" RH3b.RH3_FILIAL, RH3b.RH3_CODIGO "
		cQuery +=" FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4f.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_FILPOST','006','RA_FILIAL'),10,' ') "
		cQuery +=" left JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +=" AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +=" AND RH4p.RH4_CAMPO = RPAD(DECODE( RH3b.RH3_XTPCTM, '002', 'QS_POSTO','006','RA_POSTO'),10, ' ') "
		cQuery +=" AND RH4p.D_E_L_E_T_ <> '*' "
		cQuery +=" INNER JOIN  "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +=" AND RH3_XCODAL = PAB_CODIGO AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +=" AND " + cQ1grpSol
		cQuery +=" WHERE RH3b.D_E_L_E_T_ = ' ' "
		cQuery +=" AND ( EXISTS  (SELECT 1 FROM "+RetSqlName("SQS")+" SQS   WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL "
		cQuery +=" AND   SQS.QS_XSOLPTL = RH3b.RH3_CODIGO   AND   SQS.D_E_L_E_T_ = ' ' "
		cQuery +=" AND   SQS.QS_XSTATUS in ('1','2','3','4','6','8','A')   AND   ROWNUM = 1  )    OR RH3b.RH3_STATUS IN ('1','4') ) "
		cQuery +=" ) RALL "
		cQuery +=" WHERE RALL.FILIAL = '"+cFilPost+"' AND RALL.POSTO = '"+cPosto+"' "
	Else
		cQuery +="SELECT COUNT(*) RESERVADOS FROM "
		cQuery +="  (SELECT RH4F.RH4_CAMPO RH4f_DEF, "
		cQuery +="          RH4p.RH4_CAMPO RH4p_DEF, "
		cQuery +="          RIGHT(RH4f.RH4_VALNOV,8) FILIAL, "
		cQuery +="          RIGHT(RH4p.RH4_VALNOV,9) POSTO, "
		cQuery +="          RH3b.RH3_XTPCTM, "
		cQuery +="          RH3b.RH3_FILIAL, "
		cQuery +="          RH3b.RH3_CODIGO "
		cQuery +="   FROM "+RetSqlName("RH3")+" RH3b "
		cQuery +="   LEFT JOIN "+RetSqlName("RH4")+" RH4f ON RH4f.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4f.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4f.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM  WHEN '002' THEN  'QS_FILPOST' WHEN '006' THEN 'RA_FILIAL' END,10) "
		cQuery +="   LEFT JOIN "+RetSqlName("RH4")+" RH4p ON RH4p.RH4_FILIAL = RH3b.RH3_FILIAL "
		cQuery +="   AND RH4p.RH4_CODIGO = RH3b.RH3_CODIGO "
		cQuery +="   AND RH4p.RH4_CAMPO = RIGHT(CASE RH3b.RH3_XTPCTM  WHEN '002' THEN  'QS_POSTO' WHEN '006' THEN 'RA_POSTO' END,10) "
		cQuery +="   AND RH4p.D_E_L_E_T_ <> '*' "
		cQuery +="   INNER JOIN "+RetSqlName("PAB")+" PAB ON PAB.D_E_L_E_T_ = ' ' "
		cQuery +="   AND RH3_XCODAL = PAB_CODIGO "
		cQuery +="   AND RH3_XTPCTM = PAB_TPSOLI "
		cQuery +="   AND " + cQ1grpSol
		cQuery +="   WHERE RH3b.D_E_L_E_T_ = ' '
		cQuery +="     AND (EXISTS
		cQuery +="            (SELECT 1 FROM "+RetSqlName("SQS")+" SQS
		cQuery +="             WHERE SQS.QS_XSOLFIL = RH3b.RH3_FILIAL
		cQuery +="               AND SQS.QS_XSOLPTL = RH3b.RH3_CODIGO
		cQuery +="               AND SQS.D_E_L_E_T_ = ' '
		cQuery +="               AND SQS.QS_XSTATUS IN ('1','2','3','4','6','8')
		cQuery +="                )
		cQuery +="          OR RH3b.RH3_STATUS IN ('1','4')) ) RALL
		cQuery +=" WHERE RALL.FILIAL = '"+cFilPost+"' AND RALL.POSTO = '"+cPosto+"' "	
	EndIf
	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)
	
	nTotal := (cAlias1)->RESERVADOS
	
	(cAlias1)->(DbCloseArea())
	
Return nTotal
