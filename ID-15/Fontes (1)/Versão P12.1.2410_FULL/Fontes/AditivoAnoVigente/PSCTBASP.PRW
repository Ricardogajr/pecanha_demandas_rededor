#INCLUDE "PROTHEUS.CH"

#DEFINE STR0001 " Parametros"
#DEFINE STR0002 " Lancamentos Contabeis Off-Line"
#DEFINE STR0003 " Este programa tem como objetivo gerar automaticamente os"
#DEFINE STR0004 " lancamentos contabeis dos movimentos de Solicitacao de pagamento."
#DEFINE STR0005 "    ATENCAO: A visualizacao do lancamentos por Nota Fiscal   "
#DEFINE STR0006 " tera uma grande interferencia manual.  "
#DEFINE STR0007 " Solicitacao de Pagamento"
#DEFINE STR0008 " Contabilizando"
#DEFINE STR0009
#DEFINE STR0010 "Executando processo de otimizacao com query"
#DEFINE STR0011 "Executando query"
#DEFINE STR0012
#DEFINE STR0013
#DEFINE STR0014 "Data de"
#DEFINE STR0015
#DEFINE STR0016 "Contabilizando..."
#DEFINE STR0017 "O processamento Multithread esta disponivel apenas para processamento por documento, o processamento sera feito sem multithread. Concorda com operacao?"
#DEFINE STR0018 "Atencao"
#DEFINE STR0019 "O processamento Multithread esta disponivel apenas para processamento sem aglutinacao, o processamento sera feito sem multithread. Concorda com operacao?" 		
#DEFINE STR0020 "O processamento sera feito sem multithread. Concorda com operacao?"
#DEFINE STR0022 " Erro no processamento do pedido de compra: "
#DEFINE STR0023 " Erro no processamento de nota fiscal de entrada: "
#DEFINE STR0024 " Erro no processamento do nota fiscal de devolucao: "	
#DEFINE STR0025 " Erro na inicializacao do processo"
#DEFINE STR0026 " Erro no processo de contabilizacao"			
#DEFINE STR0027 " processo numero "
#DEFINE STR0028 "Erro no Processamento"
#DEFINE STR0029 "Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"

        
#DEFINE OPT_SELECT 1
#DEFINE OPT_FROM   2
#DEFINE OPT_WHERE  3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao do array para controle do processamento MultThread³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 	  	2
#DEFINE QTD_REGISTROS		3
#DEFINE VAR_STATUS			4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag de processamento escrito no arquivo de controle ³
//³de threads                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PSCTBASP   ³Autor  ³ Thiago Góes        ³ Data ³01.1006.2021 ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de processamento da contabilizacao off-line dos Docu- ³±±
±±³          ³mentos de Entrada.                                           ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Parametros da rotina                                  ³±±
±±³          ³       Quando informado nao existe a necessidade de interface³±±
±±³          ³       com o usuario. Pode ser colocado como um servico do   ³±±
±±³          ³       sistema.                                              ³±±
±±³          ³                                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³entrada com base nas regras dos lancamentos padronizados.    ³±±
±±³          ³                                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/COM/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PSCTBASP(aPergunte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis locais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSays    := {}
Local aButtons := {}
Local nOpcA    := 0
Local nX       := 0
Local nOpcABkp := 0
Local cPerg    := "CTBNFE"
Local cMvPar   := ""
Local cString  := ""
Local lAuto    := aPergunte<>Nil
Local oRegua   := Nil 
Local nNumProc := " "

nNumProc := GetMv("MV_CNFETHR", .F., 1 )

if !U_VALSIMP()
	Return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis Private                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina   := { { "Parametros" ,"AllwaysTrue", 0 , 3} }  //"Parametros"
Private cCadastro := "Lancamentos Contabeis Off-Line"  //"Lan‡amentos Contabeis Off-Line"
Private INCLUI    := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desliga Refresh no Lock do Top                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
///
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao           ³
//³ mv_par02 - Aglutina Lancamentos         ?  Sim Nao           ³
//³ mv_par03 - Gerar Lancamentos Por        ?  Doc Periodo Dia   ³
//³ mv_par04 - Data Inicial                                      ³
//³ mv_par05 - Data Final                                        ³
//³ mv_par06 - Da Filial                                         ³
//³ mv_par07 - At‚ a Filial                                      ³
//³ mv_par08 - Contabilizar notas de credito? Sim Nao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da inteface de processamento                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

If Empty(aPergunte)
	If !IsBlind()
		Pergunte(cPerg,.F.)
		aadd(aSays,STR0003) //"   Este programa tem como objetivo gerar automaticamente os"
		aadd(aSays,STR0004) //"lan‡amentos cont beis dos movimentos de saida."
		aadd(aSays,STR0005) //"   ATEN€AO: A visualiza‡„o do lan‡amentos por Nota Fiscal   "
		aadd(aSays,STR0006) //"ter  uma grande interferˆncia manual.                       "

		aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		aadd(aButtons, { 1,.T.,{|| nOpcA:= 1, FechaBatch() }} )
		aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )		
		FormBatch( cCadastro, aSays, aButtons )		
	Else
		Pergunte(cPerg,.F.)
		nOpcA := 1
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializacao do processamento automatico                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut("-",80)
	ConOut(STR0002+" - "+STR0007,80) //"Lan‡amentos Contabeis Off-Line"###"Documento de Entrada"
	ConOut("")
	ConOut(STR0001) //"Parametros"
	ConOut("")	
	nOpcA := 1
	Pergunte(cPerg,.F.)
	ConOut("")
	ConOut("-",80)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CTBVALOK - Ponto de Entrada para validar o Processamento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTBVALOK")
	nOpcABkp := ExecBlock("CTBVALOK",.F.,.F.,{nOpcA,mv_par04,mv_par05,mv_par06,mv_par07})
	If Valtype(nOpcABkp) == "N"
		nOpcA := nOpcABkp
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÊ
//³Validacao para multthread.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÊ
nNumProc:= IIF(nNumProc < 1 , 1, nNumProc) 

