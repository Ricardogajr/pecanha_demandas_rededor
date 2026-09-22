#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"

#DEFINE OPERATION_INSERT  1
#DEFINE OPERATION_VIEW    2
#DEFINE OPERATION_APROVE  3
#DEFINE OPERATION_RPROVE  4
#DEFINE PAGE_LENGTH 10

/*
{Protheus.doc} F0100308()
Webservice responsavel pelo portal e comunicação com protheus
@Author     Bruno de Oliveira
@Since		07/10/2016 
@Version    P12.1.7
@Project    MAN00000462901_EF_003
*/
User Function F0100308()
Return
//==================================================================================================================
WSSTRUCT SolicitVag
	WSDATA FilialVg		As String			OPTIONAL	//Filial
	WSDATA CodSolVg	 	As String			OPTIONAL	//Codigo da Solicitacao
	WSDATA CodDepto		As String			OPTIONAL	//Codigo do Departamento
	WSDATA DscDepto     As String			OPTIONAL	//Descrição do Departamento
	WSDATA FilPosto		As String			OPTIONAL	//Filial do Posto
	WSDATA CodPosto 	As String			OPTIONAL	//Codigo do Posto
	WSDATA CodMatric	As String			OPTIONAL	//Codigo da matricula
	WSDATA DataSolic 	As Date				OPTIONAL	//Data da solicitação
	WSDATA DataRespost	As Date				OPTIONAL	//Data do atendimento
	WSDATA Status    	As String			OPTIONAL	//Status da solicitacao TRequestStatus- 1=Solicitada;2=Atendida pelo RH;3=Reprovada;4=Aguardando Efetivacao do RH
	WSDATA NvlInicial	As Integer			OPTIONAL	//Nivel Inicial de Aprovacao
	WSDATA FilSolic		As String			OPTIONAL	//Filial do Solicitante
	WSDATA MatSolic		As String			OPTIONAL	//Matricula do Solicitante
	WSData NomeSolic    As String			OPTIONAL	//Nome do Solicitante
	WSDATA ChavSolic	As String			OPTIONAL	//Chave de busca do solicitante
	WSDATA NvlAprov		As Integer			OPTIONAL	//Nivel de aprovacao atual
	WSDATA FilAprov     As String			OPTIONAL	//Filial do Aprovador
	WSDATA MatAprov		As String			OPTIONAL	//Matricula do Aprovador
	WSDATA NomeAprov	As String			OPTIONAL	//Nome do Aprovador
	WSDATA VisaoOrg		As String			OPTIONAL	//Visao para aprovacao
	WSDATA Source		As String			OPTIONAL	//Origem - Se passou pelo RH ou não
	WSDATA ParticRH     As String			OPTIONAL	//Participante
	WSDATA Empresa      As String           OPTIONAL	//empresa solicitante
	WSDATA EmpAprov     As String           OPTIONAL	//empresa aprovador
	WSData Vaga			As String			OPTIONAL	//Tipo da Vaga 1=Aumento de Quadro;2=Substituição
	WsData DscVaga		As String			OPTIONAL	//Descrição da Vaga
	WSDATA CodCC		As String			OPTIONAL	//Codigo do Centro de Custo
	WSDATA CodFunc		As String			OPTIONAL	//Codigo da Funcao
	WSDATA CodCargo		As String			OPTIONAL	//Codigo do Cargo
	WSDATA PrazoVaga	As String			OPTIONAL	//Prazo da vaga
	WSDATA DatAbertura	As Date				OPTIONAL	//Data abertura da Vaga
	WSDATA DatFecham	As Date				OPTIONAL	//Data Fechamento da Vaga
	WSDATA CustoVaga	As String			OPTIONAL	//Salario(Custo da vaga)
	WSDATA ProcSelet	As String			OPTIONAL	//Codigo do Processo Seletivo
	WSDATA TpVaga		AS String			OPTIONAL	//Tipo da Vaga 1=Int\Ext; 2=Interna; 3=Externa

	WSDATA TurnoTab		As String			OPTIONAL	//Turno de Trabalho
	WSDATA HorMes		As String			OPTIONAL	//Hora Mês
	WSDATA HorSem		As String			OPTIONAL	//Horas Semanais
	WSDATA SalHora		As String			OPTIONAL	//Salario Hora
	WSDATA CatFun		As String			OPTIONAL	//Categoria funcional
	WSDATA TpContr		As String			OPTIONAL	//Tipo de Contrato 1=Determinado;2=Indeterminado
	WSDATA XObs			As String			OPTIONAL	//Observação
	
	WSDATA lRet			As String			OPTIONAL	//Retorno do webservice
	WSDATA TpRj			As String			OPTIONAL	//Tipo de Rejeição 1=Cancelamento;2=Suspenção
	
	WSDATA PrxNivel		As String			OPTIONAL	//Próximo Nível
	WSDATA CodAlcad		As String			OPTIONAL	//Código da Alçada
	WSDATA FilAtu		As String				
	WSDATA MatAtu		As String
ENDWSSTRUCT

WsStruct VagDados
	WsData FilVag	 As String
	WSData Vaga	     As String
	WsData Descr	 As String
	WsData Depto	 As String
	WsData DescDpt   As String
	WsData DescCc	 As String
	WsData Posto	 As String
	WsData FlPost	 As String
	WSDATA CodCC	 As String
	WSDATA Funcao	 As String
	WSDATA DescFu	 As String
	WSDATA NomeSol   As String
	WSDATA Prazo	 As String
	WSDATA DtAbt	 As String
	WSDATA DtFch	 As String
	WSDATA CustVg	 As String
	WSDATA ProcS	 As String
	WSDATA TpVaga	 AS String
	WSDATA CodSolic  As String
	WSDATA TurnoTab  As String
	WSDATA HorMes    As String
	WSDATA HorSem    As String
	WSDATA SalHora   As String
	WSDATA CatFun    As String
	WSDATA TpContr   As String
	WSDATA Ret	     As String
	WSDATA XObs      As String
	WSDATA ObserDet  AS String
	WSDATA CODCARGO  AS String
	WSDATA DESCRCARGO  AS String
	WSDATA DscCateg  As String
	WSDATA DscTurno  As String
	WSDATA DscFilPt  AS String
	WSDATA StatusS   AS String   
EndWSStruct

WsStruct MnhVgSolic
	WsData CdSolic As String
	WsData DataSol As String
	WsData Status  As String
	WsData FilCdSl As String
	WSDATA STATVGS AS String
EndWsStruct

WsStruct AMnhVgSl
	WsData aMnhVag As Array Of MnhVgSolic
EndWsStruct

WsStruct ARetSolict
	WsData CdSolic As String
	WsData DataSol As String
	WsData lRetorn As String
	WsData MsgAvso As String
EndWsStruct

WsStruct ApRepVaga
	WsData CodApRp As String
	WsData DtSolic As String
	WsData StatSol As String
	WsData AcaoSol As String
	WsData FilSolc As String
EndWsStruct

WsStruct AApRepVag
	WsData aApRep As Array Of ApRepVaga
EndWsStruct

WSSTRUCT InfRh3
	WSDATA RH3VISAO   AS String
	WSDATA RH3FILINI  AS String
	WSDATA RH3MATINI  AS String
	WSDATA RH3FILAPR  AS String
	WSDATA RH3MATAPR  AS String
ENDWSSTRUCT

WsStruct SolicitQdr
	WSDATA FilialQdr	As String	OPTIONAL	//Filial
	WSDATA CodSolic	 	As String	OPTIONAL	//Codigo da Solicitacao
	WSDATA CodDepto		As String	OPTIONAL	//Codigo do Departamento
	WSDATA CodMatric	As String	OPTIONAL	//Codigo da matricula
	WSDATA DataSolic 	As Date		OPTIONAL	//Data da solicitação
	WSDATA DataRespost	As Date		OPTIONAL	//Data do atendimento
	WSDATA Status    	As String	OPTIONAL	//Status da solicitacao TRequestStatus- 1=Solicitada;2=Atendida pelo RH;3=Reprovada;4=Aguardando Efetivacao do RH
	WSDATA NvlInicial	As Integer	OPTIONAL	//Nivel Inicial de Aprovacao
	WSDATA FilSolic		As String	OPTIONAL	//Filial do Solicitante
	WSDATA MatSolic		As String	OPTIONAL	//Matricula do Solicitante
	WSData NomeSolic    As String	OPTIONAL	//Nome do Solicitante
	WSDATA ChavSolic	As String	OPTIONAL	//Chave de busca do solicitante
	WSDATA NvlAprov		As Integer	OPTIONAL	//Nivel de aprovacao atual
	WSDATA FilAprov     As String	OPTIONAL	//Filial do Aprovador
	WSDATA MatAprov		As String	OPTIONAL	//Matricula do Aprovador
	WSDATA VisaoOrg		As String	OPTIONAL	//Visao para aprovacao
	WSDATA ParticRH     As String	OPTIONAL	//Participante
	WSDATA Empresa      As String   OPTIONAL	//empresa solicitante
	WSDATA EmpAprov     As String   OPTIONAL	//empresa aprovador
	WSDATA CdFuncao		As String	OPTIONAL	//Código da Função
	WSDATA CdCargo		As String	OPTIONAL	//Código do cargo
	WSDATA CdCentCt		As String	OPTIONAL	//Código do Centro de custo
	WSDATA Salario		As String	OPTIONAL	//Salario
	WSDATA TpContr		As String	OPTIONAL	//Tipo de contrato
	WSDATA QntQdro		As String	OPTIONAL	//Quantidade do aumento de quadro
	WSDATA TpPosto		As String	OPTIONAL	//Tipo de posto
	WSDATA Observ		As String	OPTIONAL	//Observação
	WSDATA CdPost       AS String	OPTIONAL	//Código do Posto
	WSDATA NvPost       As String	OPTIONAL	//Novo Posto
	WSDATA FilPosto     As String  OPTIONAL    //Filial do Posto
	WSDATA DescCg       As String  OPTIONAL   //Descrição centro de custo
	WSDATA DescDp       As String  OPTIONAL   //Descrição departamento
	WSDATA PrxNivel     As String  OPTIONAL		//Proximo nivel do aprovador
	WSDATA CodAlcad     As String  OPTIONAL		//Código da Alçada
	WSDATA FilAtu		As String	OPTIONAL			
	WSDATA MatAtu		As String	OPTIONAL
	WSDATA AlPostRepor  AS String   OPTIONAL
	WSDATA AlDesDpRepor AS String   OPTIONAL
	WSDATA AlDepRepor   AS String   OPTIONAL
	WSDATA AlDescRepor  AS String   OPTIONAL
	WSDATA AlFilRepor   AS String   OPTIONAL
	WSDATA AlFilSol     AS String   OPTIONAL
	WSDATA AlDescSol    AS String   OPTIONAL
	WSDATA AlDeptSol    AS String   OPTIONAL
	WSDATA AlDescDeptSol AS String  OPTIONAL
				
EndWsStruct

WsStruct QdrDados
	WSDATA FilQdr	As String OPTIONAL //Filial do Aumento de Quadro
	WSDATA CdDept	As String OPTIONAL //Código do Departamento
	WSDATA DsDept	As String OPTIONAL //Descrição do Departamento
	WSDATA CdFunc	As String OPTIONAL //Código da Função
	WSDATA DsFunc	As String OPTIONAL //Descrição da função
	WSDATA CdCarg	As String OPTIONAL //Código do cargo
	WSDATA DsCarg	As String OPTIONAL //Descrição do cargo
	WSDATA CdCCtt	As String OPTIONAL //Código do Centro de custo
	WSDATA DscCtt	As String OPTIONAL //Descrição do centro de custo
	WSDATA Salari	As String OPTIONAL	//Salario
	WSDATA TpCont	As String OPTIONAL	//Tipo de contrato
	WSDATA QntQdr	As String OPTIONAL	//Quantidade do aumento de quadro
	WSDATA TpPost	As String OPTIONAL	//Tipo de posto
	WSDATA Observ	As String OPTIONAL	//Observação
	WSDATA CodPst	As String OPTIONAL	//Código do Posto
	WSDATA OrigSl	As String OPTIONAL	//Origem da Solicitação
	WSDATA StatusS  As String OPTIONAL  //Status	
	WSDATA AlPstRpr  AS String   OPTIONAL
	WSDATA AlDsDpRpr AS String   OPTIONAL
	WSDATA AlDpRpr   AS String   OPTIONAL
	WSDATA AlDscRpr  AS String   OPTIONAL
	WSDATA AlFlRpr   AS String   OPTIONAL
	WSDATA AlFlSl     AS String   OPTIONAL
	WSDATA AlDscSl    AS String   OPTIONAL
	WSDATA AlDptSl    AS String   OPTIONAL
	WSDATA AlDscDptSl AS String  OPTIONAL
EndWsStruct

WsStruct FaixSal
	WsData NIVEL  As String
	WsData FAIXA  As String
	WsData VALOR  As String
EndWsStruct

WsStruct _FaixSal
	WsData Registro As Array Of FaixSal
EndWsStruct

WsStruct CentroCusto
	WsData CodCC  As String
	WsData DescC  As String
EndWsStruct

WsStruct IdVaga
	WsData Q3FILIAL As String
	WsData Q3CARGO  As String
	WsData Q3CC     As String
EndWsStruct

WsStruct Aprovs
	WSDATA NvlAprov	 As Integer OPTIONAL	//Nivel de aprovacao atual
	WSDATA FilAprov	 As String  OPTIONAL	//Filial do Aprovador
	WSDATA MatAprov	 As String  OPTIONAL	//Matricula do Aprovador
	WSDATA NomeAprov As String  OPTIONAL	//Nome do Aprovador
	WSDATA EmpAprov	 As String  OPTIONAL	//empresa aprovador
EndWsStruct

WsStruct InfUser
	WsData aInfUser As Array Of InfUser
EndWsStruct

WSSTRUCT _Ocupantes
	WSDATA Filial		    	AS String	OPTIONAL
	WSDATA Matricula	    	AS String	OPTIONAL
	WSDATA Nome			   	AS String	OPTIONAL
ENDWSSTRUCT

WSSTRUCT DtPostos
	WSDATA PostoEmp		 	As String						//Empresa do posto
	WSDATA PostFilial			As String						//Filial do posto
	WSDATA Posto				As String 	   				    //Posto
	WSDATA CodDepto			As String 	   				    //Departamento
	WSDATA DescrDepto			AS String 			 		    //Descricao do Departamento
	WSDATA Tipo				AS String  			 			//tipo do posto
	WSDATA DescrTipo			AS String						//Descricao do Tipo
	WSDATA Qtd					AS Integer 			 			//quantidade
	WSDATA Ocupado			AS Integer 			 			//Qtd ocupada
	WSDATA CodCargo			AS String 			 		    //Codigo do Cargo
	WSDATA DescrCargo			AS String 			 		    //Descricao do Cargo
	WSDATA CodFuncao			AS String 			 		    //Codigo da funcao
	WSDATA DescrFuncao		AS String 			 		    //Descricao da funcao
	WSDATA CC					AS String 			 		    //Centro de Custo
	WSDATA DescrCC			AS String 			 		    //Descricao do Centro de Custo
	WSDATA TipoContrato		AS String 			 		    //Tipo Contrato
	WSDATA Salario			AS Float 			 			//Salario
	WSDATA CodStatus			AS String	OPTIONAL	 		//Status
	WSDATA Status				AS String	OPTIONAL	 		//Descri
	WSDATA Ocupantes			AS Array Of _Ocupantes OPTIONAL //Lista de Ocupantes do Posto
	WSDATA NovaContr    		AS String	OPTIONAL	 		//Gera nova contrat
	WSDATA PossuiSolic      	AS Boolean OPTIONAL	     	//Possui Solicitacao para este posto?
	WSDATA Responsavel      	AS String OPTIONAL	     	//Respons?l pelo Posto
	WSDATA DescFil      	AS String OPTIONAL	     	//Nome Filial do Posto
	WSDATA Reserv      		AS Integer 	     	//Postos Reservados
ENDWSSTRUCT

WSSTRUCT _PostData
	WSDATA ListOfPosts		AS Array Of DtPostos 		OPTIONAL
	WSDATA PagesTotal			AS Integer 					OPTIONAL
ENDWSSTRUCT

WSSTRUCT DtDepartment
	WSDATA DepartmentEmp		As String				//Empresa do departamento
	WSDATA DepartmentFilial 	As String				//Filial do departamento
	WSDATA Department			As String  				//Departamento do Funcionario
	WSDATA DescrDepartment  	AS String  	OPTIONAL	//Departamento
	WSDATA KeyVision	    	AS String  	OPTIONAL	//Visao
	WSDATA TotalRegistros   	As Integer 	OPTIONAL 	//Total de registros para paginacao
	WSDATA FilPostoVis		 		As String	OPTIONAL	//filial Postos
	WSDATA PostoVis		 		As String	OPTIONAL	//Postos da Vi
ENDWSSTRUCT

WSSTRUCT _DepartmentData
	WSDATA ListOfDepartment	AS Array Of DtDepartment	OPTIONAL
	WSDATA PagesTotal			AS Integer 					OPTIONAL
ENDWSSTRUCT

WsService W0500308 Description "WebService Server para solicitação de vagas"

	WsData wsNull       As String
	WsData Solicitacao	As SolicitVag
	WsData VDado        As VagDados
	WsData AumentQdro	AS SolicitQdr
	WsData QdroSolict	As QdrDados
	WsData IDSolic		As ARetSolict
	WsData Matricul		As String
	WsData MinhaVgs 	As AMnhVgSl
	WsData AprovVgs		As AApRepVag
	WsData lRet			As Boolean
	WsData FilialS      As String
	WsData CodSolic		As String
	WsData FilialAp		As String
	WsData Visao		As String
	WsData nOperac		As Integer
	WsData TpSolic		As String
	WSDATA _InfRh3      AS InfRh3
	WsData cPosto		As String
	WsData cFilP		As String
	WsData cDepto		As String
	WsData nOcup		As Integer
	WsData nQntd		As Integer
	WsData MatricAp     As String
	WsData EmpFun		As String
	WsData aAprovador   As Aprovs
	WSDATA _FxSal      AS _FaixSal
	WSDATA cRet        As String
	WSDATA CODVAGA     AS String
	WSDATA ValMenm     As String
	WSDATA TpSit	   As String
	//WSDATA cFilP     AS String
	WSDATA _IdVaga   AS IdVaga
	WSDATA FilialPosto AS String
	WSDATA CodPosto   AS String
	WSDATA _CentroCusto AS CentroCusto
	WSDATA CODCARGO  AS String
	WSDATA nTotal    AS Integer
	WSDATA PostUsr	 AS String
	WSDATA FilPosto  AS String
	
	WSDATA Pendentes	As boolean        	OPTIONAL
	WSDATA Aprovadas 	As boolean        	OPTIONAL
	WSDATA Reprovadas   As boolean        	OPTIONAL
	WSDATA PossuiPost   As boolean
	WSDATA	MsgRet	  as String

	WSDATA FilUsr  AS String
	WSDATA Matric  AS String
	
	WSDATA CompanyID     AS String optional
	WSDATA DepartmentID  AS String optional
	WSDATA PostID        AS String optional
	WSDATA Page          AS Integer optional
	WSDATA FilterField   AS String optional
	WSDATA FilterValue   AS String optional
	WSDATA RequestType   AS String optional
	WSDATA EmployeeFil   AS String optional
	WSDATA Registration  AS String optional
	WSDATA PostoVis      AS String optional
	WSDATA PostDataD			as _PostData		//Postos
	WSDATA DepartmentDt	as _DepartmentData	//Departamentos
	
	WSDATA ParticipantID AS String optional
	WSDATA Vision        AS String optional
	WSDATA ControlPost   AS String optional
	WSDATA FilPotVis     AS String optional
	
	WSDATA cFSolicitacao AS String 
	WSDATA cCSolicitacao AS String
	WSDATA cMotivCanceld AS String
	WSDATA cFlSolicitant AS String
	WSDATA cMtSolicitant AS String
	
	WsMethod InstSolict Description "Insere solicitação de vaga para rh"
	WsMethod AprSolVaga Description "Aprova a solicitação da vaga"
	WsMethod RepSolVaga Description "Reprova a solicitação da vaga"
	WsMethod MinhSolict Description "Solicitações realizadas"
	WsMethod SolicApRp  Description "Solicitações da minha equipe"
	WsMethod BscSolVags Description "Busca as solicitações realizadas"
	WsMethod InfSolVg   Description "Pega informação referente a solicitação selecionada"
	WsMethod InsSolQdro Description "Insere solicitação de aumento de quadro(posto)"
	WsMethod AprSolQdro Description "Aprova a solicitação de aumento"
	WsMethod RepSolQdro Description "Reprova a solicitação de aumento"
	WsMethod BscSolQdro Description "Busca as solicitações realizadas"
	WsMethod VerPostSol Description "Verifica se o posto possui solicitação"
	WsMethod VerAprvSit Description "Verifica a situação do departamento"
	WsMethod InfFxSl    Description "Retorna a tabela de faixa salarial"
	WsMethod PegMnem    Description "Retorna valor do mnêmonico M_PERCTOL"
	WsMethod GetDepto   Description "Pega o departamento do solicitante"
	WsMethod VgDescDet  Description "Retorna descrição detalhada da vaga"
	WSMETHOD VerificaPosto Description "Verifica se existe posto vinculado com a vaga"
	WSMETHOD BsCntrCusto   Description "Gatilho que passa o centro de custo com base no cargo passado"
	WSMETHOD BuscDepto   Description "Busca valor de solicitações que estão para aquele departamento e posto"
	WSMETHOD RetInfUsr   Description "Busca Informas do Usuo"
	WSMETHOD GetPostosD		DESCRIPTION "Metodo que retorna os os Postos de um departamento"
	WSMETHOD GetDepartmentD DESCRIPTION "Metodo que retorna os departamentos e seus postos"
	WSMETHOD CancSolic  Description "Cancelamento da Solicita?"
	WSMETHOD BscParametr Description "Busca parametros"
	
