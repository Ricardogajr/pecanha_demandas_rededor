#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE  'TOPCONN.CH'
// ------------------------------------
#DEFINE IMP_PDF 6 

// ----------------------------------------------------------------------------
// {Protheus.doc} TEWBTYR2
// TODO Relatório de pedido de compras customizado RDSL
// @author  Ricardo
// @since   05/10/2018
// @version 6
// @return  Nil
// @param   cAlias , nReg , nOpcx , nOp
// @type    function
// --------------- -------------------------------------------------------------

user function tewbtyr2( cAlias , nReg , nOpcx , nOp )
// ------------------------------------
	local   _aAreaAnt   :=        getarea()
	local   aAreaSA2    := SA2->( getarea() )
// ------------------------------------
	private _cPerg      := ''
	private _nLinha     := 40
	private _nTotal     := 00
	private oPrint      := Nil
	private oFont07     := Nil
	private oFont08     := Nil
	private oFont09     := Nil
	private oFont10     := Nil
	private oFont10n    := Nil
	private oFont11     := Nil
	private oFont12     := Nil
	private oFont12n    := Nil
	private oFont13     := Nil
	private oFont14     := Nil
	private oFont15     := Nil
	private oFont18     := Nil
	private oFont16     := Nil
	private oFont20     := Nil
	private oFont22     := Nil
	private oFont24     := Nil
	private _nPage      := 00
	private _dData      := stod( ' / / ' )
	private oBrush1     := TBrush():New(  , CLR_HGRAY )
	private oBrush3     := TBrush():New2( , CLR_HGRAY )
	private aCabExcel   := {}
	private aItensExcel := {}
	private nNumPag     := 00
	private cMotorista  := ''
	private cFrota      := ''
	private cDoca       := ''
	private cOnda       := ''
	private cCarga      := ''
	private cRoman      := ''
	private lPrimeira   := .T.
	private lContaPag   := .F.
	private nGeralQtd   := 00
	private nContaPag   := 00
	private nGeralPlt   := 00
	private nGeralPes   := 00
	private nGeralVol   := 00
	//private cNome       := 'RDRIMPPC' + dtos( ddatabase ) + strtran( time() , ':' , '' ) Thais Paiva - 29/06/2021
	private cNome       := ""
	Private _cData	:= dtos( ddatabase )//Thais Paiva - 29/06/2021
	Private _cHora := time()//Thais Paiva - 29/06/2021
	private aInfPac     := {}
	private cXIdBio     := ''
	private cXNum       := ''
	private nDesFin     := 00
	private nTxMoeda    := 00
	private cA2CGC      := ''
	private cA2Codigo   := ''
	private cA2Loja     := ''
	private cA2Nome     := ''
	private cA2Ender    := ''
	private cA2Num      := ''
	private cA2Bairro   := ''
	private cA2Comple   := ''
	private cA2Email    := ''
	private cA2Mun      := ''
	private cA2Tel      := ''
	private cComprador  := ''
	private cEmailCom   := ''
	private cTel        := ''
	private cTipo       := ''
	private cCondPag    := ''
	private cTpFrete    := ''
	private cFilPed     := '' //SC7->C7_FILIAL
	private cNumPed     := '' //SC7->C7_NUM
	private cFornece    := '' //SC7->C7_FORNECE
	private cLoja       := '' //SC7->C7_LOJA
	private nRegSc7     := nReg
	private lImpTela    := .T.
	private nDescTot    := 00
	private nTotIpi     := 00
	private nTotIcms    := 00
	private nTotDesp    := 00
	private nTotFrete   := 00
	private nTotSeguro  := 00
	private nTotalNF    := 00
	Private cLocEst     := ""

	Default l501 := .F.
// ------------------------------------
//  [ Via Aplicação ]
// ------------------------------------
//  Ticket n° 10755177 
	if funname() == 'MATA121'
		SC7->( dbgoto( nReg ))
		cFilPed  := SC7->C7_FILIAL
		cNumPed  := SC7->C7_NUM
		cFornece := SC7->C7_FORNECE
		cLoja    := SC7->C7_LOJA
		cNome := 'RDRIMPPC'+_cData+strtran( _cHora , ':' , '' )+cFilPed+cNumPed+cFornece+cLoja //Thais Paiva - 28/06/2021
		cLocEst := SC7->C7_LOCAL
		MsgRun( 'Processando, aguarde...' , 'Processando, aguarde...' , { || fGerRel() } )
	else
// ------------------------------------
//  [ Via Schedule. ]
// ------------------------------------
		dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
		SC7->( dbgoto( nReg ))
		cFilPed  := SC7->C7_FILIAL
		cNumPed  := SC7->C7_NUM
		cFornece := SC7->C7_FORNECE
		cLoja    := SC7->C7_LOJA
		lImpTela := .F.
		cNome := 'RDRIMPPC'+_cData+strtran( _cHora , ':' , '' )+cFilPed+cNumPed+cFornece+cLoja //Thais Paiva - 28/06/2021
		fGerRel(l501)
	endif
// ------------------------------------
	restarea( _aAreaAnt )
	restarea(  aAreaSA2 )

	If Empty(oPrint:cPathPDF)
		oPrint:cPathPDF := 'SIGADOC\IMPPC\'
	EndIf
// ------------------------------------
return oPrint:cPathPDf + cNome + '.pdf'

// ----------------------------------------------------------------------------

static function fGerRel()
// ------------------------------------
	local lAdjustToLegacy := .F.
	local lDisableSetup   := .T.
	local oPrinter        := Nil
	local cDir            := 'SIGADOC\IMPPC\' //'\spool' Thais Paiva - 12013888


// ------------------------------------

	//If IsBlind()
		if !ExistDir( 'SIGADOC\IMPPC' ) //Thais Paiva - 12013888
			MakeDir( 'SIGADOC\IMPPC' ) //Thais Paiva - 12013888
		endif //Thais Paiva - 12013888
/*/	Else
		cDir := GetTempPath()
	EndIf
/*/
	oPrint := FWMSPrinter():New( cNome , IMP_PDF , lAdjustToLegacy , cDir , lDisableSetup , , , , , , .F. , lImpTela )
//  oPrint:Setup()
	oPrint:SetLandscape()
// ------------------------------------	
	oFont07  := TFont():New( 'Courier New' , 07 , 07 , , .F. , , , , .T. , .F. )
	oFont08  := TFont():New( 'Arial'       , 08 , 08 , , .F. , , , , .T. , .F. )
	oFont08n := TFont():New( 'Arial'       , 08 , 08 , , .T. , , , , .T. , .F. )
	oFont09  := TFont():New( 'Arial'       , 09 , 09 , , .F. , , , , .T. , .F. )
	oFont09n := TFont():New( 'Arial'       , 09 , 09 , , .T. , , , , .T. , .F. )
	oFont10  := TFont():New( 'Arial'       , 10 , 10 , , .F. , , , , .T. , .F. )
	oFont10n := TFont():New( 'Arial'       , 10 , 10 , , .T. , , , , .T. , .F. )
	oFont11  := TFont():New( 'Arial'       , 11 , 11 , , .F. , , , , .T. , .F. )
	oFont11n := TFont():New( 'Arial'       , 11 , 11 , , .T. , , , , .T. , .F. )
	oFont12  := TFont():New( 'Arial'       , 12 , 12 , , .F. , , , , .T. , .F. )
	oFont12n := TFont():New( 'Arial'       , 12 , 12 , , .T. , , , , .T. , .F. )
	oFont13  := TFont():New( 'Arial'       , 13 , 13 , , .F. , , , , .T. , .F. )
	oFont13n := TFont():New( 'Arial'       , 13 , 13 , , .T. , , , , .T. , .F. )
	oFont14  := TFont():New( 'Arial'       , 14 , 14 , , .F. , , , , .T. , .F. )
	oFont14n := TFont():New( 'Arial'       , 14 , 14 , , .T. , , , , .T. , .F. )
	oFont15  := TFont():New( 'Arial'       , 15 , 15 , , .T. , , , , .T. , .F. )
	oFont18  := TFont():New( 'Arial'       , 18 , 18 , , .T. , , , , .T. , .T. )
	oFont16n := TFont():New( 'Arial'       , 16 , 16 , , .T. , , , , .T. , .F. )
	oFont16  := TFont():New( 'Arial'       , 16 , 16 , , .F. , , , , .T. , .F. )
	oFont20  := TFont():New( 'Arial'       , 20 , 20 , , .F. , , , , .T. , .F. )
	oFont22  := TFont():New( 'Arial'       , 22 , 22 , , .T. , , , , .T. , .F. )
	oFont24  := TFont():New( 'Arial'       , 24 , 24 , , .T. , , , , .T. , .F. )
	oFont32  := TFont():New( 'Arial'       , 32 , 32 , , .F. , , , , .T. , .F. )

	oFont14n2  := TFont():New( 'Arial'       , 14 , 14 , , .T. , , , , .T. , .T. )
