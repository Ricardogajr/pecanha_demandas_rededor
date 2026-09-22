#INCLUDE    'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE  'TBICONN.CH'

// ----------------------------------------------------------------------------
// {Protheus.doc} F1207201()
// Seleção de itens de pedido de compra para reenvio de e-mail
// @Author  Thiago Pereira
// @Since   08/05/2019
// @Version P12.7
// @Project MAN0000007423046
// @Return  Nil
// ----------------------------------------------------------------------------
user function f1207201()

// ------------------------------------
	private cArqTrab    := ''
// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
// ------------------------------------
	private cWFLFilial := ''
	private cWFLNum    := ''
	private cWFLData   := ddatabase
	private cWFLMsg1   := ''
	private cWFLEmailF := ''
	private cWFLEmailC := ''
	private cWFLStaGer := ''
	private cWFLMsg2   := ''
	private cWFLStaEnv := ''
	private cWFLMsg3   := ''
	private cWFLRotina := 'F1207201'
// ------------------------------------

	//vldsx1()  Thais Paiva - CompatibilizaçãoP27

// ------------------------------------
	if pergunte( 'FSW1200720' , .T. )
		execrotina()
	endif
// ------------------------------------

return Nil

// ----------------------------------------------------------------------------
// {Protheus.doc} ExecRotina
// Exibição da tela com opções
// @Author  Thiago Pereira
// @Since   08/05/2019
// @Version P12.7
// @Project MAN0000007423046
// @Return  Nil
// ----------------------------------------------------------------------------
static function execrotina()
// ------------------------------------
	local   nX         := 0
	local   nI         := 0
	local   aStru      := {}
	local   aSeek      := {}
	local   aIndex     := {}
	local   aFieFilter := {}
// ------------------------------------
	private oDlgMark
	private oMrkBrowse
	private aRotina    := {}
	private aColumns   := {}
	Private cArqTrab	:= GetNextAlias() //Thais Paiva - 9528615
// ------------------------------------
//  [ Definição default dos parâmetros ]
// ------------------------------------
//  mv_par01 := ""        // Filial de
//  mv_par02 := "ZZ"      // Filial ate
//  mv_par03 := ""        // Pedido de
//  mv_par04 := "ZZZZZZ"  // Pedido ate
//  mv_par05 := Date()-60 // Data emissao de
//  mv_par06 := Date()    // Data emissao ate
//  mv_par07 := ""        // Fornecedor de
//  mv_par08 := "ZZZZZZ"  // Fornecedor ate
// ------------------------------------
	SC7->( dbsetorder( 1 )) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
// ------------------------------------
//  [ Ordem dos campos ]
// ------------------------------------
	aadd( aStru , { 'TMP_OK'     , 'C' ,  1                        , 0 } )
	aadd( aStru , { 'RECNO'      , 'N' , 10                        , 0 } )
	aadd( aStru , { 'C7_FILIAL'  , 'C' , tamsx3( 'C7_FILIAL'  )[1] , 0 } )
	aadd( aStru , { 'C7_NUM'     , 'C' , tamsx3( 'C7_NUM'     )[1] , 0 } )
	aadd( aStru , { 'C7_EMISSAO' , 'D' , tamsx3( 'C7_EMISSAO' )[1] , 0 } )
	aadd( aStru , { 'C7_CONTRA'  , 'C' , tamsx3( 'C7_CONTRA'  )[1] , 0 } )
	aadd( aStru , { 'C7_CONTREV' , 'C' , tamsx3( 'C7_CONTREV' )[1] , 0 } )
	aadd( aStru , { 'C7_GRUPCOM' , 'C' , tamsx3( 'C7_GRUPCOM' )[1] , 0 } )
	aadd( aStru , { 'C7_FORNECE' , 'C' , tamsx3( 'C7_FORNECE' )[1] , 0 } )
	aadd( aStru , { 'A2_EMAIL'   , 'C' , tamsx3( 'A2_EMAIL'   )[1] , 0 } )
	aadd( aStru , { 'C7_LOJA'    , 'C' , tamsx3( 'C7_LOJA'    )[1] , 0 } )
	aadd( aStru , { 'A2_NOME'    , 'C' , tamsx3( 'A2_NOME'    )[1] , 0 } )
	aadd( aStru , { 'C7_USER'    , 'C' , tamsx3( 'C7_USER'    )[1] , 0 } )
	aadd( aStru , { 'C7_MEDICAO' , 'C' , tamsx3( 'C7_MEDICAO' )[1] , 0 } )
	aadd( aStru , { 'ENVIADO'    , 'C' , 1                         , 0 } )
