#Include 'Protheus.ch'
#Include 'TopConn.Ch'

/*
+---------------------------------------------------------------------------------------------------------+
| Neste programa estão todas as User Functions que são chamadas em pontos de entrada do módulo Financeiro |
| Função     Ponto de Entrada                                                                             |   
| FSPE0001   FA750BRW                                                                                     |
| FSPE0006   FA580LIB                                                                                     |  
| FSPE0007   FA580LBA                                                                                     |    
| FSPE0010   F240TBOR                                                                                     | 
| FSPE0011   FA080CAN                                                                                     |
| FSPE0012   FA080PE                                                                                      | 
| FSPE0027   FA050ALT                                                                                     |  
+---------------------------------------------------------------------------------------------------------+*/



/*
{Protheus.doc}  FSPE0001()
Função chamada pelo ponto de entrada FA750BRW para adicionar o botão "Borderô Automático Multi-Pagto" 
no Funções do Contas a Pagar 
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/

User Function FSPE0001()

	Local aRet  := {}
	Local aArea := GetArea()

	Aadd(aRet, {"Borderô Multi-Pagto", "U_TEWBTYP1(.F.)", 0, 5})

	RestArea(aArea)
Return aRet


/*
{Protheus.doc}  FSPE0006()
Função chamada pelo ponto de entrada FA580LIB - Validação do título antes da liberação manual  
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/
User Function FSPE0006()

	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cQuery    := ""
	Local cRetCx    := ""

//cQuery := "SELECT E2_FILIAL, E2_NUM, E2_FORNECE, E2_LOJA 
	If SE2->E2_XAPRVSP == "2"
		MsgStop("Esse titulo possui uma SP de material pendente de aprovação, por favor, aprove a SP apra dar continuidade na aprovação do titulo.", "Liberação não permitida")
		lRet := .F.
	endif
	If !(SE2->E2_TIPO == "INS" .And. Empty(SE2->E2_FATURA)) .And. !(Alltrim(SE2->E2_TIPO) $ "TX|ISS")

		If SE2->E2_TIPO == "INS" .And. Alltrim(SE2->E2_FATURA) == "NOTFAT"

			cQuery := " SELECT E2_FILIAL, E2_NUM, E2_FORNECE, E2_LOJA, E2_FATURA FROM " + RetSqlName("SE2")
			cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_FATURA = '" + SE2->E2_NUM + "' AND "
			cQuery += " E2_FORNECE <> '" + SE2->E2_FORNECE + "' AND D_E_L_E_T_ <> '*'"

			If Select("TRBFAT") > 0
				DbSelectArea("TRBFAT")
				TRBFAT->(DbCloseArea())
			EndIf

			TCQUERY cQuery New Alias "TRBFAT"

			If !TRBFAT->(Eof())
				MsgStop("Esta fatura possui títulos de INSS com fornecedores difentes, favor verificar.", "Liberação não permitida")
			EndIf

			TRBFAT->(DbCloseArea())

		Else

			cQuery := " SELECT CASE WHEN E2_TIPO IN " + FormatIn(MV_CPNEG,"/") + " THEN SUM(E2_VALOR) WHEN E2_TIPO NOT IN " + FormatIn(MV_CPNEG,"/") + " THEN 0 END VLNDCF, "
			cQuery += " CASE WHEN E2_TIPO IN " + FormatIn(MVPAGANT,"/") + " THEN SUM(E2_VALOR) WHEN E2_TIPO NOT IN " + FormatIn(MVPAGANT,"/") + " THEN 0 END VLADPA "
			cQuery += " FROM " + RetSqlName("SE2") + " "
			cQuery += " WHERE  E2_FILIAL = '" + xFilial("SE2") + "' AND E2_FORNECE = '" + SE2->E2_FORNECE + "' AND "
			cQuery += " E2_LOJA = '" + SE2->E2_LOJA + "' AND E2_TIPO IN " + FormatIn(MVPAGANT+"/"+MV_CPNEG,"/") + " AND "
			cQuery += " E2_SALDO > 0 AND D_E_L_E_T_ <> '*' "
			cQuery += " GROUP BY E2_TIPO"

			If Select("TRBPAA") > 0
				DbSelectArea("TRBPAA")
				TRBPAA->(DbCloseArea())
			EndIf

			TCQUERY cQuery New Alias "TRBPAA"

			While !TRBPAA->(Eof())
				If TRBPAA->VLADPA > 0
					If MsgYesNo("O fornecedor possui adiantamento com saldo para compensação. Deseja prosseguir com a liberação do título?", "Aviso" )
						lRet := .T.
					Else
						lRet := .F.
					EndIf
				EndIf

				If TRBPAA->VLNDCF > 0
					If MsgYesNo("Este fornecedor possui nota de crédito em aberto. Deseja prosseguir com a liberação do título?", "Aviso" )
						lRet := .T.
					Else
						lRet := .F.
					EndIf
				EndIf

				TRBPAA->(DbSkip())

			End

			TRBPAA->(DbCloseArea())

		EndIf

		If Empty(SE2->E2_PORTADO) .And. lRet
			If MsgYesNo("Não foi definido portador para este título. Deseja prosseguir com a liberação?", "Aviso")
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf

		If Empty(SE2->E2_FORMPAG) .And. lRet
			If MsgYesNo("Não foi definido forma de pagamento para este título. Deseja prosseguir com a liberação?", "Aviso")
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf

		If !Empty(SE2->E2_XCAIXIN)

			cRetCx := U_RetSeqAnt(SE2->E2_XCAIXIN, SE2->E2_NUM)

			If Empty(Alltrim(cRetCx))
				MsgStop("Não será possível liberar este título de caixinha por haver inconsistencias no processo de criação do título. Favor excluir o título e pedir uma nova reposição", "Liberação não permitida")
				lRet := .F.
			EndIf
		EndIf


	EndIf

	RestArea(aArea)

Return lRet


/*
{Protheus.doc}  FSPE0007()
Função chamada pelo ponto de entrada FA580LBA - Validação do título antes da liberação automática   
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/
User Function FSPE0007()

	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cQuery    := ""

	If (cAliasSe2)->E2_OK == cMarca
		
		If (cAliasSe2)->E2_XAPRVSP == "2"
			MsgStop("Esse titulo possui uma SP de material pendente de aprovação, por favor, aprove a SP apra dar continuidade na aprovação do titulo.", "Liberação não permitida")
			lRet := .F.
		endif

		If !(Alltrim((cAliasSe2)->E2_TIPO) $ "TX|ISS|INS")

			cQuery := " SELECT CASE WHEN E2_TIPO IN " + FormatIn(MV_CPNEG,"/") + " THEN SUM(E2_VALOR) WHEN E2_TIPO NOT IN " + FormatIn(MV_CPNEG,"/") + " THEN 0 END VLNDCF, "
			cQuery += " CASE WHEN E2_TIPO IN " + FormatIn(MVPAGANT,"/") + " THEN SUM(E2_VALOR) WHEN E2_TIPO NOT IN " + FormatIn(MVPAGANT,"/") + " THEN 0 END VLADPA "
			cQuery += " FROM " + RetSqlName("SE2") + " "
			cQuery += " WHERE  E2_FILIAL = '" + xFilial("SE2") + "' AND E2_FORNECE = '" + SE2->E2_FORNECE + "' AND "
			cQuery += " E2_LOJA = '" + SE2->E2_LOJA + "' AND E2_TIPO IN " + FormatIn(MVPAGANT+"/"+MV_CPNEG,"/") + " AND "
			cQuery += " E2_SALDO > 0 AND D_E_L_E_T_ <> '*' "
			cQuery += " GROUP BY E2_TIPO"

			If Select("TRBPAA") > 0
				DbSelectArea("TRBPAA")
				TRBPAA->(DbCloseArea())
			EndIf

			TCQUERY cQuery New Alias "TRBPAA"

			While !TRBPAA->(Eof())
				If TRBPAA->VLADPA > 0
					If MsgYesNo("O fornecedor " + Alltrim((cAliasSe2)->E2_FORNECE) + " - " + Alltrim((cAliasSe2)->E2_NOMFOR) + " possui adiantamento com saldo para compensação. Deseja prosseguir com a liberação do título " + Alltrim((cAliasSe2)->E2_NUM) +"?", "Aviso" )
						lRet := .T.
					Else
						lRet := .F.
					EndIf
				EndIf

				If TRBPAA->VLNDCF > 0
					If MsgYesNo("O fornecedor " + Alltrim((cAliasSe2)->E2_FORNECE) + " - " + Alltrim((cAliasSe2)->E2_NOMFOR) + " possui nota de crédito em aberto. Deseja prosseguir com a liberação do título " + Alltrim((cAliasSe2)->E2_NUM) +"?", "Aviso" )
						lRet := .T.
					Else
						lRet := .F.
					EndIf
				EndIf

				TRBPAA->(DbSkip())

			End

			If Empty((cAliasSe2)->E2_PORTADO) .And. lRet
				If MsgYesNo("Não foi definido portador para o título: " + Alltrim((cAliasSe2)->E2_NUM) + ". Deseja prosseguir com a liberação?", "Aviso")
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf

			If Empty((cAliasSe2)->E2_FORMPAG) .And. lRet
				If MsgYesNo("Não foi definido forma de pagamento para o título: " + Alltrim((cAliasSe2)->E2_NUM) + ". Deseja prosseguir com a liberação?", "Aviso")
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf

			TRBPAA->(DbCloseArea())

		EndIf

	EndIf
	RestArea(aArea)

Return lRet


/*
{Protheus.doc}  FSPE0010()
Função chamada pelo ponto de entrada F240TBOR - Gravação complementar na tabela de Borderôs
@Author  Ramon Teodoro e Silva	
@Since   07/04/2017       
@Version P12.7
*/

