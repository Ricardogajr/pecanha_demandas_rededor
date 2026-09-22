#Include "Protheus.ch"

/*/{Protheus.doc} MT240TOK
Bloqueia a confirmação do movimentação interna caso o web service de exclusão de Nota Fiscal de Entrada esteja sendo executado.

@project    MAN0000007423048_EF_041
@type       User Function
@author     Rafael Riego
@since      10/05/2018
@version    12.1.7
@return     lOk, se permite ou não
/*/
User Function MT241TOK()

    Local lOk := .T.

    //Não executa caso a rotina de Exclusão de Nota Fiscal de Entrada esteja na pilha de chamada
    If !(FwIsInCallStack("U_F1303701")) .And. !(FwIsInCallStack("U_F1303702"))
        //Se vier de integração
        If FwIsInCallStack("U_F0703501")
            If !(U_F1303806())
                lOk := .F.
                Help("", 1, "HELP", "Semaforo", "Arquivo de semaforo em utilização. Não é possível prosseguir com a rotina.", 1, 0,,,,,,;
                    {""})
            EndIf
        Else
            lOk := U_F1303804()
        EndIf
    EndIf

Return lOk
