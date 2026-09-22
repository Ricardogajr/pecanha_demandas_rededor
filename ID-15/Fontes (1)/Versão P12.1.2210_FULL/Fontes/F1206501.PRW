#Include 'TOTVS.ch'

/*
{Protheus.doc} F1206501()
Inclusão\Alteração na tabela P17
@Author  Fabrica de Software
@Since   13/12/2018
@Project MAN0000007423048_EF_066
*/
User Function F1206501(cFilGrv,cCodProd,cTipo)

	Local cQuery := ""
	Local cAlias1 := GetNextAlias()
    Local lret    := .T.
	Local aAreaAtu := GetArea()
	Local AreaP17	:= P17->(GetArea())
	Local AreaSBZ   := SBZ->(GetArea()) // ticket n° 10710218 -- gravação na SBZ quando desbloq da P17

	
	cQuery += " SELECT SB1.B1_COD,P17.P17_CONV1,NNR.NNR_CODIGO FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " INNER JOIN " + RetSqlName("P17") + " P17 ON (P17.P17_FTRATA = '" + cFilGrv + "' AND P17.P17_COD = SB1.B1_COD AND P17.D_E_L_E_T_ = ' ' ) "
	cQuery += " INNER JOIN " + RetSqlName("NNR") + " NNR ON (NNR.NNR_FILIAL = P17.P17_FTRATA AND NNR.NNR_XLOCPA = '1' AND NNR.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = '" + cCodProd + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1, .T., .T.)
	
If !(cAlias1)->(EOF())
	IF cTipo == "I"
		RecLock("SBZ",.T.)
		SBZ->BZ_FILIAL  := cFilGrv
		SBZ->BZ_COD     := (cAlias1)->B1_COD
		SBZ->BZ_LOCPAD  := (cAlias1)->NNR_CODIGO
		SBZ->BZ_QE      := 0
		SBZ->(MsUnLock())
		//lret := .t.
	Elseif cTipo == "A" .AND. SBZ->(!DBSEEK(cFilGrv+(cAlias1)->B1_COD)) // ticket n° 10710218 -- gravação na SBZ quando desbloq da P17
		RecLock("SBZ",.T.)
		SBZ->BZ_FILIAL  := cFilGrv
		SBZ->BZ_COD     := (cAlias1)->B1_COD
		SBZ->BZ_LOCPAD  := (cAlias1)->NNR_CODIGO
		SBZ->(MsUnLock())
		//lRet := .T.
	Endif
EndIf
	(cAlias1)->(DbCloseArea())
	RestArea(AreaSBZ)
	RestArea(AreaP17)
	RestArea(aAreaAtu)
Return lret