EndWsService

WsMethod BscParametr WsReceive NullParam WsSend lRet WsService W0500308

	::lRet := SuperGetMv("FS_BLQSOL",,.F.)

Return .T.

WsMethod InstSolict WsReceive Solicitacao WsSend IDSolic WsService W0500308

	Local nResult	:= 0
	Local cNotif	:= ""
	Local nSvSX8	:= GetSX8Len()
	Local cObsLog	:= ""
	Local cNumSol	:= ""
	Local cVisPAB   := ""
	
	Default Self:Solicitacao:FilAtu := ""
	Default Self:Solicitacao:MatAtu := ""

	aResult := U_F0800501("1",,,"002","001",Self:Solicitacao:FilSolic,Self:Solicitacao:MatSolic,,,Self:Solicitacao:FilPosto)
	
	If aResult[1][1]
	
		Self:Solicitacao:FilAprov := aResult[1][2]
		Self:Solicitacao:MatAprov := aResult[1][3]
		Self:Solicitacao:NvlAprov := VAL(aResult[1][4])
		Self:Solicitacao:PrxNivel := aResult[1][5]
		Self:Solicitacao:CodAlcad := aResult[1][6]               
		cObsLog					  := aResult[1][8]               

		Self:Solicitacao:CodSolVg  := U_F1302201({Self:Solicitacao:FilPosto,"",""}, .T.)
			
		Self:Solicitacao:DataSolic := dDataBase
		Self:Solicitacao:ChavSolic := fBuscaChaveFuncionario(Self:Solicitacao:FilSolic,Self:Solicitacao:MatSolic,Self:Solicitacao:VisaoOrg)
		
		cNotif  := Posicione("PAC",1,xFilial("PAC")+aResult[1][6]+aResult[1][4],"PAC_APRNOT")
		cVisPAB := Posicione("PAB",1,xFilial("PAB")+aResult[1][6],"PAB_VISAO")
		
		If (Self:Solicitacao:PrxNivel == "FM" .And. cNotif == "2") .Or. (Self:Solicitacao:PrxNivel == "FM" .And. ("aprova direto" $ cObsLog .OR. "Terminou a estrutura da visão" $ cObsLog ))
			Self:Solicitacao:Status         := "4"
			Self:Solicitacao:DataRespost    := dDataBase
		Else
			Self:Solicitacao:Status         := "1"
			Self:Solicitacao:DataRespost    := CTod("")
		EndIf
		
		Begin Transaction
		
			nResult := GrSolVgRh(Self:Solicitacao, OPERATION_INSERT, aResult[1][9],aResult[1][10],cVisPAB)
			If nResult > 0
				SetSoapFault("InstSolict", "Registro nao encontrado")
				Break
			EndIf
		
		End Transaction
		
		If nResult == 0
			While (GetSx8Len() > nSvSX8)
				ConfirmSX8()
			EndDo
			
			::IDSolic:lRetorn := "TRUE"
			::IDSolic:DataSol := DTOC(dDataBase)
			::IDSolic:CdSolic := Self:Solicitacao:CodSolVg
			
			U_F0500201(Self:Solicitacao:FilPosto,Self:Solicitacao:CodSolVg,"001") //Solicitação de Vaga Aberta
			cObsLog := "Solicitação de Vaga Aberta"
			//Grava o log de inclusão da solicitação 
			U_F0800201("1",Self:Solicitacao:FilPosto,Self:Solicitacao:CodSolVg,Self:Solicitacao:CodAlcad,Self:Solicitacao:FilSolic,Self:Solicitacao:MatSolic,,,cObsLog,aResult[1][7],aResult[1][4])
			
			If !Empty(Self:Solicitacao:MatAprov)
				U_F0500201(Self:Solicitacao:FilPosto, Self:Solicitacao:CodSolVg, "002") //Aguardando Aprovação
				
				//PrpEnvMail(Self:Solicitacao:FilAprov, Self:Solicitacao:MatAprov, OPERATION_INSERT, "1", "", "", "", Self:Solicitacao:XObs)
			Else
				U_F0500201(Self:Solicitacao:FilPosto, Self:Solicitacao:CodSolVg, "005") //Aguardando efetivação
				//FsEnvRh()//Envia o email para o Rh efetivar
			EndIf
		Else
			::IDSolic:lRetorn := "FALSE"
			::IDSolic:MsgAvso := "Erro na gravação da solicitação"
		EndIf
	Else
		::IDSolic:lRetorn := "FALSE"
		::IDSolic:MsgAvso := aResult[1][8]
	EndIf
	
Return(.T.)

WsMethod AprSolVaga WsReceive Solicitacao WsSend MsgRet WsService W0500308
		
	Local nResult   := 0
	Local aSup      := {}
	Local cNumSol	:= "" 	// - Número da Solicitação RH
	Local cCodAlc	:= "" 	//	- Código da Alçada utilizada
	Local cFilSol	:= "" 	//	- Número da Filial do Solicitante
	Local cMatSol	:= "" 	//	- Número da Matrícula do Solcitante
	Local cFilApr	:= "" 	//	- Número da Filial do Aprovador
	Local cMatApr	:= "" 	//	- Número da Mátrícula do Aprovador
	Local cObsLog	:= "" 	//	- Observações do Log
	Local cNvAprv	:= "" 	//	- Nivel do Aprovador
	Local cTpSol	:= "" 	//	- Tipo Solicitação
	Local cEmailApr := ""
	Local cNotif    := ""
	Local cEmails   := ""
	Local cFilRH3	:= ""
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(Self:Solicitacao:FilialVg + Self:Solicitacao:CodSolVg))
	If RH3->RH3_XSUBST == "S"
		U_F1301111(Self:Solicitacao:FilialVg,Self:Solicitacao:CodSolVg,1) //Historico do Substituto - Perguntar
		RecLock("RH3",.F.)
		RH3->RH3_XSUBST := ""
		RH3->RH3_XFILSU := ""
		RH3->RH3_XMATSU := ""
		RH3->(MsUnLock())
	EndIf
	cFilRH3 := RH3->RH3_FILIAL
	cNumSol	:= RH3->RH3_CODIGO
	cCodAlc	:= RH3->RH3_XCODAL
	cFilSol	:= RH3->RH3_FILINI
	cMatSol	:= RH3->RH3_MATINI
	cFilApr	:= RH3->RH3_FILAPR
	cMatApr	:= RH3->RH3_MATAPR
	cPrxApr	:= RH3->RH3_XPRXNV
	cTpSol	:= RH3->RH3_XTPCTM
	
	cFilPto := RH3->RH3_XFILPO
	cCdPsto := RH3->RH3_XCODPO
	
	U_F0801402(Self:Solicitacao:FilialVg, Self:Solicitacao:CodSolVg, Self:Solicitacao:FILATU, Self:Solicitacao:MATATU, Self:Solicitacao:XOBS)
	
	If cPrxApr == "FM"
		Self:Solicitacao:Status       := "4"
		aAdd(aSup,{.T.,;          //Encontrou o aprovador?
		            "",;          //Filial Aprovador
		            "",;          //Código Aprovador
		            "",;          //Nível do Aprovador
		            "FM",;        //Próximo Nível
		            "",;          //Código da Alçada
		            "",;          //E-mail do aprovador
		            "",;          //Mensagem de retorno
		            "",;          //Filial substituido
		            ""})          //Matricula substituido
	Else
		aSup := U_F0800501("2",cCodAlc,cPrxApr,cTpSol,,cFilSol,cMatSol,,,Self:Solicitacao:FilialVg,Self:Solicitacao:CodSolVg,,,cFilPto,cCdPsto)
		Self:Solicitacao:Status       := "1"
	EndIf
	 
	If (aSup[1][1]) //Aprovação

		cNvAprv                    := IIF(Empty(aSup[1][4]),cNvAprv,aSup[1][4])
		cEmailApr                  := aSup[1][7]
		cObsLog                    := aSup[1][8]
		Self:Solicitacao:FilAprov  := aSup[1][2]
		Self:Solicitacao:MatAprov  := aSup[1][3]
		Self:Solicitacao:NvlAprov  := IIF(Empty(aSup[1][4]),0,VAL(aSup[1][4]))
		Self:Solicitacao:PrxNivel  := aSup[1][5]
		
		If cPrxApr == "FM"
			cNotif := "2"
		Else
			cNotif := Posicione("PAC",1,xFilial("PAC")+aSup[1][6]+aSup[1][4],"PAC_APRNOT")
		EndIf
		
		If (Self:Solicitacao:PrxNivel == "FM" .And. cNotif == "2") .Or. (Self:Solicitacao:PrxNivel == "FM" .And. ("aprova direto" $ cObsLog .OR. "Terminou a estrutura da visão" $ cObsLog ))
			Self:Solicitacao:Status         := "4"
			Self:Solicitacao:DataRespost    := dDataBase
		Else
			Self:Solicitacao:Status         := "1"
			Self:Solicitacao:DataRespost    := CTod("")
		EndIf
		
		Begin Transaction
		
			U_F0500201(Self:Solicitacao:FilialVg, cNumSol, "003", Self:Solicitacao:FILATU, Self:Solicitacao:MATATU)
					    
			nResult := GrSolVgRh(Self:Solicitacao, OPERATION_APROVE, aSup[1][9],aSup[1][10])
			If nResult > 0
				SetSoapFault("AprSolVaga", "Registro nao encontrado")
				Break
			EndIf
		
		End Transaction
		
		If nResult > 0
			Return .F.
		Else
			
			If !Empty(Self:Solicitacao:MatAprov) .And. RH3->RH3_STATUS != '4'//achou aprovador
				U_F0500201(Self:Solicitacao:FilialVg, cNumSol, "002")
				//Grava o log de aprovação da solicitação 
				u_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmailApr,cNvAprv)
				
				//ENVIA EMAIL
				//Envia e-mail para o solicitante
				//seek sra posiciono solicitante 
				DbSelectArea("SRA")
				SRA->(DbSetOrder(1))
				SRA->(DbSeek(cFilSol+cMatSol))
				DbSelectArea("PAB")
				PAB->(DbSetOrder(1))
				PAB->(DbSeek(xFilial("PAB")+cCodAlc))
				If EMPTY(cObsLog)
					cObsLog := Self:Solicitacao:XOBS
				EndIf
				U_F0800901("3",SRA->RA_EMAIL,cFilSol,cNumSol,SRA->RA_NOME,cTpSol,PAB->PAB_GRPSOL,cNvAprv,cObsLog)
			
				::MsgRet := "Aprovado com sucesso."
			Else //efetivação para o RHS
				//U_F0500201(Self:Solicitacao:FilialVg, Self:Solicitacao:CodSolVg, "008") //Aguardando Efetivação
				//Grava o log de aprovação da solicitação 
				U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmailApr,"FM")
															
				//FsEnvRh()//Envia e-mail para o Rh Aprovar
				::MsgRet := "Enviado para efetivação do RH."
			EndIf
		EndIf
	Else //CANCELAMENTO
		Self:Solicitacao:Status := "3"
	
		nResult:= GrSolVgRh(Self:Solicitacao, OPERATION_RPROVE)
		If nResult > 0
			SetSoapFault("RepSolQdro", "Registro nao encontrado")
			Break
		EndIf
		
		If nResult > 0
			Return .F.
		Else
			U_F0500201(Self:Solicitacao:FilialVg, cNumSol, "004", Self:Solicitacao:FILATU, Self:Solicitacao:MATATU)
			
			//Grava o log de cancelamento da solicitação 
			U_F0800201("2",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,"",cNvAprv)

			DbSelectArea("PAB")
			PAB->(DbSetOrder(1))
			PAB->(DbSeek(xFilial("PAB")+cCodAlc))

			If EMPTY(cObsLog)
				cObsLog := Self:Solicitacao:XOBS
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
							cObsLog := Self:Solicitacao:XOBS
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
		
		If Empty(aSup[1][8])
			::MsgRet := "Vaga foi Cancelada por não encontrar Aprovador."
		Else
			::MsgRet := aSup[1][8]
		EndIf
	EndIf
		
Return .T.

WsMethod RepSolVaga WsReceive Solicitacao WsSend WsNull WsService W0500308

	Local nResult   := 0
	Local cNumSol	:= "" 	// - Número da Solicitação RH
	Local cCodAlc	:= "" 	//	- Código da Alçada utilizada
	Local cFilSol	:= "" 	//	- Número da Filial do Solicitante
	Local cMatSol	:= "" 	//	- Número da Matrícula do Solcitante
	Local cFilApr	:= "" 	//	- Número da Filial do Aprovador
	Local cMatApr	:= "" 	//	- Número da Mátrícula do Aprovador
	Local cObsLog	:= "" 	//	- Observações do Log
	Local cNvAprv	:= "" 	//	- Nivel do Aprovador
	Local cTpSol	:= "" 	//	- Tipo Solicitação
	Local cEmails   := ""
	Local cEmailApr
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(Self:Solicitacao:FilialVg + Self:Solicitacao:CodSolVg))
	cNumSol	:= RH3->RH3_CODIGO
	cCodAlc	:= RH3->RH3_XCODAL
	cFilSol	:= RH3->RH3_FILINI
	cMatSol	:= RH3->RH3_MATINI
	cFilApr	:= RH3->RH3_FILAPR
	cMatApr	:= RH3->RH3_MATAPR
	cNvAprv	:= Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1])
	cTpSol  := RH3->RH3_XTPCTM
	
	U_F0801402(Self:Solicitacao:FilialVg, Self:Solicitacao:CodSolVg, Self:Solicitacao:FILATU, Self:Solicitacao:MATATU, Self:Solicitacao:XOBS)
	
	Self:Solicitacao:Status := "3"
	
	Begin Transaction
	
		nResult:= GrSolVgRh(Self:Solicitacao, OPERATION_RPROVE)
		If nResult > 0
			SetSoapFault("RepSolVaga", "Registro nao encontrado")
			Break
		EndIf
		
	End Transaction
	
	If nResult > 0
		Return .F.
	Else
		// Ticket No.4390881 - 418497 - Don Junior - Alteração da filial do solicitante para filial da vaga
		U_F0500201(Self:Solicitacao:FilialVg /*cFilSol*/, cNumSol, "004", Self:Solicitacao:FILATU, Self:Solicitacao:MATATU)
		
		//seek sra posiciono solicitante 
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		SRA->(DbSeek(cFilSol+cMatSol))
		
		//Grava o log de Rejeição da solicitação 
		U_F0800201("4",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,SRA->RA_EMAIL,cNvAprv)
		
		DbSelectArea("PAB")
		PAB->(DbSetOrder(1))
		PAB->(DbSeek(xFilial("PAB")+cCodAlc))
		If EMPTY(cObsLog)
			cObsLog := Self:Solicitacao:XOBS
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
						cObsLog := Self:Solicitacao:XOBS
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
	
Return .T.

