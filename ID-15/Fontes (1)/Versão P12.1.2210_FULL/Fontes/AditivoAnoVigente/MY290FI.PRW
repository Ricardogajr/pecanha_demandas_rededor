#include 'protheus.ch'
#include 'parmtype.ch'


STATIC lF290OWN			:= ExistBlock("F290OWN")
STATIC lF290FPG 		:= ExistBlock("F290FPG")
STATIC lf290CHK 		:= ExistBlock("F290CHK")
STATIC lF290LIBT		:= ExistBlock("F290LIBT")
STATIC lFA290HPAD		:= ExistBlock("FA290HPAD")
STATIC lF290BTIT	  	:= ExistBlock("F290BTIT")
STATIC lF290FORNP		:= EXISTBLOCK("F290FORNP")
STATIC lF290BROW		:= ExistBlock("F290BROW")
STATIC lF290BFIL		:= ExistBlock("F290BFIL")
STATIC lF290PRE			:= ExistBlock("F290PRE")
STATIC lF290Baixa		:= Existblock("F290BAIXA")
STATIC lPEGrava			:= ExistBlock("FI290GE5")
STATIC lF290FIL 		:= ExistBlock("F290FIL")
STATIC lF290CON			:= ExistBlock("F290CON")
STATIC lFA290			:= ExistBlock("FA290")
STATIC lValidCan		:= ExistBlock("FA290OKC")
STATIC lF290CN2			:= ExistBlock("F290CN2")
STATIC lFA290C 			:= ExistBlock("FA290C")
STATIC lF290CAN			:= ExistBlock("F290CAN")
STATIC lFA290OK			:= ExistBlock("FA290OK")
STATIC lF290Tit			:= ExistBlock("F290TIT")
STATIC lFa290TOk		:= Existblock("FA290TOK")
STATIC lF290Val 		:= ExistBlock("F290VAL")
STATIC LFIN290NAT		:= ExistBlock("FIN290NAT")
STATIC lFILEMOT 		:= ExistBlock("FILEMOT")
STATIC lPEMostraTela	:= ExistBlock("FI290MT")
STATIC lFI290Cols		:= ExistBlock("FI290COLS")

Static dLastPcc  := CTOD("22/06/2015")
Static lIsIssBx := FindFunction("IsIssBx")
Static __nIdxE2OK	:= 2

//Gestao
Static lAbatiment := .F.
Static _oFina2901

user function MY290FI(nPosArotina,aFatPag,lAutomato)
	
                                                                                
Local lPanelFin	:= IsPanelFin()
Local xRet	    := ''

Private aRotina	:= MenuDef()
Private cFatura	:= CRIAVAR("E2_FATURA")
Private cForn		:= CriaVar("A2_COD")
Private cLoja		:= CriaVar("A2_LOJA")
Private cPrefix 	:= CRIAVAR("E2_PREFIXO",.T.)
Private dVencto	:= Ctod(Space(8))
Private dDataDe	:= dDataBase
Private dDataAte	:= dDataBase
Private nValor 	:= 0
Private nValorFat	:= 0
Private cNat		:= Space(10)
Private nTotAbat	:= 0
Private nValCruz	:= 0
Private aVlCruz	:= {}
Private aDupl		:= {}
Private nValtot	:= 0
Private aVenc		:= {}
Private nMoeda 	:= 1
Private nIndex 	:= 0
Private cFil290 	:= ""
Private cLote
PRIVATE oFatura 	:= NIL
Private lFocus 	:= .F.
Private oTipo		:= NIL
Private oNat
//Campos usados para amarracao das faturas geradas com o mesmo prefixo, tipo e numera  o, mas para fornecedores e lojas diferentes.

//                                                              
//  Define o cabecalho da tela de baixas								   
//                                                                
Private cCadastro 	:= OemToAnsi("Aglutinacao de Titulos") //"Aglutina  o de Titulos"
Private nMoedaBco		:= 1 // Variavel necessaria para n o ocorrer error.log na funcao fa090Correc()

DEFAULT nPosArotina 	:= 0
DEFAULT aFatPag     	:= {}
DEFAULT lAutomato		:= .F.

Fa290MotBx("FAT","FATURAS   ","ANNS")   

If FunName() <> "FINA750" .And. !lPanelFin .and. Empty(aFatPag)
	dbSelectArea("SE2")
	dbSetOrder(1)
	dbGoTop()
EndIf

//                                                               
//  Carrega a funcao pergunte 					    			  
//                                                                
SetKey (VK_F12,{|a,b| AcessaPerg("AFI290",.T.)})
Pergunte("AFI290",.F.)

//                                                               
//  Ponto de entrada a ser executado antes da browse              
//                                                                
/*IF lF290BROW
	ExecBlock("F290BROW",.f.,.f.)
Endif */

If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
	dbSelectArea("SE2")
	bBlock := &( "{ |a,b,c,d,e| u_fA290Aut(a,b,c,d,e) }" )
	xRet   := Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,aFatPag,lAutomato)
Else
	//                                                               
	//  Endereca a Fun  o de BROWSE											   
	//                                                                
	mBrowse( 6, 1,22,75,"SE2",,,,,,Fa040Legenda("SE2"),,,,,,,,IIF(lF290BFIL,ExecBlock("F290BFIL",.f.,.f.),NIL))
Endif	

Set Key VK_F12 to

//                                                               
//  Recupera a Integridade dos dados									   
//                                                                
dbSelectArea("SE2")
dbSetOrder(1)

Return xRet

/*
                                                                             
                                                                             
                                                                            
   Fun  o	   fA290Aglu  Autor   Paulo Boschetti	      Data   27/07/93    
                                                                            
   Descri  o   Marcacao dos titulos para emissao de fatura				     
                                                                            
   Sintaxe	   Fa290Aglu() 												     
                                                                            
    Uso		   Generico 												     
                                                                            
                                                                             
                                                                             
*/
User Function fA290Aut(cAlias,cCampo,nOpcE,aFatPag,lAutomato)
Local lPanelFin 	:= IsPanelFin()
Local cArquivo
Local nTotal		:= 0
Local nHdlPrv		:= 0
Local lPadrao		:= .F.
Local cPadrao		:= "587"
Local nW 			:= 1
Local dDatCont 	:= dDatabase
//Local cIndex		:= ""
Local nOpca 		:= 2   
Local aBut290 		:= {{"PESQUISA",{||Fa290Pesq(oMark,cAlias)}, "Pesquisar","Pesquisar.."}} //###"Pesquisar" ### "Pesquisar..(CTRL-P)"
Local bSet16 		:= SetKey(16,{||Fa290Pesq(oMark,cAlias)})
Local oValor		:= 0
Local oQtdTit		:= 0
Local oTitAbats	:= 0
Local oValorFat	:= 0
Local cMarca		:= GetMark()
LOCAL aMoedas		:= {}
LOCAL cVar			:= ""
LOCAL aCampos 		:= {}
LOCAL nTamSeq 		:= TamSX3("E5_SEQ")[1]
LOCAL cSequencia 	:= Replicate("0",nTamSeq)
LOCAL nRecSe2 		:= 0
LOCAL cAliasSE2 	:= "SE2"
Local cSetFilter 	:= SE2->(DBFILTER()) // Salva o filtro atual, para restaurar no final da rotina
Local nValTotal 	:= 0
Local lDigita		:= .F.
Local nX			:= 0
Local oDlg
Local oDlg1
Local oDlg2
LOCAL oCbx
Local oTimer
Local nTimeOut  	:= SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione os titulos a faturar
Local nTimeMsg  	:= SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usu rio
                                                      	// informando que a tela fechar  automaticamente em XX minutos
Local aChaveLbn 	:= {}
Local lPccBaixa	:= (cPaisLoc == "BRA") .And. (SuperGetMv( "MV_BX10925" ,.T.,"2") == "1") 

Local nOldPis 		:= 0
Local nOldCof 		:= 0
Local nOldCsl 		:= 0
Local nTotBase		:= 0
Local nTotPis 		:= 0
Local nTotCof 		:= 0
Local nTotCsl 		:= 0
Local nTotISS 		:= 0
Local nTotIRPJ		:= 0
Local nBaseIrf	:= 0
Local nTtIRFat		:= 0
Local aSize 		:= {}
Local oPanel
Local lNumFat   	:= .T.
Local lFatAut   	:= .F.
Local nDecres   	:= 0
Local nVlDesc   	:= 0
Local nSlDesc   	:= 0
Local nAcresc   	:= 0
Local nVlAcre   	:= 0
Local nSlAcre   	:= 0
Local nIndSE2 		:= SE2->(IndexOrd())
Local nRecnoSE2	:= SE2->(Recno())
Local lContab530	:= VerPadrao("530") .And. ( mv_par03 == 1 )
Local lMostraTela	:=.T.
Local cKeyTit		:= ""
Local nPCCRet		:= 0
Local nPisRet		:= 0
Local nCofRet		:= 0
Local nCslRet		:= 0
Local lCalcIssBx 	:= .F.
Local aCps 		:= {}
Local lPaBruto		:= GetNewPar("MV_PABRUTO","2") == "1"  //Indica se o PA ter  o valor dos impostos descontados do seu valor
Local cCond 		:= Space(3) 
Local nFRetISS 	:= ""
Local nTRetISS 	:= ""
Local aISSFat		:= {}
Local nISSFat 		:= 0
Local lCompNdf  := .F.
Local nTamTip   := TamSX3("E2_TIPO")[1]
Local nTamTit	  := TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1]
//Rastreamento
Local lRastro		:= FVerRstFin()
Local aRastroOri	:= {}
Local aRastroDes	:= {}
Local aE2CCC     :={}
Local aE2CCD     :={}
Local aCCUSTO    :={}
Local nI         := 1
//Controle de Contabilizacao
Local aFlagCTB		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
//IRPF na baixa
Local lIRPFBaixa	:= .F.
LOCAL lBaseIRPF	:= .F.
Local nTotIRF		:= 0
Local nPropIR		:= 1
Local lUsaBaseIr	:= .F.
Local cHistFat		:= ""
Local lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)		//Controle de validacao de documentos obrigatorios
Local lAWB			:= Left(FunName(),7) == 'TMSA920' //Geracao de Titulos AWB
Local nMoedaC 	 	:= 1
Local aArea 	 	:= {}
Local cCampoAbat := "Abatmts"
Local cCampoSel		:= ""
Local cTituloSel	:= ""
Local cPictSel		:= ""
//Local nJuros	 	:= 0
Local aPcc		 	:= Array(4)
Local nSalTit 		:= 0

//Gestao
Local aSelFil		:= {}
Local aTmpFil		:= {}
Local cTmpSE2Fil 	:= ""
Local lGestao    	:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local lSE2Compart	:= Iif( lGestao, FWModeAccess("SE2",1) == "C", FWModeAccess("SE2",3) == "C")
Local cQuery		:= ""
Local aStru			:= {}
//Local aAux			:= {}
Local nQtdMark		:= 0
Local cFilAtu		:= cFilAnt
Local lInssBx 		:= SuperGetMv("MV_INSBXCP",.F.,"2") == "1"  
Local nTotIns 		:= 0   
Local nTotBIns		:= 0
Local lRoundIns		:= GetNewPar("MV_RNDINS",.F.)
Local nBaseRet		:= 0
Local nBaseFat		:= 0
Local nOldIns		:= 0
//REESTRUTURACAO SE5
Local oModelBxP	:= nil //FWLoadModel("FINM020") //Model de baixas a pagar
Local oSubFK2
Local oSubFK6
Local oFKA
Local cLog		:= ""
Local cChaveTit	:= ""
Local cChaveFK7	:= ""
Local cCamposE5	:= ""
Local nRecSE5	:= 0
Local lRet		:= .T.
Local cCodAprov	:= ""
Local lCtrlAlc	:= (SuperGetMV( "MV_FINCTAL", .T., "1" ) == "2")
Local lDirf		:= .F. 
Local cTitpai		:=""

// Contabilidade
Local cContaDB:= ""
Local cCCC	  := ""
Local cCCD	  := ""
Local cCCusto := ""
Local cItemC  := ""
Local cItemD  := ""
Local cClVlCR := ""
Local cClVlDB := ""

Local lFAT290SE5 := ExistBlock("FAT290SE5")
Local aTitSE5   := {}
Local cQuery2	:= ''
Local cCampos	:= ''
Local aCamposExtras	:= {}
Local lLoja		:= .F. //(MV_PAR01 == 1)
Local nTxMoeda	:= 0
Local cCpoTp := 0
Local nTxFat := 0
Local cVarMV_MRETISS := SuperGetMv("MV_MRETISS",.F.,"1")
Local nVarMV_NUMFATP:= GetMv("MV_NUMFATP")
Local cVarMV_INSIRF:=SuperGetMv("MV_INSIRF",.F.,"2")
Local cvarMV_NGMNTFI:= SuperGetMV("MV_NGMNTFI",.F.,"N")
Local nVarMV_MCUSTO:=GetMv("MV_MCUSTO")
Local _cNomFor := ""