// ------------------------------------
	cQuery :=    " SELECT ' '                       TMP_OK     , "       + CRLF
	cQuery +=           " ' '                       ENVIADO    , "       + CRLF
	cQuery +=           " SC7.R_E_C_N_O_            RECNO      , "       + CRLF
	cQuery +=           " SC7.C7_FILIAL                        , "       + CRLF
	cQuery +=           " SC7.C7_NUM                           , "       + CRLF
	cQuery +=           " SC7.C7_EMISSAO                       , "       + CRLF
	cQuery +=           " SC7.C7_CONTRA                        , "       + CRLF
	cQuery +=           " SC7.C7_CONTREV                       , "       + CRLF
	cQuery +=           " ISNULL(SC7.C7_GRUPCOM,'') C7_GRUPCOM , "       + CRLF
	cQuery +=           " SC7.C7_FORNECE                       , "       + CRLF
	cQuery +=           " ISNULL(SA2.A2_EMAIL  ,'') A2_EMAIL   , "       + CRLF
	cQuery +=           " SC7.C7_LOJA                          , "       + CRLF
	cQuery +=           " ISNULL(SA2.A2_NOME   ,'') A2_NOME    , "       + CRLF
	cQuery +=           " SC7.C7_USER                          , "       + CRLF
	cQuery +=           " SC7.C7_MEDICAO "                               + CRLF
	cQuery +=      " FROM " + retsqlname( 'SC7' ) + " SC7 "              + CRLF
	cQuery += " LEFT JOIN " + retsqlname( 'SA2' ) + " SA2 "              + CRLF
	cQuery +=        " ON SA2.A2_COD      = SC7.C7_FORNECE "             + CRLF
	cQuery +=       " AND SA2.A2_LOJA     = SC7.C7_LOJA "                + CRLF
	cQuery +=       " AND SA2.D_E_L_E_T_  = ' ' "                        + CRLF
	cQuery +=     " WHERE SC7.C7_FILIAL  >= '" +       MV_PAR01   + "' " + CRLF
	cQuery +=       " AND SC7.C7_FILIAL  <= '" +       MV_PAR02   + "' " + CRLF
	cQuery +=       " AND SC7.C7_NUM     >= '" +       MV_PAR03   + "' " + CRLF
	cQuery +=       " AND SC7.C7_NUM     <= '" +       MV_PAR04   + "' " + CRLF
	cQuery +=       " AND SC7.C7_EMISSAO >= '" + dtos( MV_PAR05 ) + "' " + CRLF
	cQuery +=       " AND SC7.C7_EMISSAO <= '" + dtos( MV_PAR06 ) + "' " + CRLF
	cQuery +=       " AND SC7.C7_FORNECE >= '" +       MV_PAR07   + "' " + CRLF
	cQuery +=       " AND SC7.C7_FORNECE <= '" +       MV_PAR08   + "' " + CRLF
	cQuery +=       " AND SC7.C7_XENVMAL  = 'N' "                        + CRLF
	cQuery +=       " AND SC7.C7_RESIDUO  = ''  "                        + CRLF
	cQuery +=       " AND SC7.C7_ENCER   <> 'E' "                        + CRLF
	cQuery +=       " AND SC7.D_E_L_E_T_  = ''  "                        + CRLF
	cQuery +=  " GROUP BY SC7.R_E_C_N_O_ , "                             + CRLF
	cQuery +=           " SC7.C7_FILIAL  , "                             + CRLF
	cQuery +=           " SC7.C7_NUM     , "                             + CRLF
	cQuery +=           " SC7.C7_EMISSAO , "                             + CRLF
	cQuery +=           " SC7.C7_FORNECE , "                             + CRLF
	cQuery +=           " SC7.C7_LOJA    , "                             + CRLF
	cQuery +=           " SC7.C7_USER    , "                             + CRLF
	cQuery +=           " SC7.C7_CONTRA  , "                             + CRLF
	cQuery +=           " SC7.C7_CONTREV , "                             + CRLF
	cQuery +=           " SC7.C7_MEDICAO , "                             + CRLF
	cQuery +=           " C7_GRUPCOM     , "                             + CRLF
	cQuery +=           " A2_NOME        , "                             + CRLF
	cQuery +=           " A2_EMAIL "                                     + CRLF
	cQuery +=  " ORDER BY 1 "
// ------------------------------------
	cChave   := SC7->( indexkey() )
	//Início - Thais Paiva - Compatibilização P27
	//cArqTrab 	:= CriaTrab(aStru, .T.)
	oTempTable := FWTemporaryTable():New( cArqTrab )
	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("01", {"C7_FILIAL"} ) //Thais Paiva - 9528615
	oTempTable:AddIndex("02", {"C7_NUM"} ) //Thais Paiva - 9528615
	oTempTable:AddIndex("03", {"C7_FORNECE"} ) //Thais Paiva - 9528615
	oTempTable:Create()
	//Fim - Thais Paiva - Compatibilização P27
// ------------------------------------
//  [ Criar indices ]
// ------------------------------------
	//Início - Thais Paiva - 9528615
	//cIndice1 := alltrim( criatrab( , .F. ) )
	//cIndice2 := cIndice1
	//cIndice3 := cIndice1
