#INCLUDE 'PROTHEUS.CH'
#INCLUDE   'REPORT.CH'
#INCLUDE  'TBICONN.CH'
#INCLUDE  'TOPCONN.CH'
#INCLUDE   'FILEIO.CH'

user function teleg005()

//--------------------------------
    local   oReport
//--------------------------------
    private cPerg     := 'TELEG005' 
    private nRecTMP   := 0
    private cAliasTmp := getnextalias()
    private cQry      := ''
    private aOrdem    := {}
    private aTabelas  := { 'ZZZ' , 'TM0' }
//--------------------------------
    if !pergunte( 'TELEG005' , .T. )
	    return
    endif
//--------------------------------
//  [ Interface de Impressão ]
//--------------------------------
    oReport:= ReportDef( 'TELEG005' )
    oReport:PrintDialog()

    if select( cAliasTmp ) > 0
       dbselectarea( cAliasTmp )
      ( cAliasTmp )->( dbclosearea() )
    endif

return


// ------------------------------------------------------------------
// [ ReportDef ]
// ------------------------------------------------------------------
static function ReportDef( cPerg )

// -------------------------------
    local   oCell
    local   oBreak
// -------------------------------
    private oReport
    private cTitulo := 'Relatório de Telegrama'
// -------------------------------

//+-----------------------------------------------------------------------------+
//| Criacao do componente de impressao                                          |
//+-----------------------------------------------------------------------------+
//| TReport():New                                                               |
//| ExpC1 : Nome do relatorio                                                   |
//| ExpC2 : Titulo                                                              |
//| ExpC3 : Pergunte                                                            |
//| ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao      |
//| ExpC5 : Descricao                                                           |
//+-----------------------------------------------------------------------------+

//  oReport:SayBitmap ( 360, 30 ,"C:\A\REDEDOR.BMP", 1800, 1200)
    oReport:= TReport():New( 'TELEG005' , cTitulo , 'TELEG005' , { |oReport| ReportPrint(oReport) } , cTitulo )
    oReport:SetPortrait()
    oReport:SetTotalInLine(.F.)

    oSection1 := TRSection():New( oReport , 'Seção 1' , aTabelas , aOrdem )

    TRCell():New( oSection1 , 'ZZZ_FILIAL' , cAliasTmp , 'FILIAL'       , PesqPict( 'ZZZ' , 'ZZZ_FILIAL' ) , tamsx3( 'ZZZ_FILIAL' )[1] + 05 , )
    TRCell():New( oSection1 , 'ZZZ_FICHA'  , cAliasTmp , 'FICHA MEDICA' , PesqPict( 'ZZZ' , 'ZZZ_FICHA'  ) , tamsx3( 'ZZZ_FICHA'  )[1] + 05 , )
    TRCell():New( oSection1 , 'ZZZ_COD'    , cAliasTmp , 'CODIGO'       , PesqPict( 'ZZZ' , 'ZZZ_COD'    ) , tamsx3( 'ZZZ_FICHA'  )[1] + 05 , )
    TRCell():New( oSection1 , 'TM0_MAT'    , cAliasTmp , 'MATRICULA'    , PesqPict( 'TM0' , 'TM0_MAT'    ) , tamsx3( 'TM0_MAT'    )[1] + 05 , )
    TRCell():New( oSection1 , 'TM0_NOMFIC' , cAliasTmp , 'NOME'         , PesqPict( 'TM0' , 'TM0_NOMFIC' ) , tamsx3( 'TM0_NOMFIC' )[1] + 05 , )
    TRCell():New( oSection1 , 'ZZZ_DATA'   , cAliasTmp , 'DATA ENVIO'   , PesqPict( 'ZZZ' , 'ZZZ_DATA'   ) , tamsx3( 'ZZZ_DATA'   )[1] + 05 , )
    TRCell():New( oSection1 , 'ZZZ_HIST'   , cAliasTmp , 'HISTORICO'    , PesqPict( 'ZZZ' , 'ZZZ_HIST'   ) , tamsx3( 'ZZZ_HIST'   )[1]      , )

    oSection1:SetPageBreak( .T. )

return( oReport )

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Inicializa ReportPrint                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
static function reportprint( oReport )

// -------------------------------
    local oSection1  := oReport:Section( 1 )
    local cStartPath := GetSrvProfString( 'Startpath' , '' )
