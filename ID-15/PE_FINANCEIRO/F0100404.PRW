#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"



// ------------------------------------------------------------------
// {Protheus.doc} F0100404()
// LiberaÃ§Ã£o de documento
// @Author     Mick William da Silva
// @Since      05/05/2016
// @Version    P12.7
// @Project    MAN00000462901_EF_004
// ------------------------------------------------------------------

user function F0100404()

// --------------------------------------------------------
	local   aAreas       := { SCR->( getarea() ) , SF1->( getarea() ) , SD1->( getarea() ) , SC7->( getarea() ) , getarea()   }
	local   bProcPreNota := {||}
	local   cFilDoc      := SCR->CR_FILIAL
	local   cNumPedido   := alltrim( PARAMIXB[1] )
	//local   cConta       := ''
	local   cChave       := ''
	local   cUFOri       := ''
	local   lValido      := .F.
	local   lExistPed    := .F.
	local   lSolicPag    := .F.
	local   lExistDE     := .F. // inclui por rujany guedes - verIficar se não existe o documento de entrada para não executar a execauto de geraÃ§Ã£o
	local   nOpc         := 0
	local   nOper        := PARAMIXB[3] // 1- Aprovar, 2-Estornar, 3-Aprovar pelo superior, 4-Transferir pelo superior, 5-Rejeitar, 6-Bloquear
	local   lRejeitado   := .F.
	local   nRecNP       := 0 // #8135327
	
	local   aProds       := {}
// --------------------------------------------------------
	private cEmailEmit   := '' // UsrRetMail( SC7->C7_XUSR )
	private nOpcOper     := 0
	private aCabec       := {}
	private aItens       := {}
	private aLinha       := {}
	private lMsErroAuto  := .F.
	private cObs         := ''
	PRIVATE XXDOC 		 := Space(TAMSX3("F1_DOC")[1])
	PRIVATE XXSERIE      := Space(TAMSX3("F1_SERIE")[1])
	PRIVATE XXFORN       := SPACE(TAMSX3("F1_FORNECE")[1])
	PRIVATE XXLOJA       := SPACE(TAMSX3("F1_LOJA")[1])
	Private cxProds      := ""
	Private cLog     := ""
	Private lValidou     := .T.
	Private nCdControl := 0
	Private cChaveC7 := ""
	Private cUsr     := ""
	Private aVlProd := {}
	PRIVATE XcOND  := ""
	Private XDvenC7 := ""
	Private xExDtFx := ""
	Private xTxExpe := ""
	Private lImpClas := SuperGetMV("FS_IMPCLAS",.F.,.T.) //PARAMETRO PARA DESLIGAR A CUSTOMIZAÇÃO
	Private lTpMaterial := .F.
	private lFilSimp := U_VALSIMP(cFilant)
	Private lValorSol := .F.
	Private lBaseSol := .F.
	Private lRejeitaSup := .F.
	Private lBloqueiaSup := .F.
	Private lTipoPC 	:= .F.
	Private lExistNF 	:= .F.
	Private lClassAut 	:= .T.
	Private lNatdef 	:= .F.
	
	Private nBaseIns := 0
    Private nAliqIns := 0
	Private nValIns := 0
	
	Private nBaseIss := 0
    Private nAliqIss := 0
	Private nValIss := 0

	Private nBaseIr  := 0
    Private nAliqIr  := 0
	Private nValIr   := 0

    Private nBaseSol := 0

    Private nBaseCof := 0
    Private nAliqCof := 0
	Private nValCof  := 0
    Private nBasePis := 0
	Private nAliqPis := 0
	Private nValPis  := 0
    Private nBaseCsl := 0
    Private nAliqCsl := 0
	Private nValCsl  := 0

	Private lIr     := .F.
	Private lIss 	:= .F.
	Private lInss 	:= .F.

	

	Public xfDtExce      := "1"
// --------------------------------------------------------
//  #DEFINE OP_LIB "001" // Liberado
//  #DEFINE OP_EST "002" // Estornar
//  #DEFINE OP_SUP "003" // Superior
//  #DEFINE OP_TRA "004" // Transferir Superior
//  #DEFINE OP_EST "005" // Estorna
//  #DEFINE OP_REJ "006" // Rejeitado
//  #DEFINE OP_BLQ "007" // Bloqueio
// --------------------------------------------------------
	Conout("Antes da mensagem de recusa " + Time())

	If SCR->CR_TIPO == 'PC'
		Conout("DbSeek SCR 73 " + Time())
		If SCR->( dbseek( fwxfilial( 'SCR' ) + 'PC' + cNumPedido ))
			Conout(" Fim DbSeek SCR 73 " + Time())
			lValido := .T.
			Conout("WHILE  SCR 77 " + Time())
			do while alltrim( SCR->( CR_TIPO + CR_NUM     ) ) == ;
					alltrim(        'PC'    + cNumPedido )

// --------------------------------------------------------
//          [ VerIfica os status de alÃ§ada de aprovaÃ§Ã£o ]
// --------------------------------------------------------
//          [ 01 = Aguardando nivel anterior            ]
//          [ 02 = PEndente                             ]
//          [ 03 = Liberado                             ]
//          [ 04 = Bloqueado                            ]
//          [ 05 = Liberado outro usuario               ]
//          [ 06 = Rejeitado                            ]
// --------------------------------------------------------

// --------------------------------------------------------
//          [ Aguardando nivel anterior ou PEndente ]
// --------------------------------------------------------
				If SCR->CR_STATUS == '01' .OR. ;
						SCR->CR_STATUS == '02'
					lValido := .F.
					exit

// --------------------------------------------------------
//          [ Bloqueada ou Rejeitada ]
// --------------------------------------------------------
				ElseIf SCR->CR_STATUS == '04' .OR. ;
						SCR->CR_STATUS == '06'
					lRejeitado := .T.
					exit

				EndIf

				SCR->( dbskip() )

			Enddo
			Conout("FIM WHILE  SCR 77 " + Time())
		EndIf
	EndIf
	Conout("SetOrder SC7 116 " + Time())
	SC7->( dbsetorder( 1 ) )
	Conout("Fim SetOrder SC7 116 " + Time())
	Conout("MSSEEK SC7 119 " + Time())
	lExistPed  :=   SC7->( msseek( cFilDoc + cNumPedido ))
	Conout("Fim MSSEEK SC7 119 " + Time())
	lSolicPag  := ( SC7->C7_XSOLPAG == '1' ) //verIfica se foi gerado pela F0100401 (GeraÃ§Ã£o solicitação de Pagamentos - Req. ID_635)
//  cEmailEmit := usrretmail( SC7->C7_XUSR )
	lTpMaterial :=  AllTrim(SC7->C7_XTPSP) $ "2|3"//Adionada a variavel para validar o tipo da SP.
	//lValido := .T. ; lExistPed := .T.;  lSolicPag := .T. ; lRejeitado := .F.// COMENTAR THIAGO GOES 17/02/2025

	If lExistPed .AND. lSolicPag
//                                  F1_FILIAL + F1_FORNECE      + F1_LOJA      + F1_DOC
		Conout("MSSEEK SF1 127 " + Time())
		lExistDE  := SF1->( msseek( cFilDoc   + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_XDOC ))
		Conout(" FIM MSSEEK SF1 127 " + Time())
	EndIf
	Conout("DO CASE  131 " + Time())
	do case
	case nOper == 1
		cText := 'Aprovada '
	case nOper == 2
		cText := 'Estornada'
	case nOper == 3
		cText := 'Aprovada pelo superior'
	case nOper == 4
		cText := 'Transferida pelo superior'
	case nOper == 5
		cText := 'Rejeitada pelo aprovador'
	case nOper == 6
		cText := 'Bloqueada'
	otherwise
		cText := 'Aprovada'
	Endcase
	Conout("FIM DO CASE 131 " + Time())
	If lRejeitado

		//msgrun( 'Aguarde, enviando email...' , , {|| EnviaEmail( 'Rejeitada pelo aprovador' , '' , cFilDoc , cNumPedido , nOper )})
		DBSELECTAREA("SC7")
		SC7->(DbSetOrder(1))
		SC7->(DbSeek(cFilDoc+AllTrim(cNumPedido)))

		If (SC7->C7_NUM == AllTrim(cNumPedido) .And. SC7->C7_XSOLPAG == "1")
			Processa( {|| EnviaEmail( 'Rejeitada pelo aprovador' , '' , cFilDoc , cNumPedido , nOper )}, 'Aguarde, enviando email...' )
		EndIf
	Elseif lValido .AND. lExistPed .AND. lSolicPag .And. lTpMaterial//Libera o Titulo de material da SP
		aRecusa := fRecuAut2()
			DbSelectArea("SE2")
			SE2->(DbSetOrder(6))
			SE2->(DbSeek(XFilial("SE2") + SC7->(C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC)))
			SF1->(DbSetOrder(1))
			SF1->(DbSeek(cFilDoc+SC7->C7_XDOC+SC7->C7_XSERIE+SC7->C7_FORNECE + SC7->C7_LOJA))
			aAreaSE2 := SE2->(GetArea())
				While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == XFilial("SE2") + SC7->(C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC)
					RecLock("SE2", .F.)
					SE2->E2_XAPRVSP := "1"
					SE2->E2_XDTAPRO := DDATABASE
					SE2->(MsUnlock())
					SE2->(DbSkip())
				enddo
			RestArea(aAreaSE2)
		if aRecusa[1]
			msgrun('Aguarde, Recusando Nota de Entrada e tñ‘¬o...' , , {|| U_F010101A(.T., aRecusa[2], lTpMaterial)})
		else
			SC7->( reclock( 'SC7' , .F. ))
			if AllTrim(SC7->C7_XTPSP) $ "2|3"
				SC7->C7_QUJE := SC7->C7_QUANT
			endif
			SC7->(MsUnlock())
		endif
		Return																								
	ElseIf (lValido .AND. lExistPed .AND. lSolicPag   .And. !lTpMaterial) // .And. !lExistDE
		cChaveE2 := XFilial("SE2") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_XSERIE + SC7->C7_XDOC																					 
		Conout("POSICIONE SA2 155 " + Time())
		cUFOri := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_EST' )
		Conout("FIM POSICIONE SA2 155 " + Time())

		Conout("ADD ACABEC 160 " + Time())
		aCabec := { { 'F1_FILIAL'    , cFilAnt             , NIL },;
			{ 'F1_TIPO'    , 'N'             , NIL } , ;
			{ 'F1_FORMUL'  , 'N'              , NIL } , ;
			{ 'F1_DOC'     , SC7->C7_XDOC    , NIL } , ;
			{ 'F1_SERIE'   , SC7->C7_XSERIE  , NIL } , ;
			{ 'F1_EMISSAO' , SC7->C7_XDTEMI  , NIL } , ;
			{ "F1_DTDIGIT" ,DDATABASE        , NIL } , ;
			{ 'F1_FORNECE' , SC7->C7_FORNECE , NIL } , ;
			{ 'F1_LOJA'    , SC7->C7_LOJA    , NIL } , ;
			{ 'F1_EST'     , cUFOri          , NIL } , ;
			{ 'F1_COND'    , SC7->C7_COND    , NIL } , ;
			{ 'F1_XUSR'    , SC7->C7_XUSR    , NIL } , ;
			{ 'F1_ORIGEM'  , SC7->C7_ORIGEM  , NIL } , ;
			{ 'F1_XTIPO'   , SC7->C7_XTIPO   , NIL } , ;
			{ 'F1_ESPECIE' , SC7->C7_XESPECI , NIL } , ;
			{ 'F1_XSOLPAG' , SC7->C7_XSOLPAG , NIL } , ;
			{ 'F1_XDTVNF'  , SC7->C7_XDTVEN  , NIL } , ;
			{ 'F1_XDTORIG' , SC7->C7_XDTORIG , Nil } , ;
			{ 'F1_XTXEXPE'    , SC7->C7_XTXEXPE     , NIL } , ;
			{ 'F1_XDTEXCE' , SC7->C7_XDTEXCE , NIL } }//Lucas Miranda de Aguiar melhoria data fixa

		Conout("FIM ADD ACABEC 160 " + Time())

		Conout("SETA VARIAVEIS 181 " + Time())
		cChave := cFilDoc + cNumPedido
		cChaveC7 := cChave
		XXDOC  := SC7->C7_XDOC
		XXSERIE:= SC7->C7_XSERIE
		XXFORN := SC7->C7_FORNECE
		XXLOJA := SC7->C7_LOJA
		cUsr   := SC7->C7_XUSRSP
		XcOND  := SC7->C7_COND
		XDvenC7 := DataValida(SC7->C7_XDTVEN)
		xExDtFx := SC7->C7_XDTEXCE
		xTxExpe := SC7->C7_XTXEXPE
		Conout("FIM SETA VARIAVEIS 181 " + Time())

		Conout("WHILE SC7 195  " + Time())

		//fConsInt()

		do while SC7->( !eof() ) .AND. ( SC7->(C7_FILIAL + C7_NUM) == cChave )
			aLinha := { { 'D1_FILIAL'     , SC7->C7_FILIAL , NIL } , ;
				{ 'D1_COD'     , SC7->C7_PRODUTO , NIL } , ;
				{ 'D1_UM'      , SC7->C7_UM      , NIL } , ;
				{ 'D1_QUANT'   , SC7->C7_QUANT   , NIL } , ;
				{ 'D1_VUNIT'   , SC7->C7_PRECO   , NIL } , ;
				{ 'D1_TOTAL'   , SC7->C7_TOTAL   , NIL } , ;
				{ 'D1_TES'     , ""				 , Nil } , ;
				{ 'D1_VALDESC' , SC7->C7_VLDESC  , NIL } , ;
				{ 'D1_DESPESA' , SC7->C7_DESPESA , NIL } , ;
				{ 'D1_SEGURO'  , 0 , NIL } , ;
				{ 'D1_VALFRE'  , 0 , NIL } , ;
				{ 'D1_LOCAL'   , SC7->C7_LOCAL   , NIL } , ;
				{ 'D1_CC'      , SC7->C7_CC      , NIL } , ;
				{ 'D1_PEDIDO'  , SC7->C7_NUM     , NIL } , ;
				{ 'D1_ITEMPC'  , SC7->C7_ITEM    , NIL } , ;
				{ 'D1_QTDPEDI' , SC7->C7_QUANT   , NIL } , ;
				{ 'D1_XPRIVEN' , SC7->C7_XDTVEN  , NIL } , ;
				{ 'D1_XJURMUL' , SC7->C7_XJURMUL , NIL } , ;
				{ 'D1_XMULTA'  , SC7->C7_XMULTA  , NIL } , ;
				{ 'D1_XCODREC' , SC7->C7_XRETENC  , NIL } , ;
				{ 'D1_XOBS'    , SC7->C7_OBS     , NIL } , ;  //Lucas Miranda de Aguiar
			{ 'D1_XDESFIN' , SC7->C7_XDESFIN , NIL } } // ticket n° 7951372 -- adição de campo

			//Repasse médico - Lucas Miranda de Aguiar 04/05/2023
			If SC7->(FieldPos("C7_XRETINS")) > 0
				If !Empty(SC7->C7_XRETINS)
					AADD(aLinha,{"D1_XRETINS",SC7->C7_XRETINS,NIL})
				EndIf
			EndIf

			aadd( aItens , aclone( aLinha ) )
			aadd( aProds, SC7->C7_PRODUTO )
			aadd( aVlProd, cValToChar(TRANSFORM(SC7->C7_TOTAL, "@E 999,999,999.99")))

