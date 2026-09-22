#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"


/*{Protheus.doc} FLJMUNIC()
Muda a loja do título filho dependendo da operação
@Author Lucas Miranda
@Since 20/04/2021
@Version P12.7 */


User Function FLJMUNIC()

Local aArea := GetArea()
Local aAreaE2 := SE2->(GetArea())
Local cRetIss := GetNewPar("MV_MRETISS","1") // Se retornar 1 - Gera o ISS no titulo principal, 2 na baixa.
Local cFornece := GetNewPar("MV_MUNIC","")
Local cLojForn := GetNewPar("MV_XLJMUNI","01")

//-- Verificar se o acesso é por Job/WebService
	If GetRemoteType() == -1
	Return
	EndIf

	If (Procname(1) == "U_A103VLEX" .Or. Procname(1) == "U_MT103MSD")
		fExclMt103()
	ElseIf Procname(1) == "U_F240OK"
		fExclFn240()
	ElseIf (Procname(1) == "U_FA050UPD" .Or. Procname(1) == "U_F590COK")
		fExclFn050()
	EndIf



RestArea(AareaE2)
RestArea(aArea)
Return

Static Function fExclMt103()

Local aArea := GetArea()
Local cQuery := ""
Local cAliasE2 := GetNextAlias()
Local cLoja := "00"
Local cFornIss := GetNewPar("MV_MUNIC","")
Local cParcIss := ""

DbSelectArea("SA2")
DbSetOrder(1)
SA2->(DbSeek(XFILIAL("SA2")+Padr(cFornIss,TamSx3("A2_COD")[1])+cLoja))

		cQuery += " SELECT E2_FILIAL AS FILIAL, E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA AS TITPAI, E2.* "
		cQuery += " FROM " + RetSqlName("SE2") + " E2"
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND E2_FILIAL = '"+SF1->F1_FILIAL+"' "
		cQuery += " AND E2_PREFIXO = '"+SF1->F1_SERIE+"' "
		cQuery += " AND E2_NUM = '"+SF1->F1_DOC+"' "
		cQuery += " AND E2_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQuery += " AND E2_LOJA = '"+SF1->F1_LOJA+"' "

	If Select( cAliasE2 ) > 0
		( cAliasE2 )->( DbCloseArea() )
	EndIf

		TcQuery cQuery Alias ( cAliasE2 ) New
	While !( cAliasE2 )->( Eof() )
		cParcIss := ( cAliasE2 )->E2_PARCISS
		DbSelectArea("SE2")
		DbSetOrder(17)
		If DbSeek(( cAliasE2 )->FILIAL+( cAliasE2 )->TITPAI)
			While (SE2->(!EOF()) .And. AllTrim(SE2->E2_TITPAI) == AllTrim(( cAliasE2 )->TITPAI))
				If SE2->E2_TIPO == "ISS"
					If AllTrim(cParcIss) == ""
						cParcIss := "1"
					EndIf
					Reclock("SE2",.F.)
						SE2->E2_LOJA := cLoja
						SE2->E2_NOMFOR := AllTrim(SA2->A2_NREDUZ)
						SE2->E2_PARCELA := cParcIss
					SE2->(MsUnlock())
				EndIf
			SE2->(DbSkip())
			EndDo
		EndIf
    (cAliasE2)->(DbSkip())
	EndDo
RestArea(aArea)
Return


Static Function fExclFn240()

Local aArea := GetArea()
Local aAreaE2 := SE2->(GetArea())
Local cSelect := ""
Local cLoja := "00"
Local cAliasE2 := GetNextAlias()
Local cFornIss := GetNewPar("MV_MUNIC","")
Local cParcIss := ""

DbSelectArea("SA2")
DbSetOrder(1)
SA2->(DbSeek(XFILIAL("SA2")+Padr(cFornIss,TamSx3("A2_COD")[1])+cLoja))

cSelect += " SELECT E2_PARCISS, E2_FILIAL AS FILIAL, E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA AS TITPAI FROM " + RetSqlName("SE2")
cSelect += " WHERE D_E_L_E_T_ = ' ' "
cSelect += " AND E2_NUMBOR = '"+SE2->E2_NUMBOR+"' "

	If Select( cAliasE2 ) > 0
		( cAliasE2 )->( DbCloseArea() )
	EndIf

		TcQuery cSelect Alias ( cAliasE2 ) New
	While !( cAliasE2 )->( Eof() )
	cParcIss := ( cAliasE2 )->E2_PARCISS
		DbSelectArea("SE2")
		DbSetOrder(17)
		If DbSeek(( cAliasE2 )->FILIAL+( cAliasE2 )->TITPAI)
			While (SE2->(!EOF()) .And. AllTrim(SE2->E2_TITPAI) == AllTrim(( cAliasE2 )->TITPAI))
				If SE2->E2_TIPO == "ISS"
					If AllTrim(cParcIss) == ""
						cParcIss := "1"
					EndIf
					Reclock("SE2",.F.)
						SE2->E2_LOJA := cLoja
						SE2->E2_NOMFOR := AllTrim(SA2->A2_NREDUZ)
						SE2->E2_PARCELA := cParcIss
					SE2->(MsUnlock())
				EndIf
			SE2->(DbSkip())
			EndDo
		EndIf
		( cAliasE2 )->( DbSkip() )
	EndDo

( cAliasE2 )->( DbCloseArea() )

RestArea(aAreaE2)
RestArea(aArea)

Return



Static Function fExclFn050()

Local aArea := GetArea()
Local AareaE2 := SE2->(GetArea())
Local cLoja := "00"
Local cFornIss := GetNewPar("MV_MUNIC","")
Local cTitPai := ""
Local cFilE2 := ""
Local cParcIss := SE2->E2_PARCISS

DbSelectArea("SA2")
DbSetOrder(1)
SA2->(DbSeek(XFILIAL("SA2")+Padr(cFornIss,TamSx3("A2_COD")[1])+cLoja))

cTitPai := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
cFilE2  := SE2->E2_FILIAL

	DbSelectArea("SE2")
	DbSetOrder(17)
	If SE2->(DbSeek(cFilE2+cTitPai))
		While (SE2->(!EOF()) .And. AllTrim(SE2->E2_TITPAI) == AllTrim(cTitPai))
			If SE2->E2_TIPO == "ISS"
				If AllTrim(cParcIss) == ""
					cParcIss := "1"
				EndIf
					Reclock("SE2",.F.)
						SE2->E2_LOJA := cLoja
						SE2->E2_PARCELA := cParcIss
						SE2->E2_NOMFOR := AllTrim(SA2->A2_NREDUZ)
					SE2->(MsUnlock())
			EndIf
			SE2->(DbSkip())
		EndDo
	EndIf
RestArea(AareaE2)
RestArea(aArea)
Return
