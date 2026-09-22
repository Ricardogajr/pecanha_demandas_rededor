#Include "PROTHEUS.CH"
/*{Protheus.doc} FINA050
Ponto de entrada no final do processamento da Título a Pagar.
@Author	Paulo Krüger
@Since		27/10/2016
@Version	P12.7
@Project   MAN00000463801_EF_001
@Return	lógico	 */

User Function FINA050()

Local	lRet	:=	.T.
Local	aArea	:=	GetArea()
/*===================================================================|
|Exclui documentos anexos quando excluida a Título a Pagar.          |
|===================================================================*/
If ISINCALLSTACK('FA050Delet')
	lRet := U_F0400105('FINA050',SE2->E2_FILIAL, SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA))
	lRet := U_F0400105('FINA750',SE2->E2_FILIAL, SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)) .Or. lRet
EndIf
RestArea(aArea)
Return(lRet)