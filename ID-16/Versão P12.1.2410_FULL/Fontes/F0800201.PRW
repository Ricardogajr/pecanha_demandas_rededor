#Include 'Protheus.ch'

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0800201
Geração de Arquivo de Log
-Grava a tabela PAA, porém depende da tabela PAB e SRA
@type function
@author		Ademar Fernandes
@since		24/02/2017
@version	1.0
@version	P12.1.7
@Project	MAN0000007423042_EF_002
@param		cTpOper	- Tipo da Operação realizada (1=Incluir; 2=Cancelar; 3=Aprovar; 4=Rejeitar)
@param		cFilSol	- Filial da Solicitação RH
@param		cNumSol	- Número da Solicitação RH
@param		cCodAlc	- Código da Alçada utilizada
@param		cFilSol	- Número da Filial do Solicitante
@param		cMatSol	- Número da Matrícula do Solcitante
@param		cFilApr	- Número da Filial do Aprovador
@param		cMatApr	- Número da Mátrícula do Aprovador
@param		cObsLog	- Observações do Log
@param		cEmail		- Email do aprovador
@param		cNvAprov	- Nivel do aprovador
@return 	lRet => Indica se a gravação foi realizada com sucesso
/*/
//---------------------------------------------------------------------------------------------------------------------------

User Function F0800201(cTpOper,cFilSol,cNumSol,cCodAlc,cFilSol,cMatSol,cFilApr,cMatApr,cObsLog,cEmail,cNvAprov)
	
	Local lRet		:= .T.
	Local oModAtu	:= FWModelActive()
	Local cBkpFil	:= cEmpAnt + cFilAnt
	
	Default cTpOper := ""
	Default cNumSol := ""
	Default cCodAlc := ""
	Default cFilSol := ""
	Default cMatSol := ""
	Default cFilApr := ""
	Default cMatApr := ""
	Default cObsLog := ""
	
	dbSelectArea("PAB")
	dbSetOrder(1)	//-PAB_FILIAL + PAB_CODIGO
	If DbSeek(FwxFilial("PAB") + cCodAlc,.F.)
		
		dbSelectArea("PAA")
		dbSetOrder(1)	//-PAA_FILIAL + PAA_CODIGO
		RecLock("PAA",.T.)
		PAA_FILIAL	:= FwxFilial("PAA")	//-Filial do Sistema
		PAA_CODIGO	:= GetSxeNum("PAA","PAA_CODIGO")	//-Codigo Automático
		PAA_DATA	:= dDatabase		//-Data
		PAA_HORA	:= Time()			//-Hora
		PAA_TPOPER	:= cTpOper			//-Tipo da Operaçao
		PAA_FILSOL	:= cFilSol			//-Filial da Solicitação RH
		PAA_NUMSOL	:= cNumSol			//-Número da Solicitação RH (*)		
		PAA_CODVIS	:= PAB->PAB_VISAO	//-Codigo da Visao
		PAA_CODALC	:= cCodAlc			//-Codigo de Alçada
		PAA_CODCAO	:= PAB->PAB_TPSOLI	//-Cod. Tipo de Solicitaçao
		PAA_DESCAO	:= PAB->PAB_SOLDES	//-Desc.Tipo de Solicitaçao
		PAA_CODSUB	:= PAB->PAB_GRPSOL	//-Codigo do SubGrupo
		PAA_DESSUB	:= PAB->PAB_GRPDES	//-Descricao do SubGrupo
		PAA_FILANT	:= cFilSol			//-Filial do Solicitante
		PAA_CODANT	:= cMatSol			//-Codigo do Solicitante
		PAA_POSANT	:= Posicione("SRA",1,cFilSol + cMatSol,"RA_POSTO")	//-Posto do Solicitante
		PAA_DESANT	:= Posicione("SQB",1,FwxFilial("SQB") + SRA->RA_DEPTO,"QB_DESCRIC")	//-Desc.Depto.Solicitante
		PAA_FILDOR	:= cFilApr			//-Filial do Aprovador
		PAA_CODDOR	:= cMatApr			//-Codigo do Aprovador
		PAA_POSDOR	:= Posicione("SRA",1,cFilApr + cMatApr,"RA_POSTO")	//-Posto do Aprovador
		PAA_DESDOR	:= Posicione("SQB",1,FwxFilial("SQB") + SRA->RA_DEPTO,"QB_DESCRIC")	//-Desc.Depto.Aprovador
		PAA_OBSERV	:= cObsLog			//-Observacao
		PAA_EMAIL	:= cEmail
		PAA_NIVAPR	:= cNvAprov
		PAA->(MsUnLock())
		
	Else
		lRet := .F.
		MsgAlert("Cadastro de Alçadas não encontrado!",FunDesc())
	EndIf
	
Return(lRet)
