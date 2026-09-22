#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TBICONN.CH'
#INCLUDE   'RWMAKE.CH'
#INCLUDE  'TOPCONN.CH'
#INCLUDE 'PARMTYPE.CH'

// ------------------------------------------------------------------
//  {Protheus.doc} F0500204
//  Relatório de Solicitações dos Indicadores
//  @author  Rogerio Carvalho
//  @since   15/08/2018
//  @version 12.7
//  @project MAN0000007423039_EF_002
//  @history
//  @type
// ------------------------------------------------------------------
//  Relatório desenvolvido inicalmente por Fernando Carvalho
//  (Totvs Projeto - Fabrica SP) em 07/11/2018
// ------------------------------------------------------------------
//  Alterado em 15/08/2018 por Rogerio Carvalho - 416094 (Totvs AMS-Rio),
//  para atender novas demandas do cliente (DOR04958119),
//  inserindo colunas novas, tendo uma delas vindo de outra tabela.
//  O código fonte original foi mantido comentado ao final deste.
// ------------------------------------------------------------------

// ------------------------------------------------------------------
//  [ Função Principal ]
// ------------------------------------------------------------------
user function f0500204()
// -------------------------------
    local   aArea  := getarea()
    local   oReport
// -------------------------------
    private cComp  := ''
    private aProds := {}
    private cAlias := getnextalias()
// -------------------------------
    if pergunte( 'FSW0500204' , .T. )
        processa( {|| fimprime() } , 'Imprimindo...' )
    else
        restarea( aArea )
        return
    endif
// -------------------------------
return
// ------------------------------------------------------------------

// ------------------------------------------------------------------
//  [ Função para chamar as rotinas de relatórios, ]
//  [ baseado nas respostas da tela de parâmetro   ]
// ------------------------------------------------------------------
static function fimprime()

// --------------------------------------------------------
//  [ Pergunte : Parametros de Filial ]
// --------------------------------------------------------
    if empty( alltrim( MV_PAR01 )) .OR. ;
       empty( alltrim( MV_PAR02 ))
        msgalert( 'Necessário preencher a [FILIAL] nos dois campos!' , 'PARÂMETROS - Relatório de Indicadores' )
        return
    endif

// --------------------------------------------------------
//  [ Pergunte : Parametros de Numero de Solicitação ]
// --------------------------------------------------------
    if empty( alltrim( MV_PAR03 )) .OR. ;
       empty( alltrim( MV_PAR04 ))

        if !msgyesno( 'O relatório será gerado considerando as solicitações de 00001 a 99999! Ficará mais lento para gerar! Confirma?' , 'PARÂMETROS - Relatório de Indicadores' )
            return
        else
            MV_PAR03 := '00001'
            MV_PAR04 := '99999'
        endif
    endif

// --------------------------------------------------------
//  [ Pergunte : Parametros de Numero de Solicitação ]
// --------------------------------------------------------
    if val( alltrim( MV_PAR03 )) > val( alltrim( MV_PAR04 ))
        msgalert( '[Primeira SOLICITAÇÃO] não pode ser maior que a [Segunda SOLICITAÇÃO]!' , 'PARÂMETROS - Relatório de Indicadores' )
        return
    endif

// --------------------------------------------------------
//  [ Pergunte : Parametros de Data ]
// --------------------------------------------------------
    if dtoc( MV_PAR05 ) == ' ' .OR. ;
       dtoc( MV_PAR06 ) == ' '
        msgalert( 'Necessário preencher a [DATA] nos dois campos!' , 'PARÂMETROS - Relatório de Indicadores' )
        return
    endif

// --------------------------------------------------------
//  [ Pergunte : Parametros de Data ]
// --------------------------------------------------------
    if MV_PAR05 > MV_PAR06
        msgalert( '[Primeira DATA] não pode ser maior que a [Segunda DATA]!' , 'PARÂMETROS - Relatório de Indicadores' )
        return
    endif

// --------------------------------------------------------
    if empty( alltrim( MV_PAR07 ))
        if !msgyesno( 'O relatório será gerado considerando os tipos de solicitações de 001 a 009! Ficará mais lento para gerar! Confirma?' , 'PARÂMETROS - Relatório de Indicadores' )
            return
        endif
    endif

// --------------------------------------------------------
    if empty( alltrim( MV_PAR07 ))

        u_relind1( MV_PAR01 , ;
                   MV_PAR02 , ;
                   MV_PAR03 , ;
                   MV_PAR04 , ;
                   MV_PAR05 , ;
                   MV_PAR06 , ;
                   MV_PAR07   )

        MV_PAR07 := '002'
        u_relind2( MV_PAR01 , ;
                   MV_PAR02 , ;
                   MV_PAR03 , ;
                   MV_PAR04 , ;
                   MV_PAR05 , ;
                   MV_PAR06 , ;
                   MV_PAR07   )

        MV_PAR07 := '004'
        u_relind4( MV_PAR01 , ;
                   MV_PAR02 , ;
                   MV_PAR03 , ;
                   MV_PAR04 , ;
                   MV_PAR05 , ;
                   MV_PAR06 , ;
                   MV_PAR07   )

    else

        if !empty( alltrim( MV_PAR07 )) .AND. ;
           ( MV_PAR07 <> '002' )        .AND. ;
           ( MV_PAR07 <> '004' )
// --------------------------------------------------------
//          [ Todas as solicitações , exceto, ]
//          [ Vagas sem cod vagas sem FAP,    ]
//          [ Vagas com cod vagas sem FAP,    ]
//          [ Somente FAP ]
// --------------------------------------------------------
            u_relind1( MV_PAR01 , ;
                       MV_PAR02 , ;
                       MV_PAR03 , ;
                       MV_PAR04 , ;
                       MV_PAR05 , ;
                       MV_PAR06 , ;
                       MV_PAR07   )

        elseif MV_PAR07 == '002'
// --------------------------------------------------------
//          [ Solicitações ]
//          [ Vagas sem cod vagas sem FAp ]
//          [ Vagas com cod vagas sem FAP ]
// --------------------------------------------------------
            u_relind2( MV_PAR01 , ;
                       MV_PAR02 , ;
                       MV_PAR03 , ;
                       MV_PAR04 , ;
                       MV_PAR05 , ;
                       MV_PAR06 , ;
                       MV_PAR07   )

        elseif MV_PAR07 == '004'
// --------------------------------------------------------
//          [ Solicit Somente FAP ]
// --------------------------------------------------------
            u_relind4( MV_PAR01 , ;
                       MV_PAR02 , ;
                       MV_PAR03 , ;
                       MV_PAR04 , ;
                       MV_PAR05 , ;
                       MV_PAR06 , ;
                       MV_PAR07   )

        endif

    endif

return

// ------------------------------------------------------------------
// [ TODAS SOLICITACOES EXCETO VAGAS COM /SEM FAP , E SOMENTE FAP ]
// ------------------------------------------------------------------
user function relind1( PAR01 , PAR02 , PAR03 , PAR04 , PAR05 , PAR06 , PAR07 )

// -------------------------------
    local cQuery     := ''
    local oExcel     := FWMsExcelEx():New()
    local cArqXML    := alltrim( gettemppath() ) + criatrab( , .F. ) + '.xml'
    local cNomTab    := 'Indicadores (1)'
    local cNomPar    := 'Parametros'
    local oExcelApp
    local cQuery     := ''
    local cFilDoc    := ''
    local cEmissao   := ''
    local cNumDoc    := ''
    local cDtPagam   := ''
    local cCodFor    := ''
    local cDescFor   := ''
    local cCodProd   := ''
    local cDescProd  := ''
    local nDifd      := 0
    local cDCalc     := ''
    local cResult    := ''
    local cPA5Xnrsol := ''
    local nDutil     := 0
    local dPA5xdat
// -------------------------------
    oExcel:AddworkSheet( 'Outras Solic' ) // Outras Solic : 001, 003, 005 e etc...
    oExcel:AddTable(     'Outras Solic' , cNomTab )
// -------------------------------
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'NºSolic'             , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Descricao'           , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'C.Ev.'               , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Evento'              , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Status'              , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Mat.Sol.'            , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Nome Solic'          , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Setor Solic'         , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Unidade Sol'         , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Mat.Apr.'            , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Nome Aprov'          , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Setor Aprov'         , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Unid.Aprov.'         , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Data'                , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Hora'                , 1 , 3 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Dias Uteis SLA'      , 1 , 1 )
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Filial Solicitação'  , 1 , 3 )
// ------------------------------------------------------------------
//  oExcel:AddColumn( ''             , cNomTab , 'Número FAP'          , 1 , 3 )
// ------------------------------------------------------------------
    oExcel:AddColumn( 'Outras Solic' , cNomTab , 'Analista Tratamento' , 1 , 3 )
