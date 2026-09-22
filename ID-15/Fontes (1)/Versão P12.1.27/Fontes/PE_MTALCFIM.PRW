#INCLUDE 'PROTHEUS.CH'

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
	Local cNum := SCR->CR_NUM
	Local cFil := SCR->CR_FILIAL


/* PARAMIXB[3] = Número da Operação, que pode ser:   
	1 = Inclusão de Documento
	2 = Transferência da Alçada para o Superior
	3 = Exclusão do Documento
	4 = Aprovação do Documento
	5 = Estorno da Aprovação
6 = Bloqueio Manual
*/

	If IsInCallStack('U_F1200709')
		lRet := U_F1200717(.F.) //Verifica se a medição de contrato vem de rotina customizada
	Else
		If FindFunction("U_F1207504")
			lRet := U_F1207504("D",aDocto,nOper) //Rotina para gravar o código do aprovador anterior.
		Endif
	Endif

	// ID 1529 - 13/02/2019 - Marcos Furtado - Incluir ajustes de campos customizados para operação de transferência da alçada.
	If nOper == 2  //Transferência da Alçada para o Superior
		U_F1201004(SCR->CR_FILIAL,ALLTRIM(SCR->CR_NUM),SCR->CR_TIPO)
	EndIF

	If IsInCallStack("CN300RADIT")
		If !_lAprovalCT
			DbSelectArea("SCR")
			DbSetOrder(1)
			SCR->(DbSeek(cChave))
			While !(SCR->(EOF())) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cChave
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

	RestArea(aArea)

Return lRet
