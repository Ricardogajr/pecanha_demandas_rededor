#Include "Protheus.ch"
/*
//=============================================================================================\\
// Programa   E-Mail   | Autor  Diego Fraidemberge Mariano                | Data    27/09/24   ||
//=============================================================================================||
//Desc.     | Ponto chamado no Encerramento da Medição, para preencher o campo CND_PEDIDO com  ||
//          | o valor ca C7_NUM com o número do pedido gerado                                  ||                 
||Parametros  | PARAMIXB[1] - Contém informações sobre a situação atual do contrato.           ||
            | PARAMIXB[2] - Contém informações sobre a nova situação do contrato.              ||
||Ret Nil                                                                                      ||
//=============================================================================================//
*/
User Function CN121ENC() 
   
	Local lLocTran := .T.  
	Local lResult  := .T. 

 
	Local aAreaSCR   := {}
	Local aAreaCND   := {}
	Local aArea		 := {}
	Local cNumPed  := ""

    If IsInCallStack("U_F1200709")
        Return
    EndIf


	lLocTran := PARAMIXB[1]
	lResult  := PARAMIXB[2]


	aAreaSCR   := SCR->(GetArea())
	aAreaCND   := CND->(GetArea())
	aArea		 := GetArea()
	cNumPed  := SC7->C7_NUM

	CND->CND_PEDIDO := cNumPed

	Reclock("SC7",.F.)
	SC7->C7_XMULTA := Posicione("CNE",4,CND_FILIAL+CND_NUMMED,"CNE_XMULTA")
	SC7->C7_XJURMUL := Posicione("CNE",4,CND_FILIAL+CND_NUMMED,"CNE_XJUROS")
	If CND->CND_XCTSER == ""
		SC7->C7_XCTSERV := ""
	Else
		SC7->C7_XCTSERV := CND->CND_XCTSER
	EndIf
	SC7->(MsUnLock())
	RestArea(aArea)
	RestArea(aAreaSCR)
	RestArea(aAreaCND)

Return