// -------------------------------
    local cFilAux    := ''
    local cFicAux    := ''
    local cTotal     := ''
    local nTotal     := 0
// -------------------------------
    teleg006()

    oSection1:Init()

    dbselectarea( cAliasTmp )
    dbgotop()

    cFilAux := (cAliasTmp)->ZZZ_FILIAL
    cFicAux := (cAliasTmp)->ZZZ_FICHA
    
    if nRecTMP > 0

        do while (cAliasTmp)->( !eof() )
        
            nTotal := nTotal + 1

// ---------[ Impressao do Relatorio ]------
            if oReport:Cancel()
		        exit
            endif

            oSection1:Cell( 'ZZZ_FILIAL' ):SetValue(       (cAliasTmp)->ZZZ_FILIAL   )
            oSection1:Cell( 'ZZZ_FICHA'  ):SetValue(       (cAliasTmp)->ZZZ_FICHA    )
            oSection1:Cell( 'ZZZ_COD'    ):SetValue(       (cAliasTmp)->ZZZ_COD      )
            oSection1:Cell( 'TM0_MAT'    ):SetValue(       (cAliasTmp)->TM0_MAT      )
            oSection1:Cell( 'TM0_NOMFIC' ):SetValue(       (cAliasTmp)->TM0_NOMFIC   )
            oSection1:Cell( 'ZZZ_DATA'   ):SetValue( stod( (cAliasTmp)->ZZZ_DATA   ) )
            oSection1:Cell( 'ZZZ_HIST'   ):SetValue(       (cAliasTmp)->ZZZ_HIST     )
            oSection1:PrintLine()

	        ( cAliasTmp )->( dbskip() )
	        
	        if ( (cAliasTmp)->ZZZ_FILIAL + (cAliasTmp)->ZZZ_FICHA ) <> ;
               (  cFilAux                +  cFicAux               )
               
                cTotal := 'Total : ' + transform( nTotal , '@E 999,999' )
               
                oSection1:Cell( 'ZZZ_FILIAL' ):SetValue( '' )
                oSection1:Cell( 'ZZZ_FICHA'  ):SetValue( '' )
                oSection1:Cell( 'ZZZ_COD'    ):SetValue( '' )
                oSection1:Cell( 'TM0_MAT'    ):SetValue( '' )
                oSection1:Cell( 'TM0_NOMFIC' ):SetValue( '' ) 
                oSection1:Cell( 'ZZZ_DATA'   ):SetValue( '' )
                oSection1:Cell( 'ZZZ_HIST'   ):SetValue( '' )
                oSection1:PrintLine()

                oSection1:Cell( 'ZZZ_FILIAL' ):SetValue( '' )
                oSection1:Cell( 'ZZZ_FICHA'  ):SetValue( '' )
                oSection1:Cell( 'ZZZ_COD'    ):SetValue( '' )
                oSection1:Cell( 'TM0_MAT'    ):SetValue( '' )
                oSection1:Cell( 'TM0_NOMFIC' ):SetValue( cTotal ) 
                oSection1:Cell( 'ZZZ_DATA'   ):SetValue( '' )
                oSection1:Cell( 'ZZZ_HIST'   ):SetValue( '' )
                oSection1:PrintLine()

                cFilAux := (cAliasTmp)->ZZZ_FILIAL
                cFicAux := (cAliasTmp)->ZZZ_FICHA
                nTotal  := 0
                
                oReport:FAtLine()
                
                if ( cAliasTmp )->( !eof() )
                    oSection1:Cell( 'ZZZ_FILIAL' ):SetValue( '' )
                    oSection1:Cell( 'ZZZ_FICHA'  ):SetValue( '' )
                    oSection1:Cell( 'ZZZ_COD'    ):SetValue( '' )
                    oSection1:Cell( 'TM0_MAT'    ):SetValue( '' )
                    oSection1:Cell( 'TM0_NOMFIC' ):SetValue( '' ) 
                    oSection1:Cell( 'ZZZ_DATA'   ):SetValue( '' )
                    oSection1:Cell( 'ZZZ_HIST'   ):SetValue( '' )
                    oSection1:PrintLine()
                    oSection1:Cell( 'ZZZ_FILIAL' ):SetValue( 'FILIAL'       )
                    oSection1:Cell( 'ZZZ_FICHA'  ):SetValue( 'FICHA MEDICA' )
                    oSection1:Cell( 'ZZZ_COD'    ):SetValue( 'CODIGO'       )
                    oSection1:Cell( 'TM0_MAT'    ):SetValue( 'MATRICULA'    )
                    oSection1:Cell( 'TM0_NOMFIC' ):SetValue( 'NOME'         ) 
                    oSection1:Cell( 'ZZZ_DATA'   ):SetValue( 'DATA ENVIO'   )
                    oSection1:Cell( 'ZZZ_HIST'   ):SetValue( 'HISTORICO'    )
                    oSection1:PrintLine()
                    oReport:ThinLine()
                endif

	        endif
	        
       enddo

    endif
    
    oSection1:Cell( 'ZZZ_FILIAL' ):SetValue( '' )
    oSection1:Cell( 'ZZZ_FICHA'  ):SetValue( '' )
    oSection1:Cell( 'ZZZ_COD'    ):SetValue( '' )
    oSection1:Cell( 'TM0_MAT'    ):SetValue( '' )
    oSection1:Cell( 'TM0_NOMFIC' ):SetValue( '' )
    oSection1:Cell( 'ZZZ_DATA'   ):SetValue( '' )
    oSection1:Cell( 'ZZZ_HIST'   ):SetValue( '' )

