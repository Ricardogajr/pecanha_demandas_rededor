#Include 'TOTVS.CH'
 
Static aTtPerid	:= {}
Static aTtPerAx	:= {}
Static aP08GL_T	:= {}
Static lBOracle	:= Trim(TcGetDb()) = 'ORACLE' 

/*{Protheus.doc} F0200501
Relatório de Amostra em Excel
@author		Cristiane Thomaz Polli
@since		11/07/2016
@version	12.1.7
@Menu		Compras\Relatorios\Rel. de Amostra
@Project	MAN00000463301_EF_005
*/  
User Function F0200501()

	Local 	cTabSD3		:= ''
	Local	aAreaAtu	:= {}
	Local	aArea		:= GetArea()
	Private cTitAmos	:= 'Relatório de Amostra'
	Private cPergAtu	:= 'FSW0200501'
	
	Do While Pergunte(cPergAtu,.T.)
						
		//Caso um código de produto seja informado, efetua a validação
		If !Empty(MV_PAR02)
					
			SB1->(dbSetOrder(1))
			if !SB1->(DbSeek(xFilial('SB1') + MV_PAR02))
					
				Help(" ", 1, "Help", "F0200501_01",'Informe um código de produto válido.(SB1)', 3, 0)
				Loop
						
			EndIf
								
		EndIf
			
		//Caso um código de Segmento/Categoria seja informado, efetua a validação
		If !Empty(MV_PAR03)
					
			ACU->(dbSetOrder(1))
			if !ACU->(DbSeek(xFilial('ACU') + MV_PAR03))
				Help(" ", 1, 'Help', 'F0200501_02','Informe um código de segmento/categoria válido.(ACU)', 3, 0)
				Loop						
			EndIf
								
		EndIf
			
		//Seleciona os registros
		cTabSD3		:= GetNextAlias()
		FWMsgRun(,{|| SelMovto(cTabSD3) },'Selecionando Registros','Aguarde...' )
			
		//Caso existam informações
		if !(cTabSD3)->(Eof())
					
			//Chama rotina para gerar o excell com as informações carregadas
			FWMsgRun(,{|| GerExcel(cTabSD3) },'Preenchendo o Arquivo em Excel','Aguarde...' )
					
		Else
									
			Aviso('Inexistentes','Para os parametros selecionados não existem informações.',{"OK"})
				
		EndIf
		
		(cTabSD3)->(dbCloseARea())
		RestArea(aArea)
				
	EndDo
			
Return

/*{Protheus.doc} SelMovto
 Busca informações conforme parametros selecionados.
@author		Cristiane Thomaz Polli
@since		12/07/2016
@version	12.1.7
@Param		cTabSD3, Alias para Query
@Project	MAN00000463301_EF_005
*/ 
Static Function SelMovto(cTabSD3)
	
	Local cQrySD3	:= ''
	Local lDebug 	:= .F.

	//Monta os periodos que serão considerados até a data base.	
	aTtPerid	:= {}
	MntPeri()

	//Monta a tabela GL x T conforme informações incluidas na P08
	MntGLT()
	
	cQrySD3	+= 	" SELECT	ACU.ACU_FILIAL	FILIAL		, " + CRLF
	cQrySD3	+= 	"			ACU.ACU_DESC	CATEGO		, " + CRLF
	cQrySD3	+= 	"			SB1.B1_COD		CODPRO		, " + CRLF
	cQrySD3	+= 	"			SB1.B1_DESC		DESPRO		, " + CRLF
	cQrySD3	+= 	"			P28.P28_DATREF	PERIOD		, " + CRLF
	cQrySD3	+= 	"			SUM (P28.P28_CONSUM)  RESULT " 		+ CRLF
	cQrySD3	+= 	" FROM " + RetSqlName('ACU') + " ACU " 	+ CRLF
	cQrySD3	+= 	"		INNER JOIN " + RetSqlName('ACV') + " ACV	ON	ACV.ACV_FILIAL	=	ACU.ACU_FILIAL "			+ CRLF
	cQrySD3	+= 	"												AND 	ACV.ACV_CATEGO	=	ACU.ACU_COD "				+ CRLF
	cQrySD3	+= 	"	 	INNER JOIN " + RetSqlName('SB1') + " SB1	ON	SB1.B1_FILIAL	=	'" + xFilial('SB1') + "'" 	+ CRLF
	cQrySD3	+= 	"	 	       									AND ((SB1.B1_COD = ACV.ACV_CODPRO AND ACV.ACV_GRUPO = '') OR (SB1.B1_GRUPO = ACV.ACV_GRUPO AND ACV.ACV_CODPRO = '')) " + CRLF
	cQrySD3	+= 	"	 	INNER JOIN " + RetSqlName('P28') + " P28	ON	P28.P28_FILIAL	=  '" + xFilial('ACV') + "'" 	+ CRLF
	cQrySD3	+= 	"	 											AND		P28.P28_CODPRD	=	ACV.ACV_CODPRO "			+ CRLF
	cQrySD3	+= 	" WHERE 	ACU.D_E_L_E_T_	=	'' "	+ CRLF		
	cQrySD3	+= 	" 		AND ACU.ACU_FILIAL	=  '" + xFilial('ACU') + "'" 	+ CRLF
	cQrySD3	+= 	" 		AND ACV.ACV_FILIAL	=  '" + xFilial('ACV') + "'" 	+ CRLF	
	cQrySD3	+= 	" 		AND	ACV.D_E_L_E_T_	=	'' "	+ CRLF
	cQrySD3	+= 	" 		AND	SB1.D_E_L_E_T_	=	'' "	+ CRLF
	cQrySD3	+= 	" 		AND	P28.D_E_L_E_T_	=	'' "	+ CRLF