// -------------------------------
//  [ TODAS SOLICITACOES EXCETO VAGAS COM /SEM FAP , E SOMENTE FAP ]
// -------------------------------
    cQuery :=   " SELECT PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XDESOL , "
    cQuery +=          " PA5_XUNIDA , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDESEV , "
    cQuery +=          " PA5_FUNCAO , "
    cQuery +=          " PA5_XMAT   , "
    cQuery +=          " PA5_XNOME  , "
    cQuery +=          " PA5_XSETOR , "
    cQuery +=          " PA5_XCARGO , "
    cQuery +=          " PA5_XMATAP , "
    cQuery +=          " PA5_XAPROV , "
    cQuery +=          " PA5_XSEAPV , "
    cQuery +=          " PA5_XUNAPR , "
    cQuery +=          " PA5_XCARAP , "
    cQuery +=          " PA5_XCC    , "
    cQuery +=          " PA5_XCONTA , "
    cQuery +=          " PA5_XSTAT  , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5_XUSER  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
    cQuery +=     " FROM PA5010 PA5 "
    cQuery +=    " WHERE PA5.D_E_L_E_T_       = ' ' "
// -------------------------------
    if empty( alltrim( PAR07 ))                                 // Gera todos o codigos de eventos , exceto vagas com/sem FAP e Somente FAP
        cQuery +=  " AND PA5_XCODEV      NOT IN ('002','004') "  // filtra para nao trazer vagas e FAP
    else                                                        // Gera somente o codigo de evento informado
        cQuery +=  " AND PA5_XCODEV           = '" +       PAR07   + "' "
    endif
// -------------------------------	
    cQuery +=      " AND PA5.PA5_FILIAL BETWEEN '" +       PAR01   + "' "
    cQuery +=                             " AND '" +       PAR02   + "' "
    cQuery +=      " AND PA5_XNRSOL     BETWEEN '" +       PAR03   + "' "
    cQuery +=                             " AND '" +       PAR04   + "' "
    cQuery +=      " AND PA5.PA5_XDATA  BETWEEN '" + dtos( PAR05 ) + "' "
    cQuery +=                             " AND '" + dtos( PAR06 ) + "' "
    cQuery += " ORDER BY PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
// -------------------------------
    if select( 'ARQSV1' ) > 0
        dbselectarea( 'ARQSV1' )
        ARQSV1->( dbclosearea() )
    endif
// -------------------------------
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , 'ARQSV1' , .T. , .T. )
// -------------------------------
    procregua( ARQSV1->( reccount() ))
// -------------------------------
    do while ARQSV1->( !eof() )

        incproc( 'Gerando Planilha com todos os tipos de Solicitações, exceto [Vagas e FAP]! Aguarde...' )

        cPA5Xnrsol := ARQSV1->PA5_XNRSOL // proximo numero da PA5_XNRSOL
        dPA5xdat   := ARQSV1->PA5_XDATA  // data do proximo numero da PA5_XNRSOL
        nDutil     := 0                  // armazena a quantidade de dias uteis - 1 dia
        nDifd      := 0                  // armazena a quantidade de dias uteis 

// ------------------------------------------------------------------		
//      [ verifica se há alçada do codigo da solicitação antes do periodo ]
//      [ informado no pergunte, com objetivo de contagem para o SLA      ]
// ------------------------------------------------------------------
        cQant :=   " SELECT PA5_XDATA "
        cQant +=     " FROM " + retsqlname( 'PA5' ) + " PA5 "
        cQant +=    " WHERE D_E_L_E_T_          = ' ' "
        cQant +=      " AND PA5_XNRSOL          = '" + ARQSV1->PA5_XNRSOL + "' "
        cQant +=      " AND PA5.PA5_XDATA BETWEEN '20160101' "
        cQant +=                            " AND '" + dtos( PAR05 - 1 )  + "' "
        cQant +=      " AND PA5.PA5_FILIAL      = '" + ARQSV1->PA5_FILIAL + "' "
        cQant += " ORDER BY PA5_XDATA DESC "
// -------------------------------
        if select( 'ARQANT' ) > 0
            dbselectarea( 'ARQANT' )
            ARQANT->( dbclosearea() )
        endif
// -------------------------------
        cQant := changequery( cQant )
        dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQant ) , 'ARQANT' , .T. , .T. )
// -------------------------------
        if ARQANT->( ! eof() )
            dPA5xdat := ARQANT->PA5_XDATA
        endif
// -------------------------------
        ARQANT->( dbclosearea() )
        
// ------------------------------------------------------------------
//      [ Fim verificação de período anterior para solicitção ]
// ------------------------------------------------------------------
        dbselectarea( 'ARQSV1' )

        do while ARQSV1->PA5_XNRSOL == cPA5Xnrsol

            if ARQSV1->PA5_XDATA == dPA5xdat
                nDutil := 0
            else
                nDifd  := dateworkday( stod( dPA5xdat ) , stod( ARQSV1->PA5_XDATA ))
                nDutil := nDifd - 1 // armazena a quantidade de dias uteis menos 1 dia
            endif                   // porque a funcao conta inclusive com o dia da primeira data da comparação

// -------------------------------
//          [ gera dados para planilha ]
// -------------------------------
            cdutil   := cvaltochar( nDutil )
            cNumSol  :=       ARQSV1->PA5_XNRSOL
            cDesSol  :=       ARQSV1->PA5_XDESOL
            cUnid    :=       ARQSV1->PA5_XUNIDA
            cTipCod  :=       ARQSV1->PA5_XCODEV
            cDesTip  :=       ARQSV1->PA5_XDESEV
            cFunc    :=       ARQSV1->PA5_FUNCAO
            cMat     :=       ARQSV1->PA5_XMAT
            cNome    :=       ARQSV1->PA5_XNOME
            cSet     :=       ARQSV1->PA5_XSETOR
            cCarg    :=       ARQSV1->PA5_XCARGO
            cMatAp   :=       ARQSV1->PA5_XMATAP
            cAprov   :=       ARQSV1->PA5_XAPROV
            cSetApr  :=       ARQSV1->PA5_XSEAPV
            cUniApr  :=       ARQSV1->PA5_XUNAPR
            cCarApr  :=       ARQSV1->PA5_XCARAP
            cStat    :=       ARQSV1->PA5_XSTAT
            dData    := stod( ARQSV1->PA5_XDATA ) // ARQSV1->( stod( PA5_XDATA ))
            cHora    :=       ARQSV1->PA5_XHORA
//          cCod     := ' '                       // ARQSV1->PA2_SOL
            cFili    :=       ARQSV1->PA5_FILIAL
            cUsua    :=       ARQSV1->PA5_XUSER
// -------------------------------
//          [ alimenta as colunas da planilha ]
// -------------------------------
            oExcel:AddRow( 'Outras Solic' , cNomTab , { cNumSol , ;
                                                        cDesSol , ;
                                                        cTipCod , ;
                                                        cDesTip , ;
                                                        cStat   , ;
                                                        cMat    , ;
                                                        cNome   , ;
                                                        cSet    , ;
                                                        cUnid   , ;
                                                        cCarg   , ;
                                                        cMatAp  , ;
                                                        cAprov  , ;
                                                        cSetApr , ;
                                                        cCarApr , ;
                                                        cUniApr , ;
                                                        dData   , ;
                                                        cHora   , ;
                                                        cDutil  , ;
                                                        cFili   , ;
                                                        cUsua   } )
// ------------------------------------------------------------------
//                                                      cCod    , ;
// ------------------------------------------------------------------
            dPA5xdat := ARQSV1->PA5_XDATA

            ARQSV1->( dbskip() )

        enddo

    enddo
    
// -------------------------------
//  [ gera planilha ]
// -------------------------------
    oExcel:Activate()
    oExcel:GetXMLFile( cArqXML )
// -------------------------------    
    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open( cArqXML )
    oExcelApp:SetVisible( .T. )
    oExcelApp:Destroy()
    oExcelApp := NIL
// -------------------------------
    ARQSV1->( dbclosearea() )

// ------------------------------------------------------------------
//  [ Fim : TODAS SOLICITACOES EXCETO VAGAS COM /SEM FAP , E SOMENTE FAP ]
// ------------------------------------------------------------------

return
// ------------------------------------------------------------------

// ------------------------------------------------------------------
//  [ VAGAS SEM CÓDIGO DE VAGAS E SEM FAP ]
//  [ VAGAS COM CÓDIGO DE VAGAS E SEM FAP ]
//  [ VAGAS COM CÓDIGO DE VAGAS E COM FAP ]
// ------------------------------------------------------------------
user function relind2( PAR01 , PAR02 , PAR03 , PAR04 , PAR05 , PAR06 , PAR07 )

// -------------------------------
    local oExcel     := FWMsExcel():New() // A classe FwMsExcelEx quando há mais de uma aba, a planilha corrompe.
    local cArqXML    := alltrim( gettemppath() ) + criatrab( , .F. ) + '.xml'
    local cNomTab    := 'Indicadores (2)'
    local cNomPar    := 'Parametros'
    local oExcelApp
    local cQuery     := ''
    local cFilDoc    := ''
    local cEmissao   := ''
    local cNumDoc    := ''
    local cDtPagam   := ''
    local cCodFor    := ''
    local cDescFor   := ''
    local cCodProd   := ''
    local cDescProd  := ''
    local nDifd      := 0
    local cDCalc     := ''
    local cResult    := ''
    local cPA5Xnrsol := ''
    local nDutil     := 0
    local dPA5xdat
