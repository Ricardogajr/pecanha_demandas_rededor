#INCLUDE "DIRECTRY.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#DEFINE MODEL_OPERATION_VIEW 1
#DEFINE MODEL_OPERATION_INSERT 3
#DEFINE MODEL_OPERATION_UPDATE 4
#DEFINE MODEL_OPERATION_DELETE 5
#DEFINE MODEL_OPERATION_ONLYUPDATE 6
Static CDIRTMP := GetTempPath()
/*/{Protheus.doc} RHDIVE04

	Efetua a importação da SRA - Diversidade

	@type Function User
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210
	@Obs.
	
		Se campo RA_FILIAL + RA_MAT  - Chave
		
		Se encontrou e está vazio:
			
			gravar os dados da tabela enviada
		
			SRA->RA_XGENERO
			SRA->RA_XNAMESO
			SRA->RA_XUSASOC


/*/
User Function RHDIVE04()
	Local aArea                       := GetArea()
	Local nJanAltu                    := 180
	Local nJanLarg                    := 650
	Local oBtnArq
	Local oBtnImp
	Local oBtnObri
	Local oBtnSair
	Local oGrpAco
	Local oGrpPar
	Private aIteTip                   := {}
	Private oDlgPvt
	Private oSayArq, oGetArq, cGetArq := Space(400)
	Private oSayCar, oGetCar, cGetCar := ';'
	Private oSayTip, oCmbTip, cCmbTip := ""

	//Dimensões da janela
	//Objetos da tela
	//Inserindo as opções disponíveis no Carga Dados Genérico
	aIteTip := {;
		"01=Diversidade",;
		}
	cCmbTip := aIteTip[1]

	//Criando a janela
	DEFINE MSDIALOG oDlgPvt TITLE "Carga Dados - Genérico" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Grupo Parâmetros
	@ 003, 003 	GROUP oGrpPar TO 060, (nJanLarg/2) 	PROMPT "Parâmetros: " 		OF oDlgPvt COLOR 0, 16777215 PIXEL
	//Caminho do arquivo
	@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"                  SIZE 060, 007 OF oDlgPvt PIXEL
	@ 010, 070 MSGET      oGetArq VAR    cGetArq                     SIZE 240, 010 OF oDlgPvt PIXEL
	oGetArq:bHelp := {||	ShowHelpCpo(	"cGetArq",;
		{"Arquivo CSV ou TXT que será importado."+CRLF+"Exemplo: C:\teste.CSV"},2,;
		{},2)}
	@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlgPvt ACTION (fPegaArq()) PIXEL

	//Tipo de Importação
	@ 028, 006 SAY        oSayTip PROMPT "Tipo Importação:"          SIZE 060, 007 OF oDlgPvt PIXEL
	@ 025, 070 MSCOMBOBOX oCmbTip VAR    cCmbTip ITEMS aIteTip       SIZE 100, 010 OF oDlgPvt PIXEL
	oCmbTip:bHelp := {||	ShowHelpCpo(	"cCmpTip",;
		{"Tipo de Importação que será processada."+CRLF+"Exemplo: 1 = Diversidade"},2,;
		{},2)}

	//Caracter de Separação do CSV
	@ 043, 006 SAY        oSayCar PROMPT "Carac.Sep.:"               SIZE 060, 007 OF oDlgPvt PIXEL
	@ 040, 070 MSGET      oGetCar VAR    cGetCar                     SIZE 030, 010 OF oDlgPvt PIXEL VALID fVldCarac()
	oGetArq:bHelp := {||	ShowHelpCpo(	"cGetCar",;
		{"Caracter de separação no arquivo."+CRLF+"Exemplo: ';'"},2,;
		{},2)}

	//Grupo Ações
	@ 063, 003 	GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2) 	PROMPT "Ações: " 		OF oDlgPvt COLOR 0, 16777215 PIXEL

	//Botões
	@ 070, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"              SIZE 60, 014 OF oDlgPvt ACTION (oDlgPvt:End()) PIXEL
	@ 070, (nJanLarg/2)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"      	   SIZE 60, 014 OF oDlgPvt ACTION (Processa({|| fConfirm(1) }, "Aguarde...")) PIXEL
	@ 070, (nJanLarg/2)-(63*3)  BUTTON oBtnObri PROMPT "Camp.Estrutura"    SIZE 60, 014 OF oDlgPvt ACTION (Processa({|| fConfirm(3) }, "Aguarde...")) PIXEL
	ACTIVATE MSDIALOG oDlgPvt CENTERED

	RestArea(aArea)
Return
/*/{Protheus.doc} fVldCarac
	Função que valida o caracter de separação digitado
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fVldCarac()
	Local cInvalid := " './\"+' "'
	Local lRet     := .T.

	//Se o caracter estiver contido nos que não podem, retorna erro
	If cGetCar $ cInvalid
		lRet := .F.
		MsgAlert("Caracter inválido, ele não estar contido em <b>"+cInvalid+"</b>!", "Atenção")
	EndIf
Return lRet
/*/{Protheus.doc} fPegaArq
	Função responsável por pegar o arquivo de importação
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fPegaArq()
	Local cArqAux := ""
	cArqAux := cGetFile( "Arquivo Texto | *.csv",; 	// Máscara
	"Arquivo...",; 									// Título
	,; 												// Número da máscara
	,; 												// Diretório Inicial
	.F.,; 											// .F. == Abrir; .T. == Salvar
	GETF_LOCALHARD,; 								// Diretório full. Ex.: 'C:\TOTVS\arquivo.csv'
	.F.) 											// Não exibe diretório do servidor

	//Caso o arquivo não exista ou estiver em branco ou não for a extensão txt
	If Empty(cArqAux) .Or. !File(cArqAux) .Or. (SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "txt" .And. SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "csv")
		MsgStop("Arquivo <b>inválido</b>!", "Atenção")

		//Senão, define o get
	Else
		cGetArq := PadR(cArqAux, len(cArqAux))
		oGetArq:Refresh()
	EndIf

