#INCLUDE "MATR110.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#Include "ap5mail.ch"

Static nPAJ_MSBLQL	:= SAJ->(FieldPos("AJ_MSBLQL"))
Static cPicA2_CEP	:= PesqPict("SA2","A2_CEP")
Static cPicA2_CGC	:= PesqPict("SA2","A2_CGC")
Static cUserId   	:= RetCodUsr()
Static lLGPD		:= FindFunction("SuprLGPD") .And. SuprLGPD()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR110  ³ Autor ³ Alexandre Inacio Lemes³ Data ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pedido de Compras e Autorizacao de Entrega                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR110(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico SIGACOM                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UMTR110( cAlias, nReg, nOpcx )

	Local oReport

	Private lAuto 	 := (nReg!=Nil)
	Private cFilSA2	 := xFilial("SA2")
	Private cFilSA5	 := xFilial("SA5")
	Private cFilSAJ	 := xFilial("SAJ")
	Private cFilSB1	 := xFilial("SB1")
	Private cFilSB5	 := xFilial("SB5")
	Private cFilSC7	 := xFilial("SC7")
	Private cFilSCR	 := xFilial("SCR")
	Private cFilSE4	 := xFilial("SE4")
	Private cFilSM4	 := xFilial("SM4")
	Private xUsrName := Nil
	Private	oHash 	 := Nil

	Private cEmailFor   := ""
	Private cDirUsrDest := ""
	Private nPCOk       := 0
	Private lCancela    := .F.

//Carrega os usuários do sistema para ser utilizado posteriormente nas demais funções através do HashMap
	oHash := R110Hash()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef(nReg, nOpcx)
//oReport:nDevice := 6 //1-Arquivo,2-Impressora,3-email,4-Planilha, 5-Html 6 - PDF

	If nOpcx == 3

		If lCancela
			Return(.F.)
		Endif

		oReport:Preview(.F.)
		Processa( { || oReport:Print(.F., "", .T.) }, "Gerando Pedido...")

		cArqOri := GetTempPath()+"totvsprinter\"+oReport:cFile+".pdf" // busca arquivo gerado na pasta temporaria

		If nPCOk == 0
			Alert("Não foi encontrado pedido para envio!")
			//deleto o arquivo da pasta temporaria
			FERASE(cArqOri)
			Return(.F.)
		Endif

		//copia o arquivo para outra pasta criando-a caso não exista
		cDirUsrDest := "\relato\pedidos\"
		If !ExistDir( cDirUsrDest )
			MakeDir( cDirUsrDest )
		Endif
		cArqDes := cDirUsrDest+oReport:cFile+".pdf"
		If !__CopyFile(cArqOri, cArqDes)
			Alert("Erro na cópia do arquivo. O pedido não será enviado!")
		Endif

		//deleto o arquivo da pasta temporaria
		FERASE(cArqOri)

		//chama tela para envio do e-mail
		fEmailFor(cArqDes)

	Else
		oReport:PrintDialog()
	Endif

//oReport:Print(.F., "", .T.)

Return
	*----------------------------------*
Static Function fEmailFor(cArqDes)
	*----------------------------------*
	Local oButAnexo
	Local oButCancela
	Local oButEnvia
	Local oGetAssunto
	Local oGetCC
	Local oGetDesc
	Local oSay1
	Local oSay2
	Local oSayAssunto
	Local oDlg
	Local oGroup1
	Local oListBox
	Local oCheckBox

	Local lCheckBox   := .F.
	Local aListBox    := {Alltrim(Right(cArqDes,10))}
	Local cGetAssunto := ""
	Local cGetDesc    := ""
	Local cGetCC      := Space(100)

	//Busca texto padrão para o e-mail
	dbSelectArea("ZV0")
	dbSetOrder(1)
	dbGoTop()

	While !ZV0->(Eof())
		If ZV0->ZV0_STATUS == "2"
			Exit
		Endif
		ZV0->(dbSkip())
	End

	cGetAssunto := Alltrim(ZV0->ZV0_ASSUNT)
	cGetDesc    := Alltrim(ZV0->ZV0_CORPO)

	ZV0->(dbCloseArea())

	DEFINE MSDIALOG oDlg TITLE "Envio de Pedido de Compras" FROM 000, 000  TO 500, 495 COLORS 0, 16777215 PIXEL

	@ 009, 005 SAY oSayAssunto PROMPT "Assunto:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 019, 005 MSGET oGetAssunto VAR cGetAssunto SIZE 236, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 035, 005 SAY oSay1 PROMPT "Descrição:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 043, 005 GET oGetDesc VAR cGetDesc OF oDlg MULTILINE SIZE 236, 049 COLORS 0, 16777215 HSCROLL PIXEL

	@ 097, 005 GROUP oGroup1 TO 180, 241 PROMPT "  Anexos  " OF oDlg COLOR 0, 16777215 PIXEL
	@ 105, 010 LISTBOX oListBox Fields HEADER "Arquivo" SIZE 225, 070 OF oGroup1 COLORS 0, 16777215 PIXEL
	oListBox:SetArray(aListBox)
	oListBox:bLine := { || {aListBox[oListBox:nAt]}}

	@ 186, 005 CHECKBOX oCheckBox VAR lCheckBox PROMPT "Receber cópia do e-mail" SIZE 074, 008 OF oDlg COLORS 0, 16777215 PIXEL

	@ 200, 005 SAY oSay2 PROMPT "Outros e-mails para receber a cópia" SIZE 089, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 209, 005 MSGET oGetCC VAR cGetCC SIZE 236, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 230, 096 BUTTON oButAnexo   PROMPT "&Anexar"        SIZE 045, 015 OF oDlg ACTION fAnexar(aListBox) PIXEL
	@ 230, 146 BUTTON oButEnvia   PROMPT "&Enviar e-mail" SIZE 045, 015 OF oDlg ACTION { || fEnviaEmail(cArqDes,cGetAssunto,cGetDesc,lCheckBox,cGetCC,aListBox),oDlg:End() } PIXEL
	@ 230, 195 BUTTON oButCancela PROMPT "&Cancelar"      SIZE 045, 015 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return
	*--------------------------------*
Static Function fAnexar(aListBox)
	*--------------------------------*
	Local cFileOri := cGetFile('Arquivos |*.*','Selecione arquivo',0,'C:\Dir\',.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
	Local cFileDes := RetFileName(cFileOri)+Alltrim(Right(cFileOri,4))

	aadd(aListBox, cFileDes )

	//copia o arquivo para a pasta criada no servidor para envio do anexo
	cFileDes := cDirUsrDest+cFileDes
	If !__CopyFile(cFileOri, cFileDes)
		Alert("Erro na cópia do arquivo "+cFileOri+". Anexo não incluído!")
	Endif

Return
	*----------------------------------------------------------------------------------*
Static Function fEnviaEmail(cArqDes,cGetAssunto,cGetDesc,lCheckBox,cGetCC,aListBox)
	*----------------------------------------------------------------------------------*

	Processa({|| fEnvMail(cArqDes,cGetAssunto,cGetDesc,lCheckBox,cGetCC,aListBox) },"Enviando E-mail...")

Return
	*--------------------------------------------------------------------------------*
Static Function fEnvMail(cArqDes,cGetAssunto,cGetDesc,lCheckBox,cGetCC,aListBox)
	*--------------------------------------------------------------------------------*
	Local oSendMail	:= Nil
	Local jRet		:= Nil
	Local nRet   := 0
	Local nX     := 0
	Local nI     := 0
	Local cCC    := ""
	Local _cBody := ""
	Local aAnexo := {}

	If lCheckBox
		cCC := UsrRetMail(__cUserID)
	Endif

	If !Empty(cGetCC)
		cCC += ";"+cGetCC
	Endif

	_cBody :="<html>"
	_cBody +="<head>"
	_cBody +="<meta http-equiv='Content-Type' content='text/html; charset=UTF8'>"
	_cBody +="</head>"
	_cBody +="<body>"
	_cBody +="</div>"
	_cBody +="<div id='conteudo'>"

	For nI := 1 to MLCount( cGetDesc, len(cGetDesc) )
		_cBody += MemoLine( cGetDesc, len(cGetDesc), nI )+"<br>"
	Next nI

	_cBody +="<br><br><br>"
	_cBody +="</div>"
	_cBody +="</div>"
	_cBody +="<div id='footer'>"
	_cBody +="<p></p>"
	_cBody +="</div>"
	_cBody +="</font></p>"
	_cBody +="</body>"
	_cBody +="</html>"

	If Len(aListBox) > 0
		For nX := 1 to Len(aListBox)
			aadd(aAnexo, {Lower(aListBox[nX]), cDirUsrDest + Lower(aListBox[nX])} )
		Next
	Endif

	oSendMail := nGab.cEmailService():New()
	jRet := oSendMail:sendEmailWithAttach("GRUPO AGUAS DO BRASIL - " +cGetAssunto, cEmailFor, _cBody, cCC, aAnexo)

	if jRet["codReturn"] != "200"
		MSGINFO("Falha no envio!","Atenção")
		Return .F.
	Else
		MsgInfo("E-mail enviado com sucesso!","Envio de Pedidos de Compra")
	endif

	FreeObj(jRet)
	FreeObj(oSendMail)

	/*
	If oMessage:AttachFile( cArqDes ) < 0
		Return .F.
	Else
		//adiciona uma tag informando que é um attach e o nome do arq
		oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+Alltrim(Right(cArqDes,10)))
	EndIf
	*/

	//deleto os arquivos anexados da pasta do servidor
	If Len(aListBox) > 0
		For nX := 1 to Len(aListBox)
			FERASE(cDirUsrDest + Lower(aListBox[nX]))
		Next
	Endif

Return
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ ReportDef³Autor  ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Pedido de Compras / Autorizacao de Entrega                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ nExp01: nReg = Registro posicionado do SC7 apartir Browse  ³±±
	±±³          ³ nExp02: nOpcx= 1 - PC / 2 - AE                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(nReg,nOpcx)

	Local cTitle   		:= STR0003 // "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
	Local oReport
	Local oSection1
	Local oSection2
	Local nTamDscPrd 	:= 30 //Padrão da B1_DESC

	If Type("lAuto") == "U"
		lAuto := (nReg!=Nil)
	Endif

	If Type("cFilSA2") == "U"
		cFilSA2		:= xFilial("SA2")
	Endif

	If Type("cFilSA5") == "U"
		cFilSA5		:= xFilial("SA5")
	Endif

	If Type("cFilSAJ") == "U"
		cFilSAJ		:= xFilial("SAJ")
	Endif

	If Type("cFilSB1") == "U"
		cFilSB1		:= xFilial("SB1")
	Endif

	If Type("cFilSB5") == "U"
		cFilSB5		:= xFilial("SB5")
	Endif

	If Type("cFilSC7") == "U"
		cFilSC7		:= xFilial("SC7")
	Endif

	If Type("cFilSCR") == "U"
		cFilSCR		:= xFilial("SCR")
	Endif

	If Type("cFilSE4") == "U"
		cFilSE4		:= xFilial("SE4")
	Endif

	If Type("cFilSM4") == "U"
		cFilSM4		:= xFilial("SM4")
	Endif

	If Type("oHash") == "U"
		oHash		:= R110Hash()
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Do Pedido                             ³
//³ mv_par02               Ate o Pedido                          ³
//³ mv_par03               A partir da data de emissao           ³
//³ mv_par04               Ate a data de emissao                 ³
//³ mv_par05               Somente os Novos                      ³
//³ mv_par06               Campo Descricao do Produto    	     ³
//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
//³ mv_par09               Numero de vias                        ³
//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
//³ mv_par12               Qual a Moeda ?                        ³
//³ mv_par13               Endereco de Entrega                   ³
//³ mv_par14               todas ou em aberto ou atendidos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Pergunte("UMTR110",.T.)
		lCancela := .T.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("UMTR110",cTitle,"UMTR110", {|oReport| ReportPrint(oReport,nReg,nOpcx)},STR0001+" "+STR0002)
	oReport:SetPortrait()
	oReport:oPage:SetPaperSize(9)
	oReport:HideParamPage()
	oReport:HideHeader()
	oReport:HideFooter()
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation()
	oReport:ParamReadOnly(lAuto)
	oReport:SetUseGC(.F.)

	If nOpcx == 3
		oReport:nDevice := IMP_PDF
		oReport:cFile := mv_par01
		oReport:lViewPDF := .F.
	Endif

	oSection1:= TRSection():New(oReport,STR0102,{"SC7","SM0","SA2"}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
		.T./* <.lLineStyle.>  */, /* <nColSpace>  */,/*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
		oSection1:SetReadOnly()
	oSection1:SetNoFilter("SA2")

	TRCell():New(oSection1,"M0_NOMECOM","SM0",STR0087      ,/*Picture*/,49,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ENDENT" ,"SM0",STR0088      ,/*Picture*/,48,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CEPENT" ,"SM0",STR0089      ,/*Picture*/,10,/*lPixel*/,{|| Trans(SM0->M0_CEPENT,cPicA2_CEP) })
	TRCell():New(oSection1,"M0_CIDENT" ,"SM0",STR0090      ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ESTENT" ,"SM0",STR0091      ,/*Picture*/,11,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CGC"    ,"SM0",STR0124      ,/*Picture*/,18,/*lPixel*/,{|| Transform(SM0->M0_CGC,cPicA2_CGC) })
	If cPaisLoc == "BRA"
		TRCell():New(oSection1,"M0IE"  ,"   ",STR0041      ,/*Picture*/,18,/*lPixel*/,{|| InscrEst()})
	EndIf
	TRCell():New(oSection1,"M0_TEL"    ,"SM0",STR0092      ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_FAX"    ,"SM0",STR0093      ,/*Picture*/,34,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_COD"    ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_LOJA"   ,"SA2",/*Titulo*/   ,/*Picture*/,04,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_END"    ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_BAIRRO" ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CEP"    ,"SA2",/*Titulo*/   ,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_MUN"    ,"SA2",/*Titulo*/   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_EST"    ,"SA2",/*Titulo*/   ,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CGC"    ,"SA2",/*Titulo*/   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_INSCR"  ,"   ",If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 ),/*Picture*/,18,/*lPixel*/,{|| If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ) })
	TRCell():New(oSection1,"A2_TEL"    ,"   ",STR0094      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)})
	TRCell():New(oSection1,"A2_FAX"    ,"   ",STR0093      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)})

	oSection1:Cell("A2_BAIRRO"):SetCellBreak()
	oSection1:Cell("A2_CGC"   ):SetCellBreak()
	oSection1:Cell("A2_INSCR"    ):SetCellBreak()

	oSection2:= TRSection():New(oSection1, STR0103, {"SC7","SB1"}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
								 /* <.lLineStyle.>  */, /* <nColSpace>  */, /*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)

//-- Bordas para o cabeçalho
	oSection2:SetCellBorder("LEFT",,, .T.)
	oSection2:SetCellBorder("TOP" ,,, .T.)

	TRCell():New(oSection2, "C7_NUM"		, "SC7", AllTrim(STR0129),/*Picture*/,,,,,,,,, .T.)
	TRCell():New(oSection2, "C7_ITEM"    	, "SC7",/*Titulo*/	     ,/*Picture*/,TamSX3("C7_ITEM")[1],,,,,,,, .T.)
	TRCell():New(oSection2, "C7_PRODUTO" 	, "SC7",/*Titulo*/	     ,/*Picture*/,TamSX3("C7_PRODUTO")[1],,, "CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "DESCPROD"   	, "   ", AllTrim(STR0097),/*Picture*/, nTamDscPrd,/*lPixel*/, {|| cDescPro},,,,,, .F.)
	TRCell():New(oSection2, "C7_UM"      	, "SC7", AllTrim(STR0115),/*Picture*/,6,.F./*lPixel*/,/* */, "CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_QUANT"   	, "SC7", "Quantidade"    ,/*Picture*/,TamSX3("C7_TOTAL")[1],/*lPixel*/,/* */, "RIGHT",, "RIGHT",,, .T.)
	TRCell():New(oSection2, "C7_SEGUM"   	, "SC7", AllTrim(STR0115),/*Picture*/,6,.F./*lPixel*/,/* */, "CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_QTSEGUM" 	, "SC7", "Quantidade"    ,/*Picture*/,TamSX3("C7_TOTAL")[1],/*lPixel*/,/* */, "RIGHT",, "RIGHT",,, .T.)
	TRCell():New(oSection2, "PRECO"      	, "   ", AllTrim(STR0098),/*Picture*/, TamSX3("C7_PRECO")[1],/*lPixel*/, {|| nVlUnitSC7 }, "RIGHT",, "RIGHT",,, .F.)
	TRCell():New(oSection2, "TOTAL"     	, "   ", AllTrim(STR0099),/*Picture*/, TamSX3("C7_TOTAL")[1],/*lPixel*/, {|| nValTotSC7 }, "RIGHT",, "RIGHT",,, .F.)
	TRCell():New(oSection2, "C7_IPI"     	, "SC7", "%IPI"         ,/*Picture*/,6,.F./*lPixel*/,/* */,"CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_PICM"     	, "SC7", "%ICMS"        ,/*Picture*/,6,.F./*lPixel*/,/* */,"CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_DATPRF"  	, "SC7",/*Titulo*/	     ,/*Picture*/,,/*lPixel*/,/* */, "CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_CC"      	, "SC7", AllTrim(STR0066),/*Picture*/,,/*lPixel*/,/* */, "CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_NUMSC"   	, "SC7", AllTrim(STR0123),/*Picture*/,TamSX3("C7_NUMSC")[1],/*lPixel*/,/* */, "CENTER",, "CENTER",,, .T.)
	TRCell():New(oSection2, "C7_XIDORQ"   	, "SC7", "Id Orq."       ,/*Picture*/,8,.F./*lPixel*/,/* */, "CENTER",, "CENTER",,, .T.)
//TRCell():New(oSection2, "OPCC"       	, "   ", AllTrim(STR0100),/*Picture*/, TamSX3("C7_OP")[1],/*lPixel*/, {|| cOPCC }, "CENTER",, "CENTER",,, .F.)        

	oSection2:Cell("C7_PRODUTO"):SetLineBreak()
	oSection2:Cell("DESCPROD"):SetLineBreak()
	oSection2:Cell("C7_CC"):SetLineBreak()
	oSection2:Cell("C7_NUMSC"):SetLineBreak()
//oSection2:Cell("OPCC"):SetLineBreak()

Return(oReport)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ReportPrin³ Autor ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Emissao do Pedido de Compras / Autorizacao de Entrega      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ReportPrint(ExpO1,ExpN1,ExpN2)                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
	±±³          ³ ExpN1 = Numero do Recno posicionado do SC7 impressao Menu  ³±±
	±±³          ³ ExpN2 = Numero da opcao para impressao via menu do PC      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,nReg,nOpcX)

	Local oSection1     := oReport:Section(1)
	Local oSection2     := oReport:Section(1):Section(1)

	Local aRecnoSave    := {}
	Local aPedido       := {}
	Local aPedMail      := {}
	Local aValIVA       := {}

	Local cNumSC7		:= Len(SC7->C7_NUM)
	Local cCondicao		:= ""
	Local cFiltro		:= ""
	Local cComprador	:= ""
	Local cAlter		:= ""
	Local cAprov		:= ""
	Local cTipoSC7		:= ""
	Local cCondBus		:= ""
	Local cMensagem		:= ""
	Local cVar			:= ""
	Local cObsAnt		:= ""
	Local cPictVUnit	:= PesqPict("SC7","C7_PRECO",15)
	Local cPictVTot		:= PesqPict("SC7","C7_TOTAL",, mv_par12)
	Local lNewAlc		:= .F.
	Local lLiber		:= .F.
	Local lRejeit		:= .F.

	Local nRecnoSC7   	:= 0
	Local nRecnoSM0   	:= 0
	Local nX          	:= 0
	Local nY          	:= 0
	Local nVias       	:= 0
	Local nTxMoeda    	:= 0
	Local nPageWidth 	:= oReport:PageWidth()
	Local nPageHeight   := oReport:PageHeight()
	Local nPrinted    	:= 0
	Local nValIVA     	:= 0
	Local nTotIpi	    := 0
	Local nTotIcms    	:= 0
	Local nTotDesp    	:= 0
	Local nTotFrete   	:= 0
	Local nTotalNF    	:= 0
	Local nTotSeguro  	:= 0
	Local nLinPC	    := 0
	Local nLinObs     	:= 0
	Local nDescProd   	:= 0
	Local nTotal      	:= 0
	Local nTotMerc    	:= 0
	Local nPagina     	:= 0
	Local nOrder      	:= 1
	Local lImpri      	:= .F.
	Local cCident	  	:= ""
	Local cCidcob	  	:= ""
	Local nLinPC2	  	:= 0
	Local nLinPC3	  	:= 0
	Local nAprovLin 	:= 0
	Local aAux1
	Local nQtdLinhas //, nX
	Local lC7OBSChar  	:= Type( "SC7->C7_OBS" ) == "C"
	Local nFrete		:= 0
	Local nSeguro       := 0
	Local nDesp			:= 0
	Local aSC7Obs		:= {}

	Local lPCAprov      := GetMV("MV_XPCAPRV")
	Local aPCBloq       := {}
	Local nPos          := 0

	Local cLocEntr      := ""

	Private cDescPro  	  := ""
	Private cOPCC     	  := ""
	Private nVlUnitSC7	  := 0
	Private nValTotSC7	  := 0

	Private cObs01    	  := ""
	Private cObs02    	  := ""
	Private cObs03    	  := ""
	Private cObs04    	  := ""
	Private cObs05    	  := ""
	Private cObs06    	  := ""
	Private cObs07    	  := ""
	Private cObs08    	  := ""
	Private cObs09    	  := ""
	Private cObs10    	  := ""
	Private cObs11    	  := ""
	Private cObs12    	  := ""
	Private cObs13    	  := ""
	Private cObs14    	  := ""
	Private cObs15    	  := ""
	Private cObs16    	  := ""

	Private nRet		  := 0
	Private cMoeda		  := ""
	Private cPicMoeda	  := ""
	Private cPicC7_VLDESC := ""
	Private cInscrEst	  := InscrEst()
	Private cRegra        := SuperGetMV("MV_ARRPEDC",.F.,"ROUND")
	Private nTamTot       := TamSX3("C7_PRECO")[2]

	If !(cRegra $ "ROUND|NOROUND")
		cRegra := "LEGADO"
	Endif

	If Type("lPedido") != "L"
		lPedido := .F.
	Endif

	If Type("lAuto") == "U"
		lAuto := (nReg!=Nil)
	Endif

	If Type("cFilSA2") == "U"
		cFilSA2		:= xFilial("SA2")
	Endif

	If Type("cFilSA5") == "U"
		cFilSA5		:= xFilial("SA5")
	Endif

	If Type("cFilSAJ") == "U"
		cFilSAJ		:= xFilial("SAJ")
	Endif

	If Type("cFilSB1") == "U"
		cFilSB1		:= xFilial("SB1")
	Endif

	If Type("cFilSB5") == "U"
		cFilSB5		:= xFilial("SB5")
	Endif

	If Type("cFilSC7") == "U"
		cFilSC7		:= xFilial("SC7")
	Endif

	If Type("cFilSCR") == "U"
		cFilSCR		:= xFilial("SCR")
	Endif

	If Type("cFilSE4") == "U"
		cFilSE4		:= xFilial("SE4")
	Endif

	If Type("cFilSM4") == "U"
		cFilSM4		:= xFilial("SM4")
	Endif

	If Type("oHash") == "U"
		oHash		:= R110Hash()
	EndIf

	dbSelectArea("SAJ")
	SAJ->(dbSetOrder(1))

	dbSelectArea("SCR")
	SCR->(dbSetOrder(1))

	dbSelectArea("SC7")

	SB1->(dbSetOrder(1))
	SB5->(dbSetOrder(1))
	SA5->(dbSetOrder(1))
	SM0->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	SM4->(dbSetOrder(1))

	If lAuto
		SC7->(dbGoto(nReg))
		mv_par01 := SC7->C7_NUM
		mv_par02 := SC7->C7_NUM
		mv_par03 := SC7->C7_EMISSAO
		mv_par04 := SC7->C7_EMISSAO
		R110ChkPerg()
		cCondBus := AllTrim(Str(SC7->C7_TIPO) + SC7->C7_NUM)
	Else
		MakeAdvplExpr(oReport:uParam)

		cCondicao := 'C7_FILIAL=="'       + cFilSC7 + '".And.'
		cCondicao += 'C7_NUM>="'          + mv_par01       + '".And.C7_NUM<="'          + mv_par02 + '".And.'
		cCondicao += 'Dtos(C7_EMISSAO)>="'+ Dtos(mv_par03) +'".And.Dtos(C7_EMISSAO)<="' + Dtos(mv_par04) + '"'

		oReport:Section(1):SetFilter(cCondicao,IndexKey())

		cCondBus := "1"+PadL(mv_par01, Len(SC7->C7_NUM),"0")
	EndIf

	If lPedido
		mv_par12 := MAX(SC7->C7_MOEDA,1)
	EndIf

	cMoeda		:= IIf( mv_par12 < 10 , Str(mv_par12,1) , Str(mv_par12,2) )
	If Val(cMoeda) == 0
		cMoeda := "1"
	Endif
	cPicMoeda	:= GetMV("MV_MOEDA"+cMoeda)
	cPicC7_VLDESC:= PesqPict("SC7","C7_VLDESC",14, MV_PAR12)

	nOrder	 := 10

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	cEmailFor := U_fBuscaEmail(SC7->C7_FORNECE,SC7->C7_LOJA)

	oSection2:Cell("PRECO"):SetPicture(cPictVUnit)
	oSection2:Cell("TOTAL"):SetPicture(cPictVTot)

	TRPosition():New(oSection2,"SB1",1,{ || cFilSB1 + SC7->C7_PRODUTO })
	TRPosition():New(oSection2,"SB5",1,{ || cFilSB5 + SC7->C7_PRODUTO })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o CodeBlock com o PrintLine da Sessao 1 toda vez que rodar o oSection1:Init()   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , CabecPCxAE(oReport,oSection1,nVias,nPagina) })

	oReport:SetMeter(SC7->(LastRec()))
	SC7->(dbSetOrder(nOrder))
	SC7->(dbSeek(cFilSC7+cCondBus,.T.))

	oSection2:Init()

	cNumSC7 := SC7->C7_NUM

	If SC7->(Eof()) .And. nOpcx <> 3 // Caso não tenha encontrado registro e não seja a opção de envio por email, incrementa esta variavel para apresentar relatorio informando que não tem registros para impressão.
		nPCOk++
	Endif

	If nOpcx == 3 // Se a função for chamada pela opção "enviar por email"
		nSaida := 3
	Else
		nSaida := oReport:nDevice
	Endif

	If Alltrim(Str(nSaida)) $ "4/5/6/8"

		While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02

			// If incluído para o SP 23070 - Squad Suprimentos
			If lPCAprov .And. SC7->C7_CONAPRO <> "L"

				nPos := aScan(aPCBloq,{|x|x[1] = SC7->C7_NUM})

				If nPos == 0
					Aadd( aPCBloq, { SC7->C7_NUM, DtoC(SC7->C7_EMISSAO), SC7->C7_FORNECE+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") } )
				Endif
				SC7->(dbSkip())
				Loop
			Endif

			If SC7->C7_EMITIDO == "S" .AND. MV_PAR05 == 1
				SC7->(dbSkip())
				Loop
			Endif

			If (SC7->C7_CONAPRO == "B" .AND. MV_PAR10 == 1) .OR.;
					(SC7->C7_CONAPRO != "B" .AND. MV_PAR10 == 2)
				SC7->(dbSkip())
				Loop
			Endif

			If (SC7->C7_EMISSAO < MV_PAR03) .OR. (SC7->C7_EMISSAO > MV_PAR04)
				SC7->(dbSkip())
				Loop
			Endif

			If SC7->C7_TIPO == 2
				SC7->(dbSkip())
				Loop
			EndIf

			//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
			//Â³ Filtra Tipo de SCs Firmes ou Previstas                       Â³
			//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
			If !MtrAValOP(MV_PAR11, 'SC7')
				SC7->(dbSkip())
				Loop
			EndIf

			If oReport:Cancel()
				Exit
			EndIf

			MaFisEnd()
			R110FIniPC(SC7->C7_NUM,,,cFiltro)

			cObs01    := " "
			cObs02    := " "
			cObs03    := " "
			cObs04    := " "
			cObs05    := " "
			cObs06    := " "
			cObs07    := " "
			cObs08    := " "
			cObs09    := " "
			cObs10    := " "
			cObs11    := " "
			cObs12    := " "
			cObs13    := " "
			cObs14    := " "
			cObs15    := " "
			cObs16    := " "
			aSC7Obs	  := {}

			nPCOk++ // Caso o registro atenda todos os critérios, alimento este contator para imprimir os pedidos


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Roda a impressao conforme o numero de vias informado no mv_par09 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nVias := 1 to mv_par09

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dispara a cabec especifica do relatorio.                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:EndPage()
				//oReport:Box( 260, 010, 3020 , nPageWidth-4 ) //-- Box dos itens do relatório
				//oReport:Box( 260, 010, nPageHeight-5 , nPageWidth-4 ) //-- Box dos itens do relatório
				If nSaida == 5 .Or. nSaida == 3
					oReport:Box( 260, 010, nPageHeight+10 , nPageWidth-4 ) //-- Box dos itens do relatório
				Else
					oReport:Box( 260, 010, nPageHeight, nPageWidth-4 ) //-- Box dos itens do relatório
				Endif
				nPagina  := 0
				nPrinted := 0
				nTotal   := 0
				nTotMerc := 0
				nDescProd:= 0
				nLinObs  := 0
				nRecnoSC7:= SC7->(Recno())
				cNumSC7  := SC7->C7_NUM
				aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

				While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM == cNumSC7

					// If incluído para o SP 23070 - Squad Suprimentos
					If lPCAprov .And. SC7->C7_CONAPRO <> "L"

						nPos := aScan(aPCBloq,{|x|x[1] = SC7->C7_NUM})

						If nPos == 0
							Aadd( aPCBloq, { SC7->C7_NUM, DtoC(SC7->C7_EMISSAO), SC7->C7_FORNECE+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") } )
						Endif
						SC7->(dbSkip())
						Loop
					Endif

					If SC7->C7_EMITIDO == "S" .AND. MV_PAR05 == 1
						SC7->(dbSkip())
						Loop
					Endif

					If (SC7->C7_CONAPRO == "B" .AND. MV_PAR10 == 1) .OR.;
							(SC7->C7_CONAPRO != "B" .AND. MV_PAR10 == 2)
						SC7->(dbSkip())
						Loop
					Endif

					If (SC7->C7_EMISSAO < MV_PAR03) .OR. (SC7->C7_EMISSAO > MV_PAR04)
						SC7->(dbSkip())
						Loop
					Endif

					If SC7->C7_TIPO == 2
						SC7->(dbSkip())
						Loop
					EndIf

					//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
					//Â³ Filtra Tipo de SCs Firmes ou Previstas                       Â³
					//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
					If !MtrAValOP(MV_PAR11, 'SC7')
						SC7->(dbSkip())
						Loop
					EndIf

					If oReport:Cancel()
						Exit
					EndIf

					oReport:IncMeter()

					If oReport:Row() > oReport:LineHeight() * 100
						//oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth-4 )
						oReport:SkipLine()
						oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
						oReport:EndPage()
						If nSaida == 5 .Or. nSaida == 3
							oReport:Box( 260, 010, nPageHeight+10 , nPageWidth-4 ) //-- Box dos itens do relatório
						Else
							oReport:Box( 260, 010, nPageHeight-5 , nPageWidth-4 ) //-- Box dos itens do relatório
						Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Ascan(aRecnoSave,SC7->(Recno())) == 0
						AADD(aRecnoSave,SC7->(Recno()))
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa o descricao do Produto conf. parametro digitado.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cDescPro :=  ""
					If Empty(mv_par06)
						mv_par06 := "B1_DESC"
					EndIf

					If AllTrim(mv_par06) == "B1_DESC"
						SB1->(dbSeek( cFilSB1 + SC7->C7_PRODUTO ))
						cDescPro := SB1->B1_DESC
					ElseIf AllTrim(mv_par06) == "B5_CEME"
						If SB5->(dbSeek( cFilSB5 + SC7->C7_PRODUTO ))
							cDescPro := SB5->B5_CEME
						EndIf
					ElseIf AllTrim(mv_par06) == "C7_DESCRI"
						cDescPro := SC7->C7_DESCRI
					EndIf

					If Empty(cDescPro)
						SB1->(dbSeek( cFilSB1 + SC7->C7_PRODUTO ))
						cDescPro := SB1->B1_DESC
					EndIf

					If SA5->(dbSeek(cFilSA5+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
						cDescPro := Alltrim(cDescPro) + " ("+Alltrim(SA5->A5_CODPRF)+")"
					EndIf

					If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
						nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
					Else
						nDescProd+=SC7->C7_VLDESC
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializacao da Observacao do Pedido.                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lC7OBSChar .AND. !Empty(SC7->C7_OBS) .And. nLinObs < 17

						If !(SC7->C7_OBS $ SC7->C7_OBSM)

							nLinObs++
							cVar:="cObs"+StrZero(nLinObs,2)

							If nLinObs == 1

								Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))

							Else

								If cObsAnt <> Alltrim(SC7->C7_OBS)
									Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))
								Endif

							Endif

							cObsAnt := Alltrim(SC7->C7_OBS)

						EndIf

					Endif

					If !Empty(SC7->C7_OBSM) .And. nLinObs < 17
						nLinObs++
						cVar:="cObs"+StrZero(nLinObs,2)
						if Ascan(aSC7Obs,{|x| AllTrim(x) == Alltrim(SC7->C7_OBSM) }) == 0
							aAdd(aSC7Obs, Alltrim(SC7->C7_OBSM))
							Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBSM))
						endif
					Endif

					nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,0)
					nFrete   := If(SC7->C7_TPFRETE=="F",SC7->C7_XFRETE,0)

					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nValTotSC7            := NoRound( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
						ElseIf AllTrim(cRegra) == "ROUND"
							nValTotSC7            := Round( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
						Else
							nValTotSC7            := SC7->C7_TOTAL
						EndIf
						If nValTotSC7 > 0
							nTotal 	:= nTotal 	+ nValTotSC7
							IF SC7->C7_MOEDA == 1
								nTotMerc   := MaFisRet(,"NF_TOTAL")
							ELSE
								//nFrete		:= nFrete 	+ SC7->C7_VALFRE
								//nFrete		:= SC7->C7_XFRETE    // ALTERADO ADRIANO 16/01/15 PARA ATERNDER NOVO PADRÃO FOB
								nSeguro		:= nSeguro 	+ SC7->C7_SEGURO
								nDesp		:= nDesp 	+ SC7->C7_DESPESA
								nTotMerc	+= nValTotSC7
							ENDIF
						EndIf
					EndIf

					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nValTotSC7	:= NoRound( xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2 )
						ElseIf AllTrim(cRegra) == "ROUND"
							nValTotSC7	:= Round( xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2 )
						Else
							nValTotSC7	:= xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						Endif
					ENDIF

					If oReport:nDevice != 4 .Or. (oReport:nDevice == 4 .And. !oReport:lXlsTable .And. oReport:lXlsHeader)  //impressao em planilha tipo tabela
						oSection2:Cell("C7_NUM"):Disable()
					EndIf

					If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
						oSection2:Cell("C7_SEGUM"  ):Enable()
						oSection2:Cell("C7_QTSEGUM"):Enable()
						oSection2:Cell("C7_UM"     ):Disable()
						oSection2:Cell("C7_QUANT"  ):Disable()
						nVlUnitSC7 := xMoeda(((SC7->C7_PRECO*SC7->C7_QUANT)/SC7->C7_QTSEGUM),SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
					ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
						oSection2:Cell("C7_SEGUM"  ):Disable()
						oSection2:Cell("C7_QTSEGUM"):Disable()
						oSection2:Cell("C7_UM"     ):Enable()
						oSection2:Cell("C7_QUANT"  ):Enable()
						nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						//Else
						//	oSection2:Cell("C7_SEGUM"  ):Enable()
						//	oSection2:Cell("C7_QTSEGUM"):Enable()
						//	oSection2:Cell("C7_UM"     ):Enable()
						//	oSection2:Cell("C7_QUANT"  ):Enable()
						//	nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
					EndIf

					If cPaisLoc <> "BRA" .Or. mv_par08 == 2
						oSection2:Cell("C7_IPI" ):Disable()
					EndIf

					If mv_par08 == 1 .OR. mv_par08 == 3
						//oSection2:Cell("OPCC"):Disable()
					Else
						oSection2:Cell("C7_CC"):Disable()
						oSection2:Cell("C7_NUMSC"):Disable()
						If !Empty(SC7->C7_OP)
							cOPCC := STR0065 + " " + SC7->C7_OP
						ElseIf !Empty(SC7->C7_CC)
							cOPCC := STR0066 + " " + SC7->C7_CC
						EndIf
					EndIf

					If oReport:nDevice == 4 .And. oReport:lXlsTable .And. !oReport:lXlsHeader  //impressao em planilha tipo tabela
						oSection1:Init()
						TRPosition():New(oSection1,"SA2",1,{ || cFilSA2 + SC7->C7_FORNECE + SC7->C7_LOJA })
						oSection1:PrintLine()
						oSection2:PrintLine()
						oSection1:Finish()
					Else
						oSection2:PrintLine()
					EndIf

					nPrinted++
					lImpri  := .T.



					SC7->(dbSkip())

				EndDo

				SC7->(dbGoto(nRecnoSC7))

				If oReport:Row() > oReport:LineHeight() * 68

					//oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth-4 )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dispara a cabec especifica do relatorio.                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oReport:EndPage()
					oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape

					//oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )

				EndIf

				//oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )

				oReport:Box( 1990 ,010, nPageHeight+10  , nPageWidth-4 )
				oReport:Box( 2080 ,010, nPageHeight+10  , nPageWidth-4 )
				oReport:Box( 2200 ,010, nPageHeight+10  , nPageWidth-4 )
				oReport:Box( 2320 ,010, nPageHeight+10  , nPageWidth-4 )

				If nSaida == 5 .Or. nSaida == 3 // se for emissão em html
					oReport:Box( 2200, 1080 , 2320, 1400 ) // Box da Data de Emissao
				Else
					oReport:Box( 2200, 1080 , 2340, 1400 ) // Box da Data de Emissao
				Endif

				oReport:Box( 2320,  010 , 2406, 1220 ) // Box do Reajuste
				oReport:Box( 2320, 1220 , 2460, 1750 ) // Box do IPI e do Frete
				oReport:Box( 2320, 1750 , 2460, nPageWidth-4 ) // Box do ICMS, Despesas e Desconto
				If nSaida == 5 .Or. nSaida == 3
					oReport:Box( 2406,  010 , 2700, 1220 ) // Box das Observacoes
				Else
					oReport:Box( 2406,  010 , 2720, 1220 ) // Box das Observacoes
				Endif

				cMensagem:= Formula(SC7->C7_MSG)
				If !Empty(cMensagem)
					oReport:SkipLine()
					oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
				Endif

				If SC7->C7_MOEDA == 1
					nDescProd := xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				Else
					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nDescProd := NoRound((xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)))
						Elseif AllTrim(cRegra) == "ROUND"
							nDescProd := Round((xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)),2)
						Else
							nDescProd := xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						Endif
					Endif
				Endif

				//Report:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
					//TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
					//TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
					//TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
					//TransForm(nDescProd , cPicC7_VLDESC ),;
					//2022, 050 )
				//		oReport:PrintText( "", 2022, 050 ) // imprimir linha em branco no lugar dos descontos

				oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )

				cAplic := Alltrim(LibPC(SC7->C7_NUM))
				aAplic:= StrToKArr(cAplic,";")

				oReport:PrintText( "Aplicacao: " +IIF(VALTYPE(aAplic) == "A" .AND. !EMPTY(aAplic),SubStr(aAplic[1],1,107),"") ,2022, 050 ) 	//Aplicação

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o Arquivo de Empresa SM0.                          ³
				//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
				//³ e o Local de Cobranca :                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRecnoSM0 := SM0->(Recno())
				SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))

				cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
				cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

				If Empty(MV_PAR13) //"Local de Entrega  : "

					cLocEntr := AllTrim(SC7->C7_LENT)

					If Empty(cLocEntr)
						If !Empty(SC7->C7_MEDICAO)
							If CND->(DbSeek(SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV+SC7->C7_PLANILH+SC7->C7_MEDICAO))
								cLocEntr := AllTrim(CND->CND_XLENT)
							EndIf
						EndIf
					EndIf

					//oReport:PrintText(STR0008 + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),cPicA2_CEP),, 050 )
					oReport:PrintText(STR0008 + Alltrim(cLocEntr),, 050 )

				Else
					oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
				Endif


				SM0->(dbGoto(nRecnoSM0))
				oReport:PrintText(STR0010 + Alltrim(SM0->M0_ENDCOB)+"  "+Alltrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),cPicA2_CEP),, 050 )

				oReport:SkipLine()
				oReport:SkipLine()

				SE4->(dbSeek(cFilSE4+SC7->C7_COND))

				nLinPC := oReport:Row()
				oReport:PrintText( "Condicao de Pagto:  " +SubStr(SE4->E4_CODIGO,1,40)+" - "+SubStr(SE4->E4_DESCRI,1,34),nLinPC,050 )
				oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
				oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 ) //"Total das Mercadorias : "
				oReport:SkipLine()
				nLinPC := oReport:Row()

				If cPaisLoc<>"BRA"
					aValIVA := MaFisRet(,"NF_VALIMP")
					nValIVA :=0
					If !Empty(aValIVA)
						For nY:=1 to Len(aValIVA)
							nValIVA+=aValIVA[nY]
						Next nY
					EndIf
					_cAux := " "
					if !EMPTY(ALLTRIM(SC7->C7_XCONDPG))
						_cAux := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"PF"+ALLTRIM(SC7->C7_XCONDPG), 1, ""))
					endif

					//oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
					oReport:PrintText("Forma de Pagamento: " + ALLTRIM(SC7->C7_XCONDPG) +"-" + _cAux +".",nLinPC, 050 )
					oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
					oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
					Transform(xMoeda(nValIVA,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 )
				Else
					_cAux := " "
					if !EMPTY(ALLTRIM(SC7->C7_XCONDPG))
						_cAux := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"PF"+ALLTRIM(SC7->C7_XCONDPG), 1, ""))
					endif

					//oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
					oReport:PrintText("Forma de Pagamento: " + ALLTRIM(SC7->C7_XCONDPG) +"-" + _cAux +".",nLinPC, 050 )
					oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
					oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
					Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 )
				Endif
				oReport:SkipLine()

				IF SC7->C7_MOEDA == 1
					nTotIpi	  	:= MaFisRet(,'NF_VALIPI')
					nTotIcms  	:= MaFisRet(,'NF_VALICM')
					nTotDesp  	:= MaFisRet(,'NF_DESPESA')
					nTotFrete 	:= nFrete //MaFisRet(,'NF_FRETE')
					nTotSeguro	:= MaFisRet(,'NF_SEGURO')
					nTotalNF  	:= MaFisRet(,'NF_TOTAL') + nTotFrete
				Else
					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nTotFrete 	:= NoRound(xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
							nTotSeguro 	:= NoRound(xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
							nTotDesp	:= NoRound(xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
						Elseif AllTrim(cRegra) == "ROUND"
							nTotFrete 	:= Round(xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
							nTotSeguro 	:= Round(xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
							nTotDesp	:= Round(xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
						Else
							nTotFrete 	:= xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
							nTotSeguro 	:= xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
							nTotDesp	:= xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						EndIf
					EndIf
					nTotalNF	:= nTotal + nFrete + nSeguro + nDesp
					nTotalNF	:= xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) - nDescProd
				EndIf

				oReport:SkipLine()
				oReport:SkipLine()
				nLinPC := oReport:Row()

				//If SM4->(dbSeek(cFilSM4+SC7->C7_REAJUST))
				//	oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
				//EndIf

				if ALLTRIM(SC7->C7_X2CO)== "E"
					_cAux :=	"Emitente"
				elseif ALLTRIM(SC7->C7_X2CO)== "D"
					_cAux :=	"Destinatário"
				endif

				oReport:PrintText("Descarregamento: " +  _cAux + ".",nLinPC, 050 )

				If cPaisLoc == "BRA"
					oReport:PrintText( "Total do IPI: "  + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1320 ) //"IPI      :"
					oReport:PrintText( "Total do ICMS: " + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1815 ) //"ICMS     :"
				EndIf
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( "Frete       : " + Transform(nTotFrete , tm(nTotFrete,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1320 ) //"Frete    :"
				oReport:PrintText( "Despesas     : " + Transform(nTotDesp , tm(nTotDesp ,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1815 ) //"Despesas :"
				oReport:SkipLine()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializar campos de Observacoes.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cObs02) .Or. cObs01 == cObs02

					cObs02 := ""
					aAux1 := strTokArr(cObs01, chr(13)+chr(10))
					nQtdLinhas := 0
					for nX := 1 To  Len(aAux1)
						nQtdLinhas += Ceiling(Len(aAux1[nX]) / 65)
					Next nX
					If nQtdLinhas <= 8
						R110cObs(aAux1, 65)
					Else
						R110cObs(aAux1, 40)
					EndIf
				Else
					cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<65,Len(cObs01),65))
					cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<65,Len(cObs02),65))
					cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<65,Len(cObs03),65))
					cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<65,Len(cObs04),65))
					cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<65,Len(cObs05),65))
					cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<65,Len(cObs06),65))
					cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<65,Len(cObs07),65))
					cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<65,Len(cObs08),65))
					cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<65,Len(cObs09),65))
					cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<65,Len(cObs10),65))
					cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<65,Len(cObs11),65))
					cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<65,Len(cObs12),65))
					cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<65,Len(cObs13),65))
					cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<65,Len(cObs14),65))
					cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<65,Len(cObs15),65))
					cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<65,Len(cObs16),65))
				EndIf

				cComprador:= ""
				cAlter	  := ""
				cAprov	  := ""
				lNewAlc	  := .F.
				lLiber 	  := .F.
				lRejeit	  := .F.


				//Incluida validação para os pedidos de compras por item do pedido  (IP/alçada)
				cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")

				If cTipoSC7 == "PC"

					If SCR->(dbSeek(cFilSCR+cTipoSC7+SC7->C7_NUM))
						cTst = ''
					Else
						If SCR->(dbSeek(cFilSCR+"IP"+SC7->C7_NUM))
							cTst = ''
						EndIf
					EndIf

				Else

					SCR->(dbSeek(cFilSCR+cTipoSC7+SC7->C7_NUM))
				EndIf

				If !Empty(SC7->C7_APROV) .Or. (Empty(SC7->C7_APROV) .And. SCR->CR_TIPO == "IP")

					lNewAlc := .T.
					oHash:Get(SC7->C7_USER,@xUsrName)
					cComprador := xUsrName
					If SC7->C7_CONAPRO != "B"
						IF SC7->C7_CONAPRO == "R"
							lRejeit	  := .T.
						Else
							lLiber    := .T.
						EndIf
					EndIf

					While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilSCR+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO $ "PC|AE|IP"
						oHash:Get(SCR->CR_USER,@xUsrName)
						cAprov += AllTrim(xUsrName)+" ["
						Do Case
						Case SCR->CR_STATUS=="02" //Pendente
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="03" //Liberado
							cAprov += "Ok"
						Case SCR->CR_STATUS=="04" //Bloqueado
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="05" //Nivel Liberado
							cAprov += "##"
						Case SCR->CR_STATUS=="06" //Rejeitado
							cAprov += "REJ"

						OtherWise                 //Aguar.Lib
							cAprov += "??"
						EndCase
						cAprov += "] - "

						SCR->(dbSkip())
					Enddo
					If !Empty(SC7->C7_GRUPCOM)
						SAJ->(dbSeek(cFilSAJ+SC7->C7_GRUPCOM))
						While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == cFilSAJ+SC7->C7_GRUPCOM
							If SAJ->AJ_USER != SC7->C7_USER
								If nPAJ_MSBLQL > 0
									If SAJ->AJ_MSBLQL == "1"
										dbSkip()
										LOOP
									EndIf
								EndIf
								oHash:Get(SAJ->AJ_USER,@xUsrName)
								cAlter += AllTrim(xUsrName)+"/"
							EndIf

							SAJ->(dbSkip())
						EndDo
					EndIf
					If "[BLQ]" $ cAprov
						lLiber    := .F.
					EndIf
				EndIf

				nLinPC := oReport:Row()
				oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
				oReport:PrintText( "Seguro      : " + Transform(nTotSeguro , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1320 ) // "SEGURO   :"
				oReport:PrintText("Desconto     : "  + Transform(nDescProd , cPicC7_VLDESC) ,nLinPC, 1815 ) // "Desconto   :"

				oReport:SkipLine()

				nLinPC2 := oReport:Row()
				oReport:PrintText(cObs01,,050 )
				oReport:PrintText(cObs02,,050 )

				nLinPC := oReport:Row()
				oReport:PrintText(cObs03,nLinPC,050 )

				If !lNewAlc
					oReport:PrintText( STR0078 + Transform(nTotalNF , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1650 ) //"Total Geral :"
				Else
					If lLiber
						oReport:PrintText( STR0078 + Transform(nTotalNF , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1650 )
					Else
						oReport:PrintText( STR0078 + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),IF(lRejeit,STR0130,STR0051),STR0086) ,nLinPC,1390 )
					EndIf
				EndIf
				oReport:SkipLine()

				oReport:PrintText(cObs04,,050 )
				oReport:PrintText(cObs05,,050 )
				oReport:PrintText(cObs06,,050 )
				nLinPC3 := oReport:Row()
				oReport:PrintText(cObs07,,050 )
				oReport:PrintText(cObs08,,050 )
				oReport:PrintText(cObs09,nLinPC2,650 )
				oReport:SkipLine()
				oReport:PrintText(cObs10,,650 )
				oReport:PrintText(cObs11,,650 )
				oReport:PrintText(cObs12,,650 )
				oReport:PrintText(cObs13,,650 )
				oReport:PrintText(cObs14,,650 )
				oReport:PrintText(cObs15,,650 )
				oReport:PrintText(cObs16,,650 )

				If !lNewAlc

					oReport:Box( 2700, 0010 , 3020, 0400 )
					oReport:Box( 2700, 0400 , 3020, 0800 )
					oReport:Box( 2700, 0800 , 3020, 1220 )
					oReport:Box( 2600, 1220 , 3020, 1770 )
					oReport:Box( 2600, 1770 , 3020, nPageWidth-4 )

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
					oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "R",STR0132,IF(SC7->C7_TPFRETE $ "D",STR0133,IF(SC7->C7_TPFRETE $ "T",STR0134," " ) )))) ,nLinPC,1820 ) //STR0132 Por conta remetente, STR0133 Por conta destinatario,STR0134 Por Conta Terceiros.
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
					oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
					oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
					oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
					oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
					oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()
					If nSaida <> 8 //Se não for envio direto pro email, pular essa linha
						oReport:SkipLine()
					Endif
					If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
						oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
						//oReport:SkipLine()
						oReport:PrintText("CASO COBRANCA NAO SEJA EM BOLETO BANCARIO, FAVOR FORNECER DADOS PARA DEPOSITO NA NOTA FISCAL.",,050 )

					Else
						oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
					EndIf

				Else

					oReport:Box( 2570, 1220 , 2700, 1820 )         // box pedido status do pedido
					If nSaida == 5 .Or. nSaida == 3
						oReport:Box( 2570, 1820 , 2700, nPageWidth-4 ) // box do obs do frete
					Else
						oReport:Box( 2570, 1800 , 2700, nPageWidth-4 ) // box do obs do frete
					Endif
					oReport:Box( 2700, 0010 , 2850, nPageWidth-4 ) // box comprador / aprovador

					//oReport:Box( 2700, 0010 , nPageHeight-4, nPageWidth-4 )
					//oReport:Box( 2970, 0010 , 3020, nPageWidth-4 )

					nLinPC := nLinPC3

					oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber , STR0050 , IF(lRejeit,STR0130,STR0051) ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1260 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
					oReport:PrintText( STR0080 + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1840 ) //"Obs. do Frete: "
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
					oReport:SkipLine()
					//oReport:PrintText(STR0053+" "+ If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
					//oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"

					nLinCar := 140
					nColCarac := 050
					nCCarac := 140

					nAprovLin := Ceiling( IIF(Len(AllTrim(cAprov)) < 75, 75, Len(AllTrim(cAprov))) / nLinCar)

					For nX := 1 to nAprovLin
						If nX == 1
							oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,nLinCar) , " " ),,nColCarac ) //"Aprovador(es) :"
							nColCarac+=250
						Else
							oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,nCCarac+1,nLinCar) , " " ),,nColCarac )
							nCCarac+=nLinCar
						EndIf
					Next nx

					//nX:=nAprovLin
					//While nX <= 3
					//	oReport:SkipLine()
					//	nX:=nX+1
					//EndDo

					nLinPC := oReport:Row()

					//oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )

					//cAplic := Alltrim(LibPC(SC7->C7_NUM))
					//aAplic:= StrToKArr(cAplic,";")

					//oReport:SkipLine()
					//nLinPC := oReport:Row()

					//oReport:PrintText( "Aplicacao: " +IIF(VALTYPE(aAplic) == "A" .AND. !EMPTY(aAplic),SubStr(aAplic[1],1,107),"") ,, 050 ) 	//Aplicação

					nLinPC := oReport:Row()

					//oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
					//oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
					//oReport:PrintText(       "|  "+STR0131 ,nLinPC, 830 ) 	//"Ok:REJEITADO"
					//oReport:PrintText(       "|  "+STR0062 ,nLinPC, 1050 ) 	//"??:Aguar.Lib"
					//oReport:PrintText(       "|  "+STR0067 ,nLinPC, 1300 )	//"##:Nivel Lib"
					//oReport:SkipLine()

					oReport:SkipLine()
					If nSaida <> 8 //Se não for envio direto pro email, pular essa linha
						oReport:SkipLine()
					Endif
					If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
						oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
						//oReport:SkipLine()
						oReport:PrintText("CASO COBRANCA NAO SEJA EM BOLETO BANCARIO, FAVOR FORNECER DADOS PARA DEPOSITO NA NOTA FISCAL.",,050 )
					Else
						oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
					EndIf
					//oReport:SkipLine()

					nLinPC := oReport:Row()+30
					oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )
					oReport:SkipLine()
					oReport:SkipLine()

				/* Bloco para inclusão de consulta na tabela de cadastro de mensagem para exibir a mensagem ativa para o rodapé do pedido
				   24/02/2023
				   Squad Suprimentos 
				*/
					dbSelectArea("ZAA")
					dbSetOrder(1)
					dbGoTop()

					While !ZAA->(Eof())
						If ZAA->ZAA_STATUS == "2"
							Exit
						Endif
						ZAA->(dbSkip())
					End

					cMsgLin1 := Alltrim(ZAA->ZAA_LINHA1)
					cMsgLin2 := Alltrim(ZAA->ZAA_LINHA2)
					cMsgLin3 := Alltrim(ZAA->ZAA_LINHA3)
					cMsgLin4 := Alltrim(ZAA->ZAA_LINHA4)
					cMsgLin5 := Alltrim(ZAA->ZAA_LINHA5)

					ZAA->(dbCloseArea())
					dbSelectArea("SC7")

					nLinPC := oReport:Row()

					oReport:PrintText(Alltrim(cMsgLin1),,050 )
					oReport:PrintText(Alltrim(cMsgLin2),,050 )
					oReport:PrintText(Alltrim(cMsgLin3),,050 )
					oReport:PrintText(Alltrim(cMsgLin4),,050 )
					oReport:PrintText(Alltrim(cMsgLin5),,050 )

				EndIf

			Next nVias

			MaFisEnd()


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


			If Len(aRecnoSave) > 0
				For nX :=1 to Len(aRecnoSave)
					dbGoto(aRecnoSave[nX])
					If(SC7->C7_QTDREEM >= 99)
						If nRet == 1
							RecLock("SC7",.F.)
							SC7->C7_EMITIDO := "S"
							MsUnLock()
						Elseif nRet == 2
							RecLock("SC7",.F.)
							SC7->C7_QTDREEM := 1
							SC7->C7_EMITIDO := "S"
							MsUnLock()
						Elseif nRet == 3
							//cancelar
						Endif
					Else
						RecLock("SC7",.F.)
						SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Endif
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC7->(dbGoto(aRecnoSave[Len(aRecnoSave)]))
			Endif

			Aadd(aPedMail,aPedido)

			aRecnoSave := {}

			SC7->(dbSkip())

		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
		//³ enviada por email, fornecendo um Array para o usuario conten ³
		//³ do os pedidos enviados para possivel manipulacao.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("M110MAIL")
			lEnvMail := (oReport:nDevice == 3)
			If lEnvMail
				Execblock("M110MAIL",.F.,.F.,{aPedMail})
			EndIf
		EndIf

		If lAuto .And. !lImpri
			Aviso(STR0104,STR0105,{"OK"})
		Endif

		SC7->(dbClearFilter())
		SC7->(dbSetOrder(1))

	ElseIf nSaida == 1

		While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02

			// If incluÃ­do para o SP 23070 - Squad Suprimentos
			If lPCAprov .And. SC7->C7_CONAPRO <> "L"

				nPos := aScan(aPCBloq,{|x|x[1] = SC7->C7_NUM})

				If nPos == 0
					Aadd( aPCBloq, { SC7->C7_NUM, DtoC(SC7->C7_EMISSAO), SC7->C7_FORNECE+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") } )
				Endif
				SC7->(dbSkip())
				Loop
			Endif

			If SC7->C7_EMITIDO == "S" .AND. MV_PAR05 == 1
				SC7->(dbSkip())
				Loop
			Endif

			If (SC7->C7_CONAPRO == "B" .AND. MV_PAR10 == 1) .OR.;
					(SC7->C7_CONAPRO != "B" .AND. MV_PAR10 == 2)
				SC7->(dbSkip())
				Loop
			Endif

			If (SC7->C7_EMISSAO < MV_PAR03) .OR. (SC7->C7_EMISSAO > MV_PAR04)
				SC7->(dbSkip())
				Loop
			Endif

			If SC7->C7_TIPO == 2
				SC7->(dbSkip())
				Loop
			EndIf

			//ÃƒÅ¡Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ã‚Â¿
			//Ã‚Â³ Filtra Tipo de SCs Firmes ou Previstas                       Ã‚Â³
			//Ãƒâ‚¬Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ„¢
			If !MtrAValOP(MV_PAR11, 'SC7')
				SC7->(dbSkip())
				Loop
			EndIf

			If oReport:Cancel()
				Exit
			EndIf

			MaFisEnd()
			R110FIniPC(SC7->C7_NUM,,,cFiltro)

			cObs01    := " "
			cObs02    := " "
			cObs03    := " "
			cObs04    := " "
			cObs05    := " "
			cObs06    := " "
			cObs07    := " "
			cObs08    := " "
			cObs09    := " "
			cObs10    := " "
			cObs11    := " "
			cObs12    := " "
			cObs13    := " "
			cObs14    := " "
			cObs15    := " "
			cObs16    := " "
			aSC7Obs	  := {}

			nPCOk++ // Caso o registro atenda todos os critÃ©rios, alimento este contator para imprimir os pedidos


			//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
			//Â³ Roda a impressao conforme o numero de vias informado no mv_par09 Â³
			//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
			For nVias := 1 to mv_par09

				//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
				//Â³ Dispara a cabec especifica do relatorio.                     Â³
				//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
				oReport:EndPage()
				//oReport:Box( 260, 010, 3020 , nPageWidth-4 ) //-- Box dos itens do relatÃ³rio
				oReport:Box( 260, 010, 3250 /*nPageHeight-5*/ , nPageWidth-4 ) //-- Box dos itens do relatÃ³rio
				nPagina  := 0
				nPrinted := 0
				nTotal   := 0
				nTotMerc := 0
				nDescProd:= 0
				nLinObs  := 0
				nRecnoSC7:= SC7->(Recno())
				cNumSC7  := SC7->C7_NUM
				aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

				While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM == cNumSC7

					// If incluÃ­do para o SP 23070 - Squad Suprimentos
					If lPCAprov .And. SC7->C7_CONAPRO <> "L"

						nPos := aScan(aPCBloq,{|x|x[1] = SC7->C7_NUM})

						If nPos == 0
							Aadd( aPCBloq, { SC7->C7_NUM, DtoC(SC7->C7_EMISSAO), SC7->C7_FORNECE+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") } )
						Endif
					SC7->(dbSkip())
					Loop
					Endif

					If SC7->C7_EMITIDO == "S" .AND. MV_PAR05 == 1
						SC7->(dbSkip())
						Loop
					Endif

					If (SC7->C7_CONAPRO == "B" .AND. MV_PAR10 == 1) .OR.;
							(SC7->C7_CONAPRO != "B" .AND. MV_PAR10 == 2)
						SC7->(dbSkip())
						Loop
					Endif

					If (SC7->C7_EMISSAO < MV_PAR03) .OR. (SC7->C7_EMISSAO > MV_PAR04)
						SC7->(dbSkip())
						Loop
					Endif

					If SC7->C7_TIPO == 2
						SC7->(dbSkip())
						Loop
					EndIf

					//ÃƒÅ¡Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ã‚Â¿
					//Ã‚Â³ Filtra Tipo de SCs Firmes ou Previstas                       Ã‚Â³
					//Ãƒâ‚¬Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ€Ãƒâ„¢
					If !MtrAValOP(MV_PAR11, 'SC7')
						SC7->(dbSkip())
						Loop
					EndIf

					If oReport:Cancel()
						Exit
					EndIf

					oReport:IncMeter()

					If oReport:Row() > oReport:LineHeight() * 100
						//oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth-4 )
						oReport:SkipLine()
						oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
						oReport:EndPage()
						oReport:Box( 260, 010, 3250 /*nPageHeight*/ , nPageWidth-4 ) //-- Box dos itens do relatório
					EndIf

					//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
					//Â³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.Â³
					//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
					If Ascan(aRecnoSave,SC7->(Recno())) == 0
						AADD(aRecnoSave,SC7->(Recno()))
					Endif

					//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
					//Â³ Inicializa o descricao do Produto conf. parametro digitado.Â³
					//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
					cDescPro :=  ""
					If Empty(mv_par06)
						mv_par06 := "B1_DESC"
					EndIf

					If AllTrim(mv_par06) == "B1_DESC"
						SB1->(dbSeek( cFilSB1 + SC7->C7_PRODUTO ))
						cDescPro := SB1->B1_DESC
					ElseIf AllTrim(mv_par06) == "B5_CEME"
						If SB5->(dbSeek( cFilSB5 + SC7->C7_PRODUTO ))
							cDescPro := SB5->B5_CEME
						EndIf
					ElseIf AllTrim(mv_par06) == "C7_DESCRI"
						cDescPro := SC7->C7_DESCRI
					EndIf

					If Empty(cDescPro)
						SB1->(dbSeek( cFilSB1 + SC7->C7_PRODUTO ))
						cDescPro := SB1->B1_DESC
					EndIf

					If SA5->(dbSeek(cFilSA5+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
						cDescPro := Alltrim(cDescPro) + " ("+Alltrim(SA5->A5_CODPRF)+")"
					EndIf

					If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
						nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
					Else
						nDescProd+=SC7->C7_VLDESC
					Endif
					//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
					//Â³ Inicializacao da Observacao do Pedido.                       Â³
					//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
					If lC7OBSChar .AND. !Empty(SC7->C7_OBS) .And. nLinObs < 17

						If !(SC7->C7_OBS $ SC7->C7_OBSM)

							nLinObs++
							cVar:="cObs"+StrZero(nLinObs,2)

							If nLinObs == 1

								Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))

							Else

								If cObsAnt <> Alltrim(SC7->C7_OBS)
									Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))
								Endif

							Endif

							cObsAnt := Alltrim(SC7->C7_OBS)

						EndIf

					Endif

					If !Empty(SC7->C7_OBSM) .And. nLinObs < 17
						nLinObs++
						cVar:="cObs"+StrZero(nLinObs,2)
						if Ascan(aSC7Obs,{|x| AllTrim(x) == Alltrim(SC7->C7_OBSM) }) == 0
							aAdd(aSC7Obs, Alltrim(SC7->C7_OBSM))
							Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBSM))
						endif
					Endif

					nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,0)
					nFrete   := If(SC7->C7_TPFRETE=="F",SC7->C7_XFRETE,0)

					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nValTotSC7            := NoRound( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
						ElseIf AllTrim(cRegra) == "ROUND"
							nValTotSC7            := Round( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
						Else
							nValTotSC7            := SC7->C7_TOTAL
						EndIf
						If nValTotSC7 > 0
							nTotal 	:= nTotal 	+ nValTotSC7
							IF SC7->C7_MOEDA == 1
								nTotMerc   := MaFisRet(,"NF_TOTAL")
							ELSE
								//nFrete		:= nFrete 	+ SC7->C7_VALFRE
								//nFrete		:= nFrete 	+ SC7->C7_XFRETE    // ALTERADO ADRIANO 16/01/15 PARA ATERNDER NOVO PADRÃƒO FOB
								nSeguro		:= nSeguro 	+ SC7->C7_SEGURO
								nDesp		:= nDesp 	+ SC7->C7_DESPESA
								nTotMerc	+= nValTotSC7
							ENDIF
						EndIf
					EndIf

					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nValTotSC7	:= NoRound( xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2 )
						ElseIf AllTrim(cRegra) == "ROUND"
							nValTotSC7	:= Round( xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2 )
						Else
							nValTotSC7	:= xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						Endif
					ENDIF

					If oReport:nDevice != 4 .Or. (oReport:nDevice == 4 .And. !oReport:lXlsTable .And. oReport:lXlsHeader)  //impressao em planilha tipo tabela
						oSection2:Cell("C7_NUM"):Disable()
					EndIf

					If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
						oSection2:Cell("C7_SEGUM"  ):Enable()
						oSection2:Cell("C7_QTSEGUM"):Enable()
						oSection2:Cell("C7_UM"     ):Disable()
						oSection2:Cell("C7_QUANT"  ):Disable()
						nVlUnitSC7 := xMoeda(((SC7->C7_PRECO*SC7->C7_QUANT)/SC7->C7_QTSEGUM),SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
					ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
						oSection2:Cell("C7_SEGUM"  ):Disable()
						oSection2:Cell("C7_QTSEGUM"):Disable()
						oSection2:Cell("C7_UM"     ):Enable()
						oSection2:Cell("C7_QUANT"  ):Enable()
						nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						//Else
						//	oSection2:Cell("C7_SEGUM"  ):Enable()
						//	oSection2:Cell("C7_QTSEGUM"):Enable()
						//	oSection2:Cell("C7_UM"     ):Enable()
						//	oSection2:Cell("C7_QUANT"  ):Enable()
						//	nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
					EndIf

					If cPaisLoc <> "BRA" .Or. mv_par08 == 2
						oSection2:Cell("C7_IPI" ):Disable()
					EndIf

					If mv_par08 == 1 .OR. mv_par08 == 3
						//oSection2:Cell("OPCC"):Disable()
					Else
						oSection2:Cell("C7_CC"):Disable()
						oSection2:Cell("C7_NUMSC"):Disable()
						If !Empty(SC7->C7_OP)
							cOPCC := STR0065 + " " + SC7->C7_OP
						ElseIf !Empty(SC7->C7_CC)
							cOPCC := STR0066 + " " + SC7->C7_CC
						EndIf
					EndIf


					If oReport:nDevice == 4 .And. oReport:lXlsTable .And. !oReport:lXlsHeader  //impressao em planilha tipo tabela
						oSection1:Init()
						TRPosition():New(oSection1,"SA2",1,{ || cFilSA2 + SC7->C7_FORNECE + SC7->C7_LOJA })
						oSection1:PrintLine()
						oSection2:PrintLine()
						oSection1:Finish()
					Else
						oSection2:PrintLine()
					EndIf

					nPrinted++
					lImpri  := .T.

					SC7->(dbSkip())

				EndDo

				SC7->(dbGoto(nRecnoSC7))

				If oReport:Row() > oReport:LineHeight() * 68

					//oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth-4 )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....

					//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
					//Â³ Dispara a cabec especifica do relatorio.                     Â³
					//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
					oReport:EndPage()
					oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape

					oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )

				EndIf

				//oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )

				oReport:Box( 1990 ,010, 3250 , nPageWidth-4 )
				oReport:Box( 2080 ,010, 3250 , nPageWidth-4 )
				oReport:Box( 2200 ,010, 3250 , nPageWidth-4 )
				oReport:Box( 2320 ,010, 3250 , nPageWidth-4 )

				oReport:Box( 2200, 1080 , 2320, 1400 ) // Box da Data de Emissao
				oReport:Box( 2320,  010 , 2406, 1220 ) // Box do Reajuste
				oReport:Box( 2320, 1220 , 2460, 1750 ) // Box do IPI e do Frete
				oReport:Box( 2320, 1750 , 2460, nPageWidth-4 ) // Box do ICMS, Despesas e Desconto
				oReport:Box( 2406,  010 , 2700, 1220 ) // Box das Observacoes

				cMensagem:= Formula(SC7->C7_MSG)
				If !Empty(cMensagem)
					oReport:SkipLine()
					oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
				Endif

				If SC7->C7_MOEDA == 1
					nDescProd := xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				Else
					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nDescProd := NoRound((xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)))
						Elseif AllTrim(cRegra) == "ROUND"
							nDescProd := Round((xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)),2)
						Else
							nDescProd := xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						Endif
					Endif
				Endif

				//Report:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
					//TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
					//TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
					//TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
					//TransForm(nDescProd , cPicC7_VLDESC ),;
					//2022, 050 )
				//oReport:PrintText( "", 2022, 050 ) // imprimir linha em branco no lugar dos descontos

				oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )

				cAplic := Alltrim(LibPC(SC7->C7_NUM))
				aAplic:= StrToKArr(cAplic,";")

				oReport:PrintText( "Aplicacao: " +IIF(VALTYPE(aAplic) == "A" .AND. !EMPTY(aAplic),SubStr(aAplic[1],1,107),"") ,2022, 050 ) 	//Aplicação

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
				//Â³ Posiciona o Arquivo de Empresa SM0.                          Â³
				//Â³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "Â³
				//Â³ e o Local de Cobranca :                                      Â³
				//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
				nRecnoSM0 := SM0->(Recno())
				SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))

				cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
				cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

				If Empty(MV_PAR13) //"Local de Entrega  : "

					cLocEntr := AllTrim(SC7->C7_LENT)

					If Empty(cLocEntr)
						If !Empty(SC7->C7_MEDICAO)
							If CND->(DbSeek(SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV+SC7->C7_PLANILH+SC7->C7_MEDICAO))
								cLocEntr := AllTrim(CND->CND_XLENT)
							EndIf
						EndIf
					EndIf

					//oReport:PrintText(STR0008 + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),cPicA2_CEP),, 050 )
					oReport:PrintText(STR0008 + Alltrim(cLocEntr),, 050 )

				Else
					oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
				Endif

				SM0->(dbGoto(nRecnoSM0))
				oReport:PrintText(STR0010 + Alltrim(SM0->M0_ENDCOB)+"  "+Alltrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),cPicA2_CEP),, 050 )

				oReport:SkipLine()
				oReport:SkipLine()

				SE4->(dbSeek(cFilSE4+SC7->C7_COND))

				nLinPC := oReport:Row()
				oReport:PrintText( "Condicao de Pagto:  " +SubStr(SE4->E4_CODIGO,1,40)+" - "+SubStr(SE4->E4_DESCRI,1,34),nLinPC,050 )
				oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
				oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 ) //"Total das Mercadorias : "
				oReport:SkipLine()
				nLinPC := oReport:Row()

				If cPaisLoc<>"BRA"
					aValIVA := MaFisRet(,"NF_VALIMP")
					nValIVA :=0
					If !Empty(aValIVA)
						For nY:=1 to Len(aValIVA)
							nValIVA+=aValIVA[nY]
						Next nY
					EndIf
					_cAux := " "
					if !EMPTY(ALLTRIM(SC7->C7_XCONDPG))
						_cAux := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"PF"+ALLTRIM(SC7->C7_XCONDPG), 1, ""))
					endif

					//oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
					oReport:PrintText("Forma de Pagamento: " + ALLTRIM(SC7->C7_XCONDPG) +"-" + _cAux +".",nLinPC, 050 )
					oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
					oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
					Transform(xMoeda(nValIVA,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 )
				Else
					_cAux := " "
					if !EMPTY(ALLTRIM(SC7->C7_XCONDPG))
						_cAux := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"PF"+ALLTRIM(SC7->C7_XCONDPG), 1, ""))
					endif

					//oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
					oReport:PrintText("Forma de Pagamento: " + ALLTRIM(SC7->C7_XCONDPG) +"-" + _cAux +".",nLinPC, 050 )
					oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
					oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
					Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 )
				Endif
				oReport:SkipLine()

				IF SC7->C7_MOEDA == 1
					nTotIpi	  	:= MaFisRet(,'NF_VALIPI')
					nTotIcms  	:= MaFisRet(,'NF_VALICM')
					nTotDesp  	:= MaFisRet(,'NF_DESPESA')
					nTotFrete 	:= nFrete //MaFisRet(,'NF_FRETE')
					nTotSeguro	:= MaFisRet(,'NF_SEGURO')
					nTotalNF  	:= MaFisRet(,'NF_TOTAL') + nTotFrete
				Else
					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nTotFrete 	:= NoRound(xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
							nTotSeguro 	:= NoRound(xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
							nTotDesp	:= NoRound(xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
						Elseif AllTrim(cRegra) == "ROUND"
							nTotFrete 	:= Round(xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
							nTotSeguro 	:= Round(xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
							nTotDesp	:= Round(xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
						Else
							nTotFrete 	:= xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
							nTotSeguro 	:= xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
							nTotDesp	:= xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						EndIf
					EndIf
					nTotalNF	:= nTotal + nFrete + nSeguro + nDesp
					nTotalNF	:= xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) - nDescProd
				EndIf

				oReport:SkipLine()
				oReport:SkipLine()
				nLinPC := oReport:Row()

				//If SM4->(dbSeek(cFilSM4+SC7->C7_REAJUST))
				//	oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
				//EndIf

				if ALLTRIM(SC7->C7_X2CO)== "E"
					_cAux :=	"Emitente"
				elseif ALLTRIM(SC7->C7_X2CO)== "D"
					_cAux :=	"DestinatÃ¡rio"
				endif

				oReport:PrintText("Descarregamento: " +  _cAux + ".",nLinPC, 050 )

				If cPaisLoc == "BRA"
					oReport:PrintText( "Total do IPI: "  + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1320 ) //"IPI      :"
					oReport:PrintText( "Total do ICMS: " + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1815 ) //"ICMS     :"
				EndIf
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( "Frete       : " + Transform(nTotFrete , tm(nTotFrete,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1320 ) //"Frete    :"
				oReport:PrintText( "Despesas     : " + Transform(nTotDesp , tm(nTotDesp ,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1815 ) //"Despesas :"
				oReport:SkipLine()

				//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
				//Â³ Inicializar campos de Observacoes.                           Â³
				//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
				If Empty(cObs02) .Or. cObs01 == cObs02

					cObs02 := ""
					aAux1 := strTokArr(cObs01, chr(13)+chr(10))
					nQtdLinhas := 0
					for nX := 1 To  Len(aAux1)
						nQtdLinhas += Ceiling(Len(aAux1[nX]) / 65)
					Next nX
					If nQtdLinhas <= 8
						R110cObs(aAux1, 65)
					Else
						R110cObs(aAux1, 40)
					EndIf
				Else
					cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<65,Len(cObs01),65))
					cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<65,Len(cObs02),65))
					cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<65,Len(cObs03),65))
					cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<65,Len(cObs04),65))
					cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<65,Len(cObs05),65))
					cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<65,Len(cObs06),65))
					cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<65,Len(cObs07),65))
					cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<65,Len(cObs08),65))
					cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<65,Len(cObs09),65))
					cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<65,Len(cObs10),65))
					cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<65,Len(cObs11),65))
					cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<65,Len(cObs12),65))
					cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<65,Len(cObs13),65))
					cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<65,Len(cObs14),65))
					cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<65,Len(cObs15),65))
					cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<65,Len(cObs16),65))
				EndIf

				cComprador:= ""
				cAlter	  := ""
				cAprov	  := ""
				lNewAlc	  := .F.
				lLiber 	  := .F.
				lRejeit	  := .F.


				//Incluida validaÃ§Ã£o para os pedidos de compras por item do pedido  (IP/alÃ§ada)
				cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")

				If cTipoSC7 == "PC"

					If SCR->(dbSeek(cFilSCR+cTipoSC7+SC7->C7_NUM))
						cTst = ''
					Else
						If SCR->(dbSeek(cFilSCR+"IP"+SC7->C7_NUM))
							cTst = ''
						EndIf
					EndIf

				Else

					SCR->(dbSeek(cFilSCR+cTipoSC7+SC7->C7_NUM))
				EndIf

				If !Empty(SC7->C7_APROV) .Or. (Empty(SC7->C7_APROV) .And. SCR->CR_TIPO == "IP")

					lNewAlc := .T.
					oHash:Get(SC7->C7_USER,@xUsrName)
					cComprador := xUsrName
					If SC7->C7_CONAPRO != "B"
						IF SC7->C7_CONAPRO == "R"
							lRejeit	  := .T.
						Else
							lLiber    := .T.
						EndIf
					EndIf

					While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilSCR+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO $ "PC|AE|IP"
						oHash:Get(SCR->CR_USER,@xUsrName)
						cAprov += AllTrim(xUsrName)+" ["
						Do Case
						Case SCR->CR_STATUS=="02" //Pendente
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="03" //Liberado
							cAprov += "Ok"
						Case SCR->CR_STATUS=="04" //Bloqueado
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="05" //Nivel Liberado
							cAprov += "##"
						Case SCR->CR_STATUS=="06" //Rejeitado
							cAprov += "REJ"

						OtherWise                 //Aguar.Lib
							cAprov += "??"
						EndCase
						cAprov += "] - "

						SCR->(dbSkip())
					Enddo
					If !Empty(SC7->C7_GRUPCOM)
						SAJ->(dbSeek(cFilSAJ+SC7->C7_GRUPCOM))
						While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == cFilSAJ+SC7->C7_GRUPCOM
							If SAJ->AJ_USER != SC7->C7_USER
								If nPAJ_MSBLQL > 0
									If SAJ->AJ_MSBLQL == "1"
										dbSkip()
										LOOP
									EndIf
								EndIf
								oHash:Get(SAJ->AJ_USER,@xUsrName)
								cAlter += AllTrim(xUsrName)+"/"
							EndIf

							SAJ->(dbSkip())
						EndDo
					EndIf
					If "[BLQ]" $ cAprov
						lLiber    := .F.
					EndIf
				EndIf

				nLinPC := oReport:Row()
				oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
				//oReport:PrintText( STR0076 + Transform(nTotSeguro , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1815 ) // "SEGURO   :"
				oReport:PrintText( "Seguro      : " + Transform(nTotSeguro , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1320 ) // "SEGURO   :"
				oReport:PrintText("Desconto     : "  + Transform(nDescProd , cPicC7_VLDESC) ,nLinPC, 1815 ) // "SEGURO   :"

				oReport:SkipLine()

				nLinPC2 := oReport:Row()
				oReport:PrintText(cObs01,,050 )
				oReport:PrintText(cObs02,,050 )

				nLinPC := oReport:Row()
				oReport:PrintText(cObs03,nLinPC,050 )

				If !lNewAlc
					oReport:PrintText( STR0078 + Transform(nTotalNF , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1650 ) //"Total Geral :"
				Else
					If lLiber
						oReport:PrintText( STR0078 + Transform(nTotalNF , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1650 )
					Else
						oReport:PrintText( STR0078 + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),IF(lRejeit,STR0130,STR0051),STR0086) ,nLinPC,1390 )
					EndIf
				EndIf
				oReport:SkipLine()

				oReport:PrintText(cObs04,,050 )
				oReport:PrintText(cObs05,,050 )
				oReport:PrintText(cObs06,,050 )
				nLinPC3 := oReport:Row()
				oReport:PrintText(cObs07,,050 )
				oReport:PrintText(cObs08,,050 )
				oReport:PrintText(cObs09,nLinPC2,650 )
				oReport:SkipLine()
				oReport:PrintText(cObs10,,650 )
				oReport:PrintText(cObs11,,650 )
				oReport:PrintText(cObs12,,650 )
				oReport:PrintText(cObs13,,650 )
				oReport:PrintText(cObs14,,650 )
				oReport:PrintText(cObs15,,650 )
				oReport:PrintText(cObs16,,650 )

				If !lNewAlc

					oReport:Box( 2700, 0010 , 3020, 0400 )
					oReport:Box( 2700, 0400 , 3020, 0800 )
					oReport:Box( 2700, 0800 , 3020, 1220 )
					oReport:Box( 2600, 1220 , 3020, 1770 )
					oReport:Box( 2600, 1770 , 3020, nPageWidth-4 )

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
					oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "R",STR0132,IF(SC7->C7_TPFRETE $ "D",STR0133,IF(SC7->C7_TPFRETE $ "T",STR0134," " ) )))) ,nLinPC,1820 ) //STR0132 Por conta remetente, STR0133 Por conta destinatario,STR0134 Por Conta Terceiros.
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
					oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
					oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
					oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
					oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
					oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()
					If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
						oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
						oReport:SkipLine()
						oReport:PrintText("CASO COBRANCA NAO SEJA EM BOLETO BANCARIO, FAVOR FORNECER DADOS PARA DEPOSITO NA NOTA FISCAL.",,050 )

					Else
						oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
					EndIf

				Else

					oReport:Box( 2570, 1220 , 2700, 1820 )         // box pedido status do pedido
					oReport:Box( 2570, 1820 , 2700, nPageWidth-4 ) // box do obs do frete
					oReport:Box( 2700, 0010 , 2860, nPageWidth-4 ) // box comprador / aprovador

					//oReport:Box( 2700, 0010 , nPageHeight-4, nPageWidth-4 )
					//oReport:Box( 2970, 0010 , 3020, nPageWidth-4 )

					nLinPC := nLinPC3

					oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber , STR0050 , IF(lRejeit,STR0130,STR0051) ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1260 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
					oReport:PrintText( STR0080 + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1840 ) //"Obs. do Frete: "
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
					oReport:SkipLine()
					//oReport:PrintText(STR0053+" "+ If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
					//oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"

					nLinCar := 140
					nColCarac := 050
					nCCarac := 140

					nAprovLin := Ceiling( IIF(Len(AllTrim(cAprov)) < 75, 75, Len(AllTrim(cAprov))) / nLinCar)

					For nX := 1 to nAprovLin
						If nX == 1
							oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,nLinCar) , " " ),,nColCarac ) //"Aprovador(es) :"
							nColCarac+=250
						Else
							oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,nCCarac+1,nLinCar) , " " ),,nColCarac )
							nCCarac+=nLinCar
						EndIf
					Next nx

					nLinPC := oReport:Row()

					//nX:=nAprovLin
					//While nX <= 3
					//	oReport:SkipLine()
					//	nX:=nX+1
					//EndDo

					nLinPC := oReport:Row()

					//oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )

					//cAplic := Alltrim(LibPC(SC7->C7_NUM))
					//aAplic:= StrToKArr(cAplic,";")

					//Report:SkipLine()
					//nLinPC := oReport:Row()

					//oReport:PrintText( "Aplicacao: " +IIF(VALTYPE(aAplic) == "A" .AND. !EMPTY(aAplic),SubStr(aAplic[1],1,107),"") ,nLinPC, 050 ) 	//AplicaÃ§Ã£o

					oReport:SkipLine()

					nLinPC := oReport:Row()

					//oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
					//oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
					//oReport:PrintText(       "|  "+STR0131 ,nLinPC, 830 ) 	//"Ok:REJEITADO"
					//oReport:PrintText(       "|  "+STR0062 ,nLinPC, 1050 ) 	//"??:Aguar.Lib"
					//oReport:PrintText(       "|  "+STR0067 ,nLinPC, 1300 )	//"##:Nivel Lib"
					oReport:SkipLine()

					oReport:SkipLine()
					If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
						oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
						oReport:SkipLine()
						oReport:PrintText("CASO COBRANCA NAO SEJA EM BOLETO BANCARIO, FAVOR FORNECER DADOS PARA DEPOSITO NA NOTA FISCAL.",,050 )
					Else
						oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
					EndIf
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )
					oReport:SkipLine()

				/* Bloco para inclusÃ£o de consulta na tabela de cadastro de mensagem para exibir a mensagem ativa para o rodapÃ© do pedido
				   24/02/2023
				   Squad Suprimentos 
				*/
					dbSelectArea("ZAA")
					dbSetOrder(1)
					dbGoTop()

					While !ZAA->(Eof())
						If ZAA->ZAA_STATUS == "2"
							Exit
						Endif
						ZAA->(dbSkip())
					End

					cMsgLin1 := Alltrim(ZAA->ZAA_LINHA1)
					cMsgLin2 := Alltrim(ZAA->ZAA_LINHA2)
					cMsgLin3 := Alltrim(ZAA->ZAA_LINHA3)
					cMsgLin4 := Alltrim(ZAA->ZAA_LINHA4)
					cMsgLin5 := Alltrim(ZAA->ZAA_LINHA5)

					ZAA->(dbCloseArea())
					dbSelectArea("SC7")

					oReport:PrintText(Alltrim(cMsgLin1),,050 )
					oReport:PrintText(Alltrim(cMsgLin2),,050 )
					oReport:PrintText(Alltrim(cMsgLin3),,050 )
					oReport:PrintText(Alltrim(cMsgLin4),,050 )
					oReport:PrintText(Alltrim(cMsgLin5),,050 )

				EndIf

			Next nVias

			MaFisEnd()


			//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
			//Â³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   Â³
			//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™


			If Len(aRecnoSave) > 0
				For nX :=1 to Len(aRecnoSave)
					dbGoto(aRecnoSave[nX])
					If(SC7->C7_QTDREEM >= 99)
						If nRet == 1
							RecLock("SC7",.F.)
							SC7->C7_EMITIDO := "S"
							MsUnLock()
						Elseif nRet == 2
							RecLock("SC7",.F.)
							SC7->C7_QTDREEM := 1
							SC7->C7_EMITIDO := "S"
							MsUnLock()
						Elseif nRet == 3
							//cancelar
						Endif
					Else
						RecLock("SC7",.F.)
						SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Endif
				Next nX
				//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
				//Â³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. Â³
				//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
				SC7->(dbGoto(aRecnoSave[Len(aRecnoSave)]))
			Endif

			Aadd(aPedMail,aPedido)

			aRecnoSave := {}

			SC7->(dbSkip())

		EndDo

		//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		//Â³ Executa o ponto de entrada M110MAIL quando a impressao for   Â³
		//Â³ enviada por email, fornecendo um Array para o usuario conten Â³
		//Â³ do os pedidos enviados para possivel manipulacao.            Â³
		//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		If ExistBlock("M110MAIL")
			lEnvMail := (oReport:nDevice == 3)
			If lEnvMail
				Execblock("M110MAIL",.F.,.F.,{aPedMail})
			EndIf
		EndIf

		If lAuto .And. !lImpri
			Aviso(STR0104,STR0105,{"OK"})
		Endif

		SC7->(dbClearFilter())
		SC7->(dbSetOrder(1))

	ElseIf nSaida == 3

		While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02

			// If incluído para o SP 23070 - Squad Suprimentos
			If lPCAprov .And. SC7->C7_CONAPRO <> "L"

				nPos := aScan(aPCBloq,{|x|x[1] = SC7->C7_NUM})

				If nPos == 0
					Aadd( aPCBloq, { SC7->C7_NUM, DtoC(SC7->C7_EMISSAO), SC7->C7_FORNECE+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") } )
				Endif
				SC7->(dbSkip())
				Loop
			Endif

			If SC7->C7_EMITIDO == "S" .AND. MV_PAR05 == 1
				SC7->(dbSkip())
				Loop
			Endif

			If (SC7->C7_CONAPRO == "B" .AND. MV_PAR10 == 1) .OR.;
					(SC7->C7_CONAPRO != "B" .AND. MV_PAR10 == 2)
				SC7->(dbSkip())
				Loop
			Endif

			If (SC7->C7_EMISSAO < MV_PAR03) .OR. (SC7->C7_EMISSAO > MV_PAR04)
				SC7->(dbSkip())
				Loop
			Endif

			If SC7->C7_TIPO == 2
				SC7->(dbSkip())
				Loop
			EndIf

			//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
			//Â³ Filtra Tipo de SCs Firmes ou Previstas                       Â³
			//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
			If !MtrAValOP(MV_PAR11, 'SC7')
				SC7->(dbSkip())
				Loop
			EndIf

			If oReport:Cancel()
				Exit
			EndIf

			MaFisEnd()
			R110FIniPC(SC7->C7_NUM,,,cFiltro)

			cObs01    := " "
			cObs02    := " "
			cObs03    := " "
			cObs04    := " "
			cObs05    := " "
			cObs06    := " "
			cObs07    := " "
			cObs08    := " "
			cObs09    := " "
			cObs10    := " "
			cObs11    := " "
			cObs12    := " "
			cObs13    := " "
			cObs14    := " "
			cObs15    := " "
			cObs16    := " "
			aSC7Obs	  := {}

			nPCOk++ // Caso o registro atenda todos os critérios, alimento este contator para imprimir os pedidos


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Roda a impressao conforme o numero de vias informado no mv_par09 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nVias := 1 to mv_par09

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dispara a cabec especifica do relatorio.                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:EndPage()
				//oReport:Box( 260, 010, 3020 , nPageWidth-4 ) //-- Box dos itens do relatório
				//oReport:Box( 260, 010, nPageHeight-5 , nPageWidth-4 ) //-- Box dos itens do relatório
				If nSaida == 5 .Or. nSaida == 3
					oReport:Box( 260, 010, nPageHeight+10 , nPageWidth-4 ) //-- Box dos itens do relatório
				Else
					oReport:Box( 260, 010, nPageHeight, nPageWidth-4 ) //-- Box dos itens do relatório
				Endif
				nPagina  := 0
				nPrinted := 0
				nTotal   := 0
				nTotMerc := 0
				nDescProd:= 0
				nLinObs  := 0
				nRecnoSC7:= SC7->(Recno())
				cNumSC7  := SC7->C7_NUM
				aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

				While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM == cNumSC7

					// If incluído para o SP 23070 - Squad Suprimentos
					If lPCAprov .And. SC7->C7_CONAPRO <> "L"

						nPos := aScan(aPCBloq,{|x|x[1] = SC7->C7_NUM})

						If nPos == 0
							Aadd( aPCBloq, { SC7->C7_NUM, DtoC(SC7->C7_EMISSAO), SC7->C7_FORNECE+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") } )
						Endif
						SC7->(dbSkip())
						Loop
					Endif

					If SC7->C7_EMITIDO == "S" .AND. MV_PAR05 == 1
						SC7->(dbSkip())
						Loop
					Endif

					If (SC7->C7_CONAPRO == "B" .AND. MV_PAR10 == 1) .OR.;
							(SC7->C7_CONAPRO != "B" .AND. MV_PAR10 == 2)
						SC7->(dbSkip())
						Loop
					Endif

					If (SC7->C7_EMISSAO < MV_PAR03) .OR. (SC7->C7_EMISSAO > MV_PAR04)
						SC7->(dbSkip())
						Loop
					Endif

					If SC7->C7_TIPO == 2
						SC7->(dbSkip())
						Loop
					EndIf

					//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
					//Â³ Filtra Tipo de SCs Firmes ou Previstas                       Â³
					//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
					If !MtrAValOP(MV_PAR11, 'SC7')
						SC7->(dbSkip())
						Loop
					EndIf

					If oReport:Cancel()
						Exit
					EndIf

					oReport:IncMeter()

					If oReport:Row() > oReport:LineHeight() * 100
						//oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth-4 )
						oReport:SkipLine()
						oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
						oReport:EndPage()
						If nSaida == 5 .Or. nSaida == 3
							oReport:Box( 260, 010, nPageHeight+10 , nPageWidth-4 ) //-- Box dos itens do relatório
						Else
							oReport:Box( 260, 010, nPageHeight-5 , nPageWidth-4 ) //-- Box dos itens do relatório
						Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Ascan(aRecnoSave,SC7->(Recno())) == 0
						AADD(aRecnoSave,SC7->(Recno()))
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa o descricao do Produto conf. parametro digitado.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cDescPro :=  ""
					If Empty(mv_par06)
						mv_par06 := "B1_DESC"
					EndIf

					If AllTrim(mv_par06) == "B1_DESC"
						SB1->(dbSeek( cFilSB1 + SC7->C7_PRODUTO ))
						cDescPro := SB1->B1_DESC
					ElseIf AllTrim(mv_par06) == "B5_CEME"
						If SB5->(dbSeek( cFilSB5 + SC7->C7_PRODUTO ))
							cDescPro := SB5->B5_CEME
						EndIf
					ElseIf AllTrim(mv_par06) == "C7_DESCRI"
						cDescPro := SC7->C7_DESCRI
					EndIf

					If Empty(cDescPro)
						SB1->(dbSeek( cFilSB1 + SC7->C7_PRODUTO ))
						cDescPro := SB1->B1_DESC
					EndIf

					If SA5->(dbSeek(cFilSA5+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
						cDescPro := Alltrim(cDescPro) + " ("+Alltrim(SA5->A5_CODPRF)+")"
					EndIf

					If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
						nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
					Else
						nDescProd+=SC7->C7_VLDESC
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializacao da Observacao do Pedido.                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lC7OBSChar .AND. !Empty(SC7->C7_OBS) .And. nLinObs < 17

						If !(SC7->C7_OBS $ SC7->C7_OBSM)

							nLinObs++
							cVar:="cObs"+StrZero(nLinObs,2)

							If nLinObs == 1

								Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))

							Else

								If cObsAnt <> Alltrim(SC7->C7_OBS)
									Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))
								Endif

							Endif

							cObsAnt := Alltrim(SC7->C7_OBS)

						EndIf

					Endif

					If !Empty(SC7->C7_OBSM) .And. nLinObs < 17
						nLinObs++
						cVar:="cObs"+StrZero(nLinObs,2)
						if Ascan(aSC7Obs,{|x| AllTrim(x) == Alltrim(SC7->C7_OBSM) }) == 0
							aAdd(aSC7Obs, Alltrim(SC7->C7_OBSM))
							Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBSM))
						endif
					Endif

					nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,0)
					nFrete   := If(SC7->C7_TPFRETE=="F",SC7->C7_XFRETE,0)

					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nValTotSC7            := NoRound( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
						ElseIf AllTrim(cRegra) == "ROUND"
							nValTotSC7            := Round( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
						Else
							nValTotSC7            := SC7->C7_TOTAL
						EndIf
						If nValTotSC7 > 0
							nTotal 	:= nTotal 	+ nValTotSC7
							IF SC7->C7_MOEDA == 1
								nTotMerc   := MaFisRet(,"NF_TOTAL")
							ELSE
								//nFrete		:= nFrete 	+ SC7->C7_VALFRE
								//nFrete		:= SC7->C7_XFRETE    // ALTERADO ADRIANO 16/01/15 PARA ATERNDER NOVO PADRÃO FOB
								nSeguro		:= nSeguro 	+ SC7->C7_SEGURO
								nDesp		:= nDesp 	+ SC7->C7_DESPESA
								nTotMerc	+= nValTotSC7
							ENDIF
						EndIf
					EndIf

					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nValTotSC7	:= NoRound( xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2 )
						ElseIf AllTrim(cRegra) == "ROUND"
							nValTotSC7	:= Round( xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2 )
						Else
							nValTotSC7	:= xMoeda(nValTotSC7,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						Endif
					ENDIF

					If oReport:nDevice != 4 .Or. (oReport:nDevice == 4 .And. !oReport:lXlsTable .And. oReport:lXlsHeader)  //impressao em planilha tipo tabela
						oSection2:Cell("C7_NUM"):Disable()
					EndIf

					If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
						oSection2:Cell("C7_SEGUM"  ):Enable()
						oSection2:Cell("C7_QTSEGUM"):Enable()
						oSection2:Cell("C7_UM"     ):Disable()
						oSection2:Cell("C7_QUANT"  ):Disable()
						nVlUnitSC7 := xMoeda(((SC7->C7_PRECO*SC7->C7_QUANT)/SC7->C7_QTSEGUM),SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
					ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
						oSection2:Cell("C7_SEGUM"  ):Disable()
						oSection2:Cell("C7_QTSEGUM"):Disable()
						oSection2:Cell("C7_UM"     ):Enable()
						oSection2:Cell("C7_QUANT"  ):Enable()
						nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						//Else
						//	oSection2:Cell("C7_SEGUM"  ):Enable()
						//	oSection2:Cell("C7_QTSEGUM"):Enable()
						//	oSection2:Cell("C7_UM"     ):Enable()
						//	oSection2:Cell("C7_QUANT"  ):Enable()
						//	nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
					EndIf

					If cPaisLoc <> "BRA" .Or. mv_par08 == 2
						oSection2:Cell("C7_IPI" ):Disable()
					EndIf

					If mv_par08 == 1 .OR. mv_par08 == 3
						//oSection2:Cell("OPCC"):Disable()
					Else
						oSection2:Cell("C7_CC"):Disable()
						oSection2:Cell("C7_NUMSC"):Disable()
						If !Empty(SC7->C7_OP)
							cOPCC := STR0065 + " " + SC7->C7_OP
						ElseIf !Empty(SC7->C7_CC)
							cOPCC := STR0066 + " " + SC7->C7_CC
						EndIf
					EndIf

					If oReport:nDevice == 4 .And. oReport:lXlsTable .And. !oReport:lXlsHeader  //impressao em planilha tipo tabela
						oSection1:Init()
						TRPosition():New(oSection1,"SA2",1,{ || cFilSA2 + SC7->C7_FORNECE + SC7->C7_LOJA })
						oSection1:PrintLine()
						oSection2:PrintLine()
						oSection1:Finish()
					Else
						oSection2:PrintLine()
					EndIf

					nPrinted++
					lImpri  := .T.



					SC7->(dbSkip())

				EndDo

				SC7->(dbGoto(nRecnoSC7))

				If oReport:Row() > oReport:LineHeight() * 68

					//oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth-4 )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dispara a cabec especifica do relatorio.                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oReport:EndPage()
					oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape

					//oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )

				EndIf

				//oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )
				//oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth-4 )

				oReport:Box( 1990 ,010, nPageHeight+10  , nPageWidth-4 )
				oReport:Box( 2080 ,010, nPageHeight+10  , nPageWidth-4 )
				oReport:Box( 2200 ,010, nPageHeight+10  , nPageWidth-4 )
				oReport:Box( 2320 ,010, nPageHeight+10  , nPageWidth-4 )

				If nSaida == 5 .Or. nSaida == 3 // se for emissão em html
					oReport:Box( 2200, 1080 , 2320, 1400 ) // Box da Data de Emissao
				Else
					oReport:Box( 2200, 1080 , 2340, 1400 ) // Box da Data de Emissao
				Endif

				oReport:Box( 2320,  010 , 2406, 1220 ) // Box do Reajuste
				oReport:Box( 2320, 1220 , 2460, 1750 ) // Box do IPI e do Frete
				oReport:Box( 2320, 1750 , 2460, nPageWidth-4 ) // Box do ICMS, Despesas e Desconto
				If nSaida == 5 .Or. nSaida == 3
					oReport:Box( 2406,  010 , 2700, 1220 ) // Box das Observacoes
				Else
					oReport:Box( 2406,  010 , 2720, 1220 ) // Box das Observacoes
				Endif

				cMensagem:= Formula(SC7->C7_MSG)
				If !Empty(cMensagem)
					oReport:SkipLine()
					oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
				Endif

				If SC7->C7_MOEDA == 1
					nDescProd := xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				Else
					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nDescProd := NoRound((xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)))
						Elseif AllTrim(cRegra) == "ROUND"
							nDescProd := Round((xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)),2)
						Else
							nDescProd := xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						Endif
					Endif
				Endif

				//Report:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
					//TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
					//TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
					//TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
					//TransForm(nDescProd , cPicC7_VLDESC ),;
					//2022, 050 )
				//		oReport:PrintText( "", 2022, 050 ) // imprimir linha em branco no lugar dos descontos

				oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )

				cAplic := Alltrim(LibPC(SC7->C7_NUM))
				aAplic:= StrToKArr(cAplic,";")

				oReport:PrintText( "Aplicacao: " +IIF(VALTYPE(aAplic) == "A" .AND. !EMPTY(aAplic),SubStr(aAplic[1],1,107),"") ,2022, 050 ) 	//Aplicação

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o Arquivo de Empresa SM0.                          ³
				//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
				//³ e o Local de Cobranca :                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRecnoSM0 := SM0->(Recno())
				SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))

				cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
				cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

				If Empty(MV_PAR13) //"Local de Entrega  : "

					cLocEntr := AllTrim(SC7->C7_LENT)

					If Empty(cLocEntr)
						If !Empty(SC7->C7_MEDICAO)
							If CND->(DbSeek(SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV+SC7->C7_PLANILH+SC7->C7_MEDICAO))
								cLocEntr := AllTrim(CND->CND_XLENT)
							EndIf
						EndIf
					EndIf

					//oReport:PrintText(STR0008 + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),cPicA2_CEP),, 050 )
					oReport:PrintText(STR0008 + Alltrim(cLocEntr),, 050 )

				Else
					oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
				Endif


				SM0->(dbGoto(nRecnoSM0))
				oReport:PrintText(STR0010 + Alltrim(SM0->M0_ENDCOB)+"  "+Alltrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),cPicA2_CEP),, 050 )

				oReport:SkipLine()
				oReport:SkipLine()

				SE4->(dbSeek(cFilSE4+SC7->C7_COND))

				nLinPC := oReport:Row()
				oReport:PrintText( "Condicao de Pagto:  " +SubStr(SE4->E4_CODIGO,1,40)+" - "+SubStr(SE4->E4_DESCRI,1,34),nLinPC,050 )
				oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
				oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 ) //"Total das Mercadorias : "
				oReport:SkipLine()
				nLinPC := oReport:Row()

				If cPaisLoc<>"BRA"
					aValIVA := MaFisRet(,"NF_VALIMP")
					nValIVA :=0
					If !Empty(aValIVA)
						For nY:=1 to Len(aValIVA)
							nValIVA+=aValIVA[nY]
						Next nY
					EndIf
					_cAux := " "
					if !EMPTY(ALLTRIM(SC7->C7_XCONDPG))
						_cAux := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"PF"+ALLTRIM(SC7->C7_XCONDPG), 1, ""))
					endif

					//oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
					oReport:PrintText("Forma de Pagamento: " + ALLTRIM(SC7->C7_XCONDPG) +"-" + _cAux +".",nLinPC, 050 )
					oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
					oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
					Transform(xMoeda(nValIVA,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 )
				Else
					_cAux := " "
					if !EMPTY(ALLTRIM(SC7->C7_XCONDPG))
						_cAux := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"PF"+ALLTRIM(SC7->C7_XCONDPG), 1, ""))
					endif

					//oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
					oReport:PrintText("Forma de Pagamento: " + ALLTRIM(SC7->C7_XCONDPG) +"-" + _cAux +".",nLinPC, 050 )
					oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
					oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
					Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(Val(cMoeda))) ),nLinPC,1612 )
				Endif
				oReport:SkipLine()

				IF SC7->C7_MOEDA == 1
					nTotIpi	  	:= MaFisRet(,'NF_VALIPI')
					nTotIcms  	:= MaFisRet(,'NF_VALICM')
					nTotDesp  	:= MaFisRet(,'NF_DESPESA')
					nTotFrete 	:= nFrete //MaFisRet(,'NF_FRETE')
					nTotSeguro	:= MaFisRet(,'NF_SEGURO')
					nTotalNF  	:= MaFisRet(,'NF_TOTAL') + nTotFrete
				Else
					If !Empty(cRegra)
						If AllTrim(cRegra) == "NOROUND"
							nTotFrete 	:= NoRound(xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
							nTotSeguro 	:= NoRound(xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
							nTotDesp	:= NoRound(xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda))
						Elseif AllTrim(cRegra) == "ROUND"
							nTotFrete 	:= Round(xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
							nTotSeguro 	:= Round(xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
							nTotDesp	:= Round(xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda),2)
						Else
							nTotFrete 	:= xMoeda(nFrete,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
							nTotSeguro 	:= xMoeda(nSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
							nTotDesp	:= xMoeda(nDesp ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
						EndIf
					EndIf
					nTotalNF	:= nTotal + nFrete + nSeguro + nDesp
					nTotalNF	:= xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) - nDescProd
				EndIf

				oReport:SkipLine()
				oReport:SkipLine()
				nLinPC := oReport:Row()

				//If SM4->(dbSeek(cFilSM4+SC7->C7_REAJUST))
				//	oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
				//EndIf

				if ALLTRIM(SC7->C7_X2CO)== "E"
					_cAux :=	"Emitente"
				elseif ALLTRIM(SC7->C7_X2CO)== "D"
					_cAux :=	"Destinatário"
				endif

				oReport:PrintText("Descarregamento: " +  _cAux + ".",nLinPC, 050 )

				If cPaisLoc == "BRA"
					oReport:PrintText( "Total do IPI: "  + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1320 ) //"IPI      :"
					oReport:PrintText( "Total do ICMS: " + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,Val(cMoeda),SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1815 ) //"ICMS     :"
				EndIf
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( "Frete       : " + Transform(nTotFrete , tm(nTotFrete,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1320 ) //"Frete    :"
				oReport:PrintText( "Despesas     : " + Transform(nTotDesp , tm(nTotDesp ,14,MsDecimais(Val(cMoeda)))) ,nLinPC,1815 ) //"Despesas :"
				oReport:SkipLine()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializar campos de Observacoes.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cObs02) .Or. cObs01 == cObs02

					cObs02 := ""
					aAux1 := strTokArr(cObs01, chr(13)+chr(10))
					nQtdLinhas := 0
					for nX := 1 To  Len(aAux1)
						nQtdLinhas += Ceiling(Len(aAux1[nX]) / 65)
					Next nX
					If nQtdLinhas <= 8
						R110cObs(aAux1, 65)
					Else
						R110cObs(aAux1, 40)
					EndIf
				Else
					cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<65,Len(cObs01),65))
					cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<65,Len(cObs02),65))
					cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<65,Len(cObs03),65))
					cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<65,Len(cObs04),65))
					cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<65,Len(cObs05),65))
					cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<65,Len(cObs06),65))
					cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<65,Len(cObs07),65))
					cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<65,Len(cObs08),65))
					cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<65,Len(cObs09),65))
					cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<65,Len(cObs10),65))
					cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<65,Len(cObs11),65))
					cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<65,Len(cObs12),65))
					cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<65,Len(cObs13),65))
					cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<65,Len(cObs14),65))
					cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<65,Len(cObs15),65))
					cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<65,Len(cObs16),65))
				EndIf

				cComprador:= ""
				cAlter	  := ""
				cAprov	  := ""
				lNewAlc	  := .F.
				lLiber 	  := .F.
				lRejeit	  := .F.


				//Incluida validação para os pedidos de compras por item do pedido  (IP/alçada)
				cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")

				If cTipoSC7 == "PC"

					If SCR->(dbSeek(cFilSCR+cTipoSC7+SC7->C7_NUM))
						cTst = ''
					Else
						If SCR->(dbSeek(cFilSCR+"IP"+SC7->C7_NUM))
							cTst = ''
						EndIf
					EndIf

				Else

					SCR->(dbSeek(cFilSCR+cTipoSC7+SC7->C7_NUM))
				EndIf

				If !Empty(SC7->C7_APROV) .Or. (Empty(SC7->C7_APROV) .And. SCR->CR_TIPO == "IP")

					lNewAlc := .T.
					oHash:Get(SC7->C7_USER,@xUsrName)
					cComprador := xUsrName
					If SC7->C7_CONAPRO != "B"
						IF SC7->C7_CONAPRO == "R"
							lRejeit	  := .T.
						Else
							lLiber    := .T.
						EndIf
					EndIf

					While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == cFilSCR+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO $ "PC|AE|IP"
						oHash:Get(SCR->CR_USER,@xUsrName)
						cAprov += AllTrim(xUsrName)+" ["
						Do Case
						Case SCR->CR_STATUS=="02" //Pendente
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="03" //Liberado
							cAprov += "Ok"
						Case SCR->CR_STATUS=="04" //Bloqueado
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="05" //Nivel Liberado
							cAprov += "##"
						Case SCR->CR_STATUS=="06" //Rejeitado
							cAprov += "REJ"

						OtherWise                 //Aguar.Lib
							cAprov += "??"
						EndCase
						cAprov += "] - "

						SCR->(dbSkip())
					Enddo
					If !Empty(SC7->C7_GRUPCOM)
						SAJ->(dbSeek(cFilSAJ+SC7->C7_GRUPCOM))
						While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == cFilSAJ+SC7->C7_GRUPCOM
							If SAJ->AJ_USER != SC7->C7_USER
								If nPAJ_MSBLQL > 0
									If SAJ->AJ_MSBLQL == "1"
										dbSkip()
										LOOP
									EndIf
								EndIf
								oHash:Get(SAJ->AJ_USER,@xUsrName)
								cAlter += AllTrim(xUsrName)+"/"
							EndIf

							SAJ->(dbSkip())
						EndDo
					EndIf
					If "[BLQ]" $ cAprov
						lLiber    := .F.
					EndIf
				EndIf

				nLinPC := oReport:Row()
				oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
				oReport:PrintText( "Seguro      : " + Transform(nTotSeguro , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1320 ) // "SEGURO   :"
				oReport:PrintText("Desconto     : "  + Transform(nDescProd , cPicC7_VLDESC) ,nLinPC, 1815 ) // "Desconto   :"

				oReport:SkipLine()

				nLinPC2 := oReport:Row()
				oReport:PrintText(cObs01,,050 )
				oReport:PrintText(cObs02,,050 )

				nLinPC := oReport:Row()
				oReport:PrintText(cObs03,nLinPC,050 )

				If !lNewAlc
					oReport:PrintText( STR0078 + Transform(nTotalNF , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1650 ) //"Total Geral :"
				Else
					If lLiber
						oReport:PrintText( STR0078 + Transform(nTotalNF , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1650 )
					Else
						oReport:PrintText( STR0078 + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),IF(lRejeit,STR0130,STR0051),STR0086) ,nLinPC,1390 )
					EndIf
				EndIf
				oReport:SkipLine()

				oReport:PrintText(cObs04,,050 )
				oReport:PrintText(cObs05,,050 )
				oReport:PrintText(cObs06,,050 )
				nLinPC3 := oReport:Row()
				oReport:PrintText(cObs07,,050 )
				oReport:PrintText(cObs08,,050 )
				oReport:PrintText(cObs09,nLinPC2,650 )
				oReport:SkipLine()
				oReport:PrintText(cObs10,,650 )
				oReport:PrintText(cObs11,,650 )
				oReport:PrintText(cObs12,,650 )
				oReport:PrintText(cObs13,,650 )
				oReport:PrintText(cObs14,,650 )
				oReport:PrintText(cObs15,,650 )
				oReport:PrintText(cObs16,,650 )

				If !lNewAlc

					oReport:Box( 2700, 0010 , 3020, 0400 )
					oReport:Box( 2700, 0400 , 3020, 0800 )
					oReport:Box( 2700, 0800 , 3020, 1220 )
					oReport:Box( 2600, 1220 , 3020, 1770 )
					oReport:Box( 2600, 1770 , 3020, nPageWidth-4 )

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
					oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "R",STR0132,IF(SC7->C7_TPFRETE $ "D",STR0133,IF(SC7->C7_TPFRETE $ "T",STR0134," " ) )))) ,nLinPC,1820 ) //STR0132 Por conta remetente, STR0133 Por conta destinatario,STR0134 Por Conta Terceiros.
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
					oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
					oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()

					nLinPC := oReport:Row()
					oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
					oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
					oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
					oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()
					If nSaida <> 8 //Se não for envio direto pro email, pular essa linha
						oReport:SkipLine()
					Endif
					If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
						oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
						//oReport:SkipLine()
						oReport:PrintText("CASO COBRANCA NAO SEJA EM BOLETO BANCARIO, FAVOR FORNECER DADOS PARA DEPOSITO NA NOTA FISCAL.",,050 )

					Else
						oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
					EndIf

				Else

					oReport:Box( 2570, 1220 , 2700, 1820 )         // box pedido status do pedido
					If nSaida == 5 .Or. nSaida == 3
						oReport:Box( 2570, 1820 , 2700, nPageWidth-4 ) // box do obs do frete
					Else
						oReport:Box( 2570, 1800 , 2700, nPageWidth-4 ) // box do obs do frete
					Endif
					oReport:Box( 2700, 0010 , 2850, nPageWidth-4 ) // box comprador / aprovador

					//oReport:Box( 2700, 0010 , nPageHeight-4, nPageWidth-4 )
					//oReport:Box( 2970, 0010 , 3020, nPageWidth-4 )

					nLinPC := nLinPC3

					oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber , STR0050 , IF(lRejeit,STR0130,STR0051) ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1260 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
					oReport:PrintText( STR0080 + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1840 ) //"Obs. do Frete: "
					oReport:SkipLine()

					oReport:SkipLine()
					oReport:SkipLine()
					oReport:SkipLine()

					oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
					oReport:SkipLine()
					//oReport:PrintText(STR0053+" "+ If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
					//oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"

					nLinCar := 140
					nColCarac := 050
					nCCarac := 140

					nAprovLin := Ceiling( IIF(Len(AllTrim(cAprov)) < 75, 75, Len(AllTrim(cAprov))) / nLinCar)

					For nX := 1 to nAprovLin
						If nX == 1
							oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,nLinCar) , " " ),,nColCarac ) //"Aprovador(es) :"
							nColCarac+=250
						Else
							oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,nCCarac+1,nLinCar) , " " ),,nColCarac )
							nCCarac+=nLinCar
						EndIf
					Next nx

					//nX:=nAprovLin
					//While nX <= 3
					//	oReport:SkipLine()
					//	nX:=nX+1
					//EndDo

					nLinPC := oReport:Row()

					//oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )

					//cAplic := Alltrim(LibPC(SC7->C7_NUM))
					//aAplic:= StrToKArr(cAplic,";")

					//oReport:SkipLine()
					//nLinPC := oReport:Row()

					//oReport:PrintText( "Aplicacao: " +IIF(VALTYPE(aAplic) == "A" .AND. !EMPTY(aAplic),SubStr(aAplic[1],1,107),"") ,, 050 ) 	//Aplicação

					nLinPC := oReport:Row()

					//oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
					//oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
					//oReport:PrintText(       "|  "+STR0131 ,nLinPC, 830 ) 	//"Ok:REJEITADO"
					//oReport:PrintText(       "|  "+STR0062 ,nLinPC, 1050 ) 	//"??:Aguar.Lib"
					//oReport:PrintText(       "|  "+STR0067 ,nLinPC, 1300 )	//"##:Nivel Lib"
					//oReport:SkipLine()

					oReport:SkipLine()
					If nSaida <> 8 //Se não for envio direto pro email, pular essa linha
						oReport:SkipLine()
					Endif
					If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
						oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
						//oReport:SkipLine()
						oReport:PrintText("CASO COBRANCA NAO SEJA EM BOLETO BANCARIO, FAVOR FORNECER DADOS PARA DEPOSITO NA NOTA FISCAL.",,050 )
					Else
						oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
					EndIf
					//oReport:SkipLine()

					nLinPC := oReport:Row()+30
					oReport:Line( nLinPC, 0010 , nLinPC, nPageWidth-4 )
					oReport:SkipLine()
					oReport:SkipLine()

				/* Bloco para inclusão de consulta na tabela de cadastro de mensagem para exibir a mensagem ativa para o rodapé do pedido
				   24/02/2023
				   Squad Suprimentos 
				*/
					dbSelectArea("ZAA")
					dbSetOrder(1)
					dbGoTop()

					While !ZAA->(Eof())
						If ZAA->ZAA_STATUS == "2"
							Exit
						Endif
						ZAA->(dbSkip())
					End

					cMsgLin1 := Alltrim(ZAA->ZAA_LINHA1)
					cMsgLin2 := Alltrim(ZAA->ZAA_LINHA2)
					cMsgLin3 := Alltrim(ZAA->ZAA_LINHA3)
					cMsgLin4 := Alltrim(ZAA->ZAA_LINHA4)
					cMsgLin5 := Alltrim(ZAA->ZAA_LINHA5)

					ZAA->(dbCloseArea())
					dbSelectArea("SC7")

					nLinPC := oReport:Row()

					oReport:PrintText(Alltrim(cMsgLin1),,050 )
					oReport:PrintText(Alltrim(cMsgLin2),,050 )
					oReport:PrintText(Alltrim(cMsgLin3),,050 )
					oReport:PrintText(Alltrim(cMsgLin4),,050 )
					oReport:PrintText(Alltrim(cMsgLin5),,050 )

				EndIf

			Next nVias

			MaFisEnd()


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


			If Len(aRecnoSave) > 0
				For nX :=1 to Len(aRecnoSave)
					dbGoto(aRecnoSave[nX])
					If(SC7->C7_QTDREEM >= 99)
						If nRet == 1
							RecLock("SC7",.F.)
							SC7->C7_EMITIDO := "S"
							MsUnLock()
						Elseif nRet == 2
							RecLock("SC7",.F.)
							SC7->C7_QTDREEM := 1
							SC7->C7_EMITIDO := "S"
							MsUnLock()
						Elseif nRet == 3
							//cancelar
						Endif
					Else
						RecLock("SC7",.F.)
						SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Endif
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC7->(dbGoto(aRecnoSave[Len(aRecnoSave)]))
			Endif

			Aadd(aPedMail,aPedido)

			aRecnoSave := {}

			SC7->(dbSkip())

		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
		//³ enviada por email, fornecendo um Array para o usuario conten ³
		//³ do os pedidos enviados para possivel manipulacao.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("M110MAIL")
			lEnvMail := (oReport:nDevice == 3)
			If lEnvMail
				Execblock("M110MAIL",.F.,.F.,{aPedMail})
			EndIf
		EndIf

		If lAuto .And. !lImpri
			Aviso(STR0104,STR0105,{"OK"})
		Endif

		SC7->(dbClearFilter())
		SC7->(dbSetOrder(1))

	Endif

	dbSelectArea("SX3")
	dbSetOrder(1)

	If Len(aPCBloq) > 0 
		If MsgYesNo("De acordo com os parâmetros preenchidos, existem pedidos não liberados que não serão impressos. Deseja exibir o relatório de Log desses pedidos?")
			 fImpPCBloq(aPCBloq)  
		Endif
	Endif

	oSection2:Finish()

	/*
	If nPCOk > 0
		oSection2:Finish()
	Else
		Return(.F.)
	Endif
	*/

