#Include 'TOTVS.ch'

/*/{Protheus.doc} User Function F2000104
    Processa o retorno do Status do XRT
    @type  Function
    @author Gianluca Moreira
    @since 18/05/2021
    /*/
User Function F2000104(oWsIn, oWsOut)
    Local aNotif  := {}
    Local cEmpAtu := '' 
    Local cFilAtu := ''
    Local cChave  := ''
    Local cStatus := ''
    Local cErro   := ''
    Local cMsg    := ''
    Local cEmpBkp := cEmpAnt
    Local cFilBkp := cFilAnt 
    Local oTitAtu := Nil
    Local nTit    := 0
    Private cUsername := ""

    Begin Transaction
        For nTit := 1 To Len(oWsIn:TITULOS)
            oTitAtu := oWsIn:TITULOS[nTit]
            cChave  := AllTrim(oTitAtu:E2_XCHVXRT)
            cEmpAtu := SubStr(cChave, 1, Len(cEmpAnt))
            cFilAtu := SubStr(cChave, Len(cEmpAnt)+1, Len(cFilAnt))
            cChave  := Right(cChave, TamSX3('PX0_CHVXRT')[1])
            cStatus := oTitAtu:STATUSIN
            cErro   := oTitAtu:ERRO
            /*/If !FWFilExist(cEmpAtu, cFIlAtu)
                Conout('F2000104 - Integ XRT - Empresa '+cEmpAtu+' Filial '+cFilAtu+' não encontrada')
                oWsOut:MSGOUT    := 'Empresa '+cEmpAtu+' Filial '+cFilAtu+' não encontrada'
                oWsOut:STATUSOUT := '2'
                DisarmTransaction()
                Break
            EndIf/*/
            //If cEmpAnt != cEmpAtu .Or. cFilAnt != cFilAtu
               /*/ If !RpcSetEnv(cEmpAtu, cFilAtu, 'Administrador',,'FIN')
                    Conout('F2000104 - Integ XRT - Falha ao preparar ambiente')
                    oWsOut:MSGOUT    := 'Falha ao preparar ambiente'
                    oWsOut:STATUSOUT := '2'
                    DisarmTransaction()
                    Break
                EndIf/*/
                cEmpAnt := cEmpAtu
                cFilAnt := cFilAtu
                __cUserId := "005026"
                cUserName := "Integrador"   
                //SM0->(DbSeek(cEmpAnt+cFilAnt))
            //EndIf
            If !UpdPX0(cChave, cStatus, cErro, oTitAtu, @cMsg, aNotif,cFilAtu)
                oWsOut:MSGOUT    := 'Falha ao atualizar titulo '+oTitAtu:E2_XCHVXRT
                oWSOut:MSGOUT    += ' '+cMsg
                oWsOut:STATUSOUT := '2'
                DisarmTransaction()
                Break
            EndIf
        Next nTit

        If !Empty(aNotif)
            cMsg := PrepHTML(aNotif)
            cPara := SuperGetMV('FS_C200012')
            // Envia e-mail de notificacao em thread separada para não precisar aguardar
            StartJob("U_F20005JB", GetEnvServer(), .F., cEmpAnt, cFilAnt, cPara, 'Integração XRT - Títulos a Pagar', cMsg)
        EndIf

        //If cEmpAnt != cEmpBkp .Or. cFilAnt != cFilBkp
            /*/If !RpcSetEnv(cEmpBkp, cFilBkp, 'Administrador',,'FIN')
                Conout('F2000104 - Integ XRT - Falha ao preparar ambiente')
                oWsOut:MSGOUT    := 'Falha ao preparar ambiente'
                oWsOut:STATUSOUT := '2'
                DisarmTransaction()
                Break
            EndIf/*/
            cEmpAnt := cEmpBkp
            cFilAnt := cFilBkp
            //SM0->(DbSeek(cEmpAnt+cFilAnt))
        //EndIf
        oWsOut:STATUSOUT := '1'
    End Transaction
Return

/*/{Protheus.doc} UpdPX0
    Atualiza o Status da PX0
    @type  Static Function
    @author Gianluca Moreira
    @since 18/05/2021
    /*/
