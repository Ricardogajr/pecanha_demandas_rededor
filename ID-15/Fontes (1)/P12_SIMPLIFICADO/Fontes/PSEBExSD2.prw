#Include 'Protheus.ch'
#Include "TopConn.ch"

/*
	Executado Antes da execução do processo de carga, após a criação da tabela temporária.
*/
User Function EBExSD2(cTable)
   Local aArea := GetArea()
   Local lRet  := .T.
   Local bExec := {|| lRet := Exec("Z"+cTable) }
    
   MsgRun( "Gerando o sequencial do estoque (NUMSEQ)..." , "Aguarde..." , bExec )
   
   RestArea(aArea)
   
Return lRet

****************************
Static Function Exec(cTable)
****************************
   Local lRet       := .T.
   Local cQuery     := "SELECT Z.LINHAO, Z.NUMLINHA FROM "+cTable+" Z ORDER BY Z.NUMLINHA"
   Local cCmd       := "UPDATE "+cTable+" SET LINHAO = '{1}' WHERE NUMLINHA={2}"
   Local cAlias     := GetNextAlias()
   Local aResult    := {}
   Local aHeader    := {}
   Local aData      := {}
   Local aRow       := {}
   Local nD2_NUMSEQ := 0
   Local cNumSeq    := SuperGetMV("MV_DOCSEQ",.F.,Replicate("0",TamSx3("D2_NUMSEQ")[1])) 
   Local nX         := 0
   Local cSep       := ""
   
   If Empty(cNumSeq)
      cNumSeq := Replicate("0",TamSx3("D2_NUMSEQ")[1])
   Endif
   
   TCQUERY cQuery NEW ALIAS (cAlias)
   
   (cAlias)->(DbGoTop())
   
   cSep := ";"
   If (AT(CHR(165),(cAlias)->LINHAO) > 0)
      cSep := CHR(165)
   ElseIf (AT(CHR(167),(cAlias)->LINHAO) > 0)
      cSep := CHR(167)
   Endif
   
   aHeader := StrTokArr2(AllTrim( (cAlias)->LINHAO ),cSep,.T.) 
   If (cAlias)->(!Eof())
      (cAlias)->(DbSkip())
   Endif
   
   nD2_NUMSEQ := AScan(aHeader,{|h| AllTrim(h) == "D2_NUMSEQ"})
   
   If nD2_NUMSEQ == 0
      MsgAlert('O campo "D2_NUMSEQ" não está presente no arquivo! Verifique.')
      return .F. 
   Endif
   
   While (cAlias)->(!Eof())
         
         aRow := StrTokArr2(AllTrim( (cAlias)->LINHAO ),cSep,.T.)
         
         If (Len(aRow) <> Len(aHeader)) 
            If ! MsgYesNo("O dado contido na linha nro."+cValToChar((cAlias)->NUMLINHA)+CRLF+;
                     "(Colunas = "+cValToChar(Len(aRow))+")"+CRLF+;
                     " diverge da quantidade de colunas do cabeçalho. (Colunas = "+cValToChar(Len(aHeader))+")"+CRLF+;
                     "Deseja continuar?","Confirmação")
               lRet := .F.
               Exit
            Endif

            (cAlias)->(DbSkip(1))
            Loop            
         Endif
         
         cNumSeq := fSoma1(cNumSeq,6)
         
         aRow[nD2_NUMSEQ] := cNumSeq  
         
         Aadd(aData, StrTran(StrTran(cCmd,"{1}",ArrTokStr(aRow,cSep)),"{2}",cValToChar((cAlias)->NUMLINHA)) )
         
         (cAlias)->(DbSkip(1))
   Enddo
   
   If (Select(cAlias) > 0)
      (cAlias)->(dbCloseArea())
   Endif
   
   If !lRet
      Return lRet
   Endif
   
   For nX := 1 To Len(aData)
       If (TCSqlExec(aData[nX]) < 0)
          MsgAlert("Erro durante a atualização da tabela temporária!"+ CRLF + TcSqlError())
          return .F.
       Endif
   Next nX
   
   PutMV("MV_DOCSEQ",cNumSeq)
                 
Return lRet

**********************************
Static Function fSoma1(cNum,nSize)
**********************************
   Local nNum := VAL( RetAsc(cNum,18,.F.) ) + 1
   Local cRet := RetAsc(nNum,nSize,.T.)
   If (Len(cRet) > nSize)
      cRet := Replicate('0',nSize)
   Endif
Return cRet
