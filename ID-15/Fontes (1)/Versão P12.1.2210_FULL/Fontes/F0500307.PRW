#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} F0500307
Web Service referente as solicitações para aprovação e reprovação
@type function
@author henrique.toyada
@since 26/10/2016
@project MAN00000463301_EF_003
/*/
User Function F0500307()

Return

//===========================================================================================================

WSSTRUCT AcompaSol
	WSDATA Codigo     As String
	WSDATA SolData    As String
	WSDATA CodSoli    AS String
	WSDATA TpSolic    As String
	WSDATA Status     As String
	WSDATA Solicita   As String
	WSDATA Visao      As String
	WSDATA Matric     As String
	WSDATA FilRh3     AS String
	WSDATA DesFilRh3  AS String
	WSDATA DesSubSt   AS String
	WSDATA DesCentCus AS String
ENDWSSTRUCT

WSSTRUCT _AcompaSol
	WSDATA Acompanha  As ARRAY OF AcompaSol
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT _retdados
	WSDATA FilSoli AS STRING
	WSDATA DescFil AS STRING
	WSDATA FilIniS AS STRING
	WSDATA DescFlS AS STRING
	WSDATA MatrFlS AS STRING
	WSDATA NomeFlS AS STRING
	WSDATA DescCar AS STRING
	WSDATA DescCtt AS STRING
	WSDATA FilSltd AS STRING
	WSDATA DecSltd AS STRING
	WSDATA MatSltd AS STRING
	WSDATA NomSltd AS STRING
	WSDATA CarSltd AS STRING
EndWSSTRUCT
//===========================================================================================================
WSSTRUCT InfFer
	WSDATA R8FILIAL  As String
	WSDATA R8MAT     As String
	WSDATA TMPNOME   As String
	WSDATA R8DATAINI As String
	WSDATA R8DATAFIM As String
	WSDATA R8DURACAO As String
	WSDATA TMPABONO  As String
	WSDATA TMP1P13SL As String
	WSDATA OBS       As String
	WSDATA StatusS   AS String
ENDWSSTRUCT

WSSTRUCT _InfFer
	WSDATA Registro  As ARRAY OF InfFer
ENDWSSTRUCT

//===========================================================================================================

WSSTRUCT InfHis
	WSDATA PAENOMEAP  As String
	WSDATA PAEFUNAPR  As String
	WSDATA PAEDCCAPR  As String
	WSDATA PAEOBS     As String
	WSDATA lRet       As Boolean
ENDWSSTRUCT

WSSTRUCT _InfHis
	WSDATA Registro  As ARRAY OF InfHis
ENDWSSTRUCT

//===========================================================================================================
WSSTRUCT Infh4
	WSDATA PA5FILIAL   As String
	WSDATA PA5CDVAGA   As String
	WSDATA PA5VLVAGA   As String
	WSDATA PA5SLFECH   As String
	WSDATA PA5CDCAND   As String
	WSDATA PA5NMCAND   As String
	WSDATA PA5CPFCAN   As String
	WSDATA PA5DTAPRV   As String
	WSDATA PA5LOGTOR   As String
	WSDATA TMPNMVAGA   As String
	WSDATA TMPNOMTOR   As String
	WSDATA PA2FILCAN   AS String
	WSDATA PA2STSVAG   AS String
	WSDATA PA2DESFIL   AS String
	WSDATA PA2CARGO    AS String
	WSDATA PA2DESCAR   AS String
	WSDATA PA2TURNO    AS String
	WSDATA PA2DESCTU   AS String
	WSDATA PA2DEPART   AS String
	WSDATA PA2DESDEP   AS String
	WSDATA PA2CC       AS String
	WSDATA PA2DESCC    AS String
	WSDATA PA2HRMES    AS String
	WSDATA PA2SALHR    AS String
	WSDATA PA2DTADMI   AS String
	WSDATA TMPFILVAGA  AS String  //Filial da vaga
	WSDATA TMPDESCVG   AS String   // descrição da filial
	WSDATA TMPTIPOFAP  AS String  // tipo da fap
	WSDATA TMPCARGOVG  AS String  //cargo vaga
	WSDATA TMPDSCCGVG  AS String  // descrição cargo vaga
	WSDATA TMPCCVAGA   AS String //cc vaga
	WSDATA TMPDSCVAGA  AS String // descrição cc vaga
	WSDATA TMPDPTVAGA  AS String // departamento
	WSDATA TMPDSCDVAGA AS String // descrição do departamento
	WSDATA TMPMATCOLA  AS String // Matricula colaborador
	WSDATA TMPNOMECOLA AS String // nome colaborador
	WSDATA TMPSALARIO  AS String // Salario
ENDWSSTRUCT

WSSTRUCT _Infh4
	WSDATA Registro  As ARRAY OF Infh4
ENDWSSTRUCT

//===========================================================================================================

WSSTRUCT SolDes
	WSDATA P10FILIAL  As String
	WSDATA P10MATRIC  As String
	WSDATA TMPMATRIC  As String
	WSDATA P10DTSOLI  As String
	WSDATA P10CODRES  As String
	WSDATA TMPDESRES  As String
	WSDATA P10MOTIVO  As String
	WSDATA P10DTDEMI  AS String
	WSDATA SUBGRPALC  AS String
	WSDATA NVUSUARIO  AS String
ENDWSSTRUCT

WSSTRUCT _SolDes
	WSDATA Registro  As ARRAY OF SolDes
ENDWSSTRUCT

//===========================================================================================================

WSSTRUCT SlCarSal
	WSDATA TMPFUNCAO As String //Codigo da Função Atual
	WSDATA TMPD_FUNC As String //Nome da Função Atual
	WSDATA TMPSALATU As String //Salário Atual
	WSDATA TMPTABELA As String //Códio da Tabela Atual
	WSDATA TMPNIVELT As String //Nivel da Tabela Atual
	WSDATA TMPFAIXAT As String //Faixa Atual
	WSDATA RASALARIO As String //Salário Proposto
	WSDATA RATIPOALT As String //Motivo da Alteração Salarial
	WSDATA TMPD_MOT  As String //Descrição do  Motivo
	WSDATA TMPVLSALA As String //Valor do aumento proposto
	WSDATA TMPPERCSA As String //Percentual do Aumento Proposto
	WSDATA RACODFUNC As String //Codigo da Função Proposta
	WSDATA TMPD_F_PP As String //Nome da Função Proposta
	WSDATA TMPH_M_AT As String //Horas Mês Atual
	WSDATA TMPH_S_AT As String //Horas Semana Atual
	WSDATA TMPH_D_AT As String //Horas Dia Atual
	WSDATA RAHRSMES  As String //Horas Mês Proposto
	WSDATA RAHRSEMAN As String //Horas Semana Proposto
	WSDATA RAHRSDIA  As String //Horas Dia Proposto
	WSDATA TMPTURNAT As String //Turno de Trabalho Atual
	WSDATA TMPD_TURN As String //Nome do Turno Atual
	WSDATA TMPS_TURN As String //Seq.Ini.Turno Atual
	WSDATA TMPREGRA  As String //Regra Atual
	WSDATA RATNOTRAB As String //Turno de trabalho Proposto
	WSDATA TMPDESCTU As String //Nome do Turno Proposto
	WSDATA RASEQTURN As String //Seq.Ini. Turno Proposto
	WSDATA RAREGRA   As String //Regra Proposta
	WSDATA TMPFILIAL As String //Filial Atual
	WSDATA TMPD_FILI As String //Nome da Filial Atual
	WSDATA TMPCCATU  As String //Centro de Custo Atual
	WSDATA TMPD_CCAT As String //Descrição do Centro de Custo Atual
	WSDATA TMPDEPTOA As String //Departamento Atual
	WSDATA TMPD_DEPT As String //Nome do Departamento Atual
	WSDATA RAFILIAL  As String //Filial/Empresa proposta
	WSDATA TMPN_F_D  As String //Nome da Filial/Empresa proposta
	WSDATA RACC      As String //Centro de Custo proposto
	WSDATA TMPD_CC_D As String //Descrição do Centro de Custo Proposto
	WSDATA RADEPTO   As String //Departamento Proposto
	WSDATA TMPD_DEPD As String //Nome do Departamento Proposto
	WSDATA TMPTIPO   As String //Tipo da  Solicitação
	WSDATA TMPPROCES As String //Processo Atual
	WSDATA RAPROCES  As String //Processo Proposto
	WSDATA TMPPOSTO  As String //Codigo do posto Atual
	WSDATA RAPOSTO   As String //Proposta do novo Posto
	WSDATA TMPCLVL   As String //Classe Valor Atual
	WSDATA RACLVL    As String //Proposta da nova Classe Valor
	WSDATA TMPITEM   As String //Item contabil atual
	WSDATA RAITEM    As String //Item contábil proposto
	WSDATA TMPOBSINC As String //Observação na inclusão
	WSDATA TMPMETIRO As String //Informa se a Inclusão é por Mérito
ENDWSSTRUCT

WSSTRUCT _SlCarSal
	WSDATA Registro  As ARRAY OF SlCarSal
ENDWSSTRUCT

//===========================================================================================================

WSSTRUCT Treina
	WSDATA CALEND   As String
	WSDATA CURSO    As String
	WSDATA NOME     As String
	WSDATA OBS      As String
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT Funcio
	WSDATA CodMaFun   As String
	WSDATA NomMaFun   As String
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT SuperInf
	WSDATA CodMaSup   As String
	WSDATA FilMaSup   As String
	WSDATA NvlAprov   As String
	WSDATA EmpAprov   As String
	WSDATA Solici     As String
	WSDATA FilSolic   AS String
	WSDATA Obs        As String
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT InfRh3Su
	WSDATA RH3VISAO   AS String
	WSDATA RH3FILINI  AS String
	WSDATA RH3MATINI  AS String
	WSDATA RH3FILAPR  AS String
	WSDATA RH3MATAPR  AS String
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT SupEml
	WSDATA QBMATRESP AS String
	WSDATA RANOME    As String
	WSDATA RAEMAIL   As String
	WSDATA MSGRET    As String
	WSDATA TIPRET    AS Boolean
ENDWSSTRUCT
//===========================================================================================================
WSSERVICE W0500307 DESCRIPTION "WebService Server responsavel pelas rotinas de Solicitações feitas"
	
	WSDATA Matricula   AS String
	WSDATA Filtro      AS String
	WSDATA Campo       AS String
	WSDATA Valor       AS String
	WSDATA FilFun      AS String
	WSDATA CodRh4      AS String
	WSDATA CodRh3      AS String
	WSDATA PA3XCOD     AS String
	WSDATA FILRH3      AS String
	WSDATA DATADESLIG  AS String
	WSDATA lRet        AS Boolean
	WSDATA _Acom       AS _AcompaSol // Informação da RH3
	WSDATA _Func       AS Funcio     // Informação Funcionário
	WSDATA _Inf4       AS Infh4      // Informação da RH4 FAP
	WSDATA _SlCrSl     AS SlCarSal   // Informação da RH4 CARGOS E SALARIOS
	WSDATA _SolDes     AS SolDes     // Informação da RH4 DESLIGAMENTO
	WSDATA _Treina     AS Treina     // Informação sobre o treinamento
	WSDATA _InfRh3     AS InfRh3Su
	WSDATA _SupInfP    AS SupEml
	WSDATA _SuperInf   AS SuperInf
	WSDATA _InfFerr8   AS InfFer
	WSDATA _InfHisR    AS _InfHis
	WSDATA retdados    AS _retdados
	
	WSMETHOD InfRh3    DESCRIPTION "Pega Solicitações da RH3"
	WSMETHOD FunRh3    DESCRIPTION "Pega Informação do funcionario da RH3"
	WSMETHOD InfRh4F   DESCRIPTION "Pega Solicitações da RH4 FAP"
	WSMETHOD InfRh4D   DESCRIPTION "Pega Solicitações da RH4 DESLIGAMENTO"
	WSMETHOD InfRh4C   DESCRIPTION "Pega Solicitações da RH4 CARGOS E SALARIOS"
	WSMETHOD InfRh4I   DESCRIPTION "Pega codigo da tabela PA3"
	WSMETHOD InfRh4Fe  DESCRIPTION "Visualização de ferias"
	WSMETHOD BuscaTrm  DESCRIPTION "Informação do treinamento"
	WSMETHOD ChkRh3    DESCRIPTION "Verifica status da solicitação"
	WSMETHOD InfSolVg  DESCRIPTION "Informações da RH3"
	WSMETHOD InfPegSup DESCRIPTION "Pega informação do superior"
	WSMETHOD ValAprSol DESCRIPTION "Valida se solicitação foi aprovada"
	WSMETHOD BuscObser DESCRIPTION "Busca observações da solicitação"
	WSMETHOD ValSesmt  DESCRIPTION "Valida se o aprovador atual é sesmt"
	WSMETHOD GrvDtDlg  DESCRIPTION "Atualizar a data de desligamento"
	WSMETHOD BscDados  DESCRIPTION "Busca os dados do cabeçalho das solicitações"
	
ENDWSSERVICE
//===========================================================================================================
// Metodo que envia o emailpega as informações da RH3
WSMETHOD InfRh3 WSRECEIVE Matricula,Filtro,Campo,Valor,FilFun  WSSEND _Acom WSSERVICE W0500307
	
	Local nCnt	:= 1
	Local aAux := {}
	Local oSolicita
	
	aAux := RetRh3(::Matricula,::Filtro,::Campo,::Valor,::FilFun)
	
	If Len(aAux) > 0
		::_Acom := WSClassNew( "_AcompaSol" )
		
		::_Acom:Acompanha := {}
		oSolicita :=  WSClassNew( "AcompaSol" )
		For nCnt := 1 To Len(aAux)
			oSolicita:Codigo     := aAux[nCnt][1]
			oSolicita:SolData    := aAux[nCnt][2]
			oSolicita:CodSoli    := aAux[nCnt][3]
			oSolicita:TpSolic    := aAux[nCnt][4]
			oSolicita:Status     := aAux[nCnt][5]
			oSolicita:Solicita   := aAux[nCnt][6]
			oSolicita:Visao      := aAux[nCnt][7]
			oSolicita:Matric     := aAux[nCnt][8]
			oSolicita:FilRh3     := aAux[nCnt][9]
			oSolicita:DesFilRh3  := aAux[nCnt][10]
			oSolicita:DesSubSt   := aAux[nCnt][11]
			oSolicita:DesCentCus := aAux[nCnt][12]
			AAdd( ::_Acom:Acompanha, oSolicita )
			oSolicita :=  WSClassNew( "AcompaSol" )
		Next
	Else
		::_Acom := WSClassNew( "_AcompaSol" )
		
		::_Acom:Acompanha := {}
		oSolicita :=  WSClassNew( "AcompaSol" )
		oSolicita:Codigo     := ""
		oSolicita:SolData    := ""
		oSolicita:CodSoli    := ""
		oSolicita:TpSolic    := ""
		oSolicita:Status     := ""
		oSolicita:Solicita   := ""
		oSolicita:Visao      := ""
		oSolicita:Matric     := ""
		oSolicita:FilRh3     := ""
		oSolicita:DesFilRh3  := ""
		oSolicita:DesSubSt   := ""
		oSolicita:DesCentCus := ""
		AAdd( ::_Acom:Acompanha, oSolicita )
	EndIf
Return .T.
//===========================================================================================================
// Metodo que envia o emailpega as informações da RH3
WSMETHOD FunRh3 WSRECEIVE CodRh3,FILRH3 WSSEND _Func WSSERVICE W0500307
	
	Local nCnt	:= 1
	Local aAux := {}
	Local oSolicita
	
	aAux := InfoRh3(::CodRh3,::FILRH3)
	
	If Len(aAux) > 0
		_Func:CodMaFun  := aAux[1]
		_Func:NomMaFun  := aAux[2]
	Else
		_Func:CodMaFun  := ""
		_Func:NomMaFun  := ""
	EndIf
Return .T.
//===========================================================================================================
Static Function InfoRh3(CodRh3,FILRH3)
	Local cQuery 		:= ''
	Local cAliasPa3	:= 'RETPA3'
	Local aAux			:= {}
	
	cQuery := "SELECT RH3_CODIGO,RH3_MAT,RA_NOME, QG_NOME "
	cQuery += "FROM " + RetSqlName("RH3") + " RH3 "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += "ON 	SRA.RA_MAT = RH3.RH3_MAT "
	cQuery += "AND SRA.RA_FILIAL = RH3.RH3_FILIAL "
	cQuery += "	AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("SQG") + " SQG "
	cQuery += "ON 	SQG.QG_CURRIC = RH3.RH3_MAT "
	cQuery += "	AND SQG.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE 	RH3.RH3_CODIGO = '" + CodRh3 + "' "
	cQuery += "		AND RH3.RH3_FILIAL = '" + FILRH3 + "' "
	cQuery += "		AND RH3.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPa3)
	
	DbSelectArea(cAliasPa3)
	While ! (cAliasPa3)->(EOF())
		AADD(aAux, (cAliasPa3)->RH3_MAT)
		AADD(aAux, IIF(EMPTY((cAliasPa3)->RA_NOME),(cAliasPa3)->QG_NOME,(cAliasPa3)->RA_NOME))
		(cAliasPa3)->(DbSkip())
	End
	(cAliasPa3)->(DbCloseArea())
	
Return aAux

//===========================================================================================================
// Metodo que envia o emailpega as informações da RH3
WSMETHOD ChkRh3 WSRECEIVE CodRh3,FILRH3 WSSEND lRet WSSERVICE W0500307
	
	//RH3_FILIAL+RH3_CODIGO
	RH3->(DbSetOrder(1))
	If RH3->(DBSEEK(::FILRH3 + ::CodRh3))
		If RH3->RH3_STATUS = '1'
			::lRet := .T.
		Else
			::lRet := .F.
		EndIf
	Else
		::lRet := .F.
	EndIf
	
Return .T.
//===========================================================================================================
/*{Protheus.doc} RetRh3
(long_description)
@type function
@author henrique.toyada
@since 26/10/2016
@project MAN00000463301_EF_003
*/
Static Function RetRh3(cMatri, cFiltro, cCampo, cValor, cFilSra)
	
	Local cQuery     := ''
	Local cAliasRH3  := 'RETRH3'
	Local cAliRh4    := 'RETRCX'
	Local cCdAlc     := ''
	Local cNivel     := ''
	Local cPosto     := ''
	Local lRet       := .F.
	Local lLoop      := .F.
	Local nCnt       := 1
	Local nCont      := 1
	Local aAux       := {}
	Local nPos       := 0
	Local cFilPost   := ''

	cQuery := "SELECT RH3_MAT, RH3_CODIGO, RH3_DTSOLI, RH3_XTPCTM, PAB_SOLDES, "
	cQuery += " RH3_STATUS, RH3_MATINI, SRA.RA_NOME,"
	cQuery += " RH3_VISAO, RH3_FILIAL, RA_CC, PAB_GRPDES "
	cQuery += "FROM	" + RetSqlName("RH3") + " RH3 "

	cQuery += "INNER JOIN " + RetSqlName("PAL") + " PAL "
	cQuery += "ON (PAL.PAL_FILSOL = RH3.RH3_FILIAL AND PAL.PAL_NUMSOL = RH3.RH3_CODIGO AND PAL.PAL_NIVSOL = RH3.RH3_NVLAPR )" //O Oracle compara númérico com caracter
	
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += "ON (SRA.RA_MAT = RH3.RH3_MATINI AND SRA.RA_FILIAL = RH3.RH3_FILINI AND SRA.D_E_L_E_T_ = ' ' )"

	cQuery += "INNER JOIN " + RetSqlName("PAB") + " PAB ON PAB.PAB_CODIGO = RH3.RH3_XCODAL "
	cQuery += "AND PAB.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE PAL.PAL_MATAPR = "+ cMatri +" "
	cQuery += " AND RH3_STATUS = '1'"
	cQuery += "	AND RH3_TIPO = ' '"
	cQuery += "	AND RH3_XTPCTM != ' '"
	If cFiltro == "2" .AND. !(EMPTY(cCampo))
		cQuery += "	AND " + cCampo + " like '%" + ALLTRIM(UPPER(cValor)) + "%' "
	EndIf
	cQuery += "	AND RH3.D_E_L_E_T_ = ' ' "
	cQuery += "	AND PAL.D_E_L_E_T_ = ' ' "	
	cQuery += "ORDER BY RH3_CODIGO"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRH3)
	
	DbSelectArea(cAliasRH3)
	While ! (cAliasRH3)->(EOF())
		nPos := aScan(aAux,{|x| x[9] + x[1] == (cAliasRH3)->RH3_FILIAL + (cAliasRH3)->RH3_CODIGO })
		If nPos == 0
			If cFiltro == "2" .AND. EMPTY(cCampo) .AND. !(EMPTY(cValor))
				If ALLTRIM(UPPER(cValor)) $ FWFILIALNAME(,(cAliasRH3)->RH3_FILIAL)
					lLoop := .F.
				Else
					lLoop := .T.
				EndIf
			EndIf
			If !lLoop
				AADD(aAux, {(cAliasRH3)->RH3_CODIGO,;
					(cAliasRH3)->RH3_DTSOLI,;
					(cAliasRH3)->RH3_XTPCTM,;
					(cAliasRH3)->PAB_SOLDES,;
					(cAliasRH3)->RH3_STATUS,;
					(cAliasRH3)->RA_NOME,;
					(cAliasRH3)->RH3_VISAO,;
					(cAliasRH3)->RH3_MATINI,;
					(cAliasRH3)->RH3_FILIAL,;
					FWFILIALNAME(,(cAliasRH3)->RH3_FILIAL),;
					(cAliasRH3)->PAB_GRPDES,;
					fDesc("CTT",(cAliasRH3)->RA_CC,"CTT_DESC01") })
				lLoop := .F.
			EndIf
		EndIf
		(cAliasRH3)->(DbSkip())
	End
	(cAliasRH3)->(DbCloseArea())
