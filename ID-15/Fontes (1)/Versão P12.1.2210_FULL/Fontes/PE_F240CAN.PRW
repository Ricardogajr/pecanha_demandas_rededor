 #include 'TOTVS.CH'
 
/*/{Protheus.doc} F240CAN
Ponto de entrada executado no cancelamento do bordero de pagamento.
@type User function
@author Paulo Krüger
@since 20/03/2017
@version 12.7
@project MAN0000007423041_EF_029
@return NIL
/*/

User Function F240CAN()

	Local aArea 		:= GetArea()
    Local aAreSE2      	:= SE2->(GetArea())
	Local nIdxSE2 		:= SE2->(IndexOrd())
	Local nRegSE2 		:= SE2->(Recno())
    Local aAreSE5      	:= SE5->(GetArea())
	Local nIdxSE5 		:= SE5->(IndexOrd())
	Local nRegSE5 		:= SE5->(Recno())	
    Local cSQL          := ""
    Local cEOL          := Chr(13) + Chr(10)
    Local cAliasTRB     := GetNextAlias()
    Local nCount        := 0
	Local lMonkey 		:= .F.
	Local cMKPref    	:= SuperGetMV("MK_PREFIXO", , "NEG")
	Local cFornPCC 		:= SuperGetMV("MK_FORNPCC", , "UNIAO ")
	Local cLojaPCC 		:= SuperGetMV("MK_LOJAPCC", , "00")
    Local cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
	Local cLogArq		:= "F240CAN"	


	//Desbloqueio de Notas Fiscais de Entrada
	SE2->(DbSetOrder(1))
	If SE2->(DbSeek(SEA->EA_FILIAL + SEA->EA_PREFIXO + SEA->EA_NUM + SEA->EA_PARCELA + SEA->EA_TIPO + SEA->EA_FORNECE + SEA->EA_LOJA))
		If ExistBlock("F0702901")
			U_F0702901(SE2->E2_XID)
		EndIf
	EndIf

	RestArea(aArea)

	aArea := GetArea()

    cSQL := " SELECT SE2.R_E_C_N_O_ NUMREG " + cEOL
    CSQL += "   FROM " + RetSQLName("SE2") + " SE2 " + cEOL
    cSQL += "  WHERE E2_FILIAL = '" + FWxFilial("SE2") + "' " + cEOL
//  cSQL += "    AND E2_PREFIXO = '" + SEA->EA_PREFIXO + "' " + cEOL
	cSQL += "    AND E2_PREFIXO = '" + cMKPref + "' " + cEOL
    cSQL += "    AND E2_NUM = '" + SEA->EA_NUM + "' " + cEOL
    cSQL += "    AND E2_FORNECE = '" + cFornPCC + "' " + cEOL
    cSQL += "    AND E2_LOJA = '" + cLojaPCC + "' " + cEOL
    cSQL += "    AND E2_TIPO = 'TX ' " + cEOL
    cSQL += "    AND SE2.D_E_L_E_T_ = ' ' " + cEOL

	MemoWrite(cLogDir + cLogArq + ".sql", cSQL)
    
	If Select(cAliasTRB) > 0
		(cAliasTRB)->(DBCloseArea())
	EndIf
	DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)

    Count To nCount

	(cAliasTRB)->(DBSelectArea(cAliasTRB))
	(cAliasTRB)->(DBGoTop())
	While !(cAliasTRB)->(EOF())
        
		lMonkey := .T.
		
		SE2->(DBSelectArea("SE2"))
		SE2->(DBSetOrder(1))
		SE2->(DBGoTo((cAliasTRB)->NUMREG))
		RecLock("SE2", .F.)
			SE2->(DBDelete())
			ConOut("Título TX excluído! - Recno: " + CValToChar((cAliasTRB)->NUMREG))
		SE2->(MSUnLock())

		SE5->(DBSelectArea("SE5"))
		SE5->(DBSetOrder(7))
		SE5->(DBSeek(FWxFilial("SE5") + AllTrim(SE2->E2_TITPAI)))
		While !SE5->(EOF()) .And. SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA == AllTrim(SE2->E2_TITPAI)
			If AllTrim(SE5->E5_MOTBX) == "PCC"
				RecLock("SE5", .F.)
					SE5->E5_SITUACA := "C"
				SE5->(MSUnLock())
			EndIf
			SE5->(DBSkip())
		EndDo

		(cAliasTRB)->(DBSkip())

	EndDo

    If Select(cAliasTRB) > 0
		(cAliasTRB)->(DBCloseArea())
	EndIf

    RestArea(aAreSE2)
	RestArea(aAreSE5)

	SE2->(DBSelectArea("SE2"))
	SE2->(DBSetOrder(nIdxSE2))
	SE2->(DBGoTo(nRegSE2))	

	SE5->(DBSelectArea("SE5"))
	SE5->(DBSetOrder(nIdxSE5))
	SE5->(DBGoTo(nRegSE5))	

	If lMonkey
		//F241CanImp()
	Else
		ConOut("Não foi localizado título TX! ")
	EndIf

	RestArea(aArea)

Return
