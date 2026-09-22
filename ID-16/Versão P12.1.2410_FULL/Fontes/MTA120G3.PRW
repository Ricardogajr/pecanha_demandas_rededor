/*/{Protheus.doc} MTA120G3
Ponto de entrada tem o objetivo de efetuar a atualização das cotações de compra com a Observação da SC. 
Apos gravação da SC8
Rotina de Cotação de Compras MATA150()
@type function
@author Ricardo da Silva
@since 25/10/2017
@version 1.0
@return Nil.
/*/

User Function MTA120G3()

Local aInformacoes 	:= PARAMIXB
Local aArea			:= GetArea()
Local cFil  		:= SC7->C7_FILIAL
Local cNumPed 		:= SC7->C7_NUM 		
Local cItemPed		:= SC7->C7_ITEM		
Local cSequenc		:= SC7->C7_SEQUEN	
Local cNumSC 		:= SC7->C7_NUMSC  
Local cItemSC		:= SC7->C7_ITEMSC
Local cNumCot		:= SC7->C7_NUMCOT
Local cObsInfPac	:= ""

If INCLUI .Or. ALTERA	
	If (!Empty(cNumSC) .And. !Empty(cItemSC)) .Or. !Empty(cNumCot) 
		cObsInfPac := fGetObsInf(cFil, cNumCot, cNumSc, cItemSC)		
	EndIf
	SC7->(DbGoTop())
	If SC7->(DbSeek(cFil + cNumPed))
		While !SC7->(Eof()) .And. AllTrim(SC7->C7_FILIAL) == AllTrim(cFil) .And. AllTrim(SC7->C7_NUM) == AllTrim(cNumPed)						
			RecLock("SC7", .F.)
			SC7->C7_XINFPAC := iIf(Empty(cObsSC), cObsInfPac, cObsSC)
			SC7->(MsUnLock())			    
			SC7->(DbSkip())					
		EndDo				
	EndIf
EndIf

RestArea(aArea)
Return

Static Function fGetObsInf(cFil, cNumCot, cNumSc, cItemSC)

	Local aArea := GetArea()
	Local cObsInfPac := ""
		
	If Empty(cNumCot)
		DbSelectArea("SC1")
		SC1->(DbSetOrder(01))
		If SC1->(DbSeek(cFil+cNumSC+cItemSC)) 			                                                                                                                          
			cObsInfPac := AllTrim(SC1->C1_XINFPAC)							
		EndIf			
	Else	
		DbSelectArea("SC8")
		SC8->(DbSetOrder(01))
		If SC8->(DbSeek(cFil+cNumCot)) 			                                                                                                                          
			cObsInfPac := AllTrim(SC8->C8_XINFPAC)							
		EndIf
	EndIf	
	RestArea(aArea)
Return cObsInfPac