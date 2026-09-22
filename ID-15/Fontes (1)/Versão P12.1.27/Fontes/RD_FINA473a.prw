#Include 'Protheus.ch'
#include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"
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
				StaticCall( FINA473a, FA473GrvEf, cOcNat,"","","","","","","","","",aParam)
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
StaticCall( FINA473a, FI473ACTMD, oModel)

RestArea(aAreaSE5)
RestArea(aArea)


Return lRet



