

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
User Function RDGPEM01()

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
	Private cSaudeCoop  := GETMV('MV_XCOPSAU')
	Private cOdontoCoop  := GETMV('MV_XCOOPOD')
	Private CXTPFORN := ''



//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' 

	DBSELECTAREA("SRD")
	DBSELECTAREA("RHP")
	DBSELECTAREA("RHP")
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
	//AADD(aParamBox,{1,"Verba"           	,SPACE(3)        ,"","","","",50,.T.})
	AADD(aParamBox,{1,"Verba"           	,SPACE(3)        ,"","u_ValidaVerba()","","",50,.T.})
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


		if pverba $ (cSaudeCoop)
			cxTpForn :=  '1'
		elseif pverba $ (cOdontoCoop)
			cxTpForn :=  '2'
		Else
			lGO := .F.
			MSGINFO("Verba fora do range permitido, verifique os paramentros MV_SAUDETI, MV_ODOTIT, MV_SAUDEDE, MV_ODODEP",,"ALERT")
		endif

	ELSE
		lGO := .F.// APERTOU O BOTAO DE CANCELAR.
	Endif

Return



user function ValidaVerba()
	Local lRet := .T.
//	if ! MV_PAR02 $ ('625_626_634_635')

	if ! MV_PAR02 $ ((cSaudeCoop  +'_'+ cOdontoCoop))
		lRet := .f.
		MSGINFO("Verba fora do range permitido, verifique os paramentros MV_COPSAUD, MV_COOPODO",,"ALERT")
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
	aAdd(_aCamposAlias, { "RHP_CODFOR" 	, TamSX3("RHP_CODFOR")[3]	, TamSX3("RHP_CODFOR")[1]	, TamSX3("RHP_CODFOR")[2]})
	aAdd(_aCamposAlias, { "RHP_TPLAN" 	, TamSX3("RHP_TPLAN")[3]	, TamSX3("RHP_TPLAN")[1]	, TamSX3("RHP_TPLAN")[2]})
	aAdd(_aCamposAlias, { "RHP_COMPPG" 	, TamSX3("RHP_COMPPG")[3]	, TamSX3("RHP_COMPPG")[1]	, TamSX3("RHP_COMPPG")[2]})
	aAdd(_aCamposAlias, { "RHP_ORIGEM" 	, TamSX3("RHP_ORIGEM")[3] 	, TamSX3("RHP_ORIGEM")[1]	, TamSX3("RHP_ORIGEM")[2]})
	aAdd(_aCamposAlias, { "RHP_TPFORN" 	, TamSX3("RHP_TPFORN")[3] 	, TamSX3("RHP_TPFORN")[1]	, TamSX3("RHP_TPFORN")[2]})
	aAdd(_aCamposAlias, { "RHPVLFUN" 	, TamSX3("RHP_VLRFUN")[3]	, TamSX3("RHP_VLRFUN")[1]	, TamSX3("RHP_VLRFUN")[2]})
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
		cxQry += " RHP_CODFOR,										" +ENTER
		cxQry += " RHP_TPLAN,										" +ENTER
		cxQry += " RHP_COMPPG,										" +ENTER
		cxQry += " RHP_TPFORN,										" +ENTER
		cxQry += " NVL(RHP_VLRFUN,0.00) RHPVLFUN ,					" +ENTER
		cxQry += " NVL(SUM(RD_VALOR),0.00)  AS VALORFICHA			" +ENTER
		cxQry += "FROM " + RetSqlName("SRD")+ " SRD									" +ENTER
		cxQry += " 	FULL OUTER JOIN (SELECT RHP_FILIAL,					" +ENTER
		cxQry += " 	                RHP_MAT, 						 	" +ENTER
		cxQry += " 	                RHP_PD, 						 	" +ENTER
		cxQry += " 					RHP_CODFOR,							" +ENTER
		cxQry += " 	                RHP_COMPPG, 					 	" +ENTER
		cxQry += " 					RHP_TPLAN,							" +ENTER
		cxQry += " 					RHP_TPFORN,							" +ENTER
		cxQry += " 	                SUM( RHP_VLRFUN ) AS RHP_VLRFUN  	" +ENTER
		cxQry += "  			 FROM " + RetSqlName("RHP")+ " RHP	 					" +ENTER
		cxQry += "           WHERE RHP.D_E_L_E_T_    = ' ' 			" +ENTER
		cxQry += "				AND TRIM(RHP_FILIAL) = '"+pFilial+"'    " +ENTER
		cxQry += " 				AND TRIM(RHP_MAT) >= '"+pMatDe+"' 	    " +ENTER
		cxQry += " 				AND TRIM(RHP_MAT) <= '"+pMatAte+"' 	    " +ENTER
		cxQry += "				AND trim(RHP_PD) = '"+pVerba+"'   		" +ENTER
		cxQry += "              AND RHP_COMPPG BETWEEN '" + AnoMes(pDtDe) + "' " +ENTER
		cxQry += "                  AND '" 		     + AnoMes(pDtAte) + "'" +ENTER
		cxQry += "         	GROUP BY RHP_FILIAL,                        " +ENTER
		cxQry += " 	                RHP_MAT, 						 	" +ENTER
		cxQry += " 	                RHP_PD, 						 	" +ENTER
		cxQry += " 					RHP_CODFOR,							" +ENTER
		cxQry += " 	                RHP_COMPPG, 					 	" +ENTER
		cxQry += " 					RHP_TPLAN,							" +ENTER
		cxQry += " 					RHP_TPFORN							" +ENTER
		cxQry += "          ORDER BY RHP_COMPPG ) RHP                       " +ENTER
		cxQry += "  	ON (RD_MAT = RHP_MAT AND RD_FILIAL = RHP_FILIAL AND RD_PD = RHP_PD AND RD_DATARQ = RHP_COMPPG ) " +ENTER
		cxQry += "WHERE SRD.D_E_L_E_T_ = ' '						  				" +ENTER
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
		cxQry += "           RHP_CODFOR,                                " +ENTER
		cxQry += "           RHP_TPLAN,                                 " +ENTER
		cxQry += "           RHP_COMPPG,                                " +ENTER
		cxQry += "           RHP_TPFORN,                                " +ENTER
		cxQry += "           RHP_VLRFUN                                " +ENTER
		cxQry += "ORDER BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATPGT, SRD.RD_PD, RHP.RHP_CODFOR, RHP.RHP_TPLAN, RHP.RHP_COMPPG, RHP.RHP_TPFORN 		    "	+ENTER
		cxQry += " ) WHERE RHPVLFUN <> VALORFICHA							" +ENTER
		cxQry := ChangeQuery( cxQry )

		SQLToTrb(cxQry, _aCamposAlias, "TRB")

	EndIf

