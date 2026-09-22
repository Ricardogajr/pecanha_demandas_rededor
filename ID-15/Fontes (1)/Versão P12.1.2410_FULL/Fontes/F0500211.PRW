#Include 'Protheus.ch'

/*{Protheus.doc} F0500211
Mudança do status da vaga na FAP
@type User	Function
@author		Bruno de Oliveira
@since		20/06/2017
@version	P12.1.7
@Project	MAN0000007423039_EF_002
@Param		cQSFilial, caracter, Filial da vaga
@Param		cQSVaga  , caracter, Código da vaga
@Param		cStatus  , caracter, Status da vaga
@return		Nil
*/
User Function F0500211(cQSFilial,cQSVaga,cStatus)

	Local aArea := GetArea()
	Local aAreaPA2 := PA2->(GetArea())

	DbSelectArea("PA2")
	PA2->(DbSetOrder(8))
	If PA2->(DbSeek(cQSFilial+cQSVaga))
		While !(PA2->(EOF())) .AND. AllTrim(PA2->(PA2_FILVG+PA2_CDVAGA)) == cQSFilial+cQSVaga
			If ALLTRIM(PA2->(PA2_SIT)) != "RE"
				Reclock("PA2",.F.)
				PA2->PA2_STSVAG := cStatus
				PA2->(MsUnLock())
			EndIf
			PA2->(DbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaPA2)
	RestArea(aArea)

Return