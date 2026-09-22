#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"
#include "tbiconn.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} RDGPEM01
    (long_description)
    @type  Function
    @since 19/09/2020
    @Thiago Pereira
/*/
User Function RDGPEM02()

	Local aArea   	:= GetArea()
	Local cTitulo   := 'ROTINA QUE ALTERA VALOR Da COPARTICIPACAO DO PLANO DE SAUDE U ODONTOLOGICO NO HISTORICO DO PLANO'

	Private lGo     := .T.
	Private pTipo
	Private pFilial
	Private pVerba
	Private pDtDe
	Private pDtAte
	Private pMatDe
	Private pMatAte
	Private oTable
	Private cTblName
	Private aLogarray := {}
	Private lAtivo := .F.
	Private lAchou := .F.
	Private cDPAtivo := ''
	Private aDep     := {}
	Private cSaudeTit  := GETMV('MV_XSAUDET')
	Private cOdontoTit  := GETMV('MV_XODOTI')
	Private cSaudeDep  := GETMV('MV_XSAUDED')
	Private cOdontoDep  := GETMV('MV_XODODE')
	pRIVATE cxTpForn := ''



//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' 

	DBSELECTAREA("SRD")
	DBSELECTAREA("RHS")
	DBSELECTAREA("RHK")
	DBSELECTAREA("RHN")
	DBSELECTAREA("RHL")


	Filtros()
	if lGo
		SelReg()
	endif
	if lGo
		cTblName    := '%' + oTable:GetRealName() + '%'
		Processa({|| FazUpdate()}    , "Fazendo Atualizacao dos valores...")
	endif
	IF lGo
//    	Processa({|| FazLog()}       , "GErando Aquivo de Log ...")
	endif


	If(Type('oTable') <> 'U')

		oTable:Delete()

		FreeObj(oTable)

	EndIf

	SRD->(DBCloseArea())
	RHS->(DBCloseArea())
	RHK->(DBCloseArea())
	RHN->(DBCloseArea())
	RHL->(DBCloseArea())
	RestArea(aArea)
Return

Static Function Filtros()

	LOCAL aParamBox := {}
	LOCAL cTitulo	:= "Filtros Atualizacao Valores"
	LOCAL aRet		:= {}
	LOCAL AGO       := .T.
	Local aStatus	:= {"1 - Titular","2 - Dependente","3 - Agregado"}

/*1 - MsGet                                            
[2] : Descrição                                    
[3] : String contendo o inicializador do campo     
[4] : String contendo a Picture do campo           
[5] : String contendo a validação                  
[6] : Consulta F3                                  
[7] : String contendo a validação When             
[8] : Tamanho do MsGet  
[9] : Flag .T./.F. Parâmetro Obrigatório ?         
*/

	AADD(aParamBox,{1,"Filial"          	,SPACE(8)        ,"","","SM0","",50,.T.})
	AADD(aParamBox,{1,"Verba"           	,SPACE(3)        ,"","u_Valida1Verba()","","",50,.T.})
	aAdd(aParamBox,{1,"Dt Pagamento De:  " 	,(ddataBase),""	,""	,""	 ,"",50	,.T.}) // Tipo data
	aAdd(aParamBox,{1,"Dt Pagamento Até: " 	,(ddataBase),""	,""				,""	 ,"",50	,.T.}) // Tipo data
	aAdd(aParamBox,{1,"Matricula De: "			,Space(6)		,""	,""	,""	 ,"",50	,.T.}) // Tipo caractere
	aAdd(aParamBox,{1,"Matricula Até: "			,Space(6)		,""	,""	,""	 ,"",50	,.T.}) // Tipo caractere

	//AADD(aParamBox,{2,"Tipo"	            ,1              ,aSTATUS        ,50,"",.T.})

	If ParamBox(aParamBox,"Filtros Atualizacao Valores",@aRet)
		//	IF VALTYPE(aRet[7]) == 'N'
		//		pTipo	:= SUBSTR(ASTATUS[ARET[7]],1,1)
		//	ELSE
		//    	pTipo	:= (SUBSTR(aRet[7],1,1))
		//    ENDIF


		pFilial         := aRet[1]
		pVerba			:= aRet[2]
		pDtDe			:= MonthSub(aRet[3],1)
		pDtAte          := MonthSub(aRet[4],1)
		pMatDe			:= aRet[5]
		pMatAte         := aRet[6]

		if pverba $ (cSaudeTit +'_' + cOdontoTit)
			pTipo := '1'
		elseif pverba $ (cSaudeDep +'_' + cOdontoDep)
			pTipo := '2'
		else
			MSGINFO("Verba fora do range permitido, verifique os paramentros MV_SAUDETI, MV_ODOTIT, MV_SAUDEDE, MV_ODODEP",,"ALERT")
			lGO := .F.
		EndIf

		if pverba $ (cSaudeTit +'_' + cSaudeDep)
			cxTpForn :=  '1'
		elseif pverba $ (cOdontoTit +'_' + cOdontoDep)
			cxTpForn :=  '2'
		Else
			lGO := .F.
			MSGINFO("Verba fora do range permitido, verifique os paramentros MV_SAUDETI, MV_ODOTIT, MV_SAUDEDE, MV_ODODEP",,"ALERT")
		endif


	ELSE
		lGO := .F.// APERTOU O BOTAO DE CANCELAR.
	Endif

