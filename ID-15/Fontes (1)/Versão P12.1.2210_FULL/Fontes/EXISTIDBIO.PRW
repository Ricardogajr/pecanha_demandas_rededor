#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} ExistIdBio
Validação para verificar a existencia do idbionexo nas tabelas de Pedido, cotação ou Solicitação de compras.
cIdBio = Id da bionexo
cTABELA = "SC1", "SC7", "SC8"
@type function
@author Ricardo Junior
@since 17/07/2017
@version 1.0
@return lRet .T. valido, .F. não valido.
/*/
User Function ExistIdBio(cIdBio, cTabela)

    Local lRet      := .F.
    Local cQuery    := ""
    Local _cAlias   := GetNextAlias()
    Local _cTab     := RetSqlName(cTabela) 
    Local cCmpID    := SubStr(cTabela, 2, 2) + "_XIDBIO"
    
    cQuery := " SELECT * FROM " + _cTab + " " 
    cQuery += " WHERE D_E_L_E_T_ = ' ' "
    cQuery += " AND " + cCmpID + " = '"+ cIdBio +"'" 
    
    If Select(_cAlias) > 0
        (_cAlias)->(DbCloseArea())
    EndIf
    
    DbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.T. )	

    If !(_cAlias)->(Eof())
        lRet := .T.
    EndIf
    
    (_cAlias)->(DbCloseArea())
Return lRet