// --------------------------------------------------------
//          [ Limpa Status anterior ]
// --------------------------------------------------------
			If SC7->( reclock( 'SC7' , .F. ))
				SC7->C7_XERAUT := ''
				SC7->C7_XERLEG := .F.
				SC7->( msunlock() )
			EndIf 

			nRecNP := SC7->(RECNO()) //#8135327
			nCdControl := nCdControl + SC7->C7_TOTAL

			SC7->( dbskip() )

		Enddo
		Conout("FIM WHILE SC7 195  " + Time())
		//  #8135327- 415966 - Ajuste validaÃ§Ã£o para geraÃ§Ã£o de prenota
		DbSelectArea("SC7")
		SC7->(DbGoTo(nRecNP))

		If nOper = 1 .OR. nOper = 3 .OR. nOper = 4
			nOpcOper := 3
		Else
			nOpcOper := nOper
		EndIf

		SCR->( dbsetorder( 1 ) ) // CR_FILIAL + CR_TIPO + CR_NUM
		//  #8135327- 415966 - Ajuste validaÃ§Ã£o para geraÃ§Ã£o de prenota

		lTipoPC := SCR->( msseek(     cFilDoc + 'PC'    + cNumPedido )) .AND. SC7->C7_XSOLPAG == '1'
		//lTipoPC := .T. // COMENTAR THIAGO GOES 17/02/2025.
		If( lTipoPC )
				if SC7->C7_XTPSP $ "4|5"//GPE Provisï¿½o/Ajuste
				cUserIdBk := __cUserId
				__cUserId := SC7->C7_XUSR//Alterado o campo pois alguem mudou o conteudo e o tamanho dele.
				//__cUserId := SC7->C7_XUSRSP//Muda para o usuï¿½rio que gerou a SP
				bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata103( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
				msgrun('Aguarde, gerando Nota de Entrada e tñ‘¬o...' , , bProcPreNota)
				__cUserId := cUserIdBk
				if SC7->C7_XTPSP == "5"//Exclui a nota de provisï¿½o caso for ajuste
					ExNotaProv(SC7->C7_FILIAL, SC7->C7_XNSPPRE)
				endif
			elseif SC7->C7_XTPSP == "1"//Serviï¿½o
				//aRecusa := fRecuAut2()									  
			aRecusa := fRecuAut2()
			//aRecusa[1]:= .F. // COMENTAR THIAGO GOES 17/02/2025.
			if aRecusa[1]
				bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
				//msgrun('Aguarde, gerando Pre-Nota de Entrada...' , , bProcPreNota)
				//msgrun('Aguarde, Recusando Pre-Nota de Entrada ['+aRecusa[2]+']...' , , {|| U_F010101A(.T., aRecusa[2])})
				Conout("Mensagem Pré Nota " + Time())
				Processa( bProcPreNota, 'Aguarde, gerando Pre-Nota de Entrada...'  )
				Conout("Mensagem Recusa " + Time())
				Processa(  {|| U_F010101A(.T., aRecusa[2])}, 'Aguarde, Recusando Pre-Nota de Entrada ['+aRecusa[2]+']...' )
				Conout("FIM Mensagem Recusa " + Time())
			else
				//Função de validação da classIficação automática - Lucas Miranda de Aguiar 27/02/2023
				lClassAut := fClassAut(aProds)
				lClassImp := !Empty(SC7->C7_ZIDONGY) .And. lImpClas
				//lClassAut := .T. // COMENTAR THIAGO GOES 17/02/2025.
				If lClassAut .or. lClassImp //!Empty(SC7->C7_ZIDONGY) - Ramon 07/01/26 (Possibilitar o desligamento da class auto de imposto)
					lClassAut := .T. // THIAGO GOES 17/02/2025.
					bProcPreNota := {|| fExecClass(aProds) }
					//msgrun('Aguarde. Iniciando o processo de Classificação Automática...' , , bProcPreNota)
					Processa( bProcPreNota, 'Aguarde. Iniciando o processo de Classificação Automática...')
				Else
					bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
					//msgrun('Aguarde, gerando Pre-Nota de Entrada...' , , bProcPreNota)
					Processa(bProcPreNota,'Aguarde, gerando Pre-Nota de Entrada...')
				EndIf
			endif


			// ticket n° 10326179 - gravação do valor Tx Expediente
			SF1->(DbSetOrder(1))
			If SF1->(DbSeek(xFilial("SF1")+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
				If Reclock("SF1",.F.)
					SF1->F1_XTXEXPE := SC7->C7_XTXEXPE
					SF1->(MsUnlock())
				EndIf 
			EndIf
	  Endif

// --------------------------------------------------------
//      [ Erro no execauto ]
// --------------------------------------------------------
			If lMsErroAuto

				nOpc := aviso( 'Atenção!' , 'Ocorreu um erro momento da geração da Pre-Nota de entrada. '           + ;
					'Você deve estornar essa liberação e entrar em contato com o suporte, ' + ;
					'exibindo a tela a seguir.' , { 'Estornar Lib' } , 2 )
// --------------------------------------------------------
//          { 'Estornar Lib' , -'Confirmar' } , 2 ) - Comentado em 31/01/2019 po Marcos Furtado ID 1519
// --------------------------------------------------------

				If nOpc == 1

					a097estorna()

					If !lValidou .And. !Empty(cLog)
						cObs := cLog
					Else
						cObs := mostraerro( '\tmperro.txt' )
					EndIf
					alert( cObs )

// --------------------------------------------------------
//              aviso( 'Erro execauto.' , cObs , { 'Continua' } , 2 )
//              mostraerro()
// --------------------------------------------------------

				Else

					If !lValidou .And. !Empty(cLog)
						cObs := cLog
					Else
						cObs := mostraerro( '\tmperro.txt' )
					EndIf
					alert( cObs )

// --------------------------------------------------------
//              aviso( 'Erro execauto.' , cObs , { 'Continua' } , 2 )
//              mostraerro()
// --------------------------------------------------------

				EndIf

				//msgrun( 'Aguarde, enviando email...' , , {|| EnviaEmail( 'Erro' , ' Não ' ,  cFilDoc , cNumPedido , nOper )})
				Processa( {|| EnviaEmail( 'Erro' , ' Não ' ,  cFilDoc , cNumPedido , nOper )},  'Aguarde, enviando email...')


				SC7->( dbsetorder( 1 ))
				lExistPed := SC7->( msseek( cFilDoc + cNumPedido ))

				If lExistPed
					While SC7->( !eof() ) .AND. ( SC7->(C7_FILIAL + C7_NUM) == cChave )
						If SC7->( reclock( 'SC7' , .F. ))
							SC7->C7_XERAUT := cObs // "ERRO" // MostraErro("\tmperro.txt")
							SC7->C7_XERLEG := .T.
						SC7->( msunlock() )
						EndIf 
						SC7->( dbskip() )
					Enddo
				EndIf
			Else

// --------------------------------------------------------
//          [ execauto realizado com sucesso ]
// --------------------------------------------------------
//          [ nOper := PARAMIXB[3]           ]
// --------------------------------------------------------
//          [ 1 - Aprovar                    ]
//          [ 2 - Estornar                   ]
//          [ 3 - Aprovar pelo superior      ]
//          [ 4 - Transferir pelo superior   ]
//          [ 5 - Rejeitar                   ]
//          [ 6 - Bloquear                   ]
// --------------------------------------------------------
				If nOper == 5
					//msgrun( 'Aguarde, enviando email...' , , {|| EnviaEmail( cText , '' , cFilDoc , cNumPedido , nOper )})
					Processa( {|| EnviaEmail( cText , '' , cFilDoc , cNumPedido , nOper )}, 'Aguarde, enviando email...' )
					if SC7->C7_XTPSP != "1" .And. lFilSimp
						U_ContabSP("SP2",cChaveE2)//Estorno
					endif
				elseif nOper == 1 .And. SC7->C7_XTPSP != "1" .And. lFilSimp
					U_ContabSP("SP1",cChaveE2)//contabiliza
				elseif nOper == 2 .And. SC7->C7_XTPSP != "1" .And. lFilSimp
					U_ContabSP("SP2",cChaveE2)//Estorno					   
				EndIf
			EndIf
		EndIf
	EndIf
	aeval( aAreas , {|aArea| restarea( aArea ) } )

return

// --------------------------------------------------------
//static function enviamail( cSufixo , cYesNo )
//    local cSMTP      := alltrim( getmv( 'MV_RElseRV' ))  // smtp.ig.com.br ou 200.181.100.51
//    local cConta     := alltrim( getmv( 'MV_RELACNT' ))  // fulano@ig.com.br
//    local cPass      := alltrim( getmv( 'MV_RELPSW'  ))  // 123abc
//    local cContaDes  := alltrim( getmv( 'FS_GRPFIN'  ))  // email grupo financeiro
//    local cAssunto   := '' 
//    local lConSMTP   := .F.
//    local lEnvEmail  := .F.
//    local cMensagem  := ''
//    local cError     := ''
//    local cEmailEmit := usrretmail( SC7->C7_XUSR )
////  Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP  
////  If lConSMTP  
////      SEnd MAIL FROM cConta TO alltrim(GetMV("MV_XMAILFO")) SUBJECT cAssunto BODY  cMensagem  
////      Disconnect SMTP Server  
////  EndIf  
//Return
// --------------------------------------------------------

static function enviaemail ( cSufixo , cYesNo , cFilDoc , cNumPedido , nOper )

// --------------------------------------------------------
	local cSMTP      := alltrim( getmv( 'MV_RElseRV' )) // smtp.ig.com.br ou 200.181.100.51
	local cConta     := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
	local cPass      := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
	//local cContaDes  := alltrim( getmv( 'FS_GRPFIN'  )) // email grupo financeiro
	local cAssunto   := ''
	local lConSMTP   := .F.
	local lEnvEmail  := .F.
	local aArea      := getarea()
	local cMensagem  := ''
	local cError     := ''
	local cMsgCab    := ''
	local cAliasQry  := getnextalias()
	local cEmailEmit := ''                              // UsrRetMail( SC7->C7_XUSR )  // 006783
// --------------------------------------------------------
//  SC7->( dbsetorder( 1 ))
//  lExistPed := SC7->( msseek( cFilDoc + cNumPedido ))
// --------------------------------------------------------
	cQuery := "     SELECT * "
	cQuery += "       FROM "                   + retsqlname( 'SC7' ) + " SC7 "
	cQuery += " INNER JOIN "                   + retsqlname( 'SA2' ) + " SA2 "
	cQuery += "         ON SA2.A2_FILIAL  = '" +    xfilial( 'SA2' ) + "' "
	cQuery += "        AND SA2.A2_COD     = SC7.C7_FORNECE "
	cQuery += "        AND SA2.A2_LOJA    = SC7.C7_LOJA "
	cQuery += "        AND SA2.D_E_L_E_T_ = SC7.D_E_L_E_T_ "
	cQuery += "      WHERE SC7.D_E_L_E_T_ = ' ' "
	cQuery += "        AND SC7.C7_FILIAL  = '" + cFilDoc             + "' "
	cQuery += "        AND SC7.C7_NUM     = '" + cNumPedido          + "' "    + CRLF
	cQuery += "         AND SC7.C7_XSOLPAG = '1' "

	If select(cAliasQry) > 0
		(caliasQry)->(DbcloseArea())
	EndIf

	dbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasQry , .F. , .T. )

	If ( cAliasQry )->(!EOF())
		cEmailEmit := usrretmail( (cAliasQry)->C7_XUSR ) // 006783
		If cEmailEmit == ''
			alert( 'Email do Solicitante não cadastrado, e-mail de log não será enviado' )
			return
		EndIf
	Else
		return
	EndIf

// --------------------------------------------------------
//  iIf( alltrim( cEmailEmit ) = '' , cEmailPar , cEmailEmit )
// --------------------------------------------------------

	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP

	If lConSMTP

		cMensagem := "<html>"
		cMensagem += "<head><title>" + alltrim( cAssunto ) + "</title></head>"
		cMensagem += "<body>"
		cMensagem += "<br>"

// --------------------------------------------------------    
//      cMensagem += "Documento ("+SF1->F1_DOC+"), do Fornecedor ("+alltrim(POSICIONE( "SA2",1 , xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA, "A2_NOME"))+"), "
//      cMensagem += "CNPJ ("+alltrim(POSICIONE( "SA2",1 , xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA, "A2_CGC")+"), foi inserido na Filial ("+FWxFilial('P09'))+") " 
//      cMensagem += "mas não foi encontrado. <br> TÃ­tulo em aberto para pagamento no mÃ³dulo Financeiro."
// --------------------------------------------------------

		If cSufixo = 'Erro'
			cMsgCab   := 'Ocorreu um erro na aprovação da solicitação de pagamento:  '
			cMensagem += ' solicitação de pagamento ' + (cAliasQry)->C7_NUM + ' não foi aprovada favor verIficar no campo Erro Aprovac.  '
		Else
			cMsgCab   := 'solicitação de pagamento foi ' + cSufixo + ' .'
			If nOper = 1
				cMensagem += ' solicitação de pagamento ' + (cAliasQry)->C7_NUM + ' foi ' + cSufixo + ' e encaminhada ao contas a pagar :  '
			Else
				cMensagem += ' solicitação de pagamento ' + (cAliasQry)->C7_NUM + ' foi ' + cSufixo + ' . '
			EndIf
		EndIf

		cMensagem += "<br>"
		cMensagem += "solicitação de Pagamento: " +          (cAliasQry)->C7_NUM
		cMensagem += "<br>"
		cMensagem += "Filial : "                  +          (cAliasQry)->C7_FILIAL + " - "        + FWFilialName( CEmpAnt , (cAliasQry)->C7_FILIAL )
		cMensagem += "<br>"
		cMensagem += "Fornecedor : "              + alltrim( (cAliasQry)->A2_NOME )
		cMensagem += "<br>"
		cMensagem += "Código : "                  +          (cAliasQry)->C7_FORNECE + " - Loja : " + (cAliasQry)->C7_LOJA
		cMensagem += "<br>"
		cMensagem += "CNPJ : "                    + alltrim( (cAliasQry)->A2_CGC )
		cMensagem += "<br>"
		If !lValidou
			cMensagem += "Erro : "                    + alltrim(cLog)
			cMensagem += "<br>"
		EndIf
		cMensagem += "</body>"
		cMensagem += "</html>"

		SEnd MAIL FROM cConta TO cEmailEmit  SUBJECT cSufixo + cMsgCab + cAssunto BODY  cMensagem Result lEnvEmail

		If !lEnvEmail // Erro no envio do email
			get mail error cError
			Help( '' , 1 , 'Help' , 'F0100404' , 'Erro no envio do email: ' + cError + '. Favor reportar o erro para Ã¡rea de TI da Rede DÂ´or.' , 1 , 0 )
		EndIf

		DISCONNECT SMTP SERVER

	Else // Erro na conexao com o SMTP Server
		get mail error cError
		Help( '' , 1 , 'Help' , 'F040010100' , 'Erro na conexÃ£o SMTP: ' + cError  + '. Favor reportar o erro para Ã¡rea de TI da Rede DÂ´or.' , 1 , 0 )
	EndIf

	(cAliasQry)->( dbclosearea() )

	restarea( aArea )

return


/*/{Protheus.doc} fClassAut
    Função para validar se o documento será classIficado automaticamente.
    @type  Function
    @author Lucas Miranda
    @since 27/02/2023
    @version 1.0
    /*/
Static Function fClassAut(aProds)

	Local aArea := GetArea()
	Local lAuto := .T.
	Local nX := 0
	Local nTamanho := TamSX3("P38_PRODUT")[1]

	Default aProds := {}

	DbSelectArea("P38")
	P38->(DbSetOrder(1))

	For nX := 01 To Len(aProds)

		If !(P38->(DbSeek(xFilial("P38")+Padr(aProds[nX], nTamanho, ' ')+'1')))
			lAuto := .F.
			Exit
		EndIf

	Next nX
	RestArea(aArea)
Return lAuto


/*/{Protheus.doc} fExecclass
    Função para validar se o documento será classIficado automaticamente.
    @type  Function
    @author Lucas Miranda
    @since 27/02/2023
    @version 1.0
    /*/ 
Static Function fExecClass(aProds)

	Local aArea    := GetArea()
	Local nX       := 0
	Local lExec    := .T.
	Local nTamanho := TamSX3("P38_PRODUT")[1]
	Local cUPD := ""
	Local lExistPed := .F.
	Local cChavE2 := ""
	Local aAReaSE2 := SE2->(GetArea())
	Local lPrim := .F.
	Local aItem2 := {}
	Local aItens2 := {}
	Local nTamProd      := TamSX3("B1_COD")[1]
	Local nTamGrupo     := TamSX3("B1_GRUPO")[1]
	Local lTESGrupo     := SuperGetMV("FS_TESSBM",.F.,.T.) //PARAMETRO PARA DESLIGAR A CUSTOMIZA?O
	Local x,y := 0
	//Local cArqErro := ""
	//Local c_Erro := ""
	Local nCntErr := ""
	Local aRet := {}
	Local cErroRet := ""
	Local cEol := chr(13)+chr(10)
	Local lFilSimp := U_VALSIMP(cFilAnt)

	Private aTitulo := {}
	Private aAutoImp :={}
	Private nLinha := 0 
	Private cIdZkt := ""
	Private lServObra  := .T.
	Private lTipServ := .F.
	Private cTipServ := ""
	Private aSX3 := {}
	Private cTes := "" 
	Private cCFOP := ""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto :=.T.
	Private cCodRetCop := SuperGetMV("FS_COOPDRF",.F., "3280") // Código de Retenção Copiado
 	Private cCodRetDef := SuperGetMV("FS_DEFADRF",.F., "1708") // Código de Retenção Default
	Private cNatForn := ""
	Private axCodRet := {}
	
		
	If Type("lImpClas") <> "L"
		lImpClas := SuperGetMV("FS_IMPCLAS",.F.,.T.) 
	Endif 

	Private cNaturez := ""
	Default aProds := {}

	DbSelectArea("P38")
	DbSetOrder(1)

	If Empty(SC7->C7_ZIDONGY) //!lImpClas
		For nX := 1 To Len(aProds)
			If P38->(DbSeek(xFilial("P38")+Padr(aProds[nX], nTamanho, ' ')+'1'))
				cxProds += "Código do produto: " + AllTrim(aProds[nX]) +"   -  Descrição: " + AllTrim(Posicione('SB1',1,XFILIAL('SB1')+aProds[nX],'B1_XDES')) + "  -  Valor: " + AllTrim(aVlProd[nX]) + CRLF
				If nX == 1
					cNaturez := P38->P38_NATU
				Else
					If AllTrim(cNaturez) == AllTrim(P38->P38_NATU)
						cNaturez := P38->P38_NATU
					Else
						cLog := "As naturezas dos produtos da nota não podem ser distintas. Verifique o cadastro na tabela P38"
						lExec := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf 

	cUPD := "UPDATE "+RETSQLNAME("SFT")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND "
	cUPD += " FT_FILIAL = '"+XFILIAL("SF1")+"' AND FT_NFISCAL = '"+StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])+"' AND FT_CLIEFOR = '"+XXFORN+"' AND FT_LOJA = '"+XXLOJA+"' "
	cUPD += " AND FT_SERIE = '"+XXSERIE+"'"
	TCSqlExec(cUPD)
	conout("TCSQLError() " + TCSQLError())
	If lExec
		msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper )
		If !lMsErroAuto

			AAdd(aTitulo,{"F1_FILIAL" ,SF1->F1_FILIAL, Nil })
			aadd(aTitulo,{"F1_TIPO",SF1->F1_TIPO ,NIL})
			If Empty(SF1->F1_FORMUL)
				aadd(aTitulo,{"F1_FORMUL","N" ,NIL})
			Else 
				aadd(aTitulo,{"F1_FORMUL",SF1->F1_FORMUL ,NIL})
			EndIf 
			aadd(aTitulo,{"F1_DOC" ,SF1->F1_DOC ,NIL})
			aadd(aTitulo,{"F1_SERIE" ,SF1->F1_SERIE ,NIL})
			aadd(aTitulo,{"F1_EMISSAO" ,SF1->F1_EMISSAO ,NIL})
			aadd(aTitulo,{"F1_DTDIGIT" ,DDATABASE ,NIL})
			aadd(aTitulo,{"F1_FORNECE" ,SF1->F1_FORNECE ,NIL})
			aadd(aTitulo,{"F1_LOJA" ,SF1->F1_LOJA ,NIL})
			aadd(aTitulo,{"F1_ESPECIE" ,SF1->F1_ESPECIE ,NIL})
			aadd(aTitulo,{"F1_COND" , SF1->F1_COND ,NIL})
			aadd(aTitulo,{"F1_DESPESA" ,SF1->F1_DESPESA ,NIL})
			aadd(aTitulo,{"F1_DESCONT" , SF1->F1_DESCONT ,Nil})
			aadd(aTitulo,{"F1_FRETE" , SF1->F1_FRETE ,Nil})
			aadd(aTitulo,{"F1_MOEDA" , 1 ,Nil})
			aadd(aTitulo,{"F1_TXMOEDA" , 1 ,Nil})
			aadd(aTitulo,{"F1_STATUS" , "A" ,Nil})
			aadd(aTitulo,{ 'F1_XTIPO'   , SF1->F1_XTIPO   , NIL })
			aadd(aTitulo,{ 'F1_XDTVNF'  , SF1->F1_XDTVNF  , NIL })
			aadd(aTitulo,{ 'F1_EST'     , SF1->F1_EST          , NIL })
			aadd(aTitulo,{ 'F1_XUSR'    , SF1->F1_XUSR    , NIL })
			aadd(aTitulo,{ 'F1_DTLANC'  , dDataBase    , NIL })
			/*
			aSX3 := FWSX3Util():GetAllFields("SF1")
			For y:=1 To Len(aSX3)
				If  X3Obrigat(GetSX3Cache(aSX3[y], "X3_USADO") )
					If aScan(aTitulo,{|e| e[1] == aSX3[y]}) == 0
						MsgAlert("Campo obrigatório não informado: "+aSX3[y])
					EndIf 
				EndIf
			next y
			*/

			DbSelectArea("SC7")
			SC7->(DbSetOrder(14))

			DbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			While SD1->(!Eof()) .and. SD1->D1_FILIAL == SF1->F1_FILIAL  .and.;
					SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
					SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

				aItem2 := {}
				aadd(aItem2,{"D1_FILIAL" ,SD1->D1_FILIAL,NIL})
				aadd(aItem2,{"D1_ITEM" ,SD1->D1_ITEM,NIL})
				aadd(aItem2,{"D1_COD" ,SD1->D1_COD ,NIL})
				aadd(aItem2,{"D1_UM" ,SD1->D1_UM ,NIL})
				aadd(aItem2,{"D1_LOCAL" ,SD1->D1_LOCAL ,NIL})
				aadd(aItem2,{"D1_QUANT" ,SD1->D1_QUANT ,NIL})
				aadd(aItem2,{"D1_VUNIT" ,SD1->D1_VUNIT ,NIL})
				aadd(aItem2,{"D1_TOTAL" ,SD1->D1_TOTAL ,NIL})

				If lTESGrupo
					cProd := PADR(SD1->D1_COD,nTamProd,' ')
					
					dbSelectArea("SB1")
					SB1->(DbSetOrder(1))

					If SB1->(DbSeek(xFilial("SB1")+cProd))
						If !Empty(SB1->B1_GRUPO)
							cGrupo := PADR(SB1->B1_GRUPO,nTamGrupo,' ')
						EndIf
					EndIf

					If !Empty(cGrupo) .AND. SUBSTRING(SD1->D1_CC,1,2) == "04"
						If SBM->(DbSeek(xFilial("SBM")+cGrupo))
							If !Empty(SBM->BM_XTES)
								cTes := SBM->BM_XTES
							EndIf 
						EndIf 
					EndIf
					If !Empty(cTes)
						aadd(aItem2,{"D1_TES" ,cTes ,Nil})
					Else 
						cTes := Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE")
						aadd(aItem2,{"D1_TES" ,cTes ,Nil})
					EndIf 
				Else 
					cTes := Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE")
					aadd(aItem2,{"D1_TES" ,cTes ,NIL})
				EndIf 
				aadd(aItem2,{"D1_RATEIO" ,SD1->D1_RATEIO ,NIL})
				If lImpClas .And. !Empty(SC7->C7_ZIDONGY)
					aadd(aItem2,{"D1_XCODCON",StrZero(Val(STRTRAN(STRTRAN(cValToChar(SF1->F1_DOC), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]),NIL})	
				Else
					If SF1->F1_VALBRUT = 0 
						aadd(aItem2,{"D1_XCODCON",StrZero(Val(STRTRAN(STRTRAN(cValToChar(SD1->D1_TOTAL), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]),NIL})
					Else 	
						aadd(aItem2,{"D1_XCODCON",StrZero(Val(STRTRAN(STRTRAN(cValToChar(SF1->F1_VALBRUT), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]),NIL})
					EndIf 
				EndIf

				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))

				//cCFOP := Posicione("SF4",1,xFilial("SF4")+cTes,"F4_CF")
				If SF4->(DbSeek(xFilial("SF4")+cTes))
					cCfop := SF4->F4_CF
					If !Empty(cCFOP)
						aadd(aItem2,{ 'D1_CF' , cCFOP  , NIL })
					EndIf 
				eNDiF 

				aAdd(aItem2,{"LINPOS" , "D1_ITEM",  SD1->D1_ITEM})
				aadd(aItem2,{ 'D1_VALDESC' , SD1->D1_VALDESC  , NIL })
				aadd(aItem2,{ 'D1_CC'      , SD1->D1_CC      , NIL })
				aadd(aItem2,{ 'D1_PEDIDO'  , SD1->D1_PEDIDO     , NIL })
				aadd(aItem2,{ 'D1_ITEMPC'  , SD1->D1_ITEMPC    , NIL })
				aadd(aItem2,{ 'D1_QTDPEDI' , SD1->D1_QTDPEDI   , NIL })
				aadd(aItem2,{ 'D1_XPRIVEN' , SD1->D1_XPRIVEN  , NIL })
				aadd(aItem2,{ 'D1_XJURMUL' , SD1->D1_XJURMUL , NIL })
				aadd(aItem2,{ 'D1_VALFRE'  , SD1->D1_VALFRE  , NIL })
				aadd(aItem2,{ 'D1_DESPESA' , SD1->D1_DESPESA , NIL })
				aadd(aItem2,{ 'D1_SEGURO'  , SD1->D1_SEGURO  , NIL })
				aadd(aItem2,{ 'D1_XMULTA'  , SD1->D1_XMULTA  , NIL })
				aadd(aItem2,{ 'D1_XNATURE' , SD1->D1_XNATURE , NIL })
				//If Empty(SD1->D1_XOBS)
				//	aadd(aItem2,{ 'D1_XOBS'    , "TESTE"     , NIL })
				//Else 
				aadd(aItem2,{ 'D1_XOBS'    , SD1->D1_XOBS     , NIL })
				//EndIf 
				aadd(aItem2,{ 'D1_XDESFIN' , SD1->D1_XDESFIN ,NIL })
			

				/*
				aSX3 := FWSX3Util():GetAllFields("SD1")
				For x:=1 To Len(aSX3)
					If  X3Obrigat(GetSX3Cache(aSX3[x], "X3_USADO") )
						If aScan(aItem2,{|e| e[1] == aSX3[x]}) == 0
							MsgAlert("Campo obrigatório não informado: "+aSX3[x])
						EndIf 
					EndIf
				next x
				*/
				If lImpClas
					If SC7->(DbSeek(SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEMPC)))//C7_FILENT+C7_NUM+C7_ITEM
						If !Empty(SC7->C7_ZIDONGY)
							cxProds += "Código do produto: " + AllTrim(SD1->D1_COD) +"   -  Descrição: " + AllTrim(Posicione('SB1',1,XFILIAL('SB1')+SD1->D1_COD,'B1_XDES')) + "  -  Valor: " + cValtoChar(SD1->D1_TOTAL) + cEol
							fBuscImpo(SD1->D1_ITEM, SC7->C7_ZIDONGY, aAutoImp)
						EndIf 
					EndIf 
				EndIf 

				If Type("lInss") == "L"
					If lInss
						If Type("nValIns") == "N" 
							If nValIns > 0
								aadd(aItem2,{ 'D1_VALINS'    , nValIns    , NIL })
							EndIf 
						EndIf
						If Type("nBaseIns") == "N" 
							If nBaseIns > 0
								aadd(aItem2,{ 'D1_BASEINS'    , nBaseIns    , NIL })
							EndIf 
						EndIf 
						If Type("nAliqIns") == "N" 
							If nAliqIns > 0
								aadd(aItem2,{ 'D1_ALIQINS'    , nAliqIns    , NIL })
							EndIf
						EndIf 
					EndiF 
				EndIf 

				If Type("lIr") == "L"
					If lIr
						If Type("nValIr") == "N" 
							If nValIr > 0
								aadd(aItem2,{ 'D1_VALIRR'    , nValIr    , NIL })
							EndIf 
						EndIf
						If Type("nBaseIr") == "N" 
							If nBaseIr > 0
								aadd(aItem2,{ 'D1_BASEIRR'    , nBaseIr    , NIL })
							EndIf 
						EndIf 
						If Type("nAliqIr") == "N" 
							If nAliqIr > 0
								aadd(aItem2,{ 'D1_ALIQIRR'    , nAliqIr    , NIL })
							EndIf
						EndIf 
					EndiF 
				EndIf 

				If Type("lIss") == "L"
					If lIss
						If Type("nValIss") == "N" 
							If nValIss > 0
								aadd(aItem2,{ 'D1_VALISS'    , nValIss    , NIL })
							EndIf 
						EndIf
						If Type("nBaseIss") == "N" 
							If nBaseIss > 0
								aadd(aItem2,{ 'D1_BASEISS'    , nBaseIss    , NIL })
							EndIf 
						EndIf 
						If Type("nAliqIss") == "N" 
							If nAliqIss > 0
								aadd(aItem2,{ 'D1_ALIQISS'    , nAliqIss    , NIL })
							EndIf
						EndIf 
					EndiF 
				EndIf 


				//D1_BASEISS	Base de ISS	Base de calculo do ISS	Campo indicativo da Base de Cálculo para o ISS no item.	N	14	2	@E 99,999,999,999.99	MaFisRef("IT_BASEISS","MT100",M->D1_BASEISS)				Nao	Altera	Virtual									1	2
				//D1_ALIQISS	Aliq. ISS	Aliquota de ISS	Campo indicativo da alíquota aplicada para o cálculo do ISS no item.	N	5	2	@E 99.99	MaFisRef("IT_ALIQISS","MT100",M->D1_ALIQISS)				Nao	Altera	Virtual									1	2
				//D1_VALISS	Valor do ISS	Valor do ISS	Campo indicativo do valor do ISS para o item.	N	14	2	@E 99,999,999,999.99	MaFisRef("IT_VALISS","MT100",M->D1_VALISS)

				aAdd(aItens2,aItem2)
	
				SD1->(DbSkip())
			Enddo
			
			If !lClassAut
				//Validar se os produtos são de execução automática
				RestArea(aArea)
				RestArea(aAreaSE2)
				Conout("Codigo dos produtos/serviços não são de classificação automática.")
				Return 
			EndIf 

			If lImpClas .and. !Empty(aAutoImp)
				DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                       
				If Type("lIr") == "L"
					If lIr
						If SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)) 
							If SA2->A2_TPJ == "4" //Pessoa Jurídica
								aAdd( axCodRet, {02, cCodRetCop, 1, "IRR"} )
							Else 
								//SE2_DIRF := "1" //Sim
								//SE2->E2_CODRET := cCodRetDef // Código de Retenção Default 
								aAdd( axCodRet, {02, cCodRetDef, 1, "IRR"} )
							EndIf 
						EndIf 
					EndIf 
				EndIf 

			
				//aAdd( aCodRet, {03, "5979", 1, "PIS"} )
				//aAdd( aCodRet, {04, "5960", 1, "COF"} )
				//aAdd( aCodRet, {05, "5987", 1, "CSL"} )

				//3-Inclusão / 4-Classificação / 5-Exclusão

				//MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,aItensRat,aCodRet)
				//MATA103(xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xAutoImp,xAutoAFN,xParamAuto,xRateioCC,lGravaAuto,xCodRSef,xCodRet,xAposEsp,xNatRend)
				If !Empty(cNaturez)
					If lNatdef
						cNaturez := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_NATUREZ")
					Else 
						cNaturez := AllTrim(cNaturez)
					EndIf 
				EndIf 
				AADD(aTitulo,{"E2_NATUREZ"	, PadR(cNaturez,TamSX3("E2_NATUREZ")[1])})
				MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aTitulo,aItens2,4,,aAutoImp,{},{},,,,axCodRet)
			ElseIf lImpClas .Or. lClassAut
				If !Empty(cNaturez)
					If lNatdef
						cNaturez := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_NATUREZ")
					Else 
						cNaturez := AllTrim(cNaturez)
					EndIf 
				EndIf 
				AADD(aTitulo,{"E2_NATUREZ"	, PadR(cNaturez,TamSX3("E2_NATUREZ")[1])})
				MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aTitulo,aItens2,4,,,{},{})
			EndIF
			If !lMsErroAuto
				DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                       
				//WFConOut("ERRO ao transferir o Título para carteira."+cErroRet)
				cChavE2 := xFilial("SE2") + XXFORN + XXLOJA + XXSERIE + StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])

				DbSelectArea("SE2")
				SE2->(DbSetOrder(06))
				SE2->(DbSeek(cChavE2))
				While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
					cNatForn := AllTrim(Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NATUREZ"))
					If SE2->(Reclock("SE2",.F.))
						SE2->E2_XUSNOME := AllTrim(cUsr)
						SE2->E2_XCLAUT := "1"
						SE2->E2_XPRODNF := cxProds
						If !Empty(cNaturez)
							If lNatdef
								SE2->E2_NATUREZ := cNatForn
							Else 
								SE2->E2_NATUREZ := AllTrim(cNaturez)
							EndIf 
						EndIf
						If lClassImp //!Empty(SC7->C7_ZIDONGY) 
							SE2->E2_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(SE2->E2_NUM), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
						Else
							SE2->E2_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(SE2->E2_VALOR), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
						EndIf
						If Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_XDTFIX") == "1"
							If xExDtFx == "2"
								if Empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
										AllTrim(SE2->E2_PARCELA) == '1' .OR. ;
										SE2->E2_PARCELA == Replicate("a",TamSx3("E2_PARCELA")[1]) .OR. ;
										SE2->E2_PARCELA == Replicate("A",TamSx3("E2_PARCELA")[1]) .OR. ;
										SE2->E2_PARCELA == Replicate("0",(TamSx3("E2_PARCELA")[1] - 1)) + "1"
									SE2->E2_VENCTO := XDvenC7
									SE2->E2_VENCREA := XDvenC7
								Else
									SE2->E2_VENCTO := U_DTFORNFIX(SE2->E2_VENCREA,XcOND)
									SE2->E2_VENCREA := U_DTFORNFIX(SE2->E2_VENCREA,XcOND)
								EndIf
							Else
								SE2->E2_VENCTO := XDvenC7
								SE2->E2_VENCREA := XDvenC7
							EndIf
						Else
							If !lPrim
								SE2->E2_VENCTO := XDvenC7
								SE2->E2_VENCREA := XDvenC7
								lPrim := .T.
							EndIf
						EndIf

						If lTipServ 
							If Type("cTipServ") == "C"
								SE2->E2_XTPSERV := AllTrim(cTipServ)
							ElseIf Type("cTipServ") == "N"
								SE2->E2_XTPSERV := cValToChar(cTipServ)
							EndIf   
							If lServObra == .F.
								SE2->E2_XIOBRA := "0"
							EndIf 
						EndIf 

						If Type("lImpClas") == "L"
							If lImpClas
								If Type("lIr") == "L"
									If lIr
										If SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE + SE2->E2_LOJA) )
											If SA2->A2_TPJ == "4" //Pessoa Jurídica
												//nCombo  := 1 // Posição do Combo
												cCodRet := cCodRetCop // Código de Retenção
												SE2->E2_CODRET := cCodRetCop
											Else 
												//nCombo  := 1 // Posição do Combo
												cCodRet :=  cCodRetDef// Código de Retenção
												//aadd(aImpRet,{"IRR",nCombo,cCodRet})
												SE2->E2_CODRET := cCodRetDef 
											EndIf 
										EndIf 
										SE2->E2_DIRF := "1" //Sim
									EndIf
								EndIf 
							EndIf 
						EndIf  

						SE2->( msunlock() )
					EndIf 
					SE2->(DbSkip())
				EndDo
			Else 
				aRet := GetAutoGRLog()
				For nCntErr := 1 To Len(aRet)
					cErroRet += aRet[nCntErr] + cEol 
				Next
				//c_Erro := MostraErro()
			EndIf
        Else
			aRet := GetAutoGRLog()
			For nCntErr := 1 To Len(aRet)
				cErroRet += aRet[nCntErr] + cEol 
			Next
		EndIf
	Else

		msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper )

		SC7->( dbsetorder( 1 ))
		lExistPed := SC7->( msseek( cChaveC7 ))

		If lExistPed

			do while SC7->( !eof() ) .AND. ( SC7->(C7_FILIAL + C7_NUM) == cChaveC7 )

				If SC7->( reclock( 'SC7' , .F. ))
					SC7->C7_XERAUT := cLog // "ERRO" // MostraErro("\tmperro.txt")
					SC7->( msunlock() )
				EndIf 
				SC7->( dbskip() )

			Enddo
			cLog := ""
		EndIf
	EndIf
	RestArea(aArea)
	RestArea(aAreaSE2)