// -------------------------------
    local cQry       := '' // gus
// ------------------------------------------------------------------
//  [ Inicio: VAGAS SEM CÓDIGO DE VAGAS E SEM FAP ]
// ------------------------------------------------------------------
    oExcel:AddworkSheet( 'VSVSF' ) // VSVSF : Vagas Sem cod. de Vagas e Sem FAP
    oExcel:AddTable(     'VSVSF' , cNomTab )
// ------------------------------------------------------------------
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'NºSolic'             , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Descricao'           , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'C.Ev.'               , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Evento'              , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Status'              , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Mat.Sol.'            , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Nome Solic'          , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Setor Solic'         , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Unidade Sol'         , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Mat.Apr.'            , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Nome Aprov'          , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Setor Aprov'         , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Unid.Aprov.'         , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Data'                , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Hora'                , 1 , 3 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Dias Uteis SLA'      , 1 , 1 )
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Filial Solicitação'  , 1 , 3 )
// ------------------------------------------------------------------
//  oExcel:AddColumn( ''      , cNomTab , 'Número FAP'          , 1 , 3 )
// ------------------------------------------------------------------
    oExcel:AddColumn( 'VSVSF' , cNomTab , 'Analista Tratamento' , 1 , 3 )
// ------------------------------------------------------------------
//  [ select para buscar os dados na PA5(indicadores) ]
//  [ certificando que não existe na SQS (vagas)      ]
// ------------------------------------------------------------------
    cQuery :=   " SELECT PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XDESOL , "
    cQuery +=          " PA5_XUNIDA , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDESEV , "
    cQuery +=          " PA5_FUNCAO , "
    cQuery +=          " PA5_XMAT   , "
    cQuery +=          " PA5_XNOME  , "
    cQuery +=          " PA5_XSETOR , "
    cQuery +=          " PA5_XCARGO , "
    cQuery +=          " PA5_XMATAP , "
    cQuery +=          " PA5_XAPROV , "
    cQuery +=          " PA5_XSEAPV , "
    cQuery +=          " PA5_XUNAPR , "
    cQuery +=          " PA5_XCARAP , "
    cQuery +=          " PA5_XCC    , "
    cQuery +=          " PA5_XCONTA , "
    cQuery +=          " PA5_XSTAT  , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5_XUSER  , "
    cQuery +=          " PA5.R_E_C_N_O_ " 
    cQuery +=     " FROM PA5010 PA5 "
    cQuery +=    " WHERE PA5.D_E_L_E_T_       = ' ' "
    cQuery +=      " AND PA5_XCODEV          IN ('002') "
    cQuery +=      " AND PA5_XNRSOL      NOT IN ( SELECT QS_XSOLPTL "
    cQuery +=                                     " FROM SQS010 "
    cQuery +=                                    " WHERE D_E_L_E_T_       = ' ' "
    cQuery +=                                      " AND QS_XSOLFIL BETWEEN '" + PAR01 + "' "
    cQuery +=                                                         " AND '" + PAR02 + "' ) "
    cQuery +=      " AND PA5.PA5_FILIAL BETWEEN '" +       PAR01   + "' "
    cQuery +=                             " AND '" +       PAR02   + "' "
    cQuery +=      " AND PA5_XNRSOL     BETWEEN '" +       PAR03   + "' "
    cQuery +=                             " AND '" +       PAR04   + "' "
    cQuery +=      " AND PA5.PA5_XDATA  BETWEEN '" + dtos( PAR05 ) + "' "
    cQuery +=                             " AND '" + dtos( PAR06 ) + "' "
    cQuery += " ORDER BY PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
// -------------------------------
    if select( 'ARQSV1' ) > 0
        dbselectarea( 'ARQSV1' )
        ARQSV1->( dbclosearea() )
    endif
// -------------------------------
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , 'ARQSV1' , .T. , .T. )
// -------------------------------
    procregua( ARQSV1->( reccount() ))
// -------------------------------
    do while ARQSV1->( ! eof() )

        incproc( 'Gerando Planilha com Solicitações do tipo [Vagas Sem Codigo de Vagas e Sem FAP]! Aguarde...' )
// -------------------------------
        cPA5Xnrsol := ARQSV1->PA5_XNRSOL // proximo numero da PA5_XNRSOL
        dPA5xdat   := ARQSV1->PA5_XDATA  // data do proximo numero da PA5_XNRSOL
        nDutil     := 0                  // armazena a quantidade de dias uteis - 1dia
        nDifd      := 0                  // armazena a quantidade de dias uteis
// ------------------------------------------------------------------
//      [ verifica se há alçada do codigo da solicitação antes do periodo ]
//      [ informado no pergunte , com objetivo de contagem para o SLA     ]
// ------------------------------------------------------------------
        cQant :=   " SELECT PA5_XDATA "
        cQant +=     " FROM " + retsqlname( 'PA5' ) + " PA5 "
        cQant +=    " WHERE D_E_L_E_T_          = ' ' "
        cQant +=      " AND PA5_XNRSOL          = '" + ARQSV1->PA5_XNRSOL + "' "
        cQant +=      " AND PA5.PA5_XDATA BETWEEN '20160101' "
        cQant +=                            " AND '" + dtos( PAR05 - 1 )  + "' "
        cQant +=      " AND PA5.PA5_FILIAL      = '" + ARQSV1->PA5_FILIAL + "' "
        cQant += " ORDER BY PA5_XDATA DESC "
// -------------------------------	
        if select( 'ARQANT' ) > 0
            dbselectarea( 'ARQANT' )
            ARQANT->( dbclosearea() )
        endif
// -------------------------------
        cQant := changequery( cQant )
        dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQant ) , 'ARQANT' , .T. , .T. )
// -------------------------------
        if ARQANT->( ! eof() )
            dPA5xdat := ARQANT->PA5_XDATA
        endif
// -------------------------------
        ARQANT->( dbclosearea() )

// ------------------------------------------------------------------
//      [ Fim verificação de período anterior para solicitção ]
// ------------------------------------------------------------------

        dbselectarea( 'ARQSV1' )

        do while ARQSV1->PA5_XNRSOL == cPA5Xnrsol

            if ARQSV1->PA5_XDATA == dPA5xdat
                nDutil := 0
            else
                nDifd  := dateworkday( stod( dPA5xdat ) , stod( ARQSV1->PA5_XDATA ))
                nDutil := nDifd - 1 // armazena a quantidade de dias uteis menos 1 dia
            endif                   // porque a funcao conta inclusive com o dia da primeira data da comparação

// -------------------------------
//          [ gera dados para planilha ]
// -------------------------------
            cDutil  := cvaltochar( nDutil )
            cNumSol :=       ARQSV1->PA5_XNRSOL
            cDesSol :=       ARQSV1->PA5_XDESOL
            cUnid   :=       ARQSV1->PA5_XUNIDA
            cTipCod :=       ARQSV1->PA5_XCODEV
            cDesTip :=       ARQSV1->PA5_XDESEV
            cFunc   :=       ARQSV1->PA5_FUNCAO
            cMat    :=       ARQSV1->PA5_XMAT
            cNome   :=       ARQSV1->PA5_XNOME
            cSet    :=       ARQSV1->PA5_XSETOR
            cCarg   :=       ARQSV1->PA5_XCARGO
            cMatAp  :=       ARQSV1->PA5_XMATAP
            cAprov  :=       ARQSV1->PA5_XAPROV
            cSetApr :=       ARQSV1->PA5_XSEAPV
            cUniApr :=       ARQSV1->PA5_XUNAPR
            cCarApr :=       ARQSV1->PA5_XCARAP
            cStat   :=       ARQSV1->PA5_XSTAT
            dData   := stod( ARQSV1->PA5_XDATA ) // ARQSV1->(STOD(PA5_XDATA))
            cHora   :=       ARQSV1->PA5_XHORA
            cCod    := ' '                       // ARQSV1->PA2_SOL
            cFili   :=       ARQSV1->PA5_FILIAL
            cUsua   :=       ARQSV1->PA5_XUSER
// -------------------------------
//          [ alimenta as colunas da planilha ]
// -------------------------------
            oExcel:AddRow( 'VSVSF' , cNomTab , { cNumSol , ;
                                                 cDesSol , ;
                                                 cTipCod , ;
                                                 cDesTip , ;
                                                 cStat   , ;
                                                 cMat    , ;
                                                 cNome   , ;
                                                 cSet    , ;
                                                 cUnid   , ;
                                                 cCarg   , ;
                                                 cMatAp  , ;
                                                 cAprov  , ;
                                                 cSetApr , ;
                                                 cCarApr , ;
                                                 cUniApr , ;
                                                 dData   , ;
                                                 cHora   , ;
                                                 cDutil  , ;
                                                 cFili   , ;
                                                 cUsua   } )
