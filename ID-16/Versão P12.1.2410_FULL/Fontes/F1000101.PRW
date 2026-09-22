#INCLUDE 'TOTVS.CH'

/*
{Protheus.doc} F1000101()
Relatório	PCOTA
@Author		Paulo Krüger
@Since      10/05/2017
@Version    P12.7
@Project    MAN0000007423041_EF_001 
*/

User Function F1000101()

Local oReport	
 
Pergunte('FSW1000101',.T.)
	
If Empty(MV_PAR01) .and. Empty(MV_PAR02) 
	MsgAlert('Não foi possível gerar o relatório. Favor revisar os parâmetros.')
	Return
ElseIf MV_PAR02 < MV_PAR01 
	MsgAlert('Não foi possível gerar o relatório. O parâmetro Até: possui conteúdo inferior ao parâmetro De:.')
	Return
EndIf
	
oReport := ReportDef()
oReport :PrintDialog()

Return

Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local oSection3
	
oReport:= TReport():New('F1000101','Relatório PCOTA','F1000101',{|oReport| ReportPrint(oReport)},'Relatório PCOTA')
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
oReport:nFontBody	:= 8 // Define o tamanho da fonte.
oReport:nLineHeight	:= 40 // Define a altura da linha.

oSection1:= TRSection():New(oReport, 'Solicitação de Compra', {'cAlias01'}, , .F., .T.)
TRCell():New(oSection1,'NUMSOLI'		,'cAlias01','SC'  		,'@!',06)

oSection2:= TRSection():New(oReport, 'Itens da Solicitação de Compra', {'cAlias01'}, , .F., .T.)
TRCell():New(oSection2,'CODPROD', 'cAlias01', 'Produto'   , '@!'                      , TamSX3("B1_COD")[1]    )
TRCell():New(oSection2,'DESPROD', 'cAlias01', 'Descricao' , '@!'                      , TamSX3("B1_DESC")[1]   )
TRCell():New(oSection2,'REFEREN', 'cAlias01', 'Referencia', '@!'                      , TamSX3("B1_XREFER")[1] )
TRCell():New(oSection2,'QUANTSC', 'cAlias01', 'Quantidade', PesqPict("SC1","C1_QUANT"), 15                     )

oSection3:= TRSection():New(oReport, 'Itens de Nota Fiscal de Entrada', {'cAlias01'}, , .F., .T.)
TRCell():New(oSection3,'FORNECE', 'cAlias01', 'Fornecedor'   , '@!'                       , 06 )
TRCell():New(oSection3,'LOJAFOR', 'cAlias01', 'Loja'         , '@!'                       , 02 )
TRCell():New(oSection3,'NOMEFOR', 'cAlias01', 'Nome'         , '@!'                       , 40 )
TRCell():New(oSection3,'UNIDMED', 'cAlias01', 'Unid. Med.'   , '@!'                       , 02 )
TRCell():New(oSection3,'QUANTNF', 'cAlias01', 'Quantidade'   , PesqPict("SD1","D1_QUANT") , 12 )
TRCell():New(oSection3,'DTDIGIT', 'cAlias01', 'Dt. Digitacao', '@!'                       , 10 )
TRCell():New(oSection3,'VALUNIT', 'cAlias01', 'Val. Unit.'   , PesqPict("SD1","D1_VUNIT") , 19 )
TRCell():New(oSection3,'DESCONT', 'cAlias01', 'Desconto'     , PesqPict("SD1","D1_DESC")  , 19 )
TRCell():New(oSection3,'ALIQIPI', 'cAlias01', 'Aliq. IPI'    , PesqPict("SD1","D1_IPI")   ,  6 )
TRCell():New(oSection3,'VALOIPI', 'cAlias01', 'Val. IPI'     , PesqPict("SD1","D1_VALIPI"), 19 )
TRCell():New(oSection3,'VALOTOT', 'cAlias01', 'Val. Tot.'    , PesqPict("SD1","D1_TOTAL") , 19 )

Return(oReport)

/*
{Protheus.doc} ReportPrint()
Imprimi Relatório
@Author		Paulo Krüger
@Since      10/05/2017
@Version    P12.7
@Project    MAN0000007423041_EF_001 
@param		oReport
*/
Static Function ReportPrint(oReport)

Local cAlias01	:= ''
Local cRefer01	:= ''
Local cRefer02	:= ''
Local cFilSC1	:= xFilial('SC1') 
Local cFilSB1	:= xFilial('SB1')
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local aStru		:= {}
Local cArq		:= ''
Local lIni01	:= .F.
Local lIni03	:= .F.
Local lEnc01	:= .F.
Local lEnc03	:= .F.
Local nI		:= 0

