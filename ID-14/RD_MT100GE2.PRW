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
	local nPosNtRec := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XNATREC' } )
	local nPosRec   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XCODREC' } )
	Local lFilSimp  := U_VALSIMP(cFilAnt)
	Local cTipoSp 	:= ""
	local nPosObs   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XOBS' } )
	local aTitPar   := u_retparcela( SF1->F1_COND )
	local nQtdPar   := len( aTitPar )
	local nI        := 0
	local nValDes   := 0
	local nDesFin   := 0
	local nDesFinSp := 0
//	local nDescNF   := 0
	local nJuros    := 0
	local nMulta    := 0
	local nTotPer   := 0
	local aCamposJuri := {}
//	local nXDescF   := 0
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
	Local cC7DbAut := ""
// ------------------------------------
//  alert( '[ MT100GE2 ] Inicio')
// ------------------------------------
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	If SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO))
		cC7DbAut := SC7->C7_XDBAUT
		While SC7->(!EOF()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == SD1->D1_PEDIDO
			nDesFinSp := nDesFinSp + SC7->C7_XDESFIN
			SC7->(DbSkip())
		EndDo
	EndIf

	If SC7->(FieldPos("C7_XDESFIN")) > 0
		nDesFin := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XDESFIN' )
	EndIf
	if lFilSimp
		cTipoSp := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XTPSP' )
	endif
	If SC7->(FieldPos("C7_XNUMPRO")) > 0
		cxNumPro := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XNUMPRO' )
		SE2->E2_XNUMPRO := cxNumPro//posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XNUMPRO' )
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

	If SF1->(FieldPos("F1_XSOLPAG")) > 0
		if SF1->F1_XSOLPAG == '1'
			nValDes := nDesFinSp // nXDescF // desconto finaceiro da solicitação de pagamento
		endif
	EndIf

// ------------------------------------
//    if aTitPar[1][1] == SE2->E2_VENCTO .OR. ;
//       nQtdPar       <= 1
// ------------------------------------
//  [ somente primeira parcela ]
// ------------------------------------
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
			SE2->E2_XTXEXPE := SF1->F1_XTXEXPE // ticket n° 10326179 -- gravação Tx Expediente
// ------------------------------------
	endif
// ------------------------------------

// Rafael Yera Barchi - 20/08/2021
// Chamado 12248559
// Gravação do campo Risco Sacado para que o título seja gerado conforme cadastro do fornecedor
If SE2->(FieldPos("E2_XRISCOS")) > 0 .And. SA2->(FieldPos("A2_XRISSAC")) > 0
	SE2->E2_XRISCOS := SA2->A2_XRISSAC
EndIf

//Lucas Miranda de Aguiar - Inicio
	If SE2->(FieldPos("E2_XOBSSP")) > 0 .And. nPosObs > 0
		SE2->E2_XOBSSP := aCols[1][nPosObs]
	EndIf
	If SE2->(FieldPos("E2_XHRCLAS")) > 0
		SE2->E2_XHRCLAS := Time()
	EndIf
	If SE2->(FieldPos("E2_XDTORIG")) > 0 .And. SF1->(FieldPos("F1_XDTORIG")) > 0
		SE2->E2_XDTORIG := SF1->F1_XDTORIG
	EndIf
	If SE2->(FieldPos("E2_XDTEXCE")) > 0 .And. SF1->(FieldPos("F1_XDTEXCE")) > 0
		SE2->E2_XDTEXCE := SF1->F1_XDTEXCE
	EndIf
	If SE2->(FieldPos("E2_XVALNOM")) > 0 .And. SF1->(FieldPos("F1_XVALNOM")) > 0
		SE2->E2_XVALNOM := SF1->F1_XVALNOM
	EndIf

	If SF1->(FieldPos("F1_XSOLPAG")) > 0 .And. SE2->(FieldPos("E2_XDTORIG")) > 0 .And. SE2->(FieldPos("E2_XDTEXCE")) > 0
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
	EndIf

	If SE2->(FieldPos("E2_XDTFIX")) > 0 .And. SA2->(FieldPos("A2_XDTFIX")) > 0
		If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
			SE2->E2_XDTFIX := "1"
		Else
			SE2->E2_XDTFIX := "2"
		EndIf
	EndIf
//Fim

	If nPosIns > 0
		SE2->E2_RETINS  := aCols[1][nPosIns]
	EndIf

	If nPosRec > 0
		if empty( alltrim( SE2->E2_CODRET ))
			SE2->E2_CODRET := aCols[1][nPosRec]
		endif
	EndIf

	If nPosRat > 0
		if aCols[1][nPosRat] = '2'
			SE2->E2_CCUSTO := aCols[1][nPosCC]
		endif
	EndIf

	If nPosLot > 0
		SE2->E2_HIST    := aCols[1][nPosLot]
	EndIf
	If SE2->(FieldPos("E2_XVLBRUT")) > 0
		SE2->E2_XVLBRUT := SF1->F1_VALMERC // nQtdPar
	EndIf
	If SE2->(FieldPos("E2_XTPREQ")) > 0 .And. SF1->(FieldPos("F1_XTIPO")) > 0
		SE2->E2_XTPREQ  := SF1->F1_XTIPO
	EndIf
	If SE2->(FieldPos("E2_XCGCFOR")) > 0
		SE2->E2_XCGCFOR := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SE2->( E2_FORNECE + E2_LOJA ) , 'A2_CGC'     )
	EndIf
	If SE2->(FieldPos("E2_XFORPAG")) > 0
		SE2->E2_XFORPAG := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SE2->( E2_FORNECE + E2_LOJA ) , 'A2_XCNPJPG' )
	EndIf
	If SE2->(FieldPos("E2_XDTAPRO")) > 0
		if !(cTipoSP $ "2|3")
			SE2->E2_XDTAPRO := SF1->F1_RECBMTO
		endif
	EndIf
	If SE2->(FieldPos("E2_XUSNOME")) > 0
		SE2->E2_XUSNOME := usrfullname( retcodusr() )
	EndIf
	If SE2->(FieldPos("E2_XDTINT")) > 0
		SE2->E2_XDTINT  := date()
	EndIf

	If SE2->(FieldPos("E2_XVLLIQ")) > 0
	
		SE2->E2_XVLLIQ  := SE2->( E2_VALOR + E2_MULTA + E2_JUROS + E2_XTXEXPE + E2_ACRESC - E2_DECRESC ) // ticket n° 10326179
	
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

	EndIf

	If ExistBlock("PORTAUTO")
		SE2->E2_PORTADO := u_portauto( 'E2_PORTADO' )
		If SE2->(FieldPos("E2_XAGEPOR")) > 0
			SE2->E2_XAGEPOR := u_portauto( 'E2_XAGEPOR' )
		EndIf
		If SE2->(FieldPos("E2_XDVAPOR")) > 0
			SE2->E2_XDVAPOR := u_portauto( 'E2_XDVAPOR' )
		EndIf
		If SE2->(FieldPos("E2_XCONPOR")) > 0
			SE2->E2_XCONPOR := u_portauto( 'E2_XCONPOR' )
		EndIf
		If SE2->(FieldPos("E2_XDVCPOR")) > 0
			SE2->E2_XDVCPOR := u_portauto( 'E2_XDVCPOR' )
		EndIf
	EndIf

	if SE2->E2_PORTADO == SE2->E2_FORBCO
		SE2->E2_FORMPAG := '01' // Transf. Conta Corrente
	else
		SE2->E2_FORMPAG := '41' // TED
	endif

	//Melhoria campo debito automatico
	//Lucas Miranda de Aguiar 18/09/2024
	SE2->E2_XDBAUT := cC7DbAut

	if isincallstack( 'U_F1000301' )

		If SE2->(FieldPos("E2_XCODCON")) > 0
			SE2->E2_XCODCON := aCols[1][nPosCCo]
		EndIf

		if nQtdPar <= 1

			if !empty( aCols[1][nPosVen] )
				SE2->E2_VENCTO  :=             aCols[1][nPosVen]
				SE2->E2_VENCREA := datavalida( aCols[1][nPosVen] , .T. )
			endif

		endif
	elseif lFilSimp
		If SE2->(FieldPos("E2_XCODCON")) > 0
			SE2->E2_XCODCON := aCols[1][nPosCCo]
		EndIf

		if nQtdPar <= 1

			if !empty( aCols[1][nPosVen] )
				SE2->E2_VENCTO  :=             aCols[1][nPosVen]
				SE2->E2_VENCREA := datavalida( aCols[1][nPosVen] , .T. )
			endif

		endif
	endif

	//Gian 25/08/2021
	If FindFunction('U_F2000418')
		U_F2000418() //Grava Operação Financeira do XRT no título
	EndIf

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
