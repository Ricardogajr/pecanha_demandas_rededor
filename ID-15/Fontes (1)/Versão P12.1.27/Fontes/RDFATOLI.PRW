#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

//#Include "FINA404.CH" 

/*/{Protheus.doc} FINA404
Funcao de integracao com o adapter EAI para envio de informaÃ§Ãµes dos fornecedores autonomos.
@author	William Matos
@since		17/06/2015
/*/
User Function RDFATOLI
//Local oProcesso	:= Nil
//Local oGrid		:= Nil
//Private cPerg     := "RDFATOLI"     

// EnvioXML(oGrid,lEnd)
 EnvioXML()
//FAJUSTSX1(cPerg)
/*
oGrid := FWGridProcess():New(	"RDFATOLI",; //Nome da funÃ§Ã£o
								"Nota Fiscal de Olinda",; //"IntegraÃ§ao de Fornecedores Autonomos
								"Exportação de Xml para importação na prefeitura para Notas Fiscais de Olinda.",; //DescriÃ§Ã£o da rotina
								{|lEnd| lRet := EnvioXML(oGrid,@lEnd)},; //Bloco de execuÃ§Ã£o
								"RDFATOLI",;// Pergunte
								Nil,; //cGrid
								.T.) //lSaveLog

oGrid:SetMeters(1)
oGrid:Activate()
*/ 
Return

/*/{Protheus.doc} FN404EnvioXML
Envio do XML com os dados dos fornecedores autonomos.
@author	William Matos
@since		17/06/2015
/*/
//Static Function EnvioXML(oGrid,lEnd) 
 Static Function EnvioXML()
 Local cQuery	 := ""
// Local lIntFN404 := FWHasEAI("RDFATOLI",.T.,.F.,.T.)
 Local aLog		 := {}
 Local nX		 := 0
 //Local cSepAba	:= If("|"$MVABATIM,"|",",")
 //Local cSepAnt	:= If("|"$MVPAGANT,"|",",")
 //Local cSepNeg	:= If("|"$MV_CRNEG,"|",",")
 //Local cSepProv	:= If("|"$MVPROVIS,"|",",")
 //Local cSepRec	:= If("|"$MVRECANT,"|",",")
 Local nRegSM0	 	:= SM0->(Recno())
 Local aSM0		 	:= FWLoadSM0()
 Local nFil		 	:= 0
 Local lErro	 	:= .F.
// Local lRunSched := FWGetRunSchedule()
 Local cFilOli := GETNEWPAR("MV_XFILOLI","01310012|04660001|01690001|01690004",cFilAnt)
 Local cMunExc   	:= GETNEWPAR("MV_XMUNEXC","09600|09600",cFilAnt)
 Private Eol    	:= chr(13)+chr(10)
 Private cTipBL := GETNEWPAR("MV_XTIPOBL","C",cFilAnt)
 Private cLeiBL := GETNEWPAR("MV_XLEIBL","123",cFilAnt)
 Private cAnoBL := GETNEWPAR("MV_XANOBL","2006",cFilAnt)
 Private _cPerg  	:= 'RDFATOLI'
 Private cDiretorio := ""
 Private cArquivo   := ""
 Private _lArqXml   := ""  
 Private _lArqLog   := "" 
 Private cArqXml    := ""
 Private cExtArq    := ".xml" 
 Private cExtLog    := ".log"
 Private cAliasXml  := GetNextAlias()     
 Private _nContar   := 0
 Private _nQtdErro  := 0

//If lIntFN404 //IntegraÃ§Ã£o configurada no EAI

  //	If !lRunSched //Nao carrega se for schedule pois as definicoes sao obtidas de la (botao parametros)
  //		Pergunte("RDFATOLI", .F. )
		//MV_PAR01 - Data Inicial
		//MV_PAR02 - Data Final
		//MV_PAR03 - Fornecedor Inicial
		//MV_PAR04 - Loja Inicial
		//MV_PAR05 - Fornecedor Final
		//MV_PAR06 - Loja Final
//	EndIf   

 //FAJUSTSX1(_cPerg) Thais Paiva - CompatibilizaÃ§Ã£o P27

 If ! Pergunte(_cPerg, .T. )
 	Return
 EndIf
 
 If cFilAnt $ cFilOli
 	lFilOli := .T.
 Else 
 	MsgInfo("Filial Não autorizada a executar essa rotina!", "Filial Incorreta")
 	Return
 EndIf
 
 cArquivo 	:= MV_PAR05
 cDiretorio := SelArq()
 
 cArqXml := Alltrim(cDiretorio+cArquivo)
 cArqLog := Alltrim(cDiretorio+"Log_"+cArquivo)

// Parei aqui!!!

// oGrid:SetMaxMeter(Len(aSM0), 1, "Processando as Filiais") //"Processando as filiais"

//	For nFil := 1 To Len( aSM0 )

// oGrid:SetIncMeter(1)

//		If aSM0[nFil][1] == cEmpAnt

//			cFilAnt := aSM0[nFil][2]

