#INCLUDE 'TOTVS.CH'

#DEFINE PRX_LIN chr( 13 ) + chr( 10 )

// -----------------------------------------------------------------------
// {Protheus.doc} F0703302
// Função responsável pela integração de Devolução de Compra
// @type    function
// @author  anieli.rodrigues 
// @since   20/02/2017
// @version 12.7
// @param   oCabec , object , Dados do cabeçalho da nota fiscal
// @param   oCorpo , object , Dados do item      da nota fiscal
// @project MAN0000007423041_EF_033
// @return  cRET
// -----------------------------------------------------------------------

user function f0703302( oCabec , oCorpo )

// -------------------------------------------------------------
	local   aCabec         := {}
	local   aItemPv        := {}
	local   aItens         := {}
	local   aLinha         := {}
	local   aLog           := {}
	local   bBlock         := ErrorBlock( {|e| ChkErr( e ) } )
	local   cFilPed        := ''
	local   cNumPed        := ''
	local   cQry           := ''
	local   cRet           := 'ERRO|'
	local   cAliasTrb      := getnextalias()
	local   cSerie         := ''             // supergetmv( 'FS_SRNFDEV' )
	local   cXID           := u_GetIntegID()
	local   lRet           := .T.
	local   nRegLog        := 0
	local   nTotReg        := 0
	local   nX             := 0
	local   nY             := 0
	local   oCabecAux
	local   dDataBkp       := dDataBase
// -------------------------------------------------------------
	private cErrorL        := ''
	private lAutoErrNoFile := .T.
	private lMsErroAuto    := .F.
	private cUserName      := 'INTNF'
	private dDtValExec     := ctod( '  /  /    ' )
// -------------------------------------------------------------

	BEGIN SEQUENCE

		cFilPed := alltrim( oCabec:cFilReg )

		if empty( cFilPed ) .OR. !existcpo( 'SM0' , cEmpAnt + cFilPed )
			lRet    := .F.
			cRet    += 'PARAMETRO OBRIGATORIO INVALIDO: CFILREG'
		else
			cFilAnt := cFilPed
		endif

		cSerie := supergetmv( 'FS_SRNFDEV' , .F. , '   ' , cFilAnt )

		BEGIN TRANSACTION
			nRegLog := u_f07log01( cXID , { oCabec , oCorpo } )
		END TRANSACTION

// -------------------------------------------------------------
//      if empty( cFilPed ) .OR. !existcpo( 'SM0' , cEmpAnt + cFilPed )
//          lRet    := .F.
//          cRet    += 'PARAMETRO OBRIGATORIO INVALIDO: CFILREG'
//      else
//          cFilAnt := cFilPed
//      endif
// -------------------------------------------------------------

		if empty( cSerie )
			lRet := .F.
			cRet += 'SERIE DA NOTA FISCAL NAO INFORMADA - PARAMETRO FS_SRNFDEV'
		endif

		if lRet

			BEGIN TRANSACTION

// -------------------------------------------------------------
//              [ INÍCIO - VALIDAÇÃO PARA ATUALIZAÇÃO DA NF E PEDIDO ]
// -------------------------------------------------------------
				cQry := " SELECT SF2.F2_FILIAL  , " + PRX_LIN
				cQry += "        SF2.F2_DOC     , " + PRX_LIN
				cQry += "        SF2.F2_SERIE   , " + PRX_LIN
				cQry += "        SF2.F2_CLIENTE , " + PRX_LIN
				cQry += "        SF2.F2_LOJA      " + PRX_LIN
				cQry += "   FROM "                   + retsqlname( 'SF2' )          + " SF2 " + PRX_LIN
				cQry += "  WHERE SF2.D_E_L_E_T_ = ' ' "                                       + PRX_LIN
				cQry += "    AND SF2.F2_FILIAL  = '" +    xfilial( 'SF2' )          + "'"     + PRX_LIN
				cQry += "    AND SF2.F2_XDEVFRO = '" +    alltrim( oCabec:cTagDev ) + "'"     + PRX_LIN