Return

user function Valida1Verba()
	Local lRet := .T.

	if ! MV_PAR02 $ (cSaudeTit +'_' + cOdontoTit +'_' + cSaudeDep +'_' + cOdontoDep)
		lRet := .f.
		MSGINFO("Verba fora do range permitido, verifique os paramentros MV_SAUDETI, MV_ODOTIT, MV_SAUDEDE, MV_ODODEP",,"ALERT")
	endif'


Return lRet


Static Function SelReg()

	Local aArea   	:= GetArea()
	Local cAlias   := ""
	Local nPosIni	:=	1
	Local i
	Local cxQry := ""
	Local _aCamposAlias := {}

// Instancio o objeto
	oTable  := FwTemporaryTable():New("TRB")


// Crio com array com os campos da tabela

	aAdd(_aCamposAlias, { "RD_FILIAL"	, TamSX3("RD_FILIAL")[3]    , TamSX3("RD_FILIAL")[1]	, TamSX3("RD_FILIAL")[2]})
	aAdd(_aCamposAlias, { "RD_MAT"		, TamSX3("RD_MAT")[3]	    , TamSX3("RD_MAT")[1]		, TamSX3("RD_MAT")[2]})
	aAdd(_aCamposAlias, { "RD_DATPGT"	, TamSX3("RD_DATPGT")[3]    , TamSX3("RD_DATPGT")[1]	, TamSX3("RD_DATPGT")[2]})
	aAdd(_aCamposAlias, { "RD_DATARQ"	, TamSX3("RD_DATARQ")[3]    , TamSX3("RD_DATARQ")[1]	, TamSX3("RD_DATARQ")[2]})
	aAdd(_aCamposAlias, { "RD_PD"		, TamSX3("RD_PD")[3]     	, TamSX3("RD_PD")[1]		, TamSX3("RD_PD")[2]})
	aAdd(_aCamposAlias, { "RHS_CODFOR" 	, TamSX3("RHS_CODFOR")[3]	, TamSX3("RHS_CODFOR")[1]	, TamSX3("RHS_CODFOR")[2]})
	aAdd(_aCamposAlias, { "RHS_TPLAN" 	, TamSX3("RHS_TPLAN")[3]	, TamSX3("RHS_TPLAN")[1]	, TamSX3("RHS_TPLAN")[2]})
	aAdd(_aCamposAlias, { "RHS_COMPPG" 	, TamSX3("RHS_COMPPG")[3]	, TamSX3("RHS_COMPPG")[1]	, TamSX3("RHS_COMPPG")[2]})
	aAdd(_aCamposAlias, { "RHS_ORIGEM" 	, TamSX3("RHS_ORIGEM")[3] 	, TamSX3("RHS_ORIGEM")[1]	, TamSX3("RHS_ORIGEM")[2]})
	aAdd(_aCamposAlias, { "RHS_TPFORN" 	, TamSX3("RHS_TPFORN")[3] 	, TamSX3("RHS_TPFORN")[1]	, TamSX3("RHS_TPFORN")[2]})
	aAdd(_aCamposAlias, { "RHSVLFUN" 	, TamSX3("RHS_VLRFUN")[3]	, TamSX3("RHS_VLRFUN")[1]	, TamSX3("RHS_VLRFUN")[2]})
	aAdd(_aCamposAlias, { "VALORFICHA" 	, TamSX3("RD_VALOR")[3]	    , TamSX3("RD_VALOR")[1]		, TamSX3("RD_VALOR")[2]})

// Adiciono os campos na tabela
	oTable:SetFields(_aCamposAlias)

// Crio a tabela no banco de dados
	oTable:Create()

//cFields := ''

// Busco todos os campos da tabela temporária e preencho numa variável
//For nI := 1 To Len(_aCamposAlias)

	//cFields += _aCamposAlias[nI,1] + ','

//Next nI