Private nInsFat		:= 0 
Private aInsFat		:= {}
Private aBaseIns		:= {}					 		
Private oGet
Private cCondicao	:= Space(3)
Private nValCorr	:= 0
Private nBasePCC	:= 0
Private nPisFat	:= 0
Private nCofFat	:= 0 
Private nCslFat	:= 0 
Private nIrfFat	:= 0 
Private aBaseFat	:= {}
Private aPisFat	:= {}
Private aCofFat	:= {}
Private aCslFat	:= {}
Private aIrfFat	:= {}
Private lInverte	:= .F.
Private aHeader	:= {}
Private aCols		:= {}
Private oValTot	:= 0
Private nValTot	:= 0
Private nUsado 	:= 0
Private cTipo		:= CRIAVAR("E2_TIPOFAT")
Private cFornP		:= CRIAVAR("E2_FORNECE",.F.)
Private cLojaP		:= CRIAVAR("E2_LOJA",.F.)
Private nJur290	:= 0
Private nDesc290	:= 0
Private nAcres290	:= 0
Private nDecres290	:= 0
Private nBaseIrpf	:= 0
Private aDocsOri	:= {}
Private aDocsDes	:= {}  
PRIVATE dEmiss		:= SE2->E2_EMIS1

Default lAutomato := .F.

If Type("lEmpPub") <> "L"
	lEmpPub	:= IsEmpPub()
EndIf
If dDatabase >= dLastPCc
	nVlMinImp	:= 0
EndIf

//                                                               
//  Verifica se data do movimento n o   menor que data limite de  
//  movimentacao no financeiro    										   
//                                                                
If !DtMovFin(,,"1")
	Return
Endif	
//                                                               
//  Verifica se se o processo ser  contabilizado                  
//                                                                
lPadrao := VerPadrao(cPadrao) .and. mv_par03 == 1

aPcc[1]	:= .F.

//                                                                   
//  POR MAIS ESTRANHO QUE PARE A, ESTA FUNCAO DEVE SER CHAMADA AQUI!  
//                                                                    
//  A fun  o SomaAbat reabre o SE2 com outro nome pela ChkFile para   
//  efeito de performance. Se o alias auxiliar para a SumAbat() n o   
//  estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,    
//  pois o Filtro do SE2 uptrapassa 255 Caracteres.                   
//                                                                    
SomaAbat("","","","P")

//                                                               
//  ACIONA A FUNCAO PERGUNTE												   
//                                                                
SetKey (VK_F12,{|a,b| AcessaPerg("AFI290",.T.)})
Pergunte("AFI290",.F.)

//                                                               
//  Inicializa array com as moedas existentes.						   
//                                                                
aMoedas := FDescMoed()  

dbSelectArea( cAlias )

cPictPref := AllTrim(PesqPict("SE2","E2_PREFIXO"))
cForn	:= SPACE(TamSX3("E2_FORNECE")[1])
cLoja	:= SPACE(TamSX3("E2_LOJA")[1])

//-- Tratamento necessario devido os parametros enviados pela MBrowse
If ValType(aFatPag) != "A" .Or. Len(aFatPag) < 13 .Or. ValType(aFatPag[13]) != "A"
	aFatPag := {}
EndIf
//Descricao do Array aFatPag
//[01] - Prefixo
//[02] - Tipo
//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
//[04] - Natureza
//[05] - Data de
//[06] - Data Ate
//[07] - Fornecedor
//[08] - Loja
//[09] - Fornecedor para geracao
//[10] - Loja do fornecedor para geracao
//[11] - Condicao de pagto
//[12] - Moeda
//[13] - ARRAY com os titulos da fatura
//[13,1] Prefixo
//[13,2] Numero
//[13,3] Parcela
//[13,4] Tipo
//[13,5] T tulo localizado na geracao de fatura (l gico). Iniciar com falso.
//[14] - Valor de decrescimo
//[15] - Valor de acrescimo
//                                                               
//  Verifica o numero do Lote 											   
//                                                                
LoteCont( "FIN" )

nOpca 		:= 2

While nOpca == 2
	nOpca 		:= 3
	dbSelectArea(cAlias)
	//                                                               
	//  Recebe dados a serem digitados										   
	//                                                                
	cVar := aMoedas[1]
	If Len(aFatPag) > 0
		lFatAut := .T.
		If !Empty(aFatPag[3])
			lNumFat := .F.
			cFatura := aFatPag[3]
		EndIf
	EndIf
	If lNumFat
		aTam := TamSx3("E2_NUM")
		cFatura	:= Soma1(nVarMV_NUMFATP, aTam[1])
		cFatura	:= Pad(cFatura,aTam[1])
		
		// Rafael Yera Barchi - 16/12/2021
		// Ajuste por conta de problemas quando o serviço parava com o processo em andamento
		//Grava no SX6 o numero da ultima fatura gerada
		//If lRet
