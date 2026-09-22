#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'AP5MAIL.CH'
#INCLUDE 'FILEIO.CH'
#Include 'TopConn.Ch'
#Include "TbiConn.ch"
// ------------------------------------
#DEFINE DF_SENHA "R&dD0r_12!"
#DEFINE PRX_LIN  chr( 13 ) + chr( 10 )
// ------------------------------------ 
STATIC lRmtHTM    := ( getremotetype() == 5 )//( getremotetype() == REMOTE_HTML )
STATIC cIPDowPool := '\\' + getserverip() + '\'        // SuperGetMV("FS_DOWPOOL",,"") //Compartilhamento antes de user "\\10.25.134.9\"
STATIC cIPFldPool := supergetmv( 'FS_FLDPOOL' , , '' ) // Compartilhamento antes de "user"

// ----------------------------------------------------------------------------
// {Protheus.doc} F0400101
// Função responsável pelo banco de conhecimento específico.
// @Project MAN00000463801_EF_001
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Param   nOpc - Opção selecionada pelo usuário. 1 - Visualizar, 3 - Inclusão, 5 - Exclusão, 6 - Download
// ----------------------------------------------------------------------------
 
user function f0400101( nOpc , cCodAnexo )
// ------------------------------------
	local   cCompara    := fwxfilial( 'P09' ) + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
	local   oButton1
	local   oButton2
	local   oButton3
	local   oButton4
	local   cGet1       := space( tamsx3( 'P09_NOMDOC' )[1] )
	local   oGroup1
	local   oGroup2
	local   oGroup3
	local   oGroup4
	local   oSay1
	local   oGetDad1
	local   aHeader1    := {}
	local   aCols1      := {}
	local   nEditGetD   := ''
	local   bDelOk      := {|| vlddel( oGetDad1 , nOpc ) }
	local   lRetInc     := .F.
	local   oFontx      := TFont():New( 'Courier new' , , -16 , .T. )
	Local 	cWarn := "" //Lucas Miranda de Aguiar - Melhoria data fixa
// ------------------------------------
	local   lRet        := .F. //Thais Paiva - 9425901 //.T. // DOR06959713_TK_8299289_MELHORIA
// ------------------------------------
	private oGet1
	private nTamArquivo := supergetmv( 'MV_XTANEXO' , .F. , 10000 )
	private cAviso      := ' ATENÇÃO: O tamanho máximo para anexo é de ' + cValToChar( nTamArquivo / 1000 ) + 'MB.'
	private cFile       := ''
	Private oDad550
	Private nOpc550 := 3
	Private lRet550 := .F.
	Private cCod550 := ""
	Private cBkp := ""
// ------------------------------------
	default nOpc        := 3
	default cCodAnexo   := ''
// ------------------------------------
	static  oDlg
// ------------------------------------


// ----------------------------------------------
//  [ DOR06959713_TK_8299289_MELHORIA - inicio ]
// ----------------------------------------------
//  [ Busca do título a partir da SC7 ]
// ----------------------------------------------
//  C7_FILIAL  = E2_FILIAL
//  C7_FORNECE = E2_FORNECE
//  C7_LOJA    = E2_LOJA
//  C7_XSERIE  = E2_PREFIXO
//  C7_XDOC    = E2_NUM
// ----------------------------------------------
//  [ Busca do título a partir da SF1 ]
// ----------------------------------------------
//  F1_FILIAL  = E2_FILIAL
//  F1_FORNECE = E2_FORNECE
//  F1_LOJA    = E2_LOJA
//  F1_SERIE   = E2_PREFIXO
//  F1_DOC     = E2_NUM
// ----------------------------------------------
	if U_VALSIMP() .And. IsInCallStack("U_F0100401")
		cBkp := "F0100401"
		SetFunName("S0100401")
	endif
	//Início Thais Paiva 9425901
	if nOpc == 1
		lRet := .T.
	EndIf
	//Fim Thais Paiva 9425901

	if nOpc == 3

		U_MSGDTFIX()//Função para alertar caso o fornecedor seja data fixa

		do case
// ----------------------------------------------
//          [ Solicitacao de pagamento ]
//          [ F0100401 - SC7           ]
// ----------------------------------------------
		case funname() $ 'F0100401|S0100401'
			dbselectarea( 'SE2' ) // Contas a Pagar
			dbsetorder( 6 ) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
			if dbseek(  SC7->( C7_FILIAL + C7_FORNECE + C7_LOJA + C7_XSERIE  + C7_XDOC ))
			/*Início Thais Paiva 9425901
				if (    SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM  ) == ;
						SC7->( C7_FILIAL + C7_FORNECE + C7_LOJA + C7_XSERIE  + C7_XDOC )    )
				
						if !( empty( SE2->E2_DATALIB ))
						help( '' , 1 , 'Help' , 'F0400101_SC7' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
						lRet := .F.
					endif
				endif*/
				While SE2->(!EOF()) .AND. ;
					 (SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM  ) == ;
					  SC7->( C7_FILIAL + C7_FORNECE + C7_LOJA + C7_XSERIE  + C7_XDOC ))
						if empty(SE2->E2_DATALIB)
						lRet := .T.
						Exit
					endif
					SE2->(DbSkip())
				EndDo
			Else
				lRet := .T.
			endif
			
			If !lRet
				help( '' , 1 , 'Help' , 'F0400101_SC7' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
			EndIf
		
// ----------------------------------------------
//          [ Documento de Entrada Esp  ]
//          [ MATA103 <- F1000301 - SF1 ]
// ----------------------------------------------
//          [ Documento de Entrada      ]
//          [ MATA103 - SF1             ]
// ----------------------------------------------
		case funname() == 'MATA103'
			dbselectarea( 'SE2' ) // Contas a Pagar
			dbsetorder( 6 ) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
			if dbseek(  SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC ))
				/*if (    SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == ;
						SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC )    )
				if !( empty( SE2->E2_DATALIB ))
						help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
						lRet := .F.
				endif
			endif*/
			While SE2->(!EOF()) .AND. ;
					(SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC )    )
					if empty(SE2->E2_DATALIB)
					   lRet := .T.
					   Exit
				endif
					SE2->(DbSkip())
			EndDo
		Else
				lRet := .T.
		endif
			
		If !lRet
				help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
		EndIf
			
// ----------------------------------------------
//          [ Pre-Documento de Entrada Esp ]
//          [ TEWBTYP3 - SF1               ]
// ----------------------------------------------
	case funname() == 'TEWBTYP3'
			dbselectarea( 'SE2' ) // Contas a Pagar
			dbsetorder( 6 ) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
		if dbseek(  SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC ))
				/*if (    SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == ;
						SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC )    )
			if !( empty( SE2->E2_DATALIB ))
						help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
						lRet := .F.
			endif
		endif*/
		While SE2->(!EOF()) .AND. ;
					 (SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == ;
					  SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC ))
				if empty(SE2->E2_DATALIB)
						lRet := .T.
						Exit
			endif
					SE2->(DbSkip())
		EndDo
	Else
				lRet := .T.
	endif
			
	If !lRet
				help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
	EndIf
// ----------------------------------------------
//          [ Pre-Documento de Entrada ]
//          [ MATA140 - SF1            ]
// ----------------------------------------------
case funname() == 'MATA140'
			dbselectarea( 'SE2' ) // Contas a Pagar
			dbsetorder( 6 ) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
	if dbseek(  SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC ))
				/*if (    SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == ;
						SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC )    )
		if !( empty( SE2->E2_DATALIB ))
						help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
						lRet := .F.
		endif
	endif*/
	While SE2->(!EOF()) .AND. ;
					 (SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == ;
						SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC )    )
			if empty(SE2->E2_DATALIB)
						lRet := .T.
						Exit
		endif
					SE2->(DbSkip())
	EndDo
Else
				lRet := .T.
endif
			
If !lRet
				help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
EndIf
			//Fim Thais Paiva 9425901

otherwise
			lRet := .T.

endcase

if !lRet
			return
endif

endif

// ----------------------------------------------
//  [ DOR06959713_TK_8299289_MELHORIA - fim ]
// ----------------------------------------------


// ------------------------------------
	cCompara := cCompara
// ------------------------------------
//  Condição para verficar se existe titulo gerado para a SC,
//  Caso não houver, irá disparar um email para o grupo financeiro tomar uma ação
// ------------------------------------
if fwisincallstack( 'MATA103' )

		cAlias01 := getnextalias()

	BEGINSQL Alias cAlias01
            SELECT SE2.R_E_C_N_O_ AS SE2_RECNO
              FROM %Table:SE2% SE2
        INNER JOIN %Table:SF1% SF1
                ON SF1.F1_FILIAL  = SE2.E2_FILIAL
               AND SF1.F1_DOC     = SE2.E2_NUM
               AND SF1.F1_SERIE   = SE2.E2_PREFIXO
               AND SF1.F1_FORNECE = SE2.E2_FORNECE
               AND SF1.F1_LOJA    = SE2.E2_LOJA
             WHERE SE2.%notDel%
               AND SF1.%notDel%
               AND SF1.F1_FILIAL || SF1.F1_DOC || SF1.F1_SERIE || SF1.F1_FORNECE || SF1.F1_LOJA = %Exp:cCompara%
	ENDSQL

	if !(cAlias01)->( !eof() ) .AND. ;
			SF1->F1_XSOLPAG <> '1'
		help( '' , 1 , 'Help' , 'F040010100' , 'Não foi encontrado título em aberto no Financeiro para pagamento. Foi enviado um e-mail para a equipe do financeiro informando a inexistência do Título a pagar.' , 1 , 0 )
		enviaemail()
	endif

	(cAlias01)->( dbclosearea() )

endif
// ------------------------------------
if lRmtHTM .And. ;
		( empty( cIPDowPool ) .OR. empty( cIPFldPool ) )
	help( '' , 1 , 'Help' , 'F040010100' , 'Funcionalidade não configurada para funcionar com SmartClient HTML..' , 1 , 0 )
