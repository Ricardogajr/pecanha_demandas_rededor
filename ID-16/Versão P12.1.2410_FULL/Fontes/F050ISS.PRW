#INCLUDE "PROTHEUS.CH"


User Function F050ISS()

	Local aArea := GetArea()
	Local AareaE2 := SE2->(GetArea())
	
	RestArea(AareaE2)
	RestArea(aArea)
Return
