#Include 'TOTVS.ch'

/*/{Protheus.doc} User Function F2000410
    PE FA100VLD - Valida cancelamento/exclusão da movimentação bancária.
    @type  Function
    @author Gianluca Moreira
    @since 31/05/2021
    /*/
User Function F2000410()
    Local lRet    := .T.
    Local cUsers  := SuperGetMV('FS_C200042',, '')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Return lRet
    EndIf

    If FWIsInCallStack('U_F2000401') .And. FWIsInCallStack('EstMvBco') 
        Return lRet
    EndIf

    If (RetCodUsr() $ cUsers)
        Return lRet
    EndIf

    If !Empty(SE5->E5_XCODXRT)
        lRet := .F.
        Help(,, "F2000410",, "Não é permitido alterar/excluir movimentação integrada do XRT.", 1, 0)
    EndIf
Return lRet

/*/{Protheus.doc} User Function F2000411
    PE FA100VET - Valida estorno entre contas
    @type  Function
    @author Gianluca Moreira
    @since 31/05/2021
    /*/
User Function F2000411(nRecOrig, nRecDest)
    Local aAreaSE5 := SE5->(GetArea())
    Local aAreas   := {aAreaSE5, GetArea()}
    local lRet := .T.
    Local cUsers  := SuperGetMV('FS_C200042',, '')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Return lRet
    EndIf

    If FWIsInCallStack('U_F2000401') .And. FWIsInCallStack('EstMvBco') 
        Return lRet
    EndIf

    If (RetCodUsr() $ cUsers)
        Return lRet
    EndIf

    SE5->(DbGoto(nRecOrig))
    If !Empty(SE5->E5_XCODXRT)
        lRet := .F.
        Help(,, "F2000411",, "Não é permitido alterar/excluir movimentação integrada do XRT.", 1, 0)
    EndIf

    If lRet
        SE5->(DbGoto(nRecDest))
        If !Empty(SE5->E5_XCODXRT)
            lRet := .F.
            Help(,, "F2000411",, "Não é permitido alterar/excluir movimentação integrada do XRT.", 1, 0)
        EndIf
    EndIf

    AEval(aAreas, {|x| RestArea(x)})
Return lRet

/*/{Protheus.doc} User Function F2000412
    PE F380MTR - Após confirmar a conciliação bancária, antes de gravar as tabelas
    Caso seja alterada a conciliação de algum movimento da SE5 vinda do XRT, desfaz
    a alteração
    @type  Function
    @author Gianluca Moreira
    @since 31/05/2021
    /*/
User Function F2000412(lInverte, cMarca)
    Local aAreaSE5 := SE5->(GetArea())
    Local aAreaTRB := TRB->(GetArea())
    Local aAreas   := {aAreaSE5, aAreaTRB, GetArea()}
    Local cMsg     := ''
    Local cMsg2    := ''
    Local dDtDpSE5 := CToD('')
    Local dDtDpTRB := CToD('')
    Local lConcSE5 := .F.
    Local lConcTRB := .F.
    Local cUsers   := SuperGetMV('FS_C200042',, '')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Return
    EndIf

    If (RetCodUsr() $ cUsers)
        Return
    EndIf

    TRB->(DbGoTop())
    While !TRB->(EoF())
        SE5->(DbGoto(TRB->E5_RECNO))
        If Empty(SE5->E5_XCODXRT) //Não veio do XRT
            TRB->(DbSkip())
            Loop
        EndIf
        lConcSE5 := !Empty(SE5->E5_RECONC)
        //lConcTRB := IIf(!lInverte, TRB->E5_OK == cMarca, !(TRB->E5_OK == cMarca))
        lConcTRB := !Empty(TRB->E5_OK)
        dDtDpSE5 := SE5->E5_DTDISPO
        dDtDpTRB := TRB->E5_DTDISPO

        If lConcSE5 != lConcTRB .Or. dDtDpSE5 != dDtDpTRB
            If RecLock('TRB', .F.)
                TRB->E5_OK      := IIf(lConcSE5, 'X', '')
                TRB->E5_DTDISPO := dDtDpSE5
                TRB->(MsUnlock())
            EndIf
            cMsg += CRLF
            cMsg += DToC(SE5->E5_DTDISPO)+' - '
            cMsg += AllTrim(Transform(SE5->E5_VALOR, PesqPict("SE5","E5_VALOR",19)))+' - '
            cMsg += SE5->E5_NATUREZ+' - '
            cMsg += SE5->E5_BANCO+' - '
            cMsg += SE5->E5_AGENCIA+' - '
            cMsg += SE5->E5_CONTA+' - '
            cMsg += DToC(SE5->E5_DATA)+' - '
            cMsg += AllTrim(SE5->E5_BENEF)+' - '
            cMsg += AllTrim(SE5->E5_HISTOR)
        EndIf
        TRB->(DbSkip())
    EndDo

    If !Empty(cMsg)
        cMsg2 := 'O(s) movimento(s) abaixo são de origem do XRT e não podem ter seu '
        cMsg2 += 'Status de conciliação/Data de disponibilidade alterados. A alteração foi desfeita.'+CRLF
        cMsg2 += 'Dt Disp. - Valor - Natureza - Banco - Agência - Conta - Dt Mov. - Benef. - Histór.'
        cMsg2 += cMsg
        cMsg2 += CRLF+CRLF
        cMsg2 += 'Caso precise alterar, realize o estorno no XRT e integre novamente.'
        U_F2000414('Conciliação Bancária', cMsg2)
    EndIf

    AEval(aAreas, {|x| RestArea(x)})
