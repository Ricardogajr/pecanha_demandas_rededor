#include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"
#Include 'Totvs.ch'
#include "fina473a.ch"

Static __aRecCtb := {}

/*
{Protheus.doc}  FINA473a()
Ponto de entrada criado para a opção de efetivação automática na conciliação automática.
@Author  Ramon Teodoro e Silva	
@Since   27/11/2018       
@Version P12.7
*/

User Function FINA473a()

Local aArea    := GetArea()
Local xRet     := .T.
Local aParam   := Paramixb
Local cIdPonto := ''
Local aColsIG  := {}
Local aHeadIG  := {}
	
If aParam <> NIL
		
	cIdPonto   := aParam[2]
	If  cIdPonto == "BUTTONBAR"
		
		aHeadIG := aParam[1]:aAllSubModels[2]:aHeader
		aColsIG := aParam[1]:aAllSubModels[2]:aDataModel
		xRet := {}
		Aadd( xRet, {'Efetivação Automática', 'EFETIVA AUT.',  { || U_EftAuto(aHeadIG, aColsIG, aParam[1]) }, 'Faz a efetivação de todos os registros automaticamente.' } )
		Aadd( xRet, {'Cancela Efetiv. Aut.' , 'CANCEFET AUT.', { || U_CancEft(aParam[1]) }, 'Cancela a efetivação automática.' } )
		
	Endif

EndIf

RestArea(aArea)
Return xRet

/*
{Protheus.doc}  EftAuto()
Função que faz a efetivação automática na tela de Conciliação Automática
@Author  Ramon Teodoro e Silva	
@Since   27/11/2018       
@Version P12.7
*/

User Function EftAuto(aHeadIG, aColsIG, aParam)

Local nLn       := 0
Local cOcNat    := ""
//Local cBco      := ""
Local lRet      := .T.
Local cDC       := ""
Local nValorLan := 0
Local lAchou 	:= .F.

Local nPosPro := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_IDPROC"})
Local nPosOcr := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_TIPEXT"})
Local nPosSts := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_STATUS"})
Local nPosVln := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_VLREXT"})
Local nPosDC  := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_CARTER"})
Local nPosDTx := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_DTEXTR"}) 
Local nPosTpM := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_TIPMOV"})
Local nPosDoc := Ascan(aHeadIG,{|x|Alltrim(x[2])=="IG_DOCEXT"})

Local cBanco := aParam:aAllSubModels[1]:aDataModel[1][2][2]
Local cAgenc := aParam:aAllSubModels[1]:aDataModel[1][3][2]
Local cConta := aParam:aAllSubModels[1]:aDataModel[1][4][2]