//cFields := Left(cFields, Len(cFields) -1)
	if lGo
		//cxQry := "INSERT INTO " + oTable:GetRealName()
		//cxQry += " (" + cFields + ") "
		cxQry := "SELECT * FROM (									" +ENTER
		cxQry += "SELECT 											" +ENTER
		cxQry += " RD_FILIAL,										" +ENTER
		cxQry += " RD_MAT,											" +ENTER
		cxQry += " RD_DATPGT,										" +ENTER
		cxQry += " RD_DATARQ,										" +ENTER
		cxQry += " RD_PD,											" +ENTER
		cxQry += " RHS_CODFOR,										" +ENTER
		cxQry += " RHS_TPLAN,										" +ENTER
		cxQry += " RHS_COMPPG,										" +ENTER
		cxQry += " RHS_ORIGEM,										" +ENTER
		cxQry += " RHS_TPFORN,										" +ENTER
		cxQry += " NVL(RHS_VLRFUN,0.00) RHSVLFUN ,					" +ENTER
		cxQry += " NVL(SUM(RD_VALOR),0.00)  AS VALORFICHA			" +ENTER
		cxQry += "FROM "+ RetSqlName("SRD")+ " SRD						" +ENTER
		cxQry += " 	FULL OUTER JOIN (SELECT RHS_FILIAL,					" +ENTER
		cxQry += " 	                RHS_MAT, 						 	" +ENTER
		cxQry += " 	                RHS_PD, 						 	" +ENTER
		cxQry += " 					RHS_CODFOR,							" +ENTER
		cxQry += " 	                RHS_COMPPG, 					 	" +ENTER
		cxQry += " 					RHS_TPLAN,							" +ENTER
		cxQry += " 					RHS_ORIGEM,							" +ENTER
		cxQry += " 					RHS_TPFORN,							" +ENTER
		cxQry += " 	                SUM( RHS_VLRFUN ) AS RHS_VLRFUN  	" +ENTER
		cxQry += "  			 FROM "+ RetSqlName("RHS")+ " RHS	 					" +ENTER
		cxQry += "           WHERE RHS.D_E_L_E_T_    <> '*' 			" +ENTER
		cxQry += "				AND TRIM(RHS_FILIAL) = '"+pFilial+"'    " +ENTER
		cxQry += " 				AND TRIM(RHS_MAT) >= '"+pMatDe+"' 	    " +ENTER
		cxQry += " 				AND TRIM(RHS_MAT) <= '"+pMatAte+"' 	    " +ENTER
		cxQry += "				AND trim(RHS_PD) = '"+pVerba+"'   		" +ENTER
		cxQry += "              AND RHS_COMPPG BETWEEN '" + AnoMes(pDtDe) + "' " +ENTER
		cxQry += "                  AND '" 		     + AnoMes(pDtAte) + "'" +ENTER
		cxQry += "         	GROUP BY RHS_FILIAL,                        " +ENTER
		cxQry += " 	                RHS_MAT, 						 	" +ENTER
		cxQry += " 	                RHS_PD, 						 	" +ENTER
		cxQry += " 					RHS_CODFOR,							" +ENTER
		cxQry += " 	                RHS_COMPPG, 					 	" +ENTER
		cxQry += " 					RHS_TPLAN,							" +ENTER
		cxQry += " 					RHS_ORIGEM,							" +ENTER
		cxQry += " 					RHS_TPFORN							" +ENTER
		cxQry += "          ORDER BY RHS_COMPPG ) RHS                       " +ENTER
		cxQry += "  	ON (RD_MAT = RHS_MAT AND RD_FILIAL = RHS_FILIAL AND RD_PD = RHS_PD AND RD_DATARQ = RHS_COMPPG ) " +ENTER
		cxQry += "WHERE SRD.D_E_L_E_T_ <> '*'						  				" +ENTER
		cxQry += "		AND RD_VALOR  > 0					  						" +ENTER
		cxQry += "		AND TRIM(RD_FILIAL) = '"+pFilial+"'   						" +ENTER
		cxQry += " 		AND TRIM(RD_MAT) >= '"+pMatDe+"'    						" +ENTER
		cxQry += " 		AND TRIM(RD_MAT) <= '"+pMatAte+"' 	    					" +ENTER
		cxQry += "		AND trim(RD_PD) = '"+pVerba+"'   							" +ENTER
		cxQry += "      AND RD_DATARQ BETWEEN '" + AnoMes(pDtDe) + "' 				" +ENTER
		cxQry += "               AND '" 		  + AnoMes(pDtAte) + "'				" +ENTER
		cxQry += "         	GROUP BY RD_FILIAL,                        " +ENTER
		cxQry += "           RD_MAT,                                    " +ENTER
		cxQry += "           RD_DATPGT,                                " +ENTER
		cxQry += "           RD_DATARQ,                                 " +ENTER
		cxQry += "           RD_PD,                                     " +ENTER
		cxQry += "           RHS_CODFOR,                                " +ENTER
		cxQry += "           RHS_TPLAN,                                 " +ENTER
		cxQry += "           RHS_COMPPG,                                " +ENTER
		cxQry += "           RHS_ORIGEM,                                " +ENTER
		cxQry += "           RHS_TPFORN,                                " +ENTER
		cxQry += "           RHS_VLRFUN                                " +ENTER
		cxQry += "ORDER BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATPGT, SRD.RD_PD, RHS.RHS_CODFOR, RHS.RHS_TPLAN, RHS.RHS_COMPPG, RHS.RHS_ORIGEM, RHS.RHS_TPFORN 		    "	+ENTER
		cxQry += " ) WHERE RHSVLFUN <> VALORFICHA							" +ENTER
		cxQry := ChangeQuery( cxQry )

		SQLToTrb(cxQry, _aCamposAlias, "TRB")
		// Executo o comando SQL
		//If(TcSqlExec(cxQry) < 0 .and. !Empty(TcSqlError()))
		//    MsgAlert('Ocorreu um erro ao executar o comando SQL!' + CRLF + CRLF + TcSqlError(), 'Erro ao popular tabela')
		//    lGo := .F.
		//Endif