Return

/*/{Protheus.doc} User Function F2000413
    F380CPOS - Adiciona e move campos na tela de conciliação bancária
    Adiciona os campos customizados do processo de integração do XRT
    @type  Function
    @author Gianluca Moreira
    @since 01/06/2021
    /*/
User Function F2000413(aCampos)
    Local aCamposNew := {}
    Local nI         := 0
    //Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    //If !lGrpHblt
	//	Return aCampos
    //EndIf

    AAdd(aCamposNew, aCampos[1]) //E5_OK
    AAdd(aCamposNew, aCampos[2]) //E5_FILIAL
    AAdd(aCamposNew, aCampos[3]) //E5_DTDISPO
    AAdd(aCamposNew, aCampos[4]) //E5_MOEDA
    AAdd(aCamposNew, aCampos[5]) //E5_VALOR
    If SE5->(FieldPos('E5_XCODXRT')) > 0
	    AAdd(aCamposNew, {'E5_XCODXRT',,'Código XRT'})
	    AAdd(aCamposNew, {'E5_XPCXRT',, 'Par Cont. XRT'})
	    AAdd(aCamposNew, {'E5_XINTXRT',,'Origem XRT'})
    EndIf
    For nI := 6 To Len(aCampos)
        AAdd(aCamposNew, aCampos[nI])
    Next nI 

Return aCamposNew

/*/{Protheus.doc} F2000414
Exibe uma tela com texto e barra de rolagem, substituindo a função Aviso
@author Gianluca Moreira
@since 23/07/2019
@version 1.0
@return Nil, Nil
@param cTitulo, characters, Título da Janela
@param cMsg, characters, Mensagem a ser apresentada
@type function
/*/
User Function F2000414(cTitulo, cMsg)
	Local aWindSize := FwGetDialogSize(oMainWnd)
	Local aDialog   := {00 , 00, 60,  80} 
	Local aMultGet  := {01 , 01, 90,  97} //Linha, Coluna, Altura, Largura
	Local aBotaoOk  := {91 , 84, 08,  14} //Linha, Coluna, Altura, Largura
	Local bBotaoOk  := {|| oDialog:End()}
	Local cMensagem := cMsg
	Local oDialog   := Nil
	Local oMultGet  := Nil
	Local oBotaoOk  := Nil
    Local oFont     := Nil

	aDialog := Ajusta(aWindSize, aDialog)	

	//Janela Principal
	oDialog :=  TDialog():New(aDialog[1], aDialog[2], aDialog[3], aDialog[4], cTitulo,,,,,,,,,.T.)

	aMultGet := Ajusta(aDialog, aMultGet)
	aBotaoOk := Ajusta(aDialog, aBotaoOk)

    oFont    := TFont():New('Courier new',,-14,.T.)

	oMultGet := TMultiGet():New(aMultGet[1]/2, aMultGet[2]/2, { | u | If( PCount() == 0, cMensagem, cMensagem := u ) }, oDialog,;
	aMultGet[4]/2, aMultGet[3]/2,oFont,,,,, .T.,,,,,,.T.,,,,.T.,.T.)

	oBotaoOk := TButton():New(aBotaoOk[1]/2, aBotaoOk[2]/2, 'OK',;
	oDialog, bBotaoOk, aBotaoOk[4]/2, aBotaoOk[3]/2, Nil, Nil, Nil, .T.)

	oDialog:Activate(,,,.T.)

