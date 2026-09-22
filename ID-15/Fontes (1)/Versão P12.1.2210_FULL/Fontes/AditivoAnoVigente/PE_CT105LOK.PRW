#Include "Protheus.ch"
//CT105TOK
User Function CT105LOK
Local lRet      := .T. 
Local cTexto    := ""
Local cTitulo   := ""
Local cCodUsr   := RetCodUsr()
Local IsAdmin   := FWIsAdmin(cCodUsr)
Local cUserAut  := Alltrim(SuperGetMV("PS_UEXCCTB",.F., "000322"))
Local cGrpAut   := Alltrim(SuperGetMV("PS_GEXCCTB",.F., "000000"))
Local aGrupUser := UsrRetGrp()
//Local cEncodeUTF8, cDecodeUTF8
Local Ny := 0
Local lAutExclui := .F.

If !IsInCallStack('CTBA103') .and. !IsInCallStack('CTBA102') .and.  !IsInCallStack('CTBA101')
    Return lRet
EndIf 

//If IsInCallStack('CTBAFIN') .or.  IsInCallStack('CTBANFE') .or.  IsInCallStack('CTBANFS') ;
//   .or.  IsInCallStack('CTBAATF') .or.  IsInCallStack('MATA331')  .or. IsInCallStack('GPEM110') ;
//    .or. IsInCallStack('F0101001') .or.  IsInCallStack('F0100404')
//    Return lRet
//EndIf 

If cCodUsr $ cUserAut
    lAutExclui := .T.
ElseIf IsAdmin
    lAutExclui := .T.
Else 
    For Ny := 1 to Len(aGrupUser)
        If aGrupUser[Ny] == cGrpAut
           lAutExclui := .T. 
        EndIf 
    Next Ny 
Endif 

If !lAutExclui
    If TMP->CT2_FLAG == .T. .AND. ALTERA 

        cTexto  += '<font color="#ff0000"><b>NÃo é permitido excluir linha </b></font>, o Lançamento não será gravado<br>'
        cTexto  += '<br><br><b>Contate o Administrador</b>'
        cMensagem   := EncodeUTF8(cTexto)
        cMensagem   := DecodeUTF8(cMensagem)

        cTitulo := '<h1><font color="#ff0000"><b>Atenção!</b></font></h1>'
        cTitulo := EncodeUTF8(cTitulo)
        cTitulo := DecodeUTF8(cTitulo)

        MsgInfo(cMensagem,cTitulo)

        lRet := .F.
    ElseIf Altera 
        TMP->(DbGoTop())
        While TMP->(!Eof())
            If TMP->CT2_FLAG == .T.
                lRet := .F.
            EndIf 
            TMP->(dbSkip())
        Enddo
        If !lRet
            cTexto  += '<center><font color="#ff0000"><b>Existem linhas deletadas na rotina de lançamento contábil</b></font>, o Lançamento não será gravado<br></center>'
            cTexto  += '<font color="#FF0000"><b>Contate o Administrador</b></font>'
            cMensagem   := EncodeUTF8(cTexto)
            cMensagem   := DecodeUTF8(cMensagem)

            cTitulo := '<h1><font color="#ff0000"><b>Atenção!</b></font></h1>'
            cTitulo := EncodeUTF8(cTitulo)
            cTitulo := DecodeUTF8(cTitulo)

            MsgInfo(cMensagem,cTitulo)
        EndIf 


        If Type("nDbRecTMP") <> "U"
            If nDbRecTMP <> TMP->( RECNO() )
                oGetDB:Goto( nDbRecTMP )
                TMP->(DbGoTo(nDbRecTMP))
            EndIf 
        EndIf 
        
    EndIf 
EndIf 

Return lRet
