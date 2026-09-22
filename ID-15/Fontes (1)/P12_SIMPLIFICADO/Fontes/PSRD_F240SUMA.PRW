#Include 'Protheus.ch'

/*
{Protheus.doc}  F240SUMA()
PE para adicionar os valores de multa e juros no total de acrescimos considerado na geração do SISPAG controlado pela variável nSomaAcres
@Author  Ramon Teodoro e Silva	
@Since   27/01/2017       
@Version P12.7
*/

User Function F240SUMA()

Local nRet  := 0
Local aArea := GetArea()

nRet := SE2->E2_MULTA + SE2->E2_JUROS

RestArea(aArea)

Return nRet

