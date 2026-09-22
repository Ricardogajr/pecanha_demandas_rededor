
#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"
#INCLUDE "FILEIO.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )
#DEFINE SX3_USADO "€€€€€€€€€€€€€€ "
#DEFINE SX3_NAO_USADO "€€€€€€€€€€€€€€€"
#DEFINE SX3_OBRIGAT "€"                

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPD2298
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPD2298( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS Ver 2.0.2  - " 
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cF3new    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

/*#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF*/

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPD2298" )
				Else
					MsgStop( "Atualização não Realizada.", "UPD2298" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

	    For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			//oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX2()
		
		    //------------------------------------
			// Atualiza o dicion?io SX5
			//------------------------------------
            //            cF3New := FSAtuSX5()
                         
   			//------------------------------------
   			// Atualiza o dicion?io SXB          
   			//------------------------------------
   			//FSAtuSXB(cF3New)

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			//oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos

  		    __SetX31Mode( .F. )
   		    If FindFunction(cTCBuild)
			   cTopBuild := &cTCBuild.()
            EndIf
			For nX := 1 To Len( aArqUpd )
				   /*If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
				      If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						    !aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						  TcInternal( 25, "CLOB" )
					  EndIf
				   EndIf*/
				   If Select( aArqUpd[nX] ) > 0
					  dbSelectArea( aArqUpd[nX] )
					  dbCloseArea()
				   EndIf
   			       cEmp2 := U_CHECK3SX2(aArqUpd[nX])
                   If SM0->M0_CODIGO = cEmp2
  				      X31UpdTable( aArqUpd[nX] )
				      If __GetX31Error() 
                         cErro1 := __GetX31Trace()  
                         If AT("Não foi necessário alterar a estrutura da tabela",cErro1) = 0 
                            MsgStop( "Ocorreu um erro na atualização do Banco tabela : " + ;
					                 aArqUpd[nX] + ". Verifique as Permissões no Banco. ", "ATENÇÃO" )
					        AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				         EndIf
				         /*If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					        TcInternal( 25, "OFF" )
				         EndIf*/
                      Endif
                   Endif
 			Next nX
			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			//oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX7()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			//oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .T.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
//Local nTamSeek  := Len( SX3->X3_CAMPO ) Thais Paiva - Compatibilização P27
Local _aCpoX3	:= {} //Thais Paiva - Compatibilização P27

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// --- ATENÇÃO ---
// Coloque .F. na 2a. posição de cada elemento do array, para os dados do SX3
// que não serão atualizados quando o campo já existir.
//


//
// Campos Tabela SRA
//
If !U_ACHEI1SX3("SRA","RA_XPGJUIR")
   cOrd1 := U_ULT2298SX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := U_QOrd2298SX3("SRA","RA_XPGJUIR")
Endif

aAdd( aSX3, { ;
	{ 'SRA'											, .T. }, ; //X3_ARQUIVO
	{ cOrd1											, .T. }, ; //X3_ORDEM
	{ 'RA_XPGJUIR'										, .T. }, ; //X3_CAMPO
	{ 'C'											, .T. }, ; //X3_TIPO
	{ 1											, .T. }, ; //X3_TAMANHO
	{ 0											, .T. }, ; //X3_DECIMAL
	{ 'Pagto Juizo'										, .T. }, ; //X3_TITULO
	{ 'Pagto Juizo'										, .T. }, ; //X3_TITSPA
	{ 'Pagto Juizo'										, .T. }, ; //X3_TITENG
	{ 'Contrib.Pagas em Juizo'										, .T. }, ; //X3_DESCRIC
	{ 'Contrib.Pagas em Juizo'										, .T. }, ; //X3_DESCSPA
	{ 'Contrib.Pagas em Juizo'     									, .T. }, ; //X3_DESCENG
	{ '@!'											, .T. }, ; //X3_PICTURE
	{ 'PERTENCE("SN")'	            , .T. }, ; //X3_VALID
	{ SX3_USADO									, .T. }, ; //X3_USADO
	{ ''											, .T. }, ; //X3_RELACAO
	{ ''											, .T. }, ; //X3_F3
	{ 1											, .T. }, ; //X3_NIVEL
	{ 'þA'										, .T. }, ; //X3_RESERV
	{ ''											, .T. }, ; //X3_CHECK
	{ ''											, .T. }, ; //X3_TRIGGER
	{ 'U'											, .T. }, ; //X3_PROPRI
	{ 'N'											, .T. }, ; //X3_BROWSE
	{ 'A'											, .T. }, ; //X3_VISUAL
	{ 'R'											, .T. }, ; //X3_CONTEXT
	{ ''  										, .T. }, ; //X3_OBRIGAT
	{ ''											, .T. }, ; //X3_VLDUSER
	{ 'N=Nao;S=Sim'	 							    , .T. }, ; //X3_CBOX
	{ 'N=No;S=Si'											, .T. }, ; //X3_CBOXSPA
	{ 'N=No;S=Yes'											, .T. }, ; //X3_CBOXENG
	{ ''											, .T. }, ; //X3_PICTVAR
	{ 'M->RA_TIPOADM="4B"'											, .T. }, ; //X3_WHEN
	{ ''											, .T. }, ; //X3_INIBRW
	{ ''											, .T. }, ; //X3_GRPSXG
	{ '2'											, .T. }, ; //X3_FOLDER
	{ ''											, .T. }, ; //X3_CONDSQL
	{ ''											, .T. }, ; //X3_CHKSQL
	{ ''											, .T. }, ; //X3_IDXSRV
	{ ''											, .T. }, ; //X3_ORTOGRA
	{ ''											, .T. }, ; //X3_TELA
	{ ''											, .T. }, ; //X3_POSLGT
	{ ''											, .T. }, ; //X3_IDXFLD
	{ ''											, .T. }, ; //X3_AGRUP
	{ ''											, .T. }, ; //X3_MODAL
	{ ''											, .T. }} ) //X3_PYME

// 
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

//aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1]+x[nPosCpo][1] < y[nPosArq][1]+y[nPosOrd][1]+y[nPosCpo][1] } )
aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1] < y[nPosArq][1]+y[nPosOrd][1] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG][1] )
	//Início - Thais Paiva - CompatibilizaçãoP27
		//SXG->( dbSetOrder( 1 ) )
		OpenSxs(,,,,cEmpAnt,"SXGTAB","SXG",,.F.)
		If Select("SXGTAB") > 0
			While SXGTAB->(!EOF())
				If SXGTAB->(FildPos(aSX3[nI][nPosSXG][1])) > 0
		//If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
					If aSX3[nI][nPosTam][1] <> SXGTAB->&("XG_SIZE") //SXG->XG_SIZE
						aSX3[nI][nPosTam][1] := SXGTAB->&("XG_SIZE") //SXG->XG_SIZE
						AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
						AllTrim( Str( SXGTAB->&("XG_SIZE") ) ) + "]" + CRLF + ;
						" por pertencer ao grupo de campos [" + SXGTAB->&("XG_GRUPO") + "]" + CRLF )
						//AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
						//" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
					EndIf
				Endif
				SXGTAB->(DbSkip())
			Enddo
		EndIf
	//Fim - Thais Paiva - COmpatibilização P27
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq][1] $ cAlias )
		cAlias += aSX3[nI][nPosArq][1] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
	EndIf
	
	//Início - Thais Paiva - COmpatibilização P27	
	//If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo][1], nTamSeek ) ) )
	If SX3->(FieldPos(aSX3[nI][nPosCpo][1])) == 0
		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq][1] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq][1]

			//dbSetOrder( 1 )
			//SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			//dbSkip( -1 )
			_aCpoX3 := FWSX3Util():GetAllFields( cAliasAtu , .F. ) 

			//If ( SX3->X3_ARQUIVO == cAliasAtu )
			If Len(_aCpoX3) > 0
				_nx3 := Ascan( _aCpoX3, {|x| x[1] == "X3_ORDEM"} )
				cSeqAtu := GetSx3Cache(_aCpoX3[_nx3], 'X3_ORDEM') //SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo][1] )

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		//If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG][1]
		If !Empty(GetSx3Cache(aSX3[nI][nPosCpo][1], 'X3_GRPSXG')) .AND. GetSx3Cache(aSX3[nI][nPosCpo][1], 'X3_GRPSXG') <> aSX3[nI][nPosSXG][1]
			//SXG->( dbSetOrder( 1 ) )
			//If SXG->( MSSeek( SX3->X3_GRPSXG ) )
			OpenSxs(,,,,cEmpAnt,"SXG2TB","SXG",,.F.)
			If Select("SXG2TB") > 0
				While SXG2TB->(!EOF())
					If SXG2TB->(FildPos(aSX3[nI][nPosSXG][1])) > 0
						If aSX3[nI][nPosTam][1] <> SXG2TB->&("XG_SIZE") //SXG->XG_SIZE
							aSX3[nI][nPosTam][1] := SXG2TB->&("XG_SIZE") //SXG->XG_SIZE
							AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
							AllTrim( Str( SXG2TB->&("XG_SIZE") ) ) + "]"+ CRLF + ;
							"   por pertencer ao grupo de campos [" + GetSx3Cache(aSX3[nI][nPosCpo][1], 'X3_GRPSXG') + "]" + CRLF )
							//AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
							//"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
						EndIf
					Endif
					SXG2TB->(DbSkip())
				Enddo
			EndIf
		EndIf
		//Fim - Thais Paiva - COmpatibilização P27
		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aSX3[nI][nJ][2]
				cX3Campo := AllTrim( aEstrut[nJ][1] )
				cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

				If  aEstrut[nJ][2] > 0 .AND. ;
					PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
					PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
					!cX3Campo == "X3_ORDEM"

					cMsg := "O campo " + aSX3[nI][nPosCpo][1] + " está com o " + cX3Campo + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( cX3Dado ) ) + "]" + CRLF + ;
					"que será substituído pelo NOVO conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSX3[nI][nJ][1] ) ) + "]" + CRLF + ;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX3" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
						"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
						"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

						RecLock( "SX3", .F. )
						FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
						MsUnLock()
					EndIf

				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
