#Include 'Protheus.ch'
#Include "TopConn.ch"


/*
{Protheus.doc} F1206601()
Replica para outras filiais
@Author  Fabrica de Software   
@Since   13/12/2018
@Project MAN0000007423048_EF_066
*/
User Function F1206601()
	
	Local bAcao   := {|lFim| }
	Local cTitulo := "Processando importação SBZ"
	Local cMsg    := "Processando.."
	Local lAborta := .T.

    Private lAbortPrint := .F.
	
	If MsgYesNo( 'Deseja fazer importação em massa da tabela SB1 -> SBZ? ', 'Importação em massa SBZ' )
		
		//oProcess := MsNewProcess():New({||  processaSBZ(oProcess)}, "Processando...", "Aguarde...", .T.)
		//oProcess:Activate()
		Processa( {|| Exec() }, "Aguarde...", "Gerando SBZ...",.T.)
		
	Endif
		
Return

**********************
Static Function Exec()
**********************
   Local cAliasTmp := GetNextAlias()
   Local cQuery    := ""
   Local nRecTot   := 0
   Local nRec      := 0
   Local aAreaSBZ  := SBZ->(GetArea())

   cQuery += "WITH                                                                                                                                                                    " + CRLF
   cQuery += "CTE_FILIAIS (FILIAL) AS                                                                                                                                                 " + CRLF
   cQuery += "       (                                                                                                                                                                " + CRLF
   cQuery += "        SELECT P31_CODFIL FILIAL FROM " + RetSqlName("P31") + " WHERE D_E_L_E_T_ = ' '                                                                                  " + CRLF
   cQuery += "        UNION                                                                                                                                                           " + CRLF
   cQuery += "        SELECT P30_CODFIL FILIAL FROM " + RetSqlName("P30") + " WHERE D_E_L_E_T_ = ' '                                                                                  " + CRLF
   cQuery += "       ),                                                                                                                                                               " + CRLF
   cQuery += "CTE_PRODUTOS (FILIAL,CODIGO) AS                                                                                                                                         " + CRLF
   cQuery += "       (                                                                                                                                                                " + CRLF
   cQuery += "             SELECT X.FILIAL, SB1.B1_COD                                                                                                                                " + CRLF
   cQuery += "             FROM " + RetSqlName("SB1") + " SB1, CTE_FILIAIS X                                                                                                          " + CRLF
   cQuery += "             WHERE SB1.R_E_C_D_E_L_ = 0                                                                                                                                 " + CRLF
   cQuery += "             AND SB1.D_E_L_E_T_= ' '                                                                                                                                    " + CRLF
   cQuery += "             AND SB1.B1_XBLQPER <> '1'                                                                                                                                  " + CRLF
   cQuery += "       ),                                                                                                                                                               " + CRLF
   cQuery += "CTE_MINUS (FILIAL,PRODUTO) AS                                                                                                                                           " + CRLF
   cQuery += "      (                                                                                                                                                                 " + CRLF
   cQuery += "             SELECT P.FILIAL, P.CODIGO PRODUTO                                                                                                                          " + CRLF
   cQuery += "             FROM CTE_PRODUTOS P                                                                                                                                        " + CRLF
   cQuery += "             MINUS                                                                                                                                                      " + CRLF
   cQuery += "             SELECT SBZ.BZ_FILIAL, SBZ.BZ_COD                                                                                                                           " + CRLF
   cQuery += "             FROM " + RetSqlName("SBZ") + " SBZ                                                                                                                         " + CRLF
   cQuery += "             INNER JOIN CTE_FILIAIS X ON X.FILIAL = SBZ.BZ_FILIAL                                                                                                       " + CRLF
   cQuery += "             WHERE SBZ.D_E_L_E_T_=' '                                                                                                                                   " + CRLF
   cQuery += "      ),                                                                                                                                                                " + CRLF
   cQuery += "CTE_QUANT (QTD_REC) AS                                                                                                                                                  " + CRLF
   cQuery += "      (                                                                                                                                                                 " + CRLF
   cQuery += "          SELECT COUNT(1) QTD                                                                                                                                           " + CRLF
   cQuery += "          FROM CTE_MINUS                                                                                                                                                " + CRLF
   cQuery += "      )                                                                                                                                                                 " + CRLF
   cQuery += "SELECT T.FILIAL, T.PRODUTO, Q.QTD_REC,                                                                                                                                  " + CRLF
   cQuery += "COALESCE(( SELECT NNR.NNR_CODIGO FROM " + RetSqlName("NNR") + " NNR WHERE NNR.NNR_FILIAL = T.FILIAL AND NNR.NNR_XLOCPA = '1' AND NNR.D_E_L_E_T_ = ' ' ),' ') NNR_CODIGO " + CRLF
   cQuery += "FROM CTE_MINUS T, CTE_QUANT Q                                                                                                                                           " 

   TCQUERY cQuery NEW ALIAS (cAliasTmp)

   If (cAliasTmp)->(Eof())
      If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
      MsgInfo("Não há registros para serem processados.")
      Return
   Endif

   EnableTrig(RetSqlName('SBZ'),.F.)

   DbSelectArea("SBZ")
   SBZ->(DbSetOrder(1))
   DbGotop()
   
   nRecTot := (cAliasTmp)->QTD_REC
   ProcRegua(nRecTot)

   While (cAliasTmp)->(!Eof())
      
      If lAbortPrint
         MsgStop("Rotina cancelada pelo usuário!")
         Exit
      Endif

      nRec++
      IncProc("Processando "+cVAlToChar(nRec)+" de " + cVAlToChar(nRecTot))
      ProcessMessages()
      
      if !empty((cAliasTmp)->NNR_CODIGO)
         RecLock("SBZ",.T.)
            SBZ->BZ_FILIAL  := (cAliasTmp)->FILIAL
            SBZ->BZ_COD     := (cAliasTmp)->PRODUTO
            SBZ->BZ_LOCPAD  := (cAliasTmp)->NNR_CODIGO
            SBZ->BZ_QE      := 0
         SBZ->(MsUnLock())
      endif

      (cAliasTmp)->(dbSkip(1))
   EndDo

   If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
   
   SBZ->(RestArea(aAreaSBZ))

   EnableTrig(RetSqlName('SBZ'),.T.)
   
   MsgInfo(Transform(nRec,"@E 999,999,999") + " registros inseridos.")