Return
/*/{Protheus.doc} fConfirm
	Função de confirmação da tela principal
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fConfirm(nTipo)
	Local aAux         := {}
	Local aHead        := {}
	Local aOriginal    := {}
	Local aTabela      := {}
	Local aUnic        := {}
	Local cAux         := ""
	Local cFunBkp      := FunName()
	Local cMsg         := ""
	Local nAux         := 0
	Local nModBkp      := nModulo
	Local nX           := 0
	Local oFile        := Nil
	Private aAI0Auto   := {}
	Private aCampos    := {}
	Private aDBStruct  := {}
	Private aHeadImp   := {}
	Private aRotina    := {}
	Private aStruTmp   := {}
	Private cAliasTmp  := ""
	Private cCampoChv  := ""
	Private cCampTipo  := ""
	Private cChvUnic   := ""
	Private cFiles
	Private cFilialTab := ""
	Private cLinhaCab  := ""
	Private cMark      := "OK"
	Private cRotina    := ""
	Private cTabela    := ""
	Private lChvProt   := .F.
	Private lFilProt   := .F.
	Private nTotalReg  := 0
	Private oBrowChk
	Private oModel     := Nil
	Default nTipo      := 2

	If cCmbTip == "01"
		cTabela    := "SRA"
		cCampoChv  := ""
		cChvUnic   := Posicione("SIX",1, cTabela + cValToChar( 1 ) ,"CHAVE")
		cFilialTab := FWxFilial(cTabela)
		nModulo    := 7
		aTabela  := (cTabela)->(DBStruct())

		For nX:=1 to len(aTabela)
			If Alltrim(aTabela[nX][1]) $ 'RA_FILIAL|RA_MAT|RA_XGENERO|RA_XNAMESO|RA_XUSASOC|RA_XCODRAC'
				AADD(aDBStruct,{aTabela[nX][1],aTabela[nX][2],aTabela[nX][3],aTabela[nX][4]} )
			EndIf
		Next

	Else
		nModulo	:= nModBkp
		MsgStop("Opção <b>Inválida</b>!", "Atenção")
		Return
	EndIf

	//Importação dos dados
	If nTipo == 1
		//Se o arquivo existir
		oFile := FwFileReader():New(cGetArq)

		If File(cGetArq) .And.  oFile:Open()

			aOriginal := oFile:GetAllLines() // ACESSA TODAS AS LINHAS

			nTotalReg := len(aOriginal) // TOTAL DE LINHAS

			If nTotalReg <= 0
				MsgAlert("Arquivo inválido, não possui cabeçalho ou está vazio <b>0</b> linhas!", "Atenção")
				//Se o total de registros for menor que 2, arquivo inválido
			ElseIf nTotalReg < 2
				MsgAlert("Arquivo inválido, possui menos que <b>2</b> linhas!", "Atenção")
				//Senão, chama a tela de observação e depois a importação
			Else
				//Pegando o cabeçalho
				cLinhaCab := aOriginal[1]

				aHead     := StrTokArr2(cLinhaCab, ";")
				nTotalReg := ( nTotalReg - 1 ) // Retirando o cabeçalho para correto contador de registros
				//Pegando os itens
				ADel(aOriginal, 1)
				ASize(aOriginal, Len(aOriginal) - 1)

				//Monta tabela temporária
				cAliasTmp 		:= fMontaTmp()
				cObrigatorio 	:= fObrigat(.F.)

				cLinhaCab := Iif(SubStr(cLinhaCab, Len(cLinhaCab)-1, 1) == ";", SubStr(cLinhaCab, 1, Len(cLinhaCab)-1), cLinhaCab)
				aAux  := Separa(UPPER(cLinhaCab), cGetCar)
				aUnic := Separa(UPPER(cObrigatorio),cGetCar)

				//Percorrendo o aAux e adicionando no array
				For nAux := 1 To Len(aAux)
					cAux := GetSX3Cache(aAux[nAux], 'X3_TIPO')

					//Se o título estiver em branco, quer dizer que o campo não existe, então é um campo reservado do execauto (como o LINPOS)
					If Empty(GetSX3Cache(aAux[nAux], 'X3_TITULO'))
						cCampTipo += aAux[nAux]+";"
					EndIf

					//Adiciona na grid
					aAdd(aHeadImp, { 						  aAux[nAux],; //Campo
					Iif(Empty(cAux), ' ' , cAux),; //Tipo
					.F.})  //Excluído
				Next

				For nAux := 1 To Len(aUnic) // Valida se os campos obrigatorios não estão presentes no arquivo importado

					If ! ( aScan( aAux , aUnic[nAux] ) > 0 )
						FWAlertError('<font color="#0F0F00" size="50">Falta campos obrigatórios !!</font>' ,"Baixe o modelo da planilha ou txt contendo os campos obrigatórios necessários")
						fObrigat()
						Return .F.
					EndIf

				Next

				For nAux := 1 To Len(aAux) // Valida se os campos enviados não estão presentes no dicionarios de dados

					If aScan( aDBStruct, { |x| AllTrim( x[1] ) ==  Alltrim(aAux[nAux]) } )  <= 0
						cMsg +=  aAux[nAux] + cGetCar
					EndIf

				Next

				If fValCamp(cMsg) //Se campos foram passados no arquivo mas não existem no dicionário

					//Chama a rotina de importação
					fImport(aOriginal)

					//Se houve erros na rotina
					(cAliasTmp)->(DbGoTop())
					If ! (cAliasTmp)->(EoF())
						fTelaErro()

						//Senão, mostra mensagem de sucesso
					Else

						fOkImport(aOriginal)
						FWAlertSuccess("Importação finalizada com Sucesso!", "Atenção")

					EndIf
				EndIf

				//Fechando a tabela e excluindo o arquivo temporário
				(cAliasTmp)->(DbCloseArea())
				fErase(cAliasTmp + GetDBExtension())
			EndIf

			//Senão, mostra erro
		Else
			MsgAlert("Arquivo inválido / não encontrado!", "Atenção")
		EndIf

	ElseIf nTipo == 3
		fCriar()
	EndIf

	nModulo := nModBkp
	SetFunName(cFunBkp)

	FREEOBJ(oFile)

Return
/*/{Protheus.doc} fObrigat
	Função que gera os campos obrigatórios em CSV / TXT
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fObrigat(lTela)
	Local aArea     := GetArea()
	Local cArquivo  := "obrigatorio."
	Local cFieldMy  := SuperGetMV("CG_MYFIELD", .T. , "RA_FILIAL|RA_MAT|RA_XGENERO|RA_XNAMESO|RA_XUSASOC|RA_XCODRAC" ) // Campo não é obrigatorio mas tem que ser importado
	Local cCaminho  := ""
	Local cConteud  := ""
	Local nAux      := 0
	Local cExtensao := ""
	Default lTela   := .T.

	cCaminho  := CDIRTMP

	//Enquanto houver registros na SX3 e for a mesma tabela
	For nAux := 1 To Len(aDBStruct) //Se o campo for obrigatório

		If lTela

			//If  X3Obrigat(aDBStruct[nAux][1]) .Or. ( aDBStruct[nAux][1] $ cChvUnic )  .Or. ( aDBStruct[nAux][1] $ cFieldMy )
			If  X3Obrigat(aDBStruct[nAux][1]) .Or. aDBStruct[nAux][1] $ cFieldMy
				cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
			EndIf

		Else

			If  ( X3Obrigat(aDBStruct[nAux][1])  ) .Or. ( aDBStruct[nAux][1] $ cChvUnic )  .Or. ( aDBStruct[nAux][1] $ cFieldMy )

				//Se for o campo filial
				If '_FILIAL' $ aDBStruct[nAux][1]
					//Se a filial for conforme o protheus
					If  lFilProt
						cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
					EndIf
				ELSEIf Alltrim(aDBStruct[nAux][1]) $ Alltrim(cCampoChv)
					//Se a chave for conforme o protheus
					If  lChvProt
						cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
					EndIf
				ELSE
					cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
				EndIf

			EndIf

		EndIf

	Next nAux

	cConteud := Iif(!Empty(cConteud), SubStr(cConteud, 1, Len(cConteud)-1), "")

	If lTela

		//Se escolher csv
		If MsgYesNo("Deseja gerar o layout na extensão <b>csv</b>?", "Atenção")
			cExtensao := "csv"

			//Senão, será csv
		ElseIf MsgYesNo("Deseja gerar o layout na extensão <b>txt</b>?", "Atenção")
			cExtensao := "txt"
		EndIf
		//Gera o arquivo
		MemoWrite(cCaminho+cArquivo+cExtensao, cConteud)

		//Tentando abrir o arquivo
		nRet := ShellExecute("open", cArquivo+cExtensao, "", cCaminho, 1)

		//Se houver algum erro
		If nRet <= 32
			MsgStop("Não foi possível abrir o arquivo <b>"+cCaminho+cArquivo+cExtensao+"</b>!", "Atenção")
		EndIf

	EndIf

	RestArea(aArea)

