#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT103COR
Ponto de entrada para adicionar novas legendas na tela de Documento de Entrada
@type function
@author Robson William
@since 07/05/2017
@version 1.0
@project MAN00000462901_EF_004
/*/

User Function MT103COR()
    Local aRetorno := ParamIxb[1]
        
    aRetorno := U_F010101SINCLUICOR(aRetorno)
    
Return aRetorno