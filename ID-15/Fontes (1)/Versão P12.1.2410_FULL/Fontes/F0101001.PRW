#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDef.ch"
#Include "RwMake.ch"

/* 
{Protheus.doc} F010101A()
Exibe tela de justificativa e grava a Recusa.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/

User Function F010101A(lRecuAut, cMsgRecAuto, lMat)
	Private cMsgAuto := ""
	Default lRecuAut := .F.
	Default cMsgRecAuto := "" 
	Default lMat := .F.

	if valtype(lRecuAut) != "L"
		lRecuAut := .F.
		cMsgRecAuto := ""
	endif

	if valtype(lMat) != "L"
		lMat >= .F.
	endif

	cMsgAuto := cMsgRecAuto
	If IsInCallStack("MATA103") .or. IsInCallStack("U_F0100401") .or. IsInCallStack("U_S0100401")   .Or. lRecuAut
		If U_F010101C(lRecuAut, lMat)
			SF1->(Reclock("SF1",.F.))
			SF1->F1_XSTRECU := "R"
			SF1->F1_XDTRECU := dDatabase

			IF EMPTY(SF1->F1_XDTRECP)
				SF1->F1_XDTRECP := dDataBase
			ENDIF

			SF1->(MsUnlock())
		EndIf
	Else
		If !Empty(SE2->E2_DATALIB)
			U_F010101B()
			Return
		Else
			U_F010101C(lRecuAut, lMat)
		EndIf
	EndIf

Return

/*
{Protheus.doc} F010101B()
Exibe Mensagem: “Apenas títulos Bloqueados poderão ser Recusados”
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/

User Function F010101B()

	Help("", 1, "F010101B", , "Apenas títulos Bloqueados poderão ser Recusados", 1, 0, , , , , , {""})

Return

/*
{Protheus.doc} F010101C()
Exibe tela de justificativa e confirmação de recusa.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/

User Function F010101C(lRecuAut, lMat)

	Local oButton1
	Local oButton2
	Local oGroup1
	Local oGroup2
	Local oSay01
	Local oSay02
	Local oSay03
	Local oSay04
	Local oSay05
	Local oSay06
	Local oSay07
	Local oSay08
	Local oSay09
	Local cIdEmit	 := ""
	Local cEmailEmit := ""
	Local cNomeEmit  := ""
	Local cNomeRecu  := ""
	Local cEmailRec  := ""
	Local cIDRecusa  := ""

	Local oDlg
	Local oGet01
	Local oGet02
	Local oGet03
	Local oGet04
	Local oGet05
	Local oGet06
	Local oGet07
	Local oGet08
	Local oGet09
	Local oGet10
	Local oGet11
	Local oGet12
	Local oMemo1

	Local cGet01 := ""
	Local cGet02 := ""
	Local cGet03 := ""
	Local nGet04 := ""
	Local cGet05 := ""
	Local cGet06 := ""
	Local cGet07 := ""
	Local cGet08 := ""
	Local cGet09 := ""
	Local cGet10 := ""
	Local cGet11 := ""
	Local cMemo1 := ""

	Local lRetorno      := .F.
	Local cTituloTela   := "Recusa de Título"
	Local cDetalhesTela := "Detalhes (Título a Pagar)"
	Local cPrefixo      := ""
	Local cOrigem       := ""
	Local cLojaF        := ""

	Local cMailGenFil := SuperGetMV("FS_MAILREC")

	Default lRecuAut := .F.
	Default lMat := .F.

	If OrigemNFEntrada(lRecuAut)
		If !SolicitacaoPagamentoAutorizada()
			Return
		EndIf

		if !lRecuAut
			If NotaClassificada() .and. !FwIsInCallStack("U_RDSCHREC")
				Help("", 1, "F010101A", , "A recusa não pode ser realizada em documento de entrada já classificado.", 1, 0, , , , , , {""})
				Return
			EndIf
		endif

		If !PermiteRecusa(.T.)
			Return
		EndIf

		cGet00 := SF1->F1_FILIAL
		cGet01 := SF1->F1_DOC
		cGet02 := "NF"
		cGet03 := "-"
		nGet04 := ValorNotaFiscal()
		cGet05 := dDatabase
		cGet06 := SF1->F1_FORNECE + SF1->F1_LOJA
		If SF1->F1_TIPO $ "D/B"
			cGet07 := Posicione("SA1",1,XFilial("SA1")+SF1->(F1_FORNECE+F1_LOJA),"A1_NOME")
		Else
			cGet07 := Posicione("SA2",1,XFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA),"A2_NOME")
		EndIf
		cLojaF        := SF1->F1_LOJA
		cPrefixo      := SF1->F1_SERIE

//------[ gus ]-----------------------------
//		cIdEmit       := DescobreEmitente()
//------------------------------------------		
		cIdEmit       := AchaEmitente()
//------------------------------------------

		cOrigem       := "MATA100"
		cTituloTela   := "Recusa de Documento de Entrada"
		cDetalhesTela := "Detalhes (Documento de Entrada)"
	Else

		If !PermiteRecusa(.F.)
			Return
		EndIf

		cGet00   := SE2->E2_FILIAL
		cGet01   := SE2->E2_NUM
		cGet02   := SE2->E2_TIPO
		cGet03   := SE2->E2_PARCELA
		nGet04   := SE2->E2_VALOR
		cGet05   := SE2->E2_VENCREA
		cGet06   := SE2->E2_FORNECE + If(!Empty(SE2->E2_LOJA),"/" , " ") + SE2->E2_LOJA
		cGet07   := SE2->E2_NOMFOR
		cLojaF   := SE2->E2_LOJA
		cPrefixo := SE2->E2_PREFIXO
		If SE2->E2_XCLAUT == "1"
			cIdEmit       := AchaEmitente()
		Else
			cIdEmit  := SUBS(Embaralha(SE2->E2_USERLGI,01),03, 06)
		EndIf
		cOrigem  := SE2->E2_ORIGEM
		If SE2->E2_XSTRECU == "R" .And. !IsInCallStack("U_F010101PCANCELARECUSA")
			Help(' ',1,"F010100150" ,,"O status do título é: R - Recusado. Não será processada a recusa.",2,0,,,,,, {""})
			Return
		EndIf
	EndIf


	If !Empty(cIdEmit)
		PSWORDER(01)
		If (PSWSEEK(cIdEmit))
			cEmailEmit	:= Alltrim(PSWRET()[01][14])
			cNomeEmit	:= Alltrim(PSWRET()[01][04])
		EndIf
		cGet08 := cIdEmit
		cGet09 := cNomeEmit
	ElseIf !Empty(cMailGenFil)
		cEmailEmit := cMailGenFil
		cGet08 := cIdEmit := "000000"
		cGet09 := cNomeEmit := "INTEGRAÇÃO FILIAL: " + cFilAnt
	EndIf

	If Empty(cIdEmit)
		Help(' ',1,"F010100151" ,,"Emitente não identificado. Não será processada a recusa.",2,0,,,,,, {""})
		Return
	EndIf

	/*==============================================================|
	|Captura recusante.                                              |
	|==============================================================*/
	if FwIsInCallStack("U_RDSCHREC") .Or. lRecuAut
		cIDRecusa := "000000"
	else
		cIDRecusa := RetCodUsr()
	endif

	PSWORDER(01)
	If (PSWSEEK(cIDRecusa))
		cEmailRec	:= Alltrim(PSWRET()[01][14])
		cNomeRecu	:= Alltrim(PSWRET()[01][04])
	EndIf
	cGet10 := cIDRecusa
	cGet11 := cNomeRecu
	if FwIsInCallStack("U_RDSCHREC") .Or.  lRecuAut
		lRetorno := U_F010101D(cGet01,cGet02,cGet03,cPrefixo,nGet04,SF1->F1_XDTVNF,cGet06,cGet07,cGet08,cGet09,cGet10,cGet11,cMsgAuto,dDatabase,cOrigem,cEmailEmit,cLojaF,cGet00,lRecuAut, lMat)
	else
		If Empty(cIDRecusa)
		Help(' ',1,"F010100152" ,,"Recusante não identificado. Não será processada a recusa.",2,0,,,,,, {""})
		Return
		EndIf
	
	DEFINE MSDIALOG oDlg TITLE cTituloTela FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL
	
	@ 000, 004 GROUP oGroup1 TO 211, 347 PROMPT cDetalhesTela OF oDlg COLOR 0, 16777215 PIXEL
	
	@ 021, 008 SAY	 oSay01 PROMPT	"Título" 	 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 032 MSGET oGet01 VAR		cGet01 	 	 SIZE 044, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 021, 088 SAY	 oSay02 PROMPT	"Tipo" 	 	 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 102 MSGET oGet02 VAR		cGet02 	 	 SIZE 022, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 021, 134 SAY	 oSay03 PROMPT	"Parcela"	 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 159 MSGET oGet03 VAR		cGet03 		 SIZE 016, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 021, 192 SAY	 oSay04 PROMPT	"Valor" 	 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 208 MSGET oGet04 VAR		nGet04 		 SIZE 051, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F. PICTURE "@E 9,999,999,999,999.99"
	@ 021, 266 SAY	 oSay05 PROMPT	"Vencimento" SIZE 029, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 301 MSGET oGet05 VAR		cGet05 		 SIZE 041, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 047, 008 SAY	 oSay06 PROMPT	"Fornecedor" SIZE 033, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 040 MSGET oGet06 VAR		cGet06 		 SIZE 048, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 047, 093 MSGET oGet07 VAR		cGet07 		 SIZE 249, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	
	@ 066, 008 SAY	 oSay07 PROMPT	"Emitente" 	 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 066, 040 MSGET oGet08 VAR		cGet08 		 SIZE 048, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 066, 093 MSGET oGet09 VAR		cGet09 		 SIZE 249, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	
	@ 082, 008 SAY	 oSay08 PROMPT	"Recusante"  SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 082, 040 MSGET oGet10 VAR		cGet10		 SIZE 047, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	@ 082, 093 MSGET oGet11 VAR		cGet11		 SIZE 249, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
	
	@ 107, 008 SAY	 oSay09 PROMPT	"Motivo" 	 SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 107, 040 GET   oMemo1 VAR     cMemo1 MEMO  SIZE 302, 100 OF oDlg COLORS 0, 16777215 PIXEL

	@ 215, 004 GROUP oGroup2 TO 249, 347 OF oDlg COLOR 0, 16777215 PIXEL
	@ 226, 233 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION oDlg:End()
	@ 226, 296 BUTTON oButton2 PROMPT "Ok" 		 SIZE 037, 012 OF oDlg PIXEL ACTION (lRetorno := U_F010101D(cGet01,;
																								cGet02         ,;
																								cGet03         ,;
																								cPrefixo       ,;
																								nGet04         ,;
																								cGet05         ,;
																								cGet06         ,;
																								cGet07         ,;
																								cGet08         ,;
																								cGet09         ,;
																								cGet10         ,;
																								cGet11         ,;
																								cMemo1         ,;
																								dDatabase      ,;
																								cOrigem        ,;
																								cEmailEmit,cLojaF,cGet00),oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	Endif
Return lRetorno

/*
{Protheus.doc} F010101D()
Grava informações da Recusa.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@param cFilOri, characters, descricao
@param cNumTit, characters, descricao
@param cTipo, characters, descricao
@param cParcela, characters, descricao
@param cPrefixo, characters, descricao
@param nValor, numeric, descricao
@param dVencrea, date, descricao
@param cFornece, characters, descricao
@param cNomFor, characters, descricao
@param cCodEmit, characters, descricao
@param cNomEmit, characters, descricao
@param cCodRecu, characters, descricao
@param cNomRecu, characters, descricao
@param cMotivo, characters, descricao
@param dData, date, descricao
@param cOrigem, characters, descricao
@param cEmailEmit, characters, descricao
@return lRet, indica se houve erro no envio do e-mail (o que resulta em rollback)
@Project    MAN00000462901_EF_010
*/

User Function F010101D(cNumTit,cTipo,cParcela,cPrefixo,nValor,dVencrea,cFornece,cNomFor,cCodEmit,cNomEmit,cCodRecu,cNomRecu,cMotivo,dData,cOrigem,cEmailEmit,cLojaF,cGet00,lRecuAut,lMat)

	Local cTipoDoc := " "
	Local cMensagem := "[CANCELAMENTO DE RECUSA]: "
//	Local cFilRec := cGet00
	Local lRet := .T.
	Local aArea := FWGetArea()
	Local lP12Simp := U_VALSIMP(cFilAnt)
	Local lRecSP   := .F.
	Default cLojaF := "01"
	Default lRecuAut := .F.
	Default lMat := .F.
	If IsInCallStack("MATA103") .or. IsInCallStack("U_F0100401") .or. IsInCallStack("U_S0100401") .Or. IsInCallStack("MATA094")// .Or.  IsInCallStack("U_RDSCHREC")
		cTipoDoc := "D"
		lRecSP := .T.
//		cFilRec := xFilial("SF1")
//	Else
//		cFilRec := xFilial("SE2")
	EndIf

	if lP12Simp
		if SE2->E2_XAPRVSP == "2"
			Alert("A solicitação de pagamento não foi aprovada e, portanto, não poderá ser recusada.")
			Return .F.
		endif
	endif

	If !IsInCallStack("U_F010101PCANCELARECUSA")
		cMensagem := ""
	EndIf
	if IsInCallStack("MATA094")
		cCodRecu := "000000"
	endif
	Begin Transaction
		P00->(RecLock("P00",.T.))
//		P00->P00_FILIAL := XFilial("P00")
		P00->P00_FILIAL := cGet00

		P00->P00_NUM	:= cNumTit
		P00->P00_PREFIX	:= cPrefixo
		P00->P00_VALOR	:= nValor
		P00->P00_XDTVEN	:= dVencrea
		P00->P00_FORNEC	:= cFornece
		P00->P00_LOJAF	:= cLojaF
		P00->P00_USREMI	:= cCodEmit
		P00->P00_USRREC	:= cCodRecu
		P00->P00_MOTIVO	:= cMensagem+cMotivo
		P00->P00_DTRECU	:= dData
		P00->P00_ORIGEM	:= cOrigem
		P00->P00_TIPO	:= cTipoDoc
		P00->(MsUnlock())

		if !lRecuAut //.Or. (lMat .And. lP12Simp)//Verifica se é simplificada.
			If !(cTipoDoc == "D")
				SE2->(RecLock("SE2",.F.))
				If  !IsInCallStack("U_F010101PCANCELARECUSA")
					SE2->E2_XDTRECU := dDatabase
					SE2->E2_XSTRECU := "R"
					SE2->E2_XAPRVSP := " "
					IF EMPTY(SE2->E2_XDTRECP)
						SE2->E2_XDTRECP := dDataBase
					ENDIF

				Else
					SE2->E2_XDTRECU := CToD("  /  /  ")
					SE2->E2_XSTRECU := " "
				EndIf
				SE2->(MsUnlock())
			EndIf
		EndIf

		//Verifica se houve erro no envio do e-mail, se sim, não grava os dados no titulo (rollback)
		// ticket n° 8096124 - inclusão parâmetro filial
		if !U_F0101004(cGet00,cNumTit,cTipo,cParcela,cPrefixo,nValor,dVencrea,cFornece,cNomFor,cCodEmit,cNomEmit,cCodRecu,cNomRecu,cMotivo,dData,cOrigem,cEmailEmit,lRecuAut)
			DisarmTransaction()
			lRet := .F.
		Else
			If !lRecuAut
				If (SE2->E2_XCLAUT == "1" .And. SE2->E2_XSTRECU == "R")
					MsgRun("Aguarde... Voltando status para pré-nota...",,{|| ExclClaut(SE2->(Recno())) } )
				endif
			EndIf
			/** Retirada do processo de exclusão do titulo
			if !lRecuAut .Or. lMat
				if (lRet .And. SE2->E2_XCLAUT <> "1")
					 
					MsgRun("Aguarde... Excluindo Título e Nota Fiscal...",,{|| ExcluiNota(SE2->(Recno())) } )
				endif
			endif			
			**/
		endif

	End Transaction

Return lRet

/*
{Protheus.doc} F010101G()
Consulta Recusas.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/
User Function F010101G()

	Local oButton1
	Local oGroup1
	Local oGroup2
	Local oDlg
	Local aWBrowse1 := {}
	Local cNomeTela := "Consulta Recusas do Título"

	local cChave // id 1521

	If OrigemNFEntrada()
		If !SolicitacaoPagamentoAutorizada()
			Return
		EndIf
//		cChave    := SF1->(             F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) // id 1521

		if SC7->C7_XTPSP $ "2|3|4|5" .And. IsInCallStack("U_F0100401") .Or. IsInCallStack("U_S0100401")
			cChave    := SC7->(C7_FILIAL+C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA) // id 1521
		else
			cChave    := SF1->( F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) // id 1521
		endif
		cNomeTela := "Consulta Recusas do Documento de Entrada"
	Else
//		cChave    := SE2->(             E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA ) // id 1521
		cChave    := SE2->( E2_FILIAL + E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA ) // id 1521
	Endif

	P00->(DbSetOrder(2)) // P00_FILIAL + P00_NUM + P00_PREFIX + P00_FORNEC + P00_LOJAF

//--[ ID 1521 ]------------------------------------------------------
//	P00->(DbSeek(XFilial("P00")+cChave))
//	While P00->(!Eof() .And. P00_FILIAL + P00_NUM + P00_PREFIX + P00_FORNEC + P00_LOJAF == XFilial("P00") + cChave)
//-------------------------------------------------------------------
	P00->(DbSeek( cChave ))
	do while P00->( !eof() .AND. P00_FILIAL + P00_NUM + P00_PREFIX + P00_FORNEC + P00_LOJAF == cChave )
//-------------------------------------------------------------------

		P00->(AAdd(aWBrowse1, {DtoC(P00_DTRECU), P00_NUM, Alltrim(UsrRetName(P00->P00_USRREC)), P00_MOTIVO}))
		P00->(dBSkip())
	End

	If Len(aWBrowse1) == 0
		Help("", 1, "F010101A", , "Não existe recusa para este documento!.", 1, 0, , , , , , {""})
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE cNomeTela FROM 000, 000  TO 400, 800 COLORS 0, 16777215 PIXEL
	@ 003, 004 GROUP oGroup1 TO 165, 397 OF oDlg COLOR 0, 16777215 PIXEL
	@ 167, 004 GROUP oGroup2 TO 196, 397 OF oDlg COLOR 0, 16777215 PIXEL

	@ 011, 009 LISTBOX oWBrowse1 Fields HEADER "Data Recusa", "Número do Título", "Usuário", "Motivo da Recusa" SIZE 381, 146 OF oDlg PIXEL ColSizes 50, 50
	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt, 1],;
		aWBrowse1[oWBrowse1:nAt, 2],;
		aWBrowse1[oWBrowse1:nAt, 3],;
		aWBrowse1[oWBrowse1:nAt, 4]}}
	@ 177, 351 BUTTON oButton1 PROMPT "Sair" SIZE 037, 012 OF oDlg PIXEL ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
{Protheus.doc} F010101I()
Manutenção de Anexos.
Nas manutenções (inclusões ou exclusões) de documentos
digitalizados anexos, verifica se existem Títulos a Pagar
Recusados vinculados à cadeia de relacionamento de tabelas.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@param cFilOri, characters, descricao
@param cRotina, characters, descricao
@param cCodOri, characters, descricao
@Project    MAN00000462901_EF_010
*/
User Function F010101I(cFilOri, cRotina, cCodOri)

	Local cTitulo    := ""
	Local cAlias01   := ""
	Local cAlias02   := ""
	Local cCompara   := ""
	Local cTPLPrefix := ""
	Local cTPLTipo   := ""
	Local cTPLParcel := ""
	Local cTPLFornec := ""
	Local cTPLLoja   := ""

	Private cRot := ""

	If cRotina == "FINA050" .Or. cRotina == "FINA750"  //Contas a Pagar
		cCompara := cFilOri + cCodOri
		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
			SELECT SE2.R_E_C_N_O_ AS SE2_RECNO
			FROM 	%Table:SE2% SE2
			WHERE 	SE2.%notDel%
			AND SE2.E2_FILIAL || SE2.E2_NUM || SE2.E2_PREFIXO || SE2.E2_FORNECE || SE2.E2_LOJA = %Exp:cCompara%
		EndSql
		While (cAlias01)->(!Eof())
			dBSelectArea("SE2")
			dBGoTo((cAlias01)->SE2_RECNO)
			If SE2->E2_XSTRECU == "R"
				Reclock("SE2",.F.)
				SE2->E2_XSTRECU := "C"
				SE2->E2_XDTRECU := dDataBase

				IF EMPTY(SE2->E2_XDTRECP)
					SE2->E2_XDTRECP := dDataBase
				ENDIF

				SE2->(MsUnlock())
			EndIf
			(cAlias01)->(dBSkip())
		EndDo
		If Select("cAlias01") > 0
			(cAlias01)->(dbCloseArea())
		EndIf

	ElseIf cRotina $ "MATA103|MATA140" //Nota/Pre Nota de Entrada

		cAlias01 := GetNextAlias()
		cCompara := cFilOri + cCodOri
		BeginSql Alias cAlias01
			SELECT SE2.R_E_C_N_O_ AS SE2_RECNO
			FROM %Table:SE2% SE2 INNER JOIN %Table:SF1% SF1  ON		SF1.F1_FILIAL	= SE2.E2_FILIAL
			AND	SF1.F1_DOC		= SE2.E2_NUM
			AND	SF1.F1_SERIE	= SE2.E2_PREFIXO
			AND	SF1.F1_FORNECE	= SE2.E2_FORNECE
			AND	SF1.F1_LOJA		= SE2.E2_LOJA
			WHERE 		SE2.%notDel%
			AND	SF1.%notDel%
			AND	SF1.F1_FILIAL || SF1.F1_DOC || SF1.F1_SERIE || SF1.F1_FORNECE || SF1.F1_LOJA = %Exp:cCompara%
			
		EndSql

		While (cAlias01)->(!Eof())
			dBSelectArea("SE2")
			dBGoTo((cAlias01)->SE2_RECNO)
			If SE2->E2_XSTRECU == "R"
				Reclock("SE2",.F.)
				SE2->E2_XSTRECU := "C"
				SE2->E2_XDTRECU := dDataBase
				SE2->(MsUnlock())

				IF EMPTY(SE2->E2_XDTRECP)
					SE2->E2_XDTRECP := dDataBase
				ENDIF

			EndIf
			(cAlias01)->(dBSkip())
		EndDo

		If Select("cAlias01") > 0
			(cAlias01)->(dbCloseArea())
		EndIf

		SF1->(dBSetOrder(01))
		If SF1->(dBSeek(cCompara))
			If SF1->F1_XSTRECU == "R"
				Reclock("SF1",.F.)
				SF1->F1_XSTRECU := "C"
				SF1->F1_XDTRECU := dDataBase

				IF EMPTY(SF1->F1_XDTRECP)
					SF1->F1_XDTRECP := dDataBase
				ENDIF

				SF1->(MsUnlock())
			EndIf

			U_XNCLAC(SF1->(RECNO()))
		EndIf

	ElseIf cRotina $ "MATA121|F0100401|S0100401" // Pedido de Compra/Solicitação de Pagamento
		cCompara := cFilOri + cCodOri
		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
			SELECT	SE2.R_E_C_N_O_	SE2_RECNO
			FROM %Table:SE2% SE2	INNER JOIN (SELECT DISTINCT	SD1.D1_FILIAL	  FILIAL	,
																SD1.D1_DOC		  DOC		,
																SD1.D1_SERIE	  SERIE		,
																SD1.D1_FORNECE	  FORNECE	,
																SD1.D1_LOJA		  LOJA
											 	FROM %Table:SC7% SC7 INNER JOIN %Table:SD1% SD1 ON		SD1.D1_FILIAL = SC7.C7_FILIAL
																									AND	SD1.D1_PEDIDO = SC7.C7_NUM
																									AND	SD1.D1_ITEMPC = SC7.C7_ITEM
											 	WHERE 	SC7.%notDel%		AND
														SD1.%notDel%		AND
														SC7.C7_FILIAL || SC7.C7_NUM  = %Exp:cCompara%)   SD1A ON  	SD1A.FILIAL	 =	SE2.E2_FILIAL
																												AND	SD1A.DOC	 =	SE2.E2_NUM
																												AND	SD1A.SERIE	 =	SE2.E2_PREFIXO
																												AND	SD1A.FORNECE =	SE2.E2_FORNECE
																												AND	SD1A.LOJA	 =	SE2.E2_LOJA
			WHERE 		SE2.%notDel%
		EndSql
		if U_VALSIMP(SC7->C7_FILIAL)
			if (cAlias01)->(Eof())
				DbSelectArea("SCR")
				SCR->(DbSetOrder(01))
				SCR->(DbSeek(SC7->C7_FILIAL+"PC"+SC7->C7_NUM))
				if SC7->C7_XTPSP $ "2|3" .And. AllTrim(SC7->C7_XORIG) != '3'//AllTrim(SC7->C7_XSERIE) != "MIG"
					if SC7->C7_XDTEXCE == "1"
						U_PSDTFIXSP(SC7->C7_COND, SC7->C7_TOTAL, 3)
					endif
					fConapro("L", SC7->(Recno()))
					MsgRun("Gerando Nota Fiscal e Titulo...","Aguarde...",{|| lRet := gerNotaFis(SC7->(Recno())) })
					MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
					MaAlcDoc({SC7->C7_NUM,"PC" ,SC7->C7_TOTAL,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,dDataBase},dDataBase,1)
					fConaPro("B", SC7->(Recno()))
				elseif SC7->C7_XTPSP $ "2|3" .And. AllTrim(SC7->C7_XORIG) == '3'
					MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
					MaAlcDoc({SC7->C7_NUM,"PC" ,SC7->C7_TOTAL,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,dDataBase},dDataBase,1)
				elseif SC7->C7_XTPSP $ "4|5" .And. AllTrim(SC7->C7_CONAPRO) == "L"
					fConapro("L", SC7->(Recno()))
					MsgRun("Gerando Nota Fiscal e Titulo...","Aguarde...",{|| lRet := gerNotaFis(SC7->(Recno())) })
					fConaPro("B", SC7->(Recno()))
					DbSelectArea("SCR")
					DbSetOrder(1)
					If DbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM)
						MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
						MaAlcDoc({SC7->C7_NUM,"PC" ,SC7->C7_TOTAL,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,dDataBase},dDataBase,1)
						fConaPro("B", SC7->(Recno()))
					Endif
				endif
			endif
		endif

		While (cAlias01)->(!Eof())
			dBSelectArea("SE2")
			dBGoTo((cAlias01)->SE2_RECNO)
			If SE2->E2_XSTRECU == "R"
				Reclock("SE2",.F.)
				SE2->E2_XSTRECU := "C"
				SE2->E2_XDTRECU := dDataBase

				IF EMPTY(SE2->E2_XDTRECP)
					SE2->E2_XDTRECP := dDataBase
				ENDIF

				SE2->(MsUnlock())
			EndIf
			(cAlias01)->(dBSkip())
		EndDo
		If Select("cAlias01") > 0
			(cAlias01)->(dbCloseArea())
		EndIf

		cAlias02 := GetNextAlias()
		BeginSql Alias cAlias02
			SELECT	SF1.R_E_C_N_O_	SF1_RECNO
			FROM	(SELECT DISTINCT	SD1.D1_FILIAL	  FILIAL	,
										SD1.D1_DOC		  DOC		,
										SD1.D1_SERIE	  SERIE		,
										SD1.D1_FORNECE	  FORNECE	,
										SD1.D1_LOJA		  LOJA
				   	 FROM %Table:SC7% SC7 INNER JOIN %Table:SD1% SD1 ON		SD1.D1_FILIAL = SC7.C7_FILIAL
																		AND	SD1.D1_PEDIDO = SC7.C7_NUM
																		AND	SD1.D1_ITEMPC = SC7.C7_ITEM
					 WHERE 	SC7.%notDel%		AND
							SD1.%notDel%		AND
							SC7.C7_FILIAL || SC7.C7_NUM  = %Exp:cCompara%)	SD1A	INNER JOIN %Table:SF1% SF1 ON		SF1.F1_FILIAL	= SD1A.FILIAL
																													AND	SF1.F1_DOC		= SD1A.DOC
																													AND	SF1.F1_SERIE	= SD1A.SERIE
																													AND SF1.F1_FORNECE	= SD1A.FORNECE
																													AND SF1.F1_LOJA		= SD1A.LOJA
			 WHERE 		SF1.%notDel%
		EndSql

		While (cAlias02)->(!Eof())
			dBSelectArea("SF1")
			dBGoTo((cAlias02)->SF1_RECNO)
			If SF1->F1_XSTRECU == "R"
				Reclock("SF1",.F.)
				SF1->F1_XSTRECU := "C"
				SF1->F1_XDTRECU := dDataBase
				SF1->(MsUnlock())
			EndIf
			(cAlias02)->(dBSkip())
		EndDo
		If Select("cAlias02") > 0
			(cAlias02)->(dbCloseArea())
		EndIf

	ElseIf cRotina  == "MATA110" //Solicitação de Compra
		cCompara := cFilOri + cCodOri
		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
			SELECT SE2.R_E_C_N_O_ SE2_RECNO
			FROM %Table:SE2% SE2 INNER JOIN (SELECT DISTINCT SD1.D1_FILIAL  FILIAL  ,
			SD1.D1_DOC     DOC     ,
			SD1.D1_SERIE   SERIE   ,
			SD1.D1_FORNECE FORNECE ,
			SD1.D1_LOJA    LOJA
			FROM	%Table:SC1% SC1	INNER JOIN %Table:SC7% SC7 ON	SC7.C7_FILIAL = SC1.C1_FILIAL
			AND SC7.C7_NUM 	  = SC1.C1_PEDIDO
			AND SC7.C7_ITEM   = SC1.C1_ITEMPED
			INNER JOIN %Table:SD1% SD1 ON 	SD1.D1_FILIAL = SC7.C7_FILIAL
			AND SD1.D1_PEDIDO = SC7.C7_NUM
			AND SD1.D1_ITEMPC = SC7.C7_ITEM
			WHERE 	SC1.%notDel%    AND
			SD1.%notDel%    AND
			SC7.%notDel%    AND
			SC1.C1_FILIAL || SC1.C1_NUM = %Exp:cCompara%)  SD1A ON 	SD1A.FILIAL	 =	SE2.E2_FILIAL
			AND	SD1A.DOC	 =	SE2.E2_NUM
			AND	SD1A.SERIE	 =	SE2.E2_PREFIXO
			AND	SD1A.FORNECE =	SE2.E2_FORNECE
			AND	SD1A.LOJA	 = 	SE2.E2_LOJA
			WHERE SE2.%notDel%
		EndSql

		While (cAlias01)->(!Eof())
			dBSelectArea("SE2")
			dBGoTo((cAlias01)->SE2_RECNO)
			If SE2->E2_XSTRECU == "R"
				Reclock("SE2",.F.)
				SE2->E2_XSTRECU := "C"
				SE2->E2_XDTRECU := dDataBase

				IF EMPTY(SE2->E2_XDTRECP)
					SE2->E2_XDTRECP := dDataBase
				ENDIF

				SE2->(MsUnlock())
			EndIf
			(cAlias01)->(dBSkip())
		EndDo
		If Select("cAlias01") > 0
			(cAlias01)->(dbCloseArea())
		EndIf

		cAlias02 := GetNextAlias()
		BeginSql Alias cAlias02
			SELECT	SF1.R_E_C_N_O_ SF1_RECNO
			FROM 	%Table:SF1% SF1 INNER JOIN (SELECT DISTINCT SD1.D1_FILIAL  FILIAL  ,
																SD1.D1_DOC     DOC     ,
																SD1.D1_SERIE   SERIE   ,
																SD1.D1_FORNECE FORNECE ,
																SD1.D1_LOJA    LOJA
												FROM	%Table:SC1% SC1	INNER JOIN %Table:SC7% SC7 ON		SC7.C7_FILIAL = SC1.C1_FILIAL
																										AND SC7.C7_NUM 	  = SC1.C1_PEDIDO
																										AND SC7.C7_ITEM   = SC1.C1_ITEMPED
																		INNER JOIN %Table:SD1% SD1 ON 		SD1.D1_FILIAL = SC7.C7_FILIAL
																										AND SD1.D1_PEDIDO = SC7.C7_NUM
																										AND SD1.D1_ITEMPC = SC7.C7_ITEM
												WHERE 	SC1.%notDel%    AND
														SD1.%notDel%    AND
														SC7.%notDel%    AND
														SC1.C1_FILIAL || SC1.C1_NUM = %Exp:cCompara%)	SD1A ON 	SD1A.FILIAL	 =	SF1.F1_FILIAL
																												AND	SD1A.DOC	 =	SF1.F1_DOC
																												AND	SD1A.SERIE	 =	SF1.F1_SERIE
																												AND	SD1A.FORNECE =	SF1.F1_FORNECE
																												AND	SD1A.LOJA	 = 	SF1.F1_LOJA
			WHERE SF1.%notDel%
		EndSql

		While (cAlias02)->(!Eof())
			dBSelectArea("SF1")
			dBGoTo((cAlias02)->SF1_RECNO)
			If SF1->F1_XSTRECU == "R"
				Reclock("SF1",.F.)
				SF1->F1_XSTRECU := "C"
				SF1->F1_XDTRECU := dDataBase

				IF EMPTY(SF1->F1_XDTRECP)
					SF1->F1_XDTRECP := dDataBase
				ENDIF

				SF1->(MsUnlock())
			EndIf
			(cAlias02)->(dBSkip())
		EndDo
		If Select("cAlias02") > 0
			(cAlias02)->(dbCloseArea())
		EndIf

	ElseIf cRotina $ "GPEM660" //Manutenção de Benefícios

		cAlias01 := GetNextAlias()
		BeginSql Alias cAlias01
			SELECT SE2.R_E_C_N_O_ AS SE2_RECNO
			FROM 	%Table:SE2% SE2
			WHERE 	SE2.%notDel%
			AND SE2.E2_FILIAL || SE2.E2_PREFIXO || SE2.E2_NUM || SE2.E2_TIPO || SE2.E2_FORNECE = %Exp:cCodOri%
		EndSql

		While (cAlias01)->(!Eof())
			dBSelectArea("SE2")
			dBGoTo((cAlias01)->SE2_RECNO)
			If SE2->E2_XSTRECU == "R"
				Reclock("SE2",.F.)
				SE2->E2_XSTRECU := "C"
				SE2->E2_XDTRECU := dDataBase
				SE2->(MsUnlock())
			EndIf
			(cAlias01)->(dBSkip())
		EndDo
		If Select("cAlias01") > 0
			(cAlias01)->(dbCloseArea())
		EndIf

	ElseIf cRotina $ "AE_DESPV" //Prestação de Contas

		If LHP->(DbSeek(XFilial("LHP")+cCodOri))
			cTitulo := LHP->LHP_FILIAL+LHP->LHP_CODIGO // ticket n° 7598818 - 415966 - alteração na busca

			cAlias01 := GetNextAlias()
			BeginSql Alias cAlias01
				SELECT SE2.R_E_C_N_O_ AS SE2_RECNO
				FROM 	%Table:SE2% SE2
				WHERE 	SE2.%notDel% AND
				SE2.E2_FILIAL || SE2.E2_NUM = %Exp:cTitulo% AND
				SE2.E2_PREFIXO = "CDV" // ticket n° 7598818 - 415966 - alteração na busca
			EndSql

			While (cAlias01)->(!Eof())
				dBSelectArea("SE2")
				dBGoTo((cAlias01)->SE2_RECNO)
				If SE2->E2_XSTRECU == "R"
					Reclock("SE2",.F.)
					SE2->E2_XSTRECU := "C"
					SE2->E2_XDTRECU := dDataBase

					IF EMPTY(SE2->E2_XDTRECP)
						SE2->E2_XDTRECP := dDataBase
					ENDIF

					SE2->(MsUnlock())
				EndIf
				(cAlias01)->(dBSkip())
			EndDo

			If Select("cAlias01") > 0
				(cAlias01)->(dbCloseArea())
			EndIf

			cTPLPrefix := PadR(SuperGetMV('MV_PREREEM'), TamSX3("E2_PREFIXO")[1])
			cTPLTipo   := PadR(SuperGetMV('MV_TIPREEM'), TamSX3("E2_TIPO")   [1])
			cTPLParcel := PadR(SuperGetMV('MV_PARREEM'), TamSX3("E2_PARCELA")[1])

			dbSelectArea("SA2")
			SA2->(DbOrderNickName("SA2CDV6")) //A2_FILIAL+A2_MAT
			If MsSeek(xFilial('SA2') + LHP->LHP_FUNC)
				cTPLFornec := SA2->A2_COD
				cTPLLoja   := SA2->A2_LOJA
				SE2->(DbSetOrder(1))
				If SE2->(DbSeek(LHP->(LHP_FILIAL + cTPLPrefix + LHP_CODIGO + cTPLParcel + cTPLTipo + cTPLFornec + cTPLLoja)))
					If SE2->E2_XSTRECU == "R"
						Reclock("SE2",.F.)
						SE2->E2_XSTRECU := "C"
						SE2->E2_XDTRECU := dDataBase
						SE2->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf

	ElseIf cRotina $ "TEWBTYP3" //Pré nota especifica
		
		SF1->(Reclock("SF1",.F.))
		SF1->F1_XSTRECU := "C"
		SF1->F1_XDTRECU := dDatabase
		SF1->(MsUnlock())
		aAreaSD1 := SD1->(GetArea())
		if SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
			if (SuperGetMV("MV_XPRDEST",,"") $ AllTrim(SD1->D1_COD) .Or. SuperGetMV("MV_XPRDNES",,"") $ AllTrim(SD1->D1_COD) .Or. SuperGetMV("MV_XPRDGPE",,"") $ AllTrim(SD1->D1_COD)) .And.  SE2->E2_XSTRECU == "R"
				cChavE2 := SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
				aAReaSE2 := SE2->(FWGetArea())
				If SE2->(DbSeek(cChavE2))
					While !SE2->(Eof()) .And. cChavE2 == SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
						Reclock("SE2",.F.)
						SE2->E2_XSTRECU := "C"
						SE2->E2_XDTRECU := dDataBase
						SE2->(MsUnlock())
						SE2->(DbSkip())
					EndDo
				endif
				RestArea(aAreaSE2)
			endif
		endif
		RestArea(aAreaSD1)

		If SF1->F1_STATUS <> "A"
			cRot := "TEWBTYP3"
			U_XNCLAC(SF1->(RECNO()))
		EndIf
	EndIf

