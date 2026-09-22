#INCLUDE "MATA331.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RDCTBEST  ³ Autor ³ Thiago Góes		    ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Contabilizacao do Custo Medio                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indicacao da variavel de processamento em Batch    ³±±
±±³          ³ ExpA2 = Lista com as filiais a serem consideradas (Batch)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RDCTBEST(lBat,aListaFil)
 Local   oDlg
 Local   nX
 Local   dBkpData    := CTOD('  /  /  ')       
 Local   cPerg       := "RDCTBEST"
 Private dDtLim              
 Private nLinha:=0 
 Private lExecuta := .T.
 Private cCriterio := ""
 Private lRateio:= .F.
 Private cChaveBusca := ""
 Private lPosiciona :=.T.
 Private dInicio	   := GETNEWPAR("MV_ULMES")+1
 Private a330ParamZX:= ARRAY(21)
 Private lLanctoOn
 Private lAglutina
 Private lDigita
 Private cCadastro := OemToAnsi(FWI18NLang("MATA331","STR0001",1))
 Private l330ArqExcl:= IIf(Getmv("MV_CUSTEXC")!="N",.T.,.F.) 	// Abertura de arq. exclusivos/compartilhados
 Private lMATA330   := .T.
 Private cEol := chr(13)+chr(10)
 Private lSimula
 Private cTabCTK
 Private cTabCT2
 Private cTabCV3
 Private cCtaRec  
 Private nTotal166 := 0
 Private nTotal168 := 0
 Public aFlagCtb    := {}
 Public aTabRecori  := {}
 Public aDadosProva := {}
 Public ACT5 := {}
 Public aFilsCalc := {}
 
 Default aListaFil := {}
 Default dDtLim := Date()
 
 STATIC  a330RegCTB := {} 
 
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do programa em relacao aos modulos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//FAJUSTSX1( cPerg ) Thais Paiva - Compatibilização P27

If AMIIn(4,12,44,72,34)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ dInicio  - Data Inicial para processamento                   ³
	//³ mv_par01 - Data limite para processamento                    ³
	//³ mv_par02 - Calculo de Custo por  1 = SIM           			 |
	//|                                  2 = NAO 				     |
	//|                                  3 = Selec. Filiais          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Pergunte(cPerg, .F.)

	lDigita   := .F.  // pergunta mv_par02 - Se mostra e permite digitar lancamentos contabeis
	lAglutina := .F. //  pergunta mv_par03 - Se deve aglutinar os lancamentos contabeis  
	lLanctoOn := .F.    //mv_par04 - Se deve atualizar os valores dos movimentos
	lBat	  := IIf(lBat == NIL, .F., lBat)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Inicializa o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	ProcLogIni( {},"RDCTBEST")
 
	 DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi(FWI18NLang("MATA331","STR0001",1)) PIXEL //"Contabilização dos Custo Medio"
	 @ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
	 @ 16, 15 SAY OemToAnsi(FWI18NLang("MATA331","STR0001",1)) SIZE 268, 8 OF oDlg PIXEL //"Este programa permite que os lançamentos contabeis do periodo selecionado sejam refeitos sem que "
	 @ 26, 15 SAY OemToAnsi(FWI18NLang("MATA331","STR0003",3)) SIZE 268, 8 OF oDlg PIXEL //"seja necessario rodar novamente a rotina de Recalculo do Custo Medio."
	 @ 36, 15 SAY OemToAnsi(FWI18NLang("MATA331","STR0004",4)) SIZE 268, 8 OF oDlg PIXEL //"Atenção: As perguntas utilizadas nesta rotina são as mesmas utilizadas na rotina do Recalculo"
	 @ 46, 15 SAY OemToAnsi(FWI18NLang("MATA331","STR0005",5)) SIZE 268, 8 OF oDlg PIXEL //"do Custo Medio, porem somente as perguntas referentes a contabilização são utilizadas."
	// @ 56, 15 SAY OemToAnsi(STR0011) SIZE 268, 8 OF oDlg PIXEL //"Importante: somente serão contabilizados na rotina os dados de custo medio aglutinados"
	 @ 56, 15 SAY "Importante: somente serão contabilizados na rotina os dados de custo medio aglutinados" SIZE 268, 8 OF oDlg PIXEL
	// @ 66, 15 SAY OemToAnsi(STR0012) SIZE 268, 8 OF oDlg PIXEL //"Médio."
	 @ 80, 15 SAY OemToAnsi(FWI18NLang("MATA331","STR0006",6)) + DTOC(dInicio) SIZE 268, 8 OF oDlg PIXEL //"Data Inicial de Processamento : "
	
	 DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView() ENABLE OF oDlg
	 DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
	 DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(MTA331TOk(),(Processa({|lEnd| fProcess(aListaFil,lBat,@lEnd)},OemToAnsi(FWI18NLang("MATA331","STR0007",7)),OemToAnsi(FWI18NLang("MATA331","STR0008",8)),.F.),oDlg:End()),) ENABLE OF oDlg //##"Processando ..."##"Contabilizacao do Custo Medio"
	 DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	 ACTIVATE MSDIALOG oDlg CENTERED
	//	Else
	//		Processa({|lEnd| fProcess(aListaFil,lBat,@lEnd)},OemToAnsi(STR0007),OemToAnsi(STR0008),.F.)
	//	EndIf	
 EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fProcess³ Autor ³ Thiago Góes			      ³ Data ³19/04/19³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a Contabilizacao do Custo Medio                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Lista com as filiais a serem consideradas (Batch)  ³±±
