#INCLUDE "PROTHEUS.CH"
//#INCLUDE "TBICONN.CH"   
//#INCLUDE "TOTVS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RDCTBPRC  ³ Autor ³ Thiago Góes		    ³ Data ³ 25/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina Executa procedure para aglutinacao do estoque       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±³          ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDCTBPRC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RDCTBPRC()
 Local   oDlg
 Local   nX
 Local   cPerg       := "RDCTBPRC"
 Private nLinha:=0 
 Private dInicio	   := DATE()
 Private a330ParamZX:= ARRAY(21)
 Private cEol := chr(13)+chr(10) 
 Private aProgs := {}
 Private nFilProc := 0
 Private cFilsQry  := " "
 Private cUserRot := " "
 Public aFilsCalc := {}
 
 aAdd( aProgs, { "RDCTBPRC" } )
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Inicializa o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	ProcLogIni( {},"RDCTBPRC")   
 	
	 DEFINE MSDIALOG oDlg FROM  52,9 TO 223,512 TITLE "Aglutinação de movimentos do Estoque" PIXEL style nor(WS_VISIBLE,WS_POPUP) //"Contabilização dos Custo Medio"
	 @ 11, 6 TO 90,247 LABEL "" OF oDlg  PIXEL
 	 @ 26, 15 SAY "Este programa permite que seja executada a procedure de aglutinação do estoque por filial " SIZE 268, 8 OF oDlg PIXEL //"Este programa permite que os lançamentos contabeis do periodo selecionado sejam refeitos sem que "
	 @ 36, 15 SAY "            Importante: somente serão permitidas uma execução simultanea                  " SIZE 268, 8 OF oDlg PIXEL
	
	 DEFINE SBUTTON FROM 69, 153 TYPE 15 ACTION ProcLogView() ENABLE OF oDlg
	 DEFINE SBUTTON FROM 69, 183 TYPE 1  ACTION Processa({|lEnd| fProcess(@lEnd)},"Processando ...","Executando Procedure Aglutinação Estoque",.F.,oDlg:End()) ENABLE OF oDlg //##"Processando ..."##"Contabilizacao do Custo Medio"
	 DEFINE SBUTTON FROM 69, 213 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	 ACTIVATE MSDIALOG oDlg CENTERED
	//	Else
	//		Processa({|lEnd| fProcess(aListaFil,lBat,@lEnd)},OemToAnsi(STR0007),OemToAnsi(STR0008),.F.)
	//	EndIf	
 EndIf
 
 If nFilProc == Len(aFilsCalc) .And. !Empty(aFilsCalc)
 	MsgInfo(" ", "Processo Finalizado com sucesso!",{"OK"}) 
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
Static Function fProcess(lEnd)
 Local cOrigens  	:= ""
 Local cFilBack  	:= cFilAnt
 Local nForFilial	:= 0
 Local aAuxFil   	:= {}

// Variaveis utilizadas para criacao do arquivo de trabalho
// Local aCamposTRC:= GetTRStru()
// Local cNomTRC   := CriaTrab(aCamposTRC,.T.)
// Local cNomTRC1  := Substr(cNomTRC,1,7)+"Z"
 Local cQry        := " "
 Local aSelFil     := {}
 
 
// dDtLim  := MV_PAR01 //data limite para processamento.
 
// Private lBat    := lBatch     
 
 // Array com filiais a serem processadas na contabilizacao
 a330RegCTB := {} 

// Variaveis utilizadas para lancamentos contabeis

 ProcLogAtu("INICIO")
  
//Gestao - Selecao de filiais    
// aSelFil	:= {}
// If mv_par02 == 1 .And. Len( aSelFil ) <= 0 
 aSelFil := AdmGetFil(.F.,.T.,"QZA")
 If Len( aSelFil ) <= 0
 	Aviso("Aviso","Nenhuma Filial Selecionada",{"Ok"},,) 
	Return
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
	
		cFilAnt:=aFilsCalc[nForFilial]  
	    
	    cMensLog := "Processando Aglutinacao do estoque - Filial : "+cFilAnt
	
		ProcLogAtu("MENSAGEM",cMensLog,cMensLog) //"Apagando Lançamentos Contabeis do Periodo"
	
		fProced(cFilAnt)             
	
		ProcLogIni( {},"RDCTBPRC") 
		
	Next nForFilial

	// Restaura filial original apos processamento
	cFilAnt:=cFilBack

 EndIf

ProcLogAtu("FIM")

	
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
Static Function fProced(cFilsQry)
//***************************************?
 
 Local aResult := {}
 aResult := TCSPEXEC("STP_AGL_CTB_SD3", cFilsQry)
 
 If Empty(aResult)
	Conout('Erro na execução da Stored Procedure : '+TcSqlError())
	MsgInfo("Procedure Não Executada - Erro - Filial :"+cFilsQry)
 Else
//	 Conout("Retorno String   : "+aResult[1])
//	 Conout("Retorno Numerico : "+str(aResult[2]))
	 MsgInfo("Procedure Executada - Com sucesso - Filial :"+cFilsQry)
	 nFilProc ++
 Endif
   
Return    

//Verifica se o programa esta executando em outra instancia
//*--------------------------------------------*
Static Function cf_ProcInUse(aProgs,cUserRot)
//*--------------------------------------------*
 Local lRet       := .F.
 Local lOk        := .T.
 Local aInfo      := {}
 Local aMonitor   := {}
 Local cString    := ""
 Local cLogged    := ""
 Local nMonitor   := 1
 Local nElem      := 0  
 Local nProgs     := 0     
 Local cCodUser   := RetCodUsr() //Retorna o Codigo do Usuario
 Local cUserName  := UsrRetName( cCodUser )//Retorna o nome do usuario 
// Local aAreaAnt   := GetArea()       

// aMonitor := GetUserInfoArray()

IF !LockByName("RDCTBPRC_"+cFilant)
    	lRet := .T.
ENDIF
 
// RESTAREA(aAreaAnt)  
   
Return(lRet)          