Return

/*
{Protheus.doc} F010101M() 
Aciona ponto de entrada FA580LIB.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/
User Function F010101M()

	Local cMensagem := ""
	Local lRet		:= .T.
	Local aArea		:= FWGetArea()

	If SE2->E2_XSTRECU  == "R"
		If !IsInCallStack("MSEXECAUTO")
			cMensagem := "Título Recusado." + CRLF
			cMensagem += "Não pode ser liberado."
			MsgAlert(cMensagem)
		EndIf
		lRet := .F.
	EndIf

	If SE2->E2_XCLAUT == "1"
		If !IsInCallStack("MSEXECAUTO")
			lRet := fGetCont()
		EndIF
	EndIf
	RestArea(aArea)
Return(lRet)

/*
{Protheus.doc} F010101N()
Aciona ponto de entrada  F580LBA.
@Author     Paulo Krüger
@Since      18/01/2017
@Version    P12.7
@Project    MAN00000462901_EF_010
*/
User Function F010101N()
	Local cMensagem := ""
	Local lRet		:= .T.
	Local cAliasXX	:= ALIAS()
	Local aArea		:= FWGetArea()
	Local aAreaSE2	:= SE2->(FWGetArea())
	Local nRecnoSE2	:= SE2->(Recno())

	SE2->(dbGoTo((cAliasXX)->RECNO))
	If SE2->E2_XSTRECU  == "R"
		If !IsInCallStack("MSEXECAUTO")
			cMensagem := "Título Recusado:" + SE2->E2_PREFIXO + If(!Empty(SE2->E2_PREFIXO),"-","") + SE2->E2_NUM + "-" + SE2->E2_NOMFOR + "." + CRLF
			cMensagem += "Não pode ser liberado."
			MsgAlert(cMensagem)
		EndIf
		lRet := .F.
	EndIf

	If SE2->E2_XCLAUT == "1"
		If !IsInCallStack("MSEXECAUTO")
			lRet := fGetCont()
		EndIF
	EndIf

	SE2->(dBGoTo(nRecnoSE2))
	RestArea(aAreaSE2)
	RestArea(aArea)