//"SELECT INTO TSC00_324231872 (FILIAL,RD_MAT,RD_DATPGT,RD_PD,RHS_CODFOR,RHS_TPLAN,RHS_COMPPG,RHS_ORIGEM,RHS_TPFORN,RHSVLFUN,VALORFICHA)  SELECT  RD_FILIAL,RD_MAT,RD_DATPGT,RD_PD,RHS_CODFOR,RHS_TPLAN,RHS_COMPPG,RHS_ORIGEM,RHS_TPFORN,COALESCE(RHS_VLRFUN,0.00) RHSVLFUN,COALESCE(SUM(RD_VALOR),0.00) AS VALORFICHA FROM SRD010 SRD FULL OUTER JOIN (SELECT RHS_FILIAL,RHS_MAT,RHS_PD,RHS_CODFOR,RHS_COMPPG,RHS_TPLAN,RHS_ORIGEM,RHS_TPFORN,SUM(RHS_VLRFUN ) AS RHS_VLRFUN FROM RHS010 RHS WHERE  RHS.D_E_L_E_T_ <> '*' AND TRIM(RHS_FILIAL) = '04J40001' AND TRIM(RHS_MAT) >= '000000' AND TRIM(RHS_MAT) <= '999999' AND TRIM(RHS_PD) = '625' AND RHS_DATPGT BETWEEN '20190101' AND '20191231' GROUP BY RHS_FILIAL, RHS_MAT, RHS_PD, RHS_CODFOR, RHS_COMPPG, RHS_TPLAN, RHS_ORIGEM, RHS_TPFORN  ORDER BY  RHS_COMPPG )  RHS ON (RD_MAT = RHS_MAT AND RD_FILIAL = RHS_FILIAL AND RD_PD = RHS_PD AND RD_DATARQ = RHS_COMPPG AND RD_VALOR <> RHS_VLRFUN) WHERE  SRD.D_E_L_E_T_ <> '*' AND RD_VALOR > 0 AND TRIM(RD_FILIAL) = '04J40001' AND TRIM(RD_MAT) >= '000000' AND TRIM(RD_MAT) <= '999999' AND TRIM(RD_PD) = '625' AND RD_DATPGT BETWEEN '20190101' AND '20191231' AND RHS.RHS_ORIGEM IN ('1') GROUP BY RD_FILIAL, RD_MAT, RD_DATPGT, RD_PD, RHS_CODFOR, RHS_TPLAN, RHS_COMPPG, RHS_ORIGEM, RHS_TPFORN, RHS_VLRFUN  ORDER BY  SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATPGT, SRD.RD_PD, RHS.RHS_CODFOR, RHS.RHS_TPLAN, RHS.RHS_COMPPG, RHS.RHS_ORIGEM, RHS.RHS_TPFORN"



	EndIf

Return


