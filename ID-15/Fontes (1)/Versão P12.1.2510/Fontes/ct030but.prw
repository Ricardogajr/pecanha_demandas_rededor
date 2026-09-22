#INCLUDE "protheus.ch"
/*/{Protheus.doc} CT030BUT
Customização do menu centro de custo
@type function
@version P122410 
@author Ricardo Junior
@since 1/9/2026
@return variant, Nil
/*/
User Function CT030BUT()
Local aBotoes := ParamIXB
 
aAdd(aBotoes,{ "C.Custo x Filial" , "Processa( { || U_P52SELCC() })", 0, 0} )
 
Return aBotoes
