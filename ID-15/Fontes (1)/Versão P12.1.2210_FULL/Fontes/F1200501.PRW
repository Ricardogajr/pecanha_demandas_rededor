#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#Include "RPTDEF.CH" //Thais Paiva - 12013888
#INCLUDE 'PROTHEUS.CH' //Thais Paiva - 12013888
#INCLUDE 'PARMTYPE.CH' //Thais Paiva - 12013888
#INCLUDE 'TOPCONN.CH' //Thais Paiva - 12013888
#DEFINE IMP_PDF 6 //Thais Paiva - 12013888
#define POP3 0
#define IMAP 1
#define MAPI 2

// ----------------------------------------------------------------------------
// {Protheus.doc} 1200501
// Rotina para envio de email com o espelho do pedido de compra
// @author  Sandro
// @since   18/08/2017
// @project MAN0000007423046_EF_005
// ----------------------------------------------------------------------------
// @obs
// Chamada da função:
// U_TEWBTYR2( cAlias , nReg , nOpcx , nOp )
// ----------------------------------------------------------------------------
// Função    : TEWBTYR2 
// Parâmetros: cAlias , nReg , nOpcx , nOp
// cAlias    : Alias da tabela "SC7"
// nReg      : Recno do arquivo
// nOpcx     : nil
// nOp       : 1
// Retorno   : Path + nome do arquivo
// ----------------------------------------------------------------------------

user function f1200501( nRecSC7 )

// ------------------------------------
	local   cArquivo    := ''
	local   aAreaSA2    := SA2->( getarea( 'SA2' ))
	local   cRet        := ''
// ------------------------------------
//  [ DOR06872720_TK_8056955 ] 
// ------------------------------------
	local   cFilNom     := alltrim( fwfilialname( cEmpAnt , SC7->C7_FILIAL , 1 ))
	local   cForNom     := ''
	Local   lSched      := .F.
// ------------------------------------
	private cWFLFilial  := SC7->C7_FILIAL
	private cWFLNum     := SC7->C7_NUM
	private cWFLData    := ddatabase
	private cWFLMsg1    := ''
	private cWFLEmailF  := ''
	private cWFLEmailC  := ''
	private cWFLStaGer  := ''
	private cWFLMsg2    := ''
	private cWFLStaEnv  := ''
	private cWFLMsg3    := ''
	private cWFLRotina  := 'F1200501'
	private cWFLHora    := time() //Thais Paiva - 12013888
	private cWFLArq 	:= '' //Thais Paiva - 12013888
	private cWFLRecn	:= nRecSC7 //Thais Paiva - 12013888
	private cWFLCdFor	:= SC7->C7_FORNECE  //Thais Paiva - 12013888
	private cWFLLjFor	:=  SC7->C7_LOJA  //Thais Paiva - 12013888
	private cWFLFornec	:= "" //Thais Paiva - 12013888
	private cWFLNumCon	:= CN9->CN9_NUMERO //Thais Paiva - 12013888
	private cWFLRevisa	:= CN9->CN9_REVISA //Thais Paiva - 12013888
	private cWFLTabPrc	:= Posicione("CNA",1,CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA,"CNA_XTABPC")//Thais Paiva - 12013888
	private cWFLUsuario	:= Alltrim(USRFULLNAME(__cuserid)) //Thais Paiva - 12013888


// ------------------------------------

	if CN9->CN9_XENVPC == 'S'

		cMailContr := alltrim( CN9->CN9_XEMAIL )
		aAreaSA2   := SA2->( getarea( 'SA2' ))

		SA2->( dbsetorder( 1 )) // A2_FILIAL +        A2_COD     + A2_LOJA
		SA2->( dbseek(      xfilial( 'SA2' ) + SC7->( C7_FORNECE + C7_LOJA )))

		cWFLFornec := alltrim( SA2->A2_NREDUZ ) //Thais Paiva - 12013888

		//  if SC7->C7_CONAPRO = 'L' .AND. ;
			//   SC7->C7_RESIDUO = ' '

		if empty( SA2->A2_EMAIL )

			alert( 'Conta de email não cadastrada no fornecedor!' )