Return aAux

//===========================================================================================================
// Metodo que envia o email
WSMETHOD InfRh4Fe WSRECEIVE CodRh4,FILRH3 WSSEND _InfFerr8 WSSERVICE W0500307
	
	Local aAuxH4 := {}
	Local nCnt   := 0
	Local oSolicita
	
	aAuxH4 := Rh4Inf(::CodRh4,::FILRH3)
	
	If Len(aAuxH4) > 0
		::_InfFerr8:R8FILIAL  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "R8_FILIAL"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:R8MAT     := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "R8_MAT"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:TMPNOME   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_NOME"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:R8DATAINI := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "R8_DATAINI"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:R8DATAFIM := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "R8_DATAFIM"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:R8DURACAO := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "R8_DURACAO"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:TMPABONO  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_ABONO"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:TMP1P13SL := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_1P13SL"})) = 0,'',aAuxH4[var][2])
		::_InfFerr8:Obs       := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_OBS"})) = 0,'',aAuxH4[var][2])
	Else
		::_InfFerr8:R8FILIAL  := ""
		::_InfFerr8:R8MAT     := ""
		::_InfFerr8:TMPNOME   := ""
		::_InfFerr8:R8DATAINI := ""
		::_InfFerr8:R8DATAFIM := ""
		::_InfFerr8:R8DURACAO := ""
		::_InfFerr8:TMPABONO  := ""
		::_InfFerr8:TMP1P13SL := ""
		::_InfFerr8:Obs       := ""
	EndIf
	
	::_InfFerr8:StatusS := IIF((var := AScan(aAuxH4, {|x, y|  Alltrim(x[1]) == "RH3_STATUS"}))Â = 0, '', aAuxH4[var][2])
	
