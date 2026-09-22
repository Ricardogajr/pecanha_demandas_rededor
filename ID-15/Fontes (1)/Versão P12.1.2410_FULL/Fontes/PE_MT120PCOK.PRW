#Include 'Protheus.ch'

/*/{Protheus.Doc} MT120PCOK    
Valida Pedido de Compra - Fonte MATA120
@project	MAN00000462901_EF_004     
@author		Paulo Krüger
@version	P12
@since		15/06/2016  
@Return		.T., A linha sera sempre valida mas utilizamos o PE para alterar o campo C7_XSTATUS                                                           
/*/
User Function MT120PCOK()
	
	Local lPCValido := .T.
	
	lPCValido := U_F0100406()

Return lPCValido