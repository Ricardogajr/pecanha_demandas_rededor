/*{Protheus.doc} F0500313
Gatilho para preencher o valor da Vaga.
@author Nairan Alves Silva
@since 09/05/2017
@Project MAN0000007423039_EF_003
*/
User Function F0500313()	
	Local nRet     := 0
	Local aAreaSQS := SQS->(GetArea())
	Local oModel   := FwModelActive()
	Local oMdl     := oModel:getModel('F05003_PA2')

	If SQS->(DbSeek(xFilial("SQS") + oMdl:GetValue("PA2_CDVAGA")))
		nRet := SQS->QS_VCUSTO
	EndIf

	RestArea(aAreaSQS)

Return nRet