#INCLUDE 'PROTHEUS.CH'
/*{Protheus.doc} F0200401
Relatório de Rastreabilidade de SC
@type User function
@author Cristiane Thomaz Polli
@since 04/07/2016
@version P12.1.7
@Project MAN00000463301_EF_004
@return ${return}, ${não há}
*/
User Function F0200401()

	Private oReport	 := Nil
	
	    If TRepInUse()
		
			oReport := ReportDef()
			
			If oReport == Nil
		
				Aviso('Relatório','Relatório Cancelado.',{"OK"}) 
		
			Else
		
				oReport:PrintDialog()
		
			Endif
		
		EndIf

Return

/*{Protheus.doc} ReportDef
Função onde devem ser criados os componentes de impressão, as seções e as células, 
os totalizadores e demais componentes que o usuário poderá personalizar 
no relatório.
@type Static function
@author Cristiane Thomaz Polli
@since 05/07/2016
@version  P12.1.7
@Project MAN00000463301_EF_004
@return ${oReport}, ${objeto}
*/
Static Function ReportDef()
	
	Local cTitulo := 'Relatório de Rastreabilidade de SC'
	Local cPergAtu:= 'FSW0200401'
	Local aColImpr:= {}
	Local nFor    :=0

		if pergunte(cPergAtu,.T.)
			
			//Valida o parametro Filial
			if Empty(MV_PAR01)
			
				Aviso('Não Preenchido','Informe no mínimo uma filial. Campo obrigatório!',{"OK"}) 
			
				Return oReport
				
			Else
				
				If !(U_F0200403())
	
					Return oReport
				
				EndIf			
					
				
			EndIf
			
			//Valida o parametro Setor
			If Empty(MV_PAR02)
			
				Aviso('Não Preenchido','Informe no mínimo uma setor. Campo obrigatório!',{"OK"}) 
			
				Return oReport

			Else
			
					If !(U_F0200402())
				
						Return oReport
						
					EndIf
				
			EndIf		
			
			//Valida os parametros de data
			if MV_PAR03 > MV_PAR04
			
				Aviso('Inválido Período','Data final  informada é menor que a data inicial informada. Favor verificar as datas informadas!',{"OK"}) 
			
				Return oReport
				
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³funcao para trazer em array as regras de colunas conforme o tipo de pesquisa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColImpr := F02004Col(aColImpr)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao do componente de impressao                                      ³
			//³                                                                        ³
			//³TReport():New                                                           ³
			//³ExpC1 : Nome do relatorio                                               ³
			//³ExpC2 : Titulo                                                          ³
			//³ExpC3 : Pergunte                                                        ³
			//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
			//³ExpC5 : Descricao                                                       ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:= TReport():New('F0200401_' + dtos(dDatabase) + '_' + StrTran(time(),':','_'),cTitulo,cPergAtu, {|oReport| ReportPrint(oReport,cPergAtu)},cTitulo)
			oReport:SetPortrait(.F.)
			oReport:SetLandscape(.T.)
									
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao da secao utilizada pelo relatorio                               ³
			//³                                                                        ³
			//³TRSection():New                                                         ³
			//³ExpO1 : Objeto TReport que a secao pertence                             ³
			//³ExpC2 : Descricao da seçao                                              ³
			//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
			//³        sera considerada como principal para a seção.                   ³
			//³ExpA4 : Array com as Ordens do relatório                                ³
			//³ExpL5 : Carrega campos do SX3 como celulas                              ³
			//³        Default : False                                                 ³
			//³ExpL6 : Carrega ordens do Sindex                                        ³
			//³        Default : False                                                 ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSec1 := TRSection():New(oReport,'Titulos',{"SC1"},{'Origem unica'},/*Campos do SX3*/,/*Campos do SIX*/)	
			oSec1:SetTotalInLine(.F.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao da celulas da secao do relatorio                                ³
			//³TRCell():New                                                            ³
			//³ExpO1 : Objeto TSection que a secao pertence                            ³
			//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
			//³ExpC3 : Nome da tabela de referencia da celula                          ³
			//³ExpC4 : Titulo da celula                                                ³
			//³        Default : X3Titulo()                                            ³
			//³ExpC5 : Picture                                                         ³
			//³        Default : X3_PICTURE                                            ³
			//³ExpC6 : Tamanho                                                         ³
			//³        Default : X3_TAMANHO                                            ³
			//³ExpL7 : Informe se o tamanho esta em pixel                              ³
			//³        Default : False                                                 ³
			//³ExpB8 : Bloco de código para impressao.                                 ³
			//³        Default : ExpC2                                                 ³
			//³                                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			For nFor := 1 to len(aColImpr)
				TRCell():New(oSec1,aColImpr[nFor][1],"QRY",aColImpr[nFor][2],/*Picture*/,aColImpr[nFor][3],/*lPixel*/,aColImpr[nFor][4])
			Next nFor	
									
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho no top da pagina                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Section(1):SetHeaderPage()	
			
		EndIf
		
Return oReport

/*{Protheus.doc} F02004Col
Retorna array com os titulos das colunas a serem exibidas no relátorio.
@type Static function
@author Cristiane Thomaz Polli
@since 05/07/2016
@version 12.1.7
@param aColImpr, array, (array vazio para ser retornado com os campos a exibir)
@Project MAN00000463301_EF_004
@return ${aColImpr}, ${Retorna os campos a serem exibidos.}
*/
Static Function F02004Col(aColImpr)

	Local aAreaSX3	:= SX3->(GetArea())
	
		AAdd(aColImpr,{'cFilC1'		,'Estabelecimento'			,TamSx3('C1_FILIAL')[1]			,Nil})
		AAdd(aColImpr,{'cSetor'		,'Cod.Setor'				,TamSx3('C1_LOCAL')[1]			,Nil})
		AAdd(aColImpr,{'cCodProd'	,'Cód.Material'				,TamSx3('C1_PRODUTO')[1]		,Nil})
		AAdd(aColImpr,{'cDesProd'	,'Descrição'				,TamSx3('C1_DESCRI')[1]			,Nil})
		AAdd(aColImpr,{'cSolic'		,'Solicitante'				,TamSx3('C1_SOLICIT')[1]		,Nil})
		AAdd(aColImpr,{'cNumSolic'	,'Número da Solic.'			,TamSx3('C1_NUM')[1]			,Nil})
		AAdd(aColImpr,{'cTpSolic'	,'Tipo de Solic.'			,TamSx3('C1_TPSC')[1]			,Nil})
		AAdd(aColImpr,{'cMotSolic'	,'Motivo da Solic.'			,10/*TamSx3('C1_XMOTIVO')[1]*/	,Nil})
		AAdd(aColImpr,{'dEmisSoli'	,'Emissao da Solic.'		,TamSx3('C1_EMISSAO')[1]		,{||(StoD(dEmisSoli))}})
		AAdd(aColImpr,{'DtLib'		,'Data Liberação'			,TamSx3('CR_DATALIB')[1]		,{||(StoD(DtLib))}})
		AAdd(aColImpr,{'cComprador'	,'Comprador'				,TamSx3('C7_USER')[1]			,Nil})
		AAdd(aColImpr,{'cNumPC'		,'Pedido de Compras'		,TamSx3('C7_NUM')[1]			,Nil})
		AAdd(aColImpr,{'dEmisPC'	,'Emissão PC'				,TamSx3('C7_EMISSAO')[1]		,{||(StoD(dEmisPC))}})
		AAdd(aColImpr,{'DtLib'		,'Data Aprovação'			,TamSx3('CR_DATALIB')[1]		,{||(StoD(DtLib))}})
		AAdd(aColImpr,{'cNumMed'	,'Numero Medição'			,TamSx3('CND_NUMMED')[1]		,Nil})
		AAdd(aColImpr,{'dDtMed'		,'Data da Medição'			,TamSx3('CND_DTINIC')[1]		,{||(StoD(dDtMed))}})
		AAdd(aColImpr,{'DtLib'		,'Aprovação Medição'		,TamSx3('CR_DATALIB')[1]		,{||(StoD(DtLib))}})
		AAdd(aColImpr,{'cNotaFis'	,'Nota Fiscal'				,TamSx3('F1_DOC')[1]			,Nil})
		AAdd(aColImpr,{'cSerNF'		,'Série da NF'				,TamSx3('F1_SERIE')[1]			,Nil})
		AAdd(aColImpr,{'dEmisNF'	,'Emissão da NF'			,TamSx3('F1_EMISSAO')[1]		,{||(StoD(dEmisNF))}})
		AAdd(aColImpr,{'DtEntreg'	,'Previsão Entrega'			,TamSx3('C7_DATPRF')[1]			,{||(StoD(DtEntreg))}})
		AAdd(aColImpr,{'DtEntreg'	,'Data de Entrega'			,TamSx3('C7_DATPRF')[1]			,{||(StoD(DtEntreg))}})
		AAdd(aColImpr,{'nQtdPrev'	,'Quantidade Prevista'		,TamSx3('C7_QUANT')[1]			,Nil})
		AAdd(aColImpr,{'nQtdEntre'	,'Quantidade Entregue'		,TamSx3('C7_QUJE')[1]			,Nil})
		AAdd(aColImpr,{'nQtdPEnd'	,'Quantidade Pendente'		,TamSx3('C7_QUANT')[1]			,Nil})
		AAdd(aColImpr,{'cCGC'		,'CPF/CNPJ'					,TamSx3('A2_CGC')[1]			,Nil})
		AAdd(aColImpr,{'cNomFor'	,'Nome Fornecedor'			,TamSx3('A2_NOME')[1]			,Nil})
		
	RestArea(aAreaSX3)

Return aColImpr

/*{Protheus.doc} ReportPrint
Responsável pela seleçaõ e impressão dos registros.
@type Static function
@author Cristiane Thomaz Polli
@since 05/07/2016
@version 12.1.7
@param oReport, objeto, (Descrição do parâmetro)
@param cPergAtu, caracter, (Nome do Parametro de perguntas SX1)
@Project MAN00000463301_EF_004
@return ${return}, ${não existe}
*/
Static Function ReportPrint(oReport,cPergAtu)
	
	Local cWheryC1	:= ''
	
	// Transforma parametros Range em expressao SQL
	MakeSqlExpr(cPergAtu)
		
	cWheryC1	:= MV_PAR01
	
	if !Empty(MV_PAR02)
	
			cWheryC1	+= 'AND' + MV_PAR02
	
	EndIf
	
	cWheryC1 := "%" + cWheryC1 + "%"
	
	BeginSql Alias "QRY"
		   				
		SELECT C1_FILIAL cFilC1, C1_LOCAL cSetor, C1_PRODUTO cCodProd, C1_DESCRI cDesProd, C1_SOLICIT cSolic, C1_NUM cNumSolic, C1_TPSC cTpSolic,
		C1_XMOTIVO cMotSolic, C1_EMISSAO dEmisSoli,
		C7_USER cComprador, C7_NUM cNumPC, C7_EMISSAO dEmisPC, C7_DATPRF DtEntreg, C7_QUANT nQtdPrev, C7_QUJE nQtdEntre, C7_QUANT - C7_QUJE nQtdPEnd,
		CND_NUMMED cNumMed, CND_DTINIC dDtMed, 
		D1_DOC cNotaFis, D1_SERIE cSerNF, D1_EMISSAO dEmisNF,
		A2_NOME cNomFor, A2_CGC  cCGC,
		MAX(CR_DATALIB) DtLib
		FROM %table:SC1% SC1 (NOLOCK)
		LEFT JOIN %table:SC7% SC7 (NOLOCK)
		        ON  SC7.%notDel% 		   
			   AND C7_FILIAL  = C1_FILIAL
			   AND C7_NUMSC = C1_NUM
			   AND C7_ITEMSC = C1_ITEM
		LEFT JOIN %table:CND% CND  (NOLOCK)
		       ON CND_FILIAL = C7_FILIAL
		      AND CND_PEDIDO = C7_NUM
		      AND  CND.%notDel%   
		LEFT JOIN  %table:SD1% SD1 (NOLOCK)
		       ON D1_FILIAL = C1_FILIAL
		       AND SD1.%notDel%  
		       AND D1_PEDIDO = C7_NUM
		       AND D1_ITEM = C7_ITEM
		LEFT  JOIN %table:SA2% SA2 (NOLOCK)
		        ON A2_FILIAL = %exp:xFilial("SA2")%
		        AND A2_COD = C7_FORNECE
		        AND A2_LOJA = C7_LOJA
		        AND SA2.%notDel% 
		LEFT JOIN %table:SCR%  SCR
     		   ON CR_FILIAL = C1_FILIAL
			  AND CR_NUM = C1_NUM
     		  AND CR_TIPO = 'SC'
			  AND CR_DATALIB > '        '
     		  AND SCR.%notDel% 
		WHERE 	%Exp:cWheryC1% 
		  AND SC1.%notDel% 
	      AND C1_EMISSAO BETWEEN %exp:Dtos(MV_PAR03)%  AND %exp:Dtos(MV_PAR04)% 
		GROUP BY C1_FILIAL, C1_LOCAL, C1_PRODUTO, C1_DESCRI, C1_SOLICIT, C1_NUM, C1_TPSC,
		C1_XMOTIVO, C1_EMISSAO, C7_USER, C7_NUM, C7_EMISSAO, C7_DATPRF, C7_QUANT, C7_QUJE, C7_QUANT - C7_QUJE,
		CND_NUMMED, CND_DTINIC, D1_DOC, D1_SERIE, D1_EMISSAO, A2_NOME, A2_CGC
		ORDER BY C1_FILIAL, C1_EMISSAO, C1_NUM, C1_PRODUTO
	   
   EndSql
      
   oReport:SetMeter(0)
    
    // Impressão do cabecalho da sessao
	oReport:Section(1):Init()
	
	While  !QRY->(Eof())

		oReport:Section(1):PrintLine()//imprime a linha
		QRY->(dbSkip())

	EndDo
	
	QRY->(DbCloseArea())
		   
	oReport:Section(1):Finish()
	oReport:Section(1):SetPageBreak()
Return