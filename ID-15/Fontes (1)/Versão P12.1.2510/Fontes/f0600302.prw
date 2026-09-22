#include "protheus.ch"

/*/{Protheus.doc} F0600302

@type function
@author alexandre.arume
@since 11/11/2016
@version 1.0
@return ${return}, ${return_description}

/*/
User Function F0600302()

	Local cOper 	:= "UPSERT"
	Local cFuncF003	:= "GPEA010|TRMA100|PONA160|GPER200"
	
	If (IsInCallStack("fGravaSr3") .AND. AllTrim(FunName()) $ cFuncF003) .Or.  AllTrim(FunName()) $ "GPEM690|CSAA080"
	
		U_F0600901("F0600301",; // cFunc 
					SR3->(RECNO()),; // nRecno 
					"SR3",; // cAliasTrb 
					SR3->R3_FILIAL + SR3->R3_MAT + DTOS(SR3->R3_DATA) + SR3->R3_TIPO,; // cChave 
					"",; // cObs
					CTOD(""),; // Data de envio
					cOper) // Operacao
					
	EndIf
	
Return .T.