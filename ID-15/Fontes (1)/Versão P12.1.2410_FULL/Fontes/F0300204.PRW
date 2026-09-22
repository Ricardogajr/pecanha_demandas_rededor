#include "protheus.ch"

/*/{Protheus.doc} F0300204
Validação do codigo da unidade.

@type function
@author alexandre.arume
@since 22/11/2016
@version 1.0
@return ${return}, ${return_description}

/*/
User Function F0300204()
	
	Local lRet		:= .T.							// Variavel de retorno
	Local oModel	:= FWModelActive()				// Modelo ativa
	Local oMld 		:= oModel:GetModel("PA4MASTER")	// Modelo de dados da rotina
	Local cCod		:= oMld:GetValue("PA4_XFIL")	// Codigo da filial
	Local aAreas	:= {GetArea(), SM0->(GetArea())}
	
	If ! Empty(cCod)
		
		dbSelectArea("SM0")
		SM0->(dbSetOrder(1))
		
		lRet := IIf(SM0->(DbSeek(cEmpAnt + cCod)), .T., .F.)
		
	EndIf
	
	AEval(aAreas, {|x,y| RestArea(x)})
	
Return lRet