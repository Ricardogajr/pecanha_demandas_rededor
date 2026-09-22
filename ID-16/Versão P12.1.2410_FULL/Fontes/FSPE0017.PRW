#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120COR
PONTO DE ENTRADA COR DA LEGENDA
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return aCores Array com as cores da legenda
/*/
User Function FSPE0017()
	
	Local aPar 	:= PARAMIXB[1]
	Local aCores:= {}
	Local nX	:= 00	
	
	aAdd(aCores,{ '!EMPTY(C7_XIDBIO) .And. SC7->C7_QUJE != SC7->C7_QUANT .AND. SC7->C7_CONAPRO != "B" .And. SC7->C7_RESIDUO != "S"', 'PMSTASK4'})//Integrado Bionexo e Liberado
	aAdd(aCores,{ '!EMPTY(C7_XIDBIO) .And. SC7->C7_QUJE != SC7->C7_QUANT .AND. SC7->C7_CONAPRO == "B" .And. SC7->C7_RESIDUO != "S"', 'PMSTASK6'})//Integrado Bionexo e Bloqueado
	aAdd(aCores,{ '!EMPTY(C7_XIDEXNF).And. SC7->C7_QUJE = 0 .And. SC7->C7_RESIDUO != "S"', 'BR_MARRON_OCEAN'})//Processo de Devolução de Nota
	
	For nX := 01 To Len(aPar)
		aAdd(aCores, {aPar[nX][01],aPar[nX][02]}) 
	Next nX
	
Return( aCores )