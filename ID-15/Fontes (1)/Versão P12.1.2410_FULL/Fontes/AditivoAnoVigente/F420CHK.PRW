#Include "Protheus.ch"
#Include "Totvs.ch"
#INCLUDE "FINA420.CH"


User Function F420CHK()

	Local nRetorno := 1
	Local nTecla := 1
	Local cFilBor := SE2->E2_FILIAL
	Local nX := 0
	Local oDlg, oRad

	If TYPE("lTela") <> "L"
		Public lTela := .F.
	EndIf
	If Type("cBor") <> "C"
		Public cBor := ""
	EndIf
	If Type("nLastn") <> "N"
		Public nLastn := 0
	EndIf

	If cBor <> SE2->E2_NUMBOR
		lTela := .F.
	EndIf

	If lTela
		Return nLastn
	EndIf

	If !IsBlind()
		If SE2->E2_NUMBOR >= MV_PAR01 .and. SE2->E2_NUMBOR <= MV_PAR02
			dbSelectArea("SEA")
			If (dbSeek(cFilBor+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+;
					SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
				If SEA->EA_TRANSF == "S" .and. SEA->EA_FILORIG == SE2->E2_FILORIG
					//nX := ASCAN(aBordero,SubStr(SE2->E2_NUMBOR,1,6))
					If nX == 0
						nOpc := 1
						DEFINE MSDIALOG oDlg FROM  35,   37 TO 188,383 TITLE OemToAnsi(STR0008) PIXEL  //"Bordero Existente"
						@ 11, 7 SAY OemToAnsi(STR0009) SIZE 58, 7 OF oDlg PIXEL  //"O border“ n£mero:"
						@ 11, 68 MSGET SE2->E2_NUMBOR When .F. SIZE 37, 10 OF oDlg PIXEL
						@ 24, 7 SAY OemToAnsi(STR0010) SIZE 82, 7 OF oDlg PIXEL  //"j  foi enviado ao banco."
						@ 37, 6 TO 69, 120 LABEL OemToAnsi(STR0011) OF oDlg  PIXEL  //"Para prosseguir escolha uma das op‡äes"
						@ 45, 11 RADIO oRad VAR nTecla 3D SIZE 75, 11 PROMPT OemToAnsi(STR0012),OemToAnsi(STR0013) OF oDlg PIXEL  //"Gera com esse border“"###"Ignora esse border“"
						DEFINE SBUTTON FROM 11, 140 TYPE 1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
						DEFINE SBUTTON FROM 24, 140 TYPE 2 ENABLE OF oDlg Action (nopc:=0,oDlg:End())
						ACTIVATE MSDIALOG oDlg Centered
						If nOpc == 1
							If nTecla == 1
								nRetorno := 1
							Else
								nRetorno := 2
							EndIf
						Else
							nRetorno := 3
						EndIf
						//Else
						//	nRetorno := Int(Val(SubStr(aBordero[nX],7,1)))
					Endif
				Endif
			Endif
		Endif
	EndIf


	lTela := .T.
	cBor := SE2->E2_NUMBOR
	nLastn := nRetorno

Return nRetorno
