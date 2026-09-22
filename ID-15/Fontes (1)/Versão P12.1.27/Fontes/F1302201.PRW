#Include 'Protheus.ch'

/*/{Protheus.doc} F1302201
Modifica código do RH3_CODIGO
@author henrique.toyada
@since 29/12/2017
@param aParam, array, (Descrição do parâmetro)
@param lRet, logico, (Descrição do parâmetro)
@return cNewCode, ${return_description}
@project MAN0000007423048_EF_022
/*/
User Function F1302201(aParam, lRet)

	Local aArea    := GetArea()
	Local cNewCode := ""
	Local cVarRh3  := GetMv("FS_VRNMRH3")
	
	Default aParam := {"","",""}
	Default lRet   := .F.
	
	cNewCode := aParam[2]
	
	If aParam[3] == "H" .OR. lRet
		If !(EMPTY(cVarRh3))
			cNewCode  := GetSX8Num("RH3", "RH3_CODIGO", cVarRh3)
			While RH3->(DbSeek(aParam[1] + cNewCode))
				cNewCode  := GetSX8Num("RH3", "RH3_CODIGO", cVarRh3)
			EndDo
		Else
			cNewCode  := GetSX8Num("RH3", "RH3_CODIGO")
			While RH3->(DbSeek(aParam[1] + cNewCode))
				cNewCode  := GetSX8Num("RH3", "RH3_CODIGO")
			EndDo
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return cNewCode