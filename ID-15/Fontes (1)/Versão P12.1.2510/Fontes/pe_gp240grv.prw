#INCLUDE 'Protheus.ch'

/*{Protheus.doc} GP240GRV
Pto.Entrada criado após a inclusão do Atestado Médico, possibilitando a alteração da tabela TNY.

@author		Ademar Fernandes
@since		27/07/2017
@project	MAN0000007423045_EF_003 
*/
User Function GP240GRV()
	Local lRet := .T.
	Local aArea := GetArea()
	Local oModel 	:= FWModelActive()
	Local oGridSRA 	:= oModel:GetModel("GPEA240_SRA")
	Local oGrid     := oModel:GetModel("GPEA240_SR8")	
	
	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return lRet
	EndIf
	
	If FindFunction("U_F1100103")
		lRet := U_F1100103(oGrid,oGridSRA)
	EndIf
	
	If lRet
		oGrid:SETValue("R8_XHROPER",Time())
	EndIf
	RestArea(aArea)
Return(lRet)
