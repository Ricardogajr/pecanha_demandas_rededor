/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMREGUA_AP6บAutor  ณArmando / Willy     บ Data ณ  09/13/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Mostra a regua, com coordenadas em Pixel.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MRegua(_nLinha, _lQuadro)

Local _nL

ChkTemplate("CDV")

oPrint:Line( _nLinha, 50, _nLinha, 2300 )
oPrint:Line( 0050, 0050, 3050, 0050 )

oFontReg := TFont():New("Tahoma", 10, 10, .F., .F., , , , .F., .F.)

If .not. _lQuadro
	For _nL := 100 to 2300 step 100
		oPrint:Line( _nLinha, _nL, _nLinha + 20, _nL )
		oPrint:Say(_nLinha - 40, _nL - 13, Str(_nL/100,2), oFontReg)
	Next 
	
	For _nL := 100 to 3000 step 100
		oPrint:Line( _nL, 0050, _nL, 0070 )
		oPrint:Say(_nL - 15, 15, Str(_nL/100,2), oFontReg)
	Next
Else
	For _nL := 100 to 2300 step 100
		oPrint:Line( _nLinha, _nL, 3050, _nL )
		oPrint:Say(_nLinha - 40, _nL - 13, Str(_nL/100,2), oFontReg)
	Next
	
	For _nL := 100 to 3000 step 100
		If _nL < _nLinha
			oPrint:Line( _nL, 0050, _nL, 0070 )
		Else
			oPrint:Line( _nL, 0050, _nL, 2350 )
		EndIf
		oPrint:Say(_nL - 15, 15, Str(_nL/100,2), oFontReg)
	Next
EndIf

Return
