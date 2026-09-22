#Include "Totvs.ch"


User Function MSEMAILPC()


	Local cRet := ""

	Local cParam1 := GetNewPaR("MS_TXTPCM1","Caro fornecedor, <br> Segue em anexo pedido de compra enviado pela área de suprimentos da empresa Rede Dor para seu conhecimento e atendimento.<br><br>")
	Local cParam2 := GetNewPaR("MS_TXTPCM2","Em caso de dúvidas entre em contato com nossa equipe de Suprimentos. <br> <br> <b>Importante:</b> <br> O vencimento deverá acatar a condição de pagamento acordada, o pagamento ocorrerá nos dias 10, 20 ou 30, via depósito bancário. <br>")
	Local cParam3 := GetNewPaR("MS_TXTPCM3","O pedido de compra deve constar no XML da NF-e; Campo xPed: número do pedido; Campo xItem: item correspondente. <br> Essas informações são importantes na Nota Fiscal para garantir o recebimento e pagamento no prazo.")

	cRet := cParam1+cParam2+cParam3


Return cRet 

/*/
	Função para validar a diferença de dias entre emissão e entrega do pedido.
/*/
User Function MsVldEmerg(dDataI,dDataE,cCtServ) //Data emissão e data entrega

	Local lRet := .F.
	Local nDiaEntrega  := DateDiffDay(dDataI,dDataE) //Diferença de dias entre emissão e entrega
	local nDiasEmerg := GetNewPar("MS_DIASEME",5)// Quantidade de dias para considerar emergencia

	If nDiasEmerg == 0
		Return .F.
	EndIf

	If (IsInCallStack("MATA094") .OR. IsInCallStack("U_XMATA094") .Or. cCtServ == "1")
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))

		If cCtServ == "1"
			Return .F.
		ElseIf SCR->(DbSeek(SC7->C7_FILIAL+"MD"+PADR(SC7->C7_MEDICAO,TAMSX3("CR_NUM")[1])))
			Return .F.
		EndIf
	EndIf
	If nDiasEmerg >= nDiaEntrega
		lRet := .T.
	EndIf

Return lRet
