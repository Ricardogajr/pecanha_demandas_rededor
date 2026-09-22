#include "protheus.ch"

/*/{Protheus.doc} F0600102
Gravação na tabela de interface.

@project	MAN0000007423040_EF_001
@type 		function
@author 	alexandre.arume
@since 		07/11/2016
@version 	1.0
@param 		cTbl, character, Nome da tabela
@param 		aTblStru, array, Estrutura dos campos da tabela
@param 		aValues, array, Valores a serem inseridos
@return 	lRet, Gravou na tabela de interface ou não.

/*/
User Function F0600102(cTbl, aTblStru, aValues)

	Local cMsgError := ""
	
	// Conexao com base externa.
	If !U_F06001C1(@cMsgError)
		Conout(cMsgError)		
		Return .F.
	EndIf
	
	// Criação da tabela de interface.		
	If !U_F06001C3(cTbl, aTblStru, @cMsgError)
	
		// Desconecta da basa externa.
		U_F06001C2(@cMsgError)
		Conout("Erro na criação da Tabela Interface - " + cTbl)
		Return .F.
		
	EndIf
	
	// Inserção na tabela de interface.			
	If !U_F06001C4(cTbl, aTblStru, aValues, @cMsgError)
		
		// Desconecta da basa externa.
		U_F06001C2(@cMsgError)
		Conout(cMsgError)
		Return .F.
		
	EndIf
	
	// Desconecta da basa externa.
	If !U_F06001C2(@cMsgError)
		Conout(cMsgError)
		Return .F.
	EndIf
	
Return .T.