Static Function GrSolVgRh(oSolicVag,nOperacao,cFilSubd,cMatSubd,cVisPAB)

	Local nResult   := 0
	Local nX        := 0
	Local nItem     := 0
	Local cFilRH4   := xFilial("RH4", oSolicVag:FilPosto)
	Local cMatSol   := ""
	Local aDados    := {}
	Local cOpr      := ""
	Local cQueryChv := ""
	Local cAlias1   := GetNextAlias()
	Local cChave    := ""
	
	If nOperacao == 1
		cMatSol := Alltrim(Posicione('SRA',1,oSolicVag:FilSolic + IIF(EMPTY(oSolicVag:MatSolic)   ,"",oSolicVag:MatSolic),'RA_NOME'))
		aDados  := {{"QS_FILIAL"  , IIF(EMPTY(oSolicVag:FilPosto)   ,"",oSolicVag:FilPosto         )},;
                    {"TMP_VAGA"   , IIF(EMPTY(oSolicVag:Vaga)       ,"",oSolicVag:Vaga             )},;
                    {"QS_DESCRIC" , IIF(EMPTY(oSolicVag:DscVaga)    ,"",oSolicVag:DscVaga          )},;
                    {"RBT_DEPTO"  , IIF(EMPTY(oSolicVag:CodDepto)   ,"",oSolicVag:CodDepto         )},;
                    {"TMP_DSCDPT" , IIF(EMPTY(oSolicVag:DscDepto)   ,"",oSolicVag:DscDepto         )},;
                    {"QS_POSTO"   , IIF(EMPTY(oSolicVag:CodPosto)   ,"",oSolicVag:CodPosto         )},;
                    {"QS_FILPOST" , IIF(EMPTY(oSolicVag:FilPosto)   ,"",oSolicVag:FilPosto         )},;
                    {"QS_CC"      , IIF(EMPTY(oSolicVag:CodCC)      ,"",oSolicVag:CodCC            )},;
                    {"QS_FUNCAO"  , IIF(EMPTY(oSolicVag:CodFunc)    ,"",oSolicVag:CodFunc          )},;
                    {"QS_SOLICIT" , IIF(EMPTY(cMatSol)              ,"",cMatSol                    )},;
                    {"QS_PRAZO"   , IIF(EMPTY(oSolicVag:PrazoVaga)  ,"",oSolicVag:PrazoVaga        )},;
                    {"QS_DTABERT" , IIF(EMPTY(oSolicVag:DatAbertura),"",DTOC(oSolicVag:DatAbertura))},;
                    {"QS_DTFECH"  , IIF(EMPTY(oSolicVag:DatFecham)  ,"",DTOC(oSolicVag:DatFecham)  )},;
                    {"QS_VCUSTO"  , IIF(EMPTY(oSolicVag:CustoVaga)  ,"",oSolicVag:CustoVaga        )},;
                    {"QS_PROCESS" , IIF(EMPTY(oSolicVag:ProcSelet)  ,"",oSolicVag:ProcSelet        )},;
                    {"QS_TIPO"    , IIF(EMPTY(oSolicVag:TpVaga)     ,"",oSolicVag:TpVaga           )},;
                    {"QS_XSOLPTL" , IIF(EMPTY(oSolicVag:CodSolVg)   ,"",oSolicVag:CodSolVg         )},;
                    {"QG_XTURNTB" , IIF(EMPTY(oSolicVag:TurnoTab)   ,"",oSolicVag:TurnoTab         )},;
                    {"QG_XHRMES"  , IIF(EMPTY(oSolicVag:HorMes)     ,"",oSolicVag:HorMes           )},;
                    {"QG_XHRSEM"  , IIF(EMPTY(oSolicVag:HorSem)     ,"",oSolicVag:HorSem           )},;
                    {"QG_XSALHOR" , IIF(EMPTY(oSolicVag:SalHora)    ,"",oSolicVag:SalHora          )},;
                    {"TMP_TABSAL" , ""													            },;
                    {"QG_XCATFUN" , IIF(EMPTY(oSolicVag:CatFun)     ,"",oSolicVag:CatFun           )},;
                    {"QG_XTPCONT" , IIF(EMPTY(oSolicVag:TpContr)    ,"",oSolicVag:TpContr          )},;
                    {"TMP_XOBS"   , IIF(EMPTY(oSolicVag:XObs)       ,"",oSolicVag:XObs             )};
                   }
	
		cQueryChv := "SELECT RD4_CHAVE,RD4_FILIDE,RD4_CODIDE "
		cQueryChv += "FROM " + RetSqlName("RCX") + " RCX "
		cQueryChv += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
		cQueryChv += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
		cQueryChv += "WHERE RCX.RCX_FILFUN = '" + oSolicVag:FilSolic  + "' AND "
		cQueryChv += "RCX.RCX_MATFUN = '" + oSolicVag:MatSolic + "' AND "
		cQueryChv += "RD4.RD4_CODIGO = '" + cVisPAB + "' AND "
		cQueryChv += "RCX.D_E_L_E_T_ = ' '"
		
		cQueryChv := ChangeQuery(cQueryChv)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryChv),cAlias1,.T.,.T.)
		
		If !(cAlias1)->(EOF())
			cChave := (cAlias1)->RD4_CHAVE
			cFilPost := (cAlias1)->RD4_FILIDE
			cCodPost := (cAlias1)->RD4_CODIDE
		EndIf

	EndIf
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	
	Begin Sequence
	 
		If nOperacao == 1
			Reclock("RH3",.T.)
			RH3->RH3_FILIAL	:= oSolicVag:FilPosto
			RH3->RH3_CODIGO	:= oSolicVag:CodSolVg
			//RH3->RH3_MAT   	:= oSolicVag:CodMatric
			RH3->RH3_TIPO  	:= ""
			RH3->RH3_ORIGEM	:= "PORTAL"
			RH3->RH3_DTSOLI	:= oSolicVag:DataSolic
			RH3->RH3_KEYINI	:= oSolicVag:ChavSolic
			RH3->RH3_VISAO  := oSolicVag:VisaoOrg
			RH3->RH3_NVLINI	:= oSolicVag:NvlInicial //verificar o nivel inicial
			RH3->RH3_FILINI	:= oSolicVag:FilSolic
			RH3->RH3_MATINI	:= oSolicVag:MatSolic
			RH3->RH3_XTPCTM := "002"
			RH3->RH3_XCODAL := oSolicVag:CodAlcad
			RH3->RH3_XPRXNV := oSolicVag:PrxNivel
			RH3->RH3_XDCARG	:= Posicione("SQ3",1,xFilial("SQ3")+oSolicVag:CodCargo,"Q3_DESCSUM")
			RH3->RH3_XFLPTV := oSolicVag:FilPosto
			RH3->RH3_XCHAVE := cChave
			RH3->RH3_XFILPO := cFilPost
			RH3->RH3_XCODPO := cCodPost
			If !Empty(cFilSubd) .AND. !Empty(cMatSubd)
				RH3->RH3_XSUBST := "S"
				RH3->RH3_XFILSU := cFilSubd
				RH3->RH3_XMATSU := cMatSubd
			EndIf
			
			If RH3->(ColumnPos("RH3_EMP")) > 0 .AND. RH3->(ColumnPos("RH3_EMPINI")) > 0 .AND. RH3->(ColumnPos("RH3_EMPAPR")) > 0
				If Empty(oSolicVag:Empresa)
					oSolicVag:Empresa := cEmpAnt
				EndIf
			
				If Empty(oSolicVag:EmpAprov)
					oSolicVag:EmpAprov := cEmpAnt
				EndIf
			
				RH3->RH3_EMP	:= oSolicVag:Empresa
				RH3->RH3_EMPINI	:= cEmpAnt
				RH3->RH3_EMPAPR	:= oSolicVag:EmpAprov
			EndIf
			
			If ColumnPos('QB_KEYINI')>0
				//Atualiza Chave de busca no departamento.
				If Select("SQB")>0
					If SQB->(FieldPos("QB_KEYINI")) > 0
						If Empty(SQB->QB_KEYINI) .OR. SQB->QB_KEYINI <> oSolicVag:ChavSolic
							Reclock("SQB",.F.)
							SQB->QB_KEYINI := oSolicVag:ChavSolic
							SQB->(MsUnlock())
						EndIf
					EndIf
				EndIf
			EndIf
			
		Else
			If RH3->(DbSeek(oSolicVag:FilialVg+oSolicVag:CodSolVg))
				Reclock("RH3",.F.)
				RH3->RH3_XPRXNV := oSolicVag:PrxNivel
			Else
				nResult := 1
				break
			EndIf
		EndIf
		
		If nOperacao == 3 .OR. nOperacao == 4
			If nOperacao == 3
				cOpr := "1"
			Else
				cOpr := "2"
			EndIf
			If RH3->RH3_XSUBST == "S" //Se Houve Substitui?
				U_F1301111(oSolicVag:FilialVg,oSolicVag:CodSolVg,cOpr) //Historico do Substituto		
				RH3->RH3_XSUBST := ""
				RH3->RH3_XFILSU := ""
				RH3->RH3_XMATSU := ""
			EndIf
		EndIf	
		
		If nOperacao == 3 .and. oSolicVag:Status == "4"
			RH3->RH3_STATUS := "4"
			RH3->RH3_NVLAPR := 99
			RH3->RH3_FILAPR := ""
			RH3->RH3_MATAPR := ""
			RH3->RH3_XFILAP := oSolicVag:FilAtu
			RH3->RH3_XMATAP := oSolicVag:MatAtu
			RH3->RH3_XDTAPV := Date()
			If RH3->(ColumnPos("RH3_EMPAPR")) > 0
				RH3->RH3_EMPAPR	:= ""
			EndIf
			U_F0500201(oSolicVag:FilialVg, oSolicVag:CodSolVg, "005")
		Else
			RH3->RH3_STATUS := oSolicVag:Status
			If nOperacao != 4 //Atenção para teste (rejeição) //Verificar em caso de ser um notificador
				RH3->RH3_XFILAP := oSolicVag:FilAtu
				RH3->RH3_XMATAP := oSolicVag:MatAtu
				RH3->RH3_FILAPR := oSolicVag:FilAprov
				RH3->RH3_MATAPR := oSolicVag:MatAprov
				RH3->RH3_XDTAPV := Date()
				If !Empty(cFilSubd) .AND. !Empty(cMatSubd)
					RH3->RH3_XSUBST := "S"
					RH3->RH3_XFILSU := cFilSubd
					RH3->RH3_XMATSU := cMatSubd
				EndIf
			
				RH3->RH3_NVLAPR := oSolicVag:NvlAprov
				cNvApr := Strzero(oSolicVag:NvlAprov,TAMSX3("RH3_XPRXNV")[1])
				
				If RH3->(ColumnPos("RH3_EMPAPR")) > 0
					RH3->RH3_EMPAPR	:= oSolicVag:EmpAprov
				EndIf
			EndIf
			
		EndIf
		
		If nOperacao == 4 //Rejeição
			RH3->RH3_XFILAP := oSolicVag:FilAtu
			RH3->RH3_XMATAP := oSolicVag:MatAtu
			RH3->RH3_XDTAPV := Date()			
			If oSolicVag:TpRj == "2" //suspender
				RH3->RH3_XSUSPE := "2"
			EndIf
		EndIf
		RH3->(MsUnlock())

		U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)	
		
		If oSolicVag:Status == "1" .AND. nOperacao == 1
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(oSolicVag:FilAprov + oSolicVag:MatAprov))
			U_F0800901("1",SRA->RA_EMAIL,oSolicVag:FilialVg,oSolicVag:CodSolVg,SRA->RA_NOME,"002","001",cNvApr,oSolicVag:XObs)
		EndIf

	End Sequence
	
	If nResult == 0

		DBSelectArea("RH4")
		
		If nOperacao == 1
			For nX:= 1 To Len(aDados)
				If !Empty(aDados[nX, 1])
					Reclock("RH4",.T.)
					RH4->RH4_FILIAL	:= cFilRH4
					RH4->RH4_CODIGO	:= oSolicVag:CodSolVg
					RH4->RH4_ITEM	:= ++nItem
					RH4->RH4_CAMPO	:= aDados[nX, 1]
					If aDados[nX, 1] == "TMP_XOBS"
						RH4->RH4_XOBS	:= aDados[nX, 2]
					Else
						RH4->RH4_VALNOV	:= aDados[nX, 2]
					EndIf
					RH4->(MsUnlock())
				EndIf
			Next nX
		EndIf
	
	EndIf
	
Return nResult

WsMethod MinhSolict WsReceive Matricul,TpSolic WsSend MinhaVgs WsService W0500308

	Local aAux 	:= {}
	Local nX		:= 1
	Local oSolVg := Nil
	
	aAux := BscMinhSol(::Matricul,::TpSolic)
	
	If Len(aAux) > 0
	
		::MinhaVgs := WSClassNew( "AMnhVgSl" )
		::MinhaVgs:aMnhVag := {}
		
		oSolVg :=  WSClassNew( "MnhVgSolic" )
		For nX := 1 To Len(aAux)
			oSolVg:CdSolic 	:= aAux[nX][1]
			oSolVg:DataSol	:= aAux[nX][2]
			If aAux[nX][4] == "1" //Cancelado sim
				oSolVg:Status 	:= "5"
			Else
				oSolVg:Status 	:= aAux[nX][3]
			EndIf
			oSolVg:FilCdSl := aAux[nX][5]
			
			// Jamer Nunes Pedroso - 20/05/2017
			oSolVg:STATVGS := U_F0200327(aAux[nX][6]) 
			AAdd( ::MinhaVgs:aMnhVag, oSolVg )
			oSolVg :=  WSClassNew( "MnhVgSolic" )
		Next
	Else
		::MinhaVgs := WSClassNew( "AMnhVgSl" )
		::MinhaVgs:aMnhVag := {}
		
		oSolVg :=  WSClassNew( "MnhVgSolic" )
		oSolVg:CdSolic := ""
		oSolVg:DataSol := ""
		oSolVg:Status  := ""
		oSolVg:FilCdSl := ""
		oSolVg:STATVGS := ""
		
		AAdd( ::MinhaVgs:aMnhVag, oSolVg )
	EndIf
	
Return(.T.)

Static Function BscMinhSol(cMatric,cTpSolic)

	Local aArea 	:= GetArea()
	Local cQuery 	:= ""
	Local cAlias1	:= GetNextAlias()
	Local aAux		:= {}
	
	cQuery := "SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_DTSOLI, RH3.RH3_STATUS, RH3.RH3_XCANCL, SQS.QS_XSTATUS "
	cQuery += "FROM	" + RetSqlName("RH3") + " RH3 "
	cQuery += "LEFT JOIN " + RetSqlName("SQS") + " SQS "
	cQuery += "ON SQS.QS_XSOLFIL = RH3.RH3_FILIAL "
	cQuery += "AND SQS.QS_XSOLPTL = RH3.RH3_CODIGO "
	cQuery += "WHERE RH3.RH3_XTPCTM = '" + cTpSolic + "' AND RH3.RH3_MATINI = '" + cMatric + "' AND RH3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH3.RH3_CODIGO "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	DbSelectArea(cAlias1)
	While !(cAlias1)->(EOF())
		AADD(aAux, {(cAlias1)->RH3_CODIGO,(cAlias1)->RH3_DTSOLI,(cAlias1)->RH3_STATUS,(cAlias1)->RH3_XCANCL,(cAlias1)->RH3_FILIAL,(cAlias1)->QS_XSTATUS})
		(cAlias1)->(DbSkip())
	End
	
	(cAlias1)->(DbCloseArea())
	RestArea(aArea)

Return aAux

WsMethod SolicApRp WsReceive Matricul,FilialAp,Visao,TpSolic WsSend AprovVgs WsService W0500308

	Local aDados:= {}
	Local nY	:= 1
	Local oARVg := Nil
	
	aDados := BscSolVg(::Matricul,::FilialAp,::Visao,::TpSolic)
	
	If Len(aDados) > 0
	
		::AprovVgs := WSClassNew( "AApRepVag" )
		::AprovVgs:aApRep := {}
		
		oARVg :=  WSClassNew( "ApRepVaga" )
		For nY := 1 To Len(aDados)
			oARVg:CodApRp 	:= aDados[nY][1]
			oARVg:DtSolic	:= aDados[nY][2]
			oARVg:StatSol 	:= aDados[nY][3]
			oARVg:AcaoSol   := aDados[nY][4]
			oARVg:FilSolc	:= aDados[nY][5]
			AAdd( ::AprovVgs:aApRep, oARVg )
			oARVg :=  WSClassNew( "ApRepVaga" )
		Next nY
	Else
		::AprovVgs := WSClassNew( "AApRepVag" )
		::AprovVgs:aApRep := {}
		
		oARVg :=  WSClassNew( "ApRepVaga" )
		oARVg:CodApRp := ""
		oARVg:DtSolic := ""
		oARVg:StatSol := ""
		oARVg:AcaoSol := ""
		oARVg:FilSolc := ""
		AAdd( ::AprovVgs:aApRep, oARVg )
	EndIf

Return(.T.)

Static Function BscSolVg(cMatric,cFilAp,cVisao,cTpSolic)

	Local aArea 	:= GetArea()
	Local cAlias1	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cAcao		:= ""
	Local aDad		:= {}
	
	cQuery := "SELECT RH3_FILIAL, RH3_VISAO, RH3_CODIGO, RH3_DTSOLI, RH3_STATUS "
	cQuery += "FROM	" + RetSqlName("RH3") + " "
	cQuery += "WHERE RH3_VISAO = '" + cVisao + "' "
	cQuery += "	AND RH3_XTPCTM = '" + cTpSolic + "' "
	cQuery += "	AND RH3_STATUS = '1' "
	cQuery += "	AND RH3_FILAPR = '" + cFilAp + "' "
	cQuery += "	AND RH3_MATAPR = '" + cMatric + "' "
	cQuery += "	AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	DbSelectArea(cAlias1)
	While !(cAlias1)->(EOF())
		
		If (cAlias1)->RH3_STATUS $ "14"
			cAcao := "Pendente"
		ElseIf (cAlias1)->RH3_STATUS == "2"
			cAcao := "Aprovado"
		Else
			cAcao := "Reprovado"
		EndIf
		
		AADD(aDad, {(cAlias1)->RH3_CODIGO,(cAlias1)->RH3_DTSOLI,(cAlias1)->RH3_STATUS,cAcao,(cAlias1)->RH3_FILIAL})
		
		(cAlias1)->(DbSkip())
	End
	
	(cAlias1)->(DbCloseArea())
	RestArea(aArea)

Return aDad

WsMethod BscSolVags WsReceive CodSolic,Matricul,Visao,FilialS WsSend VDado WsService W0500308

	Local aAux    := {}
	Local aAreas  := {SRJ->(GetArea()),SQB->(GetArea()),GetArea()}

	aAux := FTdsSolic(::CodSolic,::Matricul,::Visao,::FilialS)
			
	If Len(aAux) > 0
		/*
			WsData FilVag,Vaga,Descr,Depto,DescCc,Posto
			FlPost,CodCC,Funcao,DescFu,NomeSol,Prazo,DtAbt		
			DtFch,CustVg,ProcS,TpVaga,CodSolic,TurnoTab,HorMes,HorSem
			SalHora,CatFun,TpContr,Ret,XObs
		*/

		::VDado:FilVag   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_FILIAL" })) = 0, '', aAux[var][2])
		::VDado:Vaga     := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "TMP_VAGA"  })) = 0, '', aAux[var][2])
		::VDado:Descr    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_DESCRIC"})) = 0, '', aAux[var][2])
		::VDado:Depto    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RBT_DEPTO" })) = 0, '', aAux[var][2])
		::VDado:DescDpt  := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "TMP_DSCDPT"})) = 0, '', aAux[var][2])
		::VDado:Posto    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_POSTO"  })) = 0, '', aAux[var][2])
		::VDado:FlPost   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_FILPOST"})) = 0, '', aAux[var][2])
		::VDado:CodCC    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_CC"     })) = 0, '', aAux[var][2])
		::VDado:Funcao   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_FUNCAO" })) = 0, '', aAux[var][2])
		::VDado:NomeSol  := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_SOLICIT"})) = 0, '', aAux[var][2])
		::VDado:Prazo    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_PRAZO"  })) = 0, '', aAux[var][2])
		::VDado:DtAbt    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_DTABERT"})) = 0, '', aAux[var][2])
		::VDado:DtFch    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_DTFECH" })) = 0, '', aAux[var][2])
		::VDado:CustVg   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_VCUSTO" })) = 0, '', aAux[var][2])
		::VDado:ProcS    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_PROCESS"})) = 0, '', aAux[var][2])
		::VDado:TpVaga   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QS_TIPO"   })) = 0, '', aAux[var][2])
		::VDado:DescCc   := POSICIONE("CTT", 1, XFILIAL("CTT") + ALLTRIM(::VDado:CodCC), "CTT_DESC01")
		::VDado:DescFu   := POSICIONE("SRJ", 1, XFILIAL("SRJ") + Alltrim(::VDado:Funcao), "RJ_DESC")
		::VDado:CodSolic := ""
		::VDado:TurnoTab := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QG_XTURNTB"})) = 0, '', aAux[var][2])
		::VDado:HorSem   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QG_XHRSEM" })) = 0, '', aAux[var][2])
		::VDado:HorMes   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QG_XHRMES" })) = 0, '', aAux[var][2])
		::VDado:SalHora  := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QG_XSALHOR"})) = 0, '', aAux[var][2])
		::VDado:CatFun   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QG_XCATFUN"})) = 0, '', aAux[var][2])
		::VDado:TpContr  := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "QG_XTPCONT"})) = 0, '', aAux[var][2])
		
		::VDado:DscCateg := POSICIONE("SX5",1,xFilial("SX5") + "28" + ::VDado:CatFun ,"X5_DESCRI")
		::VDado:DscTurno := POSICIONE("SR6",1,xFilial("SR6") + ::VDado:TurnoTab , "R6_DESC")
		::VDado:DscFilPt := POSICIONE("SM0",1,SM0->M0_CODIGO + ::VDado:FlPost,"M0_NOME")
		
		cChave := POSICIONE("SQ3",1,Fwxfilial("SQ3") + ALLTRIM(::VDado:Funcao) + SPACE(TAMSX3("Q3_CC")[1]) ,"Q3_DESCDET")

		::VDado:ObserDet := MSMM(cChave,,,,3,,,"SQ3","Q3_MEMO1")//
		cCODCARGO := POSICIONE("SQ3",1,Fwxfilial("SQ3") + ::VDado:Funcao,"Q3_CARGO")

		::VDado:CODCARGO   := cCODCARGO
		cDESCRCARGO := POSICIONE("SQ3",1,Fwxfilial("SQ3") + ::VDado:Funcao ,"Q3_DESCSUM")

		::VDado:DESCRCARGO := cDESCRCARGO
		DbSelectArea("RH4")
		RH4->(DbSetOrder(1))
		If RH4->(DBSEEK(Alltrim(::VDado:FilVag) + ::CodSolic + "25"))
			::VDado:XObs := RH4->RH4_XOBS
		Else
			::VDado:XObs := ""
		EndIf
		::VDado:Ret     := ".T."
		
		::VDado:StatusS := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RH3_STATUS"})) = 0, '', aAux[var][2])
				
	Else
	
		::VDado:Ret     := ".F."
	
	EndIf

	AEval(aAreas, {|x| RestArea(x)} )
	
