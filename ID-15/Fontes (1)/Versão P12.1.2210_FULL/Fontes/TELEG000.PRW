#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TBICONN.CH'
#INCLUDE  'TOPCONN.CH'
#INCLUDE   'RWMAKE.CH'

user function teleg000()

// --------------------------
    local   aRotAdic := {}
//  local   bPre     := { || u_teleg001() } //{ || msgalert( 'Chamada antes da função'   )       }
    local   bOK      := { || msgalert( 'Chamada ao clicar em OK'   ) , .T. }
    local   bTTS     := { || msgalert( 'Chamada durante transacao' )       }
    local   bNoTTS   := { || u_teleg002() } //{ || msgalert( 'Chamada após transacao'    )       }
    local   aButtons := {} // adiciona botões na tela de inclusão, alteração, visualização e exclusao
// --------------------------
//  dbselectarea( 'TM0' )
    private cFicFil  := TM0->TM0_FILIAL
    private cFicNum  := TM0->TM0_NUMFIC
    private cFicNom  := TM0->TM0_NOMFIC
//  private cFicCod  := getsxenum( 'ZZZ' , 'ZZZ_COD' )
    private aCampos  := { 'ZZZ_FILIAL' , ;
                          'ZZZ_FICHA'  , ;
                          'ZZZ_NOMFIC' , ;
                          'ZZZ_COD'    , ;
                          'ZZZ_DATA'   , ;
                          'ZZZ_HRENV'  , ;
                          'ZZZ_MOTENV'   }
// --------------------------
//    private aRotina  := { { 'Procurar'    , 'AxPesqui' , 0 , 1 } , ;
//                          { 'Visualizar'  , 'AxVisual' , 0 , 2 } , ;
//                          { 'Incluir'     , 'AxInclui' , 0 , 3 } , ;
//                          { 'Alterar'     , 'AxAltera' , 0 , 4 } , ;
//                          { 'Excluir'     , 'AxDeleta' , 0 , 5 } }
// --------------------------
//    alert( 'TM0->TM0_FILIAL -> ' + TM0->TM0_FILIAL + ' <-' )
//    alert( 'TM0->TM0_NUMFIC -> ' + TM0->TM0_NUMFIC + ' <-' )
// --------------------------
    dbselectarea( 'ZZZ' )
    dbsetorder( 1 ) // ZZZ_FILIAL + ZZZ_COD + ZZZ_FICHA
    set filter to ZZZ->ZZZ_FILIAL = cFicFil .AND. ;
                  ZZZ->ZZZ_FICHA  = cFicNum
// --------------------------
    aadd( aButtons , { 'PRODUTO' , { || msgalert( 'Teste' ) } , 'Teste' , 'Botão Teste' } ) // adiciona chamada no aRotina
//  aadd( aRotAdic , { 'Adicional' , 'u_adic'       , 0 , 6 } )
    aadd( aRotAdic , { 'Relatório' , 'u_teleg005()' , 0 , 6 } )
// --------------------------
//    axcadastro( 'ZZZ'       , ; // alias 
//                'Telegrama' , ; // titulo
//                'u_delok()' , ; // funcao delete
//                'u_cok()'     ) // funcao ok
// --------------------------                
    axcadastro( 'ZZZ'       , ; // alias 
                'Telegrama' , ; // titulo
                'u_delok()' , ; // funcao delete
                'u_cok()'   , ; // funcao ok
                arotadic    , ; // rotinas adicionais
                /*bPre*/    , ; // codeblock antes do diálogo   inc / alt / exc
                            , ; // codeblock ao clicar botao ok inc / alt / exc
                            , ; // codeblock durante transacao  inc / alt / exc
                bNoTTS      , ; // codeblock apos    transacao  inc / alt / exc
                            , ; // array campos considerados   pela   rotina automatica
                            , ; // numero da opcao selecionada para a rotina automatica
                            , ; // array com botoes enchoicebar *
                            , ; // array que substitui o controle de acessos
                            , ; // variavel private que enchoice usa
                              ) // indica se menudef padrao
