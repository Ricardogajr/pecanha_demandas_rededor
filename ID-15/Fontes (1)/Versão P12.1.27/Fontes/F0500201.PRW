#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TOPCONN.CH'

// ------------------------------------------------------------------
// {Protheus.doc} F0500201
// Função para  monitoramento de solicitações- RH
// @type    function
// @author  queizy.nascimento
// @since   03/11/2016
// @version 1.0
// @param   cFilOri     , character , filial de origem
// @param   cNumSolicit , character , Numero do processo RH3
// @param   cCodStatus  , character , Numero Status RCC
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

user function f0500201( cFilOri , cNumSolicit , cCodStatus , cFilAprv , cMatAprv )

// ----------------------------------------------
    local   cDescriSolicit := ''     // Descrição da Solicitação
    local   aEvento        := {}     // Descrição do Evento
    local   aApr           := {}
    local   cFuncao        := ''     // Função       do Solicitante
    local   cMatrSolicit   := ''     // Matricula    do Solicitante
    local   cNomeSolicit   := ''     // Nome         do Solicitante
    local   cSetorSolicit  := ''     // Departamento do Solicitante
    local   cUnidSolicit   := ''     // Filial       do Solicitante
    local   cCargoSolicit  := ''     // Cargo        do Solicitante
    local   cMatrAprov     := ''     // Matricula       do Aprovador
    local   cNomeAprov     := ''     // Nome            do Aprovador
    local   cSetorAprov    := ''     // Departamento    do Aprovador
    local   cUnidAprov     := ''     // Filial          do Aprovador
    local   cCargoAprov    := ''     // Cargo           do Aprovador
    local   cCC            := ''     // Centro de Custo do Aprovador
    local   cContaOrcament := ''     // Conta Orçamentária
    local   cStatus        := ''     // Descrição do Status
    local   cFilSol        := ''
    local   cFilApr        := ''
    local   nValorMov      := 0      // Valor envolvido na movimentação
    local   dData          := date() // Data da Gravação do Monitoramento
    local   cHora          := substr( time() , 1 , 2 ) + ':' + ;
                              substr( time() , 4 , 2 ) // Hora da Gravação do Monitoramento
    local   nI             := 0
    local   cCodEvento     := ''
    local   aAreas         := { SQB->( getarea() ) , ;
                                SRJ->( getarea() ) , ;
                                SRA->( getarea() ) , ;
                                RCC->( getarea() ) , ;
                                RH4->( getarea() ) , ;
                                RH3->( getarea() ) , ;
                                PA7->( getarea() ) , ;
                                PA5->( getarea() ) , ;
                                       getarea()     }
    local   lFAT           := .F.
// ----------------------------------------------
    local   lGrava         := .T. // #10210441
// ----------------------------------------------
//  [ DOR06792028_TK_7252418 - Início - 1 / 4 ]
// ----------------------------------------------
    private cUser          := ''
    private cRspMat        := ''
    private cRspNom        := ''
    private cRspSet        := ''
    private cRspUni        := ''
    private cRspCar        := ''
    private lRespon        := .F.
// ----------------------------------------------
//  [ DOR06792028_TK_7252418 - Fim - 1 / 4 ]
// ----------------------------------------------
    default cFilAprv       := ''
    default cMatAprv       := ''
// ----------------------------------------------

    dbselectarea( 'SRA' ) // Funcionários
    set filter to

// ------------------------------------------------------------------
//  [ Deverá posicionar na RH3 com o valor passado por parâmetro (cNumSolicit) e  ]
//  [ buscar as seguintes informações na RH3, preenchendo as seguintes variáveis: ]
// ------------------------------------------------------------------

    dbselectarea( 'RH3' ) // Solicitações ao RH
    RH3->( dbsetorder( 1 ) ) // RH3_FILIAL + RH3_CODIGO
    if !( RH3->( dbseek(           cFilOri + cNumSolicit )))
        aeval( aAreas , {|x| restarea(x) } )
        return .F.
    endif

    cMatrSolicit := RH3->RH3_MATINI
    cFilSol      := RH3->RH3_FILINI

    if empty( cMatAprv )
        cMatrAprov := RH3->RH3_MATAPR
        cFilApr    := RH3->RH3_FILAPR
    else
        cMatrAprov := cMatAprv
        cFilApr    := cFilAprv
    endif

    cCodEvento := RH3->RH3_XTPCTM
    
