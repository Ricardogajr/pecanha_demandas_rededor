#Include 'Protheus.ch'

#Include "rwmake.ch"
#Include "topconn.ch"
#Include "protheus.ch"

/*
{Protheus.doc} TEWBTYR1()
Relatório de Faturas Emitidas
@Author     Ramon Teodoro
@Since      20/04/2016       
@Version    P12.7
@Return     lRet
*/

User Function TEWBTYR1()
	
Local oReport
Private cPerg := "TEWBTYR1"

CriaSX1(cPerg)

//If TRepInUse()
	Pergunte(cPerg, .F.)
	oReport := ReportDef()
	oReport:PrintDialog()	
//EndIf
	
Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Montagem da estrutura do Relatório						   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
*/
Static Function ReportDef()

Local oReport
Local oSecFat
Local oSecTit
//Local oSecCli
Local oBreak

oReport := TReport():New("TEWBTYR1","Faturas Emitidas",cPerg,{|oReport| PrintReport(oReport)},"Faturas Emitidas")

oReport:oPage:nPaperSize	:= 9  
oReport:nFontBody			:= 08
oReport:nLineHeight			:= 60
oReport:cFontBody 			:= "Arial"
oReport:nFontBody 			:= 9
oReport:lBold 				:= .F.
oReport:lUnderLine 			:= .F.
oReport:lHeaderVisible 		:= .T.
oReport:lFooterVisible 		:= .F.
oReport:DisableOrientation()  
//oReport:SetPortrait()
oReport:SetTotalInLine(.F.)
oReport:SetLeftMargin(2)
oReport:oPage:SetPageNumber(1)
oReport:SetColSpace(1)
oReport:SetLandscape()

oSecFat := TRSection():New(oReport,"Fatura")
oSecTit	:= TRSection():New(oReport,"Títulos")
	
TRCell():New(oSecFat,"E2_FATURA","",,,TAMSX3("E2_FATURA")[1])	
TRCell():New(oSecFat,"E2_FORNECE","",,,TAMSX3("E2_FORNECE")[1])
TRCell():New(oSecFat,"E2_VALOR","","Valor",,TAMSX3("E2_VALOR")[1])
//TRCell():New(oSecFat,"E2_SALDO","",,,16)
//oSecFat:SetHeaderSection(.F.)

TRCell():New(oSecTit,"E2_FILIAL","",,,30)
TRCell():New(oSecTit,"E2_PREFIXO","",,,TAMSX3("E2_PREFIXO")[1])	
TRCell():New(oSecTit,"E2_NUM","",,,TAMSX3("E2_NUM")[1])
TRCell():New(oSecTit,"E2_TIPO","",,,TAMSX3("E2_TIPO")[1])
//TRCell():New(oSecTit,"E2_FORNECE","",,,)
TRCell():New(oSecTit,"E2_FORNECE" ,,,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*{|| E2_FORNECE+'-'+E2_NOMFOR}*/)
TRCell():New(oSecTit,"E2_NATUREZ","",,,TAMSX3("E2_NATUREZ")[1])
TRCell():New(oSecTit,"E2_EMISSAO","",,,TAMSX3("E2_EMISSAO")[1])
TRCell():New(oSecTit,"E2_VENCTO","",,,TAMSX3("E2_VENCTO")[1])
TRCell():New(oSecTit,"E2_VALOR","",,"@E 99,999,999.99",TAMSX3("E2_VALOR")[1])

//TRFunction():New(oSecTit:Cell("E2_NUM"),NIL,"COUNT",,NIL,NIL,NIL,.F.,.T.)
TRFunction():New(oSecTit:Cell("E2_VALOR"),NIL,"SUM",,NIL,NIL,NIL,.F.,.T.)

If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
	
Return oReport


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Impressão do Relatório									   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
*/
Static Function PrintReport(oReport)

Local oSecFat	:= oReport:Section(1)
Local oSecTit	:= oReport:Section(2)
Local aFilial   :=	U_TEWBTR12()
Local nPos      := 0
Local cNomeFil  := ""
	