//	cQrySD3	+= 	"		AND P28.P28_DATREF	<=	'" + SubsTr(DtoS(mv_par01),05,02) + SubsTr(DtoS(mv_par01),01,04) + "'"	+ CRLF		
	cQrySD3	+= 	"		AND SUBSTRING(P28.P28_DATREF,3,4)||SUBSTRING(P28.P28_DATREF,1,2)	<=	'" + SubsTr(DtoS(mv_par01),01,04) + SubsTr(DtoS(mv_par01),05,02)  + "'"	+ CRLF		
	//Filtra pela categoria/segmento se informado
	If !Empty(mv_par03)
		cQrySD3	+=	"     AND ACU.ACU_COD = '" + mv_par03 + "' " + CRLF
	EndIf
	//Filtra somente por produtos controlados pelo planejamento
	If mv_par04 == 1
		cQrySD3	+=	"     AND ACU.ACU_CTRLP = '1' " + CRLF
	EndIf
	//Filtra pelo codigo de produto se informado
	If !Empty(mv_par02)
		cQrySD3	+=	"	AND ACV.ACV_CODPRO = '" + mv_par02 + "'" + CRLF
	EndIf
	
	cQrySD3	+=	" GROUP BY ACU_FILIAL,  ACU_DESC,  B1_COD,  B1_DESC, P28_DATREF "  + CRLF
	cQrySD3	+=	"  		ORDER BY ACU.ACU_FILIAL, ACU.ACU_DESC, SB1.B1_COD , P28.P28_DATREF DESC   " + CRLF

	IF lDebug
		EEcView(cQrySD3)
	Endif
	
	cQrySD3 := ChangeQuery(cQrySD3)
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQrySD3), cTabSD3, .F., .T.)
		 		 
Return

/*{Protheus.doc} MntPeri
Monta os meses anteriores com base na data informada.
@author 	Cristiane Thomaz Polli
@since 		12/07/2016
@version 	12.1.7
@Project 	MAN00000463301_EF_005
*/ 
Static Function MntPeri()
 	
	Local nMeses	:= 24
	Local nM		:= 0
	Local dDatRef	:= MonthSub(MV_PAR01,1)
 		
	For nM := 1 to nMeses

		AAdd(aTtPerid,{StrTran(DtoC(MonthSub(dDatRef,nMeses-nM)),"/","") ,0,'PERIOD_' + Alltrim(Str(nM))})

	Next nM
 		
Return