Return(.T.)

Static Function FTdsSolic(cCodSolic,cMatricul,cVisao,cFilCSol)

	Local aDados := {}
	Local cAlias1 := GetNextAlias()
	Local cQuery := ""
	Local cStatus := ""


	cQuery := "SELECT RH3.RH3_CODIGO,RH3.RH3_MAT,RH3.RH3_VISAO,RH3.RH3_STATUS,RH4.RH4_CODIGO,RH4.RH4_CAMPO,RH4.RH4_VALNOV, RH4.R_E_C_N_O_ AS RECNO "
	cQuery += "FROM " + RetSqlName("RH3") + " RH3 "
	cQuery += "INNER JOIN " + RetSqlName("RH4") + " RH4 ON(RH3.RH3_FILIAL = RH4.RH4_FILIAL AND RH3.RH3_CODIGO = RH4.RH4_CODIGO AND RH4.D_E_L_E_T_ = ' ') "
	cQuery += "WHERE RH3.RH3_FILIAL = '" + cFilCSol + "' AND "
	cQuery += "RH3.RH3_CODIGO = '" + cCodSolic + "' AND "
	cQuery += "RH3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RH4.RH4_ITEM "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	DbSelectArea(cAlias1)
	While !(cAlias1)->(EOF())
		
		cStatus := (cAlias1)->RH3_STATUS
		
		If (cAlias1)->RH4_CAMPO != "TMP_JUSTIF"
			AADD(aDados, {(cAlias1)->RH4_CAMPO,(cAlias1)->RH4_VALNOV})
		Else
			RH4->(DbGoTo((cAlias1)->RECNO))
			AADD(aDados, {(cAlias1)->RH4_CAMPO,RH4->RH4_XOBS})
		EndIf
		(cAlias1)->(DbSkip())
	End
	(cAlias1)->(DbCloseArea())
	
	If Len(aDados) > 0
		AADD(aDados, {"RH3_STATUS",cStatus})
	EndIf

Return aDados

WsMethod InsSolQdro WsReceive AumentQdro WsSend IDSolic WsService W0500308

	Local nResult
	Local nSvSX8  := GetSX8Len()
	Local cNotif  := ""
	Local cVisPAB := ""
	
	If Self:AumentQdro:NvPost == "1"
		cSubGrp := "001"
	Else
		cSubGrp := "002"
	EndIf
	aResult := U_F0800501("1",,,"003",cSubGrp,Self:AumentQdro:FilSolic,Self:AumentQdro:MatSolic,,,Self:AumentQdro:FilPosto)
	If aResult[1][1]
	
		Self:AumentQdro:FilAprov := aResult[1][2]
		Self:AumentQdro:MatAprov := aResult[1][3]
		Self:AumentQdro:NvlAprov := VAL(aResult[1][4])
		Self:AumentQdro:PrxNivel := aResult[1][5]
		Self:AumentQdro:CodAlcad := aResult[1][6]       
		
		cObsLog					 := aResult[1][8]       
		
		Self:AumentQdro:CodSolic := U_F1302201({Self:AumentQdro:FilPosto,"",""}, .T.)
		
		Self:AumentQdro:DataSolic := dDataBase
		Self:AumentQdro:ChavSolic := fBuscaChaveFuncionario(Self:AumentQdro:FilSolic,Self:AumentQdro:MatSolic,Self:AumentQdro:VisaoOrg)
		
		cNotif  := Posicione("PAC",1,xFilial("PAC")+aResult[1][6]+aResult[1][4],"PAC_APRNOT")
		cVisPAB := Posicione("PAB",1,xFilial("PAB")+aResult[1][6],"PAB_VISAO")
		
		If (Self:AumentQdro:PrxNivel == "FM" .And. cNotif == "2") .OR. (Self:AumentQdro:PrxNivel == "FM" .And. ("aprova direto" $ cObsLog .OR. "Terminou a estrutura da visão" $ cObsLog ))
			Self:AumentQdro:Status			:= "4"
			Self:AumentQdro:DataRespost		:= dDataBase
		Else
			Self:AumentQdro:Status			:= "1"
			Self:AumentQdro:DataRespost 	:= CTod("")
		EndIf
		
		Begin Transaction

			nResult := GrSolQdro(Self:AumentQdro, OPERATION_INSERT,aResult[1][9],aResult[1][10],cVisPAB)
			If nResult > 0
				SetSoapFault("InsSolQdro", "Registro nao encontrado")
				Break
			EndIf
		
		End Transaction
		
		If nResult == 0
			While (GetSx8Len() > nSvSX8)
				ConfirmSX8()
			EndDo
			
			::IDSolic:lRetorn := "TRUE"
			::IDSolic:DataSol := DTOC(dDataBase)
			::IDSolic:CdSolic := Self:AumentQdro:CodSolic
			
			U_F0500201(Self:AumentQdro:FilPosto, Self:AumentQdro:CodSolic, "001") //Solicitação de Aumento de Quadro Aberta
			
			cObsLog := "Solicitação de Aumento de Quadro Aberta"
			//Grava o log de inclusão da solicitação 
			U_F0800201("1",Self:AumentQdro:FilPosto,Self:AumentQdro:CodSolic,Self:AumentQdro:CodAlcad,Self:AumentQdro:FilSolic,Self:AumentQdro:MatSolic,,,cObsLog,aResult[1][7],aResult[1][4])
			
			If !Empty(Self:AumentQdro:MatAprov)
				U_F0500201(Self:AumentQdro:FilPosto, Self:AumentQdro:CodSolic, "002") //Aguardando Aprovação
				//PrpEnvMail(Self:AumentQdro:FilAprov, Self:AumentQdro:MatAprov, OPERATION_INSERT, "2", "", "", "", Self:AumentQdro:Observ)
			Else
				U_F0500201(Self:AumentQdro:FilPosto, Self:AumentQdro:CodSolic, "005")//Aguardando efetivação Posto
				//FsEnvRh()
			EndIf
		Else
			::IDSolic:lRetorn := "FALSE"
			::IDSolic:MsgAvso := "Erro na gravação da solicitação"
		EndIf
		
	Else
		::IDSolic:lRetorn := "FALSE"
		::IDSolic:MsgAvso := aResult[1][8]
	EndIf

Return(.T.)

WsMethod AprSolQdro WsReceive AumentQdro WsSend MsgRet WsService W0500308
	
	Local nResult   := 0
	Local aSup      := {}
	Local cTpOper	:= "" 	// - Tipo da Operação realizada (1=Incluir; 2=Cancelar; 3=Aprovar; 4=Rejeitar)
	Local cNumSol	:= "" 	// - Número da Solicitação RH
	Local cCodAlc	:= "" 	//	- Código da Alçada utilizada
	Local cFilSol	:= "" 	//	- Número da Filial do Solicitante
	Local cMatSol	:= "" 	//	- Número da Matrícula do Solcitante
	Local cFilApr	:= "" 	//	- Número da Filial do Aprovador
	Local cMatApr	:= "" 	//	- Número da Mátrícula do Aprovador
	Local cObsLog	:= "" 	//	- Observações do Log
	Local cNvAprv	:= "" 	//	- Nivel do Aprovador
	Local cTpSol	:= "" 	//	- Tipo Solicitação
	Local cEmailApr := ""
	Local cEmails   := ""
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(Self:AumentQdro:FilialQdr + Self:AumentQdro:CodSolic))
	cNumSol	:= RH3->RH3_CODIGO
	cCodAlc	:= RH3->RH3_XCODAL
	cFilSol	:= RH3->RH3_FILINI
	cMatSol	:= RH3->RH3_MATINI
	cFilApr	:= RH3->RH3_FILAPR
	cMatApr	:= RH3->RH3_MATAPR
	cPrxApr	:= RH3->RH3_XPRXNV
	cTpSol	:= RH3->RH3_XTPCTM

	cFilPto := RH3->RH3_XFILPO
	cCdPsto := RH3->RH3_XCODPO
	
	U_F0801402(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, Self:AumentQdro:FILATU,Self:AumentQdro:MATATU, Self:AumentQdro:Observ)
	
	If cPrxApr == "FM"
		Self:AumentQdro:Status  := "4" //verificar status no RH3
		aAdd(aSup,{	.T.,;		//Encontrou o aprovador?
		"",;		//Filial Aprovador
		"", ; 		//Código Aprovador
		"", ;		//Nível do Aprovador
		"FM", ;		//Próximo Nível
		"", ;		//Código da Alçada
		"",; 		//E-mail do aprovador	
		"",; 		//Mensagem de retorno
		"",; 		//Filial Substituido
		""})		//Matricula Substituido
	Else
		aSup := U_F0800501("2",cCodAlc,cPrxApr,cTpSol,,cFilSol,cMatSol,,,Self:AumentQdro:FilialQdr,Self:AumentQdro:CodSolic,,,cFilPto,cCdPsto)
		Self:AumentQdro:Status       := "1"
	EndIf
	
	If (aSup[1][1]) //Aprovação

		cNvAprv                  := IIF(Empty(aSup[1][4]),cNvAprv,aSup[1][4])
		cEmailApr                := aSup[1][7]
		cObsLog                  := aSup[1][8]
		Self:AumentQdro:FilAprov := aSup[1][2]
		Self:AumentQdro:MatAprov := aSup[1][3]
		Self:AumentQdro:NvlAprov := IIF(Empty(aSup[1][4]),0,VAL(aSup[1][4]))
		Self:AumentQdro:PrxNivel := aSup[1][5]
		
		If cPrxApr == "FM"
			cNotif := "2"
		Else
			cNotif := Posicione("PAC",1,xFilial("PAC")+aSup[1][6]+aSup[1][4],"PAC_APRNOT")
		EndIf
		
		If (Self:AumentQdro:PrxNivel == "FM" .And. cNotif == "2") .OR. (Self:AumentQdro:PrxNivel == "FM" .And. ("aprova direto" $ cObsLog .OR. "Terminou a estrutura da visão" $ cObsLog )) //ID 946 Cenario termino de estrura
			Self:AumentQdro:Status         := "4"
			Self:AumentQdro:DataRespost    := dDataBase
		Else
			Self:AumentQdro:Status         := "1"
			Self:AumentQdro:DataRespost    := CTod("")
		EndIf
			
		U_F0500201(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, "003",Self:AumentQdro:FILATU,Self:AumentQdro:MATATU) //Solicitação de Aumento de Quadro Aprovado
		nResult := GrSolQdro(Self:AumentQdro, OPERATION_APROVE,aSup[1][9],aSup[1][10])
		If nResult > 0
			SetSoapFault("AprSolQdro", "Registro nao encontrado")
			Break
		EndIf
		
		If nResult > 0
			Return .F.
		Else
			If Self:AumentQdro:Status != "4"
				U_F0500201(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, "002") //Aguardando Aprovação
				//Grava o log de aprovação da solicitação 
				U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmailApr,cNvAprv)
				
				//ENVIA EMAIL
				//Envia e-mail para o solicitante
				//seek sra posiciono solicitante 
				DbSelectArea("SRA")
				SRA->(DbSetOrder(1))
				SRA->(DbSeek(cFilSol+cMatSol))
				DbSelectArea("PAB")
				PAB->(DbSetOrder(1))
				PAB->(DbSeek(xFilial("PAB")+cCodAlc))
				If EMPTY(cObsLog)
					cObsLog := Self:AumentQdro:Observ
				EndIf
				U_F0800901("3",SRA->RA_EMAIL,cFilSol,cNumSol,SRA->RA_NOME,cTpSol,PAB->PAB_GRPSOL,cNvAprv,cObsLog)
		
				::MsgRet := "Aprovado com sucesso."
			Else
				U_F0500201(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, "005")//Aguardando efetivação Posto
				//Grava o log de aprovação da solicitação 
				U_F0800201("3",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmailApr,"FM")
				//FsEnvRh()//Envia e-mail para o Rh Aprovar
				::MsgRet := "Enviado para efetivação do RH."
			EndIf
		EndIf
				
	Else	//CANCELAMENTO
		Self:AumentQdro:Status := "3"
	
		nResult:= GrSolQdro(Self:AumentQdro, OPERATION_RPROVE)
		If nResult > 0
			SetSoapFault("RepSolQdro", "Registro nao encontrado")
			Break
		EndIf
		
		If nResult > 0
			Return .F.
		Else
			U_F0500201(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, "004",Self:AumentQdro:FILATU,Self:AumentQdro:MATATU) 
			
			//Grava o log de cancelamento da solicitação 
			U_F0800201("2",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,"",cNvAprv)
			
			DbSelectArea("PAB")
			PAB->(DbSetOrder(1))
			PAB->(DbSeek(xFilial("PAB")+cCodAlc))
			If EMPTY(cObsLog)
				cObsLog := Self:AumentQdro:Observ
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
							cObsLog := Self:AumentQdro:Observ
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
		
		If Empty(aSup[1][8])
			::MsgRet := "Aumento de quadro foi cancelado por não encontrar Aprovador."
		Else
			::MsgRet := aSup[1][8]
		EndIf
	
	EndIf
	
Return(.T.)

WsMethod RepSolQdro WsReceive AumentQdro WsSend WsNull WsService W0500308

	Local nResult := 0
	Local cNumSol := "" 	// - Número da Solicitação RH
	Local cCodAlc := "" 	//	- Código da Alçada utilizada
	Local cFilSol := "" 	//	- Número da Filial do Solicitante
	Local cMatSol := "" 	//	- Número da Matrícula do Solcitante
	Local cFilApr := "" 	//	- Número da Filial do Aprovador
	Local cMatApr := "" 	//	- Número da Mátrícula do Aprovador
	Local cObsLog := "" 	//	- Observações do Log
	Local cNvAprv := "" 	//	- Nivel do Aprovador
	Local cTpSol  := "" 	//	- Tipo Solicitação
	Local cEmails := ""
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	RH3->(DbSeek(Self:AumentQdro:FilialQdr + Self:AumentQdro:CodSolic))
	cNumSol	:= RH3->RH3_CODIGO
	cCodAlc	:= RH3->RH3_XCODAL
	cFilSol	:= RH3->RH3_FILINI
	cMatSol	:= RH3->RH3_MATINI
	cFilApr	:= RH3->RH3_FILAPR
	cMatApr	:= RH3->RH3_MATAPR
	cNvAprv	:= Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1])
	cTpSol  := RH3->RH3_XTPCTM
	
	U_F0801402(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, Self:AumentQdro:FILATU,Self:AumentQdro:MATATU, Self:AumentQdro:Observ)
	
	Self:AumentQdro:Status := "3"
	
	nResult:= GrSolQdro(Self:AumentQdro, OPERATION_RPROVE)
	
	If nResult > 0
		SetSoapFault("RepSolQdro", "Registro nao encontrado")
		Break
	EndIf
	
	If nResult > 0
		Return .F.
	Else
		U_F0500201(Self:AumentQdro:FilialQdr, Self:AumentQdro:CodSolic, "004", Self:AumentQdro:FILATU,Self:AumentQdro:MATATU) //Solicitação de Aumento de Quadro Reprovado
	
		//seek sra posiciono solicitante 
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		SRA->(DbSeek(cFilSol + cMatSol))
		
		//Grava o log de Rejeicao da solicitacao 
		U_F0800201("4",cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,SRA->RA_EMAIL,cNvAprv)
		
		DbSelectArea("PAB")
		PAB->(DbSetOrder(1))
		PAB->(DbSeek(xFilial("PAB")+cCodAlc))
		If EMPTY(cObsLog)
			cObsLog := Self:AumentQdro:Observ
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
						cObsLog := Self:AumentQdro:Observ
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
	
Return(.T.)