±±³          ³ ExpL2 = Indicacao da variavel de processamento em batch    ³±±
±±³          ³ ExpL3 = Variavel que controla interrupcao do processo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function fProcess(aListaFil,lBatch,lEnd)
 Local cOrigens  := ""
 Local cFilBack  := cFilAnt
 Local nForFilial:= 0
 Local aAuxFil   := {}

// Variaveis utilizadas para criacao do arquivo de trabalho
 Local aCamposTRC:= GetTRStru()
 Local cNomTRC   := ""
 Local cNomTRC1  := Substr(cNomTRC,1,7)+"Z" //Compatibilização P27
 Local cQry      := " "
 Local aSelFil   := {}
 Private aFilsCalc := {}
 
 
 dDtLim  := MV_PAR01 //data limite para processamento.
 
 Private lBat    := lBatch     
 
 // Array com filiais a serem processadas na contabilizacao
 a330RegCTB := {} 

// Variaveis utilizadas para lancamentos contabeis
 
 lDigita   := .F.  // pergunta mv_par02 - Se mostra e permite digitar lancamentos contabeis
 lAglutina := .F. //  pergunta mv_par03 - Se deve aglutinar os lancamentos contabeis  
 lLanctoOn := .F.    //mv_par04 - Se deve atualizar os valores dos movimentos
 lBat	   := IIf(lBat == NIL, .F., lBat)

 
 //fProced(dTos(dInicio))
 
