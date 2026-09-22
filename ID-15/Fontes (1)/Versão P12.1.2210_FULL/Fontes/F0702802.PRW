#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702802
Função para gravação do ID de integração na tabela SE5
@type User function
@author anieli.rodrigues
@since 23/03/2017
@version 12.7
@project MAN0000007423041_EF_028
/*/

User Function F0702802()

	Local lInt := IsInCallStack("U_F0702801") 

		If lInt 
      		Reclock("SE5",.F.)
			E5_XID = cXID
			SE5->(MsUnlock())
		EndIf 	

Return