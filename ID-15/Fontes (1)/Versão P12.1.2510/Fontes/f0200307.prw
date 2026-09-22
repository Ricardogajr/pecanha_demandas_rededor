#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
{Protheus.doc} F0200307()
Webservice responsavel pelo portal e comunicação com protheus
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param
@Return
*/
User Function F0200307()
Return
//===========================================================================================================
WSSTRUCT Acesso
	WSDATA Matricula		As String 	OPTIONAL
	WSDATA Nome			As String 	OPTIONAL
	WSDATA Admissao		As String 	OPTIONAL
	WSDATA Departame  	As String 	OPTIONAL
	WSDATA CenCusto		As String 	OPTIONAL
	WSDATA Cargo			As String 	OPTIONAL
	WSDATA NMCENTRO      AS String 	OPTIONAL
	WSDATA NMCARGO       AS String 	OPTIONAL
	WSDATA NomeFil		AS String  OPTIONAL
	WSDATA NMDEPART      AS String 	OPTIONAL
ENDWSSTRUCT

WSSTRUCT _Subordinados
	WSDATA Registro		As ARRAY OF Acesso
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT Solicitacao
	WSDATA COD				AS String
	WSDATA Matricula		As String
	WSDATA Nome			As String
	WSDATA Status			As String
	WSDATA FilialS       AS String
	WSDATA CODPA3        AS String
	WSDATA FilPa3        AS String
ENDWSSTRUCT

WSSTRUCT _Solicitacao
	WSDATA Registro		As ARRAY OF Solicitacao
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT Superior
	WSDATA RANOME			AS String
	WSDATA RAEMAIL		As String
	WSDATA RD4TREE       AS String
	WSDATA SRADEPTO      AS String
	WSDATA QBMATRESP     AS String
ENDWSSTRUCT

WSSTRUCT _Superior
	WSDATA Registro		As ARRAY OF Superior
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT TreiSolici
	WSDATA CodigoTrm  AS String
	WSDATA DataTrm    AS String
	WSDATA StatusTrm  AS String
	WSDATA FilialTrm  AS String
ENDWSSTRUCT

WSSTRUCT _TreiSolici
	WSDATA TrmSL				As ARRAY OF TreiSolici
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT Treinamento
	WSDATA Treinamento	AS String
	WSDATA Curso			AS String
	WSDATA Inicio			AS String
	WSDATA Termino		AS String
	WSDATA Horario		AS String
	WSDATA Vagas			AS String
	WSDATA Calendario		AS String
	WSDATA Turma			AS String
	WSDATA Reservado		AS String
	WSDATA FilTrm        AS String
ENDWSSTRUCT

WSSTRUCT _Treinamento
	WSDATA Trm				As ARRAY OF Treinamento
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT Institu
	WSDATA RA0ENTIDA   As String
	WSDATA RA0DESC     As String
ENDWSSTRUCT

WSSTRUCT _Institu
	WSDATA Registro    As ARRAY OF Institu
ENDWSSTRUCT

//===========================================================================================================

WSSTRUCT ItensCurso//AcademicGrantFields
	WSDATA benefitCode						AS String				      			//Código do beneficio (RIS_CODE - Char - 2)
	WSDATA benefitName						AS String	      						//Nome do Benfício (RIS_DESC - Char - 20)
	WSDATA salaryTo							AS Float								//Salário até
ENDWSSTRUCT

WSSTRUCT IncentivoItens//AcademicGrantList
	WSDATA itens								AS Array Of ItensCurso		//Lista dos subsídios acadêmicos
	WSDATA curseName							AS String								//Nome do Curso
	WSDATA instituteName						AS String								//Nome da instituição
	WSDATA contact							AS String								//Contato na intituição
	WSDATA phone								AS String								//Telefone do contato
	WSDATA ramal								AS String								//Ramal
	WSDATA startDate							AS String								//Data de inicio do curso
	WSDATA endDate							AS String								//Data do fim do curso
	WSDATA monthlyPayment					AS String								//Valor da mensalidade
	WSDATA installmentAmount					AS String								//Qtde. total de parcelas
	WSDATA benefconcedido       			AS String 								//Beneficio Concedido
	WSDATA vltotcurso           			AS String 								//Valor Total Curso
	WSDATA vlinvesanovig        			AS String 								//Valor Investimento Ano Vigente
	WSDATA duracao              			AS String 								//Duração
	WSDATA observation						AS String								//Obesrvação
ENDWSSTRUCT

WSSTRUCT Incentivo//AcademicGrantList
	WSDATA curseName							AS String								//Nome do Curso
	WSDATA instituteName						AS String								//Nome da instituição
	WSDATA contact							AS String								//Contato na intituição
	WSDATA phone								AS String								//Telefone do contato
	WSDATA ramal								AS String								//Ramal
	WSDATA startDate							AS String								//Data de inicio do curso
	WSDATA endDate							AS String								//Data do fim do curso
	WSDATA monthlyPayment					AS String								//Valor da mensalidade
	WSDATA installmentAmount					AS String								//Qtde. total de parcelas
	WSDATA benefconcedido       			AS String 								//Beneficio Concedido
	WSDATA vltotcurso           			AS String 								//Valor Total Curso
	WSDATA vlinvesanovig        			AS String 								//Valor Investimento Ano Vigente
	WSDATA duracao              			AS String 								//Duração
	WSDATA observation						AS String								//Obesrvação
	WSDATA TIPO                           AS String
ENDWSSTRUCT

//===========================================================================================================
WSSTRUCT _RH4val
	WSDATA RA3MAT 	AS String
	WSDATA TMPNOME 	AS String
	WSDATA RA3CALEND 	AS String
	WSDATA RA3CURSO 	AS String
	WSDATA Obs    	AS String
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT Participante
	WSDATA Email    AS String
	WSDATA Treina   AS String
	WSDATA Nome     AS String
ENDWSSTRUCT

//===========================================================================================================
WSSTRUCT SupEmail
	WSDATA QBMATRESP AS String
	WSDATA RANOME    As String
	WSDATA RAEMAIL   As String
ENDWSSTRUCT

WSSTRUCT _SupEmail
	WSDATA Registro    As ARRAY OF SupEmail
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT EstruturaSolic
	WSDATA Nome        AS String
	WSDATA Matricula   AS String
	WSDATA Setor       AS String
	WSDATA CCusto      AS String
	WSDATA Unidade     AS String
	WSDATA Cargo       AS String
	WSDATA Telefone    AS String
	WSDATA Ramal       AS String
	WSDATA Email       AS String
	WSDATA TpCurso     AS String
	WSDATA Instituicao AS String
	WSDATA NomeCurso   AS String
	WSDATA DtInicio    AS String
	WSDATA DtTermino   AS String
	WSDATA Duracao     AS String
	WSDATA Mensalidade AS String
	WSDATA InvAnoVig   AS String
	WSDATA VlTotCurso  AS String
	WSDATA BenConcedi  AS String
	WSDATA Observacao  AS String
	WSDATA Status      AS String
	WSDATA Solicitante AS String
ENDWSSTRUCT
//===========================================================================================================
WSSTRUCT _RetSl
	WsData FlAprov As String
	WsData CdAprov As String
	WsData lRetorn As Boolean
	WsData MsgAvso As String
ENDWSSTRUCT
//===========================================================================================================
WSSERVICE W0200301 DESCRIPTION "WebService Server responsavel pelas rotinas de Incentivo Academico e Treinamento/Evento"
	
	WSDATA Assunto         AS String
	WSDATA Body            AS String
	WSDATA Matricu         AS String
	WSDATA RetEmal         AS Boolean
	WSDATA Ret             AS String
	WSDATA Depto           AS String
	WSDATA _DADOS          AS Participante
	WSDATA _Acesso         AS Acesso
	WSDATA _Treinam        AS Treinamento
	WSDATA _Solici         AS _Solicitacao
	WSDATA _Superi         AS _Superior
	WSDATA RADepart        AS String
	WSDATA _Subord         AS _Subordinados
	WSDATA _Treina         AS _Treinamento
	WSDATA _Inst           AS _Institu
	WSDATA _SupInf         AS _SupEmail
	WSDATA _SupInfP        AS SupEmail
	WSDATA EmployeeFil     AS String
	WSDATA WsNull          As String	         	OPTIONAL	//NULL
	WSDATA aRetSol		   As _RetSl
	WSDATA _Ret            AS Boolean
	WSDATA _RetIn          AS Boolean
	WSDATA lProc           AS Boolean
	WSDATA CodTrm          AS String
	WSDATA CodCur          AS String
	WSDATA Nome            AS String
	WSDATA CodSol          AS String
	WSDATA Matricula       AS String
	WSDATA Setor           AS String
	WSDATA CCusto          AS String
	WSDATA Unidade         AS String
	WSDATA Cargo           AS String
	WSDATA Telefone        AS String
	WSDATA Ramal           AS String
	WSDATA Email           AS String
	WSDATA TpCurso         AS String
	WSDATA Instituicao     AS String
	WSDATA NomeCurso       AS String
	WSDATA CodRh4          AS String
	WSDATA FIRH3H4         AS String
	WSDATA DtInicio        AS String
	WSDATA DtTermino       AS String
	WSDATA Duracao         AS String
	WSDATA Mensalidade     AS String
	WSDATA InvAnoVig       AS String
	WSDATA VlTotCurso      AS String
	WSDATA BenConcedi      AS String
	WSDATA Observacao      AS String
	WSDATA Status          AS String
	WSDATA Solicitante     AS String
	WSDATA MatAprov        AS String
	WSDATA AcademicoGrant  AS IncentivoItens
	WSDATA TreinaSolicita  AS _TreiSolici
	WSDATA Academico       AS Incentivo
	WSDATA RH4val          AS _RH4val
	//WSDATA EmployeeFil     AS String
	WSDATA Solici          AS String
	//WSDATA Status          AS String
	WSDATA CodMatri        AS String
	
	WSDATA calendRa2       AS String
	WSDATA cursoRa2        AS String
	WSDATA turmaRa2        AS String
	// RH4
	WSDATA Matri           AS String
	WSDATA NomeSol         AS String
	WSDATA CalenSol        AS String
	WSDATA CursoSol        AS String
	WSDATA TurmaSol        AS String
	WSDATA DtSolic         AS String
	WSDATA Observ          AS String
	WSDATA FilSoliciIn     AS String
	WSDATA FilAprIn        AS String
	WSDATA MatSoliciIn     AS String
	WSDATA MatAprIn        AS String
	WSDATA lStatus         AS Boolean
	//WSDATA Matricula       AS String
	WSDATA Calendario      AS String
	WSDATA Tipo            AS String
	WSDATA LocalSol        AS String
	WSDATA Superio         AS String
	WSDATA FilSuperio      AS String
	WSDATA FilMatSup       AS String
	WSDATA CodMatSup       AS String
	WSDATA FilTrm          AS String
	WSDATA FilFun          AS String
	WSDATA Obs             AS String
	WSDATA FilAtu          AS String 
	WSDATA MatAtu          AS String
	
	WSMETHOD ParamEntre         DESCRIPTION "Pega paramêtros do protheus"
	WSMETHOD CriaEntre          DESCRIPTION "Pega as informações para passar o e-mail"
	WSMETHOD RetornaPa3         DESCRIPTION "Retorna Solicitações da pessoa"
	WSMETHOD ListaSolicita      DESCRIPTION "Metodo que retorna a lista"
	WSMETHOD InserePa3          DESCRIPTION "Grava na tabela PA3"
	WSMETHOD BuscaTrm           DESCRIPTION "Pega treinamentos"
	WSMETHOD InfTrm             DESCRIPTION "Pega treinamento especifico"
	WSMETHOD InsereSoli         DESCRIPTION "Insere treinamento especifico"
	WSMETHOD InfPa3             DESCRIPTION "Retorna solicitação"
	WSMETHOD SoliTrm            DESCRIPTION "Pega solicitações feitas"
	WSMETHOD AnaSoli            DESCRIPTION "Pega iten da solicitações feitas"
	WSMETHOD VisSuper           DESCRIPTION "Visão dos superiores"
	WSMETHOD StatuTrmIn         DESCRIPTION "Status da pessoa para com o treinamento"
	WSMETHOD PegSuper           DESCRIPTION "Pega superior"
	WSMETHOD InfInsti           DESCRIPTION "Pega Entidade institucionais"
	WSMETHOD PegViInv           DESCRIPTION "Pega visão para envio de e-mail de reprovação"
	WSMETHOD RetInvFu           DESCRIPTION "Retorna dados do funcionario"
	