Return

	*-----------------------------------*
Static Function fImpPCBloq(aPCBloq)
	*-----------------------------------*
	Local oPrint

	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.
	Local cLocal          := "\spool"
	Local cNomeArq        := "ImpPCBloq"

	Local oFont10  := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont10b := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _nLin := 20
	Local nX    := 0

	oPrint := FWMsPrinter():New(cNomeArq, IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , ,.T., ,.F.)

	oPrint:SetPortrait()
	oPrint:SetPaperSize(9)

	oPrint:StartPage()

	oPrint:Line (_nLin+010,020,_nLin+010,800,,"-8")
	oPrint:Say  (_nLin+020,030,"Relatório de Log de Pedidos Não Liberados", oFont10b)
	oPrint:Line (_nLin+025,020,_nLin+025,800,,"-8")

	oPrint:Say  (_nLin+035,030,"Data: "+DToC(Date()) , oFont10)
	oPrint:Say  (_nLin+047,030,"Hora: "+Time()       , oFont10)

	_nLin += 90

	oPrint:Say ( _nLin,020,"Segue abaixo, os pedidos ainda não liberados que não foram impressos:",oFont10b )

	oPrint:Line (_nLin+010,020,_nLin+010,800)

	oPrint:Say  (_nLin+020,030,"Pedido"    ,oFont10b)
	oPrint:Say  (_nLin+020,130,"Emissão"   ,oFont10b)
	oPrint:Say  (_nLin+020,230,"Fornecedor",oFont10b)

	oPrint:Line (_nLin+025,020,_nLin+025,800)

	For nX:=1 To Len(aPCBloq)

		oPrint:Say (_nLin+035,030,aPCBloq[nX][1],oFont10)
		oPrint:Say (_nLin+035,130,aPCBloq[nX][2],oFont10)
		oPrint:Say (_nLin+035,230,aPCBloq[nX][3],oFont10)

		_nLin += 12

	Next

	oPrint:EndPage()
	oPrint:Preview()
	FreeObj(oPrint)
    oPrint := Nil
