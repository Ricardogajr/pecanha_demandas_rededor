#Include 'TOTVS.ch'

#Define ALTERA_PREV 2

/*/{Protheus.doc} User Function F050ALT
    Após confirmar a alteração do registro
    @type  Function
    @author Gianluca Moreira
    @since 19/05/2021
    @version version
    @param nOpcA, Numeric, Opção da janela. 1-Confirmar 2-Cancelar
    @return return_var, Nil
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6070876
    /*/
User Function F050ALT()

	Local aAreaFKD  := {}
	Local cQryFKD   := "" //ticket n° 10326179
	Local cTmp      := "" //ticket n° 10326179
	Local cChFK7    := "" //ticket n° 10326179
	Local nOpcA := ParamIXB[1]
	Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

	//Verifica se está habilitada a integração neste grupo de empresas
	If lGrpHblt
		If nOpcA == 1
			//Grava registro previsto na PX0 - envio ao XRT
			U_F2000100('SE2', ALTERA_PREV)
		EndIf
	EndIf

	//ticket n° 10326179 -- tratamento para gravação em Valores Acessórios (lanç. manual)
	aAreaFKD  := FKD->(GetArea())
	cChFK7    := SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA

	cQryFKD  := " SELECT FK7_FILIAL, FK7_IDDOC, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_XTXEXPE  "
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
		If FKD->(!DbSeek(xFilial('FKD')+'000001'+(cTmp)->(FK7_IDDOC)))
			Reclock("FKD",.T.)
			FKD->FKD_FILIAL := (cTmp)->(FK7_FILIAL)
			FKD->FKD_CODIGO := "000001"
			FKD->FKD_IDDOC  := (cTmp)->(FK7_IDDOC)
			FKD->FKD_VALOR  := SE2->E2_XTXEXPE
			FKD->(MsUnLock())
		Else
			Reclock("FKD",.F.)
			FKD->FKD_VALOR  := SE2->E2_XTXEXPE
			FKD->(MsUnLock())
		EndIf

	EndIf
	RestArea(aAreaFKD)
// Fim -- ticket n° 10326179

Return
