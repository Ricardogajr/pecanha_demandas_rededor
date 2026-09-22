#Include 'Protheus.ch'

/*
{Protheus.doc}  F560BLOCK
Ponto de entrada para validar se a solicitação de viagem está aprovada 
@Author  Ramon Teodoro e Silva	
@Since   22/08/2018       
@Version P12.7
*/

User Function CDVLIBVLD()

Local lRet := .T.
Local aArea := GetArea()

DbSelectArea("LHP")
DbSetOrder(1)
If DbSeek(xFilial("LHP")+LHQ->LHQ_CODIGO)

	If !Empty(LHP->LHP_SUPIMD) .And. !Empty(LHP->LHP_DGRAR)

		If (LHP->LHP_FLAG == "A" .And. LHP->LHP_FLAG1 == "A") .Or. (LHP->LHP_FLAG == "B" .And. LHP->LHP_FLAG1 == "B") 
			lRet := .T.		
		Else
			MsgStop("Solicitação de viagem ainda pendente de aprovação, não será possível liberá-la.","Atenção")
			lRet := .F.	
		EndIf
	
	ElseIf !Empty(LHP->LHP_SUPIMD) .And. Empty(LHP->LHP_DGRAR)
	
		If LHP->LHP_FLAG == "A" .Or. LHP->LHP_FLAG == "B"
			lRet := .T.		
		Else
			MsgStop("Solicitação de viagem ainda pendente de aprovação, não será possível liberá-la.","Atenção")
			lRet := .F.	
		EndIf
	
	ElseIf Empty(LHP->LHP_SUPIMD) .And. Empty(LHP->LHP_DGRAR)
	
		MsgStop("Esta solicitação de viagem não possui aprovadores. Favor informá-los antes de fazer a liberação.","Atenção")
		lRet := .F.
			
	EndIf

EndIf

RestArea(aArea)
Return lRet

