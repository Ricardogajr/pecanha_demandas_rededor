#include "rwmake.ch"
#include "protheus.ch"

User Function A103VLEX()

Local aArea := GetArea()
Local AareaE2 := SE2->(GetArea())
Local lRet := .T.

//Verifica se a LOJA DO ISS é 01 e muda para 00 antes da exclusão
U_FLJMUNIC()
 

RestArea(AareaE2)
RestArea(aArea)
Return lRet
