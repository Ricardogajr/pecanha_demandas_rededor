#Include "PROTHEUS.CH"
/*{Protheus.doc} F550AEXC
Ponto de entrada no final do processamento de Caixinha.
@Author	Paulo Krüger
@Since		27/10/2016
@Version	P12.7
@Project	MAN00000463801_EF_001
@Return	lógico	 */

User Function F550AEXC()

Local	lRet	:=	.T.
Local	aArea	:=	GetArea()
Local	cFilOri:=	SET->ET_FILIAL
Local	cCodOri:=	SET->ET_CODIGO
/*===================================================================|
|Exclui documentos anexos quando excluido Movimento de Caixinha.     |
|===================================================================*/
If ISINCALLSTACK('FA550Deleta')
	U_F0400105('FINA550', cFilOri, cCodOri)
EndIf
RestArea(aArea)
Return(lRet)