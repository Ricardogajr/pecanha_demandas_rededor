#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MT110CON 
Antigo MTA110OK do projeto Connecta. 
@type function
@author Ricardo
@since 05/11/2018
@version 1.0
@return lRet .T. valido, .F. não valido.
/*/
User Function MT110CON()

	Local aArea := GetArea()
	Local lRet  := .T.
	Local aCabec:={"C1_XIDBIO", "C1_XENVBIO", "C1_XDTCOTA", "C1_XHRCOTA", "C1_XIDPROC","C1_XITEMED","C1_XOBSMED","C1_XNUMMED","C1_XITMED","C1_XORIMED","C1_XCONTR","C1_XREVISA","C1_XHRMED","C1_XIDPLAN","C1_XITPLAN" } 
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