//			cAliasXmlXML 	:= GetNextAlias()

			//Monta query.
			
 cQuery := " SELECT  " + Eol  
 cQuery += "    SUBSTR(F1_EMISSAO,1, 6) AS COMPETENCIA, " + Eol 
 cQuery += "    (select to_char(sysdate, 'DDMMYYYY') from dual) AS DATAG, " + Eol 
 cQuery += "     (select to_char(sysdate, 'HH24MISS') from dual) AS HORAG, " + Eol 
 cQuery += "     A2_COD,  " + Eol 
 cQuery += "     A2_NOME, " + Eol 
 cQuery += "     A2_CGC, " + Eol 
 cQuery += "     A2_COD_MUN, " + Eol
 cQuery += "     A2_INSCRM,  " + Eol
 cQuery += "     CASE A2_TIPO  " + Eol 
 cQuery += "         WHEN 'X' THEN A2_PFISICA " + Eol 
 cQuery += "         ELSE '0000000' " + Eol 
 cQuery += "     END AS A2_PFISICA, " + Eol 
 cQuery += "     '0000000' A2_RG,  " + Eol 
 cQuery += "     substr( A2_CEP, 1 , 5 ) || '-' || substr(A2_CEP, 6 , length(A2_CEP) ) AS A2_CEP, " + Eol 
 cQuery += "     substr(LTRIM(A2_END),1,105) A2_END,  " + Eol 
 cQuery += "     CASE A2_NR_END " + Eol 
 cQuery += "         WHEN ' ' THEN 'S/N' " + Eol 
 cQuery += "         ELSE A2_NR_END " + Eol 
 cQuery += "     END A2_NR_END,  " + Eol 
 cQuery += "     substr(A2_ENDCOMP,1,45) AS A2_ENDCOMP,  " + Eol 
 cQuery += "     substr(A2_BAIRRO,1,45) AS A2_BAIRRO, " + Eol 
 cQuery += "     substr(A2_MUN,1,45) AS A2_MUN,  " + Eol 
 cQuery += "     A2_EST, " + Eol 
 cQuery += "     CASE A2_PAIS  " + Eol 
 cQuery += "         WHEN '105' THEN ' ' " + Eol 
 cQuery += "         ELSE A2_PAIS " + Eol 
 cQuery += "     END AS A2_PAIS,     " + Eol 
 cQuery += "     substr(A2_EMAIL,1,60) AS A2_EMAIL,  " + Eol 
 cQuery += "     A2_DDD,  " + Eol 
 cQuery += " REPLACE(REPLACE(A2_TEL,'-',''),' ','') A2_TEL, " + Eol
 cQuery += "     A2_DDD,  " + Eol 
 cQuery += " REPLACE(A2_FAX,'-','') A2_FAX, " + Eol
 cQuery += "     A2_NREDUZ,  " + Eol 
 cQuery += "     A2_INSCR,  " + Eol 
 cQuery += "     CASE A2_TIPO " + Eol 
 cQuery += "         WHEN 'F' THEN '23' " + Eol 
 cQuery += "         WHEN 'J' THEN '21' " + Eol 
 cQuery += "         WHEN 'X' THEN '14' " + Eol 
 cQuery += "     ELSE '0' " + Eol 
 cQuery += "     END AS A2_TIPO, " + Eol 
 cQuery += "     CASE A2_SIMPNAC " + Eol 
 cQuery += "         WHEN '1' THEN 'SN' " + Eol 
 cQuery += "         ELSE 'NO' " + Eol 
 cQuery += "     END AS A2_SIMPNAC, " + Eol 
 cQuery += "     F3_CODRET,  " + Eol 
 cQuery += "     CASE F3_ESPECIE " + Eol 
 cQuery += "         WHEN 'NFS' THEN 'E' " + Eol 
 cQuery += "         WHEN 'NF'  THEN 'N' " + Eol 
 cQuery += "     ELSE 'O' " + Eol 
 cQuery += "     END AS F3_ESPECIE, " + Eol 
 cQuery += "     F3_SERIE, 	" + Eol 
 cQuery += "     F3_NFISCAL,  " + Eol 
 cQuery += " SUBSTR(F3_EMISSAO,7, 2)||SUBSTR(F3_EMISSAO,5, 2)||SUBSTR(F3_EMISSAO,1, 4) F3_EMISSAO, " + Eol
 cQuery += " REPLACE(F3_CODISS,'.','@') F3_CODISS, " + Eol
 cQuery += "     F3_VALCONT,  " + Eol 
 cQuery += "     CASE " + Eol 
 cQuery += "         WHEN (F3_BASEICM > 0 AND F3_ALIQICM > 0) THEN 'S' " + Eol 
 cQuery += "         ELSE 'N' " + Eol 
 cQuery += "     END F3_RECISS, " + Eol 
 cQuery += "     F3_BASEICM,  " + Eol 
 cQuery += "     F3_ALIQICM, " + Eol 
 cQuery += "     F3_VALICM,  " + Eol 
 cQuery += "     '00000' BASE_LEGAL,  " + Eol 
 cQuery += "     SUBSTR(A2_IBGE,1,2) A2_IBGEI, " + Eol 
 cQuery += "     SUBSTR(A2_IBGE,3,5) A2_IBGEF  " + Eol 
 
 cQuery += "     FROM " + RetSQLName("SF1")+ " F1 " + Eol 