ENDWSSERVICE
//===========================================================================================================
// Metodo que envia o email
WSMETHOD RetInvFu WSRECEIVE Matricula,FilAprIn WSSEND _Acesso WSSERVICE W0200301
	
	If !(EMPTY(::Matricula)) .AND. !(EMPTY(::FilAprIn))
		cCenCusto  := POSICIONE("SRA",1,::FilAprIn + ::Matricula,"RA_CC")
		cCargo     := POSICIONE("SRA",1,::FilAprIn + ::Matricula,"RA_CARGO")
		cDepartame := POSICIONE("SRA",1,::FilAprIn + ::Matricula,"RA_DEPTO")
		cData      := DTOS(POSICIONE("SRA",1,::FilAprIn + ::Matricula,"RA_ADMISSA"))
		::_Acesso:Matricula  := POSICIONE("SRA",1,::FilAprIn + ::Matricula,"RA_MAT")
		::_Acesso:Nome		:= POSICIONE("SRA",1,::FilAprIn + ::Matricula,"RA_NOME")
		::_Acesso:Admissao	:= SUBSTR(cData,7,2) + "/" + SUBSTR(cData,5,2) + "/" + SUBSTR(cData,0,4)
		::_Acesso:Departame  := cDepartame
		::_Acesso:CenCusto	:= cCenCusto
		::_Acesso:Cargo		:= cCargo
		::_Acesso:NMCENTRO   := POSICIONE("CTT",1,U_F0600402( ::FilAprIn, "CTT") + cCenCusto,"CTT_DESC01")
		::_Acesso:NMCARGO    := POSICIONE("SQ3",1,U_F0600402( ::FilAprIn, "SQ3") + cCargo,"Q3_DESCSUM")
		::_Acesso:NMDEPART   := POSICIONE("SQB",1,U_F0600402( ::FilAprIn, "SQB") + cDepartame,"QB_DESCRIC")
		::_Acesso:NomeFil	 := FWFilialName(,::FilAprIn)	
	EndIf
	
Return .T.
//===========================================================================================================
// Metodo que envia o email
WSMETHOD ParamEntre WSRECEIVE Assunto, Body, Matricu WSSEND RetEmal WSSERVICE W0200301
	::RetEmal := U_F0200304(::Assunto, ::Body, ::Matricu)
Return .T.
//===========================================================================================================
// Metodo que pega as informações(Nome/Email/Treinamento)
WSMETHOD CriaEntre WSRECEIVE FilMatSup,CodMatSup, calendRa2, cursoRa2, turmaRa2 WSSEND _DADOS WSSERVICE W0200301
	Local aAux := {}
	aAux := U_F0200305(::FilMatSup, ::CodMatSup, ::calendRa2, ::cursoRa2, ::turmaRa2)
	
	::_dados:Email 	:= aAux[2]
	::_dados:Treina 	:= aAux[3]
	::_dados:Nome  	:= aAux[1]
Return .T.
////===========================================================================================================
// Pega as informações de quem está logado
WSMETHOD RetornaPa3 WSRECEIVE Matricu WSSEND _Solici WSSERVICE W0200301
	Local aAux := {}
	Local nCnt	:= 1
	Local oSolicita
	
	aAux := RetPa3(::Matricu)
	
	If Len(aAux) > 0
		::_Solici := WSClassNew( "_Solicitacao" )
		
		::_Solici:Registro := {}
		oSolicita :=  WSClassNew( "Solicitacao" )
		For nCnt := 1 To Len(aAux)
			oSolicita:COD 		:= aAux[nCnt][1]
			oSolicita:Matricula 	:= aAux[nCnt][2]
			oSolicita:Nome 		:= aAux[nCnt][3]
			oSolicita:Status 		:= aAux[nCnt][4]
			oSolicita:FilialS		:= aAux[nCnt][5]
			oSolicita:CODPA3		:= aAux[nCnt][6]
			oSolicita:FilPa3  	:= aAux[nCnt][7]
			AAdd( ::_Solici:Registro, oSolicita )
			oSolicita :=  WSClassNew( "Solicitacao" )
		Next
	Else
		::_Solici := WSClassNew( "_Solicitacao" )
		::_Solici:Registro := {}
		oSolicita :=  WSClassNew( "Solicitacao" )
		oSolicita:COD 		:= ""
		oSolicita:Matricula 	:= ""
		oSolicita:Nome 		:= ""
		oSolicita:Status 		:= ""
		oSolicita:FilialS		:= ""
		oSolicita:CODPA3		:= ""
		oSolicita:FilPa3  	:= ""
		AAdd( ::_Solici:Registro, oSolicita )
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} RetPa3()
Retorna todas as solicitações de incentivo
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cMatricu, matricula
@Return     aAux
*/
Static Function RetPa3(cMatricu)
	
	Local cQuery     := ''
	Local cAliasRh3  := 'RETPA3'
	Local cAliasrH4  := 'RETRH4'
	Local cCodPa3    := ''
	Local cFilPa3    := ''
	Local nCnt       := 1
	Local aAux       := {}
	
	cQuery := "SELECT	RH3_CODIGO, RH3_MAT, RH3_DTSOLI , RH3_XTPCTM, PA7_DESCR, RH3_STATUS, RH3_MATINI, "
	cQuery += "SRA.RA_NOME, RH3_VISAO, RH3_FILIAL "
	cQuery += "FROM	" + RetSqlName("RH3") + " RH3 "
	cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += "ON SRA.RA_MAT = RH3.RH3_MATINI "
	cQuery += "AND SRA.RA_FILIAL = RH3.RH3_FILINI "
	cQuery += "	AND SRA.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("PA7") + " PA7 "
	cQuery += "ON PA7.PA7_CODIGO = RH3.RH3_XTPCTM "
	cQuery += "	AND PA7.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE	RH3_MATINI = '"+ cMatricu +"' "
	cQuery += "		AND RH3_TIPO = ' ' "
	cQuery += "		AND RH3_XTPCTM = '007' "
	cQuery += "		AND RH3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH3_CODIGO"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRh3)
	
	DbSelectArea(cAliasRh3)
	While ! (cAliasRh3)->(EOF())
		
		AADD(aAux, {(cAliasRh3)->RH3_CODIGO,;
			(cAliasRh3)->RH3_MAT,;
			POSICIONE("SRA",1,(cAliasRh3)->RH3_FILIAL + (cAliasRh3)->RH3_MAT, "RA_NOME"),;
			(cAliasRh3)->RH3_STATUS,;
			(cAliasRh3)->RH3_FILIAL,;
			POSICIONE("RH4",1,(cAliasRh3)->RH3_FILIAL + (cAliasRh3)->RH3_CODIGO + '1', "RH4_VALNOV"),;
			POSICIONE("RH4",1,(cAliasRh3)->RH3_FILIAL + (cAliasRh3)->RH3_CODIGO + '2', "RH4_VALNOV")})
		(cAliasRh3)->(DbSkip())
	End
	(cAliasRh3)->(DbCloseArea())
	
Return aAux

//===========================================================================================================

WSMETHOD ListaSolicita WSRECEIVE EmployeeFil WSSEND AcademicoGrant WSSERVICE W0200301
	Local cMatFun		:= ::EmployeeFil
	Local lRet 		:= .T.
	Local oItem
	Local cQuery		:= GetNextAlias()
	
	BeginSql alias cQuery
		SELECT R.RIS_COD
		, R.RIS_DESC
		, R.RIS_SALATE
		FROM %table:RIS% R
		WHERE (R.RIS_FILIAL = %exp:' '% OR R.RIS_FILIAL = (SELECT RA_FILIAL FROM %table:SRA% WHERE RA_MAT = %exp:cMatFun%))
		AND R.RIS_TPBENE = %exp:'83'%
		AND R.%notDel%
		
	EndSql
	
	If (cQuery)->(Eof())
		SetSoapFault("Incentivo Academico" , "Não há incentivos acadêmicos cadastrado ou disponíveis.")
		lRet :=  .F.
	Else
		Self:AcademicoGrant						:= WSClassNew("IncentivoItens")
		Self:AcademicoGrant:itens 				:= {}
		Self:AcademicoGrant:curseName 			:= ''
		Self:AcademicoGrant:instituteName 		:= ''
		Self:AcademicoGrant:contact 			:= ''
		Self:AcademicoGrant:phone 				:= ''
		Self:AcademicoGrant:ramal 				:= ''
		Self:AcademicoGrant:startDate 			:= ''
		Self:AcademicoGrant:endDate 			:= ''
		Self:AcademicoGrant:monthlyPayment 	:= ''
		Self:AcademicoGrant:installmentAmount 	:= ''
		Self:AcademicoGrant:benefconcedido		:= ''
		Self:AcademicoGrant:vltotcurso			:= ''
		Self:AcademicoGrant:vlinvesanovig		:= ''
		Self:AcademicoGrant:duracao				:= ''
		Self:AcademicoGrant:observation 		:= ''
		//Self:AcademicoGrant:tipo 		       := ''
		
		While (cQuery)->(!Eof())
			oItem:= WSClassNew("ItensCurso")
			oItem:benefitCode			:= (cQuery)->RIS_COD
			oItem:benefitName			:= (cQuery)->RIS_DESC
			oItem:salaryTo			:= (cQuery)->RIS_SALATE
			AAdd(Self:AcademicoGrant:itens, oItem)
			(cQuery)->( dbSkip() )
		EndDo
	EndIf
