#Include 'Protheus.ch'
#include "RWMAKE.CH"
#Include "topconn.ch"

/*
{Protheus.doc} TEWBTYR3()
Relatório Específico de Notas Fiscais
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function TEWBTYR3( cAlias, nReg, nOpcx )

Local oReport
//Local lTRepInUse := .T.

//PRIVATE lAuto := (nReg!=Nil)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= U_RepDefR3(nReg, nOpcx)
oReport:PrintDialog()

Return


/*
{Protheus.doc} ReportDefR3()
Relatório Específico de Notas Fiscais
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function RepDefR3(nReg,nOpcx)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cTitulo	:= "Impressão de Nota Fiscal"

Private cPerg
Private oReport
 
cString := "SF2"
wnrel   := "TEWBTYR3"
cPerg   := "TEWBTYR3"

//U_AjusteSX1() Thais Paiva - Compatibilização P27
Pergunte(cPerg,.F.)
oReport:= TReport():New("TEWBTYR3",cTitulo,"TEWBTYR3", {|oReport| U_R3Print(oReport,nReg,nOpcx)},"Relatorio de Notas Fiscais")
oReport:lHeaderVisible := .F. //oculta cabeçalho
oReport:HideParamPage()  //oculta página de parâmetros


Return(oReport)


/*
{Protheus.doc} R3Print()
Relatório Específico de Notas Fiscais - Processamento do relório
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function R3Print(oReport,nReg,nOpcx)

Local aAreaRPS		:= {}
Local aPrintServ	:= {}
Local aPrintObs		:= {}
Local aTMS			:= {}

Local cServ			:= ""
Local cDescrServ	:= ""
Local cCNPJCli		:= ""
Local cTime			:= ""
Local cLogo			:= ""
Local cServPonto	:= ""
Local cObsPonto		:= ""
Local cAliasSF3		:= "SF3"
Local cCli			:= ""
Local cIMCli		:= ""
Local cEndCli		:= ""
Local cBairrCli		:= ""
Local cCepCli		:= ""
Local cMunCli		:= ""
Local cCodMun		:= ""
Local cDescMun      := ""
Local cUFCli		:= ""
Local cEmailCli		:= ""
Local cCampos		:= ""
Local cDescrBar     := SuperGetMv("MV_DESCBAR",.F.,"")
Local cCodServ      := ""
Local cObsRio       := ""
Local cLogAlter     := GetNewPar("MV_LOGRPS","") // caminho+nome do logotipo alternativo  
Local cTotImp       := ""
Local cFontImp      := ""

Local lCampBar      := !Empty(cDescrBar) .And. SB1->(FieldPos(cDescrBar)) > 0
Local lDescrNFE		:= ExistBlock("MTDESCRNFE")
Local lObsNFE		:= ExistBlock("MTOBSNFE")
Local lCliNFE		:= ExistBlock("MTCLINFE")
Local lPEImpRPS		:= ExistBlock("MTIMPRPS")
Local lDescrBar     := GetNewPar("MV_DESCSRV",.F.)
Local lImpRPS		:= .T.

Local nValDed       := 0
Local nVALISS       := 0
Local nDescIncond   := 0
Local nValLiq       := 0
Local nVlContab     := 0
Local nValDesc      := 0
Local nValPis       := 0
Local nValCof       := 0
Local nValCSLL      := 0
Local nValIR        := 0
Local nValINSS      := 0
Local cRecIss       := ""
Local cRecCof       := ""
Local cRecPis       := ""
Local cRecIR        := ""
Local cRecCsl       := ""
Local cRecIns		:= ""
Local cTitulo		:= "" //"RECIBO PROVISÓRIO DE SERVIÇOS - RPS" 
Local nCopias		:= mv_par07
Local nLinIni		:= 225
Local nColIni		:= 225
Local nColFim		:= 2175
Local nLinFim		:= 2975
Local nX			:= 1
Local nY			:= 1
Local nLinha		:= 0
Local nCentro		:= nColFim - nColIni
Local cCNPJIntSer	:= ""
Local cCliIntSer	:= ""
Local cMunPreSer	:= ""
Local cNroInsObr	:= ""
Local cValAprTri	:= ""
//Local nValCOFINS	:= 0
//Local nValIRPF		:= 0
Local nValCred		:= 0

Local oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont10n	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito
Local oFont12n	:= TFont():New("Cuourier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
Local oFont09 	:= TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont09n	:= TFont():New("Courier New",9,9,,.T.,,,,.T.,.F.)	//Negrito     
Local oFont25n	:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)	//Negrito

Local cNomePac  := ""
Local cDtNasc   := ""
Local cCpfPac   := ""
Local cNumAtend := ""

#IFDEF TOP
	Local cQuery    := ""
#ELSE 
	Local cChave    := ""
	Local cFiltro   := ""
#ENDIF

Private lRecife := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RECIFE",.T.,.F.)
Private lRio    := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RIODEJANEIRO",.T.,.F.)

dbSelectArea("SF3")
dbSetOrder(6)

#IFDEF TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que serao adicionados a query somente se existirem na base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cCampos := " ,F3_ISSMAT "

	If lRecife
    	cCampos += " ,F3_CNAE "
	Endif
	/*
	If Empty(cCampos)
		cCampos := "%%"
	Else
		cCampos := "% " + cCampos + " %"
	Endif
	*/
	If TcSrvType()<>"AS/400"

		lQuery		:= .T.
		cAliasSF3	:= GetNextAlias()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cQuery := "% SF3.F3_DTCANC = '' AND %"
		Else
			cQuery := "%%"
		Endif

		cSelect:= "%"
		cSelect+= "F3_FILIAL,F3_ENTRADA,F3_EMISSAO,F3_NFISCAL,F3_SERIE," 
		cSelect+= IIF(SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE","F3_SDOC,","") + "F3_CLIEFOR,F3_PDV,"
		cSelect+= "F3_LOJA,F3_ALIQICM,F3_BASEICM,F3_VALCONT,F3_TIPO,F3_VALICM,F3_ISSSUB,F3_ESPECIE,"
		cSelect+= "F3_DTCANC,F3_CODISS,F3_TRIBMUN,F3_OBSERV,F3_NFELETR,F3_EMINFE,F3_HORNFE, F3_CODNFE,F3_CREDNFE, F3_ISENICM "+cCampos
		cSelect+= "%"

		BeginSql Alias cAliasSF3
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE
			COLUMN F3_DTCANC AS DATE
			COLUMN F3_EMINFE AS DATE
			SELECT %Exp:cSelect%

			FROM %table:SF3% SF3

			WHERE SF3.F3_FILIAL = %xFilial:SF3% AND
				SF3.F3_CFO >= '5' AND
				SF3.F3_ENTRADA >= %Exp:mv_par01% AND
				SF3.F3_ENTRADA <= %Exp:mv_par02% AND
				SF3.F3_TIPO = 'S' AND
				SF3.F3_CODISS <> %Exp:Space(TamSX3("F3_CODISS")[1])% AND
				SF3.F3_CLIEFOR >= %Exp:mv_par03% AND
				SF3.F3_CLIEFOR <= %Exp:mv_par04% AND
				SF3.F3_NFISCAL >= %Exp:mv_par05% AND
				SF3.F3_NFISCAL <= %Exp:mv_par06% AND
				%Exp:cQuery%
				SF3.%NotDel%

			ORDER BY SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_TIPO,SF3.F3_CLIEFOR,SF3.F3_LOJA
		EndSql

		dbSelectArea(cAliasSF3)
	Else

#ENDIF
		cArqInd := CriaTrab(NIL,.F.)
		cChave  := "DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA+F3_CNAE"
		cFiltro := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
		cFiltro += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' .And. "
		cFiltro += "DtOs(F3_ENTRADA) >= '" + Dtos(mv_par01) + "' .And. "
		cFiltro += "DtOs(F3_ENTRADA) <= '" + Dtos(mv_par02) + "' .And. "
		cFiltro += "F3_TIPO == 'S' .And. F3_CODISS <> '" + Space(Len(F3_CODISS)) + "' .And. "
		cFiltro += "F3_CLIEFOR >= '" + mv_par03 + "' .And. F3_CLIEFOR <= '" + mv_par04 + "' .And. "
		cFiltro += "F3_NFISCAL >= '" + mv_par05 + "' .And. F3_NFISCAL <= '" + mv_par06 + "'"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cFiltro	+= " .And. Empty(F3_DTCANC)"
		Endif

		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros...")  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif
#ENDIF


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasSF3)->(!Eof())
		ProcRegua(LastRec())
		If oReport:Cancel()
			Exit
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa Deducoes do ISS  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValDed := (cAliasSF3)->F3_ISSSUB
		nValDed += (cAliasSF3)->F3_ISSMAT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor contabil ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlContab := (cAliasSF3)->F3_VALCONT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o SF2 para verificar o horario de emissao do documento e Lei da Transparência³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF2->(dbSetOrder(1))
		cTime   := ""
		cTotImp := ""
		cFontImp:= ""

		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			cTime := Transform(SF2->F2_HORA,"@R 99:99")
			//Lei Transparência - 12.741
			cTotImp := Iif( SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
			//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
					cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
				EndIf
			EndIf
			cValAprTri := Iif(SF2->F2_TOTIMP>0, Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"/"+AlqLeiTran("SB1","SBZ")[2], "")
			// NF Cupom nao sera processada
			If !Empty(SF2->F2_NFCUPOM)
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS := (cAliasSF3)->(GetArea())
		lImpRPS	 := .T.
		If lPEImpRPS
			lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !lImpRPS
			(cAliasSF3)->(dbSKip())
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a descricao do codigo de servicos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDescrServ := ""
		dbSelectArea("SX3")
		dbSetOrder(2)
		//Início - Thais Paiva - Compatibilização P27
		//If dbSeek("BZ_CODISS") 
		If FieldPos("BZ_CODISS") > 0
			//If Alltrim(SX3->X3_F3) == "60" 
			If Alltrim(GetSx3Cache("BZ_CODISS", 'X3_F3')) == "60"
				//SX5->(dbSetOrder(1))
				//If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
					cDescrServ := U_SX5UTILI("L","60",(cAliasSF3)->F3_CODISS,4)//SX5->X5_DESCRI
				//Endif
			//ElseIf Alltrim(SX3->X3_F3) == "CCQ"
			ElseIf Alltrim(GetSx3Cache("BZ_CODISS", 'X3_F3')) == "CCQ"
				dbSelectArea("CCQ")
				CCQ->(dbSetOrder(1))
				If CCQ->(dbSeek(xFilial("CCQ")+(cAliasSF3)->F3_CODISS))
					cDescrServ := CCQ->CCQ_DESC
				Endif
			EndIf
		Else
			//SX5->(dbSetOrder(1))
			//If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
				cDescrServ := U_SX5UTILI("L","60",(cAliasSF3)->F3_CODISS,4)//SX5->X5_DESCRI
			//Endif
		EndIf
		If lDescrBar
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			SB1->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
					Endif
				Endif
			Endif
		Endif 
		If lRecife
			cCodAtiv := Alltrim((cAliasSF3)->F3_CNAE)  
		ElseIf lRio 
			cCodServ := Alltrim((cAliasSF3)->F3_CODISS) + " - " + cDescrServ
		Else
			cCodServ := Alltrim((cAliasSF3)->F3_TRIBMUN) + " - " + Posicione("SX5",1,xFilial("SX5")+"60"+(cAliasSF3)->F3_TRIBMUN,"SX5->X5_DESCRI")			
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o pedido para discriminar os servicos prestados no documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		SC6->(dbSetOrder(4))
		SC5->(dbSetOrder(1))
		If SC6->(DbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
			If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM))  
				cServ     := AllTrim(SC5->C5_XDSERV) //+CHR(13)+CHR(10) +" | "+AllTrim(SubStr(SX5->X5_DESCRI,1,55))
				cNomePac  := Alltrim(SC5->C5_XNOMEPA)
				cDtNasc   := Alltrim(DtoC(SC5->C5_XDATANA))
				cCpfPac   := Alltrim(SC5->C5_XCPFPAC)
				cNumAtend := Alltrim(SC5->C5_XNUMATE)
				cCodMun	  := SC5->C5_MUNPRES
				cDescMun  := SC5->C5_DESCMUN
				cUFCli	  := SC5->C5_ESTPRES
			Endif
		Endif
			
		If Empty(cServ)
			cServ := cDescrServ
		Endif
		//Lei Transparência
		If !Empty(cTotImp) //.And. !lPaulista
			cServ += CHR(13)+CHR(10)+cTotImp+cFontImp
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para compor a descricao a ser apresentada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS	:= (cAliasSF3)->(GetArea())
		cServPonto	:= ""
		If lDescrNFE
			cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !(Empty(cServPonto))
			cServ := cServPonto
		Endif
		aPrintServ	:= U_R3Mont(cServ,13,999)
		/*If lRioJaneiro
			cObsRio := ""
			nDescIncond := 0
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					SF4->(DbSetOrder(1))
					If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
						If SF2->F2_DESCONT > 0
							If SF4->F4_DESCOND == "1"
								cObsRio := " Deconto Condic. de (R$) "
								cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99"))
							Else
								nDescIncond := SF2->F2_DESCONT
							EndIf
						EndIf
					EndIf
				Endif
			Endif
		Endif*/
		cObserv := Alltrim((cAliasSF3)->F3_OBSERV) + Iif(!Empty((cAliasSF3)->F3_OBSERV)," | ","")
		cObserv += Iif(!Empty((cAliasSF3)->F3_PDV) .And. Alltrim((cAliasSF3)->F3_ESPECIE) == "CF","RPS generado por emisor de comp. fiscal(ECF)" + " | ","")
		/*If lRioJaneiro
			cObsRio += "'Obrigatória a conversão em Nota Fiscal de Serviços Eletrônica – NFS-e – NOTA CARIOCA em até vinte dias.'" + " | "
		EndIf*/
		aAreaRPS := (cAliasSF3)->(GetArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para complementar as observacoes a serem apresentadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cObsPonto	:= ""
		If lObsNFE
			cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		cObserv 	:= cObserv + cObsPonto
		cObserv 	:= cObserv + cObsRio
		aPrintObs	:= U_R3Mont(cObserv,11,675)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cLiente/fornecedor do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCNPJCli := ""
		cRecIss  := ""
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If RetPessoa(SA1->A1_CGC) == "F"
				cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else
				cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif
			cCli		:= SA1->A1_NOME
			cIMCli		:= SA1->A1_INSCRM
			cEndCli		:= SA1->A1_END
			cBairrCli	:= SA1->A1_BAIRRO
			cCepCli		:= SA1->A1_CEP
			cMunCli		:= SA1->A1_MUN
			//cCodMun		:= SA1->A1_COD_MUN
			//cUFCli		:= SA1->A1_EST
			cEmailCli	:= SA1->A1_EMAIL
			cRecIss     := SA1->A1_RECISS
			cRecCof     := SA1->A1_RECCOFI
			cRecPis     := SA1->A1_RECPIS
			cRecIR      := SA1->A1_RECIRRF
			cRecCsl     := SA1->A1_RECCSLL
			cRecIns     := SA1->A1_RECINSS
		Else
			(cAliasSF3)->(dbSKip())
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTms()
			aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
			If Len(aTMS) > 0
				cCli		:= aTMS[04]
				If RetPessoa(Alltrim(aTMS[01])) == "F"
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aTMS[02]
				cEndCli		:= aTMS[05]
				cBairrCli	:= aTMS[06]
				cCepCli		:= aTMS[09]
				cMunCli		:= aTMS[07]
				cUFCli		:= aTMS[08]
				cEmailCli	:= aTMS[10]
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para trocar o cliente a ser impresso.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCliNFE
			aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
			If Len(aMTCliNfe) >= 12
				cCli		:= aMTCliNfe[01]
				cCNPJCli	:= aMTCliNfe[02]
				If RetPessoa(cCNPJCli) == "F"
					cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aMTCliNfe[03]
				cEndCli		:= aMTCliNfe[04]
				cBairrCli	:= aMTCliNfe[05]
				cCepCli		:= aMTCliNfe[06]
				cMunCli		:= aMTCliNfe[07]
				cUFCli		:= aMTCliNfe[08]
				cEmailCli	:= aMTCliNfe[09]
			Endif
		Endif
		//If lBhorizonte .Or. lPaulista
			nValDed     := 0
			nValDesc    := 0
			nDescIncond := 0
			nValLiq     := 0
			nVALISS     := 0
			nValPis     := 0
			nValCof     := 0
			nValCSLL    := 0
			nValIR      := 0
			nValINSS	:= 0
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
						If Alltrim(SD2->D2_CODISS) == Alltrim((cAliasSF3)->F3_CODISS) 
							SF4->(DbSetOrder(1))		
							If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
								nValLiq  += SD2->D2_TOTAL
								nVALISS  += SD2->D2_VALISS
								nValPis  += SD2->D2_VALPIS
								nValCof  += SD2->D2_VALCOF
								nValCSLL += SD2->D2_VALCSL
								nValIR   += SD2->D2_VALIRRF
								nValINSS := SD2->D2_VALINS
								nValDesc += SD2->D2_DESCON
								If SF4->F4_DESCOND <> "1"
									nDescIncond := nValDesc
								EndIf
								If SF4->F4_AGREG == "D"
									nValDesc += SD2->D2_DESCICM
									nValLiq -= SD2->D2_DESCICM
									//Acrescenta o ISS no valor Contábil, pois o ISS foi deduzido na emissão da NF e
									//para a impressão correta do RPS é necessario soma-lo
									//nVlContab é impresso como valor da mercadoria para Belo Horizonte
									nVlContab := nVlContab + SD2->D2_DESCICM
								Endif
								nValDed += SD2->( D2_ABATISS + D2_ABATMAT )
							EndIf
						Endif
						SD2->(dbSkip())
					End 
				Endif 
			EndIf
			nRetFeder   := 0
			If cRecIss == "1"
				nValLiq := nValLiq - nValISS
			EndIf
			If cRecCof == "S"
				nValLiq    := nValLiq - nValCof
				nRetFeder  := nRetFeder + nValCof
			EndIf
			If cRecPis == "S"
				nValLiq := nValLiq - nValPis
				nRetFeder  := nRetFeder + nValPis
			EndIf
			If cRecCsl == "S"
				nValLiq := nValLiq - nValCsll
				nRetFeder  := nRetFeder + nValCsll
			EndIf
			If cRecIr == "1"
				nValLiq := nValLiq - nValIR
				nRetFeder  := nRetFeder + nValIR
			Endif
			If cRecIns == "S"
				nValLiq := nValLiq - nValINSS
				nRetFeder  := nRetFeder + nValINSS
			EndIf
		//Endif

		/*If lJoinville
			SF2->(dbSetOrder(1))
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE)))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						nValBase	:= Iif (Empty((cAliasSF3)->F3_BASEICM),(cAliasSF3)->F3_ISENICM,(cAliasSF3)->F3_BASEICM)
						nAliquota	:= SB1->B1_ALIQISS
					Endif
				EndIf
			EndIf
		Endif*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Relatorio Grafico:                                                                                      ³
		//³* Todas as coordenadas sao em pixels	                                                                   ³
		//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
		//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to nCopias
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box no tamanho do RPS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Line(nLinIni,nColIni,nLinIni,nColFim)
			oReport:Line(nLinIni,nColIni,nLinFim,nColIni)
			oReport:Line(nLinIni,nColFim,nLinFim,nColFim)
			oReport:Line(nLinFim,nColIni,nLinFim,nColFim)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados da empresa emitente do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//O arquivo com o logo deve estar abaixo do rootpath (mp8\system)
			If Empty(cLogAlter)
				cLogo := FisxLogo("1")
			Else
				cLogo := cLogAlter
			EndIf
			
			If !Empty((cAliasSF3)->F3_DTCANC) 
				oReport:Say(100,1000,"CANCELADA",oFont25n,1400,CLR_RED)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Título do Documento  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Say(160,nCentro/2-len(cTitulo),cTitulo,oFont12n)
			oReport:SayBitmap(280,nColIni+10,cLogo,350,340)
			oReport:Line(nLinIni,1800,612,1800)
			oReport:Line(354,1800,354,nColFim)
			oReport:Line(483,1800,483,nColFim)
			oReport:Line(612,nColIni,612,nColFim)
			oReport:Say(245,730,PadC(Alltrim(SM0->M0_NOMECOM),40),oFont12n)
			oReport:Say(305,680,PadC(Alltrim(SM0->M0_ENDENT),50),oFont10)
			oReport:Say(355,680,PadC(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50),oFont10)
			oReport:Say(405,680,PadC(Alltrim(SM0->M0_CIDENT) + " - " + Alltrim(SM0->M0_ESTENT),50),oFont10)
			oReport:Say(455,680,PadC(Alltrim("Telefone: ") + Alltrim(SM0->M0_TEL),50),oFont10) // Telefone:
			oReport:Say(505,680,PadC(Alltrim("C.N.P.J.: ") + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFont10) // C.N.P.J.::
			oReport:Say(555,680,PadC(Alltrim("I.M.: ") + Alltrim(SM0->M0_INSCM),50),oFont10) // I.M.:
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Informacoes sobre a emissao do RPS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//	oReport:Say(250,1830,PadC(Alltrim("Número / Série RPS"),15),oFont10n) // "Número/Série RPS"
			//oReport:Say(295,1830,PadC(Alltrim(Alltrim((cAliasSF3)->F3_NFELETR) + Iif(!Empty((cAliasSF3)->F3_SERIE)," / " + Alltrim((cAliasSF3)->F3_SERIE),"")),15),oFont10)
			
			oReport:Say(250,1830,Alltrim("Número"),oFont09n) // "Número"
			oReport:Say(295,1830,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont09)
			
			//oReport := TSay():New(295,1830,{||'NF CANCELADA'},,,oFont12n,,,,.T.,CLR_RED,CLR_WHITE,200,20) 
			
			oReport:Say(375,1830,Alltrim("Código Verificação"),oFont09n) // "Código Verificação"
			oReport:Say(420,1830,Padl((cAliasSF3)->F3_CODNFE,32),oFont09)
	  		
			oReport:Say(510,1830,Alltrim("Emissão"),oFont09n) // "Emissão"
			oReport:Say(555,1830,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont09)
			
		//	oReport:Say(635,1830,PadC(Alltrim("Hora Emissão "),15),oFont10n) // "Hora Emissão"
		//	oReport:Say(680,1830,PadC(Alltrim((cAliasSF3)->F3_HORNFE),15),oFont10)
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados do destinatario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Say(625,nCentro/2-len("DADOS DO DESTINATÁRIO "),"DADOS DO DESTINATÁRIO ",oFont12n) // "DADOS DO DESTINATÁRIO"	
			oReport:Say(685,250,"Nome/Razão Social:",oFont10n) // "Nome/Razão Social:"
			oReport:Say(745,250,"C.P.F./C.N.P.J.:",oFont10n) // "C.P.F./C.N.P.J.:"
			oReport:Say(805,250,"Inscrição Municipal:",oFont10n) // "Inscrição Municipal:"
			oReport:Say(865,250,"Endereço:",oFont10n) // "Endereço:"
			oReport:Say(925,250,"CEP:",oFont10n) // "CEP:"
			oReport:Say(985,250,"Município:",oFont10n) // "Município:"
			oReport:Say(985,1800,"UF:",oFont10n) // "UF:"
			oReport:Say(1045,250,"E-mail:",oFont10n) // "E-mail:"
			oReport:Say(685,750,Alltrim(cCli),oFont10)
			oReport:Say(745,750,Alltrim(cCNPJCli),oFont10)
			oReport:Say(805,750,Alltrim(cIMCli),oFont10)
			oReport:Say(865,750,Alltrim(cEndCli) + " - " + Alltrim(cBairrCli) ,oFont10)
			oReport:Say(925,750,Transform(cCepCli,"@R 99999-999"),oFont10)
			oReport:Say(985,750,Alltrim(cMunCli),oFont10)
			oReport:Say(985,1900,Alltrim(cUFCli),oFont10)
			oReport:Say(1045,750,Alltrim(cEmailCli),oFont10)
			oReport:Line(1105,nColIni,1105,nColFim)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados do intermediario de serviço³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Say(1118,nCentro/2-len("INTERMEDIÁRIO DE SERVIÇOS"),"INTERMEDIÁRIO DE SERVIÇOS",oFont12n) // "INTERMEDIÁRIO DE SERVIÇOS"
			oReport:Say(1175,250,"C.P.F./C.N.P.J.:",oFont10n) // "C.P.F./C.N.P.J.:"
			oReport:Say(1175,950,"Nome/Razão Social:",oFont10n) // "Nome/Razão Social:"
			oReport:Say(1175,520,Alltrim(cCNPJIntSer),oFont10)
			oReport:Say(1175,1255,Alltrim(cCliIntSer),oFont10)
			oReport:Line(1235,nColIni,1235,nColFim)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Discriminacao dos Servicos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Say(1250,nCentro/2-len("DISCRIMINAÇÃO DOS SERVIÇOS"),"DISCRIMINAÇÃO DOS SERVIÇOS",oFont12n) // "DISCRIMINAÇÃO DOS SERVIÇOS"
			nLinha	:= 1300
			For nY := 1 to Len(aPrintServ)
				If nY > 15
					Exit
				Endif
				oReport:Say(nLinha,250,Alltrim(aPrintServ[nY]),oFont10)
				nLinha 	:= nLinha + 45
			Next
		 	
		 	If !Empty(cNomePac)
				oReport:Say(nLinha+=45,250,"PACIENTE: "+cNomePac,oFont10)
			EndIf
			If !Empty(Transform(cDtNasc, " ", "/"))
				oReport:Say(nLinha+=45,250,"DT NASC.: "+cDtNasc,oFont10)
			EndIf
			If !Empty(cCpfPac)
				oReport:Say(nLinha+=45,250,"CPF.....: "+cCpfPac,oFont10)
			EndIf
			If !Empty(cNumAtend)
				oReport:Say(nLinha+=45,250,"N ATEND.: "+cNumAtend,oFont10)
			EndIf
			
			oReport:Line(1950,nColIni,1950,nColFim)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valores da prestacao de servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If !lBhorizonte
				oReport:Say(1880,nColIni,PadC(Alltrim("VALOR TOTAL DA PRESTAÇÃO DE SERVIÇOS")+" R$ "+AllTrim(Transform((nVlContab+nValDesc),"@E 999,999,999.99")),100) ,oFont12n) 
				oReport:Line(1950,nColIni,1950,nColFim)
			//EndIf

		/*	If lRecife
				oReport:Say(1965,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
				oReport:Say(2005,250,Alltrim(cCodAtiv),oFont10)
			ElseIf lBhorizonte
				oReport:Say(1865,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
				oReport:Say(1865,950,Alltrim(cCodServ),oFont10)
			ElseIf lPaulista*/
				oReport:Line(1950,582,2050,582)
				oReport:Line(1950,972,2050,972)
				oReport:Line(1950,1372,2050,1372)
				oReport:Line(1950,1772,2050,1772)
				oReport:Say(1965,250,Alltrim("INSS (R$)"),oFont09n) // "INSS (R$)"
				oReport:Say(2005,280,Transform(nValINSS,"@E 999,999,999.99"),oFont10)
				oReport:Say(1965,600,Alltrim("IR (R$)"),oFont09n) // "IRPF (R$)"
				oReport:Say(2005,670,Transform(nValIR,"@E 999,999,999.99"),oFont10)
				oReport:Say(1965,1000,Alltrim("CSLL (R$)"),oFont09n) // "CSLL (R$)"
				oReport:Say(2005,1070,Transform(nValCSLL,"@E 999,999,999.99"),oFont10)
				oReport:Say(1965,1400,Alltrim( "COFINS (R$)"),oFont09n) // "COFINS (R$)"
				oReport:Say(2005,1470,Transform(nValCof,"@E 999,999,999.99"),oFont10)
				oReport:Say(1965,1800,Alltrim("PIS/PASEP (R$)"),oFont09n) // "PIS/PASEP (R$)"
				oReport:Say(2005,1870,Transform(nValPis,"@E 999,999,999.99"),oFont10)
				oReport:Line(2050,nColIni,2050,nColFim)
				oReport:Say(2055,250,Alltrim("Código do Serviço"),oFont09n) // "Código do Serviço"
				oReport:Say(2100,250,Alltrim(cCodServ),oFont10)
		/*	Else
				oReport:Say(1965,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
				oReport:Say(2005,250,Alltrim(cCodServ),oFont10)
			EndIf*/

			/*If lBhorizonte
				oReport:Line(1925,nColIni,1925,nColFim)
			ElseIf lPaulista*/
				oReport:Line(2145,nColIni,2145,nColFim)
			/*Else
				oReport:Line(2050,nColIni,2050,nColFim)
			EndIf*/

			/*If lRioJaneiro
				oReport:Line(2050,632,2150,632)
				oReport:Line(2050,979,2150,979)
				oReport:Line(2050,1446,2150,1446)
				oReport:Line(2050,1736,2150,1736)
				oReport:Say(2065,250,Alltrim("Total deduções (R$)"),oFont09n) // "Total deduções (R$)"
				oReport:Say(2105,320,Transform(nValDed,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2065,647,Alltrim("Desc.Incond. (R$)"),oFont09n) // "Desc.Incond. (R$)"
				oReport:Say(2105,667,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)
				oReport:Say(2065,1014,Alltrim("Base de cálculo (R$)"),oFont09n) // "Base de cálculo (R$)"
				oReport:Say(2105,1134,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont09)
				oReport:Say(2065,1484,Alltrim("Alíquota (%)"),oFont09n) // "Alíquota (%)"
				oReport:Say(2105,1584,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)
				oReport:Say(2065,1791,Alltrim("Valor do ISS (R$)"),oFont09n) // "Valor do ISS (R$)"
				oReport:Say(2105,1881,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont09)
				oReport:Line(2150,nColIni,2150,nColFim)
			ElseIf lBhorizonte
				oReport:Say(1950,250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
				oReport:Say(1950,920,Transform(nVlContab,"@E 999,999,999.99"),oFont09)        
				oReport:Say(1950,1250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
				oReport:Say(1950,1870,Transform(nVlContab,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2000,250,Alltrim("(-)Descontos: "),oFont09n) // "Descontos"
				oReport:Say(2000,920,Transform(nValDesc,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2000,1250,Alltrim("(-)Deduçoes: "),oFont09n) // "Deduções"
				oReport:Say(2000,1870,Transform(nValDed,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2050,250,Alltrim("(-)Ret.Federais: "),oFont09n) // "Ret.Federais"
				oReport:Say(2050,920,Transform(nRetFeder,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2050,1250,Alltrim("(-)Desc.Incond.: "),oFont09n) // "Desc.Incod"
				oReport:Say(2050,1870,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2100,250,Alltrim("(-)ISS Ret.: "),oFont09n) // "ISS Ret."
				oReport:Say(2100,920,Transform(IIf(cRecIss=="1",nValISS,0),"@E 999,999,999.99"),oFont09)        
				oReport:Say(2100,1250,Alltrim("(=)Base Cálc.: "),oFont09n) // "Base Cálc."
				oReport:Say(2100,1870,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2150,250,Alltrim("Valor Liq.: "),oFont09n) // "Valor Liq."
				oReport:Say(2150,920,Transform(nValLiq,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2150,1250,Alltrim("Alíquota: "),oFont09n) // "Alíquota"
				oReport:Say(2150,1988,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)        
				oReport:Say(2200,1250,Alltrim("(=)Valor ISS: "),oFont09n) // "Valor ISS"
				oReport:Say(2200,1870,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont09)        
				oReport:Say(2260,250,"PIS:" ,oFont09)
				oReport:Say(2260,285,Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFont09) 
				oReport:Say(2260,630,"COFINS:" ,oFont09)
				oReport:Say(2260,660,Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFont09) 
				oReport:Say(2260,1005,"IR:" ,oFont09)
				oReport:Say(2260,1035,Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFont09) 
				oReport:Say(2260,1380,"CSLL:" ,oFont09)
				oReport:Say(2260,1410,Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFont09) 
				oReport:Say(2260,1755,"INSS:" ,oFont09)
				oReport:Say(2260,1785,Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFont09)
				oReport:Say(2330,nColIni,PadC(Alltrim("INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"),75),oFont10n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
				oReport:Line(2380,nColIni,2380,nColFim)
				oReport:Line(2380,712,2380,712)
				oReport:Line(2380,1070,2380,1070)
				oReport:Line(2380,1686,2380,1686)
				oReport:Say(2400,250,Alltrim("Número"),oFont09n) // "Número"
				oReport:Say(2440,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont09)
				oReport:Say(2400,737,Alltrim("Emissão"),oFont09n) // "Emissão"
				oReport:Say(2440,757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont09)
				oReport:Say(2400,1094,Alltrim("Código Verificação"),oFont09n) // "Código Verificação"
				oReport:Say(2440,1144,Padl((cAliasSF3)->F3_CODNFE,32),oFont09)
				oReport:Say(2400,1711,Alltrim("Crédito IPTU"),oFont09n) // "Crédito IPTU"
				oReport:Say(2440,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont09)
				oReport:Line(2500,nColIni,2500,nColFim)
				nLinha	:= 2530
				For nY := 1 to Len(aPrintObs)
					If nY > 11
						Exit
					Endif
					oReport:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont09)
					nLinha 	:= nLinha + 50
				Next
			ElseIf lPaulista*/
				cMunPreSer := UfCodIBGE(cUFCli)+cCodMun+" - "+cDescMun
				oReport:Line(2145,572,2245,572) //oReport:Line(2145,582,2245,582)
				oReport:Line(2145,952,2245,952) //oReport:Line(2145,972,2245,972)
				oReport:Line(2145,1202,2245,1202)//oReport:Line(2145,1372,2245,1372)
				oReport:Line(2145,1502,2245,1502) 
				oReport:Line(2145,1802,2245,1802) //oReport:Line(2145,1772,2245,1772)
				oReport:Say(2160,250,Alltrim("Total deduções (R$)"),oFont09n) // "Total deduções (R$)"
				oReport:Say(2200,280,Transform(nValDed,"@E 999,999,999.99"),oFont10)	
				oReport:Say(2160,590,Alltrim("Base de cálculo (R$)"),oFont09n) // "Base de cálculo (R$)"  //oReport:Say(2160,600,Alltrim("Base de cálculo (R$)"),oFont09n) // "Base de cálculo (R$)"
				oReport:Say(2200,660,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont10)//oReport:Say(2200,670,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont10)
				oReport:Say(2160,980,Alltrim("Alíquota (%)"),oFont09n) // "Alíquota (%)" //oReport:Say(2160,1000,Alltrim("Alíquota (%)"),oFont09n) // "Alíquota (%)"
				oReport:Say(2200,1000,Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999.99"),oFont10) //oReport:Say(2200,1070,Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99"),oFont10)
				oReport:Say(2160,1230,Alltrim("Valor do ISS (R$)"),oFont09n) // "Valor do ISS (R$)"  //oReport:Say(2160,1400,Alltrim("Valor do ISS (R$)"),oFont09n) // "Valor do ISS (R$)"
				oReport:Say(2200,1250,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)  //oReport:Say(2200,1470,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)
				oReport:Say(2160,1530,Alltrim("Crédito (R$)"),oFont09n) // "Crédito (R$)" //oReport:Say(2160,1800,Alltrim("Crédito (R$)"),oFont09n) // "Crédito (R$)"
				oReport:Say(2200,1550,Transform(nValCred,"@E 999,999,999.99"),oFont10)   //oReport:Say(2200,1870,Transform(nValCred,"@E 999,999,999.99"),oFont10)
				oReport:Say(2160,1830,Alltrim("Desconto (R$)"),oFont09n) // "Desconto" 
				oReport:Say(2200,1870,Transform(nValDesc,"@E 999,999,999.99"),oFont10)   
				oReport:Line(2245,nColIni,2245,nColFim)
				//
				oReport:Line(2245,920,2345,920)
				oReport:Line(2245,1400,2345,1400)
				oReport:Say(2260,250,Alltrim("Municipio da Prestação do Serviço"),oFont09n) //"Municipio da Prestação do Serviço"
				oReport:Say(2300,250,cMunPreSer,oFont10)
				oReport:Say(2260,940,Alltrim("Número da Inscrição da Obra"),oFont09n) //"Número da Inscrição da Obra"
				oReport:Say(2300,940,cNroInsObr,oFont10)
				oReport:Say(2260,1425,Alltrim("Valor Aproximado dos Tributos/Fonte"),oFont09n) //"Valor Aproximado dos Tributos/Fonte"
				oReport:Say(2300,1425,cValAprTri,oFont10)
				oReport:Line(2345,nColIni,2345,nColFim)
			/*Else
				oReport:Line(2050,712,2150,712)
				oReport:Line(2050,1199,2150,1199)
				oReport:Line(2050,1686,2150,1686)
				oReport:Say(2065,250,Alltrim("Total deduções (R$)"),oFont10n) // "Total deduções (R$)"
				oReport:Say(2105,370,Transform(nValDed,"@E 999,999,999.99"),oFont10)
				oReport:Say(2065,737,Alltrim("Base de cálculo (R$)"),oFont10n) // "Base de cálculo (R$)"
				oReport:Say(2105,857,Iif(lJoinville,Transform(nValBase,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99")),oFont10)
				oReport:Say(2065,1224,Alltrim("Alíquota (%)"),oFont10n) // "Alíquota (%)"
				oReport:Say(2105,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99")),oFont10)
				oReport:Say(2065,1711,Alltrim("Valor do ISS (R$)"),oFont10n) // "Valor do ISS (R$)"
				oReport:Say(2105,1831,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)
				oReport:Line(2150,nColIni,2150,nColFim)
			EndIf*/

			/*If !(lBhorizonte .Or. lPaulista)
				oReport:Say(2180,nCentro/2-len("INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"),"INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA",oFont12n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
				oReport:Line(2250,nColIni,2250,nColFim)
				oReport:Line(2250,712,2350,712)
				oReport:Line(2250,1070,2350,1070)
				oReport:Line(2250,1686,2350,1686)
				oReport:Say(2265,250,Alltrim("Número"),oFont10n) // "Número"
				oReport:Say(2305,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont10)
				oReport:Say(2265,737,Alltrim("Emissão"),oFont10n) // "Emissão"
				oReport:Say(2305,757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont10)
				oReport:Say(2265,1094,Alltrim("Código Verificação"),oFont10n) // "Código Verificação"
				oReport:Say(2305,1144,Padl((cAliasSF3)->F3_CODNFE,32),oFont10)
				oReport:Say(2265,1711,Alltrim("Crédito IPTU"),oFont10n) // "Crédito IPTU"
				oReport:Say(2305,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont10)
				oReport:Line(2350,nColIni,2350,nColFim)
			Endif*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Outras Informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If !lBhorizonte
				oReport:Say(2363,nCentro/2-len("OUTRAS INFORMAÇÕES"),"OUTRAS INFORMAÇÕES",oFont12n) // "OUTRAS INFORMAÇÕES"
				nLinha	:= 2423
				For nY := 1 to Len(aPrintObs)
					If nY > 11
						Exit
					Endif
					oReport:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont10)
					nLinha	:= nLinha + 50
				Next
				
				oReport:Say(nLinha,250,Alltrim("- Esta NFS-e substitui o RPS Nº" + Alltrim((cAliasSF3)->F3_NFISCAL) + " Série " + Alltrim((cAliasSF3)->F3_SERIE) + ", emitido em " + DtoC((cAliasSF3)->F3_EMISSAO) +"." ),oFont09n) //"Municipio da Prestação do Serviço"
				nLinha	+= 50
				oReport:Say(nLinha,250,Alltrim("- Valor Líquido a Pagar: " + Alltrim(Transform(nVlContab,"@E 999,999,999.99"))),oFont09n) //"Municipio da Prestação do Serviço"
				//oReport:Say(2300,250,cMunPreSer,oFont10)
				oReport:Line(1850,nColIni,1850,nColFim)
			//EndIF
			If nCopias > 1 .And. nX < nCopias
				oReport:EndPage()
			Endif
		Next
		(cAliasSF3)->(dbSkip())
		If !((cAliasSF3)->(Eof()))
			oReport:EndPage()
		Endif
	End

If !lQuery
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

Return

/*
{Protheus.doc} R3Mont()
Relatório Específico de Notas Fiscais - Discriminação de serviços 
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function R3Mont(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo		:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,86),nLinhas)

	cMemo := MemoLine(cString,86,nY) + "|"

	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif
	End 
Next

For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		End 
		For nX := 1 to Min(MlCount(cMemo,86),nLinhas)
			cAux := MemoLine(cMemo,86,nX)
			Aadd(aPrint,cAux)
		Next
	Endif
Next

Return(aPrint)

/*
{Protheus.doc} AjusteSX1()
Relatório Específico de Notas Fiscais - Ajustes na SX1 caso necessário
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/
/*Início - Thais Paiva - Compatibilização P27
User Function AjusteSX1()
Local aAreaSX1	:= SX1->(GetArea())

SX1->(dbSetOrder(1))
If SX1->(DbSeek("TEWBTYR3  05"))
	If SX1->X1_TAMANHO <> TamSx3("F3_NFISCAL")[1]
		RecLock("SX1",.F.)
		SX1->X1_TAMANHO := TamSx3("F3_NFISCAL")[1]
		SX1->(MSUnlock())
	Endif
Endif

If SX1->(DbSeek("TEWBTYR3  06"))
	If SX1->X1_TAMANHO <> TamSx3("F3_NFISCAL")[1]
		RecLock("SX1",.F.)
		SX1->X1_TAMANHO := TamSx3("F3_NFISCAL")[1]
		SX1->(MSUnlock())
	Endif
Endif

RestArea(aAreaSX1)
Return(.T.)
Fim - Thais Paiva - Compatibilização P27*/

/*
{Protheus.doc} R3Mont()
Relatório Específico de Notas Fiscais - Discriminação de serviços (Sorocaba)
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/
User Function R3Discri(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo		:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,130),nLinhas)

	cMemo := MemoLine(cString,130,nY)

	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif
	End 
Next

For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		End 
		For nX := 1 to Min(MlCount(cMemo,130),nLinhas)
			cAux := MemoLine(cMemo,130,nX) 
			Aadd(aPrint,cAux)
		Next
	Endif
Next

Return(aPrint)


/*
{Protheus.doc} R3Mont()
Relatório Específico de Notas Fiscais - Funcao para "ENGROSSAR" a espessura das linhas do BOX 
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function BoxR3(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oReport:Box(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

/*
{Protheus.doc} R3Mont()
Relatório Específico de Notas Fiscais - Funcao para "ENGROSSAR" a espessura das linhas  
@Author     Ramon Teodoro
@Since      22/08/2017       
@Version    P12.7
@Return     lRet
*/

User Function LineR3(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oReport:Line(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return


Return .T.

