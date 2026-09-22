// ###########################################################################################
// -----------+-------------------+-----------------------------------------------------------
// Data       | Autor: 	          | Descricao
// -----------+-------------------+-----------------------------------------------------------
// 01/04/2020 | Thais Paiva  	  | Rotina customizada para manipula��o da SX5
// -----------+-------------------+-----------------------------------------------------------
// Par�metros | cTipo	  		  | L (Leitura) - G (Grava��o) - A (Array) 
//            | cTabela           | C�digo da Tabela a ser lida/alterada (Obrigat�rio)
//            | cChave            | Chave de pesquisa da tabela                      
//            | nRetorno          | Retorno da pesquisa sendo: (Leitura)
//            |                   | 1 FILIAL - 2 TABELA - 3 CHAVE - 4 DESCRICAO  
//            | cTxtPor           | String com a descri��o da tabela em Portugu�s (Grava��o)
//            | cTxtIng           | String com a descri��o da tabela em Ingl�s (Grava��o)
//            | cTxtEsp           | String com a descri��o da tabela em Espanhol (Grava��o)
//            | cTxtAlt           | String com a descri��o da tabela no Idioma Alternativo (Grava��o)
// -----------+-------------------+-----------------------------------------------------------
// Retorno 	  |	FWGetSX5		  | Array:  1 FILIAL - 2 TABELA - 3 CHAVE - 4 DESCRICAO  
// -----------+-------------------+-----------------------------------------------------------

#Include 'Protheus.ch'
#Define CRLF Chr(13) + Chr(10)

User Function SX5UTILI(cTipo,cTabela,cChave,nRetorno,cTxtPor,cTxtIng,cTxtEsp,cTxtAlt)
Local _aRetLe := {}
Local cRetL	  := ""	

DEFAULT cChave := ""
DEFAULT nRetorno := 0
DEFAULT cTxtPor := ""
DEFAULT cTxtIng := ""
DEFAULT cTxtEsp := ""
DEFAULT cTxtAlt := ""
DEFAULT cTipo	:= ""

If cTipo == "L"
	
	_aRetLe := FWGetSX5(cTabela,cChave)
	
	If Len(_aRetLe) > 0
	
		cRetL := _aRetLe[1][nRetorno]
	
	Else
		
		alert("Tabela" + cTabela + " Chave: "+ cChave + " não existe.")
		
	EndIf
	
ElseIf cTipo == "G"

	FwPutSX5(,cTabela,cChave,cTxtPor,cTxtIng,cTxtEsp,cTxtAlt)

Else

	cRetL := FWGetSX5(cTabela)
	
	If Len(cRetL) == 0
	
		
		alert("Tabela" + cTabela + " não existe.")
		
	EndIf
	
EndIf

Return cRetL 