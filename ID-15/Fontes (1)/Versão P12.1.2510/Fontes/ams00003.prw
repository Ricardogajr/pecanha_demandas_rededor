#Include 'Protheus.ch'
#include "rwmake.ch"


/*
{Protheus.doc} AMS00003()
Funcao para gerar ID a ser usado no campo PA6_ID - Integração de dados 
@Author     Rogerio Carvalho
@Since      21/05/2017
@Version    P12.1.07
@Project    
*/
User Function AMS00003()

	Local cID      := FWUUIDV4(.F.)
	Local lRetId   := .f.				 
	
	dbSelectArea("PA6")
	DbOrderNickName("PA6ID")

	// Verifica se o ID gerado não existe na tabela PA6
	// Só permite prosseguir se o ID não existir
	
	While !lRetId
	  	
	  	PA6->(dbgotop())
		
		if PA6->(dbSeek(cID))
			
			cID:=FWUUIDV4(.F.)

		Else
		
			lRetId:= .t.
		
		EndIf
		
	Enddo
	
return (alltrim(cID)) 