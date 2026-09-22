#include "totvs.ch"

/*{Protheus.doc} MT240EST
Ponto de entrada para validar o estorno do movimento interno

@author Alex Sandro
@since 08/03/2017
@project MAN0000007423041_EF_035
@return Nil
*/

User Function MT240EST()
Local lRet := .f.

    lRet := U_F0703503() // Não pode estornar movimento gerados de integração.

Return lRet

