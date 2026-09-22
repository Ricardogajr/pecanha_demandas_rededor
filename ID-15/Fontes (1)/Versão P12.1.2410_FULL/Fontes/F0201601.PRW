#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*
{Protheus.doc} F0201601()
Criação de rotina para Visualização do cadastro de setores
@Author     Mick William da Silva
@Since      13/05/2016
@Version    12.1.7
@Project    MAN00000463301_EF_016
*/

User Function F0201601()

	Local lRet 		 := .T.
	Local oObj 		 := ''
	Local cIdPonto 	 := ''
	Local nOperation := 0
	
	If ((!FWIsInCallStack("U_F0700601")) .AND. (!FWIsInCallStack("U_F0700602")))
		If Type("PARAMIXB") == "A"
			oObj     := PARAMIXB[1]
			cIdPonto := PARAMIXB[2]
			If cIdPonto == 'MODELVLDACTIVE'
				nOperation := oObj:GetOperation()
				If (nOperation == MODEL_OPERATION_INSERT) .Or. (nOperation == MODEL_OPERATION_DELETE)
					Help( ,, 'F0201601 - Locais de Estoque',, 'A manutenção de locais de estoque deverá ser realizada somente nos sistemas front', 1, 0 )
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

