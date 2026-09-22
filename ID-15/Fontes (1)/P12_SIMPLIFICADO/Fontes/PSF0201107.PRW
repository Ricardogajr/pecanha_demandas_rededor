#Include "Protheus.ch"
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} F0201107(cCodigo)
Verifica se o subgrupo que está sendo manipulado na tela de cadastro de produtos pertence ao
mesmo tipo de produto.
@project    MAN0000007423048
@type       User Function
@author     Alceu Pereira
@since      15/04/2019
@version    1.0
@return     lRet, se validou ou não
/*/
              
User Function F0201107()

    Local aArea := GetArea()
    Local lRet  := .T.
    Local cQuery    := ""
    Local cAliasQry := GetNextAlias()

    cQuery :=  "SELECT "
    cQuery +=      "BM_MSBLQL, BM_DESC, P25_DESCSU "
    cQuery +=  "FROM "
    cQuery +=       RETSQLNAME("SBM")+ " BM "
    cQuery +=  "INNER JOIN "+ RETSQLNAME("P25") +" P25 ON  "
    cQuery +=  "	P25.P25_TIPO = BM.BM_GRUPO AND "
    cQuery +=  "	P25.D_E_L_E_T_ = ' ' "
    cQuery +=  "WHERE "
    cQuery +=  "	P25.P25_SUBGRP = '" + M->B1_XSUBGRP + "' AND "
    cQuery +=  "	BM.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

    If (cAliasQry)->( EOF())

	Help('',1,'Help',"MATA010","Não é possível utilizar este subgrupo, ele está associado ao tipo INATIVO.",1,0)
        (cAliasQry)->( dbCloseArea() )
        RestArea(aArea)
        lRet := .F.

    Else
        If (cAliasQry)->BM_MSBLQL == "1"

            Help('',1,'Help',"MATA010","Subgrupo está bloqueado e não pode ser utilizado",1,0)
            (cAliasQry)->( dbCloseArea() )
            lRet := .F.

        EndIf
    EndIf

    RestArea(aArea)

Return (lRet)