// ------------------------------------
	//cIndice1 := left( cIndice1 , 5 ) + right( cIndice1 , 2 ) + 'A'
	//cIndice2 := left( cIndice2 , 5 ) + right( cIndice2 , 2 ) + 'B'
	//cIndice3 := left( cIndice3 , 5 ) + right( cIndice3 , 2 ) + 'C'
// ------------------------------------
//  [ Se indice existir excluir ]
// ------------------------------------
	//if file(    cIndice1 + OrdBagExt() )
	//    ferase( cIndice1 + OrdBagExt() )
	// endif
	// if file(    cIndice2 + OrdBagExt() )
	//    ferase( cIndice2 + OrdBagExt() )
	//endif
	//if file(    cIndice3 + OrdBagExt() )
	//    ferase( cIndice2 + OrdBagExt() )
	//endif
// ------------------------------------
	//aadd( aFieFilter , { 'C7_FILIAL'  , 'Filial'     , 'C' , 08 , 0 , '@!' } )
	//aadd( aFieFilter , { 'C7_NUM'     , 'Pedido'     , 'C' , 06 , 0 , '@!' } )
	//aadd( aFieFilter , { 'C7_FORNECE' , 'Fornecedor' , 'C' , 06 , 0 , '@!' } )
// ------------------------------------
//    dbusearea( .T. , __LocalDriver , cArqTrab , cArqTrab , .F. )

// ------------------------------------
//  [ A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro ]
// ------------------------------------
	//indregua( cArqTrab , cIndice1 , 'C7_FILIAL'  , , , 'Indice Filial...'        )
	//indregua( cArqTrab , cIndice2 , 'C7_NUM'     , , , 'Indice Numero Pedido...' )
	//indregua( cArqTrab , cIndice3 , 'C7_FORNECE' , , , 'Indice Fornecedor...'    )
// ------------------------------------
	//dbclearindex()

// ------------------------------------
//  [ Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho. ]
// ------------------------------------
	//dbsetindex( cIndice1 + OrdBagExt() )
	//dbsetindex( cIndice2 + OrdBagExt() )
	//dbsetindex( cIndice3 + OrdBagExt() )
	//Fim - Thais Paiva - 9528615
// ------------------------------------
	(cArqTrab)->( dbsetorder( 0 ))
// ------------------------------------

	processa( {|| sqltotrb( cQuery , aStru , cArqTrab ) } )

// ------------------------------------

	for nX := 1 to len( aStru )

		if aStru[nX][1] $ 'C7_FILIAL|C7_NUM|C7_EMISSAO|C7_FORNECE|C7_LOJA|C7_USER|C7_GRUPCOM|A2_NOME|Y1_NOME|C7_MEDICAO|C7_CONTRA|C7_CONTREV|R_E_C_N_O_|'

// ------------------------------------
//          [ Adiciona as colunas no browse ]
// ------------------------------------
			aadd( aColumns , FWBrwColumn():New() )
// ------------------------------------
			aColumns[ len( aColumns ) ]:SetData   (        &( '{||' + aStru[nX][1] + '}' ) )
			aColumns[ len( aColumns ) ]:SetTitle  ( rettitle(         aStru[nX][1]       ) )
			aColumns[ len( aColumns ) ]:SetSize   (                   aStru[nX][3]         )
			aColumns[ len( aColumns ) ]:SetDecimal(                   aStru[nX][4]         )
			aColumns[ len( aColumns ) ]:SetPicture( pesqpict( 'SC7' , aStru[nX][1]       ) )
// ------------------------------------

			if aStru[nX,1] == 'C7_FILIAL'
// ------------------------------------
				aadd( aColumns , FWBrwColumn():New() )
// ------------------------------------	            
				aColumns[ len( aColumns )]:SetData   ( {|| RetNomeFil() } )
				aColumns[ len( aColumns )]:SetTitle  ( 'Descrição filial' )
				aColumns[ len( aColumns )]:SetSize   ( 20                 )
				aColumns[ len( aColumns )]:SetDecimal(  0                 )
				aColumns[ len( aColumns )]:SetPicture( '@!'               )
// ------------------------------------
			endif

// ------------------------------------
		endif

	next nX

// ------------------------------------
	(cArqTrab)->( dbgotop() )

// ------------------------------------
	DEFINE MSDIALOG oDlgMark TITLE 'Reenvio de e-mails - Pedido de Compras' FROM 000 , 000 TO 800 , 1000 COLORS 0 , 16777215 PIXEL Style DS_MODALFRAME