BeginSql Alias "TRB1"
SELECT E2_FILIAL, E2_NUM, E2_FORNECE, E2_VALOR, E2_SALDO
FROM   %table:SE2% E2A
WHERE   E2_NUM     between %exp:MV_PAR01%  AND %exp:MV_PAR02%
       	AND E2_FORNECE between %exp:MV_PAR05% AND %exp:MV_PAR06%
       	AND E2_NATUREZ between %exp:MV_PAR07% AND %exp:MV_PAR08%
       	AND E2_EMISSAO between %exp:DtoS(MV_PAR09)% AND  %exp:DtoS(MV_PAR10)%
       	AND E2_VENCTO  between %exp:DtoS(MV_PAR11)% AND  %exp:DtoS(MV_PAR12)%
       	AND E2_FATURA = 'NOTFAT'
       	AND E2A.%NotDel%
EndSql

TRB1->(DbGoTop())

oSecFat:Init()
oSecTit:Init()
/*
oSecTit:Cell("E2_FILIAL") 
oSecTit:Cell("E2_PREFIXO") 
oSecTit:Cell("E2_NUM") 
oSecTit:Cell("E2_TIPO") 
oSecTit:Cell("E2_FORNECE") 
oSecTit:Cell("E2_NATUREZ") 	
oSecTit:Cell("E2_EMISSAO")  
oSecTit:Cell("E2_VENCTO") 
oSecTit:Cell("E2_VALOR") 
//oSecTit:PrintLine()
*/
While !oReport:Cancel() .And. !TRB1->(Eof())
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	cFatura := TRB1->E2_NUM
	
	oSecFat:Cell("E2_FATURA"):SetValue(TRB1->E2_NUM)
	oSecFat:Cell("E2_FORNECE" ):SetValue(TRB1->E2_FORNECE)
	oSecFat:Cell("E2_VALOR"  ):SetValue(TRB1->E2_VALOR)
	//oSecFat:Cell("E2_SALDO"  ):SetValue(TRB1->E2_SALDO)
	oSecFat:PrintLine()
	
	BeginSql Alias "TRB2"

		SELECT E2_FILIAL,E2_NUM,E2_FATURA,E2_PREFIXO,E2_TIPO,E2_EMISSAO,E2_VENCTO,E2_FORNECE,E2_NOMFOR,E2_NATUREZ,E2_VALOR
		FROM   %table:SE2% E2B
		WHERE  E2_FATURA = %exp:cFatura%
		        AND E2_NUM     between %exp:MV_PAR03% AND %exp:MV_PAR04%
		        AND E2_FORNECE between %exp:MV_PAR05% AND %exp:MV_PAR06%
		        AND E2_NATUREZ between %exp:MV_PAR07% AND %exp:MV_PAR08%
		        AND E2_EMISSAO between %exp:DtoS(MV_PAR09)% AND %exp:DtoS(MV_PAR10)%
		        AND E2_VENCTO  between %exp:DtoS(MV_PAR11)% AND %exp:DtoS(MV_PAR12)%
		        AND E2B.%NotDel% 

	EndSql

	TRB2->(dbGoTop())

	While !oReport:Cancel() .And. !TRB2->(Eof())
		oReport:IncMeter()
		
		If oReport:Cancel()
			Exit
		EndIf
		
		nPos := aScan(aFilial, {|x|x[1] == TRB2->E2_FILIAL})
		If nPos > 0
			cNomeFil := aFilial[nPos][2]
		EndIf
				
		oSecTit:Cell("E2_FILIAL"):SetValue(TRB2->E2_FILIAL + "-" + Alltrim(cNomeFil))
		oSecTit:Cell("E2_PREFIXO"):SetValue(TRB2->E2_PREFIXO)
		oSecTit:Cell("E2_NUM"):SetValue(TRB2->E2_NUM)
		oSecTit:Cell("E2_TIPO"):SetValue(TRB2->E2_TIPO)
		oSecTit:Cell("E2_FORNECE"):SetValue(Alltrim(TRB2->E2_FORNECE) + "-" + Alltrim(TRB2->E2_NOMFOR))
		oSecTit:Cell("E2_NATUREZ"):SetValue(TRB2->E2_NATUREZ)	
		oSecTit:Cell("E2_EMISSAO"):SetValue(STOD(TRB2->E2_EMISSAO))
		oSecTit:Cell("E2_VENCTO"):SetValue(STOD(TRB2->E2_VENCTO))
		oSecTit:Cell("E2_VALOR"):SetValue(TRB2->E2_VALOR)
		oSecTit:PrintLine()
		
		TRB2->(dbSkip())
		
	End
	
	TRB2->(DbCloseArea())
	oReport:SkipLine()
	
	TRB1->(dbSkip())
				
