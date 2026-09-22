#INCLUDE "PROTHEUS.CH"
/*{Protheus.doc} MT103FIM()
Ponto de entrada no final do processamento da Nota de Entrada.
@Author	Paulo Krüger
@Since		27/10/2016
@Version	P12.7
@Project	MAN00000463801_EF_001
@Return	lógico	 */

User Function MT103FIM()

	U_F0400107() // Exclui documentos anexos quando excluida a Nota de Entrada.
Return