If nNumProc > 1 .And. nOpcA == 1
	If CtbValMult(.T.,MV_PAR02 == 1,MV_PAR01 == 1,MV_PAR03 ) 
		nOpcA := 1
	Else
		nOpcA := 0
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nOpcA == 1
	If CanProcItvl(mv_par04, mv_par05,mv_par06,mv_par07,"PSCTBASP")
		Do Case
		Case IsBlind() .And. !lAuto
			BatchProcess( 	cCadastro, 	STR0003 + Chr(13) + Chr(10) +;
				STR0004 + Chr(13) + Chr(10) +;
				STR0005 + Chr(13) + Chr(10) +;
				STR0006, "PSCTBASP",;
				{ ||	MaPSCTBASP(MV_PAR01==1,MV_PAR02==1,MV_PAR03,MV_PAR04,;
				MV_PAR05,MV_PAR06,MV_PAR07,If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),Nil,.F.) },{ || .F. })
		Case nNumProc > 1 .And. !lAuto .And. CtbValMult(.F.,MV_PAR02 == 1, MV_PAR01 == 1, MV_PAR03 )
			MsgRun( STR0016,, {|| PSCTBASPMult(mv_par04,mv_par05,mv_par06,mv_par07,If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),nNumProc) } ) //"Contabilizando..."
		Case !lAuto
			oRegua := MsNewProcess():New({|lEnd| MaPSCTBASP(MV_PAR01==1,;
				MV_PAR02==1,;
				MV_PAR03,;
				MV_PAR04,;
				MV_PAR05,;
				MV_PAR06,;
				MV_PAR07,;
				If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),;
				oRegua,;
				@lEnd) },STR0002,"",.T.)//"Lan‡amentos Contabeis Off-Line"
			oRegua:Activate()
		OtherWise
			MaPSCTBASP(MV_PAR01==1,;
				MV_PAR02==1,;
				MV_PAR03,;
				MV_PAR04,;
				MV_PAR05,;
				MV_PAR06,;
				MV_PAR07,;
				If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),;
				Nil,;
				.F.)
			ConOut("Finished: "+Time())					
		EndCase                           
	EndIf
	FreeProcItvl("PSCTBASP")
EndIf

// Inicializa as variaveis staticas da contabilizacao
ClearCx105()

Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaPSCTBASP  ³Autor  ³ Eduardo Riera         ³ Data ³20.10.2001 ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de contabilizacao dos documentos de entrada off-line  ³±±
±±³          ³                                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Mostra Lancamento Contabil                            ³±±
±±³          ³ExpL2: Aglutina lancamentos contabeis                        ³±±
±±³          ³ExpN3: Contabilizar por:                                     ³±±
±±³          ³       [1] Documento de Saida                                ³±±
±±³          ³       [2] Periodo                                           ³±±
±±³          ³ExpD4: Data de emissao inicial                               ³±±
±±³          ³ExpD5: Data de emissao final                                 ³±±
±±³          ³ExpC6: Codigo da filial inicial                              ³±±
±±³          ³ExpC7: Codigo da filial final                                ³±±
±±³          ³ExpO8: Objeto da interface                              (OPC)³±±
±±³          ³ExpL9: Flag de cancelamento da rotina                        ³±±
±±³          ³PARAMETROS PARA PROCESSAMENTO MULTITHREAD                    ³±±
±±³          ³ExpL10: Flag para processamento de Pedido                     ³±±
±±³          ³ExpL11: Flag para processamento de Nota Fiscal                ³±±
±±³          ³ExpL12: Pedido a ser Processado                               ³±±
±±³          ³ExpL13: Nota Fiscal a ser processada                         ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³entrada com base nas regras dos lancamentos padronizados.    ³±±
±±³          ³                                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/COM/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaPSCTBASP(lDigita,lAglutina,nTpCtb,dDataIni,dDataFim,cFilDe,cFilAte,lContNCC,oObj,lEnd,lContPed,lContNFE,lMulti,cCodIni,cCodFim,lDevolucao)
Local aArea      := GetArea()
Local aStruSF1   := {}
Local aStruSD1   := {}
Local aStruSB1   := {}
Local aStruSF4   := {}
Local aStruSA1   := {}
Local aStruSA2   := {}
Local aStruSC7   := {}
Local aCT5       := {}
Local aOptimize  := {}
Local aFilUser   := {}
Local dSavBase   := dDataBase
Local dDataProc  := Ctod("")
Local lCtNfsDt   := ExistBlock("CTNFEDT")
Local lFilSf1    := Existblock("CTNFEFIL")
Local lLctPadSp1  := VerPadrao("SP1")	// Devolucao de Vendas 		  - SD1
Local lLctPad    := .F.
Local lDetProva  := .F.
Local lHeader    := .F.
Local lContinua  := .T.
Local lValido    := .F.
Local lInterface := oObj<>Nil
Local lOptimize  := .F.
Local lSkipSF1   := .F.
Local lFirst     := .F.
Local lRetPE     := .F.
Local lCTNFEORD  := .T.
Local lD1Cancel  := SD1->(FieldPos("D1_CANCEL")) > 0
Local cLoteCtb   := ""
Local cArqCtb    := ""
Local cAliasSD1  := "SD1"
Local cAliasSB1  := "SB1"
Local cAliasSF4  := "SF4"
Local cAliasSA1  := "SA1"
Local cAliasSA2  := "SA2"
Local cAliasSC7  := "SC7"
Local cAliasSF1  := "SF1"
Local cAliasBkp  := ""
Local cFornece   := ""
Local cLoja      := ""
Local cDocumento := ""
Local cSerie     := ""
Local cTipoNf    := ""
Local cSP1       := Nil
Local dDtDigit   
Local dDtEmissao
Local cQuery     := ""
Local cQueryOrd  := ""
Local cString    := ""
Local cKeySF1    := "F1_FILIAL+DTOS(F1_DTDIGIT)+F1_SERIE+F1_DOC+F1_FORNECE+F1_LOJA+F1_TIPO"
Local cKeySC7    := "C7_FILIAL+DTOS(C7_EMISSAO)+C7_NUM"
Local cArqSF1    := ""
Local cArqSC7    := ""
Local cPedido    := ""
Local cDataCtb	 := "F1_DTDIGIT"
Local cKey       := ""
Local nHdlPrv    := 0
Local nTotalCtb  := 0
Local nParcCtb	 := 0
Local nOrdSF1    := 0
Local nRecSF1    := 0
Local nOrdSC7    := 0
Local nRecSC7    := 0
Local nX         := 0
Local nY         := 0
Local nCar       := 0

Local aFlagCTB   := {}
Local lUsaFlag   := GetNewPar("MV_CTBFLAG",.F.)
Local lOptNFe    := GetNewPar("MV_OPTNFE",.F.)
Local cCTBPais   := GetNewPar("MV_CTBPAIS","CHI,MEX")

