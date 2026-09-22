#include "totvs.ch"

/*{Protheus.doc} MT010INC
Ponto de entrada apos a inclusão do produto.

@author Alex Sandro
@since 08/02/2017
@project MAN0000007423041_EF_024
@return Nil
*/

User Function MT010INC()

    U_F0702401("I") // Rotina para inclusão dos registros para tratamentos por filiais
    U_F0702505(SB1->B1_COD)

Return Nil