Return


Static Function FazUpdate()

	Local nContDep   := 0
	Local lresto := .F.

	dbselectarea("TRB")
	TRB->( DbGoTop() )

	DO WHILE !TRB->(EOF())//  !ZZ3->(EOF())

		dbselectArea("RHP")
		DBSETORDER(2)
		DBGOTOP()
		IF DBSEEK(TRB->RD_FILIAL+ TRB->RD_MAT + TRB->RHP_COMPPG) // + cxTpForn + cCodfor + TRB->RD_PD + "  " )

			do while RHP->( ! eof() ) .AND. RHP->RHP_FILIAL+ RHP->RHP_MAT + RHP->RHP_COMPPG == ;
					TRB->RD_FILIAL+ TRB->RD_MAT + TRB->RHP_COMPPG

				if 	RHP->RHP_FILIAL + RHP->RHP_MAT + RHP->RHP_COMPPG + RHP->RHP_PD  ==  ;
						TRB->RD_FILIAL  + TRB->RD_MAT  + TRB->RD_DATARQ  + TRB->RD_PD

					reclock( 'RHP' , .F. )
					dbDelete()
					RHP->( msunlock() )
				endif
				RHP->(DBSKIP())
			enddo
		endif


		cad_dependente()

		DBSELECTAREA("TRB")
		TRB->(DBSKIP())

	ENDDO
	If Len(aLogarray) > 0
		GrvLog(aLogarray)
	endif

