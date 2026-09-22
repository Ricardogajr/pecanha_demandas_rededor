/*
{Protheus.doc} F0100332()
Atualiza as informações do campo RH3_XFLPTV de acordo com a RH4. 
@Author     Nairan Alves
@Since	     31/10/2017
@Version    P12.7
@Project    MAN00000462901_EF_003
@Return	 cHtml
*/

User function F0100332()

	If MsgYesNo("Deseja atualizar os registros na RH3","Atenção")
		Processa( { || AtuRH3() })
	EndIf
	
Return

Static function AtuRH3()
	Local cAliasQry := GetNextAlias()
	Local aAreaRH3	:= RH3->(GetArea())	
	Local cQuery 	:= ""
	Local nCont		:= 0

	cQuery := "	SELECT RH4_FILIAL, RH4_CODIGO, RH4_VALNOV FROM "+RetSqlName("RH4")+" " 
	cQuery += "	INNER JOIN "+RetSqlName("RH3")+" "
	cQuery += "	ON RH4_FILIAL = RH3_FILIAL "
	cQuery += "	AND RH4_CODIGO = RH3_CODIGO "
	cQuery += "	WHERE "
	cQuery += "	RH4_CAMPO = 'QS_FILPOST' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasQry )
	
	RH3->(DbSetOrder(1))
	While (cAliasQry)->(!EOF())
		If RH3->(DbSeek((cAliasQry)->RH4_FILIAL + (cAliasQry)->RH4_CODIGO))
			RecLock("RH3",.F.)
				RH3->RH3_XFLPTV := (cAliasQry)->RH4_VALNOV
			RH3->(MsUnLock())
			nCont++
		EndIf
		(cAliasQry)->(DbSkip())
	Enddo
	Aviso('Atualização RH3',"Total de registros alterados: " + cValtoChar(nCont), {'OK'}, 1)
	
	RestArea(aAreaRH3)
Return