Static Function FazUpdate()

	Local nContDep   := 0
	Local lresto := .F.

	dbselectarea("TRB")
	TRB->( DbGoTop() )

	DO WHILE !TRB->(EOF())//  !ZZ3->(EOF())

		dbselectArea("RHS")
		DBSETORDER(1)
		DBGOTOP()
		IF DBSEEK(TRB->RD_FILIAL+ TRB->RD_MAT + TRB->RHS_COMPPG)

			do while RHS->( ! eof() ) .AND. RHS->RHS_FILIAL+ RHS->RHS_MAT + RHS->RHS_COMPPG == ;
					TRB->RD_FILIAL+ TRB->RD_MAT + TRB->RHS_COMPPG

				if 	RHS->RHS_FILIAL + RHS->RHS_MAT + RHS->RHS_COMPPG + RHS->RHS_PD  ==  ;
						TRB->RD_FILIAL  + TRB->RD_MAT  + TRB->RD_DATARQ  + TRB->RD_PD

					reclock( 'RHS' , .F. )
					dbDelete()
					RHS->( msunlock() )
				endif
				RHS->(DBSKIP())
			enddo
		endif



		IF pTipo = '1' //Titular
			cad_titular()
		elseif pTipo = '2' //dependente
			cad_dependente()
		ELSEIF 	TRB->RHS_ORIGEM == '3' // AGREGADO

		ENDIF

		DBSELECTAREA("TRB")
		TRB->(DBSKIP())

	ENDDO

	If Len(aLogarray) > 0
		GrvLog(aLogarray)
	endif

Return

Static Function cad_titular()
	Local cTITTMP	    := GetNextAlias()
	Local cRHNTMP	    := GetNextAlias()
	Local cperiodo := substr(TRB->RD_DATARQ,5,2)+substr(TRB->RD_DATARQ,1,4)
	Local aLastQuery := {}
	Local cCodfor := ''
	Local cRHSCod := ''
	Local cPlano  := ''
	Local cPerIni := ''
	Local cPerFim := ''
	Local lAchouCHK := .f.
	// VERIFICA OCADASTRO PLANO SAUDE

	BEGINSQL ALIAS cTITTMP
	SELECT  RHK_CODFOR AS CODFOR,  RHK_TPPLAN  AS TPPLAN, RHK_PLANO  AS PLANO 
	FROM %Table:RHK%
	WHERE %NotDel%
	   AND RHK_FILIAL = %Exp:TRB->RD_FILIAL%
	   AND RHK_MAT = %Exp:TRB->RD_MAT%
	   AND RHK_TPFORN = %Exp:cxTpForn%
	   AND SUBSTR(RHK_PERINI,3,4) || SUBSTR(RHK_PERINI,1,2) <= %Exp:TRB->RD_DATARQ%
       AND (SUBSTR(RHK_PERFIM,3,4) || SUBSTR(RHK_PERFIM,1,2) >= %Exp:TRB->RD_DATARQ% OR RHK_PERFIM = '      ')
	ENDSQL

	if (cTITTMP)->(Eof())
		(cTITTMP)->(dbCloseArea())
		BEGINSQL ALIAS cTITTMP
		SELECT RHN_CODFOR AS CODFOR, RHN_TPPLAN AS TPPLAN, RHN_PLANO AS PLANO
		FROM %Table:RHN%
		WHERE	%NotDel%
			AND RHN_FILIAL = %Exp:TRB->RD_FILIAL%
			AND RHN_MAT = %Exp:TRB->RD_MAT%
			AND RHN_ORIGEM = '1'
			AND RHN_PD =%Exp:TRB->RD_PD%
			AND RHN_TPFORN = %Exp:cxTpForn%
			AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
			AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
			AND RHN_DATA||RHN_OPERAC = (SELECT	MAX(RHN_DATA||RHN_OPERAC) ULTDATA
							FROM
								%Table:RHN%
							WHERE %NotDel%
								AND RHN_FILIAL = %Exp:TRB->RD_FILIAL%
								AND RHN_MAT = %Exp:TRB->RD_MAT%
								AND RHN_ORIGEM = '1'
								AND RHN_PD =%Exp:TRB->RD_PD%
								AND RHN_TPFORN = %Exp:cxTpForn%
								AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
								AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
							)
		ENDSQL
	endif

	IF ! (cTITTMP)->(Eof())
		cCodfor := (cTITTMP)->CODFOR
		cRHSCod := (cTITTMP)->TPPLAN
		cPlano  := (cTITTMP)->PLANO

		dbselectArea("RHS")
		//DBSETORDER(1)
		//DBGOTOP()

		//IF DBSEEK(TRB->RD_FILIAL+ TRB->RD_MAT + TRB->RHS_COMPPG+ '1' + '  ' +'1'+ (cRHKTMP)->RHK_TPFORN + cCodfor+ cRHSCod +  cPlano + TRB->RD_PD)
		//   	RECLOCK("RHS",.F.)
		//		RHS->RHS_VLRFUN := TRB->VALORFICHA
		//       RHS->(MSUNLOCK())
		//	AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHS->RHS_VLRFUN,"Titular Atualizado com sucesso"})
		//Else
		RecLock("RHS",.T.)
		RHS->RHS_FILIAL	:= TRB->RD_FILIAL
		RHS->RHS_MAT	:= TRB->RD_MAT
		RHS->RHS_DATA   := LASTDAY(STOD(TRB->RD_DATARQ+'01')) //SToD(AnoMes(TRB->RD_DATARQ)+LAST_DAY(STOD(TRB->RD_DATARQ))
		RHS->RHS_ORIGEM := '1'
		//RHS->RHS_CODIGO	:= (cTITTMP)->RHL_CODIGO
		RHS->RHS_TPLAN  := '1'
		RHS->RHS_TPFORN := cxTpForn
		RHS->RHS_CODFOR := cCodfor
		RHS->RHS_TPPLAN := cRHSCod
		RHS->RHS_PLANO  := cPlano
		RHS->RHS_PD		:= TRB->RD_PD
		RHS->RHS_VLRFUN := TRB->VALORFICHA
		RHS->RHS_VLREMP := 0
		RHS->RHS_COMPPG	:= TRB->RD_DATARQ
		RHS->RHS_DATPGT := TRB->RD_DATPGT
		RHS->RHS_TIPO   :=  "1"
		RHS->RHS_XOBSER := "GERADO PELA ROTINA DE AJUSTE"
		RHS->(msUnlock())
		AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHS->RHS_VLRFUN,"Funcionario cadastrado com sucesso"})
		//endif
		(cTITTMP)->(dbCloseArea())
	else
		AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA,'0',"Funcionario nao encontrado na RHK nem na RHN"})
	endif
