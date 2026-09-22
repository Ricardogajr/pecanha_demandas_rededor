#include "totvs.ch"

User Function MT103MSD()

Local aArea := GetArea()
Local aAreaE2 := SE2->(GetArea())

U_FLJMUNIC()//Função para mudar a loja do fornecedor de titulo de ISS para 0 caso exista.
 
RestArea(aAreaE2)
RestArea(aArea)
Return .T.