Return .T.

//===========================================================================================================
// Metodo que envia o email
WSMETHOD InfRh4F WSRECEIVE CodRh4,FILRH3 WSSEND _Inf4 WSSERVICE W0500307
	
	Local aAuxH4 := {}
	Local nCnt   := 0
	Local oSolicita
	
	aAuxH4 := Rh4Inf(::CodRh4,::FILRH3)
	
	If Len(aAuxH4) > 0
		::_Inf4:TMPFILVAGA  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_FILVAG"})) = 0,'',aAuxH4[var][2]) //Filial da vaga
		::_Inf4:PA5FILIAL   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_FILIAL"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5CDVAGA   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CDVAGA"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5VLVAGA   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_VLVAGA"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5SLFECH   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_SLFECH"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5CDCAND   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CDCAND"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5NMCAND   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_NMCAND"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5CPFCAN   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CPFCAN"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5DTAPRV   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DTAPRV"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA5LOGTOR   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_LOGTOR"})) = 0,'',aAuxH4[var][2])
		::_Inf4:TMPNMVAGA   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DSCCGV"})) = 0,'',aAuxH4[var][2])//POSICIONE("SQS",1,::_Inf4:TMPFILVAGA + ::_Inf4:PA5CDVAGA,'QS_DESCRIC')
		::_Inf4:TMPNOMTOR   := POSICIONE("SRA",1,::_Inf4:PA5FILIAL + ::_Inf4:PA5LOGTOR,'RA_NOME')
		::_Inf4:PA2FILCAN   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_FILCAN"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2STSVAG   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_STSVAG"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DESFIL   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DESFIL"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2CARGO    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CARGO" })) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DESCAR   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DESCAR"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2TURNO    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_TURNO" })) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DESCTU   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DESCTU"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DEPART   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DEPART"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DESDEP   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DESDEP"})) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2CC       := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_CC"    })) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DESCC    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DESCC" })) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2HRMES    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_HRMES" })) = 0,'',aAuxH4[var][2])
		::_Inf4:PA2DTADMI   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_DTADMI"})) = 0,'',aAuxH4[var][2])
		::_Inf4:TMPDESCVG   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DESCVG"})) = 0,'',aAuxH4[var][2]) // descrição da filial
		::_Inf4:TMPTIPOFAP  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_TIPOFA"})) = 0,'',aAuxH4[var][2]) // tipo da fap
		::_Inf4:TMPCARGOVG  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_CARGOV"})) = 0,'',aAuxH4[var][2]) //cargo vaga
		::_Inf4:TMPDSCCGVG  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DSCCGV"})) = 0,'',aAuxH4[var][2]) // descrição cargo vaga
		::_Inf4:TMPCCVAGA   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_CCVAGA"})) = 0,'',aAuxH4[var][2]) //cc vaga
		::_Inf4:TMPDSCVAGA  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DSCVAG"})) = 0,'',aAuxH4[var][2]) // descrição cc vaga
		::_Inf4:TMPDPTVAGA  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DPTVAG"})) = 0,'',aAuxH4[var][2]) // departamento
		::_Inf4:TMPDSCDVAGA := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DSCDVA"})) = 0,'',aAuxH4[var][2]) // descrição do departamento
		::_Inf4:TMPMATCOLA  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_MATCOL"})) = 0,'',aAuxH4[var][2]) // Matricula colaborador
		::_Inf4:TMPNOMECOLA := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_NOMECO"})) = 0,'',aAuxH4[var][2]) // nome colaborador
		::_Inf4:PA2SALHR    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "PA2_SALHR" })) = 0,'',aAuxH4[var][2])  // salario hora
		::_Inf4:TMPSALARIO  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_SALFUN"})) = 0,'',aAuxH4[var][2]) // salario
	Else
		::_Inf4:PA5FILIAL   := ""
		::_Inf4:PA5CDVAGA   := ""
		::_Inf4:PA5VLVAGA   := ""
		::_Inf4:PA5SLFECH   := ""
		::_Inf4:PA5CDCAND   := ""
		::_Inf4:PA5NMCAND   := ""
		::_Inf4:PA5CPFCAN   := ""
		::_Inf4:PA5DTAPRV   := ""
		::_Inf4:PA5LOGTOR   := ""
		::_Inf4:TMPNMVAGA   := ""
		::_Inf4:TMPNOMTOR   := ""
		::_Inf4:PA2FILCAN   := ""
		::_Inf4:PA2STSVAG   := ""
		::_Inf4:PA2DESFIL   := ""
		::_Inf4:PA2CARGO    := ""
		::_Inf4:PA2DESCAR   := ""
		::_Inf4:PA2TURNO    := ""
		::_Inf4:PA2DESCTU   := ""
		::_Inf4:PA2DEPART   := ""
		::_Inf4:PA2DESDEP   := ""
		::_Inf4:PA2CC       := ""
		::_Inf4:PA2DESCC    := ""
		::_Inf4:PA2HRMES    := ""
		::_Inf4:PA2SALHR    := ""
		::_Inf4:PA2DTADMI   := ""
		::_Inf4:TMPFILVAGA  := ""
		::_Inf4:TMPDESCVG   := ""
		::_Inf4:TMPTIPOFAP  := ""
		::_Inf4:TMPCARGOVG  := ""
		::_Inf4:TMPDSCCGVG  := ""
		::_Inf4:TMPCCVAGA   := ""
		::_Inf4:TMPDSCVAGA  := ""
		::_Inf4:TMPDPTVAGA  := ""
		::_Inf4:TMPDSCDVAGA := ""
		::_Inf4:TMPMATCOLA  := ""
		::_Inf4:TMPNOMECOLA := ""
		::_Inf4:TMPSALARIO  := ""
	EndIf
	
