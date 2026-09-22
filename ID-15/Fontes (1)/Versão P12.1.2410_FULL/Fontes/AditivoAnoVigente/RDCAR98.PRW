#INCLUDE "FWMVCDEF.CH"
#INCLUDE "fwmvcdef.CH"
#INCLUDE "Protheus.ch"
#include "fileio.ch"
/*/{Protheus.doc} RDCAR98
description Rotina responsável por gerar a SP.
@type function
@version  1.0
@author Ricardo Junior
@since 21/02/2023
@param aCabec, array, param_description
@param aItens, array, param_description
@param nOpc, numeric, param_description
@param lBloqueia, logical, param_description
@return variant, return_description
/*/
User function RDCAR98(aCabec, aItens, nOpc, lBloqueia)
	Local lRetorno	:= .T.
	Local nY 		:= 00
	Local nX 		:= 00
	Local nA 		:= 00
	Local lRet		:= .F.
	Local lErro 	:= .F.

	Private oModel2 		:= FWLoadModel('F0100401')
	Private lMsErroAuto := .F.
	Private aHeader := {}
	Private aCols   := {}

	Default aCabec 		:= {}
	Default aItens 		:= {}
	Default nOpc   		:= 3
	Default lBloqueia 	:= .F.


	oModelGrid := oModel2:GetModel("MODEL_SC7")
	lChange	:= .T.

	if Len(aCabec) == 0 .Or. Len(aItens) == 0
		return {"Cabeçalho ou itens não encontrados."}
	endif

	oModel2:SetOperation(nOpc)
	oModel2:Activate()

	nDtVenc := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XDTVEN" })
	nDtEmi := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_EMISSAO" })
	nXRetec := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XRETENC" })
	nXTipo := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XTIPO" })
	nUser  := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XUSER" })
	nFil   := aScan(aItens[1], {|x| Upper(AllTrim(x[1])) == "C7_FILIAL" })
	nSeri  := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XSERIE" })
	nDoc   := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_XDOC" })
	nFornece  := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_FORNECE" })
	nLoja  := aScan(aCabec, {|x| Upper(AllTrim(x[1])) == "C7_LOJA" })
	
	cFilAnt := aItens[1][nFil][2]
	for nY := 01 To Len(aCabec)
		if !Empty(oModel2:aErrorMessage[6])
			aError := GravaLog(cFilAnt, aCabec[nDoc][2], aCabec[nSeri][2], aCabec[nFornece][2])
			lErro := .T.
			Exit
		endif
		if nY == nUser //Pula o preenchimendo do campo Data de vencimento.
			fConvert("C7_XUSER",__cUserId, 'MODEL_SC7p')
			Loop
	/*	elseif nY == nDtEmi
			fConvert(aCabec[nY][1],dDataBase, 'MODEL_SC7p')
			Loop
		elseif nDtEmi == 0 .And. Empty(FwFldGet("C7_EMISSAO")) .And. !Empty(FwFldGet("C7_COND"))//Caso não seja passada a data de emissao
			fConvert("C7_EMISSAO",dDataBase, 'MODEL_SC7p')
			fConvert(aCabec[nY][1],aCabec[nY][2], 'MODEL_SC7p')
			Loop*/
		elseif nY == nDtVenc
			lAltDt := .T.				
			if !Empty(aCabec[nY][2])
				if Posicione("SA2",1,xFilial("SA2")+AllTrim(aCabec[nFornece][2])+AllTrim(aCabec[nLoja][2]),"A2_XDTFIX") == "1"
					if U_fVldEx()
						fConvert("C7_XDTEXCE", "Sim", 'MODEL_SC7p')				
					else
						lAltDt := .F.
					endif
				endif								
			endif			
			if lAltDt 
				fConvert(aCabec[nY][1], aCabec[nY][2], 'MODEL_SC7p')
			endif
			Loop
		elseif nY == nXRetec
			if aCabec[nXTipo][2] $ AllTrim(GetNewPar("FS_TPSP","CFR"))
				if !Empty(aCabec[nXRetec][2])
					aAreaX5 := GetArea()
					DbSelectArea("SX5")
					SX5->(DbSetOrder(1))				
					if !SX5->(DbSeek(xFilial("SX5")+PadR("37", TamSx3("X5_TABELA")[1])+PadR(aCabec[nXRetec][2], TamSx3("X5_CHAVE")[1]))) 
						aError := GravaLog(cFilAnt, aCabec[nDoc][2], aCabec[nSeri][2], aCabec[nFornece][2], "O código de retenção "+ aCabec[nXRetec][2] + " é inválido.")
						lErro := .T.
						restArea(aAreaX5)
						Exit
					else
						fConvert(aCabec[nY][1],aCabec[nY][2], 'MODEL_SC7p')
					endif
					restArea(aAreaX5)
				endif
			endif
		endif
		fConvert(aCabec[nY][1], aCabec[nY][2], 'MODEL_SC7p')
	next nY
	//fConvert("C7_XSERIE",aCabec[nSeri][2], 'MODEL_SC7p')

	if lErro
		Return aError
	endif

	for nX := 01 To Len(aItens)
		if nX > 1
			oModelGrid:AddLine()
		endif
		oModelGrid:GoLine(nX)
		for nA := 01 To Len(aItens[nX])
			if !Empty(oModel2:aErrorMessage[6])
				aError := GravaLog(cFilAnt, aCabec[nDoc][2], aCabec[nSeri][2], aCabec[nFornece][2])
				lErro := .T.
				Exit
			endif
			if aItens[nX][nA][1] == "C7_FILIAL"
				Loop
			endif
			fConvert(aItens[nX][nA][1],aItens[nX][nA][2], 'MODEL_SC7')
		next nA
		if lErro
			Exit
		endif
	next nX

	if lErro
		Return aError
	endif

	Begin Transaction
		//Valida dados.
		if oModel2:VldData()
			if oModel2:CommitData()
				ConfirmSx8()
			else
				RollBackSX8()
				DisarmTransaction()
			endif
			aError := GravaLog(cFilAnt,AllTrim(Fwfldget("C7_XDOC")),AllTrim(Fwfldget("C7_XSERIE")),AllTrim(Fwfldget("C7_FORNECE")))
		else
			aError := GravaLog(cFilAnt,AllTrim(Fwfldget("C7_XDOC")),AllTrim(Fwfldget("C7_XSERIE")),AllTrim(Fwfldget("C7_FORNECE")))
			lRetorno := .F.
			RollBackSX8()
			DisarmTransaction()
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
	case TamSx3(cCampo)[3] == "D" .And. valType(cConteudo) != "D"
		xConteudo := SToD(cConteudo)
	Case TamSx3(cCampo)[3] == "N" .And. valType(cConteudo) != "N"
		if At(',', cConteudo) > 0
			xConteudo := Val(StrTran(StrTran(cConteudo,".",""),",","."))//Val(cConteudo)
		else
			xConteudo := Val(cConteudo)
		endif
	Case TamSx3(cCampo)[3] == "L" .And. valType(cConteudo) != "L"
		xConteudo := iIf(AllTrim(FwFldGet(cCampo))=="F", .F., .T.)
	OtherWise
		xConteudo := cConteudo
	endcase
	oModel2:SetValue(cModelSC7, cCampo, xConteudo)