//Gestao - Selecao de filiais    
// aSelFil	:= {}
 If mv_par02 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil(.F.,.T.,"QZA")
	If Len( aSelFil ) <= 0
		Aviso("Aviso","Nenhuma Filial Selecionada",{"Ok"},,) 
		Return
	EndIf	
 Else
	aSelFil := { cFilAnt }	 
 EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para selecao das filiais para calculo por empresa     |	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 aFilsCalc:=aClone(aSelFil)
 
 If !Empty(aFilsCalc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao para o calendario contabil                    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nForFilial := 1 to Len(aFilsCalc)
		//If aFilsCalc[nForFilial]
			// Altera filial corrente
			cFilAnt:=aFilsCalc[nForFilial]
			//-- Verifica Calendario Contabil
			dInicio := GETNEWPAR("MV_ULMES",FirstDate( Date())-1,cFilAnt)
			dInicio := dInicio+1
			If  !(fVldCal(dInicio,dDtLim))
				Aviso("Calendario Bloqueado", "Filial : "+cFilAnt)
				Return .T.
			EndIf	
		//EndIf
	Next nForFilial
	// Restaura filial original apos processamento
	cFilAnt:=cFilBack
	dInicio := GETNEWPAR("MV_ULMES",FirstDate( Date())-1,cFilAnt)+1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a criacao e a abertura do arquivo de trabalho "TRC" e cria seu indice.    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Início - Thais Paiva - Compatibilização P27
	//dbUseArea( .T.,,cNomTRC,"TRC",.T.) //Cria compartilhado para multithread
	//INDEX ON TRC_FILIAL+TRC_SEQUEN TO (cNomTRC1+".cdx")
	//dbClearIndex()
	//dbSetIndex(cNomTRC1+".cdx")
	//dbSetOrder(1)    
	oTempTable := FWTemporaryTable():New( "TRC" )
	oTemptable:SetFields( aCamposTRC )
	oTempTable:AddIndex( '01' , { "TRC_FILIAL","TRC_SEQUEN"} )
	oTempTable:Create()
	////Início - Thais Paiva - Compatibilização P27
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os lancamentos contabeis relacionados                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nForFilial := 1 to Len(aFilsCalc)
	
		cFilAnt:=aFilsCalc[nForFilial]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se vai abrir o arquivo para lancamentos contabeis   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//cOrigens := "MATA240/MATA250/MATA260/MATA261/MATA330/MTA460C/MTA520C/CNA200C/MATA685/" 
		cOrigens := "RDCTBEST"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento			    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("MENSAGEM",FWI18NLang("MATA331","STR0013",13),FWI18NLang("MATA331","STR0013",13)) //"Apagando Lançamentos Contabeis do Periodo"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Apagando Lancamentos Contabeis do Periodo   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fApaga(cOrigens,dDtLim,.F.,cFilAnt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza reprocessamento contabil            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aAuxFil,cFilAnt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento			    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogIni( {},"RDCTBEST") 
			//EndIf
	Next nForFilial
	
	//-- Restaura filial original apos processamento
	cFilAnt:=cFilBack
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reprocessamento Contabil para fAPAGA()           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fReproc(aAuxFil,dInicio,a330ParamZX[01])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa Lancamentos Contabeis por Filial 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nForFilial := 1 to Len(aFilsCalc)
		cFilAnt:=aFilsCalc[nForFilial]
		//-- Gera lancamentos contabeis
		GeraLancto(lBat,lEnd)
	Next nForFilial

	//-- Restaura filial original apos processamento
	cFilAnt:=cFilBack
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa geracao de lancamentos contabeis					 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fContab("RDCTBEST",cNomTRC,cNomTRC1,aFilsCalc)
	
	For nForFilial := 1 to Len(aFilsCalc)
		fLimCtt(aFilsCalc[nForFilial])
	Next nForFilial
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga arquivo de Trabalho         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectarea("TRC")
	dbCloseArea()
	oTempTable:Delete() //Thais Paiva - 04/12/2020
	//Ferase(cNomTrc+GetDBExtension()) Thais Paiva - Compatibilização P27
	//Ferase(cNomTrc1+OrdBagExt()) Thais Paiva - Compatibilização P27
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MA331FIM - Ponto de entrada utilizado para validacoes  |
	//| no fim da contabilização                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 EndIf
 
Aviso("Aviso", "Processo Finalizado com sucesso!",{"OK"})
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA331TOk ³ Autor ³Thiago Góes		    ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se pode efetuar a Contabilizacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTA331TOk()
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o periodo a ser processado nao se encontra encerrado |                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If lRet 
	If dInicio > dDtLim
		Aviso(FWI18NLang("MATA331","STR0022",22),FWI18NLang("MATA331","STR0020",20),{"Ok"},,FWI18NLang("MATA331","STR0021",21)) // ATENCAO - "A data limite final informada para execução da rotina de recalculo do custo medio e menor ou igual a data de inicio de processamento do parametro MES. Favor verificar a data informada para processamento."
		lRet := .F.
	EndIf
 EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraLancto   ³ Autor ³Thiago Góes 		³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera Lancamentos Contabeis 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indicacao da variavel de processamento em Batch    ³±±
±±³          ³ ExpL2 = Variavel que indica o fim do processamento.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 Static Function GeraLancto(lBat,lEnd)
 Local aAreaAnt := GetArea()
 Local aAreaQZA := QZA->(GetArea())
 Local cAliasTRB:= "TRB"
 Local lQuery   := .F.
 Local nTotRegs := 0
 Local cQuery  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A330CDEV - Ponto de Entrada utilizado para contabilizar os   |
//| lancamentos de devolucao de compras LP 678                   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 //Local lA330CDEV := ExistBlock("A330CDEV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipos de Lancamentos Padronizados                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| 166 -> Saida de saldo em estoque (requisicao) para materiais com apropriacao direta                                         |
//| 168 -> Entrada de saldo em estoque (devolucao / producao) para materiais com apropriacao direta                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 dbSelectArea("QZA")		//-- Movimentacoes internas (producao/requisicao/devolucao)
 nTotRegs += RecCount()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ProcLogAtu("MENSAGEM",FWI18NLang("MATA331","STR0014",14),FWI18NLang("MATA331","STR0014",14)) //"Iniciando Processamento do Arquivo de Trabalho"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Arquivo de Trabalho Top/CodeBase 					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 lQuery	  := .T.
 cAliasTRB := CriaTrab( Nil,.F.)
 
 cQuery := " SELECT 'QZA' TRB_ARQ,R_E_C_N_O_ TRB_RECMOV,row_number() OVER (ORDER BY QZA.R_E_C_N_O_) TRB_SEQCAL "+cEol
 cQuery += "   FROM "+ RetSqlName("QZA")+" QZA "+cEol
 cQuery += "    WHERE QZA_FILIAL = '" + cFilAnt + "'"+cEol
 cQuery += "    	AND QZA_DATA >= '" + DTOS(dInicio) + "' AND QZA_DATA <= '" + DTOS(dDtLim) + "'  "+cEol
 cQuery += "    	AND D_E_L_E_T_ = ' ' "+cEol

 cQuery += " ORDER BY QZA_FILIAL, QZA_DATA " 


 cQuery := ChangeQuery(cQuery)

 dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .F., .T.)
 dbSelectArea(cAliasTRB)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("MENSAGEM",FWI18NLang("MATA331","STR0015",15),FWI18NLang("MATA331","STR0015",15)) //"Termino do Processamento do Arquivo de Trabalho"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ProcLogAtu("MENSAGEM",FWI18NLang("MATA331","STR0016",16),FWI18NLang("MATA331","STR0016",16)) //"Definindo Tipos de Lançamentos Contabeis"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Lancamentos Contabeis							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 dbSelectArea(cAliasTRB)
 dbGoTop()

 If !lBat
	ProcRegua(nTotRegs)
 EndIf

 While !(cAliasTRB)->(Eof())

	If lEnd
		@PROW()+1,001 PSay OemToAnsi(FWI18NLang("MATA331","STR0009",9)) //-- "CANCELADO PELO OPERADOR"
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimentacao do Cursor                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lBat
		IncProc(OemToAnsi(OemToAnsi(FWI18NLang("MATA331","STR0010",10))))		//"Processando ..."
	EndIf

	dbSelectArea("QZA")
	dbGoto((cAliasTRB)->TRB_RECMOV)
	//-- Gera o lancamento no arquivo de prova
	If QZA->QZA_TM <= "500"                                     
		A330DET(cValtoChar((cAliasTRB)->TRB_SEQCALC),"168","RDCTBEST","QZA")
	Else 
	   	A330DET(cValtoChar((cAliasTRB)->TRB_SEQCALC),"166","RDCTBEST","QZA")
	EndIf

	(cAliasTRB)->(dbSkip())
	Loop

 EndDo

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Atualiza o log de processamento			    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ProcLogAtu("MENSAGEM",FWI18NLang("MATA331","STR0017",17),FWI18NLang("MATA331","STR0017",17)) //"Termino da Definição dos Tipos de Lançamentos Contabeis"

 If lQuery
	dbSelectArea(cAliasTRB)
	dbCloseArea()
 EndIf

 RestArea(aAreaQZA)
 RestArea(aAreaAnt)

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A330DET  ³ Autor ³Thiago Góes   		    ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria em array lancamentos contabil testando lLanctoOn       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A330DET(cSeqCalc,cLanctoPad,cRotinaCall,cAliasOri,lAvalLcto)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Sequencia de calculo                               ³±±
±±³          ³ ExpC2 = Codigo do Lancamento Padrao                        ³±±
±±³          ³ ExpC3 = Rotina Chamadora                                   ³±±
±±³          ³ ExpC4 = Alias                                              ³±±
±±³          ³ ExpL5 = Avalia se usa 666/668 para Req/Dev de Consumo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A330Det(cSeqCalc,cLanctoPad,cRotinaCall,cAliasOri,lAvalLcto)
 Local cAlias  := Alias(), lCCusto := .F.
 Local l667669 := cLanctoPad$"667#669"
 Local lPcoInte:= SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
 Local lRet	  := .F.

 cRotinaCall := "RDCTBEST"
 cAliasOri   := IIF(cAliasOri==NIL,"QZA",cAliasOri)
 lAvalLcto   := IIF(lAvalLcto==NIL,.F.,lAvalLcto)

 If cAliasOri == "QZA"
	dbSelectArea("QZA")

	RecLock("QZA",.F.)                                                                 
	_FIELD->QZA_DATA := LastDay(dInicio,0)
	MsUnlock()

	// Adiciona na lista para geracao de lancamento contabil
	GravaRegCT(cFilAnt,cAliasOri,(cAliasOri)->(Recno()),cSeqCalc+"01",cLanctoPad,cRotinaCall,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o PCO processo 314 item 02      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 EndIf

 dbSelectArea(cAlias)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaRegCT³ Autor ³Thiago Góes            ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava registro no arquivo de trabalho para contabilizacao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilTRC    = Endereco do arquivo de contra-prova           ³±±
±±³          ³ cAliasTRC  = Alias do Movimento SD1/SD2/SD3                ³±±
±±³          ³ nRecTRC    = Numero do Registro do Movimento               ³±±
±±³          ³ cSeqTRC    = Codigo sequencial do Movimento                ³±±
±±³          ³ cLanctoTRC = Numero do Lancamento Padrao                   ³±±
±±³          ³ cRotTRC    = Rotina que originou a chamada da funcao       ³±±
±±³          ³ lProcLanc  = Avalia Lancamentos 667/669                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaRegCT(cFilTRC,cAliasTRC,nRecTRC,cSeqTRC,cLanctoTRC,cRotTRC,lProcLanc)
Local nAcho := ASCAN(a330RegCTB,{|x| x[1] == cFilTRC})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza array de controle de Filiais processadas                                 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAcho == 0
	AADD(a330RegCTB,{cFilTRC,1,0,"","",0})
Else
	a330RegCTB[nAcho,2]+=1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza registros                                                                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRC")

DbAppend()
 Replace TRC_FILIAL With cFilTRC
// Replace TRC_ALIAS  With cAliasTRC //alterado por thiago goes em 10/07/2020
 Replace TRC_RECTRC With nRecTRC
 Replace TRC_SEQTRC With cSeqTRC
 Replace TRC_LANTRC With cLanctoTRC
 Replace TRC_ROTTRC With cRotTRC
 Replace TRC_AVALTR With If(lProcLanc,"S","N")
 Replace TRC_SEQUEN With cFilTRC + StrZero(IIf(nAcho == 0,1,a330RegCTB[nAcho,2]),10,0)
MsRUnlock()

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    fLimCtt Autor ³Thiago Góes				    ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava registro no arquivo de trabalho para contabilizacao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilTRC    = Endereco do arquivo de contra-prova           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fLimCtt(cFilTRC)
 Local nIndFil	:= Ascan(a330RegCTB, {|x| x[1] == cFilTRC})
 
 If nIndFil > 0
	a330RegCTB[nIndFil] := {cFilTRC,0,0,"","",0}
 EndIf

Return Nil

//--------------------------------------------------------------------------
/*/{Protheus.doc} A330LimCtt
Apaga lançamento contabeis - direciona para fApCTB
@author Victor Rezende
@since 17/03/17
@param cFilTRC
/*/
//--------------------------------------------------------------------------

Static Function fApaga(cRotina,dDtLimite,lReproc,cFilAnt)

//If CtbInUse()
 IncProc("Contabilizando Lançamentos  - Apagando Lançamentos - Filial : "+cFilAnt) //"Contabilizando Lançamentos"
 fApCTB(cRotina,dDtLimite,lReproc,cFilAnt)
//Else
//	Ca100ApCON(cRotina,dDtLimite)
//EndIf		

Return .T.

//--------------------------------------------------------------------------
/*/{Protheus.doc} A330LimCtt
Apaga lançamento contabeis
@author Victor Rezende
@since 17/03/17
@param cFilTRC
/*/
//--------------------------------------------------------------------------

Static Function fApCTB(cRotina,dDataFim,lReproc,cFilAnt)

 Local dDataIni := GETNEWPAR("MV_ULMES",FirstDate( Date())-1,cFilAnt)+1
 Local lCusto	:= CtbMovSaldo("CTT")
 Local lItem		:= CtbMovSaldo("CTD")
 Local lCLVL		:= CtbMovSaldo("CTH")
 Local lDeleta   := .T.
 Local nMinRecno, nMaxRecno
 Local nCont
 Local nValor      
 Local nCountReg	:= 0
 Local lDelFisico:=	GetNewPar('MV_CON100D',.T.)
 Local lExclusivo	:= If(FindFunction("ADMTabExc"), ADMTabExc("CT2"), !Empty(xFilial("CT2"))) //Analisa se a tabela esta exclusiva

Default lReproc := .T.

cRotina	:= Upper(cRotina)

 If CtbInUse()
	ChkFile("CT2")
 Endif

 #IFDEF TOP
	If TcSrvType() != "AS/400"  .And. lDelFisico

// Verifico na moeda 01 se a data de inicio e de fim eh valida

		If ! CtbDtComp(5,dDataIni,"01") .Or. ! CtbDtComp(5,dDataFim,"01")
			Return
		Endif
		
		//Verifico o menor registro e maior registro da tabela a ser atualizada		
		cRotina := If(Right(cRotina, 1) = "/", Left(cRotina, Len(cRotina) - 1), cRotina)
		
		cRecno := "cRecno"  						
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName("CT2")+ " "
		cQuery += "WHERE CT2_FILIAL = '" + cFilAnt + "' AND "
		cQuery += "CT2_DATA >= '" + Dtos(dDataIni) + "' AND "
		cQuery += "CT2_DATA <= '" + Dtos(dDataFim) + "' AND "
		cQuery += "CT2_ROTINA IN " + FormatIn(cRotina, "/") + " AND "
		cQuery += "(CT2_FILORI = '  ' OR CT2_FILORI = '" + cFilAnt + "' ) AND "
		cQuery += "(CT2_EMPORI = '  ' OR CT2_EMPORI = '" + cEmpAnt + "' )"
		cQuery += " ORDER BY RECNO "
		cQuery := ChangeQuery(cQuery)
		
		If ( Select ( "cRecno" ) <> 0 )
			dbSelectArea ( "cRecno" )
			dbCloseArea ()
		Endif
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cRecno,.T.,.F.)
		

		cQuery := "DELETE FROM "+RetSqlName("CT2")+ " "
		cQuery += "WHERE CT2_FILIAL = '"+cFilAnt +"' AND "
		cQuery += "CT2_DATA >= '" + Dtos(dDataIni) + "' AND "
		cQuery += "CT2_DATA <= '" + Dtos(dDataFim) + "' AND "
		cQuery += "CT2_ROTINA IN " + FormatIn(cRotina, "/") + " AND "
		cQuery += "(CT2_FILORI = '  ' OR CT2_FILORI = '" + cFilAnt + "' ) AND "
		cQuery += "(CT2_EMPORI = '  ' OR CT2_EMPORI = '" + cEmpAnt + "' ) AND "
		
		While cRecno->(!Eof())
	
			nMin := (cRecno)->RECNO
			
			nCountReg := 0
				
			While cRecno->(!EOF()) .and. nCountReg <= 4096
					
				nMax := (cRecno)->RECNO
				nCountReg++
				cRecno->(DbSkip())

			End
				
			cChave := " R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
			TcSqlExec(cQuery+cChave)
		End
		dbSelectArea("cRecno")
		dbCloseArea()
	Else
 #ENDIF

	dbSelectArea("CT2")
	dbSeek(cFilAnt+DTOS(dDataIni),.T.)
	
	While ! Eof() .And. CT2->CT2_FILIAL == cFilAnt .And. DTOS(CT2->CT2_DATA) <= DTOS(dDataFim)
		
		If ! (Alltrim(Upper(CT2->CT2_ROTINA))$cRotina )
			dbSkip()
			Loop
		EndIf
		
		//????????????????????????????????
		//?Atualiza o Plano de Contas                                   ?
		//????????????????????????????????
		lDeleta := .T.							// Verifica qual registro pode deletar
		For nCont := 1 To Len(CT2->CT2_MOEDAS)
			IF SubStr(CT2->CT2_MOEDAS,nCont,1) == "1" .And. lDeleta
				cMoeda  := StrZero(nCont,2)
				nValor  := &('CT2->CT2_VLR'+cMoeda)
				If lDeleta
					lDeleta := CtbDtComp(5,CT2->CT2_DATA,cMoeda)
				Endif
	
	// Removida desgravacao de saldos - Sera Chamado Reprocessamento
	
			EndIf
		Next nCont		
		If lDeleta
			dbSelectArea("CT2")
			RecLock( "CT2", .f., .t. )
			CT2->( DbDelete() )
			MsUnlock()
		EndIf
		
		dbSkip( )
	End
	