// --------------------------
//    axcadastro( 'ZZZ'       , ; // alias 
//                'Telegrama' , ; // titulo
//                'u_delok()' , ; // funcao delete
//                'u_cok()'   , ; // funcao ok
//                aRotAdic    , ; // rotinas adicionais
//                bPre        , ; // codeblock antes do diálogo   inc / alt / exc
//                bOK         , ; // codeblock ao clicar botao ok inc / alt / exc
//                bTTS        , ; // codeblock durante transacao  inc / alt / exc
//                bNoTTS      , ; // codeblock apos    transacao  inc / alt / exc
//                aCampos     , ; // array campos considerados   pela   rotina automatica
//                            , ; // numero da opcao selecionada para a rotina automatica
//                aButtons    , ; // array com botoes enchoicebar *
//                            , ; // array que substitui o controle de acessos
//                            , ; // variavel private que enchoice usa
//                              ) // indica se menudef padrao
// --------------------------                             
// * aButtons[1][1] – Nome do arquivo da imagem do botão.
// * aButtons[1][2] – Bloco de execução.
// * aButtons[1][3] – Mensagem de exibição no ToolTip.
// * aButtons[1][4] – Nome do botão.
// --------------------------
                              
return( .T. )

// --------------------------------------------------------                        

user function delok()

//    msgalert( 'Chamada antes do delete' )

    dbselectarea( 'ZZZ' )
    reclock( 'ZZZ' , .F. )
        dbdelete()
    msunlock()
    
    aviso( 'Telegrama - Exclusão' , 'Registro excluído com sucesso!' )

return

// --------------------------------------------------------

user function cok()

// --------------------------
    local   lRet     := .T.
// --------------------------
    private cZFil    := M->ZZZ_FILIAL
    private cZFic    := M->ZZZ_FICHA
//  private cZNom    := M->ZZZ_NOFIC
    private cZCod    := M->ZZZ_COD
    private cZDatEnv := M->ZZZ_DATA
    private cZHorEnv := M->ZZZ_HRENV
    private cZMotEnv := M->ZZZ_MOTENV
    private cZMotDes := posicione( 'ZZY' , 1 , xfilial( 'ZZY' , M->ZZZ_FILIAL ) + M->ZZZ_MOTENV , 'ZZY_DESCRI' )
    private cZInfRet := M->ZZZ_INFRET
    private cZInfDes := posicione( 'ZZW' , 1 , xfilial( 'ZZW' , M->ZZZ_FILIAL ) + M->ZZZ_INFRET , 'ZZW_DESCRI' )
    private cZDatRet := M->ZZZ_DTRET
    private cZHis    := M->ZZZ_HIST
// --------------------------
//    msgalert( 'Clicou botao OK' )
//    if INCLUI
//        alert( 'Inclusão' )
//    endif
//    if ALTERA
//        alert( 'Alteração' )
//    endif
//    lRet := u_teltudok()
// --------------------------   

// -[ filial ]---------------
    if lRet
        if empty( alltrim( cZFil ) )
            alert( 'Filial em branco não permitida!' )
            lRet := .F.
        endif
    endif
    
// -[ ficha ]----------------
    if lRet
        if empty( alltrim( cZFic ) )
            alert( 'Ficha em branco não permitida!' )
            lRet := .F.
        endif
    endif

// -[ nome ficha ]-----------
//    if lRet
//        if empty( alltrim( cZNom ) )
//            alert( 'Nome Ficha em branco não permitido!' )
//            lRet := .F.
//        endif
//    endif

// -[ codigo ]---------------
    if lRet
        if empty( alltrim( cZCod ) )
            alert( 'Código em branco não permitido!' )
            lRet := .F.
        endif
    endif
    
