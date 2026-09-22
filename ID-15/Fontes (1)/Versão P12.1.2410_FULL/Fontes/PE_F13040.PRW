#Include 'PROTHEUS.CH'
#Include 'PARMTYPE.CH'
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PE_F13040
Rotina utilizada nos pontos de entradas da FSW para ajustar os campos C7_QUJE, C7_ENCER, B2_SALPEDI e B2_SALPED2.
@author Reinaldo Dias
@since 07/06/2018
@version undefined
/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} F13040E
Ponto de entrada utilizado na rotina da FSW na inclusão da nota fiscal de entrada.
@author Reinaldo Dias
@since 07/06/2018
@version undefined
/*/
User Function F13046E() 
/*
ExecBlock("F13046E", .F., .F., {aCabNota, aItensNota})
aCabNota [1] := F1_DOC
aCabNota [2] := F1_SERIE
aCabNota [3] := F1_FORNECE
aCabNota [4] := F1_LOJA
aCabNota [5] := F1_FORMUL

aItensNota[1] := D1_PEDIDO
aItensNota[2] := D1_ITEMPC
aItensNota[3] := D1_QUANT
aItensNota[4] := D1_LOCAL
aItensNota[5] := D1_COD
*/
Local aArea    := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
Local aItens   := PARAMIXB[2]
Local nI

DBSelectArea("SC7")
DBSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN 

DBSelectArea("SB2")
DBSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL  

For nI:= 1 To Len(aItens)
  cProduto := aItens[nI,5] //Produto
  nQuant   := aItens[nI,3] //Quantidade
  cLocal   := aItens[nI,4] //Armazém
  cPedido  := aItens[nI,1] //Pedido de Compra
  cItemPC  := aItens[nI,2] //Item do Pedido de Compra   
  //Atualiza o Pedido de Compra
  IF SC7->(DBSeek(xFilial("SC7")+cPedido+cItemPC))
     RecLock("SC7",.F.)
     SC7->C7_QUJE  -= nQuant
     SC7->C7_ENCER := IIF(SC7->C7_QUANT - SC7->C7_QUJE > 0," ","E")
     SC7->(MsUnlock())
     //Atualiza o Saldos Físico e Financeiro
     IF SB2->(DBSeek(xFilial("SB2")+cProduto+cLocal))
        RecLock("SB2",.F.)
        SB2->B2_SALPEDI += nQuant
        SB2->B2_SALPED2 += ConvUm(SB2->B2_COD,SB2->B2_SALPEDI,0,2)
        SB2->(MsUnlock())
     Endif
  Endif
Next   

RestArea(aAreaSC7)
RestArea(aAreaSB2)
RestArea(aArea)                                             

Return Nil


/*/{Protheus.doc} F13040I
Ponto de entrada utilizado na rotina da FSW após a exclusão da nota fiscal de entrada.
@author Reinaldo Dias
@since 07/06/2018
@version undefined
/*/
User Function F13040I()
/*
ExecBlock("F13040I", .F., .F., {aNota, aItens})
aNota[1] := F1_DOC
aNota[2] := F1_SERIE
aNota[3] := F1_FORNECE
aNota[4] := F1_LOJA
aNota[5] := F1_FORMUL

aItens[1] := D1_COD, 
aItens[2] := D1_QUANT, 
aItens[3] := D1_LOCAL, 
aItens[4] := D1_CC, 
aItens[5] := D1_DTDIGIT, 
aItens[6] := D1_CUSTO
aItens[7] := D1_PEDIDO 
aItens[8] := D1_ITEMPC
*/
Local aArea    := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
Local aItens   := PARAMIXB[2]
Local nI

DBSelectArea("SC7")
DBSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN 

DBSelectArea("SB2")
DBSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL  

For nI:= 1 To Len(aItens)
  cProduto := aItens[nI,1] //Produto
  nQuant   := aItens[nI,2] //Quantidade
  cLocal   := aItens[nI,3] //Armazém
  cPedido  := aItens[nI,7] //Pedido de Compra
  cItemPC  := aItens[nI,8] //Item do Pedido de Compra   
  //Atualiza o Pedido de Compra
  IF SC7->(DBSeek(xFilial("SC7")+cPedido+cItemPC))
     RecLock("SC7",.F.)
     SC7->C7_QUJE  += nQuant
     SC7->C7_ENCER := IIF(SC7->C7_QUANT - SC7->C7_QUJE > 0," ","E")
     SC7->(MsUnlock())
     //Atualiza o Saldos Físico e Financeiro
     IF SB2->(DBSeek(xFilial("SB2")+cProduto+cLocal))
        RecLock("SB2",.F.)
        SB2->B2_SALPEDI -= nQuant
        SB2->B2_SALPED2 -= ConvUm(SB2->B2_COD,SB2->B2_SALPEDI,0,2)
        SB2->(MsUnlock())
     Endif
  Endif   
Next

RestArea(aAreaSC7)
RestArea(aAreaSB2)
RestArea(aArea)                                             

Return Nil

/*
User Function fTstPC() // U_fTstPC()
Local aNotas     := {}
Local aItens     := {}
Local aCabNota   := {}
Local aItensNota := {}
Local cProduto   := "500            "
Local nQuant     := 100
Local cLocal     := "01"
Local cPedido    := "000001"
Local cItemPC    := "0001"   

AAdd(aItensNota,{cPedido,cItemPC,030,cLocal,cProduto})
AAdd(aItensNota,{cPedido,cItemPC,100,cLocal,cProduto})

ExecBlock("F13046E", .F., .F., {aCabNota, aItensNota})

AAdd(aItens,{cProduto,030,cLocal,Nil,Nil,Nil,cPedido,cItemPC})
AAdd(aItens,{cProduto,100,cLocal,Nil,Nil,Nil,cPedido,cItemPC})

ExecBlock("F13040I", .F., .F., {aNotas, aItens})

Return*/