// ------------------------------------
//              [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLMsg1 := 'NÃO OK (1.1) - Conta de email não cadastrada no fornecedor!'
// ------------------------------------

			sndPrepErr(SC7->C7_NUM,nRecSC7,"Conta de email não cadastrada no fornecedor ",1) //Thais Paiva - 12013888

		else

// ------------------------------------
//              [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cForNom    := alltrim( SA2->A2_NREDUZ )
			cWFLMsg1   := 'OK (1.0) - CN9->CN9_XENVPC == "S"! Pedido não bloqueado! Email do fornecedor informado!'
			cWFLEmailF := alltrim( SA2->A2_EMAIL   )
			cWFLEmailC := alltrim( CN9->CN9_XEMAIL )
// ------------------------------------
			If Empty(SC7->C7_USER)
				lSched := .T.
			EndIf
			cArquivo := u_tewbtyr2( 'SC7' , nRecSC7 , Nil , 1 )
			cWFLArq    := cArquivo //Thais Paiva - 12013888

// ------------------------------------
//              [ Valida se o arquivo foi criado com sucesso ]
// ------------------------------------
			//if vldarquivo( cArquivo ) - Thais Paiva - 29/06/2021
			if vldarquivo(cArquivo,nRecSC7)

// ------------------------------------
//                  DOR06872720_TK_8056955
// ------------------------------------
//                  cRet := preparaemail( alltrim( SA2->A2_EMAIL ) , ;
//                                        cArquivo                 , ;
//                                        SC7->C7_NUM              , ;
//                                        cMailContr               , ;
//                                        nRecSC7                    )
// ------------------------------------
				cRet := preparaemail( alltrim( SA2->A2_EMAIL ) , ;
					cArquivo                 , ;
					SC7->C7_NUM              , ;
					cMailContr               , ;
					nRecSC7                  , ;
					cFilNom                  , ;
					cForNom                    )
// ------------------------------------

				if !empty( cRet )
					msgalert( cRet )
					sndPrepErr(SC7->C7_NUM,nRecSC7,cRet,2) //Thais Paiva - 12013888
				endif

			else
				sndmailerr( SC7->C7_NUM , nRecSC7 )
			endif

		endif

        /*/ else

		alert( 'Pedido não foi gerado devido a estar bloqueado' )
// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
		cWFLMsg1 := 'NÃO OK (1.2) - Pedido não foi gerado devido a estar bloqueado'
// ------------------------------------

        endif/*/

// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
// ------------------------------------
	else

// ------------------------------------
//      cWFLMsg1 := 'NÃO OK (1.3) - Envia E-mail Automático? <> "S" ( CN9->CN9_XENVPC <> "S" )'
// ------------------------------------
		cWFLMsg1 := 'NÃO OK (1.3) - Envia E-mail Automático? <> "S" (CN9->CN9_XENVPC="' + CN9->CN9_XENVPC + '"'
		cWFLMsg1 += '|CN9->(recno())=' + alltrim( str( CN9->( recno() )))
		cWFLMsg1 += '|CN9->CN9_FILIAL="'   +               CN9->CN9_FILIAL + '"'
		cWFLMsg1 += '|CN9->CN9_NUMERO="'   +               CN9->CN9_NUMERO + '"'
		cWFLMsg1 += '|CN9->CN9_REVISA="'   +               CN9->CN9_REVISA + '")'
// ------------------------------------
		//Chamado: 9193230 - Thais Paiva Campos enviados na mensagem corrigidos.
	endif

// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
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
	WFL->WFL_HORA := cWFLHora //Thais Paiva - 12013888
	WFL->WFL_ARQUIV := cWFLArq //Thais Paiva - 12013888
	WFL->WFL_RECNC7 := cValToChar(cWFLRecn) //Thais Paiva - 12013888
	WFL->WFL_CODFOR	:= cWFLCdFor //Thais Paiva - 12013888
	WFL->WFL_LOJFOR	:= cWFLLjFor //Thais Paiva - 12013888
	WFL->WFL_FORNEC	:= cWFLFornec //Thais Paiva - 12013888
	WFL->WFL_NUMCON	:= cWFLNumCon //Thais Paiva - 12013888
	WFL->WFL_REVISA	:= cWFLRevisa //Thais Paiva - 12013888
	WFL->WFL_TABPRC := cWFLTabPrc //Thais Paiva - 12013888
	WFL->WFL_USER := cWFLUsuario //Thais Paiva - 12013888
	WFL->( msunlock() )
// ------------------------------------

	restarea( aAreaSA2 )

return .T.

// ----------------------------------------------------------------------------
// [ DOR06872720_TK_8056955 ]
// static function PreparaEmail( cContaDes , cArquivo , cNumPC , cMailContr , nRecSC7 )
// ----------------------------------------------------------------------------
static function preparaemail( cContaDes , cArquivo , cNumPC , cMailContr , nRecSC7 , cFilNom , cForNom )

// ------------------------------------
	local cSMTP     := alltrim( getmv( 'MV_RELSERV' )) // smtp.ig.com.br ou 200.181.100.51
	local cConta    := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
	local cPass     := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
// ------------------------------------
//  [ DOR06872720_TK_8056955 ]
// ------------------------------------
//  local cAssunto  := 'Pedido de compra: ' + cNumPC
// ------------------------------------
	local cAssunto  := iif(U_MsVldEmerg(SC7->C7_EMISSAO,SC7->C7_DATPRF,SC7->C7_XCTSERV),'[EMERGENCIAL] ',"")+'Pedido de compra: ' + cNumPC  + ;
		' - Filial: ' + cFilNom + ;
		' - Fornecedor: ' + cForNom
// ------------------------------------
	local cCorpo    := U_MSEMAILPC()//alltrim( getmv( 'FS_EF12005' , , 'Caro fornecedor, <br> Anexo, enviamos o espelho do Pedido de Compra para seu conhecimento.<br>' ))
	local cRet      := ''
	local cMensagem := ''
	Local _cNomAux := "" //Thais Paiva - 29/06/2021
	Local _cArqAux := ""  //Thais Paiva - 29/06/2021
// ------------------------------------

	//Início - Thais Paiva 29/06/2021
	_aAreaC7 := GetArea()
	dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
	SC7->( dbgoto( nRecSC7 ))
	_cNomAux := SC7->C7_FILIAL+SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA
	RestArea(_aAreaC7)
	_cArqAux := Substr(StrTran(cArquivo,".pdf",""),-Len(_cNomAux))
	If _cArqAux <> _cNomAux
		cRet := "Filial, Pedido, Fornecedor ou Loja do Nome do Arquivo divergente do Pedido."
		cWFLStaGer := 'ERRO'
		cWFLMsg2   := 'NÃO OK (3.1) - Filial, Pedido, Fornecedor ou Loja do Nome do Arquivo divergente do Pedido.'
	EndIf
	If cNumPC <> SC7->C7_NUM .OR. cFilNom <> alltrim( fwfilialname( cEmpAnt , SC7->C7_FILIAL , 1 )) .OR. cForNom <> Alltrim(POSICIONE("SA2",1,xfilial( 'SA2' )+SC7->(C7_FORNECE + C7_LOJA),"A2_NREDUZ"))
		cRet := "Filial, Pedido ou Fornecedor do Assunto do E-mail diferente do Pedido."
		cWFLStaGer := 'ERRO'
		cWFLMsg2   := 'NÃO OK (3.1) - Filial, Pedido ou Fornecedor do Assunto do E-mail diferente do Pedido.'
	EndIf
	RestArea(_aAreaC7)
	If Empty(Alltrim(cRet))
		//Fim - Thais Paiva 29/06/2021
		cMensagem := '<html>'
		cMensagem += '<head><title>' + alltrim( cAssunto ) + '</title></head>'
		cMensagem += '<body>'
		cMensagem += '<br>'
		cMensagem += cCorpo
		cMensagem += '<br>'
		cMensagem += '</body>'
		cMensagem += '</html>'
		// ------------------------------------
		cRet := enviaemail( cSMTP      , ;
			cConta     , ;
			cPass      , ;
			cContaDes  , ;
			cAssunto   , ;
			cArquivo   , ;
			cMensagem  , ;
			cMailContr , ;
			nRecSC7      )
		// ------------------------------------
	EndIf //Thais Paiva 29/06/2021

