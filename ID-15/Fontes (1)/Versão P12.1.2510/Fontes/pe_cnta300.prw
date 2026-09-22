#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" //9897642 - Thais Paiva

/*
{Protheus.doc} CNTA300()
Ponto de Entrada MVC CNTA300
@author Sandro
@since 18/08/2017
@project MAN0000007423046_EF_008
*/
User Function CNTA300()

	Local xRetorno := .T.
	Local oObj
	Local cIdPonto

	If ParamIxb <> Nil .And. Len(ParamIxb) >= 2
		oObj     := ParamIxb[1]
		cIdPonto := ParamIxb[2]

		If cIdPonto == 'MODELCOMMITNTTS' .Or. cIdPonto == 'FORMCOMMITTTSPRE' .Or. cIdPonto == 'FORMCOMMITTTSPOS'
			xRetorno := Nil
		ElseIf cIdPonto == 'MODELVLDACTIVE'
			// Ignora PE quando vem da tabela de preço
			If !IsInCallStack("U_F1205401")
				xRetorno := U_F1205402()
			EndIf
		ElseIf cIdPonto == 'BUTTONBAR'
			xRetorno := {}
			If !Inclui .AND. !IsInCallStack("U_F1205401")
				Aadd( xRetorno , U_F0400110() )  // INCLUSÃO DO BOTÃO VISUALIZAR BCO. DE CONHECIMENTO
			EndIf
			Aadd( xRetorno , U_F1205404(oObj:nOperation) )
			If (IsInCallStack("U_F1205401"))
				Aadd( xRetorno , U_F1205409(oObj:nOperation) ) //Adicionar botão de Sobrepor Tabela
			Endif
		ElseIf cIdPonto == 'FORMPOS'
			xRetorno := U_F1205601()
		ELseIf cIdPonto == 'MODELPOS'
			xRetorno := U_F1205408()
			If (xRetorno .And. IsInCallStack("CN300RADIT"))
				U_XVLDRV300(oobj)
			EndIf
			//Início - 9897642 - Thais Paiva
		ELseIf cIdPonto == 'MODELPRE'
			oObj:GetModel("CN9MASTER"):GetStruct():SetProperty("CN9_GRPAPR",MODEL_FIELD_WHEN,{||.T.})
			oObj:GetModel("CN9MASTER"):GetStruct():SetProperty("CN9_APROV",MODEL_FIELD_WHEN,{||.T.})
			//Fim - 9897642 - Thais Paiva
		EndIf

        If cIdPonto == 'MODELCOMMITNTTS' .And. oObj:nOperation == 3 // Após a gravação total do modelo e fora da transação.
            U_XXFORNAIB(AIB->(RECNO()))
	EndIf

EndIf

Return xRetorno
