#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE STAT_APROVADO '4'

// ------------------------------------------------------------------
// {Protheus.doc} F0500101
// @type    function
// @author  alexandre.arume
// @since   10/10/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
user function f0500101()
// ------------------------------------
    local oBrowse
// ------------------------------------
    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( 'P10' )
    oBrowse:SetMenuDef( 'F0500101' )
    oBrowse:SetDescription( 'Solicitacao de Desligamento' )
    oBrowse:SetSeeAll( .F. )
// ------------------------------------	
    oBrowse:AddLegend( 'P10->P10_STATUS == "1"' , 'YELLOW' , 'Solicitado'               )
    oBrowse:AddLegend( 'P10->P10_STATUS == "2"' , 'GREEN'  , 'Aprovado'                 )
    oBrowse:AddLegend( 'P10->P10_STATUS == "3"' , 'RED'    , 'Rejeitado'                )
    oBrowse:AddLegend( 'P10->P10_STATUS == "4"' , 'BLUE'   , 'Aguardando Efetivacao RH' )
// ------------------------------------
    oBrowse:SetFilterDefault(' P10_MATSOL == "' + __cUserId + ;
                                     '" .OR. "' + __cUserId + '" == "000000"' )
// ------------------------------------
    oBrowse:Activate()
// ------------------------------------
return

// ------------------------------------------------------------------
// {Protheus.doc} MenuDef
// @type    function
// @author  alexandre.arume
// @since   10/10/2016
// @version 1.0
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function menudef()
// ------------------------------------
    local aRotina := {}
// ------------------------------------
    ADD OPTION aRotina Title 'Pesquisar'                     Action 'PesqBrw'          OPERATION 1 ACCESS 0
    ADD OPTION aRotina Title 'Visualizar'                    Action 'VIEWDEF.f0500101' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Incluir'                       Action 'VIEWDEF.f0500101' OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'                      Action 'VIEWDEF.f0500101' OPERATION 8 ACCESS 0
    ADD OPTION aRotina Title 'Banco Específico - Visualizar' Action 'u_f0400101(1)'    OPERATION 0 ACCESS 0
    ADD OPTION aRotina Title 'Banco Específico - Incluir'    Action 'u_f0400101(3)'    OPERATION 0 ACCESS 0
    ADD OPTION aRotina Title 'Banco Específico - Excluir'    Action 'u_f0400101(5)'    OPERATION 0 ACCESS 0
    ADD OPTION aRotina Title 'Legenda'                       Action 'u_f0500109'       OPERATION 6 ACCESS 0
    ADD OPTION aRotina Title 'Cancelar Solicitação'          Action 'u_f0500125'       OPERATION 7 ACCESS 0
// ------------------------------------
return aRotina

// ------------------------------------------------------------------
// {Protheus.doc} ModelDef
// @type    function
// @author  alexandre.arume
// @since   10/10/2016
// @version 1.0
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function modeldef()
	
// ------------------------------------
    local oModel   := Nil                             // Modelo de dados
    local oStruP10 := FWFormStruct( 1 , 'P10' )       // Estrutura   da tabela P10
    local bPosVal  := {|oModel| f05001val( oModel ) } // Bloco de validação da P10
