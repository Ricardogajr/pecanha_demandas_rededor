#INCLUDE 'PROTHEUS.CH'
#Include "TOTVS.ch" //Thais Paiva - 09/12/2020

/*/{Protheus.doc} F1600701
Processa medições.
@author 	Nairan Alves Silva
@since 		07/03/2018
@version 	P12.7
@Project    MAN0000007423050
@Return		lRet
/*/

User Function F1600701(cFilCNE,cPedido,cValor)

    Local aAreaSC7 := SC7->(GetArea())
    Local aAreaCNE := CNE->(GetArea())
    Local nDescFin := 0
    Local nDescItem:= 0
	Local nTDesFin := 0
	Local nTPedido := 0
	Local xRet := 0
	
	Default cValor := "" //Thais Paiva - 10355882
	
	cFilCNE := xFilial("CNE")
	
	//Calcula o Desconto Por item e o valor total do pedido 
    SC7->(DbSetOrder(1))
    SC7->(DbSeek(XFilial("SC7")+cPedido))
    If !Empty(SC7->C7_MEDICAO)
	    Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cPedido
	        nDescFin  := POSICIONE("CNE",1,cFilCNE + SC7->(C7_CONTRA + C7_CONTREV + C7_PLANILH + C7_MEDICAO + C7_ITEMED), "CNE_XDESFI")
	        If nDescFin > 0
	        	nTDesFin += (nDescFin / 100) * SC7->C7_TOTAL 
	        EndIf
	        nTPedido += SC7->C7_TOTAL
	        SC7->(DbSkip())
	    End Do
	    If nTDesFin > 0
		    nDescItem := Round((nTDesFin / nTPedido)*100,2)
		    
			SC7->(DbSeek(XFilial("SC7")+cPedido))
		    Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cPedido
		        SC7->(RecLock("SC7",.F.))
		        SC7->C7_XDESFIN  := nDescItem
		        SC7->(MsUnLock())
		        SC7->(DbSkip())
		    EndDo
		EndIf
	Else
 	    nDescItem := cValor
	EndIf
	
    RestArea(aAreaSC7)
    RestArea(aAreaCNE)

Return(nDescItem)


/*/
User Function F1600702(cFilCNE, cPedido) // Problema está na chamada desta funcao

    Local aAreaSC7 := SC7->(GetArea())
    Local aAreaCNE := CNE->(GetArea())
    Local nDescFin := 0
    Local nDescItem:= 0
	Local nTDesFin := 0
	Local nTPedido := 0
	Local xRet := 0
	Local I:=0
	cFilCNE := xFilial("CNE")

	//Calcula o Desconto Por item e o valor total do pedido 
    SC7->(DbSetOrder(1))
    SC7->(DbSeek(XFilial("SC7")+cPedido))
//  If !Empty(SC7->C7_MEDICAO)

 //  	FOR I:=1 TO LEN(aListMedic)
		//nDescFin := RetDesFin(aListMedic[I][19],aListMedic[I][01],aListMedic[I][02], aListMedic[I][06], aListMedic[I][05],aListMedic[I][07], aListMedic[I][09])	
//	NEXT	

	    Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cPedido
	       // Aqui deve ser a filia do CNE , verificar 
//	        nDescFin  := POSICIONE("CNE",1,cFilCNE + SC7->(C7_CONTRA + C7_CONTREV + C7_PLANILH + C7_MEDICAO + C7_ITEMED), "CNE_XDESFI")
//	        nDescFin  := CNE->CNE_XDESFI
			I:=VAL(SC7->C7_ITEM)
			nDescFin := RetDesFin(aListMedic[I][19],aListMedic[I][01],aListMedic[I][02], aListMedic[I][06], aListMedic[I][05],aListMedic[I][07], aListMedic[I][09])	

	        If nDescFin > 0
	        	nTDesFin += (nDescFin / 100) * SC7->C7_TOTAL 
	        EndIf
	        nTPedido += SC7->C7_TOTAL
	        SC7->(DbSkip())
	    End Do

	    If nTDesFin > 0
		    nDescItem := Round((nTDesFin / nTPedido)*100,2)
		    
			SC7->(DbSeek(XFilial("SC7")+cPedido))
		    Do While !SC7->(Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+cPedido
		        SC7->(RecLock("SC7",.F.))
		        SC7->C7_XDESFIN  := nDescItem
		        SC7->(MsUnLock())
		        SC7->(DbSkip())
		    EndDo
		EndIf

//	EndIf
	
    RestArea(aAreaSC7)
    RestArea(aAreaCNE)

Return(nDescItem)

Static Function RetDesFin(cFilCtr, cNumCtr, cRevCtr, cForne, cNumCNA, cLoja, cProduto)

Local aAreaCNA	:= CNA->(GetArea())
Local aAreaAIB	:= AIB->(GetArea())
Local nRet	:= 0

CNA->(DbSetOrder(1))
AIB->(DbSetOrder(2))
    //		    CNA_FILIAL + CNA_CONTRA + CNA_REVISA + CNA_NUMERO                                                                                                                     
If CNA->(DbSeek(cFilCtr + cNumCtr + cRevCtr + cNumCNA))
	If AIB->(DbSeek(CNA->CNA_FILIAL + cForne + cLoja + CNA->CNA_XTABPC + cProduto ))
		nRet := AIB->AIB_XDESFI
	EndIf
EndIf

RestArea(aAreaCNA)
RestArea(aAreaAIB)

Return nRet


/*/