Return(lRet)

/*
{Protheus.doc} F010101PCANCELARECUSA()
Implementa Função para Cancelamento da Recusa.
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
User Function F010101PCANCELARECUSA()

	If U_F010101C()
		If IsIncallStack("FINA750") .Or. IsIncallStack("FINA050")
			DbSelectArea("SF1")
			DbSetOrder(1)
			if SF1->(DbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
				SF1->(Reclock("SF1",.F.))
				SF1->F1_XSTRECU := " "
				SF1->F1_XDTRECU := CtoD("  /  /  ")
				SF1->(MsUnlock())
			EndIf
		Else
			SF1->(Reclock("SF1",.F.))
			SF1->F1_XSTRECU := " "
			SF1->F1_XDTRECU := CtoD("  /  /  ")
			SF1->(MsUnlock())
		EndIf
	EndIf

Return

/*
{Protheus.doc} F010101PCANCELARECUSA()
Implementa Função para Cancelamento da Recusa.
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
User Function F010101QVALIDACLASSIFICACAO()

	Local lRetorno := .T.

	If SF1->F1_XSTRECU == "R"
		lRetorno := .F.
		HELP(' ',1,"F010101P" ,,"Documento de Entrada Recusado. Impossível continuar.",2,0,,,,,,)
	Endif

Return lRetorno

/*
{Protheus.doc} F010101RINCLUILEGENDA()
Adiciona Legenda de Recusa na Nota Fiscal de Entrada
@Author     Robson William
@Since      07/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
User Function F010101RINCLUILEGENDA(aRetorno)

	AAdd(aRetorno, {"BR_CANCEL", "Documento com Recusa"})

Return aRetorno

/*
{Protheus.doc} F010101RINCLUICOR()
Adiciona Nova Cor no brose da Nota Fiscal de Entrada para Recusa
@Author     Robson William
@Since      07/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
User Function F010101SINCLUICOR(aCores)
	Local aRetorno  := {}
	Local nContador := 0

	AAdd(aRetorno,{ "F1_XSTRECU == 'R'", "BR_CANCEL"})

	For nContador:=1 to len(aCores)
		AAdd(aRetorno,aCores[nContador])
	Next

Return aRetorno

/*
{Protheus.doc} NotaClassificada()
Verifica se a nota fiscal foi classificada
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
Static Function NotaClassificada()

	Local aArea		:= FWGetArea()
	Local aAreaSD1	:= SD1->(FWGetArea())
	Local lClassificada := .F.

	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(XFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
		lClassificada := !Empty(SD1->D1_TES)
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

Return lClassificada

/*
{Protheus.doc} OrigemNFEntrada()
Verifica se a chamada é de nota fiscal ou solicitação de pagamento
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
Static Function OrigemNFEntrada(lRecuAut)
	Local lRetorno := .F.
	Default lRecuAut := .F.
	If IsInCallStack("MATA103") .Or. IsInCallStack("U_F0100401") .or. IsInCallStack("U_S0100401") .Or. lRecuAut
		lRetorno := .T.
	Endif

Return lRetorno

/*
{Protheus.doc} SolicitacaoPagamentoAutorizada()
Verifica se é possível realizar a recusa quando a chamada vier da tela de solicitação de pagamento
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
Static Function SolicitacaoPagamentoAutorizada()

	Local lRetorno := .F.

	If IsInCallStack("U_F0100401") .or. IsInCallStack("U_S0100401")
		If Empty(SC7->C7_XDOC)
			HELP(' ',1,"F010101P" ,,"Documento de Entrada não informado!",2,0,,,,,, {"Informe o Documento de Entrada."})
		ElseIf SC7->C7_CONAPRO == "B" .And. (SC7->C7_XTPSP == "1"  .Or. Empty(SC7->C7_XTPSP))
			HELP(' ',1,"F010101P" ,,"Solicitação de Pagamento não autorizada!",2,0,,,,,, {"Realize a aprovação desta Solicitação de Pagamento."})
		Else
			SF1->(DbSetOrder(1))
			If !SF1->(DbSeek(XFilial("SF1")+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
				if SC7->C7_XTPSP $ "2|3|4|5"
					lRetorno := .T.
				else
					HELP(' ',1,"F010101P" ,,"Documento de Entrada informado não foi gerado!",2,0,,,,,, {"Gere o Documento de Entrada."})
				endif
			Else
				lRetorno := .T.
			EndIf
		EndIf
	Else
		lRetorno := .T.
	EndIf

Return lRetorno

/*
{Protheus.doc} ValorNotaFiscal()
Apura o valor das mercadorias a partir dos itens da nota pois, para notas não classificadas, os campos de valor bruto e valor da mercadoria não está preenchido
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
Static Function ValorNotaFiscal()
	Local aAreaSD1 := SD1->(FWGetArea())
	Local nRetorno := 0

	SD1->(DbSetOrder(1))
	SD1->(DbSeek(XFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
	While SD1->(!Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == XFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))
		nRetorno += SD1->D1_TOTAL
		SD1->(DbSkip())
	End
	RestArea(aAreaSD1)

Return nRetorno

/*
{Protheus.doc} PermiteRecusa()
Verifica se o documento atual permite operação de recusa ou cancelamento de recusa
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
Static Function PermiteRecusa(lVemDeNota)

	Local lRetorno := .T.
	Default lVemDeNota := .T.

	If lVemDeNota
		If IsInCallStack("U_F010101PCANCELARECUSA") .And. !(SF1->F1_XSTRECU == "R")
			Help("", 1, "F010101A", , "Não existe recusa para este documento!.", 1, 0, , , , , , {""})
			lRetorno := .F.
		ElseIf !IsInCallStack("U_F010101PCANCELARECUSA") .And. SF1->F1_XSTRECU == "R"
			Help("", 1, "F010101A", , "Já existe recusa para este documento!.", 1, 0, , , , , , {""})
			lRetorno := .F.
		EndIf
	Else
		If IsInCallStack("U_F010101PCANCELARECUSA") .And. !(SE2->E2_XSTRECU == "R")
			Help("", 1, "F010101A", , "Não existe recusa para este documento!.", 1, 0, , , , , , {""})
			lRetorno := .F.
		ElseIf !IsInCallStack("U_F010101PCANCELARECUSA") .And. SE2->E2_XSTRECU == "R"
			Help("", 1, "F010101A", , "Já existe recusa para este documento!.", 1, 0, , , , , , {""})
			lRetorno := .F.
		EndIf
	Endif

Return lRetorno


/*
{Protheus.doc} PermiteRecusa()
Descobre o emitente do documento de solicitacao de pagamento
@Author     Robson William
@Since      05/06/2017
@Version    P12.7
@Project    MAN00000462901_EF_010, AID/MIT031 - Solicitação de Melhoria
*/
Static Function DescobreEmitente()
	Local cRetorno := RetCodUsr()
	Local cAlias01 := GetNextAlias()

	BeginSql Alias cAlias01
		SELECT DISTINCT C7_XUSR
          FROM %Table:SC7% SC7 
         WHERE SC7.C7_FILIAL  = %xfilial:SC7%
           AND SC7.C7_XDOC    = %exp:SF1->F1_DOC%
           AND SC7.C7_XSERIE  = %exp:SF1->F1_SERIE%
           AND SC7.C7_FORNECE = %exp:SF1->F1_FORNECE%
           AND SC7.C7_LOJA    = %exp:SF1->F1_LOJA%
           AND SC7.C7_XUSR   <> ''
           AND SC7.%notDel%
	EndSql

	If (cAlias01)->(!Eof())
		cRetorno := (cAlias01)->C7_XUSR
	EndIf
	(cAlias01)->(dbCloseArea())

