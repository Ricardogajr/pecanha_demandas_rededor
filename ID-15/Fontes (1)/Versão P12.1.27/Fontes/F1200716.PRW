#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} F1200716
Validação de contratos.
@Author		Paulo Krüger
@Since		15/09/2017
@Version	P12.7
@param		cFilMed - Filial da SC / Medição
@param		cFilCtr - Filial do contrato
@param		cNumCtr - Numero do contrato
@Project    MAN0000007423046
@Return		cMens - Mensagem de erro
/*/

User Function F1200716(cFilMed, cFilCtr, cNumCtr)
 
Local cAlias01	:= ''
Local cNumPed	:= ''
Local cMens		:= ''

Default	cFilMed	:= ''
Default	cFilCtr	:= ''
Default	cNumCtr	:= ''
	
cAlias01	:= GetNextAlias()

BeginSql Alias cAlias01
SELECT	CND.CND_NUMMED NUMMED	,
		CND.CND_FILIAL FILCND
FROM	%Table:CND% CND
WHERE		CND.%notDel%
		AND CND.CND_FILIAL	= %Exp:cFilMed%
		AND CND.CND_CONTRA	= %Exp:cNumCtr%
		AND CND.CND_PEDIDO  = %Exp:cNumPed%
EndSql

(cAlias01)->(DbGoTop())

If (cAlias01)->(!Eof())
	cMens := 'Contrato: ' + AllTrim(cNumCtr) + ' / Filial: ' + cFilCtr + ' com medição não encerrada: ' + (cAlias01)->NUMMED + ' / Filial: ' + (cAlias01)->FILCND + '.'
EndIf

(cAlias01)->(DbCloseArea())

Return(cMens) 