Return lRet

//===========================================================================================================
// Grava na tabela PA3
WSMETHOD InserePa3 WSRECEIVE Nome,Matricula,Setor,CCusto,Unidade,Cargo,Telefone,Ramal,Email,TpCurso,Instituicao,NomeCurso,DtInicio,DtTermino,Duracao,Mensalidade,InvAnoVig,VlTotCurso,BenConcedi,Observacao,Status,FilSoliciIn, MatSoliciIn,FilFun WSSEND aRetSol WSSERVICE W0200301
	
	Local aResult := {}
	
	BEGIN TRANSACTION
		
		aResult := GrvPa3(::Nome,::Matricula,::Setor,::CCusto,::Unidade,::Cargo,::Telefone,::Ramal,::Email,::TpCurso,::Instituicao,::NomeCurso,::DtInicio,::DtTermino,::Duracao,::Mensalidade,::InvAnoVig,::VlTotCurso,::BenConcedi,::Observacao,::Status,::FilSoliciIn, ::MatSoliciIn, ::FilFun)
		
		If aResult[1][1]
			::aRetSol:FlAprov := aResult[1][2]
			::aRetSol:CdAprov := aResult[1][3]
			::aRetSol:lRetorn := aResult[1][1]
			::aRetSol:MsgAvso := aResult[1][4]
		Else
			::aRetSol:FlAprov := ""
			::aRetSol:CdAprov := ""
			::aRetSol:lRetorn := .F.
			::aRetSol:MsgAvso := aResult[1][4]
		EndIf
		
	END TRANSACTION
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} GrvPa3()
Grava incentivo
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cNome, Nome
@Param      cMatricula, Matricula
@Param      cSetor, Setor
@Param      cCCusto, Centro de custo
@Param      cUnidade, Unidade
@Param      cCargo, cargo
@Param      cTelefone, telefone
@Param      cRamal, ramal
@Param      cEmail, e-mail
@Param      cTpCurso, tipo do curso
@Param      cInstituic, instituição realizadora
@Param      cNomeCurso, nome do curso
@Param      cDtInicio, data de inicio do curso
@Param      cDtTermino, data termino do curso
@Param      cDuracao, duração do curso
@Param      cMensalida, mensalidade do curso
@Param      cInvAnoVig, investimento do ano vigente
@Param      cVlTotCurs, valor total do curso
@Param      cBenConced, beneficio concedido
@Param      cObservacao, observação
@Param      cStatus, status da solicitação
@Param      cSolicitante, matricula do solicitante
@Return     aAux
*/
Static Function GrvPa3(cNome,cMatricula,cSetor,cCCusto,cUnidade,cCargo,cTelefone,cRamal,cEmail,cTpCurso,cInstituic,cNomeCurso,cDtInicio,cDtTermino,cDuracao,cMensalida,cInvAnoVig,cVlTotCurs,cBenConced,cObservacao,cStatus,cFilSolici, cMatSolici, cFilFun)
	
	Local oModel  := Nil
	Local nX      := 0
	Local aAux    := {}
	Local aRegs   := {}
	Local lRet    := .F.
	Local aRetSup := {}
	Local aRet    := {}
	Local cNotif  := ""
	Local cXStatus := ""
	
	cDtIni := substr(cdtinicio,7,4) + substr(cdtinicio,4,2) + substr(cdtinicio,0,2)
	cDtFim := substr(cDtTermino,7,4) + substr(cDtTermino,4,2) + substr(cDtTermino,0,2)
	
	cMensalida := StrTran( cMensalida, ".", "" )
	cMensalida := StrTran( cMensalida, ",", "." )
	
	cInvAnoVig := StrTran( cInvAnoVig, ".", "" )
	cInvAnoVig := StrTran( cInvAnoVig, ",", "." )
	
	cVlTotCurs := StrTran( cVlTotCurs, ".", "" )
	cVlTotCurs := StrTran( cVlTotCurs, ",", "." )
	
	cBenConced := StrTran( cBenConced, ",", "." )
	
	//Busca aprovador
	aRetSup := U_F0800501("1",,,"007","001",cFilSolici,cMatSolici,cFilFun,cMatricula)
	
	If aRetSup[1][1] //Encontrou o aprovador
	
		cNotif := Posicione("PAC",1,xFilial("PAC")+aRetSup[1][6]+aRetSup[1][4],"PAC_APRNOT")
		
		If (aRetSup[1][5] == "FM" .And. cNotif == "2") .Or. (aRetSup[1][5] == "FM" .And. ("aprova direto" $ aRetSup[1][8] .OR. "Terminou a estrutura da visão!" $ aRetSup[1][8] )) 
			cXStatus := "4"
		Else
			cXStatus := "1"
		EndIf
		
		cFilApr := aRetSup[1][2]
		cMatApr := aRetSup[1][3]
		cNvlApr := aRetSup[1][4]
		cCodAlc := aRetSup[1][6]
		cPrxNvl := aRetSup[1][5]
		
		cCod  := GetSX8Num("PA3", "PA3_XCOD")
		DbSelectArea("PA3")
		While PA3->(DbSeek(xFilial("PA3")+cCod))
			cCod  := GetSX8Num("PA3", "PA3_XCOD")
		End
		
		If ! PA3->(DbSeek(cFilSolici + cCod))
			Reclock("PA3", .T.)
			PA3->PA3_FILIAL := xFilial("PA3")
			PA3->PA3_XCOD   := cCod
			PA3->PA3_XMATRI := cMatricula
			PA3->PA3_XSETOR := cSetor
			PA3->PA3_XCENTR := cCCusto
			PA3->PA3_XUNIDA := cUnidade
			PA3->PA3_XCARGO := cCargo
			PA3->PA3_XEMAIL := cEmail
			PA3->PA3_XTELEF := cTelefone
			PA3->PA3_XRAMAL := cRamal
			PA3->PA3_XTIPO  := cTpCurso
			PA3->PA3_XINSTI := cInstituic
			PA3->PA3_XCURS  := cNomeCurso
			PA3->PA3_XINICI := STOD(cDtIni)
			PA3->PA3_XTERMI := STOD(cDtFim)
			PA3->PA3_XDURAC := VAL(cDuracao)
			PA3->PA3_XMENSL := VAL(cMensalida)
			PA3->PA3_XVLTAL := VAL(cInvAnoVig)
			PA3->PA3_XVLTCU := VAL(cVlTotCurs)
			PA3->PA3_XPCBEN := VAL(cBenConced)
			PA3->PA3_XSOLIC := cMatSolici
			PA3->PA3_RSPAPR := cMatApr
			PA3->PA3_XOBSER := cObservacao
			PA3->PA3_XSTATU := cStatus
			PA3->(MsUnlock())
		EndIf
		
		If (__lSX8)
			ConfirmSx8()
			lRet := .T.
		EndIf
		
		aRegs := {;
			{"PA3_FILIAL",xFilial("PA3")},;
			{"PA3_XCOD  ",cCod          },;
			{"PA3_XMATRI",cMatricula    },;
			{"PA3_XSETOR",cSetor        },;
			{"PA3_XCENTR",cCCusto		 },;
			{"PA3_XUNIDA",cUnidade		 },;
			{"PA3_XCARGO",cCargo        },;
			{"PA3_XEMAIL",cEmail        },;
			{"PA3_XTELEF",cTelefone     },;
			{"PA3_XRAMAL",cRamal        },;
			{"PA3_XTIPO ",cTpCurso      },;
			{"PA3_XINSTI",cInstituic    },;
			{"PA3_XCURS ",cNomeCurso    },;
			{"PA3_XINICI",cDtIni	     },;
			{"PA3_XTERMI",cDtFim	     },;
			{"PA3_XDURAC",cDuracao      },;
			{"PA3_XMENSL",cMensalida    },;
			{"PA3_XVLTAL",cInvAnoVig    },;
			{"PA3_XVLTCU",cVlTotCurs    },;
			{"PA3_XPCBEN",cBenConced    },;
			{"PA3_XSOLIC",cMatSolici  	 },;
			{"PA3_RSPAPR",cMatApr	  	 },;
			{"PA3_XOBSER",cObservacao	 },;
			{"PA3_XSTATU",cStatus		 };
			}
		
		If lRet
			lRet := GrvSoliIn(aRegs,cMatricula,cFilSolici,cMatSolici,cFilApr,cMatApr,cFilFun,cNvlApr,cCodAlc,cPrxNvl,cXStatus)
			If lRet
				aAdd(aRet,{lRet,cFilApr,cMatApr,""})
			Else
				aAdd(aRet,{lRet,"","","Não foi possivel fazer a inclusão no banco!"})
			EndIf
		EndIf
		
	Else
		aAdd(aRet,{lRet,"","",aRetSup[1][8]})
	EndIf
	
Return aRet
//===========================================================================================================
// Pega informações dos Treinamentos
WSMETHOD BuscaTrm WSRECEIVE lProc WSSEND _Treina WSSERVICE W0200301
	Local aAux := {}
	Local nCnt := 1
	Local oTreina
	
	aAux := TrmRa2()
	
	If Len(aAux) > 0
		::_Treina := WSClassNew( "_Treinamento" )
		
		::_Treina:Trm := {}
		oTreina :=  WSClassNew( "Treinamento" )
		For nCnt := 1 To Len(aAux)
			oTreina:Calendario 	:= aAux[nCnt][1]
			oTreina:Treinamento 	:= aAux[nCnt][2]
			oTreina:Curso 		:= aAux[nCnt][3]
			oTreina:Inicio 		:= aAux[nCnt][4]
			oTreina:Termino		:= aAux[nCnt][5]
			oTreina:Horario		:= aAux[nCnt][6]
			oTreina:Vagas			:= cValToChar(aAux[nCnt][7] - aAux[nCnt][9])
			oTreina:Turma			:= aAux[nCnt][8]
			oTreina:Reservado		:= cValToChar(aAux[nCnt][9])
			oTreina:FilTrm    	:= aAux[nCnt][10]
			AAdd( ::_Treina:Trm, oTreina )
			oTreina :=  WSClassNew( "Treinamento" )
		Next
	Else
		::_Treina := WSClassNew( "_Treinamento" )
		
		::_Treina:Trm := {}
		oTreina :=  WSClassNew( "Treinamento" )
		oTreina:Calendario 	:= ""
		oTreina:Treinamento 	:= ""
		oTreina:Curso 		:= ""
		oTreina:Inicio 		:= ""
		oTreina:Termino		:= ""
		oTreina:Horario		:= ""
		oTreina:Vagas			:= ""
		oTreina:Turma			:= ""
		oTreina:Reservado		:= ""
		oTreina:FilTrm    	:= ""
		AAdd( ::_Treina:Trm, oTreina )
	EndIf