// -[ data envio ]-----------
//    if lRet
//        if empty( alltrim( dtos( cZDatEnv ) ) )
//            alert( 'Data Envio em branco não permitida!' )
//            lRet := .F.
//        endif
//    endif
//
// -[ hora envio ]-----------
//    if lRet
//        if empty( alltrim( cZHorEnv ) )      .OR. ; 
//                  alltrim( cZHorEnv ) == ':'
//            alert( 'Hora Envio em branco não permitida!' )
//            lRet := .F.
//        endif
//    endif
    
// -[ motivo envio ]---------
    if lRet
        if empty( alltrim( cZMotEnv ) )
            alert( 'Motivo Envio em branco não permitido!' )
            lRet := .F.
        endif
    endif
    if lRet
//        alert( 'Antes cZFil    -> ' + cZFil    + ' <-' )
//        alert( 'Antes cZMotEnv -> ' + cZMotEnv + ' <-' )
//        alert( 'Antes cZMotDes -> ' + cZMotDes + ' <-' )

        dbselectarea( 'ZZY' )
        dbsetorder( 1 ) // ZZY_FILIAL + ZZY_COD
        if !dbseek( cZFil + cZMotEnv )
            alert( 'Motivo Envio não cadastrado!' )
            lRet := .F.
        else
            cZMotDes := ZZY->ZZY_DESCRI
        endif

//        alert( 'Depois cZMotDes -> ' + cZMotDes + ' <-' )
    endif
    
// -[ inf retorno ]----------
//  if lRet
//      if empty( alltrim( cZInfRet ) )
//          alert( 'Inf. Retorno em branco não permitido!' )
//          lRet := .F.
//      endif
//  endif
    if lRet
//      alert( 'Antes cZFil    -> ' + cZFil    + ' <-' )
//       alert( 'Antes cZInfRet -> ' + cZInfRet + ' <-' )
//      alert( 'Antes cZInfDes -> ' + cZInfDes + ' <-' )
        if !empty( alltrim( cZInfRet ) )
            dbselectarea( 'ZZW' )
            dbsetorder( 1 ) // ZZW_FILIAL + ZZW_CODIGO
            if !dbseek( cZFil + cZInfRet )
                alert( 'Inf. Retorno não cadastrado!' )
                lRet := .F.
            else
                cZInfDes := ZZW->ZZW_DESCRI
            endif
//          alert( 'Depois cZInfDes -> ' + cZInfDes + ' <-' )
        endif
    endif

// -[ data retorno ]---------
//  if lRet
//      if empty( alltrim( dtos( cZDatRet ) ) )
//          alert( 'Data Retorno em branco não permitida!' )
//          lRet := .F.
//      endif
//  endif

// --------------------------
//    msgalert( 'teltudok - fim' )
// --------------------------
    
//return lRet

// --------------------------    
    if lRet
//        alert( 'lRet == .T.' )
        
        if INCLUI
//          confirmsxe( .T. )
            confirmsx8( .T. )
        endif
        
    else
//        alert( 'lRet == .F.' )
    endif
    
// --------------------------
//    if lRet
//        reclock( 'ZZZ' , .T. )
//        msunlock()
//    endif
// --------------------------

return lRet // .T.

// --------------------------------------------------------

user function adic()

    msgalert( 'Rotina adicional' )

return

// --------------------------------------------------------

user function teltudok()

// --------------------------
    local   lRet     := .T.
// --------------------------
    private cZFil    := M->ZZZ_FILIAL
    private cZFic    := M->ZZZ_FICHA
//  private cZNom    := M->ZZZ_NOFIC
    private cZCod    := M->ZZZ_COD
    private cZDatEnv := M->ZZZ_DATA
    private cZHorEnv := M->ZZZ_HRENV
    private cZMotEnv := M->ZZZ_MOTENV
    private cZMotDes := posicione( 'ZZY' , 1 , xfilial( 'ZZY' , M->ZZZ_FILIAL ) + M->ZZZ_MOTENV , 'ZZY_DESCRI' )
    private cZInfRet := M->ZZZ_INFRET
    private cZInfDes := posicione( 'ZZW' , 1 , xfilial( 'ZZW' , M->ZZZ_FILIAL ) + M->ZZZ_INFRET , 'ZZW_DESCRI' )
    private cZDatRet := M->ZZZ_DTRET
    private cZHis    := M->ZZZ_HIST
