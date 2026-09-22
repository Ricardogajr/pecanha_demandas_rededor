#Include 'Protheus.ch'

/*
{Protheus.doc}  F590COK()
Ponto de entrada utilizado para armazenar os valores de juros e multa dos títulos no cancelamento do borderô para 
regravar após o processo no PE_F590CAN   
@Author  Ramon Teodoro e Silva	
@Since   02/08/2019       
@Version P12.7
*/

User Function F590COK()

Local lRet  := .T. 
Local aArea := GetArea() 
Local aAreaE2 := SE2->(GETAREA())
 
Public __nCntrlMul := IIf( SE2->E2_MULTA > 0, SE2->E2_MULTA, Nil) 
Public __nCntrlJur := IIf( SE2->E2_JUROS > 0, SE2->E2_JUROS, Nil)

U_FLJMUNIC()//Volta a loja para zero.

RestArea(aAreaE2)
RestArea(aArea)
Return lRet