// ------------------------------------------------------------------
//  [ Deverá posicionar na SRA, com a informação do campo RH3_MATINI e ]
//  [ retornar os seguintes campos preenchendo as seguintes variáveis: ]
// ------------------------------------------------------------------

    dbselectarea( 'SRA' ) // Funcionários 
    SRA->( dbsetorder( 1 )) // RA_FILIAL + RA_MAT
    if !( SRA->( dbseek(         cFilSol + cMatrSolicit )))
        aeval( aAreas , {|x| restarea(x) } )
        return .F.
    endif

    cNomeSolicit  := SRA->RA_NOME
    cUnidSolicit  := cFilSol
    cCargoSolicit := posicione( 'SQ3' , 1 , iif( empty( xfilial( 'SQ3' ) ) , xfilial( 'SQ3' ) , cFilSol ) + SRA->RA_CARGO   , 'Q3_DESCSUM' )
    cFuncao       := posicione( 'SRJ' , 1 , iif( empty( xfilial( 'SRJ' ) ) , xfilial( 'SRJ' ) , cFilSol ) + SRA->RA_CODFUNC , 'RJ_DESC'    )
    cSetorSolicit := posicione( 'SQB' , 1 , iif( empty( xfilial( 'SQB' ) ) , xfilial( 'SQB' ) , cFilSol ) + SRA->RA_DEPTO   , 'QB_DESCRIC' )
    cCC           := SRA->RA_CC

// ------------------------------------------------------------------
//  [ Deverá posicionar na SRA novamente, com o campo RH3_MATAPR e     ]
//  [ retornar os seguintes campos preenchendo as seguintes variáveis: ]
// ------------------------------------------------------------------

    if cCodStatus $ '001/005/011/012/013/019/020'
        aApr       := ''
        cFilApr    := ''
        cMatrAprov := ''
    endif

    if cCodStatus $ '006/007/008/009/010/014/015/016/017/018/021/022/023'
        aAux       := u_getinfmat( .F. )
        cFilApr    := aAux[1]
        cMatrAprov := aAux[2]
    endif

    if cCodStatus $ '002'
        cFilApr    := cFilApr
        cMatrAprov := cMatrAprov
    endif

    if !( empty( cFilApr    )) .AND. ;
       !( empty( cMatrAprov ))

        if SRA->( dbseek( cFilApr + cMatrAprov ))
            cNomeAprov  := SRA->RA_NOME
            cUnidAprov  := SRA->RA_FILIAL
            cCargoAprov := posicione( 'SQ3' , 1 , iif( empty( xfilial( 'SQ3' )) , xfilial( 'SQ3' ) , cFilApr ) + SRA->RA_CARGO , 'Q3_DESCSUM' )
            cSetorAprov := posicione( 'SQB' , 1 , iif( empty( xfilial( 'SQB' )) , xfilial( 'SQB' ) , cFilApr ) + SRA->RA_DEPTO , 'QB_DESCRIC' )
        endif

    endif

    dbselectarea( 'PA7' )   // Controle Solicitação Portal   
    PA7->( dbgotop() )
    PA7->( dbsetorder( 1 )) // PA7_FILIAL + PA7_CODIGO + PA7_CODSUB

    dbselectarea( 'RH4' )   // Alteracao cadastral
    RH4->( dbsetorder( 1 )) // RH4_FILIAL + RH4_CODIGO + RH4_ITEM
    RH4->( dbgotop() )

    if cCodEvento <> '006'

// ------------------------------------------------------------------
//      [ Caso o valor da variável cCodEvento seja diferente de "006": ]
//      [ Deverá posicionar na TABELA DE ENVENTOS (PA7),               ]
//      [ com a variável cCodEvento e                                  ]
//      [ retornar preenchendo a variável:                             ]
// ------------------------------------------------------------------

        if PA7->( dbseek( PA7->PA7_FILIAL + cCodEvento ))
            cDescriSolicit := PA7->PA7_DESCR
            aadd( aEvento , PA7->PA7_DESCR )
        endif

