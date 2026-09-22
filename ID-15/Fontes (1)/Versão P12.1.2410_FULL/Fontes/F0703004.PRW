#INCLUDE 'TOTVS.CH'

/*{Protheus.doc} F0703004 
Parametrização e chamada de rotina de recalculo de consumo médio dos produtos no mês.
@author Paulo Krüger
@since  06/12/2017
@project MAN0000007423041_EF_030
@version P12.1.7c
@return Nil   
*/  

User Function F0703004() 

Local cPerg		:= 'FSW0703004'
Local dAux		:= dDataBase
Local lContPerg	:= .T.
Local nX		:= 0

While lContPerg 
	//Parametros:	
	//01 - Database
	//02 - Código do produto
	//03 - Local de Estoque
	If Pergunte(cPerg, .T.)
		If Empty(mv_par01)
			Alert('Informação de data obrigatória.')
			Loop
		Else
			lContPerg := .F.
		EndIf			
	
		If !lContPerg
			If MsgYesNo("Deseja gerar todos os dados do período "+SubStr(DToS(mv_par01),01,06)+" até o período "+SubStr(DToS(dDataBase),01,06)+"?","Atenção")
				dAux := mv_par01
				For nX := 1 To DateDiffMonth(mv_par01,ddatabase)
					//ProcRegua(DateDiffMonth(mv_par01,ddatabase))
					U_F0703005(cFilAnt, dAux, mv_par02, mv_par03)
					Processa( {|| U_F0703005(cFilAnt, dAux, mv_par02, mv_par03)}, 'Aguarde...', 'Atualizando período tabela P28 (Consumo Médio no Mês).',.F.)
					dAux := MonthSum(dAux,1)
					//IncProc()
				Next
			EndIf
		EndIf
		
	Else
		lContPerg := .F.
	EndIf
EndDo

Return