#IFDEF TOP
 Endif
#ENDIF

// Reprocessamento contabil
If lReproc
	cFil190 := If(lExclusivo, cFilAnt, XFilial("CT2"))
	CTBA190(.T.,dDataIni,dDataFim,cFil190,cFil190,"1",.F.,"  ")
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ fContab                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Thiago Góes					             ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processa geracao de lancamentos contabeis                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 = Nome do processo utilizado na funcao ProcLogAtu    ³±±
±±³           ³ ExpC2 = Nome do arquivo de trabalho                        ³±±
±±³           ³ ExpC3 = Nome do indice do arquivo de trabalho              ³±±
±±³           ³ ExpA4 = Array com as filiais selecionadas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fContab(cProcLog,cNomTRC,cNomTRC1,aFilsCalc)
 Local aCt5 := {}	 // Variavel para armazenar os lancamentos padroes envolvidos na rotina - Melhora de perfomance na DetProva para SigaCTB
// Armazena filial original
 Local cFilBack  := cFilAnt  
// Numero de threads para processamento
 Local nThreads  := 1
// Array com controle dos registros para cada thread
 Local aThreads  := {}
// Numero de registros
 Local nRegistros:= 0
 Local nRegProc  := 0
 Local nInicio   := 0
 Local nValLancto:= 0