// cQuery += "    -- INNER JOIN " + RetSQLName("SD1") +" D1 ON D1_DOC = F1_DOC  " + Eol 
// cQuery += "    --     AND D1_SERIE = D1_SERIE " + Eol 
// cQuery += "    --     AND D1_FILIAL = F1_FILIAL " + Eol 
// cQuery += "    --     AND D1_FORNECE = F1_FORNECE " + Eol 
// cQuery += "    --     AND D1_LOJA = F1_LOJA " + Eol 
// cQuery += "    --     AND D1.D_E_L_E_T_ = F1.D_E_L_E_T_  " + Eol 
 cQuery += "     INNER JOIN " + RetSQLName("SF3")+ " F3 ON F3_NFISCAL = F1_DOC " + Eol 
 cQuery += "         AND F3_SERIE      = F1_SERIE " + Eol 
 cQuery += "         AND F3_CLIEFOR    = F1_FORNECE " + Eol 
 cQuery += "         AND F3_LOJA       =  F1_LOJA " + Eol 
 cQuery += "         AND F3_EMISSAO    = F1_EMISSAO  " + Eol 
 cQuery += "         AND F3.D_E_L_E_T_ = F1.D_E_L_E_T_ " + Eol 
 cQuery += "     INNER JOIN " + RetSQLName("SA2")+ " A2 ON A2_COD = F1_FORNECE " + Eol 
 cQuery += "         AND A2_LOJA = F1_LOJA  " + Eol
 cQuery += "         AND A2_COD_MUN NOT IN "+FormatIn(cMunExc,'|')+ Eol  
// cQuery += "     WHERE F1_FILIAL IN "+FormatIn(cFilOli,'|')+ Eol 
 cQuery += "      WHERE F1_FILIAL = '"+cFilAnt+"'"+Eol
// cQuery += "     	 AND F1_FORNECE NOT IN '"+FormatIn(cMunExc,'|')+"'" + Eol 
 cQuery += "         AND F1_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"'" + Eol 
 cQuery += "         AND F1_DOC 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + Eol 
// cQuery += "         AND F1_SERIE = '"+MV_PAR01+"'" + Eol 
 cQuery += "         AND F1.D_E_L_E_T_ = ' ' " + Eol 
 cQuery += "         ORDER BY A2_COD,F3_NFISCAL, F1_EMISSAO" + Eol 

 cQuery := ChangeQuery(cQuery)

 DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasXml,.T.,.T.)
 DbSelectArea(cAliasXml)

	//Processa o XML
 If Select(cAliasXml) > 0
 //	GeraXml( (cAliasXml), aLog,@lErro,oGrid)
	 Processa({|| GeraXml()}, "Gerando Arquivo XML ... Filial : "+cFilAnt)
 Else
	Aadd(aLog,"Não Existem dados para serem processados, Filial :" + AllTrim(cFilAnt) + "." )//"NÃ£o existem dados para serem processados."###"Filial: "
 EndIf	

 (cAliasXml)->(DBCloseArea())
 FErase((cAliasXml) + GetDbExtension())
 cAliasXml := ""

 SM0->(DBGoTo(nRegSM0))
 cFilAnt := Iif ( FindFunction("FWCODFIL"), FWCodFil(), SM0->M0_CODFIL)

	//Salva log de processamento do XML.

Return 

/*/{Protheus.doc} FN404EnvioXML
FunÃ§Ã£o que preenche o xml para envio.
@author	William Matos
@since 17/06/2015
@param cAliasXml - Entidade temporaria com os dados que serÃ£o enviados pela mensagem unica
/*/
Static Function GeraXml()
 Local cEvent 		:= "UPSERT"
 Local cXMLRet		:= ""
 Local cXMLCab		:= ""
 Local cInternalID	:= ""
 Local cCEITomador	:= {}
 Local cCGCTomador	:= ""
 Local cTpTomador	:= ""
 Local cNatService	:= "1" //Urbano
 Local cLog			:= ""
 Local aResult		:= {}
 Local nX			:= 0
 Local cMensErro		:= ""
 Local cChvAux		:= ""
 Local nTotDoc := 0
 Local nTotPre := 0
 Local nTotReg := 0
 Local nTotBsL := 0

//Pesquisa dados na SM0
 dbSelectArea("SM0")
 If SM0->(dbSeek(cEmpAnt+cFilAnt))
	cCEITomador	:= SM0->M0_CEI
	cCGCTomador	:= SM0->M0_CGC
	cTpTomador	:= '0' //Default como serviÃ§o para o segmento.   
//	cHeInsc     := SM0->M0_CODMUN
    cHeinsc     := SM0->M0_INSCM
 EndIf

  
 If File(Alltrim(cArqXml)+Alltrim(cExtArq)) 
   	If MsgYesNo("Arquivo já existe na pasta", "Deseja Sobrescrever o arquivo?")
      	If FErase(Alltrim(cArqXml)+Alltrim(cExtArq)) == -1
      		MsgInfo("Não foi possivel deletar o arquivo", "Aviso")
      		Return
      	EndIf
   	Else
   		Return
   	EndIf
 ElseIf FILE(cArqLog + cExtLog)
    FErase(Alltrim(cArqLog) + Alltrim(cExtLog))
 EndIf
 
 _lArqXml := FCreate( cArqXml + cExtArq, 0 )
 _lArqLog := FCreate( cArqLog + cExtLog, 0 )

 If _lArqXml == - 1 .Or. ! File( cArqXml + cExtArq )
