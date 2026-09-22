#Include "Protheus.ch"
/*/{Protheus.doc} AfterLogin
Anstes de Logar para informar ao usuário que é uma filial Simplificada.
@type function
@version P12 
@author Ricardo junior
@since 1/10/2025
@return variant, Nulo
/*/ 
User Function AfterLogin()
    Local aArea := GetArea()
    if U_VALSIMP(cFilAnt)
        MsgInfo("Você está acessando uma filial do P12 Simplificado!", "Atenção")
    endif    
    RestArea(aArea)
Return
