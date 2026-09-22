#include "totvs.ch"

/*/{Protheus.doc} FA050UPD
Pré valida inclusão alteração e exclusão de contas a pagar
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project MAN0000007423041_EF_033
@return lRet
/*/ 

User Function FA050UPD()

	Local aArea := GetArea()
	Local aAreaE2 := SE2->(GetArea())
	Local lRet := .T.

	lRet := U_F0703305()

	If (lRet .And. !INCLUI .And. !ALTERA)
		U_FLJMUNIC()//Função para mudar a loja do fornecedor de titulo de ISS para 1 caso exista.
	EndIf
	
RestArea(aAreaE2)
RestArea(aArea)
Return lRet