Return

/*/{Protheus.doc} Ajusta
Converte os tamanhos passados em % para pixel, para desenhar as telas
@author Gianluca Moreira
@since 24/06/2019
@version 1.0
@return aAjustado, Array com as coordenadas convertidas de % para pixel
@param aWind, array, Array com as dimensões da janela
@param aItem, array, Array a ser ajustado
@type function
/*/
Static Function Ajusta(aWind, aItem)
	Local aAjustado := {0, 0, 0, 0}
	Local nLarg     := aWind[4]-aWind[2]
	Local nAlt      := aWind[3]-aWind[1]

	aAjustado[1] := int(aItem[1]*nAlt/100)
	aAjustado[2] := int(aItem[2]*nLarg/100)
	aAjustado[3] := int(aItem[3]*nAlt/100)
	aAjustado[4] := int(aItem[4]*nLarg/100)
Return aClone(aAjustado)

/*/{Protheus.doc} User Function F2000415
    Valid do campo E2_XOPFXRT
    @type  Function
    @author Gianluca Moreira
    @since 14/06/2021
    /*/
User Function F2000415()
    Local aAreaSE2 := SE2->(GetArea())
    Local aAreas   := {aAreaSE2, GetArea()}
    Local cOpFin   := ''
    Local cNaturez := M->E2_NATUREZ
    Local dDtVenc  := M->E2_VENCREA
    Local lRet     := .T.
    Local nOpFin   := Val(M->E2_XOPFXRT)
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		lRet := .F.
        Help(,, "F2000415",, "Não é permitido informar operação - integração XRT desabilitada nesta empresa", 1, 0)
        Return lRet
    EndIf

    If nOpFin < 0
        lRet := .F.
        Help(,, "F2000415",, "Não é permitido informar operação negativa.", 1, 0)
        Return lRet
    EndIf

    If nOpFin == 0
        M->E2_XOPFXRT := Space(TamSX3('E2_XOPFXRT')[1])
        Return lRet
    EndIf

    cOpFin := StrZero(nOpFin, TamSX3('E2_XOPFXRT')[1])
    //If Empty(cNaturez) .Or. Empty(dDtVenc)
    If Empty(dDtVenc)
        M->E2_XOPFXRT := cOpFin
        Return lRet
    EndIf

    SE2->(DBOrderNickName('FSW2000400')) //E2_FILIAL+DTOS(E2_VENCREA)+E2_XOPFXRT+E2_NATUREZ
    //Removida natureza da chave da operação financeira do título
    //If SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin+cNaturez))
    If SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin))
        lRet := .F.
        Help(,, "F2000415",, "Já existe título incluso com mesma data de vencimento, "+;
        'Operação Financeira.', 1, 0)
        AEval(aAreas, {|x| RestArea(x)})
        Return lRet
    EndIf

    M->E2_XOPFXRT := cOpFin
    AEval(aAreas, {|x| RestArea(x)})
Return lRet

/*/{Protheus.doc} User Function F2000416
    PE FA050INC - Valida inclusão de título a pagar
    PE FA050ALT - Valida alteração de título a pagar
    Verifica se já existe registro criado da mesma operação financeira
    @type  Function
    @author Gianluca Moreira
    @since 14/06/2021
    /*/
User Function F2000416()
    Local aAreaSE2 := SE2->(GetArea())
    Local aAreas   := {aAreaSE2, GetArea()}
    Local cOpFin   := M->E2_XOPFXRT
    Local cNaturez := M->E2_NATUREZ
    Local dDtVenc  := M->E2_VENCREA
    Local lRet     := .T.
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Return lRet
    EndIf

    If Empty(cOpFin)
        Return lRet
    EndIf

    SE2->(DBOrderNickName('FSW2000400')) //E2_FILIAL+DTOS(E2_VENCREA)+E2_XOPFXRT+E2_NATUREZ
    //If SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin+cNaturez))
    //Removida natureza da chave da operação financeira do título
    If SE2->(DbSeek(FWXFilial('SE2')+DToS(dDtVenc)+cOpFin))
        lRet := .F.
        Help(,, "F2000416",, "Já existe título incluso com mesma data de vencimento, "+;
        'Operação Financeira.', 1, 0)
        Return lRet
    EndIf

    AEval(aAreas, {|x| RestArea(x)})