// ------------------------------------
    oStruP10:RemoveField( 'P10_FILIAL' )
    oModel := MPFormModel():New( 'F05001M' , /*Pré-Valid*/ , bPosVal /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
    oModel:SetVldActivate( {|oModel| VldManut( oModel ) } )

// ------------------------------------
//  [ Adiciona ao modelo uma estrutura de formulá	rio de edição por campo ]
    oModel:AddFields( 'P10MASTER' , /*cOwner*/ , oStruP10 , /*bPreValidacao*/ , /*bPosValidacao*/ , /*bCarga*/ )

// ------------------------------------	
//  [ Adiciona a descricao do Modelo de Dados ]
    oModel:SetDescription( 'Solicitacao de Desligamento' )

// ------------------------------------
//  [ Adiciona a descricao do Componente do Modelo de Dados ]
    oModel:GetModel( 'P10MASTER' ):SetDescription( 'Dados de Solicitacao de Desligamento' )

// ------------------------------------
    oModel:SetPrimaryKey( { 'P10_FILIAL' , 'P10_COD' } )
// ------------------------------------
    oStruP10:SetProperty( 'P10_MATRIC' , MODEL_FIELD_VALID , {|| u_f0500102( oModel ) } )
    oStruP10:SetProperty( 'P10_CODRES' , MODEL_FIELD_VALID , {|| u_f0500103( oModel ) } )
// ------------------------------------
return oModel

// ------------------------------------------------------------------
// {Protheus.doc} ViewDef
// @type    function
// @author  alexandre.arume
// @since   10/10/2016
// @version 1.0
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function viewdef()
// ------------------------------------
//  [ Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado ]
    local oModel   := FWLoadModel( 'F0500101' )
    local oStruP10 := FWFormStruct( 2 , 'P10' )
    local oView
// ------------------------------------
    oStruP10:RemoveField( 'P10_MATSOL' )
// ------------------------------------
//  [ Cria o objeto de View ]
    oView := FWFormView():New()
// ------------------------------------
//  [ Define qual o Modelo de dados será utilizado ]
    oView:SetModel(oModel)
//  [ Adiciona no nosso View um controle do tipo FormFields(antiga enchoice) ]
    oView:AddField( 'VIEW_P10' , oStruP10 , 'P10MASTER' )
// ------------------------------------
//  [ Criar um "box" horizontal para receber algum elemento da view ]
    oView:CreateHorizontalBox( 'TELA' , 100 )
// ------------------------------------
//  [ Relaciona o ID da View com o "box" para exibicao ]
    oView:SetOwnerView( 'VIEW_P10' , 'TELA' )
// ------------------------------------
return oView

// ------------------------------------------------------------------
// {Protheus.doc} F05001Val
// Valida se o tipo de rescisão esta cadastrada na tabela TP Rescisões Vs. Visões.
// @type    function
// @author  alexandre.arume
// @since   14/10/2016
// @version 1.0
// @param   oModel, objeto, (Descrição do parâmetro)
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function f05001val( oModel )

// ------------------------------------
    local aAreaRCC  := RCC->( getarea() )             // Armazena area RCC
    local lRet      := .F.                            // Variavel de retorno
    local oMdl      := oModel:GetModel( 'P10MASTER' ) // Modelo de dados da rotina
    local cCodRes   := oMdl:GetValue( 'P10_CODRES' )  // Codigo da rescisão
    local cCodTab   := 'U005'                         // Codigo da tabela RCC
    local cMatric   := oMdl:GetValue( 'P10_MATRIC' )  // Matricula do funcionario
    local cFilSol   := xfilial( 'P10' )               // Filial da Solicitação
    local nOpera    := oMdl:GetOperation()
    local cAssunto  := ''
    local cBody     := ''
    local cEmail    := ''
    local cNumSolic := ''
    local cSubGrp   := ''
    local aMatInc   := {}
    local cNotif    := ''
    local cStatus   := ''
    local aCampos   := { 'P10_FILIAL' , ;
                         'P10_MATRIC' , ;
                         'P10_DTSOLI' , ;
                         'P10_CODRES' , ;
                         'P10_DESRES' , ;
                         'P10_MOTIVO' , ;
                         'P10_DTDEMI'   }
    local aDados    := { xFilial( 'P10' )                                                             , ;
                         cMatric                                                                      , ;
                   dtos( oMdl:GetValue( 'P10_DTSOLI' ) )                                              , ;
                         cCodRes                                                                      , ;
                         fdescrcc( 'S043' , if( !empty( cCodRes ) , cCodRes , '' ) , 1 , 2 , 3 , 30 ) , ;
                         oMdl:GetValue( 'P10_MOTIVO' )                                                , ;
                   dtos( oMdl:GetValue( 'P10_DTDEMI' ) )                                                }
// ------------------------------------
    if fdescrcc( 'U005' , alltrim( cCodRes ) , 0 , 2 , 36 , 1 ) == 'S'
        if !u_f0400101( 3 , oMdl:GetValue( 'P10_COD' ) ) // Inclusão de Arquivos
            help( '' , 1 , 'Help' , , 'O anexo de arquivos é obrigatório!!!' , 3 , 0 )
            return .F.
        endif
    endif
// ------------------------------------
    if !empty( alltrim( cCodRes ))
// ------------------------------------
        dbselectarea( 'RCC' ) // Parâmetros
        RCC->( dbsetorder( 1 )) // RCC_FILIAL + RCC_CODIGO + RCC_FIL + RCC_CHAVE + RCC_SEQUEN
        RCC->( dbseek(       xfilial( 'RCC' ) + cCodTab    ) )
// ------------------------------------
        do while !RCC->( eof())                     .AND. ;
                  RCC->RCC_FILIAL + RCC->RCC_CODIGO ==    ;
                 xfilial( 'RCC' ) + cCodTab
// ------------------------------------
            if RCC->RCC_FILIAL + RCC->RCC_CODIGO             == xFilial( 'RCC' ) + cCodTab .AND. ;
                alltrim( substr( RCC->RCC_CONTEU ,  1 , 2 )) == alltrim( cCodRes )
              cSubGrp := substr( RCC->RCC_CONTEU , 33 , 3 )
                lRet   := .T.
                exit
            endif
// ------------------------------------
            RCC->( dbskip() )
// ------------------------------------
        enddo
// ------------------------------------
    endif
// ------------------------------------
    restarea( aAreaRCC )
// ------------------------------------	
    if nOpera != 5

        if lRet

// ---------[ Salva nas tabelas RH3 e RH4 para utilização do fluxo padrão do Portal. ]
            cNumSolic := u_f0500105( cFilSol , ;
                                     cMatric , ;
                                     cSubGrp , ;
                                     aCampos , ;
                                     aDados  , ;
                                     @cEmail , ;
                                     @cNotif , ;
                                     @cStatus  )
// ------------------------------------
            if !empty( cNumSolic )
// -------------[ Indicadores ]--------
                u_f0500201( RH3->RH3_FILIAL , ;
                            RH3->RH3_CODIGO , ;
                            '001'             ) // Solicitação de Desligamento Aberta
// -------------[ Atualiza a Solicitação ]
                oMdl:SetValue( 'P10_CODRH3' , cNumSolic )
// ------------------------------------
                if cStatus == '4'
                    oMdl:SetValue( 'P10_STATUS' , '4' )
                    u_f0801402( RH3->RH3_FILIAL , ;
                                cNumSolic       , ;
                                RH3->RH3_FILINI , ;
                                RH3->RH3_MATINI , ;
                                'Enviado Diretamente para Efetivação.' )
                    u_f0500201( RH3->RH3_FILIAL , ;
                                RH3->RH3_CODIGO , ;
                                '005' )
                else
                    u_f0500201( RH3->RH3_FILIAL , ;
                                RH3->RH3_CODIGO , ;
                                '002' )
                endif

// ------------------------------------------------------------------
// -------------[ Envia o primeiro e-mail. ]
//              cAssunto := 'Solicitação de Desligamento de Funcionário: ' + cNumSolic
//              cBody    := '<html><body><pre>' + CRLF
//              cBody    += '<b>Prezado,</b>'   + CRLF
////            if alltrim( cNotif ) != '2'
//                  cBody += 'Solicitação de desligamento de funcionário Nº <b>' + cNumSolic + ;
//                           '</b> aguardando sua aprovação/reprovação no portal de RH.' + CRLF				
////            endif
//              cBody += '</pre></body></html>'
//              if alltrim( cNotif ) != '2'
////                if u_f0200304( cAssunto , cBody , cEmail )
////                    msgalert( 'O aviso da solicitação  Nº <b>' + cNumSolic + ;
////                              '</b> foi enviado com sucesso.' , 'Atenção' )
////                else
//////                  msgalert( 'Ocorreu um erro no envio do aviso da solicitação.' , 'Atenção' )
////                endif
//              endif				
//              msgalert( 'O aviso da solicitação  Nº <b>' + cNumSolic + ;
//                        '</b> foi enviado com sucesso.' , 'Atenção' )
// ------------------------------------------------------------------

                atuanexo( oMdl:GetValue( 'P10_COD' ) , cNumSolic )
            else
                lRet := .F.
            endif
// ------------------------------------
        else
            msgalert( 'Rescisão não cadastrada na tabela TP Rescisões vs. Visões.' , 'Atenção' )
        endif
// ------------------------------------
    endif
// ------------------------------------
    if !lRet
        excanexo( oMdl:GetValue( 'P10_COD' ))
    endif
// ------------------------------------
return( lRet )

// ------------------------------------------------------------------
// {Protheus.doc} f0500102
// Validação do funcionário.
// @type    function
// @author  alexandre.arume
// @since   14/10/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @Param   oModel, objeto, Modelo de dados
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
//user function f0500102( oModel )
// ------------------------------------
//  local lRet     := .T.                            // Variavel de retorno
//  local oMld     := oModel:GetModel( 'P10MASTER' ) // Modelo de dados da rotina
//  local cCodFunc := oMld:GetValue( 'P10_MATRIC' )  // Codigo do funcionario
//  local aAreaSRA := SRA->( getarea() )             // Armazena area SRA
//  local aAreaP10 := P10->( getarea() )             // Armazena area P10
// ------------------------------------	
//  if !empty( cCodFunc )
//      dbselectarea( 'SRA' ) // Funcionários
//      SRA->( dbsetorder( 1 ))          // RA_FILIAL + RA_MAT
//      if !( lRet := SRA->( dbseek( xfilial( 'SRA' ) + cCodFunc )))
//          msgalert( 'Funcionário inexistente.' , 'Atenção' )
//      endif
//      dbselectarea( 'P10' ) // SOLICITACAO DE DESLIGAMENTO
//      P10->( dbsetorder( 2 )) // P10_FILIAL + P10_MATRIC
//      if P10->( dbseek(    xfilial( 'P10' ) + cCodFunc ))
//          if P10->P10_STATUS <> '3' .AND. ;
//             P10->P10_STATUS <> '2'
//              msgalert( 'Funcionário já possui solicitação de desligamento.' , 'Atenção' )
//              lRet := .F.
//          endif
//      endif
//  endif
// ------------------------------------	
//  restarea( aAreaSRA )
//  restarea( aAreaP10 )
// ------------------------------------
//return lRet
// ------------------------------------------------------------------
user function f0500102( oModel )
// ------------------------------------
    local lRet     := .T.                            // Variavel de retorno
    local oMld     := oModel:GetModel( 'P10MASTER' ) // Modelo de dados da rotina
    local cCodFunc := oMld:GetValue( 'P10_MATRIC'  ) // Codigo do funcionario
    local aAreaSRA := SRA->( getarea() )             // Armazena area SRA
    local aAreaP10 := P10->( getarea() )             // Armazena area P10
// ------------------------------------
    if !empty( cCodFunc )
// ------------------------------------
        dbselectarea( 'SRA' ) // Funcionários
        SRA->( dbsetorder( 1 ))          // RA_FILIAL + RA_MAT
        if !( lRet := SRA->( dbseek( xfilial( 'SRA' ) + cCodFunc )))
            msgalert( 'Funcionário inexistente.' , 'Atenção' )
        endif
// ------------------------------------
        dbselectarea( 'P10' ) // SOLICITACAO DE DESLIGAMENTO
        P10->( dbsetorder( 2 )) // P10_FILIAL + P10_MATRIC
        if P10->( dbseek(    xfilial( 'P10' ) + cCodFunc ))
            do while lRet                           .AND. ;
                     P10->( ! eof() )               .AND. ;
                     P10_FILIAL == xfilial( 'P10' ) .AND. ;
                     P10_MATRIC == cCodFunc
                if P10->P10_STATUS <> '3' .AND. ;
                   P10->P10_STATUS <> '2'
                    msgalert( 'Funcionário já possui solicitação de desligamento.' , 'Atenção' )
                    lRet := .F.
                endif
                P10->( dbskip() )
            enddo
        endif
    endif
// ------------------------------------
    restarea( aAreaSRA )
    restarea( aAreaP10 )
// ------------------------------------
return lRet

// ------------------------------------------------------------------
// {Protheus.doc} F0500103
// Função acionada na validação do campo Codigo de Rescisão para preenchimento do campo Descrição da Rescisão.
// @type    function
// @author  alexandre.arume
// @since   14/10/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @Param   oModel, objeto, Modelo de dados
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
user function f0500103( oModel )
// ------------------------------------	
    local lRet     := .F.                            // Variavel de retorno
    local aAreaRCC := RCC->( getarea() )             // Armazena area RCC
    local oMld     := oModel:GetModel( 'P10MASTER' ) // Modelo de dados da rotina
    local cTpRes   := oMld:GetValue( 'P10_CODRES' )  // Codigo da rescisão
    local cCodTab  := 'S043'                         // Codigo da tabela RCC
    local cDesc    := ''                             // Descrição da rescisão
// ------------------------------------
    if ! empty( cTpRes )

        dbselectarea( 'RCC' ) // Parâmetros
        RCC->( dbsetorder( 1 )) // RCC_FILIAL + RCC_CODIGO + RCC_FIL + RCC_CHAVE + RCC_SEQUEN
        RCC->( dbseek( xfilial( 'RCC' ) + cCodTab ))

        do while !RCC->( eof() ) .AND. ;
                  RCC->RCC_FILIAL + RCC->RCC_CODIGO == xfilial( 'RCC' ) + cCodTab

            if RCC->RCC_FILIAL + RCC->RCC_CODIGO            == xfilial( 'RCC' ) + cCodTab .AND. ;
                alltrim( substr( RCC->RCC_CONTEU , 1 , 2 )) == alltrim( cTpRes )

                cDesc := alltrim( substr( RCC->RCC_CONTEU , 3 , 30 ))
                oMld:LoadValue( 'P10_DESRES' , cDesc )
                lRet  := .T.
                exit
            endif

            RCC->( dbskip() )

        enddo

    endif
// ------------------------------------
    restarea( aAreaRCC )
// ------------------------------------
    if !lRet
        msgalert( 'Rescisão não cadastrada na tabela TP Rescisões vs. Visões.' , 'Atenção' )
    endif
// ------------------------------------
return( lRet )

// ------------------------------------------------------------------
// {Protheus.doc} F0500104
// Processo de aprovação.
// @type    function
// @author  alexandre.arume
// @since   21/10/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @Param   oModel, objeto, Modelo de dados
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
user function f0500104( oModel )
// ------------------------------------
    local   lRet          := .F.
    local   aArea         := getarea()
    local   oModelRH3     := oModel:GetModel( 'RH3MASTER' )
// ------------------------------------
    local   cSolic        := oModelRH3:GetValue( 'RH3_CODIGO' , 4 )
    local   cVisao        := oModelRH3:GetValue( 'RH3_VISAO'  , 4 )
    local   dDtSol        := oModelRH3:GetValue( 'RH3_DTSOLI' , 4 )
    local   cFilP10       := oModelRH3:GetValue( 'RH3_FILIAL' , 4 )
    local   cTpRes        := fdescrcc( 'U005' , cVisao , 33 , 6 , 69 , 1 )
    local   aInfoP10      := getP10( cSolic )
// ------------------------------------
    private cMatric       := oModelRH3:GetValue( 'RH3_MAT' , 4 )
    private cTipResPortal := alltrim( aInfoP10[02] )
// ------------------------------------

// -[ Valida se o tipo de rescisão precisa de anexo ]
    if HasAttach( cMatric , cTpRes )

        dbselectarea( 'SRA' ) // Funcionários
        SRA->( dbsetorder( 1 )) // RA_FILIAL + RA_MAT

        if SRA->( dbseek(   xfilial( 'SRA' ) + cMatric ))

            set filter to SRA->RA_FILIAL == xfilial( 'SRA' ) .AND. SRA->RA_MAT == cMatric
// ---------[ ticket n° 5441948 - 415966 - Paulo Dias ]
// ---------[ passar a validação TRUE no GPEM040 para efetuar a integração dos roteiros pra matrícula específica ]
            setfunname( 'GPEM040' )

// ---------[ Chama o calculo da rescisão ]------
            FWMsgRun( , {|| GPEM040() } , 'Processando...' , 'Iniciando cálculo de rescisão...' )

            set filter to

            dbselectarea( 'SRG' ) // RESCISOES
            SRG->( dbsetorder( 1 )) //     RG_FILIAL + RG_MAT                                + DTOS(RG_DTGERAR)
            lRet :=  SRG->( dbseek( xfilial( 'SRG' ) + oModelRH3:GetValue( 'RH3_MAT' , 4 )))

// ---------[ Atualiza a P10 ]-------------------
            if lRet
                u_f0500110( cSolic , '2' )
            endif
            
        endif
    endif

    restarea( aArea )
    
return( lRet )

// ------------------------------------------------------------------
// {Protheus.doc} F0500105
// Salva nas tabelas RH3 e RH4.
// @type    function
// @author  alexandre.arume
// @since   17/10/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @param   cMatric   , character , (Descrição do parâmetro)
// @param   cFilSol   , character , (Descrição do parâmetro)
// @param   cSubGrp   , character , (Descrição do parâmetro)
// @param   aCampos   , array     , (Descrição do parâmetro)
// @param   aDados    , array     , (Descrição do parâmetro)
// @param   cMailDesr , character , (Descrição do parâmetro)
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
user function f0500105( cFilSol , cMatric , cSubGrp , aCampos , aDados , cMailDest , cNotif , cStatus )
// ------------------------------------
    local   aMatInc  := {}
    local   aRH3     := {}
    local   aRetSup  := {}
    local   cNumRH3  := ''
    local   cFSolic  := ''
    local   cMSolic  := ''
    local   aEmail   := {}
    local   nX       := 0
    local   cEmail   := ''
    local   cGrupo   := ''
    local   cFilSltd := ''
    local   cEmp     := cEmpAnt
    local   cFilPost := ''
    local   cCodPost := ''
    local   cQuery   := ''
    local   cAlias1  := getnextalias()
    local   cVisPAB  := ''
    local   cCodAlc  := ''
// ------------------------------------	
    default cStatus	 := ''
    default cNotif   := ''
// ------------------------------------
    aMatInc := u_getinfmat()
// ------------------------------------
    if !empty( aMatInc     ) .AND. ;
       !empty( aMatInc[01] ) .AND. ;
       !empty( aMatInc[02] )
// ------------------------------------

// -----[ Valida as situações sem justa causa ]
// ------------------------------------------------------------------
// -----[ Nairan - Alteração Solicitada na AID MAN00000397423039_AID_001. ]
// ------------------------------------------------------------------
//      if cSubGrp == '005'      // DISPENSA SEM JUSTA CAUSA
//          if IsGer( cMatric )
//              cSubGrp := '098' // FUNCIONARIO GERENTE OU SUPERIOR (DISPENSA SEM JUSTA CAUSA)
//          elseif IsOver10( cMatric , stod( aDados[03] ) ) .OR. HasRFX( cMatric , stod( aDados[03] ))
//              cSubGrp := "099" //FUNCIONARIO COM MAIS DE 10 ANOS (DISPENSA SEM JUSTA CAUSA)
//          endif
//      endif
// ------------------------------------------------------------------

// ------------------------------------------------------------------
// -----[ Se subgrupos de óbito, pedido de demissão, ]
// -----[ abandono e término de contrato a estrutura da alçada seguirá pelo solicitado ]
        if cSubGrp == '001' .OR. ;
           cSubGrp == '002' .OR. ;
           cSubGrp == '003' .OR. ;
           cSubGrp == '004'

            cFSolic := cFilSol
            cMSolic := cMatric

        else //se não estrutura da alçada seguirá pelo solicitante

            cFSolic := aMatInc[01]
            cMSolic := aMatInc[02]

        endif
// ------------------------------------------------------------------
        cQuery := "   SELECT PAB_CODIGO , "
        cQuery += "          PAB_DTVLD    "
        cQuery += "     FROM "                + retsqlname( 'PAB' ) + " "
        cQuery += "    WHERE PAB_TPSOLI  = '005' "
        cQuery += "      AND PAB_GRPSOL  = '" + cSubGrp             + "' "
        cQuery += "      AND PAB_DTVLD  >= '" + dtos( date() )      + "' "
        cQuery += "      AND D_E_L_E_T_  = ' ' "
        cQuery += " ORDER BY PAB_DTVLD "
        cQuery := changequery( cQuery )
        dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAlias1 )