Return

Static Function cad_Dependente()
//Local cperiodo := substr(TRB->RD_DATARQ,5,2)+substr(TRB->RD_DATARQ,1,4)	//Month2Str(TRB->RD_DATARQ)+Year2Str(TRB->RD_DATARQ)
	Local cDEPTMP := GetNextAlias()
	Local cRHKTMP := GetNextAlias()
	Local cRHNTMP := GetNextAlias()
	Local cperiodo := substr(TRB->RD_DATARQ,5,2)+substr(TRB->RD_DATARQ,1,4)
	Local cCodfor := ''
	Local cRHSCod := ''
	Local nQtd := 0
	Local ncont := 0
	Local nNewVL := 0



	BEGINSQL ALIAS cDEPTMP
	SELECT  RHL_CODIGO AS CODIGO , RHL_TPFORN AS TPFORN, RHL_CODFOR AS CODFOR, RHL_TPPLAN AS TPPLAN, RHL_PLANO AS PLANO  
	FROM %Table:RHL%
	WHERE %NotDel%
	   AND RHL_FILIAL = %Exp:TRB->RD_FILIAL%
	   AND RHL_MAT = %Exp:TRB->RD_MAT%
	   AND RHL_TPFORN = %Exp:cxTpForn%
	   AND SUBSTR(RHL_PERINI,3,4) || SUBSTR(RHL_PERINI,1,2) <= %Exp:TRB->RD_DATARQ%
       AND (SUBSTR(RHL_PERFIM,3,4) || SUBSTR(RHL_PERFIM,1,2) >= %Exp:TRB->RD_DATARQ% OR RHL_PERFIM = '      ')
	   //AND (substr(RHL_PERINI,3,4)||substr(RHL_PERINI,1,2)) <= %Exp:cperiodo%
	ORDER BY RHL_PERINI
	ENDSQL

	if (cDEPTMP)->(Eof())
		(cDEPTMP)->(dbCloseArea())
		BEGINSQL ALIAS cDEPTMP
		SELECT RHN_CODIGO AS CODIGO , RHN_TPFORN AS TPFORN, RHN_CODFOR AS CODFOR, RHN_TPPLAN AS TPPLAN, RHN_PLANO AS PLANO 
		FROM %Table:RHN%
		WHERE	%NotDel%
			AND RHN_FILIAL = %Exp:TRB->RD_FILIAL%
			AND RHN_MAT = %Exp:TRB->RD_MAT%
			AND RHN_ORIGEM = '2'
			AND RHN_PDDAGR =%Exp:TRB->RD_PD%
			AND RHN_TPFORN = %Exp:cxTpForn%
			AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
			AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
			AND RHN_DATA||RHN_OPERAC = (SELECT
								MAX(RHN_DATA||RHN_OPERAC) ULTDATA
							FROM
								%Table:RHN%
							WHERE %NotDel%
								AND RHN_FILIAL = %Exp:TRB->RD_FILIAL%
								AND RHN_MAT = %Exp:TRB->RD_MAT%
								AND RHN_ORIGEM = '2'
								AND RHN_PDDAGR =%Exp:TRB->RD_PD%
								AND RHN_TPFORN = %Exp:cxTpForn%
								AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
								AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
							)
		ENDSQL
	endif

	While ! (cDEPTMP)->(Eof())
		nQtd++
		(cDEPTMP)->(dbskip())
	end
	(cDEPTMP)->(dbGotop())

	IF nQtd > 0
		nNewVL := fDistribui(TRB->VALORFICHA,nqtd)
		ncont := 0
		While ! (cDEPTMP)->(Eof())
			ncont++
			dbselectArea("RHS")
			RHS->(DBSETORDER(1))
			RHS->(DBGOTOP())
			IF RHS->(DBSEEK(PadR(TRB->RD_FILIAL, TamSx3("RD_FILIAL")[1])+ PadR(TRB->RD_MAT, TamSx3("RD_MAT")[01]) + PadR(TRB->RHS_COMPPG, TamSx3("RHS_COMPPG")[01]) + PadR((cDEPTMP)->TPFORN, TamSX3("RHS_TPFORN")[01]) + PadR((cDEPTMP)->CODFOR,TamSx3("RHS_CODFOR")[01])+ PadR(TRB->RD_PD, TamSx3("RD_PD")[01]) + PadR((cDEPTMP)->CODIGO, TamSx3("RHS_CODIGO")[01]) + PadR('2',TamSX3("RHS_ORIGEM")[01]) ))
				RECLOCK("RHS",.F.)
				RHS->RHS_VLRFUN := nNewVL[ncont]
				RHS->(MSUNLOCK())
				AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHS->RHS_VLRFUN,"Dependente Atualizado com sucesso"})
			Else
				RecLock("RHS",.T.)
				RHS->RHS_FILIAL	:= TRB->RD_FILIAL
				RHS->RHS_MAT	:= TRB->RD_MAT
				RHS->RHS_DATA   := LASTDAY(STOD(TRB->RD_DATARQ+'01')) //SToD(AnoMes(TRB->RD_DATARQ)+LAST_DAY(STOD(TRB->RD_DATARQ))
				RHS->RHS_ORIGEM := '2'
				RHS->RHS_CODIGO	:= (cDEPTMP)->CODIGO
				RHS->RHS_TPLAN  := '1'
				RHS->RHS_TPFORN := (cDEPTMP)->TPFORN
				RHS->RHS_CODFOR := (cDEPTMP)->CODFOR
				RHS->RHS_TPPLAN := (cDEPTMP)->TPPLAN
				RHS->RHS_PLANO  := (cDEPTMP)->PLANO
				RHS->RHS_PD		:= TRB->RD_PD
				RHS->RHS_VLRFUN := nNewVL[ncont]
				RHS->RHS_VLREMP := 0
				RHS->RHS_COMPPG	:= TRB->RD_DATARQ
				RHS->RHS_DATPGT := TRB->RD_DATPGT
				RHS->RHS_TIPO   :=  "1"
				RHS->RHS_XOBSER := "GERADO PELA ROTINA DE AJUSTE"
				RHS->(msUnlock())
				AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHS->RHS_VLRFUN,"Dependente cadastrado com sucesso"})
			endif
			(cDEPTMP)->(dbskip())
		end
		(cDEPTMP)->(dbCloseArea())
	else
		AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ,TRB->VALORFICHA, '0',"Dependente nao encontrado na RHL"})
	endif
