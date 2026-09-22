#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} RHDIVE02

	Faz validação do campo RA_XUSASOC - RA_XGENERO - RA_XNAMESO

	@type Function Static
	@author Cleiton Genuino da Silva
	@since 28/11/2023
	@version 12.1.2210

/*/
user Function RHDIVE02()
	Local aArea    := GetArea() as array
	Local cGenero  := ""        as character
	Local cNameSoc := ""        as character
	Local cUsaName := ""        as character
	Local lOk      := .T.       as logical

	cGenero   := M->RA_XGENERO
	cNameSoc  := M->RA_XNAMESO
	cUsaName  := M->RA_XUSASOC

	If lOk .And. Upper(cUsaName) == 'S' .And. empty(cGenero)

		 Help(NIL, NIL, "Atenção", NIL, 'Será necessário o preencimento do campo gênero', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Como foi indicado o uso do nome social preencher o gênero e o nome social na aba Diversidade'} )

		 lOk   := .F.  
	EndIf

	If lOk .And. cUsaName == 'S' .And. empty(cNameSoc)

		 Help(NIL, NIL, "Atenção", NIL, 'Será necessário o preencimento do campo nome social', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Como foi indicado o uso do nome social preencher o gênero e o nome social na aba Diversidade'} )

		 lOk   := .F.  
	EndIf

	restarea(aArea)

Return lOk