// -------------------------------------------------------------
				cQry := changequery( cQry )
				dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQry ) , cAliasTrb , .T. , .T. )
// -------------------------------------------------------------
				if (cAliasTrb)->( !eof() )

// -------------------------------------------------------------
//                  [ FUNÇÃO RESPONSÁVEL PELO CANCELAMENTO DE DEVOLUÇÃO ]
//                  [ DE NOTA FISCAL DE SAÍDA E PEDIDO DE VENDA         ]
// -------------------------------------------------------------
					oCabecAux          := MontaCab():New()
					oCabecAux:cFILREG  := (cAliasTrb)->F2_FILIAL
					oCabecAux:cDOC     := (cAliasTrb)->F2_DOC
					oCabecAux:cSERIE   := (cAliasTrb)->F2_SERIE
					oCabecAux:cFORNECE := (cAliasTrb)->F2_CLIENTE
					oCabecAux:cLOJA    := (cAliasTrb)->F2_LOJA
					oCabecAux:cDTDEV   := dtoc( ddatabase )
					cRet               := u_f0703308( oCabecAux , 5 , 1 )

					if 'ERRO' $ cRet
						DISARMTRANSACTION()
						BREAK
					endif

				endif

				(cAliasTrb)->( dbclosearea() )
// -------------------------------------------------------------
//              [ TÉRMINO - VALIDAÇÃO PARA ATUALIZAÇÃO DA NF E PEDIDO ]
// -------------------------------------------------------------

				ddatabase := ctod( oCabec:cDtDev )
				lRet      := cararraydev( oCabec , oCorpo , @aCabec , @aItens , cXID , @cRet )

				if !lRet
					ROLLBACKSX8()
					DISARMTRANSACTION()
					BREAK
				endif

				dDtValExec := ctod( oCabec:cDtDev )

				msexecauto( { |x,y,z| mata410( x , y , z ) } , aCabec , aItens , 3 )

				if lMsErroAuto

					cRet += "INCONSISTENCIA DE ROTINA AUTOMATICA | " + CRLF
					aLog := GetAutoGRLog()

					for nY := 1 to len( aLog )
						cRet += aLog[nY] + CRLF
					next nY

					ROLLBACKSX8()
					DISARMTRANSACTION()
					BREAK

				endif

				SC5->( dbordernickname( 'EF0703302' )) // C5_FILIAL + C5_XID
				if SC5->( dbseek( xfilial( 'SC5' ) + cXId ))

					cNumPed := SC5->C5_NUM

					if SC6->( dbseek( xfilial( 'SC6' ) + cNumPed ))

						do while SC5->C5_FILIAL == xfilial( 'SC5' ) .AND. ;
								SC5->C5_NUM    == SC6->C6_NUM

