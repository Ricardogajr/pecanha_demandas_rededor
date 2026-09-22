/*/{Protheus.doc} F1600301
Função de integração da exclusão de Pedido de Vendas
Executada no ponto de entrada MA410DEL 
@type  Function
@author Carlos A. Gomes Jr.
@since 13/12/17
/*/
User Function F1600301

    Local cMensagem := "PEDIDO DE VENDA EXCLUIDO " + SC5->C5_NUM 
    Local cRet      := "OK|"+cMensagem
    Local cRecno    := "0"

    If !Empty(SC5->C5_XNUM)
        P22->(DbSetOrder(1))
        If P22->(DbSeek(xFilial("P22")+cEmpAnt+cFilAnt+SC5->C5_NUM))
            cRecno := CValToChar(P22->(RecNo()))
        EndIf
        U_F0703401( cRecno, "1", SC5->C5_NUM, cRet, ;
                    cFilAnt, SC5->C5_XTIPO, "F", , , SC5->C5_CLIENTE, SC5->C5_LOJACLI, "T", ;
                    StrZero(Day(  SC5->C5_EMISSAO),2) + "/" + ;
                    StrZero(Month(SC5->C5_EMISSAO),2) + "/" + ;
                    StrZero(Year( SC5->C5_EMISSAO),4), , , , , , , , , cMensagem, , SC5->C5_XNUM,  )
    EndIf


Return 