// ------------------------------------------------------------------
        if (cAlias1)->( !eof() )
            cCodAlc := (cAlias1)->( PAB_CODIGO )
        endif
        (cAlias1)->( dbclosearea() )
// ------------------------------------------------------------------
        cVisPAB := posicione( 'PAB' , 1 , xfilial( 'PAB' ) + cCodAlc , 'PAB_VISAO' )
        
        cAlias1 := GetNextAlias()

        cQuery :=     " SELECT   RD4_CHAVE  , "
        cQuery +=            "   RD4_FILIDE , "
        cQuery +=            "   RD4_CODIDE   "
        cQuery +=       " FROM " + retsqlname( 'RCX' ) + " RCX "
        cQuery += " INNER JOIN " + retsqlname( 'RD4' ) + " RD4 "
        cQuery +=         " ON ( RD4.RD4_FILIDE = RCX.RCX_FILIAL "
        cQuery +=         " AND  RD4.RD4_CODIDE = RCX.RCX_POSTO  "
        cQuery +=         " AND  RD4.D_E_L_E_T_ = ' ' ) "
        cQuery +=       " WHERE  RCX.RCX_FILFUN = '" + cFSolic + "' "
        cQuery +=         " AND  RCX.RCX_MATFUN = '" + cMSolic + "' "
        cQuery +=         " AND  RD4.RD4_CODIGO = '" + cVisPAB + "' "
        cQuery +=         " AND  RCX.D_E_L_E_T_ = ' ' "
        cQuery := changequery( cQuery )
        dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAlias1 , .T. , .T. )
// ------------------------------------------------------------------
        if !(cAlias1)->( eof() )
            cFilPost := (cAlias1)->RD4_FILIDE
            cCodPost := (cAlias1)->RD4_CODIDE
        endif
        (cAlias1)->( dbclosearea() )
// ------------------------------------------------------------------
        aRetSup := u_f0800501( '1' , , , '005' , cSubGrp , cFSolic , cMSolic , cFilSol , cMatric , , , @aEmail , .F. )
// ------------------------------------------------------------------
        if aRetSup[1][1]

            cNotif := posicione( 'PAC' , 1 , xfilial( 'PAC' ) + aRetSup[1][6] + aRetSup[1][4] , 'PAC_APRNOT' )

            if ( aRetSup[1][5]  == 'FM' .AND.   cNotif == '2' )                                  .OR. ;
               ( aRetSup[1][5]  == 'FM' .AND. ( 'aprova direto'                  $ aRetSup[1][8] .OR. ;
                                                'Terminou a estrutura da visão!' $ aRetSup[1][8] ) )
                cStatus := '4'
            else
                cStatus := '1'
            endif
// ------------------------------------------------------------------
            aadd(     aRH3 , { 'RH3_MAT'    , cMatric               } ) // 01
            aadd(     aRH3 , { 'RH3_ORIGEM' , 'U_F0500101'          } ) // 02
            aadd(     aRH3 , { 'RH3_DTSOLI' , date()                } ) // 03
            aadd(     aRH3 , { 'RH3_FILINI' , aMatInc[01]           } ) // 04
            aadd(     aRH3 , { 'RH3_MATINI' , aMatInc[02]           } ) // 05
            aadd(     aRH3 , { 'RH3_EMPAPR' , cEmp                  } ) // 06
            aadd(     aRH3 , { 'RH3_EMPINI' , cEmp                  } ) // 07
            aadd(     aRH3 , { 'RH3_EMP'    , cEmp                  } ) // 08
            aadd(     aRH3 , { 'RH3_STATUS' , cStatus               } ) // 09
            aadd(     aRH3 , { 'RH3_NVLAPR' , val( aRetSup[1][04] ) } ) // 10
            aadd(     aRH3 , { 'RH3_FILAPR' ,      aRetSup[1][02]   } ) // 11
            aadd(     aRH3 , { 'RH3_MATAPR' ,      aRetSup[1][03]   } ) // 12
            aadd(     aRH3 , { 'RH3_KEYINI' , '002'                 } ) // 13
            aadd(     aRH3 , { 'RH3_XTPCTM' , '005'                 } ) // 14
            aadd(     aRH3 , { 'RH3_XCODAL' ,      aRetSup[1][06]   } ) // 15
            aadd(     aRH3 , { 'RH3_XPRXNV' ,      aRetSup[1][05]   } ) // 16
            if !empty( aRetSup[1][09] ) .AND. ;
               !empty( aRetSup[1][10] )
                aadd( aRH3 , { 'RH3_XSUBST' , 'S'                   } )
                aadd( aRH3 , { 'RH3_XFILSU' ,      aRetSup[1][09]   } )
                aadd( aRH3 , { 'RH3_XMATSU' ,      aRetSup[1][10]   } )
            endif
            aadd(     aRH3 , { 'RH3_XFILPO' , cFilPost              } )
            aadd(     aRH3 , { 'RH3_XCODPO' , cCodPost              } )
// ------------------------------------------------------------------
            cNumRH3 := u_f0500106( 3 , aRH3 , aCampos , aDados )
