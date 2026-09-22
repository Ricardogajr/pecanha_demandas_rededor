#DEFINE F24CONSUMO    1
#DEFINE F24COMPRA     2
#DEFINE F24P12TOFRONT 1
#DEFINE F24FRONTTOP12 2

/*{Protheus.doc} F0702208
Executado no PE MT160GRPC (analise de cotação)
Gravação de campos customizados no pedido de compras
*/
User Function F0702208

    Local aConv := U_F07024X(SC7->C7_PRODUTO, cFilAnt , SC7->C7_QUANT, F24COMPRA , F24P12TOFRONT, Nil)
    
    If !Empty(aConv[3])
        Help(,,'F0702208',,"Erro de conversão de unidade de medida para o produto: " + SC7->C7_PRODUTO + " - " + aConv[3],1,0)
    Else
        SC7->C7_XQTDPC  := aConv[1]
        SC7->C7_XUMCONV := aConv[2]
        SC7->C7_XTPFATO := aConv[5]
        SC7->C7_XFATOR  := aConv[6]
        SC7->C7_XPRECO  := SC7->(C7_TOTAL / C7_XQTDPC)
        SC7->C7_XTOTAL  := SC7->(C7_XPRECO * C7_XQTDPC)

    EndIf

Return
