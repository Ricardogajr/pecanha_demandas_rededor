/*/{Protheus.doc} FA090TIT
Ponto de entrada executado na saida da funcao de baixa multifilial.
@type User function
@author Paulo Kruger
@since 22/03/2017
@project MAN0000007423041_EF_029
@return  lOkBaixar, Se pode baixar ou não.
/*/

User Function FA090TIT() 
    Local aArea     := GetArea()
    Local lOkBaixar := .T.

    //Bloqueio de Notas Fiscais de Entrada
    lOkBaixar := U_F0702901(SE2->E2_XID)

    RestArea(aArea)

Return lOkBaixar