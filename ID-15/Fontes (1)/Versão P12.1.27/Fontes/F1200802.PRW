#Include "totvs.ch"

/*{Protheus.doc} F1200802
validação de alteração e exclusao da tabela de preço fornecedor
    
@author Sandro
@since 18/08/2017
@param lRet Retorno por referencia
@param cAlias
@param nRecno
@param cFunction
@project MAN0000007423046_EF_008
@obs
    Utilizando no ponto de entrada MBRWBTN
    
*/
User Function F1200802(cAlias, nRecno, nOption, cFunction ) 
    
    Local aContrato := {}
    Local cMsg      := ""
    Local nx
    Local cTipRev   := GetMv("FS_TIPREVT", ,"004")
    Local lRet      := .T.

    If nOption <> 4 .And. nOption <> 5
        Return lRet
    EndIf 

    If ! cFunction == "COM010TAB" 
        Return lRet
    EndIf

    If !BuscaContrato(AIA->AIA_CODFOR, AIA->AIA_LOJFOR, AIA->AIA_CODTAB, aContrato, nOption == 4)
        cMsg := "Tabela de preço bloqueada - Contrato(s) não se encontra(m) em Elaboração"
        If nOption == 4
            cMsg += " ou Revisão do tipo [" + cTipRev +"]"
        EndIf
        cMsg += CRLF

        For nx:= 1 to len(aContrato)
            If aContrato[nx,3] == "F"
                cMsg += aContrato[nx,1] + " - " + aContrato[nx,2] + CRLF
            EndIf
        Next

        MsgAlert(cMsg)
        lRet := .F.

    ElseIf !ValidaUsuario(aContrato)
        MsgAlert("Usuário sem acesso a manutenção da tabela de preços. - Entre em contato com o gestor do contrato para solicitar o acesso na tabela de preço.")
        lRet := .F.  
    
    EndIf

Return lRet


Static Function BuscaContrato(cCodFor, cLoja, cCodTab, aContrato, lAlteracao)

    Local aArea     := GetArea()
    Local cQuery    := ""
    Local lLiberado := .T.
    Local cTipRev   := GetMv("FS_TIPREVT", ,"004")
    Local cQRYAlias := GetNextAlias()

    //aContrato := {{"0000100010","001"},{"0000100009","003"}}

    cQuery := "SELECT CNA.CNA_CONTRA, CNA.CNA_REVISA, "
    cQuery += "CASE WHEN ( "
    cQuery += "     CN9.CN9_SITUAC = '02' "
    If lAlteracao
        cQuery += " OR (CN9.CN9_SITUAC = '09' AND CN9.CN9_TIPREV = '" + cTipRev + "') "
    EndIf 
    cQuery += "     ) THEN 'T' ELSE 'F' END AS LIBER "
	cQuery += "FROM " + RetSQLName("CN9") + " CN9 "
	cQuery += "INNER JOIN " + RetSqlName("CNA") + " CNA ON "
    cQuery += "      CN9.CN9_NUMERO = CNA.CNA_CONTRA AND 
    cQuery += "      CN9.CN9_REVISA = CNA.CNA_REVISA AND 
    cQuery += "      CN9.CN9_FILIAL = CNA.CNA_FILIAL "
	cQuery += " WHERE CNA.CNA_FILIAL = '" + XFilial('CNA') + "' AND "
	cQuery += "       CN9.CN9_FILIAL = '" + XFilial('CN9') + "' AND "
	cQuery += "       CNA.CNA_XTABPC = '" + cCodTab + "' AND "
    cQuery += "       CNA.CNA_FORNEC = '" + cCodFor + "' AND "
    cQuery += "       CNA.CNA_LJFORN = '" + cLoja + "' AND "
    cQuery += "       CNA.D_E_L_E_T_ = ' ' AND "
	cQuery += "       CN9.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( ,, cQuery), cQRYAlias, .F., .T.)
    Do While !(cQRYAlias)->(Eof())
	    aAdd(aContrato, {(cQRYAlias)->CNA_CONTRA, (cQRYAlias)->CNA_REVISA, (cQRYAlias)->LIBER })
        lLiberado := lLiberado .And. (cQRYAlias)->LIBER == "T"
        (cQRYAlias)->(DbSkip())
    EndDo
	(cQRYAlias)->(dbCloseArea())

    RestArea(aArea)
    
Return lLiberado

Static Function ValidaUsuario(aContrato)
    
    Local aArea     := GetArea()
    Local aAreaCNN  := CNN->(GetArea())
    Local lValido   := .F.
    Local nGrupo    := 0
    Local nContrato := 0
    Local aGrupo    := PswRet()[1][10] //UsrGrComp(__cUserID)
    
    Begin Sequence
    
        If Empty(aContrato)
            lValido := .T.
            Break
        EndIf
        
        If Len(aGrupo) == 0
            Break
        EndIf

        If AScan(aGrupo, "*") != 0
            lValido := .T.
            Break
        EndIF

        For nContrato:= 1 to len(aContrato)
            CNN->(DbSetOrder(1))
            If CNN->(DbSeek(XFilial("CNN") + __cUserID + aContrato[nContrato, 1])) .And. CNN->CNN_TRACOD == "001"
                lValido := .T.
                Break
            EndIf
            CNN->(DbSetOrder(2))
            For nGrupo := 1 to Len(aGrupo)
                If CNN->(DbSeek(XFilial("CNN") + aGrupo[nGrupo] + aContrato[nContrato, 1])) .And. CNN->CNN_TRACOD == "001"
                    lValido := .T.
                    Break
                EndIf
            Next
        Next

    End Sequence

    RestArea(aAreaCNN)
    RestArea(aArea)

Return lValido
				