// ------------------------------------------------------------------
            SRA->( dbsetorder( 1 )) // RA_FILIAL + RA_MAT
            SRA->( dbseek(           aRH3[11,02] + aRH3[12, 02] ))

            u_f0800901( '1'             , ;
                        SRA->RA_EMAIL   , ;
                        RH3->RH3_FILIAL , ;
                        RH3->RH3_CODIGO , ;
                        SRA->RA_NOME    , ;
                        '005'           , ;
                        cSubGrp         , ;
                        strzero( RH3->RH3_NVLAPR , tamsx3( 'RH3_XPRXNV' )[1]) , '' )

            cMailDest := aRetSup[1][7]

            if len( aEmail ) > 0

                for nX := 1 to len( aEmail )

                    cEmail   += alltrim(aEmail[nX]) + ';'
                    cFilSltd := RH3->RH3_FILIAL

                    u_f0800201( '1'                    , ;
                                xfilial( 'RH3' )       , ;
                                cNumRH3                , ;
                                RH3->RH3_XCODAL        , ;                              // 15
                                RH3->RH3_FILINI        , ;                              // 04
                                RH3->RH3_MATINI        , ;                              // 05
                                RH3->RH3_FILAPR        , ;                              // 11
                                RH3->RH3_MATAPR        , ;                              // 12
                                'Notificador-Inclusão' , ;
                                aEmail[nX]             , ;
                                strzero( RH3->RH3_NVLAPR , tamsx3( 'RH3_XPRXNV' )[1] )) // 10

                next nX

                u_f0800901( '3'                                                                    , ;
                            cEmail                                                                 , ;
                            RH3->RH3_FILIAL                                                        , ;
                            cNumRH3                                                                , ;
                            posicione( 'SRA' , 1 , RH3->RH3_FILINI + RH3->RH3_MATINI , 'RA_NOME' ) , ;
                            '005'                                                                  , ;
                            cSubGrp                                                                , ;
                            strzero( RH3->RH3_NVLAPR , tamsx3( 'RH3_XPRXNV' )[1]) , 'Notificação' )

            endif

            if cSubGrp == '001' .OR. ;
               cSubGrp == '002' .OR. ;
               cSubGrp == '003'
                u_f0600601( RH3->RH3_FILIAL , 'RH3' , RH3->RH3_CODIGO , RH3->( recno() ) , 'UPSERT' )
            endif

        else
            help( '' , 1 , 'Help' , , aRetSup[1][8] , 3 , 0 )
        endif

    else
        help( '' , 1 , 'Help' , , 'Não há o vínculo entre o Solicitante e o cadastro de Funcionários.' , 3 , 0 )
    endif

return( cNumRH3 )

// ------------------------------------------------------------------
// {Protheus.doc} F0500106
// Salva nas tabelas RH3 e RH4.
// @type    function
// @author  Roberto Souza
// @since   10/11/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @param   nOpc      , numeric    , (Descrição do parâmetro)
// @param   aDadosRH3 , array      , aDadosRH3[??][01] - Nome do campo; aDadosRH3[??][02] - Conteudo do campo
// @param   aCposRH4  , array      , Campos da RH4
// @param   aDadosRH4 , array      , Dados  da RH4
// @param   cFilSRA   , characters , descricao
// @return  cNumRH3   , characters , descricao
// ------------------------------------------------------------------
user function f0500106( nOpc , aDadosRH3 , aCposRH4 , aDadosRH4 , cFilSRA )
// ------------------------------------	
    local   aArea      := getarea()
    local   cNumRH3    := ''
    local   aStruRH3   := getstru( 'RH3' )
    local   nLenDados  := len( aDadosRH3 )
    local   nLenStru   := len( aStruRH3 )
    local   nDados     := 1
    local   nRH4       := 1
    local   nStru      := 1
    local   aRH3       := {}
    local   aRH3Aux    := {}
    local   cFilBck    := cFilAnt
    local   cObsLog    := 'Solicitação de Desligamento Aberta'
    local   cEmail     := ''
    local   nPosFilini := 0
    local   nPosMatini := 0
    local   nPosFilApr := 0
    local   nPosMatApr := 0
    local   nPosXcodal := 0
    local   nPosXprxnv := 0
    local   cQueryChv  := ''
    local   cAlias1    := getnextalias()
    local   cChave     := ''
    local   nVar       := 0
    local   cFilPost   := ''
    local   cCodPost   := ''
// ------------------------------------
    default nOpc       := 3
    default cFilSRA    := xfilial( 'RH3' )
// ------------------------------------
    private INCLUI     := ( nOpc == 3 )
// ------------------------------------
    if !( cFilSRA == xfilial( 'RH3' ) )
        cFilAnt := cFilSRA
    endif
// ------------------------------------
    if nOpc == 3
// ------------------------------------

// -----[ Varre a estrutura pra validar os campos ]
        for nStru := 1 To nLenStru

// ---------[ Ignora os campos filial e código ]
            if !( alltrim( aStruRH3[nStru][01]) $ 'RH3_FILIAL|RH3_CODIGO' )

// -------------[ Busca o Campo na estrutura ]
                nScan := ascan( aDadosRH3 , {|x| alltrim(x[01]) == alltrim( aStruRH3[nStru][01] )  } )

                if nScan > 0
                    aadd( aRH3 , { aStruRH3[nStru][01] , aDadosRH3[nScan][02] } )
                else

// -----------------[ Tratamento para incluir valor default caso ternha iniciar padrão e não seja campo virtual ]
                    if !empty( aStruRH3[nStru][11] ) .AND. ;
                      alltrim( aStruRH3[nStru][09] ) <>'V'
                        aadd( aRH3Aux , { aStruRH3[nStru][01] , aStruRH3[nStru][11] } )
                    endif
                endif
            endif
        next nStru

        if !empty( aRH3 )

            cFilSolic := iif( ( nVar := ascan( aRH3 , {|x, y|  alltrim(x[1]) == 'RH3_FILINI' } ) ) = 0 , '' , aRH3[nVar][2] )
            cMatSolic := iif( ( nVar := ascan( aRH3 , {|x, y|  alltrim(x[1]) == 'RH3_MATINI' } ) ) = 0 , '' , aRH3[nVar][2] )
            cCodAlcda := iif( ( nVar := ascan( aRH3 , {|x, y|  alltrim(x[1]) == 'RH3_XCODAL' } ) ) = 0 , '' , aRH3[nVar][2] )

            cVisPAB   := posicione( 'PAB' , 1 , xfilial( 'PAB' ) + cCodAlcda , 'PAB_VISAO' )

            cQueryChv :=     " SELECT   RD4_CHAVE  , "
            cQueryChv +=            "   RD4_FILIDE , "
            cQueryChv +=            "   RD4_CODIDE   "
            cQueryChv +=       " FROM " + retsqlname( 'RCX' ) + " RCX "
            cQueryChv += " INNER JOIN " + retsqlname( 'RD4' ) + " RD4 "
            cQueryChv +=         " ON ( RD4.RD4_FILIDE = RCX.RCX_FILIAL "
            cQueryChv +=        " AND   RD4.RD4_CODIDE = RCX.RCX_POSTO  "
            cQueryChv +=        " AND   RD4.D_E_L_E_T_ = ' ' ) "
            cQueryChv +=      " WHERE   RCX.RCX_FILFUN = '" + cFilSolic + "' "
            cQueryChv +=        " AND   RCX.RCX_MATFUN = '" + cMatSolic + "' "
            cQueryChv +=        " AND   RD4.RD4_CODIGO = '" + cVisPAB   + "' "
            cQueryChv +=        " AND   RCX.D_E_L_E_T_ = ' ' "
            cQueryChv := changequery( cQueryChv )
            dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQueryChv ) , cAlias1 , .T. , .T. )
// ------------------------------------
            if !(cAlias1)->( eof() )
                cChave := (cAlias1)->RD4_CHAVE
            endif
// ------------------------------------
            cNumRH3 := u_f1302201( { cFilSRA , '' , '' } , .T. )

            dbselectarea( 'RH3' ) // SOLICITACOES AO RH  
            reclock( 'RH3' , .T. )
// -------------[ Campos que são incluidos obrigatoriamente aqui ]
                RH3->RH3_FILIAL := xfilial( 'RH3' )
                RH3->RH3_CODIGO := cNumRH3
// -------------[ Grava os Campos passados ]
                for nDados := 1 to len( aRH3 )
                    nField := RH3->( FieldPos( aRH3[nDados][01] ) )
                    RH3->( FieldPut(  nField , aRH3[nDados][02] ) )
                next nDados
// -------------[ Grava os Campos não passados ]
                for nDados := 1 to len( aRH3Aux )
                    nField := RH3->( FieldPos(  aRH3Aux[nDados][01]  ))
                    RH3->( FieldPut( nField , &(aRH3Aux[nDados][02] )))
                next nDados
                RH3->RH3_VISAO  := cVisPAB
                RH3->RH3_XCHAVE := cChave
            RH3->( msunlock() )

            confirmsx8()

            u_f0801201( RH3->RH3_FILAPR , ;
                        RH3->RH3_MATAPR , ;
                        RH3->RH3_FILIAL , ;
                        RH3->RH3_CODIGO , ;
                        RH3->RH3_NVLAPR , ;
                        RH3->RH3_XCODAL   )

            if !empty( aCposRH4  ) .AND. ;
               !empty( aDadosRH4 )

                dbselectarea( 'RH4' ) // ALTERACAO CADASTRAL 

                for nRH4 := 1 to len( aCposRH4 )

                    reclock( 'RH4' , .T. )
                        RH4_FILIAL := xfilial( 'RH4' )
                        RH4_CODIGO := cNumRH3
                        RH4_ITEM   := nRH4
                        RH4_CAMPO  := aCposRH4[nRH4]
                        RH4_DESCAM := posicione( 'SX3' , 2 , aCposRH4[nRH4] , 'X3Descric()' )
                        RH4_VALANT := ''
                        if aCposRH4[nRH4] == 'P10_MOTIVO'
                            RH4_XOBS   := aDadosRH4[nRH4]
                        elseIf aCposRH4[nRH4] == 'TMP_OBSINC'
                            RH4_XOBS   := aDadosRH4[nRH4]
                        else
                            RH4_VALNOV := aDadosRH4[nRH4]
                        endif
                   RH4->( msunlock() )

               next nRH4

