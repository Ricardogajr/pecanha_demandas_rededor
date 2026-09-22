#Include "PROTHEUS.CH"

/*{Protheus.doc} F0400107
Exclui documentos anexos quando excluida a Nota de Entrada.
@Author	Paulo Krüger
@Since		27/10/2016
@Version	P12.7
@Project	MAN00000463801_EF_001
@Return	lógico
*/

User Function F0400107()

	Local aArea     := GetArea()
	Local cFilOri   := SF1->F1_FILIAL
	Local cDocOri   := SF1->F1_DOC
	Local cSerOri   := SF1->F1_SERIE
	Local cForn     := SF1->F1_FORNECE
	Local cForLoj   := SF1->F1_LOJA
    Local lDeletado := PARAMIXB[01] == 5
    Local lConfirma := PARAMIXB[02] == 1

	If lConfirma .and. lDeletado
		SF1->(dBSetOrder(01))
		If !SF1->(DbSeek(cFilOri + cDocOri + cSerOri + cForn + cForLoj))
			// Exclui documentos anexos quando excluida a Nota de Entrada.
			U_F0400105('MATA103',cFilOri, cDocOri + cSerOri + cForn + cForLoj)
		EndIf
	EndIf

	RestArea(aArea)

Return 