// ------------------------------------
	aadd( aSeek , { 'Filial'     , { { '' , 'C' , tamsx3( 'C7_FILIAL'  )[1] , 0 , 'Filial'     , '@!' } } } )
	aadd( aSeek , { 'Numero'     , { { '' , 'C' , tamsx3( 'C7_NUM'     )[1] , 0 , 'Numero'     , '@!' } } } )
	aadd( aSeek , { 'Fornecedor' , { { '' , 'C' , tamsx3( 'C7_FORNECE' )[1] , 0 , 'Fornecedor' , '@!' } } } )
// ------------------------------------
	oMrkBrowse := FWMBrowse():New()
// ------------------------------------        
//      oMrkBrowse:SetFieldMark('TMP_OK')
// ------------------------------------
	oMrkBrowse:SetAlias( cArqTrab )
	oMrkBrowse:SetMenuDef( 'F1207201' )
	oMrkBrowse:SetFilterDefault( "(cArqTrab)->ENVIADO == ' '" )
	oMrkBrowse:SetDBFFilter( .T. )
	oMrkBrowse:SetFixedBrowse( .T. )
	oMrkBrowse:SetTemporary( .T. )         // Indica que o Browse utiliza tabela temporária
	oMrkBrowse:SetSeek( .T. , aSeek ) // Habilita a utilização da pesquisa de registros no Browse
// ------------------------------------
	oColumn := oMrkBrowse:AddMarkColumns( { ||if(!empty( (cArqTrab)->(TMP_OK) ) , 'LBOK' , 'LBNO' ) } , {|oMrkBrowse| Marca() } )
	oMrkBrowse:SetColumns( aColumns )
	oMrkBrowse:Activate()
// ------------------------------------	
	oDlgMark:lMaximized := .T.
// ------------------------------------
	DEFINE SBUTTON oSButton1 FROM 130, 320 TYPE 02 OF oDlgMark ENABLE ACTION fCloseDlg()
// ------------------------------------

	ACTIVATE MSDIALOG oDlgMark
// ------------------------------------

return

// ----------------------------------------------------------------------------
// {Protheus.doc} RetNomeFil()
// Retorno o nome da filial
// @author  Alex Sandro Valario
// @since   15/08/2017
// @Project MAN0000007423046_EF_003
// @Return  Nil
// ----------------------------------------------------------------------------
static function retnomefil()
// ------------------------------------
	local cNomeFil := 'Não Encontrado'
	local aArea    := SM0->( getarea( 'SM0' ))
	local nRecno   := SM0->( recno() )
	local cFilSC7  := ( Alias() )->C7_FILIAL
// ------------------------------------
	SM0->( dbsetorder( 1 )) // M0_CODIGO + M0_CODFIL
	if SM0->( dbseek(          cEmpAnt   + cFilSC7 ))
		cNomeFil := SM0->M0_FILIAL
	endif
	SM0->( restarea( aArea ))
	SM0->( dbgoto( nRecno ))
// ------------------------------------
return cNomeFil

// ----------------------------------------------------------------------------
// {Protheus.doc} MenuDEF()
// Menu do Browse de Medição Automatizada
// @author  Thiago Pereira
// @since   08/05/2019
// @version P12.7
// @Project MAN00000462901_EF_001
// @Return  aRotina, Retorna a Rotina a ser inclusa no Menu.
// ----------------------------------------------------------------------------
static function menudef()
// ------------------------------------
	local aRotina := {}
// ------------------------------------
	ADD OPTION aRotina TITLE 'Reenviar E-mail'	ACTION 'U_F1207202()' OPERATION 2 ACCESS 0
return aRotina

// ----------------------------------------------------------------------------

static function Marca()

	//if empty( (cArqTrab)->TMP_OK ) 8056955 - Thais Paiva
	if empty( Alltrim((cArqTrab)->TMP_OK) )

		reclock( (cArqTrab) , .F. )
		(cArqTrab)->TMP_OK := 'S'
		(cArqTrab)->( msunlock())

	else

		reclock( (cArqTrab) , .F. )
		(cArqTrab)->TMP_OK := ' '
		(cArqTrab)->( msunlock() )

	endif

return

// ----------------------------------------------------------------------------
// {Protheus.doc} F1207202()
// Rotina que faz o envio de acordo com os pedidos selecionados
// @author  Thiago Pereira
// @since   08/05/2019
// @version P12.7
// @Project MAN00000462901_EF_001
// ----------------------------------------------------------------------------

user function f1207202()
	msaguarde( {|| BtnEnviar() } , 'Aguarde...' , 'Reenviando e-mails' , .T. )
return

// ----------------------------------------------------------------------------
// {Protheus.doc} BtnEnviar()
// Rotina que faz o envio de acordo com os pedidos selecionados
// @author  Thiago Pereira
// @since   08/05/2019
// @version P12.7
// @Project MAN00000462901_EF_001
// ----------------------------------------------------------------------------

