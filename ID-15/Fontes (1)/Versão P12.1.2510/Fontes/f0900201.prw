#include "totvs.ch"

/*{Protheus.doc} F0900201
FUNCOES DE VALIDACAO PARA MAN0000007423043_EF_002
Funcao respons?vel por validar mesmo tipo de produto em relacao ï¿½ Estoc?vel na
confirmacao da rotina Analisa Cota??o
@author  robson.william
@since   03/04/2017
@param   aPropostas, vetor com as propostas as prpostas a serem analisadas
@project MAN0000007423043_EF_002
@return  lRet
*/

User Function F0900201(aPropostas)
	Local lRet		:= .T.
	Local lFaz 		:= .F.
	Local cPrimeiro	:= ""
	Local cProduto 	:= ""
	Local nI, nJ

	/*
	For nJ:=1 to len(aPropostas[1])
	cPrimeiro := ""
	For nI:=1 to len(aPropostas[1,nJ,1,2])
	If !aPropostas[1,nJ,1,2,nI,1]
	Loop
	EndIf
	cProduto := aPropostas[1,nJ,1,2,nI,3]
	If Empty(cPrimeiro)
	cPrimeiro := P17->(Posicione("P17",1,xFilial("P17") + cProduto + cFilAnt,"P17_ESTOQ"))
	Loop
	EndIf
	If !P17->(Posicione("P17",1,xFilial("P17") + cProduto + cFilAnt,"P17_ESTOQ") == cPrimeiro)
	_SetNamedPrvt("__nVez",1,"A161MapCot")
	lFaz := .T.
	EndIf
	Next
	Next

	If !lFaz
	_SetNamedPrvt("__nVez",0,"A161MapCot")
	Else
	If !MsgYesNo("Existem produtos ESTOCï¿½VEIS e produtos Nï¿½O ESTOCï¿½VEIS na mesma cotaï¿½ï¿½o de compras, e nï¿½o ï¿½ permitido haver esta combinaï¿½ï¿½o. Deseja gerar um pedido para cada tipo?")
	lRet := .F.
	EndIf
	EndIf
	*/

	_SetNamedPrvt("__nVez",1,"A161MapCot")
	If !MsgYesNo("Caso exista produtos ESTOCÁVEIS e produtos NÃO ESTOCÁVEIS na mesma cotações de compras, serão gerados pedidos separados para o fornecedor. Deseja continuar?")
		lRet := .F.
	EndIf
	_SetNamedPrvt("__cPedComp","","A161MapCot")
Return lRet

/*/{Protheus.doc} F0900202
FUNCOES DE VALIDACAO PARA MAN0000007423043_EF_002
Fun??o respons?vel por agrupar os produtos ESTOC?VEIS e N?O ESTOC?VEIS
e gerar pedido de compra adicional com um do grupos
@type User function
@author robson.william
@since 06/04/2017
@version 12.7
@param	__nVez = Variï¿½vel Private Criada no Ponto de Entrada MT161OK e usada para controlar qual pedido de compra deverï¿½ fazer
@project	MAN0000007423043_EF_002
@return lRet
/*/

User Function F0900202(aParamIxb) //{cFilAnt,SC7->C7_NUM,aRatFin,MaFisRet(1,"IT_TOTAL")}

	Processa({|| GeraPed(aParamIxb) }, "Validando dados de produtos...")

Return