// ------------------------------------
//  MsgRun( 'Gerando Dados...' , 'Gerando Dados...' , {|| fGetDados() } )
// ------------------------------------
	processa( {|| fGetDados() } , 'Aguarde...' , 'Carregando...' , .F. )
// ------------------------------------
return

// ----------------------------------------------------------------------------

static function fGetCabec()
// ------------------------------------
	local cFileLogo := GetSrvProfString( 'Startpath' , '' ) + u_r2logo()
	local oBrush1   := TBrush():New( , CLR_HGRAY )
	local aAreaSA2  := SA2->( getarea() )

// ------------------------------------
	cXIdBio := iif( empty( cXIdBio ) , _aPedAux[1][1] , cXIdBio )
	cXNum   := iif( empty( cXNum   ) , _aPedAux[1][2]   , cXNum   )
// ------------------------------------
	if lPrimeira
		lPrimeira := .F.
		oPrint:StartPage()
	else
		fGetRodape()
		oPrint:StartPage()
		_nLinha := 40
	endif
// ------------------------------------
	nContaPag++
// ------------------------------------
	dbselectarea( 'SM0' ) // empresas
// ------------------------------------
//  [ ticket n° 8050937 - 415966 - Condição para que a rotina de Imprimir Pedido pegue a filial correta ]	
// ------------------------------------
//	dbseek( cEmpAnt + cFilAnt , .T. )
// ------------------------------------
	dbseek( cEmpAnt + cFilPed , .T. )

	oPrint:SayBitmap( 012 , 001 , cFileLogo , 100 , 30 )
	nHoriz := 830 // oPrint:nPageWidth - 300

	dbselectarea( 'SA2' ) // fornecedores
	SA2->( dbsetorder( 1 )) // A2_FILIAL + A2_COD + A2_LOJA

	if SA2->( dbseek( xfilial( 'SA2' ) + _aPedAux[1][3] + _aPedAux[1][4] ))
		cA2CGC    := alltrim( SA2->A2_CGC     )
		cA2Codigo := alltrim( SA2->A2_COD     )
		cA2Loja   := alltrim( SA2->A2_LOJA    )
		cA2Nome   := alltrim( SA2->A2_NOME    )
		cA2Ender  := alltrim( SA2->A2_END     )
		cA2Num    := alltrim( SA2->A2_NR_END  )
		cA2Bairro := alltrim( SA2->A2_BAIRRO  )
		cA2Comple := alltrim( SA2->A2_ENDCOMP )
		cA2Email  := alltrim( SA2->A2_EMAIL   )
		cA2Mun    := alltrim( SA2->A2_MUN     )
		cA2Tel    := '(' + substr( SA2->A2_DDD , 1 ,  3 ) + ;
			')' + substr( SA2->A2_TEL , 1 , 15 )
	endif
// ------------------------------------

	If U_MsVldEmerg(ctoD(_aPedAux[1][34]),ctoD(_aPedAux[1][16]),SC7->C7_XCTSERV)
		oPrint:Say(     030 , 130 , OemToAnsi( 'PEDIDO EMERGENCIAL '       )            , oFont14n2 )
	EndIf
	oPrint:Say(     030 , 300 , OemToAnsi( 'Pedido de Compra P12: '       ) + cNumPed           , oFont14n )
	if !empty( cXIdBio )
		oPrint:Say( 020 , 480 , OemToAnsi( 'Pedido de Compra Bionexo: '   ) + cXIdBio           , oFont10  )
	endif
	if !empty( cXNum )
		oPrint:Say( 032 , 480 , OemToAnsi( 'Pedido de Compra Front: '     ) + cXNum             , oFont10  )
	endif
	oPrint:Say(     030 , 650 , OemToAnsi( 'Data Emissão: '               ) + dtoc( dDataBase ) , oFont11  )
	oPrint:Say(     030 , 780 , OemToAnsi( 'Pg:'+ cValToChar( nContaPag ) )                     , oFont11  )
// ------------------------------------
	BoxColor(    _nLinha + 3 , 0010 , _nLinha + 080 , nHoriz , CLR_WHITE )
	oPrint:Line( _nLinha + 5 , 0290 , _nLinha + 080 , 0290 )
	_nLinha := fPulaLinha( 2 )
// ------------------------------------
	oPrint:Say( _nLinha , 015 , OemToAnsi( 'Empresa: '                ) + alltrim( SM0->M0_NOMECOM ) , oFont11 )
	oPrint:Say( _nLinha , 300 , OemToAnsi( 'Razão Social: ' + cA2Nome )                              , oFont11 )
	oPrint:Say( _nLinha , 600 , OemToAnsi( 'Código: '       + cA2Codigo + ' Loja: ' + cA2Loja      ) , oFont11 )
	_nLinha := fPulaLinha()
// ------------------------------------
	oPrint:Say( _nLinha , 015 , OemToAnsi( 'Endereço: '     + alltrim( SM0->M0_ENDENT )            ) , oFont11 )
	oPrint:Say( _nLinha , 300 , OemToAnsi( 'Endereço: '     + cA2Ender                             ) , oFont11 )
	oPrint:Say( _nLinha , 600 , OemToAnsi( 'Numero: '       + cA2Num                               ) , oFont11 )
	_nLinha := fPulaLinha()
// ------------------------------------
	oPrint:Say( _nLinha , 015 , OemToAnsi( 'CEP: '         + alltrim( SM0->M0_CEPENT ) + ;
		'   '   + 'Cidade: '      + alltrim( SM0->M0_CIDENT )             ) , oFont11 )
	oPrint:Say( _nLinha , 300 , OemToAnsi( 'Complemento: ' + cA2Comple                             ) , oFont11 )
	oPrint:Say( _nLinha , 600 , OemToAnsi( 'Bairro: '      + cA2Bairro                             ) , oFont11 )
	_nLinha := fPulaLinha()
// ------------------------------------
	oPrint:Say( _nLinha , 015 , OemToAnsi( 'TEL: '         + alltrim( SM0->M0_TEL )                ) , oFont11 )
	oPrint:Say( _nLinha , 300 , OemToAnsi( 'Municipio: '   + cA2Mun                                ) , oFont11 )
	oPrint:Say( _nLinha , 600 , OemToAnsi( 'CNPJ/CPF: '    + if( len( cA2CGC ) > 11 , transform( cA2CGC , '@R 99.999.999/9999-99' ) , ;
		transForm( cA2CGC , '@R 999.999.999-99'     ) ) ) , oFont11 )
	_nLinha := fPulaLinha()
// ------------------------------------
	oPrint:Say( _nLinha , 015 , OemToAnsi( 'CNPJ/CPF: '    + transform( alltrim( SM0->M0_CGC ) , '@R 99.999.999/9999-99'  )           ) , oFont11 )
	oPrint:Say( _nLinha , 300 , OemToAnsi( 'Fone: '        + cA2Tel                                                                   ) , oFont11 )
	oPrint:Say( _nLinha , 600 , OemToAnsi( 'Email: '       + cA2Email                                                                 ) , oFont11 )
	_nLinha := fPulaLinha()
// ------------------------------------
return

// ----------------------------------------------------------------------------

static function fGetDados()
// ------------------------------------
	local _nLinSay   := 410
	local _cQuery    := ''
	local nCount     := 0
	local nTotQuant  := 0
	local nTotPallet := 0
	local nTotPeso   := 0
	local nTotVol    := 0
	local cIdEnt     := ''
	local aItensCli  := {}
	local cQuery     := ''
	local nDescProd  := 0
	local aTextObs   := {}
	local cFiltro    := 'SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !empty(SC7->C7_RESIDUO)'
	Local nX := 0 //Thais Paiva - 14082481
	Local _nPd := 0 //Thais Paiva - 14082481
	Private _aPedAux := {}
