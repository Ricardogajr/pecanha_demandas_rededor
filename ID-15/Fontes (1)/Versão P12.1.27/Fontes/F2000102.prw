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
    PE FINM020 - Baixas a pagar
    atualiza a tabela PX0 com os dados do título baixado
    @type  Function
    @author Gianluca Moreira
    @since 17/05/2021
    /*/
User Function F2000102(oModel, cIdPonto, cIdModel)
    Local aAreaFK2  := FK2->(GetArea())
    Local aAreaFKA  := FKA->(GetArea())
    Local aAreaSE2  := SE2->(GetArea())
    Local aAreaPX0  := PX0->(GetArea())
    Local aAreas    := {aAreaFK2, aAreaFKA, aAreaSE2, aAreaPX0, GetArea()}
    Local aSaveRow  := FWSaveRows()
    Local cIDDoc    := ''
    Local cTpDoc    := ''
    Local cPgRec    := ''
    Local cChvSE2   := ''
    Local cChvPX0   := ''
    Local cDocs     := '' 
    Local nFKA      := 0
    Local nFK2      := 0
    Local oFKA		:= oModel:GetModel('FKADETAIL')
    Local oFK2		:= oModel:GetModel('FK2DETAIL')
    Local lRetBco   := FWIsInCallStack('FINA430') .Or. FWIsInCallStack('FINA300')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		AEval(aAreas, {|x| RestArea(x)})
        U_LimpaArr(aAreas)
        Return
    EndIf

    //FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
    FK2->(DbSetOrder(2)) //FK2_FILIAL+FK2_IDDOC+FK2_SEQ
    SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    PX0->(DbSetOrder(1)) //PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE+PX0_EXC
    For nFKA := 1 To oFKA:Length()
        oFKA:GoLine(nFKA)

        If oFK2:IsEmpty()
            Loop
        EndIf
            
        For nFK2 := 1 To oFK2:Length()
            oFK2:GoLine(nFK2)
            cIDDoc  := oFK2:GetValue('FK2_IDDOC')

            //Já processou este documento
            If (cIdDoc $ cDocs) 
                Loop
            EndIf

            cDocs += cIdDoc

            If FK2->(DbSeek(FWXFilial('FK2')+cIdDoc))
                While !FK2->(EoF()) .And. FK2->(FK2_FILIAL+FK2_IDDOC) == FWXFilial('FK2')+cIdDoc
                    //Integrada à PX0
                    If FK2->FK2_XPX0 $ '23' 
                        FK2->(DbSkip())
                        Loop
                    EndIf
                    cChvPX0   := FK2->(FK2_FILIAL+FK2_IDFK2)
                    //Já processou esse movimento de baixa - redundância
                    If PX0->(DbSeek(FWXFilial('PX0')+'FK2'+AvKey(cChvPX0, 'PX0_CHAVE')))
                        FK2->(DbSkip())
                        Loop
                    EndIf

                    cTpDoc    := FK2->FK2_TPDOC
                    If cTpDoc == 'CP' //Compensação de Pagamento - não reflete banco, não envia ao XRT
                        If RecLock('FK2', .F.)
                            FK2->FK2_XPX0 := '2' //Processado PX0
                            FK2->(MsUnlock())
                        EndIf
                        FK2->(DbSKip())
                        Loop
                    EndIf

                    cChvSE2   := U_F2000108(cIDDoc)
                    cPgRec    := FK2->FK2_RECPAG

                    If !Empty(cChvSE2) .And. SE2->(DbSeek(cChvSE2))
                        //Título de adiantamento é tratado a partir da FK5
                        //a FK2 registra apenas os movimentos de compensação, sem refletir banco
                        If SE2->E2_TIPO $ MVPAGANT
                            If RecLock('FK2', .F.)
                                FK2->FK2_XPX0 := '2' //Processado PX0
                                FK2->(MsUnlock())
                            EndIf
                            FK2->(DbSKip())
                            Loop
                        EndIf
                        

                        //Processando baixa por retorno bancário - PX0 já foi gerada no envio
                        //Não deve criar uma nova linha realizada/prevista
                        If lRetBco .And. cPgRec == 'P'
                            //If RecLock('FK2', .F.)
                            //    FK2->FK2_XPX0 := '3' //Baixa por retorno bancário
                            //    FK2->(MsUnlock())
                            //EndIf
                            U_F2000110(.F.) //Limpa o Flag de envio bancário na SE2
                            //FK2->(DbSKip())
                            //Loop
                        EndIf

                        If cPgRec == 'P'
                            //Verifica se foi enviado ao banco, sem retorno ainda
                            If SE2->E2_XENVBCO == '1' //Enviado
                                //Gera estorno por "rejeição bancária"
                                //U_F2000100('SE2', REJBAN_PREV)
                                //U_F2000100('SE2', REJBAN_REAL)   
                                U_F2000110(.F.) //Limpa o Flag de envio bancário na SE2                             
                            EndIf
                            U_F2000100('SE2', BAIXAT_PREV) //Zera a previsão
                            U_F2000100('FK2', BAIXAT_REAL) //Envia o realizado
                        ElseIf cPgRec == 'R'
                            U_F2000100('SE2', ESTBXA_PREV) //Recria a previsão
                            U_F2000100('FK2', ESTBXA_REAL) //Envia o estorno do realizado
                        EndIf

                        //Independente de gerar a PX0, marca como processado, pois existem condições
                        //onde não é gerada a PX0
                        If RecLock('FK2', .F.)
                            FK2->FK2_XPX0 := '2' //Processada PX0
                            FK2->(MsUnlock())
                        EndIf
                    EndIf
                    FK2->(DbSKip())
                EndDo
            EndIf                
        Next nFK2
    Next nFKA
  
    FWRestRows(aSaveRow, oModel)
    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return .T.

/*/{Protheus.doc} F2000108
    Recupera a chave do título a partir da baixa
    @type  Static Function
    @author Gianluca Moreira
    @since 25/05/2021
    @version version
    /*/
Static __aTamCpos := {}
User Function F2000108(cIDDoc)
    Local aAreaFK7  := FK7->(GetArea())
    Local aAreas    := {aAreaFK7, GetArea()}
    Local cChvSE2   := ''
    Local cChvFK7   := ''
    Local nAtu      := 0

    Set Deleted Off

    FK7->(DbSetOrder(1)) //FK7_FILIAL+FK7_IDDOC
    If FK7->(DbSeek(FWXFilial('FK7')+cIDDoc))
        cChvFK7 := FK7->FK7_CHAVE

        If Empty(__aTamCpos)
            aAdd(__aTamCpos,TamSXG('033')[1])
            aAdd(__aTamCpos,TamSX3('E2_PREFIXO')[1])
            aAdd(__aTamCpos,TamSXG('018')[1])
            aAdd(__aTamCpos,TamSXG('011')[1])
            aAdd(__aTamCpos,TamSX3('E2_TIPO')[1])
            aAdd(__aTamCpos,TamSXG('001')[1])
            aAdd(__aTamCpos,TamSXG('002')[1])
        Endif

        //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
        cChvSE2 := SubStr(cChvFK7, nAtu+1, __aTamCpos[1]); nAtu += __aTamCpos[1]+1 //Filial
        cChvSE2 += SubStr(cChvFK7, nAtu+1, __aTamCpos[2]); nAtu += __aTamCpos[2]+1 //Prefixo
        cChvSE2 += SubStr(cChvFK7, nAtu+1, __aTamCpos[3]); nAtu += __aTamCpos[3]+1 //Número
        cChvSE2 += SubStr(cChvFK7, nAtu+1, __aTamCpos[4]); nAtu += __aTamCpos[4]+1 //Parcela
        cChvSE2 += SubStr(cChvFK7, nAtu+1, __aTamCpos[5]); nAtu += __aTamCpos[5]+1 //Tipo
        cChvSE2 += SubStr(cChvFK7, nAtu+1, __aTamCpos[6]); nAtu += __aTamCpos[6]+1 //Fornecedor
        cChvSE2 += SubStr(cChvFK7, nAtu+1, __aTamCpos[7])                          //Loja
    EndIf

    Set Deleted On

    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return cChvSE2


/*/{Protheus.doc} User Function F2000109
    PE FINM020 - FORMLINEPRE - SETVALUE - FK2_TPDOC
    Verifica se está sendo gerada a linha do estorno da baixa, e apaga os campos
    customizados que tiveram seus valores copiados.
    @type  Function
    @author Gianluca Moreira
    @since 01/06/2021
    /*/
User Function F2000109(oModel)
    Local cTpDoc := ''
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Return
    EndIf
    
    cTpDoc := oModel:GetValue('FK2_TPDOC')
    If cTpDoc == 'ES'
        oModel:LoadValue('FK2_XMSXRT', '')
        oModel:LoadValue('FK2_XPX0', '1') //Não processado
        //Campos da integração da baixa
        oModel:LoadValue('FK2_XCDXRT', '')
        oModel:LoadValue('FK2_XPCXRT', '')
    EndIf
Return
