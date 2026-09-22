#Include 'Protheus.ch'
#Include 'TopConn.Ch'

/*/{Protheus.doc} FA420NAR
    Ponto de entrada para retornar o diretório e nome do arquivo a ser gerado
    @type  User Function
    @author Ramon Teodoro
    @since 11/09/2020
    @return cRet
    @example
    @see (links_or_references)
    /*/
User Function FA420NAR()
    
Local aArea   := GetArea()
Local cRet    := Paramixb
Local cDirArq := Alltrim(GetMV( "FS_XDIRARQ" , .F. , .F. )) 
Local cNumArq := Alltrim(GetMV( "FS_XNUMARQ" , .F. , .F. ))

If !IsInCallStack("U_TEWBTYP4")

    If !Empty(cDirArq) .And. !Empty(cNumArq) 

        If !ExistDir(cDirArq)
            MsgAlert( "O diretório: '" + cDirArq + "' não existe. Verifique o parâmetro FS_XDIRARQ ")
            cRet := ""
        Else     
            cNumArq := Soma1(cNumArq)	
            
            If At("\", cDirArq) > 0
                cRet := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "\", cDirArq, cDirArq+"\") + cNumArq + "." + Alltrim(SEE->EE_EXTEN)
            ElseIf At("/", cDirArq) > 0
                cRet := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "/", cDirArq, cDirArq+"/") + cNumArq  + "." + Alltrim(SEE->EE_EXTEN)
            EndIf           
           
            PutMV("FS_XNUMARQ", cNumArq)
        
        EndIf

    Else

        MsgAlert( "Parâmetros FS_XDIRARQ ou FS_XNUMARQ não foram definidos para esta filial.")
        cRet := ""
        
    EndIf

EndIf

RestArea(aArea)
Return cRet