// ------------------------------------
	cQuery     :=     "SELECT SC7.C7_FILIAL  , "                                  + CRLF
	cQuery     +=            "SC7.C7_NUM     , "                                  + CRLF
	cQuery     +=            "SC7.C7_FORNECE , "                                  + CRLF
	cQuery     +=            "SC7.C7_LOJA    , "                                  + CRLF
	cQuery     +=            "SC7.C7_ITEM    , "                                  + CRLF
	cQuery     +=            "SC7.C7_PRODUTO , "                                  + CRLF
	cQuery     +=            "SC7.C7_DESCRI  , "                                  + CRLF
	cQuery     +=            "SC7.C7_OBS     , "                                  + CRLF
	cQuery     +=            "SC7.C7_DATPRF  , "                                  + CRLF
	cQuery     +=            "SC7.C7_LOCAL   , "                                  + CRLF
	cQuery     +=            "SC7.C7_QUANT   , "                                  + CRLF
	cQuery     +=            "SC7.C7_PRECO   , "                                  + CRLF
	cQuery     +=            "SC7.C7_TOTAL   , "                                  + CRLF
	cQuery     +=            "SC7.C7_VALIPI  , "                                  + CRLF
	cQuery     +=            "SC7.C7_VALICM  , "                                  + CRLF
	cQuery     +=            "SC7.C7_VALFRE  , "                                  + CRLF
	cQuery     +=            "SC7.C7_DESPESA , "                                  + CRLF
	cQuery     +=            "SC7.C7_SEGURO  , "                                  + CRLF
	cQuery     +=            "SC7.C7_XIDBIO  , "                                  + CRLF
	cQuery     +=            "SC7.C7_XNUM    , "                                  + CRLF
	cQuery     +=            "SC7.C7_XINFPAC , "                                  + CRLF
	cQuery     +=            "SC7.C7_SEGUM   , "                                  + CRLF
	cQuery     +=            "SB1.B1_XREFER  , "                                  + CRLF
	cQuery     +=            "SC7.C7_XDESFIN , "                                  + CRLF
	cQuery     +=            "SC7.C7_COND    , "                                  + CRLF
	cQuery     +=            "NNR.NNR_DESCRI , "                                  + CRLF
	cQuery     +=            "SBZ.BZ_QE      , "                                  + CRLF
	cQuery     +=            "SC7.C7_DESC1   , "                                  + CRLF
	cQuery     +=            "SC7.C7_DESC2   , "                                  + CRLF
	cQuery     +=            "SC7.C7_DESC3   , "                                  + CRLF
	cQuery     +=            "SC7.C7_VLDESC  , "                                  + CRLF
	cQuery     +=            "SC7.C7_TPFRETE , "                                  + CRLF
	cQuery     +=            "SC7.C7_TXMOEDA , "                                  + CRLF
	cQuery     +=            "SC7.C7_MOEDA   , "                                  + CRLF
	cQuery     +=            "SC7.C7_TIPO    , "                                  + CRLF
	cQuery     +=            "SC7.C7_USER    , "                                  + CRLF
	cQuery     +=            "SC7.C7_XPRECO  , "                                  + CRLF
	cQuery     +=            "SC7.C7_XQTDPC  , "                                  + CRLF
	cQuery     +=            "SC7.C7_EMISSAO , "                                  + CRLF
	cQuery     +=            "P17_UM2          "                                  + CRLF
	cQuery     +=       "FROM "                   + retsqlname( 'SC7' ) + " SC7 " + CRLF
	cQuery     += "INNER JOIN "                   + retsqlname( 'SB1' ) + " SB1 " + CRLF
	cQuery     +=         "ON SB1.B1_FILIAL  = '" +    xfilial( 'SB1' ) + "'    " + CRLF
	cQuery     +=        "AND SC7.C7_PRODUTO = SB1.B1_COD "                       + CRLF
	cQuery     +=        "AND SB1.D_E_L_E_T_ = ' '  "                             + CRLF
// ------------------------------------
//  [ ticket n° 8050937 - 415966 - Condição para que a rotina "Reenvia PC" pegue a filial correta ]
// ------------------------------------
	if funname() == 'MATA121'
		cQuery += "INNER JOIN "                   + retsqlname( 'NNR' ) + " NNR " + CRLF
		cQuery +=         "ON NNR.NNR_FILIAL = '" + cFilPed             + "' "    + CRLF
		cQuery +=        "AND NNR.NNR_CODIGO = SC7.C7_LOCAL "                     + CRLF
		cQuery +=        "AND NNR.D_E_L_E_T_ = ' ' "                              + CRLF
		cQuery +=  "LEFT JOIN "                   + retsqlname( 'SBZ' ) + " SBZ " + CRLF
		cQuery +=         "ON SBZ.BZ_FILIAL  = '" + cFilPed             + "' "    + CRLF
		cQuery +=        "AND SBZ.BZ_COD     = SC7.C7_PRODUTO "                   + CRLF
		cQuery +=        "AND SBZ.D_E_L_E_T_ = ' ' "                              + CRLF
	else
		cQuery += "INNER JOIN "                   + retsqlname( 'NNR' ) + " NNR " + CRLF
		cQuery +=         "ON NNR.NNR_FILIAL = '" +    xfilial( 'NNR' ) + "' "    + CRLF
		cQuery +=        "AND NNR.NNR_CODIGO = SC7.C7_LOCAL "                     + CRLF
		cQuery +=        "AND NNR.D_E_L_E_T_ = ' ' "                              + CRLF
		cQuery +=  "LEFT JOIN "                   + retsqlname( 'SBZ' ) + " SBZ " + CRLF
		cQuery +=         "ON SBZ.BZ_FILIAL  = '" +    xfilial( 'SBZ' ) + "' "    + CRLF
		cQuery +=        "AND SBZ.BZ_COD     = SC7.C7_PRODUTO "                   + CRLF
		cQuery +=        "AND SBZ.D_E_L_E_T_ = ' ' "                              + CRLF
	endif
// ------------------------------------
	cQuery     +=  "LEFT JOIN "                   + retsqlname( 'P17' ) + " P17 " + CRLF
	cQuery     +=         "ON P17.P17_FILIAL = '" +    xfilial( 'P17' ) + "' "    + CRLF
	cQuery     +=        "AND P17.P17_COD    = SC7.C7_PRODUTO  "                  + CRLF
	cQuery     +=        "AND P17.P17_FTRATA = SC7.C7_FILIAL   "                  + CRLF
	cQuery     +=        "AND P17.D_E_L_E_T_ = ' ' "                              + CRLF
	cQuery     +=      "WHERE SC7.C7_FILIAL  = '" + cFilPed             + "' "    + CRLF
	cQuery     +=        "AND SC7.C7_NUM     = '" + cNumPed             + "' "    + CRLF
	cQuery     +=        "AND SC7.C7_FORNECE = '" + cFornece            + "' "    + CRLF
	cQuery     +=        "AND SC7.C7_LOJA    = '" + cLoja               + "' "    + CRLF
	cQuery     +=        "AND SC7.C7_CONAPRO = 'L' "                              + CRLF
	cQuery     +=        "AND SC7.C7_RESIDUO = ' ' "                              + CRLF
	cQuery     +=        "AND SC7.D_E_L_E_T_ = ' ' "                              + CRLF //Thais Paiva - 08/04/2021 - Trocar o posicionamento do D_E_L_E_T_
	cQuery     +=   "ORDER BY SC7.C7_ITEM "                                       + CRLF
// ------------------------------------
	if select( 'AITMP' ) > 0
		AITMP->( dbclosearea() )
	endif
	TcQuery cQuery New Alias 'AITMP'
// ------------------------------------

	if AITMP->( eof() )

// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		recLock( 'WFL' , .T. )
		WFL->WFL_FILIAL := cFilPed //SC7->C7_FILIAL Thais Paiva - 28/06/2021
		WFL->WFL_NUM    := cNumPed //SC7->C7_NUM Thais Paiva - 28/06/2021
		//WFL->WFL_DATA   := _cData//ddatabase
		//WFL->WFL_MSG1   := 'NÃO OK (1.1) - O Pedido de compras está totalmente bloqueado e não será feita a impressão.' Thais Paiva - 28/06/2021
		WFL->WFL_MSG2   := 'NÃO OK (1.1) - O Pedido de compras está totalmente bloqueado e não será feita a impressão.' //Thais Paiva - 28/06/2021
		WFL->WFL_STAGER := 'ERRO' //Thais Paiva - 28/06/2021
		WFL->WFL_ROTINA := 'TEWBTYR2'
		WFL->WFL_HORA := _cHora //Thais Paiva - 12013888
		WFL->WFL_ARQUIVO := cNome //Thais Paiva - 12013888
		WFL->WFL_RECNC7 := cValToChar(nRegSc7) //Thais Paiva - 12013888
		WFL->WFL_USER := Alltrim(USRFULLNAME(__cuserid)) //Thais Paiva - 12013888
		WFL->( msunlock() )
