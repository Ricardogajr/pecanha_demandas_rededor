
/*/{Protheus.doc} GPALTSAL
PE quando o salario do funcionário for atualizado. 

@type function
@author alexandre.arume
@since 09/11/2016
@version 1.0
@param nOpcx, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}

/*/
User Function GPALTSAL(nOpcx)
	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return .T.
	EndIf
	
	U_F0600302()
	
Return .T.