Return cConteud

/*/{Protheus.doc} fCriar
	Função que gera os campos não encontrados no dicionario de dados em CSV / TXT
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fCriar(lTela)
	Local aArea     := GetArea()
	Local cArquivo  := "estrutura."
	Local cCaminho  := ""
	Local cConteud  := ""
	Local nAux      := 0
	Local cExtensao := ""
	Default lTela   := .T.

	cCaminho  := CDIRTMP

	//Enquanto houver registros na SX3 e for a mesma tabela
	For nAux := 1 To Len(aDBStruct) //Se o campo for obrigatório

		//Se for o campo filial
		If '_FILIAL' $ aDBStruct[nAux][1]
			//Se a filial for conforme o protheus
			If ! lFilProt
				cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
			EndIf
		ELSEIf  Alltrim(aDBStruct[nAux][1]) $ Alltrim(cCampoChv)
			//Se a chave for conforme o protheus
			If ! lChvProt
				cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
			EndIf
		ELSE
			cConteud += Alltrim(aDBStruct[nAux][1])+cGetCar
		EndIf

	Next

	cConteud := Iif(!Empty(cConteud), SubStr(cConteud, 1, Len(cConteud)-1), "")

	If lTela

		//Se escolher txt
		If MsgYesNo(" Deseja gerar o arquivo de estrutura com a extensão <b>txt</b>?", "Atenção")
			cExtensao := "txt"

			//Senão, será csv
		Else
			cExtensao := "csv"
		EndIf
		//Gera o arquivo
		MemoWrite(cCaminho+cArquivo+cExtensao, cConteud)

		//Tentando abrir o arquivo
		nRet := ShellExecute("open", cArquivo+cExtensao, "", cCaminho, 1)

		//Se houver algum erro
		If nRet <= 32
			MsgStop("Não foi possível abrir o arquivo <b>"+cCaminho+cArquivo+cExtensao+"</b>!", "Atenção")
		EndIf

	EndIf

	RestArea(aArea)

Return cConteud
/*/{Protheus.doc} fValCamp
	Função que gera os campos não encontrados no dicionario de dados e presentes no CSV / TXT
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fValCamp(cMsg)
	Local aArea     := GetArea()
	Local cArquivo  := "dicionario."
	Local cCaminho  := ""
	Local cConteud  := ""
	Local cExtensao := ""
	Default cMsg    := ""

	cCaminho  := CDIRTMP

	If !Empty(cMsg)

		cConteud := cMsg
		FWAlertError('<font color="#0F0F00" size="40">Campo(s) não encontrado(s) no dicionario !!</font>' ,"Crie o campo no diconário ou retire o campo do arquivo")

		//Se escolher txt
		If MsgYesNo(" Deseja gerar o arquivo de campo(s) não encontrado(s) no dicionario <b>txt</b>?", "Atenção")
			cExtensao := "txt"

			//Senão, será csv
		Else
			cExtensao := "csv"
		EndIf
		//Gera o arquivo
		MemoWrite(cCaminho+cArquivo+cExtensao, cConteud)

		//Tentando abrir o arquivo
		nRet := ShellExecute("open", cArquivo+cExtensao, "", cCaminho, 1)

		//Se houver algum erro
		If nRet <= 32
			MsgStop("Não foi possível abrir o arquivo <b>"+cCaminho+cArquivo+cExtensao+"</b>!", "Atenção")
		EndIf

	EndIf

	RestArea(aArea)