Return
//Verifica se esta sem anexo.
//static function fRecuAut1()
static function fTemAnexo()
	Local cQuery := ""
	Local lRet := .F.
	Local cAliasC7 := GetNextAlias()
	Local aArea := P39->(GetArea())

	/*/cQuery += "SELECT C7_NUM FROM "+RetSqlName("SC7")+ " SC7 " + CRLF
	cQuery += "WHERE SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "AND R_E_C_N_O_ = "+cValToChar(SC7->(Recno()))+" " + CRLF
	cQuery += "AND NOT EXISTS (SELECT R_E_C_N_O_ FROM P09010 P09 WHERE P09.D_E_L_E_T_ = ' ' AND P09.P09_FILIAL||P09.P09_CODORI = SC7.C7_FILIAL||SC7.C7_NUM)" + CRLF
	/*/

	cQuery += " SELECT SC7.C7_NUM "
	cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
	cQuery += " AND SC7.R_E_C_N_O_ = "+cValToChar(SC7->(Recno()))+" "
	cQuery += " AND NOT EXISTS (
	cQuery += " SELECT 1 FROM " +  RetSqlName("P09") + " P09 WHERE P09.D_E_L_E_T_ = ' ' AND P09.P09_FILIAL = SC7.C7_FILIAL AND P09.P09_CODORI = SC7.C7_NUM)"

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasC7, .T., .T.)

	If (cAliasC7)->(Eof())
		lRet := .T.
	EndIf

	RestArea(aArea)
