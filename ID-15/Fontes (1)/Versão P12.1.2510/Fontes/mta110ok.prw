#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MTA110OK
Ponto de entrada que Limpar os campos da integração do bionexo 
@type function
@author Ricardo
@since 24/10/2017
@version 1.0
@return lRet .T. valido, .F. não valido.
/*/
User Function MTA110OK()

	Local aArea := GetArea()
	Local lRet  := .T.
	Local aCabec:={"C1_XIDBIO", "C1_XENVBIO", "C1_XDTCOTA", "C1_XHRCOTA", "C1_XIDPROC" } 
	Local nX	:= 00
	
	If LCOPIA
		For nX := 01 To Len(aCabec)
			nPos := aScan(aHeader, {|x| AllTrim(x[2]) == aCabec[nX]})		
			If nPos > 0
				If aCabec[nX] == "C1_XDTCOTA"
					For nY := 01 To Len(aCols)		
						aCols[nY][nPos] := CToD("  /  /    ")
					Next nY
				Else	
					For nY := 01 To Len(aCols)		
						aCols[nY][nPos] := ""
					Next nY
				EndIf
			EndIf			
		Next nX
	EndIf
	
	RestArea(aArea)
Return lRet 