return 

/*/{Protheus.doc} processaSBZ
Processar a carga da tabela SB1->SBZ.

@type  	Static Function
@author William Ferreira Souza
@since 	05/06/2019
/*/
Static Function processaSBZ(oObj)
    
	Local aAreaSB1  := {}
	Local aAreaP17  := {}
	Local aAreaP30  := {}
	Local aAreaSBZ	:= {}
	Local aAreaP31	:= {}
	Local cText     := ""
	Local nAtual    := 0
	Local nAtual2   := 0
	Local nCtt := 1

    aAreaSB1 := SB1->(GetArea('SB1'))
    aAreaP17 := P17->(GetArea('P17'))
	aAreaP30 := P30->(GetArea('P30'))
	aAreaSBZ := SBZ->(GetArea('SBZ'))
	aAreaP31 := P31->(GetArea('P31'))

	DbSelectArea("P30")
	P30->(DbSetOrder(1))
	DbGotop()
	DbSelectArea("P31")
	P31->(DbSetOrder(1))
	DbGotop()
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	DbGotop()
	DbSelectArea("SBZ")
	SBZ->(DbSetOrder(1))
	DbGotop()

	oObj:SetRegua1(P31->(RecCount()))
		
	While P30->(!Eof()) //.AND. nCtt<50
		IF 	P30->P30_REPLIC == '1'
	
			If P31->(DbSeek(FwXFilial("P31") + P30->P30_COD))  
				While P31->P31_COD = P30->P30_COD 
				   nAtual++
				   oObj:IncRegua1("Processando Filial.: "+ P31->P31_CODFIL + " ("+cvaltochar(nAtual)+"/"+cvaltochar(P31->(RecCount()))+")")
					