return
endif
// ------------------------------------
if nOpc == 5
	//Início Thais Paiva 9425901
	do case
	case funname() == 'MATA103'
		dbselectarea( 'SE2' ) // Contas a Pagar
		dbsetorder( 6 ) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
		if dbseek(  SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC ))
			While SE2->(!EOF()) .AND. ;
					(SE2->( E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == SF1->( F1_FILIAL + F1_FORNECE + F1_LOJA + F1_SERIE   + F1_DOC )    )
				if !empty(SE2->E2_DATALIB)
					lRet := .F.
					Exit
				Else
					lRet := .T.
				endif
				SE2->(DbSkip())
			EndDo
		Else
			lRet := .T.
		endif

		If !lRet
			help( '' , 1 , 'Help' , 'F0400101_SF1' , 'O Título foi liberado para pagamento pelo Contas a Pagar.' , 1 , 0 )
		EndIf

	otherwise
		lRet := .T.
	endcase

	If lRet
		if !( VldExc() )
			return
		endif
	EndIf
	//Fim Thais Paiva 9425901
endif

If lRet
	// ----------------------------------------------------------------------------
    // Linha adicionada para atender a demanda de melhoria do projeto Banco de Conhecimento
    // ----------------------------------------------------------------------------
    aadd( aHeader1 , { 'Data/Hora' , 'P09_DTHORA' , '@!'       , tamsx3( 'P09_DTHORA' )[1] , 00         , ''       , '€€€€€€€€€€€€€€ ' , 'C'     , ''    , 'R'        , ''      , '' } )
    // ----------------------------------------------------------------------------

	// ----------------------------------------------------------------------------
	//                   TITULO    , X3_CAMPO     , X3_PICTURE , X3_TAMANHO                , X3_DECIMAL , X3_VALID , X3_USADO          , X3_TIPO , X3_F3 , X3_CONTEXT , X3_CBOX , X3_RELACAO
	// ----------------------------------------------------------------------------
	aadd( aHeader1 , { 'Documento' , 'P09_NOMDOC' , '@!'       , tamsx3( 'P09_NOMDOC' )[1] , 00         , ''       , '€€€€€€€€€€€€€€ ' , 'C'     , ''    , 'R'        , ''      , '' } )
	aadd( aHeader1 , { 'Rotina'    , 'P09_ROTINA' , '@!'       , 10                        , 00         , ''       , '€€€€€€€€€€€€€€ ' , 'C'     , ''    , 'R'        , ''      , '' } )
	aadd( aHeader1 , { 'Código'    , 'P09_CODDOC' , '@!'       , 09                        , 00         , ''       , '€€€€€€€€€€€€€€ ' , 'C'     , ''    , 'R'        , ''      , '' } )
	// ----------------------------------------------------------------------------
	if nOpc == 1

		nEditGetD := GD_UPDATE
		FilDados( @aCols1 , cCodAnexo )

	elseif nOpc == 3

		nEditGetD := GD_UPDATE + GD_DELETE
		FilDados( @aCols1 , cCodAnexo )

		if len( aCols1 ) == 0
			//aadd( aCols1 , { '' , '' , '' , .F. } )
			aadd( aCols1 , { '' , '' , '' , '' , .F. } )
		endif

	else

		nEditGetD := GD_DELETE
		FilDados( @aCols1 , cCodAnexo )

	endif

	if empty( aCols1 )
		help( '' , 1 , 'Help' , 'F040010112' , 'Não existe documentos anexado.' , 1 , 0 )
		return
	endif

	DEFINE MSDIALOG oDlg TITLE "Banco de Conhecimento Rede D'Or" FROM 000 , 000 TO 400 , 800     COLORS 0 , 16777215 PIXEL

	@ 002 , 003 GROUP oGroup1 TO 195 , 395 PROMPT 'Banco de Conhecimento Específico' OF oDlg COLOR  0 , 16777215 PIXEL
	@ 036 , 007 GROUP oGroup3 TO 192 , 390                                           OF oDlg COLOR  0 , 16777215 PIXEL
	@ 013 , 007 GROUP oGroup2 TO 035 , 390                                           OF oDlg COLOR  0 , 16777215 PIXEL
	@ 021 , 010 SAY oSay1 PROMPT 'Selecione o documento:' SIZE 061 , 007             OF oDlg COLORS 0 , 16777215 PIXEL

	oGetDad1 := MsNewGetDados():New( 042 , 015 , 140 , 377 , nEditGetD , , , , , , , , , bDelOk , oDlg , aHeader1 , aCols1 )

	if !lRmtHTM
		@ 019 , 071 MSGET oGet1 VAR cGet1                   SIZE 250 , 010 OF oDlg COLORS 0 , 16777215 VALID ( u_f0400108( cGet1 ) .AND. addgrid( @oGetDad1 , @aCols1 , @cGet1 , @oGet1 )) WHEN nOpc == 3 PIXEL
		@ 019 , 330 BUTTON oButton1 PROMPT 'Buscar Arquivo' SIZE 050 , 012 OF oDlg ACTION u_f0400102( @oGet1 , @cGet1 )                                                                    WHEN nOpc == 3 PIXEL
	else
		@ 019 , 071 MSGET oGet1 VAR cGet1                   SIZE 250 , 010 OF oDlg COLORS 0 , 16777215                                                                                     WHEN .F.       PIXEL
		@ 019 , 330 BUTTON oButton1 PROMPT 'Buscar Arquivo' SIZE 050 , 012 OF oDlg ACTION ( u_f0400102( @oGet1 , @cGet1 ) , addgrid( @oGetDad1 , @aCols1 , @cGet1 , @oGet1 ))              WHEN nOpc == 3 PIXEL
	endif

	@ 158 , 010 GROUP oGroup4 TO 188 , 388             OF oDlg COLOR 0 , 16777215 PIXEL
	@ 150 , 012 SAY oSay1 PROMPT cAviso SIZE 250 , 007 OF oDlg                    PIXEL COLOR CLR_RED FONT oFontx

	if nOpc == 1

		@ 166 , 226     BUTTON oButton2 PROMPT 'Download'  SIZE 049 , 017 OF oDlg ACTION AbriArq( oGetDad1 , 2 ) WHEN nOpc == 1 PIXEL
		if !lRmtHTM
			@ 166 , 280 BUTTON oButton2 PROMPT 'Visualiza' SIZE 049 , 017 OF oDlg ACTION AbriArq( oGetDad1 , 1 ) WHEN nOpc == 1 PIXEL
		endif
		@ 166 , 335     BUTTON oButton3 PROMPT 'Cancela'   SIZE 049 , 017 OF oDlg ACTION oDlg:End()                             PIXEL

	elseif nOpc == 3

		@ 166 , 172     BUTTON oButton2 PROMPT 'Download'  SIZE 049 , 017 OF oDlg ACTION AbriArq( oGetDad1 , 2 ) WHEN nOpc == 1 PIXEL
		if !lRmtHTM
			@ 166 , 226 BUTTON oButton2 PROMPT 'Visualiza' SIZE 049 , 017 OF oDlg ACTION AbriArq( oGetDad1 , 1 ) WHEN nOpc == 1 PIXEL
		endif
		@ 166 , 280     BUTTON oButton3 PROMPT 'Cancela'   SIZE 049 , 017 OF oDlg ACTION oDlg:End()                             PIXEL
		@ 166 , 335     BUTTON oButton4 PROMPT 'Confirma'  SIZE 049 , 017 OF oDlg ACTION ( iif( GrvArq( oGetDad1 , nOpc , @lRetInc , cCodAnexo ) , oDlg:End() , )) /*WHEN(nOpc == 3 .Or. nOpc == 5)*/ PIXEL

	elseif nOpc == 5

		@ 166 , 172     BUTTON oButton2 PROMPT 'Download'  SIZE 049 , 017 OF oDlg ACTION AbriArq( oGetDad1 , 2 ) WHEN nOpc == 1 PIXEL
		if !lRmtHTM
			@ 166 , 226 BUTTON oButton2 PROMPT 'Visualiza' SIZE 049 , 017 OF oDlg ACTION AbriArq( oGetDad1 , 1 ) WHEN nOpc == 1 PIXEL
		endif
		@ 166 , 280     BUTTON oButton3 PROMPT 'Sair'      SIZE 049 , 017 OF oDlg ACTION oDlg:End()                             PIXEL
		@ 166 , 335     BUTTON oButton4 PROMPT 'Excluir'   SIZE 049 , 017 OF oDlg ACTION ExcArq( oGetDad1 , nOpc , cCodAnexo ) /*WHEN(nOpc == 3 .Or. nOpc == 5)*/ PIXEL

	endif

	if nOpc == 1
		oGetDad1:oBrowse:bLDblClick := {|| Processa( {|| AbriArq( oGetDad1 , 1 ) } , 'Aguarde' , 'Chamando funcao...' ) }
	endif

	ACTIVATE MSDIALOG oDlg CENTERED

EndIf

if !Empty(cBkp)
	setFunName(cBkp)
	cBkp := ""
endif
		
return lRetInc

// ----------------------------------------------------------------------------
// {Protheus.doc} F0400102()
// Executa a função cGetFile e atualiza o Objeto
// @Author	Nairan Alves Silva
// @Since	15/09/2016
// @Project MAN00000463801_EF_001
// @Param	oGet - Objeto em tela
// @Param	cGet - Diretório do arquivo
// ----------------------------------------------------------------------------
user function F0400102(oGet1,cGet1)
// ------------------------------------
	local cGet1Bkp := cGet1
// ------------------------------------
	if !lRmtHTM
		cGet1 := CGetFile( 'Todos Arquivos|*.*'                                         , ;
			'Selecione o arquivo'                                        , ;
			1                                                            , ;
			'C:\'                                                        , ;
			.T.                                                          , ;
			NOr( GETF_LOCALHARD , GETF_LOCALFLOPPY , GETF_NETWORKDRIVE ) , ;
			.F. )
	else
		cGet1 := CGetFile(                                                              , ;
			'Selecione o link abaixo'                                    , ;
			1                                                            , ;
			, ;
			.T.                                                          , ;
			, ;
			.F. )
	endif

	if !u_f0400108( cGet1 )
		cGet1 := cGet1Bkp
	endif

	oGet1:Refresh()
	oGet1:SetFocus()

return

// ----------------------------------------------------------------------------
static function VldDel( oGetDad1 , nOpc )
// ------------------------------------
	local nX     := 0
	local aCols1 := AClone( oGetDad1:aCols )
	local nAt    := oGetDad1:nAt
	local lRet   := .T.
// ------------------------------------
	if nOpc != 5
// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
		if !empty( aCols1[nAt][3] )
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
				if !empty( aCols1[nAt][4] )
// ------------------------------------	
					lRet := .F.
					help( '' , 1 , 'Help' , 'F040010113' , 'Não é possível deletar itens já incluídos. Para esse processo é necessário selecionar a opção Banco de Conhecimento - Excluir' , 1 , 0 )
				endif
			endif

			return lRet

// ----------------------------------------------------------------------------
// {Protheus.doc} AbriArq()
// Função executada para visualizar ou baixar arquivos
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Project MAN00000463801_EF_001
// @Param   oGetDad1 - Diretório do arquivo
// @Param   nOpc - 1 - Visualizar, 2 - Download
// ----------------------------------------------------------------------------
static function AbriArq( oGetDad1 , nOpc )
// ------------------------------------
	local aDados    := AClone( oGetDad1:aCols )
	local nLin      := oGetDad1:nAt
	local cArqRed   := '\RDANEXOS\'
	local cWebAnexo := '\WEBANEXOS\'
	local cArqLoc   := GetTempPath()
// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	local cFile     := aDados[nLin][03]
	local cNArq     := alltrim( aDados[nLin][01] )
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	local cFile     := aDados[nLin][04]
	local cNArq     := alltrim( aDados[nLin][02] )
// ------------------------------------

	local lRet      := .T.
	local nHdl      := 0
	Local _cMsg := 'Não foi possível abrir o arquivo.'
// ------------------------------------

	If substr(AllTrim(cNArq),1,4) == "http"
		nHdl := ShellExecute("Open",cNArq,"","",1)
		if nHdl < 0
			help( '' , 1 , 'Help' , 'F040010111' , _cMsg , 1 , 0 ) //Fim Thais Paiva 16424543
		else
			msginfo( 'Processo realizado com Sucesso.' , 'Sucesso!' )
		endif
		Return
	EndIf

	if !lRmtHTM
		if nOpc != 1
			cArqLoc := CGetFile( 'Todos Arquivos|*.*'                                                             , ;
				'Selecione o Diretório Destino'                                                  , ;
				1                                                                                , ;
				'C:\'                                                                            , ;
				.F.                                                                              , ;
				Nor( GETF_LOCALHARD , GETF_LOCALFLOPPY , GETF_NETWORKDRIVE , GETF_RETDIRECTORY ) , ;
				.F. )
		endif

		if empty( cArqLoc )
			return
		endif

		if !( file( cArqRed + fwxfilial( 'P09' ) + cFile + '.MZP' ) ) //Início Thais Paiva 16424543
			lRet := .F.
			_cMsg := "Arquivo: "+cArqRed + fwxfilial( 'P09' ) + cFile + ".MZP"+" não encontrado!"
		endif

		If lRet
			cpys2t( cArqRed + fwxfilial( 'P09' ) + cFile + '.MZP' , cArqLoc , , )

			if !( file( cArqLoc + fwxfilial( 'P09' ) + cFile + '.MZP' ) )
				lRet := .F.
			endif
		EndIf

		if lRet
			lRet := MsDecomp( cArqLoc + fwxfilial( 'P09' ) + cFile + '.MZP' , cArqLoc , DF_SENHA )
		endif

		if lRet .AND. nOpc == 1
			nHdl := shellExecute( 'Open' , cArqLoc + cNArq , 'Null' , 'C:\' , 1 )
		endif

		If lRet
			nHdl := ferase( cArqLoc + fwxfilial( 'P09' ) + cFile + '.MZP' , , )
		EndIf

		if !lRet .OR. nHdl < 0
			help( '' , 1 , 'Help' , 'F040010111' , _cMsg , 1 , 0 ) //Fim Thais Paiva 16424543
		else
			msginfo( 'Processo realizado com Sucesso.' , 'Sucesso!' )
		endif

	else
		if !( file( cArqRed + fwxfilial( 'P09' ) + cFile + '.MZP' ) ) //Início Thais Paiva 16424543
			lRet := .F.
			_cMsg := "Arquivo: "+cArqRed + fwxfilial( 'P09' ) + cFile + ".MZP"+" não encontrado!"
		endif
		If lRet
			if MsDecomp( cArqRed + fwxfilial( 'P09' ) + cFile + '.MZP' , cWebAnexo , DF_SENHA )
				//Início - Thais Paiva - 8004071
				//__CopyFile( cWebAnexo + cNArq , cWebAnexo + NoAcento( ANSIToOEM( cNArq )))
				//CpyS2TW( cWebAnexo + NoAcento( ANSIToOEM( cNArq )))
				_cNovoArq := FLIMPAESP(NoAcento(cNArq))
				lRet := __CopyFile(cWebAnexo+cNArq,cWebAnexo+_cNovoArq)
				If lRet
					nHdl := CpyS2TW(cWebAnexo+_cNovoArq)
					If nHdl == 0
						nHdl := ferase( cWebAnexo + cNArq )
						//ferase( cWebAnexo + NoAcento( ANSIToOEM( cNArq )))
						If nHdl <> 0
							_cMsg := "Erro ao excluir arquivo: "+cWebAnexo + cNArq+" -> "+ STR(FERROR())
						Endif

						If nHdl == 0
							nHdl := FErase(cWebAnexo+_cNovoArq)
							//Fim - Thais Paiva - 8004071
							If nHdl <> 0
								_cMsg := "Erro ao excluir arquivo: "+cWebAnexo+_cNovoArq+" -> "+ STR(FERROR())
							Endif
						Else
							nHdl := FErase(cWebAnexo+_cNovoArq)
							If nHdl <> 0
								_cMsg += PRX_LIN+"Erro ao excluir arquivo: "+cWebAnexo+_cNovoArq+" -> "+ STR(FERROR())
							Endif
						Endif
					Else
						lRet := .F.
						_cMsg := "Falha na copia do arquivo: "+cWebAnexo + cNArq
						Do Case
						Case nHdl == -1
							_cMsg += " - Erro -1: Diretório não é um diretório no servidor."
						Case nHdl == -2
							_cMsg += " - Erro -2: Arquivo não existe no servidor."
						Case nHdl == -3
							_cMsg += " - Erro -3: Falha na transmissão para o Servidor Web (SmartClient HTML)."
						Case nHdl == -4
							_cMsg += " - Erro -4: Falha na transmissão para o Client Web (navegador de internet)."
						Otherwise
							_cMsg += " - Erro não mapeado."
						End Case
					EndIf
				Else
					_cMsg := "Não foi possível copiar o arquivo: "+cWebAnexo+cNArq+" para: "+cWebAnexo+_cNovoArq
				EndIf
			Else
				lRet := .F.
			endif
		Endif
		If !lRet
			help( '' , 1 , 'Help' , 'F040010111' , _cMsg , 1 , 0 ) //Fim Thais Paiva 16424543
		Endif
	endif

return

// ----------------------------------------------------------------------------
// {Protheus.doc} AddGrid()
// Função para adicionar arquivos no Grid
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @Param   oGetDad1 - Objeto GetDados
// @Param   aCols1   - Acols do Objeto
// @Param   cGet1    - Conteúdo do Get
// @Param   Get1     - Objeto do Get
// @return  Nil
// ----------------------------------------------------------------------------
static function addgrid( oGetDad1 , aCols1 , cGet1 , oGet1 )
// ------------------------------------
	local nX     := 0
	local aDados := aclone( oGetDad1:aCols )
// ------------------------------------

	if !empty( cGet1 )

		if ascan( aDados ,{ |x| alltrim(x[1] ) == cGet1} ) > 0
			help( '' , 1 , 'Help' , 'F040010106' , 'O arquivo ' + alltrim( cGet1 ) + ' já foi selecionado.' , 1 , 0 )
		elseif !lRmtHTM .AND. !( file( cGet1 ))
			help( '' , 1 , 'Help' , 'F040010107' , 'O arquivo não existe no diretório especificado.'        , 1 , 0 )
		else

			if empty( aDados[01][01] )
				aDados := {}
			endif

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
			aadd( aDados , { cGet1 , funname() , '' , .F. } )
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
			aadd( aDados , { DTOC(DATE())+" "+TIME(), cGet1 , funname() , '' , .F. } )
// ------------------------------------

		endif

	endif

	oGetDad1:aCols := AClone(aDados)
	oGetDad1:Refresh()
	cGet1          := space( 50 )
	oGet1:Refresh()

return

// ----------------------------------------------------------------------------
// {Protheus.doc} GrvArq()
// Função para gravar os arquivos selecionados
// @Author	Nairan Alves Silva
// @Since	15/09/2016
// @Project MAN00000463801_EF_001
// @Param   oGetDad1 - Objeto GetDados
// @Param 	nOpc     - 3 - Inclusão , 5 - Exclusão
// @Param 	lRetInc  - Valida Exclusão
// ----------------------------------------------------------------------------

static function grvarq( oGetDad1 , nOpc , lRetInc , cCodAnexo )
// ------------------------------------
	local   aAttach   := {}
	local   aDados    := aclone( oGetDad1:aCols   )
	local   aHeader   := aclone( oGetDad1:aHeader )
	local   cArqRed   := '\RDANEXOS\'
	local   cArqLoc   := gettemppath()
	local   cWebAnexo := '\WEBANEXOS\'
	local   cRet      := ''
	local   nRet      := 0
	local   lRet      := .T.
	local   nHdl      := 0
	local   cNArq     := '' // alltrim(substr(cFile,rAt('\', cFile) + 1,50))
	local   nX        := 0
	local   cCodigo   := ''
	local   cNivel    := RetNvlTor()
	local   cMsg      := 'Não foi possível realizar a operação.'
	local   cContArq  := ''
	local   aContArq  := {}
	local   nTamArq   := 0
	local 	cfilbkp := cFilAnt
	Local   cOri    := ""
	Local  cRot := ""
// ------------------------------------
	default lRetInc   := .F.
// ------------------------------------

	If funname() == "FINA560"
		oDad550 := oGetDad1
		nOpc550 := nOpc
		lRet550 := lRetInc
		cCod550 := cCodAnexo
	EndIf


	if nOpc <> 1

		if !( msgyesno( 'Confirma Operação?' , 'Banco de Conhecimento' ))
			return
		endif

		if !( existdir( '\RDANEXOS' ))
			nRet := makedir( '\RDANEXOS' )
			if nRet != 0
				help( '' , 1 , 'Help' , 'F040010101' , 'Não foi possível criar o diretório na rede.' , 1 , 0 )
				return
			endif
		endif

		if !lRmtHTM
			if !( existdir( cArqLoc ))
				nRet := makedir( cArqLoc )
				if nRet != 0
					help( '' , 1 , 'Help' , 'F040010102' , 'Não foi possível criar o diretório Local.' , 1 , 0 )
					return
				endif
			endif
		else
			if !( existdir( cWebAnexo ))
				nRet := makedir( cWebAnexo )
				if nRet != 0
					Help( '' , 1 , 'Help' , 'F040010105' , 'Não foi possível criar o diretório Local (WEB).' , 1 , 0 )
					return
				endif
			endif
		endif

		if lRet := validarq( aDados , nOpc , cCodAnexo , aHeader )

// ------------------------------------
			BEGIN TRANSACTION

				if nOpc == 3

					for nX := 1 to len( aDados )

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
						if aDados[nX][len( aHeader ) + 1] .OR. ;
								!empty( aDados[nX][3] )        .OR. ;
								empty( aDados[nX][1] )
							Loop
						endif

						lRetInc := .T.
						cOri := retcodori( aDados[nX][02] , cCodAnexo )[01]

						cNArq   := retnomearq( aDados[nX][01] , 2 )
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
						if aDados[nX][len( aHeader ) + 1] .OR. ;
								!empty( aDados[nX][4] )        .OR. ;
								empty( aDados[nX][2] )
							Loop
						endif

						lRetInc := .T.
						cOri := retcodori( aDados[nX][03] , cCodAnexo )[01]

						cNArq   := retnomearq( aDados[nX][2] , 2 )
// ------------------------------------

						cCodigo := getsxenum( 'P09' , 'P09_CODDOC' )
						cRot := aDados[nX][02]

						reclock( 'P09' , .T. )
						P09->P09_FILIAL := fwxfilial( 'P09' )
						P09->P09_CODDOC := cCodigo
						P09->P09_NOMDOC := cNArq
// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
							P09->P09_DTHORA := dtos( date() ) + strtran( time() , ':' , '' )
							P09->P09_CODORI := retcodori( aDados[nX][02] , cCodAnexo )[01]
							P09->P09_ROTINA := aDados[nX][02]
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
						P09->P09_DTHORA := dtos( ctod( substr( aDados[nX][1] ,1 ,10 ) ) ) + strtran( substr( aDados[nX][1] ,12,8 ) , ':' , '' )
						P09->P09_CODORI := retcodori( aDados[nX][03] , cCodAnexo )[01]
						P09->P09_ROTINA := aDados[nX][03]
// ------------------------------------

						P09->P09_NIVEL  := cNivel
						P09->( msunlock() )

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
						aContArq := u_copyconteu( aDados[nX][01] )
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
						aContArq := u_copyconteu( aDados[nX][02] )
// ------------------------------------


						Conout("Inicio u_copyconteu P09 linha 760 " + Time())
						cContArq := aContArq[1]
						nTamArq  := aContArq[2]

						aadd( aAttach , { cNArq , cContArq , nTamArq } )

// ----------------------------------------------------------------------------
//                      [ Verifica se há título a pagar recusado.                        ]
//                      [ Se houver, altera o status de R (recusado) para C (corrigido). ]
//                      [ Parâmetros:                                                    ]
//                      [ 01 - Filial                                                    ]
//                      [ 02 - Rotina                                                    ]
//                      [ 03 - Origem                                                    ]
// ----------------------------------------------------------------------------
						//u_f010101I( fwxfilial( 'P09' )        , ;
							//	aDados[nX][02]            , ;
							//	retcodori( aDados[nX][02] , ;
							//	cCodAnexo)[02]              )
						u_f010101I( fwxfilial( 'P09' )        , ;
							aDados[nX][3]            , ;
							retcodori( aDados[nX][3] , ;
							cCodAnexo)[02]              )

						if !lRmtHTM

							//cRet := mscompress( aDados[nX][01]                                  , ;
								//	cArqLoc + fwxfilial( 'P09' ) + cCodigo + '.MZP' , ;
								//	DF_SENHA                                          )
							cRet := mscompress( aDados[nX][2]                                  , ;
								cArqLoc + fwxfilial( 'P09' ) + cCodigo + '.MZP' , ;
								DF_SENHA                                          )
							nHdl := fopen( cRet )

							if nHdl == -1
								ROLLBACKSX8()
								DISARMTRANSACTION()
								lRet := .F.
								exit
							else
								fclose( nHdl )
								if !( cpyt2s( cArqLoc + fwxfilial( 'P09' ) + cCodigo + '.MZP' , cArqRed ))
									ROLLBACKSX8()
									DISARMTRANSACTION()
									lRet := .F.
									exit
								else
									ferase( cRet )
								endif
							endif

						else

							//if !( cpyt2s( aDados[nX][01] , cWebAnexo ))
							if !( cpyt2s( aDados[nX][2] , cWebAnexo ))
								cMsg := 'Problemas na copia do arquivo por WEB.'
								ROLLBACKSX8()
								DISARMTRANSACTION()
								lRet := .F.
								exit
							endif

							//cRet := mscompress( cWebAnexo + retnomearq( aDados[nX][1] , 2 ) , ;
								//	cArqRed   + fwxfilial( 'P09' ) + cCodigo + '.MZP' , DF_SENHA )
							cRet := mscompress( cWebAnexo + retnomearq( aDados[nX][2] , 2 ) , ;
								cArqRed   + fwxfilial( 'P09' ) + cCodigo + '.MZP' , DF_SENHA ) ;

							//ferase( cWebAnexo + retnomearq( aDados[nX][1] , 2 ))
							ferase( cWebAnexo + retnomearq( aDados[nX][2] , 2 ))

							if empty( cRet )
								cMsg := 'Problemas no tratamento de arquivo por WEB.'
								ROLLBACKSX8()
								DISARMTRANSACTION()
								lRet := .F.
								exit
							endif

						endif

						CONFIRMSX8()

					next nX

				else

					for nX := 1 to len( aDados )

						if aDados[nX][len(aHeader) + 1]

							//cCodigo := aDados[nX][03]
							cCodigo := aDados[nX][4]
							nHdl    := ferase( cArqRed + fwxfilial( 'P09' ) + cCodigo + '.MZP' )

							if P09->( dbseek( fwxfilial( 'P09' ) + cCodigo ))
								reclock( 'P09' , .F. )
								P09->( dbdelete() )
								P09->( msunlock() )
							endif

						endif

					next nX

				endif

			END TRANSACTION
// ------------------------------------

// ------------------------------------
//          [ Tratamento para tamanho de arquivo ]
// ------------------------------------

			if lRet

				nTamArq := 0

				for nX := 1 to len( aAttach )
					nTamArq += aAttach[nX][3]
				next nX

				nTamArq += 4000 // Soma o tamanho das tags do XML

				if ( nTamArq / 1024 ) > nTamArquivo // Transformo em Mbytes e verifico de nao passa MaxStringSize
					cMsg := ' Arquivos para anexo juntos somam mais de ' + cValToChar( nTamArquivo ) + ' MB de limite.  '
					lRet := .F.
				endif

			endif

			if lRet
				if nOpc == 3
					if findfunction( 'U_F1701104' )
						u_f1701104( aAttach , , .F. )
					endif
// ------------------------------------
//                  else -> deleção
//                  U_F1701104(aAttach,, .T.)
// ------------------------------------
				endif
				If FunName() == "FINA560" .And. nOpc == 3 .And. lRetInc
					fEnvTit(oDad550,nOpc550,lRet550,cCod550)
				EndIf
				U_DTFXSE2()//Grava o nome do usuário na F1_XVALNOM ou E2_XVALNOM
				fAltSP("I",funname())
				msginfo( 'Processo realizado com Sucesso.' , 'Sucesso!' )

			else
				help( '' , 1 , 'Help' , 'F040010103' , cMsg , 1 , 0 )
			endif

			if !lRetInc
				for nX := 1 to len( aDados )
					if !aDados[nX][len(aHeader) + 1]
						lRetInc := .T.
						exit
					endif
				next nX
			endif

		endif
	endif
	cFilAnt := cfilbkp
return lRet

// ----------------------------------------------------------------------------
// {Protheus.doc} ExcArq()
// Função para Excluir os arquivos selecionados.
// @Author  Nairan Alves Silva
// @Since   04/01/2017
// @Version P12.7
// @Project MAN00000463801_EF_001
// @Param   oGetDad1 - Objeto GetDados
// @Param   nOpc - 3 - Inclusão, 5 - Exclusão
// @return  Nil
// ----------------------------------------------------------------------------
static function ExcArq( oGetDad1 , nOpc , cCodAnexo )
// ------------------------------------
	local aDados  := aclone( oGetDad1:aCols   )
	local aHeader := aclone( oGetDad1:aHeader )
	local aCols   := {}
	local nAt     := oGetDad1:nAt
	local cArqRed := '\RDANEXOS\'
	local cArqLoc := gettemppath()
	local cRet    := ''
	local nRet    := 0
	local lRet    := .T.
	local nHdl    := 0
	local cNArq   := '' // alltrim( substr( cFile , rAt( '\' , cFile ) + 1,50 ))
	local nX      := 0
	local cCodigo := ''
	local cNivel  := RetNvlTor()
	local cMsg    := 'Não foi possível realizar a operação.'
// ------------------------------------

	if nOpc <> 1

		if !msgyesno( 'Confirma Exclusão?' , 'Banco de Conhecimento' )
			return
		endif

		if lRet := validarq( aDados , nOpc , , aHeader )

// ------------------------------------
			//BEGIN TRANSACTION

			//cCodigo := aDados[nAt][03]
			cCodigo := aDados[nAt][4]
			//nHdl    := ferase( cArqRed + cCodigo + '.MZP' )

			//if nHdl == 0
			if P09->( dbseek( fwxfilial( 'P09' ) + cCodigo ))
				reclock( 'P09' , .F. )
				P09->( dbdelete() )
				P09->( msunlock() )
				If !(Left(AllTrim(aDados[nAt][2]),4,1) == "http")
					nHdl    := ferase( cArqRed + fwxfilial('P09')+cCodigo + '.MZP' )
				EndIf
			else
				cMsg := "Não encontrou o registro na P09!"
				lRet := .F.
			endif
			//else
			//	lRet := .F.
			//	cMsg := "Não foi possível excluir o arquivo! ERROR: "+cValToChar(fError()) + CRLF + "Consulte o Link: https://tdn.totvs.com/display/public/framework/FError "
			//endif

			//END TRANSACTION
// ------------------------------------
			/*if P09->( dbseek( fwxfilial( 'P09' ) + cCodigo ))
				nHdl    := ferase( cArqRed + fwxfilial( 'P09' )+cCodigo + '.MZP' )
				reclock( 'P09' , .F. )
				P09->( dbdelete() )
				P09->( msunlock() )
			endif*/


			if lRet
				fildados( @aCols , cCodAnexo )
				oGetDad1:aCols := aclone( aCols )
				oGetDad1:Refresh()
				If FunName() == "FINA560"
					fExclTit(oDad550,nOpc550,lRet550,cCod550)
				Endif
				fAltSP("D",FunName())
				msginfo( 'Arquivo Excluído com Sucesso.' , 'Sucesso!' )
			else
				help( '' , 1 , 'Help' , 'F040010104' , cMsg , 1 , 0 )
			endif

		endif

	endif

return lRet

// ----------------------------------------------------------------------------
// {Protheus.doc} RetNomeArq()
// Função para retornar o nome do arquivo
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @Param   cDir  - Diretório do Arquivo
// @Param   nTipo - 1 - Sem Extensão, 2 - Com extensão
// @return  Nil
// ----------------------------------------------------------------------------
static function RetNomeArq( cDir , nTipo )
// ------------------------------------
	local   cRet  := ''
// ------------------------------------
	default nTipo := 1
// ------------------------------------
	cRet := alltrim( substr( cDir , rAt( '\' , cDir ) + 1 , tamsx3( 'P09_NOMDOC' )[1] ))
	if nTipo == 1
		cRet := substr( cRet , 1 , rAt( '.' , cRet ) -1 )
	endif

return cRet

// ----------------------------------------------------------------------------
// {Protheus.doc} RetNvlTor()
// Retorna o Nível do Arquivo
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @return  Nil
// ----------------------------------------------------------------------------
static function retnvltor()
// ------------------------------------
	local cFunc := funname()
	local cRet  := '00'
// ------------------------------------

	if cFunc == 'MATA110'
		cRet := '01'

	elseif alltrim( cFunc )  $ 'MATA120|MATA121'
		cRet := '02'

	elseif alltrim( cFunc ) == 'MATA103'
		cRet := '03'

	elseif alltrim( cFunc ) == 'MATA140' .OR. ;
			alltrim( cFunc ) == 'TEWBTYP3' // PRE-NOTA OU PRE-ESP
		cRet := '04'

	elseif alltrim( cFunc ) == 'FINA050' .OR. ;
			alltrim( cFunc ) == 'FINA750'
		cRet := '05'

	elseif alltrim( cFunc ) == 'FINA550'
		cRet := '06'

	elseif alltrim( cFunc ) == 'GPEM660'
		cRet := '07'

	elseif alltrim( cFunc ) == 'F0100401'
		cRet := '08'

	elseif alltrim( cFunc ) == 'S0100401'
		cRet := '08'

	elseif alltrim( cFunc ) == 'AE_DESPV'
		cRet := '09'

	elseif alltrim( cFunc ) == 'F0500101'
		cRet := '10'

	elseif alltrim( cFunc ) == 'F0100323'
		cRet := '11'

	endif

return cRet

// ----------------------------------------------------------------------------
// {Protheus.doc} RetCodOri()
// Retorna o Campo Chave da Tabela
// @Project MAN00000463801_EF_001
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Param   cFunc     - Função responsável por acionar a rotina de banco de conhecimento
// @Param   cCodAnexo - Código fixo do anexo. Utilizado para solicitações de desligamento
// @return  Nil
// ----------------------------------------------------------------------------
static function retcodori( cFunc , cCodAnexo )
// ------------------------------------
	local   aRet      := {}
	local   cIntFin   := ''
	local   cRet      := ''
// ------------------------------------
	default cCodAnexo := ''
// ------------------------------------
	if alltrim( cFunc ) == 'MATA110'
		cRet    := SC1->C1_NUM
		cIntFin := cRet

	elseif alltrim( cFunc ) $ 'MATA120|MATA121'
		cRet    := SC7->C7_NUM
		cIntFin := cRet
		cFilAnt := SC7->C7_FILIAL

	elseif alltrim( cFunc ) $ 'MATA103'
		cRet    := SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )
		cIntFin := cRet
		cFilAnt := SF1->F1_FILIAL

	elseif alltrim( cFunc ) $ 'MATA140|TEWBTYP3'
		cRet    := SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )
		cIntFin := cRet
		cFilAnt := SF1->F1_FILIAL

	elseif alltrim( cFunc ) $ 'FINA050' .OR. ;
			alltrim( cFunc ) $ 'FINA750'
		cRet    := SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )
		cIntFin := cRet
		cFilAnt := SE2->E2_FILIAL

	elseif alltrim( cFunc ) $ 'FINA550'
		cRet    := SET->ET_CODIGO
		cIntFin := cRet

	elseif alltrim( cFunc ) $ 'GPEM660'
		cRet    := RC1->( RC1_FILTIT + RC1_CODTIT + RC1_PREFIX + RC1_NUMTIT )
		cIntFin := RC1->( RC1_FILTIT + RC1_PREFIX + RC1_NUMTIT + RC1_TIPO + RC1_FORNEC )

	elseif alltrim( cFunc ) $ 'F0100401|S0100401'
		cRet    := SC7->C7_NUM
		cIntFin := cRet
		cFilAnt := SC7->C7_FILIAL

	elseif alltrim( cFunc ) $ 'AE_DESPV'
		cRet    := LHQ->LHQ_CODIGO
		cIntFin := cRet

	elseif alltrim( cFunc ) $ 'F0500101'
		if !( empty( cCodAnexo ))
			cRet := cCodAnexo
		else
			cRet := P10->P10_CODRH3
		endif
		cIntFin  := cRet

	elseif alltrim( cFunc ) $ 'F0100323' .OR. ;
			('F08010'        $ alltrim( cFunc ))
		cRet    := RH3->RH3_CODIGO
		cIntFin := cRet

	elseif alltrim( cFunc ) $ 'CNTA300'
		cRet := CN9->CN9_NUMERO

	elseif alltrim( cFunc ) $ 'MATA094' .Or. alltrim( cFunc ) $ 'XMATA094' .Or. allTrim( cfunc ) $ 'XAPREPMED'
		cRet := alltrim(SCR->CR_NUM) + iif( SCR->CR_TIPO $ ('PC|SC') , SCR->CR_TIPO , '' )

	elseif alltrim( cFunc ) $ 'MATA460A'
		cRet := SC9->C9_PEDIDO

	elseif AllTrim (cFunc) $ 'FINA560'
		cRet := AllTrim(SEU->EU_FILIAL)+AllTrim(SEU->EU_NUM)

	ElseIf AllTrim(cFunc) $ 'CNTA121'
		cRet := CND->(CND_FILIAL+CND_NUMMED+CND_CONTRA+CND_REVISA)
	endif
// ------------------------------------
	aadd( aRet , cRet    )
	aadd( aRet , cIntFin )
// ------------------------------------
return aRet

// ----------------------------------------------------------------------------
// {Protheus.doc} vldexc()
// Valida se os arquivos poderão ou não ser excluídos
// @Project MAN00000463801_EF_001
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @return  Nil
// ----------------------------------------------------------------------------
static function vldexc()
// ------------------------------------
	local cFunc := funname()
	local cMsg  := ''
	local lRet  := .T.
// ------------------------------------
	if cFunc == 'MATA110'

		lRet := !( alltrim( SC1->C1_APROV ) != 'B' )
		if !lRet
			cMsg := 'A solicitação de compra já foi aprovada.'
		endif

	elseif alltrim( cFunc ) $ 'MATA120|MATA121'

		lRet := !(alltrim(SC7->C7_CONAPRO) != 'B')
		if !lRet
			cMsg := 'O pedido de compra já foi aprovado.'
		endif

	elseif alltrim( cFunc ) == 'MATA103'

		if empty( SF1->F1_DUPL )
			SE2->( dbsetorder( 1 )) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
			SE2->( msseek(      SF1->( F1_FILIAL + F1_PREFIXO + F1_DUPL )))
			do while lRet            .AND. ;
					!SE2->( eof() ) .AND. ;
					SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM ) == SF1->( F1_FILIAL + F1_PREFIXO + F1_DUPL )
				lRet := empty( SE2->E2_BAIXA )
				SE2->( dbskip() )
			enddo
			if !lRet
				cMsg := 'A nota fiscal tem um título a pagar já baixado.'
			endif
		endif

	elseif alltrim( cFunc ) == 'MATA140' .OR. ;
			alltrim( cFunc ) == 'TEWBTYP3'

		lRet := empty( SF1->F1_STATUS )
		if !lRet
			cMsg := 'A Pré-Nota já foi classificada.'
		endif

	elseif alltrim( cFunc ) == 'FINA050' .OR. ;
			alltrim( cFunc ) == 'FINA750'

		lRet := empty( SE2->E2_BAIXA )
		if !lRet
			cMsg := 'O título já foi baixado.'
		endif

	elseif alltrim( cFunc ) == 'FINA550'

		lRet := alltrim( SET->ET_SITUAC ) == '0'
		if !lRet
			cMsg := 'O caixinha não está mais ativo.'
		endif

	elseif alltrim( cFunc ) == 'GPEM660'

		lRet := empty( RC1->RC1_NUMTIT )
		if !lRet
			cMsg := 'Título gerado. Não é possível excluir anexos.'
		endif

	elseif alltrim( cFunc ) $ 'F0100401|S0100401'

		if ( SC7->C7_CONAPRO == 'B' .AND. SC7->C7_QUJE < SC7->C7_QUANT )
			lRet := .T.
		else
			lRet := .F.
		endif
		if !lRet
			cMsg := 'A solicitação de pagamento já foi aprovada.'
		endif

	elseif alltrim( cFunc ) == 'AE_DESPV'

		lRet := empty( posicione( 'LHP' , 1 , fwxfilial( 'LHP' ) + LHQ->LHQ_CODIGO , 'LHP_DOCUME' ))
		if !lRet
			cMsg := 'A prestação de conta já possui um título gerado.'
		endif

	endif
// ------------------------------------
	if !lRet
		help( '' , 1 , 'Help' , 'F040010108' , cMsg , 1 , 0 )
	endif
// ------------------------------------
return lRet

// ----------------------------------------------------------------------------
// {Protheus.doc} FilDados()
// Filtra informações do GetDados 
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version	P12.7
// @Project MAN00000463801_EF_001
// @Param   aCols1 - Acols do GetDados
// @return  Nil
// ----------------------------------------------------------------------------
static function fildados( aCols1 , cCodAnexo )
// ------------------------------------
	local   cQuery    := ''
	local   aArea     :=        getarea()
	local   aAreaSC1  := SC1->( getarea() )
	local   aAreaSC7  := SC7->( getarea() )
	local   aAreaSD1  := SD1->( getarea() )
	local   aAreaSF1  := SF1->( getarea() )
	local   aAreaSE2  := SE2->( getarea() )
	local   aAreaRC1  := RC1->( getarea() )
	local   cAliasTrb := getnextalias()
	local   cFunc     := funname()
	local   aFiltSC7  := {}
	local   aFiltSC1  := {}
// ------------------------------------
//  [ Inclusão do campo Data e Hora na tela de Banco de Conehcimento ]
// ------------------------------------
	local   cData := ''
// ------------------------------------

// ------------------------------------
//  [ Implementado por conta do ID 1539 para tratar notas migradas sem SD1 ]
// ------------------------------------
	local   lAchouD1  := .F. // Localizou SD1
	local   lXMIGLT   := .F. // Nota migrada
// ------------------------------------
	default cCodAnexo := ''
// ------------------------------------
	if alltrim( cFunc ) == 'MATA110'

		if !empty( SC1->C1_NUM )
			aadd( aFiltSC1 , SC1->C1_NUM )
			cQuery += QuerySC1( , aFiltSC1 , cQuery )
		endif

	elseif alltrim( cFunc ) $ 'MATA120|MATA121'

		if !empty( SC7->C7_NUM )
			aadd( aFiltSC7 , SC7->C7_NUM )
			cQuery += QuerySC7( , aFiltSC7 , cQuery )
		endif

		SC1->( dbsetorder( 6 )) // C1_FILIAL + C1_PEDIDO + C1_ITEMPED + C1_PRODUTO
		if SC1->( dbseek( fwxfilial( 'SC1' ) + SC7->C7_NUM ))

// ------------------------------------
//          cQuery += ' UNION '
// ------------------------------------
			if !empty( SC1->C1_NUM )
				aadd( aFiltSC1 , SC1->C1_NUM )
				cQuery += QuerySC1( , aFiltSC1 , cQuery )
			endif
// ------------------------------------
//          lSC1 := .T.
// ------------------------------------

		endif

	elseif alltrim( cFunc ) $ 'MATA103|MATA140|TEWBTYP3'

		if cFunc == 'MATA103'
			cQuery += QuerySF1( "'MATA103','MATA140','TEWBTYP3'" )
		else
			cQuery += QuerySF1( "'MATA140','TEWBTYP3'" )
		endif

		SC7->( dbsetorder( 1 )) // C7_FILIAL + C7_NUM + C7_ITEM  + C7_SEQUEN
		SD1->( dbsetorder( 1 )) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM

		aFiltSC7 := {}
		aFiltSC1 := {}

		if SD1->( dbseek( xfilial( 'SD1' ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )))

			do while SD1->( D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )

				if SC7->( dbseek( fwxfilial( 'SC7' ) + SD1->D1_PEDIDO )) // .AND. ! empty(QuerySC7(.T.,aFiltSC7))
// ------------------------------------
//                  cQuery += " UNION "
// ------------------------------------
					aadd( aFiltSC7 , SC7->C7_NUM )
// ------------------------------------
//                  cQuery += QuerySC7()
// ------------------------------------
				endif

				SC1->( dbsetorder( 6 )) // C1_FILIAL + C1_PEDIDO + C1_ITEMPED + C1_PRODUTO
				if SC1->( dbseek( fwxfilial( 'SC1' ) + SC7->C7_NUM ))
// ------------------------------------
//                  cQuery += " UNION "
// ------------------------------------
					aadd( aFiltSC1 , SC1->C1_NUM )
				endif
				SD1->( dbskip() )

			enddo

			if len( aFiltSC7 ) > 0
				cQuery += QuerySC7( , aFiltSC7 , cQuery )
			endif

			if len( aFiltSC1 ) > 0
				cQuery += QuerySC1( , aFiltSC1 , cQuery )
			endif

		endif

	elseif alltrim( cFunc ) $ 'FINA050' .OR. ;
			alltrim( cFunc ) $ 'FINA750'

		If SE2->E2_TIPO == "CX "
			cQuery += cQueryEU()
		Else
			cQuery += QuerySE2()
			SC7->( dbsetorder( 1 )) // C7_FILIAL + C7_NUM + C7_ITEM  + C7_SEQUEN
			SD1->( dbsetorder( 1 )) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
			SF1->( dbsetorder( 1 )) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO

			lAchouD1 := SD1->( dbseek( xfilial( 'SD1' ) + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )))

			if SF1->( dbseek( xfilial( 'SF1' ) + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )))
				if SF1->F1_XMIGLT <> ' '
					lXMIGLT := .T. // Nota migrada
				endif
			endif