For nLn := 1 to Len(aColsIG)

	SE5->(DbSetOrder(13))
	
	nValorLan := aColsIG[nLn][1][1][nPosVln]
	lAchou := .F.
	
	If aColsIG[nLn][1][1][nPosSts] == "1" .And. !Empty(nValorLan)
		
		cDC	     := IIF( aColsIG[nLn][1][1][nPosDC] == "1","R","P")
		dDataExt := aColsIG[nLn][1][1][nPosDtx]
		cDocExt  := aColsIG[nLn][1][1][nPosDoc]
		cTipoSis := aColsIG[nLn][1][1][nPosTpM]  
				
		If SE5->(DbSeek(xFilial("SE5")+ cBanco  +DtoS(dDataExt) + cConta + cAgenc ))
		
			While SE5->(!EOF()) .and. DTOS(SE5->E5_DTDISPO) == DTOS(dDataExt)
				cRecPagE5 := SE5->E5_RECPAG
	
				IF !Empty(cDocExt) .and. cTipoSis $ "CHQ" .and. Alltrim(SE5->E5_NUMCHEQ) == Alltrim(cDocExt) .and. cRecPagE5 == cDC
					Help(" ",1,"A470EXIST")
					lAchou := .T.
					Exit
				Endif
	
				If SE5->E5_VALOR == nValorLan .and. Empty(SE5->E5_NUMCHEQ) .and. cRecPagE5 == cDC .And. SE5->E5_SITUACA != "C"
	
				/*	DEFINE MSDIALOG oDlg3 FROM  69,90 TO 220,400 TITLE  STR0062 PIXEL  //"Efetivação de Lançamento no SE5"
					@ 00 , 03 TO 55, 152 OF oDlg4 PIXEL
					@ 10 , 10 SAY  "Existe lançamento semelhante em Data, Valor e Carteira."  SIZE 140, 7 OF oDlg3 PIXEL  
					@ 20 , 10 SAY  "no seu arquivo de movimentos bancários.	Em caso de     "  SIZE 140, 7 OF oDlg3 PIXEL  //
					@ 30 , 10 SAY  "dúvida, não efetive o lançamento, pois poder  gerar    "  SIZE 140, 7 OF oDlg3 PIXEL  //
					@ 40 , 10 SAY  "duplicidade. Deseja efetivar este lançamento ?		   "  SIZE 140, 7 OF oDlg3 PIXEL  //"
					DEFINE SBUTTON FROM 60, 50 TYPE 1 ENABLE ACTION (nOpcaE:=1,oDlg3:End()) OF oDlg3
					DEFINE SBUTTON FROM 60, 80 TYPE 2 ENABLE ACTION (nOpcaE:=2,oDlg3:End()) OF oDlg3
		
					ACTIVATE MSDIALOG oDlg3 CENTERED
	
					If nOpcaE == 1
						lAchou := .F.
					Else
						lAchou := .T.
					Endif*/
					lAchou := .T.
					Exit
				Endif
				SE5->(DbSkip())
			End
		EndIf
	
		If !lAchou
			
			//cBco   := Posicione("SIF", 1, xFilial("SIF")+aColsIG[nLn][1][1][nPosPro], "IF_BANCO")
			cOcNat := Posicione("SEJ", 1, xFilial("SEJ")+cBanco +aColsIG[nLn][1][1][nPosOcr], "EJ_XNATUR")
		
			If !Empty(cOcNat)
				aParam:aAllSubModels[2]:nLine := nLn
				FA473GrvEf(cOcNat,"","","","","","","","","",aParam)
			Else
				MsgAlert("A ocorrência: " + aColsIG[nLn][1][1][nPosOcr] + " não possui natureza cadastrada.", "Movimento não efetivado" )
			EndIf
	
		EndIf 
		
	Else
		Help(" ",1,"A470JA_REC")
	EndIf
		
Next nLn

Return lRet

/*
{Protheus.doc}  EftAuto()
Cancela a efetivação automática
@Author  Ramon Teodoro e Silva	
@Since   27/11/2018       
@Version P12.7
*/

User Function CancEft(aParam)

Local lRet := .T.
Local nOpca1 		:= 0
Local oDlg1		:= Nil
Local oModel		:= aParam //FWModelActive()
Local oModelCab	:= oModel:getModel('CONMASTER')
Local oModelDet	:= oModel:getModel('CONDETAIL')
Local aSaveLines	:= FWSaveRows()
Local lEfetiva	:= oModelDet:GetValue("IG_EFETIVA") == '1'
Local nRecSE5		:= oModelDet:GetValue("RECSE5")
Local lAtuSldNat := .T.
Local aArea		:= GetArea()
Local aAreaSE5	:= SE5->(GetArea())
Local cFilX		:= cFilAnt
Local lContab	 	:= .F.
Local oModelMov
Local cLog := ""
Local lRet := .T.
Local oSubFKA
Local oSubFK5
Local cCamposE5 := ""

Local nLm := 0

DbSelectArea("SE5")