return cRet

// ----------------------------------------------------------------------------

static function enviaemail( cSMTP , cConta , cPass , cContaDes , cAssunto , cArquivo , cMensagem , cMailContr , nRecSC7 )
// ------------------------------------
	local lConSMTP   := .F.
	local lEnvEmail  := .F.
	local cError     := ''
	local cRet       := ''
	local cNomeAnexo := cArquivo
	Local _cBcc := Alltrim(SuperGetMV('MV_XPCCCO', .F., "")) //Thais Paiva 01/07/2021
	Local _cEmail := "" //Thais Paiva - 12013888
// ------------------------------------
	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP

	if lConSMTP

		if !IsInCallStack( 'U_F1200600' )

			cNomeAnexo := '\workflow\' + substr( cArquivo , rat( '\' , cArquivo ) + 1 )

			if !ExistDir( '\workflow' )
				mkdir( '\workflow' )
			endif

			//cpyt2s( cArquivo , '\workflow\' , .T. )
			__CopyFile( cArquivo , cNomeAnexo)

		endif

		//Início - Thais Paiva 01/07/2021
		//if empty( cMailContr )
		Do Case
		Case Empty( cMailContr ) .AND. Empty( _cBcc )
			SEND MAIL FROM cConta TO cContaDes               SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
			//else
		Case !Empty( cMailContr ) .AND. Empty( _cBcc )
			SEND MAIL FROM cConta TO cContaDes CC cMailContr SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
		Case Empty( cMailContr ) .AND. !Empty( _cBcc )
			SEND MAIL FROM cConta TO cContaDes BCC _cBcc SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
		Otherwise
			SEND MAIL FROM cConta TO cContaDes CC cMailContr BCC _cBcc SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
			//endif
		EndCase
		//Fim - Thais Paiva 01/07/2021

		//ferase( cNomeanexo ) Thais Paiva - 06/07/2021

		dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
		SC7->( dbgoto( nRecSC7 ))

		if !lEnvEmail // Erro no envio do email

			Get Mail Error cError
			cRet := 'Erro no envio do email: ' + cError

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaEnv := 'ERRO'
			cWFLMsg3   := 'NÃO OK (3.2) - ' + cRet
// ------------------------------------

			reclock( 'SC7' , .F. )
			SC7->C7_XENVMAL := 'N'
			SC7->( msunlock() )

		else

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaEnv := 'OK'
			cWFLMsg3   := 'OK (3.0) - Conexão SMTP OK! Email enviado!'
// ------------------------------------

			reclock( 'SC7' , .F. )
			SC7->C7_XENVMAL := 'S'
			SC7->( msunlock() )
 
			//Início - Thais Paiva - 12013888
			_cEmail := SalvaEmail(cConta,cContaDes,cMailContr,_cBcc,cAssunto,cMensagem,cNomeAnexo) //Thais Paiva - 12013888
			If !Empty(Alltrim(_cEmail)) .AND. !IsInCallStack( 'U_F1200600' )
				//cpyt2s( _cEmail , '\workflow\' , .T. )
				__CopyFile( _cEmail , cNomeAnexo)
			EndIf

		endif

		Disconnect SMTP Server

	else // Erro na conexao com o SMTP Server

		Get Mail Error cError
		cRet := 'Erro na conexão SMTP: ' + cError

// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		cWFLStaEnv := 'ERRO'
		cWFLMsg3   := 'NÃO OK (3.1) - ' + cRet
// ------------------------------------

	endif

return cRet

// ----------------------------------------------------------------------------
// {Protheus.doc} VldArquivo
// Valida o conteudo de arquivo (se existe, se possui conteudo e se foi completamente escrito)
// @author thiago oliveira 
// @since  02/04/2019
// ----------------------------------------------------------------------------

//static function vldarquivo( cArquivo ) Thais Paiva - 29/06/2021
static function vldarquivo(cArquivo,nRecSC7)
// ------------------------------------
	local nHandle := 0
	local lRet    := .T.
	local nTam    := 0
	local nTry    := 1
	Local _cNomAux := "" //Thais Paiva - 29/06/2021
	Local _cArqAux := "" //Thais Paiva - 29/06/2021
// ------------------------------------	

	nHandle := fopen( cArquivo )

// ------------------------------------
//  [ Verifica se consegue abrir o arquivo                 ]
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
//          [ Validacao para garantir que o arquivo foi escrito por completo              ]
//          [ a cada 1 segundo, mudara o conteudo dele com relacao a verificacao anterior ]
// ------------------------------------
			do while ( nTry                     <= 40 .AND. ;
					fseek( nHandle , 0 , 2 ) <> nTam     )

				nTry++
				nTam := fseek( nHandle , 0 , 2 )
				sleep( 1000 )

			enddo

			lRet := ( fseek( nHandle , 0 , 2 ) == nTam .AND. ;
				nTry                     <= 40         )

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			if lRet
				cWFLStaGer := 'OK'
				cWFLMsg2   := 'OK (2.0) - Arquivo OK!'
			else
				cWFLStaGer := 'ERRO'
				cWFLMsg2   := 'NÃO OK (2.3) - Arquivo incompleto.'
			endif
// ------------------------------------

		else
			lRet := .F.

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaGer := 'ERRO'
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
		cWFLStaGer := 'ERRO'
		cWFLMsg2   := 'NÃO OK (2.1) - Não é possível abrir o arquivo gerado.'
// ------------------------------------

	endif
// ------------------------------------
	If lRet //Início - Thais Paiva - 29/06/2021
		_aAreaC7 := GetArea()
		DbSelectArea("SC7")
		SC7->(dbgoto( nRecSC7 ))
		_cNomAux := SC7->C7_FILIAL+SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA
		RestArea(_aAreaC7)
		_cArqAux := Substr(StrTran(cArquivo,".pdf",""),-Len(_cNomAux))
		If _cArqAux <> _cNomAux
			lRet := .F.
			cWFLStaGer := 'ERRO'
			cWFLMsg2   := 'NÃO OK (2.4) - Filial, Pedido, Fornecedor ou Loja do Nome do Arquivo divergente do Pedido.'
		EndIf
	EndIf //Fim - Thais Paiva - 29/06/2021
	if !lRet
		ferase( cArquivo )
	endif
// ------------------------------------

return lRet

// ----------------------------------------------------------------------------
// {Protheus.doc} SndMailErr
// Envia o e-mail informando o erro ao obter o relatorio PDF
// @author thiago oliveira
// @since  02/04/2019
// ----------------------------------------------------------------------------
static function sndmailerr( cNumPC , nRecSC7 )
// ------------------------------------
	local cSMTP     := alltrim( getmv( 'MV_RELSERV' )) // smtp.ig.com.br ou 200.181.100.51
	local cConta    := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
	local cPass     := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
	local cAssunto  := ''
	local cMensagem := ''
	local lConSMTP  := .F.
// ------------------------------------
	dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
	SC7->( dbgoto( nRecSC7 ))
