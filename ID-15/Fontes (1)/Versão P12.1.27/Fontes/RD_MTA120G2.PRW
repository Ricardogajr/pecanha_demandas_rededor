#Include 'Protheus.ch'

/*
{Protheus.doc}  MTA120G2()
Ponto de entrada para gravações complementares no pedido de compra
@Author  Ramon Teodoro e Silva	
@Since   17/04/2017       
@Version P12.7
*/

User Function MTA120G2() 
     
Local aArea   := GetArea()
Local lRet    := .T. 

If IsInCallStack("U_F0702601") //integração pedido de compra
	nXDesFin := nIntValDes
EndIf 
 
If (IsInCallStack("MATA121") .Or. IsInCallStack("U_F0702601") .Or. !IsBlind()) .And. !IsInCallStack("U_F0100401")
	If Type("nXDesFin") == "U"
		nXDesFin := 00
	EndIf	
	SC7->C7_XDESFIN := nXDesFin 
EndIf

RestArea(aArea)
     
Return lRet