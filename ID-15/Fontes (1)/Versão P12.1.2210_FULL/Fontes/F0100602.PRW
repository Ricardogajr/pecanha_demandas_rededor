#Include 'Protheus.ch'
#INCLUDE "APWIZARD.CH"
/*
{Protheus.doc} F0100602()
Montagem do e-mail a ser enviado. 
@Author     Bruno de Oliveira
@Since      01/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_006
@Param		lRet, lógico, permite continuar ou não
@Return 	lRet, permite continuar ou não
*/
User Function F0100602(lRet)

Local aArea			:= GetArea()
Local aAreaSQS		:= SQS->(GetArea())
Local aAreaSRA		:= SRA->(GetArea())
Local cAssunto		:= "Admissão do Candidato\Funcionário" 
Local cEmlRespVg		:= ""
Local cConteudo		:= ""
Local cCcopia			:= ""

If lRet .AND. IsInCallStack("RSPM001")

	DbSelectArea("SQS")
	SQS->(DbSetOrder(1))
	If !SQS->(DbSeek(xFilial("SQS") + cVaga))
		Aviso("Atencao", "Vaga não encontrada.")
		lRet := .F.
	Else
		
		If Empty(SQS->QS_MATRESP)
			Aviso("Atencao", "Favor preencher a matricula do responsável da vaga.")
			lRet := .F.
		Else
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(SQS->QS_FILRESP + SQS->QS_MATRESP)) 
				cEmlRespVg := SRA->RA_EMAIL
			EndIf
			
			If Empty(cEmlRespVg)
				Aviso("Atencao", "Favor preencher o e-mail do responsável da vaga.")
			Else
				cConteudo := 	"O Candidato " + AllTrim(M->RA_NOME) + "  referente a solicitação " + ;
							SQS->QS_XSOLPTL + " foi encaminhado para Assinatura de Contrato."				
				lRet := U_F0100603(cEmlRespVg,cAssunto,cConteudo,cCcopia,.F.)
				
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSRA)
RestArea(aAreaSQS)
RestArea(aArea)

Return lRet