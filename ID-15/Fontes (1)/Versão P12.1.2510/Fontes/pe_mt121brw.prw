#INCLUDE 'Protheus.ch'

/*{Protheus.doc} MT121BRW()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author		Nairan Alves Silva
@Since			27/09/2016
@Project    	MAN00000463801_EF_001
*/

User Function MT121BRW()
	
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	U_F0400103()
	
	If lExecPECli .And. FindFunction( "U_FSPE0005")
	    U_FSPE0005()
	EndIf

    If Type("aRotina") == "A"
        //aRotina é uma variável private disponível para adicionar novas opções no menu Ações Relacionadas
        AAdd(aRotina, {"Alteração de Fornecedor", "U_F1304901()" , 0, 4, 0, Nil})
    EndIf

Return