#Include 'TOTVS.ch'

#Define EXCLUI_PREV 3

/*/{Protheus.doc} User Function FA050B01
    Ponto na exclusão do título, após confirmar a exclusão e antes de
    excluir o registro
    @type  Function
    @author Gianluca Moreira
    @since 20/05/2021
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6071104
    /*/
User Function FA050B01()
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        //Grava registro previsto na PX0 - envio ao XRT
        U_F2000100('SE2', EXCLUI_PREV)
    EndIf    
    
Return
