#Include 'Protheus.ch'

/*
{Protheus.doc} F0100326()
Após admissão atualiza status da vaga
@Author     Bruno de Oliveira
@Since      25/11/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param      cVaga, código da vaga
@param cCPF, characters, descricao
*/

User Function F0100326(cCPF)

	Local aArea := GetArea()
	Local aAreaSQS := SQS->(GetArea())
	Local aAreaSQG := SQG->(GetArea())
	Local aAreaPA2 := PA2->(GetArea())

	If IsInCallStack( "RSPM001")
		
		DbSelectArea("SQG")
		SQG->(DbSetOrder(3))
		SQG->(DbGotop())
		If SQG->(DbSeek(xFilial("SQG") + alltrim(cCPF)))
			
			//cSQGVaga := SQG->QG_VAGA
			cSQGCur	 := SQG->QG_CURRIC
		
			// 416094 - Rogerio Carvalho - AMS Rio - 11/07/2018 - DOR04520620 
			DbSelectArea("SQS")
			SQS->(DbSetOrder(1)) //QS_FILIAL + QS_VAGA
			SQS->(DbGotop())
			If SQS->(DbSeek(xFilial("SQS") + alltrim(cVaga)))
		
				/* Jamer Nunes Pedroso - 19/05/2017
				RecLock("SQS", .F.)
				SQS->QS_XSTATUS := "7" //Concluída
				SQS->(MsUnlock())

				*/

				RecLock("SQS", .F.)
				SQS->QS_XSTATUS := "9" // 9=Ass.Contrato
				SQS->(MsUnlock())

				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "023")
				U_F0500201(SQS->QS_XSOLFIL, SQS->QS_XSOLPTL, "020")

				U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "023")
				U_F0500201(PA2->PA2_FILSOL, PA2->PA2_SOL, "020")
				U_F0500211(SQS->QS_FILIAL,SQS->QS_VAGA,"9")
				
				DbSelectArea("PA2")
				PA2->(DbSetOrder(1))
				PA2->(DbGotop())
				If PA2->(DbSeek(xFilial("PA2") + alltrim(cVaga)+ alltrim(cSQGCur)))
		
		
					//If PA2->(!Eof()) .And. PA2->PA2_SIT != "AP"
					 If PA2->PA2_SIT <> "AP" .AND. PA2->PA2_SIT <> "RE"  // 416094 - Rogerio Carvalho - AMS Rio - 11/07/2018 - DOR04520620 
						RecLock("PA2",.F.)
							PA2->PA2_SIT := "AP"
							PA2->PA2_STSVAG := "9"
						MsUnLock()
					EndIf
				Endif
			EndIf
		Endif
	EndIf

	RestArea(aAreaPA2)
	RestArea(aAreaSQG)
	RestArea(aAreaSQS)
	RestArea(aArea)

Return