return lRet

//Valida Regra da recusa automática
static function fRecuAut2()
	Local lRet := .F.
	//Local nX := 0
	Local aArea := GetArea()
	Local aAreaSC7 := SC7->(GetArea())
	Local aAreaP39 := P39->(GetArea())
	Local aProdSC7 := {}
	//Local aProdP39 := {}
	Local cErro := ""
	Local cIn := ""
	Local cQry := ""
	Local lAnexoTD := .F.
	Local cAliasP39 := GetNextAlias()
	Local lVlDAnx := .F.
	Local lVldVnc := .F.

	Conout("FRECUAUT2 - DBSELECTAREA E SETORDER " + TIME())
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	cNum := SC7->C7_NUM
	Conout("FRECUAUT2 - DBSELECTAREA E SETORDER FIM " + TIME())

	Conout("FRECUAUT2 - WHILE SC7 E ADD APRODSC7 " + TIME())
	cIn := "("
	While !SC7->(Eof()) .And. SC7->C7_NUM == cNum
		aAdd(aProdSC7, { SC7->C7_NUM, SC7->C7_XDTVEN, SC7->C7_PRODUTO })
		cIn := cIn + "'"+AllTrim(SC7->C7_PRODUTO)+"',"
		SC7->(DbSkip())
	EndDo
	cIn := SUBSTR( cIn, 1, Len(cIn)-1) + ")"
	Conout("FRECUAUT2 - WHILE SC7 E ADD APRODSC7 FIM " + TIME())

	Conout("FRECUAUT2 - RESTAREA SC7 " + TIME())
	RestArea(aAreaSC7)
	Conout("FRECUAUT2 - FIM RESTAREA SC7 " + TIME())


	Conout("FRECUAUT2 - zDiasUteis " + TIME())
	ndiasUteis := zDiasUteis(dDatabase, aProdSC7[1][2])
	Conout("FRECUAUT2 - FIM zDiasUteis " + TIME())

	CONOUT(" DBSELECTAREA P39, DBSETORDER E DBGOTOP " + TIME())
	DbSelectArea("P39")
	P39->(DbSetOrder(1))
	P39->(DbGoTop())
	CONOUT(" FTEMANEXO " + TIME())
	cAnexo := iif(fTemAnexo(),"1","2")
	CONOUT(" WHILE P39 " + TIME())

	cQry += " SELECT TRIM( UTL_RAW.CAST_TO_VARCHAR2(P39_MSGMAI)) AS MSG, P39.* FROM " + RetSqlName("P39") + " P39 WHERE D_E_L_E_T_ = ' ' AND P39_STATUS = '1' AND ((P39_PRODUT = ' ' AND P39_TDPROD = '1') OR P39_PRODUT IN " +cIn+ ") ORDER BY P39_PRODUT "

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQry), cAliasP39, .T., .T.)

	If !(cAliasP39)->(Eof())

		While !(cAliasP39)->(Eof())
			If AllTrim((cAliasP39)->P39_PRODUT) == ""
				lAnexoTD := .T.
				Exit
			EndIf
			(cAliasP39)->(DbSkip())
		EndDo

		(cAliasP39)->(DbGoTop())

		While !(cAliasP39)->(Eof())

			If lVldVnc .And. lVlDAnx
				Exit
			EndIf

			If !lVlDAnx
				If lAnexoTD
					if cAnexo == "2"
						cErro += AllTrim((cAliasP39)->MSG) + CRLF
						lRet := .T.
						lVlDAnx := .T.
					endif
				Else
					If (cAliasP39)->P39_ANEXO == "1"
						if cAnexo == "2"
							cErro += AllTrim((cAliasP39)->MSG) + CRLF
							lRet := .T.
							lVlDAnx := .T.
						endif
					EndIf
				EndIf
			EndIf

			If !lVldVnc
				If (cAliasP39)->P39_VENCRE > 0
					If ndiasUteis <= (cAliasP39)->P39_VENCRE
						cErro += AllTrim((cAliasP39)->MSG) + CRLF
						lRet := .T.
						lVldVnc := .T.
					EndIf
				EndIf
			EndIf
			(cAliasP39)->(DbSkip())
		EndDo

	EndIf

	(cAliasP39)->(DbCloseArea())

	/*/While !P39->(Eof())
	If P39->P39_STATUS != "1"
		P39->(DbSkip())
		Loop
	endif
	cCod := P39->P39_CODIGO
	Conout(" Segundo While " + Time())
	While !P39->(Eof()) .And. AllTrim(cCod) == AllTrim(P39->P39_CODIGO)
		aAdd(aProdP39, { P39->P39_CODIGO, P39->P39_VENCRE, P39->P39_PRODUT, P39->P39_DESCRI, P39->P39_TDPROD, P39->P39_ANEXO, P39->P39_MSGMAI})
		P39->(DbSkip())
	EndDo
	Conout(" Fim Segundo While " + Time())
	//Verifica vencimento e produto.
	For nX := 01 To Len(aProdSC7)
		if AllTrim(aProdP39[1][5]) == "1"
			nPosPro := 1
		else
			Conout(" aScan 1 " + Time())
			nPosPro := aScan(aProdP39, {|x| AllTrim(x[3]) == AllTrim(aProdSC7[nX][3]) })
			Conout(" Fim aScan 1 " + Time())
		endif
		if ((ndiasUteis <= aProdP39[1][2]) .And. nPosPro > 0) .Or. aProdP39[1][2] == 0
			if (AllTrim(aProdP39[1][6]) == "1")
				if cAnexo == "2"
					Conout( "Replace cErro 1 " + Time())
					cErro += Replace(AllTrim(aProdP39[1][7]),CRLF," ")
					Conout( "Fim Replace cErro " + Time())
				else
					loop
				endif
			else
				Conout( "Replace cErro 2 " + Time())
				cErro += Replace(AllTrim(aProdP39[1][7]),CRLF," ")
				Conout( " Conout Replace cErro " + Time())
			endif
			//cErro := " Recusado automático pela regra [" + AllTrim(aProdP39[1][1]) + ":" + AllTrim(aProdP39[1][4]) + "]"
			if !lRet
				lRet := .T.
			endif
			Loop
		endif
		Next nX/*/