Return

STATIC FUNCTION VERCADSAUDE()

	Local Ativo := .f.
	Local nQtd  := 0
	Local nPgto := 0
	lAtivo := .F.
	lAchou := .F.

	IF TRB->RHS_ORIGEM == '1'
		dbselectArea("RHK")
		DBSETORDER(1)
		IF DBSEEK(XFILIAL("RHK") + TRB->RD_MAT + TRB->RHS_CODFOR)  //!ZZ3->(EOF())
			DO WHILE !RHK->(EOF()) .AND. (XFILIAL("RHK") + RHK->RHK_MAT + RHK->RHK_CODFOR) == TRB->RD_FILIAL + TRB->RD_MAT + TRB->RHS_CODFOR
				IF RHK->RHK_TPPLAN == TRB->RHS_TPLAN
					lAchou := .T.
					IF TRB->RHS_COMPPG >= RHK->PERINI .AND. TRB->RHS_COMPPG <= RHK->PERFIM
						lATIVO := .T.
					ELSE
						lATIVO := .F.
					ENDIF
				ELSE
					LACHOU := .F.
				ENDIF
				DBSELECTAREA("RHK")
				RHK->(DBSKIP())
			ENDDO
		endif
	ELSEIF 	TRB->RHS_ORIGEM == '2'
		cQuery := "SELECT RHL_CODIGO " +ENTER
		cQuery += "FROM " + RetSqlName("RHL")  + " " +ENTER
		cQuery += "WHERE RHL_FILIAL = '" + TRB->RD_FILIAL + "' " +ENTER
		CQUERY += " AND RHL_MAT     = '" + TRB->RD_MAT + "' " +ENTER
		CQUERY += " AND RHL_TPFORN  = '" + TRB->RHS_TPFORN  + "' " +ENTER
