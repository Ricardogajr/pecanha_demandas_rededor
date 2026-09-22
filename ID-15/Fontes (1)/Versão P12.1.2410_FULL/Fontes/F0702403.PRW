#include 'protheus.ch'

/*{Protheus.doc} F0702403
Função de teste para validar a função generica de conversão das unidades de medida 
conforme processo de origem e filiais, que será utilizada em todos os processos que 
necessitem de conversão entre 
as unidades de medida. 

@author Alex Sandro
@since 08/02/2017
@project MAN0000007423041_EF_024
@return NIL
*/

User Function F0702403()
	
    Local aPergs   := {}
	Local cProduto := Space(15)
	Local cFilConv := Space(08)
	Local nQtdConv := 0
	Local cProcesso:= "Consumo"
	Local cDirecao := "P12 P/ Front"
	Local cUMFront := Space(TamSx3('B1_UM')[1])
	Local nProcesso:= 0
	Local nDirecao := 0
	Local aRet     := {}
	Local aConv    := {}
	
	AAdd( aPergs ,{1,"Codigo do Produto "       ,cProduto       ,"@!",'.T.','SB1','.T.',70,.T.})
	AAdd( aPergs ,{1,"Filial Conversão  "       ,cFilConv       ,"@!",'.T.','SM0','.T.',40,.T.})
	AAdd( aPergs ,{1,"Quantidade Base   "       ,nQtdConv       ,"@E 99,999,999.99",'.T.',,'.T.',50,.T.})
	AAdd( aPergs ,{2,"Processo "                ,cProcesso      , {"Consumo", "Compra","Estoque"}, 50,'.T.',.T.})
	AAdd( aPergs ,{2,"Direção "                 ,cDirecao       , {"P12 P/ Front", "Front p/ P12"}, 50,'.T.',.T.})
	AAdd( aPergs ,{1,"U.M. Front p/ Validação " ,cUMFront       ,"@!",'.T.',,'.T.',40,.f.})
	
	If ! ParamBox(aPergs ,"Parametros para Conversão",aRet)
		Return .f.
	EndIf
	
	cProduto := aRet[1]
	cFilConv := aRet[2]
	nQtdConv := aRet[3]
	nProcesso:= AScan({"Consumo", "Compra","Estoque"},Alltrim(aRet[4]))
	nDirecao := AScan({"P12 P/ Front", "Front p/ P12"},Alltrim(aRet[5]))
	cUMFront := aRet[6]
	
	aConv := U_F07024X(cProduto, cFilConv , nQtdConv, nProcesso, nDirecao, cUMFront)
	
	/*
	A função deverá retornar um array com 3 elementos:
	1 elemento – Numero com quantidade convertida a ser utilizado no destino
	2 elemento – Caracter com unidade de Medida do destino
	3 elemento -  Caracter com a mensagem, caso tenha inconsistências nas validações
	*/
	Alert(  "Quantidade Convertida:" + cValtoChar(aConv[1]) + CRLF + ;
		"UM Retorno:" + aConv[2] + CRLF + CRLF + aConv[3] + aConv[4] )
	
Return .t.

