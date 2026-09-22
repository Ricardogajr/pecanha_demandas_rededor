#INCLUDE 'PROTHEUS.CH'

/*{Protheus.doc} F1200717
Rotina chamada a partir do ponto de entrada MT097GRV.
Verifica se a medição de contrato vem de rotina customizada.
@author 	Paulo Krüger
@since 		18/09/2017
@version 	P12.7
@Project    MAN0000007423046
@Param		lInicio, .T. (INICIO) .F. (FIM)
@Return 	Lógico
*/

User Function F1200717(lInicio)

Local lRet

Default lInicio := .F.

If IsInCallStack('U_F1200709')
	lRet := .T.
	If lInicio
		lRet := .F.
	EndIf
EndIf

Return lRet