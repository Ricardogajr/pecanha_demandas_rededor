#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F1206801()
Novos Botoes na Liberação de Documentos
@Author  Fabrica de Software
@Since   09/01/2019
@Param   nOper, numerico, operação
@Param   nTp, numerico, tipo do botão
@Project MAN0000007423048_EF_068
*/
User Function F1206801(nOper,nTp)
	
	Local aButtons := {}
	
	If nOper == MODEL_OPERATION_UPDATE
		If nTp == 1
			aButtons := {"Documento Emitido", "CLIPS", { || U_F1206802() }, "Doc.Emitido" }
		ElseIf nTp == 2
			aButtons := {"Banco Específico - Visualizar", "CLIPS", { || U_F0400101(1) }, "BC Conhecimento" }
		ElseIf nTp == 3
			aButtons := {"Grade de Aprovação", "CLIPS", { || U_F1207601() }, "Grade Aprovação" }
		EndIf
	EndIf
	
Return aButtons

/*
{Protheus.doc} F1206802()
Abertura dos documentos posicionados
@Author  Fabrica de Software
@Since   09/01/2019
@Project MAN0000007423048_EF_068
*/
User Function F1206802()

	Local oMdl := FwModelActivate()
	Local cFilSCR := oMdl:GetModel("FieldSCR"):GetValue("CR_FILIAL")
	Local cNumSCR := oMdl:GetModel("FieldSCR"):GetValue("CR_NUM")
	Local cTipSCR := oMdl:GetModel("FieldSCR"):GetValue("CR_TIPO")
	
	If cTipSCR == "PC" //Pedido de Compra
		cChave := cFilSCR+Substr(cNumSCR,1,len(SC7->C7_NUM))
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		MsSeek(cChave)
		If SC7->C7_XSOLPAG == "1" //Solicitação de Pagamento
			FWExecView("Solicitação de Pagamento",'F0100401',MODEL_OPERATION_VIEW,,{||.T.})
		Else
			MatA120(1,,,2) //Pedido de Compra
		EndIf
	ElseIf cTipSCR == "SC" //Solicitação de Compra
		cChave := cFilSCR+Substr(cNumSCR,1,len(SC1->C1_NUM))
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		MsSeek(cChave)
		A110Visual("SC1", cChave, 2)
	ElseIf cTipSCR == "CT" //Contrato
		cNumDoc := Substr(SCR->CR_NUM,1,TAMSX3('CN9_NUMERO')[1] + TAMSX3('CN9_REVISA')[1])
		cChave 	:= xFilial("CN9")+cNumDoc
		DbSelectArea("CN9")
		CN9->(DbSetOrder(1))
		MsSeek(cChave)
		FWExecView("Visualização do Contrato",'CNTA300',MODEL_OPERATION_VIEW,,{||.T.})	
	EndIf

Return