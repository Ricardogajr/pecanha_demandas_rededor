#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
/*/
Função XF01004MJ
Função responsável por gerar a alçada completa na SCR caso o campo de MULTA ou JUROS
tiver valor maior do que os parâmetros.
Lucas Miranda de Aguiar - 29/06/2021
/*/
User Function XF01004MJ()

	Local aArea	    := GetArea()
	Local cTipoCr 	:= "PC"
	Local cGrpAprov	:= ""
	Local cAliasAl  := GetNextAlias()
	Local cAliasCr  := GetNextAlias()
	Local cQuery	:= ""
	Local cAprov 	:= ""

	Local lOk		:= .F.
	Local lAlçada   := .F.
	Local lContinua := .F.


	Private cNumCr 	:= SC7->C7_NUM
	Private cFilCR 	:= SC7->C7_FILIAL


	//Verifica se existe algum produto com Multa ou Juros e se está cadastrado na P34
	lContinua := fValidProc()

	If lContinua

		cQuery := " SELECT * FROM " + RetSqlName("SCR")
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND CR_NUM = '"+cNumCr+"'"
		cQuery += " AND CR_FILIAL = '"+cFilCR+"'"
		cQuery += " AND CR_TIPO = '"+cTipoCr+"'"
		cQuery += " AND CR_STATUS = '02'"


		If Select( cAliasCr ) > 0
			( cAliasCr )->( DbCloseArea() )
		EndIf

		TcQuery cQuery Alias ( cAliasCr ) New
		If !( cAliasCr )->( Eof() )

			cGrpAprov := SCR->CR_GRUPO

			cQuery := " SELECT * FROM " + RetSqlName("SAL") + " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND AL_APROV NOT IN "
			cQuery += " (SELECT CR_APROV FROM SCR010 WHERE D_E_L_E_T_ = ' ' AND CR_NUM = '" +cNumCr + "' AND CR_FILIAL = '" +cFilCR+ "' AND CR_TIPO = '"+cTipoCr+"')"
			cQuery += " AND AL_COD = '" + cGrpAprov +"'"

			If Select( cAliasAl ) > 0
				( cAliasAl )->( DbCloseArea() )
			EndIf

			TcQuery cQuery Alias ( cAliasAl ) New
			While !( cAliasAl )->( Eof() )
				cAprov := ( cAliasAl )->AL_APROV
				lCria := fValAprov(cAprov)
				If lCria
					Reclock("SCR",.T.)
					SCR->CR_FILIAL	:= ( cAliasCr )->CR_FILIAL
					SCR->CR_NUM		:= ( cAliasCr )->CR_NUM
					SCR->CR_TIPO	:= ( cAliasCr )->CR_TIPO
					SCR->CR_NIVEL	:= ( cAliasAl )->AL_NIVEL
					SCR->CR_USER	:= ( cAliasAl )->AL_USER
					SCR->CR_APROV	:= ( cAliasAl )->AL_APROV
					SCR->CR_STATUS	:= IIF(( cAliasAl )->AL_NIVEL == ( cAliasCr )->CR_NIVEL  ,"02","01")
					SCR->CR_TOTAL	:= ( cAliasCr )->CR_TOTAL
					SCR->CR_EMISSAO	:= STOD(( cAliasCr )->CR_EMISSAO)
					SCR->CR_MOEDA	:= ( cAliasCr )->CR_MOEDA
					SCR->CR_TXMOEDA	:= ( cAliasCr )->CR_TXMOEDA
					SCR->CR_PRAZO	:= STOD(( cAliasCr )->CR_PRAZO)
					SCR->CR_AVISO	:= STOD(( cAliasCr )->CR_AVISO)
					SCR->CR_ESCALON	:= IIF(( cAliasCr )->CR_ESCALON == "F"  ,.F.,.T.)
					SCR->CR_ESCALSP	:= IIF(( cAliasCr )->CR_ESCALSP == "F"  ,.F.,.T.)
					SCR->CR_GRUPO 	:= ( cAliasCr )->CR_GRUPO
					SCR->CR_ITGRP 	:= ( cAliasCr )->CR_ITGRP
					SCR->CR_XNOME	:= FullName(( cAliasAl )->AL_USER)
					SCR->CR_XFORNEC := SC7->C7_FORNECE
					SCR->CR_XNOMFOR := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1,"Fornecedor nao cadastrado")
					SCR->CR_XCOMSOL := FullName(SC7->C7_XUSR)
					SCR->CR_XDOC	:= SC7->C7_XDOC
					SCR->CR_XLOJA	:= SC7->C7_LOJA
					SCR->CR_XAPRO	:= ( cAliasCr )->CR_XAPRO

					SCR->(MsUnlock())
				EndIf
				( cAliasAl )->( DbSkip() )
			EndDo
			( cAliasAl )->( DbCloseArea() )
		EndIf
		( cAliasCr )->( DbCloseArea() )
	EndIf
	RestArea(aArea)