//		If ! MsgYesNo( "Arquivo [" + _cScript + ".CSV] não pode ser criado corretamente, deseja proceguir sem gerar excel?" )
//	fClose( _lArqCsv )
	cArqXml := ""
	MsgInfo("Não foi possivel criar o arquivo XML!", "Aviso")
	Return
 EndIf
//<?xml version='1.0' encoding='ISO-8859-1' ?>
//<declaracao>
 cXMLCab := '<?xml version="1.0" encoding="ISO-8859-1"?>'           
 cXMLCab += '<declaracao>'   //inicio da declaração
//não aceita caracteres especiais, tais como: & ! ^ ' "
//Por exemplo, caso o nome de um Tomador/Prestador seja A & B, a tag com seu nome ficaria
//<tpNome>
//<![CDATA[A & B]]>
//</tpNome>       
/*
<header>
<heInsc></heInsc>
<heComp></heComp>
<heGeDt></heGeDt>
<heGeHo></heGeHo>
<heVers></heVers>
<hePref></hePref>
</header>
*/

//************
//***Header XML***
//************
 cXMLCab += "<header>"
 cXMLCab += "<heInsc>"+Alltrim(cHeInsc)+		"</heInsc>"
 cXMLCab += "<heComp>"+(cAliasXml)->COMPETENCIA+"</heComp>" 
 cXMLCab += "<heGeDt>"+(cAliasXml)->DATAG+		"</heGeDt>" 
 cXMLCab += "<heGeHo>"+(cAliasXml)->HORAG+		"</heGeHo>"  
 cXMLCab += "<heVers>"+'2000'+					"</heVers>"
 cXMLCab += "<hePref>"+'OLIN'+					"</hePref>"
 cXMLCab += "</header>"
 
 fWrite( _lArqXml, cXMLCab, _lArqXml )
 
//*************************************************************************** 
//Exemplo de arquivo XML para o Tipo de Registro 'Tomador/Prestador' - tompre
//***************************************************************************
 (cAliasXml)->( DbGoTop() )

 //_nContar := Contar( "CALIASXML", "!EOF()" )
 
  Count To _nContar
 //oObj:SetRegua1(nTotal)

 ProcRegua( _nContar )

 (cAliasXml)->(dbGotop())
 While (cAliasXml)->( !Eof() ) //.AND. nX <= 50   
 	Nx++
 	cMensErro := ""
	//Caso um dos campos necessarios nao estejam preenchidos, nao envia os dados e gera log
	//*****************************************************
	// Log erro Dados do Fornecedor (Tomador)
	//*****************************************************
 	IncProc("Periodo : "+dtoc(MV_PAR03)+" à "+dtoc(MV_PAR04)+Eol+"Fornecedor : "+(cAliasXml)->A2_COD+ " Nota Fiscal: "+(cAliasXml)->F3_NFISCAL) //"Contabilizando Lançamentos"

	Do Case
		Case Empty((cAliasXml)->A2_COD)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Código do Fornecedor não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_NOME)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Nome do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_CGC)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : CNPJ do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_COD_MUN)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Codigo do Municipio do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_CEP)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : CEP do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_END)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Endereço do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_BAIRRO)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Bairro do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_MUN)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Municipio do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_EST)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Estado do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		    
		//*****************************************************
		// Log erro Dados da Nota Fiscal (Itens)
		//*****************************************************
	    
//		Case Empty((cAliasXml)->F3_CODRET)
//			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Código do Documento Recebido do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
//			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_ESPECIE)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Tipo de documento do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_NFISCAL)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Numero da Nota do Fornecedor :"+(cAliasXml)->A2_COD+" não informado."+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_EMISSAO)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Emissao da nota do Fornecedor :"+(cAliasXml)->A2_COD+" não informado."+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_CODISS)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Serviço tomado do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_VALCONT) .And. (cAliasXml)->F3_RECISS == 'S'
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Documento retido sem Valor do serviço do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_BASEICM) .And. (cAliasXml)->F3_RECISS == 'S'
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Documento retido sem Base de calculo imposto do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->F3_VALICM) .And. (cAliasXml)->F3_RECISS == 'S'
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Documento retido sem Valor do ISS do Fornecedor :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
		Case Empty((cAliasXml)->A2_IBGEI) .And. Empty((cAliasXml)->A2_IBGEF)
			cMensErro := "Linha :"+STRZERO((Nx),6)+ " Nota(Campo Obrigatorio) : Local de Prestação (Código do Estado) :"+(cAliasXml)->A2_COD+" não informado, Nota Fiscal :"+(cAliasXml)->F3_NFISCAL+Eol
			GravLog(cMensErro)
	EndCase

	//	cChvAux := (cAliasXml)->A2_FILIAL + (cAliasXml)->A2_COD + (cAliasXml)->A2_LOJA

	//	cMensErro := STR0005 + AllTrim((cAliasXml)->A2_COD) + STR0006 + AllTrim((cAliasXml)->A2_LOJA) + If(!Empty((cAliasXml)->A2_FILIAL)," (" + STR0007 + AllTrim(cFilAnt) + ")","" ) + STR0008 //"O Fornecedor: "###" Loja: "###"Filial: "###", estÃ¡ com seu cadastro incompleto para envio dos dados."

   //	cMensErro += STR0009 //" Confira os campos: "
    /*
	cMensErro += AllTrim(RetTitle("A2_NOME"))		+ ", "
	cMensErro += AllTrim(RetTitle("A2_CGC"))		+ ", "
	cMensErro += AllTrim(RetTitle("A2_CBO"))		+ ", "
	cMensErro += AllTrim(RetTitle("A2_DTNASC"))		+ ", "
	cMensErro += AllTrim(RetTitle("A2_CODNIT"))		+ ", "
	cMensErro += AllTrim(RetTitle("A2_CATEG"))		+ STR0010 //" e "
	cMensErro += AllTrim(RetTitle("A2_OCORREN"))	+ "."
    */

    If !Empty(cMensErro)       
    	_nQtdErro ++
	//	Aadd(aLog,cMensErro)
		lErro := .T.
		(cAliasXml)->(DBSkip())
		Loop
	EndIf

		//Faz laÃ§o para pular todos os titulos do fornecedor com dados incompletos
