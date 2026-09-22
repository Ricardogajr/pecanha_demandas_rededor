// #########################################################################################
// Projeto: Monkey
// Modulo : Integração API
// Fonte  : WSMNK03
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 30/04/21 | Rafael Yera Barchi| Rotina para processamento dos títulos
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE    "PROTHEUS.CH"
#INCLUDE    "TBICONN.CH"

#DEFINE 	cFunction		"WSMNK03"
#DEFINE 	cPerg			PadR(cFunction, 10)
#DEFINE 	cTitleRot	 	"Payables"
#DEFINE 	cEOL			Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSMNK03
//Rotina para processamento dos títulos
@author Rafael Yera Barchi
@since 30/04/2021
@version 1.00
@type function

/*/
//------------------------------------------------------------------------------------------
User Function WSMNK03(__cEmp, __cFil, cMNKLote, lUltimo)

	Local 	nRegua		:= 0
    Local   cSQL1       := ""
    Local   cSQL2       := ""
    Local   cBanco      := ""
    Local	cAliasTRB1	:= GetNextAlias()
    Local	cAliasTRB2	:= GetNextAlias()
	Local   cGlbName 	:= "WSMNK03"
	Local 	aIfo		:= GetUserInfoArray()
	Local 	nVerT		:= 0
	Local 	lLimpa		:= .T.

    Private cLogDir		:= ""
    Private cLogArq		:= ""


	//--< Procedimentos >-------------------------------------------------------------------
    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Início - Empresa: " + __cEmp + " / Filial: " + __cFil))
    
    // Verifica se a rotina já está sendo executada em outras threads para evitar concorrência do processo e duplicidade de registros
	For nVerT := 1 To Len(aIfo)
		If Empty(AllTrim(GetGlbValue(cGlbName)))
			PutGlbValue(cGlbName, CValToChar(ThreadID()))
			lLimpa		:= .F.
			nVerT		:= Len(aIfo)
		ElseIf GetGlbValue(cGlbName) == CValToChar(aIfo[nVerT][3]) .And. GetGlbValue(cGlbName) <> CValToChar(ThreadID())
			ConOut("[" + AllTrim(cFunction) + "] - " + FWTimeStamp(2) + " - Parou o processamento da rotina" + cFunction + " - Thread: " + CValToChar(ThreadID()))
			Return
		EndIf
	Next nVerT
    
    PREPARE ENVIRONMENT EMPRESA __cEmp FILIAL __cFil MODULO "FIN"
    
        ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Ambiente Aberto - Empresa: " + __cEmp + " / Filial: " + __cFil))
        
        cBanco      := PadR(SuperGetMV("MK_BANCO", , ""), TamSX3("A6_COD")[1])
        cLogDir		:= SuperGetMV("MK_LOGDIR", , "\log\")
        cLogArq		:= cFunction
            
        // Query para selecao de títulos fora do vencimento
        cSQL1 := MNK03Qr1()

        If Select(cAliasTRB1) > 0
            (cAliasTRB1)->(DBCloseArea())
        EndIf
        DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL1), (cAliasTRB1), .F., .T.)

        Count To nRegua

        ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Query1: " + CValToChar(nRegua)))

        (cAliasTRB1)->(DBSelectArea(cAliasTRB1))
        (cAliasTRB1)->(DBGoTop())
        While !(cAliasTRB1)->(EOF())

            SE2->(DBSelectArea("SE2"))
            SE2->(DBGoTo((cAliasTRB1)->E2RECNO))

            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Reprocessando Registro: " + CValToChar((cAliasTRB1)->E2RECNO)))

            /*
            If SE2->E2_PORTADO == cBanco
            
                // Limpa dados do borderô
                SEA->(DBSelectArea("SEA"))
                SEA->(DBSetOrder(1))
                If SEA->(DBSeek(FWxFilial("SEA") + SE2->E2_NUMBOR + "P" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
                    RecLock("SEA", .F.)
                        SEA->(DBDelete())
                    SE2->(MSUnLock())
                EndIf

            EndIf
            */
                
            RecLock("SE2", .F.)
                /*
                If SE2->(FieldPos("E2_XPORTAD")) > 0 .And. !Empty(SE2->E2_XPORTAD)
                    SE2->E2_PORTADO := SE2->E2_XPORTAD
                EndIf
                SE2->E2_NUMBOR  := Space(TamSX3("E2_NUMBOR")[1])
                SE2->E2_DTBORDE := CToD("")
                SE2->E2_XMNKSTA := Space(TamSX3("E2_XMNKSTA")[1])
                SE2->E2_XMNKLOT := Space(TamSX3("E2_XMNKLOT")[1])
                */
                SE2->E2_XMNKLOT := cMNKLote
                SE2->E2_XMNKSTA := "4"  // Fora do vencimento
            SE2->(MSUnLock())

            (cAliasTRB1)->(DBSkip())

        EndDo

        If Select(cAliasTRB1) > 0
            (cAliasTRB1)->(DBCloseArea())
        EndIf
        
        // Query para selecao de registros
        cSQL2 := MNK03Qr2()

        If Select(cAliasTRB2) > 0
            (cAliasTRB2)->(DBCloseArea())
        EndIf
        DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL2), (cAliasTRB2), .F., .T.)

        Count To nRegua

        ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Query2: " + CValToChar(nRegua)))

        (cAliasTRB2)->(DBSelectArea(cAliasTRB2))
        (cAliasTRB2)->(DBGoTop())
        While !(cAliasTRB2)->(EOF())

            ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Selecionando Registro: " + CValToChar((cAliasTRB2)->E2RECNO)))
            
            SE2->(DBSelectArea("SE2"))
            SE2->(DBGoTo((cAliasTRB2)->E2RECNO))
            RecLock("SE2", .F.)
                SE2->E2_XMNKLOT := cMNKLote
                SE2->E2_XMNKSTA := "0"
                If SE2->(FieldPos("E2_XPORTAD")) > 0
                    SE2->E2_XPORTAD := SE2->E2_PORTADO
                EndIf
                If SE2->(FieldPos("E2_XRISCOS")) > 0
                    SE2->E2_XRISCOS := "S"
                EndIf
            SE2->(MSUnLock())

            (cAliasTRB2)->(DBSkip())

        EndDo

        If Select(cAliasTRB2) > 0
            (cAliasTRB2)->(DBCloseArea())
        EndIf

        If lUltimo
            ZM1->(DBSelectArea("ZM1"))
            ZM1->(DBSetOrder(1))
            If ZM1->(DBSeek(FWxFilial("ZM1") + cMNKLote))
                RecLock("ZM1", .F.)
                    ZM1->ZM1_STATUS := "2"
                ZM1->(MSUnLock())
            EndIf
        EndIf

        ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Fechando - Empresa: " + __cEmp + " / Filial: " + __cFil))

    RESET ENVIRONMENT

	If !Empty(AllTrim(GetGlbValue(cGlbName)))
		ClearGlbValue(cGlbName)
	EndIf

    ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | WSMNK03 Fim - Empresa: " + __cEmp + " / Filial: " + __cFil))

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK03Qr1
//Query de seleção de registros
@author Rafael Yera Barchi
@since 30/04/2021
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function MNK03Qr1()

    Local 	cSQL 		:= ""