/*{Protheus.doc} GerExcel
Popula as informações nas celulas e gera  o arquivo XML
@author 	Cristiane Thomaz Polli
@since 		14/07/2016
@version 	12.1.7
@Project 	MAN00000463301_EF_005
*/ 
Static Function GerExcel(cTabSD3)
 
	Local oExcSD3 	:= FWMsExcelEx():New()
	Local cAba1		:= 'Parametros'
	Local cTitulo1	:= 'Parametros Selecionados'
	Local cAba2		:= 'Informações'
	Local cTitulo2	:= 'Planilha de Amostra'
	Local cNmArqEx	:= ''
	Local cCamiAux	:= ''
	Local nItemAtu	:= 1
		
	//Aba - Parametros
	oExcSD3:AddworkSheet(cAba1)
	oExcSD3:AddTable (cAba1,cTitulo1)
	oExcSD3:AddColumn(cAba1,cTitulo1,'Parametro',1,1)
	oExcSD3:AddColumn(cAba1,cTitulo1,'Conteúdo Informado',2,1)
	oExcSD3:AddRow(cAba1,cTitulo1,{'Data Base',Dtoc(MV_PAR01)})
	oExcSD3:AddRow(cAba1,cTitulo1,{'Código do Produto',MV_PAR02})
	oExcSD3:AddRow(cAba1,cTitulo1,{'Segmento/Categoria',MV_PAR03})
	oExcSD3:AddRow(cAba1,cTitulo1,{'Somente categorias controladas pela Equipe de Planejamento',IIF(MV_PAR04==1, '1=Sim','2=Não')})
	oExcSD3:AddRow(cAba1,cTitulo1,{'Data da Geração',Dtoc(dDatabase)})
	oExcSD3:AddRow(cAba1,cTitulo1,{'Hora da Geração',time()})
		    
	//Aba - Informações
	oExcSD3:AddworkSheet(cAba2)
	oExcSD3:AddTable (cAba2,cTitulo2)
	oExcSD3:AddColumn(cAba2,cTitulo2,'Estabelecimento',1,1)       // 01 
	oExcSD3:AddColumn(cAba2,cTitulo2,'Código do Produto',2,1)     // 02
	oExcSD3:AddColumn(cAba2,cTitulo2,'Descrição do Produto',2,1)  // 03
	oExcSD3:AddColumn(cAba2,cTitulo2,'Segmento/Categoria',2,1)    // 04
//	oExcSD3:AddColumn(cAba2,cTitulo2,'1',2,2)                     // 05 


	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(24),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(23),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(22),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(21),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(20),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(19),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(18),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(17),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(16),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(15),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(14),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(13),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(12),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(11),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(10),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(09),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(08),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(07),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(06),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(05),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(04),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(03),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(02),2,2)
	oExcSD3:AddColumn(cAba2,cTitulo2,TextMes(01),2,2)