AADD(aStru,{'FILSOLI'	,'C',08,00})
AADD(aStru,{'NUMSOLI'	,'C',06,00})
AADD(aStru,{'ITESOLI'	,'C',04,00})
AADD(aStru,{'CODPROD'	,'C',TamSX3("B1_COD")[1]   ,00})
AADD(aStru,{'DESPROD'	,'C',TamSX3("B1_DESC")[1]  ,00})
AADD(aStru,{'REFEREN'	,'C',TamSX3("B1_XREFER")[1],00})
AADD(aStru,{'QUANTSC'	,'N',12,02})
AADD(aStru,{'FORNECE'	,'C',06,00})
AADD(aStru,{'LOJAFOR'	,'C',02,00})
AADD(aStru,{'NOMEFOR'	,'C',40,00})
AADD(aStru,{'UNIDMED'	,'C',02,00})
AADD(aStru,{'QUANTNF'	,'N',12,02})
AADD(aStru,{'DTDIGIT'	,'D',08,00})
//AADD(aStru,{'VALUNIT'	,'N',15,02})
AADD(aStru,{'VALUNIT'	,'N',TAMSX3("D1_VUNIT")[1],TAMSX3("D1_VUNIT")[2]})
AADD(aStru,{'DESCONT'	,'N',15,02})
AADD(aStru,{'ALIQIPI'	,'N',06,02})
AADD(aStru,{'VALOIPI'	,'N',15,02})
AADD(aStru,{'VALOTOT'	,'N',15,02})

//Início - Thais Paiva - Compatibilização P27
//cArq := Criatrab(aStru,.T.)
//DbUseArea(.T.,,cArq,'cAlias01')
oTempTable := FWTemporaryTable():New( "cAlias01" ) 	
oTemptable:SetFields( aStru )
oTempTable:AddIndex( '01' , { "FILSOLI","NUMSOLI","ITESOLI" } ) //Thais Paiva - 04/12/2020
oTempTable:Create()	
//Fim - Thais Paiva - Compatibilização P27

SC1->(dBSetOrder(01))

If Empty(MV_PAR01)
	MV_PAR01 := ''
EndIf

If SC1->(dBSeek(cFilSC1 + MV_PAR01,.T.))
	While !SC1->(Eof()) .and. SC1->C1_FILIAL == cFilSC1 .and. SC1->C1_NUM >= MV_PAR01 .and. SC1->C1_NUM <= MV_PAR02
		SB1->(dBSetOrder(01))
		If SB1->(dBSeek(cFilSB1 + SC1->C1_PRODUTO,.F.))

		  	fRetNFE(SC1->C1_FILIAL, SC1->C1_NUM, SC1->C1_ITEM, SC1->C1_PRODUTO, SB1->B1_DESC, SC1->C1_QUANT, SB1->B1_XREFER)

	  	EndIf
	  	SC1->(dBSkip())
	EndDo
EndIf

cAlias01->(DbGoTop()) 


While cAlias01->(!EOF()) 
	If oReport:Cancel() 
		Exit
	EndIf

	If !(cRefer01 == cAlias01->NUMSOLI) 		
		
		If lEnc01
			oSection1:Finish()
			lEnc01 := .F.
		EndIf
				
		nI += 01
		If nI >= 01
			lIni01  := .T. 
			lIni03  := .T. 
		EndIf
		If lIni01 
			oSection1:Init()
			lIni01	:= .F.
			lEnc01	:= .T.
			nI := 0
		EndIf	
		cRefer01 := cAlias01->NUMSOLI
		oReport:IncMeter()
		oSection1:Cell('NUMSOLI'):SetValue(cAlias01->NUMSOLI)
		oSection1:Printline()
	EndIf
	If !(cRefer02 == cAlias01->NUMSOLI + cAlias01->ITESOLI)
		cRefer02 := cAlias01->NUMSOLI + cAlias01->ITESOLI

		lIni03 := .T. 		
		If lEnc03
			oSection3:Finish()
		EndIf

		oSection2:Init() 
		oReport:IncMeter()
		oSection2:Cell('CODPROD'):SetValue(cAlias01->CODPROD)
		oSection2:Cell('DESPROD'):SetValue(cAlias01->DESPROD)
		oSection2:Cell('REFEREN'):SetValue(cAlias01->REFEREN)
		oSection2:Cell('QUANTSC'):SetValue(cAlias01->QUANTSC)
		oSection2:Printline()

		oReport:ThinLine()
		oSection2:Finish()

	EndIf

	If lIni03
		oSection3:Init()
		lEnc03 := .T.
	EndIf
	lIni03 := .F.
		
	oSection3:Cell('NOMEFOR'):SetValue(cAlias01->NOMEFOR)
	oSection3:Cell('UNIDMED'):SetValue(cAlias01->UNIDMED)
	oSection3:Cell('QUANTNF'):SetValue(cAlias01->QUANTNF)
	oSection3:Cell('DTDIGIT'):SetValue(cAlias01->DTDIGIT)
	oSection3:Cell('VALUNIT'):SetValue(cAlias01->VALUNIT)
	oSection3:Cell('DESCONT'):SetValue(cAlias01->DESCONT)
	oSection3:Cell('ALIQIPI'):SetValue(cAlias01->ALIQIPI)
	oSection3:Cell('VALOIPI'):SetValue(cAlias01->VALOIPI)
	oSection3:Cell('VALOTOT'):SetValue(cAlias01->VALOTOT)
	oSection3:Printline()

	oReport:ThinLine()

	cAlias01->(DbSkip())
End