Return

	*--------------------------*
Static Function LibPC(cDoc)
	*--------------------------*

	Local cAplic := ""
	Local aArea := SC7->(getarea())
	Local nCont := 110

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial("SC7")+cDoc)

	While !SC7->(EoF()) .AND. SC7->C7_NUM == cDoc
		If !EMPTY(AllTrim(SC7->C7_APLIC)) .AND. AT(AllTrim(SC7->C7_APLIC),cAplic) == 0
			If Len(cAplic) + Len(AllTrim(SC7->C7_APLIC)+ " | ") > nCont
				cAplic += ";" + AllTrim(SC7->C7_APLIC) + " | "
				nCont += 110
			ElseIf !EMPTY(AllTrim(SC7->C7_APLIC))
				cAplic += AllTrim(SC7->C7_APLIC) + " | "
			EndIf
		Else
			cAplic := Posicione("SC1",2,xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC,"C1_OBSSC")
		EndIf
		SC7->(DbSkip())
	EndDo
	SC7->(restarea(aArea))
Return cAplic

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³CabecPCxAE³ Autor ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Emissao do Pedido de Compras / Autorizacao de Entrega      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ CabecPCxAE(ExpO1,ExpO2,ExpN1,ExpN2)                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
	±±³          ³ ExpO2 = Objeto da sessao1 com o cabec                      ³±±
	±±³          ³ ExpN1 = Numero de Vias                                     ³±±
	±±³          ³ ExpN2 = Numero de Pagina                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nenhum                                                      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CabecPCxAE(oReport,oSection1,nVias,nPagina)

	Local nLinPC		:= 0
	Local nPageWidth	:= oReport:PageWidth()
	Local cCGC			:= ""
	Local cTitCGC 		:= FWX3Titulo( "A2_CGC" )

	If Type("cPicMoeda") == "U"
		cMoeda		:= IIf( mv_par12 < 10 , Str(mv_par12,1) , Str(mv_par12,2) )
		If Val(cMoeda) == 0
			cMoeda := "1"
		Endif
		cPicMoeda := GetMV("MV_MOEDA"+cMoeda)
	Endif

	If Type("cInscrEst") == "U"
		cInscrEst := InscrEst()
	Endif

	If Type("cFilSA2") == "U"
		cFilSA2		:= xFilial("SA2")
	Endif

	If Type("cFilSA5") == "U"
		cFilSA5		:= xFilial("SA5")
	Endif

	If Type("cFilSAJ") == "U"
		cFilSAJ		:= xFilial("SAJ")
	Endif

	If Type("cFilSB1") == "U"
		cFilSB1		:= xFilial("SB1")
	Endif

	If Type("cFilSB5") == "U"
		cFilSB5		:= xFilial("SB5")
	Endif

	If Type("cFilSC7") == "U"
		cFilSC7		:= xFilial("SC7")
	Endif

	If Type("cFilSCR") == "U"
		cFilSCR		:= xFilial("SCR")
	Endif

	If Type("cFilSE4") == "U"
		cFilSE4		:= xFilial("SE4")
	Endif

	If Type("cFilSM4") == "U"
		cFilSM4		:= xFilial("SM4")
	Endif

	If Type("oHash") == "U"
		oHash		:= R110Hash()
	EndIf

	TRPosition():New(oSection1,"SA2",1,{ || cFilSA2 + SC7->C7_FORNECE + SC7->C7_LOJA })
	cBitmap := R110Logo()

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(cFilSA2 + SC7->C7_FORNECE + SC7->C7_LOJA))

	oSection1:Init()

	oReport:Box( 010 , 010 ,  260 , 1000 )
	oReport:Box( 010 , 1000,  260 , nPageWidth-4 )

	oReport:PrintText( If(nPagina > 1,(STR0033)," "),,oSection1:Cell("M0_NOMECOM"):ColPos())

	nLinPC := oReport:Row()
	oReport:PrintText( If( mv_par08 == 1 , (STR0068), (STR0069) ) + " - " + cPicMoeda ,nLinPC,1030 )
	oReport:PrintText( If( mv_par08 == 1 , SC7->C7_NUM, SC7->C7_NUMSC + "/" + SC7->C7_NUM ) + " /" + Ltrim(Str(nPagina,2)) ,nLinPC,1910 )
	oReport:SkipLine()


	nLinPC := oReport:Row()
	If(SC7->C7_QTDREEM >= 99)
		nRet := Aviso("TOTVS", STR0125 +chr(13)+chr(10)+ "1- " + STR0126 +chr(13)+chr(10)+ "2- " + STR0127 +chr(13)+chr(10)+ "3- " + STR0128,{"1", "2", "3"},2)
		If(nRet == 1)
			oReport:PrintText( Str(SC7->C7_QTDREEM,2) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 2)
			oReport:PrintText( "1" + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 3)
			oReport:CancelPrint()
		Endif
	Else
		oReport:PrintText( If( SC7->C7_QTDREEM > 0, Str(SC7->C7_QTDREEM+1,2) , "1" ) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
	Endif

	oReport:SkipLine()

	_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap
	oReport:SayBitmap(25,25,_cFileLogo,500,80) // insere o logo no relatorio

	nLinPC := oReport:Row()
	oReport:PrintText(STR0087 + SM0->M0_NOMECOM,nLinPC,15)  // "Empresa:"

	oReport:PrintText(STR0106 + Substr(;
		If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME),;
			1,50) + "    " + STR0107 + SA2->A2_COD + " " + STR0108 + SA2->A2_LOJA ,nLinPC,1025)

		oReport:SkipLine()

		nLinPC := oReport:Row()
		oReport:PrintText(STR0088 + SM0->M0_ENDENT,nLinPC,15)

		oReport:PrintText(STR0088 + Substr(;
			If(lLGPD,RetTxtLGPD(SA2->A2_END,"A2_END"),SA2->A2_END),;
				1,49) + " " + STR0109 + Substr(;
				If(lLGPD,RetTxtLGPD(SA2->A2_BAIRRO,"A2_BAIRRO"),SA2->A2_BAIRRO),;
					1,25),nLinPC,1025)

				oReport:SkipLine()

				If cPaisLoc == "BRA"
					cCGC	:= Transform(;
						If(lLGPD,RetTxtLGPD(SA2->A2_CGC,"A2_CGC"),SA2->A2_CGC),;
							Iif(SA2->A2_TIPO == 'F',Substr(PICPES(SA2->A2_TIPO),1,17),Substr(PICPES(SA2->A2_TIPO),1,21)))
					Else
						cCGC	:= SA2->A2_CGC
					EndIf

					nLinPC := oReport:Row()
					oReport:PrintText(STR0089 + Trans(SM0->M0_CEPENT,cPicA2_CEP)+Space(2)+STR0090 + "  " + RTRIM(SM0->M0_CIDENT) + " " + STR0091 + SM0->M0_ESTENT ,nLinPC,15)
					oReport:PrintText(STR0110+Left(;
						If(lLGPD,RetTxtLGPD(SA2->A2_MUN,"A2_MUN"),SA2->A2_MUN),;
							30)+" "+STR0111+;
							If(lLGPD,RetTxtLGPD(SA2->A2_EST,"A2_EST"),SA2->A2_EST)+;
								" "+STR0112+;
								If(lLGPD,RetTxtLGPD(SA2->A2_CEP,"A2_CEP"),SA2->A2_CEP),nLinPC,1025)

								oReport:SkipLine()

								nLinPC := oReport:Row()
								oReport:PrintText(STR0092 + SM0->M0_TEL + Space(2) + STR0093 + SM0->M0_FAX ,nLinPC,15)

								oReport:PrintText(STR0094 + "("+Substr(;
									If(lLGPD,RetTxtLGPD(SA2->A2_DDD,"A2_DDD"),SA2->A2_DDD),;
										1,3)+") "+Substr(;
										If(lLGPD,RetTxtLGPD(SA2->A2_TEL,"A2_TEL"),SA2->A2_TEL),;
											1,15) + " "+STR0114+"("+Substr(;
											If(lLGPD,RetTxtLGPD(SA2->A2_DDD,"A2_DDD"),SA2->A2_DDD),;
												1,3)+") "+SubStr(;
												If(lLGPD,RetTxtLGPD(SA2->A2_FAX,"A2_FAX"),SA2->A2_FAX),1,15),nLinPC,1025)

												oReport:SkipLine()

												nLinPC := oReport:Row()
												oReport:PrintText(cTitCGC + Transform(SM0->M0_CGC,cPicA2_CGC) ,nLinPC,15)
												If cPaisLoc == "BRA"
													oReport:PrintText(Space(2) + STR0041 + cInscrEst ,nLinPC,415)
												Endif

												oReport:PrintText(cTitCGC + cCGC +Space(10)+If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 )+If( cPaisLoc$"ARG|POR|EUA",space(18),If(lLGPD,RetTxtLGPD(SA2->A2_INSCR,"A2_INSCR"),SA2->A2_INSCR)),nLinPC,1025)

												oReport:SkipLine()
												oReport:SkipLine()

												oSection1:Finish()

												Return