// -------------------------[ fonte original svn ]------------------------
//                            nQtd := MaLibDoFat( SC6->( recno() ) , ;
//                                                SC6->C6_QTDVEN   , ; // --> Quantidade a ser liberada
//                                                .T.              , ; // --> Bloqueio de Credito
//                                                .T.              , ; // --> Bloqueio de Estoque - lBloqueia
//                                                .F.              , ; // --> Avaliacao de Credito
//                                                .F.              , ; // --> Avaliacao de Estoque
//                                                .F.              , ; // --> Permite Liberacao Parcial
//                                                .F.              , ; // --> Tranfere Locais automaticamente
//                                                NIL              , ; // --> Empenhos ( Caso seja informado nao efetua a gravacao apenas avalia )
//                                                NIL              , ; // --> CodBlock a ser avaliado na gravacao do SC9
//                                                NIL              , ; // --> Array (aSaldos) com Empenhos previamente escolhidos (impede selecao dos empenhos pelas rotinas)
//                                                NIL              , ;
//                                                NIL              , ;
//                                                NIL              , ;
//                                                                 , ;
//                                                SC6->C6_QTDVEN     )
// -------------------------[ Marcelo Mendes ]----------------------------
							nQtd := MaLibDoFat( SC6->( recno() ) , ;
								SC6->C6_QTDVEN   , ; // --> Quantidade a ser liberada
							.T.              , ; // --> Bloqueio de Credito
							.T.              , ; // --> Bloqueio de Estoque - lBloqueia
							.T.              , ; // --> Avaliacao de Credito ***
							.T.              , ; // --> Avaliacao de Estoque ***
							.F.              , ; // --> Permite Liberacao Parcial
							.F.              , ; // --> Tranfere Locais automaticamente
							NIL              , ; // --> Empenhos ( Caso seja informado nao efetua a gravacao apenas avalia )
							NIL              , ; // --> CodBlock a ser avaliado na gravacao do SC9
							NIL              , ; // --> Array (aSaldos) com Empenhos previamente escolhidos (impede selecao dos empenhos pelas rotinas)
							NIL              , ;
								NIL              , ;
								NIL              , ;
								, ;
								SC6->C6_QTDVEN     )
// -----------------------------------------------------------------------

							lRet := VldLibPv( SC6->C6_NUM  , ;
								SC6->C6_ITEM , ;
								@cRet          )

							if !lRet
								ROLLBACKSX8()
								DISARMTRANSACTION()
								BREAK
							endif

							SB1->( dbsetorder( 1 )) // B1_FILIAL + B1_COD
							SB1->( dbseek(      xfilial( 'SB1' ) + SC6->C6_PRODUTO ))

							SB2->( dbsetorder( 1 )) // B2_FILIAL + B2_COD + B2_LOCAL
							SB2->( dbseek(      xfilial( 'SB2' ) + SC6->C6_PRODUTO ))

							SF4->( dbsetorder( 1 )) // F4_FILIAL + F4_CODIGO
							SF4->( dbseek(      xfilial( 'SF4' ) + SC6->C6_TES ))

							aadd( aItemPv , { SC6->C6_NUM      , ; // [01]
							SC6->C6_ITEM     , ; // [02]
							SC6->C6_LOCAL    , ; // [03]
							SC6->C6_QTDVEN   , ; // [04]
							SC6->C6_VALOR    , ; // [05]
							SC6->C6_PRODUTO  , ; // [06]
							.F.              , ; // [07]
							SC9->( recno() ) , ; // [08]
							SC5->( recno() ) , ; // [09]
							SC6->( recno() ) , ; // [10]
							SE4->( recno() ) , ; // [11]
							SB1->( recno() ) , ; // [12]
							SB2->( recno() ) , ; // [13]
							SF4->( recno() ) } ) // [14]

							SC6->( dbskip() )

						enddo

						MaLiberOk( { SC5->C5_NUM } , .T. )
						pergunte( 'MT460A' , .F. )

						cNota := MaPvlNfs( aItemPv     , ; // --> Array com os itens a serem gerados
						cSerie      , ; // --> Serie da Nota Fiscal
						.F.         , ; // --> Mostra   Lct.Contabil
						MV_PAR02==1 , ; // --> Aglutina Lct.Contabil
						MV_PAR03==1 , ; // --> Contabiliza On-Line
						MV_PAR04==1 , ; // --> Contabiliza Custo On-Line
						MV_PAR05==1 , ; // --> Reajuste de preco na nota fiscal
						MV_PAR07    , ; // --> Tipo de Acrescimo Financeiro
						MV_PAR08    , ; // --> Tipo de Arredondamento
						MV_PAR15==1 , ; // --> Atualiza Amarracao Cliente x Produto
						MV_PAR16==2   ) // --> Cupom Fiscal

						SC5->( dbsetorder( 1 )) // C5_FILIAL + C5_NUM
						SC5->( dbseek( xfilial( 'SC5' ) + cNumPed ))

						SF2->( dbsetorder( 2 )) // F2_FILIAL + F2_CLIENTE       + F2_LOJA    + F2_DOC  + F2_SERIE + F2_TIPO + F2_ESPECIE
						if SF2->( dbseek(   xfilial( 'SC5' ) + SC5->(C5_CLIENTE + C5_LOJACLI + C5_NOTA + C5_SERIE )))

							cRet := 'OK|' + SC5->C5_NOTA

