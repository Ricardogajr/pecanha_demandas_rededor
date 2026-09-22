#Include 'Protheus.ch'

/*
{Protheus.doc} TCF040VLD()
Verifica se funcionário existe, se existe ele verifica demissão e motivo
Este Ponto de Entrada tem como objetivo validar se determinada solicitação deverá ser atendida ou reprovada
@Author     Ademar Fernandes
@Since      02/05/2017
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return	 lRet
*/
User Function TCF040VLD()

Local lCont := U_F0201407()
	
Return lCont