// ------------------------------------
//      if SD1->( dbseek( xfilial( 'SD1' ) + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA ))) .AND. ;
//         SF1->( dbseek( xfilial( 'SF1' ) + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )))
// ------------------------------------
			if SF1->( dbseek( xfilial( 'SF1' ) + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA ))) .AND. ;
					( lXMIGLT .OR. lAchouD1 )
// ------------------------------------
//      if SF1->( dbseek( xfilial( 'SF1' ) + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )))
// ------------------------------------

				cQuery   += " UNION "
				cQuery   += QuerySF1( "'MATA103','MATA140','TEWBTYP3'" )
				aFiltSC7 := {}
				aFiltSC1 := {}

				do while SD1->( D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )

					if SC7->( dbseek( fwxfilial( 'SC7' ) + SD1->D1_PEDIDO ))

// ------------------------------------
//                  cQuery += " UNION "
// ------------------------------------
						aadd( aFiltSC7 , SC7->C7_NUM )
// ------------------------------------
//                  cQuery += QuerySC7()
// ------------------------------------
					endif

					SC1->( dbsetorder( 6 ))//  C1_FILIAL + C1_PEDIDO + C1_ITEMPED + C1_PRODUTO
					if SC1->( dbseek( fwxfilial( 'SC1' ) + SC7->C7_NUM ))
