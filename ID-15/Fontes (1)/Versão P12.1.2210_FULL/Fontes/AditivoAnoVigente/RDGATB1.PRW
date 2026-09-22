#include "protheus.ch"
#include "parmtype.ch"

User Function ITEM()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ""
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
	Local lIsGrid 	:= .F.
	Local nLinha 	:= 0
	Local nQtdLinhas:= 0
	Local cMsg 		:= ""
	Local nOper 	:= 0
	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2] 
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)
		nOper 	:= oObj:GetOperation()

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
		ElseIf cIdPonto == "MODELCOMMITTTS" 
            //Os pontos de entrada MT010INC, MT010ALT e MTA010E estão sendo tratados aqui
			//Chamada após a gravação total do modelo e dentro da transação.		
			If nOper== 5 //// Exclusao MTA010E
				 U_F0702401("E") // Rotina para inclusão dos registros para tratamentos por filiais
			EndIf

			If SB1->(dbSeek(xFilial("SB1")+SB1->B1_COD))
				SB1->(RecLock("SB1",.F.))
					SB1->B1_ZONERGY := .T.
					SB1->B1_ZINTOGY := '1'
				SB1->(MsUnlock())
			Endif
		EndIf
	EndIf

Return xRet

User Function TSMT010()
	Alert("Buttonbar")
Return NIL