/*

	oExcSD3:AddColumn(cAba2,cTitulo2,'1',2,2)                     // 05
	oExcSD3:AddColumn(cAba2,cTitulo2,'2',2,2)                     // 06
	oExcSD3:AddColumn(cAba2,cTitulo2,'3',2,2)                     // 07
	oExcSD3:AddColumn(cAba2,cTitulo2,'4',2,2)                     // 08
	oExcSD3:AddColumn(cAba2,cTitulo2,'5',2,2)                     // 09
	oExcSD3:AddColumn(cAba2,cTitulo2,'6',2,2)                     // 10
	oExcSD3:AddColumn(cAba2,cTitulo2,'7',2,2)                     // 11
	oExcSD3:AddColumn(cAba2,cTitulo2,'8',2,2)                     // 12
	oExcSD3:AddColumn(cAba2,cTitulo2,'9',2,2)                     // 13
	oExcSD3:AddColumn(cAba2,cTitulo2,'10',2,2)                    // 14
	oExcSD3:AddColumn(cAba2,cTitulo2,'11',2,2)                    // 15
	oExcSD3:AddColumn(cAba2,cTitulo2,'12',2,2)                    // 16
	oExcSD3:AddColumn(cAba2,cTitulo2,'13',2,2)                    // 17
	oExcSD3:AddColumn(cAba2,cTitulo2,'14',2,2)                    // 18
	oExcSD3:AddColumn(cAba2,cTitulo2,'15',2,2)                    // 19
	oExcSD3:AddColumn(cAba2,cTitulo2,'16',2,2)                    // 20
	oExcSD3:AddColumn(cAba2,cTitulo2,'17',2,2)                    // 21
	oExcSD3:AddColumn(cAba2,cTitulo2,'18',2,2)                    // 22
	oExcSD3:AddColumn(cAba2,cTitulo2,'19',2,2)                    // 23
	oExcSD3:AddColumn(cAba2,cTitulo2,'20',2,2)                    // 24
	oExcSD3:AddColumn(cAba2,cTitulo2,'21',2,2)                    // 25
	oExcSD3:AddColumn(cAba2,cTitulo2,'22',2,2)                    // 26
	oExcSD3:AddColumn(cAba2,cTitulo2,'23',2,2)                    // 27
	oExcSD3:AddColumn(cAba2,cTitulo2,'24',2,2)                    // 28
*/

	Do While !(cTabSD3)->(Eof())

		oExcSD3:AddRow(cAba2,cTitulo2,MntInfPd(RetNmSM0((cTabSD3)->FILIAL),cTabSD3,nItemAtu))
		nItemAtu	:= nItemAtu + 1
			
	EndDo
				
	oExcSD3:Activate()
				
	cNmArqEx	:=	'F0200501_' + dtos(dDatabase) + '_' + StrTran(time(),':','_') + ".xls"
	oExcSD3:GetXMLFile(cNmArqEx)
		
	//Permite que o colaborador selecione uma pasta para copiar o arquivo.	
	if MsgYesNo('Deseja selecionar em qual diretório será copiado o arquivo gerado?')
			
		cCamiAux	:= cGetFile( '*.txt' , 'Selecione a Pasta', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.F., .T. )

	EndIf
		
	//Caso não seja selecionado  uma pasta busca das configurações do usuário
	if Empty(Alltrim(cCamiAux))
		
		cCamiAux	:= PswRet()[2][3]
			
	EndIf
		
	//Caso o usuário não possua configuração de diretorio para impresssão.
	if Empty(Alltrim(cCamiAux))
		
		cCamiAux	:=  'C:\TOTVS\'
		
	EndIf
		
	//Verifica se o diretório existe e se não existe força a criação
	if !ExistDir(cCamiAux)
		
		MakeDir(cCamiAux)
		
	EndIf
		
	//Copia do servidor para o caminho informado		
	If __Copyfile('\system\' + cNmArqEx,cCamiAux + cNmArqEx)
		
		Aviso('Sucesso - Geração do arquivo','O arquivo foi gerado com sucesso no caminho: ' + cCamiAux + cNmArqEx,{"OK"})
		
	Else
			
		Aviso('Não Gerado','Arquivo não foi copiado para o caminho informado.' + cCamiAux + 'Contate o departamento de TI.',{'OK'})
						
	EndIf

Return

/*{Protheus.doc} MntInfPd
Monta os calculos e quantidades referente a cada linha de produto
@author Cristiane Thomaz Polli
@since 		14/07/2016
@version 	12.1.7
@Param		cNmFilial, Filial da registro (SD3)
@Param		cTabSD3, Alias da Query
@Param		nItemAtu, número do item
@Return		aInfProd, Vetor (	1.Cod.Filial(SD3)  ou filial atual,
								2.Cod.Produto,
								3.Descrição do Produto,
								4.Categoria,
								5 ao 28.Quantidades entre os periodos 1 a 24 (24 celulas),
								29.CM = Quantidade médio exceto dos meses zerados,
								30.CM90= Quantidade médio dos últimos 3 meses,
								31.CM180=Quantidade média dos últimos 6 meses,
								32.Média= Quantidade média entre  as médias (CM + CM90 + CM180)/3,
								33.Desvio padrão,
								34.Percentual do  Desvio padrão com  relação a Quantidade Média(CM),
								35.GL= valor chumbado na tabela  P08 correspondente ao numero do item a ser impresso,
								36.T=  valor chumbado na tabela  P08 relacionada ao  GL impresso,
								37.Erro = parametro (FS_AMOS1*Desvio Padrão)/Raiz quadrada FS_AMOS2,
								38.Minimo = Média -  Erro,
								39.Máximo = Média + Erro,
								40.Nº períodos= número de períodos que tiveram movimentação diferente de zero(0).
							)								 
@Project 	MAN00000463301_EF_005
*/ 
/*{Protheus.doc} MntGLT
Monta array com as informações contidas na tabela P08 
@author 	Cristiane Thomaz Polli
@since 		13/07/2016
@version 	12.1.7
@Project 	MAN00000463301_EF_005
*/ 
Static Function MntGLT()
 	
	Local cQryP08	:= ''
	Local cTabP08	:= GetNextAlias()
	Local aArea	:= GetArea()
	Local nPosP08	:= 1
 	
	If lBOracle 
		cQryP08	:= "	SELECT TO_NUMBER(P08_GL) GL , P08.P08_T T " + CRLF
	Else
		cQryP08	:= "	SELECT CONVERT(INT,P08.P08_GL) GL, P08.P08_T T " + CRLF
	EndIf
	
	cQryP08	+= "	FROM " + RetSqlName('P08') + " P08 " + CRLF
	cQryP08	+= "	WHERE P08.P08_FILIAL = '" + xFilial('P08') + "' " + CRLF
	If P08->(FieldPos("P08_MSBLQL")) > 0
		cQryP08	+= "	 AND P08.P08_MSBLQL <> '1' " + CRLF
	EndIf
	cQryP08	+= "	 AND P08.D_E_L_E_T_ = ' ' " + CRLF
	cQryP08	+= "	 ORDER BY GL " + CRLF
 	
 	cQryP08 := ChangeQuery(cQryP08)
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQryP08), cTabP08, .F., .T.)

	If !(cTabP08)->(Eof())
 	
		While !(cTabP08)->(Eof())
 	
			AAdd(aP08GL_T,{ nPosP08, (cTabP08)->GL, (cTabP08)->T })
			(cTabP08)->(dbSkip())
			nPosP08	:= nPosP08 + 1
 		
		EndDo
 		
	EndIf
 	
	(cTabP08)->(dbCloseArea())
	RestArea(aArea)
 	