For nLm := 1 to Len(oModel:aAllSubModels[2]:aDataModel)
	
	oModel:aAllSubModels[2]:GoLine(nLm)
	
	lEfetiva := oModelDet:GetValue("IG_EFETIVA") == '1'
	nRecSE5	 := oModelDet:GetValue("RECSE5")
	cFilAnt  := oModelDet:GetValue("IG_FILORIG")
	
	If lEfetiva
		
		SE5->(DbGoto(nRecSE5))
		
		cCamposE5 += "{"
		cCamposE5 += "{'E5_RECONC', ''}"																	
		cCamposE5 += "}"
				
		oModelMov := FWLoadModel("FINM030") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
		oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
		oModelMov:Activate()
		oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5				
		oModelMov:SetValue( "MASTER", "E5_OPERACAO", 1 ) //E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
		
		//Posiciona a FKA com base no IDORIG da SE5 posicionada
		oSubFKA := oModelMov:GetModel( "FKADETAIL" )
		oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
		
		//Dados do movimento
		oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )
		oSubFK5:SetValue( "FK5_DTCONC", CTOD("") )
		oSubFK5:SetValue( "FK5_SEQCON", "" )
	
		If oModelMov:VldData()
	       	oModelMov:CommitData()
	       	oModelMov:DeActivate()
		Else
			lRet := .F.
		    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		    cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	
	   
	       	Help( ,,"MF473CANEF",,cLog, 1, 0 )	
		Endif					
		
		If lRet
		
			//Atualiza saldo bancario quando da efetivação de movimento 
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,IIF(SE5->E5_RECPAG == "R","-","+"),.T.,.T.)
		
			If lAtuSldNat
				AtuSldNat(SE5->E5_NATUREZ, SE5->E5_DATA, "01", "3", SE5->E5_RECPAG, SE5->E5_VALOR, 0, "-",,FunName(),"SE5", SE5->(Recno()),0)
			Endif
			
			FWModelActive (oModelDet)
	
			oModelDet:LoadValue("IG_VLRMOV",0)
			oModelDet:LoadValue("IG_DTMOVI",CTOD(""))
			oModelDet:LoadValue("IG_DOCMOV",SPACE(TamSx3("IG_DOCMOV")[1]))
			oModelDet:LoadValue("IG_AGEMOV",SPACE(TamSx3("IG_AGEMOV")[1]))
			oModelDet:LoadValue("IG_CONMOV",SPACE(TamSx3("IG_CONMOV")[1]))
			cCor := F473COR("1")
			oModelDet:LoadValue("IG_STATUS","1")
			oModelDet:LoadValue("COR",cCor)
			oModelDet:LoadValue("RECSE5",0 )
			oModelDet:LoadValue("IG_HISMOV",SPACE(TamSx3("IG_HISMOV")[1]))
			oModelDet:LoadValue("IG_NATMOV",SPACE(TamSx3("IG_NATMOV")[1]))
			oModelDet:LoadValue("IG_EFETIVA",SPACE(TamSx3("IG_EFETIVA")[1]))
			oModelDet:LoadValue("DESCONC","1")
			
			SE5->(DbGoto(nRecSE5))
			
			//Verifica se gera lancamento na contabilidade.	
			If SE5->E5_RECPAG =="R"
				cPadrao:= "565"
				If VerPadrao(cPadrao)
					lContab:=.T.
				EndIf
			Else
				cPadrao:= "564"
				If VerPadrao(cPadrao)
					lContab:=.T.
				EndIf
			EndIf
		                
			If lContab
				aAdd(__aRecCTB,{nRecSE5 ,cPadrao, SE5->E5_FILORIG })
			EndIf
		Endif
	
	Else
	//	Help(" ",1,"FIN473CAN",,"Esse registro não foi efetivado pela rotina de Reconciliação Bancária.", 1, 0 )//
	EndIf

Next nLm

cFilAnt := cFilX

FWRestRows(aSaveLines)
FI473ACTMD(oModel)

RestArea(aAreaSE5)
RestArea(aArea)


Return lRet

Static Function FA473GrvEf(cNaturEfet,cCCC,cCCD,cItemD,cItemC,cClVlDb,cClVlCr,cCCrd,cCDeb,cHistor,oModel)
Local nValorMov  := 0
Local nRecno	 := 0
Local lRet		 := .T.
Local lAtuSldNat := .T.
Local oModelAux  := FWModelActive()
Local oModelCab	 := oModel:getModel('CONMASTER')
Local oModelDet	 := oModel:getModel('CONDETAIL')
Local cBanco     := oModelCab:GetValue("BANCO")
Local cAgencia   := oModelCab:GetValue("AGENCIA")
Local cConta     := oModelCab:GetValue("CONTA")
Local cTipoSist	 := oModelDet:GetValue("IG_TIPMOV")
Local cDC        := IIf(oModelDet:GetValue("IG_CARTER") == "1","R","P")
Local dDataExt	 := oModelDet:GetValue("IG_DTEXTR")
Local aAreaSE5	 := SE5->(GetArea())
Local aArea		 := GetArea()
Local cPadrao    := "563"
Local aSaveLines := FWSaveRows()
Local lGeraLanc	 := oModelCab:GetValue('CTBONLINE') == "1"
Local oModelMov  := FWLoadModel("FINM030")
Local oSubFKA    := Nil
Local oSubFK5    := Nil
Local oSubFK8    := Nil
Local cLog       := ""
Local cCamposE5  := ""
Local lIntPFS    := SuperGetMV("MV_JURXFIN",,.F.) // Integração SIGAPFS x SIGAFIN

