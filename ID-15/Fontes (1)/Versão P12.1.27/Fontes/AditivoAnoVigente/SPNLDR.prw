#include 'protheus.ch'
#include 'parmtype.ch'
#include "Fileio.ch" 
#Include "TopConn.ch"

user function SPNLDR(cTab)

    Local lRet := .F.

	Private cAliasTab  := UPPER(cTab)
    Private lAutoExec  := (Type("__lPackage") == "L" .And. __lPackage)

	Processa( {|| lRet := Exec(cTab) }, "Aguarde...", "Processando...",.F.)
Return lRet

**************************
Static Function Exec(cTab)
**************************

	Local lRet 		:= .T.
	Local cLote     := ""
	Local aResult 	:= {}
	Local cDataIni  := DTos(Date())
	Local cHoraIni  := Time()
	Local cSpName   := ""
	Local dDataMov  := ""
	Local cDataMov  := ""
	
	cLote    := GetLote(cAliasTab)
    If Empty(cLote)
	   MsgStop("Não há lote para o processamento! Verifique.")
	   return .F.
    Endif
    
    If Empty(AllTrim( cLote := FWInputBox("Número do Lote:", cLote) ))
       return .F.
    Endif
    
    cLote := PadL(GetDtoVal(AllTrim(cLote)),15,'0')

    If ! ExistLote(cAliasTab,cLote)
	   MsgStop(U_fmtStr("O Lote <b>{1}</b> é inválido! Verifique.",{cLote}))
	   return .F.
    Endif
    
    If ! MsgYesNo(U_fmtStr("Confirma o processamento do Lote <b>{1}</b>?",{cLote}),"Confirmação")
	   MsgStop("Processamento cancelado pelo usuário.")
       return .F.
    Endif
    
    If LoteInResum(cAliasTab,cLote)
	   MsgStop(U_fmtStr("O Lote <b>{1}</b> está <b>marcado</b> como processado! Verifique.",{cLote}))
	   return .F.
    Endif
    
	cSpName := "MIG_P12_" + cAliasTab
	If TCSPExist(cSpName)

	    //--Preparativos para a execução do processo.
	    Prepare(cLote)
	    //
	    
	    /*
	    ** Inicia o monitoramento do R_E_C_N_O_...
	    */
	    StartJob("U_STARTMNT",GetEnvServer(),.F.,cAliasTab,cLote)
	    /*
	    **
	    */
	    If ( cAliasTab == "SD3" )
	       dDataMov  := SuperGetMV("MV_ULMES",.F.,"19000101")
	       If ! Empty(dDataMov)
	          cDataMov := DTOS(dDataMov + 1)
	       Else 
	          cDataMov := "19000101"
	       Endif
		   aResult := TCSpExec(cSpName, cLote, cDataIni, cHoraIni, (cDataMov+RIGHT(GETSXENUM("SD3","D3_SEQCALC") ,6)) )
	    Else 
		   aResult := TCSpExec(cSpName, cLote, cDataIni, cHoraIni)
		Endif
		lRet := Empty(AllTrim(TcSqlError()))
		IF !lRet
	       MsgStop('Erro na execução da Stored Procedure : '+chr(13)+TcSqlError())
	    Endif
	Else
		IncProc("Não encontrou a procedure MIG_P12_" + cAliasTab )
		lRet := .F.
	EndIf	
    /*
    ** FINALIZA o monitoramento do R_E_C_N_O_...
    */
	U_FinalMnt(cAliasTab,cLote)
	
return lRet


*******************************
Static Function GetLote(cAlias)
*******************************
   Local cRet      := ""
   Local cQuery    :=  "SELECT MAX(NUMEROLOTE) LOTE FROM ARQ{1} "
   Local cAliasTmp := GetNextAlias()
   
   cQuery := StrTran(cQuery,"{1}",cAlias)
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      cRet := (cAliasTmp)->LOTE
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   If Empty(cRet)
      cRet := '000000000000001'
   Endif
   
return cRet


*****************************************
Static Function LoteInResum(cAlias,cLote)
*****************************************
   Local lRet      := .F.
   Local cQuery    := "SELECT CASE WHEN EXISTS(SELECT 1 FROM ARQ{1}_RESUMO T WHERE T.NUMEROLOTE='{2}') THEN '1' ELSE '0' END OK FROM DUAL "
   Local cAliasTmp := GetNextAlias()
   
   cQuery := U_FmtStr(cQuery,{cAlias,cLote})
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      lRet := ( (cAliasTmp)->OK == '1' )
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return lRet


***************************************
Static Function ExistLote(cAlias,cLote)
***************************************
   Local lRet      := .F.
   Local cQuery    := "SELECT CASE WHEN EXISTS(SELECT 1 FROM ARQ{1} T WHERE T.NUMEROLOTE='{2}') THEN '1' ELSE '0' END OK FROM DUAL "
   Local cAliasTmp := GetNextAlias()
   
   cQuery := U_FmtStr(cQuery,{cAlias,cLote})
   
   TCQUERY cQuery NEW ALIAS (cAliasTmp)
   
   If (cAliasTmp)->(!Eof())
      lRet := ( (cAliasTmp)->OK == '1' )
   Endif
   
   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
return lRet


******************************
Static Function Prepare(cLote)
******************************
   Local lRet      := .T.
   Local aCommands := {}
   
   Aadd(aCommands,U_FmtStr("DELETE FROM ARQ{1}_LOG WHERE NUMEROLOTE = '{2}'",{cAliasTab,cLote}))
   Aadd(aCommands,U_FmtStr("DELETE FROM ARQ{1}_RESUMO WHERE NUMEROLOTE = '{2}'",{cAliasTab,cLote}))
   
   For nX := 1 To Len(aCommands)
       If (TCSQLExec(aCommands[nX]) < 0)
          MsgStop("Erro ao executar o comando: " +CRLF + aCommands[nX] + CRLF + CRLF + TCSQLError())
          lRet := .F.
          Exit
       Endif
   Next nX
   
Return lRet   
