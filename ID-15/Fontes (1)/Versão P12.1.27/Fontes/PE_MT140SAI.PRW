#Include "PROTHEUS.CH"
/*{Protheus.doc} MT140SAI()
Ponto de entrada no final do processamento da Pre-Nota de Entrada.
@Author	Paulo Krüger
@Since		27/10/2016
@Version	P12.7
@Project   MAN00000463801_EF_001
@Return	lógico*/

User Function MT140SAI()

Local	lRet	:=	.T.
Local	aArea	:=	GetArea()
Local	cFilOri:=	SF1->F1_FILIAL
Local	cDocOri:=	SF1->F1_DOC
Local	cSerOri:=	SF1->F1_SERIE
Local	cForn	:=	SF1->F1_FORNECE
Local	cForLoj:=	SF1->F1_LOJA

If FunName() == 'MATA140'
	/*===================================================================|
	|Exclui documentos anexos quando excluida a Pre-Nota de Entrada.     |
	|===================================================================*/
	If PARAMIXB[01] == 5
		SF1->(dBSetOrder(01))
		If !SF1->(DbSeek(cFilOri + cDocOri + cSerOri + cForn + cForLoj))
			/*===================================================================|
			|Exclui documentos anexos quando excluida a Pré-Nota.                |
			|===================================================================*/
			lRet := U_F0400105('MATA140',cFilOri, cDocOri + cSerOri + cForn + cForLoj)
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return(lRet)