Return .T.
//===========================================================================================================
// Metodo que envia o email
WSMETHOD InfRh4I WSRECEIVE CodRh4,FILRH3 WSSEND PA3XCOD WSSERVICE W0500307
	
	Local aAuxH4 := {}
	Local nCnt   := 0
	Local oSolicita
	
	aAuxH4 := Rh4Inf(::CodRh4,::FILRH3)
	
	If Len(aAuxH4) > 0
		::PA3XCOD  := ALLTRIM(aAuxH4[2][2])
	Else
		::PA3XCOD  := ""
	EndIf
	
Return .T.
//===========================================================================================================
// Metodo que envia o email
WSMETHOD InfRh4D WSRECEIVE CodRh4,FILRH3 WSSEND _SolDes WSSERVICE W0500307
	
	Local aAuxH4 := {}
	Local nCnt   := 0
	Local oSolicita
	
	aAuxH4 := Rh4Inf(::CodRh4,::FILRH3)
	aInfRs := BscTpFR(::FILRH3,::CodRh4)
	
	If Len(aAuxH4) > 0
		::_SolDes:P10FILIAL  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_FILIAL"})) = 0,'',aAuxH4[var][2])
		::_SolDes:P10MATRIC  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_MATRIC"})) = 0,'',aAuxH4[var][2])
		::_SolDes:P10DTSOLI  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_DTSOLI"})) = 0,'',aAuxH4[var][2])
		::_SolDes:P10CODRES  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_CODRES"})) = 0,'',aAuxH4[var][2])
		::_SolDes:TMPDESRES  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_DESRES"})) = 0,'',aAuxH4[var][2])
		::_SolDes:P10MOTIVO  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_MOTIVO"})) = 0,'',aAuxH4[var][2])
		::_SolDes:P10DTDEMI  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "P10_DTDEMI"})) = 0,'',aAuxH4[var][2])
		//::_SolDes:TMPMATRIC  := POSICIONE("SRA",1,::FILRH3 + ::_SolDes:P10MATRIC,'RA_NOME')
		::_SolDes:TMPMATRIC  := POSICIONE("SRA",1,FILRH3 + allTrim(aAuxH4[2,2]),'RA_NOME')
		If Len(aInfRs) > 0
			::_SolDes:SUBGRPALC := IIF(Empty(aInfRs[1]),"",aInfRs[1])
			::_SolDes:NVUSUARIO := IIF(Empty(aInfRs[2]),"",aInfRs[2])
		EndIf
	Else
		::_SolDes:P10FILIAL  := ""
		::_SolDes:P10MATRIC  := ""
		::_SolDes:P10DTSOLI  := ""
		::_SolDes:P10CODRES  := ""
		::_SolDes:TMPDESRES  := ""
		::_SolDes:P10MOTIVO  := ""
		::_SolDes:P10DTDEMI  := ""
		::_SolDes:TMPMATRIC  := ""
		::_SolDes:SUBGRPALC  := ""
		::_SolDes:NVUSUARIO  := ""
	EndIf
	
Return .T.
//===========================================================================================================
// Metodo que envia o email
WSMETHOD InfRh4C WSRECEIVE CodRh4,FILRH3 WSSEND _SlCrSl WSSERVICE W0500307
	
	Local aAuxH4 := {}
	Local aAux   := {}
	Local nCnt   := 0
	Local nPos   := 0
	Local var    := 0
	Local cTipo  := ""
	Local oSolicita
	
	aAuxH4 := Rh4Inf(::CodRh4,::FILRH3)
	aAux   := Rh4InfR(::CodRh4,::FILRH3)
	
	If Len(aAuxH4) > 0
		::_SlCrSl:TMPFUNCAO := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_FUNCAO"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_FUNC := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_FUNC"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPSALATU := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_SALATU"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPTABELA := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_TABELA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPNIVELT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_NIVELT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPFAIXAT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_FAIXAT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RASALARIO := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_SALARIO"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RATIPOALT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_TIPOALT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_MOT  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_MOT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPVLSALA := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_VLSALA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPPERCSA := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_PERCSA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RACODFUNC := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_CODFUNC"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_F_PP := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_F_PP"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPH_M_AT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_H_M_AT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPH_S_AT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_H_S_AT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPH_D_AT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_H_D_AT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAHRSMES  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_HRSMES"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAHRSEMAN := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_HRSEMAN"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAHRSDIA  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_HRSDIA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPTURNAT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_TURNAT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_TURN := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_TURN"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPS_TURN := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_S_TURN"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPREGRA  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_REGRA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RATNOTRAB := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_TNOTRAB"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPDESCTU := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DESCTU"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RASEQTURN := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_SEQTURN"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAREGRA   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_REGRA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPFILIAL := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_FILIAL"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_FILI := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_FILI"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPCCATU  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_CCATU"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_CCAT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_CCAT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPDEPTOA := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_DEPTOA"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_DEPT := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_DEPT"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAFILIAL  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_FILIAL"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPN_F_D  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_N_F_D"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RACC      := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_CC"}) ) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_CC_D := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_CC_D"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RADEPTO   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_DEPTO"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPD_DEPD := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_D_DEPD"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPPROCES := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_PROCES"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAPROCES  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_PROCES"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPPOSTO  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_POSTO"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAPOSTO 	:= IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_POSTO"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPCLVL  	:= IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_CLVL"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RACLVL  	:= IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_CLVL"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPITEM 	:= IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_ITEM"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:RAITEM  	:= IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA_ITEM"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPOBSINC := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_OBSINC"})) = 0,'',aAuxH4[var][2])
		::_SlCrSl:TMPMETIRO := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_ESCL"})) = 0,'',aAuxH4[var][2])

		If EMPTY(::_SlCrSl:TMPD_FILI) .AND. !(EMPTY(::_SlCrSl:TMPFILIAL))
			::_SlCrSl:TMPD_FILI := FWFilialName(,::_SlCrSl:TMPFILIAL)
		EndIf
	EndIf
	
	If Len(aAux) > 0
		For var:= 1 To Len(aAux)
			cTipo += ALLTRIM(aAux[var][2])
		Next
		::_SlCrSl:TMPTIPO   := cTipo
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} Rh4Inf()

