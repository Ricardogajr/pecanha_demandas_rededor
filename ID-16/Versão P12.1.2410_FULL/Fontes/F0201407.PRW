#INCLUDE "Protheus.ch"
 
/*
{Protheus.doc} F0201407()
Verifica se funcionário existe, se existe ele verifica demissão e motivo
Este Ponto de Entrada tem como objetivo validar se determinada solicitação deverá ser atendida ou reprovada
@Author     Ademar Fernandes
@Since      02/05/2017
@Version    P12.7
@Project    MAN00000462901_EF_002 
@Return	 lRet
*/
User Function F0201407()
Local lCont := .T.

If RH3->RH3_TIPO $ "H|9"	//-Candidato Externo
	
	//-Posiciona tabelas antes de chamar função
	POSICIONE("RH4", 1, RH3->(RH3_FILIAL+RH3_CODIGO)+"2", "RH4_VALNOV")
	POSICIONE("SQG", 1, xFilial("SQG")+RH4->RH4_VALNOV, "QG_CIC")

	lCont := U_F0201404(.T.)		//-Verifica Blacklist
	If lCont
		lCont := U_F0100201(.T.)	//-Verifica tab.auxiliar U0001
	EndIf
EndIf
   		
Return lCont