Return  IIF(EMPTY(cConteud),.T.,.F.)
/*/{Protheus.doc} fMontaTmp
	Função que monta a estrutura da tabela temporária com os erros
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fMontaTmp()
	Local aArea     := GetArea()
	Local aIndex    := {}
	Local aStruTmp  := {}
	Local cAliasTmp := ""
	Local oTrb      := nil

	//Se tiver aberto a temporária, fecha e exclui o arquivo
	If Select(cAliasTmp) > 0 .And. !Empty(cAliasTmp)
		(cAliasTmp)->(DbCloseArea())
	EndIf

	//Adicionando a Estrutura (Campo, Tipo, Tamanho, Decimal)
	aStruTmp:={}
	aadd(aStruTmp, {"TMP_ARQ"  , "C", 250, 0})
	aadd(aStruTmp, {"TMP_LINHA", "N", 018, 0})
	aadd(aStruTmp, {"TMP_SEQ"  , "C", 010, 0})

	//Criando tabela temporária
	cAliasTmp := GetNextAlias()
	xCriaTRB(aStruTmp,aIndex,@oTrb,@cAliasTmp)
	cAliasTmp := oTrb:GetAlias()

	//Setando os campos que serão mostrados no MsSelect
	aCampos := {}
	aadd(aCampos, {"TMP_ARQ"  , , "Arquivo Log.", ""})
	aadd(aCampos, {"TMP_LINHA", , "Linha Erro"  , ""})
	aadd(aCampos, {"TMP_SEQ"  , , "Sequencia"   , "@!"})

	RestArea(aArea)

Return cAliasTmp
/*/{Protheus.doc} SraTp
	Validação do campo Tipo na tela de observação da carga genérica
	@type function
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 1.0
	@return LOGICAL, Retorno da rotina
/*/
User Function SraTp()
	Local lRetorn := .F.
	Local aColsAux := oMsNew:aCols
	Local nLinAtu := oMsNew:nAt

	//Se o campo atual estiver contido nos campos próprios do execauto (como LINPOS)
	If aColsAux[nLinAtu][01] $ cCampTipo
		lRetorn := .T.

		//Senão, campo não pode ser alterado
	Else
		lRetorn := .F.
		MsgAlert("Campo não pode ser alterado!", "Atenção")
	EndIf

Return lRetorn
/*/{Protheus.doc} fTelaErro
	Função que mostra os erros gerados na tela
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fTelaErro()
	Local aArea		:= GetArea()
	Local oDlgErro
	Local oGrpErr
	Local oGrpAco
	Local oBtnFech
	Local oBtnVisu
	Local nJanLarErr	:= 600
	Local nJanAltErr	:= 400
	//Criando a Janela
	DEFINE MSDIALOG oDlgErro TITLE "Erros na Importação" FROM 000, 000  TO nJanAltErr, nJanLarErr COLORS 0, 16777215 PIXEL
	//Grupo Erros
	@ 003, 003 	GROUP oGrpErr TO (nJanAltErr/2)-28, (nJanLarErr/2) 	PROMPT "Erros: " 		OF oDlgErro COLOR 0, 16777215 PIXEL
	//Criando o MsSelect
	oBrowChk := MsSelect():New(	cAliasTmp,;												//cAlias
	"",;														//cCampo
	,;															//cCpo
	aCampos,;													//aCampos
	,;															//lInv
	,;															//cMar
	{010, 006, (nJanAltErr/2)-31, (nJanLarErr/2)-3},;	//aCord
	,;															//cTopFun
	,;															//cBotFun
	oDlgErro,;													//oWnd
	,;															//uPar11
	)															//aColors
	oBrowChk:oBrowse:lHasMark    := .F.
	oBrowChk:oBrowse:lCanAllmark := .F.

	//Grupo Ações
	@ (nJanAltErr/2)-25, 003 	GROUP oGrpAco TO (nJanAltErr/2)-3, (nJanLarErr/2) 	PROMPT "Ações: " 		OF oDlgErro COLOR 0, 16777215 PIXEL

	//Botões
	@ (nJanAltErr/2)-18, (nJanLarErr/2)-(63*1)  BUTTON oBtnFech PROMPT "Fechar"        SIZE 60, 014 OF oDlgErro ACTION (oDlgErro:End()) PIXEL
	@ (nJanAltErr/2)-18, (nJanLarErr/2)-(63*2)  BUTTON oBtnVisu PROMPT "Vis.Erro"      SIZE 60, 014 OF oDlgErro ACTION (fVisErro()) PIXEL
	ACTIVATE MSDIALOG oDlgErro CENTERED

	RestArea(aArea)
