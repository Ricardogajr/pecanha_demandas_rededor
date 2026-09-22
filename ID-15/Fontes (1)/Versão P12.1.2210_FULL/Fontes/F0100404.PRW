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

user function f0100404()

// --------------------------------------------------------
	local   aAreas       := { SCR->( getarea() ) , SF1->( getarea() ) , SD1->( getarea() ) , SC7->( getarea() ) , getarea()   }
	local   bProcPreNota := {||}
	local   cFilDoc      := SCR->CR_FILIAL
	local   cNumPedido   := alltrim( PARAMIXB[1] )
	local   cConta       := ''
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
	local   lClassAut    := .F.
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
	private cxProds      := ""
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
	Private lTpMaterial := .F.
	
	private lFilSimp := U_VALSIMP(cFilant)

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

	If lExistPed .AND. lSolicPag
//                                  F1_FILIAL + F1_FORNECE      + F1_LOJA      + F1_DOC
		Conout("MSSEEK SF1 127 " + Time())
		lExistDE  := SF1->( msseek( cFilDoc   + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_XDOC ))		
		lTpMaterial :=  AllTrim(SC7->C7_XTPSP) $ "2|3"//Adionada a variavel para validar o tipo da SP.
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
	elseif lValido .AND. lExistPed .AND. lSolicPag .And. lTpMaterial//Libera o Titulo de material da SP
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
			msgrun('Aguarde, Recusando Nota de Entrada e título...' , , {|| U_F010101A(.T., aRecusa[2], lTpMaterial)})
		else
			SC7->( reclock( 'SC7' , .F. ))
			if AllTrim(SC7->C7_XTPSP) $ "2|3"
				SC7->C7_QUJE := SC7->C7_QUANT
			endif
			SC7->(MsUnlock())
		endif
		Return
	ElseIf (lValido .AND. lExistPed .AND. lSolicPag .And. !lTpMaterial)  // .And. !lExistDE
		cChaveE2 := XFilial("SE2") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_XSERIE + SC7->C7_XDOC
		Conout("POSICIONE SA2 155 " + Time())
		cUFOri := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_EST' )
		Conout("FIM POSICIONE SA2 155 " + Time())

		Conout("ADD ACABEC 160 " + Time())
		aCabec := { { 'F1_TIPO'    , 'N'             , NIL } , ;
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
			{ 'F1_XTXEXPE' , SC7->C7_XTXEXPE , NIL } , ;
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
		XDvenC7 := SC7->C7_XDTVEN
		xExDtFx := SC7->C7_XDTEXCE
		xTxExpe := SC7->C7_XTXEXPE
		Conout("FIM SETA VARIAVEIS 181 " + Time())

		Conout("WHILE SC7 195  " + Time())
		do while SC7->( !eof() ) .AND. ( SC7->(C7_FILIAL + C7_NUM) == cChave )
			aLinha := { { 'D1_COD'     , SC7->C7_PRODUTO , NIL } , ;
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
			SC7->( reclock( 'SC7' , .F. ))
			SC7->C7_XERAUT := ''
			SC7->C7_XERLEG := .F.
			SC7->( msunlock() )

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

		If( lTipoPC )
			if SC7->C7_XTPSP $ "4|5"//GPE Provisï¿½o/Ajuste
				cUserIdBk := __cUserId
				__cUserId := SC7->C7_XUSR//Alterado o campo pois alguem mudou o conteudo e o tamanho dele.
				//__cUserId := SC7->C7_XUSRSP//Muda para o usuï¿½rio que gerou a SP
				bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata103( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
				msgrun('Aguarde, gerando Nota de Entrada e título...' , , bProcPreNota)
				__cUserId := cUserIdBk
				if SC7->C7_XTPSP == "5"//Exclui a nota de provisï¿½o caso for ajuste
					ExNotaProv(SC7->C7_FILIAL, SC7->C7_XNSPPRE)
				endif
			elseif SC7->C7_XTPSP == "1"//Serviï¿½o
				aRecusa := fRecuAut2()

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
					If lClassAut
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
					Reclock("SF1",.F.)
					SF1->F1_XTXEXPE := SC7->C7_XTXEXPE
					SF1->(MsUnlock())
				EndIf
			endif
		endif

		
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

					do while SC7->( !eof() ) .AND. ( SC7->(C7_FILIAL + C7_NUM) == cChave )

						SC7->( reclock( 'SC7' , .F. ))
						SC7->C7_XERAUT := cObs // "ERRO" // MostraErro("\tmperro.txt")
						SC7->C7_XERLEG := .T.
						SC7->( msunlock() )

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
	local cContaDes  := alltrim( getmv( 'FS_GRPFIN'  )) // email grupo financeiro
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
	DbSetOrder(1)

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
	Local aTitulo := {}



	Private cNaturez := ""

	Default aProds := {}


	DbSelectArea("P38")
	DbSetOrder(1)

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

	cUPD := "UPDATE "+RETSQLNAME("SFT")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND "
	cUPD += " FT_FILIAL = '"+XFILIAL("SF1")+"' AND FT_NFISCAL = '"+StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])+"' AND FT_CLIEFOR = '"+XXFORN+"' AND FT_LOJA = '"+XXLOJA+"' "
	cUPD += " AND FT_SERIE = '"+XXSERIE+"'"
	TCSqlExec(cUPD)
	conout("TCSQLError() " + TCSQLError())

	If lExec
		msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper )
		If !lMsErroAuto

			aadd(aTitulo,{"F1_TIPO" ,SF1->F1_TIPO ,NIL})
			aadd(aTitulo,{"F1_FORMUL" ,SF1->F1_FORMUL ,NIL})
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


			DbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			While SD1->(!Eof()) .and. SD1->D1_FILIAL == SF1->F1_FILIAL  .and.;
					SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
					SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

				aItem2 := {}
				aadd(aItem2,{"D1_ITEM" ,SD1->D1_ITEM,NIL})
				aadd(aItem2,{"D1_COD" ,SD1->D1_COD ,NIL})
				aadd(aItem2,{"D1_UM" ,SD1->D1_UM ,NIL})
				aadd(aItem2,{"D1_LOCAL" ,SD1->D1_LOCAL ,NIL})
				aadd(aItem2,{"D1_QUANT" ,SD1->D1_QUANT ,NIL})
				aadd(aItem2,{"D1_VUNIT" ,SD1->D1_VUNIT ,NIL})
				aadd(aItem2,{"D1_TOTAL" ,SD1->D1_TOTAL ,NIL})
				aadd(aItem2,{"D1_TES" ,Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE") ,NIL})
				aadd(aItem2,{"D1_RATEIO" ,SD1->D1_RATEIO ,NIL})
				aadd(aItem2,{"D1_XCODCON",StrZero(Val(STRTRAN(STRTRAN(cValToChar(SF1->F1_VALBRUT), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]),NIL})
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
				aadd(aItem2,{ 'D1_XOBS'    , SD1->D1_XOBS     , NIL })
				aadd(aItem2,{ 'D1_XDESFIN' , SD1->D1_XDESFIN ,NIL })
				aAdd(aItens2,aItem2)

				SD1->(DbSkip())
			enddo


			MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aTitulo,aItens2,4,{},{},{})
			If !lMsErroAuto

				cChavE2 := xFilial("SE2") + XXFORN + XXLOJA + XXSERIE + StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])

				DbSelectArea("SE2")
				SE2->(DbSetOrder(06))
				SE2->(DbSeek(cChavE2))
				While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
					Reclock("SE2",.F.)

					/*/if empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
					AllTrim(SE2->E2_PARCELA) == '1' .OR. ;
						SE2->E2_PARCELA == Replicate("a",TamSx3("E2_PARCELA")[1]) .OR. ;
						SE2->E2_PARCELA == Replicate("A",TamSx3("E2_PARCELA")[1]) .OR. ;
						SE2->E2_PARCELA == Replicate("0",(TamSx3("E2_PARCELA")[1] - 1)) + "1"
					SE2->E2_XTXEXPE := xTxExpe
					EndIf/*/

					SE2->E2_XUSNOME := AllTrim(cUsr)
					SE2->E2_XCLAUT := "1"
					SE2->E2_XPRODNF := cxProds
					If !Empty(cNaturez)
						SE2->E2_NATUREZ := AllTrim(cNaturez)
					EndIf
					SE2->E2_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(SE2->E2_VALOR), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
					If Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_XDTFIX") == "1"
						If xExDtFx == "2" 
							if empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
									AllTrim(SE2->E2_PARCELA) == '1' .OR. ;
									SE2->E2_PARCELA == Replicate("a",TamSx3("E2_PARCELA")[1]) .OR. ;
									SE2->E2_PARCELA == Replicate("A",TamSx3("E2_PARCELA")[1]) .OR. ;
									SE2->E2_PARCELA == Replicate("0",(TamSx3("E2_PARCELA")[1] - 1)) + "1"
								//SE2->E2_VENCTO := XDvenC7
								SE2->E2_VENCREA := XDvenC7
							Else
								//SE2->E2_VENCTO := U_DTFORNFIX(SE2->E2_VENCREA,XcOND)
								SE2->E2_VENCREA := U_DTFORNFIX(SE2->E2_VENCTO,XcOND)
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
					SE2->(DbSkip())
				EndDo
			EndIf

		EndIf
	Else

		msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper )

		SC7->( dbsetorder( 1 ))
		lExistPed := SC7->( msseek( cChaveC7 ))

		If lExistPed

			do while SC7->( !eof() ) .AND. ( SC7->(C7_FILIAL + C7_NUM) == cChaveC7 )

				SC7->( reclock( 'SC7' , .F. ))
				SC7->C7_XERAUT := cLog // "ERRO" // MostraErro("\tmperro.txt")
				//SC7->C7_XERLEG := .T.
				SC7->( msunlock() )

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
	Local nX := 0
	Local aArea := GetArea()
	Local aAreaSC7 := SC7->(GetArea())
	Local aAreaP39 := P39->(GetArea())
	Local aProdSC7 := {}
	Local aProdP39 := {}
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
/*/{Protheus.doc} ExNotaProv
Exclui nota de provisão
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
	Local lContab := .F.
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
			RecLock("SE2", .F.)
			SE2->E2_NUMBOR := " "
			SE2->(MsUnlock())
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