/*/
	cQuery :=    " SELECT ' '                       TMP_OK     , "       + CRLF
	cQuery +=           " ' '                       ENVIADO    , "       + CRLF
	cQuery +=           " SC7.R_E_C_N_O_            RECNO      , "       + CRLF
	cQuery +=           " SC7.C7_FILIAL                        , "       + CRLF
	cQuery +=           " SC7.C7_NUM                           , "       + CRLF
	cQuery +=           " SC7.C7_EMISSAO                       , "       + CRLF
	cQuery +=           " SC7.C7_CONTRA                        , "       + CRLF
	cQuery +=           " SC7.C7_CONTREV                       , "       + CRLF
	cQuery +=           " ISNULL(SC7.C7_GRUPCOM,'') C7_GRUPCOM , "       + CRLF
	cQuery +=           " SC7.C7_FORNECE                       , "       + CRLF
	cQuery +=           " ISNULL(SA2.A2_EMAIL  ,'') A2_EMAIL   , "       + CRLF
	cQuery +=           " SC7.C7_LOJA                          , "       + CRLF
	cQuery +=           " ISNULL(SA2.A2_NOME   ,'') A2_NOME    , "       + CRLF
	cQuery +=           " SC7.C7_USER                          , "       + CRLF
	cQuery +=           " SC7.C7_MEDICAO "                               + CRLF
/*/

static function btnenviar()
// ------------------------------------
	local oMark    := getmarkbrow()
	local cFiltro  := ''
	local lItMarka := .F.
	local aPedNG   := {}
	local aPedOK   := {}
	local cMsgFim  := ''
	Local nI
// ------------------------------------
//  [ Verifica se existem itens selecionados para envio ]
// ------------------------------------
	(cArqTrab)->( dbgotop() )

	do while (cArqTrab)->( !eof() )

		//if !empty( (cArqTrab)->TMP_OK ) 8056955 - Thais Paiva
		if !empty( Alltrim((cArqTrab)->TMP_OK) ) .AND. Empty((cArqTrab)->ENVIADO)
// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLFilial := (cArqTrab)->(C7_FILIAL)
			cWFLNum    := (cArqTrab)->(C7_NUM   )
			cWFLData   := ddatabase
			cWFLMsg1   := ''
			cWFLEmailF := ''
			cWFLEmailC := ''
			cWFLStaGer := ''
			cWFLMsg2   := ''
			cWFLStaEnv := ''
			cWFLMsg3   := ''
			cWFLRotina := 'F1207201'
// ------------------------------------

// ------------------------------------
//          [ Envia email para o item selecionado ]
// ------------------------------------

			if sendmail()

				aadd( aPedOK , (cArqTrab)->(C7_NUM) )

// ------------------------------------
//              [ Update de campo para refresh apos envio ]
// ------------------------------------
				reclock( (cArqTrab) , .F. )
				(cArqTrab)->ENVIADO := 'S'
				(cArqTrab)->( msunlock() )

			else

				aadd( aPedNG , (cArqTrab)->(C7_NUM) )

			endif

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			recLock( 'WFL' , .T. )
			WFL->WFL_FILIAL := cWFLFilial
			WFL->WFL_NUM    := cWFLNum
			WFL->WFL_DATA   := cWFLData
			WFL->WFL_MSG1   := cWFLMsg1
			WFL->WFL_EMAILF := cWFLEmailF
			WFL->WFL_EMAILC := cWFLEmailC
			WFL->WFL_STAGER := cWFLStaGer
			WFL->WFL_MSG2   := cWFLMsg2
			WFL->WFL_STAENV := cWFLStaEnv
			WFL->WFL_MSG3   := cWFLMsg3
			WFL->WFL_ROTINA := cWFLRotina
			WFL->( msunlock() )
// ------------------------------------

		endif

		(cArqTrab)->( dbskip() )

	enddo

	if len( aPedOK ) == 0 .AND. ;
			len( aPedNG ) == 0

		msgalert( 'Não há itens selecionados.' , 'Seleção incorreta de itens.' )

	else

		cMsgFim := 'Reenvio de e-mails finalizado.' + CRLF

// ------------------------------------
//      [ Exibe itens OK ]
// ------------------------------------
		if len( aPedOK ) > 0
			cMsgFim += CRLF + 'Total pedidos enviados com sucesso: ' + cValToChar( len( aPedOK )) + CRLF
			for nI := 1 to len( aPedOK )
				cMsgFim += ' -> ' + aPedOK[nI] + CRLF
			next nI
		endif

// ------------------------------------
//      [ Exibe itens com erro ]
// ------------------------------------
		if len( aPedNG ) > 0
			cMsgFim += CRLF + 'Total pedidos com erros no e-mail: ' + cValToChar( len( aPedNG )) + CRLF
			for nI := 1 to len( aPedNG )
				cMsgFim += ' -> ' + aPedNG[nI] + CRLF
			next nI
		endif

		msginfo( cMsgFim )

	endif

	oMrkBrowse:ExecuteFilter( .T. )
	oMrkBrowse:oBrowse:Refresh( .T. )