Return .T.
//===========================================================================================================
/*
{Protheus.doc} TrmRa2()
Pega treinamentos aptos para cadastro
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return     aAux
*/
Static Function TrmRa2()
	
	Local cQuery 	:= ''
	Local cAliTrm	:= 'TRMRA2'
	Local aAux		:= {}
	
	cQuery := "SELECT RA2_CALEND, RA2_DESC, RA2_CURSO, "
	cQuery += "       RA2_DATAIN, RA2_DATAFI, RA2_HORARI, "
	cQuery += "       RA2_VAGAS, RA2_TURMA, RA2_RESERV, RA2_FILIAL "
	cQuery += "FROM	" + RetSqlName("RA2") + " "
	cQuery += "WHERE 	RA2_VAGAS != RA2_RESERV "
	cQuery += "		AND RA2_REALIZ != 'S' "
	cQuery += "		AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTrm)
	
	DbSelectArea(cAliTrm)
	While ! (cAliTrm)->(EOF())
		AADD(aAux, {	(cAliTrm)->RA2_CALEND ,;
			(cAliTrm)->RA2_DESC ,;
			(cAliTrm)->RA2_CURSO,;
			(cAliTrm)->RA2_DATAIN,;
			(cAliTrm)->RA2_DATAFI,;
			(cAliTrm)->RA2_HORARI,;
			(cAliTrm)->RA2_VAGAS,;
			(cAliTrm)->RA2_TURMA,;
			(cAliTrm)->RA2_RESERV,;
			(cAliTrm)->RA2_FILIAL;
			}  	)
		(cAliTrm)->(DbSkip())
	End
	(cAliTrm)->(DbCloseArea())
	
Return aAux

//===========================================================================================================
// Metodo que envia o email
WSMETHOD AnaSoli WSRECEIVE CodRh4,FIRH3H4 WSSEND RH4val WSSERVICE W0200301
	
	Local aAuxH4 := {}
	
	aAuxH4 := Rh4Inf(::CodRh4,::FIRH3H4)
	
	If Len(aAuxH4) > 0
		::RH4val:RA3MAT		:= ALLTRIM(aAuxH4[1][2])
		::RH4val:TMPNOME	  	:= ALLTRIM(aAuxH4[2][2])
		::RH4val:RA3CALEND	:= ALLTRIM(aAuxH4[3][2])
		::RH4val:RA3CURSO	  	:= ALLTRIM(aAuxH4[4][2])
		::RH4val:obs  	  	:= ALLTRIM(aAuxH4[5][2])
	Else
		::RH4val:RA3MAT		:= ""
		::RH4val:TMPNOME	  	:= ""
		::RH4val:RA3CALEND	:= ""
		::RH4val:RA3CURSO	  	:= ""
		::RH4val:obs  	  	:= ""
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} Rh4Inf()
Retorna informações da solicitação de treinamento selecionado
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      CodSol, codigo da solicição de treinamento
@Return     aAux
*/
Static Function Rh4Inf(CodSol, FIRH3H4)
	
	Local cQuery 	:= ''
	Local cAliRh4	:= 'RH4INF'
	Local aAux		:= {}
	
	cQuery := "SELECT RH4_CAMPO, RH4_VALNOV "
	cQuery += "FROM	" + RetSqlName("RH4") + " "
	cQuery += "WHERE RH4_CODIGO = '" + CodSol + "' "
	cQuery += "		AND RH4_FILIAL = '" + FIRH3H4 + "'"
	cQuery += "      AND RH4_CAMPO IN ('RA3_CALEND','RA3_CURSO', 'RA3_MAT', 'TMP_NOME', 'TMP_OBS') "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRh4)
	
	DbSelectArea(cAliRh4)
	Do While ! (cAliRh4)->(EOF())
		DO CASE 
			CASE ALLTRIM((cAliRh4)->RH4_CAMPO) == "TMP_OBS"
				RH4->(DbSetOrder(1))
				RH4->(DBSEEK(Alltrim(FIRH3H4 + CodSol + "  8")))//Item 6 de desligamento é o motivo
				AADD(aAux, {(cAliRh4)->RH4_CAMPO,RH4->RH4_XOBS})
			OTHERWISE
				AADD(aAux, {(cAliRh4)->RH4_CAMPO,(cAliRh4)->RH4_VALNOV})
		ENDCASE
		(cAliRh4)->(DbSkip())
	EndDo
	(cAliRh4)->(DbCloseArea())
	
Return aAux
//===========================================================================================================
// Pega informações do Treinamento especifico
WSMETHOD InfTrm WSRECEIVE CodTrm, CodCur, FilTrm WSSEND _Treinam WSSERVICE W0200301
	Local aAux := {}
	
	aAux := TrmInf(::CodTrm, ::CodCur, ::FilTrm)
	
	If Len(aAux) > 0
		::_Treinam:Calendario 	:= aAux[1]
		::_Treinam:Treinamento 	:= aAux[2]
		::_Treinam:Curso 			:= aAux[3]
		::_Treinam:Inicio 		:= aAux[4]
		::_Treinam:Termino		:= aAux[5]
		::_Treinam:Horario		:= aAux[6]
		::_Treinam:Vagas			:= cValToChar(aAux[7])
		::_Treinam:Turma			:= aAux[8]
	Else
		::_Treinam:Calendario 	:= ""
		::_Treinam:Treinamento 	:= ""
		::_Treinam:Curso 			:= ""
		::_Treinam:Inicio 		:= ""
		::_Treinam:Termino		:= ""
		::_Treinam:Horario		:= ""
		::_Treinam:Vagas			:= ""
		::_Treinam:Turma			:= ""
	EndIf
Return .T.
//===========================================================================================================
/*
{Protheus.doc} TrmInf()
Pega informações do treinamento
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cCalend, codigo do calendario
@Param      cCurso, codigo do curso
@Return     aAux
*/
Static Function TrmInf(cCalend, cCurso, cFilTrm)
	
	Local cQuery 	:= ''
	Local cAliTrm	:= 'TRMINF'
	Local aAux		:= {}
	
	cFilTrm := U_F0600402( cFilTrm, "RA2")
	
	cQuery := "SELECT RA2_CALEND, RA2_DESC, RA2_CURSO, "
	cQuery += "       RA2_DATAIN, RA2_DATAFI, RA2_HORARI, "
	cQuery += "       RA2_VAGAS, RA2_TURMA, RA2_RESERV "
	cQuery += "FROM	" + RetSqlName("RA2") + " "
	cQuery += "WHERE  RA2_FILIAL = '"+ cFilTrm +"' "
	cQuery += "  	  AND RA2_CALEND = '" + cCalend + "' "
	cQuery += "       AND RA2_CURSO = '" + cCurso + "' "
	cQuery += "       AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTrm)
	
	DbSelectArea(cAliTrm)
	While ! (cAliTrm)->(EOF())
		AADD(aAux, (cAliTrm)->RA2_CALEND	)
		AADD(aAux, (cAliTrm)->RA2_DESC		)
		AADD(aAux, (cAliTrm)->RA2_CURSO		)
		AADD(aAux, (cAliTrm)->RA2_DATAIN	)
		AADD(aAux, (cAliTrm)->RA2_DATAFI	)
		AADD(aAux, (cAliTrm)->RA2_HORARI	)
		AADD(aAux, ((cAliTrm)->RA2_VAGAS - (cAliTrm)->RA2_RESERV ))
		AADD(aAux, (cAliTrm)->RA2_TURMA		)
		(cAliTrm)->(DbSkip())
	End
	(cAliTrm)->(DbCloseArea())
	
Return aAux
//===========================================================================================================
// Solicitações feitas
WSMETHOD SoliTrm WSRECEIVE CodMatri WSSEND TreinaSolicita WSSERVICE W0200301
	Local aAux 	:= {}
	Local nCnt		:= 1
	Local oTreina := Nil
	
	aAux := TrmInfSol(::CodMatri)
	
	If Len(aAux) > 0
		::TreinaSolicita := WSClassNew( "_TreiSolici" )
		
		::TreinaSolicita:TrmSL := {}
		oTreina :=  WSClassNew( "TreiSolici" )
		For nCnt := 1 To Len(aAux)
			oTreina:CodigoTrm 	:= aAux[nCnt][1]
			oTreina:DataTrm 		:= aAux[nCnt][2]
			oTreina:StatusTrm 	:= aAux[nCnt][3]
			oTreina:FilialTrm    := aAux[nCnt][4]
			AAdd( ::TreinaSolicita:TrmSL, oTreina )
			oTreina :=  WSClassNew( "TreiSolici" )
		Next
	Else
		::TreinaSolicita := WSClassNew( "_TreiSolici" )
		
		::TreinaSolicita:TrmSL := {}
		oTreina :=  WSClassNew( "TreiSolici" )
		oTreina:CodigoTrm 	:= ""
		oTreina:DataTrm 		:= ""
		oTreina:StatusTrm 	:= ""
		oTreina:FilialTrm    := ""
		AAdd( ::TreinaSolicita:TrmSL, oTreina )
	EndIf
Return .T.
//===========================================================================================================
/*
{Protheus.doc} TrmInfSol()
Informações da solicitação de treinamento
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cCodMatri, codigo da matricula do solicitante
@Return     aAux
*/
Static Function TrmInfSol(cCodMatri)
	
	Local aArea 	:= GetArea()
	Local cQuery 	:= ''
	Local cAliTrm	:= 'TRMINFSOL'
	Local aAux		:= {}
	
	cQuery := "SELECT RH3_CODIGO, RH3_DTSOLI, RH3_STATUS, RH3_FILIAL "
	cQuery += "FROM	" + RetSqlName("RH3") + " "
	cQuery += "WHERE RH3_FILIAL = '"+FwxFilial("RH3")+"' "
	cQuery += "		AND RH3_XTPCTM = '001' "
	cQuery += "      AND RH3_MATINI = '" + cCodMatri + "' "
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH3_CODIGO"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTrm)
	
	DbSelectArea(cAliTrm)
	While ! (cAliTrm)->(EOF())
		AADD(aAux, {(cAliTrm)->RH3_CODIGO,;
			(cAliTrm)->RH3_DTSOLI,;
			(cAliTrm)->RH3_STATUS,;
			(cAliTrm)->RH3_FILIAL	})
		(cAliTrm)->(DbSkip())
	End
	(cAliTrm)->(DbCloseArea())
	
	RestArea(aArea)
	
