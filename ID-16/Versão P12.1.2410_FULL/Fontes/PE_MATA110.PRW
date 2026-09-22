#Include "PROTHEUS.CH"
/*{Protheus.doc} MATA110()
Ponto de entrada no final do processamento da Solicitação de Compra.
@Author	Paulo Krüger
@Since		25/10/2016
@Version	P12.7
@Project   MAN00000463801_EF_001
@Return	lógico	 */

User Function MATA110()

Local	lRet	:=	.T.
Local	aArea	:=	GetArea()
Local	cFilOri:=	SC1->C1_FILIAL
Local	cNumOri:=	SC1->C1_NUM
/*===================================================================|
|Exclui documentos anexos quando excluida a Solicitação de Compras.  |
|===================================================================*/
If IsInCallStack('A110Deleta')
	SC1->(dBSetOrder(01))
	If !SC1->(DbSeek(cFilOri + cNumOri))
		lRet := U_F0400105('MATA110', cFilOri, cNumOri)
	EndIf
EndIf
RestArea(aArea)
Return(lRet)