//			nVarMV_NUMFATP
//			RecLock( "SX6",.F. )
			putmv("MV_NUMFATP" ,cFatura)
			MsUnlock()
		//EndIf

		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI Numero da Fatura: " + cFatura))

	EndIf
	cFatAnt	:= cFatura
	//                                                               
	//  Ponto de Entrada para inicializacao das vari veis da fatura   
	//                                                                
	If lF290PRE
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE F290PRE"))
		ExecBlock("F290PRE",.F.,.F.)
	Endif
	
	If lFatAut
		cPrefix  := aFatPag[01]
		cTipo    := aFatPag[02]
		cNat     := aFatPag[04]
		dDataDe  := Iif(!Empty(aFatPag[05]),aFatPag[05],dDataDe)
		dDataAte := Iif(!Empty(aFatPag[06]),aFatPag[06],dDataAte)
		cForn    := aFatPag[07]
		cLoja    := aFatPag[08]
		cFornP   := aFatPag[09]
		cLojaP   := aFatPag[10]
		nOpca    := 1
		nDecres  := Iif(Len(aFatPag) > 13 .And. ValType(aFatPag[14]) == "N",aFatPag[14],0)
		nAcresc  := Iif(Len(aFatPag) > 14 .And. ValType(aFatPag[15]) == "N",aFatPag[15],0)
		
		/*
		ConOut("cForn: " + cForn)
		ConOut("cLoja: " + cLoja)
		ConOut("cFornP: " + cFornP)
		ConOut("cLojaP: " + cLojaP)
		*/

		If lAutomato
			If FindFunction("GetParAuto")
				aRetAuto := GetParAuto("FINA290TestCase")
				
				nValorFat := aRetAuto[1][1]
				
			EndIf
		EndIf
	Else
		aSize := MSADVSIZE()
		If lPanelFin  //Chamado pelo Painel Financeiro
			//Espacamento := 45
			dbSelectArea(cAlias)
			oPanelDados := FinWindow:GetVisPanel()
			oPanelDados:FreeChildren()
			aDim := DLGinPANEL(oPanelDados)
			DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )
			//                                                                 
			//  Observacao Importante quanto as coordenadas calculadas abaixo:  
			//  --------------------------------------------------------------  
			//  a funcao DlgWidthPanel() retorna o dobro do valor da area do	  
			//  painel, sendo assim este deve ser dividido por 2 antes da sub-  
			//  tracao e redivisao por 2 para a centralizacao. 					  
			//                                                                  
			nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 218) /2
			nEspLin  := 0
			
		Else
			DEFINE MSDIALOG oDlg FROM	22,9 TO 240,540 TITLE OemToAnsi("Faturas a Pagar") PIXEL //"Faturas a Pagar"
			nEspLarg := 5
			nEspLin  := 2
		Endif
		
		oDlg:lMaximized := .F.
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		
		
		@ 004+nEspLin, nEspLarg TO 036+nEspLin, 218+nEspLarg OF oPanel PIXEL
		@ 038+nEspLin, nEspLarg TO 070+nEspLin, 218+nEspLarg OF oPanel PIXEL
		@ 072+nEspLin, nEspLarg TO 104+nEspLin, 218+nEspLarg OF oPanel PIXEL
		
		nEspLarg := nEspLarg - 7
		
		@ 020+nEspLin, 014+nEspLarg MSGET cPrefix	Pict cPictPref  			 SIZE 10, 11 OF oPanel PIXEL
		@ 020+nEspLin, 040+nEspLarg MSGET oTipo VAR cTipo		F3 "05" Picture "@!" Valid If(nOpca<>0,(!Empty (cTipo) .and. FA290Tipo(@cTipo)),.T.) SIZE 10, 11 OF oPanel PIXEL HASBUTTON
		oTipo:cReadVar := "E2_TIPOFAT"
		
		@ 020+nEspLin, 075+nEspLarg MSGET oFATURA VAR cFatura	Valid If(nOpca<>0,!Empty(cFatura),.T.) SIZE 42, 11 OF oPanel PIXEL
		@ 020+nEspLin, 120+nEspLarg MSGET oNat VAR cNat		F3 "SED" Valid If(nOpca<>0,Fa290Nat(),.T.) SIZE 55, 11 OF oPanel PIXEL HASBUTTON
		@ 020+nEspLin, 175+nEspLarg MSCOMBOBOX oCbx VAR cVar ITEMS aMoedas 		SIZE 46, 14 OF oPanel PIXEL
		
		@ 054+nEspLin, 014+nEspLarg MSGET dDataDe	Valid If(nOpca<>0,F290VLDDT("DataDe", dDataDe),.T.)		SIZE 50, 11 OF oPanel PIXEL HASBUTTON
		@ 054+nEspLin, 068+nEspLarg MSGET dDataAte	Valid If(nOpca<>0, F290VLDDT("DataAte", dDataDe, dDataAte),.T.) SIZE 50, 11 OF oPanel PIXEL HASBUTTON
		@ 054+nEspLin, 120+nEspLarg MSGET nValorFat Picture "@E 9,999,999,999.99"    SIZE 65, 11 OF oPanel PIXEL HASBUTTON
		
		@ 085+nEspLin, 014+nEspLarg MSGET cForn		F3 "FOR" Valid If(nOpca<>0,Fa290For(cForn,cLoja,lLoja,.F.),.T.) SIZE 65, 11 OF oPanel PIXEL HASBUTTON
		@ 085+nEspLin, 079+nEspLarg MSGET cLoja		When lLoja Valid If(nOpca<>0,Fa290For(cForn,cLoja,lLoja,.F.),.T.) SIZE 21, 11 OF oPanel PIXEL
		
		@ 085+nEspLin, 120+nEspLarg MSGET cFornP		When mv_par01 == 2 .and. ( Iif( lF290FORNP , EXECBLOCK("F290FORNP",.F.,.F.) , .T. )) Valid If(nOpca<>0,Fa290For(cFornP,cLojaP,.T.,.F.),.T.) F3 "FOR" SIZE 65, 11 OF oPanel PIXEL HASBUTTON
		@ 085+nEspLin, 185+nEspLarg MSGET cLojaP		When mv_par01 == 2 .and. ( Iif( lF290FORNP , EXECBLOCK("F290FORNP",.F.,.F.) , .T. )) Valid If(nOpca<>0,Fa290For(cFornP,cLojaP,.T.,.F.),.T.) SIZE 21, 11 OF oPanel PIXEL
		
		@ 010+nEspLin, 014+nEspLarg SAY OemToAnsi("Prefixo") SIZE 20, 7 OF oPanel PIXEL //"Prefixo"
		@ 010+nEspLin, 040+nEspLarg SAY OemToAnsi("Tipo") SIZE 12, 7 OF oPanel PIXEL //"Tp"
		@ 010+nEspLin, 075+nEspLarg SAY OemToAnsi("Nr.Fatura") SIZE 49, 7 OF oPanel PIXEL //"Nr.Fatura"
		@ 010+nEspLin, 120+nEspLarg SAY OemToAnsi("Natureza") SIZE 25, 7 OF oPanel PIXEL //"Natureza"
		@ 010+nEspLin, 175+nEspLarg SAY OemToAnsi("Moeda") SIZE 25, 7 OF oPanel PIXEL //"Moeda"
		
		@ 044+nEspLin, 014+nEspLarg SAY OemToAnsi("Emissao de") SIZE 30, 7 OF oPanel PIXEL //"Emiss o de"
		@ 044+nEspLin, 068+nEspLarg SAY OemToAnsi("Emissao Ate") SIZE 10, 7 OF oPanel PIXEL //"At "
		@ 044+nEspLin, 120+nEspLarg SAY OemToAnsi("Valor da Fatura") SIZE 50, 7 OF oPanel PIXEL //"Valor da Fatura"
		
		@ 075+nEspLin, 014+nEspLarg SAY OemToAnsi("Fornecedor") SIZE 30, 7 OF oPanel PIXEL //"Fornecedor"
		@ 075+nEspLin, 079+nEspLarg SAY OemToAnsi("Loja") SIZE 30, 7 OF oPanel PIXEL //"Loja"
		@ 075+nEspLin, 120+nEspLarg SAY OemToAnsi("Gerar p/Fornecedor") SIZE 50, 7 OF oPanel PIXEL //"Gerar p/Fornecedor"
		@ 075+nEspLin, 185+nEspLarg SAY OemToAnsi("Loja") SIZE 30, 7 OF oPanel PIXEL //"Loja"

		aCps := {"cPrefix","cFatura","cNat","cForn","cLoja","cFornP","cLojaP"}		
		
		If lPanelFin  //Chamado pelo Painel Financeiro
			oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			{||nOpca:=0,IF(If(FA290NUM(cFatAnt), FA290Ok() .And. Iif(lLoja, Fa290For(cForn,cLoja,.T.,.T.), Fa290For(cFornP,cLojaP,.T.,.T.)) ,.F.),nOpca:=1,nOpca:=2),oDlg:End()},;
			{||nOpca:=0,oDlg:End()})
			
			FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)
			
		Else
			DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION (nOpca:=0,IF(If(FA290NUM(cFatAnt),FA290Ok() .And. F290VlCpos(aCps) .And. Iif(lLoja, Fa290For(cForn,cLoja,.T.,.T.), Fa290For(cFornP,cLojaP,.T.,.T.)) ,.F.),nOpca:=1,nOpca:=2),oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 21, 230 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED
		Endif
	Endif
Enddo

If(nOpca<>1,nOpca:=0,.T.)

If nOpca == 0
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	Return
EndIf

If lFatAut .And. !Empty(aFatPag[12])
	nMoeda := aFatPag[12]
Else
	nMoeda := Val(Substr(cVar,1,2))
EndIf

//                                                               
//  Cria indice condicional										 
//                                                                
//Selecao de filiais
/*If mv_par06 == 1 .and. !lSE2Compart
	If Len( aSelFil ) <= 0 
		aSelFil := AdmGetFil(.F.,.T.,"SE2")
		If Len( aSelFil ) <= 0
			Return
		EndIf	
	Endif
Else */
	aSelFil := { cFilAnt }	 
//EndIf

// Monta Estrutura de Campos
cCampos := TTGetStru(aStru,"SE2")

cAliasSE2 := "TRBSE2"
cQuery := Fa290ChecF(aSelFil,aTmpFil,cTmpSE2Fil,cCampos)

// Adiciono o campo RECNO a Estrutura dos campos
Aadd( aStru , { "RECNO" , "N" , 10 , 0 } )
cCampos += ",RECNO"

AADD(aCamposExtras,{ cCampoAbat , "N" , 14 , 2 })
AADD(aCamposExtras,{ "ABATSOMADO" , "N" , 14 , 2 })
AADD(aCamposExtras,{ "CALCULADO", "C" , 1 , 0 })
AADD(aCamposExtras,{ "VLSOMAABAT" , "N" , 14 , 2 })

For nI := 1 To Len(aCamposExtras)
	AADD(aStru,aCamposExtras[nI])
Next nI

If _oFina2901 <> Nil
	_oFina2901:Delete()
	_oFina2901 := Nil
Endif

// Cria  o da Tabela Tempor ria >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
MsErase(cAliasSE2)

_oFina2901 := FWTemporaryTable():New( cAliasSe2 )  
_oFina2901:SetFields(aStru) 
_oFina2901:AddIndex("1", {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"})
_oFina2901:AddIndex(TRIM(STR(__nIdxE2OK)), {"E2_OK","E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"}) //Ordem de Marcacao
_oFina2901:Create()

cQuery2 := " INSERT "
If ALLTRIM(tcGetdb()) == "ORACLE"
	cQuery2 += " /*+ APPEND */ "
Endif

cQuery2 += " INTO "+_oFINA2901:GetRealName()+" ("+cCampos+") " + cQuery
Processa({|| TcSQLExec(cQuery2)}) 
// Processa({||SqlToTrb(cQuery, aStru, cAliasSe2)}) // Cria arquivo temporario	
(cAliasSE2)->(DbSetOrder(1))  
(cAliasSE2)->(DbGoTop())  
// ---------------------------------------------------------------------------------------

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
	Set Filter to
	dbSetOrder(1)
	RetIndex("SE2")
	// Restaura o filtro
	Set Filter To &cSetFilter.
	dbGoTop()
	
	DbSelectArea(cAliasSe2)
	DbCloseArea()
	
	//Deleta tabela tempor ria criada no banco de dados
	If _oFina2901 <> Nil
		_oFina2901:Delete()
		_oFina2901 := Nil
	Endif
	
	//Gestao
	For nX := 1 TO Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
	Next

	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	Return(.F.)
Endif

nValor		:= 0	// valor total dos titulos,mostrado no rodape do browse
nValCruz 	:= 0
nQtdTit		:= 0	// quantidade de titulos,mostrado no rodape do browse
nTitAbats	:= 0	// valor dos abatimentos dos titulos marcados
aVlCruz		:= {} // Valor na Moeda Nacional correspondente a cada parcela
lIrpfBaixa	:=  SA2->A2_CALCIRF == "2"

lCalcIssBx	:= IIF(lIsIssBx, IsIssBx("P"), cVarMV_MRETISS == "2" )

nOpcA 		:= 0

//                                                                 
//  Monta array com capos a serem mostrados na marcacao de titulos  
//  Utiliza os capos em uso do SE2 mais o E2_SALDO que apesar de    
//  nao estar em uso deve ser mostrado na tela.                     
//                                                                  
AADD(aCampos,{"E2_OK","","  ",""})
AADD(aCampos,{cCampoAbat,"","STR077","@E 999,999,999.99"})
AADD(aCampos,{"ABATSOMADO","","Valor do abatimento considerado na fatura","@E 999,999,999.99"})

For nX := 1 To Len(aStru)
	If (aStru[nX,1] $ "E2_OK|ABATSOMADO|CALCULADO|VLSOMAABAT|"+cCampoAbat) .Or. ;
	   (aStru[nX,1] == "E2_FILIAL" .And. Len(aSelFil) > 1)
		Loop
	EndIf
	cCampoSel := aStru[nX,1]
	cPictSel := X3Picture(cCampoSel)
	cTituloSel := X3Titulo() // Posicionamento do SX3 feito pela funcao X3Picture
	AADD(aCampos,{cCampoSel,"",cTituloSel,cPictSel})
Next nX

dbSelectArea(cAliasSe2)

IF lF290BTIT
	ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE F290BTIT"))
	aCampos:=ExecBlock("F290BTIT",.f.,.f.,aCampos)
EndIF 

//                                                               
//  Inicia integracao com Modulo SIGAPCO                          
//                                                                
PcoInilan("000015")

//                                                               
//  Marca os titulos ate o valor informado para a fatura 		   
//                                                                

If MV_PAR05 == 1 .Or. lFatAut
	Fa290Marca(cAliasSe2,cMarca,nValorFat,lPccBaixa,(cPaisLoc == "BRA"),aChaveLbn,aFatPag)
EndIf

nValorF := nValorFat

If lFatAut
	If Ascan(aFatPag[13],{ | e | e[5] == .F. }) > 0
		IW_MSGBOX("Existem Titulos que nao foram localizados na geracao da Fatura",,"Atencao",'STOP')		//'Existem t tulos que n o foram localizados na gera  o da fatura'###"Aten  o"
		//                                                               
		//  Recupera a Integridade dos dados									   
		//                                                                
		FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
		dbSelectArea("SE2")
		RetIndex( "SE2" )
		// Restaura o filtro
		Set Filter To &cSetFilter.
		DbSelectArea(cAliasSe2)
		DbCloseArea()
			
		//Deleta tabela tempor ria criada no banco de dados
		If _oFina2901 <> Nil
			_oFina2901:Delete()
			_oFina2901 := Nil
		Endif
		
		//Gestao
		For nX := 1 TO Len(aTmpFil)
			CtbTmpErase(aTmpFil[nX])
		Next
		dbSelectArea("SE2")
		Return(.F.)
	EndIf		
	nOpca := 1
Else  
	//                                                       
	//  Faz o calculo automatico de dimensoes de objetos      
	//                                                        
	aSize := MSADVSIZE()

	oSize := FWDefSize():New(.T.)

	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lLateral := .F.				
	oSize:lProp := .T.
	
	oSize:Process()

	DEFINE MSDIALOG oDlg1 TITLE "Fatura a Pagar" PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd  //"Fatura a Pagar"
	oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg1) },oDlg1) // Ativa timer
	oTimer:Activate()  
	

	nLinIni := oSize:GetDimension("MASTER","LININI")
	nColIni := oSize:GetDimension("MASTER","COLINI")
	nLinFin := oSize:GetDimension("MASTER","LINEND")
	nColFin := oSize:GetDimension("MASTER","COLEND")

	@ nLinIni + 001, 002  To nLinIni+033,nColFin PIXEL OF oDlg1

	@ nLinIni + 008 , 005		SAY OemToAnsi("Prefixo") + cPrefix 				  FONT oDlg1:oFont PIXEL Of oPanel// "Prefixo: "
	@ nLinIni + 017 , 005		Say OemToAnsi("Numero") + cFatura 				  FONT oDlg1:oFont PIXEL Of oPanel// "N mero: "
	@ nLinIni + 008 , 080		SAY OemToAnsi("Natureza") + Substr(cNat,1,10)		  FONT oDlg1:oFont PIXEL Of oPanel// "Natureza: "
	@ nLinIni + 017 , 080		SAY OemToAnsi("Moeda") + AllTrim(Str(nMoeda,2,0)) FONT oDlg1:oFont PIXEL Of oPanel// "Moeda: "
	
	
	@ nLinIni + 008 , 150		Say OemToAnsi("Valor da Fatura") FONT oDlg1:oFont PIXEL Of oPanel	//"Valor Fatura"
	@ nLinIni + 008 , 200		Say OemToAnsi("Valor Selecionado") FONT oDlg1:oFont PIXEL Of oPanel	//"Valor Selecionado"
	@ nLinIni + 008 , 250		Say OemToAnsi("Titulo Selecionado") FONT oDlg1:oFont PIXEL Of oPanel	//"T t. Selec."
	@ nLinIni + 017 , 150		Say oValorFat VAR nValorF	  Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL Of oPanel
	@ nLinIni + 017 , 200		Say oValor	  VAR nValor	  Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL Of oPanel
	@ nLinIni + 017 , 250		Say oQtdTit   VAR nQtdTit	  Picture "999999"            FONT oDlg1:oFont PIXEL Of oPanel
	

	oMark 		:=MsSelect():New(cAliasSE2,"E2_OK","!E2_SALDO",aCampos,@lInverte,@cMarca,{nLinIni + 36, nColIni, nLinFin, nColFin})
	oMark:bMark := {||Fa290Exibe(cMarca,oValor,oQtdTit,lPccBaixa,(cPaisLoc == "BRA"),cAliasSE2)}
	oMark:bAval	:= {||Fa290bAval(cAliasSE2,cMarca,oValor,oQtdTit,oMark,lPccBaixa,(cPaisLoc == "BRA"),aChaveLbn)}
	oMark:oBrowse:lhasMark = .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:bAllMark := { || Fa290Inverte(cAliasSE2,cMarca,oValor,oQtdTit,.T.,oMark,lPccBaixa,(cPaisLoc == "BRA"),aChaveLbn,,,,oTitAbats)}
	
	If lF290FPG
	  ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE F290FPG"))
	  aBut290 := ExecBlock( "F290FPG",.F.,.F., {aBut290})
    EndIf      
	 
	If lPanelFin  //Chamado pelo Painel Financeiro			
	   ACTIVATE MSDIALOG oDlg1 ON INIT FaMyBar(oDlg1,{|| nOpca := 1,;
	   	IIF(Fa290ValOK(),IF(Fa290Soma(),oDlg1:End(),;
			Iif(Fa290Val(oValorFat),nOpca:=0,nOpca:=0)),nOpca:=0)},;
			{|| nOpca := 2,oDlg1:End()},aBut290)     
	Else
		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| nOpca := 1,;
			IIF(Fa290ValOK(),IF(Fa290Soma(),oDlg1:End(),;
			Iif(Fa290Val(oValorFat),nOpca:=0,nOpca:=0)),nOpca:=0)},;
			{|| nOpca := 2,oDlg1:End()},,aBut290)  
	Endif
	SetKey(16,bSet16)
EndIf
	
dbSelectArea("SE2")