// ------------------------------------------------------------------
//                                               cCod    , ;
// ------------------------------------------------------------------

            dPA5xdat := ARQSV1->PA5_XDATA

            ARQSV1->( dbskip() )

        enddo

    enddo

    ARQSV1->( dbclosearea() )

// ------------------------------------------------------------------
//  [ Fim : VAGAS SEM CÓDIGO DE VAGAS E SEM FAP ]
// ------------------------------------------------------------------


// ------------------------------------------------------------------
//  [ Inicio: VAGAS COM CÓDIGO DE VAGAS E SEM FAP ]
// ------------------------------------------------------------------ 
    oExcel:AddworkSheet( 'VCVSF' ) // VCVSF : Vagas com Código de Vagas e Sem FAP
    oExcel:AddTable(     'VCVSF' , cNomTab )
// ------------------------------------------------------------------
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'NºSolic'             , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Descricao'           , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'C.Ev.'               , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Evento'              , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Status'              , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab,  'Mat.Sol.'            , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Nome Solic'          , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Setor Solic'         , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Unidade Sol'         , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Mat.Apr.'            , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Nome Aprov'          , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Setor Aprov'         , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Unid.Aprov.'         , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Data'                , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Hora'                , 1 , 3 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Dias Uteis SLA'      , 1 , 1 )
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Filial Solicitação'  , 1 , 3 )
// ------------------------------------------------------------------
//  oExcel:AddColumn( ''      , cNomTab , 'Número FAP'          , 1 , 3 )
// ------------------------------------------------------------------
    oExcel:AddColumn( 'VCVSF' , cNomTab , 'Analista Tratamento' , 1 , 3 )

// ------------------------------------------------------------------
//  [ select para buscar na PA5(indicadores) , ]
//  [ certificando que existe na SQS(vagas)    ]
// ------------------------------------------------------------------
    cQuery :=   " SELECT PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XDESOL , "
    cQuery +=          " PA5_XUNIDA , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDESEV , "
    cQuery +=          " PA5_FUNCAO , "
    cQuery +=          " PA5_XMAT   , "
    cQuery +=          " PA5_XNOME  , "
    cQuery +=          " PA5_XSETOR , "
    cQuery +=          " PA5_XCARGO , "
    cQuery +=          " PA5_XMATAP , "
    cQuery +=          " PA5_XAPROV , "
    cQuery +=          " PA5_XSEAPV , "
    cQuery +=          " PA5_XUNAPR , "
    cQuery +=          " PA5_XCARAP , "
    cQuery +=          " PA5_XCC    , "
    cQuery +=          " PA5_XCONTA , "
    cQuery +=          " PA5_XSTAT  , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5_XUSER  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
    cQuery +=     " FROM PA5010 PA5 "
    cQuery +=    " WHERE PA5.D_E_L_E_T_       = ' ' "
    cQuery +=      " AND PA5_XCODEV          IN ('002') "
    cQuery +=      " AND PA5_XNRSOL          IN ( SELECT QS_XSOLPTL "
    cQuery +=                                     " FROM SQS010 "
    cQuery +=                                    " WHERE D_E_L_E_T_       = ' ' "
    cQuery +=                                      " AND QS_XSOLFIL BETWEEN '" + PAR01 + "' "
    cQuery +=                                                         " AND '" + PAR02 + "' ) "
    cQuery +=      " AND PA5.PA5_FILIAL BETWEEN '" +       PAR01   + "' "
    cQuery +=                             " AND '" +       PAR02   + "' "
    cQuery +=      " AND PA5_XNRSOL     BETWEEN '" +       PAR03   + "' "
    cQuery +=                             " AND '" +       PAR04   + "' "
    cQuery +=      " AND PA5.PA5_XDATA  BETWEEN '" + dtos( PAR05 ) + "' "
    cQuery +=                             " AND '" + dtos( PAR06 ) + "' "
    cQuery += " ORDER BY PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
// -------------------------------
    if select( 'ARQSV1' ) > 0
        dbselectarea( 'ARQSV1' )
        ARQSV1->( dbclosearea() )
    endif
// -------------------------------
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , 'ARQSV1' , .T. , .T. )
// -------------------------------
    procregua( ARQSV1->( reccount() ))
// -------------------------------

    do while ARQSV1->( ! eof() )

// -------------------------------
        incproc( 'Gerando Planilha com Solicitações do tipo [Vagas Com Codigo de Vagas e Sem FAP]! Aguarde...' )
// -------------------------------
        cPA5Xnrsol := ARQSV1->PA5_XNRSOL //         proximo numero da PA5_XNRSOL
        dPA5xdat   := ARQSV1->PA5_XDATA  // data do proximo numero da PA5_XNRSOL
        nDutil     := 0                  // armazena a quantidade de dias uteis menos um dia ( - 1 dia  )
        nDifd      := 0                  // armazena a quantidade de dias uteis
// -------------------------------
//      [ verifica na SQS ]
// -------------------------------
        dbselectarea( 'SQS' ) // Vagas
        SQS->( dbsetorder( 5 )) // QS_XSOLPTL
        dbgotop()
// -------------------------------
//      [ verifica se existe na SQS(vagas), por redundancia ]
// -------------------------------
        if SQS->( dbseek( cPA5Xnrsol ))

            cQSVaga  := SQS->QS_VAGA
            cQSFilVg := SQS->QS_FILPOST

            dbselectarea( 'PA2' ) // FORMULÁRIO DE APROVAÇÃO PROFIS
            PA2->( dbsetorder( 8 )) // PA2_FILVG + PA2_CDVAGA
            dbgotop()

// -------------------------------
//          [ verifica se existe na PA2 (FAP) ]
// -------------------------------       	
            if !PA2->( dbseek( cQSFilVg + cQSVaga ))

// -------------------------------
//              [ verifica se há alçada do codigo da solicitação antes do periodo ]
//              [ informado no pergunte , com objetivo de contagem para o SLA     ]
// -------------------------------
                cQant :=   " SELECT PA5_XDATA "
                cQant +=     " FROM " + retsqlname( 'PA5' ) + " PA5 "
                cQant +=    " WHERE D_E_L_E_T_          = ' ' "
                cQant +=      " AND PA5_XNRSOL          = '" + cPA5Xnrsol         + "' "
                cQant +=      " AND PA5.PA5_XDATA BETWEEN '20160101' "
                cQant +=                            " AND '" + dtos( PAR05 - 1 )  + "' "
                cQant +=      " AND PA5.PA5_FILIAL      = '" + ARQSV1->PA5_FILIAL + "' "
                cQant += " ORDER BY PA5_XDATA DESC "
// -------------------------------		
                if select( 'ARQANT' ) > 0
                    dbselectarea( 'ARQANT' )
                    ARQANT->( dbclosearea() )
                endif
// -------------------------------
                cQant := changequery( cQant )
                dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQant ) , 'ARQANT' , .T. , .T. )
// -------------------------------
                if ARQANT->( ! eof() )
                    dPA5xdat := ARQANT->PA5_XDATA
                endif
                ARQANT->( dbclosearea() )

// ------------------------------------------------------------------
//              [ Fim verificação de período anterior para solicitção ]
// ------------------------------------------------------------------


// ------------------------------------------------------------------
//              [ essa verificação é a mais importante. ]
//              [ só segue se nao existir na FAP        ]
// ------------------------------------------------------------------
                dbselectarea( 'ARQSV1' )

                do while ARQSV1->PA5_XNRSOL == cPA5Xnrsol

                    if ARQSV1->PA5_XDATA == dPA5xdat
                        nDutil := 0
                    else
                        nDifd  := dateworkday( stod( dPA5xdat ) , stod( ARQSV1->PA5_XDATA ))
                        nDutil := nDifd - 1 // armazena a quantidade de dias uteis menos 1 dia
                    endif                   // porque a funcao conta inclusive com o dia da primeira data da comparação

// -------------------------------
//                  [ gera dados para planilha ]
// -------------------------------
                    cdutil  :=       cvaltochar( nDutil )
                    cNumSol :=       ARQSV1->PA5_XNRSOL
                    cDesSol :=       ARQSV1->PA5_XDESOL
                    cUnid   :=       ARQSV1->PA5_XUNIDA
                    cTipCod :=       ARQSV1->PA5_XCODEV
                    cDesTip :=       ARQSV1->PA5_XDESEV
                    cFunc   :=       ARQSV1->PA5_FUNCAO
                    cMat    :=       ARQSV1->PA5_XMAT
                    cNome   :=       ARQSV1->PA5_XNOME
                    cSet    :=       ARQSV1->PA5_XSETOR
                    cCarg   :=       ARQSV1->PA5_XCARGO
                    cMatAp  :=       ARQSV1->PA5_XMATAP
                    cAprov  :=       ARQSV1->PA5_XAPROV
                    cSetApr :=       ARQSV1->PA5_XSEAPV
                    cUniApr :=       ARQSV1->PA5_XUNAPR
                    cCarApr :=       ARQSV1->PA5_XCARAP
                    cStat   :=       ARQSV1->PA5_XSTAT
                    dData   := stod( ARQSV1->PA5_XDATA ) // ARQSV1->(STOD(PA5_XDATA))
                    cHora   :=       ARQSV1->PA5_XHORA
