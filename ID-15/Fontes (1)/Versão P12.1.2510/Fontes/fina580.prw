#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TBICONN.CH'

// ------------------------------------------------------------------
// {Protheus.doc} FINA580()
// Assunto     Ponto de Entrada após liberação de título
// @Author     Paulo Dias
// @Since      17/02/2020
// @Version    P12.1.17
// @ticket     DOR07141920
// ------------------------------------------------------------------

User Function FINA580()
	Local aArea := GetArea()
	Local aAreaFKD := {}
	Local aAreaFK7 := FK7->(GetArea())
	Local cTime := Time()
	Local cQryFKD   := "" //ticket n° 10326179
	Local cTmp      := "" //ticket n° 10326179
	Local cChFK7    := "" //ticket n° 10326179
	Local cFilE2    := "" //Correção erro dbseek FKD - Lucas Miranda
	Local lContinua := .T.
	Local lFilSimp := U_VALSIMP(SE2->E2_FILIAL)
	
	DbSelectArea("SE2")
	Reclock("SE2",.F.)
	SE2->E2_XHORLIB := cTime
	MsUnlock()

	if !lFilSimp
	//ticket n° 10326179 -- tratamento para gravação em Valores Acessórios (Liberação automática)
		aAreaFKD  := FKD->(GetArea())
		cChFK7 := SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
		cFilE2 := SE2->E2_FILIAL//Correção erro dbseek FKD - Lucas Miranda

		//Bloco de correção quando estoura erro na query da FK7
		DbSelectArea("FK7")
		FK7->(DbSetOrder(2))

		If !FK7->(DbSeek(Space(TamSX3("FK7_FILIAL")[1])+"SE2"+cChFK7))
			If !FK7->(DbSeek(cFilE2+"SE2"+cChFK7))
				lContinua := .F.
			EndIf
		EndIf

		If lContinua
			DbSelectArea("FKD")
			FKD->(DbSetOrder(1))
			If FKD->(!DbSeek(cFilE2+'000001'+FK7->FK7_IDDOC))//Correção erro dbseek FKD - Lucas Miranda
				Reclock("FKD",.T.)
				FKD->FKD_FILIAL := FK7->FK7_FILIAL
				FKD->FKD_CODIGO := "000001"
				FKD->FKD_IDDOC  := FK7->FK7_IDDOC
				FKD->FKD_VALOR  := SE2->E2_XTXEXPE
				FKD->(MsUnLock())
			Elseif SE2->E2_XTXEXPE <> FKD->FKD_VALOR
				Reclock("FKD",.F.)
				FKD->FKD_VALOR  := SE2->E2_XTXEXPE
				FKD->(MsUnLock())
			EndIf
		EndIf
	//FIM

	/*/cQryFKD  := " SELECT FK7_FILIAL, FK7_IDDOC, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_XTXEXPE  "
		cQryFKD  += " FROM "+ RetSqlName("FK7") + " FK7 ," + RetSqlName("SE2") + " SE2 "
		cQryFKD  += " WHERE FK7.D_E_L_E_T_ = ' ' "
		cQryFKD  += " AND FK7_CHAVE = '" + cChFK7 + "'"
		cQryFKD  += " AND SE2.D_E_L_E_T_ = ' ' "
		cQryFKD  += " AND E2_NUM = '" + SUBSTR(cChFK7,14,9) + "'"

		cQryFKD := ChangeQuery(cQryFKD)
		cTmp    := GetNextAlias()
		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQryFKD ), cTmp, .F., .T. )

		If (cTmp)->(!Eof())
			DbSelectArea("FKD")
			FKD->(DbSetOrder(1))
			If FKD->(!DbSeek(cFilE2+'000001'+(cTmp)->(FK7_IDDOC)))//Correção erro dbseek FKD - Lucas Miranda
				Reclock("FKD",.T.)
				FKD->FKD_FILIAL := (cTmp)->(FK7_FILIAL)
				FKD->FKD_CODIGO := "000001"
				FKD->FKD_IDDOC  := (cTmp)->(FK7_IDDOC)
				FKD->FKD_VALOR  := SE2->E2_XTXEXPE
				FKD->(MsUnLock())
			Elseif SE2->E2_XTXEXPE <> FKD->FKD_VALOR
				Reclock("FKD",.F.)
				FKD->FKD_VALOR  := SE2->E2_XTXEXPE
				FKD->(MsUnLock())
			EndIf
	EndIf/*/
			aAreaFKD  := FKD->(GetArea())
	// Fim -- ticket n° 10326179
			RestArea(aAreaFK7)
			RestArea(aAreaFKD)
			RestArea(aArea)
	endif
Return