/*		if lRet
			exit
	endif
*/
		/*/aProdP39 := {}
	EndDo/*/
		CONOUT(" FIM WHILE " + TIME())
		CONOUT(" RESTAREA 39,C7,AAREA " + TIME())
		RestArea(aAreaP39)
		RestArea(aAreaSC7)
		RestArea(aArea)
		CONOUT(" FIM RESTAREA 39,C7,AAREA " + TIME())
		return { lRet, cErro }

Static Function zDiasUteis(dDtIni, dDtFin)
	Local aArea    := GetArea()
	Local nDias    := 0
	Local dDtAtu   := sToD("")
	Default dDtIni := dDataBase
	Default dDtFin := dDataBase

	//Enquanto a data atual for menor ou igual a data final
	dDtAtu := dDtIni
	While dDtAtu <= dDtFin
		//Se a data atual for uma data Válida
		If dDtAtu == DataValida(dDtAtu)
			nDias++
		EndIf

		dDtAtu := DaySum(dDtAtu, 1)
	EndDo

	RestArea(aArea)
Return nDias
// ------------------------------------------------------------------
// [ fim de f0100404.prw ]
// ------------------------------------------------------------------
 
 Static Function fBuscImpo(nLinha,cIdZkt,aAutoImp)
  //Para impostos de Itens informar: referência, valor, número da linha
	
	//Local aAutoImp := {}
	Local cJson := ""
	//Local nTamJson    := TamSX3("ZKT_JSON")[1]

	dbSelectArea("ZKT")
	ZKT->(dbSetOrder(2))

	If ZKT->(dbSeek(cIdZkt))
		cJson := ZKT->ZKT_JSON
		SItemJson(nLinha, cJson,aAutoImp)
            
		
		/*
		
		cIdBlu  := Alltrim(oJson:GetJsonText("uuid"))
		cDocNum := Alltrim(oJson:GetJsonText("document_number"))
		cValDev := Alltrim(oJson:GetJsonText("value"))
		cMsgBlu := Alltrim(oJson:GetJsonText("message"))
		*/
		//aAdd(aAutoImp,{"IT_BASEICM", 361.21 , 1}) // Base ICMS
		//aAdd(aAutoImp,{"IT_ALIQICM", 12     , 1}) // Porcentagem ICMS
		//aAdd(aAutoImp,{"IT_VALICM" , 43.35  , 1}) // Valor ICMS
		//aAdd(aAutoImp,{"IT_BASESOL", 480.41 , 1}) // Base ICMS ST
		//aAdd(aAutoImp,{"IT_ALIQSOL", 12     , 1}) // Porcentagem ICMS
 
 	//C7_BASEICM/C7_BASEIPI/C7_BASEIR/C7_BASESOL/C7_VALICM/C7_VALIPI/C7_VALIR/C7_VALSOL/C7_ICMSRET/C7_ICMCOMP

	EndIf 
    // Exemplo para manipular o pergunte MTA103
    //aAdd(aParamAux, {"MV_PAR01", 2}) //-- Mostra Lanc. Contabil? 1 = Sim, 2 = NÃ£o
    //aAdd(aParamAux, {"MV_PAR06", 2}) //-- Contabilizacao Online? 1 = Sim, 2 = NÃ£o
 
 
    //3-InclusÃ£o / 4-ClassificaÃ§Ã£o / 5-ExclusÃ£o
    //MSExecAuto({|x,y,z,a,b,c,d| MATA103(x,y,z,a,b,c,d,,,)},aCab,aLinha,nOpc,lTela,aAutoImp,,aParamAux)

Return 

