#Include 'Protheus.ch'

/*
{Protheus.doc} F0100324()
Atualização do curriculo
@Author     Bruno de Oliveira
@Since      07/11/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param      cVaga, código da vaga
@Param      lPE, lógico se veio do ponto de entrada
@Return     cRet, retono
*/
User Function F0100324(cVaga, lPE)

Local aArea := GetArea()
Local aAreaRH4 := RH4->(GetArea())
Local aAreaSQS := SQS->(GetArea())
Local cRet	:= "1"
Local cValSal := ""

DbSelectArea("SQS")
SQS->(DbSetOrder(1)) //QS_FILIAL + QS_VAGA
If SQS->(DbSeek(xFilial("SQS") + cVaga))
	
	If !Empty(SQS->QS_XSOLFIL) .AND. !Empty(SQS->QS_XSOLPTL)
	
		DbSelectArea("RH4")
		RH4->(DbSetOrder(1))
		If RH4->(DbSeek(SQS->(QS_XSOLFIL + QS_XSOLPTL)))
			While RH4->(!EOF()) .AND. RH4->(RH4_FILIAL + RH4_CODIGO) == xFilial("RH4") + SQS->QS_XSOLPTL
			
				If !lPE //Chamada do gatilho
			
					If AllTrim(RH4->RH4_CAMPO) == "QG_XCATFUN" //Categoria Funcional
						cRet := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XTURNTB" //Turno de Trabalho
						M->QG_XTURNTB := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XHRMES" //Horas Mês (Jornada)
						M->QG_XHRMES := VAL(Alltrim(RH4->RH4_VALNOV))
						M->QG_XHRDIA := Round(M->QG_XHRMES/30,2)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XHRSEM" //Horas Semanal
						M->QG_XHRSEM := VAL(Alltrim(RH4->RH4_VALNOV))
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XSALHOR" //Salario Hora 
						cValSal := Alltrim(RH4->RH4_VALNOV)
						cValSal := StrTran( cValSal, ".", "" )
 						cValSal := StrTran( cValSal, ", ", "." )
						M->QG_XSALHOR := VAL(cValSal)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XTPCONT" //Tipo Contrato
						M->QG_XTPCONT := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QS_CC" //Centro de Custo
						M->QG_CC := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QS_FUNCAO" //Função
						M->QG_CODFUN := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "RBT_DEPTO" //Departamento
						M->QG_DEPTO := Alltrim(RH4->RH4_VALNOV)
					EndIf
				
				Else //Chamada do Ponto de entrada
				
					If AllTrim(RH4->RH4_CAMPO) == "QG_XCATFUN" //Categoria Funcional
						SQG->QG_XCATFUN := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XTURNTB" //Turno de Trabalho
						SQG->QG_XTURNTB := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XHRMES" //Horas Mês (Jornada)
						SQG->QG_XHRMES := VAL(Alltrim(RH4->RH4_VALNOV))
						SQG->QG_XHRDIA := Round(SQG->QG_XHRMES/30,2)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XHRSEM" //Horas Semanal
						SQG->QG_XHRSEM := VAL(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XSALHOR" //Salario Hora 
						cValSal := Alltrim(RH4->RH4_VALNOV)
						cValSal := StrTran( cValSal, ".", "" )
 						cValSal := StrTran( cValSal, ", ", "." )
						SQG->QG_XSALHOR := VAL(cValSal)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QG_XTPCONT" //Tipo Contrato
						SQG->QG_XTPCONT := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QS_CC" //Centro de Custo
						SQG->QG_CC := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "QS_FUNCAO" //Função
						SQG->QG_CODFUN := Alltrim(RH4->RH4_VALNOV)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "RBT_DEPTO" //Departamento
						SQG->QG_DEPTO := Alltrim(RH4->RH4_VALNOV)
					EndIf
				
				EndIf	
					
			RH4->(DbSkip())
			End
			
		EndIf
		
		If lPE
		/*	
			SQG->QG_VAGA := cVaga
		
			If SQS->QS_XSTATUS <> "2"
							
				RecLock("SQS", .F.)
				SQS->QS_XSTATUS := "2" //Em Recrutamento
				SQS->(MsUnLock())
				
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"2")	//Status da Vaga na FAP			
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "011") //Em Recrutamento
				
			EndIf			
		*/
		EndIf		
		
	EndIf
EndIf	

RestArea(aAreaSQS)
RestArea(aAreaRH4)
RestArea(aArea)

Return cRet