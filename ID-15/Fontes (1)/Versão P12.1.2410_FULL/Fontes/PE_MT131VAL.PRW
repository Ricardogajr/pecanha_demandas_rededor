#INCLUDE 'Protheus.ch'

/*{Protheus.doc} MT131VAL
Pto.Entrada criado após limpar as marcas realizadas no C1_OK de todos os registros marcados pelo usuario

@author	Ademar Fernandes
@since	15/08/2017
@project	MAN0000007423046_EF_009 
*/
User Function MT131VAL()
	Local lRet := .T.
	Local aArea := GetArea()
	Local cMarca   := PARAMIXB[1]
	Local cQuerySC1:= PARAMIXB[2]
	
	If FindFunction("U_F1200901")
		lRet := U_F1200901(cMarca,cQuerySC1)
	EndIf
	
	RestArea(aArea)
Return(lRet)
