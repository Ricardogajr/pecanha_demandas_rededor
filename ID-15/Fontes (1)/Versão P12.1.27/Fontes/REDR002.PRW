#include 'parmtype.ch'
#include "PROTHEUS.CH"	
#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"
/*/{Protheus.doc} RERI001
//TODO Descrição Relaltório de pedidos pendentes de SP.
@author Ricardo Junior
@since 07/06/2019
@version 1.0
@return Nil

@type function
/*/
User Function REDR002()

	Local _aArea 	  	:= GetArea()
	Local _cPerg 	  	:= 'REDR002'
	Private cAlias 		:= GetNextAlias() 
 
	FAJUSTSX1( _cPerg )

	If ! Pergunte( _cPerg, .T. )
		Return
	EndIf

	Processa( {|| fExec()}, "Aguarde...","Processando Relatório de Aprovações...", .F. )

	RestArea( _aArea )

Return

Static Function fExec

	Local _cPath 	:= "C:\REL_APROV\" 
	Local _cArq 	:= "APROV"+"_"+StrZero(Seconds(),5,0)+".csv"
	Local aArea 	:= GetArea()
	Local _cQuery 	:= " " 
	Local _nTotal 	:= 0 
	
	If !ExistDir(_cPath)
		If !MakeDir(_cPath)
			MsgAlert('Não foi possivel criar o arquivo de log, por favor, contate o admnistrador do sistema.')
		EndIf
	EndIf
	/*
	_cQuery := " WITH A AS (" + CRLF
	_cQuery += " SELECT DISTINCT C7_FILIAL, C7_ITEM, C7_EMISSAO, C7_NUM, C7_QUANT, C7_QUJE,C7_QTDACLA, C7_XDTVEN,C7_CONAPRO, C7_FORNECE, C7_APROV, C7_XSOLPAG, C7_XTIPO, C7_CC, C7_PRODUTO" + CRLF
	_cQuery += " FROM "+RetSqlName("SC7")+" C7" + CRLF
	_cQuery += " WHERE C7_XSOLPAG = '1'" + CRLF
	_cQuery += " AND C7_CONAPRO = 'B'" + CRLF
	_cQuery += " AND C7_QUJE < C7_QUANT" + CRLF
	_cQuery += " AND D_E_L_E_T_ = ' '" + CRLF
	_cQuery += " ORDER BY C7.C7_FILIAL, C7_XDTVEN" + CRLF
	_cQuery += " )" + CRLF
	_cQuery += " SELECT CR_FILIAL AS FILIAL, TRIM(CR_NUM) AS SOL_PAG, C7_XTIPO AS TIPO_REQ, C7_FORNECE AS FORNECE, A2_NOME AS NOME_FORNECE, CR_APROV AS COD_APROV, 
	_cQuery += " 		AK_NOME AS APROV,CR_USER AS USUARIO_APROV,  C7_CC AS CENTRO_CUSTO, CTT_DESC01 AS DESC_CENTRO_CUSTO, CR_TOTAL AS TOTAL, C7_PRODUTO AS PRODUTO, C7_EMISSAO AS EMISSAO," + CRLF
	_cQuery += "        CR_NIVEL AS NIVEL, --01=Aguardando nivel anterior;02=Pendente" + CRLF
	_cQuery += "        C7_XDTVEN AS DATA_VENCIMENTO, CR_STATUS, CR_GRUPO, CR_DATALIB, CR_USERLIB, CR_LIBAPRO" + CRLF
	_cQuery += "   FROM A" + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("SCR")+" CR ON C7_FILIAL = CR_FILIAL AND C7_NUM = CR_NUM AND CR_TIPO = 'PC'" + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("SAK")+" AK ON AK_FILIAL = CR_FILIAL AND AK_COD = CR_APROV AND CR_USER = AK_USER" + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("SA2")+" A2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = C7_FORNECE	" + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT_CUSTO = C7_CC	" + CRLF*/
	
		_cQuery := " SELECT CR_FILIAL AS FILIAL," + CRLF 
    _cQuery += " TRIM(CR_NUM) AS SOL_PAG,   " + CRLF
	_cQuery += " C7.C7_XTIPO AS TIPO_REQ, C7.C7_FORNECE AS FORNECE, A2_NOME AS NOME_FORNECE," + CRLF
	_cQuery += " CR_APROV AS COD_APROV, AK_NOME AS APROV, CR_USER AS USUARIO_APROV, C7_CC AS CENTRO_CUSTO," + CRLF
	_cQuery += " CTT_DESC01 AS DESC_CENTRO_CUSTO, CR_TOTAL AS TOTAL, C7_PRODUTO AS PRODUTO, C7_EMISSAO AS EMISSAO," + CRLF
	_cQuery += " MIN(CR_NIVEL) AS NIVEL, C7_XDTVEN AS DATA_VENCIMENTO, CR_STATUS, CR_GRUPO, CR_DATALIB,  CR_USERLIB," + CRLF
	_cQuery += " CR_LIBAPRO                                                                                                             " + CRLF
	_cQuery += " FROM "+RetSqlName("SCR")+" CR                                                                                          " + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("SAK")+" AK                                                                                    " + CRLF
	_cQuery += " 	ON AK_FILIAL = CR_FILIAL                                                                                            " + CRLF
	_cQuery += " 	AND AK_COD = CR_APROV                                                                                               " + CRLF
	_cQuery += " 	AND CR_USER = AK_USER                                                                                               " + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("SC7")+" C7                                                                                    " + CRLF
	_cQuery += " 	ON C7_FILIAL = CR_FILIAL                                                                                            " + CRLF
	_cQuery += " 	AND C7_NUM = CR_NUM                                                                                                 " + CRLF
	_cQuery += " 	AND C7_CONAPRO = 'B'                                                                                                " + CRLF
	_cQuery += " 	AND C7_XSOLPAG = '1'                                                                                                " + CRLF
	_cQuery += " 	AND C7_QUJE < C7_QUANT                                                                                              " + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("SA2")+" A2                                                                                    " + CRLF
	_cQuery += " 	ON A2_FILIAL = '        '                                                                                           " + CRLF
	_cQuery += " 	AND A2_COD = C7.C7_FORNECE	                                                                                        " + CRLF
	_cQuery += " 	AND A2_LOJA = C7_LOJA                                                                                               " + CRLF
	_cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT                                                                                   " + CRLF
	_cQuery += " 	ON CTT_FILIAL = '        '                                                                                          " + CRLF
	_cQuery += " 	AND CTT_CUSTO = C7_CC                                                                                               " + CRLF
	_cQuery += "     WHERE CR.D_E_L_E_T_ = ' '                                                                                          " + CRLF
	_cQuery += "     AND 	AK.D_E_L_E_T_ = ' '                                                                                         " + CRLF
	_cQuery += "     AND 	C7.D_E_L_E_T_ = ' '                                                                                         " + CRLF
	_cQuery += "     AND 	CTT.D_E_L_E_T_ = ' '                                                                                        " + CRLF
	_cQuery += "     AND 	A2.D_E_L_E_T_ = ' '                                                                                         " + CRLF
	_cQuery += "     AND 	CR_TIPO = 'PC'																								" + CRLF
	_cQuery += "     AND   	CR_FILIAL  BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'														" + CRLF
	_cQuery += "     AND   	C7_EMISSAO BETWEEN '"+Dtos(mv_par03)+"' AND '"+DtoS(mv_par04)+"'											" + CRLF
	_cQuery += "     AND   	C7_XDTVEN BETWEEN '"+Dtos(mv_par13)+"' AND '"+DtoS(mv_par14)+"'											" + CRLF
	_cQuery += "     AND   	C7_FORNECE BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'														" + CRLF
	_cQuery += "     AND   	C7_XTIPO   BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'														" + CRLF
	_cQuery += "     AND   	C7_PRODUTO BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'														" + CRLF
	_cQuery += "     AND   	C7_CC 	 BETWEEN '"+mv_par11+"' AND '"+mv_par12+"'															" + CRLF
	_cQuery += "     AND 	CR_STATUS IN ('02')																							" + CRLF  
	_cQuery += "     GROUP BY CR_FILIAL, TRIM(CR_NUM), C7.C7_XTIPO, C7.C7_FORNECE, A2_NOME, CR_APROV, AK_NOME, CR_USER, C7_CC,          " + CRLF
	_cQuery += "     CTT_DESC01, CR_TOTAL, C7_PRODUTO, C7_EMISSAO, C7_XDTVEN, CR_STATUS, CR_GRUPO, CR_DATALIB, CR_USERLIB, CR_LIBAPRO   " + CRLF
	_cQuery += "     ORDER BY 1, 8, 2, 15" + CRLF	
	 
   	DbUseArea(.F., "TOPCONN", TcGenQry(,, _cQuery), cAlias, .f., .f.) 
	Count To _nTotal
	ProcRegua(_nTotal)
	
	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		Return
	EndIf
	
	nHDestino := FCREATE(_cPath+_cArq)
	/*
	cXml := '<?xml version="1.0"?>																                             ' + CRLF
	cXml += '<?mso-application progid="Excel.Sheet"?>                                                                        ' + CRLF
	cXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"                                                  ' + CRLF
	cXml += ' xmlns:o="urn:schemas-microsoft-com:office:office"                                                              ' + CRLF
	cXml += ' xmlns:x="urn:schemas-microsoft-com:office:excel"                                                               ' + CRLF
	cXml += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"                                                        ' + CRLF
	cXml += ' xmlns:html="http://www.w3.org/TR/REC-html40">                                                                  ' + CRLF
	cXml += ' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">                                       ' + CRLF
	cXml += '  <AllowPNG/>                                                                                                   ' + CRLF
	cXml += ' </OfficeDocumentSettings>                                                                                      ' + CRLF
	cXml += ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">                                                 ' + CRLF
	cXml += '  <WindowHeight>12315</WindowHeight>                                                                            ' + CRLF
	cXml += '  <WindowWidth>28800</WindowWidth>                                                                              ' + CRLF
	cXml += '  <WindowTopX>32767</WindowTopX>                                                                                ' + CRLF
	cXml += '  <WindowTopY>32767</WindowTopY>                                                                                ' + CRLF
	cXml += '  <ProtectStructure>False</ProtectStructure>                                                                    ' + CRLF
	cXml += '  <ProtectWindows>False</ProtectWindows>                                                                        ' + CRLF
	cXml += ' </ExcelWorkbook>                                                                                               ' + CRLF
	cXml += ' <Styles>                                                                                                       ' + CRLF
	cXml += '  <Style ss:ID="Default" ss:Name="Normal">                                                                      ' + CRLF
	cXml += '   <Alignment ss:Vertical="Bottom"/>                                                                            ' + CRLF
	cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>                               ' + CRLF
	cXml += '  </Style>                                                                                                      ' + CRLF
	cXml += '  <Style ss:ID="s63">                                                                                           ' + CRLF
	cXml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>                                                     ' + CRLF
	cXml += '   <Borders>                                                                                                    ' + CRLF
	cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="3"                                        ' + CRLF
	cXml += '     ss:Color="#FFFFFF"/>                                                                                       ' + CRLF
	cXml += '   </Borders>                                                                                                   ' + CRLF
	cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#333399"                                 ' + CRLF
	cXml += '    ss:Bold="1"/>                                                                                               ' + CRLF
	cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>                                                            ' + CRLF
	cXml += '  </Style>                                                                                                      ' + CRLF
	cXml += '  <Style ss:ID="s65">                                                                                           ' + CRLF
	cXml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>                                                     ' + CRLF
	cXml += '   <Borders>                                                                                                    ' + CRLF
	cXml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"                                         ' + CRLF
	cXml += '     ss:Color="#4F81BD"/>                                                                                       ' + CRLF
	cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"                                           ' + CRLF
	cXml += '     ss:Color="#4F81BD"/>                                                                                       ' + CRLF
	cXml += '   </Borders>                                                                                                   ' + CRLF
	cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"                                 ' + CRLF
	cXml += '    ss:Bold="1"/>                                                                                               ' + CRLF
	cXml += '   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>                                                            ' + CRLF
	cXml += '  </Style>                                                                                                      ' + CRLF
	cXml += '  <Style ss:ID="s66">                                                                                           ' + CRLF
	cXml += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>                                                       ' + CRLF
	cXml += '   <Borders>                                                                                                    ' + CRLF
	cXml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"                                          ' + CRLF
	cXml += '     ss:Color="#B8CCE4"/>                                                                                       ' + CRLF
	cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"                                           ' + CRLF
	cXml += '     ss:Color="#B8CCE4"/>                                                                                       ' + CRLF
	cXml += '   </Borders>                                                                                                   ' + CRLF
	cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>                               ' + CRLF
	cXml += '   <Interior ss:Color="#B8CCE4" ss:Pattern="Solid"/>                                                            ' + CRLF
	cXml += '  </Style>                                                                                                      ' + CRLF
	cXml += '  <Style ss:ID="s67">                                                                                           ' + CRLF
	cXml += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>                                                       ' + CRLF
	cXml += '   <Borders>                                                                                                    ' + CRLF
	cXml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"                                          ' + CRLF
	cXml += '     ss:Color="#DCE6F1"/>                                                                                       ' + CRLF
	cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"                                           ' + CRLF
	cXml += '     ss:Color="#DCE6F1"/>                                                                                       ' + CRLF
	cXml += '   </Borders>                                                                                                   ' + CRLF
	cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>                               ' + CRLF
	cXml += '   <Interior ss:Color="#DCE6F1" ss:Pattern="Solid"/>                                                            ' + CRLF
	cXml += '  </Style>                                                                                                      ' + CRLF
	cXml += ' </Styles>                                                                                                      ' + CRLF
	cXml += ' <Worksheet ss:Name="1-Aprovacoes">                                                                             ' + CRLF
	cXml += '  <Table ss:ExpandedColumnCount="11" ss:ExpandedRowCount="125" x:FullColumns="1"                                ' + CRLF
	cXml += '   x:FullRows="1" ss:DefaultRowHeight="15">                                                                     ' + CRLF
	cXml += '   <Column ss:Width="52.5"/>                                                                                    ' + CRLF
	cXml += '   <Column ss:Width="99"/>                                                                                      ' + CRLF
	cXml += '   <Column ss:Width="138.75"/>                                                                                  ' + CRLF
	cXml += '   <Column ss:Width="66"/>                                                                                      ' + CRLF
	cXml += '   <Column ss:Width="389.25"/>                                                                                  ' + CRLF
	cXml += '   <Column ss:Width="257.25"/>                                                                                  ' + CRLF
	cXml += '   <Column ss:Width="118.5" ss:Span="1"/>                                                                       ' + CRLF
	cXml += '   <Column ss:Index="9" ss:Width="99"/>                                                                         ' + CRLF
	cXml += '   <Column ss:Width="191.25"/>                                                                                  ' + CRLF
	cXml += '   <Column ss:Width="231"/>                                                                                     ' + CRLF
	cXml += '   <Row ss:AutoFitHeight="0">                                                                                   ' + CRLF
	cXml += '    <Cell ss:MergeAcross="10" ss:StyleID="s63"><Data ss:Type="String">Aprovações pendentes</Data></Cell>        ' + CRLF
	cXml += '   </Row>                                                                                                       ' + CRLF
	cXml += '   <Row ss:AutoFitHeight="0">                                                                                   ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Filial</Data></Cell>                                          ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Filial</Data></Cell>                                    ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Solicitação Pagamento</Data></Cell>                           ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Fornecedor</Data></Cell>                                      ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Nome do fornecedor</Data></Cell>                              ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Nome do aprovador</Data></Cell>                               ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Data de vencimento</Data></Cell>                              ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Valor do documento</Data></Cell>                              ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Centro de Custo</Data></Cell>                                 ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">Desc. Centro de Custo</Data></Cell>                           ' + CRLF
	cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="String">E-mail Aprovador</Data></Cell>                                ' + CRLF
	cXml += '   </Row>' + CRLF
	*/
	cXml := "Filial;Desc. Filial;Solicitação Pagamento;Fornecedor;Nome do fornecedor;Nome do aprovador;Data de vencimento;Valor do documento;Centro de Custo;Desc. Centro de Custo;E-mail Aprovador;" + CRLF
	FWRITE(nHDestino, cXml)
	cXml := ""
	 DbSelectArea(cAlias)             
	(cAlias)->(DbGoTop())
	nContador := 0
	cFilBkp := cFilAnt 
	nX := 0
	nNum := 66
	While !(cAlias)->(Eof())
		cFilAnt := (cAlias)->FILIAL
		incProc("Gerando arquivo... registro: " + cValToChar(nX++) + "/"+cValToChar(_nTotal))
		cXml :=  "'" +(cAlias)->FILIAL+ ';';
				+"'" +FWFilialName()+ ';';
				+"'" +(cAlias)->SOL_PAG+ ';';
				+"'" +(cAlias)->FORNECE+ ';';
				+(cAlias)->NOME_FORNECE+ ';';
				+(cAlias)->APROV+ ';';
				+DTOC(STOD((cAlias)->DATA_VENCIMENTO))+ ';';
				+TRANSFORM((cAlias)->TOTAL, "@E 999,999,999,999.99")+ ';';
				+"'" +AllTrim((cAlias)->CENTRO_CUSTO)+ ';';
				+(cAlias)->DESC_CENTRO_CUSTO+ ';';
				+UsrRetMail((cAlias)->USUARIO_APROV) + CRLF
		
		/*
		cXml += '   <Row ss:AutoFitHeight="0">																				' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->FILIAL+'</Data></Cell>                        ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+FWFilialName()+'</Data></Cell>                          ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->SOL_PAG+'</Data></Cell>                       ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->FORNECE+'</Data></Cell>                       ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->NOME_FORNECE+'</Data></Cell>                  ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->APROV+'</Data></Cell>                         ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+DTOC(STOD((cAlias)->DATA_VENCIMENTO))+'</Data></Cell>               ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="Number">'+ cValToChar((cAlias)->TOTAL)+'</Data></Cell>            ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->CENTRO_CUSTO+'</Data></Cell>                  ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+(cAlias)->DESC_CENTRO_CUSTO+'</Data></Cell>             ' + CRLF
		cXml += '   <Cell ss:StyleID="s'+cValToChar(nNum)+'"><Data ss:Type="String">'+UsrRetMail((cAlias)->USUARIO_APROV)+'</Data></Cell>     ' + CRLF
		cXml += '   </Row>	' + CRLF
		*/
		FWRITE(nHDestino, cXml)
		If nNum == 66
			nNum := 67
		Else
			nNum := 66
		EndIf	
		(cAlias)->(DbSkip())
	EndDo
	cFilAnt := cFilBkp
	/*
	cXml := ""
	cXml += ' </Table>																	' + CRLF
	cXml += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">		' + CRLF
	cXml += '    <PageSetup>                                                            ' + CRLF
	cXml += '     <Header x:Margin="0.31496062000000002"/>                              ' + CRLF
	cXml += '     <Footer x:Margin="0.31496062000000002"/>                              ' + CRLF
	cXml += '     <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"      ' + CRLF
	cXml += '      x:Right="0.511811024" x:Top="0.78740157499999996"/>                  ' + CRLF
	cXml += '    </PageSetup>                                                           ' + CRLF
	cXml += '    <Unsynced/>                                                            ' + CRLF
	cXml += '    <Selected/>                                                            ' + CRLF
	cXml += '    <Panes>                                                                ' + CRLF
	cXml += '     <Pane>                                                                ' + CRLF
	cXml += '      <Number>3</Number>                                                   ' + CRLF
	cXml += '      <RangeSelection>R1C1:R1C11</RangeSelection>                          ' + CRLF
	cXml += '     </Pane>                                                               ' + CRLF
	cXml += '    </Panes>                                                               ' + CRLF
	cXml += '    <ProtectObjects>False</ProtectObjects>                                 ' + CRLF
	cXml += '    <ProtectScenarios>False</ProtectScenarios>                             ' + CRLF
	cXml += '   </WorksheetOptions>                                                     ' + CRLF
	cXml += '  </Worksheet>                                                             ' + CRLF
	cXml += ' </Workbook>                                                               ' + CRLF
	FWRITE(nHDestino, cXml)
	*/
	FCLOSE(nHDestino)

	oExcel := MsExcel():New()            
	oExcel:WorkBooks:Open(_cPath + _cArq)     
	oExcel:SetVisible(.T.)                 
	oExcel:Destroy()                        

	RestArea(aArea)	