// -------------------------------------------------------------
//                          [ RAFAEL FALCO - 14/05/2018 ]
//                          [ GRAVAÇÃO DO CAMPO F2_XDEVFRO (MAN0000007423048_EF_036)
// -------------------------------------------------------------
							SF2->( reclock( 'SF2' , .F. ))
							SF2->F2_XDEVFRO := alltrim( oCabec:cTagDev )
							SF2->( msunlock() )

						else
							lRet := .F.
							cRet += 'FALHA NA GERACAO DA NOTA FISCAL'
							DISARMTRANSACTION()
							BREAK
						endif

					else
						lRet := .F.
						cRet += 'FALHA NA GERACAO DO PEDIDO DE VENDAS'
						DISARMTRANSACTION()
						BREAK
					endif

				else
					lRet := .F.
					cRet += 'FALHA NA GERACAO DO PEDIDO DE VENDAS'
					DISARMTRANSACTION()
					BREAK
				endif

			END TRANSACTION

		endif

	END SEQUENCE

	dDataBase := dDataBkp

	ErrorBlock( bBlock )

	if !empty( cErrorL )
		lRet := .F.
		cRet += 'ERRO DE PROGRAMACAO | ' + CRLF + cErrorL
	endif

	if !lRet .OR. lMsErroAuto
		u_f07log02( nRegLog , ;
			cRet    , ;
			.F.     , ;
			'SC5'   , ;
			1       , ;
			xfilial( 'SC5' ) + '|' + cNumPed )
	else
		u_f07log02( nRegLog , ;
			cRet    , ;
			.T.     , ;
			'SC5'   , ;
			1       , ;
			xfilial( 'SC5' ) + '|' + cNumPed )
	endif

return cRet

// -------------------------------------------------------------
// {Protheus.doc} ChkErr
// Função para tratamento de erros
// @type    function
// @author  anieli.rodrigues
// @since   03/02/2017
// @version 12.7
// @param   oErroArq , object , Dados do erro capturado
// @project MAN0000007423041_EF_033
// -------------------------------------------------------------

static function chkerr( oErroArq )

	local nI := 0

	if oErroArq:GenCode > 0
		cErrorL := '(' + alltrim( str( oErroArq:GenCode )) + ') : ' + alltrim( oErroArq:Description ) + CRLF
	endif

	nI := 2

	do while (!empty( ProcName( ni )))
		cErrorL += trim( ProcName( ni )) + '(' + alltrim( str( ProcLine( ni ))) + ') ' + CRLF
		ni ++
	enddo

	if Intransact()
		cErrorL += 'Transacao aberta desarmada'
		DISARMTRANSACTION()
	endif

	BREAK

return

// -------------------------------------------------------------
// {Protheus.doc} CarArrayDev
// Função responsável pela montagem do array para do pedido de venda de devolução
// @type function
// @author  anieli.rodrigues
// @since   22/02/2017
// @version 12.7
// @param   oCabec , object    , Dados dos cabeçalho do pedido de venda de devolução
// @param   oCorpo , object    , Dados do item       do pedido de venda de devolução
// @param   aCabec , array     , Variavel para montagem do array de cabeçalho (referencia)
// @param   aItens , array     , Variavel para montagem do array de itens     (referencia)
// @param   cXID   , caractere , ID unico reservado para a integração
// @param   cRet   , caractere , Variavel para armazenar mensagem de erro     (referencia)
// @project MAN0000007423041_EF_033
// @return  lRet
// -------------------------------------------------------------
static function CarArrayDev( oCabec , oCorpo , aCabec , aItens , cXID , cRet )

