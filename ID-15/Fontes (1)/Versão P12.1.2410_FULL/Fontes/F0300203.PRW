#include "protheus.ch"

/*/{Protheus.doc} F0300203
Validação do codigo de pesquisa.

@type function
@author alexandre.arume
@since 22/11/2016
@version 1.0
@return ${return}, ${return_description}

/*/
User Function F0300203()
	
	Local lRet		:= .T.							// Variavel de retorno
	Local oModel	:= FWModelActive()				// Modelo ativa
	Local oMld 		:= oModel:GetModel("PA4MASTER")	// Modelo de dados da rotina
	Local cCod		:= oMld:GetValue("PA4_XCOD")	// Codigo da pesquisa
	Local aAreas	:= {GetArea(), RD5->(GetArea())}
	
	If ! Empty(cCod)
		
		dbSelectArea("RD5")
		RD5->(dbSetOrder(1))
		
		lRet := IIf(RD5->(DbSeek(xFilial("RD5") + cCod)) .AND. RD5->RD5_TIPO == "2", .T., .F.)
		
	EndIf
	
	AEval(aAreas, {|x,y| RestArea(x)})
	
Return lRet
