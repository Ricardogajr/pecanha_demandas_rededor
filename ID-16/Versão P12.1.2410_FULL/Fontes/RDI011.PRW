#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TopConn.ch"

user function RDI011()
	Local lRet := Exec()
return lRet


	**********************
Static Function Exec()
	**********************
	Local lRet       := .F.
	Local aAreaQZ1   := QZ1->(GetArea())
	Local lPreVldEx  := .F.
	Local bPreVldEx  := {|| lPreVldEx := PreVldExec() }
	Local bExec      := {|| lRet := U_SelectImp() }
	Local bExecB2    := {|| fSobeB2()}

	Private lSobeB2 := .F.
	Private cTime := Time()

	MsgRun( "Validando os processos..." , "Aguarde..." , bPreVldEx )

	If ! lPreVldEx
		return .F.
	Endif

	MsgRun( "Executando o processo..." , "Aguarde..." , bExec )


	If lRet
		If lSobeB2
			MsgRun( "Subindo carga automática da SB2" , "Aguarde..." , bExecB2 )
		EndIf
		MsgInfo("Processo concluído!")
	Endif

	QZ1->(RestArea(aAreaQZ1))

Return lRet

	****************************
Static Function PreVldExec()
	****************************
	Local lRet      := .T.
	Local aFiles    := {}
	Local cMask     := ""
	Local cPath     := ""
	Local nRetSinc  := 0

	lRet := U_RDI002(QZ1->QZ1_CODIGO,.T.,.T.,@nRetSinc)

	If ! lRet .And. ! MsgYesNo('O cadastro do processo não está sincronizado com o dicionário!'+CRLF+CRLF+"Deseja continuar?","Atenção")
		//MsgStop("O cadastro do processo não está sincronizado com o dicionário! Verifique.")
		return lRet
	Endif

	If __nLocalLdr == 1
		cPath := AllTrim(GetMv("FS_RDI006")) + AllTrim(QZ1->QZ1_DESTIN) + "\"
	Else
		cPath := U_GetDir(101) + AllTrim(QZ1->QZ1_DESTIN) + "\"
	Endif

	cPath := Left(cPath,RAT("\",cPath))
	cMask := AllTrim(QZ1->QZ1_DESTIN)+'*.TXT'

	aFiles := Directory(cPath + cMask)

	lRet := ! Empty(aFiles)

	If ! lRet
		MsgStop("Não há arquivo na origem!"+CRLF+CRLF+cPath)
	Endif

	If lRet .And. AllTrim(QZ1->QZ1_DESTIN) == "SB9"

		cMsg := '<center><h2><font color="#ff0000">Atenção!</font></h2></center>' + CRLF
		cMsg += '<h3><font color="#ff0000">UTILIZAR ESSA FUNÇÃO SOMENTE ANTES DO GO LIVE, PORQUE TODOS OS DADOS DA SB2 SERÃO DELETADOS ANTES DA CARGA.</font></h3>' +CRLF
		cMsg += "<b>Deseja iniciar o processamento da tabela SB2 com base no arquivo da SB9?</b>" + CRLF

		If MsgYesNo(cMsg)
			lSobeB2 := .T.
		EndIf
	EndIf

return lRet


Static Function fSobeB2()

	Local aArea := GetArea()
	Local cQryZ3 := ""
	Local cAliasQZ3 := GetNextAlias()
	Local cXmigLt := ""
	Local cAliasSB9 := GetNextAlias()
	Local cQryB9 := ""
	Local cUpdate := ""
	Local cUpdB9 := ""


	cQryZ3 := " SELECT QZ3_XMIGLT FROM " + RetSQLName("QZ3")
	cQryZ3 += " WHERE D_E_L_E_T_ = ' ' AND QZ3_CODTAB = 'SB9' "
	cQryZ3 += " AND QZ3_DATAIN = '"+DtoS(dDatabase)+"' AND QZ3_HORAIN >= '" +cTime+ "' ORDER BY R_E_C_N_O_ DESC"

	If Select( cAliasQZ3 ) > 0
		( cAliasQZ3 )->( DbCloseArea() )
	EndIf

	TcQuery cQryZ3 Alias ( cAliasQZ3 ) New

	If ( cAliasQZ3 )->(!EOF())
		cXmigLt := ( cAliasQZ3 )->QZ3_XMIGLT
	EndIf

	( cAliasQZ3 )->( DbCloseArea() )

	If !Empty(cXmigLt)

		If MsgYesNo("Deseja converter a quantidade dos produtos da SB9/SB2 de acordo com a tabela P17?")
			DbSelectArea("SB9")

			cUpdB9 := " UPDATE " +RetSqlName("SB9")+ " B91 SET B9_QINI = (SELECT VALOR_CONVERTIDO FROM ( "
			cUpdB9 += " SELECT B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI,QTD_CONVERTIDA, TP_CONVERSAO, "
			cUpdB9 += " CASE WHEN TP_CONVERSAO = 'M' THEN B9_QINI*QTD_CONVERTIDA ELSE B9_QINI/QTD_CONVERTIDA END AS VALOR_CONVERTIDO,RECNO "
			cUpdB9 += " FROM (SELECT B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, P17_CONSUM AS QTD_CONVERTIDA, P17_FROP12 AS TP_CONVERSAO, B9.R_E_C_N_O_ AS RECNO FROM " +RetSqlName("SB9")+ " B9 "
			cUpdB9 += " INNER JOIN " +RetSqlName("P17")+ " P17 ON "
			cUpdB9 += " P17.D_E_L_E_T_ = ' ' "
			cUpdB9 += " AND P17.P17_COD = B9.B9_COD "
			cUpdB9 += " AND P17.P17_FTRATA = B9.B9_FILIAL "
			cUpdB9 += " WHERE B9.D_E_L_E_T_ = ' ' AND "
			cUpdB9 += " B9.R_E_C_N_O_ = B91.R_E_C_N_O_ "
			cUpdB9 += " GROUP BY B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, P17_CONSUM, P17_FROP12,B9.R_E_C_N_O_))) "
			cUpdB9 += " WHERE R_E_C_N_O_ IN (SELECT RECNO FROM ( "
			cUpdB9 += " SELECT B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI,QTD_CONVERTIDA, TP_CONVERSAO, "
			cUpdB9 += " CASE WHEN TP_CONVERSAO = 'M' THEN B9_QINI*QTD_CONVERTIDA ELSE B9_QINI/QTD_CONVERTIDA END AS VALOR_CONVERTIDO,RECNO "
			cUpdB9 += " FROM (SELECT B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, P17_CONSUM AS QTD_CONVERTIDA, P17_FROP12 AS TP_CONVERSAO, B9.R_E_C_N_O_ AS RECNO FROM " +RetSqlName("SB9")+ " B9 "
			cUpdB9 += " INNER JOIN " +RetSqlName("P17")+ " P17 ON "
			cUpdB9 += " P17.D_E_L_E_T_ = ' ' "
			cUpdB9 += " AND P17.P17_COD = B9.B9_COD "
			cUpdB9 += " AND P17.P17_FTRATA = B9.B9_FILIAL "
			cUpdB9 += " WHERE B9.D_E_L_E_T_ = ' ' "
			cUpdB9 += " AND B9_XMIGLT = '" + cXmigLt + "' "
			cUpdB9 += " GROUP BY B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, P17_CONSUM, P17_FROP12,B9.R_E_C_N_O_))) "

			If TcSQLExec( cUpdB9 ) != 0
				Alert("Erro ao mudar a quantidade da SB9 " + CRLF + TcSQLError())
				Return
			Else
				SB9->(dbCommit())
				//Fim deleção
			EndIf
		EndIf

		cQryB9 += " SELECT * FROM " + RetSqlName("SB9")
		cQryB9 += " WHERE D_E_L_E_T_ = ' ' "
		cQryB9 += " AND B9_XMIGLT = '"+AllTrim(cXmigLt)+"'"

		If Select( cAliasSB9 ) > 0
			( cAliasSB9 )->( DbCloseArea() )
		EndIf

		TcQuery cQryB9 Alias ( cAliasSB9 ) New

		If ( cAliasSB9 )->(!EOF())
			DbSelectArea("SB2")
			DbSelectArea("NNR")
			NNR->(DbSetOrder(1))
			//Deleta SB2 da filial para subir os dados sem interferência
			cUpdate += " UPDATE " + RetSqlName("SB2") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_, B2_XMIGLT = 'DELETE " + Right(cXmiglt,11) + "' WHERE "
			cUpdate += " B2_FILIAL = '"+( cAliasSB9 )->B9_FILIAL+"'"
			If TcSQLExec( cUpdate ) != 0
				Alert("Erro ao tentar deletar as linhas na tabela SB2 " + CRLF + TcSQLError())
				Return
			Else
				SB2->(dbCommit())
				//Fim deleção
			EndIf
			(cAliasSB9 )->(DbGoTop())
			While  (cAliasSB9 )->(!EOF())
				Reclock("SB2",.T.)
				SB2->B2_FILIAL := (cAliasSB9 )->B9_FILIAL
				SB2->B2_COD    := (cAliasSB9 )->B9_COD
				SB2->B2_QFIM   := (cAliasSB9 )->B9_QINI
				SB2->B2_LOCAL  := (cAliasSB9 )->B9_LOCAL
				SB2->B2_QATU   := (cAliasSB9 )->B9_QINI
				SB2->B2_VFIM1  := (cAliasSB9 )->B9_VINI2
				SB2->B2_VATU1  := (cAliasSB9 )->B9_VINI2
				SB2->B2_LOCALIZ:= AllTrim(Posicione("NNR",1,(cAliasSB9 )->B9_FILIAL+(cAliasSB9 )->B9_LOCAL,"NNR_DESCRI"))
				SB2->B2_XDATA  := LastDate(MonthSub(dDatabase,1))
				SB2->B2_XMIGLT := (cAliasSB9 )->B9_XMIGLT
				SB2->(MsUnLock())
				(cAliasSB9)->(DbSkip())
			Enddo
			( cAliasSB9 )->( DbCloseArea() )
		Else
			Alert("Não existem dados gravados na tabela SB9 com o ID de carga (XMIGLT) " + AllTrim(cXmigLt))
		EndIf
	EndIf


	RestArea(aArea)
Return
