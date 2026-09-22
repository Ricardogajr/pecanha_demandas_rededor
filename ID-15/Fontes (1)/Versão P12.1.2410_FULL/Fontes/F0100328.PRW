#Include 'Protheus.ch'

/*
{Protheus.doc} F0100328()
Verifica se a vaga pode ser publicada ou não
@Author     Bruno de Oliveira
@Since      09/01/2017
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Param      cCodVaga, caracter, código da vaga
*/
User Function F0100328(cCodVaga)

	Local lRet := .T.

	If SQS->QS_XPUBLIC == "2" //Não
		lRet := .F. 
	Else
		lRet := .T.
	EndIf
	
Return lRet