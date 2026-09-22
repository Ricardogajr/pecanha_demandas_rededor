#INCLUDE "rwmake.ch"
#include "protheus.ch"

/*
{Protheus.doc} PE_FA430SE2 NÃO UTILIZADO
Ponto de entrada para posicionar os títulos da caixa cujo idcnab tem tamanho reduzido
@Author     Ramon Teodoro e Silva
@Since      21/12/2020     
@Version    P12.27
@Return
*/

User Function FA430SE2

Local lRet    := .T.
Local aArea   := GetArea()
Local aParam  := PARAMIXB
Local cIdCnab := ""
Local cBanco   := mv_par05
Local cAgencia := mv_par06
Local cConta   := mv_par07 
Local lFilSimp := U_VALSIMP(cFilAnt)

If !Empty(aParam)

    cIdCnab := Paramixb[1][1]

    If Alltrim(cBanco) = "104" .And. !Empty(cIdCnab)

        cQuery := "SELECT R_E_C_N_O_ REC FROM " + RetSQLName("SE2") + " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
        cQuery += "E2_PORTADO = '" + cBanco + "' AND E2_XAGEPOR = '" + cAgencia + "' AND E2_XCONPOR = '" + cConta + "' AND "
        cQuery += "SUBSTR(E2_IDCNAB,5, 6) = '" + cIdCnab + "' AND D_E_L_E_T_ = ''"
        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB104", .F., .T. )

        If TRB104->(!Eof())
            SE2->(DbGoTo(TRB104->REC))
            nMulta := SE2->E2_MULTA
            nJuros := SE2->E2_JUROS + SE2->E2_ACRESC
        EndIf

        TRB104->(DbCloseArea())

    Else
        If lFilSimp
            If !Empty(cIdCnab)  
                nMulta := SE2->E2_MULTA 
                nJuros := SE2->E2_JUROS + SE2->E2_ACRESC
            EndIf
        Endif
        RestArea(aArea)
    EndIf

EndIf

Return lRet