Static Function GrSolQdro(oSolicQdr,nOperacao,cFilSubd,cMatSubd,cVisPAB)

	Local nResult   := 0
	Local nX        := 0
	Local nItem     := 0
	Local cFilRH4   := xFilial("RH4", oSolicQdr:FilPosto)
	Local cSim      := "Novo Posto"
	Local cNao      := "Aumento de Quantidade"
	Local cDescFc   := ""
	Local cDescCg   := ""
	Local aDados    := {}
	Local cOpr      := ""
	Local cQueryChv := ""
	Local cAlias1   := GetNextAlias()
	Local cChave    := ""
		
	If nOperacao == 1
		cDescFc := IIF(Empty(oSolicQdr:CdFuncao),"",Alltrim(Posicione('SRJ',1,xFilial("SRJ")+Alltrim(oSolicQdr:CdFuncao),'SRJ->RJ_DESC')))
		cDescCg := IIF(Empty(oSolicQdr:CdCargo),"",Alltrim(Posicione('SQ3',1,xFilial("SQ3")+Alltrim(oSolicQdr:CdCargo),'SQ3->Q3_DESCSUM')))
		aDados  := {{"RCL_FILIAL", IIf(Empty(oSolicQdr:FilPosto) ,"",oSolicQdr:FilPosto)},;
                    {"RCL_DEPTO" , IIf(Empty(oSolicQdr:CodDepto) ,"",oSolicQdr:CodDepto)},;
                    {"RCL_DDEPTO", IIf(Empty(oSolicQdr:DescDp)   ,"",oSolicQdr:DescDp) },;
                    {"RCL_CC"    , IIf(Empty(oSolicQdr:CdCentCt) ,"",oSolicQdr:CdCentCt)},;
                    {"RCL_DESCCC", IIf(Empty(oSolicQdr:DescCg)   ,"",oSolicQdr:DescCg)},;
                    {"RCL_FUNCAO", IIf(Empty(oSolicQdr:CdFuncao) ,"",oSolicQdr:CdFuncao)},;
                    {"RCL_DFUNC" , IIf(Empty(cDescFc)            ,"",cDescFc)},;
                    {"RCL_CARGO" , IIf(Empty(oSolicQdr:CdCargo)  ,"",oSolicQdr:CdCargo)},;
                    {"RCL_DCARGO", IIf(Empty(cDescCg)            ,"",cDescCg)},;
                    {"RCL_SALAR" , IIf(Empty(oSolicQdr:Salario)  ,"",oSolicQdr:Salario)},;
                    {"RCL_TPOSTO", IIf(Empty(oSolicQdr:TpPosto)  ,"",oSolicQdr:TpPosto)},;
                    {"TMP-Desc.P", IIf(Empty(oSolicQdr:TpPosto)  ,"",IIF(oSolicQdr:TpPosto=="1","Individual","Generico"))},;
                    {"RCL_TPCONT", IIf(Empty(oSolicQdr:TpContr)  ,"",oSolicQdr:TpContr)},;
                    {"TMP-Desc.C", IIf(Empty(oSolicQdr:TpContr)  ,"",IIF(oSolicQdr:TpContr=="1","Indeterminado","Determinado"))},;
                    {"RCL_NPOSTO", IIf(Empty(oSolicQdr:QntQdro)  ,"",oSolicQdr:QntQdro)},;
                    {"TMP_JUSTIF", IIf(Empty(oSolicQdr:Observ)   ,"",oSolicQdr:Observ)},;
                    {"RCL_FILIAL" ,IIf(Empty(oSolicQdr:FilPosto) ,"",oSolicQdr:FilPosto)},;
                    {"RCL_POSTO" , IIf(Empty(oSolicQdr:CdPost)   ,"",oSolicQdr:CdPost)},;
					{"AlPostRepo" , IIf(Empty(oSolicQdr:AlPostRepor  ),"",oSolicQdr:AlPostRepor  )},;
					{"AlFilRepor" , IIf(Empty(oSolicQdr:AlFilRepor   ),"",oSolicQdr:AlFilRepor   )},;
					{"AlDescRepo" , IIf(Empty(oSolicQdr:AlDescRepor  ),"",oSolicQdr:AlDescRepor  )},;
					{"AlDepRepor" , IIf(Empty(oSolicQdr:AlDepRepor   ),"",oSolicQdr:AlDepRepor   )},;
					{"AlDesDpRep" , IIf(Empty(oSolicQdr:AlDesDpRepor ),"",oSolicQdr:AlDesDpRepor )},;
					{"AlFilSol  " , IIf(Empty(oSolicQdr:AlFilSol     ),oSolicQdr:FilPosto,oSolicQdr:AlFilSol     )},;
					{"AlDescSol " , IIf(Empty(oSolicQdr:AlDescSol    ),FWFilialName(,oSolicQdr:FilPosto),oSolicQdr:AlDescSol    )},;
					{"AlDeptSol " , IIf(Empty(oSolicQdr:AlDeptSol    ),oSolicQdr:CodDepto,oSolicQdr:AlDeptSol    )},;
					{"AlDescDept" , IIf(Empty(oSolicQdr:AlDescDeptSol),oSolicQdr:DescDp,oSolicQdr:AlDescDeptSol)},;
                    {"RBT_TIPOR" , IIf(Empty(oSolicQdr:NvPost)   ,"",IIF(oSolicQdr:NvPost=="1",cSim,cNao))};
                   }
	
		cQueryChv := "SELECT RD4_CHAVE,RD4_FILIDE,RD4_CODIDE "
		cQueryChv += "FROM " + RetSqlName("RCX") + " RCX "
		cQueryChv += "INNER JOIN " + RetSqlName("RD4") + " RD4 ON(RD4.RD4_FILIDE = RCX.RCX_FILIAL AND "
		cQueryChv += "RD4.RD4_CODIDE = RCX.RCX_POSTO AND RD4.D_E_L_E_T_ = ' ') "
		cQueryChv += "WHERE RCX.RCX_FILFUN = '" + oSolicQdr:FilSolic  + "' AND "
		cQueryChv += "RCX.RCX_MATFUN = '" + oSolicQdr:MatSolic + "' AND "
		cQueryChv += "RD4.RD4_CODIGO = '" + cVisPAB + "' AND "
		cQueryChv += "RCX.D_E_L_E_T_ = ' '"
		
		cQueryChv := ChangeQuery(cQueryChv)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryChv),cAlias1,.T.,.T.)
		
		If !(cAlias1)->(EOF())
			cChave := (cAlias1)->RD4_CHAVE
			cFilPost := (cAlias1)->RD4_FILIDE
			cCodPost := (cAlias1)->RD4_CODIDE
		EndIf
	
	EndIf
	
	DbSelectArea("RH3")
	RH3->(DbSetOrder(1))
	
	Begin Sequence
	 
		If nOperacao == 1
			Reclock("RH3",.T.)
			RH3->RH3_FILIAL	:= oSolicQdr:FilPosto
			RH3->RH3_CODIGO	:= oSolicQdr:CodSolic
			RH3->RH3_TIPO  	:= ""
			RH3->RH3_ORIGEM	:= "PORTAL"
			RH3->RH3_DTSOLI	:= oSolicQdr:DataSolic
			RH3->RH3_KEYINI	:= oSolicQdr:ChavSolic
			RH3->RH3_VISAO  := oSolicQdr:VisaoOrg
			RH3->RH3_NVLINI	:= oSolicQdr:NvlInicial //verificar o nivel inicial
			RH3->RH3_FILINI	:= oSolicQdr:FilSolic
			RH3->RH3_MATINI	:= oSolicQdr:MatSolic
			RH3->RH3_XTPCTM := "003"
			RH3->RH3_XCODAL := oSolicQdr:CodAlcad
			RH3->RH3_XPRXNV := oSolicQdr:PrxNivel
			RH3->RH3_XCHAVE := cChave
			RH3->RH3_XFILPO := cFilPost
			RH3->RH3_XCODPO := cCodPost
			If !Empty(cFilSubd) .AND. !Empty(cMatSubd)
				RH3->RH3_XSUBST := "S"
				RH3->RH3_XFILSU := cFilSubd
				RH3->RH3_XMATSU := cMatSubd
			EndIf
			
			If RH3->(ColumnPos("RH3_EMP")) > 0 .AND. RH3->(ColumnPos("RH3_EMPINI")) > 0 .AND. RH3->(ColumnPos("RH3_EMPAPR")) > 0
				If Empty(oSolicQdr:Empresa)
					oSolicQdr:Empresa := cEmpAnt
				EndIf
			
				If Empty(oSolicQdr:EmpAprov)
					oSolicQdr:EmpAprov := cEmpAnt
				EndIf
			
				RH3->RH3_EMP	:= oSolicQdr:Empresa
				RH3->RH3_EMPINI	:= cEmpAnt
				RH3->RH3_EMPAPR	:= oSolicQdr:EmpAprov
			EndIf
			
			If ColumnPos('QB_KEYINI')>0
				//Atualiza Chave de busca no departamento.
				If Select("SQB")>0
					If SQB->(FieldPos("QB_KEYINI")) > 0
						If Empty(SQB->QB_KEYINI) .OR. SQB->QB_KEYINI <> oSolicQdr:ChavSolic
							Reclock("SQB",.F.)
							SQB->QB_KEYINI := oSolicQdr:ChavSolic
							SQB->(MsUnlock())
						EndIf
					EndIf
				EndIf
			EndIf
			
		Else
			If RH3->(DbSeek(oSolicQdr:FilialQdr+oSolicQdr:CodSolic))
				Reclock("RH3",.F.)
				RH3->RH3_XPRXNV := oSolicQdr:PrxNivel
			Else
				nResult := 1
				break
			EndIf
		EndIf
		
		If nOperacao == 3 .OR. nOperacao == 4
			If nOperacao == 3
				cOpr := "1"
			Else
				cOpr := "2"
			EndIf
			If RH3->RH3_XSUBST == "S" //Se Houve Substitui?
				U_F1301111(oSolicQdr:FilialQdr,oSolicQdr:CodSolic,cOpr) //Historico do Substituto		
				RH3->RH3_XSUBST := ""
				RH3->RH3_XFILSU := ""
				RH3->RH3_XMATSU := ""
			EndIf
		EndIf
		
		If ((nOperacao == 3) .And. oSolicQdr:Status == "4" )//(RH3->RH3_XPRXNV == "FM"))
			RH3->RH3_STATUS := "4"
			RH3->RH3_NVLAPR := 99
			RH3->RH3_FILAPR := ""
			RH3->RH3_MATAPR := ""
			RH3->RH3_XFILAP := oSolicQdr:FilAtu
			RH3->RH3_XMATAP := oSolicQdr:MatAtu
			RH3->RH3_XDTAPV := Date()
			If RH3->(ColumnPos("RH3_EMPAPR")) > 0
				RH3->RH3_EMPAPR	:= ""
			EndIf
			cSubGrp := IIF(oSolicQdr:NvPost == "1","001","002")
		Else
			RH3->RH3_STATUS := oSolicQdr:Status
			RH3->RH3_NVLAPR := oSolicQdr:NvlAprov
			RH3->RH3_FILAPR := oSolicQdr:FilAprov
			RH3->RH3_MATAPR := oSolicQdr:MatAprov
			RH3->RH3_XFILAP := oSolicQdr:FilAtu
			RH3->RH3_XMATAP := oSolicQdr:MatAtu
			RH3->RH3_XDTAPV := Date()
			If RH3->(ColumnPos("RH3_EMPAPR")) > 0
				RH3->RH3_EMPAPR	:= oSolicQdr:EmpAprov
			EndIf
			
			cNvApr := Strzero(RH3->RH3_NVLAPR,TAMSX3("RH3_XPRXNV")[1])
			
			If !Empty(cFilSubd) .AND. !Empty(cMatSubd)
				RH3->RH3_XSUBST := "S"
				RH3->RH3_XFILSU := cFilSubd
				RH3->RH3_XMATSU := cMatSubd
			EndIf
		EndIf
			
		RH3->(MsUnlock())

		U_F0801201(RH3->RH3_FILAPR, RH3->RH3_MATAPR, RH3->RH3_FILIAL, RH3->RH3_CODIGO, RH3->RH3_NVLAPR, RH3->RH3_XCODAL)

		If oSolicQdr:Status == "1" .AND. nOperacao == 1
			SRA->(DbSetOrder(1))
			SRA->(DbSeek(oSolicQdr:FilAprov + oSolicQdr:MatAprov))
			cSubGrp := IIF(oSolicQdr:NvPost == "1","001","002")
			U_F0800901("1",SRA->RA_EMAIL,oSolicQdr:FilialQdr,oSolicQdr:CodSolic,SRA->RA_NOME,"003",cSubGrp,cNvApr,oSolicQdr:Observ)
		EndIf

	End Sequence
	
	If nResult == 0

		DBSelectArea("RH4")
		
		If nOperacao == 1
			For nX:= 1 To Len(aDados)
				If !Empty(aDados[nX, 1])
					Reclock("RH4",.T.)
					RH4->RH4_FILIAL	:= cFilRH4
					RH4->RH4_CODIGO	:= oSolicQdr:CodSolic
					RH4->RH4_ITEM	:= ++nItem
					RH4->RH4_CAMPO	:= aDados[nX, 1]
					If aDados[nX, 1] != "TMP_JUSTIF"
						RH4->RH4_VALNOV	:= aDados[nX, 2]
					Else
						RH4->RH4_XOBS     := aDados[nX, 2]
					EndIf
					RH4->(MsUnlock())
				EndIf
			Next nX
		EndIf
	
	EndIf
	
Return nResult

WsMethod BscSolQdro WsReceive CodSolic,Matricul,Visao,FilialS WsSend QdroSolict WsService W0500308

	Local aAux    := {}
	Local aArea  := GetArea()

	aAux := FTdsSolic(::CodSolic,::Matricul,::Visao,::FilialS)
            
	If Len(aAux) > 0

		::QdroSolict:FilQdr	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_FILIAL" })) = 0, '', aAux[var][2])
		::QdroSolict:CdDept	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_DEPTO"  })) = 0, '', aAux[var][2])
		::QdroSolict:DsDept	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_DDEPTO" })) = 0, '', aAux[var][2])
		::QdroSolict:CdCCtt	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_CC"     })) = 0, '', aAux[var][2])
		::QdroSolict:DscCtt	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_DESCCC" })) = 0, '', aAux[var][2])
		::QdroSolict:CdFunc	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_FUNCAO" })) = 0, '', aAux[var][2])
		::QdroSolict:DsFunc	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_DFUNC"  })) = 0, '', aAux[var][2])
		::QdroSolict:CdCarg	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_CARGO"  })) = 0, '', aAux[var][2])
		::QdroSolict:DsCarg	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_DCARGO" })) = 0, '', aAux[var][2])
		::QdroSolict:Salari	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_SALAR"  })) = 0, '', aAux[var][2])
		::QdroSolict:TpPost	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "TMP-Desc.P" })) = 0, '', aAux[var][2])
		::QdroSolict:TpCont	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "TMP-Desc.C" })) = 0, '', aAux[var][2])
		::QdroSolict:QntQdr	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_NPOSTO" })) = 0, '', aAux[var][2])
		::QdroSolict:Observ	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "TMP_JUSTIF" })) = 0, '', aAux[var][2])
		::QdroSolict:CodPst	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RCL_POSTO"  })) = 0, '', aAux[var][2])
		::QdroSolict:OrigSl	:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RBT_TIPOR"  })) = 0, '', aAux[var][2])
		
		::QdroSolict:StatusS := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "RH3_STATUS"})) = 0, '', aAux[var][2])
        ::QdroSolict:AlPstRpr  := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlPostRepo"  }))= 0, '', aAux[var][2])
		::QdroSolict:AlDsDpRpr := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlDesDpRep"  }))= 0, '', aAux[var][2])
		::QdroSolict:AlDpRpr   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlDepRepor"  }))= 0, '', aAux[var][2])
		::QdroSolict:AlDscRpr  := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlDescRepo"  }))= 0, '', aAux[var][2])
		::QdroSolict:AlFlRpr   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlFilRepor"  }))= 0, '', aAux[var][2])
		::QdroSolict:AlFlSl    := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlFilSol"    }))= 0, '', aAux[var][2])
		::QdroSolict:AlDscSl   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlDescSol"   }))= 0, '', aAux[var][2])
		::QdroSolict:AlDptSl   := IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlDeptSol"   }))= 0, '', aAux[var][2])
		::QdroSolict:AlDscDptSl:= IIF((var := AScan(aAux, {|x, y|  Alltrim(x[1]) == "AlDescDept"  }))= 0, '', aAux[var][2])               
	EndIf

	RestArea(aArea)

Return(.T.)

WsMethod InfSolVg WsReceive FilialS,CodSolic WsSend _InfRh3 WsService W0500308

	Local aAux := {}

	aAux := RetInfRh3(::FilialS,::CodSolic)
	
	If Len(aAux) > 0
		
		::_InfRh3:RH3VISAO   := Alltrim(aAux[1])
		::_InfRh3:RH3FILINI  := Alltrim(aAux[2])
		::_InfRh3:RH3MATINI  := Alltrim(aAux[3])
		::_InfRh3:RH3FILAPR  := Alltrim(aAux[4])
		::_InfRh3:RH3MATAPR  := Alltrim(aAux[5])
				
	EndIf
	
Return .T.

WsMethod VerPostSol WsReceive cPosto,cDepto,nOcup,nQntd,cFilP WsSend PossuiPost WsService W0500308

	Local lRet := .T.
	Local cQuery := ""
	Local cAlias1 := GetNextAlias()
	Local nValRH3 := 0
	cQuery := "SELECT Count(RH3_CODIGO) QUANT "
	cQuery += "FROM " + RetSqlName("RH3") + " RH3 "
	cQuery += "INNER JOIN " + RetSqlName("RH4") + " RH4 ON (RH3.RH3_FILIAL = RH4.RH4_FILIAL AND "
	cQuery += "RH3.RH3_CODIGO = RH4.RH4_CODIGO AND RH4.D_E_L_E_T_ = ' ' )  "
	cQuery += "INNER JOIN " + RetSqlName("RH4") + " RH4A ON (RH4.RH4_FILIAL = RH4A.RH4_FILIAL AND "
	cQuery += "RH4.RH4_CODIGO = RH4A.RH4_CODIGO AND RH4A.D_E_L_E_T_ = ' ' )  "
	cQuery += "INNER JOIN " + RetSqlName("RH4") + " RH4B ON (RH4.RH4_FILIAL = RH4B.RH4_FILIAL AND "
	cQuery += "RH4.RH4_CODIGO = RH4B.RH4_CODIGO AND RH4B.D_E_L_E_T_ = ' ' )  "
	cQuery += "WHERE RH4A.RH4_CAMPO = 'QS_POSTO' AND  "
	cQuery += "RH4A.RH4_VALNOV = '" + ::cPosto + "' AND "
	cQuery += "RH4.RH4_CAMPO = 'RBT_DEPTO' AND  "
	cQuery += "RH4.RH4_VALNOV = '" + ::cDepto + "' AND "
	cQuery += "RH4B.RH4_CAMPO = 'QS_FILPOST' AND  "
	cQuery += "RH4B.RH4_VALNOV = '" + ::cFilP + "' AND "
	cQuery += "RH3.RH3_STATUS IN ('1','4') AND "
	cQuery += "RH3.RH3_XTPCTM = '002' AND  "
	cQuery += "RH3.D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	nValRH3 := (cAlias1)->(QUANT)
	
	(cAlias1)->(DbCloseArea())
	
	cQuery := "SELECT COUNT(QS_VAGA) QUANT "
	cQuery += "FROM	" + RetSqlName("SQS") + " "
	cQuery += "WHERE QS_POSTO = '" + ::cPosto + "' AND QS_FILPOST = '" + ::cFilP + "' AND QS_XSTATUS != '5' AND "
	cQuery += "D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	nValSQS := (cAlias1)->(QUANT)
	
	(cAlias1)->(DbCloseArea())
	
	If ((::nOcup + nValRH3 + nValSQS) < ::nQntd)//calculo: (ocupado+solic_existe) menor que quantidade_disponivel
		::PossuiPost := .F.
	Else
		::PossuiPost := .T.
	EndIf

Return .T.

WsMethod VerAprvSit WsReceive FilialAp, MatricAp, cDepto, Visao, EmpFun, TpSit WsSend aAprovador WsService W0500308

	aAprov := FsBscAprov(::FilialAp,::MatricAp,::cDepto,::Visao,::EmpFun,::TpSit)
	
	If Len(aAprov) > 0
		::aAprovador:FilAprov  := aAprov[1][1]
		::aAprovador:MatAprov  := aAprov[1][2]
		::aAprovador:NomeAprov := aAprov[1][3]
		::aAprovador:NvlAprov  := aAprov[1][4]
		::aAprovador:EmpAprov  := aAprov[1][7]
	Else
		::aAprovador:FilAprov  := ""
		::aAprovador:MatAprov  := ""
		::aAprovador:NomeAprov := ""
		::aAprovador:NvlAprov  := 99
		::aAprovador:EmpAprov  := ""
	EndIf

Return .T.

