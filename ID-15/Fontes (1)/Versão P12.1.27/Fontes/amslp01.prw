// -----------+-----------------+------------------------------------
// Data       | Autor: 	        | Descricao
// -----------+-----------------+------------------------------------
// 15/10/2021 | Gustavo Thees  	| Rede Dor #12636140 - Lanc Padrao
// -----------+-----------------+------------------------------------
user function amslp01()
// --------------------------
    local cConta     := ''
    local cRetencao  := ''
// --------------------------
    set deleted on
// --------------------------
    do case
        case alltrim( funname() ) == 'MATA103'
            cRetencao := cCodRet
        case alltrim( funname() ) == 'TEWBTYP3'
            set deleted off
      	    dbselectarea( 'SE2' )
	        dbsetorder( 6 )
	        if dbseek( xfilial( 'SE2' ) + SF1->(F1_FORNECE + F1_LOJA + F1_SERIE + F1_DOC ))
                do while !eof()                              .AND. ;
                         SE2->E2_FILIAL  == xfilial( 'SE2' ) .AND. ;
                         SE2->E2_FORNECE == SF1->F1_FORNECE  .AND. ;
                         SE2->E2_LOJA    == SF1->F1_LOJA     .AND. ;
                         SE2->E2_PREFIXO == SF1->F1_SERIE    .AND. ;
                         SE2->E2_NUM     == SF1->F1_DOC
                    dbskip()
                enddo
                dbskip(-1)
            endif
            cRetencao := alltrim( SE2->E2_CODRET )
        otherwise
            cRetencao := alltrim( posicione( 'SE2' , 6 , xfilial( 'SE2' ) + SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC) , 'E2_CODRET' ))
    endcase
// --------------------------
    do case
        case cRetencao == '3208'
            cConta := '210301001012'
        case cRetencao == '9478'
            cConta := '210301001018'
        otherwise
            cConta := '210301001005'
    endcase
// --------------------------
    set deleted on
// --------------------------
return cConta
// ---------------------------------------------------
// [ fim de amslp01.prw ]
// ---------------------------------------------------