//		While (cAliasXml)->(!Eof()) .And. cChvAux == (cAliasXml)->A2_FILIAL + (cAliasXml)->A2_COD + (cAliasXml)->A2_LOJA  
//		(cAliasXml)->(DBSkip())
//		EndDo

		//Se nao acabou os dados, volto 1, pois o loop avancara para o proximo
//		If (cAliasXml)->(!Eof())
//			(cAliasXml)->(DBSkip(-1))
//		EndIf

//		Loop

//	EndIf
/*
	If (cAliasXml)->A2_INDRUR == '0' //NÃ£o Ã© Produtor rural.
		cNatService := '1' //Urbano 
	Else
		cNatService := '2' //Rural
	EndIf

	cInternalID :=	cEmpAnt							+ "|" + ;
					RTrim(XFilial("SE2"))			+ "|" + ;
					RTrim((cAliasXml)->E2_PREFIXO)	+ "|" + ;
					RTrim((cAliasXml)->E2_NUM)		+ "|" + ;
					RTrim((cAliasXml)->E2_PARCELA)	+ "|" + ;
					RTrim((cAliasXml)->E2_TIPO)		+ "|" + ;
					RTrim((cAliasXml)->E2_FORNECE)	+ "|" + ;
					RTrim((cAliasXml)->E2_LOJA)

*/  
	cXMLRet := "<tompre>"
	cXMLRet += "<tpCod>" +(cAliasXml)->A2_COD+"</tpCod>"
	cXMLRet += "<tpNome><![CDATA["+Alltrim((cAliasXml)->A2_NOME)+"]]></tpNome>"
	cXMLRet += "<tpDocu>"+(cAliasXml)->A2_CGC+"</tpDocu>"
	
	cXMLRet += "<tpInMu></tpInMu>"
	
	cXMLRet += "<tpPass></tpPass>"
	//cXMLCab += "<tpRgNu>"+(cAliasXml)->A2_RG+"</tpRgNu>"
	//cXMLCab += "<tpRgOr>"+(cAliasXml)->A2_COD+"</tpRgOr>"
	//cXMLCab += "<tpRgEs>"+(cAliasXml)->A2_COD+"</tpRgEs>"
	cXMLRet += "<tpCep>" +(cAliasXml)->A2_CEP+					"</tpCep>"
	cXMLRet += "<tpLogr>"+Alltrim((cAliasXml)->A2_END)+			"</tpLogr>"
	cXMLRet += "<tpNume>"+Alltrim((cAliasXml)->A2_NR_END)+		"</tpNume>"
	cXMLRet += "<tpComp>"+Alltrim((cAliasXml)->A2_ENDCOMP)+		"</tpComp>"
	cXMLRet += "<tpBair>"+Alltrim((cAliasXml)->A2_BAIRRO)+		"</tpBair>"
	cXMLRet += "<tpMuni>"+Alltrim((cAliasXml)->A2_MUN)+					"</tpMuni>"
	cXMLRet += "<tpEsta>"+Alltrim((cAliasXml)->A2_EST)+					"</tpEsta>"
	cXMLRet += "<tpPais>"+Alltrim((cAliasXml)->A2_PAIS)+"</tpPais>"
	cXMLRet += "<tpMail>"+Alltrim((cAliasXml)->A2_EMAIL)+		"</tpMail>"
	//cXMLCab += "<tpTReD>"+(cAliasXml)->A2_COD+"</tpTReD>"
	//cXMLCab += "<tpTReN>"+(cAliasXml)->A2_COD+"</tpTReN>"
	//cXMLCab += "<tpTCeD>"+(cAliasXml)->A2_COD+"</tpTCeD>"
	//cXMLCab += "<tpTCeN>"+(cAliasXml)->A2_COD+"</tpTCeN>"
	cXMLRet += "<tpTCoD>"+Alltrim((cAliasXml)->A2_DDD)+				"</tpTCoD>"
	cXMLRet += "<tpTCoN>"+Alltrim((cAliasXml)->A2_TEL)+				"</tpTCoN>"
	cXMLRet += "<tpTFaD>"+Alltrim((cAliasXml)->A2_DDD)+				"</tpTFaD>"
	cXMLRet += "<tpTFaN>"+Alltrim((cAliasXml)->A2_FAX)+				"</tpTFaN>"
    cXMLRet += "<tpNFan><![CDATA["+Alltrim((cAliasXml)->A2_NREDUZ)+"]]></tpNFan>"
	cXMLRet += "<tpInEs>"+Alltrim((cAliasXml)->A2_INSCR)+			"</tpInEs>"
	cXMLRet += "<tpNaJu>"+(cAliasXml)->A2_TIPO+				"</tpNaJu>"
	cXMLRet += "<tpSiTr>"+(cAliasXml)->A2_SIMPNAC+			"</tpSiTr>"
	cXMLRet += "</tompre>"
    nTotPre++
    
	fWrite( _lArqXml, cXMLRet, _lArqXml )
	
	cCodFor := (cAliasXml)->A2_COD








	While (cAliasXml)->( !Eof() ) .And. (cAliasXml)->A2_COD == cCodFor
	//*****************************************************
	//Layout para o Tipo de Registro 'Documentos Recebidos'
	//*****************************************************
	//Exemplo de arquivo XML para o Tipo de Registro 'Documentos Recebidos' - docrec
        If (cAliasXml)->A2_SIMPNAC == "SN"
	            nTotBsL ++
	            cXMLRet :="<basleg>"
	            cXMLRet +="<blCod>"+cValToChar(nTotBsL)+"</blCod>"
	            cXMLRet +="<blTip>"+Alltrim(cTipBL)+"</blTip>"
	            cXMLRet +="<blNum>"+Alltrim(cLeiBL)+"</blNum>"
				
	            cXMLRet +="<blAno>"+Alltrim(cAnoBL)+"</blAno>"
	            cXMLRet +="</basleg>"

	            fWrite( _lArqXml, cXMLRet, _lArqXml )
        EndIf
		
		cXMLRet :="<docrec>"