// ------------------------------------

		//alert( 'O Pedido de compras esta totalmente bloqueado e não será feita a impressão.' ) Thais Paiva - 08/04/2021
		Help(NIL, NIL, "TEWBTYR2", NIL, "O Pedido de compras esta totalmente bloqueado e não será feita a impressão.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
		AITMP->( dbclosearea() )
		return
		//Início - Thais Paiva - 9324747
	Else

		nTxMoeda := iif( AITMP->C7_TXMOEDA > 0 , AITMP->C7_TXMOEDA , Nil )

		If FunName() == "MATA121"
			oProcess := MsNewProcess():New({|lEnd| fLoadData(@oProcess, @lEnd) },"Lendo Registros do Pedido...","Aguarde",.T.)
			oProcess:Activate()
		EndIf

		While AITMP->(!eof())

			aAdd(_aPedAux,{AITMP->C7_XIDBIO,; //1
			AITMP->C7_XNUM,; //2
			AITMP->C7_FORNECE,; //3
			AITMP->C7_LOJA,; //4
			AITMP->C7_USER,; //5
			AITMP->C7_TIPO,; //6
			AITMP->C7_TPFRETE,; //7
			AITMP->C7_COND,; //8
			AITMP->C7_NUM,; //9
			Alltrim(AITMP->C7_DESCRI),; //10
			Alltrim(AITMP->C7_OBS),; //11
			Alltrim(AITMP->B1_XREFER),; //12
			Alltrim(AITMP->NNR_DESCRI),; //13
			Alltrim(AITMP->C7_ITEM),; //14
			Alltrim(AITMP->C7_PRODUTO),; //15
			dtoc(stod(AITMP->C7_DATPRF)),; //16
			Alltrim(AITMP->P17_UM2),; //17
			cValToChar(AITMP->BZ_QE),; //18
			AITMP->C7_TXMOEDA,; //19
			AITMP->C7_DESC1,; //20
			AITMP->C7_DESC2,; //21
			AITMP->C7_DESC3,; //22
			AITMP->C7_TOTAL,; //23
			AITMP->C7_VLDESC,; //24
			AITMP->C7_XQTDPC,; //25
			AITMP->C7_XPRECO,; //26
			AITMP->C7_VALIPI,; //27
			AITMP->C7_XINFPAC,; //28
			AITMP->C7_VALICM,; //29
			AITMP->C7_DESPESA,; //30
			AITMP->C7_VALFRE,; //31
			AITMP->C7_SEGURO,; //32
			AITMP->C7_XDESFIN,; //33
			dtoc(stod(AITMP->C7_EMISSAO))})//34

			AITMP->(DbSkip())
		EndDo

		fGetCabec( .T. )
		fGetBoxItens( .T. )
// ------------------------------------	
		//Início - Thais Paiva - 28/06/2021
		recLock( 'WFL' , .T. )
		WFL->WFL_FILIAL := cFilPed
		WFL->WFL_NUM    := cNumPed
		//WFL->WFL_DATA   := ddatabase
		WFL->WFL_MSG2   := 'OK (1.1) - O Pedido de compras será impresso.'
		WFL->WFL_STAGER := 'OK'
		WFL->WFL_ROTINA := 'TEWBTYR2'
		WFL->WFL_HORA := _cHora //Thais Paiva - 12013888
		WFL->WFL_ARQUIVO := cNome //Thais Paiva - 12013888
		WFL->WFL_RECNC7 := cValToChar(nRegSc7) //Thais Paiva - 12013888
		WFL->WFL_USER := Alltrim(USRFULLNAME(__cuserid)) //Thais Paiva - 12013888
		WFL->( msunlock() )
		//Fim - Thais Paiva - 28/06/2021
	endif

	nColor     := CLR_HGRAY
	cComprador := UsrFullName( _aPedAux[1][5] )
	cEmailCom  := UsrRetMail ( _aPedAux[1][5] )
	cTel       := posicione( 'SY1' , 3 , xfilial( 'SY1' ) + _aPedAux[1][5] , 'Y1_TEL' )
	cTipo      := _aPedAux[1][6]
	cTpFrete   := _aPedAux[1][7]
	cCondPag   := _aPedAux[1][8]
	u_r2finipc( _aPedAux[1][9] , , , cFiltro )
// ------------------------------------
	//do while !AITMP->( eof() )
	For _nPd := 1 To Len(_aPedAux)

		nPulaLin := 1
		nEspaco   := 0 //nSpaco   := 0 Thais Paiva 14082481

		if nColor == CLR_HGRAY
			nColor := CLR_WHITE
		else
			nColor := CLR_HGRAY
		endif

		nDesFin    := _aPedAux[_nPd][33]
		nTamQbr    := 15 //10 Thais Paiva 14082481
		cTextDesc  := fFormatText(_aPedAux[_nPd][10])
		nLinDesc   := MlCount( cTextDesc  , 0030 )
		cTextObs   := fFormatText(_aPedAux[_nPd][11])
		nLinObs    := MlCount( cTextObs   , 0020 )
		cTextRef   := fFormatText(_aPedAux[_nPd][12])
		nLinRef    := MlCount( cTextRef   , 0010 )
		cTextLocal := fFormatText(_aPedAux[_nPd][13])
		nLinLocal  := MlCount( cTextLocal , 0010 )
		aTextObs   := {}
		aTextDesc  := {}
		aTextRef   := {}
		aTextLocal := {}
		nTamPos    := 5

		if nLinDesc > 1
			nTamQbr  := 15 * nLinDesc //10 * nLinDesc Thais Paiva 14082481
			nPulaLin := nLinDesc
			for nX := 01 to nLinDesc
				aadd( aTextDesc , { MemoLine( cTextDesc , 0030 , nX ) } )
			next nX
		endif

		if nLinObs > 1
			nTamQbr  := iif( nTamQbr  > nLinObs * 15 , nTamQbr  , nLinObs * 15 ) //iif( nTamQbr  > nLinObs * 10 , nTamQbr  , nLinObs * 10 ) Thais Paiva 14082481
			nTamPos  := nTamPos * nLinObs
			nPulaLin := iif( nPulaLin > nLinObs      , nPulaLin , nLinObs      )
			for nX := 01 to nLinObs
				aadd( aTextObs , { MemoLine( alltrim( cTextObs ) , 0020 , nX ) } )
			next nX
		endif

		if nLinRef > 1
			nTamQbr  := iif( nTamQbr  > nLinRef * 15 , nTamQbr  , nLinRef * 15 ) //iif( nTamQbr  > nLinRef * 10 , nTamQbr  , nLinRef * 10 ) Thais Paiva 14082481
			nTamPos  := nTamPos * nLinRef
			nPulaLin := iif( nPulaLin > nLinRef      , nPulaLin , nLinRef      )
			for nX := 01 to nLinRef
				aadd( aTextRef , { MemoLine( cTextRef , 0010 , nX ) } )
			next nX
		endif

		if nLinLocal > 1
			nTamQbr  := iif( nTamQbr  > nLinLocal * 15 , nTamQbr  , nLinLocal * 15 ) //iif( nTamQbr  > nLinLocal * 10 , nTamQbr  , nLinLocal * 10 ) Thais Paiva 14082481
			nTamPos  := nTamPos * nLinLocal
			nPulaLin := iif( nPulaLin > nLinLocal      , nPulaLin , nLinLocal      )
			for nX := 01 to nLinLocal
				aadd( aTextLocal , { MemoLine( cTextLocal , 0010 , nX ) } )
			next nX
		endif

// ------------------------------------
		BoxColorItens( _nLinha , 0010 , _nLinha + nTamQbr , 0050 , nColor )
		BoxColorItens( _nLinha , 0050 , _nLinha + nTamQbr , 0100 , nColor )
		BoxColorItens( _nLinha , 0100 , _nLinha + nTamQbr , 0250 , nColor )
		BoxColorItens( _nLinha , 0250 , _nLinha + nTamQbr , 0350 , nColor )
		BoxColorItens( _nLinha , 0350 , _nLinha + nTamQbr , 0400 , nColor )
		BoxColorItens( _nLinha , 0400 , _nLinha + nTamQbr , 0450 , nColor )
		BoxColorItens( _nLinha , 0450 , _nLinha + nTamQbr , 0480 , nColor )
		BoxColorItens( _nLinha , 0480 , _nLinha + nTamQbr , 0510 , nColor )
		BoxColorItens( _nLinha , 0510 , _nLinha + nTamQbr , 0560 , nColor )
		BoxColorItens( _nLinha , 0560 , _nLinha + nTamQbr , 0610 , nColor )
		BoxColorItens( _nLinha , 0610 , _nLinha + nTamQbr , 0680 , nColor )
		BoxColorItens( _nLinha , 0680 , _nLinha + nTamQbr , 0730 , nColor )
		BoxColorItens( _nLinha , 0730 , _nLinha + nTamQbr , 0780 , nColor )
		BoxColorItens( _nLinha , 0780 , _nLinha + nTamQbr , 0830 , nColor )
// ------------------------------------
		//nEspaco := nTamQbr / 4 Início Thais Paiva 14082481
		If nTamQbr > 15 //Thais
			nEspaco := nTamQbr / 6
		EndIf //Fim Thais Paiva 14082481
// ------------------------------------
		oPrint:SayAlign( _nLinha + nEspaco , 0010 , OemToAnsi( _aPedAux[_nPd][14] ) , oFont08 , 0050 , nTamPos , , 2 , 2 )
		oPrint:SayAlign( _nLinha + nEspaco , 0050 , OemToAnsi( _aPedAux[_nPd][15] ) , oFont08 , 0050 , nTamPos , , 2 , 2 )
// ------------------------------------
		if len( aTextDesc ) > 1
			_nLinhaAux := _nLinha
			for nX := 01 to len( aTextDesc )
				oPrint:SayAlign( _nLinhaAux    , 0100 , OemToAnsi( alltrim( aTextDesc[nX][1] ) )      , oFont08 , 0250 , 0050    , , 0 , 1 )
				_nLinhaAux += 10
			next nX
		else
			oPrint:SayAlign( _nLinha + nEspaco , 0100 , OemToAnsi( _aPedAux[_nPd][10] )   , oFont08 , 0250 , 0050    , , 0 , 1 )
		endif
// ------------------------------------
		if len( aTextObs ) > 1
			_nLinhaAux := _nLinha
			for nX := 01 to len( aTextObs )
				oPrint:SayAlign( _nLinhaAux    , 0250 , OemToAnsi( alltrim( aTextObs[nX][1] ) )       , oFont08 , 0100 , nTamPos , , 0 , 1 )
				_nLinhaAux += 10
			next nX
		else
			oPrint:SayAlign( _nLinha + nEspaco , 0250 , OemToAnsi( _aPedAux[_nPd][11] )      , oFont08 , 0100 , nTamPos , , 0 , 1 )
		endif
// ------------------------------------
		if len( aTextRef ) > 1
			_nLinhaAux := _nLinha
			for nX := 01 to len( aTextRef )
				oPrint:SayAlign( _nLinhaAux    , 0350 , OemToAnsi( alltrim( aTextRef[nX][1] ) )       , oFont08 , 0055 , nTamPos , , 0 , 1 )
				_nLinhaAux += 10
			next nX
		else
			oPrint:SayAlign( _nLinha + nEspaco , 0350 , OemToAnsi( _aPedAux[_nPd][12] ) , oFont08 , 0055 , nTamPos , , 0 , 1 )
		endif
// ------------------------------------
		oPrint:SayAlign(     _nLinha + nEspaco , 0400 , OemToAnsi( _aPedAux[_nPd][16] ) , oFont08 , 0050 , nTamPos , , 2 , 2 )
		oPrint:SayAlign(     _nLinha + nEspaco , 0450 , OemToAnsi( _aPedAux[_nPd][17] ) , oFont08 , 0030 , nTamPos , , 2 , 2 )
		oPrint:SayAlign(     _nLinha + nEspaco , 0480 , OemToAnsi( _aPedAux[_nPd][18] ) , oFont08 , 0030 , nTamPos , , 2 , 2 )
// ------------------------------------
		if len( aTextLocal ) > 1
			_nLinhaAux := _nLinha
			for nX := 01 to len( aTextLocal )
				oPrint:SayAlign( _nLinhaAux    , 0510 , OemToAnsi( alltrim( aTextLocal[nX][1] ) )     , oFont08 , 0050 , nTamPos , , 0 , 1 )
				_nLinhaAux += 10
			next nX
		else
			oPrint:SayAlign( _nLinha + nEspaco , 0510 , OemToAnsi( _aPedAux[_nPd][13] )  , oFont08 , 0050 , nTamPos , , 0 , 1 )
		endif
// ------------------------------------
//      oPrint:SayAlign( _nLinha , 0530 , OemToAnsi( alltrim( AITMP->NNR_DESCRI ) ) , oFont08 , 0050 , nTamPos , , 2 , 2 )
//      aConv      := u_f07024x( AITMP->C7_PRODUTO , AITMP->C7_FILIAL , AITMP->C7_QUANT , 2 , 1 , AITMP->C7_SEGUM )
//      nQtdCalcUm := aConv[1]
// ------------------------------------
		nTxMoeda   := iif( _aPedAux[_nPd][19] > 0 , _aPedAux[_nPd][19] , Nil )
// ------------------------------------
//      nVlUnitSC7 := xMoeda( ( AITMP->C7_TOTAL / nQtdCalcUm ) , AITMP->C7_MOEDA , 1 , AITMP->C7_DATPRF , MsDecimais( AITMP->C7_MOEDA ) , nTxMoeda )
// ------------------------------------
		if _aPedAux[_nPd][20] != 0 .OR. ;
				_aPedAux[_nPd][21] != 0 .OR. ;
				_aPedAux[_nPd][22] != 0
			nDescProd:= xCalcDesc( _aPedAux[_nPd][23] , ;
				_aPedAux[_nPd][20] , ;
				_aPedAux[_nPd][21] , ;
				_aPedAux[_nPd][22]   )
			nDescTot += nDescProd
		else
			nDescProd := _aPedAux[_nPd][24]
			nDescTot  += nDescProd
		endif
// ------------------------------------
		oPrint:SayAlign( _nLinha + nEspaco , 0560 , transform( _aPedAux[_nPd][25], '@E 999,999.9999'        ) , oFont08 , 0050 , nTamPos , , 2 , 2 )
		oPrint:SayAlign( _nLinha + nEspaco , 0610 , transform( _aPedAux[_nPd][26], '@E 999,999,999.9999999' ) , oFont08 , 0070 , nTamPos , , 1 , 0 )
		oPrint:SayAlign( _nLinha + nEspaco , 0680 , transform( _aPedAux[_nPd][23], '@E 999,999,999.99'      ) , oFont08 , 0050 , nTamPos , , 1 , 0 )
		oPrint:SayAlign( _nLinha + nEspaco , 0730 , transform( _aPedAux[_nPd][27], '@E 999,999,999.99'      ) , oFont08 , 0050 , nTamPos , , 1 , 0 )
		oPrint:SayAlign( _nLinha + nEspaco , 0780 , transform( nDescProd        , '@E 999.99'              ) , oFont08 , 0050 , nTamPos , , 1 , 0 )
// ------------------------------------
		if !empty( Alltrim(_aPedAux[_nPd][28]) ) .AND. len( aInfPac ) == 0
			nLinInfPac := MlCount( alltrim( _aPedAux[_nPd][28] ) , 0050 )
			for nX := 01 to nLinInfPac
				aadd( aInfPac , { MemoLine( alltrim( _aPedAux[_nPd][28] ) , 0050 , nX ) } )
			next nX
		endif
// ------------------------------------
		nTotIpi    += _aPedAux[_nPd][27]
		nTotIcms   += _aPedAux[_nPd][29]
		nTotDesp   += _aPedAux[_nPd][30]
		nTotFrete  += _aPedAux[_nPd][31]
		nTotSeguro += _aPedAux[_nPd][32]
		_nTotal    += _aPedAux[_nPd][23]
// ------------------------------------
		_nLinha    := fPulaLinha( nPulaLin )
		//AITMP->( dbskip() )
// ------------------------------------
		//enddo
	Next _nPd
	//Fim - Thais Paiva - 9324747
// ------------------------------------
	fGetBoxAux()
	fgetRodape()
	MaFisEnd()
	oPrint:Print( .F. )
// ------------------------------------
return

// ----------------------------------------------------------------------------

static function fGetRodape()
	oPrint:Line( 0590 , 0010 , 0590 , 0830 )
	oPrint:Say( 0600 , 0010 , 'TOTVS - TEWBTYR2' , oFont09 )
	oPrint:EndPage()
return

// ----------------------------------------------------------------------------

static function fPulaLinha( nLin )
// ------------------------------------
	local   _nLinAux := 10
// ------------------------------------
	default nLin     := 1
// ------------------------------------
	_nLinha += _nLinAux * nLin

	if _nLinha >= 0560
		_nLinha := 40
		fGetCabec( .T. )
		fGetBoxItens( .T. )
//     _nLinha := fPulaLinha()
	endif
// ------------------------------------
return _nLinha

// ----------------------------------------------------------------------------

static function BoxColor( nPos1 , nPos2 , nPos3 , nPos4 , cColor )
// ------------------------------------
	oBrush1 := TBrush():New2( , CLR_BLACK )
	oBrush2 := TBrush():New2( , cColor    )
// ------------------------------------
	oPrint:fillRect( { nPos1     , nPos2     , nPos3     , nPos4     } , oBrush1        )
	oPrint:fillRect( { nPos1 + 1 , nPos2 + 1 , nPos3 - 1 , nPos4 - 1 } , oBrush2 , '-1' )
// ------------------------------------
	oBrush1:End()
	oBrush2:End()
// ------------------------------------
return

// ----------------------------------------------------------------------------

static function BoxColorItens( nPos1 , nPos2 , nPos3 , nPos4 , cColor )
// ------------------------------------
	oBrush1 := TBrush():New2( , cColor )
	oBrush2 := TBrush():New2( , cColor )
// ------------------------------------
	oPrint:fillRect( { nPos1     , nPos2     , nPos3     , nPos4     } , oBrush1        )
	oPrint:fillRect( { nPos1 + 1 , nPos2 + 1 , nPos3 - 1 , nPos4 - 1 } , oBrush2 , '-1' )
// ------------------------------------
	oBrush1:End()
	oBrush2:End()
// ------------------------------------
return

// ----------------------------------------------------------------------------

static function fGetBoxItens( lImp )
// ------------------------------------
	default lImp := .F.
// ------------------------------------
	if lImp

		BoxColor( _nLinha , 0010 , _nLinha + 10 , 0050 , CLR_WHITE )
		BoxColor( _nLinha , 0050 , _nLinha + 10 , 0100 , CLR_WHITE )
		BoxColor( _nLinha , 0100 , _nLinha + 10 , 0250 , CLR_WHITE )

		BoxColor( _nLinha , 0250 , _nLinha + 10 , 0350 , CLR_WHITE )
		BoxColor( _nLinha , 0350 , _nLinha + 10 , 0400 , CLR_WHITE )
		BoxColor( _nLinha , 0400 , _nLinha + 10 , 0450 , CLR_WHITE )

		BoxColor( _nLinha , 0450 , _nLinha + 10 , 0480 , CLR_WHITE )
		BoxColor( _nLinha , 0480 , _nLinha + 10 , 0510 , CLR_WHITE )
		BoxColor( _nLinha , 0510 , _nLinha + 10 , 0560 , CLR_WHITE )

		BoxColor( _nLinha , 0560 , _nLinha + 10 , 0610 , CLR_WHITE )
		BoxColor( _nLinha , 0610 , _nLinha + 10 , 0680 , CLR_WHITE )
		BoxColor( _nLinha , 0680 , _nLinha + 10 , 0730 , CLR_WHITE )

		BoxColor( _nLinha , 0730 , _nLinha + 10 , 0780 , CLR_WHITE )
		BoxColor( _nLinha , 0780 , _nLinha + 10 , 0830 , CLR_WHITE )

// ------------------------------------        

		oPrint:SayAlign( _nLinha , 0010 , OemToAnsi('Item'      ) , oFont09n , 0050 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0050 , OemToAnsi('Produto'   ) , oFont09n , 0050 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0100 , OemToAnsi('Descrição' ) , oFont09n , 0150 , 0005 , , 2 , 2 )

		oPrint:SayAlign( _nLinha , 0250 , 'Complemento'           , oFont09n , 0100 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0350 , 'Referencia'            , oFont09n , 0050 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0400 , 'Data Entrega'          , oFont09n , 0050 , 0005 , , 2 , 2 )

		oPrint:SayAlign( _nLinha , 0450 , '2UM'                   , oFont09n , 0030 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0480 , 'Q.Emb.'                , oFont09n , 0030 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0510 , 'Local'                 , oFont09n , 0050 , 0005 , , 2 , 2 )

		oPrint:SayAlign( _nLinha , 0560 , 'Quantidade'            , oFont09n , 0050 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0610 , 'Valor Unit.'           , oFont09n , 0070 , 0005 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0680 , 'Valor Tot.'            , oFont09n , 0050 , 0005 , , 2 , 2 )

		oPrint:SayAlign( _nLinha , 0730 , 'Valor Ipi'             , oFont09n , 0050 , 0020 , , 2 , 2 )
		oPrint:SayAlign( _nLinha , 0780 , 'Desc.'                 , oFont09n , 0050 , 0020 , , 2 , 2 )

	endif
// ------------------------------------
	_nLinha := fPulaLinha()
// ------------------------------------
return

// ----------------------------------------------------------------------------

static function fGetBoxAux()
	Local nX := 0 //Thais Paiva 14082481
	Local lContinua := .T.
	Local nContador := 0
	Local nY := 0
	Local aFilCD := {}
	Local cFilBKP := cFilAnt
	Local cFrase1 := GetNewPar("MS_RELT1","O vencimento deverá acatar a condição de pagamento acordada, o pagamento ocorrerá nos dias 10, 20 ou 30, via depósito bancário.")
	Local cFrase2 := GetNewPar("MS_RELT2","O pedido de compra deve constar no XML da NF-e; Campo xPed: número do pedido; Campo xItem: item correspondente.")
	Local cFrase3 := GetNewPaR("MS_RELT3","Essas informações são importantes na Nota Fiscal para garantir o recebimento e pagamento no prazo.")

	Local nTeste1 := 0060
	Local nTeste2 := 0830
	Local nTeste3 := 0015
	Local nTeste4 := 0830
	Local nTeste5 := 0005

	_nLinha := fPulaLinha()
	if _nLinha + 300 > 560
		oPrint:SayAlign( _nLinha , 0010 , 'Continua na proxima página....' , oFont10n , 0190 , 0001 , , 0 , 1 )
		_nLinha := fPulaLinha( 300 )
		_nLinha := fPulaLinha(     )
	endif
// ------------------------------------
	dbselectarea( 'SM0' ) // empresas
// ------------------------------------
//  [ ticket n° 8050937 - 415966 - Condição para que a rotina de Imprimir Pedido pegue a filial correta ]
// ------------------------------------
//	dbseek( cEmpAnt + cFilAnt , .T. )
// ------------------------------------
	dbseek( cEmpAnt + cFilPed , .T. )
	cCident := iif( len( SM0->M0_CIDENT ) > 20 , substr( SM0->M0_CIDENT , 1 , 15 ) , SM0->M0_CIDENT )
	cCidcob := iif( len( SM0->M0_CIDCOB ) > 20 , substr( SM0->M0_CIDCOB , 1 , 15 ) , SM0->M0_CIDCOB )

	BoxColor( _nLinha , 0010 , _nLinha + 0200 , 0830 , CLR_WHITE )

	oPrint:SayAlign( _nLinha + 5 , 0010 , 'Local de Entrega:' , oFont10n , 0090 , 0020 , , 2 , 2 )

	nContador := 0
	cEndCD := ""
	cFilAnt := cFilPed
	If Empty(cLocEst)
		cLocEst := SC7->C7_LOCAL
	EndIf
	While lContinua

		If nContador == 0
			cFilCD := GetNewPar("MV_XFCD","Não Existe")
			If cFilCd == "Não Existe"
				lContinua := .F.
			Else
				aFilCD := StrTokArr( cFilCD, '|' )
				For nY := 01 To Len(aFilCD)
					if alltrim( cLocEst) == alltrim( aFilCD[nY] )
						cEndCD := GetNewPar("MV_XECD","")
						lContinua := .F.
					EndIf
				Next nY
			EndIf
		Else
			cFilCD := GetNewPar("MV_XFCD"+CValToChar(nContador),"Não Existe")
			If cFilCd == "Não Existe"
				lContinua := .F.
			Else
				aFilCD := StrTokArr( cFilCD, '|' )
				For nY := 01 To Len(aFilCD)
					if alltrim( cLocEst) == alltrim( aFilCD[nY] )
						cEndCD := GetNewPar("MV_XECD"+CValToChar(nContador),"")
						lContinua := .F.
					EndIf
				Next nY
			EndIf
		EndIf
		nContador++
	EndDo

	if !Empty(cEndCD)
		oPrint:SayAlign( _nLinha + 5 , 0090 , alltrim( cEndCD ) , oFont10 , 0400 , 0020 , , 0 , 1 )
	else
		oPrint:SayAlign( _nLinha + 5 , 0090 , alltrim( SM0->M0_ENDCOB ) + '  '       + ;
			rtrim( SM0->M0_CIDCOB ) + ' - '      + ;
			SM0->M0_ESTCOB   + ' - CEP: ' + ;
			trans( alltrim( SM0->M0_CEPCOB ) , PesqPict( 'SA2' , 'A2_CEP' )) , oFont10 , 0400 , 0020 , , 0 , 1 )
	endif
// ------------------------------------
	_nLinha := fPulaLinha( 2 )
	BoxColor( _nLinha , 010 , _nLinha + 100 , 415 , CLR_WHITE )
	BoxColor( _nLinha , 415 , _nLinha + 100 , 830 , CLR_WHITE )
	BoxColor( _nLinha , 415 , _nLinha + 050 , 622 , CLR_WHITE )
	BoxColor( _nLinha , 622 , _nLinha + 050 , 830 , CLR_WHITE )

	_nLinha := fPulaLinha()
	oPrint:SayAlign( _nLinha , 0015 , 'Observações: ' , oFont10n , 0080 , 0005 , , 0 , 1 )
	_nLinhaAux := _nLinha + 10
	for nX := 01 to len( aInfPac )
		oPrint:SayAlign( _nLinhaAux , 0015 , alltrim( aInfPac[nX][01] ) , oFont10 , 0300 , 0010 , , 0 , 1 )
		_nLinhaAux += 10
	next nX

// ------------------------------------
//	dbselectarea( 'SC7' )
//	SC7->( dbgoto( nRegSc7 ))
//	nTotIpi    := MaFisRet( , 'NF_VALIPI'  )
//	nTotIcms   := MaFisRet( , 'NF_VALICM'  )
//	nTotDesp   := MaFisRet( , 'NF_DESPESA' )
//	nTotFrete  := MaFisRet( , 'NF_FRETE'   )
//	nTotSeguro := MaFisRet( , 'NF_SEGURO'  )
//	nTotalNF   := MaFisRet( , 'NF_TOTAL'   )
//	MaFisEnd()
// ------------------------------------

	oPrint:SayAlign( _nLinha , 0420 , 'Frete: '                                               , oFont10n , 0080 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0480 , transform( nTotFrete , '@E 999,999,999.99' )            , oFont10  , 0080 , 0005 , , 0 , 1 ) // 'Frete    :'

	oPrint:SayAlign( _nLinha , 0628 , 'Total Desconto: '                                      , oFont10n , 0080 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0708 , transform( nDescTot  , '@E 999,999,999.99' )            , oFont10  , 0080 , 0005 , , 0 , 1 )

	_nLinha := fPulaLinha()
	oPrint:SayAlign( _nLinha , 0420 , 'Tipo de Frete: '                                       , oFont10n , 0080 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0500 , iif( cTpFrete == 'C' , 'CIF' , ;
		iif( cTpFrete == 'F' , 'FOB' , ' ' ) )                  , oFont10  , 0080 , 0005 , , 0 , 1 )

	if nDesFin > 0
		oPrint:SayAlign( _nLinha , 0628 , 'Desconto Financeiro: '                             , oFont10n , 0100 , 0005 , , 0 , 1 )
		oPrint:SayAlign( _nLinha , 0738 , alltrim( transform( nDesFin , '99.99%' ))           , oFont10  , 0080 , 0005 , , 0 , 1 )
	endif
	_nLinha := fPulaLinha()
	oPrint:SayAlign( _nLinha , 0420 , 'Seguro: '                                              , oFont10n , 0080 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0500 , alltrim( transform( nTotSeguro , '@E 999,999,999.99' )) , oFont10  , 0080 , 0005 , , 0 , 1 )

	_nLinha := fPulaLinha( 3 )
	oPrint:SayAlign( _nLinha , 0420 , 'Total das Mercadorias: '                               , oFont10n , 0100 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0520 , transform( _nTotal , '@E 999,999,999.99' )              , oFont10  , 0080 , 0005 , , 2 , 2 )

	oPrint:SayAlign( _nLinha , 0628 , 'Total do IPI: '                                        , oFont10n , 0080 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0708 , transform( nTotIpi , '@E 999,999,999.99' )              , oFont10  , 0080 , 0005 , , 0 , 1 )

	_nLinha  := fPulaLinha()
	If _nTotal ==  ( _nTotal + nTotIpi + nTotDesp + nTotFrete + nTotSeguro ) - nDescTot
		nTotalNF := _nTotal
	Else
		nTotalNF := NOROUND(( _nTotal + nTotIpi + nTotDesp + nTotFrete + nTotSeguro ) - nDescTot,2)
	EndIf

	oPrint:SayAlign( _nLinha , 0420 , 'Total geral: '                                         , oFont10n , 0100 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0520 , transform( nTotalNF , '@E 999,999,999.99' )             , oFont10  , 0080 , 0005 , , 2 , 2 )

	_nLinha := fPulaLinha()
	oPrint:SayAlign( _nLinha , 0420 , 'Condição de pagamento: '                               , oFont10n , 0100 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0520 , posicione( 'SE4' , 1 , xfilial( 'SE4' ) + padr( cCondPag , tamsx3( 'C7_COND' )[01] ) , 'E4_DESCRI' ) , oFont10 , 0080 , 0005 , , 0 , 1 )

	_nLinha := fPulaLinha( 3 )
	oPrint:SayAlign( _nLinha , 0015 , 'Comprador responsavel: '                               , oFont10n , 0120 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0120 , substr( cComprador , 1 , 60 )                           , oFont10  , 0080 , 0005 , , 0 , 1 )

	_nLinha := fPulaLinha()
	oPrint:SayAlign( _nLinha , 0015 , 'E-mail: '                                              , oFont10n , 0030 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0050 , OemToAnsi( alltrim( cEmailCom ))                        , oFont10  , 0120 , 0005 , , 0 , 1 )

	_nLinha := fPulaLinha()
	oPrint:SayAlign( _nLinha , 0015 , 'Telefone: '                                            , oFont10n , 0080 , 0005 , , 0 , 1 )
	oPrint:SayAlign( _nLinha , 0120 , alltrim( cTel )                                         , oFont10  , 0080 , 0005 , , 0 , 1 )

	_nLinha := fPulaLinha( 3 )
	//BoxColor( _nLinha , 0010 , _nLinha + 0060 , 0830 , CLR_WHITE )
	BoxColor( _nLinha , 0010 , _nLinha + nTeste1 , nTeste2 , CLR_WHITE )
	_nLinha := fPulaLinha()

	if cValToChar( cTipo ) $ '1|3'
		oPrint:SayAlign( _nLinha , nTeste3 , cFrase1, oFont10n , nTeste4 , nTeste5 , , 0 , 1 )
		_nLinha := fPulaLinha()
		oPrint:SayAlign( _nLinha , nTeste3 , cFrase2, oFont10n , nTeste4 , nTeste5 , , 0 , 1 )
		_nLinha := fPulaLinha()
		oPrint:SayAlign( _nLinha , nTeste3 , cFrase3, oFont10n , nTeste4 , nTeste5 , , 0 , 1 )
	else
		oPrint:SayAlign( _nLinha , 0015 , cFrase1 , oFont10n , 0830 , 0005 , , 0 , 1 )
		_nLinha := fPulaLinha()
		oPrint:SayAlign( _nLinha , nTeste3 , cFrase2, oFont10n , nTeste4 , nTeste5 , , 0 , 1 )
		_nLinha := fPulaLinha()
		oPrint:SayAlign( _nLinha , nTeste3 , cFrase3, oFont10n , nTeste4 , nTeste5 , , 0 , 1 )
	endif

// ------------------------------------
//  SM4->( dbsetorder( 1 ))
//  if SM4->( dbseek( xfilial( 'SM4' ) + SC7->C7_REAJUST ))
//      oReport:PrintText( STR0014 + ' ' + SC7->C7_REAJUST + ' ' + SM4->M4_DESCR , nLinPC , 050 ) // 'Reajuste :'
//      oPrint:SayAlign( _nLinha , 0015 , 'Reajuste :'  , oFont10n , 0830 , 0005 , , 0 , 1 )
//      oPrint:SayAlign( _nLinha , 0015 , SM4->M4_DESCR , oFont10n , 0830 , 0005 , , 0 , 1 )
//  endif
// ------------------------------------
	cFilAnt := cFilBKP
return

// ----------------------------------------------------------------------------

user function R2Logo()
// ------------------------------------
	local cBitmap := 'LGRL' + SM0->M0_CODIGO+SM0->M0_CODFIL + '.BMP' // Empresa + Filial
// ------------------------------------

//##############################################################
//  Se nao encontrar o arquivo com o codigo do grupo de empresas 
//  completo, retira os espacos em branco do codigo da empresa   
//  para nova tentativa.                                         
//##############################################################
	if !File( cBitmap )
		cBitmap := 'LGRL' + alltrim( SM0->M0_CODIGO ) + SM0->M0_CODFIL + '.BMP' // Empresa + Filial
	endif

//##############################################################
//  Se nao encontrar o arquivo com o codigo da filial completo, 
//  retira os espacos em branco do codigo da filial para nova   
//  tentativa.                                                  
//##############################################################
	if !File( cBitmap )
		cBitmap := 'LGRL' + SM0->M0_CODIGO + alltrim( SM0->M0_CODFIL ) + '.BMP' // Empresa + Filial
	endif

//##############################################################
//  Se ainda nao encontrar, retira os espacos em branco do codigo
//  da empresa e da filial simultaneamente para nova tentativa.  
//##############################################################
	if !File( cBitmap )
		cBitmap := 'LGRL' + alltrim( SM0->M0_CODIGO ) + alltrim( SM0->M0_CODFIL ) + '.BMP' // Empresa + Filial
	endif

//##############################################################
//  Se nao encontrar o arquivo por filial, usa o logo padrao     
//##############################################################
	if !File( cBitmap )
		cBitmap := 'LGRL' + SM0->M0_CODIGO + '.BMP' // Empresa
	endif
// ------------------------------------
return cBitmap

// ----------------------------------------------------------------------------

static function fFormatText( cTexto )
// ------------------------------------
	local   aAux      := {}
	local   nX        := 0
	local   cTextoAux := ''
// ------------------------------------
	default cTexto    := ''
// ------------------------------------
	do while '  ' $ cTexto
		cTexto := strtran( cTexto , '  ' , ' ' )
	enddo
// ------------------------------------
	aAux := strtokarr( cTexto , '' + chr( 13 ) + chr( 10 ))
	for nX := 01 to len( aAux )
		cTextoAux += aAux[nX] + ' '
	next nX
// ------------------------------------
return cTextoAux

// ----------------------------------------------------------------------------

user function R2FIniPC( cPedido , cItem , cSequen , cFiltro )
// ------------------------------------
	local   aArea    :=        getarea()
	local   aAreaSC7 := SC7->( getarea() )
	local   cValid   := ''
	local   nPosRef  := 0
	local   nItem    := 0
	local   cItemDe  := iif( cItem==Nil , ''                                , cItem )
	local   cItemAte := iif( cItem==Nil , repl( 'Z' , len( SC7->C7_ITEM ) ) , cItem )
	local   cRefCols := ''
	Local _aCmpC7	:= {} //Thais Paiva - Compatibilização P27
	Local _nC7 := 0 //Thais Paiva 14082481
// ------------------------------------
	default cSequen  := ''
	default cFiltro  := ''
// ------------------------------------
	dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
	dbsetorder( 1 ) // C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN

	if dbseek( xfilial( 'SC7' ) + cPedido + cItemDe + alltrim( cSequen ))

		MaFisEnd()
		MaFisIni( SC7->C7_FORNECE , SC7->C7_LOJA , 'F' , 'N' , 'R' , {} )

		do while !eof()                                                   .AND. ;
				SC7->C7_FILIAL + SC7->C7_NUM  == xfilial('SC7') + cPedido .AND. ;
				SC7->C7_ITEM                  <= cItemAte                 .AND. ;
				( empty( cSequen ) .OR. cSequen == SC7->C7_SEQUEN )
// ------------------------------------
//          [ Nao processar os Impostos se o item possuir residuo eliminado ]
// ------------------------------------
			if &cFiltro
				dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
				dbskip()
				loop
			endif

// ------------------------------------
//          [ TESTE ]
// ------------------------------------
//          [ Inicia a Carga do item nas funcoes MATXFIS ]
// ------------------------------------
			nItem++
			MaFisIniLoad( nItem )
			//Início - Thais Paiva - Compatibilização P27
			//dbSelectArea("SX3")
			//dbSetOrder(1)
			//dbSeek('SC7')
			_aCmpC7 := FWSX3Util():GetAllFields( "SC7" , .F. )
			//While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			For _nC7 := 1  to Len(_aCmpC7)
				cValid	:= StrTran(UPPER(GetSx3Cache(_aCmpC7[_nC7], 'X3_VALID'))," ","") //StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')

				if 'MAFISREF' $ cValid
					nPosRef  := at( 'MAFISREF("' , cValid ) + 10
					cRefCols := substr( cValid , nPosRef , at( '","MT120",' , cValid ) - nPosRef )
// ------------------------------------
//                  [ Carrega os valores direto do SC7. ]
// ------------------------------------
					//MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
					MaFisLoad(cRefCols,&("SC7->"+ GetSx3Cache(_aCmpC7[_nC7], 'X3_CAMPO')),nItem)
				endif

				//dbSkip()
				//End
			Next _nC7
			//Fim - Thais Paiva - Compatibilização P27
			MaFisEndLoad( nItem , 2 )
			dbselectarea( 'SC7' )
			dbskip()

		enddo

	endif
// ------------------------------------
	restarea( aAreaSC7 )
	restarea( aArea    )
// ------------------------------------
return .T.

//Início - Thais Paiva - 9324747
Static Function fLoadData(oProcess, lEnd)
	Local nCountC7
	Local _aAreaC7 := GetArea()
	Local _cPedido := ""

	Default lEnd := .F.

	DbSelectArea("SC7")
	SC7->(DbGoto(nRegSc7))
	_cPedido := SC7->C7_NUM
	nCountC7 := SC7->(RecCount())

	oProcess:SetRegua1(nCountC7)

	While SC7->(!Eof()) .and.  SC7->C7_NUM == _cPedido
		sleep(300)

		If lEnd	//houve cancelamento do processo
			Exit
		EndIf

		oProcess:IncRegua1("Lendo Itens do Pedido: " + SC7->C7_NUM+" - Item: "+SC7->C7_ITEM)

		SC7->(DbSkip())
	End

	RestArea(_aAreaC7)

Return
//Fim - Thais Paiva - 9324747




Static Function xCalcDesc( nValor, nDesc1, nDesc2, nDesc3)
	Local nTotDesc:= 0

	nTotDesc := nValor*nDesc1/100
	nTotDesc := nTotDesc + (nValor-nTotDesc)*nDesc2/100
	nTotDesc := nTotDesc + (nValor-nTotDesc)*nDesc3/100

Return (nTotDesc)
// ----------------------------------------------------------------------------
// [ fim de tewbtyr2.prw ]
// ----------------------------------------------------------------------------