// -------------------------------------------------------------
	local aConv      := {}
	local aLinha     := {}
	local aTrava     := {} // Marcelo Mendes
	local cItem      := strzero( 0 , tamsx3( 'C6_ITEM' )[1] )
	local cTESDev    := ''
	local lRet       := .T.
	local nTamDoc    := tamsx3( 'F1_DOC'     )[1]
	local nTamFor    := tamsx3( 'F1_FORNECE' )[1]
	local nTamIt     := tamsx3( 'D1_ITEM'    )[1]
	local nTamLoja   := tamsx3( 'F1_LOJA'    )[1]
	local nTamProd   := tamsx3( 'D1_COD'     )[1]
	local nTamSer    := tamsx3( 'F1_SERIE'   )[1]
	local nX         := 0
	local nQtdTotDev := 0
	local nQtdNoPed  := 0
	local nQtdDoItem := 0
	local cSD1Chave  := ''
	Local nTamPrcVen:= TamSX3("C6_PRCVEN")[2]
// -------------------------------------------------------------

	SF1->( dbsetorder( 1 )) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
	if SF1->( dbseek(   xfilial( 'SF1' ) + padr( oCabec:cDoc     , nTamDoc  ) + ;
			padr( oCabec:cSerie   , nTamSer  ) + ;
			padr( oCabec:cFornece , nTamFor  ) + ;
			padr( oCabec:cLoja    , nTamLoja ) ) )

		aadd( aCabec , { 'C5_TIPO'    , 'D'                   , NIL } )
		aadd( aCabec , { 'C5_CLIENTE' , oCabec:cFornece	      , NIL } )
		aadd( aCabec , { 'C5_LOJAENT' , oCabec:cLoja          , NIL } )
		aadd( aCabec , { 'C5_LOJACLI' , oCabec:cLoja          , NIL } )
		aadd( aCabec , { 'C5_CONDPAG' , SF1->F1_COND          , NIL } )
		aadd( aCabec , { 'C5_ORIGEM'  , 'F0703203'            , NIL } )
		aadd( aCabec , { 'C5_XID'     , cXID                  , NIL } )
		aadd( aCabec , { 'C5_EMISSAO' , ctod( oCabec:cDtDev ) , NIL } )

		for nX := 1 to len( oCorpo )

			cSD1Chave := xfilial( 'SD1' )                       + ;
				padr( oCabec:cDoc         , nTamDoc  ) + ;
				padr( oCabec:cSerie       , nTamSer  ) + ;
				padr( oCabec:cFornece     , nTamFor  ) + ;
				padr( oCabec:cLoja        , nTamLoja ) + ;
				padr( oCorpo[nX]:cProduto , nTamProd )
			SD1->( dbsetorder( 1 )) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
			SD1->( dbgotop() ) // Marcelo Mendes
			if SD1->( dbseek( cSD1Chave ))

				If SD1->D1_VALDESC < 1
					Reclock("SD1",.F.)
					SD1->D1_VALDESC := 0
					SD1->(msunlock())
				EndIf


// -------------[ Marcelo Mendes ]----------------------------------------

				if len( aTrava ) == 0

					aadd( atrava , SD1->D1_COD  )
					aadd( atrava , SD1->D1_ITEM )
					aadd( atrava , 0            )

				elseif aTrava[1] == SD1->D1_COD .AND. ;
						aTrava[2] == SD1->D1_ITEM

					if aTrava[3] == 0
						SD1->( dbskip() )
						aTrava[3] := aTrava[3] + 3
					else
						SD1->( dbskip( aTrava[3] ))
						aTrava[3] := aTrava[3] + 1
					endif

				else

					aTrava := {}
					aadd( aTrava , SD1->D1_COD  )
					aadd( aTrava , SD1->D1_ITEM )
					aadd( aTrava , 0            )

				endif
