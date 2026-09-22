/*/{Protheus.doc} FPROCPED

@project Rotina de reenvio de pedidos ERP
@description Rotina de Menu utilizada para reprocessar pedidos ERP manualmente

/*/

#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "ApWebSrv.ch"


User Function FPROCPED()

	Local aArea := GetArea()
	Private cGetFil  := "        "
	Private cGetPed  := "      "
	Private cGetOper  := " "
	Private lHasButton := .T.


	SetPrvt("oDlg1","oSay1","oSay2","oSay3","oBtn1","oBtn2","oGet1","oGet2","oGet3")
	oDlg1      := MSDialog():New( 308,-1030,516,-777,"Reenvio de Pedidos ERP",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 012,000,{||" Filial"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 028,000,{||" Num Ped"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 044,000,{||" Operação"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oBtn1      := TButton():New( 072, 016, "Enviar",oDlg1,{||fInsert()}, 037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2      := TButton():New( 072, 068, "Fechar",oDlg1,{||oDlg1:End()}, 037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oGet1      := TGet():New( 012, 028, { | u | If( PCount() == 0, cGetFil, cGetFil := u ) },oDlg1, ;
		060, 0008, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetFil",,,,lHasButton  )
	oGet2      := TGet():New( 044, 028, { | u | If( PCount() == 0, cGetOper, cGetOper := u ) },oDlg1, ;
		060, 0008, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetOper",,,,lHasButton  )
	oGet3      := TGet():New( 028, 028, { | u | If( PCount() == 0, cGetPed, cGetPed := u ) },oDlg1, ;
		060, 0008, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetPed",,,,lHasButton  )
	oDlg1:Activate(,,,.T.)


	RestArea(aArea)
Return

Static Function fInsert()

	Local lValidou := .F.
	Local cFilBkp := cFilAnt

	cGetOper := Upper(cGetOper)

	If AllTrim(cGetFil) == "".Or. AllTrim(cGetPed) == "" .Or. AllTrim(cGetOper) == ""
		Alert("Todos os campos devem ser preenchidos")
		Return
	EndIf
	If Len(AllTrim(cGetFil)) < 8
		Alert("O número da filial está incorreto.")
		Return
	ElseIf Len(AllTrim(cGetPed)) < 6
		Alert("O número do pedido está incorreto")
		Return
	ElseIf cGetOper $ "I|B|D|E|R"
		lValidou := .T.
	Else
		Alert("Operação inválida")
		Return
	EndIf
	cFilAnt := cGetFil
	lValidou := IsPCLib(cGetPed,cGetFil)
	If (!lValidou  .And. cGetOper != "B")
		Alert("O pedido não está liberado! A rotina será abortada.")
		Return
	EndIf

	lValidou := VldProEstocavel(cGetPed,cGetFil)
	If lValidou == .F.
		Alert("O pedido contém produtos não estocáveis.")
		Return
	EndIf

	If lValidou
		U_F07022RE(cGetPed, cGetOper)
		cFilAnt := cFilBkp
		Alert("Pedido enviado, verificar status na tabela P20.")
	EndIf



//Verifica se o pedido está liberado
Static Function IsPCLib(cPedComp,cGetFil)
	Local lRet := .T.
	Local aSC7Area := SC7->(GetArea())

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(cGetFil + AllTrim(cPedComp)))
	While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == cGetFil + AllTrim(cPedComp))
		If SC7->C7_CONAPRO <> 'L'
			lRet := .F.
			Exit
		Endif
		SC7->(DbSkip())
	End
	RestArea(aSC7Area)

Return lRet


//Valida Estocável
Static Function VldProEstocavel(cPedComp)

	Local lEstocavel := .T.
	Local aAreas     := { SC7->(GetArea()), P17->(GetArea()), GetArea() }
	Local cQry := ""
	Local cTabTemp := GetNextAlias()
	Local cItens := ""

	SC7->(DbSetOrder(1))
	If SC7->(MsSeek(xFilial("SC7") + ALLTRIM(cPedComp)))
		DbSelectArea("P17")
		P17->(DbSetOrder(1))

		While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == cGetFil + AllTrim(cPedComp))
			If P17->(MsSeek(XFilial("P17")+SC7->C7_PRODUTO+cFilAnt))
				If P17->P17_ESTOQ == "N"
					lEstocavel := .F.
					Exit
				EndIf
			EndIf
			SC7->(DbSkip())
		EndDo

	Else

		cQry := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO FROM " + RETSQLNAME("SC7") + " WHERE D_E_L_E_T_ = '*' "
		cQry += " AND C7_FILIAL = '"+CGETFIL+"' AND C7_NUM = '"+cPedComp+"' GROUP BY C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabTemp,.T.,.T.)

		DbSelectArea("P17")
		P17->(DbSetOrder(1))

		While !(cTabTemp)->(EOF())

			If !((cTabTemp)->C7_ITEM $ cItens)
				cItens += "| " + (cTabTemp)->C7_ITEM

				If P17->(MsSeek(XFilial("P17")+(cTabTemp)->C7_PRODUTO+(cTabTemp)->C7_FILIAL))
					If P17->P17_ESTOQ == "N"
						lEstocavel := .F.
						Exit
					EndIf
				EndIf
			EndIf
			(cTabTemp)->(DbSkip())
		EndDo

	EndIf

	AEval(aAreas,{|aArea| RestArea(aArea) })
Return lEstocavel
