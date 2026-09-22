#INCLUDE 'PROTHEUS.CH'
#DEFINE	 RECSOLICIT	01	//RECNO da SC
#DEFINE	 FILSOLICIT	02	//Filial da SC 
#DEFINE	 NUMSOLICIT	03	//Numero da SC 
#DEFINE	 ITMSOLICIT	04	//Item da SC 
#DEFINE	 PRDSOLICIT	05	//Produto 
#DEFINE	 DESSOLICIT	06	//Descrição produto 
#DEFINE	 QTDSOLICIT	07	//Quantidade 
#DEFINE	 PRCSOLICIT	08	//Preço total
#DEFINE	 VLTOTSOLIC	09	//Valor total 
#DEFINE	 LOCALSOLIC	10	//Local de estoque 
#DEFINE	 EMISSSOLIC	11	//Emissao 
#DEFINE	 FORNCSOLIC	12	//Fornecedor 
#DEFINE	 LOJAFSOLIC	13	//Loja do fornecedor 
#DEFINE	 GRPCOSOLIC	14	//Grupo de compras 
#DEFINE	 OBSERSOLIC	15	//Observações 
#DEFINE	 VLUNISOLIC	16	//Valor unitario
#DEFINE	 CCUSTSOLIC	17	//Centro de custo 
#DEFINE	 XTIPOSOLIC	18	//Tipo de solicitacao 
#DEFINE	 FLGGCSOLIC	19	//Flag da solicitacao 
#DEFINE	 CONTASOLIC	20	//Conta contabil 
#DEFINE	 ITEMCSOLIC	21	//Item contabil 
#DEFINE	 CLASSSOLIC	22	//Classe de valor
#DEFINE	 QTDAGSOLIC 23	//Quantidade aglutinada
#DEFINE	 VLRAGSOLIC 24	//Valor aglutinado
#DEFINE	 IDINTSOLIC 25	//ID de integração
#DEFINE	 FLAGGSOLIC 26  //Flag GCT
#DEFINE	 STATMSOLIC 27	//Status da medição
#DEFINE	 OBSMDSOLIC 28	//Observacoes da medição
#DEFINE	 NUMMDSOLIC 29	//Numero da medição
#DEFINE	 ITMMDSOLIC	30	//Item da medição
#DEFINE	 ORMEDSOLIC	31	//Origem da medição
#DEFINE	 DTMEDSOLIC	32	//Data da medição
#DEFINE	 HRMEDSOLIC	33	//Hora da medição
#DEFINE	 FILCTSOLIC	34	//Filial do contrato
#DEFINE	 CONTRSOLIC	35	//Numero do contrato
#DEFINE  RVCTRSOLIC	36	//Revisao do contrato
#DEFINE	 DINCTSOLIC	37	//Data inicial do contrato
#DEFINE	 DFICTSOLIC	38	//Data final do contrato
#DEFINE	 VGCTRSOLIC 39	//Vigencia do contrato
#DEFINE	 NUMPCSOLIC	40	//Num do PC
#DEFINE	 ITMPCSOLIC	41	//Item do PC
#DEFINE	 USERCSOLIC	42	//Código do usuário
#DEFINE	 SETORSOLIC 43  //Setor
#DEFINE	 MOTIVSOLIC 44  //Motivo
#DEFINE	 CHAVESOLIC	45	//Filial + Produto + Local de Estoque + Centro de Custo
/*/{Protheus.doc} F1200711
Mensagem de processamento.
@author 	Paulo Krüger
@since 		23/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/

User Function F1200711() 

Local	aAreaSC1	:= SC1->(GetArea())
Local	nI			:=	0
Local	cMensagem	:= 	''
Local	cCodProd	:=	''	
Local	cDescProd	:=	''
Local	nSM0Recno	:=	0
Local	cNmFilAut	:=	''
Local	aWBrowse1	:=	{}

Private	oDlg

cMensagem := 'Processamento encerrado.' + CRLF
cMensagem += 'OBS: Duplo click na linha para exibir detalhes.'
nSM0Recno	:=	SM0->(Recno())
For nI := 01 To Len(aProdSel)
	SC1->(DbSetOrder(1))
	If SC1->(DbSeek(aProdSel[nI][FILSOLICIT] + aProdSel[nI][NUMSOLICIT] + aProdSel[nI][ITMSOLICIT]))
		cCodProd	:= SC1->C1_PRODUTO	
		cDescProd	:= POSICIONE("SB1",1,xFilial("SB1") + cCodProd,"B1_DESC")
	Else
		cCodProd	:= ''	
		cDescProd	:= ''	
	EndIf
	cNmFilAut	:=	POSICIONE('SM0',01,cEmpAnt + aProdSel[nI][FILSOLICIT],'M0_FILIAL')
	Aadd(aWBrowse1,{	aProdSel[nI][FILSOLICIT]	,	;
						cNmFilAut					,	;
						aProdSel[nI][NUMSOLICIT]	,	;
						aProdSel[nI][ITMSOLICIT]	,	;
						aProdSel[nI][CONTRSOLIC]	,	;
						aProdSel[nI][NUMMDSOLIC]	,	;
						cCodProd					,	;
						cDescProd					,	;
						aProdSel[nI][ITMMDSOLIC]	,	;
						aProdSel[nI][NUMPCSOLIC]	,	;
						aProdSel[nI][ITMPCSOLIC]	,	;
						aProdSel[nI][OBSMDSOLIC]	,	;
						aProdSel[nI][FILSOLICIT] + cNmFilAut + aProdSel[nI][NUMSOLICIT] + aProdSel[nI][ITMSOLICIT] })
Next nI
SM0->(DbGoTo(nSM0Recno))  

aSort(aWBrowse1,,,{|x,y| x[11] < y[11]})

DEFINE MSDIALOG oDlg TITLE 'Resumo do processamento' FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL
@ 024, 024 SAY  oSay1 PROMPT cMensagem SIZE 193, 016 OF oDlg COLORS 0, 16777215 PIXEL
@ 015, 020 GROUP oGroup1  TO 045, 330 PROMPT '' OF oDlg COLOR 0, 16777215 PIXEL
@ 047, 020 GROUP oGroup2  TO 120, 330 PROMPT '' OF oDlg COLOR 0, 16777215 PIXEL
@ 012, 016 GROUP oGroup3  TO 123, 333 PROMPT '' OF oDlg COLOR 0, 16777215 PIXEL
fGetDados1(aWBrowse1)
DEFINE SBUTTON oSButton1 FROM 130, 320 TYPE 02 OF oDlg ENABLE ACTION fCloseDlg()
ACTIVATE MSDIALOG oDlg CENTERED

/*/{Protheus.doc} fGetDados1
Monta linhas do grid da mensagem de processamento.
@author 	Paulo Krüger
@since 		24/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/

