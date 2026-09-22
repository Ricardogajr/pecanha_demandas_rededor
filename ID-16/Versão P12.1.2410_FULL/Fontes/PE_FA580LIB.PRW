#INCLUDE 'Protheus.ch'
 
/*
{Protheus.doc} FA580LIB()
O ponto de entrada FA580LIB foi desenvolvido para bloquear ou não a liberação manual.
Necessita de um retorno .T. ou .F.
@Author     Paulo Krüger
@Since      20/01/2017
@Project    MAN00000462901_EF_010
*/

User Function FA580LIB()

	Local lRet       := .T.
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	
	lRet := U_F010101M()
	
	If lExecPECli .And. lRet .and. FindFunction("U_FSPE0006")
	    lRet := U_FSPE0006()
	EndIf

Return lRet