// ------------------------------------------------------------------
//             aadd( aRH3 , { 'RH3_MAT'    , cMatric              } ) // 01
//             aadd( aRH3 , { 'RH3_ORIGEM' , 'U_F0500101'         } ) // 02
//             aadd( aRH3 , { 'RH3_DTSOLI' , date()               } ) // 03
//             aadd( aRH3 , { 'RH3_FILINI' , aMatInc[01]          } ) // 04
//             aadd( aRH3 , { 'RH3_MATINI' , aMatInc[02]          } ) // 05
//             aadd( aRH3 , { 'RH3_EMPAPR' , cEmp                 } ) // 06
//             aadd( aRH3 , { 'RH3_EMPINI' , cEmp                 } ) // 07
//             aadd( aRH3 , { 'RH3_EMP'    , cEmp                 } ) // 08
//             aadd( aRH3 , { 'RH3_STATUS' , '1'                  } ) // 09
//             aadd( aRH3 , { 'RH3_NVLAPR' , val( aRetSup[1][4] ) } ) // 10
//             aadd( aRH3 , { 'RH3_FILAPR' ,      aRetSup[1][2]   } ) // 11
//             aadd( aRH3 , { 'RH3_MATAPR' ,      aRetSup[1][3]   } ) // 12
//             aadd( aRH3 , { 'RH3_KEYINI' , '002'                } ) // 13
//             aadd( aRH3 , { 'RH3_XTPCTM' , '005'                } ) // 14
//             aadd( aRH3 , { 'RH3_XCODAL' ,      aRetSup[1][6]   } ) // 15
//             aadd( aRH3 , { 'RH3_XPRXNV' ,      aRetSup[1][5]   } ) // 16
// ------------------------------------------------------------------

                nPosFilini := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_FILINI' } ) // 04
                nPosMatini := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_MATINI' } ) // 05
                nPosFilApr := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_FILAPR' } ) // 11
                nPosMatApr := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_MATAPR' } ) // 12
                nPosXcodal := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_XCODAL' } ) // 15
                nPosXprxnv := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_XPRXNV' } ) // 16
                nPosNvlApr := ascan( aDadosRH3 , {|x| alltrim(x[01]) == 'RH3_NVLAPR' } ) // 10

                cEmail := posicione( 'SRA' , 1 , aDadosRH3[nPosFilApr][2] + aDadosRH3[nPosMatApr][2] , 'RA_EMAIL' )

// -------------[ Grava o log de inclusão da solicitação ]
                u_f0800201( '1'                      , ;
                            xfilial( 'RH3' )         , ;
                            cNumRH3                  , ;
                            aDadosRH3[nPosXcodal][2] , ; // 15
                            aDadosRH3[nPosFilini][2] , ; // 04
                            aDadosRH3[nPosMatini][2] , ; // 05
                            aDadosRH3[nPosFilApr][2] , ; // 11
                            aDadosRH3[nPosMatApr][2] , ; // 12
                            cObsLog                  , ;
                            cEmail                   , ;
                            strzero( aDadosRH3[nPosNvlApr][2] , tamsx3( 'RH3_XPRXNV' )[1] )) // 10
            endif
        endif
    endif

    restarea( aArea )
    cFilAnt := cFilBck // retorna a variavel

return( cNumRH3 )

// ------------------------------------------------------------------
// {Protheus.doc} F0500109
// Legenda do Browse
// @type    function
// @author  Roberto Souza
// @since   10/11/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
user function f0500109()
// ------------------------------------
    local aLegenda := {}
// -[ Monta as cores ]-----------------
    aadd( aLegenda , { 'BR_AMARELO'  , 'Solicitado'               } )
    aadd( aLegenda , { 'BR_VERDE'    , 'Aprovado'                 } )
    aadd( aLegenda , { 'BR_VERMELHO' , 'Rejeitado'                } )
    aadd( aLegenda , { 'BR_AZUL'     , 'Aguardando Efetivacao RH' } )
    BrwLegenda( 'Status da Solicitação' , 'Status' , aLegenda )
return( .T. )

// ------------------------------------------------------------------
// {Protheus.doc} F0500110
// Atualiza o status da P10
// @type    function
// @author 	Roberto Souza
// @since 	10/11/2016
// @version 1.0
// @Project MAN0000007423039_EF_001
// @param 	cSolic  , char , Codigo da solicitação
// @param 	cStatus , char , Status a ser alterado
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
user function f0500110( cSolic , cStatus , cFilAtu )
// ------------------------------------
    local   lRet     := .F.
    local   aArea    := getarea()
    local   aInfoP10 := {}
// ------------------------------------
    default cSolic   := ''
    default cStatus  := ''
    default cFilAtu  := xfilial( 'P10' )
// ------------------------------------
    if !empty( cSolic  ) .AND. ;
       !empty( cStatus )
        getP10( cSolic , cStatus , cFilAtu )
        lRet := .T.			
    endif

    restArea( aArea )

return( lRet )

// ------------------------------------------------------------------
// {Protheus.doc} HasAttach
// @type    function
// @author  alexandre.arume
// @since   20/10/2016
// @version 1.0
// @param   cMatric , character , (Descrição do parâmetro)
// @param   cTpRes  , character , (Descrição do parâmetro)
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function HasAttach( cMatric , cTpRes )
// ------------------------------------
    local lRet     := .T.
    local cQuery   := ''
    local cMyAlias := getnextalias()
// ------------------------------------
    cTpRes := alltrim( cTpRes )
// ------------------------------------
    do case
        case cTpRes $ '1,2,4' // Óbito, Pedido de Demissão, Abandono de Emprego

            cQuery := " SELECT P09_CODDOC "
            cQuery +=   " FROM "                  + retsqlname( 'P09' ) + " "
            cQuery +=  " WHERE P09_CODORI    = '" + cMatric             + "' "
            cQuery +=    " AND P09_FILIAL    = '" +    xfilial( 'P09' ) + "' "
            cQuery +=    " AND P09_ROTINA LIKE '%F0500101%' "
            cQuery +=    " AND D_E_L_E_T_    = ' ' "
            cQuery := changequery( cQuery )
            dbusearea( .T. , 'TOPCONN' , TCGenQry( , , cQuery ) , cMyAlias , .F. , .T. )

            if (cMyAlias)->( eof() )
                msgalert( 'Favor inserir o anexo para prosseguir o processo de aprovação.' , 'Atenção' )
                lRet := .F.
            endif

            (cMyAlias)->( dbclosearea() )

    endcase

return lRet

// ------------------------------------------------------------------
// {Protheus.doc} HasRFX
// Verifica se o funcionario tem estabilidade.
// @type    function
// @author  alexandre.arume
// @since   24/10/2016
// @version 1.0
// @param   cMatric , character , (Descrição do parâmetro)
// @param   dDtSol  , data      , (Descrição do parâmetro)
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function HasRFX( cMatric , dDtSol )
// ------------------------------------	
    local lRet := .F.
// ------------------------------------	
    dbselectarea( 'RFX' ) // PERIODOS DE ESTABILIDADE
    RFX->(dbsetorder( 1 )) // RFX_FILIAL + RFX_MAT + DTOS(RFX_DATAI) + RFX_TPESTB 
    RFX->( dbseek(      xfilial( 'RFX' ) + cMatric ))
    do while !RFX->( eof() ) .AND. ;
              RFX->RFX_FILIAL + RFX->RFX_MAT  == xfilial( 'RFX' ) + cMatric
        if RFX->RFX_DATAF > dtos( dDtSol )
            lRet := .T.
            exit
        endif
        RFX->( dbskip() )
    enddo
return lRet

// ------------------------------------------------------------------
// {Protheus.doc} IsGer
// Verifica se o funcionario é gerente.
// @type    function
// @author  Roberto Souza
// @since   24/10/2016
// @version 1.0
// @param   cMatric , character , (Descrição do parâmetro)
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function IsGer( cMatric )
// ------------------------------------
    local cFunc := posicione( 'SRA' , 1 , xfilial( 'SRA' ) + cMatric , 'RA_CODFUNC' )
    local lRet  := posicione( 'SRJ' , 1 , xfilial( 'SRJ' ) + cFunc   , 'RJ_XGEREN'  ) == '08'
// ------------------------------------
return( lRet )

// ------------------------------------------------------------------
// {Protheus.doc} GetInfMat
// Retorna a relação usuario x funcionario.
// @type    function
// @author  Roberto Souza
// @since   08/11/2016
// @version 1.0
// @param   lExib , logico , Exibe mensagem de erro?
// @return  aInfo , Filial e Matricula do Funcionario Logado
// @Project MAN0000007423039_EF_001
// ------------------------------------------------------------------
user function GetInfMat( lExib )
// ------------------------------------	
    local   aInfo    := { '' , '' }
    local   aAllUser := {}
    local   nTamEmp  := len( alltrim( cEmpAnt ))
    local   nTamFil  := len( alltrim( cFilAnt ))
// ------------------------------------
    default lExib    := .T.
// ------------------------------------
//  [ Busca vinculo funcional ]

    PswOrder( 1 )

    if ( PswSeek( __cUserId , .T. ) )

        aAllUser := PswRet()
        cFilUsr  := substr( aAllUser[1,22] , nTamEmp + 1           , nTamFil )
        cMatUsr  := substr( aAllUser[1,22] ,(Len(aalluser[1,22])-6) + 1 , 6       )

        if !empty( cFilUsr ) .AND. ;
           !empty( cMatUsr )
            aInfo[01] := cFilUsr
            aInfo[02] := cMatUsr
        else
            if lExib
                help( '' , 1 , 'Help' , , 'O usuario solicitante não possui vinculo funcional. É necessário efetuar a amarração com a matricula do funcionário através do módulo Configurador' , 3 , 0 )
            endif
        endif

    endif

return( aInfo )

// ------------------------------------------------------------------
// {Protheus.doc} GetP10
// Retorna as informações da P10 a partir da solicitação
// @type    function
// @author  Roberto Souza
// @since   08/11/2016
// @version 1.0
// @param   cMatric , character , (Descrição do parâmetro)
// @return  ${return} , ${return_description}
// ------------------------------------------------------------------
static function getP10( cSolic , cStatus , cFilAtu )
// ------------------------------------	
    local   aInfo   := Array(10)
    local   cP10    := getnextalias()
// ------------------------------------
    default cSolic  := ''
    default cStatus := ''
    default cFilAtu := xfilial( 'P10' )
// ------------------------------------
    BEGINSQL alias cP10
        SELECT P10_COD , P10_CODRES , P10_MATSOL , P10_DTSOLI
          FROM %table:P10%
         WHERE P10_CODRH3 = %exp:cSolic%
           AND P10_FILIAL = %exp:cFilAtu%
           AND %notdel%
    ENDSQL