Static Function UpdPX0(cChave, cStatus, cErro, oTitAtu, cMsg, aNotif,cFilAtu)
    Local aAreaSE2  := SE2->(GetArea())
    Local aAreaFK2  := FK2->(GetArea())
    Local aAreaFK5  := FK5->(GetArea())
    Local aAreaPX0  := PX0->(GetArea())
    Local aAreas    := {aAreaPX0, aAreaSE2, aAreaFK2, aAreaFK5, GetArea()}
    Local cOrigem   := ''
    Local lRet      := .T.
    Local nLenChave := 0
	Local lAtuPX0	:= .T.
	
    PX0->(DbSetOrder(3)) //PX0_FILIAL+PX0_CHVXRT
    If !PX0->(DbSeek(cFilAtu+cChave))
        lRet := .F.
        cMsg := 'Registro PX0 não localizado: '+cChave
        AEval(aAreas, {|x| RestArea(x)}) 
        U_LimpaArr(aAreas)
        Return lRet
    EndIf
	lAtuPX0 := .T.
    If PX0->PX0_STXRT != '5' //Só deixa atualizar o status se for igual a 5
		//
		// Não envia o retorno com o alerta
		//
        //lRet := .F.
        //cMsg := 'Registro PX0 com status já processado ou na fila. '
        //cMsg += 'somente é possível atualizar o status 5-aguardando retorno'
        //AEval(aAreas, {|x| RestArea(x)}) 
        //U_LimpaArr(aAreas)
        //Return lRet
		
		lAtuPX0 := .F.
    EndIf
    If RecLock('PX0', .F.)
		If lAtuPX0 // Só atualiza o status se for igual a 5
			PX0->PX0_STXRT  := cStatus
		Endif
        PX0->PX0_MSGXRT := cErro
        PX0->(MsUnlock())
    Else
        lRet := .F.
        cMsg := 'Não foi possível obter acesso exclusivo ao registro PX0'
    EndIf

    If !Empty(cErro) .And. lRet
        cOrigem := PX0->PX0_ORIGEM
        If cOrigem == 'SE2'
            nLenChave := Len(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
            SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
            If SE2->(DbSeek(SubStr(PX0->PX0_CHAVE, 1, nLenChave)))
                If RecLock('SE2', .F.)
                    SE2->E2_XMSGXRT := cErro
                    SE2->(MsUnlock())
                EndIf
            EndIf
        ElseIf cOrigem == 'FK2'
            nLenChave := Len(FK2->(FK2_FILIAL+FK2_IDFK2))
            FK2->(DbSetOrder(1)) //FK2_FILIAL+FK2_IDFK2
            If FK2->(DbSeek(SubStr(PX0->PX0_CHAVE, 1, nLenChave)))
                If RecLock('FK2', .F.)
                    FK2->FK2_XMSXRT := cErro
                    FK2->(MsUnlock())
                EndIf
            EndIf
        ElseIf cOrigem == 'FK5'
            nLenChave := Len(FK5->(FK5_FILIAL+FK5_IDMOV))
            FK5->(DbSetOrder(1)) //FK5_FILIAL+FK5_IDMOV
            If FK5->(DbSeek(SubStr(PX0->PX0_CHAVE, 1, nLenChave)))
                If RecLock('FK5', .F.)
                    FK5->FK5_XMSXRT := cErro
                    FK5->(MsUnlock())
                EndIf
            EndIf
        EndIf
        //PrepTab(aNotif, (cOrigem)->(Found()), cErro)
    EndIf

    cChave := PX0->PX0_FILIAL+PX0->PX0_CHVXRT
    /*/If lRet
        U_F07Log03("U_F2000104", oTitAtu, 'OK', "2", "PX0", 3, cChave)
    Else
        U_F07Log03("U_F2000104", oTitAtu, 'Falha', "1", "PX0", 3, cChave)
    EndIf/*/

    AEval(aAreas, {|x| RestArea(x)})
    U_LimpaArr(aAreas)
Return lRet

/*/{Protheus.doc} PrepTab
    Prepara a tabela que será enviada por e-mail
    @type  Static Function
    @author Gianluca Moreira
    @since 27/07/2021
    /*/
Static Function PrepTab(aTable, lEncontrou, cErro)
    Local cChvSE2 := ''
    
    If !Empty(aTable)
        AAdd(aTable, {'---', '---'})
    EndIf
    AAdd(aTable, {'Grupo: ',  cEmpAnt})
    AAdd(aTable, {'Filial: ', cFilant})
    If lEncontrou
        If PX0->PX0_ORIGEM == 'SE2'
            cChvSE2 := RTrim(PX0->PX0_CHAVE)
        ElseIf PX0->PX0_ORIGEM == 'FK2'
            cChvSE2 := U_F2000108(FK2->FK2_IDDOC)
        ElseIf PX0->PX0_ORIGEM == 'FK5'
            cChvSE2 := U_F2000211(FK5->FK5_IDMOV, FK5->FK5_IDDOC)
        EndIf
    EndIf

    If !Empty(cChvSE2) .And. SE2->(DbSeek(cChvSE2))
        AAdd(aTable, {'Prefixo:', SE2->E2_PREFIXO})
        AAdd(aTable, {'Número:', SE2->E2_NUM})
        AAdd(aTable, {'Parcela:', SE2->E2_PARCELA})
        AAdd(aTable, {'Tipo:', SE2->E2_TIPO})
        AAdd(aTable, {'Fornecedor:', SE2->E2_FORNECE})
        AAdd(aTable, {'Loja:', SE2->E2_LOJA})
        AAdd(aTable, {'Crítica:', cErro})
    Else
        AAdd(aTable, {'Origem:', PX0->PX0_ORIGEM})
        AAdd(aTable, {'Chave PX0:', PX0->PX0_CHAVE})
        AAdd(aTable, {'Crítica:', cErro})
    EndIf
Return

/*/{Protheus.doc} PrepHTML
    Prepara o e-mail que será enviado caso hajam erros
    @type  Static Function
    @author Gianluca Moreira
    @since 27/07/2021
    /*/
Static Function PrepHTML(aTable)
    Local cHTML     := ""
    Local nTable    := 1

    Default aTable  := {}


	cHTML := "<html>"
	cHTML += "<head>"
	cHTML += "<title>Integração XRT - Títulos a Pagar</title>"
	cHTML += "</head>"
	cHTML += "<body>" 
	cHTML += "<article>"
    cHTML += "<br><p style='font-size: 20px'>Dados dos títulos com crítica ao integrar com XRT:</p>"	

    If Len(aTable) > 0
        cHTML += "<br><table border='0'>"
        For nTable := 1 To Len(aTable)
            cHTML += "<tr>"
            cHTML += "<td>" + aTable[nTable, 1] + "</td>"
            cHTML += "<td>" + aTable[nTable, 2] + "</td>"
            cHTML += "</tr>"
        Next nTable
        cHTML += "</table>"
    Endif
    cHTML += "<br><p style='font-size: 10px'>* E-mail enviado automaticamente</p>"	
    cHTML += "</article>"
	cHTML += "</body>"
	cHTML += "</html>"

Return cHTML