nValorMov := oModelDet:GetValue("IG_VLREXT")

//Grava Movimentacao da efetivacao no SE5
If lRet
	//Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
	cCamposE5 := "{"
	cCamposE5 += "{'E5_VENCTO', STOD('" + DToS(dDataExt) + "')}"
	cCamposE5 += ",{'E5_DTDIGIT', STOD('" + DToS(dDataExt) + "')}"
	cCamposE5 += "}"

	oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
	oModelMov:Activate()
	oModelMov:SetValue( "MASTER", "E5_GRV", .T. )
	oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
	oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo

	//Dados do Processo
	oSubFKA := oModelMov:GetModel("FKADETAIL")
	oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
	oSubFKA:SetValue( "FKA_TABORI", "FK5" )

	//Dados do Movimento
	oSubFK5 := oModelMov:GetModel("FK5DETAIL")
	oSubFK5:SetValue( "FK5_BANCO", cBanco )
	oSubFK5:SetValue( "FK5_AGENCI", cAgencia )
	oSubFK5:SetValue( "FK5_CONTA", cConta )
	oSubFK5:SetValue( "FK5_DATA", dDataExt )
	oSubFK5:SetValue( "FK5_TPDOC", "DH" )
	oSubFK5:SetValue( "FK5_DTDISP", dDataExt )
	oSubFK5:SetValue( "FK5_HISTOR", IIf( Empty(cHistor), oModelDet:GetValue("IG_HISTEXT"), cHistor ) )
	oSubFK5:SetValue( "FK5_VALOR", nValorMov )
	oSubFK5:SetValue( "FK5_NATURE", cNaturEfet )
	oSubFK5:SetValue( "FK5_MOEDA", IIf(cTipoSist == "CHQ", "C1", "M1"))
	oSubFK5:SetValue( "FK5_RECPAG", cDC )
	oSubFK5:SetValue( "FK5_FILORI", cFilAnt )
	oSubFK5:SetValue( "FK5_ORIGEM", FunName() )

	//Verifica se o movimento ‚ referente a um cheque e grava nro do cheque.
	If cTipoSist $ "CHQ"
		oSubFK5:SetValue( "FK5_NUMCH", oModelDet:GetValue("IG_DOCEXT") )
	EndIf

	//Dados Contábeis
   	oSubFK8 := oModelMov:GetModel("FK8DETAIL")
	oSubFK8:SetValue( "FK8_DEBITO", cCDeb )
	oSubFK8:SetValue( "FK8_CREDIT", cCCrd )
	oSubFK8:SetValue( "FK8_CCD", cCCD )
	oSubFK8:SetValue( "FK8_CCC", cCCC )
	oSubFK8:SetValue( "FK8_ITEMD", cItemD )
	oSubFK8:SetValue( "FK8_ITEMC", cItemC )
	oSubFK8:SetValue( "FK8_CLVLDB", cClVlDb )
	oSubFK8:SetValue( "FK8_CLVLCR", cClVlCr )

	If oModelMov:VldData()
       	oModelMov:CommitData()
       	oModelMov:DeActivate()
	Else
		lRet := .F.
	    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
	    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
	    cLog += cValToChar(oModelMov:GetErrorMessage()[6])
    	Help( ,,"MF473GRVEF",,cLog, 1, 0 )
	EndIf

	If lRet
		nRecno:=SE5->(Recno())

		If Existblock("F473EFGR")
			 ExecBlock( "F473EFGR", .F., .F. ,nRecno)
		EndIf

		//Integração com SIGAPFS x SIGAFIN
		If lIntPFS .And. FindFunction("JurConBco")
			JurConBco(nRecno, cNaturEfet, oModelDet:GetValue("IG_SEQMOV"), cBanco, cAgencia, cConta, cDC, dDataExt, nValorMov, cHistor)
		EndIf

		//Atualiza saldo bancario quando da efetivação de movimento
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,IIf(SE5->E5_RECPAG == "R","+","-"))

		If lAtuSldNat
			AtuSldNat(SE5->E5_NATUREZ, SE5->E5_DATA, "01", "3", SE5->E5_RECPAG, SE5->E5_VALOR, 0, "+",,FunName(),"SE5", SE5->(Recno()),0)
		EndIf

		oModelDet:LoadValue("IG_VLRMOV",SE5->E5_VALOR)
		oModelDet:LoadValue("IG_DTMOVI",SE5->E5_DTDISPO)
		oModelDet:LoadValue("IG_DOCMOV",SE5->E5_NUMCHEQ)
		oModelDet:LoadValue("IG_AGEMOV",SE5->E5_AGENCIA)
		oModelDet:LoadValue("IG_CONMOV",SE5->E5_CONTA)
		cCor := F473COR("3")
		oModelDet:LoadValue("IG_STATUS","3")
		oModelDet:LoadValue("COR",cCor)
		oModelDet:LoadValue("RECSE5",nRecno )
		oModelDet:LoadValue("IG_HISMOV",SE5->E5_HISTOR)
		oModelDet:LoadValue("IG_NATMOV",SE5->E5_NATUREZ)
		oModelDet:LoadValue("IG_EFETIVA","1")

		//Verifica se gera lancamento na contabilidade.
		If SE5->E5_RECPAG != "R"
			cPadrao := "562"
		EndIf

		If lGeraLanc .And. VerPadrao(cPadrao)
			AAdd(__aRecCTB, {nRecno, cPadrao, cFilAnt})
		EndIf
	EndIf

	oModelAux:Activate()