Return
/*{Protheus.doc} RetNmSM0
Retorna o nome da filial
@author Cristiane Thomaz Polli
@since 13/07/2016
@version 12.1.7
@return cNameAtu, Nome da filial do registro da SD3.
@Project MAN00000463301_EF_005
*/ 
Static Function RetNmSM0(cFilSD3)

	Local aAreaSM0	:= SM0->(GetArea())
	Local cNameAtu	:= ''
	
	dbSelectArea('SM0')
	if SM0->(DbSeek(cEmpAnt + cFilSD3))
		
		cNameAtu	:= Alltrim(SM0->M0_FILIAL)
		
	EndIf
		
	RestArea(aAreaSM0)
	
Return cNameAtu

Static Function TextMes(nMes)
Local cText := ""

cText := Substr(MesExtenso(MonthSub(MV_PAR01,nMes)),1,3)+"/"+ALLTRIM(STR(YEAR(MonthSub(MV_PAR01,nMes))))

Return(cText)


Static Function MntInfPd(cNmFilial,cTabSD3,nItemAtu)
  	
	Local nFSAmos1:= SuperGetMv("FS_AMOS1")
	Local nFSAmos2:= SuperGetMv("FS_AMOS2")
	Local aInfProd	:= array(28)

		 	 
	cCodSD3		:= (cTabSD3)->CODPRO
	 	
	aInfProd[1]	:=	cNmFilial
	aInfProd[2]	:=	cCodSD3
	aInfProd[3]	:=	(cTabSD3)->DESPRO
	aInfProd[4]	:=	(cTabSD3)->CATEGO
						
	While cCodSD3 == (cTabSD3)->CODPRO
			
		if (nPeriAtu	:= AScan(aTtPerid, {|x,y|  substring(x[1],3,6) == (cTabSD3)->PERIOD})) > 0

			aInfProd[nPeriAtu + 4] := (cTabSD3)->RESULT
										
		EndIf
								
		(cTabSD3)->(dbSkip())
								
	EndDo
			
	
Return aInfProd









