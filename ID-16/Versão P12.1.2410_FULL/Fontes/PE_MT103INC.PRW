#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT103INC
Ponto de entrada para a validação da Inclusão ou Classificação Fiscal do Documento de Entrada
@type function
@author Robson William
@since 07/05/2017
@version 1.0
@project MAN00000462901_EF_004
/*/

User Function MT103INC()
    Local lRetorno := .T.
    Local lEClassificacao := ParamIxb
    
    If lEClassificacao
        lRetorno := U_F010101QVALIDACLASSIFICACAO()
    EndIf

Return lRetorno