//Variaveis para gravacao do código de correlativo
Local aDiario    := {}
Local lSeqCorr   := UsaSeqCor("SF1/SF2/SC7")

Local lTemMov    := .F.
Local lExecLP    := .F.
Local cD1_TEC    := ""
Local aSM0       := AdmAbreSM0()
Local nContFil   := 0
Local __cFilAnt  := cFilAnt
Local lCTNFEORD	 :=ExistBlock("CTNFEORD")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa parametros DEFAULT                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lDigita    := .F.
DEFAULT lAglutina  := .F.
DEFAULT nTpCtb     := 1
DEFAULT dDataIni   := FirstDay(dDataBase)
DEFAULT dDataFim   := LastDay(dDataBase)
DEFAULT cFilDe     := cFilAnt
DEFAULT cFilAte    := cFilAnt  
DEFAULT lContNCC   := .T.
DEFAULT lEnd       := .F.
DEFAULT lContPed   := .T.
DEFAULT lContNFE   := .T.
DEFAULT lMulti     := .F.
DEFAULT cCodIni    := ""
DEFAULT cCodFim    := ""
DEFAULT lDevolucao := .F.

If !CtbInUse()				/// SIGACON NaO FAZ A MARCAcaO DOS FLAGS DE CONTABILIZACAO
	lUsaFlag := .F.			/// MANTEM A MARCACAO DOS FLAGS PELA ROTINA DE CONTABILIZAcaO
Endif

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compatibilizacao dos lancamentos contabeis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lLctPad  := lLctPadSP1 
lContinua := lLctPad

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da primeira regua por filiais                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInterface
	oObj:SetRegua1(Len(aSM0))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as Filiais do usuario corrente  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFilUser := MatFilCalc(.f.,,,,,,.T.)


//Verifica se é devolucao e multithread
lDevolucao := lDevolucao .And. lMulti