Return aAux
//===========================================================================================================
// Pega informações do Treinamento especifico
WSMETHOD InfPa3 WSRECEIVE CodSol,FIRH3H4 WSSEND Academico WSSERVICE W0200301
	Local aAux := {}
	
	aAux := Pa3Inf(::CodSol,::FIRH3H4)
	
	If Len(aAux) > 0
		::Academico:curseName      := aAux[6]
		::Academico:instituteName  := aAux[5]
		::Academico:contact        := aAux[3]
		::Academico:phone          := aAux[1]
		::Academico:ramal          := aAux[2]
		::Academico:startDate      := aAux[7]
		::Academico:endDate        := aAux[8]
		::Academico:monthlyPayment := cValToChar(aAux[10])
		::Academico:benefconcedido := cValToChar(aAux[13])
		::Academico:vltotcurso     := cValToChar(aAux[11])
		::Academico:vlinvesanovig  := cValToChar(aAux[12])
		::Academico:duracao        := cValToChar(aAux[9])
		::Academico:tipo           := aAux[4]
		::Academico:observation    := aAux[14]
	Else
		::Academico:curseName      := ""
		::Academico:instituteName  := ""
		::Academico:contact        := ""
		::Academico:phone          := ""
		::Academico:ramal          := ""
		::Academico:startDate      := ""
		::Academico:endDate        := ""
		::Academico:monthlyPayment := ""
		::Academico:benefconcedido := ""
		::Academico:vltotcurso     := ""
		::Academico:vlinvesanovig  := ""
		::Academico:duracao        := ""
		::Academico:tipo           := ""
		::Academico:observation    := ""
	EndIf
Return .T.
//===========================================================================================================
/*
{Protheus.doc} Pa3Inf()
Busca informações da solicitação passada
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      CodSol, codigo da solicitação de incentivo
@Return     aAux
*/
Static Function Pa3Inf(CodSol,FIRH3H4)
	
	Local cQuery 	:= ''
	Local cAliPa3	:= 'PA3INF'
	Local aAux		:= {}
	
	FIRH3H4 := U_F0600402( FIRH3H4, "PA3")
	
	cQuery := "SELECT PA3_XTELEF, PA3_XRAMAL, PA3_XEMAIL, PA3_XTIPO, PA3_XINSTI, PA3_XCURS, PA3_XINICI, "
	cQuery += "PA3_XTERMI, PA3_XDURAC, PA3_XMENSL, PA3_XVLTAL, PA3_XVLTCU, PA3_XPCBEN "
	cQuery += "FROM	" + RetSqlName("PA3") + " "
	cQuery += "WHERE PA3_XCOD = '" + CodSol + "' "
	cQuery += "		AND PA3_FILIAL = '" + FIRH3H4 + "'"
	cQuery += "		AND D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliPa3)
	
	DbSelectArea(cAliPa3)
	While ! (cAliPa3)->(EOF())
		AADD(aAux, (cAliPa3)->PA3_XTELEF	)
		AADD(aAux, (cAliPa3)->PA3_XRAMAL	)
		AADD(aAux, (cAliPa3)->PA3_XEMAIL	)
		AADD(aAux, POSICIONE("RIS",1,XFILIAL("RIS")+"83"+(cAliPa3)->PA3_XTIPO,"RIS_DESC"))
		AADD(aAux, POSICIONE("RA0",1,XFILIAL("RA0")+(cAliPa3)->PA3_XINSTI,"RA0_DESC"))
		AADD(aAux, (cAliPa3)->PA3_XCURS		)
		AADD(aAux, (cAliPa3)->PA3_XINICI	)
		AADD(aAux, (cAliPa3)->PA3_XTERMI	)
		AADD(aAux, (cAliPa3)->PA3_XDURAC	)
		AADD(aAux, (cAliPa3)->PA3_XMENSL	)
		AADD(aAux, (cAliPa3)->PA3_XVLTAL	)
		AADD(aAux, (cAliPa3)->PA3_XVLTCU	)
		AADD(aAux, (cAliPa3)->PA3_XPCBEN	)
		AADD(aAux, POSICIONE("PA3",3,XFILIAL("PA3") + CodSol,"PA3_XOBSER")	)
		(cAliPa3)->(DbSkip())
	End
	(cAliPa3)->(DbCloseArea())
	