Static Function SItemJson(nLinha, cJson,aAutoImp)
   	Local aItems
	Local i
	Local cError := ""
	Local found
	Local lValIcm := SuperGetMV("FS_JVALICM",.F.,.T.) // VALIDA ICMS CLASSIFICACAO 
	Local lValIPI := SuperGetMV("FS_JVALIPI",.F.,.T.) // VALIDA IPI CLASSIFICACAO 
	Local lValIR  := SuperGetMV("FS_JVALIR" ,.F.,.T.) // VALIDA IR CLASSIFICACAO 
	Local lValIss := SuperGetMV("FS_JVALISS",.F.,.T.) // VALIDA ISS CLASSIFICACAO 
	Local lValPCC := SuperGetMV("FS_JVALPCC",.F.,.T.) // VALIDA PCC CLASSIFICACAO 
	Local lValINS := SuperGetMV("FS_JVALINS",.F.,.T.) // VALIDA ISS CLASSIFICACAO 
	Local lValSOL := SuperGetMV("FS_JVALSOL",.F.,.T.) // VALIDA SOl CLASSIFICACAO 
	Local cTipServCM:= SuperGetMV("FS_TIPSERV",.F., "03") //Tipo de Servico que não classifica automaticamente
	Local cCodServ := SuperGetMV("FS_CSERVCL",.F., "17.05") //Código de Serviço que não classifica automaticamente
	Local nTAliqIns := SuperGetMV("FS_TALIQIN",.F., 11) //Tolerancia de Alíquota do INSS para Classificação automática
    Local nValCOF := 0
    Local nValPIS := 0
    Local nValCSL := 0
    //Local nValISS := 0
   //Local nValPCC := 0
    //Local nValINS := 0
    Local nValSOL := 0
    //Local nValIR  := 0
    Local nValIPI := 0
    Local nValICM := 0
    Local nBaseIcm := 0
    Local nAliqIcm := 0
    Local nBaseIpi := 0
    Local nAliqIpi := 0

    Local lValorIpi := .F.
		
	Private lPcc 	:= .F.
	Private lIcms 	:= .F.
	
	Private lImpPis := .F.
	Private lImpCof := .F.
	Private lImpCsl := .F.
	Private nRecIss := 1 // 1 - ISS Recolhe, 2 - ISS Nao recolhe
	//Private aAutoImp := {}
	Private oJson
	Private lRecIss := .F.

	Private cNfsServ := ""
	Private lNfsServ := .F.
	
	nBaseIns := 0
	nAliqIns := 0
	nValIns := 0

	nBaseIss := 0
	nAliqIss := 0
	nValIss  := 0

	nBaseIr  := 0
	nAliqIr  := 0
	nBaseIss := 0
	nAliqIss := 0

	nBaseSol := 0

	nBaseCof := 0
	nAliqCof := 0
	nBasePis := 0
	nAliqPis := 0
	nBaseCsl := 0
	nAliqCsl := 0

	lIr    := .F.
	lIss 	:= .F.
	lInss 	:= .F.


	//SuperGetMv("MV_APRPCEC",.F.,.F.)

    // JSON recebido como string
    //cJson := '{...}' // Substitua pelo JSON completo
	oJson := JsonObject():new() 
    cError:= oJson:fromJson(cJson)  	
    // Fazendo o parsing do JSON
   // oJson := JsonParse(cJson)
	 IF !Empty(cError)
	 	 conout("Houve um erro na conversão do texto para objeto" , "Falha no 'parse' do JSON")
		 Return
	 EndIf 
	//nId := oJson:GetJSonObject('a1_cod')
    // Verificando se o objeto JSON foi criado com sucesso
    IF !Empty(oJson["data"]["itens"]) 
        aItems := oJson["data"]["itens"]//["itens"]
        found := .F. // Variável para indicar se o item foi encontrado

        // Loop através dos itens encontrados
		
        FOR i := 1 TO Len(oJson['data']['itens'])
            // Verifica se o código do item corresponde ao código pesquisado
            IF AllTrim(aItems[i]['fields']["C7_ITEM"]) == nLinha
             	nLin := Val(nLinha)

				/*/ ************************* /*/	
				/*/ CALCULO DO ICMS DAS NOTAS /*/
				/*/ ************************* /*/	

				If lValIcm
					lAliqIcm := .F.; lValorIcm  := .F.; lBaseIcm := .F.
								
					If Type("aItems[i]['fields']['C7_BASEICM']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASEICM"] ) .OR. aItems[i]['fields']["C7_BASEICM"] > 0 
							nBaseIcm := aItems[i]['fields']["C7_BASEICM"]
							lBaseIcm := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASEICM']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASEICM'] ) .OR. oJson['data']['header']['fields']['C7_BASEICM'] > 0 
							nBaseIcm := oJson['data']['header']['fields']['C7_BASEICM']
							lBaseIcm := .T.
						EndIf 
					EndIf 			

					If Type("aItems[i]['fields']['C7_PICM']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_PICM"] ) .OR. aItems[i]['fields']["C7_PICM"] > 0 
							nAliqIcm := aItems[i]['fields']["C7_PICM"]
							lAliqIcm := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_PICM']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_PICM'] ) .OR. oJson['data']['header']['fields']['C7_PICM'] > 0 
							nAliqIcm := oJson['data']['header']['fields']['C7_PICM']
							lAliqIcm := .T.
						EndIf 
					EndIf 	
	
					If Type("aItems[i]['fields']['C7_VALICM']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALICM"] ) .OR. aItems[i]['fields']["C7_VALICM"] > 0 
							nValIcm := aItems[i]['fields']["C7_VALICM"]
							lValorIcm := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALICM']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALICM'] ) .OR. oJson['data']['header']['fields']['C7_VALICM'] > 0 
							nValIcm := oJson['data']['header']['fields']['C7_VALICM']
							lValorIcm := .T.
						EndIf 
					EndIf 	
			

					If lAliqIcm .and. lValorIcm .and. lBaseIcm 
						aAdd(aAutoImp,{"IT_BASEICM", nBaseIcm , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_ALIQICM", nAliqIcm , nLin}) // Aliquota ICMS
						aAdd(aAutoImp,{"IT_VALICM" , nValIcm , nLin}) // Valor ICMS
						lIcms := .T.
					EndIf 
				EndIf 

				/*/ ************************* /*/	
				/*/ CALCULO DO IPI DAS NOTAS /*/
				/*/ ************************* /*/	
				If lValIPI
					lAliqIpi := .F.; lValIpi  := .F.; lBaseIpi := .F.

                   	If Type("aItems[i]['fields']['C7_BASEIPI']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASEIPI"] ) .OR. aItems[i]['fields']["C7_BASEIPI"] > 0 
							nBaseipi := aItems[i]['fields']["C7_BASEIPI"]
							lBaseipi := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASEIPI']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASEIPI'] ) .OR. oJson['data']['header']['fields']['C7_BASEIPI'] > 0 
							nBaseipi := oJson['data']['header']['fields']['C7_BASEIPI']
							lBaseipi := .T.
						EndIf 
					EndIf 	

                    If Type("aItems[i]['fields']['C7_IPI']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_IPI"] ) .OR. aItems[i]['fields']["C7_IPI"] > 0 
							nAliqIpi := aItems[i]['fields']["C7_IPI"]
							lAliqIpi := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_IPI']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_IPI'] ) .OR. oJson['data']['header']['fields']['C7_IPI'] > 0 
							nAliqIpi := oJson['data']['header']['fields']['C7_IPI']
							lAliqIpi := .T.
						EndIf 
					EndIf 	

                    If Type("aItems[i]['fields']['C7_VALIPI']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALIPI"] ) .OR. aItems[i]['fields']["C7_VALIPI"] > 0 
							nValIpi := aItems[i]['fields']["C7_VALIPI"]
							lValorIpi := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALIPI']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALIPI'] ) .OR. oJson['data']['header']['fields']['C7_VALIPI'] > 0 
							nValIpi := oJson['data']['header']['fields']['C7_VALIPI']
							lValorIpi := .T.
						EndIf 
					EndIf 	

					If lAliqIpi .and. lValorIpi .and. lBaseipi
						aAdd(aAutoImp,{"IT_BASEIPI", nBaseipi , nLin}) // Base IPI
						aAdd(aAutoImp,{"IT_ALIQIPI", nAliqipi , nLin}) // Aliquota IPI
						aAdd(aAutoImp,{"IT_VALIPI" , nValIpi  , nLin}) // Valor IPI
						lIpi := .T.
					EndIf 
				EndIf 
				
				If lValIr 
					/*/ CALCULO DO IR DAS NOTAS /*/	
					lAliqiR := .F.; lValorIr  := .F.; lBaseIR := .F.

                    If Type("aItems[i]['fields']['C7_BASEIR']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASEIR"] ) .OR. aItems[i]['fields']["C7_BASEIR"] > 0 
							aAdd(aAutoImp,{"IT_BASEIRR", aItems[i]['fields']["C7_PRECO"] , nLin})
							If Len(oJson['data']['itens']) > 1	 
								nBaseIr := aItems[i]['fields']["C7_PRECO"] //aItems[i]['fields']["C7_BASEIR"]
							Else
								nBaseIr := aItems[i]['fields']["C7_BASEIR"]
							EndIf
							lBaseIr := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASEIR']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASEIR'] ) .OR. oJson['data']['header']['fields']['C7_BASEIR'] > 0 
							If Len(oJson['data']['itens']) > 1	 
								nBaseIr := aItems[i]['fields']["C7_PRECO"]
							Else
								nBaseIr := oJson['data']['header']['fields']['C7_BASEIR']
							EndIF
							lBaseIr := .T.
						EndIf 
					EndIf 	

                    If Type("aItems[i]['fields']['C7_ALIQIR']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_ALIQIR"] ) .OR. aItems[i]['fields']["C7_ALIQIR"] > 0 
							nAliqIr := aItems[i]['fields']["C7_ALIQIR"]
							lAliqiR := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_ALIQIR']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_ALIQIR'] ) .OR. oJson['data']['header']['fields']['C7_ALIQIR'] > 0 
							nAliqIr := oJson['data']['header']['fields']['C7_ALIQIR']
							lAliqiR := .T.
						EndIf 
					EndIf 	

                    If Type("aItems[i]['fields']['C7_VALIR']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALIR"] ) .OR. aItems[i]['fields']["C7_VALIR"] > 0 
							If Len(oJson['data']['itens']) > 1	
								nValIr := Round(aItems[i]['fields']["C7_VALIR"] * (aItems[i]['fields']["C7_PRECO"] / aItems[i]['fields']["C7_BASEIR"]),2)//aItems[i]['fields']["C7_VALIR"]
							Else
								nValIr := aItems[i]['fields']["C7_VALIR"]
							EndIf
							lValorIr := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALIR']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALIR'] ) .OR. oJson['data']['header']['fields']['C7_VALIR'] > 0 
							If Len(oJson['data']['itens']) > 1
								nValIr := Round(oJson['data']['header']['fields']['C7_VALIR'] * (aItems[i]['fields']["C7_PRECO"] / oJson['data']['header']['fields']['C7_BASEIR']),2)//oJson['data']['header']['fields']['C7_VALIR']
							Else
								nValIr := oJson['data']['header']['fields']['C7_VALIR']
							EndIf
							lValorIr := .T.
						EndIf 
					EndIf 	

					If lAliqIr .and. lValorIr .and. lBaseIr
						aAdd(aAutoImp,{"IT_BASEIRR", nBaseIr , nLin}) // Base IR
						aAdd(aAutoImp,{"IT_ALIQIRR", nAliqIr , nLin}) // Aliquota IR
						aAdd(aAutoImp,{"IT_VALIRR" , nValIr , nLin}) // Valor IR
						lIr:= .T.
					EndIf 
				EndIf 

				/*/ CALCULO DO ISS DAS NOTAS /*/	

				If lValISS 
					/*/ CALCULO DO ISS DAS NOTAS /*/	
					lAliqISS := .F.; lValorISS  := .F.; lBaseISS := .F.

                    If Type("aItems[i]['fields']['C7_BASEISS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASEISS"] ) .OR. aItems[i]['fields']["C7_BASEISS"] > 0 
							If Len(oJson['data']['itens']) > 1	 
								nBaseIss := aItems[i]['fields']["C7_PRECO"] 
							Else
								nBaseIss := aItems[i]['fields']["C7_BASEISS"]
							EndIf
							lBaseIss := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASEISS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASEISS'] ) .OR. oJson['data']['header']['fields']['C7_BASEISS'] > 0 
							If Len(oJson['data']['itens']) > 1	 
								nBaseIss := aItems[i]['fields']["C7_PRECO"]
							Else
								nBaseIss := oJson['data']['header']['fields']['C7_BASEISS']
							EndIf
							lBaseIss := .T.
						EndIf 
					EndIf 	
					
                    If Type("aItems[i]['fields']['C7_ALIQISS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_ALIQISS"] ) .OR. aItems[i]['fields']["C7_ALIQISS"] > 0 
							nAliqIss := aItems[i]['fields']["C7_ALIQISS"]
							lAliqiss := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_ALIQISS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_ALIQISS'] ) .OR. oJson['data']['header']['fields']['C7_ALIQISS'] > 0 
							nAliqIss := oJson['data']['header']['fields']['C7_ALIQISS']
							lAliqiss := .T.
						EndIf 
					EndIf 	

                    If Type("aItems[i]['fields']['C7_VALISS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALISS"] ) .OR. aItems[i]['fields']["C7_VALISS"] > 0 
							If Len(oJson['data']['itens']) > 1	
								nValIss := Round(aItems[i]['fields']["C7_VALISS"] * (aItems[i]['fields']["C7_PRECO"] / aItems[i]['fields']["C7_BASEISS"]),2)
							Else
								nValIss := aItems[i]['fields']["C7_VALISS"]
							EndIf
							lValorISS := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALISS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALISS'] ) .OR. oJson['data']['header']['fields']['C7_VALISS'] > 0 
							If Len(oJson['data']['itens']) > 1
								nValIss := Round(oJson['data']['header']['fields']['C7_VALISS'] * (aItems[i]['fields']["C7_PRECO"] / oJson['data']['header']['fields']['C7_BASEISS']),2)
							Else
								nValIss := oJson['data']['header']['fields']['C7_VALISS']
							EndIf
							lValorISS := .T.
						EndIf
					EndIf

					If Type("oJson['data']['header']['fields']['F1_RECISS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['F1_RECISS'] ) .OR. oJson['data']['header']['fields']['F1_RECISS'] > 0 
							cRecIss := oJson['data']['header']['fields']['F1_RECISS']
							lRecIss := .T.
						EndIf 
					EndIf 	

					If lRecIss 
						If cReciss == "2"
							nRecIss := 1
						Else 
							nRecIss := 2
						EndIf 
						aadd(aTitulo,{ 'F1_RECISS'    , nRecIss    , NIL }) // ISS Retido
					EndIf 

					If lAliqIss  .and. lValorISS .and. lBaseIss
						aAdd(aAutoImp,{"IT_BASEISS", nBaseIss , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_ALIQISS", nAliqIss , nLin}) // Aliquota ICMS
						aAdd(aAutoImp,{"IT_VALISS" , nValIss , nLin}) // Valor ICMS
					//	aAdd(aAutoImp,{"NF_RECISS" , nValIss , nLin}) // Valor ICMS
						lIss := .T.
					EndIf 
				EndIf 

				/*/ CALCULO DO PCC DAS NOTAS /*/	
				
				If lValPCC
					lAliqPis := .F.; lValPis  := .F.; lBasePis := .F.
					lAliqCof := .F.; lValCof  := .F.; lBaseCof := .F.
					lAliqCsl := .F.; lValCsl  := .F.; lBaseCsl := .F.

					/*/ CSLL /*/ 

                    If Type("aItems[i]['fields']['C7_BASECSL']") <> "U" 
						If  !Empty(aItems[i]['fields']["C7_BASECSL"] ) .OR. !Empty(aItems[i]['fields']["C7_BASECSL"]) > 0 
							nBaseCsl := aItems[i]['fields']["C7_BASECSL"]
							lBaseCsl := .T.
						EndIf 
					ElseIf Type("aItems[i]['fields']['C7_BASCSL']") <> "U" 
						If !Empty(aItems[i]['fields']["C7_BASCSL"] ) .OR. !Empty(aItems[i]['fields']["C7_BASCSL"]) > 0 
							nBaseCsl := aItems[i]['fields']["C7_BASCSL"]
							lBaseCsl := .T.
						EndIf 
					ElseIf Type("oJson['data']['header']['fields']['C7_BASECSL']") <> "U" 
						If  (!Empty(oJson['data']['header']['fields']['C7_BASECSL'] ) .OR. oJson['data']['header']['fields']['C7_BASECSL'] > 0 ) 
							nBaseCsl := oJson['data']['header']['fields']['C7_BASECSL']
							lBaseCsl := .T.
						EndIf 
					ElseIf Type("oJson['data']['header']['fields']['C7_BASCSL']") <> "U" 
						If !Empty(oJson['data']['header']['fields']['C7_BASCSL'] ) .OR. oJson['data']['header']['fields']['C7_BASCSL'] > 0 
							nBaseCsl := oJson['data']['header']['fields']['C7_BASCSL']
							lBaseCsl := .T.
						EndIf 
					EndIf 	
                    
                    If Type("aItems[i]['fields']['C7_ALQCSL']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_ALQCSL"] ) .OR. aItems[i]['fields']["C7_ALQCSL"] > 0 
							nAliqCsl := aItems[i]['fields']["C7_ALQCSL"]
							lAliqCsl := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_ALQCSL']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_ALQCSL'] ) .OR. oJson['data']['header']['fields']['C7_ALQCSL'] > 0 
							nAliqCsl := oJson['data']['header']['fields']['C7_ALQCSL']
							lAliqCsl := .T.
						EndIf 
					EndIf 	

                    If Type("aItems[i]['fields']['C7_VALCSL']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALCSL"] ) .OR. aItems[i]['fields']["C7_VALCSL"] > 0 
							nValCsl := aItems[i]['fields']["C7_VALCSL"]
							lValCsl := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALCSL']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALCSL'] ) .OR. oJson['data']['header']['fields']['C7_VALCSL'] > 0 
							nValCsl := oJson['data']['header']['fields']['C7_VALCSL']
							lValCsl := .T.
						EndIf 
					EndIf 	

					If lAliqCsl .and. lValCsl .and. lBaseCsl
						aAdd(aAutoImp,{"IT_BASECSL", nBaseCsl , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_ALIQCSL", nAliqCsl , nLin}) // Aliquota ICMS
						aAdd(aAutoImp,{"IT_VALCSL" , nValCsl  , nLin}) // Valor ICMS
						lImpCsl := .T.
					EndIf 

					/*/ PIS /*/ 

                    If Type("aItems[i]['fields']['C7_BASPIS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASPIS"] ) .OR. aItems[i]['fields']["C7_BASPIS"] > 0 
							nBasePIS := aItems[i]['fields']["C7_BASPIS"]
							lBasePIS := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASPIS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASPIS'] ) .OR. oJson['data']['header']['fields']['C7_BASPIS'] > 0 
							nBasePIS := oJson['data']['header']['fields']['C7_BASPIS']
							lBasePIS := .T.
						EndIf 
					EndIf 	
                    
                    If Type("aItems[i]['fields']['C7_ALQPIS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_ALQPIS"] ) .OR. aItems[i]['fields']["C7_ALQPIS"] > 0 
							nAliqPIS := aItems[i]['fields']["C7_ALQPIS"]
							lAliqPIS := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_ALQPIS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_ALQPIS'] ) .OR. oJson['data']['header']['fields']['C7_ALQPIS'] > 0 
							nAliqPIS := oJson['data']['header']['fields']['C7_ALQPIS']
							lAliqPIS := .T.
						EndIf 
					EndIf
                    
                    If Type("aItems[i]['fields']['C7_VALPIS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALPIS"] ) .OR. aItems[i]['fields']["C7_VALPIS"] > 0 
							nValPIS := aItems[i]['fields']["C7_VALPIS"]
							lValPIS := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALPIS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALPIS'] ) .OR. oJson['data']['header']['fields']['C7_VALPIS'] > 0 
							nValPIS := oJson['data']['header']['fields']['C7_VALPIS']
							lValPIS := .T.
						EndIf 
					EndIf

					If lAliqPIS .and. lValPIS .and. lBasePIS
						aAdd(aAutoImp,{"IT_BASEPIS", nBasePIS , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_ALIQPIS", nAliqPIS , nLin}) // Aliquota ICMS
						aAdd(aAutoImp,{"IT_VALPIS" , lValPIS  , nLin}) // Valor ICMS
						lImpPis := .T.
					EndIf 
				
					/*/ COFINS /*/ 

                    If Type("aItems[i]['fields']['C7_BASCOF']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASCOF"] ) .OR. aItems[i]['fields']["C7_BASCOF"] > 0 
							nBaseCOF := aItems[i]['fields']["C7_BASCOF"]
							lBaseCOF := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASCOF']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASCOF'] ) .OR. oJson['data']['header']['fields']['C7_BASCOF'] > 0 
							nBaseCOF := oJson['data']['header']['fields']['C7_BASCOF']
							lBaseCOF := .T.
						EndIf 
					EndIf

                    If Type("aItems[i]['fields']['C7_ALQCOF']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_ALQCOF"] ) .OR. aItems[i]['fields']["C7_ALQCOF"] > 0 
							nAliqCOF := aItems[i]['fields']["C7_ALQCOF"]
							lAliqCOF := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_ALQCOF']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_ALQCOF'] ) .OR. oJson['data']['header']['fields']['C7_ALQCOF'] > 0 
							nAliqCOF := oJson['data']['header']['fields']['C7_ALQCOF']
							lAliqCOF := .T.
						EndIf 
					EndIf

                    If Type("aItems[i]['fields']['C7_VALCOF']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALCOF"] ) .OR. aItems[i]['fields']["C7_VALCOF"] > 0 
							nValCOF := aItems[i]['fields']["C7_VALCOF"]
							lValCOF := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALCOF']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALCOF'] ) .OR. oJson['data']['header']['fields']['C7_VALCOF'] > 0 
							nValCOF := oJson['data']['header']['fields']['C7_VALCOF']
							lValCOF := .T.
						EndIf 
					EndIf

					If lBaseCOF .and. lAliqCOF .and. lValCOF
						aAdd(aAutoImp,{"IT_BASECOF", nBaseCOF , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_ALIQCOF", nAliqCOF , nLin}) // Aliquota ICMS
						aAdd(aAutoImp,{"IT_VALCOF" , nValCOF  , nLin}) // Valor ICMS
						lImpCof := .T.
					EndIf 

					If lImpPis .and. lImpCof .and. lImpCsl
						lPcc := .T.
					EndIf 
								
				EndIf 

				If  lValIns
					lAliqIns := .F.; lValorIns  := .F.; lBaseIns := .F.
					/*/ INSS /*/ 
                    If Type("aItems[i]['fields']['C7_BASEINS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASEINS"] ) .OR. aItems[i]['fields']["C7_BASEINS"] > 0 
							If Len(oJson['data']['itens']) > 1	 
								nBaseIns := aItems[i]['fields']["C7_PRECO"] 
							Else
								nBaseIns := aItems[i]['fields']["C7_BASEINS"]
							EndIf
							lBaseIns := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASEINS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASEINS'] ) .OR. oJson['data']['header']['fields']['C7_BASEINS'] > 0 
							If Len(oJson['data']['itens']) > 1	 
								nBaseIns := aItems[i]['fields']["C7_PRECO"] 
							Else
								nBaseIns := oJson['data']['header']['fields']['C7_BASEINS']
							EndIf
							lBaseIns := .T.
						EndIf 
					EndIf

                    If Type("aItems[i]['fields']['C7_ALIQINS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_ALIQINS"] ) .OR. aItems[i]['fields']["C7_ALIQINS"] > 0 
							nAliqIns := aItems[i]['fields']["C7_ALIQINS"]
							lAliqIns := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_ALIQINS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_ALIQINS'] ) .OR. oJson['data']['header']['fields']['C7_ALIQINS'] > 0 
							nAliqIns := oJson['data']['header']['fields']['C7_ALIQINS']
							If ValType(nAliqIns) == "C"
								nAliqIns := Val(nAliqIns)
							EndIf 
							lAliqIns := .T.
						EndIf 
					EndIf

                    If Type("aItems[i]['fields']['C7_VALINS']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALINS"] ) .OR. aItems[i]['fields']["C7_VALINS"] > 0 
							If Len(oJson['data']['itens']) > 1	
								nValIns := Round(aItems[i]['fields']["C7_VALINS"] * (aItems[i]['fields']["C7_PRECO"] / aItems[i]['fields']["C7_BASEINS"]),2)
							Else
								nValIns := aItems[i]['fields']["C7_VALINS"]
							EndIf
							If ValType(nValIns) == "C"
								nValIns := Val(nValIns)
							EndIf 
							lValorIns := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALINS']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALINS'] ) .OR. oJson['data']['header']['fields']['C7_VALINS'] > 0 
							If Len(oJson['data']['itens']) > 1
								nValIns := Round(oJson['data']['header']['fields']['C7_VALINS'] * (aItems[i]['fields']["C7_PRECO"] / oJson['data']['header']['fields']['C7_BASEINS']),2)
							Else
								nValIns := oJson['data']['header']['fields']['C7_VALINS']
							EndIf
							If ValType(nValIns) == "C"
								nValIns := Val(nValIns)
							EndIf 
							lValorIns := .T.
						EndIf 
					EndIF 
					if Type("oJson['data']['header']['fields']['E2_XTPSERV']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['E2_XTPSERV'] ) .OR. oJson['data']['header']['fields']['E2_XTPSERV'] > "0" 
							cTipServ := oJson['data']['header']['fields']['E2_XTPSERV']
							lTipServ := .T.
						EndIf 
					EndIf

					If lTipServ
						If Alltrim(cTipServ) == Alltrim(cTipServCM)
							lClassAut := .F.
						Else
							lServObra := .F.
						EndIf 
					EndIF 

					If nALiqIns > nTAliqIns //Tolerancia de Aliquota para Classificacao Automatica
						lClassAut := .F.
                 	EndIF 
					
					If lAliqIns .and. lValorIns .and. lBaseIns
						aAdd(aAutoImp,{"IT_BASEINS", nBaseIns , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_ALIQINS", nAliqIns , nLin}) // Aliquota ICMS
						aAdd(aAutoImp,{"IT_VALINS" , nValIns  , nLin}) // Valor ICMS
						lInss := .T.
					EndIf 

				EndIf 

				//If Type("oJson['data']['header']['fields']['E2_XTPSERV']") <> "U"
				//	If  !Empty(oJson['data']['header']['fields']['E2_XTPSERV'] ) .OR. oJson['data']['header']['fields']['E2_XTPSERV'] > "0" 
				//		cTipServ := oJson['data']['header']['fields']['E2_XTPSERV']
				//		lTipServ := .T.
				//	EndIf 
				//EndIf 

				lNfsServ := .F.

				If lTipServ
					If Alltrim(cTipServ) == Alltrim(cTipServCM)
						lClassAut := .F.
					Else
						lServObra := .F.
					EndIf 
				EndIF 
				
				If Type("aItems[i]['fields']['B1_XREFER']") <> "U"
					If  !Empty(aItems[i]['fields']["B1_XREFER"] ) //.OR. aItems[i]['fields']["B1_XREFER"] > 0 )
						cNfsServ := aItems[i]['fields']["B1_XREFER"]
						lNfsServ := .T.
					EndIf 
				Elseif Type("oJson['data']['header']['fields']['B1_XREFER']") <> "U"
					If  !Empty(oJson['data']['header']['fields']['B1_XREFER'] ) //.OR. oJson['data']['header']['fields']['B1_XREFER'] > 0 )
						cNfsServ := oJson['data']['header']['fields']['B1_XREFER']
						lNfsServ := .T.
					EndIf 
				EndIf

				If lNfsServ
					If Alltrim(cNfsServ) $ Alltrim(cCodServ)
						lClassAut := .F.
					EndIF 
				EndIf 

				If  lValSol
					lValorSol  := .F.; lBaseSol := .F.
					
					/*/ INSS /*/ 
                    If Type("aItems[i]['fields']['C7_BASESOL']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_BASESOL"] ) .OR. aItems[i]['fields']["C7_BASESOL"] > 0 
							nBaseSol := aItems[i]['fields']["C7_BASESOL"]
							lBaseSol := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_BASESOL']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_BASESOL'] ) .OR. oJson['data']['header']['fields']['C7_BASESOL'] > 0 
							nBaseSol := oJson['data']['header']['fields']['C7_BASESOL']
							lBaseSol := .T.
						EndIf 
					EndIf

                    If Type("aItems[i]['fields']['C7_VALSOL']") <> "U"
						If  !Empty(aItems[i]['fields']["C7_VALSOL"] ) .OR. aItems[i]['fields']["C7_VALSOL"] > 0 
							nValSol := aItems[i]['fields']["C7_VALSOL"]
							lValorSol := .T.
						EndIf 
					Elseif Type("oJson['data']['header']['fields']['C7_VALSOL']") <> "U"
						If  !Empty(oJson['data']['header']['fields']['C7_VALSOL'] ) .OR. oJson['data']['header']['fields']['C7_VALSOL'] > 0 
							nValSol := oJson['data']['header']['fields']['C7_VALSOL']
							lValorSol := .T.
						EndIf 
					EndIf

					If lValorSol .and. lBaseSol
						aAdd(aAutoImp,{"IT_BASESOL", nBaseSol , nLin}) // Base ICMS	
						aAdd(aAutoImp,{"IT_VALSOL" , nValSol  , nLin}) // Valor ICMS
						lSolid := .T.
					EndIf 
				EndIf 

				/*If Len(aAutoImp) > 0
					aAdd(aAutoImp, {"C7_PRECO", aItems[i]['fields']["C7_PRECO"], nLin})
				EndIf*/

				//aAdd(aAutoImp,{"IT_BASESOL", 480.41 , nLin}) // Base ICMS ST
				//aAdd(aAutoImp,{"IT_ALIQSOL", 12     , nLin}) // Porcentagem ICMS
				//cDesc := aItems[i]["C7_DESCRI"]
                //ConOut("Item encontrado: " + AllTrim(aItems[i]["C7_ITEM"]) + ", Descrição: " + AllTrim(cDesc))
                //found := .T.
                EXIT // Sair do loop se o item for encontrado
            ENDIF
        NEXT
		cNaturez := fGetNatu()
        //IF !found        // Mensagem se o item não foi encontrado
        //    ConOut("Item com código " + codItem + " não encontrado.")
        //ENDIF
    ELSE
        ConOut("Não foi possível analisar o JSON ou itens não encontrados.")
    ENDIF