// Contador
 Local nX         :=0
 Local nZ         :=0
 Local nForFilial :=0
// Id do arquivo de log
 Local nHdl
// Variaveis utilizadas na contabilizacao
 Local nHdlPrv    :=NIL	// Endereco do arquivo de contra prova dos lanctos cont.
 Local nTotal     :=0	// Total dos lancamentos contabeis
 Local nTotRead   :=0   	// Total lido da thread
 Local cLoteEst   :=""	// Numero do lote para lancamentos do estoque
 Local cArquivo   :=""	// Nome do arquivo contra prova
//LOCAL aDadosProva:={}  // Array com dados gerados na abertura do lancamento
 Local cArray     :=""
// Retorna o StartPath
 Local cStartPath := GetSrvProfString("Startpath","")
//Array auxiliar para controle de Jobs
 Local aJobAux    := {}
 Local cJobAux    := {}
// Controle de tentativas
 Local nRetry_0   := 0
 Local nRetry_1   := 0
// Variaveis para o reprocessamento contabil
 Local dReproc    := dDtLim
 Local aAuxFil    := {}
// Sempre processar saldo tipo 1 - Real
 Local aTpSaldo   := {"1"}
 Local aAuxTpSld  := {"1"}
// Utilizado para verificar se gera tabela CV3
 Local lProcCV3   := SuperGetMv("MV_PROCCV3",.F.,.T.)
 Local dSaveData  := Date()