@Author     Henrique Madureira
@Since
@Version    P12.7
@project    MAN00000463301_EF_003
@Param      CodSol, Codigo da solicitação
@Return     aAux
*/
Static Function Rh4Inf(CodSol,FILRH3)
	
	Local cQuery 	:= ''
	Local cAliRh4	:= 'RH4INF'
	Local aAux		:= {}
	Local aArea	:= GetArea()

	cQuery := "SELECT RH4_CAMPO, RH4_VALNOV, R_E_C_N_O_ AS RECNO  "
	cQuery += "FROM	" + RetSqlName("RH4") + " "
	cQuery += "WHERE RH4_CODIGO = '" + CodSol + "' "
	cQuery += "		AND RH4_FILIAL = '" + FILRH3 + "' "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH4_ITEM "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)
	
	DbSelectArea(cAliRh4)
	While ! (cAliRh4)->(EOF())
	
		DO CASE
		CASE (cAliRh4)->RH4_CAMPO == "P10_MOTIVO"
			RH4->(DbGoTo((cAliRh4)->RECNO))
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
		CASE ALLTRIM((cAliRh4)->RH4_CAMPO) == "TMP_OBS"
			RH4->(DbGoTo((cAliRh4)->RECNO))
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
		CASE ALLTRIM((cAliRh4)->RH4_CAMPO) == "TMP_OBSINC"
			RH4->(DbGoTo((cAliRh4)->RECNO))
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
		OTHERWISE
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,(cAliRh4)->RH4_VALNOV})
		ENDCASE
		(cAliRh4)->(DbSkip())
	End
	(cAliRh4)->(DbCloseArea())
	
	If Len(aAux) > 0
		cStatus := Posicione("RH3",1,FILRH3+CodSol,"RH3_STATUS")
		AADD(aAux, {"RH3_STATUS",cStatus})
	EndIf
	
	RestArea(aArea)
Return aAux

/*
{Protheus.doc} Rh4InfR()

@Author     Henrique Madureira
@Since
@Version    P12.7
@project    MAN00000463301_EF_003
@Param      CodSol, Codigo da solicitação
@Return     aAux
*/
Static Function Rh4InfR(CodSol,FILRH3)
	
	Local cQuery 	:= ''
	Local cAliRh4	:= 'RH4INFH'
	Local aAux		:= {}
	Local aReg    := {}
	
	cQuery := "SELECT RH4_CAMPO, RH4_VALNOV "
	cQuery += "FROM	" + RetSqlName("RH4") + " "
	cQuery += "WHERE RH4_CODIGO = '" + CodSol + "' "
	cQuery += "		AND RH4_FILIAL = '" + FILRH3 + "' "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)
	
	DbSelectArea(cAliRh4)
	While ! (cAliRh4)->(EOF())
		
		If ! (cAliRh4)->(EOF()) .AND. ALLTRIM((cAliRh4)->RH4_CAMPO) = "TMP_TIPO"
			AADD(aAux, {(cAliRh4)->RH4_CAMPO,(cAliRh4)->RH4_VALNOV})
		EndIf
		(cAliRh4)->(DbSkip())
	End
	//AADD(aReg,aAux)
	(cAliRh4)->(DbCloseArea())
	
Return aAux

//===========================================================================================================
// Metodo que envia o email
WSMETHOD BuscaTrm WSRECEIVE CodRh4,FILRH3 WSSEND _Treina WSSERVICE W0500307
	
	Local aAuxH4 := {}
	Local nCnt   := 0
	Local var := 0
	Local oSolicita
	
	aAuxH4 := Rh4Inf(::CodRh4,::FILRH3)
	
	If Len(aAuxH4) > 0
		For var:= 1 to Len(aAuxH4)
			::_Treina:CALEND  := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA3_CALEND"})) = 0,'',aAuxH4[var][2])
			::_Treina:CURSO   := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "RA3_CURSO"})) = 0,'',aAuxH4[var][2])
			::_Treina:NOME    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_NOME"})) = 0,'',aAuxH4[var][2])
			::_Treina:Obs    := IIF((var := ASCAN(aAuxH4,{|x,y|  Alltrim(x[1]) == "TMP_OBS"})) = 0,'',aAuxH4[var][2])
		Next
		
	EndIf
	
Return .T.
//===========================================================================================================
WsMethod InfSolVg WsReceive CodRh3,FILRH3 WsSend _InfRh3 WsService W0500307
	
	Local aAux := {}
	
	aAux := RetInfRh3(::CodRh3,::FILRH3)
	
	If Len(aAux) > 0
		
		::_InfRh3:RH3VISAO   := Alltrim(aAux[1])
		::_InfRh3:RH3FILINI  := Alltrim(aAux[2])
		::_InfRh3:RH3MATINI  := Alltrim(aAux[3])
		::_InfRh3:RH3FILAPR  := Alltrim(aAux[4])
		::_InfRh3:RH3MATAPR  := Alltrim(aAux[5])
		
	EndIf
	
Return .T.
//===========================================================================================================
Static Function RetInfRh3(cCodSol,FILRH3)
	
	Local cQuery 	:= ''
	Local cAliRh3	:= 'RHPA3INF'
	Local aAux		:= {}
	
	cQuery := "SELECT RH3_VISAO, RH3_FILINI, RH3_MATINI,RH3_FILAPR, RH3_MATAPR "
	cQuery += "FROM	" + RetSqlName("RH3") + " "
	cQuery += "WHERE RH3_CODIGO = '" + cCodSol + "' "
	cQuery += "		AND RH3_FILIAL = '" + FILRH3 + "' "
	cQuery += "		AND D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh3)
	
	DbSelectArea(cAliRh3)
	While !(cAliRh3)->(EOF())
		AADD(aAux, (cAliRh3)->RH3_VISAO)
		AADD(aAux, (cAliRh3)->RH3_FILINI)
		AADD(aAux, (cAliRh3)->RH3_MATINI)
		AADD(aAux, (cAliRh3)->RH3_FILAPR)
		AADD(aAux, (cAliRh3)->RH3_MATAPR)
		(cAliRh3)->(DbSkip())
	End
	(cAliRh3)->(DbCloseArea())
	