Return


Static Function fValAprov(cAprov)

	Local aArea := GetArea()
	Local lRet := .F.

	Default cAprov := ""

	DbSelectArea("SAK")
	DbSetOrder(1)
	If SAK->(DbSeek(Xfilial("SAK")+cAprov))
		If AllTrim(SAK->AK_XMULJUR) <> "1"
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet



Static Function fValidProc()

	Local lContinua := .F.
	Local lMulta := .F.
	Local lJuros := .F.

	Local nMulta	:= 9999999
	Local nJuros	:= 9999999

	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())

		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbGoTop()

	If SC7->(dbSeek(cFilCR+cNumCr))
		While SC7->(!EOF()) .And. AllTrim(SC7->C7_FILIAL) == AllTrim(cFilCR) .And. AllTrim(SC7->C7_NUM) == AllTrim(cNumCr)
			lMulta := .F.
			lJuros := .F.
			If SC7->C7_XMULTA >= nMulta
				lMulta := .T.
			EndIf
			If SC7->C7_XJURMUL >= nJuros
				lJuros := .T.
			EndIf
			DbSelectArea("P34")
			DbSetOrder(3)
			DbGoTop()
			If P34->(DbSeek(xFilial("P34")+SC7->C7_XTIPO+SC7->C7_PRODUTO))
				If lMulta
					If P34->P34_MULTA <> "1"
						lContinua := .T.
					EndIf
				EndIf
				If lJuros
					If P34->P34_JUROS <> "1"
						lContinua := .T.
					EndIf
				EndIf
			ElseIf P34->(DbSeek(xFilial("P34")+SC7->C7_XTIPO+Space(Len(SC7->C7_PRODUTO))))
				If lMulta
					If P34->P34_MULTA <> "1"
						lContinua := .T.
					EndIf
				EndIf
				If lJuros
					If P34->P34_JUROS <> "1"
						lContinua := .T.
					EndIf
				EndIf
			ElseIf P34->(DbSeek(xFilial("P34")+Space(Len(SC7->C7_XTIPO))+SC7->C7_PRODUTO))
				If lMulta
					If P34->P34_MULTA <> "1"
						lContinua := .T.
					EndIf
				EndIf
				If lJuros
					If P34->P34_JUROS <> "1"
						lContinua := .T.
					EndIf
				EndIf
			Else
				If (lJuros .Or. lMulta)
					lContinua := .T.
				EndIf
			EndIf
			If lContinua
				Exit
			EndIf
			SC7->(DbSkip())
		EndDo
	EndIf

Return lContinua