//Variaveis para gravação do código de correlativo
 Local aDiario	:= {}
 Local lSeqCorr	:= UsaSeqCor("QZA")

// Rotina default da contabilizacao
 Default cProcLog :="RDCTBEST"
 Default aFilsCalc:= {}   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a quantidade de threads da primeira filial selecionada  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ProcLogAtu("MENSAGEM","Iniciando Geração de Lançamentos Contabeis","Iniciando Geração de Lançamentos Contabeis") //Iniciando Geração de Lançamentos Contabeis

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONTABILIZACAO PADRAO (THREAD UNICA)              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 For nZ:=1 to Len(a330RegCTB)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Posiciona registros para lancamento contabil                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	cFilAnt:=a330RegCTB[nZ,1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	dbSeek(xFilial()+"09EST")
	cLoteEst:=IIF(!Eof(),Trim(X5Descri()),"EST")
	nTotal  :=0     // Total dos lancamentos contabeis
	cArquivo:=""    // Nome do arquivo contra prova
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho do arquivo de prova                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	nHdlPrv := A330HEAD(cLoteEst,"RDCBEST",Pad(Subs(cUsuario,7,6),6),@cArquivo)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento			    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ProcLogAtu("MENSAGEM","Iniciando Geração do Arquivo de Contra-Prova","Iniciando Geração do Arquivo de Contra-Prova") //"Iniciando Geração do Arquivo de Contra-Prova"

	dbSelectArea("TRC")
	dbGoTop()
	dbSeek(cFilAnt)
	
    	
	While TRC->(!Eof()) .And. TRC_FILIAL == cFilAnt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimentacao do Cursor                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       	If !lBat .And. !IsBlind()
			ProcLogAtu("MENSAGEM","Contabilizando Lançamentos","Contabilizando Lançamentos") //"Contabilizando Lançamentos"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Checa se deve processar registro                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Posiciona arquivo e registro	
		// dbSelectArea(TRC->TRC_ALIAS) //alterado por thiago góes em 10/07/2020
    	// Posiciona registro na tabela SB1
		QZA->(dbGoto(TRC->TRC_RECTRC))
		dSaveData := QZA->QZA_DATA	
		dDataBase:=dSaveData
		nHdlPrv:= HeadProva(cLoteEst,"RDCTBEST",Alltrim(cUserName),@cArquivo) 
		        
		If !lBat .And. !IsBlind()
			IncProc("Contabilizando Lançamentos  - Filial : "+cFilAnt+ " - Periodo : "+dtoc(dSaveData)) //"Contabilizando Lançamentos"
		EndIf
		
        While (dSaveData == QZA->QZA_DATA)
			// Gera lancamento      
			QZA->(dbGoto(TRC->TRC_RECTRC))
	
			If QZA->QZA_TM >= "500"
				nValLancto := DetProva(nHdlPrv,"166","RDCTBEST",cLoteEst, @nLinha)
			Else
			  	nValLancto := DetProva(nHdlPrv,"168","RDCTBEST",cLoteEst)
			EndIf
					 
			nTotal +=  nValLancto
			 	
			dbSelectArea("TRC")
			dbSkip()
			If TRC->(!Eof()) .And.(dSaveData != QZA->QZA_DATA)
		    	RodaProva(nHdlPrv,nValLancto) 
	   			cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,.F.) // Essa e a funcao do quadro dos lancamentos. 
		    	nHdlPrv := A330HEAD(cLoteEst,"RDCBEST",Pad(Subs(cUsuario,7,6),6),@cArquivo)	
			EndIf	
		EndDo
	
		If nHdlPrv != NIL
			RodaProva(nHdlPrv,nValLancto) 
	   		cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,.F.) // Essa e a funcao do quadro dos lancamentos. 
  	  	EndIf
    EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento			    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem informacoes para fechar lancamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nHdlPrv != NIL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento			    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FunName() == 'RDCTBEST'
			ProcLogIni( {},"RDCTBEST")
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aTpSaldo - Tipos de saldos para reprocessamento contabil              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX:=1 to Len(aAuxTpSld)
			If Ascan( aTpSaldo,aAuxTpSld[nX] ) == 0
				Aadd( aTpSaldo,aAuxTpSld[nX] )
			EndIf
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Analisa data final para execucao do reprocessamento contabil.         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CT2->(DbSetOrder(1))
		CT2->(DbSeek(Soma1(xFilial("CT2")), .T.))	// Procuro a proxima filial
		CT2->(DbSkip(-1))							// Volto para o registro anterior
		//Maior data de reprocessamento dos saldos contabeis
		If CT2->CT2_FILIAL = xFilial("CT2") .And. CT2->CT2_DATA > dReproc
			dReproc := CT2->CT2_DATA
		EndIf
 	EndIf

 Next nZ
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Carrega array auxiliar de filiais           |
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 For nForFilial := 1 to Len(aFilsCalc)
	// Altera filial corrente
	cFilAnt:=aFilsCalc[nForFilial]
	// Adiciona filial no array auxiliar
	aAdd(aAuxFil,cFilAnt)
 Next nForFilial

 // Restaura filial original apos processamento
 cFilAnt:=cFilBack
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reprocessamento Contabil para CA100INCL()            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If !Empty(aAuxFil)
	fReproc(aAuxFil,dInicio,dReproc,aTpSaldo)
 EndIf	

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Atualiza o log de processamento			    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If FunName() == 'RDCTBEST'
	ProcLogIni( {},'RDCTBEST')
 EndiF

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Atualiza o log de processamento			    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ProcLogAtu("MENSAGEM","Encerramento da Geração de Lançamentos Contabeis","Encerramento da Geração de Lançamentos Contabeis") //"Encerramento da Geração de Lançamentos Contabeis"

 // Filial corrente a ser considerada
 cFilAnt:=cFilBack
