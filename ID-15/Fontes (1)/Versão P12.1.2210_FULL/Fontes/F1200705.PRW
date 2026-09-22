#INCLUDE 'PROTHEUS.CH'

/*{Protheus.doc} F1200705
Prepara tela de seleção de contratos por agrupamento.
@author 	Paulo Krüger
@since 		17/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return 	Nil
*/
User Function F1200705()

Local nI			:=	0
Local cRefer		:=	''
Local lExibeTela	:= .T.

//Quando chamado de Medição manual ou Job não exibe tela
If ISINCALLSTACK('U_F1200600') .OR. ISINCALLSTACK('U_F1200601')
	lExibeTela := .F.
EndIf

If !Empty(aAgrup)
	aSort(aAgrup  ,,,{|x, y| x[02] < y[02]}) // Ordena por Filial + Produto + Local + Centro de custo
	cRefer	:= aAgrup[01][02]
	For nI := 01 To Len(aAgrup)
		Aadd(aSelContr,{	aAgrup[nI][01]	,	;	//[01]Id de integração
							aAgrup[nI][05]	,	;	//[02]Filial da SC
							aAgrup[nI][06]	,	;	//[03]Produto
							aAgrup[nI][07]	,	;	//[04]Local de estoque
							aAgrup[nI][08]	,	;	//[05]Centro de custo
							U_F1200101(aAgrup[nI][05], aAgrup[nI][06], aAgrup[nI][01]), ; //[06]Array com contratos
							aAgrup[nI][09]	,	;	//[07]Tipo de Solicitacao
							aAgrup[nI][10]	,	;	//[08]Numero da solicitacao
							aAgrup[nI][11]	,	;	//[09]Item da Solicitacao
							aAgrup[nI][12]})	    //[10]Data programada	
		If !Empty(aSelContr[01][06])
			If Len(aSelContr[01][06]) > 01	//Quando existe a possibilidade de escolha de contrato
				If lExibeTela				
					U_F1200706()			//Tela de seleção de contratos
				EndIf
			Else	
				U_F1200707(Nil,aSelContr) //Lista ítens para medição
			EndIf		 
		EndIf
		
		aSize(aSelContr,0)
	Next nI	
EndIf

Return