// ------------------------------------
//                  cQuery += " UNION "
// ------------------------------------
						aadd( aFiltSC1 , SC1->C1_NUM )
					endif

					SD1->( dbskip() )

				enddo

			else
				cQuery += " UNION "
				cQuery += QrySE2CN9( 'FINA050|FINA750' , ;
					SE2->E2_FILIAL    , ;
					SE2->E2_PREFIXO   , ;
					SE2->E2_NUM       , ;
					SE2->E2_TIPO      , ;
					SE2->E2_FORNECE     )
			endif

			if len( aFiltSC7 ) > 0
				cQuery += QuerySC7( , aFiltSC7 , cQuery )
			endif

			if len( aFiltSC1 ) > 0
				cQuery += QuerySC1( , aFiltSC1 , cQuery )
			endif

			RC1->( dbsetorder( 2 )) // RC1_FILIAL + RC1_FILTIT       + RC1_PREFIX + RC1_NUMTIT + RC1_TIPO + RC1_FORNEC
			if RC1->( dbseek(    xfilial( 'RC1' ) + SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM     + E2_TIPO  + E2_FORNECE )))
				cQuery += " UNION "
				cQuery += QueryRC1()
			endif

			cQuery += " UNION "
			cQuery += QueryLHP( SE2->E2_FILIAL  , ;
				SE2->E2_PREFIXO , ;
				SE2->E2_NUM     , ;
				SE2->E2_PARCELA , ;
				SE2->E2_TIPO    , ;
				SE2->E2_FORNECE , ;
				SE2->E2_LOJA      )
		EndIf
	elseif alltrim( cFunc ) $ 'FINA550'
		cQuery += QuerySET()

	elseif alltrim( cFunc ) $ 'GPEM660'
		cQuery += QueryRC1()

	elseif 'F0100401' $ alltrim( cFunc ) .Or. 'S0100401' $ alltrim( cFunc )
		cQuery += QuerySolPg()

	elseif alltrim( cFunc ) == 'AE_DESPV' .OR. ;
			alltrim( cFunc ) == 'AE_APVSOL'
		cQuery += QueryLHC(cFunc) // ticket n° 8943071

	elseif alltrim( cFunc ) = 'F0500101'
		cQuery += QueryP10( cCodAnexo )

	elseif alltrim( cFunc ) = 'F0100323' .OR. ;
			( 'F08010' $ alltrim( cFunc )) .OR. ;
			alltrim( cFunc ) = 'GPEM040' // ticket n° 12537523
		cQuery += QueryRH3( cCodAnexo )

	elseif ( alltrim( cFunc ) == 'CNTA300')
		cQuery += QueryCN9()

	elseif alltrim( cFunc ) == 'MATA094' .Or. alltrim( cFunc ) == 'XMATA094' .Or. allTrim( cfunc ) == 'XAPREPMED'
		cQuery += QuerySCR( alltrim( cFunc          ) , ;
			alltrim( SCR->CR_FILIAL ) , ;
			alltrim( SCR->CR_NUM    ) , ;
			alltrim( SCR->CR_TIPO   )   )
// ------------------------------------
//      alltrim( SC7->C7_XESPECI ) = 'CF'
// ------------------------------------

	elseif ( alltrim( cFunc ) == 'MATA460A' )
		cQuery += QuerySC9( alltrim( cFunc ) , ;
			SC9->C9_FILIAL   , ;
			SC9->C9_PEDIDO   , ;
			SC9->C9_ITEM     , ;
			SC9->C9_CLIENTE  , ;
			SC9->C9_LOJA     , ;
			SC9->C9_PRODUTO    )

	elseif ( alltrim( cFunc ) == 'FINA560')
// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*		
		cQuery += " SELECT P09.P09_CODDOC , "
		cQuery +=        " P09.P09_NOMDOC , "
		cQuery +=        " P09.P09_NIVEL  , "
		cQuery +=        " P09.P09_ROTINA "
		cQuery +=   " FROM "                   + retsqlname( 'P09' ) + " P09 "
		cQuery +=  " WHERE P09.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND P09.P09_FILIAL = '" +    xfilial( 'P09' ) + "' "
		cQuery +=    " AND P09_ROTINA     = '" +    alltrim( cFunc ) + "' "
		cQuery += " AND P09_CODORI = '"+AllTrim(SEU->EU_FILIAL)+AllTrim(SEU->EU_NUM)+"'"
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   14/002/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
			cQuery += " SELECT P09.P09_CODDOC , "
			cQuery +=        " P09.P09_NOMDOC , "
			cQuery +=        " P09.P09_NIVEL  , "
			cQuery +=        " P09.P09_ROTINA , "
			cQuery +=        " P09.P09_DTHORA "
			cQuery +=   " FROM "                   + retsqlname( 'P09' ) + " P09 "
			cQuery +=  " WHERE P09.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND P09.P09_FILIAL = '" +    xfilial( 'P09' ) + "' "
			cQuery +=    " AND P09_ROTINA     = '" +    alltrim( cFunc ) + "' "
			cQuery += " AND P09_CODORI = '"+AllTrim(SEU->EU_FILIAL)+AllTrim(SEU->EU_NUM)+"'"
// ------------------------------------

		ElseIf (Alltrim(cFunc) == "CNTA121")
			cQuery += " SELECT P09.P09_CODDOC , "
			cQuery +=        " P09.P09_NOMDOC , "
			cQuery +=        " P09.P09_NIVEL  , "
			cQuery +=        " P09.P09_ROTINA, "
			cQuery +=        " P09.P09_DTHORA "
			cQuery +=   " FROM "                   + retsqlname( 'P09' ) + " P09 "
			cQuery +=  " WHERE P09.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND P09.P09_FILIAL = '" +    xfilial( 'P09' ) + "' "
			cQuery +=    " AND P09_ROTINA     = '" +    alltrim( cFunc ) + "' "
			cQuery += " AND P09_CODORI = '"+CND->(CND_FILIAL+CND_NUMMED+CND_CONTRA+CND_REVISA)+"'"

		else

// ----------------------------------------------------------------------------    
//      [ RAFAEL FALCO - 24/05/2018                     ]
//      [ CASO NÃO EXISTA NENHUMA CONDIÇÃO SATISFATÓRIA ]
//      [ UTILIZAR A QUERY GENÉRICA PARA NÃO DAR ERRO   ]
// ----------------------------------------------------------------------------
// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*	
		cQuery := " SELECT P09.P09_CODDOC , "
		cQuery +=        " P09.P09_NOMDOC , "
		cQuery +=        " P09.P09_NIVEL  , "
		cQuery +=        " P09.P09_ROTINA "
		cQuery +=   " FROM "                   + retsqlname( 'P09' ) + " P09 "
		cQuery +=  " WHERE P09.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND P09.P09_FILIAL = '" +    xfilial( 'P09' ) + "' "
		cQuery +=    " AND P09_ROTINA     = '" +    alltrim( cFunc ) + "' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   14/002/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
			cQuery := " SELECT P09.P09_CODDOC , "
			cQuery +=        " P09.P09_NOMDOC , "
			cQuery +=        " P09.P09_NIVEL  , "
			cQuery +=        " P09.P09_ROTINA , "
			cQuery +=        " P09.P09_DTHORA "
			cQuery +=   " FROM "                   + retsqlname( 'P09' ) + " P09 "
			cQuery +=  " WHERE P09.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND P09.P09_FILIAL = '" +    xfilial( 'P09' ) + "' "
			cQuery +=    " AND P09_ROTINA     = '" +    alltrim( cFunc ) + "' "
// ------------------------------------
		endif

// ------------------------------------
		cQuery := changequery( cQuery ) //- Devido ID 1279
		dbUseArea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasTrb , .T. , .T. )
// ------------------------------------

		do while (cAliasTrb)->( !eof() )
			If !EMPTY((cAliasTrb)->P09_DTHORA)
				cData := TrataDtHr( (cAliasTrb)->P09_DTHORA )
			Endif
			aadd( aCols1 , {  cData, ;
				(cAliasTrb)->P09_NOMDOC , ;
				(cAliasTrb)->P09_ROTINA , ;
				(cAliasTrb)->P09_CODDOC , ;
				.F.                     } )
			(cAliasTrb)->( dbskip() )
		enddo

		if ( len( aCols1 ) == 0 )
// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*	
		aadd( aCols1 , { '' , '' , '' , .F. } )
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
			aadd( aCols1 , { '' , '' , '' , '' , .F. } )
// ------------------------------------
		endif

		restarea( aAreaRC1 )
		restarea( aAreaSC1 )
		restarea( aAreaSC7 )
		restarea( aAreaSD1 )
		restarea( aAreaSF1 )
		restarea( aAreaSE2 )

		(cAliasTrb)->( dbclosearea() )

		restarea( aArea )

		return

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySC1()
// Query para retornar dados anexados da rotina Solicitação de Compra.
// @Project MAN00000463801_EF_001
// @Author	Nairan Alves Silva
// @Since	15/09/2016
// @Version	P12.7
// @return	Nil
// ----------------------------------------------------------------------------
static function QuerySC1( lProc , aFilSc1 , cQuery )
// ------------------------------------
	local   I       := 1
	local   J       := 1
	local   cFilSC1 := '('
// ------------------------------------
	default lProc   := .F.
	default aFilSc1 := { '' }
// ------------------------------------
	if len( aFilSc1 ) > 0

		do while I <= len( aFilSc1 )

			J := 1

			do while J <= 999 .AND. I <= len( aFilSc1 )
				cFilSC1 += "'" + aFilSc1[I] + "',"
				J++
				I++
			enddo

			cFilSC1 := substring( cFilSC1 , 1 , len( cFilSC1 ) - 1 ) + ')'

			if !( empty( cQuery ))
				cQuery := " UNION "
			endif

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
			cQuery  += " SELECT P09_CODDOC , "
			cQuery  +=        " P09_NOMDOC , "
			cQuery  +=        " P09_NIVEL  , "
			cQuery  +=        " P09_ROTINA "
			cQuery  +=   " FROM "                + retsqlname( 'P09' ) + " "
			cQuery  +=  " WHERE P09_CODORI IN "  + cFilSC1
			cQuery  +=    " AND P09_FILIAL  = '" + SC1->C1_FILIAL      + "' "
			cQuery  +=    " AND P09_ROTINA  = 'MATA110' "
			cQuery  +=    " AND D_E_L_E_T_  = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
			cQuery  += " SELECT P09_CODDOC , "
			cQuery  +=        " P09_NOMDOC , "
			cQuery  +=        " P09_NIVEL  , "
			cQuery  +=        " P09_ROTINA , "
			cQuery  +=        " P09_DTHORA "
			cQuery  +=   " FROM "                + retsqlname( 'P09' ) + " "
			cQuery  +=  " WHERE P09_CODORI IN "  + cFilSC1
			cQuery  +=    " AND P09_FILIAL  = '" + SC1->C1_FILIAL      + "' "
			cQuery  +=    " AND P09_ROTINA  = 'MATA110' "
			cQuery  +=    " AND D_E_L_E_T_  = ' ' "
// ------------------------------------
			cFilSC1 := '('

		enddo

	endif

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySC7()
// Query para retornar dados anexados da rotina Pedido de Compra
// @Author	Nairan Alves Silva
// @Since	15/09/2016
// @Version	P12.7
// @Project MAN00000463801_EF_001
// @return	Nil
// ----------------------------------------------------------------------------
static function QuerySC7( lProc , aFilSc7 , cQuery )
// ------------------------------------
//  local   cAliasSC7 := getnextalias()
// ------------------------------------
	local   I         := 1
	local   J         := 1
	local   cFilSC7   := '('
// ------------------------------------
	default lProc     := .F.
	default aFilSc7   := { '' }
// ------------------------------------
	if len( aFilSc7 ) > 0

		do while I <= len( aFilSc7 )

			J := 1

			do while J <= 999 .AND. I <= len( aFilSc7 )
				cFilSC7 += "'" + aFilSc7[I] + "',"
				J++
				I++
			enddo

			cFilSC7 := substr( cFilSC7 , 1 , len( cFilSC7 ) -1 ) + ') '

			if !empty( cQuery )
				cQuery := " UNION "
			endif

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
			cQuery  += " SELECT   P09_CODDOC , "
			cQuery  +=          " P09_NOMDOC , "
			cQuery  +=          " P09_NIVEL  , "
			cQuery  +=          " P09_ROTINA "
			cQuery  +=   " FROM "                  + retsqlname( 'P09' ) + " "
			cQuery  +=  " WHERE   P09_CODORI IN "  + cFilSC7
			cQuery  +=    " AND   P09_FILIAL  = '" + SC7->C7_FILIAL       + "' "
			cQuery  +=    " AND ( P09_ROTINA  = 'MATA121' OR P09_ROTINA = 'F0100401' OR P09_ROTINA = 'S0100401') "
			cQuery  +=    " AND   D_E_L_E_T_  = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
			cQuery  += " SELECT   P09_CODDOC , "
			cQuery  +=          " P09_NOMDOC , "
			cQuery  +=          " P09_NIVEL  , "
			cQuery  +=          " P09_ROTINA , "
			cQuery  +=          " P09_DTHORA "
			cQuery  +=   " FROM "                  + retsqlname( 'P09' ) + " "
			cQuery  +=  " WHERE   P09_CODORI IN "  + cFilSC7
			cQuery  +=    " AND   P09_FILIAL  = '" + SC7->C7_FILIAL       + "' "
			cQuery  +=    " AND ( P09_ROTINA  = 'MATA121' OR P09_ROTINA = 'F0100401' OR P09_ROTINA = 'S0100401') "
			cQuery  +=    " AND   D_E_L_E_T_  = ' ' "