/*Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SRA
//

If U_Achei1SX3("SRA","RA_XPGJUIR")
   aHlpPor := {}   
   aAdd( aHlpPor, 'Indicar se as remunerações e') 
   aAdd( aHlpPor, 'correspondentes contribuições do') 
   aAdd( aHlpPor, 'período compreendido entre o')
   aAdd( aHlpPor, 'desligamento e a reintegração') 
   aAdd( aHlpPor, 'foram pagas em juízo:')                                     
   aAdd( aHlpPor, 'Valores Válidos: S, N.')                       
   aAdd( aHlpPor, 'S- Sim, N - Não.')                                     
   PutHelp( "PRA_XPGJUIR", aHlpPor, {}, {}, .T. )
   AutoGrLog( "Atualizado o Help do campo " + "RA_XPGJUIR" )
Endif

Return {}*/


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDZAZ" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
//	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	//dbUseArea( .T., , "SIGAMAT.EMP", "SM0", .T., .T. ) Thais Paiva - Compatibilização P27
	OpenSm0(cEmpAnt, .T.)

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


User Function ULT2298SX3(cArq)
Local cOrdem  := ""
//Início - Thais Paiva - Compatibilização P27
Local _aCpoX3 := FWSX3Util():GetAllFields( cArq , .F. )
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX3->X3_ARQUIVO == cArq
If Len(_aCpoX3) > 0
	For _nX3 := 1 to Len(_aCpoX3)
		cOrdem := GetSx3Cache(_aCpoX3[_nx3], 'X3_ORDEM') //SX3->X3_ORDEM
    //DbSkip()
	Next _nX3
