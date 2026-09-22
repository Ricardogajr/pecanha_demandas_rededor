#Include 'Protheus.ch'
/*/{Protheus.doc} MT150LEG
Adiciona legendas e regras de cores na Mbrowse - Atualiza Cotação
@type function
@author Ricardo
@since 02/06/2017
@version 1.0
@return aRet  O retorno será um array: 1- com novas regras de cores na mBrowse  2 - com novas cores para a legenda.
/*/
User Function MT150LEG()

	Local nRegra 	:= PARAMIXB[1]  
	Local aRet 		:= {}

	If nRegra == 1                                       
		aAdd(aRet,{ "C8_XIDBIO != ' '" , 'PMSTASK4' })  
	ElseIf nRegra == 2      
		aAdd(aRet,{'PMSTASK4' , 'Integrado Bionexo' })  
	EndIf

Return aRet