// -----------------------------------------------------------------------

				aConv := u_f07024x( padr( oCorpo[nX]:cProduto , nTamProd ) , ;
					cFilAnt                                , ;
					val( oCorpo[nX]:cQtdVen ) , 1 , 2 )

				if !empty( aConv[3] )
					lRet := .F.
					cRet += aConv[3]
					exit
				endif

				nQtdTotDev := aConv[1]
				nQtdNoPed  := 0

				do while nQtdTotDev != nQtdNoPed .AND. ;
						!SD1->( eof() )         .AND. ;
						cSD1Chave == SD1->( D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD )

					aLinha := {}

					if SD1->( D1_QUANT - D1_QTDEDEV ) == 0
						SD1->( dbskip() )
						loop
					endif

					nQtdDoItem := ( aConv[1] - nQtdNoPed )

					if nQtdDoItem > SD1->( D1_QUANT - D1_QTDEDEV )
						nQtdDoItem := SD1->( D1_QUANT - D1_QTDEDEV )
					endif

					nQtdNoPed += nQtdDoItem
					cItem     := soma1( cItem )
					cTESDev   := posicione( 'SF4' , 1 , xfilial( 'SF4' ) + SD1->D1_TES , 'F4_TESDV' )
					nValor    := val( oCorpo[nX]:cValor ) - SD1->D1_VALDESC

					aadd( aLinha , { 'C6_ITEM'    , cItem               , NIL } )
					aadd( aLinha , { 'C6_PRODUTO' , oCorpo[nX]:cProduto , NIL } )
					aadd( aLinha , { 'C6_QTDVEN'  , nQtdDoItem          , NIL } )
					aadd( aLinha , { 'C6_TES'     , cTESDev             , NIL } )
					aadd( aLinha , { 'C6_NFORI'   , SD1->D1_DOC         , NIL } )
					aadd( aLinha , { 'C6_SERIORI' , SD1->D1_SERIE       , NIL } )
					aadd( aLinha , { 'C6_ITEMORI' , SD1->D1_ITEM        , NIL } )
					aadd( aLinha , { 'C6_VALDESC' , SD1->D1_VALDESC     , NIL } )

// -------------------------------------------------------------
//                  [ ID 1517 ]
//                  [ Retira este calculo e pega o valor do D1_VUNIT ]
// -------------------------------------------------------------
//                  if !empty( oCorpo[nX]:cValor )
//                      aadd( aLinha , { 'C6_PRUNIT' , round( nValor / aConv[1] , 6 ) , NIL } )
//                      aadd( aLinha , { 'C6_PRCVEN' , round( nValor / aConv[1] , 6 ) , NIL } )
//                  endif
// -------------------------------------------------------------
					//nTotal := Round(( nQtdDoItem * SD1->D1_VUNIT ) - SD1->D1_VALDESC,6)
					//Lucas Miranda de Aguiar - Correção erro do valor
					nPrc := a410Arred((SD1->D1_VUNIT-(SD1->D1_VALDESC/SD1->D1_QUANT)),"C6_PRCVEN")
					nTotal := a410Arred(nQtdDoItem*a410Arred((SD1->D1_VUNIT-(SD1->D1_VALDESC/SD1->D1_QUANT)),"C6_PRCVEN"),"C6_VALOR")
					//Fim
//                    if !empty( oCorpo[nX]:cValor )
//                        aadd( aLinha , { 'C6_PRUNIT' , SD1->D1_VUNIT , NIL } )
//                        aadd( aLinha , { 'C6_PRCVEN' , SD1->D1_VUNIT , NIL } )
//                    endif

					if !empty( oCorpo[nX]:cValor )
						aadd( aLinha , { 'C6_PRUNIT' , SD1->D1_VUNIT , NIL } )
						aadd( aLinha , { 'C6_PRCVEN' , nPrc , NIL } )
						aadd( aLinha , { 'C6_VALOR'  , nTotal        , NIL } )
					endif


