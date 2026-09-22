/*
{Protheus.doc} F0500412()
Visualizar a solicitação de movimentação de pessoal
@Author     Nairan Alves Silva
@Since      24/05/2017
@Version    P12.1.07
@Project    MAN00000462901_EF_003
*/

User Function F0500412(cAliasSra)
	Local aAreaRH3	:= RH3->(GetArea())
	Local aAreaSRA	:= SRA->(GetArea())
	Local cFilBkp	:= ""
	Local lSolicita	:= .F.
	
	cFilBkp := cFilAnt
	
	If SRA->(DbSeek((cAliasSra)->(RA_FILIAL + RA_MAT)))
		RH3->(DbSetOrder(2))
		If AllTrim(SRA->RA_XSTMVTO) == '1'
			If RH3->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
				While RH3->(RH3_FILIAL + RH3_MAT) ==  SRA->RA_FILIAL + SRA->RA_MAT 
					If AllTrim(RH3->RH3_XTPCTM) == "006" .And. RH3->RH3_STATUS $ '1,4'
						lSolicita := .T.
						//nRecRH3 := RH3->(Recno())	
						Exit
					EndIf
					RH3->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	
	If lSolicita
		cFilAnt := RH3->RH3_FILIAL
		FWExecView('', 'F0100323', 4, , { || .T. })//, ,, ,, ,, oModGPE)
	Else
		Help("",1, "Help", "Atenção", "Não existe solicitação em aberto para este colaborador." , 3, 0)
	EndIf
	
	cFilAnt := cFilBkp
	RestArea(aAreaRH3)
	RestArea(aAreaSRA)
Return