Return aAux
//===========================================================================================================
// Metodo que envia o email
WSMETHOD InsereSoli WSRECEIVE Matri, NomeSol, CalenSol, CursoSol, TurmaSol, DtSolic, Observ, FilSoliciIn, MatSoliciIn, FilFun WSSEND aRetSol WSSERVICE W0200301
	
	Local aResult := {}
	Local aRegs   := {{"RA3_FILIAL", FWXFILIAL("RA3")  },;
		{"RA3_MAT",    ::Matri   },;
		{"TMP_NOME",   ::NomeSol },;
		{"RA3_CALEND", ::CalenSol},;
		{"RA3_CURSO",  ::CursoSol},;
		{"RA3_TURMA",  ::TurmaSol},;
		{"RA3_DATA",   ::DtSolic },;
		{"TMP_OBS",    ::Observ  }}
	
	BEGIN TRANSACTION
		
		aResult := GrvSolici(aRegs, ::Matri, ::FilSoliciIn, ::MatSoliciIn, ::FilFun )
		
		If aResult[1][1]
			::aRetSol:FlAprov := aResult[1][2]
			::aRetSol:CdAprov := aResult[1][3]
			::aRetSol:lRetorn := aResult[1][1]
			::aRetSol:MsgAvso := aResult[1][4]
		Else
			::aRetSol:FlAprov := ""
			::aRetSol:CdAprov := ""
			::aRetSol:lRetorn := .F.
			::aRetSol:MsgAvso := aResult[1][4]
		EndIf
		
	END TRANSACTION
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} GrvSolici()
Grava solicitação de treinamento
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      aRegs, dados do treinamento
@Param      cMatricula, matricula do funcionario
@Param      cFilSolici, Filial do solicitante
@Param      cMatSolici, matricula do solicitante
@Param      cFilFun, Filial do funcionario
@Return     lRet
*/
Static Function GrvSolici(aRegs, cMatricula, cFilSolici, cMatSolici,cFilFun)
	
	Local aAreas  := {RA2->(GetArea()),RH4->(GetArea()),RH3->(GetArea()),GetArea()}
	Local nCount  := 0
	Local nItem   := 0
	Local cRh3Cod := ""
	Local lRet    := .F.
	Local aRetSup := {}
	Local aRet    := {}
	Local cXStatus := ""
	Local cNotif   := ""
	Local cObsLog := "Solicitação de Treinamento Aberta"
	
	cRh3Cod  := U_F1302201({cFilFun,"",""}, .T.)
		
	//Busca o superior
	aRetSup := U_F0800501("1",,,"001","001",cFilSolici,cMatSolici,cFilFun,cMatricula)
	
	If aRetSup[1][1] //Se Encontrou o Aprovador
	
		cNotif := Posicione("PAC",1,xFilial("PAC")+aRetSup[1][6]+aRetSup[1][4],"PAC_APRNOT")
		
		If (aRetSup[1][5] == "FM" .And. cNotif == "2") .Or. (aRetSup[1][5] == "FM" .And. ("aprova direto" $ aRetSup[1][8] .OR. "Terminou a estrutura da visão!" $ aRetSup[1][8] ))
			cXStatus := "4"
		Else
			cXStatus := "1"
		EndIf
	
		RH3->(DbSetOrder(1))
		If ! RH3->(DbSeek(xFilial("RH3") + cRh3Cod))
			Reclock("RH3", .T.)
			RH3->RH3_FILIAL  := cFilFun
			RH3->RH3_CODIGO  := cRh3Cod
			RH3->RH3_MAT     := cMatricula
			RH3->RH3_ORIGEM  := "PORTAL"
			RH3->RH3_STATUS  := cXStatus
			RH3->RH3_DTSOLI  := DATE()
			RH3->RH3_FILINI  := cFilSolici
			RH3->RH3_MATINI  := cMatSolici
			RH3->RH3_FILAPR  := aRetSup[1][2]
			RH3->RH3_MATAPR  := aRetSup[1][3]
			RH3->RH3_NVLAPR  := VAL(aRetSup[1][4])
			RH3->RH3_KEYINI  := "002"
			RH3->RH3_EMP     := "01"
			RH3->RH3_EMPINI  := "01"
			RH3->RH3_EMPAPR  := "01"
			RH3->RH3_XTPCTM  := "001"
			RH3->RH3_XCODAL  := aRetSup[1][6]
			RH3->RH3_XPRXNV  := aRetSup[1][5]
			RH3->(MsUnlock())
			
			U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
			
			U_F0500201(cFilSolici,cRh3Cod,"001")
			
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(RH3->RH3_FILAPR + RH3->RH3_MATAPR))
			U_F0800901("1",SRA->RA_EMAIL,cFilFun,cRh3Cod,SRA->RA_NOME,"001","001",aRetSup[1][4],cObsLog)
		EndIf
		
		RH4->(DbSetOrder(1))
		If ! RH4->(DbSeek(xFilial("RH4") + cRh3Cod))
			For nCount:= 1 To Len(aRegs)
				If !Empty(aRegs[nCount, 2])
					Reclock("RH4", .T.)
					RH4->RH4_FILIAL	:= xFilial("RH4")
					RH4->RH4_CODIGO	:= cRh3Cod
					RH4->RH4_ITEM	    := ++nItem
					RH4->RH4_CAMPO	:= aRegs[nCount, 1]
					IF aRegs[nCount, 1] != "TMP_OBS"
						RH4->RH4_VALNOV	:= IIF(EMPTY(aRegs[nCount, 2]),'',aRegs[nCount, 2])
					Else
						RH4->RH4_XOBS  	:= IIF(EMPTY(aRegs[nCount, 2]),'',aRegs[nCount, 2])
					EndIf
					RH4->(MsUnlock())
				EndIf
			Next
		EndIf
		
		If (__lSX8)
			ConfirmSx8()
			lRet := .T.
			
			//Grava o log de inclusão da solicitação 
			U_F0800201("1",cFilFun,cRh3Cod,aRetSup[1][6],cFilSolici,cMatSolici,aRetSup[1][2],aRetSup[1][3],cObsLog,aRetSup[1][7],aRetSup[1][4])
		EndIf
		
		aAdd(aRet,{lRet,aRetSup[1][2],aRetSup[1][3],""})
		
	Else
		aAdd(aRet,{lRet,"","",aRetSup[1][8]})
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return aRet
//===========================================================================================================
/*
{Protheus.doc} GrvSoliIn()
Grava solicitação de incentivo academico
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cMatricula, matricula do funcionario
@Param      aRegs, Array com a informações para a RH4
@Param      cMatSolici, matricula do solicitante
@Return     lRet
*/
Static Function GrvSoliIn(aRegs,cMatricula,cFilSolici,cMatSolici,cFilApr,cMatApr,cFilFun,cNvlApr,cCodAlc,cPrxNvl,cXStatus)
	
	Local aAreas  := {RH4->(GetArea()),RH3->(GetArea()),GetArea()}
	Local nCount  := 0
	Local nItem   := 0
	Local lRet    := .F.
	Local cRh3Cod := ""
	Local cEmail  := ""
	Local cObsLog := "Solicitação de Incentivo Academico aberta"
	
	cRh3Cod  := U_F1302201({cFilFun,"",""}, .T.)
	RH3->(DbSetOrder(1))
	If ! RH3->(DbSeek(xFilial("RH3") + cRh3Cod))
		Reclock("RH3", .T.)
		RH3->RH3_FILIAL  := cFilFun
		RH3->RH3_CODIGO  := cRh3Cod
		RH3->RH3_MAT     := cMatricula
		RH3->RH3_ORIGEM  := "PORTAL"
		RH3->RH3_STATUS  := cXStatus
		RH3->RH3_DTSOLI  := DATE()
		RH3->RH3_FILINI  := cFilSolici
		RH3->RH3_MATINI  := cMatSolici
		RH3->RH3_FILAPR  := cFilApr
		RH3->RH3_MATAPR  := cMatApr
		RH3->RH3_NVLAPR  := VAL(cNvlApr)
		RH3->RH3_KEYINI  := "002"
		RH3->RH3_EMP     := "01"
		RH3->RH3_EMPINI  := "01"
		RH3->RH3_EMPAPR  := "01"
		RH3->RH3_XTPCTM  := "007"
		RH3->RH3_XCODAL  := cCodAlc
		RH3->RH3_XPRXNV  := cPrxNvl
		RH3->(MsUnlock())
		
		U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
		
		U_F0500201(cFilSolici,cRh3Cod,"001")
		SRA->(DbSetOrder(1))
		SRA->(DbSeek(RH3->RH3_FILAPR + RH3->RH3_MATAPR))
		U_F0800901("1",SRA->RA_EMAIL,cFilFun,cRh3Cod,SRA->RA_NOME,"007","001",Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1]),cObsLog)
	EndIf
	
	RH4->(DbSetOrder(1))
	If ! RH4->(DbSeek(xFilial("RH4") + cRh3Cod))
		For nCount:= 1 To Len(aRegs)
			Reclock("RH4", .T.)
			RH4->RH4_FILIAL	:= FWxFilial("RH4")
			RH4->RH4_CODIGO	:= cRh3Cod
			RH4->RH4_ITEM		:= ++nItem
			RH4->RH4_CAMPO	:= aRegs[nCount, 1]
			IF aRegs[nCount, 1] != "PA3_XOBSER"
				RH4->RH4_VALNOV	:= IIF(EMPTY(aRegs[nCount, 2]),'',aRegs[nCount, 2])
			Else
				RH4->RH4_XOBS  	:= IIF(EMPTY(aRegs[nCount, 2]),'',aRegs[nCount, 2])
			EndIf
			RH4->(MsUnlock())
		Next
	EndIf
	If (__lSX8)
		ConfirmSx8()
		lRet := .T.
		cEmail := Posicione("SRA",1,cFilApr+cMatApr,"RA_EMAIL")
		//Grava o log de inclusão da solicitação 
		U_F0800201("1",cFilFun,cRh3Cod,cCodAlc,cFilSolici,cMatSolici,cFilApr,cMatApr,cObsLog,cEmail,cNvlApr)
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return lRet
//===========================================================================================================
// Pega as informações de quem está logado
WSMETHOD VisSuper WSRECEIVE RADepart, Matricula, Tipo WSSEND _Superi WSSERVICE W0200301
	Local aAux := {}
	Local nCnt	:= 1
	Local oSolicita
	
	aAux := RetRd4(::RADepart, ::Matricula, ::Tipo)
	
	If Len(aAux) > 0
		::_Superi := WSClassNew( "_Superior" )
		
		::_Superi:Registro := {}
		oSolicita :=  WSClassNew( "Superior" )
		For nCnt := 1 To Len(aAux)
			oSolicita:RANOME 		:= aAux[nCnt][1]
			oSolicita:RAEMAIL 	:= aAux[nCnt][2]
			oSolicita:RD4TREE    := aAux[nCnt][3]
			oSolicita:SRADEPTO   := aAux[nCnt][5]
			oSolicita:QBMATRESP  := aAux[nCnt][4]
			AAdd( ::_Superi:Registro, oSolicita )
			oSolicita :=  WSClassNew( "Superior" )
		Next
	Else
		::_Superi := WSClassNew( "_Superior" )
		
		::_Superi:Registro := {}
		oSolicita :=  WSClassNew( "Superior" )
		oSolicita:RANOME 		:= ""
		oSolicita:RAEMAIL 	:= ""
		oSolicita:RD4TREE    := ""
		oSolicita:SRADEPTO   := ""
		oSolicita:QBMATRESP  := ""
		AAdd( ::_Superi:Registro, oSolicita )
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} RetRd4()
Retorna dados do aprovador
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cDepart, departamento
@Param      cMatri, matricula
@Param      cTipo, tipo de solicitação
@Return     aAux
*/
Static Function RetRd4(cDepart,cMatri, cTipo)
	
	Local cQuery     := ''
	Local cAliasRd4  := 'RETRD4'
	Local cAliAi8    := 'RETAI8'
	Local cAliasTRE  := 'RETTRE'
	Local cAlTRE     := 'RETTRELOG'
	Local nCnt       := 1
	Local aAux       := {}
	
	If !(EMPTY(cTipo))
		cQuery := "SELECT	AI8_VISAPV "
		cQuery += "FROM	" + RetSqlName("AI8") + " AI8 "
		If cTipo == '1'
			cQuery += "WHERE  AI8_WEBSRV = 'W0200301' "
			cQuery += "       AND UPPER(AI8_ROTINA) = UPPER('U_F0200306.apw') "
		Else
			cQuery += "WHERE  AI8_WEBSRV = 'W0200301' "
			cQuery += "       AND UPPER(AI8_ROTINA) = UPPER('U_F0200301.apw') "
		EndIf
		cQuery += " AND D_E_L_E_T_ = ' '"
	Else
		cQuery := "SELECT	RH3_VISAO "
		cQuery += "FROM	" + RetSqlName("RH3") + " "
		cQuery += "WHERE	RH3_CODIGO = '" + cSolicit + "' "
		cQuery += "		AND D_E_L_E_T_ = ' '"
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAi8)
	
	DbSelectArea(cAliAi8)
	//Pega a visão cadastrada
	cVisao := (cAliAi8)->AI8_VISAPV
	(cAliAi8)->(DbCloseArea())
	
	cQuery := "SELECT RD4.RD4_TREE "
	cQuery += "FROM 	" + RetSqlName("RD4") + " RD4 "
	cQuery += "WHERE 	RD4.RD4_CODIDE = (SELECT QB_DEPTO FROM " + RetSqlName("SQB") + " WHERE QB_MATRESP = '" + cMatri + "') "
	cQuery += "		AND RD4.RD4_CODIGO = '" + cVisao + "' "
	cQuery += "		AND RD4.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlTRE)
	
	DbSelectArea(cAlTRE)
	//Pega a posição na tree da visão
	cTreeLog := (cAlTRE)->RD4_TREE
	//cTree := (cAliasTRE)->RD4_TREE
	
	(cAlTRE)->(DbCloseArea())
	
	cQuery := "SELECT RD4.RD4_TREE "
	cQuery += "FROM 	" + RetSqlName("RD4") + " RD4 "
	cQuery += "WHERE 	RD4.RD4_CODIDE = (SELECT QB_DEPTO FROM " + RetSqlName("SQB") + " WHERE QB_MATRESP = '" + cDepart + "') "
	cQuery += "		AND RD4.RD4_CODIGO = '" + cVisao + "' "
	cQuery += "		AND RD4.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRE)
	
	DbSelectArea(cAliasTRE)
	//Pega a posição na tree da visão
	cTree := (cAliasTRE)->RD4_TREE
	
	(cAliasTRE)->(DbCloseArea())
	
	cQuery := "SELECT	RD4.RD4_CODIDE, RD4.RD4_TREE,SQB.QB_MATRESP, SRA.RA_NOME, SRA.RA_EMAIL, SRA.RA_DEPTO "
	cQuery += "FROM	" + RetSqlName("RD4") + " RD4, " + RetSqlName("SQB") + " SQB, " + RetSqlName("SRA") + " SRA "
	cQuery += "WHERE	RD4.D_E_L_E_T_ = ' ' "
	cQuery += "		AND SQB.QB_DEPTO = RD4.RD4_CODIDE "
	cQuery += "		AND SQB.QB_MATRESP = SRA.RA_MAT "
	cQuery += "		AND RD4.RD4_TREE >= ( SELECT RD4.RD4_TREE "
	cQuery += "					  FROM " + RetSqlName("RD4") + " RD4 "
	cQuery += "					   WHERE RD4.RD4_FILIAL = '"+FwxFilial("RD4")+"' "
	cQuery += "					    AND RD4.RD4_CODIDE = (	SELECT QB_DEPTO "
	cQuery += "					 							FROM " + RetSqlName("SQB") + " "
	cQuery += "					 							 WHERE QB_MATRESP = '" + cMatri + "' "
	cQuery += "												   AND D_E_L_E_T_ = ' ' ) "
	cQuery += "					  AND RD4.RD4_CODIGO = '" + cVisao + "' AND RD4.D_E_L_E_T_ = ' ' "
	cQuery += "				    )	"
	cQuery += " 		AND RD4.RD4_CODIGO = '" + cVisao + "'"
	cQuery += " 		AND RD4.D_E_L_E_T_ = ' ' "
	cQuery += "Order by RD4.RD4_TREE "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRd4)
	
	DbSelectArea(cAliasRd4)
	While ! (cAliasRd4)->(EOF())
		If VAL((cAliasRd4)->RD4_TREE) <= VAL(cTree)
			AADD(aAux, {(cAliasRd4)->RA_NOME,;
				ALLTRIM((cAliasRd4)->RA_EMAIL),;
				(cAliasRd4)->RD4_TREE,;
				(cAliasRd4)->QB_MATRESP,;
				(cAliasRd4)->RA_DEPTO  })
		EndIf
		(cAliasRd4)->(DbSkip())
	End
	(cAliasRd4)->(DbCloseArea())
	
Return aAux

