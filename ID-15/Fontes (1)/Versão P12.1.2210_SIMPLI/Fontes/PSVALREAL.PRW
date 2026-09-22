#include "rwmake.ch"
// Usado na Rotina SISPAG arquivo 341teste.pag
// Usado na Rotina SISPAG arquivos 341?TITN.pag   (  ? => refere-se ao número das empresas existentes )

User Function VALREAL()

Local nRet := 0

nRet := STRZERO(SE2->(E2_SALDO+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)*100,15)

Return(nRet)
