#Include 'Protheus.ch'

User Function F241NAT()

Local cRet  := ""
Local aArea := GetArea() 
Local cNatPis 	:= GetMv("MV_PISNAT",.F.,"PIS")
Local cNatCof	:= GetMv("MV_COFINS",.F.,"COF")
Local cNatCsl	:= GetMv("MV_CSLL",.F.,"CSL")
Local cChaveSE2 := Alltrim(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
Local nPosJM    := 0


If (SE2->E2_MULTA == 0 .Or. SE2->E2_JUROS == 0) .And. IsInCallStack("FA241Canc") 
	
	If aCntrlJM <> Nil .Or. Len(aCntrlJM) > 0
	
		nPosJM :=  Ascan(aCntrlJM,{|x|Alltrim(x[1])== cChaveSE2})
		If nPosJM > 0
	
			RecLock("SE2",.F. )
			SE2->E2_JUROS := aCntrlJM[nPosJM][2]
			SE2->E2_MULTA := aCntrlJM[nPosJM][3]
			MsUnLock()
			
		EndIf
	
	EndIf
		
EndIf

cRet := cNatPis+"/"+cNatCof+"/"+cNatCsl+"/"

RestArea(aArea)
Return cRet