Return cRetorno

// ----------------------------------------------

static function AchaEmitente()

	local cRetorno := RetCodUsr()
	local cAlias01 := GetNextAlias()

	If !IsInCallStack("FINA750")
		BeginSql Alias cAlias01
		SELECT DISTINCT C7_XUSR
          FROM %Table:SC7% SC7 
         WHERE SC7.C7_FILIAL  = %exp:SF1->F1_FILIAL%
           AND SC7.C7_XDOC    = %exp:SF1->F1_DOC%
           AND SC7.C7_XSERIE  = %exp:SF1->F1_SERIE%
           AND SC7.C7_FORNECE = %exp:SF1->F1_FORNECE%
           AND SC7.C7_LOJA    = %exp:SF1->F1_LOJA%
           AND SC7.C7_XUSR   <> ''
           AND SC7.%notDel%
		EndSql
	Else
		BeginSql Alias cAlias01
		SELECT DISTINCT C7_XUSR
          FROM %Table:SC7% SC7 
         WHERE SC7.C7_FILIAL  = %exp:SE2->E2_FILIAL%
           AND SC7.C7_XDOC    = %exp:SE2->E2_NUM%
           AND SC7.C7_XSERIE  = %exp:SE2->E2_PREFIXO%
           AND SC7.C7_FORNECE = %exp:SE2->E2_FORNECE%
           AND SC7.C7_LOJA    = %exp:SE2->E2_LOJA%
           AND SC7.C7_XUSR   <> ''
           AND SC7.%notDel%
		EndSql
	EndIf

	If (cAlias01)->(!Eof())
		cRetorno := (cAlias01)->C7_XUSR
	EndIf
	(cAlias01)->(dbCloseArea())

Return cRetorno

