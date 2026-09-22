#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120BRW
//	 Adiciona botï¿½es ï¿½ rotina     
@author Ricardo
@since 08/06/2017
@version 1.0
@type function
/*/
*---------------------------*
User Function FSPE0015()
*---------------------------*

	aAdd( aRotina, { 'Gerar SC/Resíduo', 'U_REDA003', 0, 4 } )
	aAdd( aRotina, { 'Imprimir pedido', 'U_TEWBTYR2', 0, 4 } )
	aAdd( aRotina, { 'Reenviar PC', 'U_F1207201', 0, 4 } )
                                                                                                                                                
Return( .T. )