Static Function FsBscAprov(cFilFun, cMatFun, cDepto,cVisao, cEmpFun,cTpSit, cFilSol, cMatSol, cFilLstApr, cMatLstApr)
//cEmployeeFilial, Registration, Department, "2"      , Visao  ,EmployeeEmp, Registration 
//aRet[3]        , aRet[1]     , aRet[8]   , ::TypeOrg, cVision, cEmpAnt, Self:EmployeeSolFil, Self:RegistSolic,cFilLstApr ,cMatLstApr
//cFilFun, cMatFun, cDepto, aDeptos, cTipoOrg, cVisao, cEmpFun, cFilSol, cMatSol, cFilLstApr, cMatLstApr

	Local lCont        	:= .T.
	Local cChave       	:= ""
	Local cTree        	:= ""
	Local cEmpIde		:= ""
	Local cSra			:= "%"+RetFullName("SRA",cEmpFun)+"%"
	Local cSqb			:= "%"+RetFullName("SQB",cEmpFun)+"%"
	Local cRd0			:= "%"+RetFullName("RD0",cEmpFun)+"%"
	Local cRdz			:= "%"+RetFullName("RDZ",cEmpFun)+"%"
	Local cRcx			:= "%"+RetFullName("RCX",cEmpFun)+"%"
	Local cSupAlias    	:= "QSUP"
	Local cAuxAlias    	:= "QAUX"
	Local aSuperior    	:= {}
	Local aArea1 		:= ""
	Local cTOrg			:= ""
	
	DEFAULT cFilFun    	:= ""
	DEFAULT cMatFun    	:= ""
	DEFAULT cDepto     	:= ""
	DEFAULT cVisao     	:= ""
	DEFAULT cEmpFun		:= cEmpAnt
	DEFAULT cFilSol    	:= cFilFun
	DEFAULT cMatSol    	:= cMatFun
	DEFAULT cFilLstApr  := cFilSol
	DEFAULT cMatLstApr  := cMatSol

	If cTpSit == "2"
		cDepto := Alltrim(Posicione("SRA",1,cFilFun+cMatFun,"RA_DEPTO"))
	EndIf

	VerTpOrg(@cTOrg, cVisao)
	
	If cTOrg == "1" //Posto
		
		BeginSql alias cSupAlias
			
			SELECT RD4.RD4_TREE
			FROM %EXP:cRCX% RCX
			INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = RCX.RCX_POSTO AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
			WHERE
			RD4.RD4_FILIAL    = %xfilial:RD4%  AND
			RD4.RD4_CODIGO    = %exp:cVisao%   AND
			RCX.RCX_MATFUN    = %exp:cMatFun%  AND
			RCX.RCX_FILFUN    = %exp:cFilFun%  AND
			RCX.RCX_SUBST     = '2'            AND
			RCX.RCX_TIPOCU    = '1'            AND
			RD4.%notDel%                       AND
			RCX.%notDel%
			
		EndSql
		
		If !(cSupAlias)->(EOF())
		
			cTree := (cSupAlias)->RD4_TREE
			
			aArea1 := GetArea()
			DbSelectArea("RD4")
			RD4->(DbSetOrder(1))
			If RD4->(DbSeek(xFilial("RD4")+cVisao+cTree))
				cEmpIde := RD4->RD4_EMPIDE
			EndIf
			
			If !Empty(cEmpIde)
				cSra	:= "%SRA"+cEmpIde+"0%"
				cRcx	:= "%RCX"+cEmpIde+"0%"
				cRdz	:= "%RDZ"+cEmpIde+"0%"
				cRd0	:= "%RD0"+cEmpIde+"0%"
			Else
				cSra	:= "%"+RetFullName("SRA",cEmpFun)+"%"
				cRcx	:= "%"+RetFullName("RCX",cEmpFun)+"%"
				cRdz	:= "%"+RetFullName("RDZ",cEmpFun)+"%"
				cRd0	:= "%"+RetFullName("RD0",cEmpFun)+"%"
			EndIf
			RestArea(aArea1)
			
			lCont := .T.
			While lCont
						
				BeginSql alias cAuxAlias
					
					SELECT RD4.RD4_CHAVE, RD4.RD4_EMPIDE, RCX.RCX_FILFUN, RCX.RCX_MATFUN, SRA.RA_NOME, SRA.RA_NOMECMP, SRA.RA_CATFUNC, RD0.RD0_NOME, RD4.RD4_TREE, RD4.RD4_CODIDE
					FROM %Exp:cRCX% RCX
					INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = RCX.RCX_POSTO AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
					INNER JOIN %Exp:cSRA% SRA ON SRA.RA_FILIAL = RCX.RCX_FILFUN AND	SRA.RA_MAT = RCX.RCX_MATFUN
					INNER JOIN %Exp:cRDZ% RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT
					INNER JOIN %Exp:cRD0% RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0
					WHERE RD0.RD0_FILIAL = %xfilial:RD0% AND
					RDZ.RDZ_EMPENT    = %exp:cEmpIde%     AND
					RDZ.RDZ_FILIAL    = %xfilial:RDZ%  AND
					SRA.RA_SITFOLH    <> 'D'           AND
					RD4.RD4_FILIAL    = %xfilial:RD4%  AND
					RD4.RD4_CODIGO    = %exp:cVisao%   AND
					RD4.RD4_ITEM      = %exp:cTree%   AND
					RCX.RCX_SUBST     = '2'            AND
					RCX.RCX_TIPOCU    = '1'            AND
					RD0.%notdel%						 AND
					RDZ.%notdel%						 AND
					SRA.%notdel%						 AND
					RD4.%notDel%                       AND
					RCX.%notDel%
					
				EndSql
				
				If (cAuxAlias)->( !Eof() )
					If FsVldNotf(cVisao,(cAuxAlias)->RD4_CHAVE)
						lCont := .T.
						cTree := (cAuxAlias)->RD4_TREE
						cFilSol := (cAuxAlias)->RCX_FILFUN
						cMatSol := (cAuxAlias)->RCX_MATFUN
						cPosto := (cAuxAlias)->RD4_CODIDE
						(cAuxAlias)->(DbCloseArea())
							//Envia a notificação por e-mail
						FSEnvNotf(cFilSol,cMatSol,"Posto "+cPosto)
						cAuxAlias := "QAUX"
					Else
						lCont := .F.
						aAdd( aSuperior, { (cAuxAlias)->RCX_FILFUN,;
							(cAuxAlias)->RCX_MATFUN   ,;
							if(! Empty((cAuxAlias)->RA_NOMECMP),(cAuxAlias)->RA_NOMECMP,If(! Empty((cAuxAlias)->RD0_NOME),(cAuxAlias)->RD0_NOME,(cAuxAlias)->RA_NOME)),;
							(len(Alltrim((cAuxAlias)->RD4_CHAVE))/3)-1,;
							(cAuxAlias)->RD4_CHAVE,;
							If(!Empty((cAuxAlias)->RA_NOME),(cAuxAlias)->RA_CATFUNC,""),(cAuxAlias)->RD4_EMPIDE;
							})
					EndIf
				Else
					lCont := .F.
				EndIf
			
			End
			(cAuxAlias)->( DbCloseArea() )
		EndIf
		(cSupAlias)->(dbCloseArea())
	
	ElseIf cTOrg == "2" //Departamento
	
		BeginSql alias cSupAlias
				
			SELECT SQB.QB_FILRESP, SQB.QB_MATRESP, SRA.RA_NOME, SRA.RA_NOMECMP, SRA.RA_CATFUNC, RD0.RD0_NOME, RD4.RD4_TREE, RD4.RD4_CHAVE, RD4.RD4_EMPIDE
			FROM %Exp:cSqb% SQB
			INNER JOIN %Exp:cSra% SRA ON SQB.QB_FILRESP = SRA.RA_FILIAL AND SQB.QB_MATRESP = SRA.RA_MAT
			INNER JOIN %Exp:cRdz% RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT
			INNER JOIN %Exp:cRd0% RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0
			INNER JOIN %table:RD4% RD4 ON RD4.RD4_CODIDE = SQB.QB_DEPTO AND RD4_EMPIDE=%exp:cEmpFun%
			WHERE RD4.RD4_CODIGO = %exp:cVisao% AND
			RD4.RD4_FILIAL = %xfilial:RD4% AND
			RD0.RD0_FILIAL = %xfilial:RD0% AND
			RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
			RDZ.RDZ_EMPENT = %exp:cEmpFun% AND
			SQB.QB_DEPTO   = %exp:cDepto% AND
			SQB.QB_FILIAL  = %exp:xFilial("SQB", cFilFun)% AND
			RD4.%notDel% AND
			RD0.%notdel% AND
			RDZ.%notdel% AND
			SRA.%notDel% AND
			SQB.%notDel%
		EndSql
			
		If (cSupAlias)->( !Eof() )
			
			cTree := (cSupAlias)->RD4_TREE
					
			aArea1 := GetArea()
			dbSelectArea("RD4")
			RD4->(dbSetOrder(1))
			If RD4->(dbSeek(xFilial("RD4")+cVisao+cTree))
				cEmpIde := RD4->RD4_EMPIDE
			EndIf
				
			If !Empty(cEmpIde)
				cSra := "%SRA"+cEmpIde+"0%"
				cSqb := "%SQB"+cEmpIde+"0%"
				cRdz := "%RDZ"+cEmpIde+"0%"
				cRd0 := "%RD0"+cEmpIde+"0%"
			Else
				cSra := "%"+RetFullName("SRA",cEmpFun)+"%"
				cSqb := "%"+RetFullName("SQB",cEmpFun)+"%"
				cRdz := "%"+RetFullName("RDZ",cEmpFun)+"%"
				cRd0 := "%"+RetFullName("RD0",cEmpFun)+"%"
			EndIf
					
			RestArea(aArea1)
			lCont := .T.
			While lCont
						
				BeginSql alias cAuxAlias
						
					SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_NOMECMP, SRA.RA_CATFUNC, RD0.RD0_NOME, RD4.RD4_CHAVE, RD4.RD4_TREE, RD4.RD4_EMPIDE, RD4.RD4_CODIDE
					FROM %table:RD4% RD4
					INNER JOIN %Exp:cSqb% SQB ON SQB.QB_DEPTO = RD4.RD4_CODIDE AND SQB.QB_FILIAL = RD4.RD4_FILIDE AND SQB.%notDel%
					INNER JOIN %Exp:cSra% SRA ON SQB.QB_FILRESP = SRA.RA_FILIAL AND SQB.QB_MATRESP = SRA.RA_MAT AND SRA.%notDel%
					LEFT JOIN %Exp:cRdz% RDZ ON RDZ.RDZ_CODENT = SRA.RA_FILIAL || SRA.RA_MAT AND RDZ.RDZ_FILIAL = %xfilial:RDZ% AND
					RDZ.RDZ_EMPENT = %exp:cEmpIde% AND RDZ.%notdel%
					LEFT JOIN %Exp:cRd0% RD0 ON RD0.RD0_CODIGO = RDZ.RDZ_CODRD0 AND RD0.RD0_FILIAL = %xfilial:RD0% AND RD0.%notdel%
					WHERE RD4.RD4_ITEM   = %exp:cTree%  AND
					RD4.RD4_CODIGO = %exp:cVisao% AND
					RD4.RD4_FILIAL = %xfilial:RD4% AND
					RD4.%notDel%
							
				EndSql
	
				If (cAuxAlias)->( Eof() )
					
					lCont := .F.
							
				ElseIf !( (cAuxAlias)->RA_FILIAL == cFilSol .and. (cAuxAlias)->RA_MAT == cMatSol )
					
					If FsVldNotf(cVisao,(cAuxAlias)->RD4_CHAVE)
						lCont := .T.
						cTree := (cAuxAlias)->RD4_TREE
						cFilSol := (cAuxAlias)->RA_FILIAL
						cMatSol := (cAuxAlias)->RA_MAT
						cDepto := (cAuxAlias)->RD4_CODIDE
						(cAuxAlias)->(DbCloseArea())
							//Envia a notificação por e-mail
						FSEnvNotf(cFilSol,cMatSol,"Departamento "+cDepto)
						cAuxAlias := "QAUX"
					Else
						lCont := .F.
						aAdd( aSuperior, { (cAuxAlias)->RA_FILIAL,;
							(cAuxAlias)->RA_MAT   ,;
							iIf(! Empty((cAuxAlias)->RA_NOMECMP),(cAuxAlias)->RA_NOMECMP,iIf(!Empty((cAuxAlias)->RD0_NOME),(cAuxAlias)->RD0_NOME,(cAuxAlias)->RA_NOME)),;
							(len(Alltrim((cAuxAlias)->RD4_CHAVE))/3)-1,;
							(cAuxAlias)->RD4_CHAVE,;
							iIf(!Empty((cAuxAlias)->RA_NOME),(cAuxAlias)->RA_CATFUNC,""),(cAuxAlias)->RD4_EMPIDE;
							})
					EndIf
							
				Else
					
					cTree := (cAuxAlias)->RD4_TREE
					lCont := .F.
					
				EndIf
			EndDo
			(cAuxAlias)->( DbCloseArea() )
		EndIf
		(cSupAlias)->( dbCloseArea() )
	EndIf

Return aSuperior

Static Function FsVldNotf(cVisao,cChave)

	Local cQuery 	:= ""
	Local cAlias1	:= GetNextAlias()
	Local lRet		:= .F.
	
	cQuery := "SELECT RD4_CODIGO, RD4_CHAVE, RD4_CODIDE, RD4_XAPNT "
	cQuery += "FROM	" + RetSqlName("RD4") + " "
	cQuery += "WHERE RD4_CODIGO = '" + cVisao + "' AND RD4_CHAVE = '" + cChave + "' AND "
	cQuery += "D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	If (cAlias1)->(!EOF())
		If (cAlias1)->RD4_XAPNT = '2'
			lRet := .T.
		EndIf
	EndIf

	(cAlias1)->( DbCloseArea() )

Return lRet

Static Function RetInfRh3(cFilSol,cCodSol)

	Local cQuery 	:= ''
	Local cAliRh3	:= 'RHPA3INF'
	Local aAux		:= {}
	
	cQuery := "SELECT RH3_VISAO, RH3_FILINI, RH3_MATINI,RH3_FILAPR, RH3_MATAPR "
	cQuery += "FROM	" + RetSqlName("RH3") + " "
	cQuery += "WHERE RH3_FILIAL = '" + cFilSol + "' AND "
	cQuery += "RH3_CODIGO = '" + cCodSol + "' AND D_E_L_E_T_ = ' '  "
	cQuery += "ORDER BY RH3_CODIGO "
	
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

Static Function PrpEnvMail(cFilMat, cMatApr, nOper, cSol, cVisao, cMatIni, cFilIni, cObs)

	Local aArea := GetArea()
	Local cAlias1 := GetNextAlias()
	Local cQuery := ""
	Local cAssunto 	:= ""
	Local cDesSol	:= ""
	Local cBody := ""
	Local nX := 0
	Local aEmails := {}
	Local cEmail := ""
	
	Default cObs := ""

	If cSol == "1"
		cAssunto := "Solicitação de Vagas"
		cDesSol := "vaga"
	Else
		cAssunto := "Solicitação de Aumento de Quadro\Orçamento"
		cDesSol := "aumento de quadro\orçamento"
	EndIf

	If nOper !=4
	
		cQuery := "SELECT RA_EMAIL FROM " + RetSqlName("SRA") + " "
		cQuery += "WHERE RA_FILIAL = '" + cFilMat + "' AND RA_MAT = '" + cMatApr + "' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlias1)
		
		cEmail := Alltrim((cAlias1)->RA_EMAIL)
		
		If !Empty(cEmail)
		
			cBody := '<html><body><pre>'+CRLF
			cBody += '<b>Prezado, </b>'+CRLF
			cBody += "Solicitação de " + cDesSol + " aguardando sua aprovação/reprovação no portal de Rh." + CRLF + CRLF
			cBody += "Obs.: " + cObs + " " + CRLF
			cBody += '</pre></body></html>'
			
			U_F0200304(cAssunto, cBody, cEmail) //Envia o e-mail
			
		EndIf
	
	Else
	
		aEmails := FsRetEmls(cFilMat,cMatApr,cVisao,cFilIni,cMatIni)

		cBody := '<html><body><pre>'+CRLF
		cBody += '<b>Prezado, </b>'+CRLF
		cBody += "Solicitação de " + cDesSol + " foi reprovada." + CRLF + CRLF
		cBody += "Obs.: " + cObs + " " + CRLF
		cBody += '</pre></body></html>'
		
		For nX := 1 To Len(aEmails)
			U_F0200304(cAssunto, cBody, aEmails[nX]) //Envia o e-mail
		Next nX
	
	EndIf

	RestArea(aArea)

Return .T.

Static Function FsRetEmls(cFilMat,cMatApr,cVisao,cFilIni,cMatIni)

	Local aArea := GetArea()
	Local cQuery := ""
	Local cConc := "+"
	Local cAlias1 := GetNextAlias()
	Local aRet := {}
	Local lNOracle  := TCGetDB() != 'ORACLE'

	If !lNOracle
		cConc := "||"
	EndIf

	cQuery := "	SELECT RA_FILIAL,RA_MAT, RA_NOME, RA_EMAIL "+CRLF
	cQuery += "	FROM "+RetSqlName("SRA")+" (NOLOCK) "+CRLF
	cQuery += "	WHERE D_E_L_E_T_ = '' "+CRLF
	cQuery += "	  AND RA_SITFOLH    <> 'D'  "+CRLF
	cQuery += "	  AND RA_FILIAL"+cConc+"RA_MAT IN ( SELECT RCX_FILFUN"+cConc+"RCX_MATFUN "+CRLF
	cQuery += "	  			FROM "+RetSqlName("RCX")+" (NOLOCK) "+CRLF
	cQuery += "	  		INNER JOIN "+RetSqlName("RDZ")+" (NOLOCK) "+CRLF
	cQuery += "	  				ON RDZ_CODENT = RCX_FILFUN"+cConc+"RCX_MATFUN "+CRLF
	cQuery += "	  						AND "+RetSqlName("RDZ")+".D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "	  		INNER JOIN "+RetSqlName("RD0")+"  (NOLOCK) "+CRLF
	cQuery += "	  						ON RD0_FILIAL  = ' ' "+CRLF
	cQuery += "	  						AND RD0_CODIGO = RDZ_CODRD0 "+CRLF
	cQuery += "	  						AND "+RetSqlName("RD0")+".D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "	  		WHERE RCX_FILIAL = '"+cFilIni+"' "+CRLF
	cQuery += "	  				AND "+RetSqlName("RCX")+".D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "	  				AND RCX_SUBST = '2' "+CRLF
	cQuery += "	  				AND RCX_TIPOCU = '1' "+CRLF
	cQuery += "	  				AND RCX_DTFIM = ' ' "+CRLF
	cQuery += "	  				AND RCX_FILFUN"+cConc+"RCX_POSTO IN ( 	SELECT RD4_FILIDE"+cConc+"RD4_CODIDE "+CRLF
	cQuery += "	  						FROM "+RetSqlName("RD4")+" (NOLOCK) "+CRLF
	cQuery += "	  						WHERE "+RetSqlName("RD4")+".D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "	  						  AND RD4_FILIAL = ' ' "+CRLF
	cQuery += "	  						  AND RD4_CODIGO = '"+cVisao+"' "+CRLF
	cQuery += "	  						  AND RD4_CHAVE >= ( SELECT RD4_CHAVE "+CRLF
	cQuery += "	  							FROM  "+RetSqlName("RD4")+" (NOLOCK) "+CRLF
	cQuery += "	  							WHERE RD4_FILIAL = ' ' "+CRLF
	cQuery += "	  							 AND RD4_CODIGO = '"+cVisao+"' "+CRLF
	cQuery += "	  							 AND D_E_L_E_T_ =' ' "+CRLF
	cQuery += "	  							 AND RD4_CODIDE = (SELECT RCX_POSTO "+CRLF
	cQuery += "	  							FROM "+RetSqlName("RCX")+" (NOLOCK) "+CRLF
	cQuery += "	  							WHERE RCX_FILIAL = '"+cFilIni+"'"+CRLF
	cQuery += "	  							  AND D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "	  							  AND RCX_SUBST = '2'  "+CRLF
	cQuery += "	  							  AND RCX_TIPOCU = '1' "+CRLF
	cQuery += "	  							  AND RCX_DTFIM = ' ' "+CRLF
	cQuery += "	  AND RCX_POSTO"+cConc+"RCX_FILFUN"+cConc+"RCX_MATFUN = (	SELECT RA_POSTO"+cConc+"RA_FILIAL"+cConc+"RA_MAT "+CRLF
	cQuery += "	  												FROM "+RetSqlName("SRA")+" (NOLOCK) "+CRLF
	cQuery += "	  												WHERE RA_FILIAL = '"+cFilMat+"' "+CRLF
	cQuery += "	  												AND RA_MAT = '"+cMatApr+"' "+CRLF
	cQuery += "	  												AND RA_SITFOLH    <> 'D'  "+CRLF
	cQuery += "	  												AND D_E_L_E_T_ = ' ') "+CRLF
	cQuery += "	  												) "+CRLF
	cQuery += "	  								) "+CRLF
	cQuery += "	  							) "+CRLF
	cQuery += "	  				) "+CRLF
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	DbSelectArea(cAlias1)
	While !(cAlias1)->(EOF())
		AADD(aRet, Alltrim((cAlias1)->(RA_EMAIL)))
		(cAlias1)->(DbSkip())
	End
	(cAlias1)->(DbCloseArea())
	
	RestArea(aArea)

