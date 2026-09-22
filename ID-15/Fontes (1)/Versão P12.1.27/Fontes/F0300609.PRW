#INCLUDE 'PROTHEUS.CH'

// ------------------------------------------------------------------
// {Protheus.doc} F0300609
// O sistema atualize os campos com a data fim das tabelas de planos de saúde
// que deverão ser preenchidos com a data da demissão
// tabelas RHK, RHL, RHM nos campos RHK_PERFIM, RHL_PERFIM, RHM_PERFIM.
// @type    function
// @author  Cris
// @since   22/12/2016
// @version 1.0
// @param   lRet, logico, descricao
// @return  ${return}, ${return_description}
// @example
// (examples)
// @see     (links_or_references)
// @Project MAN00000463701_EF_006
// ------------------------------------------------------------------

user function f0300609( lRet )

// -------------------------------
    local dDtRes := ''
// -------------------------------

    RHK->( dbsetorder( 1 )) // RHK_FILIAL +   RHK_MAT + RHK_TPFORN + RHK_CODFOR
    RHK->( dbseek(           M->RG_FILIAL + M->RG_MAT ))

    do while RHK->( !EOF() ) .AND. ;
             RHK->( RHK_FILIAL + RHK_MAT) == ( M->RG_FILIAL + M->RG_MAT )

        reclock( 'RHK' , .F. )

            if lRet
                dDtRes := M->RG_DATADEM
                if !( empty( dDtRes ))
                    RHK->RHK_PERFIM := substr( dtos( dDtRes ) , 5 , 2 ) + ;
                                       substr( dtos( dDtRes ) , 1 , 4 )
                    RHK->RHK_XSTAT  := '4'
                endif
            else
                RHK->RHK_PERFIM := ''
                RHK->RHK_XSTAT  := ''
            endif

        RHK->( msunlock() )
        RHK->( dbskip() )

    enddo
// ------------------------------------------------------------------

    RHL->( dbsetorder( 1 )) // RHL_FILIAL +   RHL_MAT + RHL_TPFORN + RHL_CODFOR + RHL_CODIGO
    RHL->( dbseek(           M->RG_FILIAL + M->RG_MAT ))

    do while RHL->( !EOF() ) .AND. ;
             RHL->( RHL_FILIAL + RHL_MAT ) == ( M->RG_FILIAL + M->RG_MAT )

        reclock( 'RHL' , .F. )

            if lRet
                dDtRes := M->RG_DATADEM
                if !( empty( dDtRes ))
                    RHL->RHL_PERFIM := substr( dtos( dDtRes ) , 5 , 2 ) + ;
                                       substr( dtos( dDtRes ) , 1 , 4 )
                    RHL->RHL_XSTAT  := '4'
                endif
            else
                RHL->RHL_PERFIM := ''
                RHL->RHL_XSTAT  := ''
            endif

        RHL->( msunlock() )
        RHL->( dbskip() )

    enddo

// ------------------------------------------------------------------

    RHM->( dbsetorder( 1 )) // RHM_FILIAL +   RHM_MAT + RHM_TPFORN + RHM_CODFOR + RHM_CODIGO
    RHM->( dbseek(           M->RG_FILIAL + M->RG_MAT ))

    do while RHM->( !EOF() ) .AND. ;
             RHM->( RHM_FILIAL + RHM_MAT ) == ( M->RG_FILIAL + M->RG_MAT )

        reclock( 'RHM' , .F. )

            if lRet
                dDtRes := M->RG_DATADEM
                if !( empty( dDtRes ))
                    RHM->RHM_PERFIM := substr( dtos( dDtRes ) , 5 , 2 ) + ;
                                       substr( dtos( dDtRes ) , 1 , 4 )
                    RHM->RHM_XSTAT  := '4'
                endif
            else
                RHM->RHM_PERFIM := ''
                RHM->RHM_XSTAT  := ''
            endif

        RHM->( msunlock() )
        RHM->( dbskip() )

    enddo

return

// ------------------------------------------------------------------
// [ fim de f0300609.prw ]
// ------------------------------------------------------------------
