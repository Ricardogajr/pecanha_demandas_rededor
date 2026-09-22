#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120ALT
Ponto de entrada para Validar o registro do PC e retorna andamento do processo
Nï¿½o autoriza o usuário alterar ou excluir um pedido de compras integrado pelo bionexo.
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return aCores Array com as cores da legenda ATENÇÃO, VERIFICAR SE JÃ ESTA EM USO POR OUTRAS ROTINAS
/*/
User Function FSPE0014()

	Local lRet	:= .T.
	Local nPar 	:= PARAMIXB[1]

	//If (nPar == 4 .Or. nPar == 5) .And. !Empty(SC7->C7_XIDBIO)
	If (nPar == 5) .And. !Empty(SC7->C7_XIDBIO)
		//Alert("Pedido de compras Integrado com a Bionexo. " + Iif(nPar==4, "Alteração", "Eliminação") +" não será permitida!!")
		Alert("Pedido de compras Integrado com a Bionexo. Eliminação não será permitida!!")
		lRet	:= .F.		
	EndIf

Return( lRet )