//		cXMLRet +="<drCod>" +Alltrim((cAliasXml)->F3_CODRET)+	 "</drCod>"
		cXMLRet +="<drCod>" +cValToChar(Nx)+					 "</drCod>"
		cXMLRet +="<drPres>"+Alltrim((cAliasXml)->A2_COD)+		 "</drPres>"
		cXMLRet +="<drTpDo>"+Alltrim((cAliasXml)->F3_ESPECIE)+	 "</drTpDo>"
		cXMLRet +="<drSeri>"+Alltrim((cAliasXml)->F3_SERIE)+				 "</drSeri>"
		//cXMLRet +="<drSub>" +(cAliasXml)->A2_COD+		"</drSub>"
		cXMLRet +="<drNume>"+Alltrim((cAliasXml)->F3_NFISCAL)+			 "</drNume>"
		cXMLRet +="<drData>"+(cAliasXml)->F3_EMISSAO+			 "</drData>"
		cXMLRet +="<drCSer>"+Alltrim((cAliasXml)->F3_CODISS)+	 "</drCSer>"
		cXMLRet +="<drVSer>"+cValToChar((cAliasXml)->F3_VALCONT)+"</drVSer>"
		cXMLRet +="<drReti>"+(cAliasXml)->F3_RECISS+			 "</drReti>"
		cXMLRet +="<drBasC>"+cValtoChar((cAliasXml)->F3_BASEICM)+"</drBasC>"
		cXMLRet +="<drAliq>"+cValtoChar((cAliasXml)->F3_ALIQICM)+"</drAliq>"
		cXMLRet +="<drVIss>"+cValToChar((cAliasXml)->F3_VALICM)+ "</drVIss>"
        If (cAliasXml)->A2_SIMPNAC == "SN"
            cXMLRet +="<drBaLe>"+cValToChar(nTotBsL)+"</drBaLe>"
        EndIf
		cXMLRet +="<drLoEs>"+(cAliasXml)->A2_IBGEI+				 "</drLoEs>"
		cXMLRet +="<drLoMu>"+(cAliasXml)->A2_IBGEF+				 "</drLoMu>"
		cXMLRet +="</docrec>"

	Nx++
    nTotDoc++

	fWrite( _lArqXml, cXMLRet, _lArqXml )
	(cAliasXml)->(DBSkip())
//	cCodFor := (cAliasXml)->A2_COD 

	Enddo

	
		//Envia os dados.
//	aResult := FwIntegDef( 'RDFATOLI', EAI_MESSAGE_BUSINESS , TRANS_SEND , cXMLRet ) 
	
//	If !aResult[1]
//		Aadd(aLog,cValToChar(aResult[2]))
//		lErro := .T.
//	Else
	cXMLRet := ""