For nContFil := 1 to Len(aSM0)
	
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	
	If !lContinua
		Exit
	EndIf 
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	If aScan(aFilUser,{|x| ALLTRIM(x[2]) ==  ALLTRIM(cFilAnt)}) >0 .Or. !lInterface
		aCT5    := {}
		cSP1    := Nil	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a regua de processamento de filiais                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lInterface
			oObj:IncRegua1(STR0008+": "+aSM0[nContFil][SM0_CODFIL]+"/"+aSM0[nContFil][SM0_NOMRED]) //"Contabilizando"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabilizando do documento de entrada                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lContNFE
			For nY := 1 To 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processa os documentos de entrada da filial corrente         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF1")
				dbSetOrder(1)
				dbSelectArea("SD1")
				dbSetOrder(1)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o parametro de otimizacao                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOptNFe
					lOptimize := .T.
				EndIf
				
				//Se for devolucao evita o primeiro loop
				If lDevolucao .And. nY == 1
					Loop
				EndIf

				//Se for devolucao nao deve sair do loop
				If lMulti .And. nY == 2 .And. !lDevolucao
					Exit
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Demonstra regua de processamento da query                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInterface
					If lOptimize
						oObj:IncRegua2(STR0010) //"Executando processo de otimizacao com query"
					Else
						oObj:IncRegua2(STR0011) //"Executando query"
					EndIf
				EndIf				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem do Array de otimizacao de Query                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aOptimize := {}					
				aadd(aOptimize,{}) //SELECT
				aadd(aOptimize,{}) //FROM
				aadd(aOptimize,{})	//WHERE

				If lOptimize
					cAliasSF1 := "PSCTBASP"
					cAliasSD1 := "PSCTBASP"
					cAliasSB1 := "PSCTBASP"
					cAliasSF4 := "PSCTBASP"
					cAliasSA1 := "PSCTBASP"
					cAliasSA2 := "PSCTBASP"
				Else
					cAliasSF1 := "QRYSD1"
					cAliasSD1 := "QRYSD1"
					cAliasSB1 := "QRYSD1"
					cAliasSF4 := "QRYSD1"
					cAliasSA1 := "QRYSD1"
					cAliasSA2 := "QRYSD1"
				EndIf

				aStruSF1  := SF1->(dbStruct())
				aStruSD1  := SD1->(dbStruct())
				aStruSB1  := SB1->(dbStruct())
				aStruSF4  := SF4->(dbStruct())
				aStruSA1  := SA1->(dbStruct())
				aStruSA2  := SA2->(dbStruct())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao select                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aStruSF1)
					If !"F1_BASE"$aStruSF1[nX][1] .and. !"F1_BASI"$aStruSF1[nX][1]
						aadd(aOptimize[OPT_SELECT],aStruSF1[nX])
					EndIf
				Next nX
				For nX := 1 To Len(aStruSD1)
					If !"D1_BASE"$aStruSD1[nX][1] .and. !"D1_BASI"$aStruSD1[nX][1] .and. !"D1_ALQI"$aStruSD1[nX][1] .And. !"D1_CP"$aStruSD1[nX][1]
						aadd(aOptimize[OPT_SELECT],aStruSD1[nX])
					EndIf
				Next nX 

				If lOptimize
					If nY == 1
						For nX := 1 To Len(aStruSA2)
							If aStruSA2[nX][1]$"A2_FILIAL,A2_COD,A2_LOJA,A2_CONTA,A2_NOME,A2_NREDUZ"
								aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
							EndIf
						Next nX
					Else
						For nX := 1 To Len(aStruSA1)
							If aStruSA1[nX][1]$"A1_FILIAL,A1_COD,A1_LOJA,A1_CONTA,A1_NOME,A1_NREDUZ"
								aadd(aOptimize[OPT_SELECT],aStruSA1[nX])
							EndIf
						Next nX					
					EndIf
					For nX := 1 To Len(aStruSB1)
						If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_CONTA"
							aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
						EndIf
					Next nX
					For nX := 1 To Len(aStruSF4)
						If aStruSF4[nX][1]$"F4_FILIAL,F4_CODIGO,F4_CF"
							aadd(aOptimize[OPT_SELECT],aStruSF4[nX])
						EndIf
					Next nX
				EndIf				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao from                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aOptimize[OPT_FROM],{RetSqlName("SF1"),"SF1"})
				aadd(aOptimize[OPT_FROM],{RetSqlName("SD1"),"SD1"})
				aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
				aadd(aOptimize[OPT_FROM],{RetSqlName("SF4"),"SF4"})
				If nY == 1
					aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})
				Else
					aadd(aOptimize[OPT_FROM],{RetSqlName("SA1"),"SA1"})					
				EndIf
					aadd(aOptimize[OPT_FROM],{RetSqlName("SC7"),"SC7"})
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao where                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aOptimize[OPT_WHERE] := "SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
				aOptimize[OPT_WHERE] += "SF1."+cDataCtb+" >= '"+Dtos(dDataIni)+"' AND "
				aOptimize[OPT_WHERE] += "SF1."+cDataCtb+" <= '"+Dtos(dDataFim)+"' AND "
				If lMulti .And. !Empty(cCodIni) .And. !Empty(cCodFim)
					aOptimize[OPT_WHERE] += "SF1.F1_DOC BETWEEN '" + cCodIni + "' AND '" + cCodFim + "' AND "
				EndIf
				aOptimize[OPT_WHERE] += "SF1.F1_DTLANC = '"+Dtos(Ctod(""))+"' AND "
				aOptimize[OPT_WHERE] += "SF1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
				aOptimize[OPT_WHERE] += "SD1.D1_DOC = SF1.F1_DOC AND "
				aOptimize[OPT_WHERE] += "SD1.D1_SERIE = SF1.F1_SERIE AND "
				aOptimize[OPT_WHERE] += "SD1.D1_FORNECE = SF1.F1_FORNECE AND "
				aOptimize[OPT_WHERE] += "SD1.D1_LOJA = SF1.F1_LOJA AND "
				aOptimize[OPT_WHERE] += "SD1.D1_TIPO = SF1.F1_TIPO AND "
				aOptimize[OPT_WHERE] += "SD1.D1_TES <> '"+Space(Len(SD1->D1_TES))+"' AND "
				aOptimize[OPT_WHERE] += "SD1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "(SD1.D1_ORIGLAN<>'LF' OR SF1.F1_IMPORT='S') AND "
				aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
				aOptimize[OPT_WHERE] += "SB1.B1_COD=SD1.D1_COD AND "
				aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
				aOptimize[OPT_WHERE] += "SF4.F4_CODIGO=SD1.D1_TES AND "	
				aOptimize[OPT_WHERE] += "SF4.D_E_L_E_T_=' ' AND "
				If nY == 1
					aOptimize[OPT_WHERE] += "SA2.A2_FILIAL='"+xFilial("SA2")+"' AND "
					aOptimize[OPT_WHERE] += "SA2.A2_COD = SF1.F1_FORNECE AND "
					aOptimize[OPT_WHERE] += "SA2.A2_LOJA = SF1.F1_LOJA AND "
					aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' AND "
					aOptimize[OPT_WHERE] += "SF1.F1_TIPO NOT IN('D','B') "
				Else
					aOptimize[OPT_WHERE] += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
					aOptimize[OPT_WHERE] += "SA1.A1_COD = SF1.F1_FORNECE AND "
					aOptimize[OPT_WHERE] += "SA1.A1_LOJA = SF1.F1_LOJA AND "
					aOptimize[OPT_WHERE] += "SA1.D_E_L_E_T_=' ' AND "
					aOptimize[OPT_WHERE] += "SF1.F1_TIPO IN('D','B') "
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da Query                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				cString := ""
				For nX := 1 To Len(aOptimize[OPT_SELECT])
					cString += ","+aOptimize[OPT_SELECT][nX][1]
				Next nX
				If lOptimize
					cQuery := "SELECT SF1.R_E_C_N_O_ SF1RECNO,"
					cQuery += "SD1.R_E_C_N_O_ SD1RECNO"+cString
				Else
					cQuery := "SELECT SF1.R_E_C_N_O_ SF1RECNO,"
					If nY == 1
						cQuery += "SA2.R_E_C_N_O_ SA2RECNO,"
					Else
						cQuery += "SA1.R_E_C_N_O_ SA1RECNO,"						
					EndIf
					cQuery += "SF4.R_E_C_N_O_ SF4RECNO,"
					cQuery += "SD1.R_E_C_N_O_ SD1RECNO,"
					cQuery += "SB1.R_E_C_N_O_ SB1RECNO"+cString
				EndIf
				cString := ""
				For nX := 1 To Len(aOptimize[OPT_FROM])
					cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
				Next nX
				cQuery += " FROM "+SubStr(cString,2)
				cQuery += " WHERE "+aOptimize[OPT_WHERE]
				cQuery += " AND ( C7_NUM = SD1.D1_PEDIDO AND C7_FORNECE = SD1.D1_FORNECE AND C7_LOJA = SD1.D1_LOJA AND SC7.D_E_L_E_T_ = SF1.D_E_L_E_T_ ) "
				cQuery += " AND C7_XTPSP IN ('2','3') "

				If nTpCtb == 3
					If cPaisLoc<>"PER"
						cQueryOrd := " ORDER BY " + SqlOrder("F1_FILIAL+"+cDataCtb+"+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO")+","+SqlOrder(SD1->(IndexKey()))
					Else
						cQueryOrd := " ORDER BY " + SqlOrder("F1_FILIAL+"+cDataCtb+"+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO")+","+SqlOrder(SD1->(IndexKey()))
					EndIf
				Else  
					If cPaisLoc<>"PER"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Modificar o Ordenacao para que seja igual ao DBF³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lCTNFEORD
							lCTNFEORD := ExecBlock("CTNFEORD",.F.,.F.)
						EndIf 
						If lCTNFEORD
							cQueryOrd := " ORDER BY " + SqlOrder(SF1->(IndexKey()))+","+SqlOrder(SD1->(IndexKey()))
						Else
							cQueryOrd := " ORDER BY F1_FILIAL,F1_DTDIGIT,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA,F1_TIPO"
						EndIf	            
					Else
						If MV_PAR03==1   //Especifico para Peru - tratamento correlativos.
							cQueryOrd:= "ORDER BY "
							cKey := SqlOrder(SF1->(IndexKey()))
							nCar:=AT("F1_DOC",cKey)
							If nCar>0
								cQueryOrd +=Substr(cKey,1,nCar-1)+"F1_DTDIGIT,"+Subs(cKey,nCar,Len(cKey))
							EndIf 

							cKey:=SqlOrder(SD1->(IndexKey())) 
							nCar:=AT("D1_DOC",cKey)
							If nCar>0
								cQueryOrd +=","+Substr(cKey,1,nCar-1)+"D1_DTDIGIT,"+Subs(cKey,nCar,Len(cKey))
							EndIf
						Else
							cQueryOrd := " ORDER BY " + SqlOrder(SF1->(IndexKey()))+","+SqlOrder(SD1->(IndexKey()))            
						EndIf
					EndIf
				EndIf

				cQuery += cQueryOrd
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.T.,.T.)

				For nX := 1 To Len(aOptimize[OPT_SELECT])
					If aOptimize[OPT_SELECT][nX][2]<>"C"
						TcSetField(cAliasSF1,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
					EndIf
				Next nX
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Preparacao da contabilizacao por periodo                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLctPad .And. nTpCtb == 2
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o numero do lote contabil                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SX5")
					dbSetOrder(1)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ No chile contabiliza NCC separada de NF, por isto deve ser   ³
					//³ contabilizado com LOTE DIFERENCIADO.                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		     		If cPaisLoc $ cCTBPais .And. (AllTrim(cModulo) == "FAT") 
						If MsSeek(xFilial("SX5")+"09FAT")
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "FAT "
						EndIf		
					Else
						If MsSeek(xFilial("SX5")+"09SP1")
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "SP1 "
						EndIf		
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa um execblock                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If At(UPPER("EXEC"),X5Descri()) > 0
						cLoteCtb := &(X5Descri())
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa o arquivo de contabilizacao                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					nHdlPrv:=HeadProva(cLoteCtb,"PSCTBASP",Subs(cUsuario,7,6),@cArqCtb)
					IF nHdlPrv <= 0
						HELP(" ",1,"SEM_LANC")
						lContinua := .F.
					Else
						lHeader := .T.
					EndIf		
				EndIf			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da segunda regua por periodo                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInterface
					oObj:SetRegua2(dDataFim+1-dDataIni)
				EndIf
				dDataProc := dDataIni
				dbSelectArea(cAliasSF1)
				While ( !Eof() .And. (cAliasSF1)->F1_FILIAL == xFilial("SF1") .And.;
						&((cAliasSF1)->(cDataCtb)) <= dDataFim .And. lContinua)
		
					lValido   := .T.
					lDetProva := .F.
					lSkipSF1  := .T.
		         	dDtDigit  := &((cAliasSF1)->(cDataCtb))
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a nota nao foi contabilizada                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty((cAliasSF1)->F1_DTLANC)
						If cPaisLoc <> "BRA" .And. !Empty(&((cAliasSF1)->(cDataCtb))) 
			           		If (cPaisLoc $ cCTBPais .And. ((AllTrim(cModulo) $ "COM|EST") .And. Alltrim((cAliasSF1)->F1_TIPO) == "D") .Or. ((AllTrim(cModulo) == "FAT") .And. Alltrim((cAliasSF1)->F1_TIPO) <> "D")) .And. !(Alltrim((cAliasSF1)->D1_ESPECIE) == "NCC") 
							    lValido := .F.
							Else
								If Alltrim((cAliasSF1)->F1_TIPO) == "D"
									lValido := lContNCC //verifica se contabiliza ou nao as notas de credito.
								EndIf							
							EndIf	
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Executa a filtragem da customizacao                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFilSf1
							If !(Execblock("CTNFEFIL",.F.,.F.,{cAliasSF1}))
								lValido := .F.
							EndIf
						EndIf
					Else
						lValido := .F.
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicia a contabilizacao deste documento de saida             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If lValido
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona no Cabecalho do documento de saida                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lOptimize
							SF1->(MsGoto((cAliasSF1)->SF1RECNO))
						Else
							nRecSF1 := (cAliasSF1)->SF1RECNO
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ajusta a data base com a data de contabilizacao              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Do Case
						Case nTpCtb == 1 .Or. nTpCtb == 3 
							dDataBase := &((cAliasSF1)->(cDataCtb))
							If lCtNfsDt
								dDataBase := Execblock("CTNFEDT",.F.,.F.)
							EndIf
						Case nTpCtb == 2
							dDataBase := dDataFim
						EndCase
		
						If lUsaFlag
							aAdd(aFlagCTB,{"F1_DTLANC",dDataBase,"SF1",(cAliasSF1)->SF1RECNO,0,0,0})
						EndIf
						If lSeqCorr
							aAdd(aDiario, {"SF1",(cAliasSF1)->SF1RECNO,(cAliasSF1)->F1_DIACTB,"F1_NODIA","F1_DIACTB"})
						EndIf
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Preparacao da contabilizacao por documento                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Begin Transaction
							If 	!lHeader
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Verifica o numero do lote contabil                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SX5")
								dbSetOrder(1)
								If MsSeek(xFilial("SX5")+"09SP1")
									cLoteCtb := AllTrim(X5Descri())
								Else
									cLoteCtb := "SP1 "
								EndIf		
		                        
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ No chile contabiliza NCC separada de NF, por isto deve ser   ³
								//³ contabilizado com LOTE DIFERENCIADO.                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					     		If cPaisLoc $ cCTBPais .And. (AllTrim(cModulo) == "FAT")
							   		If  (cAliasSF1)->F1_TIPO =="D" 
										SX5->(MsSeek(xFilial("SX5")+"09FAT")) 
										cLoteCtb := AllTrim(X5Descri())
									Else
										cLoteCtb := "FAT "
									EndIf	
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Executa um execblock                                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If At("EXEC",Upper(X5Descri())) > 0
									cLoteCtb := &(X5Descri())
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Inicializa o arquivo de contabilizacao                       ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								nHdlPrv:=HeadProva(cLoteCtb,"PSCTBASP",Subs(cUsuario,7,6),@cArqCtb)
								IF nHdlPrv <= 0
									HELP(" ",1,"SEM_LANC")
									lContinua := .F.
								Else
									lHeader := .T.
								EndIf		
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona registros vinculados ao cabecalho do documento     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSF1)->F1_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								If !lOptimize
									SA1->(MsGoto((cAliasSA1)->SA1RECNO))
								EndIf
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								If !lOptimize
									SA2->(MsGoto((cAliasSA2)->SA2RECNO))
								EndIf
							EndIf
							dbSelectArea(cAliasSF1)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Processa os itens do documento de saida                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea(cAliasSF1)
		
							cFornece   := (cAliasSF1)->F1_FORNECE
							cLoja      := (cAliasSF1)->F1_LOJA
							cDocumento := (cAliasSF1)->F1_DOC
							cSerie     := (cAliasSF1)->F1_SERIE
							cTipoNf    := (cAliasSF1)->F1_TIPO
							lValido    := .F.
							lFirst     := .T.
							lTemMov    := .F.
							lExecLP    := .F.
		
							While ( !Eof() .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") .And.;
									(cAliasSD1)->D1_DOC == cDocumento .And.;
									(cAliasSD1)->D1_SERIE == cSerie .And.;
									(cAliasSD1)->D1_FORNECE == cFornece .And.;
									(cAliasSD1)->D1_LOJA == cLoja )
		
								If 	( (cAliasSD1)->D1_ORIGLAN <> "LF" .Or. (cAliasSF1)->F1_IMPORT=="S" ) .And. ;
										!Empty((cAliasSD1)->D1_TES) .And. ;
										(cAliasSD1)->D1_TIPO==cTipoNf .And. ;
										IIf(lD1Cancel,(cAliasSD1)->D1_CANCEL<>"S",.T.)
		
									lValido := .T.
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Posiciona registros vinculados ao item do documento          ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("SB1")
									dbSetOrder(1)
									If !lOptimize
										SB1->(MsGoto((cAliasSB1)->SB1RECNO))
									EndIf
		
									dbSelectArea("SF4")
									dbSetOrder(1)
									If !lOptimize
										SF4->(MsGoto((cAliasSF4)->SF4RECNO))
									EndIf
									
									If !lOptimize
										dbSelectArea("SD1")
										dbSetOrder(1)
										MsGoTo((cAliasSD1)->(SD1RECNO))
									EndIf							
		                                         
				                    lTemMov := .T.
		                     
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executando os LP 660, 642 e 950 nesse momento, os lancamentos nao ficarao na mesma ordem ³
									//³ da contabilizacao On-Line, pois o parametro MV_OPTNFE esta .T.. Assim, ficara na ordem   ³
									//³ que a query gerar.   																							³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                      
									If lFirst
										lFirst   := .F.
										cD1_TEC := (cAliasSD1)->D1_TEC
										If lOptimize
											ExecLP( lOptimize,lLctPad60,lHeader,cAliasSF1,@c660,cAliasSD1,@lDetProva,@nTotalCTB,;
													  nHdlPrv,cLoteCTB,@aCT5,@aFlagCTB,lLctPad42,@c642,lLctPad95,@c950,cTipoNF,cD1_TEC )
											lExecLP := .T.
										EndIf	        
									EndIf	       
			                  
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executa os lancamentos contabeis ( 650 ) - Item              ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cSP1       	:= CtRelation("SP1",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"PSCTBASP"}})
									lDetProva 	:= .T.
									nTotalCtb 	+= DetProva(nHdlPrv,"SP1","PSCTBASP",cLoteCtb,,,,,@cSP1,@aCT5,,@aFlagCTB)
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Processa lancamentos do rateio do item do documento - SDE    ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If (cAliasSD1)->D1_RATEIO=="1"
										dbSelectArea("SDE")
										dbSetOrder(1)
										MsSeek(xFilial("SDE")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM)
		
										While !Eof() .And. SDE->DE_FILIAL == xFilial("SDE") .And.;
												SDE->DE_DOC == (cAliasSD1)->D1_DOC .And.;
												SDE->DE_SERIE == (cAliasSD1)->D1_SERIE .And.;
												SDE->DE_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
												SDE->DE_LOJA == (cAliasSD1)->D1_LOJA .And.;
												SDE->DE_ITEMNF == (cAliasSD1)->D1_ITEM
		
											If lLctPad51 .And. lHeader
												If !lOptimize
													dbSelectArea("SDE")
												EndIf
												c651      := CtRelation("651",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"PSCTBASP"}})
												lDetProva := .T.
												nTotalCtb += DetProva(nHdlPrv,"651","PSCTBASP",cLoteCtb,,,,,@c651,@aCT5,,@aFlagCTB)
											EndIf
		
											dbSelectArea("SDE")
											dbSkip()                  
										EndDo								
									EndIf							
								EndIf
		
								dbSelectArea(cAliasSD1)
								dbSkip()
								lSkipSF1 := .F.
							EndDo
							
						
							If Len(aFlagCtb) > 0 .And. aFlagCtb[Len(aFlagCTB),5] == 0 .And. aFlagCtb[Len(aFlagCTB),6] == 0 .And.;
							aFlagCtb[Len(aFlagCTB),7] == 0
								aDel (aFlagCTB,Len(aFlagCTB))
								aSize(aFlagCTB,Len(aFlagCTB)-1)								
							EndIf                             
		
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lOptimize
								SF1->(MsGoto(nRecSF1))
							EndIf
						
							If lDetProva .And. lHeader .And. nTotalCtb > 0
								If !lUsaFlag
									RecLock("SF1")
									SF1->F1_DTLANC := dDataBase
									MsUnlock()
								EndIf
							EndIf
						End Transaction
						If nTpCtb == 1 .And. lHeader
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Fecha os lancamentos contabeis                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lHeader   := .F.
							RodaProva(nHdlPrv,nTotalCtb)
							If nTotalCtb > 0
								nTotalCtb := 0
								cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
								aDiario := {}
							EndIf
						EndIf
					EndIf
					If lSkipSF1 
						dbSelectArea(cAliasSF1)
						dbSkip()
					Else
						dbSelectArea(cAliasSF1)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza a regua de processamento por periodo                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If dDataProc<> &((cAliasSF1)->(cDataCtb))
						While dDataProc<=&((cAliasSF1)->(cDataCtb))
							If lInterface
								oObj:IncRegua2(STR0014+": "+Dtoc(&((cAliasSF1)->(cDataCtb)))) //"Documento de"
							Endif
							dDataProc++
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a contabilizacao foi abortada                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lEnd
						Exit
					EndIf
		
					If nTpCtb == 3 .And. &((cAliasSF1)->(cDataCtb)) <> dDtDigit
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Fecha os lancamentos contabeis                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lHeader   := .F.
						RodaProva(nHdlPrv,nTotalCtb)
						If nTotalCtb > 0
							nTotalCtb := 0			
							cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
						EndIf
					EndIf						
				EndDo
				
				If nTpCtb == 2 .And. lHeader
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0			
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
					EndIf
				EndIf						
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna a situacao inicial                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasSF1)
				dbCloseArea()
				If !lOptimize
					ChkFile("SD1")
				Else
					dbSelectArea("SD1")
				EndIf
			Next nY
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o arquivo e compartilhado para encerrar a contab.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(FWFilial("SF1"))
			Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a contabilizacao foi abortada                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndIf
	If lEnd
		Exit
	EndIf