Return
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A330HEAD ³ Autor ³ Thiago Góes  	 	    ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Simula HEADPROVA testando lLanctoOn (Lancto. On-Line)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MA330HEad(xPar1,xPar2,xPar3,xPar4)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do lote para lancamentos contabeis          ³±±
±±³          ³ ExpC2 = Nome da Rotina de Origem dos lancamentos contabeis ³±±
±±³          ³ ExpC3 = Nome do Usuario Corrente                           ³±±
±±³          ³ ExpC4 = Nome do Arquivo de Contra-Prova                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A330HEAD(xPar1,xPar2,xPar3,xPar4,aPar5)
 Local nRet := 0
 xPar2 := "RDCTBEST"
 If lLanctoOn
	nRet := HEADPROVA(xPar1,xPar2,xPar3,@xPar4,nil,aPar5)
 EndIf
Return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fReproc  ³ Autor ³ Thiago Góes  			³ Data ³ 19.04.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reprocessamento Contabil					                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com a lista de filiais contabilizadas        ³±±
±±³          ³ ExpD2 = Data inicial de reprocessamento                    ³±±
±±³          ³ ExpD3 = Data final de reprocessamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fReproc(aAuxFil,dInicio,dFim,aTpSaldo)
 Local nForFilial := 0
 Local nTipoSaldo := 0
 Local cFilIni    := ""
 Local cFilFim    := ""
 Local aAreaAnt   := GetArea()
 Local lReproc    := AllTrim(SuperGetMv('MV_A330190',.F.,"S")) == "S"

 Default aTpSaldo := {"1"}  // Sempre processar saldo tipo 1 - Real
 Default aAuxFil  := {}

 If lReproc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena filiais processadas                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ASORT(aAuxFil,,,{ |x, y| x < y })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for base compartilhada assume intervalo de filiais |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CT2")
	If Empty(xFilial("CT2"))
		// Reprocessamento contabil base compartilhada
		For nTipoSaldo:=1 to Len(aTpSaldo)
			CTBA190(.T.,dInicio,dFim,"  ","ZZ",aTpSaldo[nTipoSaldo],.F.,"  ")
		Next nTipoSaldo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza o reprocessamento das filiais De/Ate |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aAuxFil) == 1
			// Reprocessamento contabil apenas uma filial
			For nTipoSaldo:=1 to Len(aTpSaldo)
				CTBA190(.T.,dInicio,dFim,aAuxFil[1],aAuxFil[1],aTpSaldo[nTipoSaldo],.F.,"  ")
			Next nTipoSaldo
		Else
			// Reprocessamento contabil com varias filiais
			For nForFilial := 1 To Len(aAuxFil)
				If nForFilial == 1
					cFilIni := aAuxFil[nForFilial]
				Else
					If Soma1(aAuxFil[nForFilial-1]) # aAuxFil[nForFilial]
						For nTipoSaldo:=1 to Len(aTpSaldo)
							CTBA190(.T.,dInicio,dFim,cFilIni,cFilFim,aTpSaldo[nTipoSaldo],.F.,"  ")
						Next nTipoSaldo
						cFilIni := aAuxFil[nForFilial]
				    ElseIf Len(aAuxFil) == nForFilial
						For nTipoSaldo:=1 to Len(aTpSaldo)
						    CTBA190(.T.,dInicio,dFim,cFilIni,aAuxFil[nForFilial],aTpSaldo[nTipoSaldo],.F.,"  ")
						Next nTipoSaldo
				    EndIf
			    EndIf 
				cFilFim := aAuxFil[nForFilial]
			Next nForFilial
		EndIf	
	EndIf
 EndIf

 RestArea(aAreaAnt)

Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ fProced                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Thiago góes 				             ³ Data ³ 19/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processa geracao de lancamentos contabeis                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ cDtIni = Data inicial de processamento MV_ULMES + 1 	   ³±±
±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ ±±
±±³  Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//***************************************?
Static Function fProced(cDtIni)
//***************************************?
 
 Local aResult := {}
 aResult := TCSPEXEC("STP_AGL_CTB_SD3", cDtIni)
 
 If empty(aResult)
	Conout('Erro na execução da Stored Procedure : '+TcSqlError())
 Else
	 Conout("Retorno String : "+aResult[1])
	 Conout("Retorno Numerico : "+str(aResult[2]))
	 MsgInfo("Procedure Executada - Debug")
 Endif
 
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fVldCal³ Autor ³ Thiago Góes			    ³ Data ³19.04.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o calendario contabil a fim e evitar que a rotina    ³±±
±±³          ³inclua lancamentos em uma calendario ja encerrado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dDtIni = Data Inicial                                       ³±±
±±³          ³ dDtFim = Data Final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function fVldCal(dDtIni,dDtFim)
 Local lRet := .T.
 Local aAreaAnt := GetArea()

 //-- Analisa Data Inicial e Data Final do processamento
 If !CtbDtComp(5,dDtIni+1,"01") .Or. !CtbDtComp(5,dDtFim,"01")
	lRet := .F.
 EndIf	

