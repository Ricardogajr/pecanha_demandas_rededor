#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"
#include "tbiconn.ch"

#DEFINE ENTER CHR(13)+CHR(10) 

/*/{Protheus.doc} RDGPER01
    (long_description)
    @type  Function
    @since 19/09/2020
    @Thiago Pereira
/*/
User Function  RDGPER02    
Local aArea   	:= GetArea()
Local cTitulo   := 'Relatório Compara SRD x RHS'
Private cPerg   := ""
Private cFils  := "" 
Private cVerbas := "" 
Private cMats  := "" 
Private pFilial
Private pVerba
Private pDtDe
Private pDtAte
Private pMatDe
Private pMatAte
Private lGO

DBSELECTAREA("SRD")
DBSELECTAREA("RHS")



	if !AtuPergunta(cPerg)
		RestArea(aArea)
		Return
	Endif

	Processa({|| fGeraRel(cTitulo)} , "Gerando dados...")

Return

Static Function AtuPergunta(cPerg)
Local aRet := {}
Local aParamBox := {}
Local i := 0

	AADD(aParamBox,{1,"Filial"          	,SPACE(80)        ,"","","","",150,.T.})  
    AADD(aParamBox,{1,"Verba"           	,SPACE(50)        ,"","","","",50,.T.})  
	aAdd(aParamBox,{1,"Dt Pagamento De:  " 	,(ddataBase),""	,""	,""	 ,"",50	,.T.}) // Tipo data
	aAdd(aParamBox,{1,"Dt Pagamento Até: " 	,(ddataBase),""	,""				,""	 ,"",50	,.T.}) // Tipo data
	aAdd(aParamBox,{1,"Matricula De: "			,Space(6)		,""	,""	,""	 ,"",50	,.T.}) // Tipo caractere    
	aAdd(aParamBox,{1,"Matricula Até: "			,Space(6)		,""	,""	,""	 ,"",50	,.T.}) // Tipo caractere 
	
    If ParamBox(aParamBox,"Filtros Atualizacao Valores",@aRet) 
    	//IF VALTYPE(aRet[7]) == 'N'
    	//	pTipo	:= SUBSTR(ASTATUS[ARET[7]],1,1)
    	//ELSE
	   // 	pTipo	:= (SUBSTR(aRet[7],1,1))
	    //ENDIF   
	    pFilial         := aRet[1]
    	pVerba			:= aRet[2]   
    	//pDtDe			:= aRet[3]  
    	//pDtAte          := aRet[4]
		pDtDe          := MonthSub(aRet[3],1)
	    pDtAte			:= MonthSub(aRet[3],1)
	    pMatDe			:= aRet[5]
	    pMatAte         := aRet[6]  
		lGO := .t.     
		    
	ELSE
		lGO := .F.// APERTOU O BOTAO DE CANCELAR.     
	Endif
    //Private cEol        := chr(13)+chr(10)
   	//Private cAlias 		:= GetNextAlias() 
    //Private cAliasEst 	:= GetNextAlias()   
    //Private cDriver		:= __LocalDriver
 	//Private cExtens		:= '.DTC'
 	//Private cIndArqA	:= Subs(cNomInd,1,7)+"A"
 	//Private cIndArqB	:= Subs(cNomInd,1,7)+"B"
 	//Private aStruct		:=  {}
/*
	aAdd(aParamBox,{1,"Filiais"				,Space(50)		,""	,""	,""		,""	,100	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1,"Dt Pagamento De:  " 	,Ctod(Space(8))	,""	,""	,""		,""	,50	,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Dt Pagamento Até: " 	,Ctod(Space(8))	,""	,""	,""		,""	,50	,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Verba: "				,Space(50)		,""	,""	,""		,""	,100	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1,"Matricula: "			,Space(50)		,""	,""	,""		,""	,100	,.F.}) // Tipo caractere
	
	If ParamBox(aParamBox ,"Parametros ",@aRet)      
   		MV_PAR01 := aRet[1]  //"Filiais"
   		MV_PAR02 := aRet[2]  //Dt Pagamento De:
   		MV_PAR03 := aRet[3]  //"Dt Pagamento Até: "	
   		MV_PAR04 := aRet[4]  //"Verba: "	
   		MV_PAR05 := aRet[5]  //"Matricula: "			
	else
		return .f.
	endif*/

Return lGO