// ------------------------------------------------------------------
//      [ Posicionar na RH4 buscando a linha que contenha o             ]
//      [ RH4_CAMPO == “TMP_VLSALA”, e retornar preenchendo a variável: ]
// ------------------------------------------------------------------

        if RH4->( dbseek( cFilOri + cNumSolicit ))

            do while ! eof() .AND.  RH4_CODIGO = cNumSolicit

                if alltrim( RH4_CAMPO ) == 'RCL_SALAR'
                    cValSal   := alltrim( RH4->RH4_VALNOV )
                    cValSal   := strtran( cValSal , '.' , ''  )
                    cValSal   := strtran( cValSal , ',' , '.' )
                    nValorMov := val( cValSal )
                elseif alltrim( RH4_CAMPO ) == 'QS_VCUSTO'
                    cValSal   := alltrim( RH4->RH4_VALNOV )
                    cValSal   := strtran( cValSal , '.' , ''  )
                    cValSal   := strtran( cValSal , ',' , '.' )
                    nValorMov := val( cValSal )
                endif

                RH4->( dbskip() )

            enddo

        endif

    else

        if RH4->( dbseek( RH3->RH3_FILIAL + cNumSolicit ))

            if PA7->( dbseek( PA7->PA7_FILIAL + cCodEvento ))
                cDescriSolicit := PA7->PA7_DESCR
            endif

            do while !eof() .AND.  RH4_CODIGO = cNumSolicit

                if alltrim( RH4_CAMPO ) == 'TMP_VLSALA'
                    cValSal   := alltrim( RH4->RH4_VALNOV )
                    cValSal   := strtran( cValSal , '.' , ''  )
                    cValSal   := strtran( cValSal , ',' , '.' )
                    nValorMov := val( cValSal )
                endif

                if alltrim( RH4_CAMPO ) == 'TMP_TIPO'

                        if alltrim( RH4->RH4_VALNOV ) == '1'
                        aadd( aEvento , 'Aumento Salarial' )
                    elseif alltrim( RH4->RH4_VALNOV ) == '2'
                        aadd( aEvento , 'Alteração de Cargo' )
                    elseif alltrim( RH4->RH4_VALNOV ) == '3'
                        aadd( aEvento , 'Alteração de Carga Horaria' )
                    elseif alltrim( RH4->RH4_VALNOV ) == '4'
                        aadd( aEvento , 'Troca de Turno' )
                    elseif alltrim( RH4->RH4_VALNOV ) == '5'
                        aadd( aEvento , 'Transferência' )
                    endif

                endif

                RH4->( dbskip() )

            enddo

        endif

    endif

// ------------------------------------------------------------------
//  [ Com a variável passada por parâmetro (cCodStatus),       ]
//  [ deverá posicionar na tabela auxiliar de STATUS (RCB/RCC) ]
//  [ e preencher a variável:                                  ]
// ------------------------------------------------------------------

    RCC->( dbsetorder( 1 )) // RCC_FILIAL + RCC_CODIGO + RCC_FIL    + RCC_CHAVE + RCC_SEQUEN
    RCC->( dbgotop() )
    if ( RCC->( dbseek(   RCC->RCC_FILIAL + 'U007'     + '        ' + '      '  + cCodStatus )))
        cStatus := RCC->RCC_CONTEU
    endif

// -[ Por enquanto deve ficar vazio ]--------------------------------
    cContaOrcament := ''

// -[ Gravação na tabela PA5 ]---------------------------------------
    dbselectarea( 'PA5' ) // Indicadores de Solicitações
// --------------------------------------------------------
// [ #10210441 ]
// --------------------------------------------------------
    dbsetorder( 1 ) // PA5_FILIAL + PA5_XNRSOL + PA5_XDATA
    if PA5->( dbseek(     cFilOri + cNumSolicit ))
        do while   PA5->( !eof() )            .AND. ;
                 ( PA5->PA5_FILIAL == cFilOri .AND. ;
                   PA5->PA5_XNRSOL == cNumSolicit   )
            if ( PA5->PA5_FILIAL == cFilOri     .AND. ;
                 PA5->PA5_XNRSOL == cNumSolicit .AND. ;
                 PA5->PA5_XMATAP == cMatrAprov  .AND. ;
                 PA5->PA5_XCDSTA == '003'  )
                 // ticket n° 12556840 -- Sistema não ignora a gravação na PA5 quando mesmo aprovador em caso de cancelamento
                 If cCodStatus <> "024"
                    lGrava := .F.
                EndIf 

            endif
            PA5->( dbskip() )
        enddo
    endif
