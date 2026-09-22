#Include "Protheus.ch"

#DEFINE DEF_DOCUMENTO  01 //[01] Número do Documento
#DEFINE DEF_TIPO_DOC   02 //[02] Tipo de Documento
#DEFINE DEF_VALOR_DOC  03 //[03] Valor do Documento
#DEFINE DEF_APROVADOR  04 //[04] Código do Aprovador
#DEFINE DEF_USUARIO    05 //[05] Código do Usuário
#DEFINE DEF_GRP_APROV  06 //[06] Grupo do Aprovador
#DEFINE DEF_APROV_SUP  07 //[07] Aprovador Superior
#DEFINE DEF_MOEDA_DOC  08 //[08] Moeda do Documento
#DEFINE DEF_TX_MOEDA   09 //[09] Taxa da Moeda
#DEFINE DEF_DT_EMISSAO 10 //[10] Data de Emissão do Documento
#DEFINE DEF_NIVEL      13 //[13] Nivel

/*/{Protheus.doc} FLGREPRO
Rotina que realiza o reprocessamento das mensagens com erro na P20 para o FLUIG

@project
@type       User Function
@author     Lucas Miranda
@since      27/11/2019
@version    1.0.0
@return     Nil
/*/
User Function F1701302(cEmpCon,cFilCon)

    Local aDocument     := {}
    Local aRetorno      := {}

    Local cAliasQry     := ""
    Local cFilialBkp    := ""
    Local cQuery        := ""

    Local lEnviar       := .F.
    Local lOk           := .T.

    Local nOperation    := 0
    Local nSM0Recno     := 0

    Local oAttach       := Nil

    Default cEmpCon     := ""
    Default cFilCon     := ""

    If !(Select("SX2") > 0)
        RpcSetEnv(cEmpCon, cFilCon)
        If !(Select("SX2") > 0)
            lOk         := .F.
            Conout("Erro na abertura de ambiente em JOB")
        EndIf
    EndIf

    If lOk
        cQuery := " SELECT  SCR.CR_FILIAL, SCR.CR_STATUS, SCR.CR_NUM, SCR.CR_TIPO, "
        cQuery += "         SCR.CR_TOTAL, SCR.CR_NIVEL, SCR.CR_APROV, SCR.CR_USER, SCR.CR_APRORI, "
        cQuery += "         SCR.CR_GRUPO, SCR.CR_MOEDA, SCR.CR_TXMOEDA, SCR.CR_EMISSAO, "
        cQuery += "         SCR.CR_XFLINTE, SCR.CR_XIDFLG, SCR.D_E_L_E_T_ DELETADO, SCR.R_E_C_N_O_ RECNO "
        cQuery += " FROM " + RetSQLName("SCR") + " SCR "
        cQuery += " WHERE SCR.CR_TIPO IN ('SC', 'PC', 'CT', 'RV', 'MD') "
        cQuery += "   AND SCR.CR_STATUS IN ('02', '03', '05', '04', '06') " //02-Pendente/03-Liberado/04-Bloqueado/05-Aprovado por Outro Usuário/06-Documento Rejeitado
        cQuery += "   AND SCR.CR_XFLINTE IN (' ', '1', '2') "
        cQuery += " AND SCR.CR_EMISSAO > '20190601' "
        cQuery += " ORDER BY SCR.CR_FILIAL, SCR.CR_NUM, SCR.CR_TIPO"

        cQuery := ChangeQuery(cQuery)

        cAliasQry := GetNextAlias()

        MPSysOpenQuery(cQuery, cAliasQry)

        While !((cAliasQry)->(EoF()))

            If cFilAnt != (cAliasQry)->CR_FILIAL .And. Empty(cFilialBkp)
                cFilialBkp  := cFilAnt
                cFilAnt     := (cAliasQry)->CR_FILIAL
                nSM0Recno   := SM0->(Recno())
                SM0->(DbSeek(FwCodEmp() + FwCodFil()))
            EndIf

            If ((cAliasQry)->CR_XFLINTE == "1" .Or. Empty((cAliasQry)->CR_XFLINTE))  .And. (cAliasQry)->CR_STATUS $ "02" .And. Empty((cAliasQry)->CR_XIDFLG)
                nOperation := 1
                lEnviar := .T.
                AAdd(aDocument, (cAliasQry)->CR_NUM)            // DEF_DOCUMENTO  01 - [01] Número do Documento
                AAdd(aDocument, (cAliasQry)->CR_TIPO)           // DEF_TIPO_DOC   02 - [02] Tipo de Documento
                AAdd(aDocument, (cAliasQry)->CR_TOTAL)          // DEF_VALOR_DOC  03 - [03] Valor do Documento
                AAdd(aDocument, (cAliasQry)->CR_APROV)          // DEF_APROVADOR  04 - [04] Código do Aprovador
                AAdd(aDocument, (cAliasQry)->CR_USER)           // DEF_USUARIO    05 - [05] Código do Usuário
                AAdd(aDocument, (cAliasQry)->CR_GRUPO)          // DEF_GRP_APROV  06 - [06] Grupo do Aprovador
                AAdd(aDocument, "") //não será necessário       // DEF_APROV_SUP  07 - [07] Aprovador Superior
                AAdd(aDocument, (cAliasQry)->CR_MOEDA)          // DEF_MOEDA_DOC  08 - [08] Moeda do Documento
                AAdd(aDocument, (cAliasQry)->CR_TXMOEDA)        // DEF_TX_MOEDA   09 - [09] Taxa da Moeda
                AAdd(aDocument, SToD((cAliasQry)->CR_EMISSAO))  // DEF_DT_EMISSAO 10 - [10] Data de Emissão do Documento
                AAdd(aDocument, "")                             //                   -
                AAdd(aDocument, "")                             //                   -
                AAdd(aDocument, (cAliasQry)->CR_NIVEL)          // DEF_NIVEL      13 - [13] Nivel
            ElseIf (cAliasQry)->CR_XFLINTE == "2" .And. !(Empty((cAliasQry)->CR_XIDFLG)) .And. (cAliasQry)->CR_STATUS $ "03|04|05|06|
                nOperation  := 4
                lEnviar     := .T.
            EndIf

            If lEnviar
                oAttach     := U_F1701102(, Identity((cAliasQry)->CR_USER),, AllTrim((cAliasQry)->CR_NUM),,, (cAliasQry)->CR_TIPO)
                aRetorno    := U_F1700101(.T., aDocument, nOperation, Val((cAliasQry)->CR_XIDFLG),,, oAttach)
                ASize(aDocument, 0)
                aDocument := {}
                lEnviar := .F.
                If aRetorno[1]
                    If (cAliasQry)->DELETADO = "*"
                        SET DELETED OFF
                        SCR->(DbGoTo((cAliasQry)->RECNO))
                        GrvXFluig(, "3")
                        SET DELETED ON
                    Else
                        SCR->(DbGoTo((cAliasQry)->RECNO))
                        GrvXFluig(, "3")
                    EndIf
                Else
                    SCR->(DbGoTo((cAliasQry)->RECNO))
                    If "que é o requisitante não foi encontrado." $ aRetorno[3][1]
                        GrvXFluig(, "3")
                EndIf
                EndIf
                FwFreeObj(oAttach)
            EndIf
            (cAliasQry)->(DbSkip())
        End

        (cAliasQry)->(DbCloseArea())
        //Restaura valor original da variável cFilAnt
        If !(Empty(cFilialBkp))
            cFilAnt     := cFilialBkp
            cFilialBkp  := ""
            SM0->(DbGoTo(nSM0Recno))
        EndIf
    EndIf

Return Nil

User Function TSTJob()

    While AlwaysTrue()
        Sleep(30000)
        U_F1701302("01", "01010004")
    End
Return Nil

/*Static Function SchedDef()

    Local aParam := {   "P"         ,;
        "ParamDef"  ,;
        "SCR"       ,;
        {}          ,;
        "Integração Fluig"}

Return aParam*/