#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0703501
WebService Server de integração de movimentos de Estoque
@author Alex Sandro 
@since 06/02/2017
@version 1.0
@Project MAN0000007423041_EF_035
/*/
User Function W0703501(); Return //--dummy

WSService W0703501 Description "WebService Server responsavel pela inclusão e exclusão de Movimentos Internos"
    WSData oUMovInterno as UMovInterno
    WSData oDMovInterno as DMovInterno
    WSData cRetorno     as String

    WSMethod UpsertMovimentoEstoque   Description "Realiza inclusão/alteração de movimentos internos"
    WSMethod DeleteMovimentoEstoque   Description "Realiza exclusão de Pedidos de movimentos internos"
EndWSService 

WSMethod UpsertMovimentoEstoque WSReceive oUMovInterno WSSend cRetorno WSService W0703501
	Local oParam	:= ::oUMovInterno
	
	Begin WSMethod
        ::cRetorno  := U_F0703501(oParam,3)
    End WSMethod
Return .T.

WSMethod DeleteMovimentoEstoque WSReceive oDMovInterno WSSend cRetorno WSService W0703501
	Local oParam	:= ::oDMovInterno
	
    Begin WSMethod
	    ::cRetorno  := U_F0703501(oParam,5)
	End WSMethod
Return .T.

WSStruct UMovInterno
    WSData cFILREG  as String //Código Filial
    WSData cLOCAL   as String //ocal de Estoque
    WSData cCOD     as String //Código do Produto
    WSData cXIDEXT  as String //ID Externo (número + item)
    WSData cXSETOR  as String //Código do Setor
    WSData cXCONSIG as String //Produto consignado (S/N)
    WSData cXFORN   as String //Código do fornecedor
    WSData cXLJFOR  as String //Loja do fornecedor
    WSData cCUSTO1  as String //Custo Total do movimento
    WSData cEMISSAO as String //Data de Emissão
    WSData cXHORMOV as String //Hora da Movimentação
    WSData cDOC     as String //Número do Documento
    WSData cQUANT   as String //Quantidade do Movimento
    WSData cSALDO   as String //Saldo de Inventário
    WSData cXINVENT as String //Inventario (S/N)
    WSData cTM      as String //Tipo de movimento
    WSData cUM      as String //Unid. de Medida (consumo)
    WSData cUSUARIO as String //Usuário responsável pela digitação (login do usuário)
    WSData cXNOTA   as String //Numero da Nota
    WSData cXSERIE  as String //Serie da Nota
    WSData cFILORIG as String //Filial de origem
    WSData cFILDEST as String //Filial de destino 
	WSData cCC as opt_String //Filial de destino 
EndWSStruct

WSStruct DMovInterno
    WSData cFILREG as String	//Filial
    WSData CLOCAL  as String   //Codigo do armazem
    WSData CCOD    as String   //Codigo do produto
    WSData CXIDEXT as String   //ID Externo
EndWSStruct

