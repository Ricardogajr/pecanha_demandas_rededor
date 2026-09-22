#Include "protheus.ch"
/*/{Protheus.doc} VALSIMP
Função responsável por verificar se a filial é P12 Simplificado.
@type  Function
@author user
@since 02/12/2024
@version P12
@param cFil, character, código da filial
@return logical, Retorna .T. caso a filial seja simplificada
/*/
User Function VALSIMP(cFil)
    Local aArea := GetArea()
    Local lValida := .F.

    Default cFil := cFilAnt 
    
    DbSelectArea("P33")
    DbSetOrder(01)
    if P33->(DbSeek(xFilial("P33")+PadR(cFil, TamSx3("P33_FILIAL")[01])))
        if AllTrim(P33->P33_SIMP) == "S" .And. AllTrim(P33->P33_STATUS) == "2"
            lValida := .T.
        endif
    endif 

    RestArea(aArea)
Return lValida
