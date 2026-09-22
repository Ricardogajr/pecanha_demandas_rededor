#Include "Protheus.ch"

/*/{Protheus.doc} MT410TOK
Bloqueia a confirmação do Pedido de Venda caso o web service de exclusão de Nota Fiscal de Entrada esteja sendo executado.

@project    MAN0000007423048_EF_043
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@return     lOk, se permite ou não
/*/
User Function MT410TOK()

    Local lOk := .T.

    //Não executa caso a rotina de Exclusão de Nota Fiscal de Entrada esteja na pilha de chamada
    If !(FwIsInCallStack("U_F1303701")) .And. !(FwIsInCallStack("U_F1303702"))
        lOk := U_F1303804()
    EndIf

Return lOk