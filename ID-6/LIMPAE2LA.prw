#Include 'Protheus.ch'
/*/{Protheus.doc} LIMPAE2LA
Função responsável por limpar o E2_LA antes de validar a natureza no titulo.
@type function
@version P122410  
@author Ricardo Junior
@since 1/30/2026
@return variant, nBase
/*/
User Function LIMPAE2LA()
	Local lRet := .T.
    //FA050Natur().and.FinVldNat( .F., M->E2_NATUREZ, 2 )
    //Regra solicitada pelo Peçanha - Caso alterem a natureza, o sistema limpa o campo E2_LA antes.
    if SE2->E2_NATUREZ != M->E2_NATUREZ .And. !Empty(SE2->E2_LA) .And. Altera
        RecLock("SE2",.F.)
        SE2->E2_LA := ""
        SE2->(MsUnlock())
    endif
        
    lRet := FA050Natur().and.FinVldNat( .F., M->E2_NATUREZ, 2 )

return lRet
