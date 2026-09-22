#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*{Protheus.doc} F0700007
Realiza manutenção (inclui,altera ou deleta) em um Registro com modelo MVC (Antiga ManutReg).
@Project MAN0000007423041_EF_000
*/

User Function F0700007(cFonte, cModelo, aCampos, nOperation, cRetorno )
	Local lOK    := .T.
	Local nCampo := 1
	Local oModel, oModelFields
	Local aError := {}
	
	Local oModelAnt := FwModelActive()

	Default cRetorno := ""
	
	BEGIN SEQUENCE
		
		oModel := FWLoadModel(cFonte)
		oModel:SetOperation(nOperation)
		oModel:Activate()
		
		If nOperation != MODEL_OPERATION_DELETE
			lOk := .F.
			oModelFields := oModel:GetModel(cModelo)
			For nCampo := 1 to Len(aCampos)
				If oModelFields:CanSetValue(aCampos[nCampo][1])
					If ! (lOK := oModelFields:SetValue(aCampos[nCampo][1], aCampos[nCampo][2]))
						exit
					EndIf
				EndIf
			Next
		EndIf
		
		If !( lOK .and. (lOk := oModel:VldData() .and. oModel:CommitData()))
			aError := oModel:GetErrorMessage()
//			cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
			cRetorno := "ERRO|" + aError[4] + " | " + IIF(ValType(aError[6]) <> 'U',aError[6],"") + " | " + IIF(ValType(aError[9]) <> 'U',aError[9],"")
		EndIf
		
		oModel:Destroy()
	RECOVER
		cRetorno += IIF(len(cRetorno) > 0,"|","") + " ERRO|MVC - Falha não identificada"
		lOK:= .F.
	END SEQUENCE

	If ValType(oModelAnt) == "O"
		FwModelActive(oModelAnt)
	EndIf

Return lOK