// -------------------------------------------------------------
//                  [ Fim ID 1517 ]
// -------------------------------------------------------------
//                  if !empty( oCorpo[nX]:cValor )
//                      aadd( aLinha , { 'C6_PRUNIT' , val( oCorpo[nX]:cValor ) / aConv[1] , NIL } )
//                      aadd( aLinha , { 'C6_PRCVEN' , val( oCorpo[nX]:cValor ) / aConv[1] , NIL } )
//                  endif
// -------------------------------------------------------------

					aadd( aItens , aLinha )

					SD1->( dbskip() )

				enddo

				if nQtdTotDev != nQtdNoPed
					lRet := .F.
					cRet += 'NAO HA SALDO SALDO DISPONIVEL PARA DEVOLUCAO DA NOTA.'
					exit
				endif

			else
				lRet := .F.
				cRet += 'PRODUTO DA NOTA FISCAL ORIGINAL NAO LOCALIZADO'
			endif

		next nX

	else
		lRet := .F.
		cRet += 'NOTA FISCAL ORIGINAL A DEVOLVER NAO LOCALIZADA'
	endif

return lRet

// -------------------------------------------------------------
// {Protheus.doc} VldLibPv
// Função responsável pela validacao da liberacao do pedido de venda
// @type    function
// @author  anieli.rodrigues
// @since   22/02/2017
// @version 12.7
// @param   cNum  , caractere , Número do pedido de venda
// @param   cItem , caractere , Item   do pedido de venda
// @param   cRet  , caractere , Variavel para armazenar mensagem de erro (referencia)
// @project  MAN0000007423041_EF_033
// @return   lRet
// -------------------------------------------------------------

static function VldLibPv( cNum , cItem , cRet )

	local lRet := .T.

	SC9->( dbsetorder( 1 )) // C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED
	if !SC9->(dbseek( xfilial( 'SC9' ) + cNum + cItem ))
		lRet := .F.
		cRet += 'ITEM: ' + SC6->C6_ITEM + ' FALHA NA LIBERACAO DO PEDIDO'
	endif

	if !empty( SC9->C9_BLEST )

		lRet := .F.

		if SC9->C9_BLEST == '02'
			cRet += 'ITEM: ' + SC6->C6_ITEM + ' FALHA NA LIBERACAO DE PEDIDO - BLOQUEIO DE ESTOQUE'
		elseif SC9->C9_BLEST == '03'
			cRet += 'ITEM: ' + SC6->C6_ITEM + ' FALHA NA LIBERACAO DE PEDIDO - BLOQUEIO MANUAL'
		elseif SC9->C9_BLEST == '10'
			cRet += 'ITEM: ' + SC6->C6_ITEM + ' FALHA NA LIBERACAO DE PEDIDO - JA FATURADO'
		endif

	endif

return lRet

// -------------------------------------------------------------
// [ Monta a classe e método para excluir a NF de devolução ]
// -------------------------------------------------------------

	CLASS MontaCab

		data cFILREG
		data cDOC
		data cSERIE
		data cFORNECE
		data cLOJA
		data cDTDEV

//  Declaração dos Métodos da Classe
		METHOD New() CONSTRUCTOR
	ENDCLASS

// Monta o objeto para processar o estorno da NF de saída
METHOD New() Class MontaCab
	::cFILREG  := ''
	::cDOC     := ''
	::cSERIE   := ''
	::cFORNECE := ''
	::cLOJA    := ''
	::cDTDEV   := ''

return Self

// -------------------------------------------------------------
// [ fim de f0703302.prw ]
// -------------------------------------------------------------