Return

/*/{Protheus.doc} fVisErro
	Função que visualiza o erro conforme registro posicionado
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fVisErro()
	Local nRet := 0
	Local cNomeArq := Alltrim((cAliasTmp)->TMP_ARQ)
	//Tentando abrir o objeto
	nRet := ShellExecute("open", cNomeArq, "", cDirTmp, 1)

	//Se houver algum erro
	If nRet <= 32
		MsgStop("Não foi possível abrir o arquivo " +cDirTmp+cNomeArq+ "!", "Atenção")
	EndIf
Return

/*/{Protheus.doc} fVisPlan
	Função que visualiza os erros em formato .csv
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fVisPlan()
	Local nRet := 0
	Local cNomeArq := Alltrim(cCmbTip+"Erro.csv")
	//Tentando abrir o objeto
	nRet := ShellExecute("open", cNomeArq , "", cDirTmp, 1)

	//Se houver algum erro
	If nRet <= 32
		MsgStop("Não foi possível abrir o arquivo " +cDirTmp+cNomeArq+ "!", "Atenção")
	EndIf
Return

/*/{Protheus.doc} xCriaTRB
	Função auxiliar para retornar FwTemporaryTable
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 12/02/2021
	@version 12.1.33
/*/
Static Function xCriaTRB(aFields,aIndex,oTrb,cTableName,nTipo)
	local aArea     := getArea()
	local aTmpIndx  := {}
	local i         := 0
	local lArray    := .F.
	local nX        := 0
	local oAux      := Nil
	local y         := 0
	Default aFields := {}
	Default aIndex  := {}
	Default cAlias  := Iif(empty(cTableName),getNextAlias(),cTableName)
	Default nTipo   := 1
	Default oTrb    := Nil


	Do Case
	Case ( len(aFields) ==0 )
		MsgInfo("A Estrutura do campo field está incorreta( os campos da estrutura para montagem do TRB devem ser obrigatoriamente enviados ). Por favor, revisar o mesmo para prosseguir com a operação.","Inconsistência")
		Return .F.
	EndCase

	oAux := FWTemporaryTable():New(cAlias)
	oAux:SetFields( aFields )
	If nTipo == 1
		For y := 1 to len(aIndex)
			lArray := ValType(aIndex[y])=="A"
			If( lArray )
				lArray := ValType(aIndex[y,2])=="A"
				If( lArray )
					For i := 1 to len(aIndex[y,2])
						oAux:AddIndex(StrZero((y+i),7), { aIndex[y,2,i] } )
					Next i
				Else
					oAux:AddIndex(StrZero(y,7), { aIndex[y,2] } )
				EndIf
			Else
				oAux:AddIndex(StrZero(y,7), { aIndex[y,2] } )
			EndIf
		Next y
	Else
		For y := 1 to len(aIndex)
			aTmpIndx:= {}
			aTmpIndx:= Array(Len(aIndex[y,2]))
			For nX:= 1 to Len(aIndex[y,2])
				aTmpIndx[nX]:= aIndex[y,2,nX]
			Next nX
			If Len(aTmpIndx) > 0
				oAux:AddIndex(StrZero(y,7), aTmpIndx )
			EndIf
		Next y
	EndIf
	oAux:Create()
	oTrb := oAux
	cTableName := oTrb:GetAlias()

	RestArea(aArea)