// ------------------------------------

			cFilSC7 := ' ('

		enddo

	endif

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySF1()
// Query para retornar dados anexados da rotina Documento de Entrada
// @Author	Nairan Alves Silva
// @Since	15/09/2016
// @Version	P12.7
// @Project MAN00000463801_EF_001
// @return	Nil
// ----------------------------------------------------------------------------
static function QuerySF1( cRotina )
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA "
	cQuery +=   " FROM "                + retsqlname( 'P09' )                               + " "
	cQuery +=  " WHERE P09_CODORI  = '" + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) + "' "
	cQuery +=    " AND P09_FILIAL  = '" + SF1->F1_FILIAL                                    + "' "
	cQuery +=    " AND P09_ROTINA IN (" + cRotina                                           + ") "
	cQuery +=    " AND D_E_L_E_T_  = ' ' "
*/
// ------------------------------------

// ------------------------------------
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA , "
	cQuery +=        " P09_DTHORA "
	cQuery +=   " FROM "                + retsqlname( 'P09' )                               + " "
	cQuery +=  " WHERE P09_CODORI  = '" + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) + "' "
	cQuery +=    " AND P09_FILIAL  = '" + SF1->F1_FILIAL                                    + "' "
	cQuery +=    " AND P09_ROTINA IN (" + cRotina                                           + ") "
	cQuery +=    " AND D_E_L_E_T_  = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySE2()
// Query para retornar dados anexados da rotina Contas a Pagar
// @Author  Nairan Alves Silva
// @Since	15/09/2016
// @Version	P12.7
// @Project MAN00000463801_EF_001
// @return	Nil
// ----------------------------------------------------------------------------
static function QuerySE2()
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT   P09_CODDOC , "
	cQuery +=          " P09_NOMDOC , "
	cQuery +=          " P09_NIVEL  , "
	cQuery +=          " P09_ROTINA "
	cQuery +=   " FROM "                 + retsqlname( 'P09' )                                 + " "
	cQuery +=  " WHERE   P09_CODORI = '" + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA ) + "' "
	cQuery +=    " AND   P09_FILIAL = '" + SE2->E2_FILIAL                                      + "' "
	cQuery +=    " AND ( P09_ROTINA = 'FINA050' OR P09_ROTINA = 'FINA750' ) "
	cQuery +=    " AND   D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT   P09_CODDOC , "
	cQuery +=          " P09_NOMDOC , "
	cQuery +=          " P09_NIVEL  , "
	cQuery +=          " P09_ROTINA , "
	cQuery +=          " P09_DTHORA "
	cQuery +=   " FROM "                 + retsqlname( 'P09' )                                 + " "
	cQuery +=  " WHERE   P09_CODORI = '" + SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA ) + "' "
	cQuery +=    " AND   P09_FILIAL = '" + SE2->E2_FILIAL                                      + "' "
	cQuery +=    " AND ( P09_ROTINA = 'FINA050' OR P09_ROTINA = 'FINA750' ) "
	cQuery +=    " AND   D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySET()
// Query para retornar dados anexados da rotina Caixinha
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @return  Nil
// ----------------------------------------------------------------------------
static function QuerySET()
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA "
	cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
	cQuery +=  " WHERE P09_CODORI = '" + SET->ET_CODIGO      + "' "
	cQuery +=    " AND P09_FILIAL = '" + SET->ET_FILIAL      + "' "
	cQuery +=    " AND P09_ROTINA = 'FINA550' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
	*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA , "
	cQuery +=        " P09_DTHORA "
	cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
	cQuery +=  " WHERE P09_CODORI = '" + SET->ET_CODIGO      + "' "
	cQuery +=    " AND P09_FILIAL = '" + SET->ET_FILIAL      + "' "
	cQuery +=    " AND P09_ROTINA = 'FINA550' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QueryRC1()
// Query para retornar dados anexados da rotina Manutenção de Benefícios
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @return  Nil
// ----------------------------------------------------------------------------
static function QueryRC1()
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA "
	cQuery +=   " FROM "               + retsqlname( 'P09' )                                        + " "
	cQuery +=  " WHERE P09_CODORI = '" + RC1->( RC1_FILTIT + RC1_CODTIT + RC1_PREFIX + RC1_NUMTIT ) + "' "
	cQuery +=    " AND P09_FILIAL = '" + RC1->RC1_FILTIT                                            + "' "
	cQuery +=    " AND P09_ROTINA = 'GPEM660' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA , "
	cQuery +=        " P09_DTHORA "
	cQuery +=   " FROM "               + retsqlname( 'P09' )                                        + " "
	cQuery +=  " WHERE P09_CODORI = '" + RC1->( RC1_FILTIT + RC1_CODTIT + RC1_PREFIX + RC1_NUMTIT ) + "' "
	cQuery +=    " AND P09_FILIAL = '" + RC1->RC1_FILTIT                                            + "' "
	cQuery +=    " AND P09_ROTINA = 'GPEM660' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySolPg()
// Query para retornar dados anexados da rotina Solicitação de Pagamento
// @Author  Nairan Alves Silva
// @Since   15/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @return  Nil
// ----------------------------------------------------------------------------
static function QuerySolPg()
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA "
	cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
	cQuery +=  " WHERE P09_CODORI = '" + SC7->C7_NUM         + "' "
	cQuery +=    " AND P09_FILIAL = '" + SC7->C7_FILIAL      + "' "
	cQuery +=    " AND P09_ROTINA = 'F0100401' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA , "
	cQuery +=        " P09_DTHORA "
	cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
	cQuery +=  " WHERE P09_CODORI = '" + SC7->C7_NUM         + "' "
	cQuery +=    " AND P09_FILIAL = '" + SC7->C7_FILIAL      + "' "
	cQuery +=    " AND P09_ROTINA IN ('F0100401','S0100401') "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QueryLHC()
// Query para retornar dados anexados da rotina Prestação de Contas
// @Author  Nairan Alves Silva
// @Since   20/09/2016
// @Version P12.7
// @Project MAN00000463801_EF_001
// @return  Nil
// ----------------------------------------------------------------------------
static function QueryLHC(cFunc)
// ------------------------------------
	local cQuery := ''
// ------------------------------------
// ticket n° 7094115 - 415966 -ponteirando registro 
	If  alltrim( cFunc ) == 'AE_APVSOL'	// ticket n° 8943071
		dbSelectArea("LHQ")
		LHQ->(dbSetOrder(1))
		LHQ->(DbSeek(xFilial('LHQ') + LHP->LHP_CODIGO))
	EndIf

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA "
	cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
	cQuery +=  " WHERE P09_CODORI = '" + LHQ->LHQ_CODIGO     + "' "
	cQuery +=    " AND P09_FILIAL = '" + LHQ->LHQ_FILIAL     + "' "
	cQuery +=    " AND P09_ROTINA = 'AE_DESPV' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09_CODDOC , "
	cQuery +=        " P09_NOMDOC , "
	cQuery +=        " P09_NIVEL  , "
	cQuery +=        " P09_ROTINA , "
	cQuery +=        " P09_DTHORA "
	cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
	cQuery +=  " WHERE P09_CODORI = '" + LHQ->LHQ_CODIGO     + "' "
	cQuery +=    " AND P09_FILIAL = '" + LHQ->LHQ_FILIAL     + "' "
	cQuery +=    " AND P09_ROTINA = 'AE_DESPV' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QueryLHP()
// Relaciona despesas de viagem com títulos a pagar.
// @Author  Paulo Krüger
// @Since   19/06/2017
// @Version P12.7
// @Project MAN00000463801_EF_001
// @return  Nil
// ----------------------------------------------------------------------------
static function QueryLHP( cE2_FILIAL , cE2_PREFIX , cE2_NUM , cE2_PARCEL , cE2_TIPO , cE2_FORNEC , cE2_LOJA )
// ------------------------------------
	local cQuery     := ''
	local cTPLPrefix := padr( supergetmv( 'MV_PREREEM' ) , tamsx3( 'E2_PREFIXO' )[1] )
	local cTPLTipo   := padr( supergetmv( 'MV_TIPREEM' ) , tamsx3( 'E2_TIPO'    )[1] )
// ------------------------------------
//  local cTPLParcel := padr( supergetmv( 'MV_PARREEM' ) , tamsx3( 'E2_PARCELA' )[1] )]
// ------------------------------------

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery +=         " SELECT P09.P09_CODDOC , "
	cQuery +=                " P09.P09_NOMDOC , "
	cQuery +=                " P09.P09_NIVEL  , "
	cQuery +=                " P09.P09_ROTINA   "
	cQuery +=           " FROM " + retsqlname( 'P09' ) + " P09 "
	cQuery +=     " INNER JOIN " + retsqlname( 'LHP' ) + " LHP "
	cQuery +=             " ON LHP.LHP_FILIAL = P09.P09_FILIAL "
	cQuery +=            " AND LHP.LHP_CODIGO = P09.P09_CODORI "
	if cE2_PREFIX == cTPLPrefix .AND. ;
			cTPLTipo   == cE2_TIPO
		cQuery += " INNER JOIN " + retsqlname( 'SE2' ) + " SE2 "
		cQuery +=         " ON SE2.E2_FILIAL  = LHP.LHP_FILIAL "
		cQuery +=        " AND SE2.E2_NUM     = LHP.LHP_CODIGO "
	else
		cQuery += " INNER JOIN " + retsqlname( 'SE2' ) + " SE2 "
		cQuery +=         " ON ( SE2.E2_FILIAL||SE2.E2_PREFIXO||SE2.E2_NUM||SE2.E2_PARCELA||SE2.E2_TIPO||SE2.E2_FORNECE|| SE2.E2_LOJA ) = LHP.LHP_DOCUME "
	endif
	cQuery +=          " WHERE P09.P09_FILIAL = '" + cE2_FILIAL + "' "
	cQuery +=            " AND P09.P09_ROTINA = 'AE_DESPV' "
	cQuery +=            " AND SE2.E2_FILIAL  = '" + cE2_FILIAL + "' "
	cQuery +=            " AND SE2.E2_PREFIXO = '" + cE2_PREFIX + "' "
	cQuery +=            " AND SE2.E2_NUM     = '" + cE2_NUM    + "' "
	cQuery +=            " AND SE2.E2_PARCELA = '" + cE2_PARCEL + "' "
	cQuery +=            " AND SE2.E2_TIPO    = '" + cE2_TIPO   + "' "
	cQuery +=            " AND SE2.E2_FORNECE = '" + cE2_FORNEC + "' "
	cQuery +=            " AND SE2.E2_LOJA    = '" + cE2_LOJA   + "' "
	cQuery +=            " AND P09.D_E_L_E_T_ = ' ' "
	cQuery +=            " AND LHP.D_E_L_E_T_ = ' ' "
	cQuery +=            " AND SE2.D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery +=         " SELECT P09.P09_CODDOC , "
	cQuery +=                " P09.P09_NOMDOC , "
	cQuery +=                " P09.P09_NIVEL  , "
	cQuery +=                " P09.P09_ROTINA , "
	cQuery +=                " P09.P09_DTHORA   "
	cQuery +=           " FROM " + retsqlname( 'P09' ) + " P09 "
	cQuery +=     " INNER JOIN " + retsqlname( 'LHP' ) + " LHP "
	cQuery +=             " ON LHP.LHP_FILIAL = P09.P09_FILIAL "
	cQuery +=            " AND LHP.LHP_CODIGO = P09.P09_CODORI "
	if cE2_PREFIX == cTPLPrefix .AND. ;
			cTPLTipo   == cE2_TIPO
		cQuery += " INNER JOIN " + retsqlname( 'SE2' ) + " SE2 "
		cQuery +=         " ON SE2.E2_FILIAL  = LHP.LHP_FILIAL "
		cQuery +=        " AND SE2.E2_NUM     = LHP.LHP_CODIGO "
	else
		cQuery += " INNER JOIN " + retsqlname( 'SE2' ) + " SE2 "
		cQuery +=         " ON ( SE2.E2_FILIAL||SE2.E2_PREFIXO||SE2.E2_NUM||SE2.E2_PARCELA||SE2.E2_TIPO||SE2.E2_FORNECE|| SE2.E2_LOJA ) = LHP.LHP_DOCUME "
	endif
	cQuery +=          " WHERE P09.P09_FILIAL = '" + cE2_FILIAL + "' "
	cQuery +=            " AND P09.P09_ROTINA = 'AE_DESPV' "
	cQuery +=            " AND SE2.E2_FILIAL  = '" + cE2_FILIAL + "' "
	cQuery +=            " AND SE2.E2_PREFIXO = '" + cE2_PREFIX + "' "
	cQuery +=            " AND SE2.E2_NUM     = '" + cE2_NUM    + "' "
	cQuery +=            " AND SE2.E2_PARCELA = '" + cE2_PARCEL + "' "
	cQuery +=            " AND SE2.E2_TIPO    = '" + cE2_TIPO   + "' "
	cQuery +=            " AND SE2.E2_FORNECE = '" + cE2_FORNEC + "' "
	cQuery +=            " AND SE2.E2_LOJA    = '" + cE2_LOJA   + "' "
	cQuery +=            " AND P09.D_E_L_E_T_ = ' ' "
	cQuery +=            " AND LHP.D_E_L_E_T_ = ' ' "
	cQuery +=            " AND SE2.D_E_L_E_T_ = ' ' "
// ------------------------------------

// ------------------------------------
//	cQuery := changequery( cQuery )
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QueryP10
// Query para retornar dados anexados da rotina Solicitação de Desligamento
// @type    function
// @author  alexandre.arume
// @since   14/10/2016
// @version 1.0
// @return  cQuery
// ----------------------------------------------------------------------------
static function QueryP10( cCodAnexo )
// ------------------------------------
	local   cQuery    := ''
// ------------------------------------
	default cCodAnexo := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery +=    " SELECT  P09_CODDOC , "
	cQuery +=           "  P09_NOMDOC , "
	cQuery +=           "  P09_NIVEL  , "
	cQuery +=           "  P09_ROTINA "
	cQuery +=      " FROM "                + retsqlname( 'P09' ) + " "
	if empty( cCodAnexo )
		cQuery += " WHERE  P09_CODORI = '" + P10->P10_CODRH3     + "' "
	else
		cQuery += " WHERE  P09_CODORI = '" + cCodAnexo           + "' "
	endif
	cQuery +=       " AND  P09_FILIAL = '" +      xfilial('P09') + "' "
	cQuery +=       " AND (P09_ROTINA = 'F0100323' OR P09_ROTINA = 'F0500101') "
	cQuery +=       " AND  D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery +=    " SELECT  P09_CODDOC , "
	cQuery +=           "  P09_NOMDOC , "
	cQuery +=           "  P09_NIVEL  , "
	cQuery +=           "  P09_ROTINA , "
	cQuery +=           "  P09_DTHORA "
	cQuery +=      " FROM "                + retsqlname( 'P09' ) + " "
	if empty( cCodAnexo )
		cQuery += " WHERE  P09_CODORI = '" + P10->P10_CODRH3     + "' "
	else
		cQuery += " WHERE  P09_CODORI = '" + cCodAnexo           + "' "
	endif
	cQuery +=       " AND  P09_FILIAL = '" +      xfilial('P09') + "' "
	cQuery +=       " AND (P09_ROTINA = 'F0100323' OR P09_ROTINA = 'F0500101') "
	cQuery +=       " AND  D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QueryRH3
// Query para retornar dados anexados da rotina Solicitações
// @type    function
// @author  alexandre.arume
// @since   14/10/2016
// @version 1.0
// @return  cQuery
// ----------------------------------------------------------------------------
static function QueryRH3( cCodAnexo )
// ------------------------------------
	local   cQuery    := ''
// ------------------------------------
	default cCodAnexo := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery +=    " SELECT  P09_CODDOC , "
	cQuery +=           "  P09_NOMDOC , "
	cQuery +=           "  P09_NIVEL  , "
	cQuery +=           "  P09_ROTINA "
	cQuery +=      " FROM "                + retsqlname( 'P09' ) + " "
	if empty( cCodAnexo )
		cQuery += " WHERE  P09_CODORI = '" + RH3->RH3_CODIGO     + "' "
	else
		cQuery += " WHERE  P09_CODORI = '" + cCodAnexo           + "' "
	endif
	cQuery +=       " AND  P09_FILIAL = '" + RH3->RH3_FILIAL     + "' "
	cQuery +=       " AND (P09_ROTINA = 'F0100323' OR P09_ROTINA = 'F0500101' OR P09_ROTINA = 'F0801005') "
	cQuery +=       " AND  D_E_L_E_T_ = ' ' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery +=    " SELECT  P09_CODDOC , "
	cQuery +=           "  P09_NOMDOC , "
	cQuery +=           "  P09_NIVEL  , "
	cQuery +=           "  P09_ROTINA , "
	cQuery +=           "  P09_DTHORA "
	cQuery +=      " FROM "                + retsqlname( 'P09' ) + " "
	if empty( cCodAnexo )
		cQuery += " WHERE  P09_CODORI = '" + RH3->RH3_CODIGO     + "' "
	else
		cQuery += " WHERE  P09_CODORI = '" + cCodAnexo           + "' "
	endif
	cQuery +=       " AND  P09_FILIAL = '" + RH3->RH3_FILIAL     + "' "
	cQuery +=       " AND (P09_ROTINA = 'F0100323' OR P09_ROTINA = 'F0500101' OR P09_ROTINA = 'F0801005') "
	cQuery +=       " AND  D_E_L_E_T_ = ' ' "
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QueryCN9()
// Query para retornar dados anexados da rotina Manutenção de Contratos (CNTA300)
// @Author  Rafael de Campos Falco
// @Since   25/05/2018
// @Version P12.7
// @Project MAN00000463801_EF_051
// @return  Nil
// ----------------------------------------------------------------------------
static function QueryCN9()

	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09.P09_CODDOC , "
	cQuery +=        " P09.P09_NOMDOC , "
	cQuery +=        " P09.P09_NIVEL  , "
	cQuery +=        " P09.P09_ROTINA "
	cQuery +=   " FROM "                    + retsqlname( 'P09' )        + " P09 "
	cQuery +=  " WHERE P09.D_E_L_E_T_  = ' ' "
	cQuery +=    " AND P09.P09_ROTINA  = 'CNTA300' "
	cQuery +=    " AND P09.P09_FILIAL  = '" + alltrim( CN9->CN9_FILIAL ) + "' "
	cQuery +=    " AND P09.P09_CODORI  = '" + alltrim( CN9->CN9_NUMERO ) + "' "
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/201824
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09.P09_CODDOC , "
	cQuery +=        " P09.P09_NOMDOC , "
	cQuery +=        " P09.P09_NIVEL  , "
	cQuery +=        " P09.P09_ROTINA , "
	cQuery +=        " P09.P09_DTHORA "
	cQuery +=   " FROM "                    + retsqlname( 'P09' )        + " P09 "
	cQuery +=  " WHERE P09.D_E_L_E_T_  = ' ' "
	cQuery +=    " AND P09.P09_ROTINA  = 'CNTA300' "
	cQuery +=    " AND P09.P09_FILIAL  = '" + alltrim( CN9->CN9_FILIAL ) + "' "
	cQuery +=    " AND P09.P09_CODORI  = '" + alltrim( CN9->CN9_NUMERO ) + "' "
