#Include 'Protheus.ch'
#Include "TopConn.ch"

User Function Exp2DBF()
   Local aFiles   := {}
   //Local cPath    := "\sigadoc\RAT\"
   Local cAlias   := GetNextAlias()
   Local x,f      := 0
   //Local nSeek    := 10
   Local cQuery   := ""
   Local cCQuery  := "SELECT * FROM {1}"
   /*
   Aadd(aFiles,'CTC_INC')
   Aadd(aFiles,'CTE_INC')
   Aadd(aFiles,'CTF_INC')
   Aadd(aFiles,'CTG_INC')
   Aadd(aFiles,'CTN_INC')
   Aadd(aFiles,'CTO_INC')
   Aadd(aFiles,'CTS_INC')
   Aadd(aFiles,'CTU_INC')
   Aadd(aFiles,'CTV_INC')
   Aadd(aFiles,'CTW_INC')
   Aadd(aFiles,'CTX_INC')
   Aadd(aFiles,'CTY_INC')
   Aadd(aFiles,'CT2_INC')
   Aadd(aFiles,'CT3_INC')
   Aadd(aFiles,'CT6_INC')
   Aadd(aFiles,'CT7_INC')
   Aadd(aFiles,'CT8_INC')
   Aadd(aFiles,'SA6_INC')
   Aadd(aFiles,'SEA_INC')
   Aadd(aFiles,'SEF_INC')
   Aadd(aFiles,'SE1_INC')
   Aadd(aFiles,'SE2_INC')
   Aadd(aFiles,'SE5_INC')
   Aadd(aFiles,'SE8_INC')
   Aadd(aFiles,'SE2_INC')
   Aadd(aFiles,'SE5_INC')
   Aadd(aFiles,'SE8_INC')
*/

Aadd(aFiles,'SA2010')
Aadd(aFiles,'CT1010')
Aadd(aFiles,'SED010')
Aadd(aFiles,'SB1010')
Aadd(aFiles,'SBM010')
Aadd(aFiles,'SAH010')
Aadd(aFiles,'P17010')
Aadd(aFiles,'P24010')
Aadd(aFiles,'P25010')
Aadd(aFiles,'P13010')
Aadd(aFiles,'P14010')
Aadd(aFiles,'P15010')
Aadd(aFiles,'P16010')

   For x := 1 To Len(aFiles)
   
       cAlias := aFiles[x]
       
       If (Select(cAlias) > 0)
          (cAlias)->(dbCloseArea())
       Endif     
   
       If ! MsFile(aFiles[x]) 
          fMsgStop('Tabela "{1}" não existe! Verifique.',{aFiles[x]})
          Loop
       Endif
       
       If ! TcCanOpen(aFiles[x])
          fMsgStop('Tabela "{1}" não pode ser utilizada! Verifique.',{aFiles[x]})
          Loop
       Endif
       
       cQuery := StrTran(cCQuery,"{1}",aFiles[x])
       
       TCQUERY cQuery NEW ALIAS (cAlias)   

       If (cAlias)->(Eof())
          Loop
       Endif
       
       For f := 1 To (cAlias)->(FCount())
           cCampo := (cAlias)->(FieldName(f))
           if !Empty(FWSX3Util():GetFieldType(cCampo)) .And. GetSx3Cache( cCampo ,"X3_TIPO") $ "D|N"
              do Case
                 case (GetSx3Cache( cCampo ,"X3_TIPO") == "D")
                      TCSetField(cAlias,(cAlias)->(FieldName(f)),"D")
                 case (GetSx3Cache( cCampo ,"X3_TIPO") == "N")
                      TCSetField(cAlias,(cAlias)->(FieldName(f)),"N", 15 /*GetSx3Cache( cCampo ,"X3_TAMANHO")*/,GetSx3Cache( cCampo ,"X3_DECIMAL"))
              endCase
           endif
       Next f
          
   Next
   
   If (Select(cAlias) > 0)
      (cAlias)->(dbCloseArea())
   Endif  
   
Return .T.

**************************************
Static Function fMsgStop(cMsg,aParams)
**************************************
	Local cMessage := OemToAnsi(cMsg)
	Local nX       := 0

	Default aParams := {}
	Default lBack   := .F.
   
	For nX := 1 To Len(aParams)
		cMessage := StrTran(cMessage,"{"+cValToChar(nX)+"}",cValToChar(aParams[nX]))
	Next nX
   
	MsgStop(cMessage)
	
Return nil
