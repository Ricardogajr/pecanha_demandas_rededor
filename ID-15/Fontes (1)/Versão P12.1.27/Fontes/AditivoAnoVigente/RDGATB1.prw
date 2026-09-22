#include "protheus.ch"
#include "parmtype.ch"

User Function ITEM()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.
	Local nLinha := 0
	Local nQtdLinhas := 0
	Local cMsg := ""

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2] 
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "FORMPOS"
			If !Empty(oObj:GetValue('B1_XSIMPRO'))
				If oObj:GetValue('B1_XSIMPCV') == 0
					Help(" ", 1, "Problema", , "O campo Conv Simpro deve ser preenchido quando o código Simpro é informado.", 1, 0, , , , , , {"Informe o valor de conversão no campo Conv Simpro"})
					xRet := .F.
				EndIf
			EndIf

			If (xRet .And. !Empty(oObj:GetValue('B1_XBRASIN')))
				If oObj:GetValue('B1_XBRASCV') == 0
					Help(" ", 1, "Problema", , "O campo Conv Brasind deve ser preenchido quando o código Brasindice é informado.", 1, 0, , , , , , {"Informe o valor de conversão no campo Conv Brasind"})
					xRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return xRet

User Function TSMT010()
	Alert("Buttonbar")
Return NIL

