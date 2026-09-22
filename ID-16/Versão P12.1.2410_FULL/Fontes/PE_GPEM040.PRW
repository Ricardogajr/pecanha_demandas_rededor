#INCLUDE 'Protheus.ch' 

/*{Protheus.doc} GPEM040
Ponto de entrada no calculo da rescisao
@type function
@author Cris
@since 22/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/

User Function GPEM040()
	Local aParam     := PARAMIXB
	Local cIdPonto   := ''
	Local xRet       := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return xRet
	EndIf
	
	If aParam <> NIL
      
		oModel   := aParam[1]
		cIdPonto := aParam[2]
		cIdForm  := aParam[3]
		xRet     := GetTypeRet( cIdPonto )
				
		If cIdPonto == "MODELVLDACTIVE" .AND. ISINCALLSTACK("U_F0100323")
			lTCFA040 := .T.
		EndIf

		If cIdPonto == "MODELCOMMITNTTS"
			//-Gravar PA6 da Exclusao do Calculo de Rescisao
			U_F0600604(oModel)			
		EndIf
				
		If cIdPonto == "MODELPOS"
			
			//-Atualize os campos com data fim dos planos de saúde com a data da demissão
			cTipResPortal := M->RG_TIPORES
			If INCLUI .OR. ALTERA
				U_F0300609(.T.)
			Else
				U_F0300609(.F.)
			EndIf

		EndIf
 
	EndIf

	If lExecPECli .And. FindFunction("U_FSPE0002")
		xRet := U_FSPE0002()
	EndIf

Return xRet

/*{Protheus.doc} GetTypeRet
Função que inicia a variável de retorno do PE conforme o estágio
@author	Eduardo Fernandes
@param  cStage, caracter        , Local de execução do PE
@return xRet  , lógico/array/nil, Retorno do PE
*/
Static Function GetTypeRet( cStage )

Local xRet		:= Nil
Default cStage	:= ""

If cStage $ "MODELPRE|MODELPOS|FORMPRE|FORMPOS|FORMLINEPRE|FORMLINEPOS|FORMCANCEL|MODELVLDACTIVE|"
	xRet := .T.
ElseIf cStage == "BUTTONBAR"
	xRet := {}
EndIf

Return ( xRet )