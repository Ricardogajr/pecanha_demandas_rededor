/*/{Protheus.doc} User Function FA050INC
    Validação da inclusão do título a pagar
    @type  Function
    @author Gianluca Moreira
    @since 14/06/2021
    /*/
User Function FA050INC()
    Local lRet := .T.
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        lRet := U_F2000416() //Verifica se já existe operação financeira inclusa
    EndIf    
    
Return lRet
