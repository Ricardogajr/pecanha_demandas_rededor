#Include 'Protheus.ch'

/*/ {Protheus.doc} F13040010
Rotina utilizada dentro do método UpSertDocDev para inclusão de nota fiscal de entrada em mês fechado para alterar lote contabil na exclusao da nota.

@type       User Function
@author     Marcelo Mendes
@since      28/02/2019
@version    12.1.17
/*/

User Function F1304002(n_Quantas, dDatalanc, cLote, cSubLote, cDoc)

	Local nX 

	Local cXLote := GetNewPar("FS_CTBLOT","000010")
	Local cQuery := ""

	cQuery := " SELECT NVL(Max(CT2_LOTE),0) MAXDOC "
	cQuery += " FROM "+RetSqlName("CT2")+" CT2 WHERE "
	cQuery += " CT2_DATA 	= '"+DTOS(dDatalanc)+"' AND "
	cQuery += " CT2_LOTE 	= '"+cXLote+"' AND "
	cQuery += " CT2_SBLOTE 	= '"+cSubLote+"' AND "
	cQuery += " CT2_DOC 	= '"+cDoc+"' AND "
	cQuery += " CT2_FILIAL 	= '"+xFilial("CT2")+"' AND "
	cQuery += " D_E_L_E_T_	=' ' "
	//cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPPRXDOC")

	cProxDoc := STRZERO(VAL(("TMPPRXDOC")->MAXDOC),6)

	dbSelectArea("TMPPRXDOC")
	("TMPPRXDOC")->(dbCloseArea())

//	IF VAL(cProxDoc) = 0
//	 	cProxDoc := cSubLote
//	Else
		cProxDoc := SOMA1(cProxDoc)
//	Endif

	IF Val(cProxDoc) > 0 

		For nX := 1 to n_Quantas

			If StrZero(nX, 2) == CT2->CT2_MOEDLC

//				CT2->CT2_LOTE 	:= cXLote 
//				CT2->CT2_SBLOTE := cProxDoc 
				CT2->CT2_LOTE 	:= cProxDoc 

			Endif

		Next

	Endif

Return(Nil)