/*/{Protheus.doc} GeraRel
    (long_description)
    @type  Function
    @since 19/09/2020
    @Thiago Pereira
/*/
Static Function fGeraRel(cTitulo)

Local aArea   	:= GetArea()
Local cAliasT 	:= GetNextAlias()
Local nPosIni	:=	1
Local i := 0
Local _cPath := "C:\DIVER_SRD_RHS\" 
Local _cArq := "C:\DIVER_SRD_RHS\DIVER_SRD_RHS_"+DtoS(DATE())+".CSV"
Local _lArqCsv 
Local _cLin  
Local _cScript := "C:\DIVER_SRD_RHS\DIVER_SRD_RHS"
Local _cEscrev
Local cxQry := "" 
Local _nContar := 0 
Local _lGerouExc := .F.           
Local _aCamposAlias := {}

		    aAdd(_aCamposAlias, { "FILIAL", TamSX3("RD_FILIAL")[3], TamSX3("RD_FILIAL")[1], TamSX3("RD_FILIAL")[2]}) 
	        aAdd(_aCamposAlias, { "DT_COM PETENCIA", TamSX3("RHS_COMPPG")[3], TamSX3("RHS_COMPPG")[1], TamSX3("RHS_COMPPG")[2]})
            aAdd(_aCamposAlias, { "RD_MAT", TamSX3("RD_MAT")[3],  TamSX3("RD_MAT")[1], TamSX3("RD_MAT")[2]}) 
           	aAdd(_aCamposAlias, { "RD_PD", TamSX3("RD_PD")[3], TamSX3("RD_PD")[1], TamSX3("RD_PD")[2]})
  			aAdd(_aCamposAlias, { "RD_DATARQ",TamSX3("RD_DATARQ")[3],  TamSX3("RD_DATARQ")[1], TamSX3("RD_DATARQ")[2]})
  			aAdd(_aCamposAlias, { "RHS_COMPPG", TamSX3("RHS_COMPPG")[3], TamSX3("RHS_COMPPG")[1], TamSX3("RHS_COMPPG")[2]})
  			aAdd(_aCamposAlias, { "E2_FORNECE", TamSX3("E2_FORNECE")[3], TamSX3("E2_FORNECE")[1], TamSX3("E2_FORNECE")[2]})
  			aAdd(_aCamposAlias, { "E2_NOMFOR", TamSX3("E2_NOMFOR")[3], TamSX3("E2_NOMFOR")[1], TamSX3("E2_NOMFOR")[2]})
  			aAdd(_aCamposAlias, { "RHS_VLRFUN" ,  TamSX3("RHS_VLRFUN")[3], TamSX3("RHS_VLRFUN")[1], TamSX3("RHS_VLRFUN")[2]})
            aAdd(_aCamposAlias, { "RD_VALOR" ,   TamSX3("RD_VALOR")[3], TamSX3("RD_VALOR")[1], TamSX3("RD_VALOR")[2]})


	IncProc("Buscando registros na base de dados...")
	
	For	i:=	1	To	Len(AllTrim(MV_PAR01))                  //17,22,23

		If	SubStr(MV_PAR01,i,1) ==	","

			If	Empty(cFils)
				cFils	:=	"'"+AllTrim(SubStr(MV_PAR01,nPosIni,i-1))+"'"
			Else
				cFils	+=	",'"+AllTrim(SubStr(MV_PAR01,nPosIni,i-nPosIni))+"'"
			Endif

		   nPosIni :=	i+1

		ElseIf	i	==	Len(AllTrim(MV_PAR01))

			If	Empty(cFils)
				cFils	:=	"'"+AllTrim(SubStr(MV_PAR01,nPosIni,i))+"'"
			Else
				cFils	+=	",'"+AllTrim(SubStr(MV_PAR01,nPosIni,i))+"'"
			Endif

		EndIf

	Next

 	For	i:=	1	To	Len(AllTrim(pVerba))                  //17,22,23
	
		If	SubStr(pVerba,i,1) ==	","

			If	Empty(cVerbas)
				cVerbas	:=	"'"+AllTrim(SubStr(pVerba,nPosIni,i-1))+"'"
			Else
				cVerbas	+=	",'"+AllTrim(SubStr(pVerba,nPosIni,i-nPosIni))+"'"
			Endif

		   nPosIni :=	i+1

		ElseIf	i	==	Len(AllTrim(pVerba))

			If	Empty(cVerbas)
				cVerbas	:=	"'"+AllTrim(SubStr(pVerba,nPosIni,i))+"'"
			Else
				cVerbas	+=	",'"+AllTrim(SubStr(pVerba,nPosIni,i))+"'"
			Endif

		EndIf

	Next