//===========================================================================================================
// Metodo que envia o email
WSMETHOD StatuTrmIn WSRECEIVE Matricula, Calendario WSSEND lStatus WSSERVICE W0200301
	Local aAux := {}
	
	aAux := TrmStatu(::Matricula, ::Calendario)
	
	If Len(aAux) > 0
		::lStatus := .T.
	Else
		::lStatus := .F.
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} TrmStatu()
Status do treinamento
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Param      cCodMatri, matricula do aprovador
@Param      cCodCalend, calendario do curso
@Return     aAux
*/
Static Function TrmStatu(cCodMatri, cCodCalend)
	
	Local aArea   := GetArea()
	Local nCont   := 1
	Local cQuery  := ''
	Local cAliTrm := 'TRMSTAT'
	Local aAux    := {}
	Local aAux1   := {}
	
	cQuery := "SELECT RH3_CODIGO, RH3_MAT, RH3_TIPO, RH3_ORIGEM, RH3_STATUS "
	cQuery += "FROM	" + RetSqlName("RH3") + " "
	cQuery += "WHERE RH3_MAT = '" + cCodMatri + "' AND RH3_XTPCTM = '001' AND RH3_STATUS IN ('1','4')AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTrm)
	
	DbSelectArea(cAliTrm)
	While ! (cAliTrm)->(EOF())
		AADD(aAux, {	(cAliTrm)->RH3_CODIGO,;
			(cAliTrm)->RH3_MAT,;
			(cAliTrm)->RH3_TIPO,;
			(cAliTrm)->RH3_ORIGEM,;
			(cAliTrm)->RH3_STATUS })
		(cAliTrm)->(DbSkip())
	End
	(cAliTrm)->(DbCloseArea())
	
Return aAux
// Metodo que envia o email
WSMETHOD PegSuper WSRECEIVE Matricula, Solici, LocalSol,FIRH3H4, Obs WSSEND aRetSol WSSERVICE W0200301

	Local aResult := {}
	
	BEGIN TRANSACTION
		aResult := PegSuper(::Matricula, ::Solici, ::LocalSol, ::FIRH3H4, ::Obs)
		
		If aResult[1][1]
			::aRetSol:FlAprov := aResult[1][2]
			::aRetSol:CdAprov := aResult[1][3]
			::aRetSol:lRetorn := aResult[1][1]
			::aRetSol:MsgAvso := aResult[1][8]
		Else
			::aRetSol:FlAprov := ""
			::aRetSol:CdAprov := ""
			::aRetSol:lRetorn := .F.
			::aRetSol:MsgAvso := aResult[1][8]
		EndIf
		
	END TRANSACTION
	
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
@Return     lRet
*/
Static Function PegSuper(cCodMatri, cSolicit, cLocal,cFIRH3H4, cObs)
	
	Local cCodPa3 := ''
	Local lRet    := .F.
	Local nResult := 0
	Local aAprov	:= {}
	Local cNumSol	:= "" 	// - Número da Solicitação RH
	Local cCodAlc	:= "" 	//	- Código da Alçada utilizada
	Local cFilSol	:= "" 	//	- Número da Filial do Solicitante
	Local cMatSol	:= "" 	//	- Número da Matrícula do Solcitante
	Local cFilApr	:= "" 	//	- Número da Filial do Aprovador
	Local cMatApr	:= "" 	//	- Número da Mátrícula do Aprovador
	Local cObsLog	:= "" 	//	- Observações do Log
	Local cCodAlc	:= "" 	//	- Código Alçada
	Local cPrxApr	:= "" 	//	- Nivel do Aprovador
	Local cTpSol	:= "" 	//	- Tipo Solicitação
	Local cEmailApr:= ""
	Local lGravalog	:= .F.
	Local cStatus	:= ""
	Local cNotif    := ""
	Local cNvAprv   := ""
	Local lEfetiv	:= .F.
	Local cEmails   := ""
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(cFIRH3H4 + cSolicit))
	cNumSol := RH3->RH3_CODIGO
	cCodAlc := RH3->RH3_XCODAL
	cFilSol := RH3->RH3_FILINI
	cMatSol := RH3->RH3_MATINI
	cFilApr := RH3->RH3_FILAPR
	cMatApr := RH3->RH3_MATAPR
	cCodAlc := RH3->RH3_XCODAL
	cPrxApr := RH3->RH3_XPRXNV
	cTpSol	 := RH3->RH3_XTPCTM
	
	cFilPto := RH3->RH3_XFILPO
	cCdPsto := RH3->RH3_XCODPO	
	
	U_F0801402(cFIRH3H4, cSolicit, cFilApr, cMatApr, cObs)
	
	If cPrxApr == "FM"
		aAdd(aAprov,{.T.,;		//Encontrou o aprovador?
					"",;		//Filial Aprovador
					"",; 		//Código Aprovador
					"",;		//Nível do Aprovador
					"FM",;		//Próximo Nível
					"",;		//Código da Alçada
					"",; 		//E-mail do aprovador
					"",; 		//Mensagem de retorno
					"",; 		//Filial Substituido
					""})		//Matricula Substituido
	Else
		aAprov := U_F0800501("2",cCodAlc,cPrxApr,cTpSol,,cFilSol,cMatSol,,,RH3->RH3_FILIAL,RH3->RH3_CODIGO,,,cFilPto,cCdPsto)
	EndIf
	
	cNvAprv    := aAprov[1][4]
	cEmailApr  := aAprov[1][7]
	cObsLog    := aAprov[1][8]
	cFilAprov  := aAprov[1][2]
	cMatAprov  := aAprov[1][3]
		
	If aAprov[1][1] //Encontrou o aprovador
		
		If cPrxApr == "FM"
			cNotif := "2"
		Else
			cNotif := Posicione("PAC",1,xFilial("PAC")+aAprov[1][6]+aAprov[1][4],"PAC_APRNOT")
		Endif

		If (cNvAprv == "FM" .And. cNotif == "2") .Or. (cNvAprv == "FM" .And. ("aprova direto" $ cObsLog .OR. "Terminou a estrutura da visão!" $ cObsLog ))
			lEfetiv	:= .T.
		Else
			lEfetiv	:= .F.
		EndIf
	
		If !(lEfetiv)
			
			If cLocal == '1' .OR. EMPTY(cLocal)//treinamento
				cStatus	:=  "Aprovação treinamento/evento"
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFIRH3H4 + cSolicit))
					Reclock("RH3", .F.)
					RH3->RH3_FILAPR := aAprov[1][2]
					RH3->RH3_MATAPR := aAprov[1][3]
					RH3->RH3_XPRXNV := aAprov[1][5]
					RH3->(MsUnlock())
					U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"002")
					lRet := .T.
				EndIf
			Else//incentivo
				cCodPa3 := POSICIONE("RH4",1,cFIRH3H4 + cSolicit + '2', "RH4_VALNOV")
				
				PA3->(DbSetOrder(3))
				If PA3->(DbSeek(xFilial("PA3") + cCodPa3))
					Reclock("PA3", .F.)
					PA3->PA3_RSPAPR := aAprov[1][3]
					PA3->(MsUnlock())
				EndIf
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFIRH3H4 + cSolicit))
					Reclock("RH3", .F.)
					RH3->RH3_FILAPR := aAprov[1][2]
					RH3->RH3_MATAPR := aAprov[1][3]
					RH3->RH3_XPRXNV := aAprov[1][5]
					RH3->(MsUnlock())
					U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"002")
					lRet := .T.
				EndIf
			EndIf
			If lRet
				//Grava o log de aprovação da solicitação 
				U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmailApr,cNvAprv)
				
				//ENVIA EMAIL
				//Envia e-mail para o solicitante
				
				DbSelectArea("SRA")
				SRA->(DbSetOrder(1))
				SRA->(DbSeek(cFilSol+cMatSol))
				DbSelectArea("PAB")
				PAB->(DbSetOrder(1))
				PAB->(DbSeek(xFilial("PAB")+cCodAlc))
				If EMPTY(cObsLog)
					cObsLog := cObs
				EndIf
				U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)
				U_F0800901("3",SRA->RA_EMAIL,cFilSol,cNumSol,SRA->RA_NOME,cTpSol,PAB->PAB_GRPSOL,cNvAprv,cObsLog)
			EndIf
			
		Else //EFETIVAÇÃO PARA O RH
			
			If cLocal == '1'  .OR. EMPTY(cLocal)
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFIRH3H4 + cSolicit))
					U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"005")
					Reclock("RH3", .F.)
					RH3->RH3_STATUS := "4"
					RH3->(MsUnlock())
					lRet := .T.
				EndIf
			Else
				cCodPa3 := POSICIONE("RH4",1,cFIRH3H4 + cSolicit + '2', "RH4_VALNOV")
					
				PA3->(DbSetOrder(3))
				If PA3->(DbSeek(xfilial("PA3") + cCodPa3))
					Reclock("PA3", .F.)
					PA3->PA3_XSTATUS	:= "1"
					PA3->(MsUnlock())
				EndIf
				RH3->(DbSetOrder(1))
				If RH3->(DbSeek(cFIRH3H4 + cSolicit))
					U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"005")
					Reclock("RH3", .F.)
					RH3->RH3_STATUS	:= "4"
					RH3->(MsUnlock())
					lRet := .T.
				EndIf
			EndIf
			If lRet
				PAB->(DbSetOrder(1))
				PAB->(DbSeek(xFilial("PAB") + RH3->RH3_XCODAL))
					//Grava o log de Efetivação da solicitação 
				U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmailApr,"FM")
				//FsEnvRh()//Envia e-mail para o Rh Aprovar
			EndIf
		EndIf
	Else //CANCELAMENTO
				//cancela
		RH3->(DbSetOrder(1))
		If RH3->(DbSeek(cFIRH3H4 + cSolicit))
			Reclock("RH3",.F.)
			RH3->RH3_STATUS := "3"
			RH3->RH3_NVLAPR := 99
			RH3->RH3_FILAPR := ""
			RH3->RH3_MATAPR := ""
			If RH3->(ColumnPos("RH3_EMPAPR")) > 0
				RH3->RH3_EMPAPR	:= ""
			EndIf
			RH3->(MsUnlock())
			lGravalog := .T.
		Endif
		If lGravalog
			//Grava o log de cancelamento da solicitação 
			U_F0800201("2",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,"",cNvAprv)
			
			DbSelectArea("PAB")
			PAB->(DbSetOrder(1))
			PAB->(DbSeek(xFilial("PAB")+cCodAlc))
			If EMPTY(cObsLog)
				cObsLog := cObs
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
							cObsLog := cObs
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
		EndIf
	EndIf

Return aAprov
//===========================================================================================================
// Metodo que envia o email
WSMETHOD InfInsti WSRECEIVE NULLPARAM WSSEND _Inst WSSERVICE W0200301
	Local aAux      := {}
	Local nCnt      := 1
	Local oSolicita := nil
	aAux := InfInstit()
	
	If Len(aAux) > 0
		::_Inst := WSClassNew( "_Institu" )
		
		::_Inst:Registro := {}
		oSolicita :=  WSClassNew( "Institu" )
		For nCnt := 1 To Len(aAux)
			oSolicita:RA0ENTIDA  := aAux[nCnt][1]
			oSolicita:RA0DESC    := aAux[nCnt][2]
			AAdd( ::_Inst:Registro, oSolicita )
			oSolicita :=  WSClassNew( "Institu" )
		Next
	Else
		::_Inst := WSClassNew( "_Institu" )
		
		::_Inst:Registro := {}
		oSolicita :=  WSClassNew( "Institu" )
		oSolicita:RA0ENTIDA  := ""
		oSolicita:RA0DESC    := ""
		AAdd( ::_Inst:Registro, oSolicita )
	EndIf
	
