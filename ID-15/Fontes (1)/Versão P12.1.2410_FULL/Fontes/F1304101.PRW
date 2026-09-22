#INCLUDE 'PROTHEUS.CH'

// --------------------------------------------------------
// {Protheus.doc} F1304101
// Realiza a movimentação interna para efetuar as entradas dos produtos da nota fiscal.
// --------------------------------------------------------
// @project MAN0000007423048_EF_041
// @@type   User Function
// @author  Rafael Riego 
// @since   10/05/2018
// @version 12.1.7
// @param   aItens, array, itens da nota fiscal de entrada
// @param   cNovIdInt, character, novo id de integração gerado para esta integração
// @param   nSF1Recno, numeric, recno do registro da tabela SF1
// @return  lOk, se a movimentação ocorreu com sucesso ou não
// --------------------------------------------------------

user function f1304101( aItens , cNovIdInt , nSF1Recno , cDocNum )

// -------------------------------
	local   aArea       := {}
	local   aLog        := {}
	local   aMovimento  := {}
	local   cErro       := ''
	local   cTipoMov    := ''
	local   lCustoZero  := .F.
	local   lOk         := .T.
	local   nErro       := 0
	local   nItem       := 0
	local   nQtdLinha   := 0
	Local   cVLDALMO    :=getmv( 'MV_VLDALMO' )
// -------------------------------
	private lMsErroAuto := .F.
// -------------------------------
	default aItens      := {}
	default cNovIdInt   := ''
	default nSF1Recno   := 0
	default cDocNum     := ''
// -------------------------------
	aArea    := { getarea() , SD3->( getarea() ) , SF5->( getarea() ) }
	cTipoMov := getmv( 'FS_TMENTAS' )
	dDataBkp := ddatabase
// -------------------------------    
//  aItens:
//  1. SD1->D1_COD
//  2. SD1->D1_QUANT
//  3. SD1->D1_LOCAL
//  4. SD1->D1_CC
//  5. SD1->D1_DTDIGIT
//  6. SD1->D1_CUSTO
//  7. SD1->D1_PEDIDO
//  8. SD1->D1_ITEMPC
// -------------------------------

	if !( empty( cTipoMov ))

		nQtdLinha := len( aItens )

		SF5->( dbsetorder( 1 ))
		if !( SF5->( dbseek( fwxfilial( 'SF5' ) + cTipoMov )))
			cErro := 'Tipo de Movimento ' + cTipoMov + ' não cadastrado.'
			lOk   := .F.
		elseif SF5->F5_TIPO <> 'D'
			cErro := cTipoMov + ' não é um Tipo de Movimento de Entrada.'
			lOk   := .F.
		endif

		if lOk

			if nSF1Recno <> 0
				SF1->( dbgoto( nSF1Recno ))
			endif

			for nItem := 1 to nQtdLinha

				aMovimento := {}