EndIf
//Fim - Thais Paiva - Compatibilização P27                 
Return cOrdem

User Function ACHEI1SX3(cArq,cCampo)
Local lAchei := .F.
//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX3->X3_ARQUIVO == cArq
//     If ALLTRIM(SX3->X3_CAMPO) == ALLTRIM(cCampo)
If (cArq)->(FieldPos(cCampo)) > 0
	lAchei := .T.
Endif
//     DbSkip()
//End       
//Fim - Thais Paiva - Compatibilização P27                
Return lAchei

User Function QOrd2298SX3(cArq,cCampo)
Local lAchei := "  "
//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX3->X3_ARQUIVO == cArq
//     If ALLTRIM(SX3->X3_CAMPO) == ALLTRIM(cCampo)
        lAchei := GetSx3Cache(cCampo, 'X3_ORDEM') //ALLTRIM(SX3->X3_ORDEM)
//     Endif
//     DbSkip()
//End                
//Fim - Thais Paiva - Compatibilização P27    
Return lAchei


//--------------------------------------------------------------------
//FSAtuSX5  TIPO LOGRADORO
//Função de processamento da gravação do SX5 - Campos
//
//@author TOTVS Protheus
//@since  26/09/2017
//@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
//@version 1.0
//
//--------------------------------------------------------------------

