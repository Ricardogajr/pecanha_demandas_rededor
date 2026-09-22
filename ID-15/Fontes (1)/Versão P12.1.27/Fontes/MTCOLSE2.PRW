#Include 'Protheus.ch'

User Function MTCOLSE2()

	Local aColsE2   := PARAMIXB[1]
	Local nOpc      := PARAMIXB[2]
	Local _ss       := 0
	Local aArea     := GetArea("SD1")
	Local posXpriv  := aScan(aHeader,{|x| Trim(x[2])=="D1_XPRIVEN"} )
	Local dXpriv    := CTOD(" / / ")

	If IsInCallStack("U_F010101D")
		Return aColsE2
	EndIf
	If posXpriv > 0
		dXpriv := aCols[n][posXpriv]
		If nOpc == 1
			For _ss = 1 TO Len(aColsE2) STEP +1

				If dXpriv > aColsE2[1][2] /*.AND. SE2->E2_DIRF = "1"*/ .AND. aColsE2[1][4] > 0
					aColsE2[1][2] := dXpriv
				EndIf

			Next _ss
		EndIf
	else
		Return
	EndIf

	RestArea(aArea)

Return aColsE2
