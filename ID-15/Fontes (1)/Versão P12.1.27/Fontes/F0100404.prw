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


	If SCR->CR_TIPO == 'PC'
		If SCR->( dbseek( fwxfilial( 'SCR' ) + 'PC' + cNumPedido ))

			lValido := .T.

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

		EndIf
	EndIf
	SC7->( dbsetorder( 1 ) )
	lExistPed  :=   SC7->( msseek( cFilDoc + cNumPedido ))
	lSolicPag  := ( SC7->C7_XSOLPAG == '1' ) //verIfica se foi gerado pela F0100401 (GeraÃ§Ã£o solicitação de Pagamentos - Req. ID_635)
//  cEmailEmit := usrretmail( SC7->C7_XUSR )

	If lExistPed .AND. lSolicPag
//                                  F1_FILIAL + F1_FORNECE      + F1_LOJA      + F1_DOC
		lExistDE  := SF1->( msseek( cFilDoc   + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_XDOC ))
	EndIf

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

	If lRejeitado

		msgrun( 'Aguarde, enviando email...' , , {|| EnviaEmail( 'Rejeitada pelo aprovador' , '' , cFilDoc , cNumPedido , nOper )})

	ElseIf lValido .AND. lExistPed .AND. lSolicPag // .And. !lExistDE

		cUFOri := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_EST' )

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
			{ 'F1_XDTEXCE' , SC7->C7_XDTEXCE , NIL } }//Lucas Miranda de Aguiar melhoria data fixa


		cChave := cFilDoc + cNumPedido
		cChaveC7 := cChave
		XXDOC  := SC7->C7_XDOC
		XXSERIE:= SC7->C7_XSERIE
		XXFORN := SC7->C7_FORNECE
		XXLOJA := SC7->C7_LOJA
		cUsr   := SC7->C7_XUSRSP


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

			aadd( aItens , aclone( aLinha ) )
			aadd( aProds, SC7->C7_PRODUTO )
			aadd( aVlProd, + cValToChar(TRANSFORM(SC7->C7_TOTAL, "@E 999,999,999.99")))

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
			aRecusa := fRecuAut2()
			if aRecusa[1]
				bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
				msgrun('Aguarde, gerando Pre-Nota de Entrada...' , , bProcPreNota)
				msgrun('Aguarde, Recusando Pre-Nota de Entrada ['+aRecusa[2]+']...' , , {|| U_F010101A(.T., aRecusa[2])})
			else
				//Função de validação da classIficação automática - Lucas Miranda de Aguiar 27/02/2023
				lClassAut := fClassAut(aProds)
				If lClassAut
					bProcPreNota := {|| fExecClass(aProds) }
					msgrun('Aguarde. Iniciando o processo de Classificação Automática...' , , bProcPreNota)
				Else
					bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
					msgrun('Aguarde, gerando Pre-Nota de Entrada...' , , bProcPreNota)
				EndIf
			endif


			// ticket n° 10326179 - gravação do valor Tx Expediente
			SF1->(DbSetOrder(1))
			If SF1->(DbSeek(xFilial("SF1")+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
				Reclock("SF1",.F.)
				SF1->F1_XTXEXPE := SC7->C7_XTXEXPE
				SF1->(MsUnlock())
			EndIf

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

				msgrun( 'Aguarde, enviando email...' , , {|| EnviaEmail( 'Erro' , ' Não ' ,  cFilDoc , cNumPedido , nOper )})

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
					msgrun( 'Aguarde, enviando email...' , , {|| EnviaEmail( cText , '' , cFilDoc , cNumPedido , nOper )})
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
	cQuery := "     SELECT * "                                                 + CRLF
	cQuery += "       FROM "                   + retsqlname( 'SC7' ) + " SC7 " + CRLF
	cQuery += " INNER JOIN "                   + retsqlname( 'SA2' ) + " SA2 " + CRLF
	cQuery += "         ON SA2.A2_FILIAL  = '" +    xfilial( 'SA2' ) + "' "    + CRLF
	cQuery += "        AND SA2.A2_COD     = SC7.C7_FORNECE "                   + CRLF
	cQuery += "        AND SA2.A2_LOJA    = SC7.C7_LOJA "                      + CRLF
	cQuery += "        AND SA2.D_E_L_E_T_ = SC7.D_E_L_E_T_ "                   + CRLF
	cQuery += "      WHERE SC7.D_E_L_E_T_ = ' ' "                              + CRLF
	cQuery += "        AND SC7.C7_FILIAL  = '" + cFilDoc             + "' "    + CRLF
	cQuery += "        AND SC7.C7_NUM     = '" + cNumPedido          + "' "    + CRLF

	dbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasQry , .F. , .T. )

	If select( cAliasQry )  > 0
		cEmailEmit := usrretmail( (cAliasQry)->C7_XUSR ) // 006783
		If cEmailEmit == ''
			alert( 'Email do Solicitante não cadastrado, e-mail de log não será enviado' )
			return
		EndIf
	Else
		alert( 'Não encontrou!' )
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
	local   bProcPreNota := {||}
	Local cChavE2 := ""
	Local cArqSE2 := GetNextAlias()
	Local aAReaSE2 := GetArea()

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
	/*/If lExec

	cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SE2")
	cQuery += " WHERE (E2_NUM = '" + XXDOC + "' OR E2_XCODCON = '"
	cQuery += StrZero(nCdControl,TamsX3("D1_XCODCON")[1]) + "') AND "
	cQuery += " E2_FORNECE = '" + XXFORN + "' AND "
	cQuery += " D_E_L_E_T_ = ' '"

	cQuery := " SELECT 1 "
	cQuery += " FROM " + RetSqlName("SE2")
	cQuery += " WHERE E2_FORNECE = '" + XXFORN + "' AND D_E_L_E_T_ = ' '"
	cQuery += " AND (EXISTS (SELECT 1 FROM SE2010 WHERE E2_NUM = '"+XXDOC+"' AND E2_FORNECE = '"+XXFORN+"' AND D_E_L_E_T_ = ' ')"
	cQuery += " OR EXISTS (SELECT 1 FROM SE2010 WHERE E2_XCODCON = '"+StrZero(nCdControl,TamsX3("D1_XCODCON")[1])+"' AND E2_FORNECE = '"+XXFORN+"' AND D_E_L_E_T_ = ' '))"

	If Select(cArqSE2) > 0
		DbSelectArea(cArqSE2)
		(cArqSE2)->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSE2,.T.,.T.)

	If !(cArqSE2)->(Eof())
		cLog := "Código de controle já existe na tabela SE2."
		lExec := .F.
	EndIf
	EndIf/*/

	cUPD := "UPDATE "+RETSQLNAME("SFT")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND "
	cUPD += " FT_FILIAL = '"+XFILIAL("SF1")+"' AND FT_NFISCAL = '"+StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])+"' AND FT_CLIEFOR = '"+XXFORN+"' AND FT_LOJA = '"+XXLOJA+"' "
	cUPD += " AND FT_SERIE = '"+XXSERIE+"'"
	TCSqlExec(cUPD)
	conout("TCSQLError() " + TCSQLError())

	If lExec
		For nX := 01 To Len(aItens)
			//aadd(aItens[NX],{"D1_TES" , POSICIONE("SBZ",1,xFilial("SC7")+aItens[nX][AScan(aItens[nX], {|x| AllTrim(x[1]) == "D1_COD"})][2],"BZ_TE") , Nil})
			aItens[nX][AScan(aItens[nX], {|x| AllTrim(x[1]) == "D1_TES"})][2] := POSICIONE("SBZ",1,xFilial("SC7")+aItens[nX][AScan(aItens[nX], {|x| AllTrim(x[1]) == "D1_COD"})][2],"BZ_TE")
			aadd(aItens[NX],{"D1_XCODCON" , StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]) , Nil})
		Next nX

		MATA103(aCabec,aItens,nOpcOper,,,,,/*aColsCC*/,,,/*aCodRet*/)
		If !lMsErroAuto
			/*/If !Empty(cNaturez)
			cNaturez := ", E2_NATUREZ = '"+AllTrim(cNaturez)+"' "
		Else
			cNaturez := " "
			EndIf/*/
			/*/cUPD := " UPDATE " + RETSQLNAME("SE2") + " SET E2_XUSNOME = '"+AllTrim(cUsr)+"', E2_XCLAUT = '1', E2_XPRODNF = UTL_RAW.CAST_TO_RAW('"+cxProds+"')" + cNaturez + ", E2_XCODCON = '"+StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])+"' "
			cUPD += " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '"+XFILIAL("SE2")+"' AND E2_NUM = '"+StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])+"'"
			cUPD += " AND E2_PREFIXO = '"+XXSERIE+"' AND E2_FORNECE = '"+XXFORN+"' AND E2_LOJA = '"+XXLOJA+"'"
			TCSqlExec(cUPD)
			conout("TCSQLError() " + TCSQLError())/*/
			cChavE2 := xFilial("SE2") + XXFORN + XXLOJA + XXSERIE + StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])
			aAReaSE2 := SE2->(GetArea())
			DbSelectArea("SE2")
			SE2->(DbSetOrder(06))
			SE2->(DbSeek(cChavE2))
			While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
				Reclock("SE2",.F.)
				SE2->E2_XUSNOME := AllTrim(cUsr)
				SE2->E2_XCLAUT := "1"
				SE2->E2_XPRODNF := cxProds
				If !Empty(cNaturez)
					SE2->E2_NATUREZ := AllTrim(cNaturez)
				EndIf
				SE2->E2_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(SE2->E2_VALOR), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
				SE2->(DbSkip())
			EndDo
		EndIf
	Else
		//MsgInfo("Inconsistência na classificação automática: "+cLog+CRLF+"O processo de classificação automática será abortado para dar inicio ao processo de geração de pré-nota." )

		//bProcPreNota := {|| msexecauto( {|cabec , itens , operac| mata140( cabec , itens , operac ) } , aCabec , aItens , nOpcOper ) }
		//msgrun('Aguarde, gerando Pre-Nota de Entrada...' , , bProcPreNota)

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

	cQuery += "SELECT C7_NUM FROM "+RetSqlName("SC7")+ " SC7 " + CRLF
	cQuery += "WHERE SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "AND R_E_C_N_O_ = "+cValToChar(SC7->(Recno()))+" " + CRLF
	cQuery += "AND NOT EXISTS (SELECT R_E_C_N_O_ FROM P09010 P09 WHERE P09.D_E_L_E_T_ = ' ' AND P09.P09_FILIAL||P09.P09_CODORI = SC7.C7_FILIAL||SC7.C7_NUM)" + CRLF

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

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	cNum := SC7->C7_NUM
	While !SC7->(Eof()) .And. SC7->C7_NUM == cNum
		aAdd(aProdSC7, { SC7->C7_NUM, SC7->C7_XDTVEN, SC7->C7_PRODUTO })
		SC7->(DbSkip())
	EndDo

	RestArea(aAreaSC7)

	ndiasUteis := zDiasUteis(dDatabase, aProdSC7[1][2])

	DbSelectArea("P39")
	P39->(DbSetOrder(1))
	P39->(DbGoTop())
	cAnexo := iif(fTemAnexo(),"1","2")
	While !P39->(Eof())
		If P39->P39_STATUS != "1"
			P39->(DbSkip())
			Loop
		endif
		cCod := P39->P39_CODIGO
		While !P39->(Eof()) .And. AllTrim(cCod) == AllTrim(P39->P39_CODIGO)
			aAdd(aProdP39, { P39->P39_CODIGO, P39->P39_VENCRE, P39->P39_PRODUT, P39->P39_DESCRI, P39->P39_TDPROD, P39->P39_ANEXO, P39->P39_MSGMAI})
			P39->(DbSkip())
		EndDo
		//Verifica vencimento e produto.
		For nX := 01 To Len(aProdSC7)
			if AllTrim(aProdP39[1][5]) == "1"
				nPosPro := 1
			else
				nPosPro := aScan(aProdP39, {|x| AllTrim(x[3]) == AllTrim(aProdSC7[nX][3]) })
			endif
			if ((ndiasUteis <= aProdP39[1][2]) .And. nPosPro > 0) .Or. aProdP39[1][2] == 0
				if (AllTrim(aProdP39[1][6]) == "1")
					if cAnexo == "2"
						cErro += Replace(AllTrim(aProdP39[1][7]),CRLF," ")
					else
						loop
					endif
				else
					cErro += Replace(AllTrim(aProdP39[1][7]),CRLF," ")
				endif
				//cErro := " Recusado automático pela regra [" + AllTrim(aProdP39[1][1]) + ":" + AllTrim(aProdP39[1][4]) + "]"
				if !lRet
					lRet := .T.
				endif
				Loop
			endif
		Next nX
/*		if lRet
			exit
	endif
*/
	aProdP39 := {}
EndDo
RestArea(aAreaP39)
RestArea(aAreaSC7)
RestArea(aArea)
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
