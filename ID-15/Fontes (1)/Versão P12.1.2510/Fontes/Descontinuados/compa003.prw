*+-------------------------------------------------------------------------+*
*|Funcao      | COMPA0003   | Autor | Amauri Soares - Totvs/Zydax          |*
*+------------+------------------------------------------------------------+*
*|Data Inicio | 31/01/2019                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Compatibilizador Campos SRA relacionados เs                +*
*|            | informa็๕es dos eventos peri๓dicos e nใo peri๓dicos        +*   
*+------------+------------------------------------------------------------+*
*|Solicitante | eSocial V2.5 P12                                           |*
*+------------+------------------------------------------------------------+*
*|Tabelas     | SRA                                                        |*
*+------------+------------------------------------------------------------+*
*|             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |*
*+-------------------------------------------------------------------------+*
*| Programador       |   Data   | Motivo da alteracao                      |*
*+-------------------+----------+------------------------------------------+*
*| Amauri Soares     |31/01/2019| Inicio da Implementa็ใo                  |* 
*+-------------------+----------+------------------------------------------+*
*****************************************************************************

#INCLUDE "PROTHEUS.CH"                                 

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ COMPA003 บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de update dos dicionแrios para compatibiliza็ใo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ COMPA0003    - Gerado por EXPORDIC / Upd. V.4.10.6 EFS     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COMPA003( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAวรO DE DICIONมRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como fun็ใo fazer  a atualiza็ใo  dos dicionแrios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja nใo podem haver outros"
Local   cDesc3    := "usuแrios  ou  jobs utilizando  o sistema.  ษ extremamente recomendav้l  que  se  fa็a um"
Local   cDesc4    := "BACKUP  dos DICIONมRIOS  e da  BASE DE DADOS antes desta atualiza็ใo, para que caso "
Local   cDesc5    := "ocorra eventuais falhas, esse backup seja ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
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
		If lAuto .OR. MsgNoYes( "Confirma a atualiza็ใo dos dicionแrios ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

		If lAuto
			If lOk
				MsgStop( "Atualiza็ใo Realizada.", "COMPA0003" )
				dbCloseAll()
			Else
				MsgStop( "Atualiza็ใo nใo Realizada.", "" )
				dbCloseAll()
			EndIf
		Else
			If lOk
				Final( "Atualiza็ใo Concluํda." )
			Else
				Final( "Atualiza็ใo nใo Realizada." )
			EndIf
		EndIf

		Else
			MsgStop( "Atualiza็ใo nใo Realizada.", "COMPA0003" )

		EndIf

	Else
		MsgStop( "Atualiza็ใo nใo Realizada.", "COMPA0003" )

	EndIf

EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSTProc  บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da grava็ใo dos arquivos           ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSTProc    - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSTProc( lEnd, aMarcadas )
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
		// So adiciona no aRecnoSM0 se a empresa for diferente
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
				MsgStop( "Atualiza็ใo da empresa " + aRecnoSM0[nI][2] + " nใo efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX2         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oProcess:IncRegua1( "Dicionแrio de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX2( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SIX         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oProcess:IncRegua1( "Dicionแrio de ํndices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSIX( @cTexto )   
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX3         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FSAtuSX3( @cTexto )
			oProcess:IncRegua1( "Dicionแrio de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/ํndices" )

			// Altera็ใo fํsica dos arquivos

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
   			       cEmp2 := CheckSX2(aArqUpd[nX])
                   If SM0->M0_CODIGO = cEmp2
  				      X31UpdTable( aArqUpd[nX] )
				      If __GetX31Error() 
				         cErro1 := __GetX31Trace()  
                         If AT("Nใo foi necessแrio alterar a estrutura da tabela",cErro1) = 0 
                            MsgStop( "Ocorreu um erro na atualiza็ใo do Banco tabela : " + ;
					                 aArqUpd[nX] + ". Verifique as Permiss๕es no Banco. ", "ATENวรO" )
					        AutoGrLog( "Ocorreu um erro desconhecido durante a atualiza็ใo da estrutura da tabela : " + aArqUpd[nX] )
				         EndIf
				         /*If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					        TcInternal( 25, "OFF" )
				         EndIf*/
                      Endif
                   Endif
 			Next nX

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza os helps                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuHlp( @cTexto )  

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZACAO DOS DICIONมRIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente" + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usuario da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " Estacao............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conexao............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

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


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX2 บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX2 - Arquivos      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX2   - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/* Chamada da Fun็ใo comentada, nใo estแ sendo utilizada - Thais Paiva - Compatibiliza็ใo P27
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SX2" + CRLF + CRLF

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODULO" }

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			cTexto += "Foi incluํda a tabela " + aSX2[nI][1] + CRLF
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + "01" +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
  
	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				cTexto += "Foi alterada chave unica da tabela " + aSX2[nI][1] + CRLF
			Else
				cTexto += "Foi criada   chave unica da tabela " + aSX2[nI][1] + CRLF
			EndIf
		EndIf

	EndIf 
	
Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX3 บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX3 - Campos        ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX3   - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
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
Local nSeqAtu   := 0
//Local nTamSeek  := Len( SX3->X3_CAMPO ) Thais Paiva - Compatibiliza็ใo P27
Local _aCpoX3	:= {} //Thais Paiva - Compatibiliza็ใo P27

cTexto  += "Inicio da Atualizacao" + " SX3" + CRLF + CRLF

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// Tabela SRA
//
If !AcheiSX3("SRA","RA_XOBJDET")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XOBJDET")
Endif

aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XOBJDET'														,.T.}, ; //X3_CAMPO
	{'C'																	,.T.}, ; //X3_TIPO
	{254																	,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'Obj.Contrato'														,.T.}, ; //X3_TITULO
	{'Obj.Contrato'														,.T.}, ; //X3_TITSPA
	{'Obj.Contrato'														,.T.}, ; //X3_TITENG
	{'Objeto da Contratacao'											,.T.}, ; //X3_DESCRIC
	{'Objeto da Contratacao'											,.T.}, ; //X3_DESCSPA
	{'Objeto da Contratacao'											        ,.T.}, ; //X3_DESCENG
	{''																		,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)												,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																	,.T.}, ; //X3_PROPRI
	{'S'																	,.T.}, ; //X3_BROWSE
	{'A'																	,.T.}, ; //X3_VISUAL
	{'R'																	,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{''																		,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																	,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XCPFANT")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XCPFANT")
Endif

aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XCPFANT'															,.T.}, ; //X3_CAMPO
	{'C'																		,.T.}, ; //X3_TIPO
	{11																		,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'CPF Anterior'															,.T.}, ; //X3_TITULO
	{'CPF Anterior'															,.T.}, ; //X3_TITSPA
	{'CPF Anterior'															,.T.}, ; //X3_TITENG
	{'CPF Anterior'															,.T.}, ; //X3_DESCRIC
	{'CPF Anterior'															,.T.}, ; //X3_DESCSPA
	{'CPF Anterior'															,.T.}, ; //X3_DESCENG
	{'@R 999.999.999-99'													,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)														,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																		,.T.}, ; //X3_PROPRI
	{'S'																		,.T.}, ; //X3_BROWSE
	{'A'																		,.T.}, ; //X3_VISUAL
	{'R'																		,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{'If(Empty(M->RA_XCPFANT),.T.,ChkCPF(M->RA_XCPFANT))'					,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																		,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XMATANT")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XMATANT")
Endif
	
aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XMATANT'															,.T.}, ; //X3_CAMPO
	{'C'																		,.T.}, ; //X3_TIPO
	{30																		,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'Mat.Anterior'															,.T.}, ; //X3_TITULO
	{'Mat.Anterior'															,.T.}, ; //X3_TITSPA
	{'Mat.Anterior'															,.T.}, ; //X3_TITENG
	{'Matricula anterior'													,.T.}, ; //X3_DESCRIC
	{'Matricula anterior'													,.T.}, ; //X3_DESCSPA
	{'Matricula anterior'													,.T.}, ; //X3_DESCENG
	{''																		,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)														,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																		,.T.}, ; //X3_PROPRI
	{'S'																		,.T.}, ; //X3_BROWSE
	{'A'																		,.T.}, ; //X3_VISUAL
	{'R'																		,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{''																		,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																		,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XDALCPF")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XDALCPF")
Endif
	
aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XDALCPF'															,.T.}, ; //X3_CAMPO
	{'D'																		,.T.}, ; //X3_TIPO
	{8																		,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'Dt. Alt. CPF'															,.T.}, ; //X3_TITULO
	{'Dt. Alt. CPF'															,.T.}, ; //X3_TITSPA
	{'Dt. Alt. CPF'															,.T.}, ; //X3_TITENG
	{'Data de alteracao do CPF'												,.T.}, ; //X3_DESCRIC
	{'Data de alteracao do CPF'												,.T.}, ; //X3_DESCSPA
	{'Data de alteracao do CPF'												,.T.}, ; //X3_DESCENG
	{''																		,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)														,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																		,.T.}, ; //X3_PROPRI
	{'S'																		,.T.}, ; //X3_BROWSE
	{'A'																		,.T.}, ; //X3_VISUAL
	{'R'																		,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{''																		,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																		,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XOALCPF")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XOALCPF")
Endif

aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XOALCPF'															,.T.}, ; //X3_CAMPO
	{'C'																		,.T.}, ; //X3_TIPO
	{254																		,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'Obs. Alt.CPF'															,.T.}, ; //X3_TITULO
	{'Obs. Alt.CPF'															,.T.}, ; //X3_TITSPA
	{'Obs. Alt.CPF'															,.T.}, ; //X3_TITENG
	{'Observacao Alteracao CPF'												,.T.}, ; //X3_DESCRIC
	{'Observacao Alteracao CPF'												,.T.}, ; //X3_DESCSPA
	{'Observacao Alteracao CPF'												,.T.}, ; //X3_DESCENG
	{''																		,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)														,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																		,.T.}, ; //X3_PROPRI
	{'S'																		,.T.}, ; //X3_BROWSE
	{'A'																		,.T.}, ; //X3_VISUAL
	{'R'																		,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{''																		,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																		,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XNEWCIC")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XNEWCIC")
Endif

aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XNEWCIC'															,.T.}, ; //X3_CAMPO
	{'C'																		,.T.}, ; //X3_TIPO
	{11																		,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'Novo CPF'																,.T.}, ; //X3_TITULO
	{'Novo CPF'																,.T.}, ; //X3_TITSPA
	{'Novo CPF'																,.T.}, ; //X3_TITENG
	{'Novo CPF'																,.T.}, ; //X3_DESCRIC
	{'Novo CPF'																,.T.}, ; //X3_DESCSPA
	{'Novo CPF'																,.T.}, ; //X3_DESCENG
	{'@R 999.999.999-99'													,.T.}, ; //X3_PICTURE
	{'IIF(!EMPTY(M->RA_XNEWCIC) .AND.M->RA_XNEWCIC = M->RA_XCPFANT, (MSGALERT("Novo CPF igual ao CPF anterior!"),.F.),.T.)' ,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)														,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																		,.T.}, ; //X3_PROPRI
	{'S'																		,.T.}, ; //X3_BROWSE
	{'A'																		,.T.}, ; //X3_VISUAL
	{'R'																		,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{'If(Empty(M->RA_XNEWCIC),.T.,ChkCPF(M->RA_XNEWCIC))'					,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																		,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XPALIM")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XPALIM")
Endif

aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XPALIM'															,.T.}, ; //X3_CAMPO
	{'C'																	,.T.}, ; //X3_TIPO
	{1																		,.T.}, ; //X3_TAMANHO
	{0																		,.T.}, ; //X3_DECIMAL
	{'Pensao FGTS'														,.T.}, ; //X3_TITULO
	{'Pensao FGTS'														,.T.}, ; //X3_TITSPA
	{'Pensao FGTS'														,.T.}, ; //X3_TITENG
	{'Pensao Alimenticia FGTS'										,.T.}, ; //X3_DESCRIC
	{'Pensao Alimenticia FGTS'										,.T.}, ; //X3_DESCSPA
	{'Pensao Alimenticia FGTS'										,.T.}, ; //X3_DESCENG
	{'@E 9'																,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)												,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																	,.T.}, ; //X3_PROPRI
	{'S'																	,.T.}, ; //X3_BROWSE
	{'A'																	,.T.}, ; //X3_VISUAL
	{'R'																	,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{''																		,.T.}, ; //X3_VLDUSER
	{'0=Nao existe;1=Percentual;2=Valor;3=Percentual e Valor',.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																	,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

If !AcheiSX3("SRA","RA_XVRALIM")
   cOrd1 := UltimoSX3("SRA") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := QualOrdemSX3("SRA","RA_XVRALIM")
Endif

aAdd( aSX3, { ;
	{'SRA'																	,.T.}, ; //X3_ARQUIVO
	{cOrd1																	,.T.}, ; //X3_ORDEM
	{'RA_XVRALIM'														,.T.}, ; //X3_CAMPO
	{'N'																	,.T.}, ; //X3_TIPO
	{14																		,.T.}, ; //X3_TAMANHO
	{2																		,.T.}, ; //X3_DECIMAL
	{'Val Pensao Ali'														,.T.}, ; //X3_TITULO
	{'Val Pensao Ali'														,.T.}, ; //X3_TITSPA
	{'Val Pensao Ali'														,.T.}, ; //X3_TITENG
	{'Valor Pensao Alimenticia'											,.T.}, ; //X3_DESCRIC
	{'Valor Pensao Alimenticia'											,.T.}, ; //X3_DESCSPA
	{'Valor Pensao Alimenticia'											,.T.}, ; //X3_DESCENG
	{'@E 99999999999.99'															,.T.}, ; //X3_PICTURE
	{''																		,.T.}, ; //X3_VALID
	{Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)	,.T.}, ; //X3_USADO
	{''																		,.T.}, ; //X3_RELACAO
	{''																		,.T.}, ; //X3_F3
	{0																		,.T.}, ; //X3_NIVEL
	{Chr(254) + Chr(192)												,.T.}, ; //X3_RESERV
	{''																		,.T.}, ; //X3_CHECK
	{''																		,.T.}, ; //X3_TRIGGER
	{'U'																	,.T.}, ; //X3_PROPRI
	{'S'																	,.T.}, ; //X3_BROWSE
	{'A'																	,.T.}, ; //X3_VISUAL
	{'R'																	,.T.}, ; //X3_CONTEXT
	{''																		,.T.}, ; //X3_OBRIGAT
	{''																		,.T.}, ; //X3_VLDUSER
	{''																		,.T.}, ; //X3_CBOX
	{''																		,.T.}, ; //X3_CBOXSPA
	{''																		,.T.}, ; //X3_CBOXENG
	{''																		,.T.}, ; //X3_PICTVAR
	{''																		,.T.}, ; //X3_WHEN
	{''																		,.T.}, ; //X3_INIBRW
	{''																		,.T.}, ; //X3_GRPSXG
	{''																	,.T.}, ; //X3_FOLDER
	{''	,.T.}																	, ; //X3_CONDSQL
	{''	,.T.}																	, ; //X3_CHKSQL
	{''	,.T.}																	, ; //X3_IDXSRV
	{''	,.T.}																	, ; //X3_ORTOGRA
	{''	,.T.}																	, ; //X3_TELA
	{''	,.T.}																	, ; //X3_POSLGT
	{''	,.T.}																	, ; //X3_IDXFLD
	{''	,.T.}																	, ; //X3_AGRUP
	{''	,.T.}																	, ; //X3_MODAL
	{''	,.T.}																	} ) //X3_PYME

//
// Atualizando dicionแrio
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

//aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG][1] )
		//Inํcio - Thais Paiva - COmpatibiliza็ใo P27
		OpenSxs(,,,,cEmpAnt,"SXGTAB","SXG",,.F.)
		//SXG->( dbSetOrder( 1 ) )
		//If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
		If Select("SXGTAB") > 0
			While SXGTAB->(!EOF())
				If SXGTAB->(FildPos(aSX3[nI][nPosSXG][1])) > 0
					If aSX3[nI][nPosTam][1] <> SXGTAB->&("XG_SIZE")//SXG->XG_SIZE
						aSX3[nI][nPosTam][1] := SXGTAB->&("XG_SIZE")//SXG->XG_SIZE
						AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NรO atualizado e foi mantido em [" + ;
						AllTrim( Str( SXGTAB->&("XG_SIZE") ) ) + "]" + CRLF + ;
						" por pertencer ao grupo de campos [" + SXGTAB->&("XG_GRUPO") + "]" + CRLF )
						//AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
						//" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
					EndIf
				EndIf
				SXGTAB->(DbSkip())
			EndDo
		EndIf
		//Fim - Thais Paiva - COmpatibiliza็ใo P27
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq][1] $ cAlias )
		cAlias += aSX3[nI][nPosArq][1] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
	EndIf
	
	//Inํcio - Thais Paiva - COmpatibiliza็ใo P27	
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
				cSeqAtu := GetSx3Cache(_aCpoX3[_nx3], 'X3_ORDEM')//SX3->X3_ORDEM
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
			OpenSxs(,,,,cEmpAnt,"SXG2TB","SXG",,.F.)
			If Select("SXG2TB") > 0
				While SXG2TB->(!EOF())
					If SXG2TB->(FildPos(aSX3[nI][nPosSXG][1])) > 0
			//If SXG->( MSSeek( SX3->X3_GRPSXG ) )
						If aSX3[nI][nPosTam][1] <> SXG2TB->&("XG_SIZE") //SXG->XG_SIZE
							aSX3[nI][nPosTam][1] := SXG2TB->&("XG_SIZE") //SXG->XG_SIZE
							AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NรO atualizado e foi mantido em [" + ;
							AllTrim( Str( SXG2TB->&("XG_SIZE") ) ) + "]"+ CRLF + ;
							"   por pertencer ao grupo de campos [" + GetSx3Cache(aSX3[nI][nPosCpo][1], 'X3_GRPSXG') + "]" + CRLF )
							//AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
							//"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
						EndIf
					EndIf
					SXG2TB->(DbSkip())
				EndDo
			EndIf
		EndIf
		//Fim - Thais Paiva - COmpatibiliza็ใo P27
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

					cMsg := "O campo " + aSX3[nI][nPosCpo][1] + " estแ com o " + cX3Campo + ;
					" com o conte๚do" + CRLF + ;
					"[" + RTrim( AllToChar( cX3Dado ) ) + "]" + CRLF + ;
					"que serแ substituํdo pelo NOVO conte๚do" + CRLF + ;
					"[" + RTrim( AllToChar( aSX3[nI][nJ][1] ) ) + "]" + CRLF + ;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAวรO DE DICIONมRIOS E TABELAS", cMsg, { "Sim", "Nใo", "Sim p/Todos", "Nใo p/Todos" }, 3, "Diferen็a de conte๚do - SX3" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a op็ใo de REALIZAR TODAS altera็๕es no SX3 e NรO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a a็ใo [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a op็ใo de NรO REALIZAR nenhuma altera็ใo no SX3 que esteja diferente da base e NรO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta a็ใo [Nใo p/Todos]?" )
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

cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSIX บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SIX - Indices       ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSIX   - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SIX" + CRLF + CRLF

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		cTexto += "อndice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			cTexto += "Chave do ํndice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
			lDelInd := .T. // Se for alteracao precisa apagar o indice do banco
		Else
			cTexto += "Indice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	/*If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf*/

	oProcess:IncRegua2( "Atualizando ํndices..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuHlp บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao dos Helps de Campos    ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuHlp   - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuHlp( cTexto )
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

cTexto  += "Inicio da Atualizacao" + " " + "Helps de Campos" + CRLF + CRLF


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SRA
//

cTexto += CRLF + "Final da Atualizacao" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return {}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณESCEMPRESAบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Generica para escolha de Empresa, montado pelo SM0_ บฑฑ
ฑฑบ          ณ Retorna vetor contendo as selecoes feitas.                 บฑฑ
ฑฑบ          ณ Se nao For marcada nenhuma o vetor volta vazio.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EscEmpresa()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametro  nTipo                           ณ
//ณ 1  - Monta com Todas Empresas/Filiais      ณ
//ณ 2  - Monta so com Empresas                 ณ
//ณ 3  - Monta so com Filiais de uma Empresa   ณ
//ณ                                            ณ
//ณ Parametro  aMarcadas                       ณ
//ณ Vetor com Empresas/Filiais pre marcadas    ณ
//ณ                                            ณ
//ณ Parametro  cEmpSel                         ณ
//ณ Empresa que sera usada para montar selecao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}

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

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := "Tela para M๚ltiplas Sele็๕es de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualiza็ใo"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Sele็ใo" Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Mแscara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando mแscara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando mแscara ( ?? )" Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Sele็ใo"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Sele็ใo" Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณMARCATODOSบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar para marcar/desmarcar todos os itens do    บฑฑ
ฑฑบ          ณ ListBox ativo                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณINVSELECAOบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar para inverter selecao do ListBox Ativo     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณRETSELECAOบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar que monta o retorno com as selecoes        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ MARCAMAS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para marcar/desmarcar usando mascaras               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ VERTODOS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar para verificar se estao todos marcardos    บฑฑ
ฑฑบ          ณ ou nao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ MyOpenSM0บ Autor ณ TOTVS Protheus     บ Data ณ  28/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento abertura do SM0 modo exclusivo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.6 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
 //	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
 
	//dbUseArea( .T., , "SIGAMAT.EMP", "SM0", .T., .T. )     //Alterado Thais Paiva - Compatibiliza็ใo P27
	OpenSm0(cEmpAnt, .T.)
	
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Nใo foi possํvel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENวรO" )
EndIf

Return lOpen

****************************
STATIC Function CheckSX2(cArq)
****************************
Local aArea := GetArea()
Local cEmp1 := ''
Local _aCpoX2 := {} //Thais Paiva - Compatibiliza็ใo P27

//Inํcio - Thais Paiva - Compatibiliza็ใo P27
//dbSelectArea("SX2")
//dbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX2->X2_CHAVE == cArq
      cEmp1 := Substr(FWSX2Util():GetFile(cArq),4,2)//Substr(SX2->X2_ARQUIVO,4,2)
      //DbSkip()
//End     
//Fim - Thais Paiva - Compatibiliza็ใo P27              
Return cEmp1

Static Function UltimoSX3(cArq)
Local cOrdem  := ""
//Inํcio - Thais Paiva - Compatibiliza็ใo P27
Local _aCpoX3 := FWSX3Util():GetAllFields( cArq , .F. )
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX3->X3_ARQUIVO == cArq
If Len(_aCpoX3) > 0
	For _nX3 := 1 to Len(_aCpoX3)
		cOrdem := GetSx3Cache(_aCpoX3[_nx3], 'X3_ORDEM')//SX3->X3_ORDEM
     //DbSkip()
	Next _nX3
EndIf
//Fim - Thais Paiva - Compatibiliza็ใo P27              
Return cOrdem

Static Function AcheiSX3(cArq,cCampo)
Local lAchei := .F.
//Inํcio - Thais Paiva - Compatibiliza็ใo P27
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
//Fim - Thais Paiva - Compatibiliza็ใo P27           
Return lAchei

Static Function QualOrdemSX3(cArq,cCampo)
Local lAchei := "  "
//Inํcio - Thais Paiva - Compatibiliza็ใo P27
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek(cArq)
//While !Eof() .and. SX3->X3_ARQUIVO == cArq
//     If ALLTRIM(SX3->X3_CAMPO) == ALLTRIM(cCampo)
        lAchei := GetSx3Cache(cCampo, 'X3_ORDEM') //ALLTRIM(SX3->X3_ORDEM)
//     Endif
//     DbSkip()
//End      
//Fim - Thais Paiva - Compatibiliza็ใo P27                
Return lAchei


/////////////////////////////////////////////////////////////////////////////
