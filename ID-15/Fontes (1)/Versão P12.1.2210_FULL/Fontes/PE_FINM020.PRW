#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} User Function FINM020
    Ponto de Entrada MVC da baixa do título
    @type  Function
    @author Gianluca Moreira
    @since 21/05/2021
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=284859148
    /*/
User Function FINM020()
    Local aParam   := PARAMIXB
    Local lRet     := .T.
    Local oModel   := ''
    Local cIdPonto := ''
    Local cIdModel := ''
    Local lGrpHblt := .F. //U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    // Rafael Yera Barchi - 27/10/2021
    // Chamado 12765973
    // Tratativa para verificar se não está sendo executada por job/Schedule
    If !IsInCallStack("U_MY290FI")
    
        lGrpHblt := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

        If aParam <> NIL

            oModel   := aParam[1] //Objeto do formulário ou do modelo, conforme o caso
            cIdPonto := aParam[2] //ID do local de execução do ponto de entrada
            cIdModel := aParam[3] //ID do formulário

            If cIdPonto == 'FORMLINEPRE'
                If cIdModel == 'FK2DETAIL'
                    If aParam[5] == 'SETVALUE' .And. aParam[6] == 'FK2_HISTOR'
                        //Verifica se está habilitada a integração neste grupo de empresas
                        If lGrpHblt
                            U_F2000109(oModel) //No estorno, limpa o conteúdo dos campos customizados copiados
                        EndIf
                    EndIf
                EndIf
                If cIdModel == 'FK5DETAIL'
                    If aParam[5] == 'SETVALUE' .And. aParam[6] == 'FK5_HISTOR'
                        //Verifica se está habilitada a integração neste grupo de empresas
                        If lGrpHblt
                            U_F2000212(oModel) //No estorno, limpa o conteúdo dos campos customizados copiados
                        EndIf
                    EndIf
                EndIf
            ElseIf cIdPonto == 'MODELPOS'
                //Verifica se está habilitada a integração neste grupo de empresas
                If lGrpHblt
                    lRet := U_F2000417(oModel) //Valida se é título de operação financeira
                EndIf            
            ElseIf cIdPonto == 'MODELCOMMITTTS'
                //Verifica se está habilitada a integração neste grupo de empresas
                If lGrpHblt
                    U_F2000102(oModel, cIdPonto, cIdModel) //Gera PX0 - integração com XRT - Baixas normais
                    U_F2000210(oModel, cIdPonto, cIdModel) //Gera PX0 - integração com XRT - Baixas PA
                EndIf
            EndIf
        EndIf

    EndIf

Return lRet