//  Local   cPrefixo    := SuperGetMV("MK_PREFIXO", , "NEG")
    Local   dVctIni     := dDataBase - SuperGetMV("MK_VENCINI", , 0)
    Local   dVctFim     := dDataBase + SuperGetMV("MK_VENCINI", , 0)
//  Local   cBanco      := PadR(SuperGetMV("MK_BANCO", , ""), TamSX3("A6_COD")[1])


    If "MSSQL" $ Upper(AllTrim(TCGetDB()))

        cSQL := "          SELECT SE2.R_E_C_N_O_ E2RECNO " + cEOL

        cSQL += "            FROM " + RetSQLName("SE2") + " SE2 "
        If "MSSQL" $ Upper(AllTrim(TCGetDB()))
            cSQL += "(NOLOCK) " + cEOL
        Else
            cSQL += cEOL
        EndIf

        cSQL += "           WHERE E2_FILIAL BETWEEN '" + Space(TamSX3("E2_FILIAL")[1]) + "' AND '" + Replicate("z", TamSX3("E2_FILIAL")[1]) + "' " + cEOL        
        cSQL += "             AND E2_VENCREA BETWEEN '" + DToS(dVctIni) + "' AND '" + DToS(dVctFim) + "' " + cEOL
//      cSQL += "             AND E2_XMNKLOT <> '" + Space(TamSX3("E2_XMNKLOT")[1]) + "' " + cEOL
        cSQL += "             AND E2_XMNKSTA IN ('1', '4') " + cEOL
        cSQL += "             AND SE2.D_E_L_E_T_ = ' ' " + cEOL

        cSQL += "        ORDER BY SE2.R_E_C_N_O_ " + cEOL
        
    Else

        // Query revisada pelo Ricardo Almeida
        cSQL := "          SELECT SE2.R_E_C_N_O_ E2RECNO " + cEOL
        
        cSQL += "            FROM " + RetSQLName("SE2") + " SE2 " + cEOL
        
        cSQL += "           WHERE E2_FILIAL BETWEEN '" + Space(TamSX3("E2_FILIAL")[1]) + "' AND '" + Replicate("z", TamSX3("E2_FILIAL")[1]) + "' " + cEOL
        cSQL += "             AND E2_VENCREA BETWEEN '" + DToS(dVctIni) + "' AND '" + DToS(dVctFim) + "' " + cEOL