// --------------------------------------------------------
//              [ Verifica se neste trecho deve ser verificado a cada interação do laço ]
// --------------------------------------------------------
				if aItens[nItem][6] == 0   .AND. ;
						SF5->F5_VAL      == 'S'

					lCustoZero := .T.

					if empty( SF5->F5_XTMNVAL )
						lOk      := .F.
						cErro    := 'Tipo de Movimento não valorizado não informado para o TM ' + cTipoMov + '.'
					else
						cTipoMov := SF5->F5_XTMNVAL
						if !( SF5->( dbseek( fwxfilial( 'SF5' ) + cTipoMov )))
							cErro := 'Tipo de Movimento não valorizado ' + cTipoMov + ' não cadastrado.'
							lOk   := .F.
						elseif SF5->F5_VAL == 'S'
							cErro := 'Tipo de Movimento não valorizado ' + cTipoMov + ' configurado incorretamente (F5_VAL).'
							lOk   := .F.
						endif
					endif

				endif

				if lOk

				/*/	ddatabase := aItens[nItem][5]
// --------------------------------------------------------
					aadd(     aMovimento , { 'D3_TM'      , cTipoMov         , Nil } )
					aadd(     aMovimento , { 'D3_COD'     , aItens[nItem][1] , Nil } )
					aadd(     aMovimento , { 'D3_QUANT'   , aItens[nItem][2] , Nil } )
					aadd(     aMovimento , { 'D3_LOCAL'   , aItens[nItem][3] , Nil } )
					aadd(     aMovimento , { 'D3_EMISSAO' , aItens[nItem][5] , Nil } )
// --------------------------------------------------------
					if !( empty( cDocNum ))
						aadd( aMovimento , { 'D3_DOC'     , cDocNum          , Nil } )
					endif
// --------------------------------------------------------
					if !lCustoZero
						aadd( aMovimento , { 'D3_CC'      , aItens[nItem][4] , Nil } )
						aadd( aMovimento , { 'D3_CUSTO1'  , aItens[nItem][6] , Nil } )
					endif
// --------------------------------------------------------
					aadd(     aMovimento , { 'D3_XIDEXNF' , cNovIdInt        , Nil } )
// --------------------------------------------------------
//                  [ dados da nota ]
// --------------------------------------------------------
					aadd(     aMovimento , { 'D3_XNOTA'   , SF1->F1_DOC      , Nil } )
					aadd(     aMovimento , { 'D3_XSERIE'  , SF1->F1_SERIE    , Nil } )
					aadd(     aMovimento , { 'D3_XFORN'   , SF1->F1_FORNECE  , Nil } )
					aadd(     aMovimento , { 'D3_XLJFOR'  , SF1->F1_LOJA     , Nil } )

					aadd(     aMovimento , { 'D3_XDESCTM'  , SF5->F5_TEXTO     , Nil } )
					aadd(     aMovimento , { 'D3_XCONTA'  , SF5->F5_XCONTA  , Nil } )
					aadd(     aMovimento , { 'D3_TEATF'  , SF5->F5_TEATF , Nil } )
// --------------------------------------------------------
					if cVLDALMO == 'S'
						criaSB2( aItens[nItem][1] , aItens[nItem][3] )
					endif
// --------------------------------------------------------
					MsExecAuto( {| movimentacao , operacao| MATA241( movimentacao , operacao ) } , aMovimento , 3 )
/*/

					if cVLDALMO == 'S'
						criaSB2( aItens[nItem][1] , aItens[nItem][3] )
					endif

					DbSelectArea("SD3")
					Reclock("SD3",.T.)
					SD3->D3_FILIAL    := SF1->F1_FILIAL
					SD3->D3_TM        := cTipoMov
					SD3->D3_COD       := aItens[nItem][1]
					SD3->D3_QUANT     := aItens[nItem][2]
					SD3->D3_LOCAL     := aItens[nItem][3] 
					SD3->D3_EMISSAO   := aItens[nItem][5]
					SD3->D3_DOC       := cDocNum
					SD3->D3_CC        := aItens[nItem][4]
					SD3->D3_CUSTO1    := aItens[nItem][6] 
					SD3->D3_XIDEXNF   := cNovIdInt
					SD3->D3_XNOTA     := SF1->F1_DOC
					SD3->D3_XSERIE    := SF1->F1_SERIE
					SD3->D3_XFORN     :=  SF1->F1_FORNECE
					SD3->D3_XLJFOR    := SF1->F1_LOJA
					//SD3->D3_XDESCTM   := SF5->F5_TEXTO
					//SD3->D3_XCONTA    := SF5->F5_XCONTA 
					SD3->D3_TEATF     := SF5->F5_TEATF

					SD3->(MsUnLock())

					/*/FwFreeObj( aMovimento )
					aMovimento := Nil

					if lMsErroAuto
					cErro += 'INCONSISTENCIA DE ROTINA AUTOMATICA - Movimento Interno | ' + CRLF
					aLog  := GetAutoGRLog()
					for nErro := 1 to len( aLog )
						cErro += aLog[nErro] + CRLF
					next nErro
					lOk := .F.
					exit
				Else

					Reclock("SD3",.F.)
					SD3->D3_XCONTA := SF5->F5_XCONTA
					SD3->D3_TEATF := SF5->F5_TEATF
					SD3->(MsUnLock())
					endif/*/
				else
					exit
				endif

			next nItem

		endif

	else
		lOk   := .F.
		cErro := 'Parâmetro "FS_TMENTAS" vazio. Impossível prosseguir com a execução.'
	endif

	ddatabase := dDataBkp

	if !( lOk )
		u_f1303703( cErro , .F. )
	endif

	aeval( aarea, { |area| restarea( area ) } )

return lOk
// --------------------------------------------------------
// [ fim de f1304101.prw ]
// --------------------------------------------------------