/*
Static Function ExcluiNota()

	Local aCabecNota := {}
	Local aItensNota := {}
	Local bExecAuto  := {||}
	Local nOpcExclui := 5
	Local cQuery	:= ""
	Local cAlias    := GetNextAlias()
	local lRet 		:= .T.
	Local aAreaSF1	:= SF1->(getArea())

	Private lMsErroAuto	:= .F.

	Default cTipoSP := ""
	cFilAntBkp := cFilAnt
	cFilAnt := SE2->E2_FILIAL

	cQuery += " SELECT C7_FILIAL, C7_NUM, C7_XTPSP, R_E_C_N_O_ REC FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND C7_FILIAL = '"+ SE2->E2_FILIAL +"' "
	cQuery += " AND C7_FORNECE = '"+ SE2->E2_FORNECE +"' "
	cQuery += " AND C7_LOJA = '"+ SE2->E2_LOJA+"'"
	cQuery += " AND C7_XSERIE  = '"+SE2->E2_PREFIXO+"'"
	cQuery += " AND C7_XDOC  = '"+SE2->E2_NUM+"' "

	dbUseArea(.T. , "TOPCONN" , TcGenQry(,,cQuery) , (cAlias) , .T. , .T.)

	(cAlias)->(DbGoTop())
	if !(cAlias)->(Eof())
		DbSelectArea("SC7")
		SC7->(DbGoTo((cAlias)->REC))
		if SC7->C7_XTPSP != "1" .And. !Empty(SC7->C7_XTPSP)
			//Atualiza campos da SP e sai da rotina.
			If !Empty(SE2->E2_XMIGLT)
				RecLock("SC7", .F.)
				SC7->C7_ENCER := ""
				SC7->C7_QUJE := 0
				SC7->(MsUnlock())
				Return
			endif
			//Atualiza bordero
			RecLock("SE2", .F.)
			SE2->E2_NUMBOR := " "
			SE2->(MsUnlock())
			//cChavE2 := XFilial("SE2") + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
			cChavE2 := SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
			aAReaSE2 := SE2->(GetArea())
			DbSelectArea("SE2")
			SE2->(DbSetOrder(06))
			SE2->(DbSeek(cChavE2))
			While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
				If !Empty(SE2->E2_BAIXA)
					lRet := .F.
					Exit
				EndIf
				SE2->(DbSkip())
			EndDo
			RestArea(aAreaSE2)
			if !lRet
				Return
			Endif
			DbSelectArea("SF1")
			if SF1->(DbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
				aCabecNota := {;
					{"F1_DOC"	 , SE2->E2_NUM	  , Nil},;
					{"F1_SERIE"	 , SE2->E2_PREFIXO , Nil},;
					{"F1_EMISSAO", SE2->E2_EMISSAO , Nil},;
					{"F1_FORNECE", SE2->E2_FORNECE, Nil},;
					{"F1_LOJA"	 , SE2->E2_LOJA	  , Nil};
					}
				SD1->(DbSetOrder(1))
				If !SD1->(DbSeek(SC7->C7_FILIAL+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
					Return
				endif

				U_ContabSP("SP2", cChavE2)
				//bExecAuto := {|aCabec, aItens, nOpc| MatA140(aCabec, aItens, nOpc)}
				cUserBkp := CUSERNAME
				CUSERNAME := "Integrador"
				//MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCabecNota,,5)
				bExecAuto := {|aCabec, aItens, nOpc| MATA103(aCabec, aItens, nOpc)}
				MsExecAuto(bExecAuto, aCabecNota, aItensNota, nOpcExclui)
				CUSERNAME := cUserBkp

				if lMsErroAuto
					DisarmTransaction()
					MostraErro()
					lRet := .F.
				else
					if SC7->C7_XTPSP $ "2|3"
						DbSelectArea("SE2")
						SE2->(DbSetOrder(6))
						aAReaSE2 := SE2->(GetArea())
						if SE2->(DbSeek(cChavE2))
							While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
								aExcTit := {}
								AAdd(aExcTit,{"E2_NUM" 		,SE2->E2_NUM		,NIL})
								AAdd(aExcTit,{"E2_PREFIXO"	,SE2->E2_PREFIXO	,NIL})
								AAdd(aExcTit,{"E2_PARCELA"	,SE2->E2_PARCELA	,NIL})
								AAdd(aExcTit,{"E2_TIPO"		,"NFE"				,NIL})
								AAdd(aExcTit,{"E2_FORNECE"	,SE2->E2_FORNECE	,NIL})
								AAdd(aExcTit,{"E2_LOJA"		,SE2->E2_LOJA		,NIL})

								//SetFunName("FINA050")
								MsExecAuto({|x,y,z| FINA050(x,y,z)},aExcTit,,5)
								//SetFunName("F010101A")

								If lMsErroAuto
									DisarmTransaction()
									Break
								EndIf
								SE2->(DbSkip())
							EndDo
						EndIf
						RestArea(aAreaSE2)
					endif
				endif
			endif
			RestArea(aAreaSF1)
		endif
	endif
	cFilAnt := cFilAntBkp
Return
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} gerNotaFis
description Gera a nota fiscal ao finalizar a SP.
@author  Ricardo Junior	
@since   01/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function gerNotaFis(nRecno)
	Local aArea := GetArea()
	Local aAreaSE2 := SE2->(GetArea())
	Local aCabec := {}
	Local aItens := {}
	Local lRet := .T.
	Private lMsErroAuto := .F.

	DbSelectArea("SC7")
	SC7->(DbGoTo(nRecno))
	cChavE2 := XFilial("SE2") + SC7->(C7_FORNECE + C7_LOJA + C7_XSERIE + C7_XDOC)
	cUFOri := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SC7->C7_FORNECE + SC7->C7_LOJA , 'A2_EST' )

	aCabec := { { 'F1_TIPO'    , 'N'             , NIL } , ;
		{ 'F1_FORMUL'  , ''              , NIL } , ;
		{ 'F1_DOC'     , SC7->C7_XDOC    , NIL } , ;
		{ 'F1_SERIE'   , SC7->C7_XSERIE  , NIL } , ;
		{ 'F1_EMISSAO' , SC7->C7_XDTEMI  , NIL } , ;
		{ 'F1_FORNECE' , SC7->C7_FORNECE , NIL } , ;
		{ 'F1_LOJA'    , SC7->C7_LOJA    , NIL } , ;
		{ 'F1_EST'     , cUFOri          , NIL } , ;
		{ 'F1_COND'    , SC7->C7_COND    , NIL } , ;
		{ 'F1_XUSR'    , SC7->C7_XUSR    , NIL } , ;
		{ 'F1_ORIGEM'  , SC7->C7_ORIGEM  , NIL } , ;
		{ 'F1_XTIPO'   , SC7->C7_XTIPO   , NIL } , ;
		{ 'F1_ESPECIE' , SC7->C7_XESPECI , NIL } , ;
		{ 'F1_XSOLPAG' , SC7->C7_XSOLPAG , NIL } , ;
		{ 'F1_DTLANC' ,  dDataBase, NIL } , ;
		{ 'F1_XDTVNF'  , SC7->C7_XDTVEN  , NIL }}

	cChave := SC7->C7_FILIAL + SC7->C7_NUM

	While SC7->(!Eof()) .AND. SC7->C7_FILIAL + SC7->C7_NUM == cChave
		aLinha := { { 'D1_COD'     , SC7->C7_PRODUTO , NIL } , ;
			{ 'D1_UM'      , SC7->C7_UM      , NIL } , ;
			{ 'D1_QUANT'   , SC7->C7_QUANT   , NIL } , ;
			{ 'D1_VUNIT'   , SC7->C7_PRECO   , NIL } , ;
			{ 'D1_TOTAL'   , SC7->C7_TOTAL   , NIL } , ;
			{ 'D1_TES'     , Posicione("SBZ",1,SC7->C7_FILIAL+SC7->C7_PRODUTO, "BZ_TE"), Nil},;
			{ 'D1_VALDESC' , SC7->C7_VLDESC  , NIL } , ;
			{ 'D1_DESPESA' , SC7->C7_DESPESA , NIL } , ;
			{ 'D1_LOCAL'   , SC7->C7_LOCAL   , NIL } , ;
			{ 'D1_CC'      , SC7->C7_CC      , NIL } , ;
			{ 'D1_PEDIDO'  , SC7->C7_NUM     , NIL } , ;
			{ 'D1_ITEMPC'  , SC7->C7_ITEM    , NIL } , ;
			{ 'D1_QTDPEDI' , SC7->C7_QUANT   , NIL } , ;
			{ 'D1_XPRIVEN' , SC7->C7_XDTVEN  , NIL } , ;
			{ 'D1_XJURMUL' , SC7->C7_XJURMUL , NIL } , ;
			{ 'D1_VALFRE'  , SC7->C7_VALFRE  , NIL } , ;
			{ 'D1_DESPESA' , SC7->C7_DESPESA , NIL } , ;
			{ 'D1_SEGURO'  , SC7->C7_SEGURO  , NIL } , ;
			{ 'D1_XMULTA'  , SC7->C7_XMULTA  , NIL } , ;
			{ 'D1_XNATURE' , SC7->C7_XNATURE , NIL } , ;
			{ 'D1_XOBS'    , SC7->C7_OBS     , NIL }   }

		aadd(aItens,aLinha)
		SC7->(DbSkip())
	enddo

	//3-Inclusão / 4-Classificação / 5-Exclusão
	MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCabec,aItens,3)

	if lMsErroAuto
		DisarmTransaction()
		PegaErro()
		lRet := .F.
	else
		if SC7->C7_XTPSP $ "2|3"
			aRecSe2 := SE2->(GetArea())
			DbSelectArea("SE2")
			SE2->(DbSetOrder(6))
			if SE2->(DbSeek(cChavE2))
				While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
					RecLock("SE2",.F.)
					SE2->E2_XAPRVSP := "2"
					SE2->(MsUnlock())
					SE2->(DbSkip())
				enddo
			endif
			RestArea(aRecSe2)
		endif
		U_ContabSP("SP1", cChavE2)
		lRet := .T.
	endif
	RestArea(aAreaSE2)
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fConapro
description Rotina para desbloquear e bloquear a SP.
@author  Ricardo Junior	
@since   01/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
static function	fConapro(cValor, nRecno)
	Local aArea := GetArea()
	Local aAreaC7 := SC7->(GetArea())
	DbSelectArea("SC7")
	SC7->(DbSetOrder(01))
	SC7->(DbGoTop())
	SC7->(DbGoTo(nRecno))
	cChave := SC7->C7_FILIAL+SC7->C7_NUM
	While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == cChave
		Reclock("SC7",.F.)
		SC7->C7_CONAPRO := cValor
		SC7->C7_QUJE 	:= 0
		SC7->C7_ENCER 	:= ""
		SC7->(MsUnlock())
		SC7->(DbSkip())
	enddo
	RestArea(aAreaC7)
	RestArea(aArea)
return


Static Function ExclClaut()

	Local aCabecNota := {}
	Local aItensNota := {}
	Local bExecAuto  := {||}
	Local nOpcExclui := 5
	Local cQuery	:= ""
	Local cAlias    := GetNextAlias()
	local lRet 		:= .T.
	Local aAreaSF1	:= SF1->(FWGetArea())
	Local nRecF1    := 0
	Local cUpd := ""
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}

	Private lMsErroAuto	:= .F.

	Default cTipoSP := ""
	cFilAntBkp := cFilAnt
	cFilAnt := SE2->E2_FILIAL

	cQuery += " SELECT C7_FILIAL, C7_NUM, R_E_C_N_O_ REC FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND C7_FILIAL = '"+ SE2->E2_FILIAL +"' "
	cQuery += " AND C7_FORNECE = '"+ SE2->E2_FORNECE +"' "
	cQuery += " AND C7_LOJA = '"+ SE2->E2_LOJA+"'"
	cQuery += " AND C7_XSERIE  = '"+SE2->E2_PREFIXO+"'"
	cQuery += " AND C7_XDOC  = '"+SE2->E2_NUM+"' "

	dbUseArea(.T. , "TOPCONN" , TcGenQry(,,cQuery) , (cAlias) , .T. , .T.)

	(cAlias)->(DbGoTop())
	if !(cAlias)->(Eof())

		While !(cAlias)->(Eof())
			DbSelectArea("SC7")
			SC7->(DbGoTo((cAlias)->REC))


			RecLock("SC7", .F.)
			SC7->C7_ENCER := " "
			SC7->C7_QUJE := 0
			SC7->C7_QTDACLA := 1
			SC7->(MsUnlock())
			(cAlias)->(DbSkip())
		EndDo
		//Atualiza bordero
		RecLock("SE2", .F.)
		SE2->E2_NUMBOR := " "
		SE2->(MsUnlock())
		//cChavE2 := XFilial("SE2") + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
		cChavE2 := SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
		aAReaSE2 := SE2->(FWGetArea())
		DbSelectArea("SE2")
		SE2->(DbSetOrder(06))
		SE2->(DbSeek(cChavE2))
		While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
			If !Empty(SE2->E2_BAIXA)
				lRet := .F.
				Exit
			EndIf
			SE2->(DbSkip())
		EndDo
		RestArea(aAreaSE2)
		if !lRet
			Return
		Endif
		DbSelectArea("SF1")
		DbSetOrder(1)
		if SF1->(DbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
			nRecF1 := SF1->(Recno())
		/*/	aCabecNota := {;
			{"F1_DOC"	 , SE2->E2_NUM	  , Nil},;
				{"F1_SERIE"	 , SE2->E2_PREFIXO , Nil},;
				{"F1_EMISSAO", SE2->E2_EMISSAO , Nil},;
				{"F1_FORNECE", SE2->E2_FORNECE, Nil},;
				{"F1_LOJA"	 , SE2->E2_LOJA	  , Nil};
				}
			SD1->(DbSetOrder(1))
			If !SD1->(DbSeek(SC7->C7_FILIAL+SC7->(C7_XDOC+C7_XSERIE+C7_FORNECE+C7_LOJA)))
				Return
			endif

			//U_ContabSP("SP2", cChavE2)
			//bExecAuto := {|aCabec, aItens, nOpc| MatA140(aCabec, aItens, nOpc)}
			cUserBkp := CUSERNAME
			CUSERNAME := "Integrador"
			//MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCabecNota,,5)
			bExecAuto := {|aCabec, aItens, nOpc| MATA103(aCabec, aItens, nOpc)}
			MsExecAuto(bExecAuto, aCabecNota, aItensNota, nOpcExclui)
			CUSERNAME := cUserBkp/*/

			/*/if lMsErroAuto
			DisarmTransaction()
			MostraErro()
			lRet := .F.
			else/*/
			Begin Transaction
				SF1->(DbGoTo(nRecF1))

				cUPD := "UPDATE "+RETSQLNAME("SFT")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND "
				cUPD += " FT_FILIAL = '"+SF1->F1_FILIAL+"' AND FT_NFISCAL = '"+SF1->F1_DOC+"' AND FT_CLIEFOR = '"+SF1->F1_FORNECE+"' AND FT_LOJA = '"+SF1->F1_LOJA+"' "
				cUPD += " AND FT_SERIE = '"+SF1->F1_SERIE+"'"
				TCSqlExec(cUPD)
				conout("TCSQLError() " + TCSQLError())

				aAdd(aCabec,{'F1_TIPO',SF1->F1_TIPO,NIL})
				aAdd(aCabec,{'F1_DOC',SF1->F1_DOC,NIL})
				aAdd(aCabec,{"F1_SERIE",SF1->F1_SERIE,NIL})
				aAdd(aCabec,{'F1_FORNECE',SF1->F1_FORNECE,NIL})
				aAdd(aCabec,{'F1_LOJA',SF1->F1_LOJA,NIL})

				DbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

				While SD1->(!Eof()) .and. SD1->D1_FILIAL == SF1->F1_FILIAL  .and.;
						SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
						SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

					aItens := {}

					aAdd(aItens,{'D1_ITEM',SD1->D1_ITEM,NIL})
					aAdd(aItens,{'D1_COD',SD1->D1_COD,NIL})
					aAdd(aItens,{"D1_QUANT",SD1->D1_QUANT,Nil})
					aAdd(aItens,{"D1_VUNIT",SD1->D1_VUNIT,Nil})
					aAdd(aItens,{"D1_TOTAL",SD1->D1_TOTAL,Nil})

					aAdd(aLinha,aItens)

					SD1->(DbSKip())
				EndDo

				MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, 7,,)//ESTORNO DA CLASSIFICAÇÃO

				If lMsErroAuto
					DisarmTransaction()
					Break
				Else
					SF1->(DbGoTo(nRecF1))
					SF1->(Reclock("SF1",.F.))
					SF1->F1_XSTRECU := "R"
					SF1->F1_XDTRECU := dDataBase
					SF1->F1_DUPL      := " "
					SF1->F1_VALMERC   := 0
					SF1->F1_VALBRUT   := 0
					SF1->F1_NUMTRIB   := " "
					SF1->F1_ISS       := 0
					SF1->F1_RECISS    := " "
					SF1->F1_ESTPRES   := " "
					SF1->F1_IDSED     := " "
					SF1->F1_INCISS    := " "
					SF1->F1_SIMPNAC   := " "
					SF1->F1_IDNF      := " "
					SF1->(MsUnLock())

					(cAlias)->(DbGoTop())
					if !(cAlias)->(Eof())

						While !(cAlias)->(Eof())
							DbSelectArea("SC7")
							SC7->(DbGoTo((cAlias)->REC))
							RecLock("SC7", .F.)
							SC7->C7_ENCER := " "
							SC7->C7_QUJE := 0
							SC7->C7_QTDACLA := SC7->C7_QUANT
							SC7->(MsUnlock())
							(cAlias)->(DbSkip())
						EndDo
					EndIf
				EndIf
			End Transaction
			RestArea(aAreaSE2)
			RestArea(aAreaSF1)
		endif
	endif
	cFilAnt := cFilAntBkp
	(cAlias)->(DbCloseArea())
Return


Static Function fGetCont()

	Local lRet    := .T.
	Local aArea   := FWGetArea()

	Local cQuery  := ""
	Local cArqSE2 := "TRBSE2"
	Local aHeadE2 := {}
	Local aColsE2 := {}
	Local nCont   := 0
	Local nOpc    := 0

	Private oDlSE2
	Private oDlg

	Aadd(aHeadE2,{ "FILIAL", "E2_FILIAL", PesqPict("SE2","E2_FILIAL",,), TamSX3("E2_FILIAL")[1], TamSX3("E2_FILIAL")[2] ,""  ,"", TamSX3("E2_FILIAL")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "NOME", "E2_NOMEFIL", "@!", 40, 0 ,""  ,"", "C",  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "PREFIXO", "E2_PREFIXO", PesqPict("SE2","E2_PREFIXO",,), TamSX3("E2_PREFIXO")[1], TamSX3("E2_PREFIXO")[2] ,""  ,"", TamSX3("E2_PREFIXO")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "NUMERO", "E2_NUM", PesqPict("SE2","E2_NUM",,), TamSX3("E2_NUM")[1], TamSX3("E2_NUM")[2] ,""  ,"", TamSX3("E2_NUM")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "CONTROLE", "E2_XCODCON", PesqPict("SE2","E2_XCODCON",,), TamSX3("E2_XCODCON")[1], TamSX3("E2_XCODCON")[2] ,""  ,"", TamSX3("E2_XCODCON")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "PARCELA", "E2_PARCELA", PesqPict("SE2","E2_PARCELA",,), TamSX3("E2_PARCELA")[1], TamSX3("E2_PARCELA")[2] ,""  ,"", TamSX3("E2_PARCELA")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "TIPO", "E2_TIPO", PesqPict("SE2","E2_TIPO",,), TamSX3("E2_TIPO")[1], TamSX3("E2_TIPO")[2] ,""  ,"", TamSX3("E2_TIPO")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "FORNECEDOR", "E2_FORNECE", PesqPict("SE2","E2_FORNECE",,), TamSX3("E2_FORNECE")[1], TamSX3("E2_FORNECE")[2] ,""  ,"", TamSX3("E2_FORNECE")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "NOME", "E2_NOMFOR", PesqPict("SE2","E2_NOMFOR",,), TamSX3("E2_NOMFOR")[1], TamSX3("E2_NOMFOR")[2] ,""  ,"", TamSX3("E2_NOMFOR")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "EMISSÃO", "E2_EMISSAO", PesqPict("SE2","E2_EMISSAO",,), TamSX3("E2_EMISSAO")[1], TamSX3("E2_EMISSAO")[2] ,""  ,"", TamSX3("E2_EMISSAO")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "VENCIMENTO", "E2_VENCTO", PesqPict("SE2","E2_VENCTO",,), TamSX3("E2_VENCTO")[1], TamSX3("E2_VENCTO")[2] ,""  ,"", TamSX3("E2_VENCTO")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "VALOR", "E2_PARCELA", PesqPict("SE2","E2_VALOR",,), TamSX3("E2_VALOR")[1], TamSX3("E2_VALOR")[2] ,""  ,"", TamSX3("E2_VALOR")[3],  ,,"","" ,.f. })
	Aadd(aHeadE2,{ "Recno", "E2_RECNO", "@E 9999999999", 10, 0 ,""  ,"", "N",  ,"V","",""   ,.f. })

	cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_NOMFOR, E2_EMISSAO, E2_VENCTO, E2_VALOR, E2_XCODCON, R_E_C_N_O_ FROM " + RetSqlName("SE2")
	cQuery += " WHERE (E2_NUM = '" + SE2->E2_NUM + "' OR E2_XCODCON = '" + SE2->E2_XCODCON + "') AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND "
	cQuery += " E2_FORNECE = '" + SE2->E2_FORNECE + "' AND "
	cQuery += " D_E_L_E_T_ = ' ' AND R_E_C_N_O_ 	NOT IN "
	cQuery += " ("
	cQuery += " SELECT R_E_C_N_O_ FROM "+RETSQLNAME("SE2")+" WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '"+SE2->E2_FILIAL+"'"
	cQuery += " AND E2_NUM = '"+SE2->E2_NUM+"' AND E2_FORNECE = '"+SE2->E2_FORNECE+"' "
	cQuery += " AND E2_LOJA = '"+SE2->E2_LOJA+"' AND E2_PREFIXO = '"+SE2->E2_PREFIXO+"')"

	If Select(cArqSE2) > 0
		DbSelectArea(cArqSE2)
		(cArqSE2)->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSE2,.T.,.T.)

	While !(cArqSE2)->(Eof())

		Aadd( aColsE2, { (cArqSE2)->E2_FILIAL, FWFilialName(SubStr((cArqSE2)->E2_FILIAL, 1, 2), (cArqSE2)->E2_FILIAL, 2 ), (cArqSE2)->E2_PREFIXO, (cArqSE2)->E2_NUM, (cArqSE2)->E2_XCODCON, (cArqSE2)->E2_PARCELA, (cArqSE2)->E2_TIPO,;
			(cArqSE2)->E2_FORNECE, (cArqSE2)->E2_NOMFOR, StoD((cArqSE2)->E2_EMISSAO), StoD((cArqSE2)->E2_VENCTO), (cArqSE2)->E2_VALOR, (cArqSE2)->R_E_C_N_O_, .f.})

		nCont += 1
		(cArqSE2)->(DbSkip())

	End

	If !Empty(aColsE2)

		DEFINE MSDIALOG oDlg TITLE "Títulos Encontrados"  FROM 0,0 TO 380, 820 OF oMainWnd PIXEL

		@ 160,048 SAY "Total Encontrado"           SIZE 050,07  OF oDlg PIXEL
		@ 169,048 MSGET oCout  VAR nCont           SIZE 035,09  OF oDlg PIXEL HASBUTTON When .F. Picture "@E 999"

		oDlSE2 := MsNewGetDados():New(30,0,155,412,  ,,,,,,9999,,,,oDlg,aHeadE2,aColsE2)

		oDlSE2:oBrowse:blDblClick:={|| U_VisualE2()}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpc:=1,oDlg:End()}, {|| nOpc:=0,oDlg:End() },,)
	Else
		Return .T.
	EndIf
	If nOpc == 1
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet


User Function XNCLAC(nRecF1)

	Local aArea := SF1->(FWGetArea())
	Local aAreaD1 := SD1->(FWGetArea())
	Local aProds := {}
	Local nTamanho := TamSX3("P38_PRODUT")[1]
	Local lAuto := .T.
	Local nX := 0
	Local aTitulo := {}
	Local cAliasD1 := GetNextAlias()
	Local cQuery := ""
	Local aProds := {}
	Local aVlProd := {}

	Private cNatu := ""
	Private cCCD1 := ""
	Private cxProds := ""
	Private nTot := 0

	Default nRecF1 := 0

	If SF1->F1_XSTRECU == "C"

		cQuery := "SELECT D1_COD, D1_CC, D1_TOTAL FROM "+RETSQLNAME("SD1")+ " WHERE D_E_L_E_T_ = ' ' AND "
		cQuery += " D1_FILIAL = '"+SF1->F1_FILIAL+"' AND D1_DOC = '"+SF1->F1_DOC+"' AND "
		cQuery += " D1_SERIE = '"+SF1->F1_SERIE+"' AND D1_FORNECE = '"+SF1->F1_FORNECE+"' AND "
		cQuery += " D1_LOJA = '"+SF1->F1_LOJA+"'"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasD1,.T.,.T.)

		While !(cAliasD1)->(Eof())
			AaDD(aProds,(cAliasD1)->D1_COD)
			cCCD1 := (cAliasD1)->D1_CC
			aadd( aVlProd, cValToChar(TRANSFORM((cAliasD1)->D1_TOTAL, "@E 999,999,999.99")))
			(cAliasD1)->(DbSkip())
		Enddo

		(cAliasD1)->(DbCloseArea())

		DbSelectArea("P38")
		DbSetOrder(1)

		For nX := 01 To Len(aProds)
			If IsInCallStack("U_F0400101")
				nTot := SF1->F1_VALBRUT
			ElseIf cRot <> "TEWBTYP3"
				nTot := nTot + acols[nX][8]
			Else
				nTot := SF1->F1_VALBRUT
			EndIf
			If !(P38->(DbSeek(xFilial("P38")+Padr(aProds[nX], nTamanho, ' ')+'1')))
				lAuto := .F.
				Exit
			Else
				If nX == 1
					cNatu := P38->P38_NATU
				EndIf
				If IsInCallStack("U_F0400101")
					cxProds += "Código do produto: " + AllTrim(aProds[nX]) +"   -  Descrição: " + AllTrim(Posicione('SB1',1,XFILIAL('SB1')+aProds[nX],'B1_XDES')) + "  -  Valor: " + AllTrim(aVlProd[nX]) + CRLF
				ElseIf cRot <> "TEWBTYP3"
					cxProds += "Código do produto: " + AllTrim(aProds[nX]) +"   -  Descrição: " + AllTrim(Posicione('SB1',1,XFILIAL('SB1')+aProds[nX],'B1_XDES')) + "  -  Valor: " + AllTrim(cValToChar(TRANSFORM(acols[nX][8], "@E 999,999,999.99"))) + CRLF
				Else
					cxProds += "Código do produto: " + AllTrim(aProds[nX]) +"   -  Descrição: " + AllTrim(Posicione('SB1',1,XFILIAL('SB1')+aProds[nX],'B1_XDES')) + "  -  Valor: " + AllTrim(aVlProd[nX]) + CRLF
				EndIf
				If P38->P38_NATU <> cNatu
					lAuto := .F.
					Exit
				EndIf
			EndIf
		Next nX

		If !lAuto
			if SuperGetMV("MV_XPRDEST",,"") $ AllTrim(aProds[nX]) .Or. SuperGetMV("MV_XPRDNES",,"") $ AllTrim(aProds[nX]) .Or. SuperGetMV("MV_XPRDGPE",,"") $ AllTrim(aProds[nX])
				If IsInCallStack("U_F0400101")
					//MsgRun("Aguarde... Realizando processo de classificação automática de materiais...",,{|| ClaAut(nRecF1,.T.) } )
				ElseIf cRot <> "TEWBTYP3"
					MsgRun("Aguarde... Realizando processo de classificação automática de materiais...",,{|| ClaAut(nRecF1) } )
				Else
					//MsgRun("Aguarde... Realizando processo de classificação automática de materiais...",,{|| ClaAut(nRecF1,.T.) } )
				EndIf
			endif
			Return
		EndIf
		If Empty(cNatu)
			DbSelectArea("SA2")
			DbSetOrder(1)
			cNatu := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NATUREZ")
		EndIf
		If IsInCallStack("U_F0400101")
			MsgRun("Aguarde... Realizando processo de classificação automática...",,{|| ClaAut(nRecF1,.T.) } )
		ElseIf cRot <> "TEWBTYP3"
			MsgRun("Aguarde... Realizando processo de classificação automática...",,{|| ClaAut(nRecF1) } )
		Else
			MsgRun("Aguarde... Realizando processo de classificação automática...",,{|| ClaAut(nRecF1,.T.) } )
		EndIf
	EndIf

	RestArea(aAreaD1)
	RestArea(aArea)
Return

Static Function ClaAut(nRecF1,lAnexo)

	Local aArea := FWGetArea()
	Local aCondc := {}
	Local nX := 0
	Local aTitulo := {}
	Local nCdControl := 0
	Local cTpNf := ""
	Local cUpd := ""
	Local aItem := {}
	Local aItens := {}
	Local nCount := 0
	Local cChavE2 := ""
	Local cQuery := ""
	Local cAlias := GetNextalias()

	Private lMsErroAuto := .F.
	PRIVATE XXDOC 		 := Space(TAMSX3("F1_DOC")[1])
	PRIVATE XXSERIE      := Space(TAMSX3("F1_SERIE")[1])
	PRIVATE XXFORN       := SPACE(TAMSX3("F1_FORNECE")[1])
	PRIVATE XXLOJA       := SPACE(TAMSX3("F1_LOJA")[1])

	Default lAnexo := .F.

	Begin Transaction
		DbSelectArea("SF1")
		SF1->(DbGoto(nRecF1))

		nCdControl := nTot

		aadd(aTitulo,{"F1_TIPO" ,SF1->F1_TIPO ,NIL})
		aadd(aTitulo,{"F1_FORMUL" ,SF1->F1_FORMUL ,NIL})
		aadd(aTitulo,{"F1_DOC" ,SF1->F1_DOC ,NIL})
		aadd(aTitulo,{"F1_SERIE" ,SF1->F1_SERIE ,NIL})
		aadd(aTitulo,{"F1_EMISSAO" ,SF1->F1_EMISSAO ,NIL})
		aadd(aTitulo,{"F1_DTDIGIT" ,DDATABASE ,NIL})
		aadd(aTitulo,{"F1_FORNECE" ,SF1->F1_FORNECE ,NIL})
		aadd(aTitulo,{"F1_LOJA" ,SF1->F1_LOJA ,NIL})
		aadd(aTitulo,{"F1_ESPECIE" ,SF1->F1_ESPECIE ,NIL})
		aadd(aTitulo,{"F1_COND" , SF1->F1_COND ,NIL})
		aadd(aTitulo,{"F1_DESPESA" ,SF1->F1_DESPESA ,NIL})
		aadd(aTitulo,{"F1_DESCONT" , SF1->F1_DESCONT ,Nil})
		aadd(aTitulo,{"F1_FRETE" , SF1->F1_FRETE ,Nil})
		aadd(aTitulo,{"F1_MOEDA" , 1 ,Nil})
		aadd(aTitulo,{"F1_TXMOEDA" , 1 ,Nil})
		aadd(aTitulo,{"F1_STATUS" , "A" ,Nil})
		aadd(aTitulo,{ 'F1_XTIPO'   , SF1->F1_XTIPO   , NIL })
		aadd(aTitulo,{ 'F1_DTLANC' ,  dDataBase, NIL })
		aadd(aTitulo,{ 'F1_XDTVNF'  , SF1->F1_XDTVNF  , NIL })
		aadd(aTitulo,{ 'F1_EST'     , SF1->F1_EST          , NIL })
		aadd(aTitulo,{ 'F1_XUSR'    , SF1->F1_XUSR    , NIL })



		cUPD := "UPDATE "+RETSQLNAME("SFT")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND "
		cUPD += " FT_FILIAL = '"+SF1->F1_FILIAL+"' AND FT_NFISCAL = '"+SF1->F1_DOC+"' AND FT_CLIEFOR = '"+SF1->F1_FORNECE+"' AND FT_LOJA = '"+SF1->F1_LOJA+"' "
		cUPD += " AND FT_SERIE = '"+SF1->F1_SERIE+"'"
		TCSqlExec(cUPD)
		conout("TCSQLError() " + TCSQLError())


		DbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While SD1->(!Eof()) .and. SD1->D1_FILIAL == SF1->F1_FILIAL  .and.;
				SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
				SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

			aItem := {}
			nCount++
			If lAnexo
				aadd(aItem,{"D1_ITEM" ,SD1->D1_ITEM,NIL})
				aadd(aItem,{"D1_COD" ,SD1->D1_COD ,NIL})
				aadd(aItem,{"D1_UM" ,SD1->D1_UM ,NIL})
				aadd(aItem,{"D1_LOCAL" ,SD1->D1_LOCAL ,NIL})
				aadd(aItem,{"D1_QUANT" ,SD1->D1_QUANT ,NIL})
				aadd(aItem,{"D1_VUNIT" ,SD1->D1_VUNIT ,NIL})
				aadd(aItem,{"D1_TOTAL" ,SD1->D1_TOTAL ,NIL})
				aadd(aItem,{"D1_TES" ,Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE") ,NIL})
				aadd(aItem,{"D1_RATEIO" ,SD1->D1_RATEIO ,NIL})
				aadd(aItem,{"D1_XCODCON",StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]),NIL})
				aAdd(aItem,{"LINPOS" , "D1_ITEM",  SD1->D1_ITEM})
				aadd(aItem,{ 'D1_VALDESC' , SD1->D1_VALDESC  , NIL })
				aadd(aItem,{ 'D1_CC'      , SD1->D1_CC      , NIL })
				aadd(aItem,{ 'D1_PEDIDO'  , SD1->D1_PEDIDO     , NIL })
				aadd(aItem,{ 'D1_ITEMPC'  , SD1->D1_ITEMPC    , NIL })
				aadd(aItem,{ 'D1_QTDPEDI' , SD1->D1_QTDPEDI   , NIL })
				aadd(aItem,{ 'D1_XPRIVEN' , SD1->D1_XPRIVEN  , NIL })
				aadd(aItem,{ 'D1_XJURMUL' , SD1->D1_XJURMUL , NIL })
				aadd(aItem,{ 'D1_VALFRE'  , SD1->D1_VALFRE  , NIL })
				aadd(aItem,{ 'D1_DESPESA' , SD1->D1_DESPESA , NIL })
				aadd(aItem,{ 'D1_SEGURO'  , SD1->D1_SEGURO  , NIL })
				aadd(aItem,{ 'D1_XMULTA'  , SD1->D1_XMULTA  , NIL })
				aadd(aItem,{ 'D1_XNATURE' , SD1->D1_XNATURE , NIL })
				aadd(aItem,{ 'D1_XOBS'    , SD1->D1_XOBS     , NIL })
				aadd(aItem,{ 'D1_XDESFIN' , SD1->D1_XDESFIN ,NIL })
			Else
				aadd(aItem,{"D1_ITEM" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_ITEM' } )] ,NIL})
				aadd(aItem,{"D1_COD" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_COD' } )] ,NIL})
				aadd(aItem,{"D1_UM" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_UM' } )] ,NIL})
				aadd(aItem,{"D1_LOCAL" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_LOCAL' } )] ,NIL})
				aadd(aItem,{"D1_QUANT" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_QUANT' } )] ,NIL})
				aadd(aItem,{"D1_VUNIT" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_VUNIT' } )] ,NIL})
				aadd(aItem,{"D1_TOTAL" ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_TOTAL' } )] ,NIL})
				aadd(aItem,{"D1_TES" ,Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE") ,NIL})
				aadd(aItem,{"D1_RATEIO" ,SD1->D1_RATEIO,NIL})
				aadd(aItem,{"D1_XCODCON",StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1]),NIL})
				aAdd(aItem,{"LINPOS" , "D1_ITEM",ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_ITEM' } )]  })
				aadd(aItem,{ 'D1_VALDESC'  ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_VALDESC'} )] ,NIL })
				aadd(aItem,{ 'D1_CC'       ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_CC'     } )] ,NIL })
				aadd(aItem,{ 'D1_PEDIDO'   ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_PEDIDO' } )] ,NIL })
				aadd(aItem,{ 'D1_ITEMPC'   ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_ITEMPC' } )] ,NIL })
				aadd(aItem,{ 'D1_XPRIVEN'  ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XPRIVEN'} )] ,NIL })
				aadd(aItem,{ 'D1_XJURMUL'  ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XJURMUL'} )] ,NIL })
				aadd(aItem,{ 'D1_VALFRE'   ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_VALFRE' } )] ,NIL })
				aadd(aItem,{ 'D1_DESPESA'  ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_DESPESA'} )] ,NIL })
				aadd(aItem,{ 'D1_SEGURO'   ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_SEGURO' } )] ,NIL })
				aadd(aItem,{ 'D1_XMULTA'   ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XMULTA' } )] ,NIL })
				aadd(aItem,{ 'D1_XNATURE'  ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XNATURE'} )] ,NIL })
				aadd(aItem,{ 'D1_XOBS'     ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XOBS'   } )] ,NIL })
				//aadd(aItem,{ 'D1_XDESFIN'  ,ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XDESFIN'} )] ,NIL })
				//aadd(aItem,{ 'D1_XDESFIN'  ,((ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XDESFIN'} )] - ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_TOTAL' } )])/(ACOLS[nCount][ascan( aheader , { |x| alltrim( x[2] ) == 'D1_TOTAL' } )])*100)) ,NIL })

			EndIf


			aAdd(aItens,aItem)

			SD1->(DbSkip())
		enddo

		MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aTitulo,aItens,4,{},{},{})

		If !lMsErroAuto
			SF1->(DbGoto(nRecF1))
			Reclock("SF1",.F.)
			SF1->F1_XSOLPAG := "1"
			SF1->(MsUnLock())
			XXDOC  := SF1->F1_DOC
			XXSERIE:= SF1->F1_SERIE
			XXFORN := SF1->F1_FORNECE
			XXLOJA := SF1->F1_LOJA

			/*/If !Empty(cNatu)
			cNatu := ", E2_NATUREZ = '"+AllTrim(cNatu)+"' "
		Else
			cNatu := " "
			EndIf/*/


			/*/cUPD := " UPDATE " + RETSQLNAME("SE2") + " SET E2_XCLAUT = '1', E2_XPRODNF = UTL_RAW.CAST_TO_RAW('"+cxProds+"')" + cNatu + ", E2_XCODCON = '"+StrZero(Val(STRTRAN(STRTRAN(cValToChar(SF1->F1_VALBRUT), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])+"' "
			cUPD += " WHERE D_E_L_E_T_ = ' ' AND E2_FILIAL = '"+XFILIAL("SE2")+"' AND E2_NUM = '"+StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])+"'"
			cUPD += " AND E2_PREFIXO = '"+XXSERIE+"' AND E2_FORNECE = '"+XXFORN+"' AND E2_LOJA = '"+XXLOJA+"'"
			TCSqlExec(cUPD)
			conout("TCSQLError() " + TCSQLError())/*/
			cChavE2 := xFilial("SE2") + XXFORN + XXLOJA + XXSERIE + StrZero(Val(XXDOC),TamSX3("E2_NUM")[1])
			aAReaSE2 := SE2->(FWGetArea())
			DbSelectArea("SE2")
			SE2->(DbSetOrder(06))
			SE2->(DbSeek(cChavE2))

			cQuery += " SELECT C7_FILIAL, C7_NUM, R_E_C_N_O_ REC FROM " + RetSqlName("SC7")
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND C7_FILIAL = '"+ SE2->E2_FILIAL +"' "
			cQuery += " AND C7_FORNECE = '"+ SE2->E2_FORNECE +"' "
			cQuery += " AND C7_LOJA = '"+ SE2->E2_LOJA+"'"
			cQuery += " AND C7_XSERIE  = '"+SE2->E2_PREFIXO+"'"
			cQuery += " AND C7_XDOC  = '"+SE2->E2_NUM+"' "

			dbUseArea(.T. , "TOPCONN" , TcGenQry(,,cQuery) , (cAlias) , .T. , .T.)

			(cAlias)->(DbGoTop())
			if !(cAlias)->(Eof())
				While !(cAlias)->(Eof())
					DbSelectArea("SC7")
					SC7->(DbGoTo((cAlias)->REC))
					RecLock("SC7", .F.)
					SC7->C7_ENCER := "E"
					SC7->C7_QUJE := SC7->C7_QUANT
					SC7->C7_QTDACLA := 0
					SC7->(MsUnlock())
					(cAlias)->(DbSkip())
				EndDo
			EndIf
			
			DbSelectArea("SD1")
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
			While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
				Reclock("SE2",.F.)
				if (SuperGetMV("MV_XPRDEST",,"") $ AllTrim(SC7->C7_PRODUTO) .Or. SuperGetMV("MV_XPRDNES",,"") $ AllTrim(SC7->C7_PRODUTO) .Or. SuperGetMV("MV_XPRDGPE",,"") $ AllTrim(SC7->C7_PRODUTO))
					SE2->E2_XCLAUT := ""
				else
					SE2->E2_XCLAUT := "1"
				endif
				SE2->E2_XPRODNF := cxProds
				SE2->E2_VENCREA := SD1->D1_XPRIVEN
				SE2->E2_VENCTO := SD1->D1_XPRIVEN
				SE2->E2_XDTORIG := SD1->D1_XPRIVEN
				If !Empty(cNatu)
					SE2->E2_NATUREZ := AllTrim(cNatu)
				EndIf
				SE2->E2_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(SE2->E2_VALOR), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
				SE2->(DbSkip())
			EndDo


		Else
			If !(IsBlind())
				PegaErro()
			EndIf
		EndIf

		/*/DbSelectArea("SF1")
		DbGoto(nRecF1)

		SF1->(DbGoto(nRecF1))
		Reclock("SF1",.F.)
		SF1->F1_STATUS := "A"
		SF1->F1_DTDIGIT := dDataBase
		SF1->(MsUnLock())
		cTpNf := SF1->F1_XTIPO
		aCondc := Condicao(nTot, SF1->F1_COND , , SF1->F1_DTDIGIT , , , , )
		nCdControl := nTot

		DbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		//If !lAnexo
		For nX := 1 To Len(aCondc)
			//BEGIN TRANSACTION? VERIFICAR...
			//AMANHÃ VERIFICAR SOBRE AS PARCELAS DO TÍTULO PELA COND PAGTO
			// Condicao(100, COD CONDICAO , , DATA EMISSAO , , , , )[nX][2] ESSA FUNÇÃO RETORNA UM ARRAY COM D VENCTO E VALOR DAS PARCELAS
			AAdd(aTitulo,{"E2_PREFIXO", SF1->F1_SERIE			, Nil})
			AAdd(aTitulo,{"E2_NUM"    , SF1->F1_DOC     		, Nil})
			AAdd(aTitulo,{"E2_PARCELA", cValToChar(nX)			, Nil})
			AAdd(aTitulo,{"E2_TIPO"   , "NF"    		, Nil})
			AAdd(aTitulo,{"E2_NATUREZ", cNatu                   , Nil})
			AAdd(aTitulo,{"E2_FORNECE", SF1->F1_FORNECE         , Nil})
			AAdd(aTitulo,{"E2_LOJA"   , SF1->F1_LOJA            , Nil})
			AAdd(aTitulo,{"E2_EMISSAO", SF1->F1_EMISSAO         , Nil})
			If nX == 1
				AAdd(aTitulo,{"E2_VENCTO" , SD1->D1_XPRIVEN           , Nil})
				AAdd(aTitulo,{"E2_VENCREA", SD1->D1_XPRIVEN           , Nil})
				AAdd(aTitulo,{"E2_VENCORI", SD1->D1_XPRIVEN         , Nil})
			Else
				AAdd(aTitulo,{"E2_VENCTO" , aCondc[nX][1]           , Nil})
				AAdd(aTitulo,{"E2_VENCREA", aCondc[nX][1]           , Nil})
				AAdd(aTitulo,{"E2_VENCORI", aCondc[nX][1]           , Nil})

			EndIf
			AAdd(aTitulo,{"E2_VALOR"  , aCondc[nX][2]           , Nil})//VERIFICAR O CÁLCULO PARA AS PARCELAS
			AAdd(aTitulo,{"E2_SALDO"  , aCondc[nX][2]           , Nil})
			AAdd(aTitulo,{"E2_MOEDA"  , 1          				, Nil})
			AAdd(aTitulo,{"E2_VLCRUZ" , aCondc[nX][2]           , Nil})
			AAdd(aTitulo,{"E2_CCUSTO" , cCCD1                   , Nil})
			AAdd(aTitulo,{"E2_XCLAUT" , "1"                     , Nil})
			AAdd(aTitulo,{"E2_XUSNOME", AllTrim(UsrFullName(__CUSERID)), NIL})
			AAdd(aTitulo,{"E2_XPRODNF", AllTrim(cxProds), NIL})
			AAdd(aTitulo,{"E2_XCODCON", StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("E2_XCODCON")[1]), NIL})
			AAdd(aTitulo,{"E2_XTPREQ", cTpNf, NIL})

			MsExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,3)
			aTitulo := {}

			If lMsErroAuto
				DisarmTransaction()
				Break
			Else
				SF1->(DbGoto(nRecF1))
				DbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				Reclock("SE2",.F.)
				fCompTit()
				SE2->(MsUnLock())
				DbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				While SD1->(!Eof()) .and. SD1->D1_FILIAL == SF1->F1_FILIAL  .and.;
						SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
						SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

					SD1->(RecLock("SD1",.F.))
					SD1->D1_TES := Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE")
					SD1->D1_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
					SD1->(MsUnLock())
					SD1->(DbSKip())
				EndDo

			EndIF
		Next nX
	Else
		cUpd := " UPDATE "+RETSQLNAME("SE2") " SET D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = 0 "
		cUpd += " WHERE D_E_L_E_T_ = '*' AND E2_FILIAL = '"SF1->F1_FILIAL+"' AND E2_NUM = '"SF1->F1_DOC+"'"
		cUpd += " AND E2_PREFIXO = '"+SF1->F1_SERIE+"' AND E2_FORNECE = '"+SF1->F1_FORNECE+""
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While SD1->(!Eof()) .and. SD1->D1_FILIAL == SF1->F1_FILIAL  .and.;
				SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
				SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

			SD1->(RecLock("SD1",.F.))
			SD1->D1_TES := Posicione("SBZ",1,SD1->D1_FILIAL+SD1->D1_COD, "BZ_TE")
			SD1->D1_XCODCON := StrZero(Val(STRTRAN(STRTRAN(cValToChar(nCdControl), ".", ""), ",", "")),TamsX3("D1_XCODCON")[1])
			SD1->(MsUnLock())
			SD1->(DbSKip())
		EndDo
		EndIf/*/
	End Transaction

	RestArea(aArea)
Return

/*/
Static Function fCompTit()

	local aArea     := FWGetArea()
	local lRet      := .T.
	local nPosCC    := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_CC'      } )
	local nPosRat   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_RATEIO'  } )
	local nPosIns   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XRETINS' } )
	local nPosLot   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_LOTEFOR' } )
	local nPosCCo   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XCODCON' } )
	local nPosVIt   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_TOTAL'   } )
	local nPosJur   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XJURMUL' } )
	local nPosMul   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XMULTA'  } )
	local nPosVen   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XPRIVEN' } )
	// local nPosXDes  := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XDESFIN' } )
	local nPosRec   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XCODREC' } )
	local nPosObs   := ascan( aheader , { |x| alltrim( x[2] ) == 'D1_XOBS' } )
	local aTitPar   := u_retparcela( SF1->F1_COND )
	local nQtdPar   := len( aTitPar )
	local nI        := 0
	local nValDes   := 0
	local nDesFin   := 0
	// local nDescNF   := 0
	local nJuros    := 0
	local nMulta    := 0
	local nTotPer   := 0
	// local nXDescF   := 0
	Local dDtOrig   := ""
	local lISSBaixa := getnewpar(  'MV_MRETISS' , '1' ) == '2'
	local lPCCBaixa := supergetmv( 'MV_BX10925' , .T. , '2' ) == '1' .AND. ;
		( !empty( SE5->( fieldpos( 'E5_VRETPIS' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_VRETCOF' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_VRETCSL' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_PRETPIS' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_PRETCOF' )))     .AND. ;
		!empty( SE5->( fieldpos( 'E5_PRETCSL' )))     .AND. ;
		!empty( SE2->( fieldpos( 'E2_SEQBX'   )))     .AND. ;
		!empty( SFQ->( fieldpos( 'FQ_SEQDES'  )))           )
