#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#Include 'TopConn.Ch'
#Include "TbiConn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"


User Function FCADP38()

	Local aRotAdic := {}
	Local bOK  := {||, fVeriDup()}
	Local aButtons := {}

	If cUsername == 'lucas.miranda'
		aadd(aRotAdic,{ "Carga de produtos","U_P38CRGPRD", 0 , 6 })
	EndIf

	AxCadastro("P38", "Produtos Classificação Automática", "U_fP38DEL()", "U_fP38OK()", aRotAdic, , bOK, , , , , aButtons, , )

Return(.T.)


User Function fP38DEL()
	Help(NIL, NIL, "Cadastro de produtos para classificação automática", NIL, "A deleção de registros está desativada para esta rotina.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"O produto deve ser inativado na função ALTERAR."})
Return
User Function fP38OK()

	Local aArea := GetArea()
	Local lRet := .T.



	RestArea(aArea)
Return lRet

Return



Static Function fVeriDup()
	Local aArea := GetArea()
	Local lRet := .T.
	Local cQuery := ""
	Local cAliasP38 := GetNextAlias()

	If ALTERA
		If M->P38_ATIVO == "1"
			cQuery := "SELECT * FROM " + RetSqlName("P38")
			cQuery += " WHERE D_E_L_E_T_ = ' ' AND P38_ATIVO = '1' AND P38_PRODUT = '"
			If Empty(M->P38_PRODUT)
				cQuery += P38->P38_PRODUT
			Else
				cQuery += M->P38_PRODUT
			EndIf
			cQuery += "'"
			If Select( cAliasP38 ) > 0
				( cAliasP38 )->( DbCloseArea() )
			EndIf

			TcQuery cQuery Alias ( cAliasP38 ) New

			IF (cAliasP38)->(!EOF()) .And. M->P38_ATIVO == '1'
				lRet := .F.
				Help(NIL, NIL, "Cadastro de produtos para classificação automática", NIL, "Já existe um produto com o mesmo código e status ATIVO na tabela.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do produto na tabela."})
				//Alert("Já existe um produto com o mesmo código e status ATIVO na tabela. ")
			EndIf
		EndIf
	ElseIf INCLUI

		cQuery := "SELECT * FROM " + RetSqlName("P38")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND P38_ATIVO = '1' AND P38_PRODUT = '"
		cQuery += M->P38_PRODUT + "'"

		If Select( cAliasP38 ) > 0
			( cAliasP38 )->( DbCloseArea() )
		EndIf

		TcQuery cQuery Alias ( cAliasP38 ) New

		IF (cAliasP38)->(!EOF()) .And. M->P38_ATIVO == '1'
			lRet := .F.
			Help(NIL, NIL, "Cadastro de produtos para classificação automática", NIL, "Já existe um produto com o mesmo código e status ATIVO na tabela.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do produto na tabela."})
			//Alert("Já existe um produto com o mesmo código e status ATIVO na tabela. ")
		EndIf
	EndIf

	If lRet

		DbSelectArea("SB1")
		DbSetOrder(1)
		If SB1->(DbSeek(xFilial("SB1")+M->P38_PRODUT))
			If SB1->B1_MSBLQL == "1"
				Help(NIL, NIL, "Cadastro de produtos para classificação automática", NIL, "O produto está bloqueado na tabela SB1.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do produto na tabela SB1."})
				//Alert("O produto está bloqueado na tabela SB1.")
				lRet := .F.
				Return lRet
			ElseIf SB1->B1_XESTOQ == "S"
				Help(NIL, NIL, "Cadastro de produtos para classificação automática", NIL, "Não é permitido o cadastro de produtos estocáveis na tabela P38.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do produto."})
				//Alert("Não é permitido o cadastro de produtos estocáveis na P38.")
				lRet := .F.
				Return lRet
			EndIf
		Else
			Help(NIL, NIL, "Cadastro de produtos para classificação automática", NIL, "O código de produto informado não existe na tabela SB1! Verificar o cadastro.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do produto na tabela SB1."})
			//Alert("O código de produto informado não existe na tabela SB1! Verificar o cadastro.")
			lRet := .F.
			Return lRet
		EndIf
	EndIf
	RestArea(aArea)
Return lRet


User Function P38CRGPRD()

	Local aArea   := GetArea()
	Local cDirIni := GetTempPath()
	Local cTipArq := "*.txt"
	Local cTitulo := "Seleção de Múltiplos Arquivos para Processamento"
	Local lSalvar := .F.
	Local cArqSel := ""
	Local nHdl := 0
	Local nLinhas := 0
	Local nTamArq := 0
	Local aInclui := {}
	Local aSays := {}
	Local aButtons := {}
	Local nOpcao := 0

	AADD(aSays,OemToAnsi("Importação do arquivo .TXT com os produtos."))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Clique no botão OK para prosseguir com a rotina."))

	AADD(aButtons, { 1, .T., {|o| nOpcao := 1, o:oWnd:End()}} )
	AADD(aButtons, { 2, .T., {|o| nOpcao := 2, o:oWnd:End()}} )

	FormBatch(cTitulo, aSays, aButtons,, 200, 530)

	If nOpcao == 1

		DbSelectArea("P38")
		DbSetOrder(1)
		cArqSel := tFileDialog(;
			cTipArq,;                  // Filtragem de tipos de arquivos que serão selecionados
		cTitulo,;                  // Título da Janela para seleção dos arquivos
		,;                         // Compatibilidade
		cDirIni,;                  // Diretório inicial da busca de arquivos
		lSalvar,;                  // Se for .T., será uma Save Dialog, senão será Open Dialog
		GETF_MULTISELECT;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
		)

		If ! Empty(cArqSel)
			nHdl := fOpen(cArqSel)

			fSeek(nHdl, 0, 0)
			nTamArq := fSeek(nHdl, 0, 2)
			fSeek(nHdl, 0, 0)
			fClose(nHdl)
			FT_fUse(cArqSel)
			FT_fGoTop()
			nTamLinha := Len(FT_fReadln())
			FT_fGoTop()
			nLinhas := FT_FLastRec()

			While !FT_FEOF()

				cLinha := FT_FREADLN()

				aInclui := strtokarr(cLinha, ";")

				If (aInclui[1] <> ' ' .And. aInclui[2] <> ' ')
					If P38->(DbSeek(xFilial("P38")+aInclui[1]))
						Reclock("P38",.F.)
						P38->P38_NATU := aInclui[2]
						P38->(MsUnlock())
					Else
						Reclock("P38",.T.)
						P38->P38_PRODUT := aInclui[1]
						P38->P38_NATU := aInclui[2]
						P38->(MsUnlock())
					EndIf
				EndIf

				FT_FSKIP()
			End
		EndIf
	Endif
	RestArea(aArea)
Return