// ------------------------------------
return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySCR
// Query para retornar dados anexados da rotina Liberação de Pedidos (MATA094).
// @Project MAN00000463801_EF_051
// @Author  Rafael de Campos Falco
// @Since   25/05/2018
// @Version P12.7
// @return  Nil
// ----------------------------------------------------------------------------
static function QuerySCR( cRotina , cSCRFil , cSCRNum , cSCRTipo )
// ------------------------------------
	local cQuery  := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	if ( cSCRTipo == 'CT' )

		cQuery += " SELECT P09.P09_CODDOC , "                       + PRX_LIN
		cQuery +=        " P09.P09_NOMDOC , "                       + PRX_LIN
		cQuery +=        " P09.P09_NIVEL  , "                       + PRX_LIN
		cQuery +=        " P09.P09_ROTINA "                         + PRX_LIN
		cQuery +=   " FROM " + retsqlname( 'CN9' ) + " CN9, "       + PRX_LIN
		cQuery +=              retsqlname( 'P09' ) + " P09 "        + PRX_LIN
		cQuery +=  " WHERE CN9.D_E_L_E_T_ = ' '	"                   + PRX_LIN
		cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                   + PRX_LIN
		cQuery +=    " AND CN9.CN9_FILIAL = '" + cSCRFil + "' "     + PRX_LIN
		cQuery +=    " AND CN9.CN9_NUMERO = '" + cSCRNum + "' "     + PRX_LIN
		cQuery +=    " AND P09.P09_FILIAL = CN9.CN9_FILIAL "        + PRX_LIN
		cQuery +=    " AND P09.P09_CODORI = CN9.CN9_NUMERO "        + PRX_LIN
		cQuery +=    " AND P09_ROTINA    IN ('CNTA300','MATA094') " + PRX_LIN

	elseif cSCRTipo $ ('PC|SC')

		cQuery += " SELECT DISTINCT   P09.P09_CODDOC , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_NOMDOC , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_NIVEL  , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_ROTINA "                                    + PRX_LIN
		cQuery +=            " FROM "                     + retsqlname( 'P09' ) + " P09 " + PRX_LIN
		if cSCRTipo = 'PC'
			cQuery +=   " LEFT JOIN "                     + retsqlname( 'SC7' ) + " SC7 " + PRX_LIN
			cQuery +=          " ON   SC7.D_E_L_E_T_ = ' ' "                              + PRX_LIN
			cQuery +=         " AND   SC7.C7_FILIAL  = '" + cSCRFil             + "' "    + PRX_LIN
			cQuery +=         " AND   SC7.C7_NUM     = '" + cSCRNum             + "' "    + PRX_LIN
		elseif cSCRTipo = 'SC'
			cQuery +=   " LEFT JOIN "                     + retsqlname( 'SC1' ) + " SC1 " + PRX_LIN
			cQuery +=          " ON   SC1.D_E_L_E_T_ = ' ' "                              + PRX_LIN
			cQuery +=         " AND   SC1.C1_FILIAL  = '" + cSCRFil             + "' "    + PRX_LIN
			cQuery +=         " AND   SC1.C1_NUM     = '" + cSCRNum             + "' "    + PRX_LIN
		endif
		cQuery +=           " WHERE   P09.D_E_L_E_T_ = ' ' "                              + PRX_LIN
// ----------------------------------------------------------------------------
//      cQuery +=             " AND  (P09.P09_CODORI = SC1.C1_NUM    OR P09.P09_CODORI = SC7.C7_NUM   ) "     + PRX_LIN
//      cQuery +=             " AND  (P09.P09_FILIAL = SC1.C1_FILIAL OR P09.P09_FILIAL = SC7.C7_FILIAL) "     + PRX_LIN
//      cQuery +=             " AND   P09_ROTINA    IN ('MATA110','MATA121','MATA120','MATA094','F0100401') " + PRX_LIN
// ----------------------------------------------------------------------------
		if cSCRTipo = 'SC'

			cQuery +=         " AND ((P09.P09_CODORI = SC1.C1_NUM    "                   + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC1.C1_FILIAL "                   + PRX_LIN
			cQuery +=         " AND   P09_ROTINA    IN ('MATA110'))  "                   + PRX_LIN
			cQuery +=          " OR  (P09.P09_CODORI = SC1.C1_NUM||'"  + cSCRTipo + "' " + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC1.C1_FILIAL "                   + PRX_LIN
			cQuery +=         " AND   P09_ROTINA     = 'MATA094')) "                     + PRX_LIN

		elseif cSCRTipo = 'PC'

			cQuery +=         " AND ((P09.P09_CODORI = SC7.C7_NUM "                        + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC7.C7_FILIAL "                     + PRX_LIN
			cQuery +=         " AND   P09_ROTINA    IN ('MATA121','MATA120','F0100401')) " + PRX_LIN
			cQuery +=          " OR  (P09.P09_CODORI = SC7.C7_NUM||'" + cSCRTipo + "' "    + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC7.C7_FILIAL "                     + PRX_LIN
			cQuery +=         " AND   P09_ROTINA     = 'MATA094')) "                       + PRX_LIN

		endif

	else
		alert( 'O Tipo ' + cSCRTipo + ' não é suportado para esta rotina!' )
	endif
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	if ( cSCRTipo == 'CT' )

		cQuery += " SELECT P09.P09_CODDOC , "                       + PRX_LIN
		cQuery +=        " P09.P09_NOMDOC , "                       + PRX_LIN
		cQuery +=        " P09.P09_NIVEL  , "                       + PRX_LIN
		cQuery +=        " P09.P09_ROTINA , "                       + PRX_LIN
		cQuery +=        " P09.P09_DTHORA " 						+ PRX_LIN
		cQuery +=   " FROM " + retsqlname( 'CN9' ) + " CN9, "       + PRX_LIN
		cQuery +=              retsqlname( 'P09' ) + " P09 "        + PRX_LIN
		cQuery +=  " WHERE CN9.D_E_L_E_T_ = ' '	"                   + PRX_LIN
		cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                   + PRX_LIN
		cQuery +=    " AND CN9.CN9_FILIAL = '" + cSCRFil + "' "     + PRX_LIN
		cQuery +=    " AND CN9.CN9_NUMERO = '" + cSCRNum + "' "     + PRX_LIN
		cQuery +=    " AND P09.P09_FILIAL = CN9.CN9_FILIAL "        + PRX_LIN
		cQuery +=    " AND P09.P09_CODORI = CN9.CN9_NUMERO "        + PRX_LIN
		cQuery +=    " AND P09_ROTINA    IN ('CNTA300','MATA094') " + PRX_LIN

	elseif cSCRTipo $ ('PC|SC')

		cQuery += " SELECT DISTINCT   P09.P09_CODDOC , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_NOMDOC , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_NIVEL  , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_ROTINA , "                                  + PRX_LIN
		cQuery +=                   " P09.P09_DTHORA "									  + PRX_LIN
		cQuery +=            " FROM "                     + retsqlname( 'P09' ) + " P09 " + PRX_LIN
		if cSCRTipo = 'PC'
			cQuery +=   " LEFT JOIN "                     + retsqlname( 'SC7' ) + " SC7 " + PRX_LIN
			cQuery +=          " ON   SC7.D_E_L_E_T_ = ' ' "                              + PRX_LIN
			cQuery +=         " AND   SC7.C7_FILIAL  = '" + cSCRFil             + "' "    + PRX_LIN
			cQuery +=         " AND   SC7.C7_NUM     = '" + cSCRNum             + "' "    + PRX_LIN
		elseif cSCRTipo = 'SC'
			cQuery +=   " LEFT JOIN "                     + retsqlname( 'SC1' ) + " SC1 " + PRX_LIN
			cQuery +=          " ON   SC1.D_E_L_E_T_ = ' ' "                              + PRX_LIN
			cQuery +=         " AND   SC1.C1_FILIAL  = '" + cSCRFil             + "' "    + PRX_LIN
			cQuery +=         " AND   SC1.C1_NUM     = '" + cSCRNum             + "' "    + PRX_LIN
		endif
		cQuery +=           " WHERE   P09.D_E_L_E_T_ = ' ' "                              + PRX_LIN
// ----------------------------------------------------------------------------
//      cQuery +=             " AND  (P09.P09_CODORI = SC1.C1_NUM    OR P09.P09_CODORI = SC7.C7_NUM   ) "     + PRX_LIN
//      cQuery +=             " AND  (P09.P09_FILIAL = SC1.C1_FILIAL OR P09.P09_FILIAL = SC7.C7_FILIAL) "     + PRX_LIN
//      cQuery +=             " AND   P09_ROTINA    IN ('MATA110','MATA121','MATA120','MATA094','F0100401') " + PRX_LIN
// ----------------------------------------------------------------------------
		if cSCRTipo = 'SC'

			cQuery +=         " AND ((P09.P09_CODORI = SC1.C1_NUM    "                   + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC1.C1_FILIAL "                   + PRX_LIN
			cQuery +=         " AND   P09_ROTINA    IN ('MATA110'))  "                   + PRX_LIN
			cQuery +=          " OR  (P09.P09_CODORI = SC1.C1_NUM||'"  + cSCRTipo + "' " + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC1.C1_FILIAL "                   + PRX_LIN
			cQuery +=         " AND   P09_ROTINA     = 'MATA094')) "                     + PRX_LIN

		elseif cSCRTipo = 'PC'

			cQuery +=         " AND ((P09.P09_CODORI = SC7.C7_NUM "                        + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC7.C7_FILIAL "                     + PRX_LIN
			cQuery +=         " AND   P09_ROTINA    IN ('MATA121','MATA120','F0100401','S0100401')) " + PRX_LIN
			cQuery +=          " OR  (P09.P09_CODORI = SC7.C7_NUM||'" + cSCRTipo + "' "    + PRX_LIN
			cQuery +=         " AND   P09.P09_FILIAL = SC7.C7_FILIAL "                     + PRX_LIN
			cQuery +=         " AND   P09_ROTINA     = 'MATA094')) "                       + PRX_LIN

		endif

	ElseIf cSCRTipo == "MD"

		cQuery := " SELECT P09.P09_CODDOC , "                       + PRX_LIN
		cQuery +=        " P09.P09_NOMDOC , "                       + PRX_LIN
		cQuery +=        " P09.P09_NIVEL  , "                       + PRX_LIN
		cQuery +=        " P09.P09_ROTINA, "                         + PRX_LIN
		cQuery +=        " P09.P09_DTHORA " 						+ PRX_LIN
		cQuery +=   " FROM " + retsqlname( 'CND' ) + " CND, "       + PRX_LIN
		cQuery +=              retsqlname( 'P09' ) + " P09 "        + PRX_LIN
		cQuery +=  " WHERE CND.D_E_L_E_T_ = ' '	"                   + PRX_LIN
		cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                   + PRX_LIN
		cQuery +=    " AND CND.CND_FILIAL = '" + cSCRFil + "' "     + PRX_LIN
		cQuery +=    " AND CND.CND_NUMMED = '" + AllTrim(cSCRNum) + "' "     + PRX_LIN
		//cQuery +=    " AND CND.CND_ALCAPR = 'B'"
		cQuery +=    " AND P09.P09_FILIAL = CND.CND_FILIAL "        + PRX_LIN
		cQuery +=    " AND P09.P09_CODORI LIKE  '"+cSCRFil+Alltrim(cSCRNum)+"%' "        + PRX_LIN
		cQuery +=    " AND P09_ROTINA    IN ('CNTA121') " + PRX_LIN

	else
		alert( 'O Tipo ' + cSCRTipo + ' não é suportado para esta rotina!' )
	endif

// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QuerySC9()
// Query para retornar dados anexados da rotina Documento de Saída
// @Author  Rafael de Campos Falco
// @Since   25/05/2018
// @Version P12.7
// @Project MAN00000463801_EF_051
// @return  Nil
// ----------------------------------------------------------------------------
static function QuerySC9( cRotina , cSc9_Fil , cSc9_Ped , cSc9_Ite , cSc9_Cli , cSc9_Lja , cSc9_Prd )
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09.P09_CODDOC , "                    + PRX_LIN
	cQuery +=        " P09.P09_NOMDOC , "                    + PRX_LIN
	cQuery +=        " P09.P09_NIVEL  , "                    + PRX_LIN
	cQuery +=        " P09.P09_ROTINA "                      + PRX_LIN
	cQuery +=   " FROM " + retsqlname( 'SC5' ) + " SC5, "    + PRX_LIN
	cQuery +=              retsqlname( 'CN9' ) + " CN9, "    + PRX_LIN
	cQuery +=              retsqlname( 'P09' ) + " P09  "    + PRX_LIN
	cQuery +=  " WHERE SC5.D_E_L_E_T_ = ' '	"                + PRX_LIN
	cQuery +=    " AND CN9.D_E_L_E_T_ = ' ' "                + PRX_LIN
	cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                + PRX_LIN
	cQuery +=    " AND SC5.C5_FILIAL  = '" + cSc9_Fil + "' " + PRX_LIN
	cQuery +=    " AND SC5.C5_NUM     = '" + cSc9_Ped + "' " + PRX_LIN
	cQuery +=    " AND CN9.CN9_FILIAL = SC5.C5_FILIAL  "     + PRX_LIN
	cQuery +=    " AND CN9.CN9_NUMERO = SC5.C5_MDCONTR "     + PRX_LIN
	cQuery +=    " AND P09.P09_FILIAL = CN9.CN9_FILIAL "     + PRX_LIN
	cQuery +=    " AND P09.P09_CODORI = CN9.CN9_NUMERO "     + PRX_LIN
	cQuery +=    " AND P09_ROTINA    IN ('CNTA300') "        + PRX_LIN
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09.P09_CODDOC , "                    + PRX_LIN
	cQuery +=        " P09.P09_NOMDOC , "                    + PRX_LIN
	cQuery +=        " P09.P09_NIVEL  , "                    + PRX_LIN
	cQuery +=        " P09.P09_ROTINA , "                    + PRX_LIN
	cQuery +=        " P09_DTHORA "  						 + PRX_LIN
	cQuery +=   " FROM " + retsqlname( 'SC5' ) + " SC5, "    + PRX_LIN
	cQuery +=              retsqlname( 'CN9' ) + " CN9, "    + PRX_LIN
	cQuery +=              retsqlname( 'P09' ) + " P09  "    + PRX_LIN
	cQuery +=  " WHERE SC5.D_E_L_E_T_ = ' '	"                + PRX_LIN
	cQuery +=    " AND CN9.D_E_L_E_T_ = ' ' "                + PRX_LIN
	cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                + PRX_LIN
	cQuery +=    " AND SC5.C5_FILIAL  = '" + cSc9_Fil + "' " + PRX_LIN
	cQuery +=    " AND SC5.C5_NUM     = '" + cSc9_Ped + "' " + PRX_LIN
	cQuery +=    " AND CN9.CN9_FILIAL = SC5.C5_FILIAL  "     + PRX_LIN
	cQuery +=    " AND CN9.CN9_NUMERO = SC5.C5_MDCONTR "     + PRX_LIN
	cQuery +=    " AND P09.P09_FILIAL = CN9.CN9_FILIAL "     + PRX_LIN
	cQuery +=    " AND P09.P09_CODORI = CN9.CN9_NUMERO "     + PRX_LIN
	cQuery +=    " AND P09_ROTINA    IN ('CNTA300') "        + PRX_LIN
// ------------------------------------

return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} QrySE2CN9()
// Query para retornar dados anexados da rotina Documento de Saída
// @Author  Rafael de Campos Falco
// @Since   25/05/2018
// @Version P12.7
// @Project MAN00000463801_EF_051
// @return  Nil
// ----------------------------------------------------------------------------
static function QrySE2CN9( cRotina , cSe2_Fil , cSe2_Prf , cSe2_Num , cSe2_Tip , cSe2_For )
// ------------------------------------
	local cQuery := ''

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT P09.P09_CODDOC , "                                              + PRX_LIN
	cQuery +=        " P09.P09_NOMDOC , "                                              + PRX_LIN
	cQuery +=        " P09.P09_NIVEL  , "                                              + PRX_LIN
	cQuery +=        " P09.P09_ROTINA   "                                              + PRX_LIN
	cQuery +=   " FROM " + retsqlname( 'SE2' ) + " SE2, "                              + PRX_LIN
	cQuery +=              retsqlname( 'CN9' ) + " CN9, "                              + PRX_LIN
	cQuery +=              retsqlname( 'P09' ) + " P09  "                              + PRX_LIN
	cQuery +=  " WHERE SE2.D_E_L_E_T_ = ' '	"                                          + PRX_LIN
	cQuery +=    " AND CN9.D_E_L_E_T_ = ' ' "                                          + PRX_LIN
	cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                                          + PRX_LIN
	cQuery +=    " AND SE2.E2_FILIAL  = '" + cSe2_Fil + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_NUM     = '" + cSe2_Num + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_PREFIXO = '" + cSe2_Prf + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_TIPO    = '" + cSe2_Tip + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_FORNECE = '" + cSe2_For + "' "                           + PRX_LIN
	cQuery +=    " AND CN9.CN9_FILIAL = SE2.E2_FILIAL  "                               + PRX_LIN
	cQuery +=    " AND CN9.CN9_NUMERO = SE2.E2_MDCONTR "                               + PRX_LIN
	cQuery +=    " AND CN9.CN9_REVISA = SE2.E2_MDREVIS "                               + PRX_LIN
	cQuery +=    " AND P09.P09_FILIAL = CN9.CN9_FILIAL "                               + PRX_LIN
	cQuery +=    " AND P09.P09_CODORI = CN9.CN9_NUMERO "                               + PRX_LIN
	cQuery +=    " AND P09_ROTINA    IN ('CNTA300', 'MATA110', 'MATA120', 'MATA121') " + PRX_LIN