Static Function FSAtuSX5()
   Local aArea    := GetArea()
   Local aRet     := {}
   Local cCodFil  := xFilial("SX5")
   Local lExc     := !Empty(cCodFil)
   Local aFiliais := If(!lExc,{xFilial("SX5")},FWAllFilial())
   Local nFiliais := Len(aFiliais)
   Local nX       := 0
   Local aSX5     := {}
   Local lExist   := .T.
   Local nPosChv  := 0
   Local nPosDsc  := 0
   Local nPosFil  := 0
   Local nPosTab  := 0
   Local nField   := 0
   Local cTabTmp  := ""
   Local cTabNew  := ""
   Local bMsgEmp  := {|| If(lExc,StrTran(' Empresa: "%s1".','%s1',cEmpAnt+"/"+cCodFil),StrTran(' Empresa: "%s1".','%s1',cEmpAnt))}
   Local aSx5Tmp  := {}     
   
   dbSelectArea( "SX5" )
   dbSetOrder( 1 ) //X5_FILIAL+X5_TABELA+X5_CHAVE

   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','00'},{'X5_CHAVE','ZA'} ,{'X5_DESCRI','TIPO BAS.CALCULO'} ,{'X5_DESCSPA','UPDESOC3'},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','00'} ,{'X5_DESCRI','RENDIMENTO NAO TRIBUTAVEL                              ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','01'} ,{'X5_DESCRI','RENDIMENTO NAO TRIBUTAVEL ACORDOS INTER. BITRIBUTACAO  ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','11'} ,{'X5_DESCRI','REMUNERACAO MENSAL                                     ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','12'} ,{'X5_DESCRI','13o SALARIO; 13 - FERIAS                               ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','14'} ,{'X5_DESCRI','PLR                                                    ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','15'} ,{'X5_DESCRI','RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA             ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','31'} ,{'X5_DESCRI','REMUNERACAO MENSAL                                     ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','32'} ,{'X5_DESCRI','13o SALARIO;                                           ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','33'} ,{'X5_DESCRI','FERIAS                                                 ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','34'} ,{'X5_DESCRI','PLR                                                    ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','35'} ,{'X5_DESCRI','RRA                                                    ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','41'} ,{'X5_DESCRI','PREVIDENCIA SOCIAL OFICIAL - PSO - REMUNER. MENSAL     ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','42'} ,{'X5_DESCRI','PSO - 13° SALARIO                                      ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','43'} ,{'X5_DESCRI','PSO - FERIAS                                           ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','44'} ,{'X5_DESCRI','PSO - RRA                                              ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','46'} ,{'X5_DESCRI','PREVIDENCIA PRIVADA - SALARIO MENSAL                   ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','47'} ,{'X5_DESCRI','PREVIDENCIA PRIVADA - 13° SALARIO                      ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','51'} ,{'X5_DESCRI','PENSAO ALIMENTICIA - REMUNERAÇÃO MENSAL                ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','52'} ,{'X5_DESCRI','PENSAO ALIMENTICIA - 13° SALÁRIO                       ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','53'} ,{'X5_DESCRI','PENSAO ALIMENTICIA - FÉRIAS                            ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','54'} ,{'X5_DESCRI','PENSAO ALIMENTICIA - PLR                               ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','55'} ,{'X5_DESCRI','PENSAO ALIMENTICIA - RRA                               ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','61'} ,{'X5_DESCRI','FAPI - REMUNERACAO MENSAL                              ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','62'} ,{'X5_DESCRI','FAPI - 13° SALARIO                                     ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','63'} ,{'X5_DESCRI','FUNPRESP - REMUNERACAO MENSAL                          ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','64'} ,{'X5_DESCRI','FUNPRESP - 13° SALARIO                                 ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','70'} ,{'X5_DESCRI','PARCELA ISENTA 65 ANOS - REMUNERACAO MENSAL            ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','71'} ,{'X5_DESCRI','PARCELA ISENTA 65 ANOS - 13o SALARIO                   ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','72'} ,{'X5_DESCRI','DIARIAS                                                ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','73'} ,{'X5_DESCRI','AJUDA DE CUSTO                                         ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','74'} ,{'X5_DESCRI','INDENIZACAO E RESCISAO DE CONTRATO                     ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','75'} ,{'X5_DESCRI','ABONO PECUNIARIO                                       ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','76'} ,{'X5_DESCRI','PENSAO, APOSENTADORIA OU REFORMA - REMUNERACAO MENSAL  ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','77'} ,{'X5_DESCRI','PENSAO, APOSENTADORIA OU REFORMA - 13o SALARIO         ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','78'} ,{'X5_DESCRI','VALORES PAGOS A TITULAR OU SOCIO DE ME OU EPP          ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','79'} ,{'X5_DESCRI','OUTRAS ISENCOES                                        ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','81'} ,{'X5_DESCRI','DEPOSITO JUDICIAL                                      ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','82'} ,{'X5_DESCRI','COMPENSACAO JUDICIAL DO ANO CALENDARIO                 ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','83'} ,{'X5_DESCRI','COMPENSACAO JUDICIAL DE ANOS ANTERIORES                ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','91'} ,{'X5_DESCRI','REMUNERACAO MENSAL                                     ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','92'} ,{'X5_DESCRI','13o SALARIO                                            ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','93'} ,{'X5_DESCRI','FERIAS                                                 ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','94'} ,{'X5_DESCRI','PLR                                                    ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   Aadd(aSX5,{{'X5_FILIAL',''},{'X5_TABELA','ZA'},{'X5_CHAVE','95'} ,{'X5_DESCRI','RRA                                                    ' } ,{'X5_DESCSPA',''},{'X5_DESCENG','UPDESOC3'}})
   
   nPosFil := AScan( aSX5[1], { |x| AllTrim( x[1] ) == "X5_FILIAL" } )      
   nPosTab := AScan( aSX5[1], { |x| AllTrim( x[1] ) == "X5_TABELA" } )      
   nPosChv := AScan( aSX5[1], { |x| AllTrim( x[1] ) == "X5_CHAVE"  } )      
   nPosDsc := AScan( aSX5[1], { |x| AllTrim( x[1] ) == "X5_DESCRI" } )
   nPosDsp := AScan( aSX5[1], { |x| AllTrim( x[1] ) == "X5_DESCSPA" } )
   
   //Retira a acentuaCao da descriCao (X5_DESCRI) dos campos.
   AEVal(aSX5, {|x| x[nPosDsc,2] := FwNoAccent(OemToAnsi(x[nPosDsc,2])) } ) 
   For nF := 1 To nFiliais
       cCodFil := aFiliais[nF]
       cTabTmp := ""
       //Preenche o campo X5_FILIAL
       AEVal(aSX5, {|x| x[nPosFil,2] := cCodFil  } )
       For nX := 1 To Len(aSX5)
           cChave   := aSX5[nX][nPosChv,2]
           cDesc    := aSX5[nX][nPosDsc,2]
           cDescsp  := aSX5[nX][nPosDsp,2]
           If ( cTabTmp != aSX5[nX][nPosTab,2] )
              cTabTmp := If((aSX5[nX][nPosTab,2] == '00'),AllTrim(aSX5[nX][nPosChv,2]),aSX5[nX][nPosTab,2])
              If ( AScan(aSx5Tmp,{|x| x[1] == cTabTmp}) > 0 )
                 cTabNew := aSx5Tmp[AScan(aSx5Tmp,{|x| x[1] == cTabTmp}),2]
              ElseIf (aSX5[nX][nPosTab,2] == '00') 
                 cTabNew := fExistChv(cCodFil,cDesc)
              Else
                 cTabNew := ""
              Endif
              
              lExist  := !Empty(cTabNew)  
              
              If !lExist
                 Aadd(aSx5Tmp,fNextSx5(cTabTmp,aFiliais)) 
                 cTabNew := aSx5Tmp[Len(aSx5Tmp)][2]
                 AutoGrLog( 'SX5: Criando a tabela "{1}" (E-social: "{2}")...'+Eval(bMsgEmp),{cTabNew,cTabTmp} )
              Else
                 AutoGrLog( 'SX5: Atualizando a tabela "{1}" (E-social: "{2}")...'+Eval(bMsgEmp),{cTabNew,cTabTmp} )
              Endif
              //****************************************************************************
              //* Desconsiderando a filial, pois so e possIvel vincular uma SX5 para X3_F3.* 
              //****************************************************************************
              If ( AScan(aRet,{|x| x[2] == cTabTmp .And. x[3] == cTabNew}) == 0 ) 
                 Aadd(aRet,{cCodFil,cTabTmp,cTabNew})
              Endif
           Endif
           
           //Verifica se cada chave existe para a tabela a ser atualizada/criada (cTabNew).
           If (aSX5[nX][nPosTab,2] == '00')
              lExist := SX5->(dbSeek( cCodFil + '00' + cTabNew))
           Else
              lExist := SX5->(dbSeek( cCodFil + cTabNew + cChave))
           Endif
           
           RecLock( "SX5", !lExist )
           For nC := 1 To SX5->(FCount())
               nField := aScan( aSX5[nX], { |x| SX5->(FieldName(nC)) == AllTrim( x[1] ) } )
               If (nField == 0)
                  Loop
               Endif
               If (SX5->(FieldName(nField)) == "X5_TABELA")
                  If (aSX5[nX][nPosTab,2] == '00')
                     SX5->( FieldPut( nField, '00' ) )
                  Else
                     SX5->( FieldPut( nField, cTabNew ) )
                  Endif
               ElseIf (SX5->(FieldName(nField)) == "X5_CHAVE") .And. (aSX5[nX][nPosTab,2] == '00')
                  SX5->( FieldPut( FieldPos("X5_CHAVE"), cTabNew ) )
               Else
                                                                    
                  SX5->( FieldPut( nField, aSX5[nX][nField,2] ) )
               Endif
           Next nC
           SX5->(dbCommit())
           SX5->(MsUnLock())
          
       Next nX
   Next nF
   
   RestArea(aArea)

Return cTabNew


//--------------------------------------------------------------------
//FSAtuSXB  TIPO BASE DE CALCULO IRRF
//Função de processamento da gravação do SXB - Consultas Padr?s
//
//@author TOTVS Protheus
//@since  06/09/2017
//@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
//@version 1.0
//
//--------------------------------------------------------------------

/*Static Function FSAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .T.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

cTexto  = "Inicio da Atualizacao" + " SXB" + CRLF + CRLF

aEstrut := { "XB_ALIAS",  "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , ;
             "XB_DESCRI", "XB_DESCSPA", "XB_DESCENG", "XB_CONTEM" }

//
// Consulta TIPO DE LOGRADOURO
//
aAdd( aSXB, { ;
	cF3New						, ; //XB_ALIAS
	'1'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	'DB'						, ; //XB_COLUNA
	'Tipo Bas.Calc IRRF  '				, ; //XB_DESCRI
	'Tipo Bas.Calc IRRF  '				, ; //XB_DESCSPA
	'UPDESOC3'				, ; //XB_DESCENG
	'SX5'						} ) //XB_CONTEM

aAdd( aSXB, { ;
	cF3New						, ; //XB_ALIAS
	'2'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	'01'						, ; //XB_COLUNA
	'Tabela + Chave      '				, ; //XB_DESCRI
	'Tabla + Clave       '				, ; //XB_DESCSPA
	'UPDESOC3'				, ; //XB_DESCENG
	''						} ) //XB_CONTEM

aAdd( aSXB, { ;
	cF3New						, ; //XB_ALIAS
	'4'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	'01'						, ; //XB_COLUNA
	'Chave               '				, ; //XB_DESCRI
	'Clave               '				, ; //XB_DESCSPA
	'UPDESOC3'				, ; //XB_DESCENG
	'X5_CHAVE            '				} ) //XB_CONTEM

aAdd( aSXB, { ;
	cF3New						, ; //XB_ALIAS
	'4'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	'02'						, ; //XB_COLUNA
	'Descricao           '				, ; //XB_DESCRI
	'Descripcion         '				, ; //XB_DESCSPA
	'UPDESOC3'				, ; //XB_DESCENG
	'X5_DESCRI'					} ) //XB_CONTEM

aAdd( aSXB, { ;
	cF3New						, ; //XB_ALIAS
	'5'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	''						, ; //XB_COLUNA
	''						, ; //XB_DESCRI
	''						, ; //XB_DESCSPA
	'UPDESOC3'						, ; //XB_DESCENG
	'SX5->X5_CHAVE'					} ) //XB_CONTEM

aAdd( aSXB, { ;
	cF3New						, ; //XB_ALIAS
	'6'						, ; //XB_TIPO
	'01'						, ; //XB_SEQ
	''						, ; //XB_COLUNA
	''						, ; //XB_DESCRI
	''						, ; //XB_DESCSPA
	'UPDESOC3'						, ; //XB_DESCENG
	cF3New						} ) //XB_CONTEM

//
// Atualizando dicion?io
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi incluida a consulta padrao " + aSXB[nI][1] + CRLF
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrao " + aSXB[nI][1] + " esta com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteudo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este e diferente do conteudo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONARIOS E TABELAS", cMsg, { "Sim", "Nao", "Sim p/Todos", "Nao p/Todos" }, 3, "Diferenca de conteudo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e Nao MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de Nao REALIZAR nenhuma alteração no SXB que esteja diferente da base e Nao MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Nao p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi Alterada a consulta padrao " + aSXB[nI][1] + CRLF
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padroes (SXB)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSXB )*/

****************************************************************************************
** Retorna o nome da tabela caso ja exista na SX5, atraves da filial, chave e descriCao
Static Function fExistChv(cCodFil,cDesc)
****************************************************************************************
   Local cRet    := ""
   Local cQuery  := ""
   Local nChecks := 0 //Numero de chaves a serem checadas ate considerar uma tabela existente na SX5 (por precauCao)
   Local cAlias  := GetNextAlias()

   cQuery  = "SELECT SX5.X5_CHAVE AS TABELA                 " + CRLF
   cQuery += "FROM "+RetSqlName("SX5")+" SX5                " + CRLF
   cQuery += "WHERE SX5.D_E_L_E_T_=' '                      " + CRLF
   cQuery += "AND SX5.X5_DESCSPA = 'UPDESOC2'              " + CRLF
   cQuery += "AND SX5.X5_DESCENG = 'UPDESOC2'              " + CRLF
   cQuery += "AND SX5.X5_FILIAL  = '"+cCodFil+"'            " + CRLF
   cQuery += "AND SX5.X5_TABELA  = '00'                     " + CRLF
   cQuery += "AND SX5.X5_DESCRI  = '"+cDesc+"'              " + CRLF
   TCQUERY cQuery NEW ALIAS (cAlias)             
   If (cAlias)->(!Eof())
      cRet := AllTrim((cAlias)->TABELA)
   Endif                                                
   If (Select(cAlias) > 0)
      (cAlias)->(dbCloseArea())
   Endif                       
   
Return cRet

*******************************************************************
** Retorna o proximo nome de Tabela na SX5 disponIvel, ignorando 
** a filial, pois so e possIvel vincular uma uncia SX5 para X3_F3.
Static Function fNextSx5(cTabTmp,aFiliais)
*******************************************************************
   Local aRet     := {}
   Local cTab     := "Z0"
   Local aAreaSX5 := SX5->(GetArea())
   Local nX       := 0
   Local lFree    := .F.
   
   SX5->(DbSetOrder(1))
   SX5->(DbSeek(xFilial("SX5") + "Z"))
   If SX5->(Eof())
      SX5->(DbGotop())
   Endif
   
   While !lFree 
         cTab := Soma1(cTab)
         If cTab $ "Z0|ZG|ZH|ZI|ZJ|ZM|ZN|ZO|ZP|ZQ|ZR|ZS|ZT|ZU"
            Loop
         Endif
         
         For nX := 1 To Len(aFiliais) //Verifica a disponibilidade do nome da tabela para todas as filiais.
             lFree := !SX5->(dbSeek( aFiliais[nX] + cTab))
             If !lFree
                Exit
             Endif
         Next nX
   Enddo
   
   aRet := {cTabTmp,cTab}                               

   SX5->(RestArea(aAreaSX5))                    
   
Return aRet

*************************
Static Function fDelSx5()
*************************
   Local cQuery := ""
   Local lRet   := .T.
   
   cQuery := "DELETE FROM "+RetSqlName("SX5")+" "+ CRLF
   cQuery += "WHERE X5_DESCSPA = 'UPDESOC2'   "+ CRLF
   cQuery += "AND X5_DESCENG = 'UPDESOC2'     " 
   If (TCSQLExec(cQuery) < 0)
      AutoGrLog( "Erro ao executar o comando: {1}",{TCSQLError()} )
      lRet := .F.
   Endif
Return  lRet

****************************
Static Function fSoma1(cNum)
****************************
   Local nNum := VAL( RetAsc(cNum,4,.F.) ) + 1
   Local cRet := RetAsc(nNum,2,.T.)
Return cRet


****************************
User Function CHECK3SX2(cArq)
****************************
Local aArea := GetArea()
Local cEmp1 := ''
Local _aCpoX2 := {} //Thais Paiva - Compatibilização P27

//Início - Thais Paiva - Compatibilização P27
//dbSelectArea("SX2")
//dbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX2->X2_CHAVE == cArq
      cEmp1 := Substr(FWSX2Util():GetFile(cArq),4,2) //Substr(SX2->X2_ARQUIVO,4,2)
//      DbSkip()
//End
//Fim - Thais Paiva - Compatibilização P27                   
Return cEmp1

/////////////////////////////////////////////////////////////////////////////
