#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} FA050ALT
Validações adicionais ao alterar o titulo no contas a pagar.

@project    ID1559/MAN0000007423041_EF_069
@author     William Ferreira Souza/Marcelo Mendes
@since      04/04/2019
@return     lRet
/*/
User Function FA050ALT()

    Local aAreaFKD  := {}
    Local lRet      := .T.
    Local cQryFKD   := "" //ticket n° 10326179
    Local cTmp      := "" //ticket n° 10326179
    Local cChFK7    := "" //ticket n° 10326179
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    Local cFilE2    := ""//Correção erro dbseek FKD - Lucas Miranda
    Local lContinua := .T.
    Local lFilSimp := U_VALSIMP(cFilAnt)    
    
    If lRet .And. FindFunction("U_FSPE0027")
        lRet := U_FSPE0027()
    EndIf

    if !lFilSimp
        //ticket n° 10326179 -- tratamento para gravação em Valores Acessórios (lanç. manual)
        aAreaFKD  := FKD->(GetArea())
        cChFK7    := SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
        cFilE2 := SE2->E2_FILIAL//Correção erro dbseek FKD - Lucas Miranda

        //Bloco de correção quando estoura erro na query da FK7
        DbSelectArea("FK7")
        FK7->(DbSetOrder(2))

        If !FK7->(DbSeek(Space(TamSX3("FK7_FILIAL")[1])+"SE2"+cChFK7))
            If !FK7->(DbSeek(cFilE2+"SE2"+cChFK7))
                lContinua := .F.
            EndIf
        EndIf

        If lContinua
            DbSelectArea("FKD")
            FKD->(DbSetOrder(1))
            If FKD->(!DbSeek(cFilE2+'000001'+FK7->FK7_IDDOC))//Correção erro dbseek FKD - Lucas Miranda
                Reclock("FKD",.T.)
                FKD->FKD_FILIAL := FK7->FK7_FILIAL
                FKD->FKD_CODIGO := "000001"
                FKD->FKD_IDDOC  := FK7->FK7_IDDOC
                FKD->FKD_VALOR  := SE2->E2_XTXEXPE
                FKD->(MsUnLock())
            Elseif SE2->E2_XTXEXPE <> FKD->FKD_VALOR
                Reclock("FKD",.F.)
                FKD->FKD_VALOR  := SE2->E2_XTXEXPE
                FKD->(MsUnLock())
            EndIf
        EndIf
    //FIM
    /*/
    cQryFKD  := " SELECT FK7_FILIAL, FK7_IDDOC, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_XTXEXPE  "
    cQryFKD  += " FROM "+ RetSqlName("FK7") + " FK7 ," + RetSqlName("SE2") + " SE2 "
    cQryFKD  += " WHERE FK7.D_E_L_E_T_ = ' ' "
    cQryFKD  += " AND FK7_CHAVE = '" + cChFK7 + "'"
    cQryFKD  += " AND SE2.D_E_L_E_T_ = ' ' "
    cQryFKD  += " AND E2_NUM = '" + SUBSTR(cChFK7,14,9) + "'" 

    cQryFKD := ChangeQuery(cQryFKD)
    cTmp    := GetNextAlias() 
    DbUseArea( .T., "TOPCONN", TcGenQry( , , cQryFKD ), cTmp, .F., .T. )

    If (cTmp)->(!Eof())
        DbSelectArea("FKD")
        FKD->(DbSetOrder(1))
        If FKD->(!DbSeek(cFilE2+'000001'+(cTmp)->(FK7_IDDOC)))//Correção erro dbseek FKD - Lucas Miranda
            Reclock("FKD",.T.)
            FKD->FKD_FILIAL := (cTmp)->(FK7_FILIAL)
            FKD->FKD_CODIGO := "000001"
            FKD->FKD_IDDOC  := (cTmp)->(FK7_IDDOC)
            FKD->FKD_VALOR  := M->E2_XTXEXPE
            FKD->(MsUnLock())
        Elseif SE2->E2_XTXEXPE <> M->E2_XTXEXPE
            Reclock("FKD",.F.)
            FKD->FKD_VALOR  := M->E2_XTXEXPE
            FKD->(MsUnLock())
        EndIf
    
    EndIf 
    RestArea(aAreaFKD)
    // Fim -- ticket n° 10326179
    /*/
    endif
    If (ALLTRIM(SE2->E2_ORIGEM) $ "FINA870|FINA376|FINA378|FINA290|FINA290M") .and. SE2->E2_XSTRECU == "R"
        M->E2_XSTRECU := "C"
        M->E2_XDTRECU := dDataBase
    EndIf
    
    if !lFilSimp
        //Verifica se está habilitada a integração neste grupo de empresas
        If lGrpHblt
            If lRet .And. FindFunction('U_F2000416')
                lRet := U_F2000416() //Verifica se já existe operação financeira inclusa
            EndIf
        EndIf    
    endif
	
    If lRet
        lRet := U_XBARDDA1(.T.)
    EndIf

return lRet
