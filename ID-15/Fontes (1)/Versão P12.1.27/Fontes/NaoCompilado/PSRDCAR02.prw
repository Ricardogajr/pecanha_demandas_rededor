#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Protheus.ch"
#include "fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PSFGeraSP
description Rotina responsável por gerar a SP.
@author  Ricardo Junior	
@since   01/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User function RDCAR02(aCabec, aItens, nOpc, lBloqueia)
	Local lRetorno	:= .T.
	Local nY 		:= 00
	Local nX 		:= 00
	Local lRet		:= .F.

	Private oModel 		:= FWLoadModel('PSF0100401')
	Private lMsErroAuto := .F.
	Private aHeader := {}
	Private aCols   := {}

	Default aCabec 		:= {}
	Default aItens 		:= {}
	Default nOpc   		:= 3
	Default lBloqueia 	:= .F.

	lChange	:= .T.

	if Len(aCabec) == 0 .Or. Len(aItens) == 0
		return .F.
	endif

	oModel:SetOperation(nOpc)
	oModel:Activate()

	//oModel:SetValue('MODEL_SC7p',"C7_NUM", GetSx8Num("SC7","C7_NUM"))
	nPosFor := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_FORNECE" })
	nPosLoj := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_LOJA" })

	nDtVenc := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XDTVEN" })

	cChaveSA2 := xFilial("SA2")+aCabec[nPosFor][2]+aCabec[nPosLoj][2]

	DbSelectArea("SA2")
	DbSetOrder(01)
	if DbSeek(cChaveSA2)//desbloqueia
		If SA2->A2_MSBLQL == "1"
			RecLock("SA2",.F.)
			SA2->A2_MSBLQL := "2"
			SA2->(MsUnlock())
			lRet := .T.
		endif
	Endif

	for nY := 01 To Len(aCabec)
		if nY == nDtVenc //Pula o preenchimendo do campo Data de vencimento.
			loop
		endif
		fConvert(aCabec[nY][1],aCabec[nY][2], 'MODEL_SC7p')
	next nY

	for nX := 01 To Len(aItens)
		fConvert(aItens[nX][1],aItens[nX][2], 'MODEL_SC7')
	next nX

	Begin Transaction
		//Valida dados.
		if oModel:VldData()
			oModel:CommitData()
			ConfirmSx8()
			aError := GravaLog()
			DbSelectArea("SE2")
			DbSetOrder(6)
			cChavE2 := XFilial("SE2") + SC7->(C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC)
			MaAlcDoc({SC7->C7_NUM,"PC",SC7->C7_TOTAL,,,},,3)
			if !lBloqueia
				//MaAlcDoc({SC7->C7_NUM,"PC" ,SC7->C7_TOTAL,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,dDataBase},dDataBase,3)
				//MaAlcDoc({SC7->C7_NUM,"PC",SC7->C7_TOTAL,,,},,3)
				RecLock("SC7",.F.)//Atualiza o Pedido como encerrado.
				SC7->C7_ENCER 	:= "E"
				SC7->C7_XUSR 	:= " "
				SC7->C7_QUJE 	:= 1
				SC7->C7_XORIG 	:= '3'
				SC7->C7_XDTVEN := aCabec[nDtVenc][2]
				SC7->(MsUnlock())
				//Atualiza o Titulo.
				if SE2->(DbSeek(cChavE2))
					While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
						RecLock("SE2",.F.)
						SE2->E2_XAPRVSP := "1"
						SE2->E2_XDTAPRO := DDATABASE
						SE2->(MsUnlock())
						SE2->(DbSkip())
					enddo
				endif
			else
				//Atualiza o Titulo bloqueando.
				if SE2->(DbSeek(cChavE2))
					While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
						RecLock("SE2",.F.)
						SE2->E2_XAPRVSP := "2"
						SE2->(MsUnlock())
						SE2->(DbSkip())
					enddo
				endif
				RecLock("SC7",.F.)//Atualiza o Pedido como encerrado.
				SC7->C7_XORIG := '3'
				SC7->C7_XUSR := " "
				SC7->C7_XDTVEN := aCabec[nDtVenc][2]
				SC7->(MsUnlock())
			endif
		else
			aError := GravaLog()
			lRetorno := .F.
			RollBackSX8()
			DisarmTransaction()
		endif
		if lRet//Bloqueia
			DbSelectArea("SA2")
			DbSetOrder(01)
			if DbSeek(cChaveSA2)
				RecLock("SA2",.F.)
				SA2->A2_MSBLQL := "1"
				SA2->(MsUnlock())
			Endif
		endif

	End Transaction

return aError
//-------------------------------------------------------------------
/*/{Protheus.doc} fConvert
description Converte o campo para o tipo do campo da base.
@author  Ricardo Junior
@since   26/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function fConvert(cCampo, cConteudo, cModelSC7)
	Local xConteudo := Nil
	do case
	case type(cCampo) == "D" .And. valType(&(cCampo)) != "D"
		xConteudo := SToD(cConteudo)
	Case Type(cCampo) == "N" .And. valType(&(cCampo)) != "N"
		xConteudo := Val(cConteudo)
	Case Type(cCampo) == "L" .And. valType(&(cCampo)) != "L"
		xConteudo := iIf(AllTrim(&(cCampo))=="F", .F., .T.)
	OtherWise
		xConteudo := cConteudo
	endcase
	oModel:SetValue(cModelSC7, cCampo, xConteudo)
Return

Static function GravaLog()
	Local nX	 := 00
	Local aError := {}
	aGetError := oModel:GetErrorMessage()
	aAdd(aError, "Título: " + oModel:GetValue("MODEL_SC7p", "C7_XDOC"))
	aAdd(aError, "Série: " 	+ oModel:GetValue("MODEL_SC7p", "C7_XSERIE"))
	aAdd(aError, "Cód For/Loja: " + oModel:GetValue("MODEL_SC7p", "C7_FORNECE") + "/" + oModel:GetValue("MODEL_SC7p", "C7_LOJA"))
	if aGetError[2] != "POST"
		aAdd(aError, "---------------------------------ERRO----------------------------------")
		For nX := 01 To Len(aGetError)
			aAdd(aError, aGetError[nX])
		Next nX
		aAdd(aError, Replicate("-",71))
	else
		aAdd(aError, "Num. SP: " + SC7->C7_NUM)
		aAdd(aError, "---------------------------------SUCESSO-------------------------------")
	endif
Return aError
