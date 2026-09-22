#Include 'Protheus.ch' 
/*
{Protheus.doc} MTA410I
Gravação de informações complementares no pedido de venda (ponto de entrada chamado por item do pedido)
@Author     Ramon Teodoro
@Since      03/08/2017       
@Version    P12.7
@Project     
@Return     lRet
*/

User Function MTA410I

Local lRet    := .t.
Local aArea   := GetArea()
Local nItem   := Paramixb
Local lDserv  := SuperGetMv("MV_XDSERV")
Local cCmpUsr := SuperGetMv("MV_CMPUSR")
Local nPosCmp := SC5->(FieldPos(cCmpUsr))
Local cTextNF := ""
Local nT      := 0 
Local nPosCod := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO" })
Local nPosDes := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCRI" })
Local nPosVlr := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR" })

If nItem == Len(aCols)

	If lDserv  

		For nT := 1 to Len(aCols) 
	
			If !aCols[nT][Len(aCols[nT])]
	
				If Posicione( "SB1", 1, xFilial("SB1")+aCols[nT][nPosCod], "B1_XMATSER") == "2" 
				
					cTextNF += Alltrim(aCols[nT][nPosDes]) + "     " + "R$ " + Alltrim(Transform(aCols[nT][nPosVlr],"@E 999,999,999.99")) + chr(13) + chr(10)
				
				EndIf
			
			EndIf
			
		Next nT
	
		RecLock("SC5", .F.)
		FieldPut(nPosCmp, cTextNF)
		SC5->(MsUnlock())
		
	EndIf

EndIf

RestArea(aArea)
Return lRet

