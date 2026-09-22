#Include 'TOTVS.ch'
 
#Define INCLUI_PREV 01
#Define ALTERA_PREV 02
#Define EXCLUI_PREV 03
#Define ENVBAN_PREV 04
#Define REJBAN_PREV 05
#Define BAIXAT_PREV 06
#Define ESTBXA_PREV 07
#Define GRVCHQ_PREV 08
#Define ESTCHQ_PREV 09
#Define ENVBAN_REAL 21
#Define REJBAN_REAL 22
#Define BAIXAT_REAL 23
#Define ESTBXA_REAL 24
#Define GRVCHQ_REAL 31
#Define ESTCHQ_REAL 32
#Define PAGADT_REAL 41
#Define RECADT_REAL 42

/*/{Protheus.doc} User Function F420IDBP
    Ponto na geração do arquivo de envio bancário
    @type  Function
    @author Gianluca Moreira
    @since 20/05/2021
    @see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360026399232-MP-SIGAFIN-FINA420-Pontos-de-Entradas-da-rotina-Arquivo-de-Pagamentos
    /*/
User Function F420IDBP()
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        //Verifica se foi enviado ao banco, sem retorno ainda
        If SE2->E2_XENVBCO == '1' //Enviado
            //Gera estorno por "rejeição bancária"
            //U_F2000100('SE2', REJBAN_PREV)
            //U_F2000100('SE2', REJBAN_REAL)   
            U_F2000110(.F.) //Limpa o Flag de envio bancário na SE2                             
        EndIf
        U_F2000100('SE2', ENVBAN_PREV) //Grava registro previsto na PX0 - envio ao XRT
        //U_F2000100('SE2', ENVBAN_REAL) //Grava registro realizado na PX0 - envio ao XRT
        U_F2000110(.T.) //Grava Flag de envio bancário
    EndIf    
    
Return 