End

oSecTit:Finish()
oSecFat:Finish()
	
Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Perguntas do Relatório									   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
*/
Static Function CriaSX1(cPerg)

PutSx1(cPerg, "01","Fatura De: "    , "", "", "mv_ch1", "C", 09, 00, 00, "G","", "", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código da fatura inicial.","                      "},{},{},"")
PutSx1(cPerg, "02","Fatura Até:"    , "", "", "mv_ch2", "C", 09, 00, 00, "G","", "", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código da fatura final.","                                "},{},{},"")
PutSx1(cPerg, "03","Título De: "    , "", "", "mv_ch3", "C", 09, 00, 00, "G","", "", "", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código do título inicial.","                      "},{},{},"")
PutSx1(cPerg, "04","Título Até:"    , "", "", "mv_ch4", "C", 09, 00, 00, "G","", "", "", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código do título final.","                                "},{},{},"")
PutSx1(cPerg, "05","Fornecedor De: ", "", "", "mv_ch5", "C", 06, 00, 00, "G","", "SA2", "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código do fornecedor inicial.","                      "},{},{},"")
PutSx1(cPerg, "06","Fornecedor Até:", "", "", "mv_ch6", "C", 06, 00, 00, "G","", "SA2", "", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código do fornecedor final.","                                "},{},{},"")
PutSx1(cPerg, "07","Natureza De: "  , "", "", "mv_ch7", "C", 10, 00, 00, "G","", "SED", "", "", "MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código da natureza inicial.","                      "},{},{},"")
PutSx1(cPerg, "08","Natureza Até:"  , "", "", "mv_ch8", "C", 10, 00, 00, "G","", "SED", "", "", "MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Código da natureza final.","                                "},{},{},"")
PutSx1(cPerg, "09","Emissão De: "   , "", "", "mv_ch9", "D", 8, 00, 00, "G","", "", "", "", "MV_PAR09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Data de emissão inicial.","                      "},{},{},"")
PutSx1(cPerg, "10","Emissão Até:"    , "", "", "mv_ch10", "D",8, 00, 00, "G","", "", "", "", "MV_PAR10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Data de emissão final.","                                "},{},{},"")
PutSx1(cPerg, "11","Vencimento De: " , "", "", "mv_ch11", "D", 8, 00, 00, "G","", "", "", "", "MV_PAR11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Data de vencimento inicial.","                      "},{},{},"")
PutSx1(cPerg, "12","Vencimento Até:" , "", "", "mv_ch12", "D",8, 00, 00, "G","", "", "", "", "MV_PAR12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Data de vencimento final.","                                "},{},{},"")


Return

/*
{Protheus.doc} TEWBTYR12()
Função que retorna o nome da filial
@Author     Ramon Teodoro
@Since      20/04/2016       
@Version    P12.7
@Return     lRet
*/
User Function TEWBTR12

Local aRet     := {}
Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())

DbSelectArea( "SM0" )
SM0->(DbGoTop())
While SM0->(!Eof())

	If SM0->M0_CODIGO == cEmpAnt
		Aadd( aRet, {Alltrim(SM0->M0_CODFIL), SM0->M0_FILIAL})
	EndIf
	
	SM0->(DbSkip())
End

RestArea(aArea)
RestArea(aAreaSM0)

Return aRet