If nOpca == 1
	nOpcA := 0
	
	If !lF290CON
		If lCtrlAlc
			MsgInfo("Para a fatura ser  adotado o aprovador padr o para a moeda:" + AllTrim(Str(nMoeda)) + ".","Controle de Alcadas Ativo")		//"Para a fatura ser  adotado o aprovador padr o para a moeda: " ###"Controle de al adas ativo" 
		Endif
		
		cCond := Iif(lFatAut .And. !Empty(aFatPag[11]),aFatPag[11],Space(3))
		
		If lFatAut .And. !lAWB
			nOpca := 1		
			cCondicao := cCond
			
			If nModulo == 89 .AND. !FWIsInCallStack("TA039EFET")
				aVenc := TA042Vencto(nValor, cCondicao)
			Else
				aVenc := Condicao(nValor, cCondicao, 0)
			EndIf
			
			nDup	:= Len(aVenc)
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - nDup: " + CValToChar(nDup)))
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - cPrefix: " + cPrefix))
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - cFatura: " + cFatura))
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - nValor: " + CValToChar(nValor)))
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - aVenc: " + VarInfo("Conteudo aArray - aVenc", aVenc)))
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - lFatAut: "))
			ConOut(lFatAut)
			aCols := GravaDup(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc,lFatAut)
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - aCols: " + VarInfo("Conteudo aArray - aCols", aCols)))
		Else
			aSize := MsAdvSize(,.F.,400)
			DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
			oDLg2:lMaximized := .T.
			
			oPanel1 := TPanel():New(0,0,'',oDlg2, oDlg2:oFont, .T., .T.,, ,65,65,.T.,.T. )
			oPanel1:Align := CONTROL_ALIGN_TOP
			
			oPanel2 := TPanel():New(0,0,'',oDlg2, oDlg2:oFont, .T., .T.,, ,20,20,.T.,.T. )
			oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
			@ 003,010 TO 55,125 OF oPanel1 Pixel
			@ 003,127 TO 55,500 OF oPanel1 Pixel
				
			@ 015, 015 Say "TAXA MOEDA" Of oPanel1 Pixel //Taxa Moeda
			@ 015, 050 MSGET nTxFat When If(nMoeda > 1, .T., .F.) Picture PesqPict("SE2","E2_TXMOEDA") PIXEL Of oPanel1 Hasbutton

			@ 032,015 Say "CONDICAO" Of oPanel1 Pixel   //"Condi  o: "
			@ 032,050 MSGET cCond F3 "SE4" Picture "!!!" Of oPanel1 Pixel Hasbutton Valid If(nOpca<>0,ExistCpo("SE4",cCond) .And. Fa290Cond(cCond),.T.)				
			DEFINE SBUTTON FROM 032, 090	TYPE 1 ACTION (If(!Empty(cCond)	.And.	ExistCpo("SE4",cCond) .And. Fa290Cond(cCond),;
													nOpca:=F290SelFat(oDlg2,1,@cCond,@nValor,@nValTot,@aVenc,@cPrefix,@cFatura,@cTipo,dDatCont,oPanel2,oPanel1),nOpca:=0)) ENABLE OF oPanel1
			
			If lPanelFin  //Chamado pelo Painel Financeiro			
				ACTIVATE MSDIALOG oDlg2 ON INIT FaMyBar(oDlg2,;
															{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,oDlg2:End(),nOpca := 0), nOpca := 0)},;
															{||oDlg2:End()})																												
			Else				
				ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nOpca:=1, If( valtype(oget)=="O",if(oGet:TudoOk() .And. Len(aCols) > 0,oDlg2:End(),nOpca := 0), nOpca := 0)},{||oDlg2:End()})
			Endif				                                  
	
			cCondicao := If(nOpca=0,"   ",cCond)
			aVenc := Condicao(nValor,cCondicao,0)
		EndIf
	Else
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE F290CON"))
		aVenc := Execblock("F290CON",.f.,.f.,{nValor,cCondicao,cMarca,nBasePcc,nPisFat,nCofFat,nCslFat})
		nDup := Len(aVenc)
		aCols := GravaDup(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc)
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - GravaDup - aCols: " + VarInfo("Conteudo aArray - aCols", aCols)))
		
		If !Empty(aCols)
			aVlCruz := {}
			aVlCruz := F280VlCruz(nDup,nValCruz)
			
			//Mostra tela com os diversos titulos
			For nI:=1 To Len(aCols)
				nValTot += aCols[nI][6]
			Next nI
			
			//Faz o calculo automatico de dimensoes de objetos
			If lPEMostraTela
				ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE FI290MT"))
				lMostraTela:=ExecBlock("FI290MT",.f.,.f.)
      		If ValType(lMostraTela) # "L"
      			lMostraTela:=.T.
      		EndIf
   		EndIf
			If lMostratela
				aSize := MSADVSIZE()
				nOpca := 0
				DEFINE MSDIALOG oDlg2 TITLE "Dados Contabeis e Financeiros" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Dados Cont beis Financeiros"
				oDlg2:lMaximized := .T.
				oPanel := TPanel():New(0,0,'',oDlg2,, .T., .T.,, ,20,20,.T.,.T. )
				oPanel:Align := CONTROL_ALIGN_TOP
				
				@ 003 , 005	SAY OemToAnsi("Data da Conttabilizaçaão")	PIXEL OF oPanel //"Data Contabiliza  o : "
				@ 003 , 060	Say dDatCont				PIXEL OF oPanel FONT oDlg2:oFont  
				@ 003 , 105	Say OemToAnsi("Condição de Pagamento")	PIXEL OF oPanel //"Condi  o de Pagamento : "
				@ 003 , 170	Say cCondicao				PIXEL OF oPanel
				@ 003 , 215	Say OemToAnsi("Valor Total")	PIXEL OF oPanel //"Valor Total:"
				@ 003 , 260	Say oValTot VAR nValTot	PIXEL OF oPanel FONT oDlg2:oFont Picture "@E 9,999,999,999.99" 

				oGet:= MSGetDados():New(90,1,172,312,3,"Fa290LinOk","Fa290TudOk","",.T.,,,,,,"",,"Fa290AtuVl(.F.)")
				oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				ACTIVATE MSDIALOG oDlg2 ON INIT (oGet:oBrowse:Refresh(.T.),EnchoiceBar(oDlg2,{||nOpca:=1,if(oGet:TudoOk(),oDlg2:End(),nOpca := 0)},{||oDlg2:End()}))
			Else
				nOpca := 1		
			EndIf
		Endif
	Endif
	
	// Criar a fatura
	If nOpcA == 1
		STRLCTPAD 	:= ""		// para contabilizar o historico do LP
		nTotAbat :=0
		nQtdMark := 0
		
		dbSelectArea( cAliasSE2 )
		dbGotop()
		
		//ponto de entrada para customizar um historico a ser gravado em todos os titulos selecionados para gerar a fatura.
		If lFA290HPAD
			ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE FA290HPAD"))
			cHistFat := ExecBlock( "FA290HPAD", .F., .F. )
		EndIf
		
		Begin Transaction
			(cAliasSE2)->(dbSetOrder(__nIdxE2OK))
			(cAliasSE2)->(dbSeek(cMarca))	// Localiza o primeiro registro marcado para baixa
			
			While !(cAliasSE2)->(Eof()) .And. (cAliasSE2)->E2_OK == cMarca
				dbSelectArea("SE2")
				SE2->(DbGoTo((cAliasSE2)->RECNO))
				nX := SE2->(RecNo())
				
				If SE2->E2_TXMOEDA > 0 .And. nMoeda > 1
					nTxMoeda := SE2->E2_TXMOEDA 
				Else
					nTxMoeda := RecMoeda(dDataBase,nMoeda)
				EndIf
				
				cFilOrig := SE2->E2_FILORIG
				cNumero  := E2_NUM
				cPrefixo := E2_PREFIXO
				cParcela := E2_PARCELA
				ABATIMENTO := 0
				cCamposE5 := ""
				nQtdMark++
				
				If !lFA290HPAD
					cHistFat := (cAliasSE2)->E2_HIST
				EndIf
				
				cFilAnt 	:= SE2->E2_FILORIG
				
				If (cAliasSE2)->CALCULADO == '1'
					ABATIMENTO	:= (cAliasSE2)->ABATSOMADO
				Else
					ABATIMENTO	:= SomaAbat(E2_PREFIXO,E2_NUM,E2_PARCELA,"P",E2_MOEDA,,E2_FORNECE,E2_LOJA,,,E2_TIPO)
				Endif
				
				cFilAnt	:= cFilAtu
				nTotAbat 	+= ABATIMENTO

				/*
				ConOut("lLoja")
				ConOut(lLoja)
				ConOut("cForn: " + cForn)
				ConOut("cLoja: " + cLoja)
				ConOut("cFornP: " + cFornP)
				ConOut("cLojaP: " + cLojaP)
				*/

				//Baixo os titulos de abatimento
				If ABATIMENTO > 0 
					DbSelectArea("__SE2")
					__SE2->(dbSetOrder(1))
					__SE2->(MsSeek(xFilial("SE2",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)))
					
					While !EOF() .And. __SE2->(E2_FILIAL+E2_PREFIXO+SE2->E2_NUM+E2_PARCELA) == xFilial("SE2",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)
						If __SE2->E2_TIPO $ MVABATIM .And. __SE2->E2_FORNECE == SE2->E2_FORNECE .And. Empty( __SE2->E2_BAIXA ) .And. !Empty( __SE2->E2_SALDO )
							If !(__SE2->(E2_FATURA+E2_FATPREF+E2_TIPOFAT+E2_FLAGFAT) == (cFatura+cPrefix+cTipo+"S") .And. __SE2->E2_DTFATUR == dDatabase)
								
								RecLock("__SE2")
								__SE2->E2_BAIXA 	:= dDataBase
								__SE2->E2_VALLIQ	:= __SE2->E2_SALDO
								__SE2->E2_SALDO	:= 0
								__SE2->E2_MOVIMEN	:= dDataBase
								__SE2->E2_FATURA	:= cFatura
								__SE2->E2_FATPREF	:= cPrefix
								__SE2->E2_TIPOFAT	:= cTipo
								__SE2->E2_DTFATUR	:= dDatabase
								__SE2->E2_FLAGFAT	:= "S"
								__SE2->E2_FATFOR	:= IIF(lLoja,cForn,cFornP)
								__SE2->E2_FATLOJ	:= IIF(lLoja,cLoja,cLojaP)
								MsUnlock()
								//Tira o saldo do vencimento programado do titulo
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - AtuSldNat - Inicio "))
								AtuSldNat(__SE2->E2_NATUREZ, __SE2->E2_VENCREA, __SE2->E2_MOEDA, "2", "P", __SE2->E2_VALLIQ, xMoeda(__SE2->E2_VALLIQ, __SE2->E2_MOEDA, 1),"+",,FunName(),"__SE2",__SE2->(Recno()),nOpcE)
								ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - AtuSldNat - Fim "))
							EndIf
						Endif
						__SE2->(dbSkip())
					Enddo
				Endif
				
				DbSelectArea("SE2")
				dbGoto(nX)
				
				//Atualiza a Baixa do Titulo
				If !(E2_TIPO $ MVABATIM) .and. E2_SALDO > 0
					nJur290	 := SE2->E2_SDACRES
					nDesc290 := SE2->E2_SDDECRE
					nAcres290	:= SE2->E2_ACRESC
					nDecres290 	:= SE2->E2_DECRESC
					nValCorr := fa090Correc( ) 
					
					//Posiciona no Cadastro de Naturezas
					SED->(dbSetOrder(1))
					SED->(MsSeek(xFilial("SED",cFilOrig)+SE2->E2_NATUREZ))
					SA2->(dbSetOrder(1))
					SA2->(MSSeek(xFilial("SA2",cFilOrig)+SE2->(E2_FORNECE+E2_LOJA)))
					
					lIRPFBaixa := (SA2->A2_CALCIRF == "2")
					lCalcIssBx	:= 	IIF(lIsIssBx, IsIssBx("P"), cVarMV_MRETISS == "2" )
					lBaseIRPF  := F050BIRPF(2)
					
					//Tratamento de base e impostos Lei 10925 quando pela baixa
					If lPccBaixa .and. (E2_PIS+E2_COFINS+E2_CSLL > 0)
						nVlrTit := SE2->(E2_VALOR+E2_IRRF+E2_ISS)
						
						If !lInssBx	
							nVlrTit += SE2->E2_INSS
						Endif
						
						nVlrTit += SE2->E2_SEST
						
						If lCalcIssBx 
							nVlrTit -= SE2->E2_ISS
						EndIf
						
						//AQUI VERIFICO QUANTO FOI RETIDO E QUANTO FALTA RETER
						nPCCRet	:= 0
						nPisRet	:= 0
						nCofRet	:= 0
						nCslRet	:= 0
						
						If dDatabase < dLastPcc .Or. lEmpPub
							SE5->(DBSetOrder(7))
							
							If SE5->(MSSEEK(xFilial("SE5",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
								cKeyTit := xFilial("SE5",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
								
								While !(SE5->(EOF())) .AND. cKeyTit = xFilial("SE5",cFilOrig)+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
									If (Empty( SE5->E5_PRETPIS ) .Or. SE5->E5_PRETPIS == '4' .Or. SE5->E5_PRETPIS == '5') .AND. !(SE5->E5_SITUACA=='C')
										//Valida se trata-se de um movimento de estorno, retirando os valores retidos
										If SE5->E5_TIPODOC != "ES"
											//Armazeno os valores calculados por titulo, retirando os valores retidos
											nPisRet += SE5->E5_VRETPIS
											nCofRet += SE5->E5_VRETCOF 
											nCslRet += SE5->E5_VRETCSL
										Else
											//Armazeno os valores calculados por titulo, retirando os valores retidos
											nPisRet -= SE5->E5_VRETPIS
											nCofRet -= SE5->E5_VRETCOF 
											nCslRet -= SE5->E5_VRETCSL
										EndIf
										If SubStr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CPNEG
											lCompNdf := .T.
										Endif
									Endif
									SE5->(dbSkip())
								Enddo
							Endif
							
							If (cPaisLoc == "BRA")   //Utilizo a base dos impostos e nao o saldo do titulo
								nBasePCC += IIF(Empty(E2_BASEPIS), E2_SALDO+E2_ISS+E2_IRRF,E2_BASEPIS)
							
								If !lInssBx	
									nBasePCC += IIF(Empty(E2_BASEPIS),Iif(!lInssBx,E2_INSS,0),0)							
								Endif
							Endif
							
							If lPABruto
								nBasePCC += PABrtComp()
							Endif					
							
							If !lCompNdf				
								nPisFat+= SE2->E2_PIS - nPisRet		
								nCofFat+= SE2->E2_COFINS - nCofRet		
								nCslFat+= SE2->E2_CSLL - nCslRet	
							Else
								nPisFat+= (SE2->E2_PIS * E2_SALDO+nPisRet) / E2_VALOR
								nCofFat+= (SE2->E2_COFINS * E2_SALDO+nCofRet) / E2_VALOR
								nCslFat+= (SE2->E2_CSLL * E2_SALDO+nCslRet) / E2_VALOR		
							Endif		
						ElseIf SE2->E2_TIPO # MVPAGANT .And. Empty(SE2->E2_NUMBOR)
							nSalTit		:= salRefPag(SE2->E2_FORNECE+SE2->E2_LOJA)
							nBasePCC 	+= nSalTit
							aPcc:= newMinPcc(dDataBase,  nSalTit ,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE+SE2->E2_LOJA)
						
							nPisFat+=   aPcc[2]	
							nCofFat+=   aPcc[3] 
							nCslFat+=   aPcc[4]
						EndIf
					EndIf
						
					SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ ))
					
					If SED->ED_CALCINS == "S" .and. SA2->A2_RECINSS == "S" .And. lInssBx .And. cPaisLoc = "BRA" //Inss Baixa						         
						nBaseRet	:=	0
						nVlrTit	:=	0
						SE5->(DBSetOrder(7))
						
						If SE5->(Msseek(xFilial("SE5",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
							cKeyTit := xFilial("SE5",cFilOrig)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
							
							While !(SE5->(EOF())) .And. cKeyTit = xFilial("SE5",cFilOrig)+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
								If (Empty( SE5->E5_PRETINS ) .Or. SE5->E5_PRETINS == '4' ) .And. !(SE5->E5_SITUACA=='C')
									//Armazeno os valores calculados por titulo, retirando os valores retidos
									nBaseRet	+=	SE5->E5_VALOR + SE5->E5_VRETINS + SE5->E5_VRETIRF + SE5->E5_VRETCSL + SE5->E5_VRETCOF + SE5->E5_VRETPIS + SE5->E5_VRETISS	
								Endif
								
								SE5->(dbSkip())
							Enddo
						Endif				
						
						nVlrTit	+=	 SE2->E2_VALOR //Impostos na baixa
											
						If !lIrpfBaixa  
							nVlrTit	+=	SE2->E2_IRRF
						Endif
						
						If !lPCCBaixa .And.;
								(SE2->E2_BASEPIS > nVlMinImp .Or.; //Somar se o titulo n o for menor que 5000 que os impostos n o tenham sido retidos. 
								(SE2->E2_BASEPIS <= nVlMinImp .And. SE2->E2_PRETCSL $ " 43" .And. SE2->E2_PRETCOF $ " 43" .And. SE2->E2_PRETPIS $ " 43") ) 
							nVlrTit	+=	SE2->E2_PIS + SE2->E2_COFINS +	SE2->E2_CSLL
						Endif
						
						If !lCalcIssBx
							nVlrTit	+=	SE2->E2_ISS
						Endif
						
						nBaseFat	+=	(nVlrTit - nBaseRet) // Remontar a base do titulo que j  foi retido.
						
						If !Empty( SED->ED_BASEINS )//Base reduzida
							nVlrTit := ( nVlrTit * SED->ED_BASEINS ) / 100
						EndIf
						
						If lRoundIns
							nInsFat	:= nInsFat + Round(( (nVlrTit - nBaseRet) * (SED->ED_PERCINS/100)),2)
						Else
							nInsFat 	:= nInsFat + NoRound(( (nVlrTit - nBaseRet) * (SED->ED_PERCINS/100)),2)
						EndIf
						
						If !Empty(SE2->E2_BAIXA) //Caso titulo baixado								
							nOldIns	:=	SE2->E2_INSS
							nOldVret	:=	SE2->E2_VRETINS
							cOldIns	:=	SE2->E2_PRETINS
						Else								
							If lRoundIns //Valor do inss do titulo
								nOldIns	:= Round(( (nVlrTit) * (SED->ED_PERCINS/100)),2)
							Else
								nOldIns 	:= NoRound(( (nVlrTit) * (SED->ED_PERCINS/100)),2)
							EndIf																
							nOldVret	:=	nOldIns
							cOldIns	:=	""									
						Endif	
					EndIf
						
					//Tratamento de IRRF na Baixa
					If lIrpfBaixa
						// Tratamento para o total de IR						
						If SA2->A2_TIPO == "J" .And. SED->ED_CALCIRF == "S"
							nTotIRPJ  += FCalcIRBx(0,SA2->A2_TIPO,dDatabase,dDataBase)//SE2->E2_IRRF
							nSalTit	:= salRefPag(SE2->E2_FORNECE+SE2->E2_LOJA)
							nBaseIrf += nSalTit
						Endif
						
						lUsaBaseIr := .F.
						
						//Verifico se controla a base de Impostos
						If lBaseIrpf
							If SE2->E2_BASEIRF > 0
								nBaseIrpf += SE2->E2_BASEIRF
								lUsaBaseIr := .T.
							Else
								nBaseIrpf += (SE2->E2_SALDO + Iif(!lInssBx,SE2->E2_INSS,0))
							Endif
						Else							
							nBaseIrpf += (SE2->E2_SALDO + Iif(!lInssBx,SE2->E2_INSS,0))
						Endif
						
						//Se nao usou o valor do  
						If !lUsaBaseIr
							If !lCalcIssBx
								nBaseIrpf += SE2->E2_ISS
							EndIf
								
							If !lIRPFBaixa
								nBaseIrpf += SE2->E2_IRRF
							EndIf
						Endif
						
						//Se for PF, verifica se reduz o INSS da base do IRRF
						nBaseIrpf -= Iif((cVarMV_INSIRF == "1" .And. SA2->A2_TIPO != "J"),SE2->E2_INSS,0)
					Endif

					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - Gravacao do título original - Inicio "))
					ConOut("lLoja")
					ConOut(lLoja)
					ConOut("cForn: " + cForn)
					ConOut("cLoja: " + cLoja)
					ConOut("cFornP: " + cFornP)
					ConOut("cLojaP: " + cLojaP)
						
					RecLock("SE2")
					SE2->E2_BAIXA		:= dDataBase
					SE2->E2_VALLIQ	:= SE2->E2_SALDO + SE2->E2_SDACRES - SE2->E2_SDDECRE - ABATIMENTO
					SE2->E2_JUROS		:= nJur290
					SE2->E2_DESCONT	:= nDesc290
					SE2->E2_SALDO		:= 0
					SE2->E2_MOVIMEN 	:= dDataBase
					SE2->E2_FATURA  	:= cFatura
					SE2->E2_FATPREF 	:= cPrefix
					SE2->E2_TIPOFAT 	:= cTipo
					SE2->E2_DTFATUR 	:= dDataBase
					SE2->E2_FLAGFAT 	:= "S"
					SE2->E2_SDACRES 	:= 0
					SE2->E2_SDDECRE 	:= 0
					SE2->E2_CORREC  	:= 	nValCorr
					SE2->E2_FATFOR  	:= IIF(lLoja,cForn,cFornP)
					SE2->E2_FATLOJ  	:= IIF(lLoja,cLoja,cLojaP)
					
					//Zero os impostos para que n o sejam contabilizados neste momento
					//Somente o serao na baixa do titulo gerado pela fatura.
					If lPccBaixa
						nOldPis			:= SE2->E2_PIS
						nOldCof 			:= SE2->E2_COFINS
						nOldCsl 			:= SE2->E2_CSLL
						SE2->E2_PIS 		:= 0
						SE2->E2_COFINS	:= 0
						SE2->E2_CSLL		:= 0
					Endif
					
					If SED->ED_CALCINS == "S" .and. SA2->A2_RECINSS == "S" .And. lInssBx .And. cPaisLoc = "BRA" //Inss Baixa				         						
						SE2->E2_INSS		:=	0
						SE2->E2_VRETINS	:=	0
						SE2->E2_PRETINS	:= ""
					Endif
					
					If lFA290HPAD
						SE2->E2_HIST	:= cHistFat
					EndIf
					
					SE2->(MsUnlock( ))
					
					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - Gravacao do título original - Fim "))

					//Atualiza integra  o com Manuten  o de Ativos
					If cvarMV_NGMNTFI == "S"  .And. FindFunction("NGATUMNT") .And. 'MNT' $ SE2->E2_ORIGEM						
						NGATUMNT(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE, SE2->E2_LOJA,;
								cPrefix, cFatura, cTipo, SE2->E2_ORIGEM)
					EndIf
					
					DbSelectArea("SE2")
					
					//Tira o saldo do vencimento programado do titulo
					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - AtuSldNat - Inicio "))
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALLIQ, xMoeda(SE2->E2_VALLIQ, SE2->E2_MOEDA, 1), "-",,FunName(),"SE2",SE2->(Recno()),nOpcE)
					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - AtuSldNat - Fim "))
					
					//Rastreamento - Geradores
					If lRastro
						aadd(aRastroOri,{	SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALLIQ } )
					Endif
					
					aAdd(aE2CCC,SE2->E2_CCC)
					aAdd(aE2CCD,SE2->E2_CCD)
					aAdd(aCCUSTO,SE2->E2_CCUSTO) 
						
					//Documentos 
					If lFinVDoc
						If SE2->E2_TEMDOCS = "1"
							aAdd(aDocsOri,{SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA } )
						EndIf
					EndIf
					
					If cVarMV_MRETISS=="2" //Retencao do ISS na baixa
						nISSFat  += SE2->E2_ISS
						nFRetISS := SE2->E2_FRETISS
						nTRetISS := SE2->E2_TRETISS
					EndIf
						
					//Grava os lancamentos nas contas orcamentarias SIGAPCO
					PcoDetLan("000015","02","FINA290")
						
					If lF290Baixa
						//Executa PE apos a baixa do titulo que gerou a fatura.
						//Pode ser retornado um historico que sera utilizado na contabilizacao, atraves da variavel STRLCTPAD
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE F290BAIXA"))
						STRLCTPAD += ExecBlock("F290BAIXA",.F., .F.)
					Endif
					
					//Gera movimento da Baixa do Titulo	no SE5
					//Localiza a sequencia da baixa ( CP,BA,VL,V2,LJ )
					aTipoDoc := {"CP","BA","VL","V2"}
					SE5->(dbSetOrder(2))
					cSequencia := Replicate("0",nTamSeq)
					
					For nX := 1 to len(aTipoDoc)
						SE5->(dbSeek(xFilial("SE5",cFilOrig) + aTipoDoc[nX] + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
						
						While !SE5->(Eof()) .And. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == xFilial("SE5",cFilOrig)+aTipoDoc[nX]+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
							If SE5->(E5_CLIFOR+E5_LOJA) == SE2->(E2_FORNECE+E2_LOJA) .And. SE5->E5_RECPAG == "P"
								If PadL(AllTrim(cSequencia),nTamSeq,"0") < PadL(AllTrim(SE5->E5_SEQ),nTamSeq,"0")
									cSequencia := SE5->E5_SEQ
								Endif
							EndIf
							SE5->(dbSkip())
						EndDo
					Next
					
					If Len(AllTrim(cSequencia)) < nTamSeq
						cSequencia := PadL(AllTrim(cSequencia),nTamSeq,"0")
					Endif
						
					cSequencia := Soma1(cSequencia,nTamSeq)
					
					//Atualiza a Movimenta  o Banc ria
					oModelBxP	:= FWLoadModel("FINM020") //Model de baixas a pagar
					oModelBxP:SetOperation( 3 ) //Inclusao
					oModelBxP:Activate()	
					oModelBxP:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou n o
					oModelBxP:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclus o ser  feita com um novo n mero de processo
						
					oSubFK2	:= oModelBxP:GetModel("FK2DETAIL")
					oSubFK6	:= oModelBxP:GetModel("FK6DETAIL")
					cChaveTit	:= xFilial("SE2") + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
					cChaveFK7	:= FINGRVFK7("SE2", cChaveTit)
					cChaveFk2	:= FWUUIDV4()
					
					//Dados do Processo - Define a chave da FK5 no IDORIG
					oFKA := oModelBxP:GetModel("FKADETAIL")
					
					For nX := 1 To 4
						If nX == 1
							cCpoTp  := SE2->E2_VALLIQ
							cTpDoc  := "BA"
						ElseIf nX==2
							cCpoTp  := nJur290
							cTpDoc  := "JR"
						Elseif nX==3
							cCpoTp  := nDesc290
							cTpDoc  :="DC"      
						Elseif nX==4
							cCpoTp  := nValCorr
							cTpDoc  :="CM"	
						Endif
						
						//Define os campos que n o existem nas FKs e que ser o gravados apenas na E5, para que a grava  o da E5 continue igual
						If !Empty(cCamposE5)
							cCamposE5 += "|"
						Endif
							
						cCamposE5 += "{"
						cCamposE5 += " {'E5_TIPO'	, SE2->E2_TIPO}"
						cCamposE5 += ",{'E5_PREFIXO', SE2->E2_PREFIXO}"
						cCamposE5 += ",{'E5_NUMERO'	, SE2->E2_NUM}"
						cCamposE5 += ",{'E5_PARCELA', SE2->E2_PARCELA}"
						cCamposE5 += ",{'E5_FORNECE', SE2->E2_FORNECE}"
						cCamposE5 += ",{'E5_CLIFOR'	, SE2->E2_FORNECE}"
						cCamposE5 += ",{'E5_LOJA'	, SE2->E2_LOJA}"
						cCamposE5 += ",{'E5_DTDIGIT', dDataBase}"
						cCamposE5 += ",{'E5_DTDISPO', dDataBase}"
						cCamposE5 += ",{'E5_BENEF'	, SE2->E2_NOMFOR}"
							
						If nX == 1
							cCamposE5 += ",{'E5_VLDESCO'," + cValToChar(nDesc290) + "}"
							cCamposE5 += ",{'E5_VLJUROS'," + cValToChar(nJur290)  + "}"
							cCamposE5 += ",{'E5_VLCORRE'," + cValToChar(nValCorr) + "}"
							cCamposE5 += ",{'E5_VLACRES'," + cValToChar(nAcres290)  + "}"
							cCamposE5 += ",{'E5_VLDECRE'," + cValToChar(nDecres290) + "}"
														
							If !lUsaFlag .and. lPadrao
								cCamposE5 += ",{'E5_LA'	, 'S'}"
							EndIf
							
							//Relacionamento FKA X FK2
							If !oFKA:IsEmpty()
								oFKA:AddLine()		
								oFKA:GoLine( oFKA:Length() )	
							Endif
							
							oFKA:SetValue( "FKA_IDORIG", cChaveFk2 )
							oFKA:SetValue( "FKA_TABORI", "FK2" )
							
							//Dados da baixa a pagar
							oSubFK2:SetValue( "FK2_DATA"	,dDataBase )
							oSubFK2:SetValue( "FK2_VALOR"	,cCpoTp)
							oSubFK2:LoadValue( "FK2_NATURE"	,SE2->E2_NATUREZ )
							oSubFK2:SetValue( "FK2_RECPAG"	,"P" )
							oSubFK2:SetValue( "FK2_TPDOC"	,cTpDoc)
							oSubFK2:SetValue( "FK2_HISTOR"	,"Bx.p/Emiss.Fatura"+cFatura ) //"Bx.p/Emiss.Fatura "
							oSubFK2:SetValue( "FK2_VLMOE2"	,If(SE2->E2_MOEDA > 1, Round(NoRound(xMoeda(cCpoTp, SE2->E2_MOEDA, 1, dDataBase,MsDecimais(1)+1,nTxMoeda),3),2), cCpoTp))
							oSubFK2:SetValue( "FK2_SEQ"		,cSequencia )
							oSubFK2:SetValue( "FK2_FILORI"	,SE2->E2_FILORIG )
							oSubFK2:SetValue( "FK2_CCUSTO"	,SE2->E2_CCUSTO )
							oSubFK2:SetValue( "FK2_MOEDA"	,StrZero(SE2->E2_MOEDA, TamSx3("FK2_MOEDA")[1]) )
							oSubFK2:SetValue( "FK2_MOTBX"	,"FAT" )
							oSubFK2:SetValue( "FK2_IDDOC"	,cChaveFK7 )
							oSubFK2:SetValue( "FK2_ORIGEM"	,Funname() )
							oSubFK2:SetValue( "FK2_TXMOED"	,nTxMoeda)
						Else
							If cCpoTp != 0
								If	oFKA:SeekLine({{'FKA_TABORI',"FK2"}})
									If !oSubFK6:IsEmpty()
										oSubFK6:AddLine()	
										oSubFK6:GoLine( oSubFK6:Length() )	
									Endif	
								
								    oSubFK6:SetValue( "FK6_FILIAL"	,FWxFilial("FK6") )
								    oSubFK6:SetValue( "FK6_IDFK6"	,GetSxEnum("FK6","FK6_IDFK6") )                                                                
								    oSubFK6:SetValue( "FK6_TABORI"	,"FK2" )
								    oSubFK6:SetValue( "FK6_TPDOC"	,cTpDoc )
								    oSubFK6:SetValue( "FK6_VALCAL"	,Iif (nX==4, cCpoTp, xMoeda(cCpoTp, SE2->E2_MOEDA, 1, dDataBase)) )  
								    oSubFK6:SetValue( "FK6_VALMOV"	,Iif (nX==4, cCpoTp, xMoeda(cCpoTp, SE2->E2_MOEDA, 1, dDataBase)) )
								    oSubFK6:SetValue( "FK6_RECPAG"	,"P" )
									oSubFK6:SetValue( "FK6_IDORIG"	,cChaveFK2 )								    
									oSubFK6:SetValue( "FK6_HISTOR"	,"Bx.p/Emissao Fatura" +cFatura ) //"Bx.p/Emiss.Fatura "
								EndIf
							Endif
						EndIf
						
						If !Empty(cCamposE5)
							cCamposE5 += "}"
						Endif
					Next
						
					ABATIMENTO := 0
					oModelBxP:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que ser o gravados independentes de FK5
					
					//Grava os dados
					If oModelBxP:VldData()
						oModelBxP:CommitData()
						nRecSE5 := oModelBxP:GetValue("MASTER","E5_RECNO")
						SE5->(dbGoTo(nRecSE5))
					Else
						lRet := .F.
						cLog := cValToChar(oModelBxP:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModelBxP:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModelBxP:GetErrorMessage()[6])
						Help( ,,"M020VALID",,cLog, 1, 0 )
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - Erro na gravacao do modelo de dados - M020VALID"))
						ConOut(cLog)
					Endif
						
					If lRet 
						//Contabiliza a baixa do titulo
						If lContab530
							If nHdlPrv <= 0
								nHdlPrv := HeadProva( cLote, "FINA290", substr( cUsuario, 7, 6 ), @cArquivo )
							Endif
							
							If lUsaFlag	// Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, { "FK2_LA", "S", "FK2", FK2->( RecNo() ), 0, 0, 0} )
								aAdd( aFlagCTB, {  "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
							EndIf
							
							//Contabiliza pela variavel VALOR. Nao necessita de controle de flag.
							nTotal += DetProva( nHdlPrv, "530", "FINA290" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
												/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
							
							If !lUsaFlag .And. (nTotal > 0)
								oSubFK2:SetValue( "FK2_LA"	, "S" )
							EndIf	
						EndIf
						
						If lPEGrava
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE FI290GE5"))
							Execblock("FI290GE5",.F.,.F.)
						EndIf
						
						//Preenchendo variavel para ponto de entrada
						aadd(aTitSE5,{{"E5_FILIAL"	, SE5->E5_FILIAL	, nil },;
							{"E5_DATA"		, SE5->E5_DATA		, nil },;
							{"E5_VALOR"		, SE5->E5_VALOR		, nil },;
							{"E5_NATUREZ"	, SE5->E5_NATUREZ	, nil },;
							{"E5_RECPAG"	, SE5->E5_RECPAG	, nil },;
							{"E5_TIPO"		, SE5->E5_TIPO		, nil },;
							{"E5_TIPODOC"	, SE5->E5_TIPODOC	, nil },;
							{"E5_HISTOR"	, SE5->E5_HISTOR	, nil },;
							{"E5_PREFIXO"	, SE5->E5_PREFIXO	, nil },;
							{"E5_NUMERO"	, SE5->E5_NUMERO	, nil },;
							{"E5_PARCELA"	, SE5->E5_PARCELA	, nil },;
							{"E5_FORNECE"	, SE5->E5_FORNECE	, nil },;
							{"E5_CLIFOR"	, SE5->E5_CLIFOR	, nil },;
							{"E5_LOJA"		, SE5->E5_LOJA		, nil },;
							{"E5_DTDIGIT"	, SE5->E5_DTDIGIT	, nil },;
							{"E5_MOTBX"		, SE5->E5_MOTBX		, nil },;
							{"E5_VLMOED2"	, SE5->E5_VLMOED2	, nil },;
							{"E5_VLCORRE"	, SE5->E5_VLCORRE	, nil },;
							{"E5_SEQ"		, SE5->E5_SEQ		, nil },;
							{"E5_DTDISPO"	, SE5->E5_DTDISPO	, nil },;
							{"E5_BENEF"		, SE5->E5_BENEF		, nil },;
							{"E5_FILORIG"	, SE5->E5_FILORIG	, nil },;
							{"R_E_C_N_O_"	, SE5->(Recno()), nil }})
						
						//Restauro os valores dos impostos
						If lPccBaixa
							RecLock("SE2")
							SE2->E2_PIS := nOldPis
							SE2->E2_COFINS := nOldCof
							SE2->E2_CSLL := nOldCsl
							MsUnlock()
						Endif
						
						If SED->ED_CALCINS == "S" .and. SA2->A2_RECINSS == "S" .And. lInssBx .And. cPaisLoc = "BRA" //Inss Baixa					         						
							RecLock("SE2")
							SE2->E2_INSS 		:= nOldIns
							SE2->E2_VRETINS 	:= nOldVret
							SE2->E2_PRETINS	:= cOldIns
							MsUnlock()
						Endif			 
							
						aArea := fwGetArea()
						DbSelectArea("SA2")
						SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
						SA2->(RecLock("SA2"))
						nMoedaC 	 := Int(Val(nVarMV_MCUSTO))
						
						If !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM)
							SA2->A2_SALDUP -= Round(NoRound(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
							SA2->A2_SALDUPM-= Round(NoRound(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,nMoedaC,SE2->E2_EMISSAO,3),3),2)
						Else
							SA2->A2_SALDUP += Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
							SA2->A2_SALDUPM+= Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO,3),3),2)
						EndIf
						
						fwRestArea(aArea)
					EndIf
						
					If ValType(oModelBxP) == "O" 
						oModelBxP:DeActivate()
						oModelBxP:Destroy()
					EndIf
					
					oModelBxP:= Nil
					oSubFK2  := Nil 
					oSubFK6  := Nil
					oFKA     := Nil
				EndIf
					
				(cAliasSE2)->(dbSkip())
			Enddo
			
			If lRet
				If lFAT290SE5
					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE FAT290SE5"))
					Execblock("FAT290SE5",.F.,.F.,aTitSE5)
				EndIf
				
				//Posiciono cadastro de fornecedor e natureza 
				//dos titulo a serem gerados pela fatura
				SA2->(dbSelectArea("SA2"))
				SA2->(DBSetOrder(1))
				
				If lLoja
					ConOut("Posiciona SA2 - cForn+cLoja")
					SA2->(MsSeek(xFilial("SA2")+cForn+cLoja))
					_cNomFor := SA2->A2_NREDUZ
				Else
					ConOut("Posiciona SA2 - cFornP+cLojaP")
					SA2->(MsSeek(xFilial("SA2")+cFornP+cLojaP))
					_cNomFor := SA2->A2_NREDUZ
				EndIf
				ConOut("Recno SA2 - " + CValToChar(SA2->(Recno())))
				
				SED->(MsSeek(xFilial("SED")+cNat))
				
				//Somente para compor os valors dos impostos corretamente em cima da Base para a Fatura.	
				If (dDatabase > dLastPcc) .And. SE2->E2_TIPO # MVPAGANT .And. Empty(SE2->E2_NUMBOR) .And. !lEmpPub 
					If lLoja
						aPcc:= newMinPcc(dDataBase,  nBasePCC ,cnat,"P",SE2->E2_FORNECE+SE2->E2_LOJA,,,,, lPCCBaixa )
					Else
						aPcc:= newMinPcc(dDataBase,  nBasePCC ,cnat,"P",cFornP+cLojaP,,,,, lPCCBaixa )
					EndIf			
					
					nPisFat :=   aPcc[2]	
					nCofFat :=   aPcc[3] 
					nCslFat :=   aPcc[4] 
				Endif
				
				nValTotal := 0
				//Recrio as bases e valores de impostos de acordo com as alteracoes efetuadas nas parcelas da fatura
				aBaseFat := aClone(aCols)
				aPisFat := aClone(aCols)
				aCofFat := aClone(aCols)
				aCslFat := aClone(aCols)
				aIrfFat	:= aClone(aCols)
				aISSFat := aClone(aCols)
				aBaseIR	:= aClone(aCols)
				aInsFat	:= aClone(aCols)
	         	aBaseIns	:= aClone(aCols)
				
				//Obtenho a base do IR para esta parcela
				//Primeiro calculo o valor de base de IR Total (soma dos titulos que tem IR)
				//Segundo, aplico o redutor de base de IR sobre a base total.
				// Tenho a base total de IR da Fatura.
				// Proporcionalizo o valor de cada parcela
				//Exemplo
				//Titulo		Valor		BaseIR
				//	A			10.000	10.000
				//	B			10.000	 8.000
				//	C			10.000	     0
				//				------	------
				//Totais		30.000	18.000
				//
				// Valor da Fatura = 30.000
				// Valor dos titulos com IR = 20.000 (Soma de A+B (ignoro a base anterior))
				// --------------------------------------------------------
				//Parcelado em 2x com uma natureza com base IR de 80%
				//
				//Base total de IR com redu  o : (20.000 * 0.8) = 16.000
				//Titulo		Valor		BaseIR
				//	A			15.000	 8.000
				//	B			15.000	 8.000
				//				------	------
				//Totais		30.000	16.000
				// --------------------------------------------------------										
				//Parcelado em 2x com uma natureza com base IR de 100% (sem redutor)
				//
				//Base total de IR = 20.000
				//
				//Titulo		Valor		BaseIR
				//	A			15.000	10.000
				//	B			15.000	10.000
				//				------	------
				//Totais		30.000	20.000
				// -------------------------------------------------------
				//Obtenho o redutor de base do IRPF (natureza da fatura)
				lBaseIRPF  := F050BIRPF(3)
				
				If lIrpfBaixa .and. ( lBaseIrpf .OR. SA2->A2_TIPO == "J" )
					If nBaseIrf > 0
						nBaseIrpf := nBaseIrf
					EndIf
					
		            If nBaseIrpf < nValor
	    	        	nPropIR := nBaseIrpf/nValor
						For nW := 1 to Len(aBaseIR)
							aBaseIR[nW,6]	:= (aBaseIR[nW,6] * nPropIr)
						Next
	      			Endif
					
					nPropIr	:= If (SED->ED_BASEIRF > 0, (SED->ED_BASEIRF/100),1)	
					
					//Reduzo a base do IR para cada parcela 
					//de acordo com a base de IR da natureza da fatura
					If nPropIR < 1
						nBaseIrpf := nBaseIrpf * nPropIr
						For nW := 1 to Len(aBaseIR)
							aBaseIR[nW,6]	:= (aBaseIR[nW,6] * nPropIr)
						Next
					Endif
				Endif
				
				ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - aCols: " + CValToChar(Len(aCols))))
				
				//Acerto os valores de base e impostos de acordo com a nova configuracao do aCols
				For nW := 1 to Len(aCols)
					nProp := aCols[nW,6] / nValor  //Proporcao entre a parcela e o valor total da fatura
					
					If nW < Len(aCols)
						aBaseFat[nW,6]	:= nBasePcc * nProp
						aPisFat[nW,6]	:= nPisFat * nProp
						aCofFat[nW,6]	:= nCofFat * nProp
						aCslFat[nW,6]	:= nCslFat * nProp
						aIrfFat[nW,6]	:= nTotIRPJ * nProp
						aBaseIr[nW,6]	:= nBaseIrpf * nProp					
						aISSFat[nW,6]	:= nISSFat * nProp
						
						aBaseIns[nW,6]:=	nBaseFat * nProp
						aInsFat[nW,6]	:= nInsFat * nProp
						nTotBase	+=	aBaseFat[nW,6]							
						nTotPis	+=	aPisFat[nW,6]
						nTotCof	+=	aCofFat[nW,6]
						nTotCsl	+=	aCslFat[nW,6]
						nTotISS	+= aISSFat[nW,6]
						nTtIRFat+= Round(NoRound(aIrfFat[nW,6],3),2)
						nTotIRF	+= Round(NoRound(aBaseIr[nW,6],3),2)			
						
						nTotIns	+= aInsFat[nW,6]
						nTotBIns	+= Round(NoRound(aBaseIns[nW,6],3),2)								
					Else                                        
						aBaseFat[nW,6] := nBasePcc - nTotBase
						aPisFat[nW,6] := nPisFat - nTotPis
						aCofFat[nW,6] := nCofFat - nTotCof
						aCslFat[nW,6] := nCslFat - nTotCsl
						aISSFat[nW,6] := nISSFat - nTotISS
						aBaseIr[nW,6] := nBaseIrpf - nTotIRF
						aIrfFat[nW,6] := nTotIRPJ - nTtIRFat
						aBaseIns[nW,6]:=	nBaseFat - nTotBIns
						aInsFat[nW,6] := nInsFat - nTotIns
					Endif
				Next
	    		
	    		nVlDesc := nDecres / Len(aCols)
				nSlDesc := nDecres 
	    		nVlAcre := nAcresc / Len(aCols)
		    	nSlAcre := nAcresc
				cCodAprov := ""
				
				If lCtrlAlc
					cCodAprov := FA050Aprov(nMoeda)
				Endif
				
				If lPccBaixa
					If SE2->E2_DIRF=="1"
						lDirf:=.T.
					Else 
						cTitpai:=SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
				     
						BeginSQL Alias "TMPSE2X"
							SELECT E2.E2_DIRF 
							FROM %Table:SE2% E2
							WHERE E2.E2_FILIAL = %xfilial:SE2% AND 
							E2.E2_DIRF  = %exp:"1"% AND
							E2.E2_TITPAI = %exp:cTitpai% AND
							E2.%NotDel%
					
						EndSQL
									
						If TMPSE2X->(! Eof())// Verifica se existem titulos de impostos com Dirf, caso n o exista n o grava o E2_CODRET
							lDirf:=.T. 			
						EndIf  
				
						TMPSE2X->(dbCloseArea())
				
					EndIf 
				EndIf

				ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - aCols: " + CValToChar(Len(aCols))))

				If Len(aCols) == 0
					ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - DisarmTransaction "))
					lMSErroAuto := .T.
					DisarmTransaction()
				EndIf
										      
				For nW:=1 To Len(aCols)
					If ! aCols[nW,Len(aCols[1])]  // .F. == Ativo  .T. == Deletado
						cPrefix	:= aCols[nW][1]
						cParcela 	:= aCols[nW][3]
						cTipo    	:= aCols[nW][4]
						cVencmto 	:= aCols[nW][5]
						nValDup	:= aCols[nW][6]
						nValCruz 	:= xMoeda(aCols[nW,6],nMoeda,1,dDataBase)
						cBanco		:= aCols[nW][7]
						
						//Grava informacoes contabeis obs: a conta partida credito esta contida no fornecedor
						cContaDB := SE2->E2_CONTAD
						
						//Caso o Centro de custo seja igual para todos os titulos, ele ir  manter o Centro de Custo
						//Caso tenha divergencia ele retorna em branco.
						While nI <= Len(aE2CCC)
							If nI <> Len(aE2CCC)
								If aE2CCC[nI] <> aE2CCC[nI+1] 
									cCCC	 := ''
									Exit
								Else
									cCCC	 := SE2->E2_CCC
								EndIf
							ElseIf Len(aE2CCC) == 1
								cCCC	 := SE2->E2_CCC
							EndIF
							nI++
						EndDo	
						
						nI:=1

						//Caso o Centro de custo seja igual para todos os titulos, ele ir  manter o Centro de Custo
						//Caso tenha divergencia ele retorna em branco.
						While nI <= Len(aE2CCD)
							If nI <> Len(aE2CCD)
								If aE2CCD[nI] <> aE2CCD[nI+1] 
									cCCD	 := ''
									Exit
								Else
									cCCD	 := SE2->E2_CCD
								EndIf
							ElseIf Len(aE2CCD) == 1
								cCCD	 := SE2->E2_CCD
							EndIF
							nI++
						EndDo
						
						nI:=1
						
						//Caso o Centro de custo seja igual para todos os titulos, ele ir  manter o Centro de Custo
						//Caso tenha divergencia ele retorna em branco.
						While nI <= Len(aCCUSTO)
							If nI <> Len(aCCUSTO)
								If aCCUSTO[nI] <> aCCUSTO[nI+1] 
									cCCUSTO	 := ''
									Exit
								Else
									cCCUSTO	 := SE2->E2_CCUSTO
								EndIf
							ElseIf Len(aCCUSTO) == 1
								cCCUSTO	 := SE2->E2_CCUSTO
							EndIF
							nI++
						EndDo						
							
						cItemC	 := SE2->E2_ITEMC
						cItemD	 := SE2->E2_ITEMD
						cClVlCR	 := SE2->E2_CLVLCR
						cClVlDB	 := SE2->E2_CLVLDB
						
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - Gravacao do novo Titulo da Fatura - Inicio "))

						//Implantacao da Fatura
						RecLock("SE2",.T.)
						Replace E2_FILIAL 	With xFilial("SE2")
						Replace E2_NUM 		With cFatura
						Replace E2_PARCELA	With cParcela
						Replace E2_PREFIXO	With cPrefix
						Replace E2_NATUREZ	With cNat
						Replace E2_VENCTO 	With cVencmto
						Replace E2_VENCREA	With DataValida(E2_VENCTO,.T.)
						Replace E2_VENCORI	With SE2->E2_VENCTO					
						Replace E2_EMISSAO	With dDatabase
						Replace E2_EMIS1		With dDatabase
						Replace E2_TIPO		With cTipo
						Replace E2_FORNECE 	With IIF(lLoja, cForn, cFornP)
						Replace E2_LOJA		With IIF(lLoja, cLoja, cLojaP)
						Replace E2_VALOR		With nValDup
						Replace E2_SALDO		With nValDup
						Replace E2_MOEDA		With nMoeda
						Replace E2_PORTADO	With cBanco
						Replace E2_FATURA 	With "NOTFAT"
						Replace E2_NOMFOR 	With _cNomFor
						Replace E2_VLCRUZ		With Round(xMoeda(nValDup, nMoeda, 1, dDataBase, MsDecimais(1)+1, nTxFat), 2)
						Replace E2_MULTNAT	With "2"	   
						Replace E2_FILORIG  	With cFilAnt	
						Replace E2_CODAPRO	With cCodAprov	
						Replace E2_DATAAGE 	With DataValida(E2_VENCTO,.T.)
						Replace E2_TXMOEDA 	With nTxFat
						Replace E2_CCC		With cCCC
						Replace E2_CCD		With cCCD
						Replace E2_CCUSTO	With cCCUSTO
						
						//Gestao						
						If !lSE2Compart .and. mv_par06 == 1
							Replace E2_ORIGEM 	With  "FINA290M"
						Else
							Replace E2_ORIGEM 	With  "FINA290"
						Endif
											
						If cVarMV_MRETISS=="2" //Retencao do ISS na baixa
							Replace E2_ISS 		With  aISSFat[nW,6]
							Replace E2_FRETISS 	With  nFRetISS
							Replace E2_TRETISS 	With  nTRetISS
						EndIf
	
						//Gravar campo de base do IRPF
						If lIrpfBaixa .and. lBaseIrpf
							Replace E2_BASEIRF	With aBaseIR[nW,6]
							Replace E2_PRETIRF 	With "1"						
						Endif
						
						If lInssBx //Inss Baixa
							Replace E2_BASEINS	With aBaseIns[nW,6]
							Replace E2_PRETINS 	With "1"
							Replace E2_INSS 		With aInsFat[nW,6]												
						Endif
						
						// Grava o valor do IRPJ	
						If lIrpfBaixa .and. SA2->A2_TIPO == "J" .AND. Len(aIrfFat) > 0
							Replace E2_IRRF 	With aIrfFat[nW,6]
							Replace E2_BASEIRF	With aBaseIR[nW,6]
							Replace E2_PRETIRF 	With "1"
						EndIf
						
						//Impostos Lei 10925 para tratamento na baixa.
						If lPccBaixa .and. (Len(aPisFat)+Len(aCofFat)+Len(aCslFat)> 0 ) .and. ;
							(nW <= Len(aPisFat) .and. nW <= Len(aCofFat) .and. nW <= Len(aCslFat)) .and. ;
							(aPisFat[nW,6]+aCofFat[nW,6]+aCslFat[nW,6] > 0)
							
							Replace E2_PIS		With  aPisFat[nW,6]
							Replace E2_COFINS	With  aCofFat[nW,6]
							Replace E2_CSLL		With  aCslFat[nW,6]
							Replace E2_BASEPIS 	With  aBaseFat[nW,6]
							Replace E2_BASECOF 	With  aBaseFat[nW,6]
							Replace E2_BASECSL	With  aBaseFat[nW,6]
							Replace E2_PRETPIS	With  "1"
							Replace E2_PRETCOF 	With  "1"
							Replace E2_PRETCSL 	With  "1"
						Endif				
						
						// lDirf - necess ria pois podemos ter PCC na Bx e IR na Emissao, isso faz com que o E2_DIRF=="2" e n o podemos gerar cod ret quando n o houver impostos.
						If lPccBaixa .And. lDirf .And. ( SE2->E2_PIS> 0 .Or. SE2->E2_COFINS > 0 .Or. SE2->E2_CSLL > 0 ) 
							Replace E2_CODRET With "5952"						
						Endif
						
						If nDecres > 0
							Replace E2_DECRESC   With Iif(nW == Len(aCols),nSlDesc,nVlDesc)
							Replace E2_SDDECRE   With Iif(nW == Len(aCols),nSlDesc,nVlDesc)
							nSlDesc -= nVlDesc
						EndIf
						
						If nAcresc > 0
							Replace E2_ACRESC    With Iif(nW == Len(aCols),nSlAcre,nVlAcre)
							Replace E2_SDACRES   With Iif(nW == Len(aCols),nSlAcre,nVlAcre)
							nSlAcre -= nVlAcre
						EndIf
						
						If nQtdMark == 1 // Replicar informa ?es somente em caso de Fatura de 1(um) t tulo originador.
							Replace E2_HIST With  cHistFat
							//Grava contas e custos do titulo pai
							Replace E2_CONTAD	With  cContaDB
							Replace E2_ITEMC	With  cItemC
							Replace E2_ITEMD	With  cItemD
							Replace E2_CLVLCR	With  cClVlCR
							Replace E2_CLVLDB	With  cClVlDB
						ElseIf lFA290HPAD
							Replace E2_HIST		With  cHistFat
						EndIf
						
						//Atualiza Flag de Lancamento contabil
						If lPadrao 
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, { "E2_LA", "S", "SE2", SE2->( RecNo() ), 0, 0, 0} )
							Else	
								SE2->E2_LA := "S"
							EndIf
						EndIf
						
						//Documentos 
						IF lFinVDoc
							If Len(aDocsOri) > 0
								SE2->E2_TEMDOCS := "1"
							EndIf
						EndIf
						
						SE2->(MsUnlock())

						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - Gravacao do novo Titulo da Fatura - Fim "))

						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - AtuSldNat - Inicio "))
						
						// Somo o saldo do vencimento programado do titulo
						AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "+",,FunName(),"SE2",SE2->(Recno()),nOpcE)
						
						ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - AtuSldNat - Fim "))

						DbSelectArea("SA2")
						SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
						SA2->(RecLock("SA2"))
						nMoedaC 	 := Int(Val(nVarMV_MCUSTO))
						
						If !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM)
							SA2->A2_SALDUP += Round(NoRound(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
							SA2->A2_SALDUPM+= Round(NoRound(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,nMoedaC,SE2->E2_EMISSAO,3),3),2)
						Else
							SA2->A2_SALDUP -= Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2)
							SA2->A2_SALDUPM-= Round(NoRound(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO,3),3),2)
						EndIf
						
						If lLoja                                                                                               
						 	Posicione("SE2",6,xFilial("SE2")+cForn+cLoja+cPrefix+cFatura+cParcela,"E2_NUM")
						Else
							Posicione("SE2",1,xFilial("SE2")+cPrefix+cFatura+cParcela+cTipo+cFornP,"E2_NUM")
						EndIf
						
						If lFA290
							ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE FA290"))
							ExecBlock("FA290",.f.,.f.)
						Endif
			         	
			         	nValTotal += xMoeda(nValDup,nMoeda,1,dDataBase)  // nValCruz
						
						IF lPadrao
							If nHdlPrv <= 0
								nHdlPrv := HeadProva( cLote, "FINA290", substr( cUsuario, 7, 6 ), @cArquivo )
							Endif
							
							VALOR := 0
							//Contabiliza pela variavel VALOR. Nao necessita de controle de flag.
							nTotal += DetProva( nHdlPrv, cPadrao, "FINA290" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/,;
							                    /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
						EndIf
						
						dbSelectArea("SE2")
						//Grava os lancamentos nas contas orcamentarias SIGAPCO
						PcoDetLan("000015","01","FINA290")
						
						//Rastreamento - Gerados
						If lRastro
							aadd(aRastroDes,{	SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALOR } )
						Endif
						                         
						//Documentos 
						IF lFinVDoc
							If Len(aDocsOri) > 0
								aAdd(aDocsDes,{SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA } )
							EndIf
						EndIf
					Endif
				Next nW
				
				//Gravacao do rastreamento
				If lRastro
					FINRSTGRV(2,"SE2",aRastroOri,aRastroDes,nValTotal) 
				Endif
				
				If Len(aDocsOri) > 0
					CN062GrvFat(aDocsOri,aDocsDes)
				EndIf
			Else
				ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - DisarmTransaction "))
				DisarmTransaction()	
			EndIf
		End Transaction
		
		If nTotal > 0
			dbSelectArea("SE2")
			nRecSe2 := Recno()
			SE2->(DBGoBottom())
			SE2->(dbSkip())
			VALOR := nValTotal
			
			//Contabiliza pela variavel VALOR. Nao necessita de controle de flag.
			nTotal += DetProva( nHdlPrv, cPadrao, "FINA290" /*cPrograma*/, cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/,;
			                    /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
			
			RodaProva(  nHdlPrv, nTotal )
			
			//Envia para Lancamento Contabil
			lDigita := IIf( mv_par02 == 1, .T., .F. )
			
			cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita, .F., /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/ )
			
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			VALOR := 0        
			dbSelectArea("SE2")
			SE2->(DBGoTo(nRecSe2))			
		Endif
		
	Endif
Else
	MsUnlockAll()
Endif

//If !Empty(aChaveLbn)
  //	aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
//Endif

cFatura	 := CRIAVAR("E2_FATURA")
cForn 	 := CriaVar("A2_COD")
cNat		 := Space(10)
cPrefix 	 := CRIAVAR("E2_PREFIXO",.T.)
cLoja 	 := CriaVar("A2_LOJA")
dDataDe	 := dDatabase
dDataAte  := dDatabase
nValorFat := 0
aVlCruz	 := {}

//Recupera a Integridade dos dados
FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()

dbSelectArea("SE2")

DbSelectArea(cAliasSe2)
DbCloseArea()

//Deleta tabela tempor ria criada no banco de dados
If _oFina2901 <> Nil
	_oFina2901:Delete()
	_oFina2901 := Nil
Endif

//Gestao
For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next

// Restaura indice original do SE2 que foi selecionado no Browse
dbSelectArea("SE2")
SE2->(dbSetOrder(nIndSE2)) 
SE2->(dbGoto(nRecnoSE2))

//Finaliza integracao com Modulo PCO
PcoFinLan("000015")

Return (nOpca == 1)


Static Function MenuDef()
Local aRotina := { { OemToAnsi("Pesquisar"),"AxPesqui"  , 0 , 1,,.F. },; //"Pesquisar"
	{ OemToAnsi("Visualizar"),"FA050Visua"  , 0 , 2 },; //"Visualizar"
	{ OemToAnsi("Selecionar"),"FA290Aut"    , 0 , 3 },; //"Selecionar"
	{ OemToAnsi("Cancelar"),"FA290Can"    , 0 , 6 },; //"Cancelar"
	{ OemToAnsi("Legenda"),"FA040Legenda", 0 , 7,,.F.}}// "Legenda"	
Return(aRotina)  

Static Function Fa290MotBx(cMot,cNomMot, cConfMot)
	Local lMotBxEsp	:= .F.
	Local aMotbx 	:= ReadMotBx(@lMotBxEsp)
	Local nHdlMot	:= 0
	Local I			:= 0
	Local cFile 	:= "SIGAADV.MOT"
	Local nTamLn	:= 19

	If lMotBxEsp
		nTamLn	:= 20
		cConfMot	:= cConfMot + "N"
	EndIf
/*	If lFILEMOT
		cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
	Endif   */
	
	If Ascan(aMotbx, {|x| Substr(x,1,3) == Upper(cMot)}) < 1
		nHdlMot := FOPEN(cFile,FO_READWRITE)
		If nHdlMot <0
			HELP(" ",1,"SIGAADV.MOT")
			Final("SIGAADV.MOT")
		Endif
		
		nTamArq:=FSEEK(nHdlMot,0,2)	// VerIfica tamanho do arquivo
		FSEEK(nHdlMot,0,0)			// Volta para inicio do arquivo

		For I:= 0 to  nTamArq step nTamLn // Processo para ir para o final do arquivo	
			xBuffer:=Space(nTamLn)
			FREAD(nHdlMot,@xBuffer,nTamLn)
	    Next		
		
		fWrite(nHdlMot,cMot+cNomMot+cConfMot+chr(13)+chr(10))	
		fClose(nHdlMot)		
	EndIf	
Return

/*/{Protheus.doc} F290VlCpos
Fun??o para varrer os campos preenchidos em busca de caracteres especiais
@author TOTVS S/A
@since 14/07/2014
@version P1180
@return Retorno Booleano da valida??o dos dados
/*/ 
Static Function F290VlCpos(aCps)
Local nX := 1
Local lOk := .T.
Local xCampo

Default aCps := {"cPrefix","cFatura"}

Do While nX <= Len(aCps) .And. lOk
	xCampo := &(aCps[nX])
	If !Empty(xCampo) .And. ValType(xCampo) == "C" 
		If CHR(39) $ xCampo	 .Or. ;
	       CHR(34) $ xCampo	
			lOk := .F.
		Endif		
	Endif	
	nX++
Enddo 
If !lOk
   Help("",1,"INVCAR",,"Informe Caracteres Validos no Preenchimento dos Campos",1,0) //"Informe caracteres v?lidos no preenchimento dos campos"
Endif

Return lOk


STATIC Function fa290Marca(cAlias,cMarca,nLimite,lPccBaixa,lBaseSE2,aChaveLbn,aFatPag)
 
LOCAL nRec
Local cAliasAnt := Alias()
Local lMarkTit  := .t.
//Local nPosChave:= 0
Local cChaveLbn
Local nAbatim := 0
Local aChaveTit := {}
//Local nJuros	 := 0

Default aFatPag   := {}
dbSelectArea(cAlias)
nRec := Recno()
While !Eof()
	cChaveLbn := "FAT" + (cAlias)->(xFilial("SE2")+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
	//?????????????????????????????????????????????????????????????????
	//? PONTO DE ENTRADA F290TIT                                       ?
	//? Verifica se titulo pode ser marcado para compor a Fatura,      ?
	//? caso tenha sido alterada a marca??o do titulo, ExecBlock       ?
	//? dever? retornar .F., para n?o haver altera??o dos acumuladores ?
	//? de valores e numero de titulos.                                ?
	//??????????????????????????????????????????????????????????????????
	If Len(aFatPag) > 0
		lMarkTit := .T.
	EndIf
	If lF290Tit
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | MY290FI - PE F290TIT"))
		lMarkTit := ExecBlock("F290TIT",.F.,.F.,{.T.})
	Endif
   //	If LockByName(cChaveLbn,.T.,.F.)
		If  .T.//SE2->(MsRLock()) .And. RecLock(cAlias) // Se conseguir travar o registro          
			If lMarkTit .And. Len(aFatPag) > 0 
				nPosFat := Ascan(aFatPag[13],{ | e | e[1]+e[2]+e[3]+e[4]+ if(len(e)>=6,e[6]+e[7],"")== (cAlias)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+ if(len(e)>=6,E2_FORNECE+E2_LOJA,""))})
				If nPosFat > 0
					aFatPag[13,nPosFat,5] := .T.
				Else
					lMarkTit := .F.
				EndIf
			EndIf
			If lMarkTit
				If	(nValor <= nLimite .Or. Empty(nLimite)) //.and. (cAlias)->(MsRLock()) // Se conseguir travar o registro
					(cAlias)->E2_OK := cMarca
				   //	If Ascan(aChaveLbn, cChaveLbn) == 0
					 //	Aadd(aChaveLbn,cChaveLbn)
					//Endif
					If E2_TIPO $ MV_CPNEG+"/"+MVABATIM
						nValor	-= E2_SALDO+E2_SDACRES-E2_SDDECRE
						nValCruz -= E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE,E2_MOEDA,1,E2_EMISSAO,3),3),2)
						nQtdTit++
					Else
						If (cAlias)->CALCULADO == '1'
							nAbatim	:= (cAlias)->ABATSOMADO
						Else
							nAbatim	:= SumAbatPag(E2_PREFIXO,E2_NUM,E2_PARCELA,E2_FORNECE,E2_MOEDA,"S",,E2_LOJA)
							(cAlias)->CALCULADO := '1'
						EndIf

						//Tratamento para os t?tulos que possuem a mesma chave, com exce??o do tipo, o sistema considera o mesmo abatimento para ambos
						If nAbatim > 0
							If aScan( aChaveTit , E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA ) > 0
								nAbatim := 0
							Else
								aAdd( aChaveTit , E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA )
								ABATSOMADO := nAbatim
							EndIf
						EndIf

						nTitAbats += nAbatim
						nValor   += (E2_SALDO+E2_SDACRES-E2_SDDECRE) - nAbatim
						nValCruz += E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE,E2_MOEDA,1,E2_EMISSAO,3),3),2) - nAbatim
						nQtdTit++
					EndIf
				Endif
			Endif

		Else
		   //	UnlockByName(cChaveLbn, .T., .F.)
		//	nPosChave:= Ascan(aChaveLbn, cChaveLbn)
		//	If nPosChave >0
		  //		aDel(aChaveLbn,nPosChave)
			//	aSize(aChaveLbn,Len(aChaveLbn)-1)
			//Endif
		EndIf
   //	EndIf
	dbSkip()
	SE2->(dbGoto((cAlias)->Recno))
EndDo

dbGoto(nRec)
SE2->(dbGoto((cAlias)->Recno))
dbSelectArea(cAliasAnt)
Return
