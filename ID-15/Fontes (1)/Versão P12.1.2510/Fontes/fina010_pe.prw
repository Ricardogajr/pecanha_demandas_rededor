#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
/*/{Protheus.doc} FINA010
Ponto de Entrada em MVC no Cadastro de Naturezas (FINA010)
@type function
@version  
@author Joalisson Laurentino
@since 26/09/2024
@return variant, return_description
/*/
User Function FINA010()


	Local _lRet       := .T.
	Local oModel        := ParamIXB[1]
	Local _cIdPonto   := ParamIXB[2]
	Local _cIdModel   := ParamIXB[3]
	Local _aArea   := GetArea()
	Local IS_INSERT   := oModel:GetOperation() == 3
	Local IS_UPDATE   := oModel:GetOperation() == 4


	If _cIdPonto == 'MODELPRE' /* Chamada antes da alteração de qualquer campo do modelo. */

	ElseIf _cIdPonto == 'MODELPOS' /* Chamada na validação total do modelo. */

	ElseIf _cIdPonto == 'FORMPRE' /* Chamada na antes da alteração de qualquer campo do formulário. */

	ElseIf _cIdPonto == 'FORMPOS' /* Chamada na validação total do formulário. */

	ElseIf _cIdPonto == 'FORMLINEPRE' /* Chamada na pre validação da linha do formulário. */

	ElseIf _cIdPonto == 'FORMLINEPOS' /* Chamada na validação da linha do formulário. */

	ElseIf _cIdPonto == 'MODELVLDACTIVE' /* Chamada na validação da ativação do Modelo. */

	ElseIf _cIdPonto == 'MODELCOMMITTTS' /* Chamada apos a gravação total do modelo e dentro da transação. */

	ElseIf _cIdPonto == 'MODELCOMMITNTTS' /* Chamada apos a gravação total do modelo e fora da transação. */

		if IS_INSERT .OR. IS_UPDATE
			SED->(RecLock("SED",.F.))
			SED->ED_ZONERGY := .T.
			SED->ED_ZINTOGY := '1'
			SED->(MsUnlock())
		Endif

	ElseIf _cIdPonto == 'FORMCOMMITTTSPRE' /* Chamada antes da gravação da tabela do formulário. */

	ElseIf _cIdPonto == 'FORMCOMMITTTSPOS' /* Chamada apos a gravação da tabela do formulário. */

	ElseIf _cIdPonto == 'MODELCANCEL' /* Cancela */

	ElseIf _cIdPonto == 'BUTTONBAR' /* Usado para Criação de Botoes Estrutura: { {'Nome', 'Imagem Botap', { || bBlock } } } */

	EndIf

	RestArea(_aArea)

Return _lRet