Return aRet

Static Function FSEnvNotf(cFilMat,cMatApr,cTpVis)

	Local aArea := GetArea()
	Local cEmail := ""
	Local cAssunto := "Solicitação"
	
	cEmail := Alltrim(Posicione("SRA",1,cFilMat+cMatApr,"RA_EMAIL"))

	If !Empty(cEmail)
	
		cBody := '<html><body><pre>'+CRLF
		cBody += '<b>Prezado,</b>'+CRLF
		cBody += "Para seu conhecimento, foi realizado uma solicitação para o " + cTpVis + " no portal de Rh." + CRLF
		cBody += '</pre></body></html>'
	
		U_F0200304(cAssunto,cBody,cEmail)
	
	EndIf

	RestArea(aArea)

Return

Static Function FsEnvRh()

	Local aArea := GetArea()
	Local cAssunto := "Aguardando efetivação RH"

	cBody := '<html><body><pre>'+CRLF
	cBody += "Existem solicitações para analise do RH, por favor acessar pelo ERP " + CRLF
	cBody += '</pre></body></html>'
	
	U_F0200304(cAssunto, cBody, cEmails)

	RestArea(aArea)

Return

WsMethod InfFxSl WsReceive CODVAGA, cFilP WsSend _FxSal WsService W0500308

	Local aDados:= {}
	Local nY    := 0
	Local oARVg
	
	aDados := BscFxSal(::CODVAGA,::cFilP)
	
	If Len(aDados) > 0
	
		::_FxSal := WSClassNew( "_FaixSal" )
		::_FxSal:Registro := {}
		
		oARVg :=  WSClassNew( "FaixSal" )
		For nY := 1 To Len(aDados)
			oARVg:NIVEL 	:= aDados[nY][1]
			oARVg:FAIXA	:= aDados[nY][2]
			oARVg:VALOR 	:= cValToChar(aDados[nY][3])
			AAdd( ::_FxSal:Registro, oARVg )
			oARVg :=  WSClassNew( "FaixSal" )
		Next nY
	Else
		
		::_FxSal := WSClassNew( "_FaixSal" )
		::_FxSal:Registro := {}
		
		oARVg :=  WSClassNew( "FaixSal" )
		oARVg:NIVEL 	:= ""
		oARVg:FAIXA	:= ""
		oARVg:VALOR 	:= ""
		AAdd( ::_FxSal:Registro, oARVg )
	EndIf

Return .T.

Static Function BscFxSal(cCodVg, cFilP)

	Local cQuery 	:= ''
	Local cAliRB6	:= 'INFRB6'
	Local aAux		:= {}
	
	cFilRb6 := U_F0600402( cFilP, "RB6")
	cFilSq3 := U_F0600402( cFilP, "SQ3")
	
	cQuery := "SELECT RB6.RB6_VALOR,RB6.RB6_FAIXA,RB6.RB6_NIVEL FROM " + RetSqlName("RBR") + " RBR "
	cQuery += "INNER JOIN " + RetSqlName("RB6") + " RB6 "
	cQuery += "ON RB6.RB6_FILIAL = '" + cFilRb6 + "' AND "
	cQuery += "RB6.RB6_TABELA     = (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_NIVEL  = (SELECT Q3_TABNIVE FROM " + RetSqlName("SQ3") + " WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RB6.RB6_DTREF = RBR.RBR_DTREF "
	//Motivo desta validação, este campo é customizado pelo cliente;
	//Necessário para validação para evitar duplicidade de faixa salarial
	If RB6->(FieldPos("RB6_XCARGO")) > 0
		cQuery += "AND RB6.RB6_XCARGO = '" + cCodVg + "' "
	EndIf
	cQuery += "AND RB6.D_E_L_E_T_ = ' '  "
	cQuery += "WHERE RBR.RBR_FILIAL = '" + cFilRb6 + "' "
	cQuery += "AND RBR.RBR_TABELA = (SELECT Q3_TABELA FROM " + RetSqlName("SQ3") + " WHERE  Q3_FILIAL = '" + cFilSq3 + "' AND Q3_CARGO = '" + cCodVg + "' AND D_E_L_E_T_ = ' ') "
	cQuery += "AND RBR.RBR_APLIC = '1' "
	cQuery += "AND RBR.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY RB6.RB6_NIVEL, RB6.RB6_FAIXA "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRB6)
	
	DbSelectArea(cAliRB6)
	While ! (cAliRB6)->(EOF())
		AADD(aAux, {(cAliRB6)->RB6_NIVEL,(cAliRB6)->RB6_FAIXA,(cAliRB6)->RB6_VALOR})
		(cAliRB6)->(DbSkip())
	End
	(cAliRB6)->(DbCloseArea())

Return aAux

WsMethod PegMnem WsReceive lRet WsSend cRet WsService W0500308
	
	::cRet := ALLTRIM(POSICIONE("RCA",1,XFILIAL("RCA") + 'M_PERCTOL', "RCA_CONTEU"))
	
Return .T.

WsMethod VgDescDet WsReceive _IdVaga WsSend cRet WsService W0500308
	
	Local cChave := ""
	cChave := POSICIONE("SQ3",1,Fwxfilial("SQ3") + Self:_IdVaga:Q3CARGO + Self:_IdVaga:Q3CC,"Q3_DESCDET")
	If EMPTY(cChave)
		cChave := POSICIONE("SQ3",1,Fwxfilial("SQ3") + Self:_IdVaga:Q3CARGO,"Q3_DESCDET")
	EndIf
	::cRet := MSMM(cChave,,,,3,,,"SQ3","Q3_MEMO1")
Return .T.

WsMethod GetDepto WsReceive FilialAp,MatricAp WsSend cDepto WsService W0500308

	Local cQuery 	:= ''
	Local cAlias1	:= GetNextAlias()
	
	cQuery := "SELECT QB_DEPTO "
	cQuery += "FROM	" + RetSqlName("SQB") + " "
	cQuery += "WHERE QB_FILRESP = '" + FilialAp + "' AND QB_MATRESP = '" + MatricAp + "' AND "
	cQuery += "D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	::cDepto := (cAlias1)->QB_DEPTO
	
	(cAlias1)->(DbCloseArea())

Return(.T.)

Static Function VerTpOrg(cTOrg,cVisao)

	Local aArea := GetArea()
	
	If Empty(cTOrg)
		If Empty(cVisao)
			cTOrg := "0"
		Else
			DbSelectArea("RDK")
			If RDK->(DbSeek(xFilial("RDK")+cVisao))
				
				//RDK->RDK_HIERAR -> 1=Organizacional(Departamento);2=Comunicação(Posto)                                            
				If RDK->RDK_HIERAR == "1"
					cTOrg := "2" //departamento
				Else
					cTOrg := "1" //posto
				EndIf
			Else
				Return .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)

Return

WsMethod VerificaPosto WsReceive FilialPosto,CodPosto WsSend lRet WsService W0500308

	Local cQuery 	:= ''
	Local cAlias1	:= GetNextAlias()
	
	cQuery := "SELECT QS_VAGA "
	cQuery += "FROM	" + RetSqlName("SQS") + " "
	cQuery += "WHERE QS_POSTO = '" + ::CodPosto + "' AND QS_FILPOST = '" + ::FilialPosto + "' AND QS_XSTATUS = '5' AND "
	cQuery += "D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	If !(cAlias1)->(EOF())
		::lRet := .F.
	Else
		::lRet := .T.
	EndIf
	
	(cAlias1)->(DbCloseArea())
Return ::lRet

WsMethod BsCntrCusto WsReceive cFilP,cDepto WsSend _CentroCusto WsService W0500308

	Local cQuery 	:= ''
	Local cAlias1	:= GetNextAlias()
	//Alterar para pegar o centro de custo do departamento
	cQuery := "SELECT DISTINCT CTT_CUSTO, CTT_DESC01 FROM " + RetSqlName("CTT") + "  CTT "
	cQuery += "RIGHT JOIN " + RetSqlName("SQB") + " SQB "
	cQuery += "ON QB_FILIAL = '" + cFilP + "' "
	cQuery += "AND QB_DEPTO = '" + cDepto + "' "
	cQuery += "AND SQB.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE CTT_CUSTO = QB_CC "
	cQuery += "AND CTT.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
	
	If !(cAlias1)->(EOF())
		::_CentroCusto:CodCC   := (cAlias1)->(CTT_CUSTO)
		::_CentroCusto:DescC   := (cAlias1)->(CTT_DESC01)
	Else
		::_CentroCusto:CodCC   := ""
		::_CentroCusto:DescC   := ""
	EndIf
	(cAlias1)->(DbCloseArea())
	
Return .T.

WsMethod BuscDepto WsReceive cDepto, FilPosto, CodPosto WsSend nTotal WsService W0500308

	::nTotal := U_F0500314(::cDepto, ::FilPosto, ::CodPosto)

Return .T.

WsMethod RetInfUsr WsReceive FilUsr, Matric WsSend PostUsr WsService W0500308
	Local cRet

	cRet := GetPostos(::FilUsr, ::Matric)

	::PostUsr := cRet

Return .T.


Static Function GetPostos(cFilUsr,cMatric)
	Local cRet		:= ""
	Local cQuery 	:= ""
	Local cAlias1	:= GetNextAlias()

	cQuery := "SELECT RCX_POSTO "
	cQuery += "FROM	" + RetSqlName("RCX") + " RCX "
	cQuery += "WHERE RCX.RCX_FILFUN = '" + cFilUsr + "' AND RCX.RCX_MATFUN = '" + cMatric + "' AND RCX.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)

	If !(cAlias1)->(EOF())
		While !((cAlias1)-> (EOF()))
			cRet += "'"+(cAlias1)->RCX_POSTO+"',"
			(cAlias1)->(DbSkip())
		EndDo
	EndIf

	(cAlias1)->(DbCloseArea())

Return cRet

WSMETHOD GetDepartmentD WSRECEIVE ParticipantID, Vision, FilterValue, Page, FilterField, ControlPost WSSEND DepartmentDt WSSERVICE W0500308
	Local aArea			:= GetArea()
	Local aRet			:= {}
	Local lRet			:= .T.
	Local cItem			:= ""
	Local cChave		:= ""
	Local cLike			:= ""
	Local cTipoOrg		:= ""
	Local cTabela		:= ""
	Local cWhere		:= ""
	Local cAuxAlias 	:= "QRD4"
	Local cAuxAlias1 	:= "QSQB"
	Local cVision		:= ::Vision
	Local nI			:= 1
	Local nQtd			:= 0
	Local aDeptos		:= {}
	Local nPosIni   	:= 1
	Local cFiltroCod    := ""
	Local cFiltroDescr  := ""
	Local cFilResp		:= ""
	Local nX			:= 0
	Local cPostoVis		:= ""
	Local cFilPtVis     := ""
	Local cPostoUsr		:= ""
	//Local PAGE_LENGTH   := 10	
    local   cFilialUsr       := ''  // [ DOR07339726_TK_8444453 ]
		
	DEFAULT Self:Page        := 1
	DEFAULT Self:FilterField := ""
	DEFAULT Self:FilterValue := ""
	DEFAULT Self:ControlPost := ""        

	
	If Empty(::ParticipantID)
		SetSoapFault("GetStructure4",PorEncode("Participante nao encontrado no cadastro de funcionos."))
		Return(.F.)
	EndIf
	
	If Participant(::ParticipantID , aRet )
		If Len(aRet) > 0
			If TipoOrg(@cTipoOrg, cVision)
				If cTipoOrg != "0"
					If !ChaveRD4(cTipoOrg, aRet, cVision, @cItem, @cChave, @cLike)
						SetSoapFault("GetStructure5",PorEncode("Visao nencontrada"))	 //
						Return(.F.)
					EndIf
				EndIf
			Else
				SetSoapFault("GetStructure6",PorEncode("Visao nencontrada"))	 //
				Return(.F.)
			EndIf
		Else
			SetSoapFault("GetStructure7",PorEncode("Participante nao encontrado no cadastro de funcionos."))	 //
			Return(.F.)
		EndIf
	Else
		SetSoapFault("GetStructure8",PorEncode("Participante nao encontrado no cadastro de funcionos."))	 //
		Return(.F.)
	EndIf
	
	 cFilialUsr := aRet[3] // [ DOR07339726_TK_8444453 ]

	cPostoUsr		:= StrTran(StrTran(GetPostos(aRet[3], aRet[1]),",",""),"'","")
	
	cWhere := "%"
	If !Empty(::FilterValue) .AND. !Empty(::FilterField)
		If(::FilterField == "1")
			cWhere += " AND SQB.QB_DEPTO LIKE '%" + Replace(::FilterValue,"'","") + "%'"
		Else
			cWhere += " AND SQB.QB_DESCRIC LIKE '%" + Replace(::FilterValue,"'","") + "%'"
		EndIf
	EndIf
	cWhere += "%"
	
	If cTipoOrg == "1" //postos
		IF Self:ControlPost == "N"
			BeginSql alias cAuxAlias
				SELECT RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,RCL_FILIAL, RCL.RCL_POSTO
				FROM %table:RD4% RD4
				INNER JOIN  %table:RCL% RCL ON RD4.RD4_FILIDE = RCL.RCL_FILIAL AND RD4.RD4_CODIDE = RCL.RCL_POSTO AND RCL.%notDel%
				INNER JOIN  %table:SQB% SQB ON SQB.QB_DEPTO = RCL.RCL_DEPTO AND SQB.%notDel%
				WHERE 
				RD4.RD4_CHAVE LIKE %exp:cLike%     AND
				RD4.RD4_CODIGO = %exp:cVision%     AND
				RD4.RD4_FILIAL = %xfilial:RD4%     AND
				SQB.QB_FILIAL  = %xfilial:SQB%     AND
				RD4.%notDel%                       
				%exp:cWhere%
				GROUP BY RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,RCL_FILIAL,RCL.RCL_POSTO
				ORDER BY RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,RCL.RCL_POSTO
			EndSql
		Else
			BeginSql alias cAuxAlias
				SELECT RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,RCL_FILIAL,RCL.RCL_POSTO
				FROM %table:RD4% RD4
				INNER JOIN %table:RCX% RCX ON RCX.RCX_POSTO = RD4.RD4_CODIDE AND RCX.RCX_FILIAL = RD4.RD4_FILIDE
				INNER JOIN %table:SRA% SRA ON RCX.RCX_FILFUN = SRA.RA_FILIAL	AND
				RCX.RCX_MATFUN = SRA.RA_MAT
				INNER JOIN  %table:RCL% RCL ON RD4.RD4_FILIDE = RCL.RCL_FILIAL AND RD4.RD4_CODIDE = RCL.RCL_POSTO AND RCL.%notDel%
				INNER JOIN  %table:SQB% SQB ON SQB.QB_DEPTO = RCL.RCL_DEPTO AND SQB.%notDel%
				WHERE SRA.RA_SITFOLH <> 'D'        AND
				RCX.RCX_SUBST  = '2'				 	AND
				RCX.RCX_TIPOCU = '1'               AND
				RD4.RD4_CHAVE LIKE %exp:cLike%     AND
				RD4.RD4_CODIGO = %exp:cVision%     AND
				RD4.RD4_FILIAL = %xfilial:RD4%     AND
				SQB.QB_FILIAL  = %xfilial:SQB%     AND
				RD4.%notDel%                       AND
				SRA.%notDel%                       AND
				RCX.%notDel%
				%exp:cWhere%
				GROUP BY RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,RCL_FILIAL,RCL.RCL_POSTO
				ORDER BY RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,RCL.RCL_POSTO
			EndSql
		EndIf

		While !(cAuxAlias)->(Eof())
			If (nx := aScan(aDeptos, {|x| x[3] == (cAuxAlias)->RCL_DEPTO})) > 0
				aadd(aDeptos[nx,5],{(cAuxAlias)->RCL_FILIAL,(cAuxAlias)->RCL_POSTO})
			Else
				aadd(aDeptos,{(cAuxAlias)->RD4_EMPIDE,(cAuxAlias)->RD4_FILIDE,(cAuxAlias)->RCL_DEPTO,'',{{(cAuxAlias)->RCL_FILIAL,(cAuxAlias)->RCL_POSTO}}})
			EndIf
			(cAuxAlias)->(dbSkip())
		EndDo
		(cAuxAlias)->(dbCloseArea())
		
	ElseIf cTipoOrg == "2" //departamento com visao
		
		BeginSql alias cAuxAlias
			SELECT RD4.RD4_EMPIDE, RD4.RD4_FILIDE, RD4.RD4_CODIDE, RD4.RD4_CHAVE, RD4.RD4_CODIGO, RD4.RD4_ITEM
			FROM %table:RD4% RD4
			INNER JOIN %table:SQB% SQB ON RD4.RD4_CODIDE = SQB.QB_DEPTO and RD4_EMPIDE=%exp:cEmpAnt%
			WHERE RD4.RD4_CODIGO = %exp:cVision%   AND
			RD4.RD4_FILIAL = %xfilial:RD4%  AND
			((SQB.QB_FILRESP  = %exp:aRet[3]%   AND
			SQB.QB_MATRESP = %exp:aRet[1]%  AND
			SQB.QB_FILIAL  = %exp:xFilial("SQB", aRet[3])%) OR
			(RD4.RD4_CHAVE LIKE %exp:cLike%))  AND
			RD4.%notDel%                 	  AND
			SQB.%notDel%
			%exp:cWhere%
		EndSql

		While !(cAuxAlias)->(Eof())
			aadd(aDeptos,{	(cAuxAlias)->RD4_EMPIDE,;
				(cAuxAlias)->RD4_FILIDE,;
				(cAuxAlias)->RD4_CODIDE,;
				(cAuxAlias)->RD4_CHAVE},;
				{})
			(cAuxAlias)->(dbSkip())
		EndDo
		(cAuxAlias)->(dbCloseArea())
		
	Else //departamento sem visao

		If !Empty(::FilterValue) .AND. !Empty(::FilterField)
			If(::FilterField == "1")
				cFiltroCod   := Replace(::FilterValue,"'","")
			Else
				cFiltroDescr := Replace(::FilterValue,"'","")
			EndIf
		EndIf
		
		aDeptos := GetDepto(aRet,cFiltroCod, cFiltroDescr)
	EndIf
	
	::DepartmentDt 				  := WsClassNew('_DepartmentData')
	::DepartmentDt:PagesTotal       := Ceiling(Len(aDeptos) / PAGE_LENGTH)
	::DepartmentDt:ListOfDepartment := {}
	
	If ::Page > 1
		nPosIni := ((Self:Page-1) * PAGE_LENGTH) + 1
	EndIf
	
	For nI := nPosIni To Len(aDeptos)
		
		cTabela := "%SQB" + aDeptos[nI][1] + "0%"
		cFilResp	 := "%'" + xFilial( "SQB", aDeptos[nI][2] ) + "'%"
		cPostoVis := ""
		cFilPtVis := ""
		BeginSql alias cAuxAlias1
			SELECT SQB.*
			FROM %exp:cTabela% SQB
			WHERE SQB.QB_DEPTO = %exp:aDeptos[nI][3]%  AND
			SQB.QB_FILIAL =  %exp:cFilResp% AND
			SQB.%notDel%
			%exp:cWhere%
		EndSql
		
		If !(cAuxAlias1)->(Eof())
			aadd(::DepartmentDt:ListOfDepartment,WsClassNew('DtDepartment'))
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:DepartmentEmp		:= aDeptos[nI][1]
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:DepartmentFilial	:= (cAuxAlias1)->QB_FILIAL
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:Department		:= (cAuxAlias1)->QB_DEPTO
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:DescrDepartment	:= (cAuxAlias1)->QB_DESCRIC
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:KeyVision			:= aDeptos[nI][4]
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:TotalRegistros	:= Len(aDeptos)
			If Len(aDeptos[nI][5]) > 0
				For nX := 1 To Len(aDeptos[nI][5])
					//If AllTrim(cPostoUsr) != AllTrim(aDeptos[nI][5][nX][2]) DOR07339726_TK_8444453
					If !(alltrim( cPostoUsr  ) == alltrim( aDeptos[nI][5][nX][2] ) .AND. ;
                         alltrim( cFilialUsr ) == alltrim( aDeptos[nI][5][nX][1] ))
						If nx <> Len(aDeptos[nI][5])
							cFilPtVis += "'" + aDeptos[nI][5][nX][1] + "',"
							cPostoVis += "'" + aDeptos[nI][5][nX][2] + "',"
						Else
							cFilPtVis += "'" + aDeptos[nI][5][nX][1] + "'"
							cPostoVis += "'" + aDeptos[nI][5][nX][2] + "'"
						EndIf
					EndIf
				Next nX
			EndIf
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:FilPostoVis := cFilPtVis
			::DepartmentDt:ListOfDepartment[len(::DepartmentDt:ListOfDepartment)]:PostoVis := cPostoVis
			nQtd++
		EndIf
		(cAuxAlias1)->(dbCloseArea())
		
		/*If len(::DepartmentDt:ListOfDepartment) >= PAGE_LENGTH
			Exit
		EndIf*/
	Next nI
	
	If nQtd == 0
		SetSoapFault("GetDepartament",PorEncode(""))
		Return .F.
	EndIf
	
	RestArea(aArea)
