#Include 'Protheus.ch'

/*{Protheus.doc} WSGPEINSC 
Grava campos adicionais Solicitação Vagas Internas
@author  Henrique Madureira
@since   07/06/2017
@version 12.7
@project MAN0000007423042_EF_017
*/
User Function WSGPEINSC() 
	Local cFilSolic := PARAMIXB[1]
	Local cCodSolic := PARAMIXB[2]
	
	//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return
	EndIf
	
	U_F0801701()

	/***********************************************
	Envio de email ao Superior do Candidato da Vaga
	@author  Edsonho ®
	@since   11/06/2017
	************************************************/
	If !Empty(cFilSolic) .And. !Empty(cCodSolic)
	    u_DOR006RH(cFilSolic,cCodSolic)
	EndIf

Return