/*/
												ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
												±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
												±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
												±±³Fun‡…o    ³R110Center³ Autor ³ Jose Lucas            ³ Data ³          ³±±
												±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
												±±³Descri‡…o ³ Centralizar o Nome do Liberador do Pedido.                 ³±±
												±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
												±±³Sintaxe   ³ ExpC1 := R110CenteR(ExpC2)                                 ³±±
												±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
												±±³Parametros³ ExpC1 := Nome do Liberador                                 ³±±
												±±³Parametros³ ExpC2 := Nome do Liberador Centralizado                    ³±±
												±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
												±±³ Uso      ³ MatR110                                                    ³±±
												±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
												±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
												ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R110Center(cLiberador)
Return( Space((30-Len(AllTrim(cLiberador)))/2)+AllTrim(cLiberador) )

/*/
	Função R110ChkPerg
	Autor  Vitor Pires
	Data 21/09/19
	Descrição Funcao para buscar as perguntas que o usuario nao pode alterar para impressao de relatorios direto do browse
/*/

Static Function R110ChkPerg()

	Local lPcHabPer := SuperGetMv("MV_PCHABPG", .F., .F.)

	If lPcHabPer
		mv_par05 := ChkPergUs(cUserId,"MTR110","05",mv_par05)
		mv_par08 := ChkPergUs(cUserId,"MTR110","08",mv_par08)
		mv_par09 := ChkPergUs(cUserId,"MTR110","09",mv_par09)
		mv_par10 := ChkPergUs(cUserId,"MTR110","10",mv_par10)
		mv_par11 := ChkPergUs(cUserId,"MTR110","11",mv_par11)
		mv_par14 := ChkPergUs(cUserId,"MTR110","14",mv_par14)
	Else
		mv_par05 := 2
		mv_par08 := SC7->C7_TIPO
		mv_par09 := 1
		mv_par10 := 3
		mv_par11 := 3
		mv_par14 := 1
	EndIf

Return

/*/
	Função ChkPergUs
	Autor  Nereu Humberto Junior
	Data 21/09/07
	Descrição FFuncao para buscar as perguntas que o usuario nao pode alterar para impressao de relatorios direto do browse
	Sintaxe   xVar := ChkPergUs(cUserId,cGrupo,cSeq,xDefault)
	Parametros cUserId 	: Id do usuario
	cGrupo 	: Grupo de perguntas
	cSeq 	 	: Numero da sequencia da pergunta
	xDefault	: Valor default para o parametro
	Uso       MatR110
	Versão 2: Vitor Pires	25/10/2019
