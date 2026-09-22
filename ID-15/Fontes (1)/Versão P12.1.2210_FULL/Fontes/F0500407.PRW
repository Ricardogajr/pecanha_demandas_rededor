#Include 'Protheus.ch'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500407
Atualiza o campo que sinaliza se o funcionário possui solicitação em aberto e envia e-mail notififa
@type User function
@author Cris
@since 22/11/2016
@version 1.0
@param cFilFun, character, (Filial do Funcionário)
@param cMatFun, character, (Matricula do Funcionário)
@param cCodSol, character, (Codigo da Solicitaçao)
@param cVisaoAt, character, (Codigo da Visao)
@return ${Lógico}, ${.T. foi atualizado com sucesso .F.  não foi atualizado}
@Project MAN0000007423039_EF_004
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500407(cFilFun,cMatFun,cCodSol,cVisaoAt)
	
	Local aAreaAtu	:= SRA->(GetArea())
	Local lAtuSRA	:= .F.
	Local lFuncES	:= iif(IsInCallStack("U_F0500402"),.T.,.F.)
	Local lFuncCS	:= iif(IsInCallStack("PrepNot"),.T.,.F.)
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	if SRA->(DbSeek(cFilFun + cMatFun))
		
		SRA->(Reclock('SRA',.F.))
		SRA->RA_XSTMVTO := " "
		SRA->(MSunlock())
		
		lAtuSRA	:= .T.
	Else
		
		if  lFuncES .OR. lFuncCS
			
			Help("",1, "Help", "Atualização de Funcionário(F0500407_01)", "O código de funcionário (" + cMatFun + ") não foi localizado para esta filial (" + cFilSol + "), portanto não será atualizado!" , 3, 0)
		EndIf
		
		lAtuSRA	:= .F.
	EndIf
	
	RestArea(aAreaAtu)
	
	if lAtuSRA .AND. IsInCallStack('U_F0100323')
		
		//Monta email notificador para enviar
		//U_F0500409(cFilFun,cMatFun,cCodSol,cVisaoAt,iif(lFuncES,'1','2'))
	EndIf
	
	if lAtuSRA
		
		//Garanto que continue posicionada
		dbSelectArea("RH3")
		RH3->(dbSetOrder(1))
		if RH3->(DbSeek(cFilFun + cCodSol))
			
			//			if  !isIncallstack("FsAprovSol") .AND. FindFunction("U_F0500201")
			
			//Requisito N005 -  Indicadores: -068-Reprovada pelo CSC
			//			U_F0500201(cFilFun,cCodSol,'068')
			
			//			EndIf
			
		EndIf
	EndIf
	
Return lAtuSRA
