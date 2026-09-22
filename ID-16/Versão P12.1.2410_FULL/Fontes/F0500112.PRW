#INCLUDE "Protheus.ch"

/*{Protheus.doc} F0500112()
Retorna as informações da P10 a partir da solicitação
@type function
@author Roberto Souza
@since 08/11/2016
@version 1.0
@param cMatric, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
*/
User Function F0500112( cSolic, cStatus, cFilSol )
	
	Local aInfo 	:= Array(10)
	Local cP10		:= GetNextAlias()
	
	Default cSolic  := ""
	Default cStatus := ""
	Default cFilSol	:= xFilial("P10")
	
	BeginSql alias cP10
		SELECT P10_COD,P10_CODRES, P10_MATSOL, P10_DTSOLI FROM %table:P10%
		WHERE P10_CODRH3 = %exp:cSolic% AND
		P10_FILIAL = %exp:cFilSol% AND
		%notdel%
	EndSql
	
	If (cP10)->(!Eof())
		aInfo[01] := (cP10)->P10_COD
		aInfo[02] := (cP10)->P10_CODRES
		aInfo[03] := (cP10)->P10_MATSOL
		aInfo[04] := (cP10)->P10_DTSOLI
		
		If !(EMPTY(cStatus))
			DbSelectArea("P10")
			P10->(DbSetOrder(1))
			If P10->(DbSeek(cFilSol + (cP10)->P10_COD))
				RecLock("P10",.F.)
				P10->P10_STATUS := cStatus
				P10->(MsUnlock())			
			EndIf
		EndIf
	EndIf
	
Return aInfo