//  oReport:ThinLine()
    oReport:FatLine()
    oReport:IncMeter()
    oSection1:PrintLine()
    oSection1:Finish()
    oSection1:PageBreak()

return( NIL )

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Registros para Tabela Temporaria                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
static function teleg006()

// -------------------------------
//    local x          := 0
//    local cCrLf      := chr(13) + chr(10)
//    local cSitQuery  := ''
//    local cSituacao  := strtran( MV_Par05 , "*" , "" )
//    local cCatQuery  := ''
//    local cCategoria := strtran( MV_Par06 , "*" , "" )
// -------------------------------

    cQry := ""
    cQry += "   SELECT ZZZ_FILIAL , "
    cQry += "          ZZZ_FICHA  , "
    cQry += "          ZZZ_COD    , "
    cQry += "          TM0_MAT    , "
    cQry += "          TM0_NOMFIC , "
    cQry += "          ZZZ_DATA   , "
    cQry += "          ZZZ_HRENV  , "
    cQry += "          ZZZ_MOTENV , "
    cQry += "          ZZZ_DTRET  , "
    cQry += "          ZZZ_INFRET , "
    cQry += "          UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ZZZ_HIST, 2000, 1)) AS ZZZ_HIST "
    cQry += "     FROM " + retsqlname( 'ZZZ' ) + " ZZZ, "
    cQry +=                retsqlname( 'TM0' ) + " TM0  "
    cQry += "    WHERE ZZZ.D_E_L_E_T_ <> '*' "
    cQry += "      AND ZZZ_FILIAL     >= '" + MV_PAR01 + "' "
    cQry += "      AND ZZZ_FILIAL     <= '" + MV_PAR02 + "' "
    cQry += "      AND ZZZ_FICHA      >= '" + MV_PAR03 + "' "
    cQry += "      AND ZZZ_FICHA      <= '" + MV_PAR04 + "' "
    cQry += "      AND TM0.D_E_L_E_T_ <> '*' "
    cQry += "      AND TM0_FILIAL      = ZZZ.ZZZ_FILIAL "
    cQry += "      AND TM0_NUMFIC      = ZZZ.ZZZ_FICHA  "
    cQry += " ORDER BY ZZZ_FILIAL , "
    cQry += "          ZZZ_FICHA  , "
    cQry += "          ZZZ_COD      "
    cQry := changequery( cQry )
//  alert( cQry )
// -------------------------------
    if select( cAliasTmp ) > 0
        dbselectarea( cAliasTmp )
       ( cAliasTmp )->( dbclosearea() )
    endif
// -------------------------------  
    dbusearea( .T. , 'TOPCONN' , TCGENQRY( , , cQry ) , cAliasTmp , .F. , .T. )
    dbselectarea( cAliasTmp )
    if eof()
        alert( 'vazio' )
    else
        ( cAliasTmp )->( dbgotop() )
        count To nRecTMP
    endif

return

// -----------------------------------------------------------------------
// [ fim de teleg005.prw ]
// -----------------------------------------------------------------------