//      cSQL += "             AND E2_XMNKLOT != '" + Space(TamSX3("E2_XMNKLOT")[1]) + "' " + cEOL
        cSQL += "             AND E2_XMNKSTA IN ('1', '4') " + cEOL
        cSQL += "             AND SE2.D_E_L_E_T_ = ' ' " + cEOL
        
        // Removido a pedido do Sr. Ricardo Almeida em 02/08/2022
//      cSQL += "             AND SE2.R_E_C_N_O_ LIKE '%' " + cEOL

        cSQL += "        ORDER BY SE2.R_E_C_N_O_ " + cEOL

    EndIf

    cLogArq := "MNK03Qr1"
    MemoWrite(cLogDir + cLogArq + ".sql", cSQL)

Return cSQL



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MNK03Qr2
//Query de seleção de registros
@author Rafael Yera Barchi
@since 30/04/2021
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function MNK03Qr2()

    Local 	cSQL 		:= ""
//  Local   nLimTit     := SuperGetMV("MK_LIMTIT", , 50)
    Local   cPrefixo    := SuperGetMV("MK_PREFIXO", , "NEG")
//  Local   dEmiIni     := dDataBase - SuperGetMV("MK_EMISINI", , 30)
//  Local   dEmiFim     := dDataBase - SuperGetMV("MK_EMISFIM", , 0)
    Local   dVctIni     := dDataBase + SuperGetMV("MK_VENCINI", , 0)
