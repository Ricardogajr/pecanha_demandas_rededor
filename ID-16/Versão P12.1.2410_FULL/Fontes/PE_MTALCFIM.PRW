#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} MTALCFIM
Controla a gravação de alçadas nos processos de compras.
@author 	Paulo Krüger
@since 		18/09/2017
@version 	P12.7
@Project    MAN0000007423046
@Return 	Nil
/*/

User Function MTALCFIM()
	Local aArea    := GetArea()
	Local aDocto   := PARAMIXB[1]
	Local dDataRef := PARAMIXB[2]
	Local nOper    := PARAMIXB[3]
	Local cDocSF1  := PARAMIXB[4]
	Local lResiduo := PARAMIXB[5]
	Local lRet
	Local cChave := SCR->(CR_FILIAL+CR_TIPO+CR_NUM)
	Local cNum := ""
	Local cFil := ""
	Local nRec := ""
	Local lAprovSC := .T.
	Local cTipo := ""
	Local nRecT := 0

/* PARAMIXB[3] = Número da Operação, que pode ser:   
	1 = Inclusão de Documento
	2 = Transferência da Alçada para o Superior
	3 = Exclusão do Documento
	4 = Aprovação do Documento
	5 = Estorno da Aprovação
6 = Bloqueio Manual
*/

	cNum := ADOCTO[1]
	cTipo := aDocto[2]
	cFil := cFilAnt
	cChave := cFilAnt+aDocto[2]+aDocto[1]

	SCR->(DbSeek(cFil + ADOCTO[2] + ADOCTO[1]))
	nRec := SCR->(RECNO())
	If SCR->CR_TIPO == "SC"
		cTipo := "SC"
//Tratativa temporária para alterar o CONAPRO (devido ao erro na rotina padrão.)
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		lAprovSC := fLastNvl(nRec)
		If lAprovSC
			SC1->(DbSetOrder(1))
			SC1->(MsSeek(cFil + AllTrim(cNum)))
			While SC1->(!Eof() .and. C1_FILIAL + C1_NUM == cFil + AllTrim(cNum))
				If SC1->C1_APROV <> 'L'
					RecLock("SC1",.F.)
					SC1->C1_APROV := "L"
					SC1->(MsUnlock())
				Endif
				SC1->(DbSkip())
			End
		EndIf
	EndIf

	SCR->(DbGoto(nRec))
	SC1->(DbSetOrder(1))
	SC1->(MsSeek(cFil + AllTrim(cNum)))


	If IsInCallStack('U_F1200709')
		lRet := U_F1200717(.F.) //Verifica se a medição de contrato vem de rotina customizada
	Else
		If FindFunction("U_F1207504")
			lRet := U_F1207504("D",aDocto,nOper) //Rotina para gravar o código do aprovador anterior.
		Endif
	Endif

// ID 1529 - 13/02/2019 - Marcos Furtado - Incluir ajustes de campos customizados para operação de transferência da alçada.
	If nOper == 2  //Transferência da Alçada para o Superior
		DbSelectArea("SCR")
		DbSetOrder(1)
		SCR->(DbSeek(cChave))
		While !(SCR->(EOF())) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cChave
			If (SCR->CR_APROV == adocto[4] .And. Empty(SCR->CR_XNOME))
				nRecT := SCR->(RECNO())
				RecLock("SCR",.F.)
				SCR->CR_XNOME := USRFULNAME(SCR->CR_USER)
				SCR->(MsUnLock())
			EndIf
			DbSkip()
		EndDo
		If nRecT > 0
			SCR->(DbGoto(nRecT))
		Else
			SCR->(DbSeek(cChave))
		EndIf
		U_F1201004(SCR->CR_FILIAL,ALLTRIM(SCR->CR_NUM),SCR->CR_TIPO)
	EndIF

	If IsInCallStack("CN300RADIT")
		If ValType(_lAprovalCT) <> "C"
			If !_lAprovalCT
				DbSelectArea("SCR")
				DbSetOrder(1)
				SCR->(DbSeek(cChave))
				While !(SCR->(EOF())) .And. AllTrim(SCR->(CR_FILIAL+CR_TIPO+CR_NUM)) == AllTrim(cChave)
					RecLock("SCR",.F.)
					SCR->(DbDelete())
					SCR->(MsUnLock())
					DbSkip()
				EndDo

				DbSelectArea("CN9")
				DbSetOrder(1)

				cUpdate := "UPDATE "+ RetSqlName("CN9")+ " SET CN9_SITUAC = '10' WHERE D_E_L_E_T_ = ' '"
				cUpdate += " AND CN9_FILIAL = '"+cFil+"'"
				cUpdate += " AND CN9_NUMERO = '"+Padr(AllTrim(cNum),TamSx3("CN9_NUMERO")[1])+"'"
				cUpdate += " AND CN9_SITUAC = '05' "


				If TcSQLExec( cUpdate ) != 0
					Conout("Erro ao tentar atualizar a tabela CN9" + CRLF + TcSQLError())
				Else
					CN9->(dbCommit())
				EndIf

				If CN9->(MsSeek(xFilial("CN9")+AllTrim(cNum)))
					RecLock("CN9",.F.)
					CN9->CN9_SITUAC := "05"
					CN9->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

Static function USRFULNAME(cvar)
return USRFULlNAME(cvar)


/*/{Protheus.doc} fLastNvl
Função para verificar se é o ultimo nível da aprovação de RV
@type function
@author Lucas Miranda de Aguiar
@since 24/07/2023
@version 1.0
@return 
/*/ 
Static Function fLastNvl(nRecno)

	Local aArea := GetArea()
	Local cNivel := ""
	Local lRet	:= .F.
	Local cAliasTmp := GetNextAlias()
	Local cFil := ""
	Local cTipo := ""
	Local cNum := ""

	Local cQuery := ""

	Default nRecno := 0

	DbSelectArea("SCR")
	DbGoto(nRecno)

	cQuery := " SELECT DISTINCT(CR_NIVEL) FROM "+ RETSQLNAME("SCR")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND CR_FILIAL = '"+SCR->CR_FILIAL+"'"
	cQuery += " AND CR_NUM = '"+SCR->CR_NUM+"'"
	cQuery += " AND CR_TIPO = '"+SCR->CR_TIPO+"'"
	cQuery += " AND CR_GRUPO = '"+SCR->CR_GRUPO+"'"
	cQuery += " ORDER BY CR_NIVEL DESC"

	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	TcQuery cQuery Alias ( cAliasTmp ) New

	If !( cAliasTmp )->( Eof() )
		cFil := SCR->CR_FILIAL
		cNum := AllTrim(SCR->CR_NUM)
		cTipo := SCR->CR_TIPO
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(cFil + cTipo + cNum))
			While SCR->(!(EoF())) .And. SCR->CR_FILIAL == cFil .And. SCR->CR_TIPO == cTipo .And. AllTrim(SCR->CR_NUM) == cNum
				If SCR->CR_NIVEL == ( cAliasTmp )->CR_NIVEL
					If SCR->CR_STATUS == "03"
						lRet := .T.
						Exit
					EndIf
				EndIf
				SCR->(DbSkip())
			End
		EndIf
	EndIf

	( cAliasTmp )->( DbCloseArea() )


	RestArea(aArea)
Return lRet