//	nX 		 := 0
//	EndIf

 EndDo

 nTotReg := nTotPre+nTotDoc+nTotBsL+2

 cXMLRet := "<trailler>"
 cXMLRet += "<qtRegA>"+cValtoChar(nTotReg)+"</qtRegA>"
 cXMLRet += "<qtToPr>"+cValtoChar(nTotPre)+"</qtToPr>"
 cXMLRet += "<qtBaLe>"+cValtoChar(nTotBsL)+"</qtBaLe>"
 cXMLRet += "<qtPlCo>0</qtPlCo>"
 cXMLRet += "<qtTurm>0</qtTurm>"
 cXMLRet += "<qtDoEm>0</qtDoEm>"
 cXMLRet += "<qtNoAv>0</qtNoAv>"
 cXMLRet += "<qtDoRe>"+cValtoChar(nTotDoc)+"</qtDoRe>"
 cXMLRet += "<qtDedu>0</qtDedu>"
 cXMLRet += "<qtSeAu>0</qtSeAu>"
 cXMLRet += "<qtInFi>0</qtInFi>"
 cXMLRet += "<qtTuDe>0</qtTuDe>"
 cXMLRet += "<qtDesM>0</qtDesM>"
 cXMLRet += "</trailler>"
 
 fWrite( _lArqXml, cXMLRet, _lArqXml )
 cXmlRet := cXMLCab + cXmlRet   
 
 
 cXMLRet := "</declaracao>"
 
 fWrite( _lArqXml, cXMLRet, _lArqXml )
 
 cMensErro := Eol+Eol+"Quantidade Total de Registros : "+cValToChar(Nx)+Eol+"Quantidade Total de Erros : "+cValtoChar(_nQtdErro)
 GravLog(cMensErro)
	
  
 fClose( _lArqXml )
 fClose( _lArqLog )
 
 If File(Alltrim(cArqXml)+Alltrim(cExtArq))  
 	MsgInfo("Xml Gerado no Caminho:"+Eol+Eol+cArqXml+".xml"+Eol+Eol+"Log Gerado no Caminho:"+Eol+Eol+cArqLog+".log","Arquivo Gerado com sucesso!")
 	If MsgYesNo("Arquivo de Log", "Gostaria de Visualizar o Log?")
 		If Substr(cArqLog,1,2) == "C:" .or. Substr(cArqLog,1,2) == "c:"
 			Shellexecute( "Open", cArqLog+".log", " /k dir ","c:\" , 1 )	
 		EndIf
 	EndIf
   
 EndIf

 aSize(aResult,0)
 aResult := Nil

Return

/*/{Protheus.doc}IntegDef
Mensagem unica de integraÃ§Ã£o com RM, envio de dados dos fornecedores autonomos.
@param cXml	  Xml passado para a rotina
@param nType 	  Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMessage Tipo de mensagem ( EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS)
@author William Matos
@since  19/06/15
/*/
Static Function IntegDef( cXml, nType, cTypeMessage )
Local aRet := {}

aRet := FINI404( cXml, nType, cTypeMessage )

Return aRet

/*/{Protheus.doc} SchedDef
Utilizado somente se a rotina for executada via Schedule.
Permite usar o botao Parametros da nova rotina de Schedule
para definir os parametros(SX1) que serao passados a rotina agendada.
@author  TOTVS
@version 12.1.11
@since   04/03/2016
@return  aParam
/*/
Static Function SchedDef()
Local aParam := {}

aParam := {	"P"			,;	//Tipo R para relatorio P para processo
				"FINA404"	,;	//Nome do grupo de perguntas (SX1)
				Nil			,;	//cAliasXml (para Relatorio)
				Nil			,;	//aArray (para Relatorio)
				Nil			}	//Titulo (para Relatorio)

Return aParam    

/*InÃ­cio Thais Paiva CompatibilizaÃ§Ã£o P27
//Cria e Ajusta perguntas da rotina 
//***********************\************
Static Function FAJUSTSX1( _cPerg )
//***********************************

	Local _aSx1 := {}, _cCampo , cGrupo , cOrdem, cHelp

	AADD( _aSx1, { "GRUPO","ORDEM","PERGUNT"         	, "PERSPA"         , "PERENG"     		, "VARIAVL", "TIPO", "TAMANHO", "DECIMAL", "PRESEL", "GSC", "VALID"							, "VAR01"   , "F3", "DEF01"          , "DEF02"         	, "DEF03"         	, "DEF04"       , "DEF05"          	, "HELP" } )
//	AADD( _aSx1, { _cPerg , "01"  , "Serie NF ?"     	, "¿Serie NF ?"    , "Serie NF ?" 		, "mv_ch1" 	 	, "C"   , 03       , 0        , 0       , "C"  , ""     					, "mv_par01", ""  	,""				, ""				, ""				, ""			, ""				, "Serie Nota Fiscal"     } )
	AADD( _aSx1, { _cPerg , "01"  , "Nota De  ?"		, "¿Filial ? "     , "Filial ?"   		, "mv_ch1" 	 	, "C"   , 09       , 0        , 0       , "G"  , ""     					, "mv_par01", ""	,""             , ""              	, ""              	, ""            , ""              	, "Numero da Nota Fiscal iniciando em"     } )
	AADD( _aSx1, { _cPerg , "02"  , "Nota Ate ?"		, "¿Filial ? "     , "Filial ?"   		, "mv_ch2" 	 	, "C"   , 09       , 0        , 0       , "G"  , ""     					, "mv_par02", ""	,""             , ""              	, ""              	, ""            , ""              	, "Numero da Nota Fiscal terminando em"    } )
	AADD( _aSx1, { _cPerg , "03"  , "Emissao De ?"		, "¿Emissao De ? " , "Emissao De ?"		, "mv_ch3" 		, "D"   , 08       , 0        , 0       , "G"  , ""     					, "mv_par03", ""  	,""             , ""              	, ""              	, ""            , ""               	, "Emissão da Nota Fiscal de" } )
	AADD( _aSx1, { _cPerg , "04"  , "Emissao Ate?"		, "¿Emissao Ate? " , "Emissao Ate?"		, "mv_ch4" 	 	, "D"   , 08       , 0        , 0       , "G"  , ""     					, "mv_par04", ""  	,""             , ""              	, ""              	, ""            , ""               	, "Emissão da Nota Fiscal Até"} )
	AADD( _aSx1, { _cPerg , "05"  , "Nome Arquivo ?"	, "¿Nome Arquivo?" , "Nome Arquivo?"	, "mv_ch5" 		, "C"   , 50       , 0        , 0       , "G"  , ""     					, "mv_par05", ""  	,""             , ""              	, ""              	, ""            , ""               	, "Nome do arquivo Xml que será gravado em extensão"} )
//	AADD( _aSx1, { _cPerg , "07"  , "Caminho Arquivo ?"	, "¿Emissao Ate? " , "Emissao Ate?"		, "mv_ch7" 	 	, "C"   , 80       , 0        , 0       , "G"  , 'SelArq()'					, "mv_par07", ""	,""             , ""              	, ""              	, ""            , ""               	, ""     } )
   	DbSelectArea( "SX1" )
	SX1->( DbSetOrder( 1 ) )
    
    //Se tiver Help da Pergunta
	If SX1->( ! DbSeek( _cPerg + _aSx1[Len( _aSx1 ), 2] ) )
		SX1->( DbSeek( _cPerg ) )
		While SX1->( ! Eof() ) .And. Alltrim( SX1->X1_GRUPO ) == Alltrim( _cPerg )
			SX1->( Reclock( "SX1", .F., .F. ) )
			SX1->( DbDelete() )
			SX1->( MsunLock() )
			SX1->( DbSkip() )
		End
		For _X1 := 2 To Len( _aSX1 )
			SX1->( RecLock( "SX1", .T. ) )
			For _Z := 1 To Len( _aSX1[1] )
				_cCampo := "X1_" + _aSX1[1, _Z]
				
				If _cCampo == "X1_HELP" 
					X1_HELP    := ""
//		  		    cGrupo     := SX1->X1_GRUPO											  		 //Adiciona espaços a direita para utilização no DbSeek
					cHelp := SX1->( FieldPut( FieldPos( _cCampo ), _aSx1[_X1, _Z] ) )
    				cChaveHelp := "P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + "."  //Define o nome da pergunta
    				SX1->( FieldPut( FieldPos( _cCampo ), cChaveHelp ) )
		           fPutHelp(cChaveHelp, cHelp,.T.)
		  		Else
					SX1->( FieldPut( FieldPos( _cCampo ), _aSx1[_X1, _Z] ) )
				EndIf
			Next
			SX1->( MsunLock() )
		Next
	EndIf

Return
Fim - Thais Paiva - CompatibilizaÃ§Ã£o P27*/                          

// ------------------------------------------------------------------
//  [ Pesquisa o Arquivo na pasta ]
// ------------------------------------------------------------------
static function SelArq()
// -------------------------------
    private _cExtens := 'Arquivo Xml ( *.xml ) |*.XML|'
// -------------------------------
    _cRet := cGetFile( _cExtens , 'Selecione a Pasta para salvar o arquivo' , , , .F. , GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
    _cRet := alltrim( _cRet )

return( _cRet )
// ------------------------------------------------------------------

/*---------------------------------------------------*
 | Função: GravLog                                  |
 | Desc:   Função que insere o Log				    |
 *---------------------------------------------------*/
       
Static Function GravLog(cMensLog)
	fWrite( _lArqLog, cMensLog, _lArqLog )
Return 

/*---------------------------------------------------*
 | Função: fPutHelp                                  |
 | Desc:   Função que insere o Help do Parametro     |
 *---------------------------------------------------*/
 
Static Function fPutHelp(cKey, cHelp, lUpdate)
    Local cFilePor  := "SIGAHLP.HLP"
    Local cFileEng  := "SIGAHLE.HLE"
    Local cFileSpa  := "SIGAHLS.HLS"
    Local nRet      := 0
    Default cKey    := ""
    Default cHelp   := ""
    Default lUpdate := .F.
     
    //Se a Chave ou o Help estiverem em branco
    If Empty(cKey) .Or. Empty(cHelp)
        Return
    EndIf
     
    //**************************** Português
    nRet := SPF_SEEK(cFilePor, cKey, 1)
         
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFilePor, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** Inglês
    nRet := SPF_SEEK(cFileEng, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFileEng, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** Espanhol
    nRet := SPF_SEEK(cFileSpa, cKey, 1)
     
    //Se não encontrar, será inclusão
    If nRet < 0
        SPF_INSERT(cFileSpa, cKey, , , cHelp)
     
    //Senão, será atualização
    Else
        If lUpdate
            SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
        EndIf
    EndIf
Return
	