Return aAux
//===========================================================================================================
WsMethod InfPegSup WsReceive _SuperInf WsSend _SupInfP WsService W0500307
	
	Local aAux := {}
	
	aAux := PegSuper(Self:_SuperInf)
	
	If Len(aAux) > 0
		::_SupInfP:QBMATRESP := aAux[1]
		::_SupInfP:RANOME    := aAux[2]
		::_SupInfP:RAEMAIL   := aAux[3]
		::_SupInfP:MSGRET    := aAux[4]
		::_SupInfP:TIPRET    := aAux[5]
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} PegSuper()
Pega o superior do funcionario
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cCodMatri, matricula do aprovador
@Param      cSolicit, codigo da solicitação
@Param      cLocal, tipo da solicitação
@Return     aAux
*/
Static Function PegSuper(oSolicVag)
	
	Local aAux      := {}
	Local cMatApr   := ""
	Local cFilApr   := ""
	Local cEmlApr   := ""
	Local lRet		:= .F.
	Local cRet		:= ""
	Local COBSLOG   := ""
	Local aAprov    := {}
	Local cNotif	:= ""
	Local lEfetiv	:= .F.
	Local cFilialS  := ""
	Local cMatric   := ""
	Local cEmails   := ""
	
	cSolicit:= oSolicVag:Solici
	cFilRh3 := oSolicVag:FilSolic
	
	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(cFilRh3 + cSolicit))
		cFilialS:= RH3->RH3_FILIAL
		cNumSol := RH3->RH3_CODIGO
		cTpSol  := RH3->RH3_XTPCTM
		cCodAlc := RH3->RH3_XCODAL
		cPrxApr := RH3->RH3_XPRXNV
		cFilSol := RH3->RH3_FILINI
		cMatSol := RH3->RH3_MATINI
		cFilApr := RH3->RH3_FILAPR
		cMatApr := RH3->RH3_MATAPR
		cMatric := RH3->RH3_MAT
		
		cFilPto := RH3->RH3_XFILPO
		cCdPsto := RH3->RH3_XCODPO	
	EndIf
	
	U_F0801402(cFilialS, cSolicit, oSolicVag:FilMaSup, oSolicVag:CodMaSup, oSolicVag:Obs)
	
	If cPrxApr != "FM"
	
		If cTpSol == "004" //Solicitação FAP
			DbSelectArea("PA2")
			PA2->(DbSetOrder(6)) //PA2_FILIAL+PA2_SOL
			If PA2->(DbSeek(cFilRh3+cSolicit))
				DbSelectArea("SQS")
				SQS->(DbSetOrder(1))
				If SQS->(DbSeek(PA2->(PA2_FILVG+PA2_CDVAGA)))
					cFilSol := SQS->QS_FILRESP
					cMatSol := SQS->QS_MATRESP
				EndIf
			EndIf
		EndIf
		
		If cTpSol == "005" //Desligamento
			DbSelectArea("PAB")
			PAB->(DbSetOrder(1))
			If PAB->(DbSeek(xFilial("PAB")+cCodAlc))
				//Se subgrupos de óbito, pedido de demissão e término de contrato a estrutura da alçada seguirá pelo solicitado
				cSubGrp := PAB->PAB_GRPSOL
				If cSubGrp == "001" .OR. cSubGrp == "002" .OR. cSubGrp == "003"
					cFilSol := cFilialS
					cMatSol := cMatric
				EndIf
			EndIf
			U_F0801402(cFilialS, cSolicit, cFilApr, cMatApr, oSolicVag:Obs)
		EndIf
		
	EndIf
	
	If cPrxApr == "FM"
		aAdd(aAprov,{.T.,;		//Encontrou o aprovador?
					"",;		//Filial Aprovador
					"",; 		//Código Aprovador
					"",;		//Nível do Aprovador
					"FM",;		//Próximo Nível
					"",;		//Código da Alçada
					"",; 		//E-mail do aprovador				
					"",;        //Mensagem retorno
					"",;        //Filial Substituido
					""})		//Matricula Substituido
	Else
		aAprov := U_F0800501("2",cCodAlc,cPrxApr,cTpSol,,cFilSol,cMatSol,RH3->RH3_FILIAL,RH3->RH3_MAT,RH3->RH3_FILIAL,RH3->RH3_CODIGO,,,cFilPto,cCdPsto)
	EndIf			
				
	cFilApr := aAprov[1][2]
	cMatApr := aAprov[1][3]
	cNvAprv := aAprov[1][4]
	cNomApr := POSICIONE("SRA",1,cFilApr + cMatApr,"RA_NOME")
	cEmlApr := aAprov[1][7]
	cObsLog := aAprov[1][8]
	
	If aAprov[1][1] //Encontrou aprovador
		
		If cPrxApr == "FM"
			cNotif := "2"
		Else
			cNotif := Posicione("PAC",1,xFilial("PAC") + aAprov[1][6] + aAprov[1][4],"PAC_APRNOT")
		Endif
	
		If (aAprov[1][5] == "FM" .And. cNotif == "2") .Or. (aAprov[1][5] == "FM" .And. ("aprova direto" $ cObsLog .OR. "Terminou a estrutura da visão!" $ cObsLog ))
			lEfetiv	:= .T.
		Else
			lEfetiv	:= .F.
		EndIf
	  	
		If !(lEfetiv)
			
			//Atualiza Indicadores.
			If AllTrim(cTpSol) $ '004/005/006/008'//FAP-DESLIGAMENTO-MOVIMENTAÇÃO-FERIAS
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"003", oSolicVag:FilMaSup, oSolicVag:CodMaSup)
			EndIf
			
			If RH3->RH3_XSUBST == "S" //Se Houve Substituição
				U_F1301111(cFilRh3,cSolicit,"1") //Historico do Substituto		
				Reclock("RH3", .F.)
				RH3->RH3_XSUBST := ""
				RH3->RH3_XFILSU := ""
				RH3->RH3_XMATSU := ""
				RH3->(MsUnlock())
			EndIf
			
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilRh3 + cSolicit))
				Reclock("RH3", .F.)
				RH3->RH3_FILAPR := cFilApr
				RH3->RH3_MATAPR := cMatApr
				RH3->RH3_NVLAPR := VAL(aAprov[1][4])
				RH3->RH3_XPRXNV := aAprov[1][5]
				RH3->RH3_XFILAP := oSolicVag:FilMaSup
				RH3->RH3_XMATAP := oSolicVag:CodMaSup
				If !Empty(aAprov[1][9]) .AND. !Empty(aAprov[1][10])
					RH3->RH3_XSUBST := "S"
					RH3->RH3_XFILSU := aAprov[1][9]
					RH3->RH3_XMATSU := aAprov[1][10]
				EndIf
				RH3->RH3_XDTAPV := Date()
				RH3->(MsUnlock())
				
				U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
			EndIf
			
			//Atualiza Indicadores.
			If AllTrim(cTpSol) $ '004/005/006/008'//FAP-DESLIGAMENTO-MOVIMENTAÇÃO-FERIAS
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"002")
			EndIf
			
			//GRAVA LOG
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(cFilSol+cMatSol))
			//Grava o log de Aprovação da solicitação 
			U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,SRA->RA_EMAIL,cNvAprv)

			
			//MANDA EMAIL
			DbSelectArea("PAB")
			PAB->(DbSetOrder(1))
			PAB->(DbSeek(xFilial("PAB")+cCodAlc))
			If EMPTY(cObsLog)
				cObsLog := oSolicVag:Obs
			EndIf
			U_F0800901("3",SRA->RA_EMAIL,cFilSol,cNumSol,SRA->RA_NOME,cTpSol,PAB->PAB_GRPSOL,cNvAprv,cObsLog)
			cRet := "Aprovado com sucesso."
			lRet	:= .T.
		Else //EFETIVAÇAO
			
			//Atualiza Indicadores.
			If AllTrim(cTpSol) $ '004/005/006/008'//FAP-DESLIGAMENTO-MOVIMENTAÇÃO-FERIAS
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"003", oSolicVag:FilMaSup, oSolicVag:CodMaSup)
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"005")
			EndIf

			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFilRh3 + cSolicit))
				U_F1301111(cFilRh3,cSolicit,"1") //Historico do Substituto		
				Reclock("RH3", .F.)
				RH3->RH3_STATUS	:= "4"
				RH3->RH3_XFILAP := oSolicVag:FilMaSup
				RH3->RH3_XMATAP := oSolicVag:CodMaSup

				If RH3->RH3_XSUBST == "S" //Se Houve Substituição
					RH3->RH3_XSUBST := ""
					RH3->RH3_XFILSU := ""
					RH3->RH3_XMATSU := ""
				EndIf
	
				RH3->(MsUnlock())
			EndIf
			
			cSubGrp := POSICIONE("PAB",1, XFILIAL("PAB") + RH3->RH3_XCODAL, "PAB_GRPSOL")
			
			DO CASE
			CASE cTpSol = '004'
				cFilPa2 := ALLTRIM(POSICIONE("RH4",1,RH3->RH3_FILIAL + RH3->RH3_CODIGO + "  1", "RH4_VALNOV"))
				U_F0500302(cFilPa2, RH3->RH3_FILIAL, RH3->RH3_CODIGO, "RI")
				
				
              // Mudança de Status da FAP para 'RI' // Jamer Nunes Pedroso - 19/05/2017 
				PA2->(DbSetOrder(6)) //PA2_FILIAL+PA2_SOL
				If PA2->(DbSeek(cFilRh3+cSolicit))

					Reclock("PA2",.F.)
					PA2->PA2_SIT := "RI" //AGUARDANDO MOVIMENTAÇÃO RH
					PA2->(MsUnLock())
				EndIf
			CASE cTpSol = '005'
						
				U_F0500112( cNumSol, '4', cFilialS )	
				U_F0801402(cFilialS, cSolicit, oSolicVag:FilMaSup, oSolicVag:CodMaSup, oSolicVag:Obs)			
				//----------------------------------------------
				// Grava Log PA6 - Adic. por Edu em 16/12/16	 //
				//----------------------------------------------
				U_F0600601(RH3->RH3_FILIAL, "RH3", RH3->RH3_CODIGO, RH3->(Recno()),"UPSERT")
				
			ENDCASE
			//Grava o log de Efetivação da solicitação 
			U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,RH3->RH3_FILAPR,RH3->RH3_MATAPR,cObsLog,POSICIONE("SRA",1,RH3->RH3_FILAPR+RH3->RH3_MATAPR,"RA_EMAIL"),"FM")
			//FsEnvRh()//Envia e-mail para o Rh Aprovar
			cRet := "Enviado para efetivação do RH."
			lRet := .T.
		EndIf
		
	Else //Cancelamento
		RH3->(DbSetOrder(1))
		If RH3->(DbSeek(cFilRh3 + cSolicit))
			
			Reclock("RH3",.F.)
			RH3->RH3_STATUS := "3"
			RH3->RH3_NVLAPR := 99
			RH3->RH3_FILAPR := ""
			RH3->RH3_MATAPR := ""
			RH3->RH3_XFILAP := oSolicVag:FilMaSup
			RH3->RH3_XMATAP := oSolicVag:CodMaSup
			RH3->RH3_XDTAPV := Date()
			If RH3->(ColumnPos("RH3_EMPAPR")) > 0
				RH3->RH3_EMPAPR	:= ""
			EndIf
			RH3->(MsUnlock())
		Endif

		//Grava o log de cancelamento da solicitação 
		U_F0800201("2",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,"",cNvAprv)

		DbSelectArea("PAB")
		PAB->(DbSetOrder(1))
		PAB->(DbSeek(xFilial("PAB")+cCodAlc))
		If EMPTY(cObsLog)
			cObsLog := oSolicVag:Obs
		EndIf
		
		//busca em toda alçada de aprovação para encontrar quais dos aprovadores deverão ser notificados
		DbSelectArea("PAA")
		PAA->(DbSetOrder(3))
		PAA->(DbSeek(xFilial("PAA")+ cFilSol + cNumSol))
						
		While (PAA->(!EOF()) .AND. (PAA->(PAA_FILSOL + PAA_NUMSOL)==  cFilSol + cNumSol))
			DbSelectArea("PAC")
			PAC->(DbSetOrder(1))
			If PAC->(DbSeek(xFilial("PAC")+PAA->(PAA_CODALC+PAA_NIVAPR))) .Or. (PAC->(DbSeek(xFilial("PAC") + PAA->(PAA_CODALC))) .AND. AllTrim(PAA->PAA_NIVAPR) == "FM")
				If PAC->PAC_NOTREJ == "1"
					DbSelectArea("SRA")
					SRA->(DbSetOrder(1))
					SRA->(DbSeek(PAA->(PAA_FILDOR + PAA_CODDOR)))
					If EMPTY(cObsLog)
						cObsLog := oSolicVag:Obs
					EndIf
					If !Empty(AllTrim(SRA->RA_EMAIL))
						cEmails += AllTrim(SRA->RA_EMAIL) + ";"
					EndIf
				EndIf
			EndIf
			PAA->(DbSkip())
		EndDo

		SRA->(DbSetOrder(1))
		SRA->(DbSeek(cFilSol + cMatSol))
	  	
		cEmails += AllTrim(SRA->RA_EMAIL) + ";"
	  			
		U_F0800901("2",cEmails,cFilSol,cNumSol,SRA->RA_NOME,cTpSol,PAB->PAB_GRPSOL,cNvAprv,cObsLog)

		//Atualiza Indicadores.
		If AllTrim(cTpSol) $ '004/005/006/008'//FAP-DESLIGAMENTO-MOVIMENTAÇÃO-FERIAS
			U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004", oSolicVag:FilMaSup, oSolicVag:CodMaSup)
		EndIf
				
		If cTpSol == '004' //FAP
			cFilPa2 := ALLTRIM(POSICIONE("RH4",1,cFilRh3 + cSolicit + "  1", "RH4_VALNOV"))
				
			U_F0500302(cFilPa2, cFilSol, cNumSol,"RP")
		EndIf
		
		If cTpSol == '005' //Desligamento
			U_F0500110(cSolicit,"3", cFilRh3)
		EndIf
		
		If cTpSol == '006' //Movimentação de pessoal
			U_F0500407(RH3->RH3_FILIAL,RH3->RH3_MAT,RH3->RH3_CODIGO,RH3->RH3_VISAO)
		EndIf
		
		cRet := "Solicitação Cancelada por não encontrar aprovador. " + cObsLog
		lRet	:= .F.
	EndIf
	
	If Empty(cRet)
		cRet := "Solicitação Cancelada por não encontrar aprovador."
	EndIf
	
	
	AADD(aAux,cMatApr)
	AADD(aAux,cNomApr)
	AADD(aAux,cEmlApr)
	AADD(aAux,cRet)
	AADD(aAux,lRet)
	
