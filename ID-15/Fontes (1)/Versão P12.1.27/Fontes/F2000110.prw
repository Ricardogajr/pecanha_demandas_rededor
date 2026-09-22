#Include 'TOTVS.ch'

/*/{Protheus.doc} User Function F2000110
    Atualiza campo de envio bancário da SE2
    @type  Function
    @author Gianluca Moreira
    @since 25/05/2021
    /*/
User Function F2000110(lEnvioBanc)
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If !lGrpHblt
        Return
    EndIf

    //If SE2->E2_TIPO $ MVPAGANT
    //    Return
    //EndIf
    If RecLock('SE2', .F.)
        SE2->E2_XENVBCO := IIf(lEnvioBanc, '1', '2')
        SE2->(MsUnlock())
    EndIf
Return