RestArea(aAreaAnt)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    FAJUSTSX1 Autor ³ Thiago Góes			    ³ Data ³19.04.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida e atualiza perguntas da rotina					      ³±±
±±³          ³inclua lancamentos em uma calendario ja encerrado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cPerg  = Variavel com o nome da pergunta da rotina        ³±±
±±³          ³ dDtFim = Data Final                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBEST                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
/* Início - Thais Paiva - Compatibilização P27
//***********************************
Static Function FAJUSTSX1( _cPerg )
//***********************************

 Local _aSx1 := {}, _cCampo

 AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"         , "PERSPA"      , "PERENG"     , "VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID", "VAR01"   , "F3", "DEF01"           , "DEF02"         , "DEF03"         , "DEF04"       , "DEF05"          , "HELP" } )
 AADD( _aSx1, { _cPerg , "01"  , "Data Limite?   "		 , "¿A Fecha ? " 		 , "To Date ?"  		, "mv_ch1" , "D"   , 08       , 0        , 0       , "G"  , ""     , "mv_par01", ""  , ""                , ""              , ""              , ""            , ""               , ""     } )
 AADD( _aSx1, { _cPerg , "02"  , "Seleciona Filias ?"     , "¿Seleciona Filias ?" , "Seleciona Filias ?"	, "mv_ch2" , "N"   , 01       , 0        , 4       , "C"  , ""     , "mv_par02", ""  , "Sim", "Não", "", "", "", ""     } )

 DbSelectArea( "SX1" )
 SX1->( DbSetOrder( 1 ) )

 If SX1->( ! DbSeek( _cPerg + _aSx1[Len( _aSx1 ), 2] ) )
 	SX1->( DbSeek( _cPerg ) )
 	While SX1->( ! Eof() ) .And. Alltrim( SX1->X1_GRUPO ) == Alltrim( _cPerg )
 		SX1->( Reclock( "SX1", .F., .F. ) )
 		SX1->( DbDelete() )
		SX1->( MsunLock() )
		SX1->( DbSkip() )
	End

	For _X1 := 2 To Len( _aSX1 )
		SX1->( RecLock( "SX1", .T. ) )
		For _Z := 1 To Len( _aSX1[1] )
			_cCampo := "X1_" + _aSX1[1, _Z]
			SX1->( FieldPut( FieldPos( _cCampo ), _aSx1[_X1, _Z] ) )
		Next _Z
	 	SX1->( MsunLock() )
	Next _X1
 EndIf
	
Return
Fim - Thais Paiva - Compatibilização P27 */