Return

Static Function cad_titular(pvalor)
	Local aArea 	:= GetArea()
	Local cTITTMP	:= GetNextAlias()
	Local cperiodo 	:= substr(TRB->RD_DATARQ,5,2)+substr(TRB->RD_DATARQ,1,4)
	Local aLastQuery := {}
	Local cCodfor := ''
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
		//	AND RHN_PD =%Exp:TRB->RD_PD%
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
							//	AND RHN_PD =%Exp:TRB->RD_PD%
								AND RHN_TPFORN = %Exp:cxTpForn%
								AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
								AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
							)
		ENDSQL
	endif

	IF ! (cTITTMP)->(Eof())
		dbselectArea("RHp")
		RecLock("RHP",.T.)
		RHP->RHP_FILIAL	:= TRB->RD_FILIAL
		RHP->RHP_MAT	:= TRB->RD_MAT
		RHP->RHP_DTOCOR := LASTDAY(STOD(TRB->RD_DATARQ+'01'))//LASTDAY(TRB->RD_DATARQ) //SToD(AnoMes(TRB->RD_DATARQ)+LAST_DAY(STOD(TRB->RD_DATARQ))
		RHP->RHP_ORIGEM := '1'
		RHP->RHP_TPFORN := cxTpForn
		RHP->RHP_CODFOR := (cTITTMP)->CODFOR
		RHP->RHP_TPLAN  := '1'
		RHP->RHP_PD		:= TRB->RD_PD
		RHP->RHP_VLRFUN := pvalor
		RHP->RHP_COMPPG	:= TRB->RD_DATARQ
		RHP->RHP_VLREMP = 0
		RHP->RHP_OBSERV = "GERADO PELA ROTINA DE AJUSTE"
		RHP->RHP_DATPGT = TRB->RD_DATPGT
		RHP->(msUnlock())
		AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHP->RHP_VLRFUN,"Funcionario cadastrado com sucesso"})
		(cTITTMP)->(dbCloseArea())
	else
		AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHP->RHP_VLRFUN,"Funcionario nao encontrado na RHK nem na RHN"})
	endif

	If Select(cTITTMP) > 0
		(cTITTMP)->(dbCloseArea())
	EndIf
	RestArea(aArea)
Return

