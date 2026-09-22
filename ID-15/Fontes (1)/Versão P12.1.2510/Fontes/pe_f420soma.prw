#INCLUDE "rwmake.ch"
#include "protheus.ch"


/*
{Protheus.doc} PE_F420SOMA
Ponto de entrada para acumular valores dos títulos no lote, considerando o valor dos campos e2_juros e e2_multa. 
@Author     Ramon Teodoro e Silva
@Since      13/12/2020     
@Version    P12.27
@Return
*/
User Function F420SOMA

Local nRet := 0

//nRet := SE2->(E2_SALDO+E2_SDACRES+E2_MULTA+E2_JUROS-E2_SDDECRE)
nRet := SE2->(E2_SALDO+E2_SDACRES+E2_MULTA+E2_JUROS+E2_XTXEXPE-E2_SDDECRE) // ticket n° 10326179

Return nRet 