EndIf

SE5->(RestArea(aAreaSE5))
RestArea(aArea)
FWRestRows(aSaveLines)
FI473ACTMD(oModel)
Return .T.

Static Function FI473ACTMD(oModel,lFirst)
Local aSaveLines:= FWSaveRows()
Local oMdCab	:= oModel:GetModel("CONMASTER")
Local oMdItem	:= oModel:GetModel("CONDETAIL")
Local oMdTotRec	:= oModel:GetModel("TOTREC")
Local oMdTotPag	:= oModel:GetModel("TOTPAG")
Local oMdTotSal	:= oModel:GetModel("TOTSAL")
Local nLinha	:= 0
Local nItErro	:= 0
Local lRet		:= .T.
Local cBanco	:= oMdCab:GetValue("BANCO")
Local cAgencia	:= oMdCab:GetValue("AGENCIA")
Local cConta	:= oMdCab:GetValue("CONTA")
Local dDataIni	:= oMdCab:GetValue("DATADE")
Local dDataFim  := oMdCab:GetValue("DATAATE")
Local aSaldos	:= {}
Local aTotRec := {}
Local aTotPag := {}
Local aTotSal := {}
Local nTimer  := 0
Local oTimer  := Nil
Local nQtdMov := 0

Default lFirst := .F.

AAdd(aTotRec,{STR0012,0})//"Documentos a Conciliar"
AAdd(aTotRec,{STR0013,0})//"Valor a Conciliar"
AAdd(aTotRec,{STR0014,0})//"Documentos Conciliados"
AAdd(aTotRec,{STR0015,0})//"Valor Conciliado"


AAdd(aTotPag,{STR0012,0})//"Documentos a Conciliar"
AAdd(aTotPag,{STR0013,0})//"Valor a Conciliar"
AAdd(aTotPag,{STR0014,0})//"Documentos Conciliados"
AAdd(aTotPag,{STR0015,0})//"Valor Conciliado"

AAdd(aTotSal,{STR0016,0})//"Saldo Anterior(Bancário) "
AAdd(aTotSal,{STR0017,0})//"Saldo Anterior(Reconciliado)"
AAdd(aTotSal,{STR0018,0})//"Saldo Atual(Bancário) "
AAdd(aTotSal,{STR0019,0})//"Saldo Atual(Reconciliado)"

