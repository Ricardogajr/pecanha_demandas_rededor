#include "protheus.ch"

User Function EXTRAILT(cTexto)
Private cTextoAux := ""
Private nTam      := 0
Private nPos      := 0
Private cRetorno  := ""
Private cCaracter := ""
        
cTextoAux := AllTrim(cTexto)
nTam      := Len(cTextoAux)

for nPos = 1 To nTam
    cCaracter := SubStr(cTextoAux, nPos, 1)
    If IsAlpha(cCaracter) .Or. cCaracter = " "
       cRetorno += cCaracter
    EndIf
Next

Return (cRetorno)


