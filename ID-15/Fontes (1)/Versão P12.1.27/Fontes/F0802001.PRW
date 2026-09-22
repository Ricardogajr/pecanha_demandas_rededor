/*{Protheus.doc} F0802001()
Atualiza os dados da Vaga
@type function
@author Nairan Alves Silva
@since 10/07/2017
@version 1.0
@param cFilVg - Filial da Vaga
@param cVaga - Código da Vaga
@return lRet - Confirmação da atualização da vaga
*/
User Function F0802001(cFilVg, cVaga)
	Local aAreaSQS	:=	SQS->(GetArea())
	Local lRet		:= .F.

	SQS->(DbSetOrder(1))
	If SQS->(DbSeek(cFilVg + cVaga))
		RecLock("SQS",.F.)
		If  SQS->QS_VAGAFEC > 0 // Ticket nº - 6486292 - Inclusão de validação para não deixar o campo QS_VAGAFEC negativo - Yan Cordeiro
			SQS->QS_VAGAFEC -= 1 
		EndIf
			SQS->QS_DTFECH  := ctod("//")
			SQS->(MsUnLock())
			lRet	:= .T.
	EndIf
	
	RestArea(aAreaSQS)	
Return lRet