// ------------------------------------
//  alert( '[ MT100GE2 ] Inicio')
// ------------------------------------
	If SC7->(FieldPos("C7_XDESFIN")) > 0
		nDesFin := posicione( 'SC7' , 1 , xfilial( 'SC7' ) + SD1->D1_PEDIDO , 'C7_XDESFIN' )
	EndIf

	for nI := 1 to len( aCols )

		if !aCols[nI][len( aCols[nI] ) ]
// ------------------------------------
//          posicione( 'SC7' , 2 , xfilial( 'SC7' ) + aCols[nI][nPosCod] + SD1->D1_FORNECE + SD1->D1_LOJA + aCols[nI][nPosPed] , 'C7_XDESFIN' )
// ------------------------------------
			nTotPer += noround( ( ( nDesFin * aCols[nI][nPosVIt] ) / SE2->E2_VALOR ) , 3 )
		endif

		If nPosJur > 0
			nJuros  += aCols[nI][nPosJur ] // despesa
		EndIf
		If nPosMul > 0
			nMulta  += aCols[nI][nPosMul ]
		EndIf
// ------------------------------------
//      nXDescF += aCols[nI][nPosXDes] // desconto financeiro da sol. de pagto
// ------------------------------------

	next nI

	nTotPer := round( nTotPer , 1 ) / nQtdPar
	nValDes += ( nTotPer * SE2->E2_VALOR ) / 100 // desconto financeiro do pedido