// -------------------------------
//                  cCod    :=       ARQSV1->PA2_SOL
// -------------------------------
                    cFili   :=       ARQSV1->PA5_FILIAL
                    cUsua   :=       ARQSV1->PA5_Xuser

// -------------------------------
//                  [ alimenta as colunas da planilha ]
// -------------------------------
                    oExcel:AddRow( 'VCVSF' , cNomTab , { cNumSol , ;
                                                         cDesSol , ;
                                                         cTipCod , ;
                                                         cDesTip , ;
                                                         cStat   , ;
                                                         cMat    , ;
                                                         cNome   , ;
                                                         cSet    , ;
                                                         cUnid   , ;
                                                         cCarg   , ;
                                                         cMatAp  , ;
                                                         cAprov  , ;
                                                         cSetApr , ;
                                                         cCarApr , ;
                                                         cUniApr , ;
                                                         dData   , ;
                                                         cHora   , ;
                                                         cDutil  , ;
                                                         cFili   , ;
                                                         cUsua   } )
// ------------------------------------------------------------------
//                                                       cCod    , ;
// ------------------------------------------------------------------

                    dPA5xdat := ARQSV1->PA5_XDATA

                    ARQSV1->( dbskip() )

                enddo

            else

// ------------------------------------------------------------------
//              [ se achar na PA2(FAP), pula para o proximo registro da PA5 ]
// ------------------------------------------------------------------
                dPA5xdat := ARQSV1->PA5_XDATA // pega data atual para comparar com a proxima
                
                ARQSV1->( dbskip() )

            endif

        else

// ------------------------------------------------------------------
//          [ se nao achar na SQS(vagas) , pula para o proximo registro da PA5 ]
// ------------------------------------------------------------------
            dPA5xdat := ARQSV1->PA5_XDATA // pega data atual para comparar com a proxima

            ARQSV1->( dbskip() )

        endif

    enddo

// ------------------------------------------------------------------
//  [ Fim: VAGAS COM CÓDIGO DE VAGAS E SEM FAP ]
// ------------------------------------------------------------------


// ------------------------------------------------------------------
//  [ Inicio: VAGAS COM CÓDIGO DE VAGAS E COM FAP ]
// ------------------------------------------------------------------
    oExcel:AddworkSheet( 'VCVCF' ) // VCVCF : Vagas com Codigo de Vagas e com FAP
    oExcel:AddTable(     'VCVCF' , cNomTab )
// -------------------------------
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'NºSolic'             , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Descricao'           , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'C.Ev.'               , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Evento'              , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Status'              , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Mat.Sol.'            , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Nome Solic'          , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Setor Solic'         , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Unidade Sol'         , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Mat.Apr.'            , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Nome Aprov'          , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Setor Aprov'         , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Unid.Aprov.'         , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Data'                , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Hora'                , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Dias Uteis SLA'      , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Filial Solicitação'  , 1 , 3 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Número FAP'          , 1 , 1 )
    oExcel:AddColumn( 'VCVCF' , cNomTab , 'Analista Tratamento' , 1 , 3 )
// -------------------------------
//  [ select para buscar na PA5(indicadores) , certificando que existe na SQS(vagas) ]
// -------------------------------
    cQuery :=   " SELECT PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XDESOL , "
    cQuery +=          " PA5_XUNIDA , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDESEV , "
    cQuery +=          " PA5_FUNCAO , "
    cQuery +=          " PA5_XMAT   , "
    cQuery +=          " PA5_XNOME  , "
    cQuery +=          " PA5_XSETOR , "
    cQuery +=          " PA5_XCARGO , "
    cQuery +=          " PA5_XMATAP , "
    cQuery +=          " PA5_XAPROV , "
    cQuery +=          " PA5_XSEAPV , "
    cQuery +=          " PA5_XUNAPR , "
    cQuery +=          " PA5_XCARAP , "
    cQuery +=          " PA5_XCC    , "
    cQuery +=          " PA5_XCONTA , "
    cQuery +=          " PA5_XSTAT  , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5_XUSER  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
    cQuery +=     " FROM PA5010 PA5 "
    cQuery +=    " WHERE PA5.D_E_L_E_T_       = ' ' "
    cQuery +=      " AND PA5_XCODEV          IN ('002') "
    cQuery +=      " AND PA5_XNRSOL          IN ( SELECT QS_XSOLPTL "
    cQuery +=                                     " FROM SQS010 "
    cQuery +=                                    " WHERE D_E_L_E_T_       = ' ' "
    cQuery +=                                      " AND QS_XSOLFIL BETWEEN '" + PAR01 + "' "
    cQuery +=                                                         " AND '" + PAR02 + "' ) "
    cQuery +=      " AND PA5.PA5_FILIAL BETWEEN '" +       PAR01   + "' "
    cQuery +=                             " AND '" +       PAR02   + "' "
    cQuery +=      " AND PA5_XNRSOL     BETWEEN '" +       PAR03   + "' "
    cQuery +=                             " AND '" +       PAR04   + "' "
    cQuery +=      " AND PA5.PA5_XDATA  BETWEEN '" + dtos( PAR05 ) + "' "
    cQuery +=                             " AND '" + dtos( PAR06 ) + "' "
    cQuery += " ORDER BY PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
// -------------------------------
    if select( 'ARQSV1' ) > 0
        dbselectarea( 'ARQSV1' )
        ARQSV1->( dbclosearea() )
    endif
// -------------------------------
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , 'ARQSV1' , .T. , .T. )
// -------------------------------
    procregua( ARQSV1->( reccount() ))
// -------------------------------
// analisar aqui - gus
    do while ARQSV1->( ! eof() )

        incproc( 'Gerando Planilha com Solicitações do tipo [Vagas Com Codigo de Vagas e Com FAP]! Aguarde...' )
// -------------------------------
        cPA5Xnrsol := ARQSV1->PA5_XNRSOL //         proximo numero da PA5_XNRSOL
        dPA5xdat   := ARQSV1->PA5_XDATA  // data do proximo numero da PA5_XNRSOL
        nDutil     := 0                  // armazena a quantidade de dias uteis menos um dia ( - 1 dia )
        nDifd      := 0                  // armazena a quantidade de dias uteis
// -------------------------------
//      [ verifica na SQS ]
// -------------------------------
        dbselectarea( 'SQS' ) // Vagas
        SQS->( dbsetorder( 5 )) // QS_XSOLPTL
        dbgotop()
// -------------------------------
        if SQS->( dbseek( cPA5Xnrsol )) // verifica se existe na SQS(vagas) , por redundancia

            cQSVaga  := SQS->QS_VAGA
            cQSFilVg := SQS->QS_FILPOST

            dbselectarea( 'PA2' ) // FORMULÁRIO DE APROVAÇÃO PROFIS
            PA2->( dbsetorder( 8 )) // PA2_FILVG + PA2_CDVAGA
            dbgotop()

// ------------------------------------------------------------------
//          [ verifica na PA2(FAP). só segue se existir na PA2. ]
//          [ Essa verificacao eh a mais importante.            ]
// ------------------------------------------------------------------
            if PA2->( dbseek( cQSFilVg + cQSVaga ))

// -------------------------------
// -------------------------------
//              [ select para buscar as datas na PA5(indicadores) ]
// -------------------------------
                cQry :=   " SELECT PA5_FILIAL , "
                cQry +=          " PA5_XNRSOL , "
                cQry +=          " PA5_XDESOL , "
                cQry +=          " PA5_XUNIDA , "
                cQry +=          " PA5_XCODEV , "
                cQry +=          " PA5_XDESEV , "
                cQry +=          " PA5_FUNCAO , "
                cQry +=          " PA5_XMAT   , "
                cQry +=          " PA5_XNOME  , "
                cQry +=          " PA5_XSETOR , "
                cQry +=          " PA5_XCARGO , "
                cQry +=          " PA5_XMATAP , "
                cQry +=          " PA5_XAPROV , "
                cQry +=          " PA5_XSEAPV , "
                cQry +=          " PA5_XUNAPR , "
                cQry +=          " PA5_XCARAP , "
                cQry +=          " PA5_XCC    , "
                cQry +=          " PA5_XCONTA , "
                cQry +=          " PA5_XSTAT  , "
                cQry +=          " PA5_XDATA  , "
                cQry +=          " PA5_XHORA  , "
                cQry +=          " PA5_XUSER  , "
                cQry +=          " PA5.R_E_C_N_O_ "
                cQry +=     " FROM PA5010 PA5 "
                cQry +=    " WHERE PA5.D_E_L_E_T_       = ' ' "
                cQry +=      " AND PA5_XCODEV          IN ('002') "
                cQry +=      " AND PA5_XNRSOL          IN ( SELECT QS_XSOLPTL "
                cQry +=                                     " FROM SQS010 "
                cQry +=                                    " WHERE D_E_L_E_T_ = ' ' "
                cQry +=                                      " AND QS_XSOLFIL = '" + cQSFilVg + "' ) "