// ------------------------------------
    if (cP10)->(!eof() )
        aInfo[01] := (cP10)->P10_COD
        aInfo[02] := (cP10)->P10_CODRES
        aInfo[03] := (cP10)->P10_MATSOL
        aInfo[04] := (cP10)->P10_DTSOLI
        if !( empty( cStatus ))
            dbselectarea( 'P10' ) // SOLICITACAO DE DESLIGAMENTO
            P10->( dbsetorder( 1 )) // P10_FILIAL +  P10_COD
            if P10->( dbseek(             cFilAtu + (cP10)->P10_COD ))
                reclock( 'P10' , .F. )
                    P10->P10_STATUS := cStatus
                P10->( msunlock() )
            endif
        endif
    endif
// ------------------------------------
return( aInfo )

// ------------------------------------------------------------------
// {Protheus.doc} IsOver10
// Verifica se o funcionario tem estabilidade de mais de 10 anos.
// @type    function
// @author  Roberto Souza
// @since   09/11/2016
// @version 1.0
// @param   cMatric , character , (Descrição do parâmetro)
// @param   dDtSol  , data      , (Descrição do parâmetro)
// @return  ${return}, ${return_description}
// ------------------------------------------------------------------
static function IsOver10( cMatric , dDtSol )
// ------------------------------------
    local lRet   := .F.
    local nAnosE := 10 // Anos Estabilidade
    local nDiasE := nAnosE * 365
// ------------------------------------
    dbselectarea( 'SRA' ) // Funcionários
    SRA->( dbsetorder( 1 )) // RA_FILIAL + RA_MAT
    if SRA->( dbseek( xfilial( 'SRA' ) + cMatric ))
        dDtAdmiss  := SRA->RA_ADMISSA
        nDiasAtivo := dDtSol - dDtAdmiss
        lRet       := nDiasE <= nDiasAtivo
    endif
return( lRet )

// ------------------------------------------------------------------
// {Protheus.doc} GetStru
// Cria array com estrutura de uma tabela.
// @author  Roberto Souza
// @since   08/11/2016
// @version 1
// ------------------------------------------------------------------
static function getstru( cTable )
// ------------------------------------
    local nUsado  := 0
    local aHeader := {}
	Local _aCampos := {} //Thais Paiva - Compatibilização P27
    Local _nH := 0 //Thais Paiva - 14176482
// ------------------------------------	
   
   /* Início - Thais Paiva - Compatibilização P27
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek( cTable ))
	While  SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cTable
		AAdd(aHeader,{;
			AllTrim(X3_CAMPO)	,; // 01
		X3_TIPO		,; // 02
		X3_TAMANHO	,; // 03
		X3_DECIMAL	,; // 04
		X3_PICTURE	,; // 05
		X3_VALID	,; // 06
		X3_USADO	,; // 07
		X3_F3		,; // 08
		X3_CONTEXT	,; // 09
		X3_CBOX		,; // 10
		X3_RELACAO	}) // 11
		SX3->(DbSkip())
	EndDo*/
	_aCampos := FWSX3Util():GetAllFields( cTable , .T. )
	For _nH	:= 1 to Len(_aCampos)
		Aadd(aHeader, {Alltrim(GetSx3Cache(_aCampos[_nH], 'X3_CAMPO')),;
					   GetSx3Cache(_aCampos[_nH], 'X3_TIPO'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_TAMANHO'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_DECIMAL'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_PICTURE'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_VALID'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_USADO'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_F3'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_CONTEXT'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_CBOX'),;
					   GetSx3Cache(_aCampos[_nH], 'X3_RELACAO')})
	Next _nH
	//Fim - Thais Paiva - Compatibilização P27

return( aHeader )

// ------------------------------------------------------------------
// {Protheus.doc} F0500198
// Funçao para buscar todas as visoes do usuario logado e montar um array com os integrantes da equipe dele
// @type    function
// @author  Ademar Fernandes
// @since   13/01/2017
// @version 1.0
// @Project MAN0000007423039_EF_001
// @param   cFilGes - filial do "gestor"
// @param   cMatGes - matricula do "gestor"
// @param   cCodVis - codigo da visao principal
// @return  aRet => estrutura com todos os integrantes das visoes do usuario logado
// ------------------------------------------------------------------
user function f0500198( cFilGes , cMatGes , cCodVis )
// ------------------------------------	
    local   aArea     := getarea()
    local   aPostos   := {}
    local   aRet      := {}
    local   aMatInc   := {}
    local   cQuery    := ''
    local   cMy1Alias := getnextalias()
    local   cMy2Alias := getnextalias()
    local   cTypeOrg  := ''
    local   nX
    local   cPostAte
// ------------------------------------
    default cFilGes   := ''
    default cMatGes   := ''
    default cCodVis   := ''
// ------------------------------------
    if empty( cMatGes )
        aMatInc := u_getinfmat()
    endif
    cFilGes := iif( empty( cFilGes ) , aMatInc[01] , cFilGes )
    cMatGes := iif( empty( cMatGes ) , aMatInc[02] , cMatGes )

    TipoOrg( @cTypeOrg , cCodVis )

//--[ Verifica as visoes que o Usuario participa ]
    if !empty( cMatGes ) .AND. ;
      ( empty( cCodVis ) .OR. cTypeOrg = '1' )

// ------------------------------------
//          SELECT * 
//            FROM DB2.RCX990 A
//      INNER JOIN DB2.RD4990 B
//              ON   B.D_E_L_E_T_ = ' '
//             AND     RD4_FILIDE = RCX_FILIAL
//             AND     RD4_CODIDE = RCX_POSTO
//           WHERE   A.D_E_L_E_T_ = ' '
//             AND     RCX_FILFUN = '01'
//             AND     RCX_MATFUN = '320712'
//        ORDER BY     RCX_FILIAL ,
//                     RCX_FILFUN ,
//                     RCX_MATFUN ,
//                     RCX_POSTO
// ------------------------------------

        cQuery :=     " SELECT RCX_FILIAL , "
        cQuery +=            " RCX_POSTO  , "
        cQuery +=            " RCX_FILFUN , "
        cQuery +=            " RCX_MATFUN , "
        cQuery +=            " RCX_DTINI  , "
        cQuery +=            " RCX_DTFIM  , "
        cQuery +=            " RD4_CODIGO , "
        cQuery +=            " RD4_CHAVE "
        cQuery +=       " FROM " + retsqlname( 'RCX' ) + " RCX "
        cQuery += " INNER JOIN " + retsqlname( 'RD4' ) + " RD4 "
        cQuery +=         " ON RD4.D_E_L_E_T_ = ' ' "
        cQuery +=        " AND RD4_FILIDE     = RCX_FILIAL "
        cQuery +=        " AND RD4_CODIDE     = RCX_POSTO "
        if !empty( cCodVis )
            cQuery +=    " AND RD4_CODIGO     = '" + cCodVis + "' "
        endif
        cQuery +=      " WHERE RCX.D_E_L_E_T_ = ' ' "
        cQuery +=        " AND RCX_FILFUN     = '" + cFilGes + "' "
        cQuery +=        " AND RCX_MATFUN     = '" + cMatGes + "' "
        cQuery +=   " ORDER BY RCX_FILIAL , "
        cQuery +=            " RCX_FILFUN , "
        cQuery +=            " RCX_MATFUN , "
        cQuery +=            " RCX_POSTO "
        cQuery := changequery( cQuery )
        dbusearea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cMy1Alias, .F., .T. )
		
        if (cMy1Alias)->( eof() )
            msgalert( 'Usuário logado não pertence a nenhum Posto Ativo!' , 'Atenção' )
        else

            do while (cMy1Alias)->( !eof() )
                (cMy1Alias)->( aadd( aPostos , { RCX_FILIAL   , ; // 01
                                                 RCX_POSTO    , ; // 02
                                                 RCX_FILFUN   , ; // 03
                                                 RCX_MATFUN   , ; // 04
                                                 RCX_DTINI    , ; // 05
                                                 RCX_DTFIM    , ; // 06
                                                 RD4_CODIGO   , ; // 07-Cod.Visao
                                                 RD4_CHAVE  } ) ) // 08
                (cMy1Alias)->( dbskip() )
            enddo

// ---------[ Monta o Array da(s) equipe(s) ]
            for nX := 1 to len( aPostos )

                cPostAte := substr( ( alltrim( aPostos[nX,08] ) + 'ZZZZZZZZZZZZZZZZZZZZ' ) , 1 , len( RD4->RD4_CHAVE ) )

// ------------------------------------
//              SELECT *
//                FROM   DB2.RD4990 RD4
//          INNER JOIN   DB2.RCX990 RCX
//                  ON   RCX.D_E_L_E_T_  = ' '
//                 AND   RCX_FILIAL      = RD4_FILIDE
//                 AND   RCX_POSTO       = RD4_CODIDE
//               WHERE   RD4.D_E_L_E_T_  = ' '
//                 AND   RD4_CODIGO      = '000010'
//                 AND ( RD4_CHAVE BETWEEN '001001              '
//                                     AND '001001ZZZZZZZZZZZZZZ' )
//            ORDER BY   RCX_FILIAL ,
//                       RCX_FILFUN ,
//                       RCX_MATFUN ,
//                       RCX_POSTO
// ------------------------------------

                cQuery :=     " SELECT   RCX_FILIAL , "
                cQuery +=              " RCX_POSTO  , "
                cQuery +=              " RCX_FILFUN , "
                cQuery +=              " RCX_MATFUN , "
                cQuery +=              " RCX_DTINI  , "
                cQuery +=              " RCX_DTFIM  , "
                cQuery +=              " RD4_CODIGO , "
                cQuery +=              " RD4_CHAVE "
                cQuery +=       " FROM " + retsqlname( 'RD4' ) + " RD4 "
                cQuery += " INNER JOIN " + retsqlname( 'RCX' ) + " RCX "
                cQuery +=         " ON   RCX.D_E_L_E_T_  = ' ' "
                cQuery +=        " AND   RCX_FILIAL      = RD4_FILIDE "
                cQuery +=        " AND   RCX_POSTO       = RD4_CODIDE "
                cQuery +=      " WHERE   RD4.D_E_L_E_T_  = ' ' "
                cQuery +=        " AND   RD4_CODIGO      = '" + aPostos[nX,07] + "' "
                cQuery +=        " AND ( RD4_CHAVE BETWEEN '" + aPostos[nX,08] + "' "
                cQuery +=                            " AND '" + cPostAte       + "') "
                cQuery +=   " ORDER BY   RD4_FILIAL , "
                cQuery +=              " RD4_CODIGO , "
                cQuery +=              " RD4_CHAVE "
                cQuery := changequery( cQuery )
                dbusearea( .T. , 'TOPCONN' , TCGenQry( , , cQuery ) , cMy2Alias , .F. , .T. )

                do while (cMy2Alias)->( !eof() )
                    (cMy2Alias)->( aadd( aRet , { RCX_FILIAL  , ; // 01
                                                  RCX_POSTO   , ; // 02
                                                  RCX_FILFUN  , ; // 03
                                                  RCX_MATFUN  , ; // 04
                                                  RCX_DTINI   , ; // 05
                                                  RCX_DTFIM   , ; // 06
                                                  RD4_CODIGO  , ; // 07-Cod.Visao
                                                  RD4_CHAVE } ) ) // 08
                    (cMy2Alias)->( dbskip() )
                enddo

                (cMy2Alias)->( dbclosearea() )

            next nX

        endif

        (cMy1Alias)->( dbclosearea() )

    endif

    restArea( aArea )

