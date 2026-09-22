/*/{Protheus.doc} User Function F2000120
    Chama tela dos registros integrados ao XRT a partir do título
    a pagar
    @type  Function
    @author Gianluca Moreira
    @since 15/06/2021
    /*/
User Function F2000120()
    Local aAreaSE2 := SE2->(GetArea())
    Local aAreaFK2 := FK2->(GetArea())
    Local aAreaFK5 := FK5->(GetArea())
    Local aAreaFK7 := FK7->(GetArea())
    Local aAreaFKA := FKA->(GetArea())
    Local aAreaPX0 := PX0->(GetArea())
    Local aAreas   := {aAreaSE2, aAreaFK2, aAreaFK5, aAreaFK7, aAreaFKA, aAreaPX0, GetArea()}
    Local aRecPX0  := {}
    Local cChvFK2  := ''
    Local cChvFK5  := ''
    Local cChvFK7  := ''
    Local cChvSE2  := ''
    Local cIdDoc   := ''
    Local cIdProc  := ''
    Local cFunBkp  := FunName()
    Local cFiltro  := ''
    Local cQuery   := ''
    Local cAlFK5   := ''
    Local cIn      := ''
    Local nI       := ''
    Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual
    
    //Verifica se está habilitada a integração neste grupo de empresas
    If !lGrpHblt
        Help(,, "F2000130",, 'A integração do XRT não está habilitada nesta empresa.', 1, 0,;
		,,,,, {'Verifique se os campos do processo estão criados e habilite através da rotina F2000130'})
        Return
    EndIf

    cChvSE2 := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
    cChvSE2 := AvKey(cChvSE2, 'PX0_CHAVE')

    cChvFK7 := FWXFilial('SE2')+'|'
    cChvFK7 += SE2->E2_PREFIXO+ '|'
    cChvFK7 += SE2->E2_NUM+     '|'
    cChvFK7 += SE2->E2_PARCELA+ '|'
    cChvFK7 += SE2->E2_TIPO+    '|'
    cChvFK7 += SE2->E2_FORNECE+ '|'
    cChvFK7 += SE2->E2_LOJA

    FK7->(DbSetOrder(2)) //FK7_FILIAL+FK7_ALIAS+FK7_CHAVE
    FK2->(DbSetOrder(2)) //FK2_FILIAL+FK2_IDDOC+FK2_SEQ
    PX0->(DbSetOrder(1)) //PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE+PX0_EXC
    FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV

    //Movimentos de origem da SE2
    If PX0->(DbSeek(FWXFilial('PX0')+'SE2'+cChvSE2))
        While !PX0->(EoF()) .And. PX0->(PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE) == FWXFilial('PX0')+'SE2'+cChvSE2
            AAdd(aRecPX0, PX0->(Recno()))
            PX0->(DbSkip())
        EndDo
    EndIf

    //Movimentos de origem da FK2
    If FK7->(DbSeek(FWXFilial('FK7')+'SE2'+cChvFK7))
        cIdDoc := FK7->FK7_IDDOC
        If FK2->(DbSeek(FWXFilial('FK2')+cIdDoc))
            While !FK2->(EoF()) .And. FK2->(FK2_FILIAL+FK2_IDDOC) == FWXFilial('FK2')+cIdDoc
                cChvFK2 := FK2->(FK2_FILIAL+FK2_IDFK2)
                cChvFK2 := AvKey(cChvFK2, 'PX0_CHAVE')
                If PX0->(DbSeek(FWXFilial('PX0')+'FK2'+cChvFK2))
                    While !PX0->(EoF()) .And. PX0->(PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE) == FWXFilial('PX0')+'FK2'+cChvFK2
                        AAdd(aRecPX0, PX0->(Recno()))
                        PX0->(DbSkip())
                    EndDo
                ElseIf SE2->E2_TIPO $ MVPAGANT //Caso não encontre referente à FK2, procura na FK5 baixas manuais de PA
                    FKA->(DbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
                    If FKA->(DbSeek(FWXFilial('FKA')+'FK2'+FK2->FK2_IDFK2))
                        cIdProc := FKA->FKA_IDPROC
                        FKA->(DbSetOrder(2)) //FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
                        If FKA->(DbSeek(FWXFilial('FKA')+cIdProc))
                            While !FKA->(EoF()) .And. FKA->(FKA_FILIAL+FKA_IDPROC) == FWXFilial('FKA')+cIdProc
                                If FKA->FKA_TABORI != 'FK5'
                                    FKA->(DbSkip())
                                    Loop
                                EndIf
                                If FK5->(DbSeek(FWXFilial('FK5')+FKA->FKA_IDORIG))
                                    cChvFK5 := FK5->(FK5_FILIAL+FK5_IDMOV)
                                    cChvFK5 := AvKey(cChvFK5, 'PX0_CHAVE')
                                    If PX0->(DbSeek(FWXFilial('PX0')+'FK5'+cChvFK5))
                                        While !PX0->(EoF()) .And. PX0->(PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE) == FWXFilial('PX0')+'FK5'+cChvFK5
                                            AAdd(aRecPX0, PX0->(Recno()))
                                            PX0->(DbSkip())
                                        EndDo
                                    EndIf
                                EndIf
                                FKA->(DbSkip())
                            EndDo
                        EndIf
                    EndIf
                EndIf
                FK2->(DbSkip())
            EndDo
        EndIf
    EndIf

    //Movimentos de origem da FK5 - somente adiantamentos
    If SE2->E2_TIPO $ MVPAGANT .And. !Empty(cIdDoc)
        cQuery := " Select R_E_C_N_O_ FK5Rec From "+RetSqlName('FK5')+" "
        cQuery += "  Where FK5_FILIAL = '"+FWXFilial('FK5')+"' "
        cQuery += "    And FK5_IDDOC  = '"+cIDDoc+"' "
        cQuery += "    And D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)

        cAlFK5 := MPSysOpenQuery(cQuery)

        While !(cAlFK5)->(EoF())
            FK5->(DbGoto((cAlFK5)->FK5Rec))
            cChvFK5 := FK5->(FK5_FILIAL+FK5_IDMOV)
            cChvFK5 := AvKey(cChvFK5, 'PX0_CHAVE')
            If PX0->(DbSeek(FWXFilial('PX0')+'FK5'+cChvFK5))
                While !PX0->(EoF()) .And. PX0->(PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE) == FWXFilial('PX0')+'FK5'+cChvFK5
                    AAdd(aRecPX0, PX0->(Recno()))
                    PX0->(DbSkip())
                EndDo
            EndIf
            (cAlFK5)->(DbSkip())
        EndDo
        (cAlFK5)->(DbCloseArea())
    EndIf

    If Empty(aRecPX0)
        MsgAlert('Não foram localizados registros integrados ao XRT para o título.', 'Integ XRT')
        AEval(aAreas, {|x| RestArea(x)})
        Return
    EndIf

    For nI := 1 To Len(aRecPX0)
        cIn += cValToChar(aRecPX0[nI])+','
    Next nI
    cIn := Left(cIn, Len(cIn)-1)

    cFiltro := "@"
    cFiltro += " R_E_C_N_O_ In ("+cIn+") And "
    cFiltro += " D_E_L_E_T_ = ' ' "

    SetFunName('U_F2000101')
    PX0Wind(cFiltro)
    SetFunName(cFunBkp)

    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return

/*/{Protheus.doc} PX0Wind
    (long_description)
    @type  Static Function
    @author Gianluca Moreira
    @since 15/06/2021
    /*/
Static Function PX0Wind(cFiltro)
    Local aWindSize := FwGetDialogSize(oMainWnd)
	Local aDialog   := {0 ,  0, 75,  100} 
	Local oDialog
    Local cTitulo   := 'Integração XRT'
    Local aRotBkp   := aRotina

	aDialog := Ajusta(aWindSize, aDialog)
	oDialog :=  TDialog():New(aDialog[1], aDialog[2], aDialog[3], aDialog[4], cTitulo,,,,,,,,,.T.)
    aRotina := FwLoadMenuDef('F2000101')
	U_F2000101(cFiltro, oDialog)
	oDialog:Activate(,,,.T.)
	FreeObj(aDialog)
	FreeObj(oDialog)   
    aRotina := aRotBkp
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