// --------------------------

    msgalert( 'teltudok - inicio' )
    
// -[ filial ]---------------
    if lRet
        if empty( alltrim( cZFil ) )
            alert( 'Filial em branco não permitida!' )
            lRet := .F.
        endif
    endif
    
// -[ ficha ]----------------
    if lRet
        if empty( alltrim( cZFic ) )
            alert( 'Ficha em branco não permitida!' )
            lRet := .F.
        endif
    endif

// -[ nome ficha ]-----------
//    if lRet
//        if empty( alltrim( cZNom ) )
//            alert( 'Nome Ficha em branco não permitido!' )
//            lRet := .F.
//        endif
//    endif

// -[ codigo ]---------------
    if lRet
        if empty( alltrim( cZCod ) )
            alert( 'Código em branco não permitido!' )
            lRet := .F.
        endif
    endif
    
// -[ data envio ]-----------
//    if lRet
//        if empty( alltrim( dtos( cZDatEnv ) ) )
//            alert( 'Data Envio em branco não permitida!' )
//            lRet := .F.
//        endif
//    endif
//
// -[ hora envio ]-----------
//    if lRet
//        if empty( alltrim( cZHorEnv ) )      .OR. ; 
//                  alltrim( cZHorEnv ) == ':'
//            alert( 'Hora Envio em branco não permitida!' )
//            lRet := .F.
//        endif
//    endif
    
// -[ motivo envio ]---------
    if lRet
        if empty( alltrim( cZMotEnv ) )
            alert( 'Motivo Envio em branco não permitido!' )
            lRet := .F.
        endif
    endif
    if lRet
//        alert( 'Antes cZFil    -> ' + cZFil    + ' <-' )
//        alert( 'Antes cZMotEnv -> ' + cZMotEnv + ' <-' )
//        alert( 'Antes cZMotDes -> ' + cZMotDes + ' <-' )

        dbselectarea( 'ZZY' )
        dbsetorder( 1 ) // ZZY_FILIAL + ZZY_COD
        if !dbseek( cZFil + cZMotEnv )
            alert( 'Motivo Envio não cadastrado!' )
            lRet := .F.
        else
            cZMotDes := ZZY->ZZY_DESCRI
        endif

//        alert( 'Depois cZMotDes -> ' + cZMotDes + ' <-' )
    endif
    
// -[ inf retorno ]----------
//    if lRet
//        if empty( alltrim( cZInfRet ) )
//            alert( 'Inf. Retorno em branco não permitido!' )
//            lRet := .F.
//        endif
//    endif
//    if lRet
////        alert( 'Antes cZFil    -> ' + cZFil    + ' <-' )
////        alert( 'Antes cZInfRet -> ' + cZInfRet + ' <-' )
////        alert( 'Antes cZInfDes -> ' + cZInfDes + ' <-' )
//
//        dbselectarea( 'ZZW' )
//        dbsetorder( 1 ) // ZZW_FILIAL + ZZW_CODIGO
//        if !dbseek( cZFil + cZInfRet )
//            alert( 'Inf. Retorno não cadastrado!' )
//            lRet := .F.
//        else
//            cZInfDes := ZZW->ZZW_DESCRI
//        endif
//
////        alert( 'Depois cZInfDes -> ' + cZInfDes + ' <-' )
//    endif

// -[ data retorno ]---------
//    if lRet
//        if empty( alltrim( dtos( cZDatRet ) ) )
//            alert( 'Data Retorno em branco não permitida!' )
//            lRet := .F.
//        endif
//    endif

// --------------------------

    msgalert( 'teltudok - fim' )
    
return lRet

// --------------------------------------------------------                        

user function teleg001()

alert( 'teleg001 - inicio' )

//    if INCLUI
//        M->ZZZ_DMOTIV := ' '
//        M->ZZZ_DINFRE := ' '
//    endif

