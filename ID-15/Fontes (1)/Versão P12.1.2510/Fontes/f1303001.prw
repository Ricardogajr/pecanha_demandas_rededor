#Include 'Protheus.ch'

/*
{Protheus.doc} RS01TDOK()
Ponto de entrada é acionado antes de montar a tela com os dados do candidato na admissão
@Author     Bruno de Oliveira
@Since      05/02/2018
@Version    P12.1.07
@Project    MAN0000007423048_EF_030
@Return 	lRet
*/
User Function F1303001(cFilVag,cCodVag,cCodCurr)

	Local aArea   := GetArea()
	Local cAlias1 := GetNextAlias()
	Local cQuery  := ""
	Local lLibPst := SuperGetMv("FS_BLQSOL",,.F.)
	Local lRet    := .T.
	
	If lLibPst
		cQuery := "SELECT SQS.QS_FILPOST, SQS.QS_POSTO, RCL.RCL_NPOSTO, RCL.RCL_OPOSTO "
		cQuery += "FROM " + RetSqlName("SQS") + " SQS "
		cQuery += "INNER JOIN " + RetSqlName("RCL") + " RCL "
		cQuery += "ON ( RCL.RCL_FILIAL = SQS.QS_FILPOST AND RCL.RCL_POSTO = SQS.QS_POSTO "
		cQuery += "AND RCL.D_E_L_E_T_ = ' ') "
		cQuery += "WHERE SQS.QS_FILIAL = '" + cFilVag + "' "
		cQuery += "AND SQS.QS_VAGA = '" + cCodVag + "' "
		cQuery += "AND SQS.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1)
		
		If (cAlias1)->(!EOF())
			If ((cAlias1)->RCL_NPOSTO - (cAlias1)->RCL_OPOSTO) == 0
				MsgAlert("Admissão não será processada devido o posto "+ (cAlias1)->QS_POSTO +" da filial "+ (cAlias1)->QS_FILPOST +" está totalmente ocupado. O Status da vaga será alterado para 'Pendente Posto'")
				DbSelectArea("SQS")
				SQS->(DbSetOrder(1))
				If SQS->(DbSeek(cFilVag+cVaga))
					If SQS->QS_XSTATUS != "A"
						RecLock("SQS",.F.)
						SQS->QS_XSTATUS := "A" //Posto não livre
						SQS->(MsUnLock())
						U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "025")//Aguardando liberação
						DbSelectArea("SQG")
						SQG->(DbSetOrder(1))
						If SQG->(DbSeek(xFilial("SQG")+cCodCurr))
							PA2->(DbSetOrder(6))
							If PA2->(DbSeek(SQG->QG_XFILFAP+SQG->QG_XCODFAP))
								U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "025")//Aguardando liberação
							EndIf	
						EndIf
					EndIf
				EndIf
				lRet := .F.
			Else
				lRet := .T.
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "026")//Liberação do Posto
				DbSelectArea("SQG")
				SQG->(DbSetOrder(1))
				If SQG->(DbSeek(xFilial("SQG")+cCodCurr))
					PA2->(DbSetOrder(6))
					If PA2->(DbSeek(SQG->QG_XFILFAP+SQG->QG_XCODFAP))
						U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "026")//Aguardando liberação
					EndIf	
				EndIf
			EndIf
		EndIf
		
		(cAlias1)->(DbCloseArea())	
	EndIf
	

	
	RestArea(aArea)
	
Return lRet