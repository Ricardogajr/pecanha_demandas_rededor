#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT140COR
Ponto de entrada para adicionar novas legendas na tela de Prenota Específica
@type function
@author Ramon Teodoro
@since 24/01/2023
/*/

User Function MT140COR()
    Local aRetorno := ParamIxb[1]
        
    aRetorno := U_F010101SINCLUICOR(aRetorno)
    
Return aRetorno