//    private cZMotDes := posicione( 'ZZY' , 1 , xfilial( 'ZZY' , M->ZZZ_FILIAL ) + M->ZZZ_MOTENV , 'ZZY_DESCRI' )
//    private cZInfRet := M->ZZZ_INFRET
//    private cZInfDes := posicione( 'ZZW' , 1 , xfilial( 'ZZW' , M->ZZZ_FILIAL ) + M->ZZZ_INFRET , 'ZZW_DESCRI' )

return


// --------------------------------------------------------                        

user function teleg002()

//_cTeste := M->A1_TESTE
//_nTam := TamSX3("A1_TESTE")
//_nTam1 := _nTam[1]
//MSMM(,_nTam1,,_cTeste,1,,,"SA1","A1_CODTST")

    dbselectarea( 'ZZZ' )
    reclock( 'ZZZ' , .F. )
        ZZZ->ZZZ_FILIAL := cFicFil
//        msmm( , 80 , , cZHis , 1 , , , 'ZZZ' , 'ZZZ_HIST' )
    msunlock()
    
    if INCLUI
        aviso( 'Telegrama - Inclusão' , 'Registro incluído com sucesso!' )
    endif
    if 	ALTERA
        aviso( 'Telegrama - Alteração' , 'Registro alterado com sucesso!' )
    endif

return

// --------------------------------------------------------
user function teleg003()
// --------------------------
    private cCadastro := 'Motivos do Telegrama'
    private cString   := 'ZZY'
    private aRotina   := { { 'Procurar'   , 'AxPesqui'     , 0 , 1 } , ;
                           { 'Visualizar' , 'AxVisual'     , 0 , 2 } , ;
                           { 'Incluir'    , 'AxInclui'     , 0 , 3 } , ;
                           { 'Alterar'    , 'AxAltera'     , 0 , 4 } , ;
                           { 'Excluir'    , 'u_teleg006()' , 0 , 5 }   }
// --------------------------
//    private aRotina   := { { 'Procurar'   , 'AxPesqui' , 0 , 1 } , ;
//                           { 'Visualizar' , 'AxVisual' , 0 , 2 } , ;
//                           { 'Incluir'    , 'AxInclui' , 0 , 3 } , ;
//                           { 'Alterar'    , 'AxAltera' , 0 , 4 } , ;
//                           { 'Excluir'    , 'AxDeleta' , 0 , 5 }   }
// --------------------------
    dbselectarea( 'ZZY' ) // Motivos do Telegrama
    dbsetorder( 1 ) // ZZY_FILIAL + ZZY_COD
    ZZY->( dbgotop() )
// --------------------------
    mbrowse( 6 , 1 , 22 , 75 , 'ZZY' , , , , , , ) // aCores )
// --------------------------
return( .T. )
// --------------------------------------------------------
user function teleg006()
// --------------------------
//    msgalert( 'Exclusão de Motivo de Telegrama' )
//    alert( 'ZZY->ZZY_FILIAL ==> ' + ZZY->ZZY_FILIAL + '<==' )
//    alert( 'ZZY->ZZY_COD    ==> ' + ZZY->ZZY_COD    + '<==' )
//    alert( 'ZZY->ZZY_DESCRI ==> ' + ZZY->ZZY_DESCRI + '<==' )
// --------------------------
    local cQry    := ''
    local cFilAux := ZZY->ZZY_FILIAL
    local cCodAux := ZZY->ZZY_COD
    local cRecAux := ZZY->( recno() )
// --------------------------
	cQry := " SELECT COUNT(*) TOTREG "
	cQry += "   FROM "                    + retsqlname( 'ZZZ' ) + " ZZZ "
	cQry += "  WHERE ZZZ.D_E_L_E_T_ <> '*' "
	cQry += "    AND ZZZ.ZZZ_FILIAL  = '" + cFilAux             + "' "
	cQry += "    AND ZZZ.ZZZ_MOTENV  = '" + cCodAux             + "' "