Static Function fGetDados1(aWBrowse1)
Local nX			:= 0
Local aHeaderEx		:= {}
Local aColsEx		:= {}
Local aAlterFields	:= {}
Local cInvoice		:= ''
Local cPosicao		:= ''
Local cNomeFil		:= ''
Local cFilOri		:= ''
Local cNomeFil		:= ''
Local cNumSC		:= ''
Local cItemSC		:= ''
Local cContrato		:= ''
Local cMedicao		:= ''
Local cItemMed		:= ''
Local cPedCom		:= ''
Local cItemPC		:= ''
Local cObs			:= ''
Local oWBrowse1 

@ 050, 022 	LISTBOX oWBrowse1 Fields HEADER 	'Filial'		,	;
												'Nome'			,	;
												'Sol.Compra'	,	;
												'Item'			,	;
												'Contrato'		,	;
												'Medição'		,	;
												'Produto'		,	;
												'Descrição'		,	;
												'Item med'		,	;
												'Ped.Compra'	,	;
												'Item PC'		,	;
												'Observações'		;
			SIZE 301, 069 OF oDlg PIXEL ColSizes 50,50

oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {;
						aWBrowse1[oWBrowse1:nAt,01],	;
						aWBrowse1[oWBrowse1:nAt,02],	;
						aWBrowse1[oWBrowse1:nAt,03],	;
						aWBrowse1[oWBrowse1:nAt,04],	;
						aWBrowse1[oWBrowse1:nAt,05],	;
						aWBrowse1[oWBrowse1:nAt,06],	;												
						aWBrowse1[oWBrowse1:nAt,07],	;
						aWBrowse1[oWBrowse1:nAt,08],	;
						aWBrowse1[oWBrowse1:nAt,09],	;
						aWBrowse1[oWBrowse1:nAt,10],	;
						aWBrowse1[oWBrowse1:nAt,11],	;
						aWBrowse1[oWBrowse1:nAt,12]		;
						}}

oWBrowse1:bLDblClick := {|| fAvisoExec(aWBrowse1,oWBrowse1:nAt),;
oWBrowse1:DrawSelect()}

Return
 
 
/*/{Protheus.doc} fAvisoExec
Exibe detalhe da observação
@author 	Paulo Krüger
@since 		10/10/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/   

Static Function fAvisoExec(aDados, nLinha)

Local oButton1
Local oGroup1
Local oMultiGe1
Local cMultiGe1 := ''
Static oDlg01
    
cMultiGe1 := aDados[nLinha][10]

DEFINE MSDIALOG oDlg01 TITLE 'Observações' FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
@ 003, 004 GROUP	oGroup1		TO 246, 246 PROMPT 'Observação detalhada' OF oDlg01 COLOR 0, 16777215 PIXEL
@ 222, 194 BUTTON	oButton1	PROMPT 'Sair' SIZE 046, 015 OF oDlg01 ACTION oDlg01:End() PIXEL
@ 021, 013 GET		oMultiGe1	VAR cMultiGe1 OF oDlg01 MULTILINE SIZE 220, 163 COLORS 0, 16777215 HSCROLL PIXEL

ACTIVATE MSDIALOG oDlg01 CENTERED

Return 
  
 
/*/{Protheus.doc} fCloseDlg
Fecha tela de processamento / markbrowse de seleção de SCs
@author 	Paulo Krüger
@since 		07/09/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/
Static Function fCloseDlg()

aArea := GetArea()

oDlg:End()			//Fecha tela de resumo de processamento 
oDlgMark:End()		//Fecha tela markbrowse de seleção de SCs
oDlg		:= Nil
oDlgMark	:= Nil
oMrkBrowse	:= Nil	//Reinicia objeto MarkBrowse

If IsInCallStack('U_F1200601') 
	//Medição Automatica
	Pergunte('FSW1200601',.F.)
	U_F1200701(.T., .T., .T., mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08)
Else	
	//Medição Automatizada
	U_F1200701(.T., .T., .F.)
EndIf

RestArea(aAreaSC1)                                         

Return