Return lRet

/*/{Protheus.doc} User Function F2000417
    PE FINM020 - Baixas a Pagar
    MODELPOS - Validação total do modelo
    Impede baixa/estorno de baixa de título de operação financeira
    @type  Function
    @author Gianluca Moreira
    @since 17/06/2021
    /*/
User Function F2000417(oModel)
    Local aAreaFK2  := FK2->(GetArea())
    Local aAreaFKA  := FKA->(GetArea())
    Local aAreaSE2  := SE2->(GetArea())
    Local aAreas    := {aAreaFK2, aAreaFKA, aAreaSE2, GetArea()}
    Local aSaveRow  := FWSaveRows()
    Local cDocs     := ''
    Local cIDDoc    := ''
    Local cMsg      := ''
    Local lRet      := .T.
    Local nFKA      := 0
    Local nFK2      := 0
    Local oFKA		:= oModel:GetModel('FKADETAIL')
    Local oFK2		:= oModel:GetModel('FK2DETAIL')
    Local cUsers    := SuperGetMV('FS_C200042',, '')
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    //Integração não habilitada neste grupo
    If !lGrpHblt
		Return lRet
    EndIf

    If (RetCodUsr() $ cUsers)
        Return lRet
    EndIf

    If FWIsInCallStack('U_F2000401') //Chamado do WebService
        Return lRet
    EndIf

    FK2->(DbSetOrder(2)) //FK2_FILIAL+FK2_IDDOC+FK2_SEQ
    SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
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
                    cChvSE2   := U_F2000108(cIDDoc)
                    cPgRec    := FK2->FK2_RECPAG

                    If !Empty(cChvSE2) .And. SE2->(DbSeek(cChvSE2))
                        If Empty(SE2->E2_XOPFXRT)
                            FK2->(DbSKip())
                            Loop
                        EndIf
                        cMsg := 'Não é permitido '
                        If cPgRec == 'P'
                            cMsg += 'baixar um '
                        ElseIf cPgRec == 'R'
                            cMsg += 'estornar a baixa de um '
                        EndIf
                        cMsg += 'título de operação financeira. Realize a operação no XRT.'
                        lRet := .F.
                        Help(,, "F2000417",, cMsg, 1, 0)
                        FWRestRows(aSaveRow, oModel)
                        AEval(aAreas, {|x| RestArea(x)})
                        Return lRet
                    EndIf
                    FK2->(DbSKip())
                EndDo
            EndIf                
        Next nFK2
    Next nFKA

    FWRestRows(aSaveRow, oModel)
    AEval(aAreas, {|x| RestArea(x)})
Return lRet


/*/{Protheus.doc} User Function F2000417
    Grava, na SE2, o campo E2_XOPFXRT, quando gerado a partir de uma solicitação
    de pagamentos (SC7)

    Regra:
    Os 6 primeiros digitos da solicitação serão convertidos em operação
    os 3 ultimos serão sequenciais para não repetir a numeração da nota
    só executa se a série for XRT
    @type  Function
    @author Gianluca Moreira
    @since 20/08/2021
    /*/
User Function F2000418()
    Local aAreaSC7  := SC7->(GetArea())
    Local aAreaSD1  := SD1->(GetArea())
    Local aAreaSE2  := SE2->(GetArea())
    Local aAreas    := {aAreaSC7, aAreaSD1, aAreaSE2, GetArea()}
    Local nOpFin    := 0
    Local cOpFin    := ''
    Local cSerie    := SD1->D1_SERIE
    Local cDoc      := SD1->D1_DOC

    If AllTrim(cSerie) == 'XRT'
        nOpFin := Val(SubStr(cDoc, 1, 6))
        cOpFin := StrZero(nOpFin, TamSX3('E2_XOPFXRT')[1])
        SE2->E2_XOPFXRT := cOpFin
    EndIf

    /*
    SC7->(DbSetOrder(1)) //C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
    If SC7->(DbSeek(FWXFilial('SC7')+SD1->D1_PEDIDO))
        nOpFin := Val(SC7->C7_XOPFXRT)
        cOpFin := StrZero(nOpFin, TamSX3('E2_XOPFXRT')[1])
        SE2->E2_XOPFXRT := cOpFin
    EndIf*/

    AEval(aAreas, {|x| RestArea(x)})
Return