cxQry := "SELECT * FROM (									" +ENTER	
cxQry += "SELECT 											" +ENTER										 	 
cxQry += " RD_FILIAL FILIAL,								" +ENTER								
cxQry += " RD_MAT MATRICULA,								" +ENTER								
cxQry += " RA_NOME NOME,									" +ENTER								
cxQry += " RD_DATARQ COMPETENCIA,							" +ENTER								
cxQry += " RD_PD VERBA,										" +ENTER
cxQry += " NVL(SUM(RD_VALOR),0.00)  AS VALOR_FICHA,			" +ENTER								
cxQry += " NVL(RHS_VLRFUN,0.00) VALOR_PLANO,				" +ENTER				
cxQry += " (NVL(SUM(RD_VALOR),0.00) - NVL(RHS_VLRFUN,0.00)) DIFERENCA	" +ENTER						
cxQry += "FROM " + RetSqlName("SRD")+ " SRD									" +ENTER
cxQry += "  LEFT JOIN " + RetSqlName("SRA")+ " SRA ON (RD_MAT = RA_MAT AND RD_FILIAL = RA_FILIAL AND SRA.D_E_L_E_T_ <> '*') " +ENTER
cxQry += " 	FULL OUTER JOIN (SELECT RHS_FILIAL,					" +ENTER
cxQry += " 	                RHS_MAT, 						 	" +ENTER
cxQry += " 	                RHS_PD, 						 	" +ENTER
cxQry += " 	                RHS_COMPPG, 					 	" +ENTER
cxQry += " 	                SUM( RHS_VLRFUN ) AS RHS_VLRFUN  	" +ENTER
cxQry += "  			 FROM " + RetSqlName("RHS")+ " RHS	 					" +ENTER
cxQry += "           WHERE RHS.D_E_L_E_T_    <> '*' 			" +ENTER
	If !Empty(cFils)
		cxQry += "AND RHS_FILIAL IN ("+cFils+") " + ENTER  
	EndIf  
cxQry += " 				AND TRIM(RHS_MAT) >= '"+pMatDe+"' 	    " +ENTER  
cxQry += " 				AND TRIM(RHS_MAT) <= '"+pMatAte+"' 	    " +ENTER  
	If !Empty(cVerbas)
		cxQry += "	AND trim(RHS_PD) IN ("+cVerbas+")   	" 	+ ENTER  
	EndIf 
cxQry += "              AND RHS_COMPPG BETWEEN '" + AnoMes(pDtDe) + "' " +ENTER
cxQry += "                  AND '" 		     + AnoMes(pDtAte) + "'" +ENTER
cxQry += "          			GROUP BY RHS_FILIAL,                            " +ENTER
cxQry += "                   		RHS_MAT,                                    " +ENTER
cxQry += "                   		RHS_PD,                                     " +ENTER
cxQry += "                   		RHS_COMPPG                                  " +ENTER
cxQry += "          			ORDER BY RHS_COMPPG ) RHS                       " +ENTER
cxQry += "  	ON (RD_MAT = RHS_MAT AND RD_FILIAL = RHS_FILIAL AND RD_PD = RHS_PD AND RD_DATARQ = RHS_COMPPG ) " +ENTER
cxQry += "		WHERE SRD.D_E_L_E_T_ <> '*'							  				" +ENTER
cxQry += "		AND RD_VALOR  > 0											" +ENTER
	If !Empty(cFils)
		cxQry += "AND RD_FILIAL IN ("+cFils+") " + ENTER  
	EndIf  
cxQry += " 		AND TRIM(RD_MAT) >= '"+pMatDe+"'    						" +ENTER  
cxQry += " 		AND TRIM(RD_MAT) <= '"+pMatAte+"' 	    					" +ENTER  
	If !Empty(cVerbas)
		cxQry += "		AND trim(RD_PD) IN ("+cVerbas+") " + ENTER  
	EndIf	