// --------------------------------------------------------
    lFAP  := ( alltrim( cDescriSolicit ) == 'FAP' )                                                        // DOR06792028_TK_7252418
    cUser := iif( empty( cUserName ) , getuserport( cCodStatus , cNomeSolicit , cNomeAprov ) , cUserName ) // DOR06792028_TK_7252418
    fResp()
// --------------------------------------------------------

    if lGrava // #10210441 

    for nI := 1 to len( aEvento )

        PA5->( reclock( 'PA5' , .T. ))
            PA5->PA5_FILIAL := cFilOri
            PA5->PA5_XCDSTA := cCodStatus
            PA5->PA5_XNRSOL := cNumSolicit
            PA5->PA5_XDESOL := cDescriSolicit
            PA5->PA5_XUNIDA := cUnidSolicit
            PA5->PA5_XCODEV := cCodEvento
            PA5->PA5_XDESEV := aEvento[nI]
            PA5->PA5_FUNCAO := cFuncao
            PA5->PA5_XMAT   := cMatrSolicit
            PA5->PA5_XNOME  := cNomeSolicit
            PA5->PA5_XSETOR := cSetorSolicit
            PA5->PA5_XCARGO := cCargoSolicit
// ----------------------------------------------
//          [ DOR06792028_TK_7252418 - Início - 2 / 4 ]
// ----------------------------------------------
//          PA5->PA5_XMATAP := cMatrAprov
//          PA5->PA5_XAPROV := cNomeAprov
//          PA5->PA5_XSEAPV := cSetorAprov
//          PA5->PA5_XUNAPR := cUnidAprov
//          PA5->PA5_XCARAP := cCargoAprov
// --------------------------------------------------------
            if !( cCodStatus $ '001/005/011/012/013/019/020' )
                PA5->PA5_XMATAP := iif( lFAP .AND. lRespon .AND. empty( alltrim( cMatrAprov  )) , cRspMat , cMatrAprov  )
                PA5->PA5_XAPROV := iif( lFAP .AND. lRespon .AND. empty( alltrim( cNomeAprov  )) , cRspNom , cNomeAprov  )
                PA5->PA5_XSEAPV := iif( lFAP .AND. lRespon .AND. empty( alltrim( cSetorAprov )) , cRspSet , cSetorAprov )
                PA5->PA5_XUNAPR := iif( lFAP .AND. lRespon .AND. empty( alltrim( cUnidAprov  )) , cRspUni , cUnidAprov  )
                PA5->PA5_XCARAP := iif( lFAP .AND. lRespon .AND. empty( alltrim( cCargoAprov )) , cRspCar , cCargoAprov )
            endif
// ----------------------------------------------
//          [ DOR06792028_TK_7252418 - Fim - 2 / 4 ]
// ----------------------------------------------
            PA5->PA5_XCC    := cCC
            PA5->PA5_XCONTA := cContaOrcament
            PA5->PA5_XSTAT  := cStatus
            PA5->PA5_XEMPEN := nValorMov
            PA5->PA5_XDATA  := dData
            PA5->PA5_XHORA  := cHora
// ----------------------------------------------
//          [ DOR06792028_TK_7252418 - Início - 3 / 4 ]
// ----------------------------------------------
//          PA5->PA5_XUSER  := iif( empty( cUserName ) , getuserport( cCodStatus , cNomeSolicit , cNomeAprov ) , cUserName )
// ----------------------------------------------
            PA5->PA5_XUSER  := cUser
// ----------------------------------------------
//          [ DOR06792028_TK_7252418 - Fim - 3 / 4 ]
// ----------------------------------------------

        PA5->( msunlock( 'PA5' ))

    next nI
    
    endif // #10210441

    aeval( aAreas , {|x| restarea( x ) } )

return .T.

// ------------------------------------------------------------------
// {Protheus.doc} GetUserPort
// Obtém o usuario do portal
// @author  Fernando Carvalho
// @since   14/12/2016
// @version 1.0
// @param   cCodStatus   , characters , descricao
// @param   cNomeSolicit , characters , descricao
// @param   cNomeAprov   , characters , descricao
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function getuserport( cCodStatus , cNomeSolicit , cNomeAprov )
    local cName := ''
    if cCodStatus $ '001'
        cName := cNomeSolicit
    else
        cName := cNomeAprov
    endif
return cName

// ------------------------------------------------------------------   
// {Protheus.doc} GetAprov
// Obtém o aprovador
// @author  Fernando Carvalho
// @since   14/12/2016
// @version 1.0
// @project MAN0000007423039_EF_002
// ------------------------------------------------------------------