User Function FSPE0010()

	Local lRet      := .T.
	Local lSchedule := IsBlind()

	RecLock("SEA",.F. )
	If lSchedule
		SEA->EA_XBALOG := "Job " + DtoC(Date()) + " " + Time()
	Else
		SEA->EA_XBALOG := "Man " + DtoC(Date()) + " " + Time() + " " + UsrFullName(RetCodUsr())
	EndIf
	If Empty(Alltrim(SEA->EA_ORIGEM))
		SEA->EA_ORIGEM := IIF(Alltrim(FunName()) == "TEWBTYP1", "FINA241", FunName())
	EndIf
	MsUnlock()

Return lRet


/*
{Protheus.doc}  FSPE0011()
Função chamada pelo ponto de entrada FA080CAN - Gravação complementar na exclusão\cancelamento da baixa
@Author  Ramon Teodoro e Silva	
@Since   07/04/2017       
@Version P12.7
*/

User Function FSPE0011()
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aUltMov  := {}
	Local cSeqAnt  := ""

	If !Empty(SE2->E2_XCAIXIN) //.And. Alltrim(SE2->E2_ORIGEM) == "FINA550"

		DbSelectArea("SET")
		DbSetOrder(1)
		DbGoTop()

		PcoIniLan("000359")

		If DbSeek(xFilial("SET")+SE2->E2_XCAIXIN)

			cSeqAnt := U_RetSeqAnt(SE2->E2_XCAIXIN, SE2->E2_NUM) //busca o número sequencial dos movimentos refentes ao título de reposição

			aUltMov := U_RetUltMov(SE2->E2_XCAIXIN, cSeqAnt) //busca os movimenetos referentes ao título de reposição

			U_GrInfMov(aUltMov,"", .T.) //cancela as baixas dos movimentos

			nSaldoAn := SET->ET_SALDO - SE2->E2_VALOR

			RecLock("SET",.F.)
			SET->ET_SALANT := SET->ET_SALDO
			SET->ET_SALDO  := nSaldoAn  //IIF( nSaldoAn-SE2->E2_SALDO < 0, 0, nSaldoAn-SE2->E2_SALDO )
			MsUnlock()
			PcoDetLan("000359","01","FINA550",.T.)

		EndIf

		Fa550Mov( SE2->E2_XCAIXIN, "11", SE2->E2_VALOR,"Devolução ao banco "+SET->ET_BANCO )
		AtuSalCxa( SE2->E2_XCAIXIN, dDataBase, (0-SE2->E2_VALOR), .F.)

		PcoFinLan("000359")

	EndIf

	RestArea(aArea)