Return .T.
//===========================================================================================================
/*
{Protheus.doc} InfInstit()
Monta combo com as intituições cadastradas
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_003
@Return     aAux
*/
Static Function InfInstit()
	Local cQuery  := ''
	Local cAlRa0  := 'RETRA0'
	Local nCnt    := 1
	Local aAux    := {}
	
	cQuery := "SELECT RA0_ENTIDA, RA0_DESC "
	cQuery += "FROM " + RetSqlName("RA0") + " "
	cQuery += "WHERE	D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlRa0)
	DbSelectArea(cAlRa0)
	While !(cAlRa0)->(EOF())
		AADD(aAux, {(cAlRa0)->(RA0_ENTIDA),(cAlRa0)->(RA0_DESC)})
		(cAlRa0)->(DbSkip())
	End
	(cAlRa0)->(DbCloseArea())
	
Return aAux
//===========================================================================================================
// Metodo que envia o email
WSMETHOD PegViInv WSRECEIVE Matricula, Solici, LocalSol,FIRH3H4, Obs, FilAtu, MatAtu WSSEND _SupInf WSSERVICE W0200301
	Local aAux      := {}
	Local nCnt      := 1
	Local oSolicita := NIL
	BEGIN TRANSACTION
		aAux := PegViInv(::Matricula, ::Solici, ::LocalSol, ::FIRH3H4, ::Obs, ::FilAtu, ::MatAtu)
	
		If Len(aAux) > 0
			::_SupInf := WSClassNew( "_SupEmail" )
		
			::_SupInf:Registro := {}
			oSolicita :=  WSClassNew( "SupEmail" )
			For nCnt := 1 To Len(aAux)
				oSolicita:QBMATRESP := aAux[nCnt][1]
				oSolicita:RANOME    := aAux[nCnt][2]
				oSolicita:RAEMAIL   := aAux[nCnt][3]
				AAdd( ::_SupInf:Registro, oSolicita )
				oSolicita :=  WSClassNew( "SupEmail" )
			Next
		Else
			::_SupInf := WSClassNew( "_SupEmail" )
		
			::_SupInf:Registro := {}
			oSolicita :=  WSClassNew( "SupEmail" )
			oSolicita:QBMATRESP := ""
			oSolicita:RANOME    := ""
			oSolicita:RAEMAIL   := ""
			AAdd( ::_SupInf:Registro, oSolicita )
			oSolicita :=  WSClassNew( "SupEmail" )
		EndIf
	END TRANSACTION
Return .T.
//===========================================================================================================
/*
{Protheus.doc} PegViInv()
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

Static Function PegViInv(cCodMatri, cSolicit, cLocal,cFIRH3H4, cObs, cFilAtu, cMatAtu) 
	
	Local nCont    := 1
	Local cQuery   := ''
	Local cCodPa3  := ''
	Local cTipVis  := ''
	Local cFilSol  := ''
	Local cConc    := "+"
	Local lNOracle := TCGetDB() != 'ORACLE'
	Local aAux     := {}
	Local cObsLog  := ""
	Local cNumSol  := "" 	// - Número da Solicitação RH
	Local cCodAlc  := "" 	//	- Código da Alçada utilizada
	Local cFilSol  := "" 	//	- Número da Filial do Solicitante
	Local cMatSol  := "" 	//	- Número da Matrícula do Solcitante
	Local cFilApr  := "" 	//	- Número da Filial do Aprovador
	Local cMatApr  := "" 	//	- Número da Mátrícula do Aprovador
	Local cObsLog  := "" 	//	- Observações do Log
	Local cCodAlc  := "" 	//	- Código Alçada
	Local cNvAprv  := "" 	//	- Nivel do Aprovador
	Local cTpSol   := "" 	//	- Tipo Solicitação
	Local cFilPa2  := ""    //  - Filial da PA2
	Local lReprova := .F.
	Local cEmails  := ""
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(cFIRH3H4 + cSolicit))
	cNumSol	:= RH3->RH3_CODIGO
	cCodAlc	:= RH3->RH3_XCODAL
	cFilSol	:= RH3->RH3_FILINI
	cMatSol	:= RH3->RH3_MATINI
	cFilApr	:= RH3->RH3_FILAPR
	cMatApr	:= RH3->RH3_MATAPR
	cCodAlc	:= RH3->RH3_XCODAL
	cNvAprv	:= Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1])
	cTpSol  := RH3->RH3_XTPCTM	
	
	U_F0801402(cFIRH3H4, cSolicit, cFilApr, cMatApr, cObs)
	
	If !lNOracle
		cConc := "||"
	EndIf
	
	If cLocal == '1' .OR. EMPTY(cLocal) // TREINAMENTO / EVENTO
		RH3->(DbSetOrder(1))
		If RH3->(DbSeek(cFIRH3H4 + cSolicit))
			U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004")
			Reclock("RH3", .F.)
			RH3->RH3_STATUS	:= "3"
			RH3->RH3_XFILAP := cFilAtu
			RH3->RH3_XMATAP := cMatAtu
			RH3->(MsUnlock())
			lReprova := .T.
		EndIf
		
	Else
		If cLocal == '2' //INCENTIVO ACADEMICO
			
			cCodPa3 := POSICIONE("RH4",1,cFIRH3H4 + cSolicit + '2', "RH4_VALNOV")
			cStatus	:= "Rejeição Incentivo Acadêmico"
			PA3->(DbSetOrder(3))
			If PA3->(DbSeek(xfilial("PA3") + cCodPa3))
				Reclock("PA3", .F.)
				PA3->PA3_XSTATUS	:= "2"
				PA3->(MsUnlock())
			EndIf
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFIRH3H4 + cSolicit))
				Reclock("RH3", .F.)
				RH3->RH3_STATUS := "3"
				RH3->RH3_XFILAP := cFilAtu
				RH3->RH3_XMATAP := cMatAtu
				RH3->(MsUnlock())
				lReprova := .T.
				
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004",cFilAtu,cMatAtu) // 416094 - Rogerio Carvalho DOR05180599 (cFilAtu e cMatAtu))
			EndIf
			
		EndIf
		If cLocal == '004' //FAP
			cStatus	:= "Rejeição da FAP"
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFIRH3H4 + cSolicit))
				Reclock("RH3", .F.)
				RH3->RH3_STATUS	:= "3"
				RH3->RH3_XFILAP := cFilAtu
				RH3->RH3_XMATAP := cMatAtu
				RH3->(MsUnlock())
				lReprova := .T.
				
				cFilPa2 := ALLTRIM(POSICIONE("RH4",1,cFIRH3H4 + cSolicit + "  1", "RH4_VALNOV"))
				
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004",cFilAtu,cMatAtu) // 416094 - Rogerio Carvalho DOR05180599 (cFilAtu e cMatAtu))
				U_F0500302(cFilPa2, RH3->RH3_FILIAL,cSolicit,"RP")			
			EndIf
		EndIf
		If cLocal == '005' //DESLIGAMENTO
			cStatus	:= "Rejeição do Desligamento"
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFIRH3H4 + cSolicit))
				Reclock("RH3", .F.)
				RH3->RH3_STATUS	:= "3"
				RH3->RH3_XFILAP := cFilAtu
				RH3->RH3_XMATAP := cMatAtu
				RH3->(MsUnlock())
				lReprova := .T.
				
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004",cFilAtu,cMatAtu) // 416094 - Rogerio Carvalho DOR05180599 (cFilAtu e cMatAtu))
				U_F0500110(cSolicit,"3", RH3->RH3_FILIAL)
				
			EndIf
			
		EndIf
		If cLocal == '006' // Movimentação de Pessoal
			cStatus	:= "Rejeição de Movimentação de Pessoal"
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFIRH3H4 + cSolicit))
				Reclock("RH3", .F.)
				RH3->RH3_STATUS	:= "3"
				RH3->RH3_XFILAP := cFilAtu
				RH3->RH3_XMATAP := cMatAtu
				RH3->(MsUnlock())
				lReprova := .T.
				
				// U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004") // 416094 - Rogerio Carvalho DOR05180599 (cFilAtu e cMatAtu)
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004",cFilAtu,cMatAtu) // 416094 - Rogerio Carvalho DOR05180599 (cFilAtu e cMatAtu)
				U_F0500407(RH3->RH3_FILIAL,RH3->RH3_MAT,cSolicit,RH3->RH3_VISAO)
				
			EndIf
		EndIf
		If cLocal == '008' // Férias
			RH3->(DbSetOrder(1))
			If RH3->(DbSeek(cFIRH3H4 + cSolicit))
				Reclock("RH3", .F.)
				RH3->RH3_STATUS	:= "3"
				RH3->RH3_XFILAP := cFilAtu
				RH3->RH3_XMATAP := cMatAtu
				RH3->(MsUnlock())
				lReprova := .T.
				
				U_F0500201(RH3->RH3_FILIAL,RH3->RH3_CODIGO,"004",cFilAtu,cMatAtu) // 416094 - Rogerio Carvalho DOR05180599 (cFilAtu e cMatAtu))
				U_F0500407(RH3->RH3_FILIAL,RH3->RH3_MAT,cSolicit,RH3->RH3_VISAO)
			EndIf
		EndIf
		
	EndIf
	
	If lReprova
	
		If RH3->(DbSeek(cFIRH3H4 + cSolicit))
			If RH3->RH3_XSUBST == "S" //Se Houve Substituição
				U_F1301111(Self:Solicitacao:FilialVg,Self:Solicitacao:CodSolVg,2) //Historico do Substituto	
				Reclock("RH3", .F.)	
				RH3->RH3_XSUBST := ""
				RH3->RH3_XFILSU := ""
				RH3->RH3_XMATSU := ""
				RH3->(MsUnlock())
			EndIf
		EndIf
	
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		SRA->(DbSeek(cFilSol+cMatSol))
		
		//Grava o log de Rejeição da solicitação 
		U_F0800201("4",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,SRA->RA_EMAIL,cNvAprv)
		
		DbSelectArea("PAB")
		PAB->(DbSetOrder(1))
		PAB->(DbSeek(xFilial("PAB")+cCodAlc))
		If EMPTY(cObsLog)
			cObsLog := cObs
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
						cObsLog := cObs
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
	  	
		U_F0800901("4",cEmails,cFilSol,cNumSol,SRA->RA_NOME,cTpSol,PAB->PAB_GRPSOL,"",cObsLog)
		
	EndIf
	
Return aAux
//===========================================================================================================

Static Function FsEnvRh()

	Local aArea := GetArea()
	Local cAssunto := "Aguardando efetivação RH"

	cBody := '<html><body><pre>'+CRLF
	cBody += "Existem solicitações para analise do RH, por favor acessar pelo ERP "+CRLF
	cBody += '</pre></body></html>'
	
	U_F0200304(cAssunto, cBody, cEmails)

	RestArea(aArea)

Return
