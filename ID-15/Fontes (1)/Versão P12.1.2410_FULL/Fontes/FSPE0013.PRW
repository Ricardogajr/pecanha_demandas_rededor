#include 'protheus.ch'

/*/{Protheus.doc} MT131MNU
Ponto de entrada para adicionar ao menu a rotina Integra bionexo.
@type function
@author Ricardo da Silva
@since 26/06/2017
@version 1.0
@return aRotina
/*/

User Function FSPE0013()

	aAdd( aRotina , { "Integra Bionexo"    , "U_REDA002", 0,6,0,Nil } )
	
Return( .T. )