cxQry += "      AND RD_DATARQ BETWEEN '" + AnoMes(pDtDe) + "' 				" +ENTER
cxQry += "               AND '" 		  + AnoMes(pDtAte) + "'				" +ENTER
cxQry += "         	GROUP BY RD_FILIAL,                         " +ENTER
cxQry += "          RD_MAT,                                     " +ENTER 
cxQry += "			RA_NOME,									" +ENTER	
cxQry += "			RD_DATARQ,									" +ENTER	
cxQry += "			RD_PD,										" +ENTER
cxQry += "			RHS_VLRFUN   								" +ENTER

cxQry += "ORDER BY RD_FILIAL, RD_MAT, RD_PD 				  "	+ENTER
cxQry += " ) WHERE VALOR_FICHA <> VALOR_PLANO		" +ENTER
	
cxQry := ChangeQuery( cxQry )

   	//MPSysOpenQuery(cxQry, cAliasT,_aCamposAlias) 
MPSysOpenQuery(cxQry, cAliasT)    

//	   MPSysOpenQuery(cxQry, calias)
	dbSelectArea(cAliasT)             
	(cAliasT)->( DbGoTop() )
	
	ProcRegua( _nContar )

	MONTADIR( _cPath )

	FERASE( _cPath + _cArq )

	If ! File( "C:\DIVER_SRD_RHS\DIVER_SRD_RHS.BAT" )
		_lArqCsv := FCreate( "C:\DIVER_SRD_RHS\DIVER_SRD_RHS.BAT", 0 )
		_cLin    := "ECHO OFF" + ENTER
		_cLin    += "del C:\DIVER_SRD_RHS\*LIBERACAO*.csv" + ENTER
		fWrite( _lArqCsv, _cLin, _lArqCsv )
		fClose( _lArqCsv )
	EndIf

	If File( "C:\DIVER_SRD_RHS\LIBERACAO.CSV" )
		Shellexecute( "Open", "C:\DIVER_SRD_RHS\\DIVER_SRD_RHS.BAT", " /k dir ", "c:\", 1 )
	EndIf

 	If Select(cAliasT) >0 
		_lGerouExc := .T.

		_lArqCsv := FCreate( _cArq, 0 )
		
 		_cEscrev := 'DIVERGENCIA ENTRE SRD X RHS' + ENTER
		_cEscrev += 'FILIAL;MATRICULA;NOME;COMPETENCIA;VERBA;VALOR_FICHA;VALOR_PLANO;DIFERENCA'+ ENTER
		    
 	   	fWrite( _lArqCsv, _cEscrev, _lArqCsv )
	   	
    	While (cAliasT)->( ! Eof() )    
			IncProc( "Gerando dados Relatorio..." )
           
		    _cEscrev := (cAliasT)->FILIAL 		            								+ ';'  
			_cEscrev += (cAliasT)->MATRICULA 		        								+ ';'  
			_cEscrev += (cAliasT)->NOME 		            								+ ';'  
	        _cEscrev += substr((cAliasT)->COMPETENCIA,5,2)+ '/' + substr((cAliasT)->COMPETENCIA,1,4)	+ ';'    
            _cEscrev += (cAliasT)->VERBA 			            							+ ';'
  			_cEscrev += TransForm( (cAliasT)->VALOR_FICHA,  '@E 9,999,999,999,999.99' ) 	+ ';' 
            _cEscrev += TransForm( (cAliasT)->VALOR_PLANO,    '@E 9,999,999,999,999.99' ) 	+ ';'   
			_cEscrev += TransForm( (cAliasT)->DIFERENCA,    '@E 9,999,999,999,999.99' ) + ENTER   

			fWrite( _lArqCsv, _cEscrev, _lArqCsv )
			(cAliasT)->( DbSkip() )
		EndDo
		_lGerouExc := .T.
    EndIf
    
	If _lGerouExc
		fClose( _lArqCsv )

		Aviso( 'INFO', 'O Relatorio de DIVERGêNCIA ENTRE SRD X RHS está finalizado,' +;
	                   ' seu excel será aberto.', { 'Fechar' } )

	    Shellexecute( "Open", _cArq , " /k dir ", "c:\", 1 )
	EndIf
	
	(cAliasT)->( dbCloseArea() )
//	If File( cNomInd + cExtens )     //Elimina o arquivo de trabalho
//		Ferase( cNomInd + cExtens )
//		Ferase( cIndArqB + OrdBagExt() )
//	EndIf
	
Return