Return


Static Function fGetNatu
Local cNatur	:= ""
Local cQry 		:= ""
//Local cQrySx5   := ""
Local cEol 		:= chr(13)+ chr(10)
Local cNatuPer 	:= SuperGetMV("FS_NATUPER",.F., "SERV_01|SERV_02|SERV_03|SERV_04|SERV_05|SERV_06|SERV_07|SERV_08|SERV_09|SERV_10|SERV_FED|SERV_FED1|SERV_IR|SERV_ISS|SERV_PCC" ) // relacao naturezas permitidas
Local cNatuSx5  := ""
Local cAliasNat := GetNextAlias()
//Local cAliasSx5 := GetNextAlias()
Local cNatDef 	:= SuperGetMV("FS_NATUDEF",.F., "SERV_09") //Natureza Default
Local lNatuSx5 	:= SuperGetMV("FS_NATUSX5",.F., .F.) //Utiliza SX5 para buscar naturezas
Local cTabNatSx5:= SuperGetMV("FS_NATUTAB",.F., "ZL") //TABELA SX5 cadastrada com as naturezas
Local aNaturez  := {}
Local nI := 0
Local lUsaNatDef := SuperGetMV("FS_USANATD",.F., .F.)
Local lTemImp   := .F.

Local nNatAlIR  := 0
Local nPosIr    := 0
Local nNatAlIns := 0
Local nPosIns   := 0

//FormatIn(cNatuPer,"|")

	If lNatuSx5
		aNaturez 	 := FwGetSX5(cTabNatSx5)
		If len(aNaturez) > 0
			For nI:=1 to Len(aNaturez)
				If Empty(cNatuSx5)
					cNatuSx5 := AllTrim(SubStr(aNaturez[nI][4],1,55))
				Else
					cNatuSx5 += "|"+ AllTrim(aNaturez[nI][4]) 
				EndIf
			Next nI 
			cNatuPer := cNatuSx5
		EndIf
	EndIf 

	If Type("aAutoImp") == "A"
		If !Empty(aAutoImp)
			nPosIr := aScan(aAutoImp, {|x| AllTrim(x[1]) == "IT_ALIQIRR" })
			If nPosIr > 0
				nNatAlIR := aAutoImp[nPosIr][2]
			EndIf

			nPosIns := aScan(aAutoImp, {|x| AllTrim(x[1]) == "IT_ALIQINS" })
			If nPosIns > 0
				nNatAlIns := aAutoImp[nPosIns][2]
			EndIf
		EndIf
	EndIf 

	cQry := " SELECT ED_CODIGO NATUREZA FROM "+RetSqlName("SED")+ " SED "+cEol 
	cQry += " WHERE SED.D_E_L_E_T_ = ' ' "

	If lIr 
		cQry += " AND SED.ED_CALCIRF = 'S' "
		If nNatAlIR > 0
			//cQry += " AND SED.ED_PERCIRF = " + Alltrim(Str(nNatAlIR))	
			cQry += " AND SED.ED_PERCIRF = " + Alltrim(Str(nNatAlIR))	
		EndIf 
		lTemImp := .T.
	Else 
		cQry += " AND SED.ED_CALCIRF = 'N' "
	EndIf 

	If lIss
		cQry += " AND SED.ED_CALCISS = 'S' "
		lTemImp := .T.
	Else 
		cQry += " AND SED.ED_CALCISS = 'N' "
	EndIf 

	If lInss
		cQry += " AND SED.ED_CALCINS = 'S' "
		If nNatAlIns > 0
			cQry += " AND SED.ED_PERCINS = " + Alltrim(Str(nNatAlIns))
		EndIf 
		lTemImp := .T.
	Else 
		cQry += " AND SED.ED_CALCINS = 'N' "
	EndIf 

	If lPcc
		cQry += " AND SED.ED_CALCPIS = 'S' "
		cQry += " AND SED.ED_CALCCSL = 'S' "
		cQry += " AND SED.ED_CALCCOF = 'S' "
		lTemImp := .T.
	Else 
		cQry += " AND SED.ED_CALCPIS = 'N' "
		cQry += " AND SED.ED_CALCCSL = 'N' "
		cQry += " AND SED.ED_CALCCOF = 'N' "
	EndIf 

	//cQry += " AND SED.ED_CODIGO IN "+FormatIn(cNatuPer,"|")

	If Select((cAliasNat)) > 0 ; (cAliasNat)->(DbCloseArea()) ; EndIf
	TcQuery cQry New Alias (cAliasNat)
	
	If !(cAliasNat)->(Eof()) .and. (alltrim(cNatDef) <> alltrim((cAliasNat)->NATUREZA)) .And. lTemImp
		cNatur := (cAliasNat)->NATUREZA
	Else
		If lUsaNatDef .and. !Empty(cNatDef)
			lNatDef := .F.
			cNatur := cNatDef
		Else
			lNatDef := .T.
			cNatur := cNatDef 
		EndIf 
	EndIf 

	(cAliasNat)->(dbCloseArea())
	

/*  Código		Descrição							Impostos
	SERV_01		SRV RET ISS, PCC, INSS IR 1,5%		ISS PCC INSS IR 1,5%
	SERV_02		SRV RET ISS, PCC, INSS IR 1%		ISS PCC INSS IR 1%
	SERV_03		SERV COM RET DE ISS E IR			ISS IR
	SERV_04		SERV COM RET DE ISS E PCC			ISS PCC
	SERV_05		SERV COM RET DE INSS				INSS
	SERV_06		SERV RET 							INSS, PCC E ISS		INSS PCC ISS
	SERV_07		RET INSS E ISS						INSS ISS
	SERV_08		SERV RET 							ISS, IRRF E PCC	ISS IR PCC
	SERV_09		SERVIÇOS TOMADOS		
	SERV_10		SERV RET INSS E PCC					INSS PCC
	SERV_FED	SERV COM RET DE IR E PCC			IR PCC
	SERV_FED1	SERV COM RET DE INSS, IR E PCC		INSS IR PCC
	SERV_IR		SERV COM RET IR						IR
	SERV_ISS	SERV COM RET DE ISS					ISS
	SERV_PCC	SERV COM RET DE PCC					PCC
*/


Return cNatur