Next nContFil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da Rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
cFilAnt := __cFilAnt
dDataBase := dSavBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua lancamentos contabeis do Remito                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	LocBlock("C230A",.F.,.F.)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³PSCTBASPMultºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Contabilizacao MultiThread de pedido de venda e NFE        º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PSCTBASPMult(dDataIni,dDataFim,cFilDe,cFilAte,lContNCC,nNumProc)
Local aArea 	  := GetArea()
Local aSM0 		  := AdmAbreSM0()
Local nContFil	  := 0
Local cFilIni	  := cFilAnt 
Local nX		  := 0  
Local lRet		  := .T.

For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	cFilAnt := aSM0[nContFil][SM0_CODFIL] 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")

	If lRet 
		For nX := 1 to 2
			//Contabilizacao de Nota Fiscal de Entrada
			lRet := CtbMComNFE(dDataIni,dDataFim,lContNCC,nNumProc , nX == 2)
		Next nX
		If !lRet
			Exit
		EndIf 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

Next nContFil

cFilAnt := cFilIni
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³CtbMComNFEºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³Contabilizacao da nota fiscal de entrada                    º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMComNFE(dDataIni,dDataFim,lContNCC,nNumProc,lDevolucao)
Local aArea := GetArea()
Local lRet	:= .T.
Local nX	:= 0
Local aProcs 		:= {}
Local aNfeMult	:= {}
Local nTotalReg	:= 0
Local cRaizNome	:= 'PSCTBASPPROC'
Local cChave 	    := SF1->(IndexKey(1))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNfeMult := CtbGrvNFE(dDataIni,dDataFim,lDevolucao,cChave)

