#include "protheus.ch"

/*/{Protheus.doc} F0300205
Validação do codigo da matricula.

@type function
@author alexandre.arume
@since 22/11/2016
@version 1.0
@return ${return}, ${return_description}

/*/
User Function F0300205()
	
	Local lRet		:= .T.							// Variavel de retorno
	Local oModel	:= FWModelActive()				// Modelo ativa
	Local oMld 	:= oModel:GetModel("PA4MASTER")	// Modelo de dados da rotina
	Local cFilSra := oMld:GetValue("PA4_XFIL")
	Local cCod		:= oMld:GetValue("PA4_XMAT")	// Codigo da matricula
	Local aAreas	:= {GetArea(), SRA->(GetArea())}
	
	If ! Empty(cCod)
		
		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		
		lRet := IIf(SRA->(DbSeek(cFilSra + cCod)), .T., .F.)
		
		If !(lRET)
			Help( ,, 'HELP',, "Matricula não pertence a filial logada, entre na filial desejada para continuar!", 1, 0)
		EndIf
		
	EndIf
	
	AEval(aAreas, {|x,y| RestArea(x)})
	
Return lRet