return

// ----------------------------------------------------------------------------
// {Protheus.doc} SendMail
// Envia email de acordo com o recno
// @author  Thiago Pereira
// @since   08/05/2019
// @version P12.7
// @Project MAN00000462901_EF_001
// ----------------------------------------------------------------------------

static function sendmail()
// ------------------------------------
	local cArquivo := ''
	local cRet     := ''
	local lSend    := .F.
	local ctmpMail := ""
// ------------------------------------

	if empty( (cArqTrab)->(A2_EMAIL) )

		lSend := .F.

// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		cWFLMsg1 := 'NÃO OK (1.1) - Conta de email não cadastrada no fornecedor!'
// ------------------------------------

	else
// ------------------------------------
//      [ Posiciona na SC7 antes de cada envio ]
// ------------------------------------
		dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
		SC7->( dbgoto( (cArqTrab)->( RECNO )))
		cArquivo := u_tewbtyr2( 'SC7' , (cArqTrab)->( RECNO ) , Nil , 1 )
//  ticket n° 10173886 - query para ponteiramento na CN9
		cCN9Mail := alltrim( (cArqTrab)->(C7_NUM) )
		cSC7For  := (cArqtrab)->(C7_FORNECE)

		ctmpMail:=GetNextAlias()
		BeginSql Alias ctmpMail
        SELECT CN9_XEMAIL
        FROM %table:CN9% CN9, %table:CND% CND
        WHERE CN9_FILIAL = CND_FILCTR
        AND CN9_NUMERO = CND_CONTRA
        AND CN9_REVISA = CND_REVISA
        AND CND_FORNEC = %Exp:cSC7For%
        AND CND_PEDIDO =  %Exp:cCN9Mail% 
        AND CN9.%NotDel%
        AND CND.%NotDel%
		EndSql

//      cWFLEmailC := alltrim( posicione( 'CN9' , 1 , SC7->C7_FILIAL + SC7->C7_CONTRA + SC7->C7_CONTREV , 'CN9_XEMAIL' ))
//      cWFLEmailC := alltrim( CN9->CN9_XEMAIL )
		If !(ctmpMail)->(eof())
			cWFLEmailC := alltrim( (ctmpMail)->(CN9_XEMAIL) )
		Endif
		(ctmpMail)->( DbCloseArea() )
//  Fim ticket n° 10173886
// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		cWFLMsg1   := 'OK (1.0) - Email do fornecedor informado!'
		cWFLEmailF := alltrim( (cArqTrab)->(A2_EMAIL) )
// ------------------------------------
//      [ Valida se o arquivo foi criado com sucesso ]
// ------------------------------------
		if vldarquivo( cArquivo )

//            lSend := enviarmail( alltrim( (cArqTrab)->(A2_EMAIL) ) , ;
//                                 cArquivo                          , ;
//                                 (cArqTrab)->(C7_NUM)              , ;
//                                 alltrim( CN9->CN9_XEMAIL )        , ;
//                                 (cArqTrab)->( RECNO )               ) // ticket n° 7530301 - 415966 - Paulo Dias - envio de email para fornecedor

			lSend := enviarmail( alltrim( (cArqTrab)->(A2_EMAIL) ) , ;
				cArquivo                          , ;
				(cArqTrab)->(C7_NUM)              , ;
				cWFLEmailC                       , ;
				(cArqTrab)->( RECNO )               ) // ticket n° 7530301 - 415966 - Paulo Dias - envio de email para fornecedor

// ------------------------------------        	
//          [ Deleta o arquivo para evitar duplicidade ]
// ------------------------------------
			ferase( cArquivo )

		else
			lSend := .F.
		endif

	endif

return lSend

// ----------------------------------------------------------------------------
// {Protheus.doc} VldArquivo
// Valida o conteudo de arquivo (se existe, se possui conteudo e se foi completamente escrito)
// @author Thiago Pereira
// @since  02/04/2019
// ----------------------------------------------------------------------------

static function vldarquivo( cArquivo )
// ------------------------------------
	local nHandle := 0
	local lRet    := .T.
	local nTam    := 0
	local nTry    := 1
// ------------------------------------

	nHandle := fopen( cArquivo )

// ------------------------------------
//  [ Verifica se consegue abrir o arquivo ]
//  [ caso nao consiga, executa looping 5x com 1s de pausa ]
// ------------------------------------
	do while ( nTry    <=  5 .AND. ;
			nHandle == -1       )

		nTry++
		sleep( 1000 )
		nHandle := fopen( cArquivo ) // Nova tentativa

	enddo
// ------------------------------------

	if nHandle <> -1

		nTam := fseek( nHandle , 0 , 2 ) // Determina o tamanho do arquivo
		nTry := 1

		do while ( nTry <= 5 .AND. ;
				nTam == 0       )

			nTry++
			sleep( 1000 )
			nTam := fseek( nHandle , 0 , 2 ) // Nova leitura do tamanho do arquivo (verificao de inicio da escrita)

		enddo

		sleep( 1000 )

		if nTam > 0

			nTry := 1

