#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} F0101003()
Relatório de títulos recusados no sistema.
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@Menu		Financeiro\Relatórios REDEDOR\Titulos Recusados    
*/
User Function F0101003()

	Local oReport
	Private cAlQry := GetNextAlias()
	
//-----------------------------------------------------------------------------
//--[ id 1522 ]----------------------------------------------------------------
    private dDtPriRec := ctod( space( 10 )) // id 1522
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

	oReport := ReportDef()
	oReport:PrintDialog()
	
Return
 
// ----------------------------------------------------------------------------
/*
{Protheus.doc} ReportDef()
Auxiliar Relatório de títulos recusados no sistema.
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@Return		oReport, objeto TReport
*/
Static function ReportDef()

	Local oReport
	Local oSection1
	Local cTitulo := '[F0101003] - Impressão de Documentos Recusados'
	
    if !pergunte( 'FSW0101003' , .T. )
		Return
	Endif

    oReport := TReport():New( 'F0101003' , cTitulo , , { |oReport| PrintReport( oReport ) } , 'Este relatório irá imprimir os documentos recusados.' )

	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
 	
    oSection1 := TRSection():New( oReport , 'Filial' , { 'QRY' } )
	oSection1:SetTotalInLine(.F.)

//--[ Novo ]-------------------------------------
    TRCell():new( oSection1 , 'P00_FILIAL' , cAlQry , RetTitle( 'P00_FILIAL' ) , PesqPict( 'P00' , 'P00_FILIAL' ) , 010 , .F. , )
    TRCell():new( oSection1 , 'P00_FORNEC' , cAlQry , RetTitle( 'P00_FORNEC' ) , PesqPict( 'P00' , 'P00_FORNEC' ) , 010 , .F. , )
    TRCell():new( oSection1 , 'P00_LOJAF'  , cAlQry , RetTitle( 'P00_LOJAF'  ) , PesqPict( 'P00' , 'P00_LOJAF'  ) , 010 , .F. , )
//--[ Fim Novo ]---------------------------------

//--[ 1449 - Data Primeira Recusa ]--------------
//  TRCell():new( oSection1 , 'E2_XDTRECP' , cAlQry , RetTitle( 'E2_XDTRECP' ) , PesqPict( 'P00' , 'E2_XDTRECP' ) , 010 , .F. , )
//-----------------------------------------------
    TRCell():new( oSection1 , 'E2_XDTRECP' , cAlQry , RetTitle( 'E2_XDTRECP' ) ,                                  , 010 , .F. , )
    TRCell():new( oSection1 , 'P00_DTRECU' , cAlQry , 'Data Ult.Recusa'        , PesqPict( 'P00' , 'P00_DTRECU' ) , 010 , .F. , )
    TRCell():new( oSection1 , 'QTDEREC'    , cAlQry , 'Qtde Recusas'           , '99'                             , 010 , .F. , )
//--[ Fim 1449 ]---------------------------------
//	TRCell():new( oSection1 , 'P00_DTRECU' , cAlQry , RetTitle( 'P00_DTRECU' ) , PesqPict( 'P00' , 'P00_DTRECU' ) , 010 , .F. , )
//-----------------------------------------------
    TRCell():new( oSection1 , 'P00_NUM'    , cAlQry , RetTitle( 'P00_NUM'    ) , PesqPict( 'P00' , 'P00_NUM'    ) , 010 , .F. , )
    TRCell():new( oSection1 , 'P00_USRREC' , cAlQry , RetTitle( 'P00_USRREC' ) ,                                  ,     , .F. , )
    TRCell():new( oSection1 , 'P00MOTIVO'  , cAlQry , RetTitle( 'P00_MOTIVO' ) ,                                  , 090 , .F. , )
    TRCell():new( oSection1 , 'P00_TIPO'   , cAlQry , RetTitle( 'P00_TIPO'   ) ,                                  , 010 , .F. , )
    TRCell():new( oSection1 , 'E2_XSTRECU' , cAlQry , 'STATUS'                 ,                                  , 010 , .F. , )
    TRCell():new( oSection1 , 'E2_XTPREQ'  , cAlQry , 'Solicitante'            ,                                  , 010 , .F. , )

