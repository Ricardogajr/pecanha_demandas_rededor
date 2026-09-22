#Include 'Protheus.ch'
#Include "TopConn.ch"

/*
	Executado Antes da execução do processo de carga, após a criação da tabela temporária.
*/
User Function EBExSC7() 
   Local lRet := .T.
   Local bExec:= {|| Exec() }
   
   MsgRun( "Numerando os Pedidos de Compra..." , "Aguarde..." , { || lRet := Exec() } )
   
Return lRet

**********************
Static Function Exec()
**********************
   Local lRet    := .T.
   Local cQuery  := "SELECT DISTINCT SC7.C7_FILIAL FILIAL FROM ARQSC7 SC7 "+ CRLF +;
                    "WHERE NUMEROLOTE = (SELECT MAX(X.NUMEROLOTE) FROM ARQSC7 X) ORDER BY SC7.C7_FILIAL"
   Local cAlias  := GetNextAlias()
   Local aResult := {}
   Local cNumero := ""
   Local cFilBak := cFilAnt

   TCQUERY cQuery NEW ALIAS (cAlias)
   
   While (cAlias)->(!Eof())
         
         If Empty((cAlias)->FILIAL)
            (cAlias)->(DbSkip(1))
            Loop
         Endif
         
         cFilAnt := (cAlias)->FILIAL
         cNumero := GetSxeNum("SC7","C7_NUM")
         
         aResult := TCSpExec("MIG_P12_NUMSC7", (cAlias)->FILIAL,'',cNumero)
         lRet := !Empty(aResult) .And. Empty(AllTrim(TcSqlError()))
         IF !lRet
		    MsgStop('Erro na execução da Stored Procedure : '+chr(13)+TcSqlError())
		    Exit
         Endif
         
         //AjustaSeq(aResult[1]) //Ajusta a numeração em SXE/SXF.
         (cAlias)->(DbSkip(1))
   Enddo              
   
   If (Select(cAlias) > 0)
      (cAlias)->(dbCloseArea())
   Endif
   
   cFilAnt := cFilBak

Return lRet
                     
*******************************                     
Static Function AjustaSeq(cNum)
*******************************
   Local nSaveSx8Len := 0 
   Local cSeq        := cNum
   Local nQtd        := 0
   
   While SC7->(GetSx8Len()) > 0
         SC7->(ConfirmSX8())
   Enddo

   While cSeq <= cNum
         cSeq := SC7->(GetSxeNum("SC7","C7_NUM"))
   Enddo
   
   While SC7->(GetSx8Len()) > 0
         SC7->(ConfirmSX8())
   Enddo
   
return .T.   
   