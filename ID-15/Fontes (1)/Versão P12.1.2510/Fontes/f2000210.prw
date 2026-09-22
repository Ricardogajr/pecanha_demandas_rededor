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

/*/{Protheus.doc} User Function F2000102
    PE FINM050 - Movimento bancário de PA
    atualiza a tabela PX0 com os dados de título PA
    @type  Function
    @author Gianluca Moreira
    @since 07/06/2021
    /*/
User Function F2000210(oModel, cIdPonto, cIdModel)
    Local aAreaFK2  := FK2->(GetArea())
    Local aAreaFK5  := FK5->(GetArea())
    Local aAreaFKA  := FKA->(GetArea())
    Local aAreaSE2  := SE2->(GetArea())
    Local aAreaPX0  := PX0->(GetArea())
    Local aAreas    := {aAreaFK2, aAreaFK5, aAreaFKA, aAreaSE2, aAreaPX0, GetArea()}
    Local aSaveRow  := FWSaveRows()
    Local cIdMov    := ''
    Local cIDDoc    := ''
    Local cPgRec    := ''
    Local cChvSE2   := ''
    Local cChvPX0   := ''
    Local nFKA      := 0
    Local nFK5      := 0
    Local oFKA		:= oModel:GetModel('FKADETAIL')
    Local oFK5		:= oModel:GetModel('FK5DETAIL')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If !lGrpHblt
        AEval(aAreas, {|x| RestArea(x)})
        U_LimpaArr(aAreas)
        Return .T.
    EndIf

    //FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
    //FK2->(DbSetOrder(2)) //FK2_FILIAL+FK2_IDDOC+FK2_SEQ
    FKA->(DbSetOrder(2)) //FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
    FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
    SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    PX0->(DbSetOrder(1)) //PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE+PX0_EXC
    For nFKA := 1 To oFKA:Length()
        oFKA:GoLine(nFKA)

        If oFK5:IsEmpty()
            Loop
        EndIf
            
        For nFK5 := 1 To oFK5:Length()
            oFK5:GoLine(nFK5)
            cIdProc := FWFldGet('IDPROC')
            
            If FKA->(DbSeek(FWXFilial('FKA')+cIdProc))
                While !FKA->(EoF()) .And. FKA->(FKA_FILIAL+FKA_IDPROC) == FWXFilial('FKA')+cIdProc
                    If FKA->FKA_TABORI != 'FK5'
                        FKA->(DbSkip())
                        Loop
                    EndIf

                    cIdMov  := FKA->FKA_IDORIG
                    If FK5->(DbSeek(FWXFilial('FK5')+cIdMov))
                        If FK5->FK5_XPX0 $ '23'
                            FKA->(DbSkip())
                            Loop
                        EndIf

                        //Recupera o título a pagar a partir do mov. bancario
                        cIdDoc  := FK5->FK5_IDDOC
                        cChvSE2 := U_F2000211(cIdMov, cIdDoc)

                        If Empty(cChvSE2)
                            If RecLock('FK5', .F.)
                                FK5->FK5_XPX0 := '3' //Não relacionado a títulos de pagamento
                                FK5->(MsUnlock())
                            EndIf
                            FKA->(DbSkip())
                            Loop
                        EndIf

                        cChvPX0   := FK5->(FK5_FILIAL+FK5_IDMOV)
                        //Já processou esse movimento - redundância
                        If PX0->(DbSeek(FWXFilial('PX0')+'FK5'+AvKey(cChvPX0, 'PX0_CHAVE')))
                            If RecLock('FK5', .F.)
                                FK5->FK5_XPX0 := '2' //Processado
                                FK5->(MsUnlock())
                            EndIf
                            FKA->(DbSkip())
                            Loop
                        EndIf

                        If SE2->(DbSeek(cChvSE2))
                            //Não é um título de adiantamento
                            If !(SE2->E2_TIPO $ MVPAGANT)
                                If RecLock('FK5', .F.)
                                    FK5->FK5_XPX0 := '2' //Processado PX0
                                    FK5->(MsUnlock())
                                EndIf
                                FKA->(DbSkip())
                                Loop
                            EndIf

                            cPgRec := FK5->FK5_RECPAG

                            If cPgRec == 'P'
                                U_F2000100('SE2', EXCLUI_PREV)
                                U_F2000100('FK5', PAGADT_REAL) //Envia o realizado
                            ElseIf cPgRec == 'R'
                                If !FWIsInCallStack('Fa050DelPa') //Se não estiver deletando o PA
                                    U_F2000100('SE2', INCLUI_PREV)
                                EndIf
                                U_F2000100('FK5', RECADT_REAL) //Envia o estorno do realizado
                            EndIf

                            //Independente de gerar a PX0, marca como processado, pois existem condições
                            //onde não é gerada a PX0
                            If RecLock('FK5', .F.)
                                FK5->FK5_XPX0 := '2' //Processada PX0
                                FK5->(MsUnlock())
                            EndIf
                        EndIf
                    EndIf

                    FKA->(DbSkip())
                EndDo
            EndIf       
        Next nFK5
    Next nFKA
  
    FWRestRows(aSaveRow, oModel)
    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return .T.

/*/{Protheus.doc} F2000211
    Recupera a chave do título a partir do movimento bancário
    @type  Static Function
    @author Gianluca Moreira
    @since 07/06/2021
    @version version
    /*/
User Function F2000211(cIdMov, cIdDoc)
    Local aAreaFKA  := FKA->(GetArea())
    Local aAreaFK2  := FK2->(GetArea())
    Local aAreas    := {aAreaFKA, aAreaFK2, GetArea()}
    Local cChvSE2   := ''
    Local cIdProc   := ''
    Local cIdDoc2   := cIdDoc

    If Empty(cIdDoc2)
        FKA->(DbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
        If FKA->(DbSeek(FWXFilial('FKA')+'FK5'+cIdMov))
            cIdProc := FKA->FKA_IDPROC

            FKA->(DbSetOrder(2)) //FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
            If FKA->(DbSeek(FWXFilial('FKA')+cIdProc))
                While !FKA->(EoF()) .And. FKA->(FKA_FILIAL+FKA_IDPROC) == FWXFilial('FKA')+cIdProc
                    If FKA->FKA_TABORI != 'FK2'
                        FKA->(DbSkip())
                        Loop
                    EndIf

                    FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
                    If FK2->(DbSeek(FWXFilial('FK2')+FKA->FKA_IDORIG))
                        cIdDoc2 := FK2->FK2_IDDOC
                        Exit
                    EndIf

                    FKA->(DbSkip())
                EndDo
            EndIf
        EndIf
    EndIf

    cChvSE2 := U_F2000108(cIdDoc2)

    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return cChvSE2


/*/{Protheus.doc} User Function F2000109
    PE FINM020 - FORMLINEPRE - SETVALUE - FK5_TPDOC
    Verifica se está sendo gerada a linha do estorno, e apaga os campos
    customizados que tiveram seus valores copiados.
    @type  Function
    @author Gianluca Moreira
    @since 07/06/2021
    /*/
User Function F2000212(oModel)
    Local cTpDoc := ''
    
    cTpDoc := oModel:GetValue('FK5_TPDOC')
    If cTpDoc == 'ES'
        oModel:LoadValue('FK5_XMSXRT', '')
        oModel:LoadValue('FK5_XPX0', '1') //Não processado
    EndIf
Return