//              cQry +=                                      " AND QS_XSOLFIL BETWEEN '" + PAR01 + "' "
//              cQry +=                                                         " AND '" + PAR02 + "' ) "
                cQry +=      " AND PA5.PA5_FILIAL       = '" + cQSFilVg      + "' "
//              cQry +=      " AND PA5.PA5_FILIAL BETWEEN '" +       PAR01   + "' "
//              cQry +=                             " AND '" +       PAR02   + "' "
                cQry +=      " AND PA5_XNRSOL           = '" + cPA5Xnrsol    + "' "
                cQry +=      " AND PA5_XSTAT         LIKE 'FAP (RE)%' "
//              cQry +=      " AND PA5_XNRSOL     BETWEEN '" +       PAR03   + "' "
//              cQry +=                             " AND '" +       PAR04   + "' "
//              cQry +=      " AND PA5.PA5_XDATA  BETWEEN '" + dtos( PAR05 ) + "' "
//              cQry +=                             " AND '" + dtos( PAR06 ) + "' "
                cQry += " ORDER BY PA5_FILIAL , "
                cQry +=          " PA5_XNRSOL , "
                cQry +=          " PA5_XCODEV , "
                cQry +=          " PA5_XDATA  , "
                cQry +=          " PA5_XHORA  , "
                cQry +=          " PA5.R_E_C_N_O_ "
// -------------------------------
                if select( 'ARQSV2' ) > 0
                    dbselectarea( 'ARQSV2' )
                    ARQSV2->( dbclosearea() )
                endif
// -------------------------------
                cQry := changequery( cQry )
                dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQry ) , 'ARQSV2' , .T. , .T. )
// -------------------------------
// -------------------------------

                aNumFap := {}
                do while PA2->PA2_FILVG  == cQSFilVg .AND. ;
                         PA2->PA2_CDVAGA == cQSVaga
                         
                    if ( stod( ARQSV2->PA5_XDATA ) >= PAR05 .AND. ;
                         stod( ARQSV2->PA5_XDATA ) <= PAR06       )

                        aadd( aNumFap , { PA2->PA2_SIT , ;
                                          PA2->PA2_SOL , ;
                                       ARQSV2->PA5_XDATA } ) // guarda os numeros das FAPs no vetor
                                       
                    endif

//                    aadd( aNumFap , { PA2->PA2_SIT , ;
//                                      PA2->PA2_SOL } ) // guarda os numeros das FAPs no vetor
                    PA2->( dbskip() )
                 ARQSV2->( dbskip() )

                enddo

                nContFap := 0
                cPA2SOL  := ' '

// ------------------------------------------------------------------
//              [ verifica se há alçada do codigo da solicitação antes do periodo ]
//              [ informado no pergunte , com objetivo de contagem para o SLA     ]
// ------------------------------------------------------------------
                cQant :=   " SELECT PA5_XDATA "
                cQant +=     " FROM " + retsqlname( 'PA5' ) + " PA5 "
                cQant +=    " WHERE D_E_L_E_T_          = ' ' "
                cQant +=      " AND PA5_XNRSOL          = '" + ARQSV1->PA5_XNRSOL + "' "
                cQant +=      " AND PA5.PA5_XDATA BETWEEN '20160101' "
                cQant +=                            " AND '" + dtos( PAR05 - 1 )  + "' "
                cQant +=      " AND PA5.PA5_FILIAL      = '" + ARQSV1->PA5_FILIAL + "' "
                cQant += " ORDER BY PA5_XDATA DESC "
// -------------------------------
                if select( 'ARQANT' ) > 0
                    dbselectarea( 'ARQANT' )
                    ARQANT->( dbclosearea() )
                endif
// -------------------------------
                cQant := changequery( cQant )
                dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQant ) , 'ARQANT' , .T. , .T. )
// -------------------------------
                if ARQANT->( ! eof() )
                    dPA5xdat := ARQANT->PA5_XDATA
                endif

                ARQANT->( dbclosearea() )

// ------------------------------------------------------------------
//              [ Fim verificação de período anterior para solicitação ]
// ------------------------------------------------------------------


                dbselectarea( 'ARQSV1' )

                do while ARQSV1->PA5_XNRSOL == cPA5Xnrsol

                    if ARQSV1->PA5_XDATA == dPA5xdat
                        nDutil := 0
                    else
                        nDifd  := dateworkday( stod( dPA5xdat) , stod( ARQSV1->PA5_XDATA ))
                        nDutil := nDifd - 1 // armazena a quantidade de dias uteis menos 1 dia
                    endif                   // porque a funcao conta inclusive com o dia da primeira data da comparação

// ------------------------------------------------------------------
//                  [ verifica o status da solicitação para colocar ]
//                  [ na devida coluna , o numero da FAP            ]
// ------------------------------------------------------------------
                    if substr( ARQSV1->PA5_XSTAT , 1 , 8 ) == 'FAP (RE)' .OR. ;
                       substr( ARQSV1->PA5_XSTAT , 1 , 6 ) == 'CONCLU'   .OR. ;
                       substr( ARQSV1->PA5_XSTAT , 1 , 6 ) == 'Conclu'

// -------------------------------
//                      alert(ARQSV1->PA5_XDESOL)
// -------------------------------
						If Len( aNumFap ) > 0 //Thais Paiva - 8771340
							nContFap += 1                   // contador para controlar o uso dos numeros da FAP
							if len( aNumFap ) < nContFap    // se o contador atingiu a quantidade de numeros de FAPs 
								nContFap := nContFap - 1    // usa sempre o ultimo numero de FAP
							endif
							cPA2SOL := aNumFap[nContFap][2] // se nao atingiu usa o numero da FAP seguinte
						Else //Thais Paiva - 8771340
							cPA2SOL := ' ' //Thais Paiva - 8771340
						EndIf //Thais Paiva - 8771340

                    else
                        cPA2SOL := ' ' // coloca o numero da FAP em branco
                    endif

// ------------------------------------------------------------------
//                  [ gera informações para a planilha ]
// ------------------------------------------------------------------
                    cDutil   := cvaltochar( nDutil )
                    cNumSol  :=       ARQSV1->PA5_XNRSOL
                    cDesSol  :=       ARQSV1->PA5_XDESOL
                    cUnid    :=       ARQSV1->PA5_XUNIDA
                    cTipCod  :=       ARQSV1->PA5_XCODEV
                    cDesTip  :=       ARQSV1->PA5_XDESEV
                    cFunc    :=       ARQSV1->PA5_FUNCAO
                    cMat     :=       ARQSV1->PA5_XMAT
                    cNome    :=       ARQSV1->PA5_XNOME
                    cSet     :=       ARQSV1->PA5_XSETOR
                    cCarg    :=       ARQSV1->PA5_XCARGO
                    cMatAp   :=       ARQSV1->PA5_XMATAP
                    cAprov   :=       ARQSV1->PA5_XAPROV
                    cSetApr  :=       ARQSV1->PA5_XSEAPV
                    cUniApr  :=       ARQSV1->PA5_XUNAPR
                    cCarApr  :=       ARQSV1->PA5_XCARAP
                    cStat    :=       ARQSV1->PA5_XSTAT
                    dData    := stod( ARQSV1->PA5_XDATA ) // ARQSV1->(STOD(PA5_XDATA))
                    cHora    :=       ARQSV1->PA5_XHORA
                    cCod     := cPA2SOL
                    cFili    :=       ARQSV1->PA5_FILIAL
                    cUsua    :=       ARQSV1->PA5_XUSER

// ------------------------------------------------------------------
//                  [ alimenta as colunas da planilha ]
// ------------------------------------------------------------------
                    oExcel:AddRow( 'VCVCF' , cNomTab, { cNumSol , ;
                                                        cDesSol , ;
                                                        cTipCod , ;
                                                        cDesTip , ;
                                                        cStat   , ;
                                                        cMat    , ;
                                                        cNome   , ;
                                                        cSet    , ;
                                                        cUnid   , ;
                                                        cCarg   , ;
                                                        cMatAp  , ;
                                                        cAprov  , ;
                                                        cSetApr , ;
                                                        cCarApr , ;
                                                        cUniApr , ;
                                                        dData   , ;
                                                        cHora   , ;
                                                        cDutil  , ;
                                                        cFili   , ;
                                                        cCod    , ;
                                                        cUsua   } )

                    dPA5xdat := ARQSV1->PA5_XDATA

                    ARQSV1->( dbskip() )

                enddo

            else

// ------------------------------------------------------------------
//              [ se nao achar na PA2(FAP), pula para o proximo registro da PA5 ]
// ------------------------------------------------------------------
                dPA5xdat := ARQSV1->PA5_XDATA // pega data atual para comparar com a proxima

                ARQSV1->( dbskip() )

            endif

        else

// ------------------------------------------------------------------
//          [ se nao achar na SQS(vagas) , pula para o proximo registro da PA5 ]
// ------------------------------------------------------------------
            dPA5xdat := ARQSV1->PA5_XDATA // pega data atual para comparar com a proxima

            ARQSV1->( dbskip() )

        endif

    enddo
	
