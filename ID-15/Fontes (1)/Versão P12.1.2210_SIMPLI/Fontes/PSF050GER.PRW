#INCLUDE "PROTHEUS.CH"
#Include "Totvs.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"



/*
	O ponto de entrada F050GER permite gravar dados complementares nos títulos de impostos, 
	desde que estas informações sejam idênticas para todos os impostos 
	(por exemplo, um código específico do cliente para amarração de pedido, NF e impostos).
	
	Parâmetro: ParamIxb -> Array contendo o Alias onde foi gravado o imposto e Recno do título do imposto.
*/
***********************
User Function F050GER()
	***********************
    /*
    ** Grava o campo "E2_XMIGLT" nos títulos TX's, originados à partir da carga através da rotina EXECAUTOSE2.
    */
	If IsInCallStack( 'U_EXAUTOSE2' )
		GrvXMigLt(ParamIxb)
	else
		fMvMunic()
	Endif
    /* FIM: Grava o campo "E2_XMIGLT" nos títulos TX's, originados à partir da carga através da rotina EXECAUTOSE2. */
Return

	***********************************
Static Function GrvXMigLt(ParamIxb)
	***********************************
	Local aRegImp := ParamIxb
	Local nx := 0
	Local aAreaRdm := GetArea()

	If Len(aRegImp) > 0
		For nX := 1 To Len(aRegImp)
			dbSelectArea(aRegImp[nX][1])
			dbGoto(aRegImp[nX][2])		//Gravar os dados necessarios
			If RecLock(aRegImp[nX][1])

				(aRegImp[nX][1])->E2_XMIGLT := IF(TYPE("___XMIGLT") == "C",___XMIGLT,(aRegImp[nX][1])->E2_XMIGLT)

				(aRegImp[nX][1])->(MsUnLock())
			Endif
		Next nX
	EndIf

	RestArea(aAreaRdm)
Return


Static Function fMvMunic()

	Local aArea := GetArea()
	Local AareaE2 := SE2->(GetArea())
	Local cLojaIss := GetNewPar("MV_XLJMUNI","01")
	Local cFornIss := GetNewPar("MV_MUNIC","")
	Local nX := 01
	Local cMaxParc  := ""
	Local cAliasE2 := GetNextAlias()
	Local cPrefixo := ""
	Local cNum := ""
	Local cParcela := ""
	Local cTipo := ""
	Local cFornece := ""
	Local cLoja := ""

	DbSelectArea("SA2")
	DbSetOrder(1)
	SA2->(DbSeek(XFILIAL("SA2")+Padr(cFornIss,TamSx3("A2_COD")[1])+cLojaIss))

	For nX := 01 To Len(PARAMIXB)
		SE2->(DBGOTO(PARAMIXB[nX][2]))
		If SE2->E2_TIPO == "ISS"

			cMaxParc := SE2->E2_PARCELA
			cQuery := " SELECT MAX(E2_PARCELA) AS MAXIMO FROM " + RETSQLNAME("SE2")
			cQuery += " WHERE E2_FORNECE = '" + SE2->E2_FORNECE + "'"
			cQuery += " AND E2_LOJA = '" + cLojaIss + "'"
			cQuery += " AND E2_FILIAL = '" + SE2->E2_FILIAL + "'"
			cQuery += " AND E2_PREFIXO = '" + SE2->E2_PREFIXO +"'"
			cQuery += " AND E2_NUM = '" + SE2->E2_NUM + "'"
			cQuery += " AND D_E_L_E_T_ = ' ' "

			If Select( cAliasE2 ) > 0
				( cAliasE2 )->( DbCloseArea() )
			EndIf

			TcQuery cQuery Alias ( cAliasE2 ) New
			If !( cAliasE2 )->( Eof() )
				cMaxParc := Soma1((cAliasE2)->MAXIMO,.T.)
			EndIf

			SE2->(RecLock("SE2",.F.))
			SE2->E2_PARCELA := cMaxParc
			SE2->E2_LOJA := cLojaIss
			SE2->E2_NOMFOR := AllTrim(SA2->A2_NREDUZ)
			SE2->(MsUnlock())
			FKCOMMIT()

			cPrefixo := SUBSTR(SE2->E2_TITPAI, 1,TamSX3("E2_PREFIXO")[1])
			cNum     := SUBSTR(SE2->E2_TITPAI, TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])
			cParcela := SUBSTR(SE2->E2_TITPAI, TamSX3("E2_PREFIXO")[1]+1+TamSX3("E2_NUM")[1],TamSX3("E2_PARCELA")[1])
			cTipo    := SUBSTR(SE2->E2_TITPAI, TamSX3("E2_PREFIXO")[1]+1+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1],TamSX3("E2_TIPO")[1])
			cFornece := SUBSTR(SE2->E2_TITPAI, TamSX3("E2_PREFIXO")[1]+1+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1],TamSX3("E2_FORNECE")[1])
			cLoja	 := SUBSTR(SE2->E2_TITPAI, TamSX3("E2_PREFIXO")[1]+1+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1],TamSX3("E2_LOJA")[1])

			DbSelectArea("SE2")
			DbSetOrder(1)
			SE2->(DbSeek(SE2->E2_FILIAL+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja))
			SE2->(RecLock("SE2",.F.))
			SE2->E2_PARCISS := cMaxParc
			SE2->(MsUnlock())
			FKCOMMIT()
			
			( cAliasE2 )->( DbCloseArea() )
		EndIf
	Next nX
	RestArea(AareaE2)
	RestArea(aArea)
Return