//		CQUERY += " AND RHL_CODIGO  = '" + ADEP[II][2] + "' " + Chr(10) + Chr(13)   
		CQUERY += " AND RHL_TPPLAN  = '" + TRB->RHS_TPLAN + "' " +ENTER
//		CQUERY += " AND RHL_PLANO   = '" + TRB->RHS_PLANO + "' " +ENTER  
		CQUERY += " AND RHL_PERINI <= '" + (TRB->RHS_COMPPG) + "' " +ENTER
		CQUERY += " AND RHL_PERFIM <= '" + (TRB->RHS_COMPPG) + "' " +ENTER

		If Select("DEPAT") > 0
			dbSelectArea("DEPAT")
			dbCloseArea()
		EndIf

		TcQuery cQuery New Alias "DEPAT"
		DbSelectArea("DEPAT")
		DBGOTOP()
		WHILE !DEPAT->(Eof())
			nQtd++
			cDpAtivo += "/" + DEPAT->RHL_CODIGO + "/"
			DBSELECTAREA("DEPAT")
			DEPAT->(DBSKIP())
		ENDDO

	ENDIF

RETURN nQtd


Static Function GrvLog(aLog)

	Local oFWExcel
	Local oExcel
	Local nAux 			:= 0
	Local cArquivo		:= GetTempPath()+'LogRHS_'+TRB->RD_PD + '_'+DTOS(dDatabase) + '.xml'
	Local cWorkSheet	:= "Aba Verba " + TRB->RD_PD
	Local cTable		:= "Log acerto RHS " + TRB->RD_PD
	Local aColunas		:= {}
	Local aLinhaAux		:= {}

	aAdd(aColunas, 'Verba'     )
	aAdd(aColunas, 'Empresa'   )
	aAdd(aColunas, 'Matricula' )
	aAdd(aColunas, 'Periodo'   )
	aAdd(aColunas, 'Valor Ficha'     )
	aAdd(aColunas, 'Valor Rateio'     )
	aAdd(aColunas, 'Lancamento')

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWExcel := FWMsExcelEx():New()

	//Aba 01 - Teste
	oFWExcel:AddworkSheet(cWorkSheet) //Não utilizar número junto com sinal de menos. Ex.: 1-

	//Criando a Tabela
	oFWExcel:AddTable(cWorkSheet, cTable)

	//Criando Colunas
	For nAux := 1 To Len(aColunas)
		oFWExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
	Next

	For nAux := 1 to Len(aLog)
		aLinhaAux := Array(Len(aColunas))

		aLinhaAux[1] := aLog[nAux][1]
		aLinhaAux[2] := aLog[nAux][2]
		aLinhaAux[3] := aLog[nAux][3]
		aLinhaAux[4] := aLog[nAux][4]
		aLinhaAux[5] := aLog[nAux][5]
		aLinhaAux[6] := aLog[nAux][6]
		aLinhaAux[7] := aLog[nAux][7]

		oFWExcel:AddRow(cWorkSheet, cTable, aLinhaAux)

	Next nAux

	//Ativando o arquivo e gerando o xml
	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New() 			//Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo) 	//Abre uma planilha
	oExcel:SetVisible(.T.) 				//Visualiza a planilha
	oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas

Return

Static Function fDistribui ( nxValorCheio, nxQuantos )

	Local axValores := Array( nxQuantos )
	Local nxQual := 0
	Local nxValorPadrao := Round ( nxValorCheio / nxQuantos, 2 )
	Local nxAcumulado := 0
	Local nxNovoVal := 0
	Local nxDif := 0
	Local nx

	For nxQual :=1 To nxQuantos
		axValores[nxQual] := nxValorPadrao
		nxAcumulado += axValores[nxQual]
	Next nxQual
	nxQual := 1
	While nxAcumulado > nxValorCheio
		axValores[nxQual] := axValores[nxQual] - 0.01
		nxAcumulado -= 0.01
		nxQual++
	EndDo
	nxQual := 1
	While nxAcumulado < nxValorCheio
		axValores[nxQual] := axValores[nxQual] + 0.01
		nxAcumulado += 0.01
		nxQual++
	EndDo

	For nx :=1 To len(axValores)
		nxNovoVal += axValores[nx]
	Next nx

	if nxValorCheio <> nxNovoVal
		nxdif := nxValorCheio -  nxNovoVal
		axValores[1] :=  axValores[1] + nxdif
	endif
Return axValores