/*/
Static Function ChkPergUs(cUserId,cGrupo,cSeq,xDefault)

	Local xRet   := Nil
	Local cParam := "MV_PAR"+cSeq

	SXK->(dbSetOrder(2))
	If SXK->(dbSeek("U"+cUserId+cGrupo+cSeq))
		If ValType(&cParam) == "C"
			xRet := AllTrim(SXK->XK_CONTEUD)
		ElseIf 	ValType(&cParam) == "N"
			xRet := Val(AllTrim(SXK->XK_CONTEUD))
		ElseIf 	ValType(&cParam) == "D"
			xRet := CTOD((AllTrim(SXK->XK_CONTEUD)))
		Endif
	Else
		If !(Type(cParam)=='U')
			xRet := &cParam
		Else
			xRet := xDefault
		EndIf
	Endif

Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid	:= ""
	Local nPosRef	:= 0
	Local nItem		:= 0
	Local cItemDe	:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''
	Local nX
	Static aStru	:= FWFormStruct(3,"SC7")[1]

	DEFAULT cSequen	:= ""
	DEFAULT cFiltro	:= ""
	DEFAULT cRegra    := SuperGetMV("MV_ARRPEDC",.F.,"ROUND")
	DEFAULT nTamTot   := TamSX3("C7_PRECO")[2]

	If !(cRegra $ "ROUND|NOROUND")
		cRegra := "LEGADO"
	Endif

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(cFilSC7+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == cFilSC7+cPedido .AND. ;
				SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

			// Nao processar os Impostos se o item possuir residuo eliminado
			If &cFiltro
				SC7->(dbSkip())
				Loop
			EndIf

			If !Empty(cRegra)
				If AllTrim(cRegra) == "NOROUND"
					nValTotSC7 := NoRound( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
				ElseIf AllTrim(cRegra) == "ROUND"
					nValTotSC7 := Round( SC7->C7_QUANT * SC7->C7_PRECO, nTamTot )
				Else
					nValTotSC7 := SC7->C7_TOTAL
				EndIf
			EndIf

			// Inicia a Carga do item nas funcoes MATXFIS
			nItem++
			MaFisIniLoad(nItem)

			For nX := 1 To Len(aStru)
				cValid	:= StrTran(UPPER(GetCbSource(aStru[nX][7]))," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid .And. !(aStru[nX][14]) //campos que não são virtuais
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.
					If aStru[nX][3] == "C7_TOTAL" .AND. !Empty(cRegra)
						MaFisLoad(cRefCols,nValTotSC7,nItem)
					Else
						MaFisLoad(cRefCols,&("SC7->"+ aStru[nX][3]),nItem)
					EndIf
				EndIf
			Next nX

			MaFisEndLoad(nItem,2)

			SC7->(dbSkip())
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110Logo  ³ Autor ³ Materiais             ³ Data ³07/01/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna string com o nome do arquivo bitmap de logotipo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R110Logo()

	Local cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo com o codigo do grupo de empresas ³
//³ completo, retira os espacos em branco do codigo da empresa   ³
//³ para nova tentativa.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + SM0->M0_CODFIL+".BMP" // Empresa+Filial
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo com o codigo da filial completo,  ³
//³ retira os espacos em branco do codigo da filial para nova    ³
//³ tentativa.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ainda nao encontrar, retira os espacos em branco do codigo³
//³ da empresa e da filial simultaneamente para nova tentativa.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo por filial, usa o logo padrao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf

Return cBitmap

/*/{Protheus.doc} R110cObs
//Receber conteúdo do campo "Observações" para a impressão correta 