Return

Static function GravaLog(cFil, cDoc, cSerie, cFornece, cMsgCust)
	Local aError := {}
	Local nI := 0
	Local oGridModel := oModel2:GetModel("MODEL_SC7")
	Local nQtdLinhas := oGridModel:GetQtdLine()
	Default cFil := ""
	Default cDoc := ""
	Default cSerie := ""
	Default cFornece := ""
	Default cMsgCust := ""
	
	aGetError := oModel2:GetErrorMessage()
	if !Empty(cMsgCust)
		cText := "'"+AllTrim(cFil)+";'"+AllTrim(cDoc)+";'"+AllTrim(cSerie)+";'"+AllTrim(cFornece)+";;'"+AllTrim(cMsgCust)+ " - " + AllTrim(aGetError[2]) + ":" 
		aAdd(aError, cText)
		Return aError
	endif
	if !Empty(aGetError[6])
		cCmpCabec := U_RDCAR99A('MODEL_SC7p')
		if !(AllTrim(aGetError[2]) $ AllTrim(cCmpCabec))
			if Empty(aGetError[9])
				oGridModel:GoLine(1)
				For nI := 1 To nQtdLinhas //percorendo grid
					oGridModel:GoLine(nI)
					cGetErr := FwFldGet(AllTrim(aGetError[2]))
					if Empty(cGetErr)
						cGetErr := "O Item que está com problemas é o C7_ITEM: " + FwFldGet("C7_ITEM")
					endif
				next nI
			else
				cGetErr := AllTrim(aGetError[9])
			endif
		else
			cGetErr := AllTrim(aGetError[9])
		endif

		cMsgErro := SubStr(Replace(Replace(AllTrim(aGetError[6]), CRLF, ""), "  ", ""), 1, 60)
		if Empty(FwFldGet("C7_XSERIE"))
			cCampo := ""
		else
			cCampo := " " + AllTrim(aGetError[2])	+ ":"		
		endif
		cText := "'"+AllTrim(cFil)+";'"+AllTrim(cDoc)+";'"+AllTrim(cSerie)+";'"+AllTrim(cFornece)+";;'"+AllTrim(cMsgErro) + cCampo + AllTrim(cGetErr)
		aAdd(aError, cText )
	else
		cText := "'"+AllTrim(cFil)+";'"+AllTrim(Fwfldget("C7_XDOC"))+";'"+AllTrim(Fwfldget("C7_XSERIE"))+";'"+AllTrim(Fwfldget("C7_FORNECE"))+";'"+AllTrim(SC7->C7_NUM)+";Incluído com sucesso!"
		aAdd(aError, cText )
	endif
Return aError
