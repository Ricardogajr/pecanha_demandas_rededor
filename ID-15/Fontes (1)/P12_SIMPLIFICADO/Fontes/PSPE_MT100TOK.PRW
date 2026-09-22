#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT100TOK
Validação final do Pedido de Compra
@author izac.ciszevski
@since 01/06/2017
@Project    MAN0000007423044_EF_003 
/*/
User Function MT100TOK()

    Local lValido    := .T.
    Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

    If FwIsInCallStack("ClaAut")
        Return .T.
    EndIf
    
    //Valida se é geração de nota fiscal pela SP e pela Liberação.
    if FwIsInCallStack("MATA094") .Or. FwIsInCallStack("U_F0100401") .Or. FwIsInCallStack("U_XMATA094")
        if SC7->C7_XTPSP != "1"
            Return .T.    
        endif
    endif

    lValido := U_F1000303()// Valida a solicitação de pagamento

	If lExecPECli .And. lValido .And. FindFunction('U_FSPE0019')
		lValido := U_FSPE0019()
	EndIf

	If lExecPECli .And. lValido .And. FindFunction('U_FSPE0020')
        If !(FwIsInCallStack("U_F0703301")) .and. !(FwIsInCallStack("U_F0703302"))
    		lValido := U_FSPE0020()
    	 endif	
	EndIf
	
	If lValido
		lValido := U_F0702904() //Verifica ítens estocáveis
	EndIf
	
	//Não executa caso a rotina de Exclusão de Nota Fiscal de Entrada esteja na pilha de chamada
    If lValido .And. !(FwIsInCallStack("U_F1303701")) .And. !(FwIsInCallStack("U_F1303702"))
        //Se vier de integração
        If FwIsInCallStack("U_F0703301") .Or. FwIsInCallStack("U_F0703302")
            If !(U_F1303806())
                lValido := .F.
                Help("", 1, "HELP", "Semaforo", "Arquivo de semaforo em utilização. Não é possível prosseguir com a rotina.", 1, 0,,,,,,;
                    {""})
            EndIf
        Else
            lValido := U_F1303804()
        EndIf
    EndIf
Return lValido
