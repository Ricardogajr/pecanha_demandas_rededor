#Include "Protheus.ch"
#INCLUDE "TopConn.ch"


User Function RDDM001()

	Local aArea := GetArea()
	Private cTabela := Space(3)
	Private cFilTab := "        "
	Private cMiglt := Space(30)
	Private lHasButton := .T.

	SetPrvt("oDlg1","oSay1","oSay2","oSay3","oBtn1","oBtn2","oGet1","oGet2","oGet3")
	oDlg1      := MSDialog():New( 308,-1030,516,-777,"Deleção em massa",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 012,000,{||" Tabela"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 028,000,{||" Filial"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 044,000,{||" XMIGLT"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oBtn1      := TButton():New( 072, 016, "Ok",oDlg1,{||RptStatus({|| fProcessa()}, "Aguarde...", "Processando...")}, 037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2      := TButton():New( 072, 068, "Fechar",oDlg1,{||oDlg1:End()}, 037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGet1      := TGet():New( 012, 028, { | u | If( PCount() == 0, cTabela, cTabela := u ) },oDlg1, ;
		060, 0008, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTabela",,,,lHasButton  )
	oGet2      := TGet():New( 028, 028, { | u | If( PCount() == 0, cFilTab, cFilTab := u ) },oDlg1, ;
		060, 0008, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cFilDe",,,,lHasButton  )
	oGet3      := TGet():New( 044, 028, { | u | If( PCount() == 0, cMiglt, cMiglt := u ) },oDlg1, ;
		060, 0008, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cFilPara",,,,lHasButton  )
	oDlg1:Activate(,,,.T.)

	RestArea(aArea)
Return


Static Function fProcessa()

	Local aArea := GetArea()
	Local cQuery := ""
	Local cUpdate := ""
	Local cAliasCount := GetNextAlias()
	Local cWhere := ""
	Local lContinua := .F.
	Local lRecdel := .F.
	Local lDelB2B9 := .F.


	lContinua := fValidAll()

	If !lContinua
		Return
	EndIf

	cQuery := " SELECT COUNT(*) AS COUNT FROM " + RetSqlName(cTabela)
	cWhere := " WHERE D_E_L_E_T_ = ' ' AND "
	If SUBSTR(cTabela, 1, 1) == "S"
		cWhere += SubStr(cTabela,2,2) + "_XMIGLT = '" +cMiglt+"'"
	Else
		cWhere += cTabela + "_XMIGLT = '" +cMiglt+"'"
	EndIf
	If SUBSTR(cTabela, 1, 1) == "S"
		If FWModeAccess(cTabela,1) == "E"
			cWhere += " AND " + SubStr(cTabela,2,2) + "_FILIAL = '" +cFilTab+"'"
		Else
			cWhere += " AND " + SubStr(cTabela,2,2) + "_FILIAL = '" +xFilial(cTabela)+"'"
		EndIf
	Else
		If FWModeAccess(cTabela,1) == "E"
			cWhere += " AND " + cTabela + "_FILIAL = '" +cFilTab+"'"
		Else
			cWhere += " AND " + cTabela + "_FILIAL = '" +xFilial(cTabela)+"'"
		EndIf
	EndIf

	cQuery += cWhere


	If Select( cAliasCount ) > 0
		( cAliasCount )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasCount ) New
	If ( cAliasCount )->COUNT > 0
		If MsgYesNo("A consulta " + cQuery + CRLF +  " retornou " + cValToChar(( cAliasCount )->COUNT) + " linhas, deseja prosseguir com a exclusão?")

			If cTabela == "SB9"
				If MsgYesNo("Deseja deletar os dados da tabela SB2 que estão vinculados a SB9?")
					lDelB2B9 := .T.
				EndIf
			EndIf
			lRecDEl := fRecDel()
			If lRecdel
				cUpdate := "UPDATE " + RetSqlName(cTabela) + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
			Else
				cUpdate := "UPDATE " + RetSqlName(cTabela) + " SET D_E_L_E_T_ = '*' "
			EndIf
			cUpdate += cWhere
			If TcSQLExec( cUpdate ) != 0
				Alert("Erro ao tentar atualizar a tabela " + cTabela + CRLF + TcSQLError())
			Else
				(cTabela)->(dbCommit())
				If lDelB2B9
					fDelB2(cUpdate)
				EndIf
				MsgInfo("Deleção realizada com sucesso!")
			EndIf
		EndIf
	Else
		MsgAlert("A consulta não retornou nenhuma informação, favor verificar os parâmetros de busca.")
	EndIf
	RestArea(aArea)
Return




Static Function fValidAll()

	Local lRet := .T.

	If Empty(cFilTab)
		MsgInfo("O preenchimento do campo de Filial é obrigatório..")
		lRet := .F.
		Return lRet
	ElseIf Empty(cMiglt)
		MsgInfo("O preenchimento do campo de Data de Carga é obrigatório..")
		lRet := .F.
		Return lRet
	ElseIf Empty(cTabela)
		MsgInfo("O preenchimento do campo de Tabela é obrigatório..")
		lRet := .F.
		Return lRet
	ElseIf !FWFilExist("01",cFilTab)
		MsgInfo("A filial informada não existe na empresa 01.")
		lRet := .F.
		Return lRet
	EndIf


Return lRet



Static Function fRecDel()

	Local aArea := GetArea()
	Local cQuery := ""
	Local lRet := .T.


	cQuery := " SELECT R_E_C_D_E_L_ FROM " + RetSqlName(cTabela)

	If TcSQLExec( cQuery ) != 0
		lRet := .F.
	EndIf


	RestArea(aArea)
Return lRet

Static Function fDelB2(cUpdate)

	Local cUpd := ""

	Default cUpdate := ""

	cUpd := StrTran(cUpdate,"SB9","SB2")
	cUpd := StrTran(cUpd,"B9","B2")
	DbSelectArea("SB2")

	If TcSQLExec( cUpd ) != 0
		Alert("Erro ao tentar atualizar a tabela SB2" + CRLF + TcSQLError())
	Else
		SB2->(dbCommit())
	EndIf

Return
