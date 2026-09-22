//Bibliotecas
#Include "TOTVS.ch" 
#Include 'Protheus.ch'

User Function FXBFILF4()
Local lRet := .T.

nPosCC := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "D1_CC"})
cCC := aCols[n][nPosCC]

If SubString(alltrim(cCC),1,2) == "04"
    ConPad1(, , , "SF4ATF")
Else 
    ConPad1(, , , "SF4")
EndIf 

Return lRet
