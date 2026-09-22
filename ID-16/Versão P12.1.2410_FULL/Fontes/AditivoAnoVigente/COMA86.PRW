User Function COMA086()


	Local oModel := NIL
	Local oModelAJ := NIL
	Local cIdPonto	:= PARAMIXB[2]


	If cIdPonto == "FORMLINEPOS"
		omodel := fwmodelactive()
		oModelAJ := oModel:GetModel("SAJDETAILS")
		oModelAJ:SetValue("AJ_ZINTOGY","1")
		//oModelAJ:SetValue("AJ_ZONERGY",.T.)
	EndIf

Return .T.  