// ------------------------------------
//          [ Validacao para garantir que o arquivo foi escrito por completo ]
//          [ a cada 1 segundo, mudara o conteudo dele com relacao a verificacao anterior ]
// ------------------------------------
			do while ( nTry                     <= 40 .AND. ;
					fSeek( nHandle , 0 , 2 ) <> nTam     )

				nTry++
				nTam := fSeek( nHandle , 0 , 2 )
				sleep( 1000 )

			enddo

			lRet := ( fSeek( nHandle , 0 , 2 ) == nTam .AND. ;
				nTry                     <= 40         )

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			if lRet
				cWFLStaGer := 'OK'
				cWFLMsg2   := 'OK (2.0) - Arquivo OK!'
			else
				cWFLStaGer := 'Erro'
				cWFLMsg2   := 'NÃO OK (2.3) - Arquivo incompleto.'
			endif
// ------------------------------------

		else
			lRet := .F.

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaGer := 'Erro'
			cWFLMsg2   := 'NÃO OK (2.2) - Arquivo vazio.'
// ------------------------------------

		endif

// ------------------------------------
//      [ Fecha o arquivo ]
// ------------------------------------
		fclose( nHandle )

// ------------------------------------
	else
		lRet := .F.

// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		cWFLStaGer := 'Erro'
		cWFLMsg2   := 'NÃO OK (2.1) - Não é possível abrir o arquivo gerado.'
// ------------------------------------

	endif

	if !lRet
		ferase( cArquivo )
	endif

return lRet

// ----------------------------------------------------------------------------

static function enviarmail( cContaDes , cArquivo , cNumPC , cMailContr , nRecSC7 )
// ------------------------------------
	local cSMTP     := alltrim( getmv( 'MV_RELSERV' )) // smtp.ig.com.br ou 200.181.100.51
	local cConta    := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
	local cPass     := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
	local cAssunto  := ""
	local cCorpo    := U_MSEMAILPC()//alltrim( getmv( 'FS_EF12005' , , 'Caro fornecedor, <br> Anexo, enviamos o espelho do Pedido de Compra para seu conhecimento.<br>' ))
	local cMensagem := ''
// ------------------------------------

// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
// ------------------------------------
	local cFilNom   := ''
	local cForNom   := ''
	local aArea     := getarea()
// ------------------------------------
	dbselectarea( 'SC7' )
	dbgoto( nRecSC7 )
