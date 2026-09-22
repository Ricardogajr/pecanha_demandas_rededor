#Include 'Protheus.ch'

User Function MTCOLSE2()

	Local aColsE2   := PARAMIXB[1]
	Local aArea := GetArea()

	If IsInCallStack("U_F010101D")
		Return aColsE2
	EndIf

	RestArea(aArea) 

Return aColsE2
  