return( aRet )

// ------------------------------------------------------------------
// {Protheus.doc} F0500199
// Funçao para buscar a visao do usuario logado
// e verificar se ele pode incluir uma Solicitaçao
// para o funcionario que deseja
// @type    function
// @author  Luis Trombini
// @since   06/01/2017
// @version 1.0
// @param   cMatric , characters , descricao
// @param   cCodVis , characters , descricao
// @param   nOp     , numeric    , 1-Desligamento ### 2-Movimento Pessoal
// @Project MAN0000007423039_EF_001
// @return  lRet => (.T.) Pode incluir a soliciçao ### (.F.) Não pode incluir a solicitaçao
// ------------------------------------------------------------------
user function f0500199( cMatric , cCodVis , nOp )
// ------------------------------------	
    local   aArea    := getarea()
    local   aRet     := {}
    local   aMatInc  := u_getinfmat()
    local   c1Posto  := ' '
    local   c2Posto  := ' '
    local   c1Tree   := ' '
    local   c2Tree   := ' '
    local   c1Chave  := ' '
    local   c2Chave  := ' '
    local   c1Depto  := ' '
    local   c2Depto  := ' '
    local   cTypeOrg := ''
    local   cFilTrp  := ''
    local   lRet     := .T.
    local   cOp      := ''
    local   cTitulo  := ''
// ------------------------------------
    default nOp      := 1
// ------------------------------------

    BEGIN SEQUENCE

        if nOp == 1
            cOp := 'Desligamento'
        else
            cOp := 'Movimento de Pessoal'
        endif
        cTitulo := ' Solicitação de' + cMsg

// -----[ Verifica se o Usuario logado tem Vinculo Funcional ]
        if empty( aMatInc[01] ) .AND. ;
           empty( aMatInc[02] ) // cFilUsr###cMatUsr

            lRet := .F.
            BREAK

        else

            TipoOrg( @cTypeOrg , cCodVis )
			
// ---------[ Verifica as visoes que o Usuario participa ]
            if cTypeOrg = '1'

// -------------[ Verifica solicitante para ver o nivel e pares dentro da visão ]
                dbselectarea( 'SRA' ) // Funcionários
                if SRA->( dbseek( aMatInc[01] + aMatInc[02] ))
                    c1Posto := RA_POSTO
                endif

                dbselectarea( 'RD4' ) // Itens de Visões
                RD4->( dbsetorder( 7 )) // RD4_FILIAL + RD4_CODIGO + RD4_EMPIDE + RD4_FILIDE + RD4_CODIDE
                if !RD4->( dbseek( xfilial( 'RD4' ) + cCodVis + cEmpAnt + aMatInc[01] + c1Posto ))
                    help( '' , 1 , 'Help' , cTitulo , 'Usuário sem Permissão para solicitação de ' + cOp + '.  Atenção!!!' , 3 , 0 )
                    lRet := .F.
                    BREAK
                else
                    c1Tree  := RD4_TREE
                    c1Chave := RD4_CHAVE
                endif

// -------------[ Verifica funcionario Selecionado ]
                dbselectarea( 'SRA' ) // Funcionários
                if !SRA->( dbseek( xfilial( 'SRA' ) + cMatric ))
                    help( '' , 1 , 'Help' , cTitulo , 'Funcionário inexistente nesta Filial.  Atenção!!!' , 3 , 0 )
                    lRet := .F.
                    BREAK
                else
                    cFilTrp := RA_Filial
                    c2Posto := RA_POSTO
                    if empty( c2Posto )
                        help( '' , 1 , 'Help' , cTitulo , 'Funcionário Solicitado não esta Locado em um Posto.   Atenção!!!' , 3 , 0 )
                        lRet := .F.
                        BREAK
                    endif
                endif
				
                dbselectarea( 'RD4' ) // Itens de Visões
                RD4->( dbsetorder( 7 )) // RD4_FILIAL + RD4_CODIGO + RD4_EMPIDE + RD4_FILIDE + RD4_CODIDE
                if RD4-> ( dbseek(   xfilial( 'RD4' ) + cCodVis    + cEmpAnt    + cFilTrp    + c2Posto ))
                    c2Tree  := RD4_TREE
                    c2Chave := RD4_CHAVE
                endif

                if ( c1Chave >= c2Chave )
                    help( '' , 1 , 'Help' , cTitulo , 'Usuário sem Permissão para solicitação de ' + cOp + '.  Atenção!!!' , 3 , 0 )
                    lRet := .F.
                    BREAK
                endif

            else

// -------------[ Verifica solicitante para ver o nivel e pares dentro da visão ]
                dbselectarea( 'SRA' ) // Funcionários
                if SRA->( dbseek( aMatInc[01] + aMatInc[02] ))
                    c1Depto := RA_DEPTO
                endif

                dbselectarea( 'RD4' ) // Itens de Visões
                RD4->( dbsetorder( 7 )) // RD4_FILIAL + RD4_CODIGO + RD4_EMPIDE + RD4_FILIDE  + RD4_CODIDE
                if ! RD4->( dbseek(  xfilial( 'RD4' ) + cCodVis    + cEmpAnt    + aMatInc[01] + c1Depto ))
                    help( '' , 1 , 'Help' , cTitulo , 'Departamento não Consta da Visão para solicitação de ' + cOp + '.  Atenção !!!' , 3 , 0 )
                    lRet := .F.
                    BREAK
                else
                    c1Tree  := RD4_TREE
                    c1Chave := RD4_CHAVE

                    dbselectarea( 'SQB' ) // Departamento
                    SQB->( dbsetorder( 1 )) // QB_FILIAL + QB_DEPTO
                    if ! SQB->( dbseek( xfilial( 'SQB' ) + c1Depto ))
                        help( '' , 1 , 'Help' , cTitulo , 'Departamento não Consta no Cadastro de Departamento. Atenção!!!' , 3 , 0 )
                        lRet := .F.
                        BREAK
                    else
                        if ( aMatInc[01] + aMatInc[02] ) <> ( SQB->QB_FILRESP + SQB->QB_MATRESP )
                            help( '' , 1 , 'Help' , cTitulo , 'Usuário sem Permissão para solicitação de ' + cOp + '.  Atenção!!!' , 3 , 0 )
                            lRet := .F.
                            BREAK
                        endif
                    endif
                endif

                dbselectarea( 'SRA' ) // Funcionários
                if ! SRA->( dbseek( xfilial( 'SRA' ) + cMatric ))
                    help( '' , 1 , 'Help' , cTitulo , 'Funcionário inexistente.  Atenção!!!' , 3 , 0 )
                    lRet := .F.
                    BREAK
                else
                    c2Depto := RA_DEPTO
                    cFilTrp := RA_FILIAL
                endif

                dbselectarea( 'SQB' ) // Departamento
                SQB->( dbsetorder( 1 )) // QB_FILIAL + QB_DEPTO
                if ! SQB->( dbseek( xfilial( 'SQB' ) + c2Depto ))
                    help( '' , 1 , 'Help' , cTitulo , 'Departamento não Consta no Cadastro de Departamento. Atenção!!!' , 3 , 0 )
                    lRet := .F.
                    BREAK
                else

                    if ( xfilial( 'SRA' ) + cMatric ) = ( SQB->QB_FILRESP + SQB->QB_MATRESP )

                        dbselectarea( 'RD4' ) // Itens de Visões
                        RD4->( dbsetorder( 7 )) // RD4_FILIAL + RD4_CODIGO + RD4_EMPIDE + RD4_FILIDE + RD4_CODIDE
                        if RD4->( dbseek(    xfilial( 'RD4' ) + cCodVis    + cEmpAnt    + cFilTrp    + c2Depto ))

                            c2Tree  := RD4_TREE
                            c2Chave := RD4_CHAVE

                            if ( c1Chave >= c2Chave )
                                help( '' , 1 , 'Help' , cTitulo , 'Usuário sem Permissão para solicitação de ' + cOp + '.  Atenção!!!' , 3 , 0 )
                                lRet := .F.
                                BREAK
                            endif

                        endif

                    endif

                endif

            endif

        endif

    END SEQUENCE

    restarea( aArea )
	
return( lRet )

// ------------------------------------------------------------------

static function AtuAnexo( cCodP10 , cCodRH3 )
// ------------------------------------
    local aAreaP09  := P09->( getarea() )
    local cQuery    := ''
    local cAliasTrb := getnextalias()
// ------------------------------------
    cQuery := " SELECT R_E_C_N_O_ NumRec "
    cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
    cQuery +=  " WHERE P09_CODORI = '" + cCodP10             + "' "
    cQuery +=    " AND P09_FILIAL = '" +    xfilial( 'P09' ) + " ' "
    cQuery +=    " AND D_E_L_E_T_ = ' ' "
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasTrb , .T. , .T. )
// ------------------------------------
    do while (cAliasTrb)->( !eof() )
        P09->( dbgoto( (cAliasTrb)->NumRec ))
        reclock( 'P09' , .F. )
            P09->P09_CODORI := cCodRH3
        P09->( msunlock() )
        (cAliasTrb)->( dbskip() )
    enddo
