#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} F1200601()
Medição manual.
@Author		Paulo Krüger
@Since		30/08/2017
@Version	P12.7
@Project    MAN0000007423046_EF_001
@Param		
*/
User Function F1200601()

Local lValData	:= .F.
Local lPerg		:= .F.

	If !LockByName('F1200600_' + cFilAnt ,.F.,.F. )
		MsgStop("Rotina já está em execução","Medição Automática")
	Else
		
		While !lValData 
			lPerg := Pergunte('FSW1200601',.T.)
			If lPerg 
				If mv_par05 <= mv_par06
					lValData := .T.
				Else
					Alert('Verifique as datas informadas nos parâmetros.')
				EndIf
			Else
				lValData := .T.
			EndIf	
		EndDo	

		If lPerg
			Processa({|| fProcMed()}, 'Aguarde...', 'Processando medições...',.F.)
		EndIf
		
		UnLockByName('F1200600_' + cFilAnt,.F.,.F. )

	EndIf
	
Return

/*
{Protheus.doc} fProcMed()
Processa Medições manuais.
@Author		Paulo Krüger
@Since		30/08/2017
@Version	P12.7
@Project    MAN0000007423046_EF_001
@Param		
*/
Static Function fProcMed()

	U_F1200701(.T., .T., .T., mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06, mv_par07, mv_par08)	//Seleciona solicitacoes de compras para medicao

Return