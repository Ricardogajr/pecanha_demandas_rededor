#Include 'TOTVS.ch'

#Define INCLUI_PREV 01
#Define ALTERA_PREV 02
#Define EXCLUI_PREV 03
#Define ENVBAN_PREV 04
#Define REJBAN_PREV 05
#Define BAIXAT_PREV 06
#Define ESTBXA_PREV 07
#Define GRVCHQ_PREV 08
#Define ESTCHQ_PREV 09
#Define ENVBAN_REAL 21
#Define REJBAN_REAL 22
#Define BAIXAT_REAL 23
#Define ESTBXA_REAL 24
#Define GRVCHQ_REAL 31
#Define ESTCHQ_REAL 32
#Define PAGADT_REAL 41
#Define RECADT_REAL 42

/*/{Protheus.doc} User Function F2000200
    Verifica as regras de integração, conforme MIT P20002,
    para gerar ou não a PX0 e integrar
    Deve ser chamada posicionada na SE2 e FK2, se houver
    @type  Function
    @author Gianluca Moreira
    @since 20/05/2021
    /*/
User Function F2000200(nOpc)
    Local aMotBx := {}
    Local aMot   := {}
    Local cMotBx := ''
    Local nMotBx := 0
    Local lRet   := .T.
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If !lGrpHblt
        lRet := .F.
        Return .F.
    EndIf

    //Chamado da baixa no momento do retorno bancário
    /*If FWIsInCallStack('U_FINM020') .And. (FWIsInCallStack('FINA430') .Or. FWIsInCallStack('FINA300'))
        lRet := .F.
        Return lRet
    EndIf
    */

    //Verifica se é um PA em uma operação diferente das operações de PA
    //If SE2->E2_TIPO $ MVPAGANT .And. !(nOpc >= PAGADT_REAL .And. nOpc <= RECADT_REAL)
    //    lRet := .F.
    //    Return lRet
    //EndIf

    //Valida motivo da baixa
    If nOpc == BAIXAT_REAL .Or. nOpc == ESTBXA_REAL 
        cMotBx := FK2->FK2_MOTBX
        aMotBx := ReadMotBx()
        lRet   := .F. //Procura o motivo
        For nMotBx := 1 To Len(aMotBx)
            aMot := StrTokArr(aMotBx[nMotBx], '³')
            If AllTrim(cMotBx) == AllTrim(aMot[1])
                If AllTrim(aMot[3]) <> 'S' //Não movimenta bancário
                    lRet := .F.
                    Return lRet
                Else
                    lRet := .T. //Encontrou e movimenta banco
                    Exit
                EndIf
            EndIf
        Next nMotBx

        If lRet .And. cMotBx $ 'PCC|IRF|ISS|IMR' //Motivos de baixa de imposto ao gerar borderô
            lRet := .F.
        EndIf
    EndIf


    //Na amarração do título em borderô, alguns impostos são destacados do título, gerando
    //baixas na FK2. Essas baixas não movimentam bancário, e não devem ser integradas ao XRT.
    //Elas originam outros títulos, que serão aglutinados e ai sim serão integrados
    If FWIsInCallStack('U_FINM020') .And. ;
    (FWIsInCallStack('FINA241') .Or. FWIsInCallStack('U_TEWBTYP1') .Or. FWIsInCallStack('FINA240'))
        lRet := .F.
        Return lRet
    EndIf

    //Verifica se é do Depto. de Pessoas (SIGAGPE) e Realizado
    If U_F2000201() .And. nOpc >= ENVBAN_REAL
        lRet := .F.
        Return lRet
    EndIf

    //Verifica se é operação financeira e realizado
    If SE2->(FieldPos('E2_XOPFXRT')) > 0 .And. !Empty(SE2->E2_XOPFXRT) .And. nOpc >= ENVBAN_REAL
        lRet := .F.
        Return lRet
    EndIf

    //Verifica se é título de imposto não aglutinado
    If !Empty(SE2->E2_TITPAI)
        lRet := .F.
        Return lRet
    EndIf

    //Verifica status padrão dos títulos
    //Verifica se encontra-se esperando liberação
    If (SuperGetMv("MV_CTLIPAG",.F.,.F.) .And. !( SE2->E2_TIPO $ MVPAGANT ).and. EMPTY(SE2->E2_DATALIB) .AND. ;
    (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > SuperGetMV("MV_VLMINPG",.F.,0) .AND. SE2->E2_SALDO > 0)
        If SE2->E2_XSTRECU $ ' C'
        lRet := .F.
        Return lRet
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} User Function F2000201
    Valida se o título a pagar posicionado é de origem do Gestão de Pessoas (SIGAGPE)
    @type  Function
    @author Gianluca Moreira
    @since 18/08/2021
    /*/
User Function F2000201()
    Local lRet := .F.

    //lRet := Substr(Upper(SE2->E2_ORIGEM),1,3) $ "GPE/APT"
    lRet := Substr(Upper(SE2->E2_TIPO),1,3) $ "131/132/FER/RES/FOL"
Return lRet