// --------------------------
	if select('QRY') > 0
		dbSelectArea('QRY')
		dbCloseArea()
	endif
//	MemoWrite( 'C:\ortp072a.sql' , cQrya )
	tcquery cQry Alias 'QRY' New
// --------------------------
	if QRY->TOTREG > 0
        msgalert( 'Existe(m) Telegrama(s) cadastrado(s) com esse Motivo!' + chr(13) + chr(10) + ;
                  'Exclusão não permitida!' , 'Atenção!' )
	else
        axdeleta( 'ZZY' , nRecAux , 5 )
//        reclock( 'ZZY' , .F. )
//            ZZY->( dbdelete() )
//        msunlock()
//        aviso( 'Motivos do Telegrama - Exclusão' , 'Registro excluído com sucesso!' )
	endif

return( .T. )
// --------------------------------------------------------
user function teleg004()
// --------------------------
    private cCadastro := 'Informação de Retorno do Telegrama'
    private cString   := 'ZZW'
    private aRotina   := { { 'Procurar'   , 'AxPesqui'     , 0 , 1 } , ;
                           { 'Visualizar' , 'AxVisual'     , 0 , 2 } , ;
                           { 'Incluir'    , 'AxInclui'     , 0 , 3 } , ;
                           { 'Alterar'    , 'AxAltera'     , 0 , 4 } , ;
                           { 'Excluir'    , 'u_teleg007()' , 0 , 5 }   }
// --------------------------
//    private aRotina   := { { 'Procurar'   , 'AxPesqui' , 0 , 1 } , ;
//                           { 'Visualizar' , 'AxVisual' , 0 , 2 } , ;
//                           { 'Incluir'    , 'AxInclui' , 0 , 3 } , ;
//                           { 'Alterar'    , 'AxAltera' , 0 , 4 } , ;
//                           { 'Excluir'    , 'AxDeleta' , 0 , 5 }   }
// --------------------------
    dbselectarea( 'ZZW' ) // Informação de Retorno do Telegrama
    dbsetorder( 1 ) // ZZW_FILIAL + ZZW_CODIGO
    ZZW->( dbgotop() )
// --------------------------
    mbrowse( 6 , 1 , 22 , 75 , 'ZZW' , , , , , , ) // aCores )
// --------------------------
return( .T. )
// --------------------------------------------------------
user function teleg007()
// --------------------------
    local cQry    := ''
    local cFilAux := ZZW->ZZW_FILIAL
    local cCodAux := ZZW->ZZW_CODIGO
    local cRecAux := ZZW->( recno() )
// --------------------------
	cQry := " SELECT COUNT(*) TOTREG "
	cQry += "   FROM "                    + retsqlname( 'ZZZ' ) + " ZZZ "
	cQry += "  WHERE ZZZ.D_E_L_E_T_ <> '*' "
	cQry += "    AND ZZZ.ZZZ_FILIAL  = '" + cFilAux             + "' "
	cQry += "    AND ZZZ.ZZZ_INFRET  = '" + cCodAux             + "' "
// --------------------------
	if select('QRY') > 0
		dbSelectArea('QRY')
		dbCloseArea()
	endif
//	MemoWrite( 'C:\ortp072a.sql' , cQrya )
	tcquery cQry Alias 'QRY' New
// --------------------------
	if QRY->TOTREG > 0
        msgalert( 'Existe(m) Telegrama(s) cadastrado(s) com essa Informação de Retorno!' + chr(13) + chr(10) + ;
                  'Exclusão não permitida!' , 'Atenção!' )
	else
        axdeleta( 'ZZW' , nRecAux , 5 )
//        reclock( 'ZZY' , .F. )
//            ZZY->( dbdelete() )
//        msunlock()
//        aviso( 'Motivos do Telegrama - Exclusão' , 'Registro excluído com sucesso!' )
	endif

return( .T. )
// --------------------------------------------------------
// [ fim de teleg000.prw ]
// --------------------------------------------------------
