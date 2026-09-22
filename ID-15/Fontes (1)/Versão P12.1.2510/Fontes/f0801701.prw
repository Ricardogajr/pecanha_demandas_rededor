/*{Protheus.doc} F0801701 
Grava campos adicionais 
@author  Henrique Madureira
@since   07/06/2017 
@version 12.7
@project MAN0000007423042_EF_017
*/
User Function F0801701()
	Local aParam   := PARAMIXB
	Local aArea    := GetArea()
	Local aAreaRh3 := RH3->(GetArea())
	
	If RH3->(DbSeek(aParam[1] + aParam[2]))
		If RH3->RH3_TIPO == "9"
			RecLock("RH3", .F.)
			RH3->RH3_XVAGA := INSCRSELECTIONPROC:CODE
			RH3->(MsUnLock())
		EndIf
	EndIf
	
	RestArea(aAreaRh3)
	RestArea(aArea)
Return