*/
// ------------------------------------

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT P09.P09_CODDOC , "                                              + PRX_LIN
	cQuery +=        " P09.P09_NOMDOC , "                                              + PRX_LIN
	cQuery +=        " P09.P09_NIVEL  , "                                              + PRX_LIN
	cQuery +=        " P09.P09_ROTINA , "                                              + PRX_LIN
	cQuery +=        " P09.P09_DTHORA " 											   + PRX_LIN
	cQuery +=   " FROM " + retsqlname( 'SE2' ) + " SE2, "                              + PRX_LIN
	cQuery +=              retsqlname( 'CN9' ) + " CN9, "                              + PRX_LIN
	cQuery +=              retsqlname( 'P09' ) + " P09  "                              + PRX_LIN
	cQuery +=  " WHERE SE2.D_E_L_E_T_ = ' '	"                                          + PRX_LIN
	cQuery +=    " AND CN9.D_E_L_E_T_ = ' ' "                                          + PRX_LIN
	cQuery +=    " AND P09.D_E_L_E_T_ = ' ' "                                          + PRX_LIN
	cQuery +=    " AND SE2.E2_FILIAL  = '" + cSe2_Fil + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_NUM     = '" + cSe2_Num + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_PREFIXO = '" + cSe2_Prf + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_TIPO    = '" + cSe2_Tip + "' "                           + PRX_LIN
	cQuery +=    " AND SE2.E2_FORNECE = '" + cSe2_For + "' "                           + PRX_LIN
	cQuery +=    " AND CN9.CN9_FILIAL = SE2.E2_FILIAL  "                               + PRX_LIN
	cQuery +=    " AND CN9.CN9_NUMERO = SE2.E2_MDCONTR "                               + PRX_LIN
	cQuery +=    " AND CN9.CN9_REVISA = SE2.E2_MDREVIS "                               + PRX_LIN
	cQuery +=    " AND P09.P09_FILIAL = CN9.CN9_FILIAL "                               + PRX_LIN
	cQuery +=    " AND P09.P09_CODORI = CN9.CN9_NUMERO "                               + PRX_LIN
	cQuery +=    " AND P09_ROTINA    IN ('CNTA300', 'MATA110', 'MATA120', 'MATA121') " + PRX_LIN
// ------------------------------------
return cQuery

// ----------------------------------------------------------------------------
// {Protheus.doc} ValidArq
// Verifica se ja existe o arquivo.
// @author alexandre.arume
// @since  16/12/2016
// @param  cRotina, character, (Descrição do parâmetro)
// @param  cNomDoc, character, (Descrição do parâmetro)
// @return lRet, Se o arquivo é valido ou não
// ----------------------------------------------------------------------------
static function ValidArq( aDados , nOpc , cCodAnexo , aHeader )
// ------------------------------------
	local   lRet    := .T.
	local   cQuery  := ''
	local   cAlias  := getnextalias()
	local   cDocs   := ''
	local   nX      := 0
	local   lDel    := .F.
	local   lProc   := .F.
// ------------------------------------
	default aHeader := {}
// ------------------------------------
	if len( aDados ) > 0 .AND. nOpc == 3
		// BLOCO ORIGNIAL
		//cQuery := " SELECT DISTINCT P09_NOMDOC "
		//cQuery +=   " FROM "               + retsqlname( 'P09' )                        + " "
		//cQuery +=  " WHERE P09_FILIAL  = '" +  fwxfilial( 'P09' )                        + "' "
		//cQuery +=    " AND P09_ROTINA  = '" + aDados[01][02]                             + "' "
		//cQuery +=    " AND P09_CODORI  = '" + RetCodOri( aDados[01][02] , cCodAnexo)[01] + "' "
		//cQuery +=    " AND P09_NOMDOC IN ("

		cQuery := " SELECT DISTINCT P09_NOMDOC "
		cQuery +=   " FROM "               + retsqlname( 'P09' )                        + " "
		cQuery +=  " WHERE P09_FILIAL  = '" +  fwxfilial( 'P09' )                        + "' "
		cQuery +=    " AND P09_ROTINA  = '" + aDados[01][03]                             + "' "
		cQuery +=    " AND P09_CODORI  = '" + RetCodOri( aDados[01][03] , cCodAnexo)[01] + "' "
		cQuery +=    " AND P09_NOMDOC IN ("

// ------------------------------------
		for nX := 1 to len( aDados )

			//if aDados[nX][4]
			if aDados[nX][5]
				lDel := .T.
			else
				//if !empty( aDados[nX][3] )
				if !empty( aDados[nX][4] )
					lDel := .T.
				else
					lDel := .F.
				endif
			endif

			if !lDel
				//cQuery += "'" + retnomearq( aDados[nX][1] , 2) + "', "
				cQuery += "'" + retnomearq( aDados[nX][2] , 2) + "', "
				lProc  := .T.
			endif

		next nX
// ------------------------------------

		cQuery := left( cQuery , len( cQuery ) -2 ) + ')'
		cQuery += " AND D_E_L_E_T_ = ' ' "

// ------------------------------------
		if lProc
			cQuery := changequery( cQuery )
			dbusearea( .T. , 'TOPCONN' , TCGenQry( , , cQuery ) , cAlias , .F. , .T. )

			do while !(cAlias)->( eof() )
				cDocs += alltrim( (cAlias)->P09_NOMDOC ) + ', '
				lRet  := .F.
				(cAlias)->( dbskip() )
			enddo

			if ! empty( cDocs )
				help( '' , 1 , 'Help' , 'F040010109' , 'Os arquivos ' + left( cDocs , len( cDocs ) -2 ) + ' já foram inseridos.' , 1 , 0 )
			endif
		endif
// ------------------------------------
		if lRet               .AND. ;
				len( aHeader ) > 0 .AND. ;
				len( aDados  ) > 0

			lRet := .F.

			for nX := 1 to len( aDados )
				if !empty( aDados[nX][1] ) .AND. ;
						!( aDados[nX][len( aHeader ) + 1] )
					lRet := .T.
					exit
				endif
			next nX

			if !lRet
				help( '' , 1 , 'Help' , 'F040010110' , 'É necessário anexar ao menos um arquivo.' , 1 , 0 )
			endif

		endif
// ------------------------------------

	endif

return lRet

// ----------------------------------------------------------------------------

user function f0400108( cGet1 )
// ------------------------------------
	local lNomeValido := .T.
	local nHandle
	local nLength
	local nLenMB
	local cAviso      := 'Arquivo com tamanho superior a ' + cValToChar( nTamArquivo / 1000 ) + 'MB.'
// ------------------------------------

	if !( ':' $ cGet1 )
		cGet1 := oGet1:Buffer
	endif

	if "'" $ cGet1
		help( '' , 1 , 'Help' , 'F040010114' , 'Nome do arquivo com caractere inválido (Aspas simples).' , 1 , 0 , , , , , , { 'Renomeie o arquivo antes de anexar.' } )
		lNomeValido := .F.
// ------------------------------------
//  elseif !( ':' $ cGet1 )
//      help( '' , 1 , 'Help' , 'F040010114' , 'Arquivos do servidor Protheus não podem ser utilizados.' , 1 , 0 , , , , , , { 'Escolha um arquivo de sua máquina.' } )
//      lNomeValido := .F.
// ------------------------------------
	endif

// ------------------------------------
//  [ Tratamento de tamanho ]
// ------------------------------------
	if lNomeValido

		if !empty( alltrim( cGet1 ))

			if ( nHandle := fopen( cGet1 )) >= 0

				nLength := fseek( nHandle , 0 , 2 )
				nLenMB  := ( nLength / 1024 )       // Transformo em MegaByte

				if nLenMB >= nTamArquivo            // Verifico de nao passa MaxStringSize
					help( '' , 1 , 'Help' , 'F040010114' , cAviso , 1 , 0 , , , , , , { 'Escolha um arquivo de sua máquina com tamanho menor.' } )
					lNomeValido := .F.
				endif

			else
				help( '' , 1 , 'Help' , 'F040010114' , ' Falha na abertura do arquivo. ' , 1 , 0 , , , , , , { ' Verifique o caminho do arquivo, permissões necessárias.' } )
				lNomeValido := .F.
			endif
		endif
	endif

return lNomeValido

// ----------------------------------------------------------------------------
// {Protheus.doc} EnviaEmail
// Envia email para grupo financeiro quando não houver titulo amarrado
// ao documento de entrada.
// @author William Souza
// @since  16/04/2019
// ----------------------------------------------------------------------------
static function EnviaEmail()
// ------------------------------------
	local cSMTP      := alltrim( getmv( 'MV_RelseRV' )) // smtp.ig.com.br ou 200.181.100.51
	local cConta     := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
	local cPass      := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
	local cContaDes  := alltrim( getmv( 'FS_GRPFIN'  )) // email grupo financeiro
	local cAssunto   := 'Título não encontrado - Doc Entrada Nro: ' + SF1->F1_DOC + ' - ' + SF1->F1_SERIE
	local lConSMTP   := .F.
	local lEnvEmail  := .F.
	local cMensagem  := ''
	local cError     := ''
// ------------------------------------

	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP

// ------------------------------------
	if lConSMTP

		cMensagem := '<html>'
		cMensagem += '<head><title>' + alltrim( cAssunto ) + '</title></head>'
		cMensagem += '<body>'
		cMensagem += '<br>'
// ------------------------------------
//      cMensagem += 'Documento ('+SF1->F1_DOC+'), do Fornecedor ('+alltrim(Posicione('SA2',1 , xfilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA, 'A2_NOME'))+'), '
//      cMensagem += 'CNPJ ('+alltrim(Posicione('SA2',1 , xfilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA, 'A2_CGC')+'), foi inserido na Filial ('+fwxfilial('P09'))+') '
//      cMensagem += 'mas não foi encontrado. <br> Título em aberto para pagamento no módulo Financeiro.'
// ------------------------------------
		cMensagem += 'Um documento teve banco de conhecimento inserido e não possui título relacionado em aberto para pagamento no módulo financeiro:'
		cMensagem += '<br>'
		cMensagem += '<br>'
		cMensagem += 'Filial : ' + SF1->F1_FILIAL + ' - ' + fwfilialname()
		cMensagem += '<br>'
		cMensagem += 'Fornecedor : ' + ( posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SF1->F1_FORNECE + SF1->F1_LOJA , 'A2_NOME' ))
		cMensagem += '<br>'
		cMensagem += 'Código : ' + SF1->F1_FORNECE + ' - Loja : ' + SF1->F1_LOJA
		cMensagem += '<br>'
		cMensagem += 'CNPJ : ' + alltrim( posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SF1->F1_FORNECE + SF1->F1_LOJA , 'A2_CGC' ))
		cMensagem += '<br>'
		cMensagem += 'Documento: ' + SF1->F1_DOC
		cMensagem += '<br>'
		cMensagem += '</body>'
		cMensagem += '</html>'

		SEND MAIL FROM cConta TO cContaDes SUBJECT '[Bco Conhecimento] - ' + cAssunto BODY  cMensagem Result lEnvEmail

		if !lEnvEmail // Erro no envio do email
			Get Mail Error cError
			help( '' , 1 , 'Help' , 'F040010100' , 'Erro no envio do email: ' + cError + '. Favor reportar o erro para área de TI da Rede D´or..' , 1 , 0 )
		endif

		Disconnect SMTP Server

	else // Erro na conexao com o SMTP Server
		Get Mail Error cError
		help( '' , 1 , 'Help' , 'F040010100' , 'Erro na conexão SMTP: ' + cError + '. Favor reportar o erro para área de TI da Rede D´or..' , 1 , 0 )
	endif
// ------------------------------------

return

// ----------------------------------------------------------------------------
// {Protheus.doc} F1701103
// Função de encapsulamento de static function RetCodOri().
// @project
// @type    user function
// @author  Rafael Riego
// @since   01/11/2018
// @version 12.1.17
// @param   cFunName, character, nome da função em execução
// @return  RetCodOri(cFunName), retorno da função RetCodOri()
// ----------------------------------------------------------------------------
user function f1701103( cFunName )
	default cFunName := ''
return RetCodOri( cFunName , '' )

// ----------------------------------------------------------------------------
// {Protheus.doc} CopyConteu
// Função de encapsulamento de static function RetCodOri().
// @project
// @type    Static function
// @author  Rafael Riego
// @since   01/11/2018
// @version 12.1.17
// @param   cDirArq, character, diretório + nome do arquivo.extensao
// @return  array[1] = conteudo do arquivo, array[2] = tamanho do arquivo
// ----------------------------------------------------------------------------
user function CopyConteu( cDirArq )
// ------------------------------------
	local   cBuffer   := ''
	local   cConteudo := ''
	local   nDll      := -1
	local   nRet      := -1
	local   nBloco    := 10240
	local   nBytes    := 0
	local   nCodArq   := 0
	local   nTam      := 0
// ------------------------------------
	default cDirArq   := ''
// ------------------------------------
	if !( empty( cDirArq ))
// ------------------------------------
//      [ Versão para buscar DLL para gerar o Encode64 ]
//      [ U_xEncode64(cDirArq,@cBuffer,@nTam)          ]
//      [ cConteudo := cBuffer                         ]
// ------------------------------------
		nCodArq := fopen( cDirArq , 0 ) // Grava o ID do arquivo
// ------------------------------------
//      [ Le os bytes do arquivo que será enviado ao FLUIG. ]
// ------------------------------------
		do while ( nBytes := fread( @nCodArq , @cBuffer , @nBloco )) > 0 // Lê os bytes
			cConteudo += Encode64( cBuffer )
			nTam      := nTam + nBytes
		enddo

	endif

	fclose( nCodArq )

return { cConteudo , nTam }

Static Function cQueryEU()

	Local cQry := ""
	Local cAliasFina := GetNextAlias()
	Local cQuery := ''


	cQry := "SELECT * FROM SEU010 WHERE EU_FILIAL = '"+SE2->E2_FILIAL+"'"
	cQry += " AND EU_XNUMTIT = '"+SE2->E2_NUM+"'"

	If Select( cAliasFina ) > 0
		( cAliasFina )->( DbCloseArea() )
	EndIf
	TcQuery cQry Alias ( cAliasFina ) New
	cIn := "("
	While !( cAliasFina )->( Eof() )
		cIn := cIn + "'"+AllTrim(( cAliasFina )->EU_FILIAL) + AllTrim(( cAliasFina )->EU_NUM)+"',"
		( cAliasFina )->( DbSkip())
	EndDo

	cIn := cIn + "'"+SE2->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )+"')"

	// ticket n° 10956923 - quebrar a query para não estourar banco ORACLE
	cIn1 := Iif(len(cIn) > 20978, substr(cIn,1,20979)+")",substr(cIn,1,20979))
	cIn2 := "("+substr(cIn,20981)

// ------------------------------------
// BLOCO ORIGINAL
// ------------------------------------
/*
	cQuery += " SELECT   P09_CODDOC , "
	cQuery +=          " P09_NOMDOC , "
	cQuery +=          " P09_NIVEL  , "
	cQuery +=          " P09_ROTINA "
	cQuery +=   " FROM "                 + retsqlname( 'P09' )                                 + " "
	cQuery +=  " WHERE   P09_CODORI IN " + cIn + " "
	cQuery +=    " AND   P09_FILIAL = '" + SE2->E2_FILIAL                                      + "' "
	cQuery +=    " AND ( P09_ROTINA = 'FINA050' OR P09_ROTINA = 'FINA750' OR P09_ROTINA = 'FINA560' ) "
	cQuery +=    " AND   D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
*/

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   25/01/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Banco de Conhecimento. (campo: Data/Hora)
// ------------------------------------
	cQuery += " SELECT   P09_CODDOC , "
	cQuery +=          " P09_NOMDOC , "
	cQuery +=          " P09_NIVEL  , "
	cQuery +=          " P09_ROTINA , "
	cQuery +=          " P09_DTHORA "
	cQuery +=   " FROM "                 + retsqlname( 'P09' )                                 + " "
	cQuery +=  " WHERE   P09_CODORI IN " + cIn1 + " "

	If len(cIn1) > 20978
		cQuery +=    " OR    P09_CODORI IN " + cIn2 + " "
	EndIf

	cQuery +=    " AND   P09_FILIAL = '" + SE2->E2_FILIAL                                      + "' "
	cQuery +=    " AND ( P09_ROTINA = 'FINA050' OR P09_ROTINA = 'FINA750' OR P09_ROTINA = 'FINA560' ) "
	cQuery +=    " AND   D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
// ------------------------------------

// Fim - ticket n° 10956923

Return cQuery