cAlias01->(DbCloseArea())
oTempTable:Delete() //Thais Paiva - 04/12/2020

Return

/*
{Protheus.doc} fRetNFE()
Retorna NFEs
@Author		Paulo Krüger
@Since      10/05/2017
@Version    P12.7
@Project    MAN0000007423041_EF_001 
@param		cFilOri  - Filial 
@param		cNumSC   - Solicitação de Compra
@param		cItemSC  - Item da Solicitação de Compra
@param		cProduto - Código do Produto
@param		cDescrPrd- Descrição do Produto
@param		nQuant   - Quantidade da Solicitação de Compra
*/

Static Function fRetNFE(cFilOri, cNumSC, cItemSC, cProduto, cDescrPrd, nQuant, cReferPrd)

Local cAlias02 	:= ''
Local cTES		:= ' '
Local nQtdItNF	:= 03
Local cFilSA2	:= xFilial('SA2')

cAlias02:= GetNextAlias()

BeginSql alias cAlias02
		
SELECT	SD1SORT.FILNOTA	FILNOTA	,
		SD1SORT.FORNECE	FORNECE	,
		SD1SORT.LOJAFOR	LOJAFOR	,
		SD1SORT.NOMEFOR	NOMEFOR	,
		SD1SORT.UNIDMED	UNIDMED	,
		SD1SORT.QUANTNF	QUANTNF	,
		SD1SORT.DTDIGIT	DTDIGIT	,
		SD1SORT.VALUNIT	VALUNIT	,
		SD1SORT.DESCONT	DESCONT	,
		SD1SORT.ALIQIPI	ALIQIPI	,
		SD1SORT.VALOIPI	VALOIPI	,
		SD1SORT.VALOTOT	VALOTOT	,
		SD1SORT.CODPROD	CODPROD
FROM (SELECT	SD1.D1_FILIAL	FILNOTA	,
				SD1.D1_FORNECE	FORNECE	,
				SD1.D1_LOJA		LOJAFOR	,
				SA2.A2_NOME 	NOMEFOR	,
				SD1.D1_UM		UNIDMED	,
				SD1.D1_QUANT	QUANTNF	,
				SD1.D1_DTDIGIT	DTDIGIT	,
				SD1.D1_VUNIT	VALUNIT	,
				SD1.D1_DESC		DESCONT	,
				SD1.D1_IPI      ALIQIPI	,
				SD1.D1_VALIPI 	VALOIPI	,
				SD1.D1_TOTAL	VALOTOT	,
				SD1.D1_COD		CODPROD ,
				SD1.D1_TES		TESNOTA
      FROM	%table:SD1% SD1 INNER JOIN %table:SA2% SA2 ON	SA2.A2_FILIAL	=	%exp:cFilSA2%	AND
															SA2.A2_COD		=	SD1.D1_FORNECE	AND
										    				SA2.A2_LOJA		=	SD1.D1_LOJA
	  WHERE	SD1.D1_TES		<>	%exp:cTES%		AND 										
			SD1.D1_FILIAL	=	%exp:cFilOri%	AND
			SD1.D1_COD		=	%exp:cProduto%	AND 
			SD1.%notDel%						AND
			SA2.%notDel%
	  ORDER BY SD1.D1_DTDIGIT DESC) SD1SORT
WHERE	ROWNUM <= %exp:nQtdItNF%			AND
		SD1SORT.FILNOTA	=	%exp:cFilOri%	AND
		SD1SORT.CODPROD =	%exp:cProduto%	AND
		SD1SORT.TESNOTA <>	%exp:cTES%
EndSql

(cAlias02)->(DbGoTop())

While (cAlias02)->(!Eof())

	RecLock('cAlias01',.T.)
	cAlias01->FILSOLI	:=	cFilOri
	cAlias01->NUMSOLI	:=	cNumSC
	cAlias01->ITESOLI	:=	cItemSC	
	cAlias01->CODPROD	:=	cProduto
	cAlias01->DESPROD	:=	cDescrPrd
	cAlias01->REFEREN	:=	cReferPrd
	cAlias01->QUANTSC	:=	nQuant
	cAlias01->FORNECE	:= (cAlias02)->FORNECE
	cAlias01->LOJAFOR	:= (cAlias02)->LOJAFOR
	cAlias01->NOMEFOR	:= (cAlias02)->NOMEFOR
	cAlias01->UNIDMED	:= (cAlias02)->UNIDMED
	cAlias01->QUANTNF	:= (cAlias02)->QUANTNF
	cAlias01->DTDIGIT	:= STOD((cAlias02)->DTDIGIT)
	cAlias01->VALUNIT	:= (cAlias02)->VALUNIT
	cAlias01->DESCONT	:= (cAlias02)->DESCONT
	cAlias01->ALIQIPI	:= (cAlias02)->ALIQIPI
	cAlias01->VALOIPI	:= (cAlias02)->VALOIPI
	cAlias01->VALOTOT	:= (cAlias02)->VALOTOT
	
	cAlias01->(MsUnLock())

	(cAlias02)->(DbSkip())

EndDo

(cAlias02)->(DbCloseArea())	

Return