// ------------------------------------
//  if SF1->F1_DESCONT > 0
//      nDescNF := SF1->F1_DESCONT / nQtdPar // desconto da nota 
//  endif
// ------------------------------------

	If SF1->(FieldPos("F1_XSOLPAG")) > 0
		if SF1->F1_XSOLPAG == '1'
			nValDes := nDesFin // nXDescF // desconto finaceiro da solicitação de pagamento
		endif
	EndIf

// ------------------------------------
//    if aTitPar[1][1] == SE2->E2_VENCTO .OR. ;
//       nQtdPar       <= 1
// ------------------------------------
//  [ somente primeira parcela ]
// ------------------------------------
/*/
/*/Tratativa para a alteração do tamanho do campo E2_PARCELA
	A função anterior foi deixada para que não seja diferente caso a base não tenha alteração no tamanho do campo
Lucas Miranda de Aguiar 21/02/2022/*/

	/*/If TamSx3("E2_PARCELA")[1] > 1

	if empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
			AllTrim(SE2->E2_PARCELA) == '1' .OR. ;
			SE2->E2_PARCELA == Replicate("a",TamSx3("E2_PARCELA")[1]) .OR. ;
			SE2->E2_PARCELA == Replicate("A",TamSx3("E2_PARCELA")[1]) .OR. ;
			SE2->E2_PARCELA == Replicate("0",(TamSx3("E2_PARCELA")[1] - 1)) + "1"

		SE2->E2_DECRESC := nValDes // desconto financeiro + desconto no momento da classificaçao
		SE2->E2_SDDECRE := nValDes
		SE2->E2_JUROS   := nJuros
		SE2->E2_MULTA   := nMulta
	EndIf
