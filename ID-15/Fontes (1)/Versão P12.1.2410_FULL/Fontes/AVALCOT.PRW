#include 'protheus.ch'
#include 'parmtype.ch'

*------------------------*
User Function AVALCOT()
*------------------------*
	Local nEvento := PARAMIXB[1]
	Local aArea := GetArea()
	
	If nEvento == 4    
		DbSelectArea('SC7')    
		RecLock('SC7', .F.)    
		SC7->C7_XINFPAC := SC8->C8_XINFPAC
		SC7->C7_XCODSET := SC1->C1_XCODSET    
		SC7->(MsUnlock())
	EndIf
	
	RestArea(aArea)
Return