nTotalReg := Len(aNfeMult)

If nTotalReg > 0
	
	If nNumProc > 40
		nNumProc := 40
	Endif
	
	If  nTotalReg >= nNumProc .And. nNumProc > 1 // MultiThread
		aProcs := CTBPrepNFE(nNumProc,nTotalReg,cRaizNome,aNfeMult)
		//Inicializa as Threads Transacao controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("JOBPSCTBASP", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],lContNCC,dDataIni,dDataFim,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,aProcs[nX][5],aProcs[nX][6],lDevolucao)
			Sleep(3000)
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o controle das Threads³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(3000)
		lRet := NFEMonitor(aProcs,IIF(lDevolucao,2,1) )
	Else
		lRet := CtbProcNFE(lContNCC,dDataIni,dDataFim,"","",lDevolucao)
	EndIf
EndIf

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³CtbGrvNFE  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³Grava arquivo temporario das notas fiscais de entrada       º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvNFE(dDataIni,dDataFim,lDevolucao,cChave)

Local cQuery		:= ""
Local cDataCtb	:= "F1_DTDIGIT"
Local cAliasSF1	:= GetNextAlias()
Local aNotas		:= {}
Local aArea		:= GetArea()


cQuery := "SELECT SF1.F1_DOC "
cQuery += "FROM "
cQuery += 		 RetSqlName("SF1")	+ " SF1 "
cQuery += "WHERE "
cQuery += 		"SF1.F1_FILIAL = '" + xFilial("SF1")+"' AND "
cQuery +=		"SF1."+cDataCtb+" >= '"+Dtos(dDataIni)+"' AND "
cQuery +=		"SF1."+cDataCtb+" <= '"+Dtos(dDataFim)+"' AND "
cQuery +=		"SF1.F1_DTLANC   = '"+Dtos(Ctod(""))+"' AND "
If !lDevolucao
	cQuery  += "SF1.F1_TIPO NOT IN('D','B') AND "