Static Function GeraPed(aParamIxb)
	Local aSC7Area  := SC7->(GetArea())
	Local cPrimeiro := ""
	Local aCabec	:= {}
	Local aLinha	:= {}
	Local aItens 	:= {}
	Local aCabAlt	:= {}
	Local aLinAlt	:= {}
	Local aLinNew	:= {}
	Local aItAlt	:= {}
	Local nTipo		:= 1 //Pedido de Compra
	Local cTpAtu	:= ""
	Local cConPro 	:= ""
	Local cHelpMsg	:= ""
	Local cNumAtu	:= ""
	Local nI
	Local cNumCot   := ""
	Local aItemCot  := {}

	Private LMSERROAUTO := .F.	

	If Empty(__nVez)
		Return
	EndIf

	If __cPedComp == aParamIxb[__nVez,2]
		__nVez ++
		Return
	Else
		__cPedComp := aParamIxb[1,2]
	EndIf

	SC7->(DbSetOrder(1))

	If SC7->(DbSeek(xFilial("SC7") + aParamIxb[__nVez,2]))
		While SC7->(!Eof() .and. xFilial("SC7") + C7_NUM == aParamIxb[__nVez,1] + aParamIxb[__nVez,2])
			cTpAtu := P17->(Posicione("P17",1,xFilial("P17") + SC7->C7_PRODUTO + cFilAnt,"P17_ESTOQ"))

			If Empty(cPrimeiro)
				cPrimeiro	:= cTpAtu
				nTipo 		:= SC7->C7_TIPO
			EndIf

			//Tratamento para alteraï¿½ï¿½o do pedido atual e inclusao de novo, realizando a separacao do itens ESTOCï¿½VEIS e Nï¿½O ESTOCï¿½VEIS
			If len(aCabec) == 0
				AAdd(aCabec,{"C7_NUM" 		,SC7->C7_NUM		})
				AAdd(aCabec,{"C7_EMISSAO" 	,SC7->C7_EMISSAO	})
				AAdd(aCabec,{"C7_FORNECE" 	,SC7->C7_FORNECE	})
				AAdd(aCabec,{"C7_LOJA" 		,SC7->C7_LOJA		})
				AAdd(aCabec,{"C7_COND" 		,SC7->C7_COND		})
				AAdd(aCabec,{"C7_CONTATO" 	,SC7->C7_CONTATO	})
				AAdd(aCabec,{"C7_FILENT" 	,SC7->C7_FILENT		})

				aCabAlt := aClone(aCabec)
			EndIf

			AAdd(aLinha,{"C7_ITEM"		,SC7->C7_ITEM		,Nil})
			AAdd(aLinha,{"C7_PRODUTO"	,SC7->C7_PRODUTO	,Nil})
			AAdd(aLinha,{"C7_QUANT"		,SC7->C7_QUANT		,Nil})
			AAdd(aLinha,{"C7_PRECO"		,SC7->C7_PRECO 		,Nil})
			AAdd(aLinha,{"C7_TOTAL"		,SC7->C7_TOTAL		,Nil})
			AAdd(aLinha,{"C7_TES"		,SC7->C7_TES 		,Nil})
			AAdd(aLinha,{"C7_XORIG"		,SC7->C7_XORIG		,Nil})
			AAdd(aLinha,{"C7_XNUM"		,SC7->C7_XNUM		,Nil})
			AAdd(aLinha,{"C7_RESIDUO"	,SC7->C7_RESIDUO	,Nil})
			AAdd(aLinha,{"C7_UM"		,SC7->C7_UM			,Nil})
			AAdd(aLinha,{"C7_NUMSC"		,SC7->C7_NUMSC		,Nil})
			AAdd(aLinha,{"C7_ITEMSC"	,SC7->C7_ITEMSC		,Nil})
			AAdd(aLinha,{"C7_NUMCOT"	,SC7->C7_NUMCOT		,Nil})
			AAdd(aLinha,{"C7_LOCAL"		,SC7->C7_LOCAL		,Nil})
			AAdd(aLinha,{"C7_OBS"		,SC7->C7_OBS		,Nil})
			AAdd(aLinha,{"C7_CC"		,SC7->C7_CC			,Nil})
			AAdd(aLinha,{"C7_VLDESC"	,SC7->C7_VLDESC		,Nil})
			AAdd(aLinha,{"C7_QTDSOL"	,SC7->C7_QTDSOL		,Nil})
			AAdd(aLinha,{"C7_DATPRF"	,SC7->C7_DATPRF		,Nil})
			AAdd(aLinha,{"C7_CODORCA"	,SC7->C7_CODORCA	,Nil})
			AAdd(aLinha,{"C7_GRADE"		,SC7->C7_GRADE		,Nil})
			AAdd(aLinha,{"C7_CONAPRO"	,SC7->C7_CONAPRO	,Nil})
			cConPro := SC7->C7_CONAPRO
			cNumCot := SC7->C7_NUMCOT

			If !(cTpAtu == cPrimeiro)
				aLinNew	:= aClone(aLinha)
				AAdd(aLinAlt,{"C7_REC_WT" 	,SC7->(RECNO())		,Nil})
				AAdd(aLinAlt,{"C7_ITEM" 	,SC7->C7_ITEM		,Nil})
				AAdd(aLinAlt,{"C7_PRODUTO" 	,SC7->C7_PRODUTO	,Nil})
				AAdd(aLinAlt,{"AUTDELETA" 	,"S"				,Nil})
				AAdd(aItAlt,aLinAlt)
				AAdd(aItens,aLinNew)
			EndIf

			aLinha := {}
			aLinAlt:= {}
			aLinNew:= {}

			SC7->(DbSkip())
		End
	EndIf


	If len(aItAlt) > 0 //Existem itens diferentes e o pedido deverï¿½ ser dividido
		Begin Transaction
			//Efetua a Alteraï¿½ï¿½o do Pedido Original
			MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},nTipo,aCabec,aItAlt,4)
			If lMsErroAuto
				DisarmTransaction()
				cHelpMsg := "alteraï¿½ï¿½o"
				Break
			EndIf

			//Efetua a Inclusï¿½o do Novo Pedido
			aCabec[1,2] := "" //Apaga o Nï¿½mero do Pedido de Compra
			MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},nTipo,aCabec,aItens,3)
			If lMsErroAuto
				DisarmTransaction()
				cHelpMsg := "criaï¿½ï¿½o"
				Break
			EndIf

			//Atualiza o status do bloqueio do novo pedido com o status do pedido Original
			cNumAtu := SC7->C7_NUM
			SC7->(DbSeek(xFilial("SC7") + cNumAtu))
			While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == xFilial("SC7") + cNumAtu)
				SC7->(AAdd(aItemCot,{C7_NUMSC, C7_ITEMSC, C7_ITEM}))

				SC7->(RecLock("SC7"),.F.)
				SC7->C7_CONAPRO := cConPro
				SC7->C7_NUMCOT  := cNumCot
				SC7->(MsUnlock())

				SC7->(DbSkip())
			End

			SC8->(DbSetOrder(1))
			SC8->(DbSeek(xFilial("SC8") + cNumCot))
			While !SC8->(EoF()) .And. SC8->(C8_FILIAL + C8_NUM) == xFilial("SC8") + cNumCot
				If ( nPosCot := AScan(aItemCot,{|aItCot| aItCot[1] + aItCot[2] == SC8->(C8_NUMSC + C8_ITEMSC) }) ) > 0
					RecLock("SC8",.F.)
					SC8->C8_NUMPED  := cNumAtu
					SC8->C8_ITEMPED := aItemCot[nPosCot][3]
					SC8->(MsUnLock())
				EndIf
				SC8->(DbSkip())
			EndDo


		End Transaction

		If lMsErroAuto
			Help(,,'F0900202',,'Erro na ' + cHelpMsg + ' do pedido de compras! Os itens ESTOCï¿½VEIS e Nï¿½O ESTOCï¿½VEIS permanecerï¿½o no mesmo pedido!',1,0) 
			If (!IsBlind())
				MostraErro()
			EndIf
		EndIf

	EndIf

	__nVez ++
	RestArea(aSC7Area)

Return
