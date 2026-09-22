#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function XVLDRV300(oobj)

	Local aArea := GetArea()
	Local nY := 01
	Local nZ := 01
	Local aMasters := {}
	Local lIgnora := .F.

	Public _lAprovalCT := ""

	Default ooBj := NIL

	If oobj:GetValue( "CN9MASTER", "CN9_TIPREV") <> "002"
		_lAprovalCT := .T.
		Return
	EndIf

	AADD(aMasters,"CN9MASTER")
	AADD(aMasters,"CNADETAIL")
	AADD(aMasters,"CXODETAIL")

	For nY := 01 To Len(aMasters)
		If lIgnora
			Exit
		EndIf

		If aMasters[nY] == "CNADETAIL"
			DbSelectArea("CNA")
			DbSetOrder(1)
			CNA->(DbSeek(oobj:GetValue( aMasters[nY], "CNA_FILIAL")+oobj:GetValue( aMasters[nY], "CNA_CONTRA")+oobj:GetValue( aMasters[nY], "CNA_REVISA")+oobj:GetValue( aMasters[nY], "CNA_NUMERO")))
		EndIf

		If aMasters[nY] == "CXODETAIL"
			DbSelectArea("CXO")
			DbSetOrder(1)
			CXO->(DbSeek(oobj:GetValue( aMasters[nY], "CXO_FILIAL")+oobj:GetValue( aMasters[nY], "CXO_CONTRA")+oobj:GetValue( aMasters[nY], "CXO_NUMMED")+oobj:GetValue( aMasters[nY], "CXO_REVISA")+oobj:GetValue( aMasters[nY], "CXO_NUMPLA")+oobj:GetValue( aMasters[nY], "CXO_ITEM")))
		EndIf
		For nZ := 01 To Len(oObj:GetModel(aMasters[nY]):GetStruct():afields)
			If Right(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3],7) == "_FILIAL"
				Loop
			EndIf
			If Right(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3],7) == "_FILORI"
				Loop
			EndIf
			If Right(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3],6) == "_DTFIM"
				Loop
			EndIf
			If Right(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3],6) == "_DTREV"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_REVISA"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_CODJUS"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_SITUAC"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CNA_DESCRI"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CNA_SADISC"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CNA_SADIST"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CNA_XTABPC"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CXO_ITEM"
				Loop
			EndIf
			If oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_UNVIGE"
				Loop
			EndIf

			If (oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_VIGE" .Or. oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_JUSTIF" .Or. oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_TIPREV")
				If (oobj:GetValue( aMasters[nY], oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3]) <> (Left(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3],3))->&(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3]) .And. oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3] == "CN9_VIGE")
					If Empty(_lAprovalCT)
						_lAprovalCT := .F.
					EndIf
				EndIf
			Else
				If oobj:GetValue( aMasters[nY], oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3]) <> (Left(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3],3))->&(oObj:GetModel(aMasters[nY]):GetStruct():afields[nZ][3])
					_lAprovalCT := .T.
					lIgnora := .T.
					Exit
				EndIf
			EndIf
		Next nZ
	Next nY

	If Type("_lxAltAIB") != "U"
		If _lxAltAIB
			_lAprovalCT := .T.
			_lxAltAIB := .F.
		EndIf
	EndIf

	If ValType(_lAprovalCT) == "C"
		_lAprovalCT := .F.
	EndIf

	RestArea(aArea)
Return _lAprovalCT



User Function XXFORNAIB(nRecAIB)

	Local cForn := CNA->CNA_FORNEC
	Local cLoja := CNA->CNA_LJFORN
	Local cFilc := CNA->CNA_FILIAL
	Local cTab := CNA->CNA_XTABPC
	Local cUpd := " "


	DbSelectArea("AIB")
	AIB->(DbSetOrder(1))

	If AIB->(DbSeek(cFilc+"        "+cTab))

		cUpd := " UPDATE " + RETSQLNAME("AIB") + " SET AIB_CODFOR = '"+CFORN+"', AIB_LOJFOR = '"+CLOJA+"' "
		cUpd += " WHERE D_E_L_E_T_ = ' ' AND AIB_FILIAL = '"+cFilc+"' AND AIB_CODTAB = '"+CTAB+"' AND AIB_CODFOR = ' ' "

		TCSqlExec(cUpd)
	EndIf

	AIB->(DbGoto(nRecAIB))
Return
