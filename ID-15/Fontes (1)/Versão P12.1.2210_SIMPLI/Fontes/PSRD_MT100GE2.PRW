#INCLUDE 'PROTHEUS.CH'

// ----------------------------------------------------------------------------
// {Protheus.doc}  MT100GE2()
// Ponto de entrada para gravações complementares na nota de entrada
// @Author  Ramon Teodoro e Silva	
// @Since   10/05/2017       
// @Version P12.7
// ----------------------------------------------------------------------------
user function mt100ge2()
// ------------------------------------
	local aArea     := getarea()
	local lRet      := .T.
	local nPosCC    := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_CC'      } )
	local nPosRat   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_RATEIO'  } )
	local nPosIns   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XRETINS' } )
	local nPosLot   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_LOTEFOR' } )
	local nPosCCo   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XCODCON' } )
	local nPosVIt   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_TOTAL'   } )
	local nPosJur   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XJURMUL' } )
	local nPosMul   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XMULTA'  } )
	local nPosVen   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XPRIVEN' } )
	local nPosXDes  := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XDESFIN' } )
	local nPosRec   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XCODREC' } )
	local nPosNtRec := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XNATREC' } )
	local nPosObs   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XOBS' } )
	local aTitPar   := u_retparcela( SF1->F1_COND )
	local nQtdPar   := len( aTitPar )
	local nI        := 0
	local nValDes   := 0
	local nDesFin   := 0
	local nDescNF   := 0
	local nJuros    := 0
	local nMulta    := 0
	local nTotPer   := 0
	local nXDescF   := 0
	local lNatRec   := SE2->(FieldPos("E2_XNATREC")) > 0 .And. SD1->(FieldPos("D1_XNATREC")) > 0
	Local dDtOrig   := ""
	local lISSBaixa := getnewpar(  'MV_MRETISS' , '1' ) == '2'
	local lPCCBaixa := supergetmv( 'MV_BX10925' , .T. , '2' ) == '1' .AND. ;
		( !empty( SE5->( fieldpos( 'E5_VRETPIS' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_VRETCOF' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_VRETCSL' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_PRETPIS' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_PRETCOF' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_PRETCSL' )))     .AND. ;
		!empty( SE2->( fieldpos( 'E2_SEQBX'   )))     .AND. ;
		!empty( SFQ->( fieldpos( 'FQ_SEQDES'  )))           )
// ------------------------------------
//  alert( '[ MT100GE2 ] Inicio')
// ------------------------------------
	nDesFin := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XDESFIN' )
	cTipoSp := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XTPSP' )
	
	If SC7->(FieldPos("C7_XNUMPRO")) > 0
		cxNumPro := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XNUMPRO' )
		SE2->E2_XNUMPRO := cxNumPro
		SE2->E2_XDARFRF := NoAcento(AnsiToOem(AllTrim(cxNumPro)))
	EndIf
	If SC7->(FieldPos("C7_XTPCJU")) > 0
		SE2->E2_XTPCJU := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XTPCJU' )
	EndIf

	
	for nI := 1 to len( aCols )

		if !aCols[nI][len( aCols[nI] ) ]
// ------------------------------------
//          posicione( 'SC7' , 2 , xfilial( 'SC7' ) + aCols[nI][nPosCod] + SD1->D1_FORNECE + SD1->D1_LOJA + aCols[nI][nPosPed] , 'C7_XDESFIN' )
// ------------------------------------
			nTotPer += noround( ( ( nDesFin * aCols[nI][nPosVIt] ) / SE2->E2_VALOR ) , 3 )

			If lNatRec
				If !Empty(aCols[nI][nPosNtRec]) 
					SE2->E2_XNATREC := aCols[nI][nPosNtRec]
				EndIf
			EndIf

		endif

		nJuros  += aCols[nI][nPosJur ] // despesa
		nMulta  += aCols[nI][nPosMul ]
// ------------------------------------
//      nXDescF += aCols[nI][nPosXDes] // desconto financeiro da sol. de pagto
// ------------------------------------

	next nI

	nTotPer := round( nTotPer , 1 ) / nQtdPar
	nValDes += ( nTotPer * SE2->E2_VALOR ) / 100 // desconto financeiro do pedido

// ------------------------------------
//  if SF1->F1_DESCONT > 0
//      nDescNF := SF1->F1_DESCONT / nQtdPar // desconto da nota 
//  endif
// ------------------------------------

	if SF1->F1_XSOLPAG == '1'//Se for Material, não leva o desconto
		nValDes := nDesFin // nXDescF // desconto finaceiro da solicitação de pagamento
	endif

// ------------------------------------
//    if aTitPar[1][1] == SE2->E2_VENCTO .OR. ;
//       nQtdPar       <= 1
// ------------------------------------
//  [ somente primeira parcela ]
// ------------------------------------
/*/	if empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
			SE2->E2_PARCELA = '1' .OR. ;
			SE2->E2_PARCELA = 'a' .OR. ;
			SE2->E2_PARCELA = 'A'
// ------------------------------------
		if !(cTipoSp $ "2|3")//Se for material não preenche o desconto financeiro.
			SE2->E2_DECRESC := nValDes // desconto financeiro + desconto no momento da classificaçao
			SE2->E2_SDDECRE := nValDes
		endif
		SE2->E2_JUROS   := nJuros
		SE2->E2_MULTA   := nMulta
// ------------------------------------
	endif/*/


	if empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
			AllTrim(SE2->E2_PARCELA) == '1' .OR. ;
			SE2->E2_PARCELA == Replicate("a",TamSx3("E2_PARCELA")[1]) .OR. ;
			SE2->E2_PARCELA == Replicate("A",TamSx3("E2_PARCELA")[1]) .OR. ;
			SE2->E2_PARCELA == Replicate("0",(TamSx3("E2_PARCELA")[1] - 1)) + "1"

		if !(cTipoSp $ "2|3")//Se for material não preenche o desconto financeiro.
			SE2->E2_DECRESC := nValDes // desconto financeiro + desconto no momento da classificaçao
			SE2->E2_SDDECRE := nValDes
		endif
		SE2->E2_JUROS   := nJuros
		SE2->E2_MULTA   := nMulta
	EndIf
// ------------------------------------

// Rafael Yera Barchi - 20/08/2021
// Chamado 12248559
// Gravação do campo Risco Sacado para que o título seja gerado conforme cadastro do fornecedor
If SE2->(FieldPos("E2_XRISCOS")) > 0 .And. SA2->(FieldPos("A2_XRISSAC")) > 0
	SE2->E2_XRISCOS := SA2->A2_XRISSAC
EndIf

//Lucas Miranda de Aguiar - Inicio
	SE2->E2_XOBSSP := aCols[1][nPosObs]
	SE2->E2_XHRCLAS := Time()

	SE2->E2_XDTORIG := SF1->F1_XDTORIG
	SE2->E2_XDTEXCE := SF1->F1_XDTEXCE
	SE2->E2_XVALNOM := SF1->F1_XVALNOM

	If SF1->F1_XSOLPAG <> '1'
		dDtOrig := fGetDtOri()
		If TYPE ("xfDtExce") == "C"
			SE2->E2_XDTEXCE := xfDtExce
			SE2->E2_XDTORIG := dDtOrig

			Reclock("SF1",.F.)
			SF1->F1_XDTEXCE := xfDtExce
			SF1->F1_XDTORIG := dDtOrig
			SF1->(MsUnlock())
		EndIf
	EndIf

	If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
		SE2->E2_XDTFIX := "1"
	Else
		SE2->E2_XDTFIX := "2"
	EndIf
//Fim

	SE2->E2_RETINS  := aCols[1][nPosIns]

	if empty( alltrim( SE2->E2_CODRET ))
		SE2->E2_CODRET := aCols[1][nPosRec]
	endif

	if aCols[1][nPosRat] = '2'
		SE2->E2_CCUSTO := aCols[1][nPosCC]
	endif

	SE2->E2_HIST    := aCols[1][nPosLot]
	SE2->E2_XVLBRUT := SF1->F1_VALMERC // nQtdPar
	SE2->E2_XTPREQ  := SF1->F1_XTIPO
	SE2->E2_XCGCFOR := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SE2->( E2_FORNECE + E2_LOJA ) , 'A2_CGC'     )
	SE2->E2_XFORPAG := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SE2->( E2_FORNECE + E2_LOJA ) , 'A2_XCNPJPG' )

	if !(cTipoSP $ "2|3")
		SE2->E2_XDTAPRO := SF1->F1_RECBMTO
	endif

	SE2->E2_XUSNOME := usrfullname( retcodusr() )
	SE2->E2_XDTINT  := date()
	SE2->E2_XVLLIQ  := SE2->( E2_VALOR + E2_MULTA + E2_JUROS + E2_ACRESC - E2_DECRESC )

	if !Empty(SD1->D1_XNATURE) .And. cTipoSp != "1"
		SE2->E2_NATUREZ := SD1->D1_XNATURE
	endif
	if cTipoSP $ "2|3"//Se For material, atualiza o tipo como NFE
		SE2->E2_TIPO := "NFE"
	endif

	if lPCCBaixa
		SE2->E2_XVLLIQ -= SE2->( E2_PIS + E2_COFINS + E2_CSLL )
	endif

	if lISSBaixa
		SE2->E2_XVLLIQ -= SE2->E2_ISS
	endif

	SE2->E2_PORTADO := u_portauto( 'E2_PORTADO' )
	SE2->E2_XAGEPOR := u_portauto( 'E2_XAGEPOR' )
	SE2->E2_XDVAPOR := u_portauto( 'E2_XDVAPOR' )
	SE2->E2_XCONPOR := u_portauto( 'E2_XCONPOR' )
	SE2->E2_XDVCPOR := u_portauto( 'E2_XDVCPOR' )

	if SE2->E2_PORTADO == SE2->E2_FORBCO
		SE2->E2_FORMPAG := '01' // Transf. Conta Corrente
	else
		SE2->E2_FORMPAG := '41' // TED
	endif

	//if isincallstack( 'U_F1000301' )

	if !Empty(aCols[1][nPosCCo])
		SE2->E2_XCODCON := aCols[1][nPosCCo]
	endif

	if nQtdPar <= 1

		if !empty( aCols[1][nPosVen] )
			SE2->E2_VENCTO  :=             aCols[1][nPosVen]
			SE2->E2_VENCREA := datavalida( aCols[1][nPosVen] , .T. )
		endif

	endif

	//endif

	restarea( aArea )

return lRet

// ----------------------------------------------------------------------------
// {Protheus.doc}  MTA100GE2()
// Retorna a quantidade de parcelas da nota 
// @Author  Ramon Teodoro e Silva	
// @Since   10/05/2017       
// @Version P12.7
// ----------------------------------------------------------------------------

user function retparcela( cCond )
// ------------------------------------
	local aRet  := {}
	local aArea := getarea()
// ------------------------------------
	aRet := condicao( 1 , cCond )
	restarea( aArea )
return aRet

// ----------------------------------------------------------------------------
// [ fim de rd_mt100ge2.prw ]
// ----------------------------------------------------------------------------



Static Function fGetDtOri()

	Local aArea := GetArea()
	Local dData := Condicao(100, SF1->F1_COND , , SF1->F1_EMISSAO , , , , )[1][1]



	RestArea(aArea)
Return dData