Static Function fEnvTit(oDad550,nOpc550,lRet550,cCod550)

	Local aArea := GetArea()
	Local cQuery := ""
	Local cP09Alias := GetNextAlias()
	local   aAttach   := {}
	local   aDados    := aclone( oDad550:aCols   )
	local   aHeader   := aclone( oDad550:aHeader )
	local   cArqRed   := '\RDANEXOS\'
	local   cArqLoc   := gettemppath()
	local   cWebAnexo := '\WEBANEXOS\'
	local   cRet      := ''
	local   nRet      := 0
	local   lRet      := .T.
	local   nHdl      := 0
	local   cNArq     := '' // alltrim(substr(cFile,rAt('\', cFile) + 1,50))
	local   nX        := 0
	local   cCodigo   := ''
	local   cNivel    := RetNvlTor()
	local   cMsg      := 'Não foi possível realizar a operação.'
	local   cContArq  := ''
	local   aContArq  := {}
	local   nTamArq   := 0
// ------------------------------------
	default lRetInc   := .F.
	Default nOpc := 3
// ------------------------------------


	/*/BEGIN TRANSACTION

	if nOpc550 == 3

		for nX := 1 to len( aDados )

			if aDados[nX][len( aHeader ) + 1] .OR. ;
					!empty( aDados[nX][3] )        .OR. ;
					empty( aDados[nX][1] )
				Loop
			endif

			lRetInc := .T.
			cNArq   := retnomearq( aDados[nX][01] , 2 )
			cCodigo := getsxenum( 'P09' , 'P09_CODDOC' )

			reclock( 'P09' , .T. )
			P09->P09_FILIAL := fwxfilial( 'P09' )
			P09->P09_CODDOC := cCodigo
			P09->P09_NOMDOC := cNArq
			P09->P09_DTHORA := dtos( date() ) + strtran( time() , ':' , '' )
			P09->P09_NIVEL  := cNivel
			P09->P09_CODORI := RetCodFina()
			P09->P09_ROTINA := "FINA050"
			P09->( msunlock() )

			aContArq := u_copyconteu( aDados[nX][01] )
			cContArq := aContArq[1]
			nTamArq  := aContArq[2]

			aadd( aAttach , { cNArq , cContArq , nTamArq } )

// ----------------------------------------------------------------------------
//                      [ Verifica se há título a pagar recusado.                        ]
//                      [ Se houver, altera o status de R (recusado) para C (corrigido). ]
//                      [ Parâmetros:                                                    ]
//                      [ 01 - Filial                                                    ]
//                      [ 02 - Rotina                                                    ]
//                      [ 03 - Origem                                                    ]
// ----------------------------------------------------------------------------

			u_f010101I( fwxfilial( 'P09' ), ;
				"FINA050"            , ;
				RetCodFina())

			if !lRmtHTM

				cRet := mscompress( aDados[nX][01]                                  , ;
					cArqLoc + fwxfilial( 'P09' ) + cCodigo + '.MZP' , ;
					DF_SENHA                                          )
				nHdl := fopen( cRet )

				if nHdl == -1
					ROLLBACKSX8()
					DISARMTRANSACTION()
					lRet := .F.
					exit
				else
					fclose( nHdl )
					if !( cpyt2s( cArqLoc + fwxfilial( 'P09' ) + cCodigo + '.MZP' , cArqRed ))
						ROLLBACKSX8()
						DISARMTRANSACTION()
						lRet := .F.
						exit
					else
						ferase( cRet )
					endif
				endif

			else

				if !( cpyt2s( aDados[nX][01] , cWebAnexo ))
					cMsg := 'Problemas na copia do arquivo por WEB.'
					ROLLBACKSX8()
					DISARMTRANSACTION()
					lRet := .F.
					exit
				endif

				cRet := mscompress( cWebAnexo + retnomearq( aDados[nX][1] , 2 ) , ;
					cArqRed   + fwxfilial( 'P09' ) + cCodigo + '.MZP' , DF_SENHA )
				ferase( cWebAnexo + retnomearq( aDados[nX][1] , 2 ))

				if empty( cRet )
					cMsg := 'Problemas no tratamento de arquivo por WEB.'
					ROLLBACKSX8()
					DISARMTRANSACTION()
					lRet := .F.
					exit
				endif

			endif

			CONFIRMSX8()

		next nX

	else

		for nX := 1 to len( aDados )

			if aDados[nX][len(aHeader) + 1]

				cCodigo := aDados[nX][03]
				nHdl    := ferase( cArqRed + fwxfilial( 'P09' ) + cCodigo + '.MZP' )

				if P09->( dbseek( fwxfilial( 'P09' ) + cCodigo ))
					reclock( 'P09' , .F. )
					P09->( dbdelete() )
					P09->( msunlock() )
				endif

			endif

		next nX

	endif

	END TRANSACTION/*/

	fAtStatusE2()




	RestArea(aArea)
Return

Static Function fExclTit(oDad550,nOpc550,lRet550,cCod550)

	/*/Local cQuery := ""
	Local cAliasFina := GetNextAlias()
	local cArqRed   := '\RDANEXOS\'
	Local cRet := ""
	Local cAliasP09 := GetNextAlias()


	cQuery := " SELECT * FROM " + retsqlname("SE2")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '" + SEU->EU_FILIAL + "'"
	cQuery += " AND E2_NUM = '" + SEU->EU_XNUMTIT + "'"
	cQuery += " AND E2_TIPO = 'CX'"

	If Select( cAliasFina ) > 0
		( cAliasFina )->( DbCloseArea() )
	EndIf
	TcQuery cQuery Alias ( cAliasFina ) New
	While !( cAliasFina )->( Eof() )
		cRet    := ( cAliasFina )->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )

		cQuery := " SELECT * FROM " + retsqlname("P09")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND P09_CODORI = '" + cRet + "'"
		cQuery += " AND P09_FILIAL = '" + (cAliasFina)->E2_FILIAL + "'"

		If Select( cAliasP09 ) > 0
			( cAliasP09 )->( DbCloseArea() )
		EndIf
		TcQuery cQuery Alias ( cAliasP09 ) New

		If !( cAliasP09 )->( Eof() )

			BEGIN TRANSACTION

				cCodigo := ( cAliasP09 )->P09_CODDOC
				nHdl    := ferase( cArqRed + ( cAliasP09 )->P09_CODDOC + '.MZP' )

				if P09->( dbseek( fwxfilial( 'P09' ) + ( cAliasP09 )->P09_CODDOC ))
					reclock( 'P09' , .F. )
					P09->( dbdelet5e() )
					P09->( msunlock() )
				endif

			END TRANSACTION

		EndIf
		( cAliasP09 )->( DbCloseArea() )
		(cAliasFina)->(DbSkip())
	End
	( cAliasFina )->( DbCloseArea() )


/*/

return

Static Function RetCodFina()

	Local aArea := GetArea()
	Local cAliasFina := GetNextAlias()
	Local cQuery := ""
	Local cRet := ""


	cQuery := " SELECT * FROM " + retsqlname("SE2")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '" + SEU->EU_FILIAL + "'"
	cQuery += " AND E2_NUM = '" + SEU->EU_XNUMTIT + "'"
	cQuery += " AND E2_TIPO = 'CX'"

	If Select( cAliasFina ) > 0
		( cAliasFina )->( DbCloseArea() )
	EndIf
	TcQuery cQuery Alias ( cAliasFina ) New
	If !( cAliasFina )->( Eof() )
		cRet    := ( cAliasFina )->( E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )
	EndIf
	( cAliasFina )->( DbCloseArea() )

	RestArea(aArea)
Return cRet

Static Function fAtStatusE2()

	Local aArea := GetArea()
	Local cUpdate := ""


	cUpdate := " UPDATE " + retsqlname("SE2") +  " SET E2_XSTRECU = 'C'"
	cUpdate += " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '" + SEU->EU_FILIAL + "'"
	cUpdate += " AND E2_NUM = '" + SEU->EU_XNUMTIT + "'"
	cUpdate += " AND E2_XSTRECU = 'R'"
	cUpdate += " AND E2_TIPO = 'CX'"

	If TcSQLExec( cUpdate ) != 0
		Conout("Erro ao tentar atualizar a tabela SE2" + CRLF + TcSQLError())
	Else
		SE2->(dbCommit())
	EndIf

	RestArea(aArea) //Thais Paiva - 16424543
Return

/*/{Protheus.doc} FLIMPAESP
Início - Thais Paiva - 8004071
Função para limpar caracteres especiais.
/*/
Static Function FLIMPAESP(_cCampo)
	Local aArea := GetArea()
	Local cConteudo := _cCampo
	Local _cCarEsp1	:= Alltrim(SuperGetMV('MV_XCARES1',.F.,"")) //Thais Paiva - 16424543
	Local _cCarEsp2	:= Alltrim(SuperGetMV('MV_XCARES2',.F.,"")) //Thais Paiva - 16424543
	Local _aCarEsp1 := {} //Thais Paiva - 16424543
	Local _aCarEsp2 := {} //Thais Paiva - 16424543
	Local _nC := 0 //Thais Paiva - 16424543

	_aCarEsp1 := StrTokArr( Alltrim(_cCarEsp1), ";" ) //Thais Paiva - 16424543
	_aCarEsp2 := StrTokArr( Alltrim(_cCarEsp2), ";" ) //Thais Paiva - 16424543

//Retirando caracteres
	cConteudo := StrTran(cConteudo, "'", "")
	cConteudo := StrTran(cConteudo, "#", "")
	cConteudo := StrTran(cConteudo, "%", "")
	cConteudo := StrTran(cConteudo, "*", "")
	cConteudo := StrTran(cConteudo, "&", "E")
	cConteudo := StrTran(cConteudo, ">", "")
	cConteudo := StrTran(cConteudo, "<", "")
	cConteudo := StrTran(cConteudo, "!", "")
	cConteudo := StrTran(cConteudo, "@", "")
	cConteudo := StrTran(cConteudo, "$", "")
	cConteudo := StrTran(cConteudo, "(", "")
	cConteudo := StrTran(cConteudo, ")", "")
	cConteudo := StrTran(cConteudo, "_", "")
	cConteudo := StrTran(cConteudo, "=", "")
	cConteudo := StrTran(cConteudo, "+", "")
	cConteudo := StrTran(cConteudo, "{", "")
	cConteudo := StrTran(cConteudo, "}", "")
	cConteudo := StrTran(cConteudo, "[", "")
	cConteudo := StrTran(cConteudo, "]", "")
	cConteudo := StrTran(cConteudo, "/", "")
	cConteudo := StrTran(cConteudo, "?", "")
	cConteudo := StrTran(cConteudo, "\", "")
	cConteudo := StrTran(cConteudo, "|", "")
	cConteudo := StrTran(cConteudo, ":", "")
	cConteudo := StrTran(cConteudo, ";", "")
	cConteudo := StrTran(cConteudo, '"', "")
	cConteudo := StrTran(cConteudo, "°", "")
	cConteudo := StrTran(cConteudo, "ª", "")
	cConteudo := StrTran(cConteudo, ",", "")
	cConteudo := StrTran(cConteudo, "-", "")
	cConteudo := StrTran(cConteudo, "ç", "c")
	cConteudo := StrTran(cConteudo, "Ç", "C")
	cConteudo := StrTran(cConteudo, "~", "")
	cConteudo := StrTran(cConteudo, "^", "")
	cConteudo := StrTran(cConteudo, "´", "")
	cConteudo := StrTran(cConteudo, "`", "")
	cConteudo := StrTran(cConteudo, "ã", "a")
	cConteudo := StrTran(cConteudo, "Ã", "A")
	cConteudo := StrTran(cConteudo, "â", "a")
	cConteudo := StrTran(cConteudo, "Â", "a")
	cConteudo := StrTran(cConteudo, "á", "a")
	cConteudo := StrTran(cConteudo, "Á", "A")
	cConteudo := StrTran(cConteudo, "à", "a")
	cConteudo := StrTran(cConteudo, "À", "A")
	cConteudo := StrTran(cConteudo, "é", "e")
	cConteudo := StrTran(cConteudo, "É", "E")
	cConteudo := StrTran(cConteudo, "ê", "e")
	cConteudo := StrTran(cConteudo, "Ê", "E")
	cConteudo := StrTran(cConteudo, "í", "i")
	cConteudo := StrTran(cConteudo, "Í", "I")
	cConteudo := StrTran(cConteudo, "ì", "i")
	cConteudo := StrTran(cConteudo, "Ì", "I")
	cConteudo := StrTran(cConteudo, "î", "i")
	cConteudo := StrTran(cConteudo, "Î", "I")
	cConteudo := StrTran(cConteudo, "î", "i")
	cConteudo := StrTran(cConteudo, "Î", "I")
	cConteudo := StrTran(cConteudo, "...", ".")
	cConteudo := StrTran(cConteudo, "..", ".")
	cConteudo := StrTran(cConteudo, "–", " ")
//Início - Thais Paiva - 16424543
	If Len(_aCarEsp1) > 0
		For _nC := 1 to Len(_aCarEsp1)
			cConteudo := StrTran(cConteudo, _aCarEsp1[_nC], "")
		Next _nC
	ElseIf !Empty(Alltrim(_cCarEsp1)) .AND. Len(_aCarEsp1) == 0
		cConteudo := StrTran(cConteudo, Alltrim(_cCarEsp1), "")
	EndIf
	If Len(_aCarEsp2) > 0
		For _nC := 1 to Len(_aCarEsp2)
			cConteudo := StrTran(cConteudo, _aCarEsp2[_nC], "")
		Next _nC
	ElseIf !Empty(Alltrim(_cCarEsp2)) .AND. Len(_aCarEsp2) == 0
		cConteudo := StrTran(cConteudo, Alltrim(_cCarEsp2), "")
	EndIf
//Fim - Thais Paiva - 16424543
	cConteudo := Alltrim(cConteudo)

	RestArea(aArea)
Return cConteudo
//Fim - Thais Paiva - 8004071
// ----------------------------------------------------------------------------
// [ fim de f0400101.prw ]
// ----------------------------------------------------------------------------





/*/{Protheus.doc} TrataDtHr

Função que realiza do tratamento do campo P09_DTHORA, pois o mesmo esta sendo gravado como texto no formato aaaammddhhmmss

@type function
@version  
@author Sato
@since 24/01/2024
@param cConteudo, character, Variável que irá receber o conteúdo do campo P09_DTHORA para ser convertido
@return cTexto, character, Variável que irá receber o conteúdo do campo P09_DTHORA convertido no formato dd/mm/aaaa hh:mm:ss
/*/
Static Function TrataDtHr(cConteudo as character)

	Local aArea as array
	Local cData as character
	Local cHora as character
	Local cTexto as character

	Default cConteudo := '' 	// cConteudo := '20231031170847'

	aArea := GetArea()

// Realiza a conversão do conteudo do campo P09_DTHORA (STRING), para o formato de data "dd/mm/aaaa"
	cData := substr(cConteudo,7,2)+"/"+substr(cConteudo,5,2)+"/"+substr(cConteudo,1,4)

// Realiza a conversão do conteudo do campo P09_DTHORA (STRING), para o formato de hora "hh:mm:ss"
	cHora := substr(cConteudo,9,2)+":"+substr(cConteudo,11,2)+":"+substr(cConteudo,13,2)

// Realiza a concatenação das variáveis cData e cHora para ser exibida da seguinte maneira : "dd/mm/aaaa hh:mm:ss"
	cTexto := cData+' '+cHora

	RestArea(aArea)

Return cTexto

//Fim - Thais Paiva - 8004071

//Função para gravar o campo de anexo na SP
//Lucas Miranda 04/09/2024
Static Function fAltSP(cOper,cRotina)

	Local nRecBkp := 0
	Local cFilC7  := ""
	Local cNumC7  := ""
	Local cQuery := ""
	Local cAliasC7 := GetNextAlias()
	If Alltrim(cRotina) == "MATA120" .Or. AllTrim(cRotina) == "MATA121" .Or. AllTrim(cRotina) $  "F0100401|S0100401"

		If SC7->C7_XSOLPAG == "1"
			If cOper == "I"
				nRecBkp := SC7->(RECNO())
				cFilC7 := SC7->C7_FILIAL
				cNumC7 := SC7->C7_NUM
				DbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				If SC7->(DbSeek(SC7->C7_FILIAL+SC7->C7_NUM))
					While SC7->(!EOF()) .AND. SC7->C7_FILIAL == cFilC7 .AND. SC7->C7_NUM == cNumC7
						Reclock("SC7",.F.)
						SC7->C7_XANEXO := "SIM"
						SC7->(MsUnlock())
						SC7->(DbSkip())
					EndDo
				EndIf
			Else
				nRecBkp := SC7->(RECNO())
				cQuery += " SELECT SC7.C7_NUM "
				cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
				cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
				cQuery += " AND SC7.R_E_C_N_O_ = "+cValToChar(SC7->(Recno()))+" "
				cQuery += " AND SC7.C7_XSOLPAG = '1'"
				cQuery += " AND NOT EXISTS (
				cQuery += " SELECT 1 FROM " +  RetSqlName("P09") + " P09 WHERE P09.D_E_L_E_T_ = ' ' AND P09.P09_FILIAL = SC7.C7_FILIAL AND P09.P09_CODORI = SC7.C7_NUM)"

				DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAliasC7, .T., .T.)

				If (cAliasC7)->(!Eof())
					cFilC7 := SC7->C7_FILIAL
					cNumC7 := SC7->C7_NUM
					DbSelectArea("SC7")
					SC7->(DbSetOrder(1))
					If SC7->(DbSeek(SC7->C7_FILIAL+SC7->C7_NUM))
						While SC7->(!EOF()) .AND. SC7->C7_FILIAL == cFilC7 .AND. SC7->C7_NUM == cNumC7
							Reclock("SC7",.F.)
							SC7->C7_XANEXO := "NAO"
							SC7->(MsUnlock())
							SC7->(DbSkip())
						EndDo
					EndIf
				EndIf
				(cAliasC7)->(dbclosearea())
			EndIf
			SC7->(DbGoto(nRecBkp))
		EndIf
	EndIf

Return
// ----------------------------------------------------------------------------
// [ fim de f0400101.prw ]
// ----------------------------------------------------------------------------