Return


***********************************
Static Function FAJUSTSX1( _cPerg )
***********************************

	Local _aSx1 := {}, _cCampo

	AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"      	, 		"PERSPA"       	, 		"PERENG"     	, 		"VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID", "VAR01"   , 						 "F3", "DEF01"           , "DEF02", "DEF03"         , "DEF04"       , "DEF05"          , "HELP" } )
	AADD( _aSx1, { _cPerg , "01"  , "Filial de  ?"	, 		"¿Filial de?", 			"Filial de?", 			"mv_ch1" , "C"   , TamSx3("C7_FILIAL")[01]       , 	0        , 0       , "G"  , ""     , "mv_par01", "SM0", "Filial de?" , "", ""				, ""			, ""			   , "Filial de?"     } )
	AADD( _aSx1, { _cPerg , "02"  , "Filial Ate ?"	, 		"¿Filial Ate?", 		"Filial Ate?", 			"mv_ch2" , "C"   , TamSx3("C7_FILIAL")[01]       , 	0        , 0       , "G"  , ""     , "mv_par02", "SM0", "Filial Até?", "", ""              , ""            , ""               , "Filial Até?"     } )
	AADD( _aSx1, { _cPerg , "03"  , "Emissao De ?"	,		"¿Emissao De ? ", 		"Emissao De ?", 		"mv_ch3" , "D"   , 8, 								0        , 0       , "G"  , ""     , "mv_par03", "", 	"Emissão de?" , ""              , ""              , ""            , ""           , "Emissão de?"     } )
	AADD( _aSx1, { _cPerg , "04"  , "Emissao Ate ?", 		"¿Emissao Ate ? ", 		"Emissao Ate ?" , 		"mv_ch4" , "D"   , 8,		 						0        , 0       , "G"  , ""     , "mv_par04", "", 	"Emissão Até?" , ""              , ""              , ""            , ""               , "Emissão Até?"     } )
	AADD( _aSx1, { _cPerg , "05"  , "Fornecedor de ?",  	"¿Fornecedor de?", 		"Fornecedor de?", 		"mv_ch5" , "C"   , TamSx3("C7_FORNECE")[01]       , 0        , 0       , "G"  , ""     , "mv_par05", "SA2", "Fornecedor de?", "", ""				, ""			, ""			   , "Fornecedor de?"     } )
	AADD( _aSx1, { _cPerg , "06"  , "Fornecedor Ate?",  	"¿Fornecedor Ate?",		"Fornecedor Ate?",		"mv_ch6" , "C"   , TamSx3("C7_FORNECE")[01]       , 0        , 0       , "G"  , ""     , "mv_par06", "SA2", "Fornecedor Até?", "", ""              , ""            , ""               , "Fornecedor Até?"     } )
	AADD( _aSx1, { _cPerg , "07"  , "Tipo de ?", 			"¿Tipo de?", 			"Tipo de?", 			"mv_ch7" , "C"   , TamSx3("C7_XTIPO")[01]       , 	0        , 0       , "G"  , ""     , "mv_par07", "P02", "Tipo de?", "", ""				, ""			, ""			   , "Tipo de?"     } )
	AADD( _aSx1, { _cPerg , "08"  , "Tipo Ate?", 			"¿Tipo Ate?",			"Tipo Ate?",			"mv_ch8" , "C"   , TamSx3("C7_XTIPO")[01]       ,	0        , 0       , "G"  , ""     , "mv_par08", "P02", "Tipo Até?", "", ""              , ""            , ""               , "Tipo Até?"     } )
	AADD( _aSx1, { _cPerg , "09"  , "Produto de ?", 		"¿Produto de?", 		"Produto de?", 			"mv_ch9" , "C"   , TamSx3("B1_COD")[01]       , 	0        , 0       , "G"  , ""     , "mv_par09", "SB1", "Produto de?", "", ""				, ""			, ""			   , "Produto de?"     } )
	AADD( _aSx1, { _cPerg , "10"  , "Produto Ate?", 		"¿Produto Ate?",		"Produto Ate?",			"mv_cha" , "C"   , TamSx3("B1_COD")[01]       , 	0        , 0       , "G"  , ""     , "mv_par10", "SB1", "Produto Até", "", ""              , ""            , ""               , "Produto Até"     } )
	AADD( _aSx1, { _cPerg , "11"  , "Centro de Custo de ?", "¿Centro de Custo de?", "Centro de Custo de?", 	"mv_chb" , "C"   , TamSx3("C7_CC")[01]       , 		0        , 0       , "G"  , ""     , "mv_par11", "CTT", "Centro de custo de?", "", ""				, ""			, ""			   , "Centro de custo de?"     } )
	AADD( _aSx1, { _cPerg , "12"  , "Centro de Custo Ate?", "¿Centro de Custo Ate?","Centro de Custo Ate?",	"mv_chc" , "C"   , TamSx3("C7_CC")[01]       , 		0        , 0       , "G"  , ""     , "mv_par12", "CTT", "Centro de custo Até?" , "", ""              , ""            , ""               , "Centro de custo Até?"     } )
	AADD( _aSx1, { _cPerg , "13"  , "Vencimento De ?"	,	"¿Vencimento De ? ", 	"Vencimento De ?", 		"mv_chd" , "D"   , 8, 								0        , 0       , "G"  , ""     , "mv_par13", ""   , "Vencimento de?", "", ""              , ""            , ""               , "Vencimento de?"     } )
	AADD( _aSx1, { _cPerg , "14"  , "Vencimento Ate ?", 	"¿Vencimento Ate ? ", 	"Vencimento Ate ?" , 	"mv_che" , "D"   , 8, 								0        , 0       , "G"  , ""     , "mv_par14", ""	  , "Vencimento Até?", "", ""              , ""            , ""               , "Vencimento Até?"     } )
	

	DbSelectArea("SX1")
	SX1->(DbSetOrder(01))

	If !SX1->(DbSeek(_cPerg))
		For _X1 := 2 To Len(_aSX1)
			SX1->( RecLock("SX1", .T.))
			For _Z := 1 To Len(_aSX1[1])
				_cCampo := "X1_" + _aSX1[1, _Z]
				SX1->(FieldPut(FieldPos(_cCampo), _aSx1[_X1, _Z]))
			Next
			SX1->(MsunLock())
		Next
	EndIf
	
Return