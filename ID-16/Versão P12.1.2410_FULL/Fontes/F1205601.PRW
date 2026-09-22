#Include 'Protheus.ch'

User Function F1205601()

	Local oMdl    := FwModelActive()
	Local oMdlCN9 := oMdl:GetModel("CN9MASTER")
	Local oMdlCNC := oMdl:GetModel("CNCDETAIL")
	Local cEnvPed := oMdlCN9:GetValue("CN9_XENVPC")
	Local cCondPG := ""
	Local cFornCNC := ""
	Local cLojaCNC := ""
	Local lRet    := .T. 
	Local aRet    := {}
	
	If cEnvPed == "S"
		If Empty(oMdlCN9:GetValue("CN9_XEMAIL"))
			lRet := .F.
			Help( , , 'Help', 'F1205601', 'Campo E-mail Padrão de preenchimento obrigatório', 1, 0 )
		EndIf
	EndIf	

//Bloco de tratativa para a nova norma de condição de pagamento da rede dor.
//Lucas Miranda de Aguiar - Miranda Solution 
//17/06/2025
	If lRet 
		cCondPG  := oMdlCN9:GetValue("CN9_CONDPG")
		cFornCNC := oMdlCNC:GetValue("CNC_CODIGO")
		cLojaCNC := oMdlCNC:GetValue("CNC_LOJA")
		aRet := U_MSCHKCOND(cCondPG,cFornCNC,cLojaCNC,,,.T.)  

		If !aRet[1]
			Help( , , 'Help', 'F1205601', aRet[2], 1, 0, , , , , , {"Revise a condição de pagamento escolhida."})
			lRet := aRet[1]
		EndIf
	EndIf 

Return lRet

