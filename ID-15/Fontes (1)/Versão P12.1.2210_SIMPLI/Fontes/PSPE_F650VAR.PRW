#INCLUDE "rwmake.ch"
#include "protheus.ch"

/*
{Protheus.doc} PE_F650VAR
Ponto de entrada para manipular valores dos títulos no relatório de retorno de CNAB
@Author     Ramon Teodoro e Silva
@Since      21/12/2020     
@Version    P12.27
@Return
*/

User Function F650VAR

Local lRet      := .T.
Local aArea     := GetArea()
Local aParam    := PARAMIXB
Local cIdCnab   := ""
Local cBanco    := mv_par03
Local cAgencia  := mv_par04
Local cConta    := mv_par05 

If !Empty(aParam)

    cIdCnab := Paramixb[1][1]

    If Alltrim(cBanco) = "104" .And. !Empty(cIdCnab)

        cQuery := "SELECT E2_IDCNAB, E2_NUM, E2_VALOR, E2_JUROS, E2_MULTA, E2_ACRESC, E2_DESCONT, E2_DECRESC FROM " + RetSQLName("SE2") + " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
        cQuery += "E2_PORTADO = '" + cBanco + "' AND E2_XAGEPOR = '" + cAgencia + "' AND E2_XCONPOR = '" + cConta + "' AND "
        cQuery += "SUBSTR(E2_IDCNAB,5, 6) = '" + cIdCnab + "' AND D_E_L_E_T_ = ''"
        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB104", .F., .T. )

        If TRB104->(!Eof())
            cNumTit  := TRB104->(E2_IDCNAB)
            nMulta   := TRB104->(E2_MULTA)
            nJuros   := TRB104->(E2_JUROS) + TRB104->(E2_ACRESC)
            nDescont := TRB104->(E2_DECRESC)
        EndIf

        TRB104->(DbCloseArea())

    ElseIf !Empty(cIdCnab)

        cQuery := "SELECT E2_IDCNAB, E2_NUM, E2_VALOR, E2_JUROS, E2_MULTA, E2_ACRESC, E2_DESCONT, E2_DECRESC FROM " + RetSQLName("SE2") + " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
        cQuery += "E2_PORTADO = '" + cBanco + "' AND E2_XAGEPOR = '" + cAgencia + "' AND E2_XCONPOR = '" + cConta + "' AND "
        cQuery += "E2_IDCNAB = '" + cIdCnab + "' AND D_E_L_E_T_ = ''"
        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB104", .F., .T. )

        If TRB104->(!Eof())
            nMulta   := TRB104->(E2_MULTA) 
            nJuros   := TRB104->(E2_JUROS) + TRB104->(E2_ACRESC)
            nDescont := TRB104->(E2_DECRESC)
        EndIf

        TRB104->(DbCloseArea())
    
    EndIf

EndIf

RestArea(aArea)
Return lRet