User Function XCHKMULJUR(oModel)

	Local lContinua := .F.
	Local lMulta := .F.
	Local lJuros := .F.
	Local oMdlDetail	:= oModel:GetModel("MODEL_SC7")
	Local oMdlMain		:= oModel:GetModel("MODEL_SC7p")
	Local oMdlFooter	:= oModel:GetModel("MODEL_SC7r")

	Local nMulta	:= 9999999
	Local nJuros	:= 9999999

	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())
		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbGoTop()

	If (oMdlDetail:GetValue("C7_XMULTA") >= nMulta .Or. oMdlDetail:GetValue("C7_XJURMUL")  >= nJuros )
		lMulta := .F.
		lJuros := .F.
		If oMdlDetail:GetValue("C7_XMULTA") >= nMulta
			lMulta := .T.
		EndIf
		If oMdlDetail:GetValue("C7_XJURMUL") >= nJuros
			lJuros := .T.
		EndIf
		DbSelectArea("P34")
		DbSetOrder(3)
		DbGoTop()
		If P34->(DbSeek(xFilial("P34")+oMdlMain:GetValue("C7_XTIPO")+oMdlDetail:GetValue("C7_PRODUTO")))
			If lMulta
				If P34->P34_MULTA <> "1"
					lContinua := .T.
				EndIf
			EndIf
			If lJuros
				If P34->P34_JUROS <> "1"
					lContinua := .T.
				EndIf
			EndIf
		ElseIf P34->(DbSeek(xFilial("P34")+oMdlMain:GetValue("C7_XTIPO")+Space(Len(SC7->C7_PRODUTO))))
			If lMulta
				If P34->P34_MULTA <> "1"
					lContinua := .T.
				EndIf
			EndIf
			If lJuros
				If P34->P34_JUROS <> "1"
					lContinua := .T.
				EndIf
			EndIf
		ElseIf P34->(DbSeek(xFilial("P34")+Space(Len(SC7->C7_XTIPO))+oMdlDetail:GetValue("C7_PRODUTO")))
			If lMulta
				If P34->P34_MULTA <> "1"
					lContinua := .T.
				EndIf
			EndIf
			If lJuros
				If P34->P34_JUROS <> "1"
					lContinua := .T.
				EndIf
			EndIf
		Else
			If (lJuros .Or. lMulta)
				lContinua := .T.
			EndIf
		EndIf
	EndIf

Return lContinua



User Function XAPRVMULJUR()

	Local lContinua := .F.
	Local lMulta := .F.
	Local lJuros := .F.

	Local nMulta	:= 9999999
	Local nJuros	:= 9999999

	DbSelectArea("P35")
	DbSetOrder(1)
	DbGoTop()

	While P35->(!EOF())
		If P35->P35_TIPO == "1"
			nMulta := P35->P35_VALMIN
		ElseIf P35->P35_TIPO == "2"
			nJuros := P35->P35_VALMIN
		EndIf
		P35->(DbSkip())
	EndDo

	lMulta := .F.
	lJuros := .F.
	If SC7->C7_XMULTA >= nMulta
		lMulta := .T.
	EndIf
	If SC7->C7_XJURMUL >= nJuros
		lJuros := .T.
	EndIf
	DbSelectArea("P34")
	DbSetOrder(3)
	DbGoTop()
	If P34->(DbSeek(xFilial("P34")+SC7->C7_XTIPO+SC7->C7_PRODUTO))
		If lMulta
			If P34->P34_MULTA <> "1"
				lContinua := .T.
			EndIf
		EndIf
		If lJuros
			If P34->P34_JUROS <> "1"
				lContinua := .T.
			EndIf
		EndIf
	ElseIf P34->(DbSeek(xFilial("P34")+SC7->C7_XTIPO+Space(Len(SC7->C7_PRODUTO))))
		If lMulta
			If P34->P34_MULTA <> "1"
				lContinua := .T.
			EndIf
		EndIf
		If lJuros
			If P34->P34_JUROS <> "1"
				lContinua := .T.
			EndIf
		EndIf
	ElseIf P34->(DbSeek(xFilial("P34")+Space(Len(SC7->C7_XTIPO))+SC7->C7_PRODUTO))
		If lMulta
			If P34->P34_MULTA <> "1"
				lContinua := .T.
			EndIf
		EndIf
		If lJuros
			If P34->P34_JUROS <> "1"
				lContinua := .T.
			EndIf
		EndIf
	Else
		If (lJuros .Or. lMulta)
			lContinua := .T.
		EndIf
	EndIf

Return lContinua
Static Function FullName(cParam)
Return UsrFullName(cParam)
