#INCLUDE 'TOTVS.CH'

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

/*/{Protheus.doc} User Function A390SEF
    Ponto localizado na gravação do cheque, após gravar o cheque e antes de atualizar
    o título
    @type  Function
    @author Gianluca Moreira
    @since 30/08/2021
    /*/
User Function A390SEF()
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    Local cUsrAlt   :=  UsrFullName(__cuserid)
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If lGrpHblt
        //Grava registro previsto na PX0 - envio ao XRT
        U_F2000100('SE2', GRVCHQ_PREV)
    EndIf
// ticket n° 12543360
    RecLock("SEF",.F.)
    SEF->EF_XLOGMOV := cUsrAlt
    SEF->EF_XDATMOV := DATE()
    SEF->EF_XHORMOV := TIME()

    MsUnlock()

Return