Return aAux

Static Function FsEnvRh()

	Local aArea := GetArea()
	Local cAssunto := "Aguardando efetivação RH"

	cBody := '<html><body><pre>'+CRLF
	cBody += "Existem solicitações para analise do RH, por favor acessar pelo ERP "+CRLF
	cBody += '</pre></body></html>'
	
	U_F0200304(cAssunto, cBody, cEmails)

	RestArea(aArea)

Return

WsMethod ValAprSol WsReceive Matricula,FilFun,CodRh3,FILRH3 WsSend lRet WsService W0500307
	
	Local cQuery     := ""
	Local cMatApr    := ""
	Local cAliasRh3  := "RETRH3"
	Local cAliRh4    := "RETRCX"
	Local nCnt       := 1
	Local aAux       := {}
	Local nPos       := 0
	/*
	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(::FILRH3 + ::CodRh3))
		cMatApr := RH3->RH3_MATAPR
		If RH3->RH3_STATUS != "3"
			If !(EMPTY(cMatApr))
				cPosto := POSICIONE("SRA",1,RH3->RH3_FILAPR + RH3->RH3_MATAPR,"RA_POSTO")
			Else
				cPosto := POSICIONE("SRA",1,::FilFun + ::Matricula,"RA_POSTO")
			EndIf
			If !(EMPTY(cPosto))
				cQuery := "SELECT RCX_MATFUN "
				cQuery += "FROM 	" + RetSqlName("RCX") + " RCX "
				cQuery += "WHERE RCX_POSTO = '" + cPosto + "' "
				cQuery += "		AND RCX_SUBST = '2' "
				cQuery += "		AND D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)
				
				DbSelectArea(cAliRh4)
				While ! (cAliRh4)->(EOF())
					AADD(aAux , (cAliRh4)->(RCX_MATFUN))
					(cAliRh4)->(DbSkip())
				End
				(cAliRh4)->(DbCloseArea())
			EndIf

			If !(EMPTY(cMatApr))
				::lRet := IIF(ASCAN(aAux, cMatApr ) == 0 ,.F.,.T.)
			Else
				::lRet := IIF(ASCAN(aAux, ::Matricula ) == 0 ,.F.,.T.)
			EndIf
		Else
			::lRet := .F.
		EndIf
	EndIf
	*/
	//Nairan - Com a alteração da PAL, essa validação não é mais necessária.
	::lRet := .T.
Return .T.

WSMETHOD BuscObser WSRECEIVE FilRh3, CodRh3 WSSEND _InfHisR WSSERVICE W0500307

	Local nCnt	:= 1
	Local aAux := {}
	Local oSolicita
	
	aAux := RetPae(::FilRh3,::CodRh3)
	
	If Len(aAux) > 0
		::_InfHisR := WSClassNew( "_InfHis" )
		
		::_InfHisR:Registro := {}
		oSolicita :=  WSClassNew( "InfHis" )
		For nCnt := 1 To Len(aAux)
			oSolicita:PAENOMEAP  := aAux[nCnt][1]
			oSolicita:PAEFUNAPR  := aAux[nCnt][2]
			oSolicita:PAEDCCAPR  := aAux[nCnt][3]
			oSolicita:PAEOBS     := aAux[nCnt][4]
			oSolicita:lRet       := .T.
			AAdd( ::_InfHisR:Registro, oSolicita )
			oSolicita :=  WSClassNew( "InfHis" )
		Next
	Else
		::_InfHisR := WSClassNew( "_InfHis" )
		
		::_InfHisR:Registro := {}
		oSolicita :=  WSClassNew( "InfHis" )
		oSolicita:PAENOMEAP  := ""
		oSolicita:PAEFUNAPR  := ""
		oSolicita:PAEDCCAPR  := ""
		oSolicita:PAEOBS     := ""
		oSolicita:lRet       := .F.
		AAdd( ::_InfHisR:Registro, oSolicita )
	EndIf

