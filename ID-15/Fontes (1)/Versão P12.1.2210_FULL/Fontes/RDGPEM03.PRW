

#Include "TOPCONN.Ch"
#Include "TOTVS.CH"
#Include "RWMAKE.ch"
#include "tbiconn.ch"
#include "protheus.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} RDGPEM03
    (long_description)
    @type  Function
    @since 19/09/2020
    @Thiago Pereira
/*/
User Function RDGPEM03()

	Local aArea   	:= GetArea()
	Local cTitulo   := 'ROTINA SUCESSOR'
	Local mAviso    := "Essa rotina irá realizar alterações IRREVERSIVEIS na Ficha Financeira, DESEJEA CONTINUAR????"

	Private lGo     := .T.
	Private pDtDe
	Private pDtAte
	Private pMat
	Private oTable
	Private cTblName
	Private aLogarray := {}
	Private aSRD     := {}
	Private pNewVB   := 'Z99,Z98' //GetMV("MV_NEWVB", .T., "XXX")
	Private cVerbas

//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' 

	DBSELECTAREA("SRD")
	DBSELECTAREA("RHP")
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
		IF MsgYesNo(mAviso)
			IF MsgYesNo("TEM CERTEZA?")
				Processa({|| FazUpdate()}    , "Fazendo Atualizacao dos valores...")
			ELSE
				LGO := .F.
			ENDIF
		else
			lGo := .F.
		ENDIF
	endif
	IF lGo
		Processa({|| FazLog()}       , "GErando Aquivo de Log ...")
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



	aAdd(aParamBox,{1,"Dt Pagamento De:  " 	,(ddataBase),""	,""	,""	 ,"",50	,.T.}) // Tipo data
	aAdd(aParamBox,{1,"Dt Pagamento Até: " 	,(ddataBase),""	,""				,""	 ,"",50	,.T.}) // Tipo data
	//aAdd(aParamBox,{1,"Matricula : "			,Space(6)		,""	,""	,""	 ,"",50	,.T.})

	If ParamBox(aParamBox,"Filtros Atualizacao SUESSOR",@aRet)
		pDtDe			:= aRet[1]
		pDtAte          := aRet[2]
		//pMat            := aRet[3]

	ELSE
		lGO := .F.// APERTOU O BOTAO DE CANCELAR.
	Endif



Return

Static Function SelReg()

	Local aArea   	:= GetArea()

	Local nPosIni	:=	1
	Local i
	Local cxQry := ""
	Local _aCamposAlias := {}

// Instancio o objeto
	oTable  := FwTemporaryTable():New('TRB')


// Crio com array com os campos da tabela

	aAdd(_aCamposAlias, { "RHS_FILIAL"		, TamSX3("RHS_FILIAL")[3]   , TamSX3("RHS_FILIAL")[1]	, TamSX3("RHS_FILIAL")[2]})
	aAdd(_aCamposAlias, { "RHS_DATPGT"	, TamSX3("RHS_DATPGT")[3]   , TamSX3("RHS_DATPGT")[1]	, TamSX3("RHS_DATPGT")[2]})
	aAdd(_aCamposAlias, { "RHS_MAT"		, TamSX3("RHS_MAT")[3]	    , TamSX3("RHS_MAT")[1]		, TamSX3("RHS_MAT")[2]})
	aAdd(_aCamposAlias, { "RHS_PD"		, TamSX3("RHS_PD")[3]     	, TamSX3("RHS_PD")[1]		, TamSX3("RHS_PD")[2]})
	aAdd(_aCamposAlias, { "RHS_CODFOR" 	, TamSX3("RHS_CODFOR")[3]	, TamSX3("RHS_CODFOR")[1]	, TamSX3("RHS_CODFOR")[2]})
	aAdd(_aCamposAlias, { "RHS_PLANO" 	, TamSX3("RHS_PLANO")[3]	, TamSX3("RHS_PLANO")[1]	, TamSX3("RHS_PLANO")[2]})
	aAdd(_aCamposAlias, { "RHS_TPPLAN" 	, TamSX3("RHS_TPPLAN")[3]	, TamSX3("RHS_TPPLAN")[1]	, TamSX3("RHS_TPPLAN")[2]})
	aAdd(_aCamposAlias, { "RHS_COMPPG" 	, TamSX3("RHS_COMPPG")[3]	, TamSX3("RHS_COMPPG")[1]	, TamSX3("RHS_COMPPG")[2]})
	aAdd(_aCamposAlias, { "RHS_ORIGEM" 	, TamSX3("RHS_ORIGEM")[3] 	, TamSX3("RHS_ORIGEM")[1]	, TamSX3("RHS_ORIGEM")[2]})
	aAdd(_aCamposAlias, { "RHS_TPFORN" 	, TamSX3("RHS_TPFORN")[3] 	, TamSX3("RHS_TPFORN")[1]	, TamSX3("RHS_TPFORN")[2]})
	aAdd(_aCamposAlias, { "RECNO" 		, 'N' 						, 18							, 0})

// Adiciono os campos na tabela
	oTable:SetFields(_aCamposAlias)

// Crio a tabela no banco de dados
	oTable:Create()

	cFields := ''

// Busco todos os campos da tabela temporária e preencho numa variável
	For nI := 1 To Len(_aCamposAlias)

		cFields += _aCamposAlias[nI,1] + ','

	Next nI

	cFields := Left(cFields, Len(cFields) -1)

	For	i:=	1	To	Len(AllTrim(pNewVB))                  //17,22,23

		If	SubStr(pNewVB,i,1) ==	","

			If	Empty(cVerbas)
				cVerbas	:=	"'"+AllTrim(SubStr(pNewVB,nPosIni,i-1))+"'"
			Else
				cVerbas	+=	",'"+AllTrim(SubStr(pNewVB,nPosIni,i-nPosIni))+"'"
			Endif

			nPosIni :=	i+1

		ElseIf	i	==	Len(AllTrim(pNewVB))

			If	Empty(cVerbas)
				cVerbas	:=	"'"+AllTrim(SubStr(pNewVB,nPosIni,i))+"'"
			Else
				cVerbas	+=	",'"+AllTrim(SubStr(pNewVB,nPosIni,i))+"'"
			Endif

		EndIf

	Next

	if lGo
		//cxQry := "INSERT INTO " + oTable:GetRealName()
		//cxQry += " (" + cFields + ") "

		cxQry := "SELECT 				 		 " +ENTER
		cxQry += " RHS_FILIAL,  RHS_DATPGT, RHS_MAT,  RHS_PD, RHS_CODFOR, RHS_PLANO, RHS_TPPLAN, RHS_COMPPG, RHS_ORIGEM, RHS_TPFORN, R_E_C_N_O_ AS RECNO " + ENTER
		cxQry += "  "
		cxQry += " from " + RetSqlName("RHS")  								+  "    "   + ENTER
		cxQry += "  WHERE    			"   											+ ENTER
		cxQry += "           D_E_L_E_T_ = ' '		"   								+ ENTER
		cxQry += "  AND  RHS_FILIAL in ('01F30001', '01310076', '01310055') " 			+ ENTER
		cxQry += "  AND  RHS_TPFORN = '2' " 											+ ENTER
		cxQry += "  AND  RHS_CODFOR = '007' " 											+ ENTER
		cxQry += "  AND  RHS_PLANO = '16' " 			 								+ ENTER
		cxQry += "  AND  RHS_PD IN ('634','635') " 										+ ENTER
		//cxQry += "  AND  RHS_MAT = '" + pMat + "'" + ENTER
		cxQry += "	AND  substr(RHS_DATPGT,1,6) BETWEEN '" + AnoMes(pDtDe)  +	"'"			+ ENTER
		cxQry += "	             	    AND '" + AnoMes(pDtAte) +		"'"					+ ENTER
		cxQry += "ORDER BY RHS_FILIAL, RHS_MAT, RHS_COMPPG, RHS_PD, RHS_DATPGT,  RHS_CODFOR, RHS_PLANO, RHS_TPPLAN,  RHS_ORIGEM, RHS_TPFORN 		    "	+ENTER

		// Executo o comando SQL
//	 msgalert(cxQry)
		SQLToTrb(cxQry, _aCamposAlias, "TRB")

	EndIf
	oTable:Delete()
Return


Static Function FazUpdate()

	Local cQuery := ""
	Local lresto := .F.
	lOCAL _XREGS := 0
	Local UPSRD := GetNextAlias()
	Local cxFilial := ''
	Local cxMat := ''
	Local cxData := ''
	Local cxVerba :=''

	ASRD := {}

	dbselectarea("TRB")
	TRB->( DbGoTop() )

	DO WHILE !TRB->(EOF())//  !ZZ3->(EOF())
		_XREGS ++
		DBSELECTAREA("TRB")
		TRB->(DBSKIP())

	ENDDO

	MSGALERT("Numero de registros que serão alterados: " + STR(_XREGS))

	dbselectarea("TRB")
	TRB->( DbGoTop() )
	DO WHILE !TRB->(EOF())//  !ZZ3->(EOF())
		dbselectArea("SRD")
		DBSETORDER(15)
		DBGOTOP()
		IF DBSEEK(TRB->RHS_FILIAL+ TRB->RHS_MAT + TRB->RHS_COMPPG + TRB->RHS_PD)
			cxFilial := TRB->RHS_FILIAL
			cxMat := TRB->RHS_MAT
			cxData := TRB->RHS_COMPPG
			cxVerba := TRB->RHS_PD
			DO while !SRD->(EOF()) .AND. (TRB->RHS_FILIAL+ TRB->RHS_MAT + TRB->RHS_COMPPG + TRB->RHS_PD ==	SRD->RD_FILIAL+ SRD->RD_MAT + SRD->RD_DATARQ + SRD->RD_PD  )
				RECLOCK("SRD",.F.)
				SRD->RD_PD := 'Z99'
				SRD->(MSUNLOCK('SRD'))
				AADD(ASRD, {  TRB->RHS_FILIAL+';'+TRB->RHS_MAT+';'+TRB->RHS_PD +';'+ TRB->RHS_TPFORN+';'+ TRB->RHS_CODFOR+';'+TRB->RHS_PLANO+';'+ DTOC(TRB->RHS_DATPGT)+';'+TRB->RHS_COMPPG+	';'+ "UPDATE OK PARA NOVA VERBA Z99.EXECUTADO COM SUCESSO"})
				fCopia('SRD')
				AADD(ASRD, {  TRB->RHS_FILIAL+';'+TRB->RHS_MAT+';'+TRB->RHS_PD +';'+ TRB->RHS_TPFORN+';'+ TRB->RHS_CODFOR+';'+TRB->RHS_PLANO+';'+ DTOC(TRB->RHS_DATPGT)+';'+TRB->RHS_COMPPG+	';'+ "COPIA DO REGISTRO PARA FINS DE HISTÓRICO COM VERBA Z98. EXECUTADO COM SUCESSO"})
				SRD->(DBSKIP())
			enddo
			DBSELECTAREA("RHS")
			//DO while !TRB->(EOF()) .AND. (TRB->RHS_FILIAL+ TRB->RHS_MAT + TRB->RHS_COMPPG + TRB->RHS_PD == cxFilial+ cxMat +cxData  + cxVerba  )
			DBGOTO(TRB->RECNO)
			RecLock('RHS', .F.)
			RHS->(dbDelete())
			RHS->RHS_XOBSER := 'SUESSOR'
			RHS->(MsUnLock())
			RecLock('RHS', .F.)
			RHS->(dbDelete())
			RHS->(MsUnLock())
			AADD(ASRD, {  TRB->RHS_FILIAL+';'+TRB->RHS_MAT+';'+TRB->RHS_PD +';'+ TRB->RHS_TPFORN+';'+ TRB->RHS_CODFOR+';'+TRB->RHS_PLANO+';'+ DTOC(TRB->RHS_DATPGT)+';'+TRB->RHS_COMPPG+	';'+ "DELETE DO REGSITRO NA RHS. EXECUTADO COM SUCESSO"})
			TRB->(DBSKIP())
			//EndDo
		ELSE
			AADD(ASRD, { TRB->RHS_FILIAL+';'+TRB->RHS_MAT+';'+TRB->RHS_PD +';'+ TRB->RHS_TPFORN+';'+ TRB->RHS_CODFOR+';'+TRB->RHS_PLANO+';'+ DTOC(TRB->RHS_DATPGT)+';'+TRB->RHS_COMPPG+	';'+ "REGISTRO NAO ENCONTRADO NA FICHA FINANCEIRA "})
			TRB->(DBSKIP())
		ENDIF

	ENDDO

	//IF 	TRB->RHS_TPFORN == '2' 		.AND. ;
		//	TRB->RHS_CODFOR == '007' 	.AND. ;
		//	TRB->RHS_PLANO == '16'   	.AND. ;
		//	( TRB->RHS_PD == '634' .OR. TRB->RHS_PD == '635' )
	//	// PROCURA NA SRD PARA FAZER A ALTERAÇÃO
	//		cQuery := "SELECT RD_FILIAL, RD_PD, RD_MAT, RD_DATARQ, RD_DATPGT  " +ENTER
	//		cQuery += "FROM " + RetSqlName("SRD")  + " " +ENTER
	//		cQuery += "WHERE  RD_FILIAL =  '" + TRB->RHS_FILIAL + "' " +ENTER
	//		CQUERY += " AND   RD_MAT     = '" + TRB->RHS_MAT + "' " +ENTER
	//	//		CQUERY += " AND   RD_DATPGT  = '" + DTOS(TRB->RHS_DATPGT) + "' " +ENTER
	//		CQUERY += " AND   RD_DATARQ = '" + TRB->RHS_COMPPG + "' " +ENTER
	//		CQUERY += " AND   RD_PD      = '" + TRB->RHS_PD + "' " + ENTER
	//		CQUERY += " AND   D_E_L_E_T_ = ' ' " +ENTER
	//
	//		If Select("UPSRD") > 0
	//			dbSelectArea("UPSRD")
	//			dbCloseArea()
	//		EndIf
	//
	//		TcQuery cQuery New Alias "UPSRD"
	//
	//		TCSetField("UPSRD","RD_DATPGT","D")
	//
	//		DbSelectArea("UPSRD")
	//		DBGOTOP()
	//		WHILE !UPSRD->(Eof())
	//	cQryUP := ""
	//	cQryUP += " UPDATE " + RETSQLNAME("SRD")				+ ENTER
	//	CQRYUP += " SET RD_PD = '" + 'Z98' + "' " 				+ ENTER
	//	CQRYUP += " WHERE "										+ ENTER
	//	CQRYUP += " 	  D_E_L_E_T_ = ' ' " 					+ ENTER
	//	CQRYUP += " AND   RD_FILIAL =  '" + UPSRD->RD_FILIAL 	+ "' " + ENTER
	//	CQRYUP += " AND   RD_MAT     = '" + UPSRD->RD_NAT 		+ "' " + ENTER
	//	CQRYUP += " AND   RD_DATARQ = '" + UPSRD->RD_DATARQ 	+ "' " + ENTER
	//	CQRYUP += " AND   RD_PD      = '" + UPSRD->RD_PD 		+ "' " + ENTER
	//	nXRet = TCSQLEXEC(CQRYUP)
	//IF NXRET == 0


//		DBSELECTAREA("TRB")    
//		TRB->(DBSKIP())

//	ENDDO



Return


Static Function fCopia(cTabelaAux)
	Local aArea     := GetArea()
	Local aEstru    := {}
	Local aConteu   := {}
	Local nPosFil   := 0
	Local cCampoFil := ""
	Local cQryAux   := ""
	Local nAtual    := 0

	DbSelectArea(cTabelaAux)

	//Pega a estrutura da tabela
	aEstru := (cTabelaAux)->(DbStruct())

	//Encontra o campo filial
	nPosFil   := aScan(aEstru, {|x| "RD_PD" $ AllTrim(Upper(x[1]))})
	cCampoFil := aEstru[nPosFil][1]


	For nAtual := 1 To Len(aEstru)
		//Se for campo filial
		If Alltrim(aEstru[nAtual][1]) == Alltrim(cCampoFil)
			aAdd(aConteu, 'Z98')
			//Se não, adiciona
		Else
			aAdd(aConteu, &(cTabelaAux+"->"+aEstru[nAtual][1]))
		EndIf
	Next

	//Faz um RecLock
	RecLock(cTabelaAux, .T.)
	//Percorre a estrutura
	For nAtual := 1 To Len(aEstru)
		//Grava o novo valor
		&(aEstru[nAtual][1]) := aConteu[nAtual]
	Next
	(cTabelaAux)->(MsUnlock())


	RestArea(aArea)
Return




STATIC FUNCTION FAZLOG()

// GeraTXT(aErros,caminho,cnome)
	Local cArq,cInd
	Local cString := "TRBXXX"
	Local aStru := {}
	Local nTamLin, cLin, cCpo
	Local ii := 0
	Private oGeraTxt
	Private cArqTxt := "C:\TEMP\"  + dtos(ddatabase) + "-" + strtran(substr(time(),1,8),":") + "_" + "UPDATESRD.csv"
	Private nHdl    := fCreate(cArqTxt,0)
	Private cEOL    //:= "CHR(13)+CHR(10)"

	_xcaminho := "C:\TEMP_PROTHEUS"

	IF !EXISTDIR(ALLTRIM(_XCAMINHO))
		MAKEDIR ( _XCAMINHO )
	endif


	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif


	cLin := 'ACERTO SUESSOR' + ENTER
	cLin += "FILIAL;MATRICULA;VERBA;TP FORN;FORNECE;PLANO;DT PGTO;COMPETENCIA;Status"+ ENTER
	FWrite(nHdl,cLin,nHdl)
	For ii:= 1 to len(aSRD)
		cLin := aSRD[ii][1] + ENTER
		FWrite(nHdl,cLin,nHdl)

	NEXT II

	fClose(nHdl)

	Aviso( 'INFO', 'O Relatorio de SUESSOR está finalizado,' +;
		' seu excel será aberto.', { 'Fechar' } )

	Shellexecute( "Open", cArqTxt , " /k dir ", "c:\", 1 )

RETURN


