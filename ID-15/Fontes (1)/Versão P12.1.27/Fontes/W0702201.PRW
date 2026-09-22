#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} W0702201
Webservice Server para ATUALIZACAO de pedido de compras para o IIB
@type User function
@author robson.william
@since 10/03/2017
@version 12.7
@param 
@project	MAN0000007423041_EF_022
@return lRet
/*/

User Function W0702201();Return //--dummy

WSService W0702201 Description "WebService Server para Atualização de Pedido de Compras"
	WSData RegPedComp as PedidoComprasERP
	WSData cRet       as String
	
	WSMethod AtualizaPC Description "Retorna número do pedido de compra do Front."
EndWSService

WSMethod AtualizaPC WSReceive RegPedComp WSSend cRet WSService W0702201
    Begin WSMethod
	    ::cRet := U_F0702201(::RegPedComp)
    End WSMethod
Return .T. 

WSStruct PedidoComprasERP
	WSData cFilReg as String
    WSData cNum    as String
    WSData cXNum   as String
	WSData cXFront as String
EndWSStruct