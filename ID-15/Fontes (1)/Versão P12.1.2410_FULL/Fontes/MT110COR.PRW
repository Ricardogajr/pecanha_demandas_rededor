#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT110COR
Ponto de entrada manipula o Array com as regras e cores da Mbrowse.
Adicionada as cor DESTINOS para solicitações que foram integradas com o bionexo.
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return aCores Array com as cores da legenda.
/*/
User Function MT110COR()

	Local aPar 		:= ParamIxb[1]
	Local aCores 	:= {}
	Local nX		:= 00

	aAdd( aCores, {'!Empty(C1_XIDBIO) .AND. C1_XENVBIO == "3"  .And. C1_RESIDUO != "S"', "PMSTASK5"})//Aguardando desvínculo Bionexo
	aAdd( aCores, {'C1_XENVBIO == "1" .And. C1_RESIDUO != "S"',"PMSTASK6"})//Aguardando integração Bionexo
	aAdd( aCores, {'!Empty(C1_XIDBIO) .And. C1_XENVBIO == "2" .And. Empty(C1_PEDIDO) .And. Empty(C1_COTACAO) .And. C1_QUJE != C1_QUANT .And. C1_RESIDUO != "S"',"PMSTASK4"})//Integrado Bionexo
	aAdd( aCores, {'C1_XENVBIO == "4" .And. C1_RESIDUO != "S"',"PMSTASK3"})//Erro de integração bionexo
	
	For nX := 01 To Len(aPar)
		aAdd(aCores, {aPar[nX][1], aPar[nX][2]}) 
	Next nX

Return aCores