//					Begin Transaction
					    
						oObj:SetRegua2(SB1->(RecCount()))
						
						While SB1->(!Eof())  
						    nAtual2++
						    oObj:IncRegua2("Produto.: "+ alltrim(SB1->B1_COD) + " ("+cvaltochar(nAtual2)+"/"+cvaltochar(SB1->(RecCount()))+")")
							If !SBZ->(DbSeek(P31->P31_CODFIL+SB1->B1_COD))
									if (U_F1206501(P31->P31_CODFIL,SB1->B1_COD,"I"))
										//nCtt++
										cText += "O produto "+alltrim(SB1->B1_COD)+" da filial "+alltrim(P31->P31_CODFIL)+" importado com sucesso para a tabela SBZ"  + Chr(13) + Chr(10)
									EndIf
								Endif
							SB1->(DbSkip())		
						End
	
//					End Transaction
					P31->(DbSkip())
				End
			EndIf
		EndIf
		P30->(DbSkip())
	End

	If !empty(ctext)
		zMsgLog(ctext,"Log de importação em massa SBZ")
	else
		Help('',1,'Help',"Log de importação em massa SBZ","Não há filiais/produtos disponíveis para importação em massa da SB1->SBZ",1,0)
	EndIf	
	RestArea(aAreaP30)
	RestArea(aAreaSB1)
    RestArea(aAreaP17)
	RestArea(aAreaSBZ)
	RestArea(aAreaP31)
Return


/*/
{Protheus.doc} zMsgLog()
Exibe janela de log de importação em massa
@Author  Fabrica de Software
@Since   13/12/2018
@Project MAN0000007423048_EF_066
/*/
STATIC Function zMsgLog(cMsg, cTitulo)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-012,,.F.,,,,,.F.,.F.)
	Local oMsg
	Local nIni:=1
	Local nFim:=50    

	//Criando a janela centralizada com os botões
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL
	//Get com o Log
	@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 346, 130 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL  
	@ 135, 297 BUTTON oBtnOk  PROMPT '&Fechar'  SIZE 051, 010 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
	oMsg:lReadOnly := .T.
		
	ACTIVATE MSDIALOG oDlgMens CENTERED
	
Return lRetMens

**********************************************
Static Function EnableTrig(cTableName,lEnable)
**********************************************
   Local cAlias := GetNextAlias()
   Local cQuery := ""
   Local cEnable:= If(lEnable,"enable","disable")
   
   cQuery += "select 'alter trigger '||t.table_owner||'.'||t.trigger_name||' {1}' SCRIPT     " + CRLF
   cQuery += "from USER_TRIGGERS t                                                            " + CRLF
   cQuery += "where t.base_object_type = 'TABLE'                                              " + CRLF
   cQuery += "AND t.table_name = '{2}'                                                        " + CRLF
   cQuery += "ORDER BY t.table_name                                                           "
   
   cQuery := FmtStr(cQuery,{cEnable,cTableName})

   TCQUERY cQuery NEW ALIAS (cAlias)
   
   While (cAlias)->(!Eof())
       cScript := AllTrim( (cAlias)->SCRIPT )
       If (TCSQLExec(cScript) < 0) 
          Aviso('Erro ao executar o script!',TCSQLError(),{"Fechar"},3)
       Endif
       (cAlias)->(DbSkip(1))
   Enddo
   
   If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif

return    

**********************************
Static Function FmtStr(cStr,aArgs)
**********************************
   Local nX   := 0
   Local cRet := cStr
   For nX := 1 To Len(aArgs)
       cRet := StrTran(cRet,"{"+cValToChar(nX)+"}",cValToChar(aArgs[nX]))
   Next nX
Return cRet   