If (nQtdMov := oMdItem:Length()) > 0
	If __lMetric
		oTimer:= FwMarkTimer():New()
		oTimer:StartTimer()
	EndIf
	
	For nLinha := 1 to nQtdMov
		oMdItem:GoLine( nLinha )
		If !oMdItem:IsDeleted()
			If oMdItem:GetValue("IG_CARTER") == "1" .And. oMdItem:GetValue("IG_STATUS") != "1"
				aTotRec[3][2] += 1 									// Documentos Conciliados
				aTotRec[4][2] += oMdItem:GetValue("IG_VLREXT")		// Valor Conciliado
			ElseIF oMdItem:GetValue("IG_CARTER") == "2" .And. oMdItem:GetValue("IG_STATUS") != "1"
				aTotPag[3][2] += 1 									// Documentos Conciliados
				aTotPag[4][2] += oMdItem:GetValue("IG_VLREXT")		// Valor Conciliado
			EndIf

			If oMdItem:GetValue("IG_CARTER") == "1" .And. oMdItem:GetValue("IG_STATUS") == "1"
				aTotRec[1][2] += 1 									// Total de Documentos
				aTotRec[2][2] += oMdItem:GetValue("IG_VLREXT")		// Total Conciliado
			ElseIF oMdItem:GetValue("IG_CARTER") == "2" .And. oMdItem:GetValue("IG_STATUS") == "1"
				aTotPag[1][2] += 1 									// Total de Documentos
				aTotPag[2][2] += oMdItem:GetValue("IG_VLREXT")		// Total Conciliado
			EndIf
		EndIf
	Next nLinha
EndIf

//Carregando o Modelo
If oMdTotRec:Length() < 3
	For nLinha := 1 To Len( aTotRec )
		If nLinha > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oMdTotRec:AddLine(.T.) ) != nLinha
				lRet    := .F.
				Exit
			EndIf
		EndIf
		oMdTotRec:LoadValue( "TEXTO" , Left(aTotRec[nLinha][1],23) )
		oMdTotRec:LoadValue( "VALOR" , aTotRec[nLinha][2] )
	Next nLinha
Else
	For nLinha := 1 To Len( aTotRec )
		oMdTotRec:GoLine(nLinha)
		oMdTotRec:LoadValue( "TEXTO" , Left(aTotRec[nLinha][1],23) )
		oMdTotRec:LoadValue( "VALOR" , aTotRec[nLinha][2] )
	Next nLinha
EndIf

If oMdTotPag:Length() < 3
	For nLinha := 1 To Len( aTotPag )
		If nLinha > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oMdTotPag:AddLine(.T.) ) != nLinha
				lRet    := .F.
				Exit
			EndIf
		EndIf
		oMdTotPag:LoadValue( "TEXTO" , Left(aTotPag[nLinha][1],23) )
		oMdTotPag:LoadValue( "VALOR" , aTotPag[nLinha][2] )
	Next nLinha
Else
	For nLinha := 1 To Len( aTotPag )
		oMdTotPag:GoLine(nLinha)
		oMdTotPag:LoadValue( "TEXTO" , Left(aTotPag[nLinha][1],23) )
		oMdTotPag:LoadValue( "VALOR" , aTotPag[nLinha][2] )
	Next nLinha
EndIf

If oMdTotSal:Length() < 4
	//Saldos
	aSaldos := FI473GetSal(cBanco,cAgencia,cConta,dDataIni,dDataFim)
	aTotSal[1][2] := aSaldos[1]
	aTotSal[2][2] := aSaldos[2]
	aTotSal[3][2] := aSaldos[3]
	aTotSal[4][2] := aSaldos[4]
	For nLinha := 1 To Len( aTotSal )
		If nLinha > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oMdTotSal:AddLine(.T.) ) != nLinha
				lRet    := .F.
				Exit
			EndIf
		EndIf
		oMdTotSal:LoadValue( "TEXTO" , Left(aTotSal[nLinha][1],28) )
		oMdTotSal:LoadValue( "VALOR" , aTotSal[nLinha][2] )
	Next nLinha
EndIf


FWRestRows(aSaveLines)

If lFirst
	oMdItem:GoLine(1)
EndIf

oMdTotRec:GoLine(1)
oMdTotPag:GoLine(1)
oMdTotSal:GoLine(1)

If __lMetric .And. __lGrvMetri .And. nQtdMov > 0
	nTimer      := oTimer:ElapseTime(.T.)
	__nMedEntra := (nTimer/nQtdMov)
	oTimer:Destroy()
	oTimer := nil
	__lGrvMetri := .F.
EndIf

Return