//-----------------------------------------------
//	oBreak := TRBreak():New(oSection1,oSection1:Cell("P00_DTRECU"), 'Total dia', .F.)//"Total dia") 
//  TRFunction():New(oSection1:Cell("P00_DTRECU"), , "COUNT", oBreak,,,, .F., .F.) 
//-----------------------------------------------

Return oReport
 
// ----------------------------------------------------------------------------
/*
{Protheus.doc} ReportDef()
Auxiliar de Impressão Relatório de títulos recusados no sistema.
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@Param		oReport, objeto TReport
*/
Static Function PrintReport(oReport)

	Local oSection1	:= oReport:Section(1)
    local cQuery    := ''
	Local cSGBD		:= TcGetDB()

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	cQuery := " SELECT	P00_DTRECU , "
	cQuery += "			P00_FILIAL , "
	cQuery += "			P00_NUM    , "
	cQuery += "			P00_PREFIX , "
	cQuery += "			P00_VALOR  , "
	cQuery += "			P00_USRREC , "
	cQuery += "			P00_TIPO   , "

	cQuery += "			P00_FORNEC , "
	cQuery += "			P00_LOJAF  , "

	cQuery += "			CASE WHEN F1_XSTRECU <> '' THEN F1_XSTRECU ELSE E2_XSTRECU END E2_XSTRECU,  "
// ---------------------------------------------------
//	cQuery += "			CASE WHEN NVL(F1_XDTRECP,0)<>0 F1_XDTRECP THEN WHEN NVL(E2_XDTRECP,0) THEN E2_XDTRECP ELSE E2_XDTRECP END E2_XDTRECP,  "
// ---------------------------------------------------
	cQuery += "			E2_XDTRECP ,  "
	cQuery += "			F1_XDTRECP ,  "
	cQuery += "			E2_XTPREQ  ,  "
	cQuery += "			P00_USREMI ,  "
    cQuery += "      ( SELECT COUNT(*) "
    cQuery += "          FROM " + retsqlname( 'P00' ) + " P00A   "
    cQuery += "         WHERE P00A.P00_FILIAL = P00.P00_FILIAL   "
    cQuery += "           AND P00A.P00_PREFIX = P00.P00_PREFIX   "
    cQuery += "           AND P00A.P00_NUM    = P00.P00_NUM      "
    cQuery += "           AND P00A.P00_FORNEC = P00.P00_FORNEC   "
    cQuery += "           AND P00A.P00_LOJAF  = P00.P00_LOJAF    "
    cQuery += "           AND P00A.D_E_L_E_T_ = ' '  ) QTDEREC , "

	If AllTrim(cSGBD) == 'MSSQL'
		cQuery += " ISNULL(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), P00_MOTIVO)), '') AS P00MOTIVO "
	ElseIf AllTrim(cSGBD) == 'ORACLE'
        //Alteração efetuada para correção ticket #11509713 - Ronaldo Carvalho
		//cQuery += "	utl_raw.cast_to_varchar2(P00_MOTIVO) AS P00MOTIVO  "
        cQuery += "    UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(p00_motivo, 2000, 1)) AS P00MOTIVO  "                             
	EndIf

    cQuery += "      FROM " + retsqlname( 'P00' ) + " P00  "

    cQuery += " LEFT JOIN " + retsqlname( 'SE2' ) + " SE2  "
    cQuery += "        ON SE2.E2_FILIAL   = P00.P00_FILIAL "
    cQuery += "       AND SE2.E2_PREFIXO  = P00.P00_PREFIX "
    cQuery += "       AND SE2.E2_NUM      = P00.P00_NUM    "
    cQuery += "       AND SE2.E2_FORNECE  = P00.P00_FORNEC "
    cQuery += "       AND SE2.E2_LOJA     = P00.P00_LOJAF  "
    cQuery += "       AND SE2.D_E_L_E_T_  = ' ' "

    cQuery += " LEFT JOIN " + retsqlname( 'SF1' ) + " SF1  "
    cQuery += "        ON SF1.F1_FILIAL   = P00.P00_FILIAL "
    cQuery += "       AND SF1.F1_SERIE    = P00.P00_PREFIX "
    cQuery += "       AND SF1.F1_DOC      = P00.P00_NUM    "
    cQuery += "       AND SF1.F1_FORNECE  = P00.P00_FORNEC "
    cQuery += "       AND SF1.F1_LOJA     = P00.P00_LOJAF  "
    cQuery += "       AND SF1.D_E_L_E_T_  = ' ' "

    cQuery += "     WHERE P00.D_E_L_E_T_  = ''  "
    cQuery += "       AND P00.P00_FILIAL >= '" + alltrim( MV_PAR01 ) + "' "
    cQuery += "       AND P00.P00_FILIAL <= '" + alltrim( MV_PAR02 ) + "' "
    cQuery += "       AND P00.P00_DTRECU >= '" +    dtos( MV_PAR03 ) + "' "
    cQuery += "       AND P00.P00_DTRECU <= '" +    dtos( MV_PAR04 ) + "' "
    cQuery += "       AND P00.P00_PREFIX >= '" + alltrim( MV_PAR05 ) + "' "
    cQuery += "       AND P00.P00_PREFIX <= '" + alltrim( MV_PAR07 ) + "' "
    cQuery += "       AND P00.P00_NUM    >= '" + alltrim( MV_PAR06 ) + "' "
    cQuery += "       AND P00.P00_NUM    <= '" + alltrim( MV_PAR08 ) + "' "

	If MV_PAR09 == 1
		cQuery += " AND P00.P00_TIPO = 'D'"
	ElseIf MV_PAR09 == 2
		cQuery += " AND P00.P00_TIPO = ' '"
	EndIf
	
	cQuery += " ORDER BY P00_DTRECU, P00_NUM, P00_PREFIX, P00.R_E_C_N_O_ "	

	cQuery := ChangeQuery(cQuery)
    DbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAlQry , .F. , .T. )

	(cAlQry)->(dbGoTop())
 
	If (cAlQry)->(EOF())
        help( '' , 1 , 'Sem Dados' , , 'Não foi possível localizar dados correspondentes a essa pesquisa' , 1 , 0 )
	Else
		oReport:SetMeter(0)

		Do While (cAlQry)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
	 
			oReport:IncMeter()
			
            oSection1:Cell( 'P00_DTRECU' ):SetValue( stod( ( cAlQry )->P00_DTRECU ))
            oSection1:Cell( 'P00_DTRECU' ):SetAlign( 'CENTER' )
			