Else
	cQuery  += "SF1.F1_TIPO IN('D','B') AND "
EndIf
cQuery += "SF1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery)

If Select(cAliasSF1) > 0
	dbSelectArea(cAliasSF1)
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.F.,.T.)

// Carrega Array aNotas
While (cAliasSF1)->(!Eof())
	aAdd(aNotas,(cAliasSF1)->F1_DOC)
	(cAliasSF1)->(dbSkip())
EndDo

If Select(cAliasSF1) > 0
	dbSelectArea(cAliasSF1)
	dbCloseArea()
EndIf

RestArea(aArea)

Return aNotas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³JOBPSCTBASP  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Job da contabilizacao da Nota Fiscal de Entrada            º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function JOBPSCTBASP(cEmpX,cFilX,cMarca,cFileLck,lContNCC,dDataIni,dDataFim,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cCodIni,cCodFim,lDevolucao)

Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := NFELock(cFileLck)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,,)

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock()

//Set o usuario para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.

__cUserId := cXUserId 
cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

ConOut("Starting: "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := CtbProcNFE(lContNCC,dDataIni,dDataFim,cCodIni,cCodFim,lDevolucao)

JOBNFEEnd(cVarStatus,nHandle,lRet)

ConOut("Finished: "+Time())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³CtbProcNFE ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     Processa a contabilizacao                                    º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbProcNFE(lContNCC,dDataIni,dDataFim,cCodIni,cCodFim,lDevolucao)
Local aArea := GetArea()
Local lRet := .T.

MaPSCTBASP(.F.,.F.,1,dDataIni,dDataFim,xFilial("SF1"),xFilial("SF1"),lContNCC,Nil,.F.,.F.,.T.,.T.,cCodIni,cCodFim,lDevolucao)

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³NFEMonitorºAutor³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Funcao responsavel por monitorar as threads de processamen º±±
±±º          ³ to                                                         º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³                                                            º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NFEMonitor(aProcs,nTipo)
Local lRet			:= .T.
Local nX			:= 0
Local aConcluido	:= {}
Local nHandle		:= 0
Local cMsg			:= ""
Local cRotErro		:= ""
Local cTipoErro		:= ""
Local cMsgErro		:= ""
Local aErros		:= {}

Default nTipo := 1

While .T.
	For nX := 1 to Len(aProcs)
		nHandle := NFELock(aProcs[nX][ARQUIVO])
		If  nHandle >= 0
			fClose(nHandle)
			If aScan(aConcluido,{|aItem| aItem[3] == aProcs[nX][MARCA]} ) == 0
				AADD(aConcluido, { nHandle, aProcs[nX][ARQUIVO], aProcs[nX][MARCA]})
			EndIf
		EndIf
	Next nX
	
	If Len(aConcluido) >= Len(aProcs)
		Exit
	EndIF
	Sleep(5000)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se todas a threads foram processadas corretamente³
//³libera o recurso e apaga o arquivo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aConcluido)
	FT_FUse(aConcluido[nX][2])
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(aConcluido[nX][2])
	If lRet .And. ALLTRIM(cMsg) != OK
		lRet := .F.
	EndIf
Next nX



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quais threads deram erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet       
	Do Case
		Case nTipo == 1 //Pedido de Compra
			cRotErro := STR0022 //" Erro no processamento do pedido de compra: "
		Case nTipo == 2 //Nota Fiscal de Entrada                     
			cRotErro := STR0023//" Erro no processamento de nota fiscal de entrada: "
		Case nTipo == 3 //Nota Fiscal de Devolucao                   	
			cRotErro := STR0024//" Erro no processamento do nota fiscal de devolucao: "	
	EndCase
	
	For nX := 1 to Len(aProcs)
		cStatus := GetGlbValue(aProcs[nX][VAR_STATUS])
		If cStatus != '3' // Concluido com sucesso 
	        Do Case
				Case cStatus == "1" // Erro na Conexao
					cTipoErro := STR0025 //" Erro na inicializacao do processo"
				Case cStatus == "2" // Erro no Processamento
				   	cTipoErro := STR0026 //" Erro no processo de contabilizacao"			
			EndCase
			cMsgErro := cRotErro + cTipoErro + STR0027 + cValTochar(nX) //" processo numero "
			ProcLogAtu("ERRO",STR0028,cMsgErro)//"Erro no Processamento"
			aAdd(aErros,cMsgErro)
		EndIf
	Next nX
EndIf

If !lRet
	If MsgYesNo(STR0029)//"Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"
		CtRConOut(aErros)
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NFEUnLock³ Autor ³Marcos Justo            ³ Data ³ 15/04/10 ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encerra a trava                                             ³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NFEUnLock(nHandle,lOk)
Local cMsg := IIF(lOk,OK,ERRO)
FWRITE(nHandle,cMsg)
FCLOSE(nHandle)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NFELock ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria arquivo para travar processos e garantir que sao unicos³±±
±±aÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄaÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NFELock(cFile)
Local nHJob := 0
If File(cFile)
	nHJob := FOPEN(cFile,2)
Else
	nHJob := FCREATE(cFile)
EndIf
Return nHJob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³CTBPrepNFE  ºAutor³Alvaro Camillo Netoº Data ³  15/04/10    º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³Prepara as informacoes para o processamento multithread     º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBPrepNFE(nNumProc,nTotalReg,cRaizNome,aRegsProc)
Local aProcs 		:= Array(nNumProc)
Local nX		 	:= 0
Local cDirSem  		:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc		:= 0 // Registros a processar
Local nRegJProc		:= 0 // Total de registros ja processados 
Local cVarStatus	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a pasta do semaforo caso nao exista³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o calculos das quantidades de registros³
//³que cada thread ira processar e                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aProcs)
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX)+cValtoChar(INT(Seconds())) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == 1 , 1 , aProcs[nX-1,7]+1 )
	nRegJProc	+= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
	cVarStatus  :="cNFEP"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
	PutGlbValue(cVarStatus,"0")
	GlbUnLock()
	aProcs[nX]	:= {cNomeArq,cMarca,nRegAProc,cVarStatus,aRegsProc[nRegAProc],aRegsProc[nRegJProc],nRegJProc}
