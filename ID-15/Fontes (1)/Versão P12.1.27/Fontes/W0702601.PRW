#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0702601
WebService Server
@type function
@author anieli.rodrigues
@since 27/01/2017
@version 1.0
@Project MAN0000007423041_EF_026
/*/
User Function W0702601()
Return

WSService W0702601 Description "WebService Server responsavel pela inclusão/alteração/exclusão de Pedidos de Compras Externos"
    WSData RegistroPedidoCompra   as PedidoCompra
    WSData RegistroPedidoCompraID as PedidoCompraID
    WSData cRetorno               as String

    WSMethod UpsertPEDCOMPRASEXT Description "Realiza inclusão/alteração de Pedidos de Compras Externos"
    WSMethod DeletePEDCOMPRASEXT Description "Realiza exclusão de Pedidos de Compras Externos"
EndWSService 

WSMethod UpsertPEDCOMPRASEXT WSReceive RegistroPedidoCompra WSSend cRetorno WSService W0702601
   Local oCabec := ::RegistroPedidoCompra:CabecalhoPedidoCompra
   Local oCorpo := ::RegistroPedidoCompra:ItensPedidoCompra
 
    Begin WSMethod
        ::cRetorno  := U_F0702601(oCabec,oCorpo,3)
    End WSMethod
Return .T.

WSMethod DeletePEDCOMPRASEXT WSReceive RegistroPedidoCompraID WSSend cRetorno WSService W0702601
    Local oCabec := ::RegistroPedidoCompraID
 
    Begin WSMethod
        ::cRetorno := U_F0702601(oCabec,Nil,5)
    End WSMethod
Return .T.

WSStruct PedidoCompra
    WSData CabecalhoPedidoCompra as TipoCabecalhoPedidoCompra
    WSData ItensPedidoCompra     as array of ItemPedidoCompra
EndWSStruct

WSStruct PedidoCompraID
    WSData cFILREG as String //Filial
    WSData cNUM    as String //Número do pedido de compra
    WSData cXNUM   as String //Número do pedido de compra do FRONT
EndWSStruct

WSStruct TipoCabecalhoPedidoCompra
    WSData cFILREG               as String //Filial
    WSData cTIPO                 as String //Controle de PC ou AE
    WSData cFORNECE              as String //Código do fornecedor
    WSData cLOJA                 as String //Loja do fornecedor
    WSData cCOND                 as String //Código da condição de Pagamento
    WSData cNUM                  as String //Número do pedido de compra
    WSData cXNUM                 as String //Número do pedido de compra do FRONT
    WSData cXFRONT               as String //Nome do FRONT responsável pela integração
    WSData NomeContatoFornecedor as String //Nome Contato do Fornecedor do Pedido
    WSData DataEmissao           as String //Nome de emissão do pedido de compras
    WSData TipoFreteUtilizado    as String //Tipo de Frete do Pedido (CIF ou FOB)
    WSData ValorFrete            as String //Valor do Frete do Pedido
    WSData cDESCFIN              as String //Percentual de desconto financeiro
EndWSStruct

WSStruct ItemPedidoCompra 
    WSData cITEM    as String //Item do pedido de compra 
    WSData cPRODUTO as String //Código do produto 
    WSData cUM      as String //Unidade de medida (corporativa) 
    WSData cQUANT   as String //Quantidade pedida 
    WSData cPRECO   as String //Preço unitário do item 
    WSData cTOTAL   as String //Valor total do item 
    WSData cNUMSC   as String //Número da solicitação de compra 
    WSData cITEMSC  as String //Item da solicitação de compra 
    WSData cDATPRF  as String //Data Entrega 
    WSData cLOCAL   as String //Armazém 
    WSData cOBS     as String //Observações 
    WSData cCC      as String //Centro de Custo 
    WSData cVLDESC  as String //Valor do Desconto do item 
    WSData cRESIDUO as String //Eliminado por residuo 
    WSData cINFPAC  as String //Informação do paciente
    WSData cXCODSET as String //Codigo setor
    WSData cXDOCFAB	as String //Codigo do fabricante
EndWSStruct
