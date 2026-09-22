#include "totvs.ch"

/*/{Protheus.doc} F0702201
Função responsável pelas integrações de pedidos de compras externos
@type User function
@author robson.william
@since 02/03/2017
@version 12.7
@param oPedComp, objeto, Informacoes do pedido de compras
@project MAN0000007423041_EF_022
@return cRET 
/*/

User Function F0702201(oPedComp)
	Local cRetorno	:= ""
	Local cFilInt	:= ""
	Local cFilAtu	:= ""
	Local cIdInt 	:= U_GetIntegID()
	Local lRet		:= .T.
	Local nRecSC7   := 0 //ticket n° 7918083 - 415966 - ajuste validação
	Local lValid    := .T.
	Local cUpdate   := ""
	Local cXnum 	:= ""
	Local cXfront   := ""
	Local cNum      := ""


	Begin Sequence

		Begin Transaction
			nRegLog := U_F07LOG01(cIdInt,{oPedComp})
		End Transaction

		//Tratamento dos campos
		If Empty(oPedComp:cFilReg)
			cRetorno := "ERRO|FILIAL DE INTEGRAÇÃO NÃO INFORMADA"
			lRet := .F.
		ElseIf !U_F07ChkFil(oPedComp:cFILREG)
			cRetorno := "ERRO|Filial Invalida"
			lRet := .F.
		ElseIf Empty(oPedComp:cNum)
			cRetorno := "ERRO|PEDIDO DE COMPRA PROTHEUS NÃO INFORMADO"
			lRet := .F.
		ElseIf Empty(oPedComp:cXNum)
			cRetorno := "ERRO|PEDIDO DE COMPRA FRONT NÃO INFORMADO"
			lRet := .F.
		ElseIf Empty(oPedComp:cXFront)
			cRetorno := "ERRO|IDENTIFICAÇÃO DO FRONT NÃO INFORMADA"
			lRet := .F.
		Endif

		if lRet
			cFilInt := oPedComp:cFilReg
			cXNum  := AllTrim(oPedComp:cXNum)
			cXFront := AllTrim(oPedComp:cXFront)
			cNum := AllTrim(oPedComp:cNum)

			If cFilInt != cFilAnt
				cFilAtu := cFilAnt
				cFilAnt := cFilInt
			EndIf

			SC7->(DbSetOrder(1)) //C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
			If !SC7->(DbSeek(xFilial("SC7") + AllTrim(cNum) ))
				cRetorno := "ERRO|PEDIDO DE COMPRA PROTHEUS NÃO LOCALIZADO"
				lRet := .F.
			Endif
		Endif

		If lRet
			/*/Begin Transaction				
			While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + AllTrim(oPedComp:cNum))
				RecLock("SC7",.F.)
				SC7->C7_XNUM	:= AllTrim(oPedComp:cXNum)
				SC7->C7_XFRONT	:= AllTrim(oPedComp:cXFront)
				SC7->C7_XID		:= cIdInt
				SC7->(MsUnlock())
				SC7->(DbSkip())
			End
		      End Transaction/*/

			cUpDate := " UPDATE "+RetSqlName("SC7") 
			cUpDate += " SET C7_XNUM = '"+cXnum+"', C7_XFRONT = '"+cXfront+"', C7_XID = '"+cIdInt+"'"
			cUpdate += " WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL = '"+cFilInt+"' AND C7_NUM = '"+cNum+"'"
			If TcSQLExec( cUpdate ) != 0
				Conout("ERRO AO ATUALIZAR O PEDIDO ERP "+cNum+ " ") + TCSQLError()
			Else
				SC7->(DBCommit())
			EndIf


			If SC7->(DbSeek(xFilial("SC7") + AllTrim(cNum) ))
				While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + AllTrim(cNum))
					If SC7->C7_XNUM	== ""
						lValid := .F.
					EndIf
					SC7->(DbSkip())
				End

				If lValid
					cRetorno := "OK|ID:" + cIdInt
				Else
					cRetorno := "ERRO|OS DADOS NÃO FORAM GRAVADOS"
				Endif
			EndIf
		EndIf
	End Sequence

	U_F07LOG02(nRegLog,cRetorno,(Left(cRetorno,2) == "OK"),'SC7',1,xFilial("SC7") + '|' + cNum)

	If cFilAtu != cFilAnt
		cFilAnt := cFilAtu
	EndIf

Return cRetorno
