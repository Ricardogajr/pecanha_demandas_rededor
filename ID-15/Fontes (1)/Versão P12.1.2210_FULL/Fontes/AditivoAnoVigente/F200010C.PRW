#Include 'TOTVS.ch'
#INCLUDE 'FILEIO.CH'

#Define INCLUI_PREV 01
#Define ALTERA_PREV 02
#Define EXCLUI_PREV 03
#Define ENVBAN_PREV 04
#Define REJBAN_PREV 05
#Define BAIXAT_PREV 06
#Define ESTBXA_PREV 07
#Define GRVCHQ_PREV 08
#Define ESTCHQ_PREV 09
#Define ENVBAN_REAL 21
#Define REJBAN_REAL 22
#Define BAIXAT_REAL 23
#Define ESTBXA_REAL 24
#Define GRVCHQ_REAL 31
#Define ESTCHQ_REAL 32
#Define PAGADT_REAL 41
#Define RECADT_REAL 42

/*/{Protheus.doc} F200010C

Grava borderÃ´ no tÃ­tulo de temperatura 2, transformando-o em temperatura 1

@type function
@version  
@author fabio.cazarini
@since 26/10/2021
@param cEmpAux, character, param_description
@param cFilAux, character, param_description
@return variant, return_description
/*/
User Function F200010C(cEmpAux, cFilAux)
    Local aAreaSE2  := {}
    Local aAreaFK2  := {}
    Local aAreaFK5  := {}
    Local aAreaPX0  := {}
    Local aAreas    := {} 
    Local cQuery    := ''
    Local cAlPX0    := ''
    Local cChvSE2   := ''
    Local cNumBor   := ""
    //Local lAmbiente := .F.
    Local cWsCall := 'S_F200010'

	Default cEmpAux     := FwCodEmp()
    Default cFilAux     := FwCodFil()
    
    //Tratamento de semáforo
    if !GlbNmLock(cWsCall)
        Conout("THREAD: " + cValToChar(threadID()) + " a Rotina(F200010C) esta em uso e não será chamada.")
        Return       
    else
        Conout("THREAD: " + cValToChar(threadID()) + " a Rotina(F200010C) não esta em uso e será chamada.")
    EndIf
    RpcSetEnv(cEmpAux, cFilAux,,, "FIN", "U_F200010C")
/*
    If !(Empty(cEmpAux)) .And. !(Empty(cFilAux))
		If !(Select("SX2") > 0)
            RpcSetEnv(cEmpAux, cFilAux,,, "FIN", "U_F200010C")
            If Select("SX2") > 0
                lAmbiente := .T.
            Else
				ConOut('F2000103 - F200010C - Integ XRT Titulos AP - Nao foi possivel conectar com o ambiente '+FwTimeStamp(2))
                Return NIL
            EndIf
        EndIf
    EndIf
*/
    aAreaSE2  := SE2->(GetArea())
    aAreaFK2  := FK2->(GetArea())
    aAreaFK5  := FK5->(GetArea())
    aAreaPX0  := PX0->(GetArea())
    aAreas    := {aAreaPX0, aAreaFK2, aAreaFK5, aAreaSE2, GetArea()} 
    cNumBor   := Space(Len(PX0->PX0_NUMBOR))

    Conout('F2000103 - F200010C - Integ XRT Titulos AP - Consulta de previstos sem bordero '+FwTimeStamp(2))

    /*/cQuery := " Select R_E_C_N_O_ PX0Rec From "+RetSqlName('PX0')
    //cQuery += " Where  PX0_FILIAL = '"+FWXFilial('PX0')+"' "
    //cQuery += "    And PX0_STTIT  = '3' " //Temp 2
    cQuery += "    Where PX0_STTIT  = '3' " //Temp 2
    cQuery += "    And PX0_NUMBOR = '"+cNumBor+"' "
    cQuery += "    And PX0_EXC = '2' "
    cQuery += "    And D_E_L_E_T_ = ' ' "
    cQuery += " Order by R_E_C_N_O_ Desc "/*/


    //NOVA QUERY TESTE PARA NÃO FICAR ATUALIZANDO DADOS DESNECESSÁRIOS NA PX0 TODA HORA - LUCAS MIRANDA
    cQuery := " SELECT A.R_E_C_N_O_ AS PX0Rec FROM " + RetSqlName("PX0") + " A " 
    cQuery += " LEFT JOIN " + RetSqlName("PX0") + " B " 
    cQuery += " ON B.PX0_CHAVE = A.PX0_CHAVE "
    cQuery += " AND B.PX0_FILIAL = A.PX0_FILIAL " 
    cQuery += " AND B.D_E_L_E_T_ = ' ' "
    cQuery += " AND B.PX0_CHAVE = A.PX0_CHAVE " 
    cQuery += " AND B.PX0_NUMBOR <> ' ' " 
    cQuery += " WHERE A.PX0_STTIT = '3' "
    cQuery += " AND A.PX0_NUMBOR = '"+cNumBor+"' "
    cQuery += " AND A.PX0_EXC = '2'  "
    cQuery += " AND A.D_E_L_E_T_ = ' ' " 
    cQuery += " AND B.PX0_CHAVE IS NULL "
    //FIM DA QUERY
 
    cQuery := ChangeQuery(cQuery)

    cAlPX0 := MPSysOpenQuery(cQuery)

    SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
    FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
    cFilBkp := cFilAnt     
    While !(cAlPX0)->(EoF())
        nRecnoPX0 := (cAlPX0)->PX0Rec        
        PX0->(DbGoto(nRecnoPX0))        
        cFilAnt := PX0->PX0_FILIAL
        If PX0->PX0_ORIGEM == 'FK2'
            If FK2->(DbSeek(RTrim(PX0->PX0_CHAVE)))
                cChvSE2 := U_F2000108(FK2->FK2_IDDOC)
            EndIf
        ElseIf PX0->PX0_ORIGEM == 'FK5'
            If FK5->(DbSeek(RTrim(PX0->PX0_CHAVE)))
                cChvSE2 := U_F2000211(FK5->FK5_IDMOV, FK5->FK5_IDDOC)
            EndIf
        Else
            cChvSE2 := RTrim(PX0->PX0_CHAVE)
        EndIf
        If !Empty(cChvSE2) .And. SE2->(DbSeek(cChvSE2))
            If !Empty(SE2->E2_NUMBOR)
                U_F2000100('SE2', ALTERA_PREV) //Atualiza os dados do tÃ­tulo
            EndIf
        EndIf
        
        (cAlPX0)->(DbSkip())
    EndDo
    cFilAnt := cFilBkp
    Conout('F2000103 - F200010C - Integ XRT Titulos AP - termino do ajuste de titulos previstos '+FwTimeStamp(2))
    Conout("F2000103 - Inicio da chamada F2001031")
        U_F2001031()//Função transferida para cá, depois do borderô, para não ficar gravando dados na PX0 simultaneamente,
    Conout("F2000103 - Fim da chamada F2001031")
    (cAlPX0)->(DbCloseArea())

    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)

    GlbNmUnlock(cWsCall)

	RpcClearEnv()
    
Return NIL
