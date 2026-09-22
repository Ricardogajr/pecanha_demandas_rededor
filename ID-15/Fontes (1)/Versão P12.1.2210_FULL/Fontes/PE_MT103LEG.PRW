#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT103LEG
Ponto de entrada para adicionar novas legendas na tela de Documento de Entrada
@type function
@author Robson William
@since 07/05/2017
@version 1.0
@project MAN00000462901_EF_004
/*/

User Function MT103LEG()
    Local aRetorno := ParamIxb[1]
        
    U_F010101RINCLUILEGENDA(aRetorno)
    
Return aRetorno