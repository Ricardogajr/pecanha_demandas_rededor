/*{Protheus.doc} F0802002()
Desocupa o participante do posto
@type function
@author Nairan Alves Silva
@since 10/07/2017
@version 1.0
@param cFilPA2 - Filial da FAP
@param cCandPA2 - Código do Currículo
@return lRet - Confirmação da atualização da vaga
*/

User Function F0802002(cFilPA2, cCandPA2)
	Local aAreaSQG	:= SQG->(GetArea())
	Local lRet	:= .T.

	SQG->(DbSetOrder(1))
	If SQG->(DbSeek(xFilial("SQG") + cCandPA2))			
		OrgXRescisao(SQG->QG_FILMAT, SQG->QG_MAT, dDataBase)
	Else
		lRet := .F.
	EndIf
	
	RestArea(aAreaSQG)
Return lRet