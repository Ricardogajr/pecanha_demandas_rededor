#Include 'Protheus.ch'

User Function F1205601()

	Local oMdl    := FwModelActive()
	Local oMdlCN9 := oMdl:GetModel("CN9MASTER")
	Local cEnvPed := oMdlCN9:GetValue("CN9_XENVPC")
	Local lRet    := .T.
	
	If cEnvPed == "S"
		If Empty(oMdlCN9:GetValue("CN9_XEMAIL"))
			lRet := .F.
			Help( , , 'Help', 'F1205601', 'Campo E-mail Padrão de preenchimento obrigatório', 1, 0 )
		EndIf
	EndIf	

Return lRet