/* ------------------------------------------------------------------
// [ fim de f0100404.prw ]
// ------------------------------------------------------------------
/*{Protheus.doc} ExNotaProv
Exclui nota de provisã¯
@type function
@version P12 
@author Ricardo Junior
@since 3/11/2025
@param cFil, character, Filial
@param cNum, character, Numero
@return variant, nulo
/*/
Static Function ExNotaProv(cFil, cNum)

	Local aCabecNota := {}
	Local aItensNota := {}
	Local bExecAuto  := {||}
	Local nOpcExclui := 5
	//Local lContab := .F.
	Local nRecSC7 := 00

	Default cTipoSP := ""

	DbSelectArea("SC7")
	SC7->(DbSetOrder(01))
	SC7->(DbSeek(cFil+cNum))
	nRecSC7 := SC7->(Recno())
	cTipoSP := SC7->C7_XTPSP

	SF1->(DbSetOrder(1))
	If !SF1->(DbSeek(xFilial("SF1")+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
		Return
	EndIf
	
	DbSelectArea("SE2")
	SE2->(DbSetOrder(6))
	cChavE2 := XFilial("SE2") + SC7->(C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC)
	if SE2->(DbSeek(cChavE2))
		If cTipoSP == "4"
			If RecLock("SE2", .F.)
				SE2->E2_NUMBOR := " "
			SE2->(MsUnlock())
			EndIf 
		endif
	endif

	aCabecNota := {;
		{"F1_DOC"	 , SC7->C7_XDOC	  , Nil},;
		{"F1_SERIE"	 , SC7->C7_XSERIE , Nil},;
		{"F1_EMISSAO", SC7->C7_XDTEMI , Nil},;
		{"F1_FORNECE", SC7->C7_FORNECE, Nil},;
		{"F1_LOJA"	 , SC7->C7_LOJA	  , Nil};
		}

	bExecAuto := {|aCabec, aItens, nOpc| MatA103(aCabec, aItens, nOpc)}
	MsExecAuto(bExecAuto, aCabecNota, aItensNota, nOpcExclui)

	if lMsErroAuto
		DisarmTransaction()
		MostraErro()
		//oModel:SetErrorMessage(, ,ï¿½oModel:GetId(), ,ï¿½"Help",ï¿½"Erro na rotina automï¿½tica de exclusï¿½o da Nota fiscal",ï¿½"Verifique os dados informados.", ,ï¿½)
	else
		SC7->(DbGoTo(nRecSC7))
		RecLock("SC7",.F.)//Encerra o pedido
		SC7->C7_ENCER := "E"
		SC7->C7_QUJE := SC7->C7_QUANT
		SC7->(MsUnlock())
		U_ContabSP("SP2", cChavE2)
	endif
Return

/*
// -------------------------------------------------------------------
// Campos utilizados para retorno dos impostos calculado
// -------------------------------------------------------------------
IT_GRPTRIB				//Grupo de Tributacao
IT_EXCECAO				//Array da EXCECAO Fiscal
IT_ALIQICM				//Aliquota de ICMS
IT_ICMS					//Array contendo os valores de ICMS
IT_BASEICM				//Valor da Base de ICMS
IT_VALICM				//Valor do ICMS Normal
IT_BASESOL				//Base do ICMS Solidario
IT_ALIQSOL				//Aliquota do ICMS Solidario
IT_VALSOL				//Valor do ICMS Solidario
IT_MARGEM				//Margem de lucro para calculo da Base do ICMS Sol.
IT_BICMORI				//Valor original da Base de ICMS
IT_ALIQCMP				//Aliquota para calculo do ICMS Complementar
IT_VALCMP				//Valor do ICMS Complementar do item
IT_BASEICA				//Base do ICMS sobre o frete autonomo
IT_VALICA				//Valor do ICMS sobre o frete autonomo
IT_DEDICM				//Valor do ICMS a ser deduzido
IT_VLCSOL				//Valor do ICMS Solidario calculado sem o credito aplicado
IT_PAUTIC				//Valor da Pauta do ICMS Proprio
IT_PAUTST				//Valor da Pauta do ICMS-ST
IT_PREDIC				//%Redução da Base do ICMS
IT_PREDST				//%Redução da Base do ICMS-ST
IT_MVACMP				//Margem do complementar
IT_PREDCMP				//%Redução da Base do ICMS-CMP
IT_ALIQIPI				//Aliquota de IPI
IT_IPI					//Array contendo os valores de IPI
IT_BASEIPI				//Valor da Base do IPI
IT_VALIPI				//Valor do IPI
IT_BIPIORI				//Valor da Base Original do IPI
IT_PREDIPI				//%Redução da Base do IPI
IT_PAUTIPI				//Valor da Pauta do IPI
IT_NFORI				//Numero da NF Original
IT_SERORI				//Serie da NF Original
IT_RECORI				//RecNo da NF Original (SD1/SD2)
IT_DESCONTO				//Valor do Desconto
IT_FRETE				//Valor do Frete
IT_DESPESA				//Valor das Despesas Acessorias
IT_SEGURO				//Valor do Seguro
IT_AUTONOMO				//Valor do Frete Autonomo
IT_VALMERC				//Valor da mercadoria
IT_PRODUTO				//Codigo do Produto
IT_TES					//Codigo da TES
IT_TOTAL				//Valor Total do Item
IT_CF					//Codigo Fiscal de Operacao
IT_FUNRURAL				//Aliquota para calculo do Funrural
IT_PERFUN				//Valor do Funrural do item
IT_DELETED				//Flag de controle para itens deletados
IT_LIVRO				//Array contendo o Demonstrativo Fiscal do Item
IT_ISS					//Array contendo os valores de ISS
IT_ALIQISS				//Aliquota de ISS do item
IT_BASEISS				//Base de Calculo do ISS
IT_VALISS				//Valor do ISS do item
IT_CODISS				//Codigo do ISS
IT_CALCISS				//Flag de controle para calculo do ISS
IT_RATEIOISS			//Flag de controle para calculo do ISS
IT_CFPS					//Codigo Fiscal de Prestacao de Servico
IT_PREDISS				//Redução da base de calculo do ISS
IT_VALISORI				//Valor do ISS do item sem aplicar o arredondamento
IT_IR					//Array contendo os valores do Imposto de renda
IT_BASEIRR				//Base do Imposto de Renda do item
IT_REDIR				//Percentual de Reducao da Base de calculo do IR
IT_ALIQIRR				//Aliquota de Calculo do IR do Item
IT_VALIRR				//Valor do IR do Item
IT_INSS					//Array contendo os valores de INSS
IT_BASEINS				//Base de calculo do INSS
IT_REDINSS				//Percentual de Reducao da Base de Calculo do INSS
IT_ALIQINS				//Aliquota de Calculo do INSS
IT_VALINS				//Valor do INSS
IT_ACINSS				//Acumulo INSS
IT_VALEMB				//Valor da embalagem
IT_BASEIMP				//Array contendo as Bases de Impostos Variaveis
IT_BASEIV1				//Base de Impostos Variaveis 1
IT_BASEIV2				//Base de Impostos Variaveis 2
IT_BASEIV3				//Base de Impostos Variaveis 3
IT_BASEIV4				//Base de Impostos Variaveis 4
IT_BASEIV5				//Base de Impostos Variaveis 5
IT_BASEIV6				//Base de Impostos Variaveis 6
IT_BASEIV7				//Base de Impostos Variaveis 7
IT_BASEIV8				//Base de Impostos Variaveis 8
IT_BASEIV9				//Base de Impostos Variaveis 9
IT_ALIQIMP				//Array contendo as Aliquotas de Impostos Variaveis
IT_ALIQIV1				//Aliquota de Impostos Variaveis 1
IT_ALIQIV2				//Aliquota de Impostos Variaveis 2
IT_ALIQIV3				//Aliquota de Impostos Variaveis 3
IT_ALIQIV4				//Aliquota de Impostos Variaveis 4
IT_ALIQIV5				//Aliquota de Impostos Variaveis 5
IT_ALIQIV6				//Aliquota de Impostos Variaveis 6
IT_ALIQIV7				//Aliquota de Impostos Variaveis 7
IT_ALIQIV8				//Aliquota de Impostos Variaveis 8
IT_ALIQIV9				//Aliquota de Impostos Variaveis 9
IT_VALIMP				//Array contendo os valores de Impostos Agentina/Chile/Etc.
IT_VALIV1				//Valor do Imposto Variavel 1
IT_VALIV2				//Valor do Imposto Variavel 2
IT_VALIV3				//Valor do Imposto Variavel 3
IT_VALIV4				//Valor do Imposto Variavel 4
IT_VALIV5				//Valor do Imposto Variavel 5
IT_VALIV6				//Valor do Imposto Variavel 6
IT_VALIV7				//Valor do Imposto Variavel 7
IT_VALIV8				//Valor do Imposto Variavel 8
IT_VALIV9				//Valor do Imposto Variavel 9
IT_BASEDUP				//Base das duplicatas geradas no financeiro
IT_DESCZF				//Valor do desconto da Zona Franca do item
IT_DESCIV				//Array contendo a descricao dos Impostos Variaveis
IT_DESCIV1				//Array contendo a Descricao dos IV 1
IT_DESCIV2				//Array contendo a Descricao dos IV 2
IT_DESCIV3				//Array contendo a Descricao dos IV 3
IT_DESCIV4				//Array contendo a Descricao dos IV 4
IT_DESCIV5				//Array contendo a Descricao dos IV 5
IT_DESCIV6				//Array contendo a Descricao dos IV 6
IT_DESCIV7				//Array contendo a Descricao dos IV 7
IT_DESCIV8				//Array contendo a Descricao dos IV 8
IT_DESCIV9				//Array contendo a Descricao dos IV 9
IT_QUANT				//Quantidade do Item
IT_PRCUNI				//Preco Unitario do Item
IT_VIPIBICM				//Valor do IPI Incidente na Base de ICMS
IT_PESO					//Peso da mercadoria do item
IT_ICMFRETE				//Valor do ICMS Relativo ao Frete
IT_BSFRETE				//Base do ICMS Relativo ao Frete
IT_BASECOF				//Base de calculo do COFINS
IT_ALIQCOF				//Aliquota de calculo do COFINS
IT_VALCOF				//Valor do COFINS
IT_BASECSL				//Base de calculo do CSLL
IT_ALIQCSL				//Aliquota de calculo do CSLL
IT_VALCSL				//Valor do CSLL
IT_BASEPIS				//Base de calculo do PIS
IT_ALIQPIS				//Aliquota de calculo do PIS
IT_VALPIS				//Valor do PIS
IT_RECNOSB1				//RecNo do SB1
IT_RECNOSF4				//RecNo do SF4
IT_VNAGREG				//Valor da Mercadoria nao agregada.
IT_TIPONF				//Tipo da nota fiscal
IT_REMITO				//Remito
IT_BASEPS2				//Base de calculo do PIS 2
IT_ALIQPS2				//Aliquota de calculo do PIS 2
IT_VALPS2				//Valor do PIS 2
IT_BASECF2				//Base de calculo do COFINS 2
IT_ALIQCF2				//Aliquota de calculo do COFINS 2
IT_VALCF2				//Valor do COFINS 2
IT_ABVLINSS				//Abatimento da base do INSS em valor 
IT_ABVLISS				//Abatimento da base do ISS em valor 
IT_REDISS				//Percentual de reducao de base do ISS ( opcional, utilizar normalmente TS_BASEISS ) 
IT_ICMSDIF				//Valor do ICMS diferido
IT_DESCZFPIS			//Desconto do PIS
IT_DESCZFCOF			//Desconto do Cofins
IT_BASEAFRMM			//Base de calculo do AFRMM ( Item )
IT_ALIQAFRMM			//Aliquota de calculo do AFRMM ( Item )
IT_VALAFRMM				//Valor do AFRMM ( Item )
IT_PIS252				//Decreto 252 de 15/06/2005 - PIS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_COF252				//Decreto 252 de 15/06/2005 - COFINS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_CRDZFM				//Credito Presumido - Zona Franca de Manaus
IT_CNAE					//Codigo da Atividade Economica da Prestacao de Servicos
IT_ITEM					//Numero Item
IT_SEST					//Array contendo os valores do SEST
IT_BASESES				//Base de calculo do SEST
IT_ALIQSES				//Aliquota de calculo do SEST
IT_VALSES				//Valor do INSS
IT_BASEPS3				//Base de calculo do PIS Subst. Tributaria
IT_ALIQPS3				//Aliquota de calculo do PIS Subst. Tributaria
IT_VALPS3				//Valor do PIS Subst. Tributaria
IT_BASECF3				//Base de calculo da COFINS Subst. Tributaria
IT_ALIQCF3				//Aliquota de calculo da COFINS Subst. Tributaria
IT_VALCF3				//Valor da COFINS Subst. Tributaria
IT_VLR_FRT				//Valor do Frete de Pauta
IT_BASEFET				//Base do Fethab   
IT_ALIQFET				//Aliquota do Fethab
IT_VALFET				//Valor do Fethab   
IT_ABSCINS				//Abatimento do Valor do INSS em Valor - SubContratada
IT_SPED					//SPED
IT_ABMATISS				//Abatimento da base do ISS em valor referente a material utilizado 
IT_RGESPST				//Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
IT_PRFDSUL				//Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_UFERMS				//Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_VALFDS				//Valor do Fundersul - Mato Grosso do Sul
IT_ESTCRED				//Valor do Estorno de Credito/Debito
IT_CODIF				//Codigo de autorizacao CODIF - Combustiveis
IT_BASETST				//Base do ICMS de transporte Substituicao Tributaria
IT_ALIQTST				//Aliquota do ICMS de transporte Substituicao Tributaria
IT_VALTST				//Valor do ICMS de transporte Substituicao Tributaria
IT_CRPRSIM				//Valor Crédito Presumido Simples Nacional - SC, nas aquisições de fornecedores que se enquadram no simples
IT_VALANTI				//Valor Antecipacao ICMS                       
IT_DESNTRB				//Despesas Acessorias nao tributadas - Portugal
IT_TARA					//Tara - despesas com embalagem do transporte - Portugal
IT_PROVENT				//Provincia de entrega
IT_VALFECP				//Valor do FECP
IT_VFECPST				//Valor do FECP ST
IT_ALIQFECP				//Aliquota FECP
IT_CRPRESC				//Credito Presumido SC 
IT_DESCPRO				//Valor do desconto total proporcionalizado
IT_ANFORI2				//IVA Ajustado
IT_UFORI				//UF Original da Nota de Entrada para o calculo do IVA Ajustado( Opcional )
IT_ALQORI				//Aliquota Original da Nota de Entrada para o calculo do IVA Ajustado ( Opcional )
IT_PROPOR				//Quantidade proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ALQPROR				//Aliquota proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ANFII				//Array contendo os valores do Imposto de Importação
IT_ALIQII				//Aliquota do Imposto de Importação
IT_VALII				//Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
IT_PAUTPIS				//Valor da Pauta do PIS
IT_PAUTCOF				//Valor da Pauta do Cofins
IT_ALIQDIF				//Aliquota interna do estado para calculo do Diferencial de aliquota do Simples Nacional
IT_CLASFIS				//Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
IT_VLRISC				//Valor do imposto ISC (Localizado Peru) por unidade  "PER"
IT_CRPREPE				//Credito Presumido - Art. 6 Decreto  n28.247
IT_CRPREMG				//Credito Presumido MG 
IT_SLDDEP				//Valor de desconto de depedendente fornecedor
*/
