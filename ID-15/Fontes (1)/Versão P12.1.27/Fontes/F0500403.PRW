#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
Static lBOracle	:= Trim(TcGetDb()) = 'ORACLE'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F0500403
(Posiciona na solicitação em aberto, exceto  os status onde a solicitação já foi atendida = 2 ou reprovada = 3
Regra: para o funcionário posicionado somente deverá existir unica solicitação do tipo 006 (RH3_XTPCTM)
@type function
@author Cris
@since 08/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function F0500403()
	
	Local aAreaRH3	:= RH3->(GetArea())
	Local cQryRH3	:= ''
	Local ctabRH3	:= GetNextAlias()
	
	if !lBOracle
		
		cQryRH3	:= "	SELECT TOP 1 RH3_FILIAL, RH3_CODIGO  " + CRLF
		cQryRH3	+= "	FROM " + RetSqlName("RH3") + " (NOLOCK) " + CRLF
		cQryRH3	+= "	WHERE  D_E_L_E_T_ = '' " + CRLF
		cQryRH3	+= "	  AND RH3_FILIAL = '" + xFilial("RH3") + "' " + CRLF
		cQryRH3	+= "	  AND RH3_MAT = '" + SRA->RA_MAT + "' " + CRLF
		cQryRH3	+= "	  AND RH3_STATUS NOT IN ('2','3') " + CRLF
		cQryRH3	+= "	  AND RH3_XTPCTM = '006' " + CRLF
		
	Else
		cQryRH3	:= "	SELECT RH3_FILIAL, RH3_CODIGO  " + CRLF
		cQryRH3	+= "	FROM " + RetSqlName("RH3") + " (NOLOCK) " + CRLF
		cQryRH3	+= "	WHERE  D_E_L_E_T_ = '' " + CRLF
		cQryRH3	+= "	  AND RH3_FILIAL = '" + xFilial("RH3") + "' " + CRLF
		cQryRH3	+= "	  AND RH3_MAT = '" + SRA->RA_MAT + "' " + CRLF
		cQryRH3	+= "	  AND RH3_STATUS NOT IN ('2','3') " + CRLF
		cQryRH3	+= "	  AND RH3_XTPCTM = '006' " + CRLF
		cQryRH3	+= "	  AND ROWNUM = 1 " + CRLF
		
	EndIf
	
	cQryRH3 := ChangeQuery(cQryRH3)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRH3),ctabRH3,.T.,.T.)
	
	if !(ctabRH3)->(Eof())
		
		dbSelectArea("RH3")
		RH3->(dbSetOrder(1))
		if RH3->(DbSeek((ctabRH3)->RH3_FILIAL +(ctabRH3)->RH3_CODIGO))
			
			FWExecView(" Cancelamento de Solicitação ",'F0500404',MODEL_OPERATION_UPDATE,,{|| .T.},{|| F05VLCAN()})	//-MODEL_OPERATION_UPDATE
			
			if RH3->RH3_STATUS == '3'
				//Solicitação reprovada pelo CSC
				U_F0500201(RH3->RH3_FILIAL,(ctabRH3)->RH3_CODIGO,'007')
			EndIf
		EndIf
	Else
		
		Help("",1, "Help", "Cancelamento de Solicitação(F0500403_01)", "Para o funcionário " + SRA->RA_MAT + "-" + SRA->RA_NOME + " posicionado não existe solicitação em aberto!" , 3, 0)
	EndIF
	
	(ctabRH3)->(dbCloseArea())
	RestArea(aAreaRH3)
Return


//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F05VLCAN
Solicita a cofirmação do cancelamento
@type function
@author Cris
@since 09/11/2016
@version P12.1.7
@Project MAN0000007423039_EF_004
@return ${return}, ${não há}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function F05VLCAN()
	
	Local oModAtu	:=	FWModelActive()
	Local lCanc		:= .T.
	
	if (lCanc := MsgYesNo("Deseja realmente cancelar a solicitação?"))
		
		//oModAtu:GetModel('RH3MASTER'):SetValue("RH3_STATUS","3")
		//oModAtu:GetModel('RH3MASTER'):SetValue("RH3_DTATEN",MsDate())
		If oModAtu:GetModel('RH3MASTER'):GetValue("RH3_STATUS") == '3'
			oModAtu:GetModel('RH3MASTER'):SetValue("RH3_DTATEN",MsDate())   
		Else
			Help("",1, "Help", "Confirmação de Cancelamento(F05VLCAN_01)", "Antes de confirmar o Cancelamento, é necessário atualizar manualmente o campo Status para Reprovada!" , 3, 0)
			lCanc	:= .F.
		EndIf
	Else
		lCanc	:= .F.
	EndIf

Return lCanc
