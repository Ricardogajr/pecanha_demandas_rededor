#include "protheus.ch"

/*/{Protheus.doc} F0300206
Validação do codigo do setor.

@type function
@author alexandre.arume
@since 22/11/2016
@version 1.0
@return ${return}, ${return_description}

/*/
User Function F0300206()
	
	Local lRet		:= .T.							// Variavel de retorno
	Local oModel	:= FWModelActive()				// Modelo ativa
	Local oMld 		:= oModel:GetModel("PA4MASTER")	// Modelo de dados da rotina
	Local cCod		:= oMld:GetValue("PA4_XSETO")	// Codigo do setor
	Local aAreas	:= {GetArea(), SQB->(GetArea())}
	
	If ! Empty(cCod)
		
		dbSelectArea("SQB")
		SQB->(dbSetOrder(1))
		
		lRet := IIf(SQB->(DbSeek(xFilial("SQB") + cCod)), .T., .F.)
		
	EndIf
	
	AEval(aAreas, {|x,y| RestArea(x)})
	
Return lRet