Return(lRet)

Static Function ChaveRD4(cTypeOrg,aRet,cVision,cItem,cChave,cLike)
	Local aArea		:= GetArea()
	Local cRD4Alias	:= "QRD4"
	
	
	If cTypeOrg == "1"
		
		BeginSql alias cRD4Alias
			
			SELECT RD4.RD4_ITEM, RD4.RD4_TREE, RD4.RD4_CHAVE
			FROM %table:RD4% RD4
			INNER JOIN %table:RCX% RCX   ON  RD4.RD4_CODIDE = RCX.RCX_POSTO  AND RCX_FILIAL = RD4_FILIDE
			INNER JOIN %table:RDK% RDK   ON  RD4.RD4_FILIAL = RDK.RDK_FILIAL   AND
			RD4.RD4_CODIGO = RDK.RDK_CODIGO
			WHERE
			RDK.RDK_HIERAR = '2'            AND
			RDK.RDK_TIPO   = '1'            AND
			RCX.RCX_FILFUN = %exp:aRet[3]%  AND
			RCX.RCX_MATFUN = %exp:aRet[1]%  AND
			RCX.RCX_SUBST  = '2'            AND
			RCX.RCX_TIPOCU = '1'            AND
			RD4.RD4_CODIGO = %exp:cVision%  AND
			RD4.RD4_FILIAL = %xfilial:RD4%  AND
			RDK.%notDel%                    AND
			RCX.%notDel%                    AND
			RD4.%notDel%
		EndSql
			
	ElseIf cTypeOrg == "2"
		
		BeginSql alias cRD4Alias
			
			SELECT RD4.RD4_ITEM, RD4.RD4_TREE, RD4.RD4_CHAVE
			FROM %table:RD4% RD4
			INNER JOIN %table:RDK% RDK ON RD4.RD4_FILIAL = RDK.RDK_FILIAL   AND
			RD4.RD4_CODIGO = RDK.RDK_CODIGO
			WHERE RD4.RD4_CODIGO = %exp:cVision% AND
			RD4.RD4_FILIAL = %xfilial:RD4% AND
			RD4.RD4_CODIDE = %exp:aRet[8]% AND
			RDK.RDK_HIERAR = '1'          AND
			RDK.RDK_TIPO   = '1'          AND
			RDK.%notDel%			      AND
			RD4.%notDel%
		EndSql
	EndIf
	
	If (cRD4Alias)->( Eof() )
		(cRD4Alias)->( DbCloseArea() )
		Return(.F.)
	EndIf
	
	cItem  := (cRD4Alias)->RD4_ITEM
	cChave := (cRD4Alias)->RD4_CHAVE
	If Empty((cRD4Alias)->RD4_CHAVE)
		cLike  := ''
	Else
		cLike  := Alltrim((cRD4Alias)->RD4_CHAVE) + '%'
	EndIf
	
	(cRD4Alias)->( DbCloseArea() )
	
	RestArea(aArea)
Return(.T.)

WSMETHOD GetPostosD WSRECEIVE CompanyID, DepartmentID, PostID, Page, FilterField, FilterValue, RequestType, EmployeeFil, Registration, FilPotVis, PostoVis WSSEND PostDataD WSSERVICE W0500308
	Local aArea     := GetArea()
	Local lRet		:= .T.
	Local nI		:= 1
	Local nJ		:= 1
	Local cDepto	:= Self:DepartmentID
	Local cAuxAlias := "QRCL"
	Local cAuxAlias1:= "QRCX"
	Local cTabela 	:= ""//"%RCL" + ::CompanyId + "0%"
	Local aSx3Box   := RetSx3Box( Posicione("SX3", 2, "RCL_TPOSTO", "X3CBox()" ),,, 1 )
	Local aSx3Box1  := RetSx3Box( Posicione("SX3", 2, "RCL_STATUS", "X3CBox()" ),,, 1 )
	Local cWhere	:= ""
	Local cQuery  := ""
	Local cCompRCL  := FWModeAccess("RCL", 1) +FWModeAccess("RCL", 2) +FWModeAccess("RCL", 3)
	Local aAux1 := {}
	Local aAux2 := {}
	Local nCnt	:= 0
	Local nLoopSkip	:= 0
	//Local PAGE_LENGTH      := 10	
	   		
	DEFAULT Self:Page       := 1
	DEFAULT Self:CompanyId  := cEmpAnt
	DEFAULT Self:FilterField:= ""
	DEFAULT Self:FilterValue:= ""
	DEFAULT Self:RequestType:= ""
	DEFAULT Self:EmployeeFil:= ""
	DEFAULT Self:Registration:= ""
	DEFAULT Self:FilPotVis	:= ""
	DEFAULT Self:PostoVis	:= "" 

	
	Self:FilPotVis := StrTran(Self:FilPotVis,"&#39;","'")
	Self:PostoVis  := StrTran(Self:PostoVis,"&#39;","'")
	
	cTabela := "%" + GetTableName("RCL", Self:CompanyId) + "%"
	
	cWhere := "%"
	If !Empty(Self:PostID)
		cWhere += " AND RCL.RCL_POSTO = '" + Self:PostID + "'"
		
		If !Empty(Self:PostoVis)
			cWhere += " AND RCL.RCL_POSTO IN (" + Self:PostoVis + ")"
		EndIf
	Else
		cWhere += " AND RCL.RCL_DEPTO = '" + cDepto + "' "

		If !Empty(Self:FilPotVis) .AND. !Empty(Self:PostoVis)//cCompRCL == "EEE"
			aAux1 := StrToKarr(Self:FilPotVis,",")
			aAux2 := StrToKarr(Self:PostoVis,",")
			cWhere += " AND ( "
			cWhere += "  ( RCL.RCL_FILIAL = " + aAux1[1] + " AND RCL.RCL_POSTO = " + aAux2[1] + " ) "
			For nCnt := 2 To Len(aAux2)
				cWhere += " OR ( RCL.RCL_FILIAL = " + aAux1[nCnt] + " AND RCL.RCL_POSTO = " + aAux2[nCnt] + " ) "
			Next
			cWhere += " ) "
		EndIf

		If !Empty(Self:FilterField) .AND. !Empty(Self:FilterValue)
			cWhere += " AND RCL." + Self:FilterField + " LIKE '%" + Self:FilterValue + "%'"
		EndIf
	EndIf
	cWhere += "%"
	
	If tcSqlExec("SELECT RCL_FILIAL FROM RCL" + ::CompanyId + "0 WHERE RCL_FILIAL='*' ") >= 0
		Self:PostDataD:= WsClassNew('_PostData')
		Self:PostDataD:ListOfPosts:= {}
		
		cQuery := "SELECT COUNT(*) AS REGISTROS "
		cQuery += "FROM " + RetSqlName("RCL") + " RCL "
		cQuery += "WHERE RCL.D_E_L_E_T_ = ' ' "
		cQuery += " " + StrTran(cWhere,"%","") + " "
		cQuery += "AND RCL.RCL_STATUS IN('1','2') "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAuxAlias)
	
		Self:PostDataD:PagesTotal:=	Ceiling((cAuxAlias)->REGISTROS / PAGE_LENGTH)
		(cAuxAlias)->(dbCloseArea())
		
		cQuery := "SELECT RCL.* "
		cQuery += "FROM " + RetSqlName("RCL") + " RCL "
		cQuery += "WHERE RCL.D_E_L_E_T_ = ' ' "
		cQuery += " " + StrTran(cWhere,"%","") + " "
		cQuery += "AND RCL.RCL_STATUS IN('1','2') "
		cQuery += "ORDER BY RCL.RCL_FILIAL,RCL.RCL_POSTO "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAuxAlias)
	
		If Page > 1
			nSkip := (Page-1) * PAGE_LENGTH
			For nLoopSkip := 1 to nSkip
				(cAuxAlias)->(DBSkip())
			Next nLoopSkip
		EndIf
		
		While !(cAuxAlias)->(Eof())	 .AND.;
				Len(Self:PostDataD:ListOfPosts) < PAGE_LENGTH
			AAdd(Self:PostDataD:ListOfPosts, WsClassNew('DtPostos'))
			
			Self:PostDataD:ListOfPosts[nI]:PostoEmp		:= ::CompanyId
			Self:PostDataD:ListOfPosts[nI]:PostFilial	:= (cAuxAlias)->RCL_FILIAL
			Self:PostDataD:ListOfPosts[nI]:Posto			:= (cAuxAlias)->RCL_POSTO
			Self:PostDataD:ListOfPosts[nI]:CodDepto		:= (cAuxAlias)->RCL_DEPTO
			Self:PostDataD:ListOfPosts[nI]:DescrDepto	:= Alltrim(Posicione("SQB",1,xFilial("SQB",(cAuxAlias)->RCL_FILIAL)+(cAuxAlias)->RCL_DEPTO, "SQB->QB_DESCRIC"))
			Self:PostDataD:ListOfPosts[nI]:Tipo			:= (cAuxAlias)->RCL_TPOSTO
			Self:PostDataD:ListOfPosts[nI]:DescrTipo		:= 	Alltrim(aSx3Box[Ascan( aSx3Box, { |aBox| aBox[2] = (cAuxAlias)->RCL_TPOSTO  } )][3])
			Self:PostDataD:ListOfPosts[nI]:Qtd			:= (cAuxAlias)->RCL_NPOSTO
			Self:PostDataD:ListOfPosts[nI]:Ocupado		:= (cAuxAlias)->RCL_OPOSTO
			Self:PostDataD:ListOfPosts[nI]:CodCargo		:= (cAuxAlias)->RCL_CARGO
			Self:PostDataD:ListOfPosts[nI]:DescrCargo	:= Alltrim(Posicione("SQ3",1,xFilial("SQ3",(cAuxAlias)->RCL_FILIAL)+(cAuxAlias)->RCL_CARGO,"Q3_DESCSUM"))
			Self:PostDataD:ListOfPosts[nI]:CodFuncao		:= (cAuxAlias)->RCL_FUNCAO
			Self:PostDataD:ListOfPosts[nI]:DescrFuncao	:= Alltrim(Posicione("SRJ",1,xFilial("SRJ",(cAuxAlias)->RCL_FILIAL)+(cAuxAlias)->RCL_FUNCAO,"RJ_DESC"))
			Self:PostDataD:ListOfPosts[nI]:CC			:= Alltrim((cAuxAlias)->RCL_CC)
			Self:PostDataD:ListOfPosts[nI]:DescrCC      	:= Alltrim(Posicione("CTT",1,xFilial("CTT",(cAuxAlias)->RCL_FILIAL)+(cAuxAlias)->RCL_CC,"CTT_DESC01"))
			Self:PostDataD:ListOfPosts[nI]:TipoContrato	:= Alltrim((cAuxAlias)->RCL_TPCONT)
			Self:PostDataD:ListOfPosts[nI]:Salario		:= (cAuxAlias)->RCL_SALAR
			Self:PostDataD:ListOfPosts[nI]:CodStatus		:= (cAuxAlias)->RCL_STATUS
			Self:PostDataD:ListOfPosts[nI]:Status		:= 	Alltrim(aSx3Box1[Ascan( aSx3Box1, { |aBox| aBox[2] = (cAuxAlias)->RCL_STATUS  } )][3])
			Self:PostDataD:ListOfPosts[nI]:DescFil		:= FwFilName(cEmpAnt,(cAuxAlias)->RCL_FILIAL)
			Self:PostDataD:ListOfPosts[nI]:Reserv		:= 0
			
			BeginSql alias cAuxAlias1
				SELECT RCX.RCX_FILFUN,RCX.RCX_MATFUN
				FROM %table:RCX% RCX
				WHERE RCX.RCX_POSTO = %exp:(cAuxAlias)->RCL_POSTO%
				AND RCX.%notDel%
				AND RCX.RCX_FILIAL = %xfilial:RCX%
				ORDER BY RCX.RCX_FILFUN,RCX.RCX_MATFUN
			EndSql
			
			Self:PostDataD:ListOfPosts[nI]:Ocupantes := {}
			nJ := 1
			While !(cAuxAlias1)->(Eof())
				aadd(Self:PostDataD:ListOfPosts[nI]:Ocupantes,WsClassNew('_Ocupantes'))
				Self:PostDataD:ListOfPosts[nI]:Ocupantes[nJ]:Filial		:= (cAuxAlias1)->RCX_FILFUN
				Self:PostDataD:ListOfPosts[nI]:Ocupantes[nJ]:Matricula	:= (cAuxAlias1)->RCX_MATFUN
				Self:PostDataD:ListOfPosts[nI]:Ocupantes[nJ]:Nome		:= Alltrim(Posicione('SRA',1,(cAuxAlias1)->RCX_FILFUN+(cAuxAlias1)->RCX_MATFUN,'SRA->RA_NOME'))
				
				nJ++
				(cAuxAlias1)->(dbSkip())
			EndDo
			(cAuxAlias1)->(dbCloseArea())
			
			If Self:RequestType == "3" // Aumento de Quadro
				BeginSql alias cAuxAlias1
					SELECT
					RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH4.RH4_CAMPO, RH4.RH4_VALNOV, RH4A.RH4_CAMPO, RH4A.RH4_VALNOV
					FROM
					%table:RH3% RH3
					INNER JOIN %table:RH4% RH4
					ON 	RH3.RH3_FILIAL = RH4.RH4_FILIAL AND
					RH3.RH3_CODIGO = RH4.RH4_CODIGO
					INNER JOIN %table:RH4% RH4A
					ON 	RH4.RH4_FILIAL = RH4A.RH4_FILIAL AND
					RH4.RH4_CODIGO = RH4A.RH4_CODIGO
					WHERE
					RH4A.RH4_CAMPO = 'RBT_CODPOS'                   AND
					RH4A.RH4_VALNOV = %exp:(cAuxAlias)->RCL_POSTO%  AND
					RH4.RH4_CAMPO = 'RBT_DEPTO'                     AND
					RH4.RH4_VALNOV = %exp:(cAuxAlias)->RCL_DEPTO%   AND
					RH3.RH3_STATUS in ('1', '4')                    AND
					RH4.%notDel%                                    AND
					RH4A.%notDel%                                   AND
					RH3.%notDel%
				EndSql
				
				If !(cAuxAlias1)->(Eof())
					Self:PostDataD:ListOfPosts[nI]:PossuiSolic := .T.
				Else
					Self:PostDataD:ListOfPosts[nI]:PossuiSolic := .F.
				EndIf
				(cAuxAlias1)->(dbCloseArea())
			Else
				Self:PostDataD:ListOfPosts[nI]:PossuiSolic := .F.
			EndIf
			
			Self:PostDataD:ListOfPosts[nI]:Responsavel := RespPosto((cAuxAlias)->RCL_FILIAL, (cAuxAlias)->RCL_POSTO)
			
			(cAuxAlias)->(dbSkip())
			nI++
		EndDo
		(cAuxAlias)->(dbCloseArea())
	Else
		lRet := .F.
		SetSoapFault("GetPostos",PorEncode("Departamento npossui postos")) // 
	EndIf
	
	RestArea(aArea)
Return(lRet)

//////////////////////////////////////
// Retorna o respons?l pelo posto //
//////////////////////////////////////

Static Function RespPosto(cFilPos, cCodPos)
	Local aAux		:= {}
	Local aAreaRD4	:= RD4->(GetArea())
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaRCX	:= RCX->(GetArea())		
	Local cAlias1	:= GetNextAlias()
	Local cCodResp	:= ""
	Local cCodRD4	:= ""
	Local cFilResp	:= ""
	Local cItemRD4		:= ""
 	Local cQuery 	:= ""
	Local cRet		:= "Vazio"
	
	RD4->(DbSetOrder(6))
	
	If RD4->(DbSeek(xFilial("RD4")+ cEmpAnt + cFilPos + cCodPos))
		cCodRD4	 := RD4->RD4_CODIGO
		cItemRD4 := RD4->RD4_TREE

		RD4->(DbSetOrder(1))		
		If RD4->(DbSeek(xFilial("RD4")+ cCodRD4 + cItemRD4))
			cFilResp	:= RD4->RD4_FILIDE
			cCodResp	:= RD4->RD4_CODIDE

			If RCX->(DbSeek(cFilResp + cCodResp))
				cRet := ""
				While RCX->(RCX_FILIAL + RCX_POSTO) == (cFilResp + cCodResp)
					If !Empty(cRet)
						cRet += ", "
					EndIf
					If SRA->(DbSeek(RCX->(RCX_FILFUN + RCX_MATFUN)))
						cRet += SRA->RA_NOME
					EndIf
					RCX->(DbSkip())
				EndDo
			EndIf				
		EndIf
	EndIf 
	
	RestArea(aAreaRD4)
	RestArea(aAreaSRA)
	RestArea(aAreaRCX)

Return cRet

WsMethod CancSolic WsReceive cFSolicitacao,cCSolicitacao,cMotivCanceld,cFlSolicitant,cMtSolicitant WsSend MsgRet WsService W0500308

	Local cObserv := ""
	Local cStatus := ""
	
	RH3->(DbSetOrder(1))
	If RH3->(DbSeek(::cFSolicitacao+::cCSolicitacao))
		RecLock("RH3",.F.)
		RH3->RH3_STATUS := "3" //Reprovado
		RH3->RH3_XCANCL := "1" //Cancelado Sim
		RH3->RH3_DTATEN := Date()
		RH3->(MsUnLock())
		cStatus := RH3->RH3_STATUS
	EndIf
	
	//Indicador
	U_F0500201(::cFSolicitacao, ::cCSolicitacao, "024", ::cFlSolicitant,::cMtSolicitant) //Cancelamento da solicita?
			
	cObserv := "Cancelamento: " + ::cMotivCanceld
			
	//Historico Cancelamento
	U_F0801402(::cFSolicitacao, ::cCSolicitacao, ::cFlSolicitant, ::cMtSolicitant, cObserv)
	
	If cStatus == "3"
		::MsgRet := "Cancelamento Realizado com sucesso"
	EndIf
	
Return (.T.)
