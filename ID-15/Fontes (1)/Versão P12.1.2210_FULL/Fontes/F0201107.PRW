#Include "Protheus.ch"
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} F0201107(cCodigo)
Verifica se o subgrupo que está sendo manipulado na tela de cadastro de produtos pertence ao
mesmo tipo de produto.
@project    MAN0000007423048
@type       User Function
@author     Alceu Pereira
@since      15/04/2019
@version    1.0
@return     lRet, se validou ou não
/*/

User Function F0201107(cCampo)

	Local aArea := GetArea()
	Local lRet  := .T.
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cAliasProd := GetNextAlias()
	Local cCodSubGrp := SB1->B1_XSUBGRP
	Local cGrpAltTipo := GetNewPar("MV_XALTSBG","000000")
	Local aGruposUsr := UsrRetGrp(cUserName,__cUserId)
	Local nX := 0
	Local lAltera := .F.
	Local oModel := FWModelActive()

	Default cCampo := ""

	If ((cCampo == "B1_SEGUM" .Or. cCampo == "B1_XTERUM" .Or. cCampo == "B1_UM") .And. ALTERA)
		For nX := 1 To Len(aGruposUsr)
			If AllTrim(aGruposUsr[nX]) $ AllTrim(cGrpAltTipo)
				lAltera := .T.
				Exit
			EndIf
		Next nX

		If !lAltera
			lRet := .F.
			Help(NIL, NIL, "F0201107", NIL, "Não é permitido alterar o campo "+AllTrim(GetSX3Cache(cCampo, "X3_TITULO"))+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Somente usuários com o grupo cadastrado no parâmetro MV_XALTSBG podem realizar essa manutenção."})
		EndIf
	Else

		cQuery :=  "SELECT "
		cQuery +=      "BM_MSBLQL, BM_DESC, P25_DESCSU, BM_GRUPO "
		cQuery +=  "FROM "
		cQuery +=       RETSQLNAME("SBM")+ " BM "
		cQuery +=  "INNER JOIN "+ RETSQLNAME("P25") +" P25 ON  "
		cQuery +=  "	P25.P25_TIPO = BM.BM_GRUPO AND "
		cQuery +=  "	P25.D_E_L_E_T_ = ' ' "
		cQuery +=  "WHERE "
		cQuery +=  "	P25.P25_SUBGRP = '" + M->B1_XSUBGRP + "' AND "
		cQuery +=  "	BM.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		If (cAliasQry)->( EOF())

			Help('',1,'Help',"MATA010","Não é possível utilizar este subgrupo, ele está associado ao tipo INATIVO.",1,0)
			(cAliasQry)->( dbCloseArea() )
			RestArea(aArea)
			lRet := .F.

		Else
			If (cAliasQry)->BM_MSBLQL == "1"

				Help('',1,'Help',"MATA010","Subgrupo está bloqueado e não pode ser utilizado",1,0)
				(cAliasQry)->( dbCloseArea() )
				lRet := .F.

			EndIf

			If ALTERA
				For nX := 1 To Len(aGruposUsr)
					If AllTrim(aGruposUsr[nX]) $ AllTrim(cGrpAltTipo)
						lAltera := .T.
						Exit
					EndIf
				Next nX
				cQuery :=  "SELECT "
				cQuery +=      "BM_MSBLQL, BM_DESC, P25_DESCSU, BM_GRUPO "
				cQuery +=  "FROM "
				cQuery +=       RETSQLNAME("SBM")+ " BM "
				cQuery +=  "INNER JOIN "+ RETSQLNAME("P25") +" P25 ON  "
				cQuery +=  "	P25.P25_TIPO = BM.BM_GRUPO AND "
				cQuery +=  "	P25.D_E_L_E_T_ = ' ' "
				cQuery +=  "WHERE "
				cQuery +=  "	P25.P25_SUBGRP = '" + cCodSubGrp + "' AND "
				cQuery +=  "	BM.D_E_L_E_T_ = ' ' "

				dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasProd,.F.,.T.)

				If !(cAliasProd)->( EOF())
					If !(AllTrim((cAliasQry)->BM_GRUPO) == AllTrim((cAliasProd)->BM_GRUPO))
						If !lAltera
							oModel:SetValue("SB1MASTER",'B1_XSUBGRP',cCodSubGrp)
							lRet := .F.
							Help(NIL, NIL, "F0201107", NIL, "Não é permitido alterar o subgrupo atual para um com tipo diferente.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Somente usuários com o grupo cadastrado no parâmetro MV_XALTSBG podem realizar essa manutenção."})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return (lRet)