// -------------------------------
//  [ gera planilha ]
// -------------------------------
    oExcel:Activate()
    oExcel:GetXMLFile( cArqXML )
// -------------------------------
    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open( cArqXML )
    oExcelApp:SetVisible( .T. )
    oExcelApp:Destroy()
    oExcelApp := NIL

// ------------------------------------------------------------------
//  [ Fim : VAGAS COM CÓDIGO DE VAGAS E COM FAP ]
// ------------------------------------------------------------------

return
// ------------------------------------------------------------------


// ------------------------------------------------------------------
//  [ Inicio : SOMENTE FAP ]
// ------------------------------------------------------------------
user function relind4( PAR01 , PAR02 , PAR03 , PAR04 , PAR05 , PAR06 , PAR07 )
// -------------------------------
    local cQuery     := ''
    local oExcel     := FWMsExcelEx():New()
    local cArqXML    := alltrim( gettemppath() ) + criatrab( , .F. ) + '.xml'
    local cNomTab    := 'Indicadores (3)'
    local cNomPar    := 'Parametros'
    local oExcelApp
    local cQuery     := ''
    local cFilDoc    := ''
    local cEmissao   := ''
    local cNumDoc    := ''
    local cDtPagam   := ''
    local cCodFor    := ''
    local cDescFor   := ''
    local cCodProd   := ''
    local cDescProd  := ''
    local nDifd      := 0
    local cDCalc     := ''
    local cResult    := ''
    local cPA5Xnrsol := ''
    local nDutil     := 0
    local dPA5xdat
// -------------------------------
    oExcel:AddworkSheet( 'FAP' )
    oExcel:AddTable(     'FAP' , cNomTab )
// -------------------------------
    oExcel:AddColumn( 'FAP' , cNomTab , 'NºSolic'             , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Descricao'           , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'C.Ev.'               , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Evento'              , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Status'              , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Mat.Sol.'            , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Nome Solic'          , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Setor Solic'         , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Unidade Sol'         , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Mat.Apr.'            , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Nome Aprov'          , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Setor Aprov'         , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Cargo'               , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Unid.Aprov.'         , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Data'                , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Hora'                , 1 , 3 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Dias Uteis SLA'      , 1 , 1 )
    oExcel:AddColumn( 'FAP' , cNomTab , 'Filial Solicitação'  , 1 , 3 )
// ------------------------------------------------------------------
//  oExcel:AddColumn( 'FAP' , cNomTab , 'Número FAP'          , 1 , 3 )
// ------------------------------------------------------------------
    oExcel:AddColumn( 'FAP' , cNomTab , 'Analista Tratamento' , 1 , 3 )
// ------------------------------------------------------------------
//  [ select para buscar na PA5(Indicadores) somente FAP ]
// ------------------------------------------------------------------
    cQuery :=   " SELECT PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XDESOL , "
    cQuery +=          " PA5_XUNIDA , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDESEV , "
    cQuery +=          " PA5_FUNCAO , "
    cQuery +=          " PA5_XMAT   , "
    cQuery +=          " PA5_XNOME  , "
    cQuery +=          " PA5_XSETOR , "
    cQuery +=          " PA5_XCARGO , "
    cQuery +=          " PA5_XMATAP , "
    cQuery +=          " PA5_XAPROV , "
    cQuery +=          " PA5_XSEAPV , "
    cQuery +=          " PA5_XUNAPR , "
    cQuery +=          " PA5_XCARAP , "
    cQuery +=          " PA5_XCC    , "
    cQuery +=          " PA5_XCONTA , "
    cQuery +=          " PA5_XSTAT  , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5_XUSER  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
    cQuery +=     " FROM PA5010 PA5 "
    cQuery +=    " WHERE PA5.D_E_L_E_T_       = ' ' "
    cQuery +=      " AND PA5_XCODEV          IN ('004') "
    cQuery +=      " AND PA5_XNRSOL          IN ( SELECT PA2_SOL "
    cQuery +=                                     " FROM PA2010 "
    cQuery +=                                    " WHERE D_E_L_E_T_       = ' ' "
    cQuery +=                                      " AND PA2_FILIAL BETWEEN '" + PAR01 + "' "
    cQuery +=                                                         " AND '" + PAR02 + "' ) "
    cQuery +=      " AND PA5.PA5_FILIAL BETWEEN '" +       PAR01   + "' "
    cQuery +=                             " AND '" +       PAR02   + "' "
    cQuery +=      " AND PA5_XNRSOL     BETWEEN '" +       PAR03   + "' "
    cQuery +=                             " AND '" +       PAR04   + "' "
    cQuery +=      " AND PA5.PA5_XDATA  BETWEEN '" + dtos( PAR05 ) + "' "
    cQuery +=                             " AND '" + dtos( PAR06 ) + "' "
    cQuery += " ORDER BY PA5_FILIAL , "
    cQuery +=          " PA5_XNRSOL , "
    cQuery +=          " PA5_XCODEV , "
    cQuery +=          " PA5_XDATA  , "
    cQuery +=          " PA5_XHORA  , "
    cQuery +=          " PA5.R_E_C_N_O_ "
// -------------------------------
    if select( 'ARQSV1' ) > 0
        dbselectarea( 'ARQSV1' )
        ARQSV1->( dbclosearea() )
    endif
// -------------------------------
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , 'ARQSV1' , .T. , .T. )
// -------------------------------
    procregua( ARQSV1->( reccount() ))

    do while ARQSV1->( ! eof() )

        incproc( 'Gerando Planilha com Solicitações do tipo [ FAP ]! Aguarde...' )

        cPA5Xnrsol := ARQSV1->PA5_XNRSOL // proximo numero da PA5_XNRSOL
        dPA5xdat   := ARQSV1->PA5_XDATA  // data do proximo numero da PA5_XNRSOL
        nDutil     := 0                  // armazena a quantidade de dias uteis - 1 dia
        nDifd      := 0                  // armazena a quantidade de dias uteis

// ------------------------------------------------------------------
//      [ verifica se há alçada do codigo da solicitação antes do periodo ]
//      [ informado no pergunte , com objetivo de contagem para o SLA     ]
// ------------------------------------------------------------------
        cQant :=   " SELECT PA5_XDATA "
        cQant +=     " FROM " + retsqlname( 'PA5' ) + " PA5 "
        cQant +=    " WHERE D_E_L_E_T_          = ' ' "
        cQant +=      " AND PA5_XNRSOL          = '" + ARQSV1->PA5_XNRSOL + "' "
        cQant +=      " AND PA5.PA5_XDATA BETWEEN '20160101' "
        cQant +=                            " AND '" + dtos( PAR05 - 1 )  + "' "
        cQant +=      " AND PA5.PA5_FILIAL      = '" + ARQSV1->PA5_FILIAL + "' "
        cQant += " ORDER BY PA5_XDATA DESC "
// -------------------------------
        if select( 'ARQANT' ) > 0
            dbselectarea( 'ARQANT' )
            ARQANT->( dbclosearea() )
        endif
// -------------------------------
        cQant := changequery( cQant )
        dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQant ) , 'ARQANT' , .T. , .T. )
// -------------------------------
        if ARQANT->( ! eof() )
            dPA5xdat := ARQANT->PA5_XDATA
        endif

        ARQANT->( dbclosearea() )

// ------------------------------------------------------------------
//      [ Fim verificação de período anterior para solicitção ]
// ------------------------------------------------------------------


        dbselectarea( 'ARQSV1' )

        do while ARQSV1->PA5_XNRSOL == cPA5Xnrsol

            if ARQSV1->PA5_XDATA == dPA5xdat
                nDutil := 0
            else
                nDifd  := dateworkday( stod( dPA5xdat ) , stod( ARQSV1->PA5_XDATA ))
                nDutil := nDifd - 1 // armazena a quantidade de dias uteis menos 1 dia
            endif                   // porque a funcao conta inclusive com o dia da primeira data da comparação
// -------------------------------
            cDutil  := cvaltochar( nDutil )
            cNumSol :=       ARQSV1->PA5_XNRSOL
            cDesSol :=       ARQSV1->PA5_XDESOL
            cUnid   :=       ARQSV1->PA5_XUNIDA
            cTipCod :=       ARQSV1->PA5_XCODEV
            cDesTip :=       ARQSV1->PA5_XDESEV
            cFunc   :=       ARQSV1->PA5_FUNCAO
            cMat    :=       ARQSV1->PA5_XMAT
            cNome   :=       ARQSV1->PA5_XNOME
            cSet    :=       ARQSV1->PA5_XSETOR
            cCarg   :=       ARQSV1->PA5_XCARGO
            cMatAp  :=       ARQSV1->PA5_XMATAP
            cAprov  :=       ARQSV1->PA5_XAPROV
            cSetApr :=       ARQSV1->PA5_XSEAPV
            cUniApr :=       ARQSV1->PA5_XUNAPR
            cCarApr :=       ARQSV1->PA5_XCARAP
            cStat   :=       ARQSV1->PA5_XSTAT
            dData   := stod( ARQSV1->PA5_XDATA ) // ARQSV1->(STOD(PA5_XDATA))
            cHora   :=       ARQSV1->PA5_XHORA
            cCod    := ' '                       // ARQSV1->PA2_SOL
            cFili   :=       ARQSV1->PA5_FILIAL
            cUsua   :=       ARQSV1->PA5_XUSER