//          oSection1:Cell( 'P00_USRREC' ):SetValue( usrretname( ( cAlQry )->P00_USRREC     ))
            oSection1:Cell( 'P00_USRREC' ):SetValue(   fNomRecu( ( cAlQry )->P00_USRREC , 1 ))
            oSection1:Cell( 'P00_USRREC' ):SetAlign( 'CENTER' )

// --------------------------------------------------------------------------------------
// ---------[ ID 1522 ] -----------------------------------------------------------------
//            if !empty( ( cAlQry )->F1_XDTRECP )
//                oSection1:Cell( 'E2_XDTRECP' ):SetValue( stod( ( cAlQry )->F1_XDTRECP ))
//            else
//                oSection1:Cell( 'E2_XDTRECP' ):SetValue( stod( ( cAlQry )->E2_XDTRECP ))
//            endif
// --------------------------------------------------------------------------------------
            dDtPriRec := u_fdtprirec()
            oSection1:Cell( 'E2_XDTRECP' ):SetValue( dDtPriRec )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

            oSection1:Cell( 'P00MOTIVO' ):SetValue( ( cAlQry )->P00MOTIVO )
            oSection1:Cell( 'P00MOTIVO' ):SetAlign( 'LEFT' )

            if alltrim( ( cAlQry )->P00_TIPO ) == 'D'
//              oSection1:Cell( 'P00_TIPO' ):SetValue( 'Nota Fiscal'    )
                oSection1:Cell( 'P00_TIPO' ):SetValue( 'DOC ENTRADA'    )
			ELSE
