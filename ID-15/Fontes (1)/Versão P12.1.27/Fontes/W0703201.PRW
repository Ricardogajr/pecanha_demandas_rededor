#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} W0703201
Web Services Server responsável pelas integrações de pedidos de vendas.
@author Paulo Krüger
@since 14/02/2017
@version 12.7
@project MAN0000007423041_EF_032
@return .T.
/*/

WSService W0703201 Description 'WebService responsável pela integração de Pedidos de Venda'
	WSData PV 	as PedidoVenda
	WSData cRET	as String

	WSMethod InsertPV	 	Description 'Método responsável pela inclusão de pedido de venda'
EndWSService

WSMethod InsertPV WSReceive PV WSSend cRET WSService W0703201
	Begin WSMethod
		::cRet  := U_F0703201(PV:CabPV,PV:ItPV,PV:ParcelaPV,3)
	End WSMethod
Return .T.

WSStruct CabecPV
	WSData cFILREG   as String
	WSData cIDCLIEN  as String
	WSData cNUM      as String
	WSData cEMISSAO  as String
	WSData cDESCONT  as String
	WSData cNOMEP	 as String
	WSData cDATANAS  as String
	WSData cCPFNAS   as String
	WSData cNUMATE   as String
	WSData cXTIPO    as String
EndWSStruct

WSStruct ItensPV
	WSData cITEM    as String
	WSData cPRODUTO as String
	WSData cXSETOR  as String
	WSData cPRCVEN  as String
	WSData cDESCRI  as String
	WSData cQTDVEN  as String
	WSData cVALOR   as String
	WSData cCC      as String
	WSData cLOCAL   as String
	WSData cXFATREM as String
EndWSStruct

WSStruct ParcelaPV
	WSData cVALOR	as String
	WSData cVENCTO	as String
EndWSStruct

WSStruct PedidoVenda
	WSData CabPV     as CabecPV
	WSData ItPV      as ARRAY OF ItensPV
	WSData ParcelaPV as ARRAY OF ParcelaPV
EndWSStruct