// -------------------------------
            oExcel:AddRow( 'FAP' , cNomTab , { cNumSol , ;
                                               cDesSol , ;
                                               cTipCod , ;
                                               cDesTip , ;
                                               cStat   , ;
                                               cMat    , ;
                                               cNome   , ;
                                               cSet    , ;
                                               cUnid   , ;
                                               cCarg   , ;
                                               cMatAp  , ;
                                               cAprov  , ;
                                               cSetApr , ;
                                               cCarApr , ;
                                               cUniApr , ;
                                               dData   , ;
                                               cHora   , ;
                                               cDutil  , ;
                                               cFili   , ;
                                               cUsua   } )
// ------------------------------------------------------------------
//                                             cCod    , ;
// ------------------------------------------------------------------

            dPA5xdat := ARQSV1->PA5_XDATA

            ARQSV1->( dbskip() )

        enddo

    enddo

// -------------------------------
    oExcel:Activate()
    oExcel:GetXMLFile( cArqXML )
// -------------------------------
    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open( cArqXML )
    oExcelApp:SetVisible( .T. )
    oExcelApp:Destroy()
    oExcelApp := NIL

return

// ------------------------------------------------------------------
// [ fim de f0500204.prw ]
// ------------------------------------------------------------------


// ------------------------------------------------------------------
///*
////#INCLUDE 'Protheus.ch'
//
////{Protheus.doc} F0500204
////Relatório de Solicitações dos Indicadores
////@author Fernando Carvalho
////@since 07/11/2016
////@version 12.7
////@project MAN0000007423039_EF_002
//// /*/
///*
//user function F0500204()
//	local oReport
//	local oSection
//	local lLandscape := .T. //-Aponta a orientação de página do relatório como paisagem
//	
//	if Pergunte("FSW0500204",.t.)
//		
//		oReport := TReport():New("F0500204","Relatorio de Indicadores de Monitoramento","FSW0500204",{|oReport| PrintReport(oReport)},;
//				"Este relatorio ira imprimir os Indicadores de Monitoramento.",lLandscape)
//		
//		oSection1 := TRSection():New(oReport,"Indicadores",{"PA5"})
//		TRCell():New(oSection1,"PA5_XNRSOL"	,"PA5" 	, "NºSolic"		, PesqPict("PA5","PA5_XNRSOL")  	,05,,,,,)
//		TRCell():New(oSection1,"PA5_XDESOL"	,"PA5" 	, "Descricao"		, PesqPict("PA5","PA5_XDESOL")  	,15,,,,,)
//		TRCell():New(oSection1,"PA5_XCODEV"	,"PA5" 	, "C.Ev."			, PesqPict("PA5","PA5_XCODEV")  	,05,,,,,)
//		TRCell():New(oSection1,"PA5_XDESEV"	,"PA5" 	, "Evento"		, PesqPict("PA5","PA5_XDESEV")  	,15,,,,,)
//		TRCell():New(oSection1,"PA5_XSTAT"		,"PA5" 	, "Status"		, PesqPict("PA5","PA5_XSTAT")  		,20,,,,,)
//		TRCell():New(oSection1,"PA5_XMAT"		,"PA5" 	, "Mat.Sol."		, PesqPict("PA5","PA5_XMAT")  		,05,,,,,)
//		TRCell():New(oSection1,"PA5_XNOME"		,"PA5" 	, "Nome Solic"		, PesqPict("PA5","PA5_XNOME")  		,15,,,,,)
//		TRCell():New(oSection1,"PA5_XSETOR"	,"PA5" 	, "Setor Solic"	, PesqPict("PA5","PA5_XSETOR")  	,20,,,,,)
//		TRCell():New(oSection1,"PA5_XUNIDA"	,"PA5" 	, "Unidade Sol"	, PesqPict("PA5","PA5_XUNIDA")  	,06,,,,,)
//		TRCell():New(oSection1,"PA5_XCARGO"	,"PA5" 	, "Cargo"			, PesqPict("PA5","PA5_XCARGO")  	,20,,,,,)
//		TRCell():New(oSection1,"PA5_XMATAP"	,"PA5" 	, "Mat.Apr."		, PesqPict("PA5","PA5_XMATAP")  	,05,,,,,)
//		TRCell():New(oSection1,"PA5_XAPROV"	,"PA5" 	, "Nome Aprov"		, PesqPict("PA5","PA5_XAPROV")  	,20,,,,,)
//		TRCell():New(oSection1,"PA5_XSEAPV"	,"PA5" 	, "Setor Aprov"	, PesqPict("PA5","PA5_XSEAPV")  	,20,,,,,)
//		TRCell():New(oSection1,"PA5_XCARAP"	,"PA5" 	, "Cargo"			, PesqPict("PA5","PA5_XCARAP")  	,20,,,,,)
//		TRCell():New(oSection1,"PA5_XUNAPR"	,"PA5" 	, "Unid.Aprov."	, PesqPict("PA5","PA5_XUNAPR")  	,08,,,,,)
//		TRCell():New(oSection1,"PA5_XDATA"		,"PA5" 	, "Data"			, PesqPict("PA5","PA5_XDATA")  		,10,,,,,)
//		TRCell():New(oSection1,"PA5_XHORA"		,"PA5" 	, "Hora"			, PesqPict("PA5","PA5_XHORA")  		,05,,,,,)
//		
//		oReport:SetLandscape()
//		oReport:PrintDialog()
//	endif
//Return
//
//{Protheus.doc} F0500204
////Relatório de Solicitações dos Indicadores
////@author Fernando Carvalho
////@since 07/11/2016
////@version 12.7
////@project MAN0000007423039_EF_002
//
//Static function PrintReport(oReport)
//	
//	local cWhere := ""
//	
//	#ifDEF TOP
//		cAlias := GetNextAlias()
//		MakeSqlExp("FSW0500204")
//		
//		cWhere := "%"
//		if !(EMPTY(MV_PAR01))
//			cWhere += " AND PA5.PA5_FILIAL >= '" + MV_PAR01 + "' "
//		endif
//		if !(EMPTY(MV_PAR02))
//			cWhere += " AND PA5.PA5_FILIAL <= '" + MV_PAR02 + "' "
//		endif
//		if !(EMPTY(MV_PAR03))
//			cWhere += " AND PA5.PA5_XNRSOL >= '" + MV_PAR03 + "' "
//		endif
//		if !(EMPTY(MV_PAR04))
//			cWhere += " AND PA5.PA5_XNRSOL <= '" + MV_PAR04 + "' "
//		endif
//		if !(EMPTY(MV_PAR05)) .AND. !(EMPTY(MV_PAR06))
//			cWhere += " AND PA5.PA5_XDATA BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
//		endif
//		if !(EMPTY(MV_PAR05)) .AND. EMPTY(MV_PAR06)
//			cWhere += " AND PA5.PA5_XDATA >= '" + MV_PAR05 + "' "
//		endif
//		if !(EMPTY(MV_PAR06)) .AND. EMPTY(MV_PAR05)
//			cWhere += " AND PA5.PA5_XDATA <= '" + MV_PAR06 + "' "
//		endif
//		if !(EMPTY(MV_PAR07))
//			cWhere += " AND PA5.PA5_XCODEV = '" + MV_PAR07 + "' "
//		endif
//		cWhere += "%"
//		
//		BEGIN REPORT QUERY oReport:Section(1)
//			
//			BeginSql alias cAlias
//				SELECT
//				PA5.PA5_FILIAL
//				,PA5.PA5_XNRSOL
//				,PA5.PA5_XDESOL
//				,PA5.PA5_XUNIDA
//				,PA5.PA5_XCODEV
//				,PA5.PA5_XDESEV
//				,PA5.PA5_FUNCAO
//				,PA5.PA5_XMAT
//				,PA5.PA5_XNOME
//				,PA5.PA5_XSETOR
//				,PA5.PA5_XCARGO
//				,PA5.PA5_XMATAP
//				,PA5.PA5_XAPROV
//				,PA5.PA5_XSEAPV
//				,PA5.PA5_XUNAPR
//				,PA5.PA5_XCARAP
//				,PA5.PA5_XCC
//				,PA5.PA5_XCONTA
//				,PA5.PA5_XSTAT
//				,PA5.PA5_XDATA
//				,PA5.PA5_XHORA
//				
//				FROM
//				%table:PA5% PA5
//				WHERE PA5.%notdel%
//				%exp:cWhere%
//				ORDER BY
//				PA5.PA5_XNRSOL, PA5.PA5_XDATA, PA5.PA5_XHORA, PA5.R_E_C_N_O_
//			EndSql
//			
//		END REPORT QUERY oReport:Section(1)
//		
//		oReport:Section(1):Print(.F.)
//	#endif
//Return
//*/
//
// ------------------------------------------------------------------
