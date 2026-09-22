#Include 'TOTVS.ch'

/*/{Protheus.doc} User Function F380MTR
    Após confirmar a conciliação bancária, antes de gravar as tabelas
    @type  Function
    @author Gianluca Moreira
    @since 31/05/2021
    /*/
User Function F380MTR()
    Local lInverte := ThisInv()
    Local cMarca   := ThisMark()
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        U_F2000412(lInverte, cMarca) //Desfaz alteração de registro vindo do XRT
    EndIf    
    
Return