Return( .T. )
/*/{Protheus.doc} fImport
	Função responsável por fazer a importação dos dados
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fImport(aOriginal)
	Local aAuxAtu     := {}
	Local aGenero     := FWGetSX5( 'ZG' )
	Local aRacaid	  := FWGetSX5( 'ZH' )
	Local cArqLog     := ""
	Local cChavGenero := ""
	Local cChaveRaca  := ""
	Local cCodAux     := ""
	Local cConLog     := ""
	Local cDescGenero := ""
	Local cDescRaca   := ""
	Local cFilSra     := ""
	Local cLinAtu     := ""
	Local cMatSra     := ""
	Local cSequen     := StrZero(1, 10)
	Local lFalhou     := .F.
	Local nLinAtu     := 1
	Local nPosAux     := 1
	Local nX          := 0
	Local xConteud    := ""
	Private aDados    := {}
	Default aOriginal := {}

	If Select('SRA') <= 0
		dbSelectArea('SRA')
	EndIf
	SRA->( dbSetOrder( 1 ) ) //RA_FILIAL+RA_MAT

	ProcRegua(nTotalReg)

	//Percorrendo os registros
	While nLinAtu <= nTotalReg
		IncProc("Analisando linha "+cValToChar(nLinAtu)+" de "+cValToChar(nTotalReg)+"...")
		cArqLog := "log_"+cCmbTip+"_lin_"+cValToChar(nLinAtu)+"_"+dToS(dDataBase)+"_"+StrTran(Time(), ":", "-")+".txt"
		cConLog := "Tipo:     "+cCmbTip+CRLF
		cConLog += "Usuário:  "+UsrRetName(RetCodUsr())+CRLF
		cConLog += "Ambiente: "+GetEnvServer()+CRLF
		cConLog += "Data:     "+dToC(dDataBase)+CRLF
		cConLog += "Hora:     "+Time()+CRLF
		cConLog += "----"+CRLF+CRLF

		//Pegando a linha atual e transformando em array
		cLinAtu := aOriginal[nLinAtu]
		aAuxAtu := Separa(cLinAtu, cGetCar)
		cCodAux := "" // Limpando o codigo auxiliar

		//Se tiver dados
		If !Empty(cLinAtu)
			//Se o tamanho for diferente, registra erro
			If Len(aAuxAtu) != Len(aHeadImp)
				cConLog += "O tamanho de campos da linha, difere do tamanho de campos do cabeçalho!"+CRLF
				cConLog += "Linha:     "+cValToChar(Len(aAuxAtu))+CRLF
				cConLog += "Cabeçalho: "+cValToChar(Len(aHeadImp))+CRLF

				//Gerando o arquivo
				MemoWrite(cDirTmp+cArqLog, cConLog)

				//Gravando o registro
				RecLock(cAliasTmp, .T.)
				TMP_ARQ   := cArqLog
				TMP_LINHA := nLinAtu
				TMP_SEQ   := cSequen
				(cAliasTmp)->(MsUnlock())

				//Incrementa a sequencia
				cSequen := Soma1(cSequen)

				//Senão, carrega as informações no array
			Else
				aDados	:= {}
				lFalhou:= .F.

				//Iniciando a transação
				Begin Transaction
					//Percorre o cabeçalho
					For nPosAux := 1 To Len(aHeadImp)
						xConteud := aAuxAtu[nPosAux]

						//Se o tipo do campo for Numérico
						If aHeadImp[nPosAux][2] == 'N'
							xConteud := Val(aAuxAtu[nPosAux])

							//Se o tipo for Lógico
						ElseIf aHeadImp[nPosAux][2] == 'L'
							xConteud := Iif(aAuxAtu[nPosAux] == '.T.', .T., .F.)

							//Se o tipo for Data
						ElseIf aHeadImp[nPosAux][2] == 'D'
							//Se tiver '/' na data, é padrão DD/MM/YYYY
							If '/' $ aAuxAtu[nPosAux]
								xConteud := cToD(aAuxAtu[nPosAux])

								//Senão, é padrão YYYYMMDD
							Else
								xConteud := sToD(aAuxAtu[nPosAux])
							EndIf
						EndIf

						//Se for o campo filial
						If 'RA_FILIAL' $ aHeadImp[nPosAux][1]
							cFilSra := aAuxAtu[nPosAux]
							cFilSra := PadR( cFilSra, TamSx3('RA_FILIAL')[1] )
						EndIf

						If 'RA_MAT' $ aHeadImp[nPosAux][1]
							cMatSra := aAuxAtu[nPosAux]
							cMatSra := PadR( cMatSra, TamSx3('RA_MAT')[1] )
						EndIf

						If 'RA_XGENERO' $ aHeadImp[nPosAux][1]
							cRA_XGENERO := Upper(aAuxAtu[nPosAux])
						EndIf

						If 'RA_XNAMESO' $ aHeadImp[nPosAux][1]
							cRA_XNAMESO := aAuxAtu[nPosAux]
						EndIf

						If 'RA_XUSASOC' $ aHeadImp[nPosAux][1]
							cRA_XUSASOC := Upper(aAuxAtu[nPosAux])
						EndIf

						If 'RA_XCODRAC' $ aHeadImp[nPosAux][1]
							cRA_XCODRAC := Upper(aAuxAtu[nPosAux])
						EndIf

						//Adicionando no vetor que será importado
						aAdd(aDados,{	aHeadImp[nPosAux][1],;			//Campo
						xConteud,;							//Conteúdo
						Nil})								//Compatibilidade


					Next


				End Transaction

				If !SRA->(DbSeek( cFilSra + cMatSra))
					lFalhou := .T.

					cConLog += "Não foi encontrado um registro na SRA para a Filial :" + cFilSra + ' e Matricula : ' + cMatSra
					cConLog += " retirar ou ajustar do arquivo"
					cConLog+= CRLF

				Else

					If !Empty(SRA->RA_XGENERO) .Or. !Empty(SRA->RA_XNAMESO) .Or. !Empty(SRA->RA_XUSASOC) .Or. !Empty(SRA->RA_XCODRAC)
						lFalhou := .T.

						cConLog += "Já existe um registro preenchido na SRA para a Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If ! ( cRA_XUSASOC $ 'S|N' )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois os valores aceitos são S ou N para o campo RA_XUSASOC Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If len(aGenero) > 0
						For nX := 1 to len(aGenero)
							cChavGenero += Alltrim(aGenero[nX][3]) + '|' 
							cDescGenero += Alltrim(aGenero[nX][3]) + '- ' + Alltrim(aGenero[nX][4]) + '|'
						Next
					EndIf

					If ! ( cRA_XGENERO $ cChavGenero )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois os valores aceitos são " + cDescGenero + " para o campo RA_XGENERO Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If cRA_XUSASOC == 'S' .And. ( Empty(cRA_XGENERO) .Or. Empty(cRA_XNAMESO) )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois como foi indicado o uso do nome social devem ser enviados os campos RA_XGENERO e RA_XNAMESO  preenchidos Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If len(aRacaid) > 0
						For nX := 1 to len(aRacaid)
							cChaveRaca += Alltrim(aRacaid[nX][3]) + '|' 
							cDescRaca += Alltrim(aRacaid[nX][3]) + '- ' + Alltrim(aRacaid[nX][4]) + '|'
						Next
					EndIf
					
					If ! ( cRA_XCODRAC $ cChaveRaca )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois os valores aceitos são " + cDescRaca + " para o campo RA_XGENERO Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf
					

				EndIf


				//Se houve falha na importação, grava na tabela temporária
				If lFalhou
					//Gerando o arquivo
					MemoWrite(cDirTmp+cArqLog, cConLog)

					//Gravando o registro
					RecLock(cAliasTmp, .T.)
					TMP_ARQ   := cArqLog
					TMP_LINHA := nLinAtu
					TMP_SEQ   := cSequen
					(cAliasTmp)->(MsUnlock())

					//Incrementa a sequencia
					cSequen := Soma1(cSequen)
				EndIf
			EndIf
		EndIf

		nLinAtu++

	EndDo
Return
/*/{Protheus.doc} fOkImport
	Função responsável por fazer a importação dos dados Validos
	@type  Function Static
	@author Cleiton Genuino da Silva
	@since 29/11/2023
	@version 12.1.33