// ------------------------------------
	cFilNom  := alltrim( fwfilialname( cEmpAnt , SC7->C7_FILIAL , 1 ))
	cForNom  := alltrim( posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_NREDUZ' ))
	cAssunto := iif(U_MsVldEmerg(SC7->C7_EMISSAO,SC7->C7_DATPRF,SC7->C7_XCTSERV),'[EMERGENCIAL] ',"")+'Pedido de compra: ' + cNumPC  + ;
		' - Filial: ' + cFilNom + ;
		' - Fornecedor: ' + cForNom
// ------------------------------------

// ------------------------------------
	cMensagem := '<html>'
	cMensagem += '<head><title>' + alltrim( cAssunto ) + '</title></head>'
	cMensagem += '<body>'
	cMensagem += '<br>'
	cMensagem += cCorpo
	cMensagem += '<br>'
	cMensagem += '</body>'
	cMensagem += '</html>'
// ------------------------------------

// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
// ------------------------------------
	restarea( aArea )
// ------------------------------------

return actsend( cSMTP , cConta , cPass , cContaDes , cAssunto , cArquivo , cMensagem , cMailContr , nRecSC7 )

// ----------------------------------------------------------------------------

static function actsend( cSMTP , cConta , cPass , cContaDes , cAssunto , cArquivo , cMensagem , cMailContr , nRecSC7 )
// ------------------------------------
	local lConSMTP   := .F.
	local lEnvEmail  := .F.
	local cError     := ''
	local cRet       := ''
	local cNomeAnexo := cArquivo
// ------------------------------------

	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP

	if lConSMTP

		if !isincallstack( 'U_F1200600' )

			cNomeAnexo := '\workflow\' + substr( cArquivo , rat( '\' , cArquivo ) + 1 )

			if !existdir( '\workflow' )
				mkdir( '\workflow' )
			endif 

			//cpyt2s( cArquivo , '\workflow\' , .T. )
			__CopyFile( cArquivo , cNomeAnexo)

		endif

// ------------------------------------
//      [ ticket n° 7530301 - 415966 - Paulo Dias - envio de email para fornecedor ]
// ------------------------------------
		SEND MAIL FROM cConta TO cContaDes CC cMailContr SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail

		ferase( cNomeanexo )

		dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
		SC7->( dbgoto( nRecSC7 ))

		if lEnvEmail // Email correto

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaEnv := 'OK'
			cWFLMsg3   := 'OK (3.0) - Conexão SMTP OK! Email enviado!'
// ------------------------------------

			SC7->( reclock( 'SC7' , .F. ))
			SC7->C7_XENVMAL := 'S'
			SC7->( msunlock() )

// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		else // Erro no envio do email

			Get Mail Error cError

			cRet        := 'Erro no envio do email: ' + cError
			cWFLStaEnv := 'Erro'
			cWFLMsg3   := 'NÃO OK (3.2) - ' + cRet
// ------------------------------------

		endif

		Disconnect SMTP Server

// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
// ------------------------------------
	else // Erro na conexao com o SMTP Server

		Get Mail Error cError

		cRet       := 'Erro na conexão SMTP: ' + cError
		cWFLStaEnv := 'Erro'
		cWFLMsg3   := 'NÃO OK (3.1) - ' + cRet
// ------------------------------------

	endif

return lEnvEmail

// ----------------------------------------------------------------------------
/*Início - Thais Paiva - CompatibilizaçãoP27
static function vldsx1()
// ------------------------------------
    local i
    local aAreaBKP := getarea()
    local aSX1     := {}
// ------------------------------------
    aadd( aSX1 , { 'FSW1200720' , '01' , 'Filial de:'            , 'MV_CH0' , 'C' , 8 , 0 , 'G' , 'MV_PAR01' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '02' , 'Filial até:'           , 'MV_CH1' , 'C' , 8 , 0 , 'G' , 'MV_PAR02' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '03' , 'Pedido de Compra de:'  , 'MV_CH2' , 'C' , 6 , 0 , 'G' , 'MV_PAR03' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '04' , 'Pedido de Compra até:' , 'MV_CH3' , 'C' , 6 , 0 , 'G' , 'MV_PAR04' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '05' , 'Data de Emissão de:'   , 'MV_CH4' , 'D' , 8 , 0 , 'G' , 'MV_PAR05' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '06' , 'Data de Emissão até:'  , 'MV_CH5' , 'D' , 8 , 0 , 'G' , 'MV_PAR06' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '07' , 'Fornecedor de:'        , 'MV_CH6' , 'C' , 6 , 0 , 'G' , 'MV_PAR07' , '' , '' , '' , '' , '' , '' } )
    aadd( aSX1 , { 'FSW1200720' , '08' , 'Fornecedor até:'       , 'MV_CH7' , 'C' , 6 , 0 , 'G' , 'MV_PAR08' , '' , '' , '' , '' , '' , '' } )
// ------------------------------------

    dbselectarea( 'SX1' ) // perguntas
    SX1->( dbsetorder( 1 )) // X1_GRUPO + X1_ORDEM

    for i := 1 to len( aSX1 )

        SX1->( reclock( 'SX1' , !dbseek( aSX1[i,1] + aSX1[i,2] )))
            SX1->X1_GRUPO   := aSX1[i,01]
            SX1->X1_ORDEM   := aSX1[i,02]
            SX1->X1_PERGUNT := aSX1[i,03]
            SX1->X1_VARIAVL := aSX1[i,04]
            SX1->X1_TIPO    := aSX1[i,05]
            SX1->X1_TAMANHO := aSX1[i,06]
            SX1->X1_DECIMAL := aSX1[i,07]
            SX1->X1_GSC     := aSX1[i,08]
            SX1->X1_VAR01   := aSX1[i,09]
            SX1->X1_DEF01   := aSX1[i,10]
            SX1->X1_DEF02   := aSX1[i,11]
            SX1->X1_DEF03   := aSX1[i,12]
            SX1->X1_DEF04   := aSX1[i,13]
            SX1->X1_DEF05   := aSX1[i,14]
            SX1->X1_F3      := aSX1[i,15]
        SX1->( msunlock() )

    next i

    restarea( aAreaBKP )

return( Nil )
Fim - Thais Paiva - Compatibilização P27*/

// ----------------------------------------------------------------------------
// {Protheus.doc} fCloseDlg
// Fecha tela de processamento / markbrowse de seleção de SCs
// @author  Paulo Krüger
// @since   07/09/2017
// @version P12.7
// @Project MAN0000007423046
// @Return  lRet
// ----------------------------------------------------------------------------

static function fCloseDlg()

    oDlgMark:End() // Fecha tela markbrowse de seleção de SCs

    if !empty( cArqTrab )

        dbselectarea( cArqTrab )
        dbclosearea()

        ferase( cArqTrab + GetDBExtension() )
        ferase( cArqTrab + OrdBagExt()      )

        cArqTrab := ''

        SC7->( dbsetorder( 1 )) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN

    endif

return

// ----------------------------------------------------------------------------
// [ fim de f1207201.prw ]
// ----------------------------------------------------------------------------