Static Function cad_Dependente()
	Local aArea   := GetArea()
	Local cDEPTMP := GetNextAlias()
	Local cperiodo := substr(TRB->RD_DATARQ,5,2)+substr(TRB->RD_DATARQ,1,4)
	Local cCodfor := ''
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
		//	AND RHN_PDDAGR =%Exp:TRB->RD_PD%
			AND RHN_TPFORN = %Exp:cxTpForn%
			AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
			AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
			AND RHN_DATA||RHN_OPERAC = (SELECT	MAX(RHN_DATA||RHN_OPERAC) ULTDATA
							FROM
								%Table:RHN%
							WHERE %NotDel%
								AND RHN_FILIAL = %Exp:TRB->RD_FILIAL%
								AND RHN_MAT = %Exp:TRB->RD_MAT%
								AND RHN_ORIGEM = '2'
		//						AND RHN_PDDAGR =%Exp:TRB->RD_PD%
								AND RHN_TPFORN = %Exp:cxTpForn%
								AND SUBSTR(RHN_PERINI, 3, 4) || SUBSTR(RHN_PERINI, 1, 2) <= %Exp:TRB->RD_DATARQ%
								AND (SUBSTR(RHN_PERFIM, 3, 4) || SUBSTR(RHN_PERFIM, 1, 2) >=%Exp:TRB->RD_DATARQ% OR RHN_PERFIM = '      ')
							)
		ENDSQL
	endif

	nQtd := 1
	While ! (cDEPTMP)->(Eof())
		nQtd++
		(cDEPTMP)->(dbskip())
	end
	(cDEPTMP)->(dbGotop())

	IF nQtd = 1
		cad_titular(TRB->VALORFICHA)
	ELSE
		nNewVL := fDistribui(TRB->VALORFICHA,nqtd)
		ncont := 1
		While ! (cDEPTMP)->(Eof())
			ncont++
			dbselectArea("RHP")
			RHP->(DBSETORDER(2))
			RHP->(DBGOTOP())
			IF RHP->(DBSEEK(PadR(TRB->RD_FILIAL, TamSx3("RD_FILIAL")[1])+ PadR(TRB->RD_MAT, TamSx3("RD_MAT")[01]) + PadR(TRB->RHP_COMPPG, TamSx3("RHP_COMPPG")[01]) + PadR((cDEPTMP)->TPFORN, TamSX3("RHP_TPFORN")[01]) + PadR((cDEPTMP)->CODFOR,TamSx3("RHP_CODFOR")[01])+ PadR(TRB->RD_PD, TamSx3("RD_PD")[01]) + PadR((cDEPTMP)->CODIGO, TamSx3("RHP_CODIGO")[01]) + PadR('2',TamSX3("RHP_ORIGEM")[01]) ))
				RECLOCK("RHP",.F.)
				RHP->RHP_VLRFUN := nNewVL[ncont]
				RHP->(MSUNLOCK())
				AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ, TRB->VALORFICHA, RHP->RHP_VLRFUN,"Dependente Atualizado com sucesso"})
			Else
				RecLock("RHP",.T.)
				RHP->RHP_FILIAL	:= TRB->RD_FILIAL
				RHP->RHP_MAT	:= TRB->RD_MAT
				RHP->RHP_DTOCOR := LASTDAY(STOD(TRB->RD_DATARQ+'01')) //SToD(AnoMes(TRB->RD_DATARQ)+LAST_DAY(STOD(TRB->RD_DATARQ))
				RHP->RHP_ORIGEM := '2'
				RHP->RHP_TPFORN := (cDEPTMP)->TPFORN
				RHP->RHP_CODFOR := (cDEPTMP)->CODFOR
				RHP->RHP_CODIGO	:= (cDEPTMP)->CODIGO
				RHP->RHP_TPLAN  := '1'
				RHP->RHP_PD		:= TRB->RD_PD
				RHP->RHP_VLRFUN := nNewVL[ncont]
				RHP->RHP_COMPPG	:= TRB->RD_DATARQ
				RHP->RHP_VLREMP := 0
				RHP->RHP_OBSERV := "GERADO PELA ROTINA DE AJUSTE"
				RHP->RHP_DATPGT := TRB->RD_DATPGT
				RHP->(msUnlock())
				AAdd(aLogarray,{TRB->RD_PD, TRB->RD_FILIAL,TRB->RD_MAT,TRB->RD_DATARQ,TRB->VALORFICHA, RHP->RHP_VLRFUN,"Dependente cadastrado com sucesso"})
			EndIf
			(cDEPTMP)->(dbskip())
		end
		(cDEPTMP)->(dbCloseArea())
		cad_titular(nNewVL[1])
	endif

	If Select(cDEPTMP) > 0
		(cDEPTMP)->(dbCloseArea())
	EndIf

	RestArea(aArea)
Return


Static Function GrvLog(aLog)

	Local oFWExcel
	Local oExcel
	Local nAux 			:= 0
	Local cArquivo		:= GetTempPath()+'LogRHP_'+TRB->RD_PD + '_'+DTOS(dDatabase) + '.xml'
	Local cWorkSheet	:= "Aba Verba " + TRB->RD_PD
	Local cTable		:= "Log acerto RHP " + TRB->RD_PD
	Local aColunas		:= {}
	Local aLinhaAux		:= {}

	aAdd(aColunas, 'Verba'     )
	aAdd(aColunas, 'Empresa'   )
	aAdd(aColunas, 'Matricula' )
	aAdd(aColunas, 'Periodo'   )
	aAdd(aColunas, 'Valor Ficha'    )
	aAdd(aColunas, 'Valor Rateio'    )
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
	ShellExecute("open",'LogRHP_'+TRB->RD_PD + '_'+DTOS(dDatabase) + '.xml',"",GetTempPath(),1)

	/*oExcel := MsExcel():New() 			//Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo) 	//Abre uma planilha
	oExcel:SetVisible(.T.) 				//Visualiza a planilha
	oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas*/

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