Next nX

Return aProcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³CtbValMult ºAutor  ³Alvaro Camillo Netoº Data ³  05/19/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Valida se o processamento sera feito MultiThread           º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbValMult(lMostraHelp,lAglutina,lMostraLanc,nTipo) 
Local lRet 		:= .T. 
Local lBlind    := IsBlind()
Local nHelp		:= 1 
Default lMostraHelp := .F.
Default nTipo 		:= 1
Default lMostraLanc := .F.

If lMostraHelp .And. !lBlind  
	nHelp := 1
Else
	nHelp := 0
EndIf 

If lRet .And. nTipo != 1
	If lMostraHelp .And. !lBlind  
		lRet := MsgYesNo(STR0017,STR0018)//"O processamento Multithread esta disponivel apenas para processamento por documento, o processamento sera feito sem multithread. Concorda com operacao?"##"Atencao"
	Else
		lRet := .F.
	EndIf
EndIf

If lRet .And. lAglutina
	If lMostraHelp .And. !lBlind  
		lRet := MsgYesNo(STR0019,STR0018)//"O processamento Multithread esta disponivel apenas para processamento sem aglutinacao, o processamento sera feito sem multithread. Concorda com operacao?" ##"Atencao"
	Else
		lRet := .F.
	EndIf
EndIf  

If lRet
	lCtbInTran := CTBINTRAN(nHelp,lMostraLanc)
	
	If !lCtbInTran
		If lMostraHelp .And. !lBlind   
			lRet := MsgYesNo(STR0020,STR0018)//"O processamento sera feito sem multithread. Concorda com operacao?" ##"Atencao"
		ElseIf lBlind
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf



Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³JOBFINEnd   ºAutor  ³Microsiga           º Data ³  06/21/10   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³  Finaliza a Thread verificando se ocorrer help (erro)      º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function JOBNFEEnd(cVarStatus,nHandle,lRet)
Local nX	:= 0
Local aLog  := {}
Local cMsg	:= ""
aLog  := GETAUTOGRLOG()

If !Empty(aLog)
	For nX := 1 to Len(aLog)
		cMsg := aLog[nX] 	
	Next
	UserException( "Error PSCTBASP- " + cMsg )	
Else
	// STATUS 3 - Processado com Sucesso
	PutGlbValue(cVarStatus, "3" )
	GlbUnLock()
	NFEUnLock(nHandle,lRet)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³PSCTBASPRATºAutor  ³Anieli Rodrigues    º Data ³  29/05/13   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Contabilizacao offline do rateio do pedido de compras      º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ PSCTBASP	                                                  º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function PSCTBASPRAT(cChave,nParcCtb,nHdlPrv,cLoteCtb)
	Default nParcCtb	:= 0
	Default nHdlPrv		:= 0
	Default cLoteCtb	:= ""

	SCH->(DbSetOrder(1)) //CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM	
	If SCH->(DbSeek(cChave)) 
		While SCH->(!EOF()) .and. cChave == xFilial("SCH")+SCH->CH_PEDIDO+SCH->CH_FORNECE+SCH->CH_LOJA+SCH->CH_ITEMPD
	   		If nHdlPrv > 0
	   			nParcCtb 	:= DetProva(nHdlPrv,"659","MATA120",cLoteCtb)
	   		Else
	   			Exit
	   		EndIf
	   		SCH->(DbSkip())		
        EndDo
    EndIf
Return Nil