Else
	if empty( alltrim( SE2->E2_PARCELA ))    .OR. ;
			SE2->E2_PARCELA = '1' .OR. ;
			SE2->E2_PARCELA = 'a' .OR. ;
			SE2->E2_PARCELA = 'A'
// ------------------------------------
		SE2->E2_DECRESC := nValDes // desconto financeiro + desconto no momento da classificaçao
		SE2->E2_SDDECRE := nValDes
		SE2->E2_JUROS   := nJuros
		SE2->E2_MULTA   := nMulta
// ------------------------------------
	endif
// ------------------------------------
EndIf

// Rafael Yera Barchi - 20/08/2021
// Chamado 12248559
// Gravação do campo Risco Sacado para que o título seja gerado conforme cadastro do fornecedor
If SE2->(FieldPos("E2_XRISCOS")) > 0 .And. SA2->(FieldPos("A2_XRISSAC")) > 0
	SE2->E2_XRISCOS := SA2->A2_XRISSAC
EndIf


//Lucas Miranda de Aguiar - Inicio
If SE2->(FieldPos("E2_XOBSSP")) > 0 .And. nPosObs > 0
	SE2->E2_XOBSSP := aCols[1][nPosObs]
EndIf
If SE2->(FieldPos("E2_XHRCLAS")) > 0
	SE2->E2_XHRCLAS := Time()
EndIf
If SE2->(FieldPos("E2_XDTORIG")) > 0 .And. SF1->(FieldPos("F1_XDTORIG")) > 0
	SE2->E2_XDTORIG := SF1->F1_XDTORIG
EndIf
If SE2->(FieldPos("E2_XDTEXCE")) > 0 .And. SF1->(FieldPos("F1_XDTEXCE")) > 0
	SE2->E2_XDTEXCE := SF1->F1_XDTEXCE
EndIf
If SE2->(FieldPos("E2_XVALNOM")) > 0 .And. SF1->(FieldPos("F1_XVALNOM")) > 0
	SE2->E2_XVALNOM := SF1->F1_XVALNOM
EndIf

If SF1->(FieldPos("F1_XSOLPAG")) > 0 .And. SE2->(FieldPos("E2_XDTORIG")) > 0 .And. SE2->(FieldPos("E2_XDTEXCE")) > 0
	If SF1->F1_XSOLPAG <> '1'
		dDtOrig := fGetDtOri()
		If TYPE ("xfDtExce") == "C"
			SE2->E2_XDTEXCE := xfDtExce
			SE2->E2_XDTORIG := dDtOrig

			Reclock("SF1",.F.)
			SF1->F1_XDTEXCE := xfDtExce
			SF1->F1_XDTORIG := dDtOrig
			SF1->(MsUnlock())
		EndIf
	EndIf
EndIf

If SE2->(FieldPos("E2_XDTFIX")) > 0 .And. SA2->(FieldPos("A2_XDTFIX")) > 0
	If Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_XDTFIX") == "1"
		SE2->E2_XDTFIX := "1"
	Else
		SE2->E2_XDTFIX := "2"
	EndIf
EndIf
//Fim

If nPosIns > 0
	SE2->E2_RETINS  := aCols[1][nPosIns]
EndIf

If nPosRec > 0
	if empty( alltrim( SE2->E2_CODRET ))
		SE2->E2_CODRET := aCols[1][nPosRec]
	endif
EndIf

If nPosRat > 0
	if aCols[1][nPosRat] = '2'
		SE2->E2_CCUSTO := aCols[1][nPosCC]
	endif
EndIf

If nPosLot > 0
	SE2->E2_HIST    := aCols[1][nPosLot]
EndIf
If SE2->(FieldPos("E2_XVLBRUT")) > 0
	SE2->E2_XVLBRUT := SF1->F1_VALMERC // nQtdPar
EndIf
If SE2->(FieldPos("E2_XTPREQ")) > 0 .And. SF1->(FieldPos("F1_XTIPO")) > 0
	SE2->E2_XTPREQ  := SF1->F1_XTIPO
EndIf
If SE2->(FieldPos("E2_XCGCFOR")) > 0
	SE2->E2_XCGCFOR := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SE2->( E2_FORNECE + E2_LOJA ) , 'A2_CGC'     )
EndIf
If SE2->(FieldPos("E2_XFORPAG")) > 0
	SE2->E2_XFORPAG := posicione( 'SA2' , 1 , xfilial( 'SA2' ) + SE2->( E2_FORNECE + E2_LOJA ) , 'A2_XCNPJPG' )
EndIf
If SE2->(FieldPos("E2_XDTAPRO")) > 0
	SE2->E2_XDTAPRO := SF1->F1_RECBMTO
EndIf
If SE2->(FieldPos("E2_XUSNOME")) > 0
	SE2->E2_XUSNOME := usrfullname( retcodusr() )
Endif
If SE2->(FieldPos("E2_XDTINT")) > 0
	SE2->E2_XDTINT  := date()
EndIf

If SE2->(FieldPos("E2_XVLLIQ")) > 0

	SE2->E2_XVLLIQ  := SE2->( E2_VALOR + E2_MULTA + E2_JUROS + E2_ACRESC - E2_DECRESC )

	if lPCCBaixa
		SE2->E2_XVLLIQ -= SE2->( E2_PIS + E2_COFINS + E2_CSLL )
	endif

	if lISSBaixa
		SE2->E2_XVLLIQ -= SE2->E2_ISS
	endif

EndIf

If ExistBlock("PORTAUTO")
	SE2->E2_PORTADO := u_portauto( 'E2_PORTADO' )
EndIf
If SE2->(FieldPos("E2_XAGEPOR")) > 0
	SE2->E2_XAGEPOR := u_portauto( 'E2_XAGEPOR' )
EndIf
If SE2->(FieldPos("E2_XDVAPOR")) > 0
	SE2->E2_XDVAPOR := u_portauto( 'E2_XDVAPOR' )
EndIf
If SE2->(FieldPos("E2_XCONPOR")) > 0
	SE2->E2_XCONPOR := u_portauto( 'E2_XCONPOR' )
EndIf
If SE2->(FieldPos("E2_XDVCPOR")) > 0
	SE2->E2_XDVCPOR := u_portauto( 'E2_XDVCPOR' )
EndIf

if SE2->E2_PORTADO == SE2->E2_FORBCO
	SE2->E2_FORMPAG := '01' // Transf. Conta Corrente
else
	SE2->E2_FORMPAG := '41' // TED
endif

if isincallstack( 'U_F1000301' )

	If SE2->(FieldPos("E2_XCODCON")) > 0
		SE2->E2_XCODCON := aCols[1][nPosCCo]
	EndIf

	if nQtdPar <= 1

		If nPosVen > 0
			if !empty( aCols[1][nPosVen] )
				SE2->E2_VENCTO  :=             aCols[1][nPosVen]
				SE2->E2_VENCREA := datavalida( aCols[1][nPosVen] , .T. )
			endif
		EndIf

	endif

endif
/*/
	/*/	//Gian 25/08/2021
If FindFunction('U_F2000418')
	U_F2000418() //Grava Operação Financeira do XRT no título
EndIf
/*//*/
restarea( aArea )

return lRet

Static Function fGetDtOri()

	Local aArea := FWGetArea()
	Local dData := Condicao(100, SF1->F1_COND , , SF1->F1_EMISSAO , , , , )[1][1]



	RestArea(aArea)
Return dData
/*/


/*
 * ===================================================================================
 * Data       : 24/06/2025
 * Autor      : TOTVS
 * Descrição  : Rotina de tratamento de erro para execução automática ou com interface.
 *              Esta função garante o uso correto da função MostraErro(), conforme
 *              orientações do CodeAnalysis TOTVS, evitando falhas em rotinas automáticas.
 *
 * Parâmetros : cDir Diretorio onde será armazenado o arquivo de erro.
 *
 * Retorno    : cError - String contendo a mensagem de erro em caso de execução sem interface.
 *              Quando há interface, a função apenas exibe o erro via MostraErro().
 *
 * Referências:
 * - TDN: https://tdn.totvs.com/pages/releaseview.action?pageId=6815088
 * ===================================================================================
 */

Static Function PegaErro(cDir)
    Local cError := ""
 

	Default cDir := "c:\temp\"

    If !IsBlind()  // Verifica se há interface gráfica
        MostraErro()
    Else
        cError := MostraErro(cDir, "error.log") // Armazena a mensagem de erro em log
        ConOut(PadC("Automatic routine ended with error", 80))
        ConOut("Error: " + cError)
    EndIf

Return(cError)
