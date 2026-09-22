#Include 'Protheus.ch'

/*
{Protheus.doc}  FA080REC()
Ponto de entrada recompor o valor de multa e juros no título após o cancelamento da baixa
@Author  Ramon Teodoro e Silva	
@Since   27/05/2019       
@Version P12.7
*/

User Function FA080REC()

Local lRet   := .T.
Local aArea  := GetArea() 
Local nVlJur := Paramixb[1]
Local nVlMul := Paramixb[2]

SE2->E2_JUROS	:= nVlJur
SE2->E2_MULTA	:= nVlMul

RestArea(aArea)
Return lRet

