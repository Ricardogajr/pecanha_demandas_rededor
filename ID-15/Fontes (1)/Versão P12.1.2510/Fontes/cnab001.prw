#INCLUDE "rwmake.ch"

***************************************************************************************************************************************************
* Função para retornar o número da conta bancária do funcionário sem o dígito que é o ultimo caracter do campo RA_CTDEPSA.                        *
***************************************************************************************************************************************************
User Function CNAB001()
***************************************************************************************************************************************************

Local cRet  := ""
Local aArea := GetArea()

cRet := StrZero(Val(Alltrim(Substr(SRA->RA_CTDEPSA,1,Len(Alltrim(SRA->RA_CTDEPSA))-1))),7)

RestArea(aArea)

Return(cRet)