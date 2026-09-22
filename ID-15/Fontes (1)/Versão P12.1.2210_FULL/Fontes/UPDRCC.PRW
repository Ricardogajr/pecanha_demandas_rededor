#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"
#INCLUDE "FILEIO.CH"

#DEFINE SX3_USADO "€€€€€€€€€€€€€€ "
#DEFINE SX3_OBRIGAT "€"                

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

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
/*/{Protheus.doc} UPDRCC
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  06/09/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDRCC( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cF3new    := ""
Local   cF3newb   := ""
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
					MsgStop( "Atualização Realizada.", "UPDRCC" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDRCC" )
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
			// Atualiza o Tabela RCC
			//------------------------------------
            FSAtuRCC()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()
			
			
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
   		 	           cEmp2 := U_ChckSX2(aArqUpd[nX])
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
	//dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. ) Thais Paiva - COmpatibilização P27
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


**************************
Static Function FSAtuRCC()
**************************
   Local aArea    := GetArea()
   Local aRet     := {}
   Local cCodFil  := xFilial("RCC")
   Local lExc     := !Empty(cCodFil)
   Local aFiliais := If(!lExc,{xFilial("RCC")},FWAllFilial())
   Local nFiliais := Len(aFiliais)
   Local nX       := 0
   Local aRCC     := {}
   Local lExist   := .T.
   Local nPosFil  := 0
   Local nPosCod  := 0
   Local nPosFi   := 0
   Local nPosChv  := 0
   Local nPosSeq  := 0
   Local nPosCon  := 0

   Local nField   := 0
   Local cTabTmp  := ""
   Local cTabNew  := ""
   Local bMsgEmp  := {|| If(lExc,StrTran(' Empresa: "%s1".','%s1',cEmpAnt+"/"+cCodFil),StrTran(' Empresa: "%s1".','%s1',cEmpAnt))}
   Local aSx5Tmp  := {}     
   
   dbSelectArea('RCC')
   RCC->(dbSetOrder(1))
   RCC->(dbGotop())                      
   Do While !EOF() 
      If RCC->RCC_CODIGO='S047' .OR. ;
         RCC->RCC_CODIGO='S049' .OR. ;
         RCC->RCC_CODIGO='S054' .OR. ;
         RCC->RCC_CODIGO='S056' 
         RecLock("RCC",.F.)
         RCC->(dbDelete())
         MsUnlock()
      Endif
      RCC->(dbSkip())
   End

   dbSelectArea('RCC')
   RCC->(dbSetOrder(1))                      
   RCC->(dbGotop())                      

   // TABELA 01 ESOCIAL CATEGORIAS DO TRABALHADOR
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','001'},{'RCC_CONTEU','10101EMPREGADO-GERAL, INCLUSIVE EMPREGADO P+BLICO DE ADMINISTR DIRETA OU INDIRETA CONTRATADO PELA CLT'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','002'},{'RCC_CONTEU','102  EMPREGADO-TRABALHADOR RURAL POR PEQUENO PRAZO DA LEI 11.718/2008'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','003'},{'RCC_CONTEU','10307EMPREGADO-APRENDIZ'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','004'},{'RCC_CONTEU','10406EMPREGADO-DOMESTICO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','005'},{'RCC_CONTEU','10504EMPREGADO-CONTRATO A TERMO FIRMADO NOS TERMOS DA LEI 9601/98'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','006'},{'RCC_CONTEU','106  TRABALHADOR TEMPORARIO - CONTRATO NOS TERMOS DA LEI 6.019/74'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','007'},{'RCC_CONTEU','20102TRABALHADOR AVULSO-PORTUARIO																	'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','008'},{'RCC_CONTEU','20202TRABALHADOR AVULSO-NAO PORTUARIO (INFORMACAO DO SINDICATO)									'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','009'},{'RCC_CONTEU','30121SERVIDOR PUBLICO-TITULAR DE CARGO EFETIVO													'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','010'},{'RCC_CONTEU','30220SERVIDOR PUBLICO-OCUPANTE DE CARGO EXCLUSIVO EM COMISSAO										'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','011'},{'RCC_CONTEU','30319AGENTE POLITICO                               											'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','012'},{'RCC_CONTEU','305  SERVIDOR PUBLICO VINC RPPS IND P/ CONS OU ORG REPRESENTATIVO, REPRES GOV, ORGAO OU ENT ADM PUB.'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','013'},{'RCC_CONTEU','306  SERVIDOR PUBLICO - CONTRATO TEMPORARIO														'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','014'},{'RCC_CONTEU','30912SERVIDOR PUBLICO-AGENTE PUBLICO															'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','015'},{'RCC_CONTEU','40126DIRIGENTE SINDICAL-EM RELACAO A REMUNERACAO RECEBIDA NO SINDICATO							'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','016'},{'RCC_CONTEU','410  TRABALHADRO CEDIDO - INFORMACAO PRESTADA PELO CONCESSIONARIO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','017'},{'RCC_CONTEU','701  CI AUTONOMO EM GERAL, EXCETO SE ENQUADRADO EM UMA DAS DEMAIS CATEGORIAS DE CI'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','018'},{'RCC_CONTEU','71115CI-TRANSPORTADOR AUTONOMO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','019'},{'RCC_CONTEU','72105CI-DIRETOR NAO EMPREGADO COM FGTS'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','020'},{'RCC_CONTEU','72211CI-DIRETOR NAO EMPREGADO SEM FGTS'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','021'},{'RCC_CONTEU','723  CONTRIBUINTE INDIVIDUAL - EMPRES-RIOS, SËCIOS E MEMBRO DE CONSELHO DE ADMINISTRACAO OU FISCAL'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','022'},{'RCC_CONTEU','73117CI-COOPERADO QUE PRESTA SERVICOS A EMPRESA POR INTERMEDIO DE COOPERATIVA DE TRABALHO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','023'},{'RCC_CONTEU','73418CI-TRANSPORTADOR COOPERADO QUE PRESTA SERVICOS A EMPRESA POR INTERMEDIO DE COOPERATIVA TRABALHO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','024'},{'RCC_CONTEU','738  CI-COOPERADO FILIADO A COOPERATIVA DE PRODUTO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','025'},{'RCC_CONTEU','74113CI-MICRO EMPREENDEDOR INDIVIDUAL, QUANDO CONTRATADO POR PJ'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','026'},{'RCC_CONTEU','751  CI-APOS. QQ REGIME PREV, NOM. MAGOSTRADO CLASS. TEMP. JUST. TRAB OU NOMEADO JUSTICA ELEITORAL'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','027'},{'RCC_CONTEU','761  CI-ASSOCIADO ELEITO PARA DIR. DE COOP.. ASSOC ENT. CLASSE DE QQ NATUREZA OU FINALIDADE...'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','028'},{'RCC_CONTEU','771  CI-MEMBRO DO CONSELHO TUTELAR, NOS TERMOS DA LEI N 8,069 DE 13/07/1990'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','029'},{'RCC_CONTEU','781  MINISTRO DE CONFISSAO RELIGIOSA OU MEMBRO DE VIDA CONSAGRADA, DE CONGR. OU DE ORDEM RELIGIOSA'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','030'},{'RCC_CONTEU','901  ESTAGIARIO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S049'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','031'},{'RCC_CONTEU','902  MEDICO RESIDENTE'}})

   // TABELA 03 ESOCIAL NATUREZA DE RUBRICAS
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','001'},{'RCC_CONTEU','1000Salário, vencimento, soldo ou subsídio.'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','002'},{'RCC_CONTEU','1002Descanso semanal remunerado - DSR'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','003'},{'RCC_CONTEU','1003Horas extraordinárias'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','004'},{'RCC_CONTEU','1004Horas extraordinárias – Indenização de banco de horas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','005'},{'RCC_CONTEU','1005Direito de arena'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','006'},{'RCC_CONTEU','1007Luvas e premiações'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','007'},{'RCC_CONTEU','1009Salário-família – complemento'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','008'},{'RCC_CONTEU','1010Salário in natura - pagos em bens ou serviços'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','009'},{'RCC_CONTEU','1011Sobreaviso'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','010'},{'RCC_CONTEU','1020Férias'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','011'},{'RCC_CONTEU','1021Férias - abono ou gratificação de férias superior a 20 dias'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','012'},{'RCC_CONTEU','1022Férias - abono ou gratificação de férias não excedente a 20 dias'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','013'},{'RCC_CONTEU','1023Férias - abono pecuniário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','014'},{'RCC_CONTEU','1024Férias - o dobro na vigência do contrato'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','015'},{'RCC_CONTEU','1040Licença-prêmio'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','016'},{'RCC_CONTEU','1041Licença-prêmio indenizada'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','017'},{'RCC_CONTEU','1099Outras verbas salariais'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','018'},{'RCC_CONTEU','1201Adicional de função / cargo confiança'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','019'},{'RCC_CONTEU','1202Adicional de insalubridade'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','020'},{'RCC_CONTEU','1203Adicional de periculosidade'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','021'},{'RCC_CONTEU','1204Adicional de transferência'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','022'},{'RCC_CONTEU','1205Adicional noturno'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','023'},{'RCC_CONTEU','1206Adicional por tempo de serviço'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','024'},{'RCC_CONTEU','1207Comissões, porcentagens, produção'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','025'},{'RCC_CONTEU','1208Gueltas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','026'},{'RCC_CONTEU','1209Gorjetas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','027'},{'RCC_CONTEU','1210Gratificação por acordo ou convenção coletiva'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','028'},{'RCC_CONTEU','1211Gratificações'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','029'},{'RCC_CONTEU','1213Quebra de caixa'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','030'},{'RCC_CONTEU','1215Adicional de Unidocência'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','031'},{'RCC_CONTEU','1230Remuneração do dirigente sindical'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','032'},{'RCC_CONTEU','1299Outros Adicionais'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','033'},{'RCC_CONTEU','1300PLR - Participação em Lucros ou Resultados'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','034'},{'RCC_CONTEU','1350Bolsa de estudo - estagiário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','035'},{'RCC_CONTEU','1351Bolsa de estudo - médico residente'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','036'},{'RCC_CONTEU','1352Bolsa de estudo ou pesquisa'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','037'},{'RCC_CONTEU','1401Abono'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','038'},{'RCC_CONTEU','1402Abono PIS / PASEP'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','039'},{'RCC_CONTEU','1403Abono legal'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','040'},{'RCC_CONTEU','1404Auxílio babá'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','041'},{'RCC_CONTEU','1405Assistência médica'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','042'},{'RCC_CONTEU','1406Auxílio-creche'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','043'},{'RCC_CONTEU','1407Auxílio-educação'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','044'},{'RCC_CONTEU','1409Salário-família'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','045'},{'RCC_CONTEU','1410Auxílio – Locais de difícil acesso'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','046'},{'RCC_CONTEU','1601Ajuda de custo - aeronauta'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','047'},{'RCC_CONTEU','1602Ajuda de custo de transferência'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','048'},{'RCC_CONTEU','1603Ajuda de custo - até 50% da remuneração mensal'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','049'},{'RCC_CONTEU','1604Ajuda de custo - acima de 50% da remuneração mensal'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','050'},{'RCC_CONTEU','1620Ressarcimento de despesas pelo uso de veículo do empregado'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','051'},{'RCC_CONTEU','1621Ressarcimento de despesas de viagem, exceto despesas com veículos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','052'},{'RCC_CONTEU','1629Ressarcimento de outras despesas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','053'},{'RCC_CONTEU','1650Diarias de viagem'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','054'},{'RCC_CONTEU','1651Diárias de viagem – até 50% do salário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','055'},{'RCC_CONTEU','1652Diárias de viagem – acima de 50% do salário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','056'},{'RCC_CONTEU','1801Alimentação'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','057'},{'RCC_CONTEU','1802Etapas (marítimos)'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','058'},{'RCC_CONTEU','1805Moradia'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','059'},{'RCC_CONTEU','1810Transporte'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','060'},{'RCC_CONTEU','2501Prêmios'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','061'},{'RCC_CONTEU','2502Liberalidades concedidas em mais de duas parcelas anuais'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','062'},{'RCC_CONTEU','2510Direitos Autorais e Intelectuais'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','063'},{'RCC_CONTEU','2901Empréstimos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','064'},{'RCC_CONTEU','2902Vestuário e equipamentos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','065'},{'RCC_CONTEU','2920Reembolsos diversos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','066'},{'RCC_CONTEU','2930Insuficiência de saldo'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','067'},{'RCC_CONTEU','3501Prestação de serviços – Transportador Autônomo'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','068'},{'RCC_CONTEU','3505Retiradas (pró-labore) de diretores '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','069'},{'RCC_CONTEU','3506Retiradas (pró-labore) de diretores não empregados'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','070'},{'RCC_CONTEU','3508Retiradas (pró-labore) de proprietários ou sócios'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','071'},{'RCC_CONTEU','3509Honorários a conselheiros'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','072'},{'RCC_CONTEU','3520Remuneração de cooperado'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','073'},{'RCC_CONTEU','3525Congruas, prebendas e afins'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','074'},{'RCC_CONTEU','4010Complementação salarial de auxílio-doença'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','075'},{'RCC_CONTEU','4050Salário maternidade'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','076'},{'RCC_CONTEU','4051Salário maternidade – 13° salário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','077'},{'RCC_CONTEU','500113º salário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','078'},{'RCC_CONTEU','500513° salário complementar'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','079'},{'RCC_CONTEU','5501Adiantamento de salário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','080'},{'RCC_CONTEU','550413º salário - 1ª parcela'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','081'},{'RCC_CONTEU','5510Adiantamento de benefícios previdenciários'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','082'},{'RCC_CONTEU','6000Saldo de salários na rescisão contratual'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','083'},{'RCC_CONTEU','600113º salário relativo ao aviso-prévio indenizado'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','084'},{'RCC_CONTEU','600213° salário proporcional na rescisão'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','085'},{'RCC_CONTEU','6003Indenização compensatória do aviso-prévio'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','086'},{'RCC_CONTEU','6004Férias - o dobro na rescisão'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','087'},{'RCC_CONTEU','6006Férias proporcionais'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','088'},{'RCC_CONTEU','6007Férias vencidas na rescisão'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','089'},{'RCC_CONTEU','6101Indenização compensatória - multa rescisória 20 ou 40% (CF/88)'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','090'},{'RCC_CONTEU','6102Indenização do art. 9º lei nº 7.238/84'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','091'},{'RCC_CONTEU','6103Indenização do art. 14 da lei nº 5.889, de 8 de junho de 1973'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','092'},{'RCC_CONTEU','6104Indenização do art. 479 da CLT'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','093'},{'RCC_CONTEU','6105Indenização recebida a título de incentivo a demissão.'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','094'},{'RCC_CONTEU','6106Multa do art. 477 da CLT.'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','095'},{'RCC_CONTEU','6107Indenização por quebra de estabilidade'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','096'},{'RCC_CONTEU','6129Outras Indenizações'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','097'},{'RCC_CONTEU','6901Insuficiência de saldo'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','098'},{'RCC_CONTEU','6904Multa prevista no art. 480 da CLT'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','099'},{'RCC_CONTEU','7001Proventos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','100'},{'RCC_CONTEU','9200Desconto de Adiantamentos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','101'},{'RCC_CONTEU','9201Contribuição Previdenciária mensal'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','102'},{'RCC_CONTEU','9203Imposto de renda mensal'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','103'},{'RCC_CONTEU','9205Imposto de renda sobre 13° salário'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','104'},{'RCC_CONTEU','9208Atrasos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','105'},{'RCC_CONTEU','9209Faltas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','106'},{'RCC_CONTEU','9210DSR s/faltas e atrasos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','107'},{'RCC_CONTEU','9211Faltas e atrasos - estagiários'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','108'},{'RCC_CONTEU','9213Pensão alimentícia'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','109'},{'RCC_CONTEU','921413° salário – desconto da primeira parcela'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','110'},{'RCC_CONTEU','9216Desconto de vale-transporte'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','111'},{'RCC_CONTEU','9217Contribuição a Outras Entidades e Fundos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','112'},{'RCC_CONTEU','9218Retenções judiciais'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','113'},{'RCC_CONTEU','9219Desconto de assistência médica ou odontológica'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','114'},{'RCC_CONTEU','9220Alimentação – desconto'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','115'},{'RCC_CONTEU','9221Desconto de férias'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','116'},{'RCC_CONTEU','9222Desconto de outros impostos e contribuições'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','117'},{'RCC_CONTEU','9223Previdência complementar – parte do empregado'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','118'},{'RCC_CONTEU','9224FAPI – parte do empregado'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','119'},{'RCC_CONTEU','9225Funpresp – parte do servidor'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','120'},{'RCC_CONTEU','9230Contribuição Sindical – Compulsória'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','121'},{'RCC_CONTEU','9231Contribuição Sindical – Associativa'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','122'},{'RCC_CONTEU','9232Contribuição Sindical – Assistencial'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','123'},{'RCC_CONTEU','9233Contribuição sindical – Confederativa'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','124'},{'RCC_CONTEU','9250Seguro de vida – desconto'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','125'},{'RCC_CONTEU','9254Empréstimos consignados – desconto'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','126'},{'RCC_CONTEU','9255Empréstimos do empregador – desconto'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','127'},{'RCC_CONTEU','9258Convênios'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','128'},{'RCC_CONTEU','9260FIES - Desconto'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','129'},{'RCC_CONTEU','9270Danos e prejuízos causados pelo trabalhador'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','130'},{'RCC_CONTEU','9290Desconto de pagamento indevido em meses anteriores'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','131'},{'RCC_CONTEU','9299Outros descontos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','132'},{'RCC_CONTEU','9901Base de cálculo da contribuição previdenciária'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','133'},{'RCC_CONTEU','9902Total da base de cálculo do FGTS'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','134'},{'RCC_CONTEU','9903Total da base de cálculo do IRRF'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','135'},{'RCC_CONTEU','9904Total da base de cálculo do FGTS rescisório'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','136'},{'RCC_CONTEU','9905Serviço militar'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','137'},{'RCC_CONTEU','9910Seguros'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','138'},{'RCC_CONTEU','9911Assistência Médica'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','139'},{'RCC_CONTEU','9930Salário maternidade pago pela Previdência Social'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','140'},{'RCC_CONTEU','9931Salário maternidade pago pela Previdência Social'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','141'},{'RCC_CONTEU','9932Auxílio-acidente do trabalho'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','142'},{'RCC_CONTEU','9938Isenção IRRF - 65 anos'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','143'},{'RCC_CONTEU','9939Outros valores tributáveis'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','144'},{'RCC_CONTEU','9950Horas extraordinárias - Banco de horas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','145'},{'RCC_CONTEU','9951Horas compensadas - Banco de horas'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S047'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','146'},{'RCC_CONTEU','9989Outros valores informativos'}})

   // TABELA 19 ESOCIAL MOTIVO DE DESLIGAMENTO
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','001'},{'RCC_CONTEU','101 - RESCISÃO COM JUSTA CAUSA, POR INICIATIVA DO EMPREGADOR'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','002'},{'RCC_CONTEU','202 - RESCISÃO SEM JSUTA CAUSA, POR INICIATIVA DO EMPREGADOR'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','003'},{'RCC_CONTEU','303 - RESCISÃO ANTECIPADA DO CONTRATO A TERMO POR INICIATIVA DO EMPREGADOR 	 								     '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','004'},{'RCC_CONTEU','404 - RESCISÃO ANTECIPADA DO CONTRATO A TERMO POR INICIATIVA DO EMPREGADO 	 								     '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','005'},{'RCC_CONTEU','505 - RESCISÃO POR CULPA RECÍPROCA                	 								                             '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','006'},{'RCC_CONTEU','606 - RESCISÃO POR TÉRMINO DO CONTRATO A TERMO 	 								                                 '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','007'},{'RCC_CONTEU','707 - RESCISÃO DO CONTRATO DE TRABALHO POR INICIATIVA DO EMPREGADO 	 								             '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','008'},{'RCC_CONTEU','808 - RESCISÃO DO CONTRATO DE TRABALHO POR INTERESSE DO(A) EMPREGADO(A), NAS HIPËTESES PREVISTAS NOS ARTIGOS 394 E 483, § 1º E 2º DA CLT	'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','009'},{'RCC_CONTEU','909 - RESCISAO POR FALECIMENTO DO EMPREGADOR INDIVIDUAL OU EMPREGADOR DOMESTICO POR OPCAO DO EMPREGADO 	 								'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','010'},{'RCC_CONTEU','A10 - FALECIMENTO DO EMPREGADO PROVOCADO POR OUTROS MOTIVOS, EXCETO ACIDENTE DE TRABALHO 	 								            '}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','011'},{'RCC_CONTEU','B11 - TRANSFERÊNCIA DE EMPREGADO PARA EMPRESA DO MESMO GRUPO EMPRESARIAL QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS, SEM QUE TENHA HAVIDO RESCISÃO DO CONTRATO DE TRABALHO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','012'},{'RCC_CONTEU','C12 - TRANSFERÊNCIA DE EMPREGADO DA EMPRESA CONSORCIADA PARA O CONSËRCIO QUE TENHA ASSUMIDO OS ENCARGOS TRABALHISTAS, E VICE-VERSA, SEM QUE TENHA HAVIDO RESCISÃO DO CONTRATO DE TRABALHO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','013'},{'RCC_CONTEU','D13 - TRANSF. DE EMPREGADO DE EMPRESA OU CONSËRCIO, PARA OUTRA EMPRESA OU CONSËRCIO QUE TENHA ASSUMIDO OS ENC. TRABALHISTAS POR MOTIVO DE SUCESSÃO (FUSÃO, CISÃO OU INCORPORAÇÃO), SEM RESCISÃO CONT.'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','014'},{'RCC_CONTEU','E14 - RESCISÃO DO CONTRATO DE TRABALHO POR ENCERRAMENTO DA EMPRESA, DE SEUS ESTABELECIMENTOS OU SUPRESSÃO DE PARTE DE SUAS ATIVIDADES OU MORTE DO EMPREGADOR INDIVIDUAL 	'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','015'},{'RCC_CONTEU','F15 - DEMISSÃO DE APRENDIZES POR DESEMPENHO INSUFICIENTE OU INADAPTAÇÃO 	 								       							   									'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','016'},{'RCC_CONTEU','G16 - DECLARAÇÃO DE NULIDADE DO CONTRATO DE TRABALHO POR INFRINGÊNCIA AO INCISO II DO ART. 37 DA CONSTITUIÇÃO FEDERAL, QUANDO MANTIDO O DIREITO AO SALÁRIO	 				'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','017'},{'RCC_CONTEU','H17 - RESCISÃO INDIRETA DO CONTRATO DE TRABALHO, RECONHECIDA PELA JUSTÇA DO TRABALHO 	 								                                			'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','018'},{'RCC_CONTEU','I18 - APOSENTADORIA COMPULSÓRIA (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																							'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','019'},{'RCC_CONTEU','J19 - APOSENTADORIA POR IDADE (SOMENTA PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																							'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','020'},{'RCC_CONTEU','K20 - APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUIÇÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																	'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','021'},{'RCC_CONTEU','L21 - REFORMA MILITAR (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																									'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','022'},{'RCC_CONTEU','M22 - RESERVA MILITAR (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																									'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','023'},{'RCC_CONTEU','N23 - EXONERAÇÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																										'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','024'},{'RCC_CONTEU','O24 - DEMISSÃO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																											'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','025'},{'RCC_CONTEU','P25 - VACANCIA PARA ASSUMIR OUTRO CARGO EFETIVO (SOMENTE PARA CATEGORIAS DE TRABALHADORES 301 A 306) 																			'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','026'},{'RCC_CONTEU','Q26 - RESCISÃO DO CONTRATO DE TRABALHO POR PARALISAÇÃO TEMPORÁRIA OU DEFINITIVA DA EMPRESA, ESTABELECIMENTO OU PARTE DAS ATIVIDADES MOTIVADA POR ATOS DE MUNICIPAL, ESTADUAL OU FEDERAL				'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','027'},{'RCC_CONTEU','R27 - RESCISÃO POR MOTIVO DE FORÇA MAIOR                                                             																			'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','028'},{'RCC_CONTEU','S28 - TERMINO DA CESSAO/REQUISICAO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','029'},{'RCC_CONTEU','T29 - REDISTRIBUICAO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','030'},{'RCC_CONTEU','U30 - MUDANCA DE REGIME TRABALHISTA'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','031'},{'RCC_CONTEU','V31 - REVERSAO DE REINTEGRACAO'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','032'},{'RCC_CONTEU','X32 - EXTRAVIO DE MILITAR'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','033'},{'RCC_CONTEU','Y33 - RESCISAO POR ACORDO ENTRE AS PARTES (ART. 484-A DA CLT)'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','034'},{'RCC_CONTEU','W34 - TRANSFERENCIA DE TITULARIDADE DO EMPREGADO DOMESTICO PARA OUTRO REPRESENTANTE DA MESMA UNIDADE FAMILIAR'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S056'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','035'},{'RCC_CONTEU','Z35 - EXTINÇÃO DO CONTRATO DE TRABALHO INTERMITENTE'}})

   // TABELA 20 ESOCIAL LOGRADOUROS
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','001'},{'RCC_CONTEU','AER AEROPORTO           |AER.|AER |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','002'},{'RCC_CONTEU','AL  ALAMEDA             |AL.|AL |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','003'},{'RCC_CONTEU','A   AREA                |A.|A |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','004'},{'RCC_CONTEU','BAL BALNEARIO           |BAL.|BAL |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','005'},{'RCC_CONTEU','BL  BLOCO               |BL.|BLO |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','006'},{'RCC_CONTEU','AV  AVENIDA             |AV.|AV |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','007'},{'RCC_CONTEU','CPO CAMPO               |CPO.|CPO |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','008'},{'RCC_CONTEU','CH  CHACARA             |CHAC.|CHAC |CH.|CH |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','009'},{'RCC_CONTEU','COL COLONIA             |COL.|COL |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','010'},{'RCC_CONTEU','CONDCONDOMINIO          |COND.|COND |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','011'},{'RCC_CONTEU','CJ  CONJUNTO            |CONJ.|CONJ |CJ.|CJ |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','012'},{'RCC_CONTEU','DT  DISTRITO            |DT.|DT |DISTR.|DISTR |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','013'},{'RCC_CONTEU','ESP ESPLANADA           |ESP.|ESP |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','014'},{'RCC_CONTEU','ETC ESTACAO             |EST.|EST |ETC |ETC.|'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','015'},{'RCC_CONTEU','EST ESTRADA             |ESTR.|ESTR |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','016'},{'RCC_CONTEU','FAV FAVELA              |FAV.|FAV |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','017'},{'RCC_CONTEU','FAZ FAZENDA             |FAZ.|FAZ |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','018'},{'RCC_CONTEU','FRA FEIRA               |FRA.|FRA |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','019'},{'RCC_CONTEU','GAL GALERIA             |GAL.|GAL |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','020'},{'RCC_CONTEU','GJA GRANJA              |GJA.|GJA |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','021'},{'RCC_CONTEU','JD  JARDIM              |JD.|JD |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','022'},{'RCC_CONTEU','LD  LADEIRA             |LD.|LD |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','023'},{'RCC_CONTEU','LGO LAGO                |LG.|LG |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','024'},{'RCC_CONTEU','LGA LAGOA               |LGA.|LGA |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','025'},{'RCC_CONTEU','LRG LARGO               |LRG.|LRG |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','026'},{'RCC_CONTEU','LOT LOTEAMENTO          |LOT.|LOT |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','027'},{'RCC_CONTEU','MRO MORRO               |MRO.|MRO |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','028'},{'RCC_CONTEU','NUC NUCLEO              |NUC.|NUC |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','029'},{'RCC_CONTEU','O   OUTROS              |LIN.|MGM.|PSG.|PR.|SQ.|'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','030'},{'RCC_CONTEU','PRQ PARQUE              |PRQ.|PRQ |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','031'},{'RCC_CONTEU','PSA PASSARELA           |PSA.|PSA |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','032'},{'RCC_CONTEU','PAT PATIO               |PAT.|PAT |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','033'},{'RCC_CONTEU','PC  PRACA               |PC.|PC |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','034'},{'RCC_CONTEU','PR  PRAIA               |PR.|PR |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','035'},{'RCC_CONTEU','Q   QUADRA              |Q.|Q |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','036'},{'RCC_CONTEU','REC RECANTO             |REC.|REC |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','037'},{'RCC_CONTEU','RES RESIDENCIAL         |RES.|RES |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','038'},{'RCC_CONTEU','ROD RODOVIA             |ROD.|ROD |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','039'},{'RCC_CONTEU','R   RUA                 |R.|R |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','040'},{'RCC_CONTEU','ST  SETOR               |ST.|ST |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','041'},{'RCC_CONTEU','SIT SITIO               |SIT.|SIT |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','042'},{'RCC_CONTEU','TV  TRAVESSA            |TV.|TV |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','043'},{'RCC_CONTEU','TRC TRECHO              |TRC.|TRC |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','044'},{'RCC_CONTEU','TRV TREVO               |TRV.|TRV |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','045'},{'RCC_CONTEU','VLE VALE                |VLE.|VLE |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','046'},{'RCC_CONTEU','VER VEREDA              |VER.|VER |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','047'},{'RCC_CONTEU','V   VIA                 |V.|V |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','048'},{'RCC_CONTEU','VD  VIADUTO             |VD.|VD |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','049'},{'RCC_CONTEU','VLA VIELA               |VLA.|VLA |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','050'},{'RCC_CONTEU','VL  VILA                |VL.|VL |'}})
   Aadd(aRCC,{{'RCC_FILIAL',' '},{'RCC_CODIGO','S054'},{'RCC_FIL',' '} ,{'RCC_CHAVE',' '} ,{'RCC_SEQUEN','051'},{'RCC_CONTEU','O OUTROS                |O|O|'}})
    
   nPosFil := AScan( aRCC[1], { |x| AllTrim( x[1] ) == "RCC_FILIAL" } )      
   nPosCod := AScan( aRCC[1], { |x| AllTrim( x[1] ) == "RCC_CODIGO" } )      
   nPosFi  := AScan( aRCC[1], { |x| AllTrim( x[1] ) == "RCC_FIL"  } )      
   nPosChv := AScan( aRCC[1], { |x| AllTrim( x[1] ) == "RCC_CHAVE" } )
   nPosSeq := AScan( aRCC[1], { |x| AllTrim( x[1] ) == "RCC_SEQUEN" } )
   nPosCon := AScan( aRCC[1], { |x| AllTrim( x[1] ) == "RCC_CONTEU" } )
   
   //Retira a acentuaCao da descriCao (X5_DESCRI) dos campos.
   AEVal(aRCC, {|x| x[nPosCon,2] := FwNoAccent(OemToAnsi(x[nPosCon,2])) } ) 
   For nF := 1 To nFiliais
       cCodFil := aFiliais[nF]
       //Preenche o campo RCC_FILIAL
       AEVal(aRCC, {|x| x[nPosFil,2] := cCodFil  } )
       For nX := 1 To Len(aRCC)
           cPosCod := aRCC[nX][nPosCod,2]      
           cPosFi  := aRCC[nX][nPosFi,2]     
           cPosChv := aRCC[nX][nPosChv,2]
           cPosSeq := aRCC[nX][nPosSeq,2]
           cPosCon := aRCC[nX][nPosCon,2]

           If RCC->(dbSeek( cCodFil + cPosCod + cPosFi + cPosChv + cPosSeq ))
              RecLock( "RCC", .F. )
           Else
              RecLock( "RCC", .T. )
           Endif
           For nC := 1 To RCC->(FCount())
               nField := aScan( aRCC[nX], { |x| RCC->(FieldName(nC)) == AllTrim( x[1] ) } )
               If (nField == 0)
                  Loop
               Endif
               RCC->( FieldPut( nField, aRCC[nX][nField,2] ) )
           Next nC
       //    RCC->(dbCommit())
           RCC->(MsUnLock())
       Next nX
   Next nF
   
   RestArea(aArea)

Return

**************************
Static Function FSAtuSX3()
**************************
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

//dbSelectArea("SX3")
//dbSetOrder(1)
//dbSeek("SR8")
//Do While !EOF() .AND. SX3->X3_ARQUIVO == "SR8"
//   If SX3->X3_CAMPO = "R8_NRPRCJU"
//	  RecLock("SX3",.F.)
//     dbDelete()
//	  MsUnlock()
//   Endif
//   dbSkip()
//End

//dbSelectArea("SX3")
//dbGoTop()
//dbSetOrder(1)
//dbSeek("SRG")
//Do While !EOF() .AND. SX3->X3_ARQUIVO == "SRG"
//   If SX3->X3_CAMPO = "RG_PROCS"
//	  RecLock("SX3",.F.)
//      dbDelete()
//	  MsUnlock()
//   Endif
//   dbSkip()
//End

//==============
//" TABELA SR8 "
//==============

If !U_AcheiSX3("SR8","R8_NRPRCJU")
   cOrd1 := U_UltimoSX3("SR8") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := U_QualOrdemSX3("SR8","R8_NRPRCJU")
Endif

aAdd( aSX3, { ;
	{ 'SR8'											        , .T. }, ; //X3_ARQUIVO
	{ cOrd1											        , .T. }, ; //X3_ORDEM
	{ 'R8_NRPRCJU'										    , .T. }, ; //X3_CAMPO
	{ 'C'											        , .T. }, ; //X3_TIPO
	{ 21											        , .T. }, ; //X3_TAMANHO
	{ 0											            , .T. }, ; //X3_DECIMAL
	{ 'Processo Jud'										, .T. }, ; //X3_TITULO
	{ 'Processo Jud'										, .T. }, ; //X3_TITSPA
	{ 'Processo Jud'										, .T. }, ; //X3_TITENG
	{ 'Nr. Processo Judicial'								, .T. }, ; //X3_DESCRIC
	{ 'Nr. Processo Judicial'								, .T. }, ; //X3_DESCSPA
	{ 'Nr. Processo Judicial'     							, .T. }, ; //X3_DESCENG
	{ '@!'											        , .T. }, ; //X3_PICTURE
	{ '' 											        , .T. }, ; //X3_VALID
	{ '€€€€€€€€€€€€€€ '									    , .T. }, ; //X3_USADO
	{ ''											        , .T. }, ; //X3_RELACAO
	{ ''											        , .T. }, ; //X3_F3
	{ 1											            , .T. }, ; //X3_NIVEL
	{ 'þA'										            , .T. }, ; //X3_RESERV
	{ ''											        , .T. }, ; //X3_CHECK
	{ ''											        , .T. }, ; //X3_TRIGGER
	{ 'U'											        , .T. }, ; //X3_PROPRI
	{ 'N'											        , .T. }, ; //X3_BROWSE
	{ 'A'											        , .T. }, ; //X3_VISUAL
	{ 'R'											        , .T. }, ; //X3_CONTEXT
	{ ''											        , .T. }, ; //X3_OBRIGAT
	{ ''											        , .T. }, ; //X3_VLDUSER
	{ ''											        , .T. }, ; //X3_CBOX
	{ ''											        , .T. }, ; //X3_CBOXSPA
	{ ''											        , .T. }, ; //X3_CBOXENG
	{ ''											        , .T. }, ; //X3_PICTVAR
	{ ''											        , .T. }, ; //X3_WHEN
	{ ''											        , .T. }, ; //X3_INIBRW
	{ ''											        , .T. }, ; //X3_GRPSXG
	{ ''											        , .T. }, ; //X3_FOLDER
	{ ''											        ,  .T. }, ; //X3_CONDSQL
	{ ''											        , .T. }, ; //X3_CHKSQL
	{ ''											        , .T. }, ; //X3_IDXSRV
	{ 'N'											        , .T. }, ; //X3_ORTOGRA
	{ ''											        , .T. }, ; //X3_TELA
	{ ''											        , .T. }, ; //X3_POSLGT
	{ 'N'											        , .T. }, ; //X3_IDXFLD
	{ ''			 								        , .T. }, ; //X3_AGRUP
	{ ''											        , .T. }, ; //X3_MODAL
	{ ''											        , .T. }} ) //X3_PYME

//==============
//" TABELA SRG "
//==============

If !U_AcheiSX3("SRG","RG_PROCS")
   cOrd1 := U_UltimoSX3("SRG") 
   cOrd1 := Soma1(cOrd1) 
Else
   cOrd1 := U_QualOrdemSX3("SRG","RG_PROCS")
Endif

aAdd( aSX3, { ;
	{ 'SRG'											, .T. }, ; //X3_ARQUIVO
	{ cOrd1											, .T. }, ; //X3_ORDEM
	{ 'RG_PROCS'										, .T. }, ; //X3_CAMPO
	{ 'C'											, .T. }, ; //X3_TIPO
	{ 20											, .T. }, ; //X3_TAMANHO
	{ 0											, .T. }, ; //X3_DECIMAL
	{ 'Pro.C.Social'										, .T. }, ; //X3_TITULO
	{ 'Pro.C.Social'										, .T. }, ; //X3_TITSPA
	{ 'Pro.C.Social'										, .T. }, ; //X3_TITENG
	{ 'Proc.Contr.Social    '									, .T. }, ; //X3_DESCRIC
	{ 'Proc.Contr.Social    '									, .T. }, ; //X3_DESCSPA
	{ 'Proc.Contr.Social    '     								, .T. }, ; //X3_DESCENG
	{ '@!'											, .T. }, ; //X3_PICTURE
	{ '' 											, .T. }, ; //X3_VALID
	{ '€€€€€€€€€€€€€€ '									, .T. }, ; //X3_USADO
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
	{ ''											, .T. }, ; //X3_OBRIGAT
	{ ''											, .T. }, ; //X3_VLDUSER
	{ ''											, .T. }, ; //X3_CBOX
	{ ''											, .T. }, ; //X3_CBOXSPA
	{ ''											, .T. }, ; //X3_CBOXENG
	{ ''											, .T. }, ; //X3_PICTVAR
	{ ''											, .T. }, ; //X3_WHEN
	{ ''											, .T. }, ; //X3_INIBRW
	{ ''											, .T. }, ; //X3_GRPSXG
	{ ''											, .T. }, ; //X3_FOLDER
	{ ''											, .T. }, ; //X3_CONDSQL
	{ ''											, .T. }, ; //X3_CHKSQL
	{ ''											, .T. }, ; //X3_IDXSRV
	{ 'N'											, .T. }, ; //X3_ORTOGRA
	{ ''											, .T. }, ; //X3_TELA
	{ ''											, .T. }, ; //X3_POSLGT
	{ 'N'											, .T. }, ; //X3_IDXFLD
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
		//Início - Thais Paiva - COmpatibilização P27
		//SXG->( dbSetOrder( 1 ) )
		//If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
		OpenSxs(,,,,cEmpAnt,"SXGTAB","SXG",,.F.)
		If Select("SXGTAB") > 0
			While SXGTAB->(!EOF())
				If SXGTAB->(FildPos(aSX3[nI][nPosSXG][1])) > 0
					If aSX3[nI][nPosTam][1] <> SXGTAB->&("XG_SIZE") //SXG->XG_SIZE
						aSX3[nI][nPosTam][1] := SXGTAB->&("XG_SIZE") //SXG->XG_SIZE
						AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
						AllTrim( Str( SXGTAB->&("XG_SIZE") ) ) + "]" + CRLF + ;
						" por pertencer ao grupo de campos [" + SXGTAB->&("XG_GRUPO") + "]" + CRLF )
						//AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
						//" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
					EndIf
				EndIf
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
					EndIf
					SXG2TB->(DbSkip())
				EndDo
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

**************************
/*Static Function FSAtuHlp()
**************************
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )

oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

If !U_AcheiSX3("SRG","RG_PROCS")
   aHlpPor := {}
   aAdd( aHlpPor, 'Informação sobre processo judicial  ' )
   aAdd( aHlpPor, 'que suspende a exigibilidade da  ' )
   aAdd( aHlpPor, 'Contribuição Social Rescisória.' )
   PutHelp( "PR8_XTPEFD", aHlpPor, {}, {}, .T. )
   AutoGrLog( "Atualizado o Help do campo " + "R8_XTPEFD" )
Endif

Return {}*/

****************************
User Function ChckSX2(cArq)
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
    //  DbSkip()
//End  
//Fim - Thais Paiva - Compatibilização P27
Return cEmp1

/////////////////////////////////////////////////////////////////////////////