Return lRet


/*
{Protheus.doc}  FSPE0012()
Função chamada pelo ponto de entrada FA080PE - Faz a reposição do caixinha para títulos gerados pela rotina de reposição, após a baixa do mesmo 
@Author  Ramon Teodoro e Silva	
@Since   07/04/2017       
@Version P12.7
*/

User Function FSPE0012()

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local nSaldoAn   := 0
	Local nValRep    := SE2->E2_VALOR
	Local cCaixa     := SE2->E2_XCAIXIN
//Local cSeqCxa 	 := IIf( !Empty(Alltrim(cCaixa)), Fa570SeqAtu(cCaixa), "")
	Local cSeqCxAnt  := ""

	If !Empty(cCaixa) //.And. Alltrim(SE2->E2_ORIGEM) == "FINA550"

		DbSelectArea("SET")
		DbSetOrder(1)
		DbGoTop()

		PcoIniLan("000359")

		If DbSeek(xFilial("SET")+cCaixa)

			nSaldoAn := SET->ET_SALDO

			If ((SET->ET_SALDO+nValRep)>SET->ET_VALOR)
				MsgAlert("Valor de reposição maior que o permitido", "Erro no momento da reposição do caixinha") //"Valor maior que o permitido."
				lRet := .F.
			Else

				cSeqCxAnt := U_RetSeqAnt(cCaixa, SE2->E2_NUM)

				//Baixa das despesas
				DbSelectArea("SEU")
				SEU->(DbSetOrder(5))  // filial + caixa + sequencia + num
				SEU->(DbSeek( xFilial("SEU")+ cCaixa + cSeqCxAnt))
				While !SEU->(Eof()) .And. xFilial("SEU")+cCaixa+cSeqCxAnt == SEU->(EU_FILIAL+EU_CAIXA+EU_SEQCXA)

					If SEU->EU_TIPO == "00" .And. Empty(SEU->EU_BAIXA) .And. SEU->EU_XNUMTIT == SE2->E2_NUM
						RecLock("SEU", .F.)
						SEU->EU_BAIXA := dDataBase
						SEU->(MsUnLock())
					Endif

					SEU->(DbSkip())
				End

				//Reposição
				RecLock("SET",.F.)
				SET->ET_SALDO  := nSaldoAn+ nValRep
				SET->ET_ULTREP := dDataBase
				SET->ET_SALANT := nSaldoAn
				//If nSaldoAn > 0
				//	SET->ET_SEQCXA := SOMA1(SET->ET_SEQCXA)
				//EndIf
				MsUnlock()
				PcoDetLan("000359","01","FINA550")

				Fa550Mov( SET->ET_CODIGO, "10", nValRep,"Reposição de Banco"+SET->ET_BANCO)
				AtuSalCxa( SET->ET_CODIGO, dDataBase, nValRep, .F. )

			EndIf

		EndIf

		PcoFinLan("000359")

	EndIf

	RestArea(aArea)