Return .T.

Static Function RetPae(cFilRh3,cCodRh3)

	Local cQuery   := ""
	Local cAliPae  := "RETPAE"
	Local aAux     := {}
	Local nPos     := 0
	
	cQuery := "SELECT PAE_FILIAL, PAE_NUMSOL, PAE_FILAPR, PAE_MATAPR, R_E_C_N_O_ AS RECNO "
	cQuery += "FROM 	" + RetSqlName("PAE") + " PAE "
	cQuery += "WHERE PAE_FILIAL = '" + cFilRh3 + "' "
	cQuery += "		AND PAE_NUMSOL = '" + cCodRh3 + "' "
	cQuery += "		AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliPae)
	
	DbSelectArea(cAliPae)
	While ! (cAliPae)->(EOF())
		PAE->(DbGoTo((cAliPae)->RECNO))
		AADD(aAux , { PAE->PAE_NOMEAP, PAE->PAE_FUNAPR, PAE->PAE_DCCAPR, PAE->PAE_OBS })
		(cAliPae)->(DbSkip())
	End
	(cAliPae)->(DbCloseArea())
	
Return aAux

WSMETHOD ValSesmt WSRECEIVE FilRh3, CodRh3 WSSEND lRet WSSERVICE W0500307
	
	Local cCodAl  := ""
	Local cNvApr  := ""
	Local cCodPos := ""
	Local cSesmt  := ""
	Local aAreas   := {RH3->(GetArea()), PAC->(GetArea()), PA9->(GetArea()), GetArea()}
	
	lRet := .F.
	
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(::FilRh3 + ::CodRh3))
	
	cCodAl := RH3->RH3_XCODAL
	cNvApr := Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1])
	
	If !(EMPTY(cCodAl)) .AND. !(EMPTY(cNvApr))
		PAC->(DbSetOrder(1))
		PAC->(DbSeek(xFilial("PAC") + cCodAl + cNvApr))
		
		cCodPos := PAC->PAC_CODPOS
		If !(EMPTY(cCodPos))
			PA9->(DbSetOrder(1))
			PA9->(DbSeek(xFilial("PA9") + cCodPos))
			
			cSesmt := PA9->PA9_SESMT
			
			If cSesmt != "1"
				::lRet := .T.
			EndIf
		EndIf
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return .T.

/*
{Protheus.doc} Rh4InfR()
Busca o SubGrupo da Rescisão e o Nível do Aprovado
@Author     Bruno de Oliveira
@Version    P12.1.7
@project    MAN0000007423048_EF_010
@Param      cFilSol, Filial da solicitação
@Param      cCodSol, Codigo da solicitação
@Return     aRetInf
*/
Static Function BscTpFR(cFilSol,cCodSol)

	Local cQuery  := ""
	Local cAlias1 := GetNextAlias()
	Local aRetInf := {}
	Local aArea   := GetArea()
	
	cQuery := "SELECT RH3.RH3_FILAPR, RH3.RH3_MATAPR, PAB.PAB_GRPSOL, SRA.RA_CODFUNC "
	cQuery += "FROM	" + RetSqlName("RH3") + " RH3 "
	cQuery += "INNER JOIN " + RetSqlName("PAB") + " PAB "
	cQuery += "ON ( RH3.RH3_XCODAL = PAB.PAB_CODIGO AND PAB.PAB_TPSOLI = '005' AND PAB.D_E_L_E_T_ = ' ') "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += "ON ( RH3.RH3_FILAPR = SRA.RA_FILIAL AND RH3.RH3_MATAPR = SRA.RA_MAT AND SRA.D_E_L_E_T_ = ' ') "
	cQuery += "WHERE RH3_FILIAL = '" + cFilSol + "' "
	cQuery += "AND RH3_CODIGO = '" + cCodSol + "' "
	cQuery += "AND RH3.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	If (cAlias1)->(!EOF())
		
		AADD(aRetInf,(cAlias1)->PAB_GRPSOL) //PA == 02
	
		If SRJ->(DbSeek(xFilial("SRJ")+(cAlias1)->RA_CODFUNC))
			AADD(aRetInf,SRJ->RJ_XGEREN)
		EndIf
	
	EndIf
	
Return aRetInf

WSMETHOD GrvDtDlg WSRECEIVE DATADESLIG,FilRh3,CodRh3 WSSEND lRet WSSERVICE W0500307

	Local aAreaRH4 := RH4->(GetArea())
	
	dDataDesl := CTOD(::DATADESLIG)
	
	RH4->(DBSetOrder(1))
	If RH4->(DBSeek(::FilRh3+::CodRh3+"7"))
		RecLock("RH4",.F.)
		RH4->RH4_VALNOV := DTOS(dDataDesl)
		RH4->(MsUnLock())
	EndIf
	
	::lRet := .T.
	
	RestArea(aAreaRH4)

Return .T.

WSMETHOD BscDados WSRECEIVE FilRh3,CodRh3 WSSEND retdados WSSERVICE W0500307
	
	Local aAreaRH3 := RH3->(GetArea())
	Local cCargFlS := ""
	Local cCttIniS := ""
	Local cCarSltd := ""
	
	RH3->(DbSetOrder(1))
	If RH3->(DBSeek(::FilRh3 + ::CodRh3))
		::retdados:FilSoli := RH3->RH3_FILIAL
		::retdados:DescFil := ALLTRIM(FWFILIALNAME(,RH3->RH3_FILIAL))
		::retdados:FilIniS := RH3->RH3_FILINI
		::retdados:DescFlS := ALLTRIM(FWFILIALNAME(,RH3->RH3_FILINI))
		::retdados:MatrFlS := RH3->RH3_MATINI
		::retdados:NomeFlS := ALLTRIM(POSICIONE("SRA",1,RH3->RH3_FILINI + RH3->RH3_MATINI, "RA_NOME"))
		cCargFlS  := ALLTRIM(POSICIONE("SRA",1,RH3->RH3_FILINI + RH3->RH3_MATINI, "RA_CODFUNC"))
		::retdados:DescCar := ALLTRIM(FDESC("SRJ",cCargFlS,"RJ_DESC"))
		cCttIniS  := ALLTRIM(POSICIONE("SRA",1,RH3->RH3_FILINI + RH3->RH3_MATINI, "RA_CC"))
		::retdados:DescCtt := ALLTRIM(FDESC("CTT",cCttIniS,"CTT_DESC01"))
		::retdados:FilSltd := RH3->RH3_FILIAL
		::retdados:DecSltd := ALLTRIM(FWFILIALNAME(,RH3->RH3_FILIAL))
		::retdados:MatSltd := RH3->RH3_MAT
		::retdados:NomSltd := ALLTRIM(POSICIONE("SRA",1,RH3->RH3_FILIAL + RH3->RH3_MAT, "RA_NOME"))
		cCarSltd  := ALLTRIM(POSICIONE("SRA",1,RH3->RH3_FILIAL + RH3->RH3_MAT, "RA_CODFUNC"))
		::retdados:CarSltd := ALLTRIM(FDESC("SRJ",cCarSltd,"RJ_DESC"))
	EndIf
	
	RestArea(aAreaRH3)
Return .T.
///////////////////////////////////////////
// Valida amarração entre RH3, PA9 e PAH //
///////////////////////////////////////////
Static Function VldPA9PAH(cNivel, cCodAux, cFilPosto, cPosto, cFilSol)
	Local aAreaPAC	:= PAC->(GetArea())
	Local aAreaPA9	:= PA9->(GetArea())
	Local lRet		:= .F.
	
	If Len(cValToChar(cNivel)) > 1
		cNivel := cValToChar(cNivel)
	Else
		cNivel := "0" + cValToChar(cNivel)
	EndIf
	
	PA9->(DbSetOrder(2))
		
	If PAC->(DbSeek(xFilial("PAC")+ cCodAux + cNivel))
		If PA9->(DbSeek(xFilial("PA9")+ PAC->PAC_CODPOS + cFilSol))
			While PA9->(PA9_FILIAL + PA9_CODIGO + PA9_FILSOL)== xFilial("PA9")+ PAC->PAC_CODPOS + cFilSol
				If (PA9->(PA9_FILAPR + PA9_POSAPR) == cFilPosto + cPosto)
					lRet := .T.
					Exit
				EndIf
				PA9->(DbSkip())
			EndDo	
		EndIf
	EndIf
	
	RestArea(aAreaPAC)
	RestArea(aAreaPA9)
	
Return lRet
