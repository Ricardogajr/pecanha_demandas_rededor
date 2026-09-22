#Include "PROTHEUS.CH"

/*/{Protheus.doc}  F0600901

@Author Lucas Graglia
@Since  31/10/2016
@Sample U_F0600901(cFunc,nRecno,cAliasTrb,cChave,cObs,cDatEnv)
@Return cId,	Caso Rotina e Recno foram passados como parametro Retorna o ID

@Param cFunc		,	Nome  da (Rotina, Função) que chamou a Rotina Histórico de Integração
@Param nRecno		,	Recno do Registro de Integração
@Param cAliasTrb	,	Alias da (Rotina, Função) que chamou a Rotina Histórico de Integração
@Param cChave		,	Chave do Alias da (Rotina, Função) que chamou a Rotina Histórico de Integração
@Param cDatEnv		, 	Data Envio da Integração
@Param cOper		, 	Operação
@Param cObs		,	Observação

@history 		, 416094 - Rogerio Carvalho (AMS) - 12/01/2018 : Pesquisar se o ID gerado não existe na tabela PA6
 				  A ocorrencia de duplicidade do ID está impedindo que a informação seja importada
 				  pelos softwares de terceiros. 
@Obs Função Responsável por Gravar Histórico de LOG de Integração

@Project MAN0000007423040_EF_009

/*/

User Function F0600901(cFunc,nRecno,cAliasTrb,cChave,cObs,dDatEnv,cOper, cFilTrab)
	
	Local cData    := Date()
	Local cHora    := Time()
	Local cUsuario := __cUserID	
	Local cID      := u_ams00003() //FWUUIDV4(.F.)
	Local lJob	     := ISBLIND()
	
	Default cFunc		:= Funname()
	Default nRecno		:= 0
	Default cAliasTrb	:= ""
	Default cChave		:= ""
	Default cObs		:= ""	
	Default dDatEnv		:= Date()
	Default cOper 		:= ""	
	Default cFilTrab 	:= xFilial("PA6")

		
	RecLock("PA6",.T.)
		
	PA6->PA6_FILIAL  := cFilTrab		
	PA6->PA6_ID      := alltrim(cID)
	PA6->PA6_DATA    := cData
	PA6->PA6_HORA    := cHora
	If lJob
		PA6->PA6_USUA    := 'JOB'
	Else
		PA6->PA6_USUA    := cUsuario
	EndIf
	PA6->PA6_FUNC    := cFunc
	PA6->PA6_RECNOT  := nRecno
	PA6->PA6_ALIAS   := cAliasTrb
	PA6->PA6_CHALIA  := cChave // ticket n° 6051318 - 415966 - Paulo Dias - ajuste campo para gravação do dado
	PA6->PA6_DATENV  := dDatEnv
	PA6->PA6_OPERAC  := cOper
	PA6->PA6_OBS     := cObs
		
	PA6->(MsUnlock())	
	
Return(alltrim(cID))