/*/
Static Function fOkImport(aOriginal)
	Local aAuxAtu     := {}
	Local aGenero     := FWGetSX5( 'ZG' )
	Local aRacaid     := FWGetSX5( 'ZH' )
	Local cArqLog     := ""
	Local cChavGenero := ""
	Local cChaveRaca  := ""
	Local cCodAux     := ""
	Local cConLog     := ""
	Local cDescGenero := ""
	Local cDescRaca   := ""
	Local cFilSra     := ""
	Local cLinAtu     := ""
	Local cMatSra     := ""
	Local cSequen     := StrZero(1, 10)
	Local lFalhou     := .F.
	Local nLinAtu     := 1
	Local nPosAux     := 1
	Local nX          := 0
	Local xConteud    := ""
	Private aDados    := {}
	Default aOriginal := {}

	If Select('SRA') <= 0
		dbSelectArea('SRA')
	EndIf
	SRA->( dbSetOrder( 1 ) ) //RA_FILIAL+RA_MAT

	ProcRegua(nTotalReg)

	//Percorrendo os registros
	While nLinAtu <= nTotalReg
		IncProc("Analisando linha "+cValToChar(nLinAtu)+" de "+cValToChar(nTotalReg)+"...")
		cArqLog := "log_"+cCmbTip+"_lin_"+cValToChar(nLinAtu)+"_"+dToS(dDataBase)+"_"+StrTran(Time(), ":", "-")+".txt"
		cConLog := "Tipo:     "+cCmbTip+CRLF
		cConLog += "Usuário:  "+UsrRetName(RetCodUsr())+CRLF
		cConLog += "Ambiente: "+GetEnvServer()+CRLF
		cConLog += "Data:     "+dToC(dDataBase)+CRLF
		cConLog += "Hora:     "+Time()+CRLF
		cConLog += "----"+CRLF+CRLF

		//Pegando a linha atual e transformando em array
		cLinAtu := aOriginal[nLinAtu]
		aAuxAtu := Separa(cLinAtu, cGetCar)
		cCodAux := "" // Limpando o codigo auxiliar

		//Se tiver dados
		If !Empty(cLinAtu)
			//Se o tamanho for diferente, registra erro
			If Len(aAuxAtu) != Len(aHeadImp)
				cConLog += "O tamanho de campos da linha, difere do tamanho de campos do cabeçalho!"+CRLF
				cConLog += "Linha:     "+cValToChar(Len(aAuxAtu))+CRLF
				cConLog += "Cabeçalho: "+cValToChar(Len(aHeadImp))+CRLF

				//Gerando o arquivo
				MemoWrite(cDirTmp+cArqLog, cConLog)

				//Gravando o registro
				RecLock(cAliasTmp, .T.)
				TMP_ARQ   := cArqLog
				TMP_LINHA := nLinAtu
				TMP_SEQ   := cSequen
				(cAliasTmp)->(MsUnlock())

				//Incrementa a sequencia
				cSequen := Soma1(cSequen)

				//Senão, carrega as informações no array
			Else
				aDados	:= {}
				lFalhou:= .F.

				//Iniciando a transação
				Begin Transaction
					//Percorre o cabeçalho
					For nPosAux := 1 To Len(aHeadImp)
						xConteud := aAuxAtu[nPosAux]

						//Se o tipo do campo for Numérico
						If aHeadImp[nPosAux][2] == 'N'
							xConteud := Val(aAuxAtu[nPosAux])

							//Se o tipo for Lógico
						ElseIf aHeadImp[nPosAux][2] == 'L'
							xConteud := Iif(aAuxAtu[nPosAux] == '.T.', .T., .F.)

							//Se o tipo for Data
						ElseIf aHeadImp[nPosAux][2] == 'D'
							//Se tiver '/' na data, é padrão DD/MM/YYYY
							If '/' $ aAuxAtu[nPosAux]
								xConteud := cToD(aAuxAtu[nPosAux])

								//Senão, é padrão YYYYMMDD
							Else
								xConteud := sToD(aAuxAtu[nPosAux])
							EndIf
						EndIf

						//Se for o campo filial
						If 'RA_FILIAL' $ aHeadImp[nPosAux][1]
							cFilSra := aAuxAtu[nPosAux]
							cFilSra := PadR( cFilSra, TamSx3('RA_FILIAL')[1] )
						EndIf

						If 'RA_MAT' $ aHeadImp[nPosAux][1]
							cMatSra := aAuxAtu[nPosAux]
							cMatSra := PadR( cMatSra, TamSx3('RA_MAT')[1] )
						EndIf

						If 'RA_XGENERO' $ aHeadImp[nPosAux][1]
							cRA_XGENERO := Upper(aAuxAtu[nPosAux])
						EndIf

						If 'RA_XNAMESO' $ aHeadImp[nPosAux][1]
							cRA_XNAMESO := aAuxAtu[nPosAux]
						EndIf

						If 'RA_XUSASOC' $ aHeadImp[nPosAux][1]
							cRA_XUSASOC := Upper(aAuxAtu[nPosAux])
						EndIf

						If 'RA_XCODRAC' $ aHeadImp[nPosAux][1]
							cRA_XCODRAC := Upper(aAuxAtu[nPosAux])
						EndIf

						//Adicionando no vetor que será importado
						aAdd(aDados,{	aHeadImp[nPosAux][1],;			//Campo
						xConteud,;							//Conteúdo
						Nil})								//Compatibilidade


					Next


				End Transaction

				If !SRA->(DbSeek( cFilSra + cMatSra))
					lFalhou := .T.

					cConLog += "Não foi encontrado um registro na SRA para a Filial :" + cFilSra + ' e Matricula : ' + cMatSra
					cConLog += " retirar ou ajustar do arquivo"
					cConLog+= CRLF

				Else

					If !Empty(SRA->RA_XGENERO) .Or. !Empty(SRA->RA_XNAMESO) .Or. !Empty(SRA->RA_XUSASOC)
						lFalhou := .T.

						cConLog += "Já existe um registro preenchido na SRA para a Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If len(aGenero) > 0
						For nX := 1 to len(aGenero)
							cChavGenero += Alltrim(aGenero[nX][3]) + '|' 
							cDescGenero += Alltrim(aGenero[nX][3]) + '- ' + Alltrim(aGenero[nX][4]) + '|'
						Next
					EndIf

					If ! ( cRA_XGENERO $ cChavGenero )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois os valores aceitos são " + cDescGenero + " para o campo RA_XGENERO Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If ! ( cRA_XUSASOC $ 'S|N' )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois os valores aceitos são S ou N para o campo RA_XUSASOC Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf


					If cRA_XUSASOC == 'S' .And. ( Empty(cRA_XGENERO) .Or. Empty(cRA_XNAMESO) )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois como foi indicado o uso do nome social devem ser enviados os campos RA_XGENERO e RA_XNAMESO  preenchidos Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf

					If len(aRacaid) > 0
						For nX := 1 to len(aRacaid)
							cChaveRaca += Alltrim(aRacaid[nX][3]) + '|' 
							cDescraca += Alltrim(aRacaid[nX][3]) + '- ' + Alltrim(aRacaid[nX][4]) + '|'
						Next
					EndIf
					
					If ! ( cRA_XCODRAC $ cChaveRaca )
						lFalhou := .T.
						cConLog += "Ajuste o registro pois os valores aceitos são " + cDescRaca + " para o campo RA_XGENERO Filial :" + cFilSra + ' e Matricula : ' + cMatSra
						cConLog += " retirar ou ajustar do arquivo"
						cConLog+= CRLF
					EndIf
					

				EndIf


				//Se houve falha na importação, grava na tabela temporária
				If lFalhou
					//Gerando o arquivo
					MemoWrite(cDirTmp+cArqLog, cConLog)

					//Gravando o registro
					RecLock(cAliasTmp, .T.)
					TMP_ARQ   := cArqLog
					TMP_LINHA := nLinAtu
					TMP_SEQ   := cSequen
					(cAliasTmp)->(MsUnlock())

					//Incrementa a sequencia
					cSequen := Soma1(cSequen)
				Else

					If SRA->(DbSeek( cFilSra + cMatSra))

						If Reclock('SRA',.F.)
							SRA->RA_XUSASOC := cRA_XUSASOC
							SRA->RA_XNAMESO := cRA_XNAMESO
							SRA->RA_XGENERO := Strzero(Val(cRA_XGENERO),2)
							SRA->RA_XCODRAC := Strzero(Val(cRA_XCODRAC),2)
							SRA->(MsUnlock())
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf

		nLinAtu++

	EndDo
Return