static function getaprov( cFilOri , cNumSolicit )

    local aArea     := getarea()
    local cQuery    := ''
    local cFilPA5   := ''
    local cCodPA5   := ''
    local cAliasPA5 := getnextalias()

    cQuery := "   SELECT MAX(R_E_C_N_O_) , "
    cQuery += "          PA5_FILIAL      , "
    cQuery += "          PA5_XNRSOL "
    cQuery += "     FROM "               + retsqlname( 'PA5' )
    cQuery += "    WHERE PA5_FILIAL = '" + cFilOri     + "' "
    cQuery += "      AND PA5_XNRSOL = '" + cNumSolicit + "' "
    cQuery += " GROUP BY PA5_FILIAL , PA5_XNRSOL "
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , tcgenqry( , , cQuery ) , cAliasPA5 , .T. , .T. )

    dbselectarea( 'PA5' )   // Indicadores de Solicitações
    PA5->( dbsetorder( 1 )) //       PA5_FILIAL + PA5_XNRSOL + PA5_XDATA
    if PA5->( dbseek( (cAliasPA5)->( PA5_FILIAL + PA5_XNRSOL )))
        cFilPA5 := PA5->PA5_XUNAPR
        cCodPA5 := PA5->PA5_XMATAP
    endif

    restarea( aArea )

return { cFilPA5 , cCodPA5 }

// ----------------------------------------------
// [ DOR06792028_TK_7252418 - Início - 4 / 4 ]
// ----------------------------------------------
static function fResp()
// -------------------------------
    local cQuery := ''
    lRespon      := .F.
// -------------------------------
    cQuery := "   SELECT   SRA.RA_FILIAL  , "
    cQuery += "            SRA.RA_MAT     , "
    cQuery += "            SRA.RA_NOME    , "
    cQuery += "            SRA.RA_NOMECMP , "
    cQuery += "            SRA.RA_CARGO   , "
    cQuery += "            SRA.RA_DEPTO   , "
    cQuery += "            SRA.RA_CIC     , "
    cQuery += "            SRA.RA_ADMISSA , "
    cQuery += "            SRA.RA_DEMISSA , "
    cQuery += "            SQ3.Q3_DESCSUM , "
    cQuery += "            SQB.QB_DESCRIC   "
    cQuery += "     FROM " + retsqlname( 'SRA' ) + " SRA , "
    cQuery +=                retsqlname( 'SQ3' ) + " SQ3 , "
    cQuery +=                retsqlname( 'SQB' ) + " SQB   "
    cQuery += "    WHERE   SRA.D_E_L_E_T_ <> '*' "
    cQuery += "      AND   SRA.RA_CIC      = '" + cUser             + "' "
    cQuery += "      AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
    cQuery += "      AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
    cQuery += "       OR   SRA.RA_DEMISSA  = ' ' )         "
    cQuery += "      AND   SQ3.D_E_L_E_T_ <> '*'           "
    cQuery += "      AND   SQ3.Q3_CARGO    = SRA.RA_CARGO  "
    cQuery += "      AND   SQB.D_E_L_E_T_ <> '*'           "
    cQuery += "      AND   SQB.QB_FILIAL   = SRA.RA_FILIAL "
    cQuery += "      AND   SQB.QB_DEPTO    = SRA.RA_DEPTO  "
    cQuery += " ORDER BY   SRA.RA_DEMISSA "
// -------------------------------
    if select( 'QRY' ) > 0
		dbselectarea( 'QRY' )
		dbclosearea()
	endif
//	memowrite( 'C:\f0500201_cQuery.sql' , cQuery )
	tcquery cQuery alias 'QRY' new
// -------------------------------
	if QRY->( ! eof() )
	    lRespon := .T.
        cRspMat := QRY->RA_MAT
        cRspNom := QRY->RA_NOME
        cRspSet := QRY->QB_DESCRIC
        cRspUni := QRY->RA_FILIAL
        cRspCar := QRY->Q3_DESCSUM
    endif
// -------------------------------
return
// ----------------------------------------------
// [ DOR06792028_TK_7252418 - Fim - 4 / 4 ]
// ----------------------------------------------

// ------------------------------------------------------------------
// [ fim de f0500201.prw ]
// ------------------------------------------------------------------
