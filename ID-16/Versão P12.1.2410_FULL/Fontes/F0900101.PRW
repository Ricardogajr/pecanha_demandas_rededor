#include 'protheus.ch'

/*{Protheus.doc} F0900101
Validações na digitação do codigo do produto para restringir o uso dos produtos que são controlados pelo planejamento compras.

@author Alex Sandro
@since 11/05/2017
@project MAN0000007423043_EF_001
@return NIL
*/

User Function F0900101(cVldProd)

	Local aAreas    := { ACV->(GetArea('ACV')), ACV->(GetArea('SAI')), GetArea() }
	Local aGrupos    := {}
	Local cReadVar  := ''//ReadVar()
	Local cProduto  := ''//If(Empty(cReadVar), "", &(cReadVar))
	Local cCatN1    := ''
	Local nNivel    := 0 //nivel do produto
	Local nX        := 0
	Local cTPSC     := ""
	Local cCtrlPla  := GetMV("FS_CTRLPLA", , "000001" )
	Local cCtrlTip  := GetMv("FS_CTRLTIP", , "01|" )
	Local aCtrlTip  := {}
	Local nCtrlTip  := 1
	Local cTipoSolic := ""
	Local aTipoSolic := {}
	Local nTipoSolic := 1
	Local lIsPlanej  := .F.
	Local lProdValid := .F.
	Local lSeekSAI   := .F.
	Local cUserIdBkp := __CUSERID

	Default cVldProd := ''


	if empty(cVldProd)
		cReadVar := ReadVar()
		cProduto := IIf(Empty(cReadVar), "", &(cReadVar))
	else
		cProduto := cVldProd
	endif

	SAI->(DbSetOrder(2))
	If SAI->(DbSeek(xFilial("SAI")+RetCodUsr()))
		lSeekSAI := .T.
		cTPSC := AllTrim(SAI->AI_XTPSC) + "|"
	EndIf

	SAI->(DbSetOrder(3))
	aGrupos := UsrRetGrp(__CUSERID)
	For nX := 1 To Len(aGrupos)
		If SAI->(DbSeek(xFilial("SAI") + aGrupos[nX]))
			lSeekSAI := .T.
			cTPSC += AllTrim(SAI->AI_XTPSC) + "|"
		EndIf
	Next

	If lSeekSAI
		cTipoSolic := cTPSC
		If "|" $ cTipoSolic
			aTipoSolic := StrToKarr(cTipoSolic,"|")
		Else
			AAdd(aTipoSolic,cTipoSolic)
		EndIf
		If "|" $ cCtrlTip
			aCtrlTip := StrToKarr(cCtrlTip,"|")
		Else
			AAdd(aCtrlTip,cCtrlTip)
		EndIf
		While !lIsPlanej .And. nCtrlTip <= Len(aCtrlTip)
			nTipoSolic := 1
			While !lIsPlanej .And. nTipoSolic <= Len(aTipoSolic)
				lIsPlanej := ( aCtrlTip[nCtrlTip] == aTipoSolic[nTipoSolic] )
				nTipoSolic++
			EndDo
			nCtrlTip++
		EndDo
	EndIf

	Begin Sequence

		If lIsPlanej
			//usuário é planejador
			lProdValid := .T.
			Break
		EndIf

		ACV->(DbSetOrder(5)) // FILIAL+PRODUTO+CATEGORIA Categoria X grupo de produto
		If ! ACV->(DbSeek(xFilial('ACV') + cProduto))
			// não existe amarração de produto x categoria então nao valida
			lProdValid := .T.
			Break
		EndIf


	End Sequence

	If !lProdValid
		If l110Auto //Inicio Thais Paiva 9474856
			aadd(_aMsgErr,"F0900101 - Produto restrito ao solicitante planejadores!")
		Else //Fim Thais Paiva 9474856
			Help( , , 'F0900101', , 'Produto restrito ao solicitante planejadores!', 1, 0)
		EndIf //Thais Paiva 9474856
	EndIf

	AEval(aAreas, {|aArea| RestArea(aArea) })


Return lProdValid
