#INCLUDE "PROTHEUS.CH"
#INCLUDE "CDV.CH"

// data da última atualização realizada
#DEFINE CDV_LASU_UPDATED 	"01/04/2011"

Static lFWCodFil := FindFunction("FWCodFil")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDV       ³ Autor ³ Pedro Pereira Lima    ³ Data ³31/03/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de ambiente para o RNCDV           ³±±
±±³          ³ utilizando gestão corporativa.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV - Gestão Corporativa                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CDVGCorp()
	Local aAreaSX3   := SX3->(GetArea())
	Local aSM0		 := AdmAbreSM0()

	PRIVATE aArqUpd  := {}
	PRIVATE aREOPEN  := {}

//	#IFDEF TOP
	TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top
//	#ENDIF

	cMens := STR0001 + CRLF + STR0002 + CRLF + STR0003 + CRLF + STR0004

	If Aviso(STR0005 + " " + CDV_LASU_UPDATED, cMens, {STR0006, STR0007}, 3) == 1
		//  continua apenas se usuario autorizar criacao no SX3
		Processa({|lEnd| CDVProc(@lEnd)}, STR0008, STR0009, .F.)
	EndIf

	RestArea(aAreaSX3)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDVProc   ³ Autor ³ Pedro Pereira Lima    ³ Data ³31/03/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV - Gestão Corporativa                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CDVProc(lEnd)
	Local cTexto	:= ''
	Local cFile		:= ""
	Local cMask		:= STR0010 + " (*.txt)|*.txt|"
	Local nX		   := 0
	Local nInc		:= 0
	Local aSM0		:= AdmAbreSM0()

	ProcRegua(1)
	IncProc(STR0011)

	For nInc := 1 To Len( aSM0 )
		RpcSetType(3)
		RpcSetEnv( aSM0[nInc][1], aSM0[nInc][2] )

		RpcClearEnv()
		CDVOpenSm0(.F.)
	Next

	For nInc := 1 To Len( aSM0 )
		RpcSetType(3)
		RpcSetEnv( aSM0[nInc][1], aSM0[nInc][2] )

		cTexto += Replicate("-", 128) + CRLF
		cTexto += STR0012 + ": " + aSM0[nInc][1] + " " + STR0013 + ": " + aSM0[nInc][2] + "-" + aSM0[nInc][6] + CRLF

		// atualiza o dicionario de dados
		IncProc(STR0014)
		cTexto += CDVAtuSX3()

		__SetX31Mode(.F.)
		For nX := 1 To Len(aArqUpd)
			IncProc(STR0015 + CRLF + aArqUpd[nx])
			If Select(aArqUpd[nx])>0
				dbSelecTArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
			X31UpdTable(aArqUpd[nx])
			If __GetX31Error()
				Alert(__GetX31Trace())
				Aviso(STR0001, STR0016 + ": " + aArqUpd[nx] + ". " + STR0017, {STR0018},2)
				cTexto += STR0019 + ": " + aArqUpd[nx] + CRLF
			EndIf
		Next nX

		RpcClearEnv()
		CDVOpenSm0(.F.)
	Next

	RpcSetEnv( aSM0[1][1], aSM0[1][2],,,,, { "AE1" } )

	cTexto := STR0020 + " - " + CDV_LASU_UPDATED + CRLF + cTexto
	__cFileLog := MemoWrite(Criatrab(, .F.) + ".log", cTexto)
	DEFINE FONT oFont NAME "Courier New" SIZE 8, 15
	DEFINE MSDIALOG oDlg TITLE STR0021 From 3,0 to 340,417 PIXEL
	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL READONLY
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDVAtuSX3 ³ Autor ³ Pedro Pereira Lima    ³ Data ³01/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX3                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV - Gestão Corporativa                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CDVAtuSX3()
	Local lSX3     := .F.
	Local cTexto   := ''
	Local cAlias   := ''
	Local nTamFilial:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )

	If CDVX3Field("LDY_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LDY"
		aAdd(aArqUpd, "LDY")
	EndIf

	If CDVX3Field("LHP_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LHP"
		aAdd(aArqUpd, "LHP")
	EndIf

	If CDVX3Field("LHQ_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LHQ"
		aAdd(aArqUpd, "LHQ")
	EndIf

	If CDVX3Field("LHR_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LHR"
		aAdd(aArqUpd, "LHR")
	EndIf

	If CDVX3Field("LHS_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LHS"
		aAdd(aArqUpd, "LHS")
	EndIf

	If CDVX3Field("LHT_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LHT"
		aAdd(aArqUpd, "LHT")
	EndIf

	If CDVX3Field("LJ3_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LJ3"
		aAdd(aArqUpd, "LJ3")
	EndIf

	If CDVX3Field("LJ8_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LJ8"
		aAdd(aArqUpd, "LJ8")
	EndIf

	If CDVX3Field("LJH_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LJH"
		aAdd(aArqUpd, "LJH")
	EndIf

	If CDVX3Field("LJI_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LJI"
		aAdd(aArqUpd, "LJI")
	EndIf

	If CDVX3Field("LJJ_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LJJ"
		aAdd(aArqUpd, "LJJ")
	EndIf

	If CDVX3Field("LJL_FILIAL","X3_TAMANHO",getTamSXG("033",nTamFilial)[1])
		lSX3 := .T.
		cAlias += "/LJL"
		aAdd(aArqUpd, "LJL")
	EndIf

	ProcRegua(Len(cAlias))

	If lSX3
		cTexto := STR0022 + " " + cAlias + CRLF
	EndIf

Return cTexto

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpdRNCDV  ³ Autor ³ Pedro Pereira Lima    ³ Data ³ 31/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV - Gestão Corporativa                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UpdRNCDV()

	cArqEmp := "SigaMat.Emp"
	nModulo		:= 06
	__cInterNet := Nil 

	PRIVATE aArqUpd	 := {}
	PRIVATE aREOPEN	 := {}
	Private __lPyme    := .F.

	#IFDEF TOP
	TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top
	#ENDIF

	Set Dele On

	CDVOpenSM0(.T.)
	DbGoTop()

	lHistorico 	:= MsgYesNo(STR0023 + "v. " + CDV_LASU_UPDATED + "? " + STR0024, STR0001)

	DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE STR0025

	ACTIVATE WINDOW oMainWnd ICONIZED ;
	ON INIT If(lHistorico,(Processa({|lEnd| CDVProc(@lEnd)}, STR0026, STR0027, .F.), oMainWnd:End()), oMainWnd:End())

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDVX3FIELD³ Autor ³ Pedro Pereira Lima    ³ Data ³ 31/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza um determinado campo do SX3                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cField      - campo do Protheus a ser atualizado           ³±±
±±           ³ cSX3Field   - campo do SX3 a ser atualizado                ³±±
±±           ³ uNewValue   - novo valor a ser gravado                     ³±±
±±           ³ uTestValue  - valor de teste                               ³±±
±±           ³ bBlockValue - bloco de teste (opcional - nao implementado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CDVX3Field(cField, cSX3Field, uNewValue, uTestValue, bBlockValue)
Return CDVUpdField("SX3", 2, cField, cSX3Field, uNewValue, uTestValue, bBlockValue)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDVXFIELD ³ Autor ³ Pedro Pereira Lima    ³ Data ³ 31/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza um determinado campo de uma tabela                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias      - alias da tabela a ser atualizada             ³±±
±±           ³ cIndexKey   - índice de pesquisa utilizado                 ³±±
±±           ³ cField      - campo a ser atualizado                       ³±±
±±           ³ uNewValue   - novo valor a ser gravado                     ³±±
±±           ³ uTestValue  - valor de teste                               ³±±
±±           ³ bBlockValue - bloco de teste (opcional - nao implementado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T., se a gravação foi bem sucedida                        ³±±
±±³          ³ .F., caso contrário                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CDVXField(cAlias, cIndexKey, cField, uNewValue, uTestValue, bBlockValue)
Return CDVUpdField(cAlias, 1, cIndexKey, cField, uNewValue, uTestValue, bBlockValue)

User Function CDVUpdField(cAlias, nOrder, cIndexKey, cField, uNewValue, uTestValue, bBlockValue)
	Local aArea       := (cAlias)->(GetArea())
	Local lRet        := .F.
	Local nFieldPos   := 0
	Local aStruct     := {}
	Local nPosField   := 0
	Local uValueField := 0

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(nOrder))

	// verifica se o registro existe no alias
	If !(cAlias)->(dbSeek(cIndexKey))
		RestArea(aArea)
		Return lRet
	EndIf

	// verificar se o campo existe no alias
	nFieldPos := (cAlias)->(FieldPos(cField))

	If nFieldPos == 0
		RestArea(aArea)
		Return lRet
	EndIf

	aStruct := (cAlias)->(dbStruct())
	nPosFIELD := aScan( aStruct ,{|aField|Alltrim(Upper(aField[1])) == Alltrim(Upper(cField)) } )
	uValueField := (cAlias)->(FieldGet(nFieldPos))

	If bBlockValue == Nil

		// teste por valor
		If uTestValue == Nil

			If nPosFIELD >0
				If aStruct[nPosFIELD][2] == "C"
					uValueField := AllTrim(uValueField)
					uTestValue  := AllTrim(uNewValue)
				EndIf
			EndIf

			// Somente atualiza se o valor gravado no campo (uValueField) for diferente do novo valor (uNewValue)
			lRet := !(uValueField == uTestValue)

			If lRet
				RecLock(cAlias, .F.)
				(cAlias)->(FieldPut(nFieldPos, uNewValue))
				MsUnlock()
			EndIf

			RestArea(aArea)

		Else

			If nPosFIELD >0
				// se for caracter deve retirar os brancos e maiusculas antes de comparar.
				If aStruct[nPosFIELD][2] == "C"
					uValueField := AllTrim(Upper(uValueField))
					uTestValue  := AllTrim(Upper(uTestValue))
				EndIf
			EndIf

			// se o teste existe, testa e altera o valor
			If uTestValue == uValueField
				RecLock(cAlias, .F.)
				(cAlias)->(FieldPut(nFieldPos, uNewValue))
				MsUnlock()

				RestArea(aArea)
				lRet := .T.
			EndIf
		EndIf
	Else
		// teste por bloco - nao implementado
	EndIf

	RestArea(aArea)
Return lRet

User Function UPDCDV()
	UPDRNCDV()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDVOpenSM0 ³ Autor ³ Pedro Pereira Lima   ³ Data ³31/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV - Gestão Corporativa                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CDVOpenSM0(lShared)
	Local lOpen := .F.
	Local i := 0

	//For i := 1 To 20
	//	
	//	dbUseArea(.T. ,,"SIGAMAT.EMP" ,"SM0" ,lShared ,.F.)
	//	
	//	If !Empty(Select("SM0"))
	//		lOpen := .T.
	//		dbSetIndex("SIGAMAT.IND")
	//		Exit
	//	EndIf
	//	Sleep(500)
	//Next i

Return lOpen

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Pedro Pereira Lima    ³ Data ³ 31/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
	Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
			IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
			"",;
			"",;
			"",;
			SM0->M0_NOME,;
			SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³getTamSXG ³ Autor ³ Pedro Pereira Lima    ³ Data ³ 31/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o tamanho do grupo de campo 033 	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RNCDV - Gestão Corporativa                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getTamSXG( cGrupo, nTamPad )
	Local aRet


//	nTamPad	:= SXG->XG_SIZE
//	aRet := { nTamPad, "@!", nTamPad, nTamPad }
//	Else
//		aRet := { nTamPad, "@!", nTamPad, nTamPad }
//	EndIf




	cQry1 := " SELECT XG_SIZE AS XGSIZE "
	cQry1 += " FROM "+RetSqlName("SXG") + " XG "
	cQry1 += " WHERE XG_GRUPO  =  ' " + cGrupo+  "' "
	cQry1 += " AND .D_E_L_E_T_ = '' "

	//TcQuery cQry1 New Alias "TMP1"
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry1),"TMPsxg")


	DbSelectArea( "SXG" )
	SXG->( DbSetOrder( 1 ) ) 
	If SXG->( DbSeek( cGrupo ) )


		nTamPad	:= TMPsxg->XGSIZE
		aRet := { nTamPad, "@!", nTamPad, nTamPad }
	ELSE
		aRet := { nTamPad, "@!", nTamPad, nTamPad }

	ENDIF





Return aRet