//  Local   dVctFim     := dDataBase + SuperGetMV("MK_VENCFIM", , 90)
    Local   lLibPag     := SuperGetMV("MV_CTLIPAG", , .F.)
    

	If "MSSQL" $ Upper(AllTrim(TCGetDB()))
        
        /*
        If "MSSQL" $ Upper(AllTrim(TCGetDB()))
            cSQL := "          SELECT TOP " + CValToChar(nLimTit) + " SE2.R_E_C_N_O_ E2RECNO " + cEOL
        Else
            cSQL := "          SELECT SE2.R_E_C_N_O_ E2RECNO " + cEOL
        EndIf
        */
        cSQL := "          SELECT SE2.R_E_C_N_O_ E2RECNO " + cEOL

        cSQL += "            FROM " + RetSQLName("SE2") + " SE2 "
        If "MSSQL" $ Upper(AllTrim(TCGetDB()))
            cSQL += " (NOLOCK) " + cEOL
        Else
            cSQL += cEOL
        EndIf
        
        cSQL += "      INNER JOIN " + RetSQLName("SA2") + " SA2 "
        If "MSSQL" $ Upper(AllTrim(TCGetDB()))
            cSQL += " (NOLOCK) " + cEOL
        Else
            cSQL += cEOL
        EndIf
        cSQL += "              ON A2_FILIAL = '" + FWxFilial("SA2") + "' " + cEOL
        cSQL += "             AND A2_COD = E2_FORNECE " + cEOL
        cSQL += "             AND A2_LOJA = E2_LOJA " + cEOL
        cSQL += "             AND SA2.D_E_L_E_T_ = ' ' " + cEOL
        
        cSQL += "      INNER JOIN " + RetSQLName("SED") + " SED "
        If "MSSQL" $ Upper(AllTrim(TCGetDB()))
            cSQL += " (NOLOCK) " + cEOL
        Else
            cSQL += cEOL
        EndIf
        cSQL += "              ON ED_FILIAL = '" + FWxFilial("SED") + "' " + cEOL
        cSQL += "             AND ED_CODIGO = E2_NATUREZ " + cEOL
        cSQL += "             AND SED.D_E_L_E_T_ = ' '  " + cEOL

    //  cSQL += "           WHERE E2_FILIAL = '" + FWxFilial("SE2") + "' " + cEOL
        cSQL += "           WHERE E2_FILIAL BETWEEN '" + Space(TamSX3("E2_FILIAL")[1]) + "' AND '" + Replicate("z", TamSX3("E2_FILIAL")[1]) + "' " + cEOL
        cSQL += "             AND E2_PREFIXO <> '" + cPrefixo + "' " + cEOL
    //  cSQL += "             AND E2_EMISSAO BETWEEN '" + DToS(dEmiIni) + "' AND '" + DToS(dEmiFim) + "' " + cEOL
        cSQL += "             AND E2_VENCREA > '" + DToS(dVctIni) + "' " + cEOL
    //  cSQL += "             AND E2_PORTADO = '" + Space(TamSX3("E2_PORTADO")[1]) + "' " + cEOL
        cSQL += "             AND E2_NUMBOR = '" + Space(TamSX3("E2_NUMBOR")[1]) + "' " + cEOL
        cSQL += "             AND E2_SALDO > 0 " + cEOL
        cSQL += "             AND E2_VALLIQ = 0 " + cEOL
        cSQL += "             AND E2_TIPO <> 'PA ' " + cEOL
        cSQL += "             AND E2_TIPO <> 'NCF' " + cEOL
        cSQL += "             AND E2_TIPO <> 'NDF' " + cEOL

        cSQL += "             AND E2_XMNKLOT = '" + Space(TamSX3("E2_XMNKLOT")[1]) + "' " + cEOL

        If lLibPag
            cSQL += "             AND E2_DATALIB <> '" + Space(TamSX3("E2_DATALIB")[1]) + "' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XRISCOS")) > 0
            cSQL += "             AND E2_XRISCOS = 'S' " + cEOL
        EndIf

        If SA2->(FieldPos("A2_XRISSAC")) > 0
            cSQL += "             AND A2_XRISSAC = '" + PadR("S", TamSX3("A2_XRISSAC")[1]) + "' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XMIGLT")) > 0
            cSQL += "             AND E2_XMIGLT = '" + Space(TamSX3("E2_XMIGLT")[1]) + "' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XANALIS")) > 0
            cSQL += "             AND E2_XANALIS = 'S' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XSTRECU")) > 0
            cSQL += "             AND E2_XSTRECU <> 'R' " + cEOL
        EndIf

        // Removido nos testes realizados em 13/08/2021
        /*
        If SE2->(FieldPos("E2_XLIBERA")) > 0
            cSQL += "             AND E2_XLIBERA = 'L' " + cEOL
        EndIf
        */

        If SA2->(FieldPos("A2_XINTMNK")) > 0
            cSQL += "             AND A2_XINTMNK = '1' " + cEOL
        EndIf
        cSQL += "             AND SE2.D_E_L_E_T_ = ' ' " + cEOL

        /*
        If Upper(AllTrim(TCGetDB())) == "ORACLE"
            cSQL += "             AND ROWNUM <= " + CValToChar(nLimTit) + cEOL
        EndIf
        */

        cSQL += "        ORDER BY SE2.R_E_C_N_O_ " + cEOL

    Else

        cSQL := "          SELECT R_E_C_N_O_ E2RECNO " + cEOL
        cSQL += "            FROM (SELECT SE2.R_E_C_N_O_ " + cEOL
        cSQL += "                    FROM " + RetSQLName("SE2") + " SE2, " + RetSQLName("SED") + " SED, " + RetSQLName("SA2") + " SA2 " + cEOL 
        cSQL += "                   WHERE SED.ED_CODIGO = SE2.E2_NATUREZ " + cEOL
        cSQL += "                     AND SA2.A2_COD = SE2.E2_FORNECE " + cEOL
        cSQL += "                     AND SA2.A2_LOJA = SE2.E2_LOJA " + cEOL
        cSQL += "                     AND SA2.A2_FILIAL = '" + FWxFilial("SA2") + "' " + cEOL
        cSQL += "                     AND SA2.D_E_L_E_T_ = ' ' " + cEOL

        If SA2->(FieldPos("A2_XINTMNK")) > 0
            cSQL += "                     AND SA2.A2_XINTMNK = '1' " + cEOL
        EndIf
        
        If SA2->(FieldPos("A2_XRISSAC")) > 0
            cSQL += "                     AND SA2.A2_XRISSAC = '" + PadR("S", TamSX3("A2_XRISSAC")[1]) + "' " + cEOL
        EndIf

        cSQL += "                     AND SED.ED_FILIAL = '" + FWxFilial("SED") + "' " + cEOL
        cSQL += "                     AND SED.D_E_L_E_T_ = ' ' " + cEOL
        cSQL += "                     AND SE2.E2_FILIAL BETWEEN '" + Space(TamSX3("E2_FILIAL")[1]) + "' AND '" + Replicate("z", TamSX3("E2_FILIAL")[1]) + "' " + cEOL
        cSQL += "                     AND SE2.E2_PREFIXO <> '" + cPrefixo + "' " + cEOL
        cSQL += "                     AND SE2.D_E_L_E_T_ = ' ' " + cEOL
        cSQL += "                     AND SE2.R_E_C_N_O_ IN (SELECT R_E_C_N_O_ " + cEOL
        cSQL += "                                              FROM " + RetSQLName("SE2") + " SE2 "
        cSQL += "                                             WHERE E2_VENCREA > '" + DToS(dVctIni) + "' " + cEOL
        cSQL += "                                               AND E2_NUMBOR = '" + Space(TamSX3("E2_NUMBOR")[1]) + "' " + cEOL
        cSQL += "                                               AND E2_SALDO > 0 " + cEOL
        cSQL += "                                               AND E2_VALLIQ = 0 " + cEOL
        cSQL += "                                               AND E2_TIPO <> 'PA ' " + cEOL
        cSQL += "                                               AND E2_TIPO <> 'NCF' " + cEOL
        cSQL += "                                               AND E2_TIPO <> 'NDF' " + cEOL
        
        If lLibPag
            cSQL += "                                               AND E2_DATALIB <> '" + Space(TamSX3("E2_DATALIB")[1]) + "' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XRISCOS")) > 0
            cSQL += "                                               AND E2_XRISCOS = 'S' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XMIGLT")) > 0
            cSQL += "                                               AND E2_XMIGLT = '" + Space(TamSX3("E2_XMIGLT")[1]) + "' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XANALIS")) > 0
            cSQL += "                                               AND E2_XANALIS = 'S' " + cEOL
        EndIf

        If SE2->(FieldPos("E2_XSTRECU")) > 0
            cSQL += "                                               AND E2_XSTRECU <> 'R' " + cEOL
        EndIf

        // Removido nos testes realizados em 13/08/2021
        /*
        If SE2->(FieldPos("E2_XLIBERA")) > 0
            cSQL += "                                               AND E2_XLIBERA = 'L' " + cEOL
        EndIf
        */

        // Adicionado em 29/07/2022 a pedido do Sr. Ricardo Almeida
        cSQL += "                                               AND E2_XMNKSTA NOT IN ('1','2') " + cEOL

        cSQL += "                                               ) ) " + cEOL
        
//      cSQL += "           WHERE TRIM(E2_XMNKLOT) IS NULL " + cEOL
        
        cSQL += "        ORDER BY R_E_C_N_O_ " + cEOL

    EndIf

    cLogArq := "MNK03Qr2"
    MemoWrite(cLogDir + cLogArq + ".sql", cSQL)

Return cSQL
//--< fim de arquivo >----------------------------------------------------------------------
