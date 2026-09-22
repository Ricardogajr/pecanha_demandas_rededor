#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'

/*
{Protheus.doc} F0100501()
Criação da tela inicial
@Author     Henrique Madureira
@Since      04/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_005
@Menu		 SIGATRM
@Return
*/
User Function F0100501()
	
	Local cSays1   := "Este programa realiza o processo de controle de presença dos participantes nos treinamentos definidos no plano de desenvolvimento "
	Local cSays2   := "individuais."
	Local cHelp    := OemToAnsi("Aten‡„o")
	Local cMsg     := OemToAnsi("Confirma configura‡„o dos parƒmetros?")
	Local cPerg    := "PRENAVDES"
	Local nOp      := 0
	
	Local oBtnEnd
	Local oBtnPergunte
	Local oBtnProcessa
	Local oSize
	
	Private oDlg
	Private cCadastro		:= "Controle de Presença nos cadastros"
	
	PergNew()
	Pergunte(cPerg, .F.)
	
	Begin Sequence
		
		oSize            := FwDefSize():New(.F.)
		oSize:AddObject( "CABECALHO", (650*1.1), (650*0.4) , .F., .F. ) // Não dimensionavel
		oSize:aMargins   := { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3
		oSize:lProp      := .F. // Proporcional
		oSize:Process()// Dispara os calculos
		
		DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From 0, 0 TO (650*0.4), (650*1.1) OF oMainWnd PIXEL
		
		oDlg:lEscClose   := .F. // Nao permite sair ao se pressionar a tecla ESC.
		
		@ oSize:GetDimension("CABECALHO", "LININI") + 03 , oSize:GetDimension("CABECALHO", "COLINI") + 03	GROUP oGroup TO oSize:GetDimension("CABECALHO", "LINEND") * 0.49471 , oSize:GetDimension("CABECALHO", "COLEND") * 0.5   LABEL "" OF oDlg PIXEL
		@ oSize:GetDimension("CABECALHO", "LININI") + 20 , oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY cSays1 Of oDlg Pixel
		@ oSize:GetDimension("CABECALHO", "LININI") + 27 , oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY cSays2 Of oDlg Pixel
		
		oBtnPergunte	:= TButton():New( oSize:GetDimension("CABECALHO", "LINEND") * 0.412 , 90 , "&" + "Parametros", NIL, {|| Pergunte(cPerg, .T.)} 										, 040 , 012 , NIL , NIL , NIL , .T. )	// "Parametros"
		oBtnProcessa	:= TButton():New( oSize:GetDimension("CABECALHO", "LINEND") * 0.412 , 140 , "P" + "&" + "rocessa", NIL, {|| IIF(MsgYesNo(cMsg, cHelp), oDlg:End(), NIL), nOp := 1 }	, 040 , 012 , NIL , NIL , NIL , .T. )	// "Processar"
		oBtnEnd			:= TButton():New( oSize:GetDimension("CABECALHO", "LINEND") * 0.412 , 190 , "&" + "Sair", NIL, { || oDlg:End() }														, 040 , 012 , NIL , NIL , NIL , .T. )	// "Sair"
		
		ACTIVATE DIALOG oDlg CENTERED
		
		If nOp == 1
			Processa({|| ProcPerg()}, "Aguarde...")
		EndIf
		
	End Sequence
	
Return
/*
{Protheus.doc} PergNew()
Cria pergunte
@Author     Henrique Madureira
@Since      04/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_005
@Return
*/
Static Function PergNew()
	
	Local aHelpPor  := {}
	Local cPerg     := "PRENAVDES"
	Local cStringP  := ""
	
	AAdd( aHelpPor, "Selecione a filial desejada" )
	cStringP := "Filial ? "
	
	aHelpPor :={}
	AAdd( aHelpPor, "Selecione a Matricula" )
	cStringP := "Matricula ? "
	
	aHelpPor :={}
	AAdd( aHelpPor, "Selecione o Calendario desejado" )
	cStringP := "Calendário ? "
	
	aHelpPor :={}
	AAdd( aHelpPor, "Selecione o curso desejado" )
	cStringP := "Curso ? "
	
	aHelpPor :={}
	AAdd( aHelpPor, "Selecione o periodo desejado" )
	cStringP := "Periodo ? "
	
Return

/*
{Protheus.doc} ProcPerg()
Processa informações para a gravação da nota e da data de termino do treinamento
@Author     Henrique Madureira
@Since      05/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_005
@Return
*/
Static Function ProcPerg()
	
	Local aArea    := GetArea()
	Local aAreaRdj := RDJ->(GetArea())
	Local aAtua    := {}
	Local cArq     := ""
	Local cFil     := ""
	Local cMatri   := ""
	Local cCurso   := ""
	Local cTreina  := ""
	Local cPerg    := "PRENAVDES"
	Local cWhere   := ""
	Local cMsg     := ""
	Local cPeriod  := ""
	Local lRet     := .F.
	Local nTmCurs  := TAMSX3("RDJ_CURSO")[1]
	Local nCnt     := 0
	
	MakeSqlExpr( cPerg )
	
	cFil    := MV_PAR01
	cMatri  := MV_PAR02
	cCurso  := MV_PAR03
	cTreina := MV_PAR04
	cPeriod := MV_PAR05
	
	If !Empty(cFil)
		cWhere += cFil + " AND "
	EndIf
	
	If !Empty(cMatri)
		cWhere += cMatri + " AND "
	EndIf
	
	If !Empty(cCurso)
		cWhere += cCurso + " AND "
	EndIf
	
	If !Empty(cTreina)
		cWhere += cTreina + " AND "
	EndIf
	
	cWhere		:= "%" + cWhere + "%"
	
	cArq := "FSW00510"
	BeginSql alias cArq
		
		%noparser%
		
		SELECT DISTINCT RD0.RD0_CODIGO, RA4.RA4_NOTA, RA4.RA4_DATAIN, RA4.RA4_CURSO, RA4.RA4_VALIDA
		FROM 	%table:RA4% RA4, %table:RD0% RD0, %table:SRA% SRA, %table:RA2% RA2, %table:RA1% RA1
		WHERE	%exp:cWhere%
		SRA.RA_MAT = RA4.RA4_MAT AND
		SRA.RA_CIC = RD0.RD0_CIC
		
	EndSql
	
	While !((cArq)->(Eof()))
		AAdd(aAtua, {(cArq)->RD0_CODIGO, (cArq)->RA4_NOTA, (cArq)->RA4_CURSO, (cArq)->RA4_DATAIN, (cArq)->RA4_VALIDA })
		(cArq)->(DbSkip())
	End
	
	(cArq)->(DbCloseArea())
	ProcRegua(len(aAtua))
	cDtPeriIn := DtoS(Posicione("RDU", 1, xFilial("RDU") + cPeriod, "RDU_DATINI"))
	cDtPeriFi := DtoS(Posicione("RDU", 1, xFilial("RDU") + cPeriod, "RDU_DATFIM"))
	If Len(aAtua) != 0
		For nCnt := 1 To Len(aAtua)
			IncProc()
			RDJ->(dbOrderNickName("FSWDJ"))
			If RDJ->(DbSeek(xFILIAL("RDJ") + aAtua[nCnt][1] + aAtua[nCnt][3]))
				cItmObj := xFilial("RDJ") + aAtua[nCnt][1] + PADR(aAtua[nCnt][3], nTmCurs) + cPeriod
				While RDJ->(!(EOF())) .AND. RDJ->(RDJ_FILIAL + RDJ_CODPAR + RDJ_CURSO + RDJ_PERIODO) == cItmObj
					If aAtua[nCnt][4] >= cDtPeriIn  .AND. aAtua[nCnt][4] <= cDtPeriFi
						RecLock("RDJ", .F.)
						RDJ->RDJ_XDTFIM := StoD(aAtua[nCnt][5])
						RDJ->RDJ_XNTAVL := aAtua[nCnt][2]
						RDJ->(MsUnlock())
						lRet := .T.
					EndIf
					RDJ->(DbSkip())
				End
			EndIf
		Next
		If lRet
			cMsg := "Alterado com sucesso!"
		Else
			cMsg := "Registros não alterados! Verifique os paramêtros!"
		EndIf
	Else
		cMsg := "Não foi encontrado registro! Verifique os paramêtros!"
	EndIf
	
	Help( , , 'HELP', , "Alterado com sucesso!", 1, 0)
	
	RestArea(aAreaRdj)
	RestArea(aArea)
	
Return