// ------------------------------------
    restarea( aAreaP09 )
    (cAliasTrb)->( dbclosearea() )
// ------------------------------------
return

// ------------------------------------------------------------------
// {Protheus.doc} F05001INIT
// Função para tratar o inicializador do campo RG_DESCTPR
// @author  Fernando Carvalho
// @since   28/04/2017
// @version undefined
// @type    function
// ------------------------------------------------------------------
user function f05001init()
// ------------------------------------
    local aInfoP10 := ''
    local cRet     := ''
// ------------------------------------
    if isincallstackK( 'U_F0100323' )
        aInfoP10      := getP10( RH3->RH3_CODIGO )
        M->RG_TIPORES := alltrim( aInfoP10[02] )
        M->RG_DESCTPR := fdescrcc( 'S043' , M->RG_TIPORES , 1 , 2 , 3 , 30 )
        cRet          := M->RG_DESCTPR 
    else
        cRet := fdescrcc( 'S043' , if( type( 'cTipRes' )=='C' .AND. ;
                                      !empty( cTipRes ) , cTipRes , SRG->RG_TIPORES ) , 1 , 2 , 3 , 30 )
    endif
// ------------------------------------
return cRet

// ------------------------------------------------------------------
// [ Exclui Anexo do Banco ]
// ------------------------------------------------------------------
static function ExcAnexo( cCodigo )
// ------------------------------------
    local cQuery    := ''
    local cAliasTrb := getnextalias()
// ------------------------------------
    cQuery := " SELECT R_E_C_N_O_ NumRec "
    cQuery +=   " FROM "               + retsqlname( 'P09' ) + " "
    cQuery +=  " WHERE P09_CODORI = '" + cCodigo             + "'  "
    cQuery +=    " AND P09_FILIAL = '" +    xfilial( 'P09' ) + " ' "
    cQuery +=    " AND D_E_L_E_T_ = ' ' "
    cQuery := changequery( cQuery )
    dbusearea( .T. , 'TOPCONN' , TcGenQry( , , cQuery ) , cAliasTrb , .T. , .T. )
// ------------------------------------
    do while (cAliasTrb)->( !eof() )
        P09->( dbgoto( (cAliasTrb)->NumRec ))
        P09->( reclock( 'P09' , .F. ))
            P09->( dbdelete() )
        P09->( msunlock() )
        (cAliasTrb)->( dbskip() )
    enddo
// ------------------------------------
return

// ------------------------------------------------------------------
// [ Valida se o usuário tem acesso à Solicitação ]
// ------------------------------------------------------------------
static function VldManut( oModel )
// ------------------------------------
    local lRet   := .T.
    local oMdl   := oModel:GetModel( 'P10MASTER' )
    local nOpera := oMdl:GetOperation()
// ------------------------------------
    if nOpera != 3
        if P10->P10_MATSOL != __cUserId
            lRet := .F.
            help( '' , 1 , 'Help' , , 'O usuário não tem acesso a essa solicitação.' , 3 , 0 )
        endif
    endif
// ------------------------------------
return lRet

// ------------------------------------------------------------------
// {Protheus.doc} F0500125()
// Validação para cancelamento da solicitação
// @Author  Bruno de Oliveira
// @Since   14/12/2017
// @Version P12.1.07
// @Project MAN0000007423048_EF_025
// ------------------------------------------------------------------
user function f0500125()
// ------------------------------------
    local aUser   := {}
    local cQuery
    local cFSolic := ''
    local cMSolic := ''
    local cStatus := ''
    local cAlcada := ''
    local cSubGrp := ''
    local cCodP10 := P10->P10_COD
// ------------------------------------	
    dbselectarea( 'RH3' ) // Solicitações ao RH
    RH3->( dbsetorder( 1 )) // RH3_FILIAL + RH3_CODIGO
    if RH3->( dbseek( P10->(   P10_FILIAL + P10_CODRH3 )))
        cFilSol := RH3->RH3_FILIAL
        cCodSol := RH3->RH3_CODIGO
        cFSolic := RH3->RH3_FILINI
        cMSolic := RH3->RH3_MATINI
        cStatus := RH3->RH3_STATUS
        cAlcada := RH3->RH3_XCODAL
    endif

    dbselectarea( 'PAB' ) // CABEÇALHO CADASTRO ALÇADA
    PAB->( dbsetorder( 1 )) // PAB_FILIAL + PAB_CODIGO
    if PAB->( dbseek( xfilial( 'PAB' ) + cAlcada ))
        cSubGrp := PAB->PAB_GRPSOL
    endif

    aUser := u_getinfmat()

    if !empty( aUser[1] ) .AND. ;
       !empty( aUser[2] )

        if ( aUser[1] + aUser[2] ) == ( cFSolic + cMSolic )

            if cSubGrp == '001' .OR. ;
               cSubGrp == '002' .OR. ;
               cSubGrp == '003' .OR. ;
               cStatus != '1'
                msgalert( 'Usuário não tem permissão para cancelar a solicitação' )
            else
                u_CanclSlc( cFilSol , cCodSol , cCodP10 , cFSolic, cMSolic , '005' )
            endif

        else
            msgalert( 'Usuário não tem permissão para cancelar a solicitação' )
        endif

    endif

return

// ------------------------------------------------------------------
// {Protheus.doc} CanclSlc()
// Cancelamento da Solicitação
// @Author  Bruno de Oliveira
// @Since   14/12/2017
// @Version P12.1.07
// @Project MAN0000007423048_EF_025
// @Param   cFilSol , Filial da Solicitação
// @Param   cCodSol , Código da Solicitação
// @Param   cCodPth , Código para posicionar nas tabelas auxiliares (PA2 e P10)
// @Param   cFSolic , Filial do usuario responsavel
// @Param   cMSolic , Matricula do usuario responsavel
// @Param   cSolic  , Tipo de Solicitação
// ------------------------------------------------------------------
user function CanclSlc( cFilSol , cCodSol , cCodPth , cFSolic , cMSolic , cSolic )
// ------------------------------------
    local oDlg
    local lRetorno := .F.
    local cMotCanc := ''
    local cObserv  := ''
// ------------------------------------
    DEFINE MSDIALOG oDlg TITLE 'Motivo do Cancelamento' FROM 180 , 180 TO 420 , 700 PIXEL
    TMultiGet():new( 001 , 001 , {|u|if(pCount()>0,cMotCanc:=u,cMotCanc)} , oDlg , 260 , 92 , , , , , , .T. )
      TButton():New( 100 , 080 , 'OK'     , oDlg , {||oDlg:End() , lRetorno := .T. } , 40 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
      TButton():New( 100 , 130 , 'Voltar' , oDlg , {||oDlg:End() , lRetorno := .F. } , 40 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
    ACTIVATE DIALOG oDlg CENTERED
// ------------------------------------

    if lRetorno

        if !empty( cMotCanc )
            RH3->( dbsetorder( 1 )) // RH3_FILIAL + RH3_CODIGO
            if RH3->( dbseek(             cFilSol + cCodSol ))
				cFilRh3 := RH3->RH3_FILIAL //Thais Paiva - 14176482
                reclock( 'RH3' , .F. )
                    RH3->RH3_STATUS := '3' // Reprovado
                    RH3->RH3_XCANCL := '1' // Cancelado Sim
                    RH3->RH3_DTATEN := date()
                RH3->( msunlock() )
            endif
            /* ticket n° 12485794
            if cSolic == '005' // Desligamento
                P10->( dbsetorder( 1 )) // P10_FILIAL + P10_COD
                if P10->( dbseek(             cFilSol + cCodPth ))
                    reclock( 'P10' , .F. )
                        P10->P10_STATUS := '3' // Reprovado
                    P10->( msunlock() )
                endif
            */
            If cSolic == '005' // Desligamento
                P10->(DbSetOrder(3)) //P10_FILIAL+P10_MATRIC+P10_CODRH3 (DbSetOrder(2)) 14417674 - Thais Paiva
                If P10->( Dbseek(cFilSol + RH3->RH3_MAT + cCodSol)) //P10->( Dbseek(cFilSol + RH3->RH3_MAT)) 14417674 - Thais Paiva
                    Reclock('P10', .F.)
                        P10->P10_STATUS := '3' // Reprovado
                    P10->(MsUnlock())
                Endif
            // Fim ticket n° 12485794    
            elseif cSolic == '004' // FAP
                PA2->( dbsetorder( 6 )) // PA2_FILIAL + PA2_SOL
                if PA2->( dbseek( cCodPth ))
					cFilPa2 := PA2->PA2_FILIAL //Thais Paiva - 14176482
                    reclock( 'PA2' , .F. )
                        PA2->PA2_SIT := 'RE' // Reprovado
                    PA2->( msunlock() )
                endif

            elseif cSolic == '006' // Movimentação
                SRA->( dbsetorder( 1 )) // RA_FILIAL + RA_MAT
                if SRA->( dbseek( cCodPth ))
                    reclock( 'SRA' , .F. )
                        SRA->RA_XSTMVTO := ' '
                    SRA->( msunlock() )
                endif
            endif

// ---------[ Indicador ]--------------
            u_f0500201( cFilSol , cCodSol , '024' , cFSolic , cMSolic ) // Cancelamento da solicitação

            cObserv := 'Cancelamento: ' + cMotCanc

// ---------[ Historico Cancelamento ]-
            u_f0801402( cFilSol , cCodSol , cFSolic , cMSolic , cObserv )
			
			//Início - Thais Paiva - 14176482
			If  cSolic == '004' // FAP
				U_F0500302(cFilPa2,cFilRh3,cCodSol,"RP")
			EndIf
			//Fim - Thais Paiva - 14176482

            msgalert( 'Cancelamento Realizado com sucesso' )

        else
            msgalert( 'Motivo é obrigatório! Solicitação não será cancelada' )
        endif

    else
        msgalert( 'Motivo é obrigatório! Solicitação não será cancelada' )
    endif

return

// ------------------------------------------------------------------
// [ fim de f0500101.prw ]
// ------------------------------------------------------------------