/*
{Protheus.doc} F07024X
Função para conversão da unidade medida entre a filial e corporativa

@param cProduto Código do produto
@param cFilConv Filial de conversão
@param nQtde Quantidade utilizada na origem
@param cProcesso 1-Consumo; 2-Compra; 3-Estoque
@param cDirecao 1-P12 P/ Front;2- Front p/ P12
@param cUmOrig Unidade de Medida de origem 
@author  Alex Sandro
@version  1.0
@since   15/02/2017
@project MAN0000007423041_EF_024
@Return aConv  array com quantidade, unidade de medida e Mensagem
@Sample
*/
User Function F07024X(cProduto, cFilConv , nQtde, nProcesso, nDirecao,cUmFront)
	Local aAreaP17  := P17->(GetArea())
	Local aAreaSB1  := SB1->(GetArea())
	Local cMsg      := ''
	Local nQtConv   := 0
	Local cUMRet    := ''
	Local cLog      := ''
	Local cUMCorp   := ''
	Local cTipCon   := ''
	Local nFtCon    := 0
	
	DEFAULT cUmFront := ''
	
	SB1->(DbSetOrder(1))
	If ! SB1->(DbSeek(xFilial('SB1') + cProduto))
		cMsg:= 'Produto ' + cProduto + ' não cadastrado!'
		RestArea(aAreaSB1)
		Return {0,'',cMsg,'','',0}
	EndIf
	cUMCorp := SB1->B1_UM
	RestArea(aAreaSB1)
	P17->(DbSetOrder(1))
	If ! P17->(DbSeek(xFilial('P17') + cProduto + cFilConv))
		cMsg:= 'Tratamento de Filial ' + cFilConv + '  ' + Alltrim(FWFilialName(cEmpAnt,cFilConv)) + ' não cadastrado!'
		RestArea(aAreaP17)
		Return {0,'',cMsg,'','',0}
	EndIf	
	
	// Valida Unidade de Medida Orgiem do Protheus com o Front
	If nDirecao ==2 .and. ! Empty(cUmFront)
		If nProcesso == 1 //Consumo
			cUMAux := P17->P17_UM1
		ElseIf nProcesso == 2 //Compra
			cUMAux := P17->P17_UM2
		Else //Estoque
			cUMAux := P17->P17_UM3
		EndIf
		If ! cUMAux == cUmFront
			cMsg:= 'Unidade de Medida divergente entre o Protheus e Front! - [' + cProduto + ']. UM Protheus: '+cUMAux+' / UM Front:'+cUmFront+'.'
			RestArea(aAreaP17)
			Return {0,'',cMsg,'','',0}
		EndIf
	EndIf
	
	cLog += "Parâmetros de Entrada" + CRLF
	cLog += "Produto : " + cProduto + CRLF
	cLog += "Filial : " + cFilConv + CRLF
	cLog += "Quantidade: " + cValToChar(nQtde) + CRLF
	If ! Empty(cUmFront)
		cLog += "UM Front: " + cUmFront + CRLF
	EndIf
	cLog += "Processo : " + cValToChar(nProcesso) + ' ' + {"Consumo", "Compra","Estoque"}[nProcesso] + CRLF
	cLog += "Direção : " + cValToChar(nDirecao) + ' ' + {"P12 P/ Front", "Front p/ P12"}[nDirecao] + CRLF
	cLog +=CRLF
	cLog += "Formula utilizada" + CRLF

	If nDirecao == 1 // do P12 para o Front
		If nProcesso == 1 // Consumo
			If Empty(P17->P17_CONSUM)
				cMsg:= ' [P17_CONSUM] Fator de conversão de consumo vazio!'
				RestArea(aAreaP17)
				Return {0,'',cMsg,'','',0}
			EndIf
			If P17->P17_FROP12 == "D"
				nQtConv := nQtde * P17->P17_CONSUM
				cTipCon := "M"
				nFtCon  := P17->P17_CONSUM
				cLog += "Quantidade * P17->P17_CONSUM" + CRLF
				cLog += cValToChar(nQtde) + ' * ' + cValToChar(P17->P17_CONSUM) + CRLF
			Else
				nQtConv := nQtde / P17->P17_CONSUM
				cTipCon := "D"
				nFtCon  := P17->P17_CONSUM
				cLog += "Quantidade / P17->P17_CONSUM" + CRLF
				cLog += cValToChar(nQtde) + ' / ' + cValToChar(P17->P17_CONSUM) + CRLF
			EndIf
			cUMRet := P17->P17_UM1
		ElseIf nProcesso == 2 // compras
			If Empty(P17->P17_COMP)
				cMsg:= ' [P17_COMP] Fator de conversão de compras vazio!'
				RestArea(aAreaP17)
				Return {0,'',cMsg,'','',0}
			EndIf

			If P17->P17_P12FRO=="M"
				nQtConv := nQtde * P17->P17_COMP
				cTipCon := "M"
				nFtCon  := P17->P17_COMP
				cLog += "Quantidade * P17->P17_COMP" + CRLF
				cLog += cValToChar(nQtde) + ' * ' + cValToChar(P17->P17_COMP) + CRLF
			Else
				nQtConv := nQtde / P17->P17_COMP
				cTipCon := "D"
				nFtCon  := P17->P17_COMP
				cLog += "Quantidade / P17->P17_COMP" + CRLF
				cLog += cValToChar(nQtde) + ' / ' + cValToChar(P17->P17_COMP) + CRLF
			EndIf
			cUMRet := P17->P17_UM2
		Else // Estoque
			If Empty(P17->P17_CONV2)
				cMsg:= ' [P17_CONV2] Fator de conversão de estoque vazio!'
				RestArea(aAreaP17)
				Return {0,'',cMsg,'','',0}
			EndIf
			
			If P17->P17_TPC2=="M"
				nQtConv := nQtde * P17->P17_CONV2
				cTipCon := "M"
				nFtCon  := P17->P17_CONV2
				cLog += "Quantidade * P17->P17_CONV2" + CRLF
				cLog += cValToChar(nQtde) + ' * ' + cValToChar(P17->P17_CONV2) + CRLF
			Else
				nQtConv := nQtde / P17->P17_CONV2
				cTipCon := "D"
				nFtCon  := P17->P17_CONV2
				cLog += "Quantidade / P17->P17_CONV2" + CRLF
				cLog += cValToChar(nQtde) + ' / ' + cValToChar(P17->P17_CONV2) + CRLF
			EndIf
			cUMRet := P17->P17_UM3
		EndIF
		cLog += "Unidade Origem:" + cUMCorp + CRLF
		cLog += "Unidade Destino:" + cUMRet + CRLF

	Else //Do Front Para o P12
		If nProcesso == 1 // Consumo
			If Empty(P17->P17_CONSUM)
				cMsg:= ' [P17->P17_CONSUM] Fator de conversão de consumo vazio!'
				RestArea(aAreaP17)
				Return {0,'',cMsg,'','',0}
			EndIf
			
			If P17->P17_FROP12=="M"
				nQtConv := nQtde * P17->P17_CONSUM
				cTipCon := "M"
				nFtCon  := P17->P17_CONSUM
				cLog += "Quantidade * P17->P17_CONSUM" + CRLF
				cLog += cValToChar(nQtde) + ' * ' + cValToChar(P17->P17_CONSUM) + CRLF
			Else
				nQtConv := nQtde / P17->P17_CONSUM
				cTipCon := "D"
				nFtCon  := P17->P17_CONSUM
				cLog += "Quantidade / P17->P17_CONSUM" + CRLF
				cLog += cValToChar(nQtde) + ' / ' + cValToChar(P17->P17_CONSUM) + CRLF
			EndIf
			cUMRet := P17->P17_UM1
		ElseIf nProcesso == 2 // compras
			If Empty(P17->P17_COMP)
				cMsg:= ' [P17_COMP] Fator de conversão de compras vazio!'
				RestArea(aAreaP17)
				Return {0,'',cMsg,'','',0}
			EndIf
			
			If P17->P17_P12FRO == "D"
				nQtConv := nQtde * P17->P17_COMP
				cTipCon := "M"
				nFtCon  := P17->P17_COMP
				cLog += "Quantidade * P17->P17_COMP" + CRLF
				cLog += cValToChar(nQtde) + ' * ' + cValToChar(P17->P17_COMP) + CRLF
			Else
				nQtConv := nQtde / P17->P17_COMP
				cTipCon := "D"
				nFtCon  := P17->P17_COMP
				cLog += "Quantidade / P17->P17_COMP" + CRLF
				cLog += cValToChar(nQtde) + ' / ' + cValToChar(P17->P17_COMP) + CRLF
			EndIf
			cUMRet := P17->P17_UM2
		Else // Estoque
			If Empty(P17->P17_CONV2)
				cMsg:= ' [P17_CONV2] Fator de conversão de estoque vazio!'
				RestArea(aAreaP17)
				Return {0,'',cMsg,'','',0}
			EndIf
			
			If P17->P17_TPC2=="M"
				nQtConv := nQtde * P17->P17_CONV2
				cTipCon := "M"
				nFtCon  := P17->P17_CONV2
				cLog += "Quantidade * P17->P17_CONV2" + CRLF
				cLog += cValToChar(nQtde) + ' * ' + cValToChar(P17->P17_CONV2) + CRLF
			Else
				nQtConv := nQtde / P17->P17_CONV2
				cTipCon := "D"
				nFtCon  := P17->P17_CONV2
				cLog += "Quantidade / P17->P17_CONV2" + CRLF
				cLog += cValToChar(nQtde) + ' / ' + cValToChar(P17->P17_CONV2) + CRLF
			EndIf
			cUMRet := P17->P17_UM3
		EndIF
		cLog += "Unidade Origem:" + cUMRet + CRLF
		cLog += "Unidade Destino:" + cUMCorp + CRLF
		cUMRet := cUMCorp
	EndIF
	
	RestArea(aAreaP17)
	
Return {nQtConv,cUMRet,'',cLog,cTipCon,nFtCon}