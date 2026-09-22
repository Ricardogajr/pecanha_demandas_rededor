#Include "PROTHEUS.CH"
/*{Protheus.doc} GPM060EX()
Ponto de entrada no final do processamento de Manutenção de Benefícios.
@Author	Paulo Krüger
@Since		28/10/2016
@Version	P12.7
@Project	MAN00000463801_EF_001
@Return	lógico	 */

User Function GPM060EX()

Local	lRet	:=	.T.
Local	aArea	:=	GetArea()

Local	cFilOri:=	RC1->RC1_FILTIT
Local	cCodOri:=	RC1->RC1_CODTIT
Local	cPreOri:=	RC1->RC1_PREFIX
Local	cNumOri:=	RC1->RC1_NUMTIT

//Valida pelos parametros se essa empresa irá executar essas chamadas.
If !U_VALIDEMP()
	Return lRet
EndIf
	
/*====================================================================================|
|Exclui documentos anexos quando excluido registro na rotina Manutenção de Benefícios.|
|====================================================================================*/
RC1->(dBSetOrder(01))
//If !RC1->(DbSeek(cFilOri + cCodOri + cPreOri + cNumOri)) Thais Paiva - 9746207
If !RC1->(DbSeek(xFilial("RC1") + cFilOri + cCodOri + cPreOri + cNumOri))
	U_F0400105('GPEM660', cFilOri, cCodOri + cPreOri + cNumOri)
EndIf
RestArea(aArea)
Return(lRet)