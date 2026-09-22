/*/{Protheus.doc} User Function F2000220
    PE FINM030 - Versões antigas do módulo financeiro ainda usam o fonte para lançamentos de títulos
    a pagar de adiantamento
    PE FINM050 - Versões recentes do financeiro passam a utilizar o fonte FINM050 para lançar 
    adiantamentos
    @type  Function
    @author Gianluca Moreira
    @since 03/08/2021
    /*/
User Function F2000220()
    Local aParam   := PARAMIXB
    Local lRet     := .T.
    Local oModel   := ''
    Local cIdPonto := ''
    Local cIdModel := ''
    Local lGrpHblt := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    Local cUsrAlt  := UsrFullName(__cUserId) 

    If aParam <> NIL

        oModel   := aParam[1] //Objeto do formulário ou do modelo, conforme o caso
        cIdPonto := aParam[2] //ID do local de execução do ponto de entrada
        cIdModel := aParam[3] //ID do formulário


        If cIdPonto == 'FORMLINEPRE'
			If cIdModel == 'FK5DETAIL'
				If aParam[5] == 'SETVALUE' .And. aParam[6] == 'FK5_HISTOR'
                    //Verifica se está habilitada a integração neste grupo de empresas
                    If lGrpHblt
                        U_F2000212(oModel) //No estorno, limpa o conteúdo dos campos customizados copiados
                    EndIf					
				EndIf
			EndIf
        ElseIf cIdPonto == 'MODELCOMMITTTS' 
            If lGrpHblt
                U_F2000210(oModel, cIdPonto, cIdModel) //Gera PX0 - integração com XRT
            EndIf
        // ticket n° 12912589  
        ElseIf cIdPonto == 'MODELPRE'
            If cIdModel == 'FINM050' .OR. cIdModel == 'FINM030' 
                
                //DbSelectArea('SE5')
                //DbSetOrder(21)

                If SE5->E5_RECPAG == 'R' .AND. SE5->E5_TIPODOC == 'ES' // Gravação de log na exclusão de título PA 
                    Reclock('SE5',.F.)
                    SE5->E5_XLOGMOV  := cUsrAlt
                    SE5->E5_XHORMOV  := TIME() 
                    SE5->E5_XDATMOV  := DATE() 
                    
                    MsUnlock()
                ElseIf SE5->E5_SITUACA == 'E' .AND. Alltrim(SE5->E5_TIPODOC) == '' // Cancelamento da movimentação a Pagar ou Receber
                    Reclock('SE5',.F.)
                    SE5->E5_XLOGMOV  := cUsrAlt
                    SE5->E5_XHORMOV  := TIME() 
                    SE5->E5_XDATMOV  := DATE()

                    MsUnlock()
        
                ElseIf Alltrim(SE5->E5_SITUACA) == '' .AND. SE5->E5_TIPODOC == 'TR' .AND. Empty(SE5->E5_XHORMOV) // Estorno da transferência entre c/c
                    Reclock('SE5',.F.)
                    SE5->E5_XLOGMOV  := cUsrAlt
                    SE5->E5_XHORMOV  := TIME() 
                    SE5->E5_XDATMOV  := DATE()

                    MsUnlock()
                EndIf   
                //EndIf
            EndIf  
        EndIf
    EndIf


Return lRet