//              oSection1:Cell( 'P00_TIPO' ):SetValue( 'Título'         )
                oSection1:Cell( 'P00_TIPO' ):SetValue( 'CONTAS A PAGAR' )
			ENDIF	
            oSection1:Cell( 'P00_TIPO' ):SetAlign( 'LEFT' )

// --------------------------------------------------------------------------------------
// ---------[ ID 1522 ] -----------------------------------------------------------------
//            if empty( ( cAlQry )->E2_XTPREQ )
////              oSection1:Cell( 'P00_USRREC' ):SetValue(           ( cAlQry )->P00_DUSEMI )
//                oSection1:Cell( 'E2_XTPREQ'  ):SetValue( fNomRecu( ( cAlQry )->P00_USREMI , 1 ))
//            else
//                oSection1:Cell( 'E2_XTPREQ'  ):SetValue( fNomRecu( ( cAlQry )->P00_USRREC , 1 ))
//            endif
// --------------------------------------------------------------------------------------
            oSection1:Cell( 'E2_XTPREQ'  ):SetValue( fNomRecu( ( cAlQry )->P00_USREMI , 1 ))
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

			oSection1:PrintLine()
	 
			(cAlQry)->(dbSkip())
		EndDo
	
	EndIf
	
	oSection1:Finish()
	(cAlQry)->(DbCloseArea())

Return

// ----------------------------------------------------------------------------

Static Function fNomRecu(cUser,nTp)

	Local cIDRecusa	:= cUser
    local cNomeRecu := ''
	Local nOrder := nTp

	PSWORDER(nOrder)

	If (PSWSEEK(cIDRecusa))
		cNomeRecu	:= Alltrim(PSWRET()[01][04])
	EndIf

return( cNomeRecu )

// ----------------------------------------------------------------------------

user function fdtprirec()

    local cArqQry       := GetNextAlias()
    local cSelQry       := ''
    local dDtPriRec_aux := ctod( space( 10 )) // id 1522
    
    if !empty( ( cAlQry )->F1_XDTRECP )
        dDtPriRec_aux := stod( ( cAlQry )->F1_XDTRECP )
        
    elseif !empty( ( cAlQry )->E2_XDTRECP )
        dDtPriRec_aux := stod( ( cAlQry )->E2_XDTRECP )

    else // data da primeira recusa gravada em P00

        cSelQry := "   SELECT P00_FILIAL , "
        cSelQry += "          P00_NUM    , "
        cSelQry += "          P00_PREFIX , "
        cSelQry += "          P00_FORNEC , "
        cSelQry += "          P00_LOJAF  , "
        cSelQry += "          P00_DTRECU , "
        cSelQry += "          P00_VALOR    "
        cSelQry += "     FROM " + retsqlname( 'P00' ) + " P00 "
        cSelQry += "    WHERE P00.D_E_L_E_T_ <> '*' "
        cSelQry += "      AND P00.P00_FILIAL  = '" + ( cAlQry )->P00_FILIAL + "' "
        cSelQry += "      AND P00.P00_NUM     = '" + ( cAlQry )->P00_NUM    + "' "
        cSelQry += "      AND P00.P00_PREFIX  = '" + ( cAlQry )->P00_PREFIX + "' "
        cSelQry += "      AND P00.P00_FORNEC  = '" + ( cAlQry )->P00_FORNEC + "' "
        cSelQry += "      AND P00.P00_LOJAF   = '" + ( cAlQry )->P00_LOJAF  + "' "
        cSelQry += " ORDER BY P00_DTRECU, P00_NUM, P00_PREFIX "
        cSelQry := ChangeQuery( cSelQry )
        dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cSelQry ) , cArqQry , .F. , .T. )
        ( cArqQry )->( dbgotop() )
        if ( cArqQry )->( ! eof() )
            dDtPriRec_aux := stod( ( cArqQry )->P00_DTRECU )    
        endif
        
    endif

return dDtPriRec_aux

// ----------------------------------------------------------------------------
// [ fim de f0101003.prw ]
// ----------------------------------------------------------------------------