@param aAux1					Pegar array do cObs01 onde foi separado com "enter" como quebra de linha
@param nTamLinha				Definição do máximo de caracteres que precisa ser definido na linha do campo Observações 

@author Gustavo Mantovani Cândido
@since 09/05/2018
@version 1.0
/*/
Static Function R110cObs(aAux1, nTamLinha)
	Local cVar
	Local nObs := 1
	Local nTam := 0
	Local nX, nY
	Local nQtdLinhas := 0
	For nX := 1 To Len(aAux1)
		nY := 1
		nQtdLinhas := Ceiling(Len(aAux1[nX]) / nTamLinha)
		While nY <= nQtdLinhas .And. nObs <= 16
			cVar := "cObs"+StrZero(nObs,2)
			nTam := (nTamLinha * ( nY - 1 )) + 1

			&(cVar) := Substr(aAux1[nX],nTam, IIF( nY <> nQtdLinhas, nTamLinha, (( Len(aAux1[nX]) - ( nTam ))) + 1 ))
			nObs++
			nY++
		EndDo
	Next nY
Return Nil

/*/{Protheus.doc} R110Hash
//Carga de usuários do sistema para objeto HashMap
@Return oHash Objeto 		

@author Fabiano Dantas
@since 19/10/2022
@version 1.0
/*/
Static Function R110Hash()
	Local aCadUsu  := FWSFALLUSERS()
	Local nM 		 := 0

	oHash := tHashMap():New()
	For nM := 1 To Len(aCadUsu)
		oHash:Set(aCadUsu[nM][2],aCadUsu[nM][4])//Carrega o codigo e nome completo do usuário.
	Next

Return oHash
