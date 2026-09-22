#Include 'Protheus.ch'

/*
{Protheus.doc}  F050INS()
Ponto de entrada para gravações complementares no título de imposto INSS
@Author  Ramon Teodoro e Silva	
@Since   25/08/2017       
@Version P12.7
*/

User Function F050INS

Local lRet    := .t.
Local aArea   := GetArea()
Local nPosIns := 0 

If IsInCallStack("MATA103")

	nPosIns := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_XRETINS"})
	SE2->E2_RETINS  := aCols[1][nPosIns] 

EndIf

RestArea(aArea)
Return lRet