Return lRet


/*
{Protheus.doc}  RetSeqAnt()
Função feita para retornar a sequencia dos movimentos de caixinha referentes ao título de reposição que está sendo baixado. 
@Author  Ramon Teodoro e Silva	
@Since   14/05/2017       
@Version P12.7
*/

User Function RetSeqAnt(cCaixa, cNumTit)

	Local cRet   := ""
	Local aArea  := GetArea()
	Local cQuery := ""
	Local lcount := .f.

	cQuery := " SELECT * FROM " + RetSqlName("SEU") + " "
	cQuery += " WHERE EU_FILIAL = '" + xFilial("SEU") + "' AND EU_CAIXA = '" + cCaixa + "' AND EU_XNUMTIT = '" + cNumTit + "' AND"
	cQuery += " D_E_L_E_T_ = ' '"

	If Select("TMPSEU") > 0
		DbSelectArea("TMPSEU")
		TMPSEU->(DbCloseArea())
	EndIf

//cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery New Alias "TMPSEU"

//DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPSEU", .F., .T.)

	lCount := TMPSEU->(Reccount())

	If !TMPSEU->(Eof())
		cRet := TMPSEU->EU_SEQCXA
		TMPSEU->(DbCloseArea())
	Else // ID 100 CHAMADO 9556886 - Erro ao liberar Tit Pagar na primeira reposição do caixinha - EDUARDO WILLIAMS 17/08/2020
		cQuery := " SELECT EU_NUM FROM " + RetSqlName("SEU") + " "
		cQuery += " WHERE EU_FILIAL = '" + xFilial("SEU") + "' AND EU_CAIXA = '" + cCaixa + "' AND"
		cQuery += " D_E_L_E_T_ = ' '"

		If Select("TMPSEU") > 0
			DbSelectArea("TMPSEU")
			TMPSEU->(DbCloseArea())
		EndIf

		TCQUERY cQuery New Alias "TMPSEU"

		If TMPSEU->(EOF())
			cRet := 'PRIMEIRO'
		EndIf

		TMPSEU->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return cRet

/*
{Protheus.doc}  FSPE0027()
Função chamada pelo ponto de entrada FA050ALT para validar a relação entre o campo cód. barras e forma de pagamento 
na alteração do título. 
@Author  Ramon Teodoro e Silva	
@Since   13/05/2019       
@Version P12.7
*/

User Function FSPE0027()

	Local lRet  := .T.
	Local aArea := GetArea()

	If !Empty(M->E2_CODBAR)

		If !(VldCodBar(M->E2_CODBAR))

			lRet := .F.

		Else

			If M->E2_FORMPAG $ "01|02|03|04|05|10|40|41|43"

				MsgStop("Use o código adequado para pagamentos com código de barras.",  "Forma de pagamento incorreta!")
				lRet := .F.

			EndIf

		EndIf

	EndIf

	RestArea(aArea)
Return lRet