// ------------------------------------	
	cAssunto  := 'Erro ao enviar PDF de pedido de compra: ' + cNumPC
// ------------------------------------
	cMensagem := '<html>'
	cMensagem += '<head><title>' + cAssunto + '</title></head>'
	cMensagem += '<body>'
	cMensagem += '<br>'
	cMensagem += 'Ocorreu um erro ao gerar o arquivo PDF do pedido: ' + cNumPC + ' da filial ' + SM0->M0_FILIAL
	cMensagem += ' para o fornecedor ' + posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_NOME' )
	cMensagem += ', é necessário imprimir o mesmo no sistema e enviar em anexo a um e-mail para o fornecedor novamente.<br><br><br>'
	cMensagem += '</body>'
	cMensagem += '</html>'
// ------------------------------------
	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP
	if lConSMTP
		SEND MAIL FROM cConta TO alltrim( getmv( 'MV_XMAILFO' )) SUBJECT cAssunto BODY  cMensagem
		recLock( 'SC7' , .F. )
		SC7->C7_XENVMAL := 'N'
		SC7->( msunlock() )
		Disconnect SMTP Server
	endif
// ------------------------------------

return

// ----------------------------------------------------------------------------
// [ fim de f1200501.prw ]
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// {Protheus.doc} sndPrepErr
// Envia o e-mail informando o erro ao Preparar ou Enviar e-mail
// @author Thais Paiva
// @since  29/06/2021
// ----------------------------------------------------------------------------
static function sndPrepErr(cNumPC,nRecSC7,cMsg,nTp)
// ------------------------------------
	local cSMTP     := alltrim( getmv( 'MV_RELSERV' )) // smtp.ig.com.br ou 200.181.100.51
	local cConta    := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
	local cPass     := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
	local cAssunto  := ''
	local cMensagem := ''
	local lConSMTP  := .F.
// ------------------------------------
	dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
	SC7->( dbgoto( nRecSC7 ))
// ------------------------------------	
	If nTp == 2
		cAssunto  := 'Erro ao preparar/enviar E-mail de pedido de compra: ' + cNumPC
	Else
		cAssunto  := cMsg +' do Pedido de Compra: ' + cNumPC
	EndIf
// ------------------------------------
	cMensagem := '<html>'
	cMensagem += '<head><title>' + cAssunto + '</title></head>'
	cMensagem += '<body>'
	cMensagem += '<br>'
	If nTp == 2
		cMensagem += 'Ocorreu um erro na montagem/envio do e-mail do pedido: ' + cNumPC + ' da filial ' + SM0->M0_FILIAL
		cMensagem += ' para o fornecedor ' + posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_NOME' )
		cMensagem += ', é necessário imprimir o mesmo no sistema e enviar em anexo a um e-mail para o fornecedor novamente.<br><br>'
		cMensagem += 'Segue erro informado: ' + Alltrim(cMsg)
	Else
		cMensagem += 'O Fornecedor: '+ posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_NOME' )
		cMensagem += ' não possui e-mail cadastrado. Será necessário imprimir o Pedido de Compra no sistema e'
		cMensagem += ' enviar em anexo a um e-mail para o fornecedor novamente. <br> '
		cMensagem += 'Para que o problema não ocorra novamente deve-se atualizar o Cadastro do Fornecedor informando uma conta de e-mail. <br><br> '
	EndIf
	cMensagem += '<br><br><br>'
	cMensagem += '</body>'
	cMensagem += '</html>'
// ------------------------------------
	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP

	if lConSMTP
		SEND MAIL FROM cConta TO alltrim( getmv( 'MV_XMAILFO' )) SUBJECT cAssunto BODY  cMensagem
		recLock( 'SC7' , .F. )
		SC7->C7_XENVMAL := 'N'
		SC7->( msunlock() )
		Disconnect SMTP Server
	endif
// ------------------------------------
return

//Início - Thais Paiva - 07/07/2021
Static Function SalvaEmail(cConta,cContaDes,cMailContr,_cBcc,cAssunto,cMensagem,cNomeAnexo)
	Local _cNomeArq := 'EMAIL'
	Local oPrinter
	local cDir            := '\IMPPC\'
	Local lAdjustToLegacy := .F.
	Local lDisableSetup  := .T.
	Local _cNomeAux := substr( cNomeAnexo , rat( '\' , cNomeAnexo ) + 1 )
	Local cAuxMsg := {}

	if !ExistDir( '\IMPPC' ) //Thais Paiva - 12013888
		MakeDir( '\IMPPC' ) //Thais Paiva - 12013888
	endif //Thais Paiva - 12013888

	_cNomeArq += StrTran(_cNomeAux,"RDRIMPPC","")
	_cNomeArq := StrTran(_cNomeArq,".pdf","")

	cAuxMsg := StrTran(cMensagem,cAssunto,"")
	cAuxMsg := StrTran(cAuxMsg,"<body>","")
	cAuxMsg := StrTran(cAuxMsg,"<html>","")
	cAuxMsg := StrTran(cAuxMsg,"<head>","")
	cAuxMsg := StrTran(cAuxMsg,"<title>","")
	cAuxMsg := StrTran(cAuxMsg,"</title>","")
	cAuxMsg := StrTran(cAuxMsg,"</head>","")
	cAuxMsg := StrTran(cAuxMsg,"<br>"," ")
	cAuxMsg := StrTran(cAuxMsg,"</body>","")
	cAuxMsg := StrTran(cAuxMsg,"</html>","")
	cMensagem := StrTran(cAuxMsg,"  "," ")
	cMensagem := Alltrim(cMensagem)

	oPrinter := FWMSPrinter():New(_cNomeArq, IMP_PDF, lAdjustToLegacy, cDir, lDisableSetup , , , , , , .F. , .F. )
	oPrinter:SetPortrait()

	oFont09  := TFont():New( 'Arial'       , 09 , 09 , , .F. , , , , .T. , .F. )

	oPrinter:StartPage()

	oPrinter:Say(015,10,"INFORMAÇÕES DO E-MAIL ENVIADO", oFont09 )
	oPrinter:Line(017 , 10 , 015 , 0580 )
	oPrinter:Say(030,10,"De: "+cConta, oFont09 ) // conteudo
	oPrinter:Say(040,10,"Para: "+cContaDes, oFont09 ) // conteudo
	oPrinter:Say(050,10,"CC: "+IIf(Empty(Alltrim(cMailContr)),"N/A",cMailContr), oFont09) // conteudo
	oPrinter:Say(060,10,"BCC: "+IIf(Empty(Alltrim(_cBcc)),"N/A",_cBcc), oFont09 ) // conteudo
	oPrinter:Say(070,10,"Assunto: "+cAssunto, oFont09 ) // conteudo
	oPrinter:Say(080,10,"Mensagem: "+Substr(cMensagem,1,150), oFont09 ) // conteudo
	If Len(cMensagem) > 150
		oPrinter:Say(090,10,"          "+Substr(cMensagem,151,150), oFont09 ) // conteudo
	EndIf
	If Len(cMensagem) > 250
		oPrinter:Say(100,10,"          "+Substr(cMensagem,301), oFont09 ) // conteudo
	EndIf
	oPrinter:Say(110,10,"Nome Anexo: "+cNomeAnexo, oFont09 ) // conteudo

	oPrinter:Line(0128 , 010 , 0128 , 0580 )
	oPrinter:Say( 0135 , 0010 , 'TOTVS - F1200501 - SalvaEmail' , oFont09 )
	oPrinter:Line(0137 , 0010 , 0137 , 0580 )
	oPrinter:Preview() // depois de salvar abre o arquivo na tela

	oPrinter:EndPage()

Return oPrinter:cPathPDF + _cNomeArq + '.pdf'
//Fim - Thais Paiva - 12013888
