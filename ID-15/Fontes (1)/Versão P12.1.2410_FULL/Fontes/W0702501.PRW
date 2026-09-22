#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} W0702501 
Função de identificação do webservice de integração de Cadastro de Produtos.
@type 		function
@author 	robson.william, Reinaldo Dias
@since 		16/02/2017
@version 	1.0
@project	MAN000007423041_EF_025
/*/
User Function W0702501(); Return //--dummy

WSService W0702501 Description "WebService Server para Integração de Produtos"
	WSData RegProduto   as ProdutoImpRedeDor
	WSData RegStatus    as ProdutoStatus    
	WSData cRet         as String
	
	WSMethod UpsertProduto Description "Inclusão e Alteração de Produtos"
	WSMethod UpsertStatus  Description "Alteração do Status na P17"
EndWSService

WSMethod UpsertProduto WSReceive RegProduto WSSend cRet WSService W0702501
    Begin WSMethod
        ::cRet := U_F0702501(::RegProduto)
    End WSMethod
Return .T.

WSMethod UpsertStatus WSReceive RegStatus WSSend cRet WSService W0702501
    Begin WSMethod
        ::cRet := U_F0702504(::RegStatus)
    End WSMethod
Return .T.

WSStruct ProdutoImpRedeDor
	WSData cFilReg   as String
    WSData cCod		 as String
    WSData cDesc	 as String
    WSData cXDESCLI	 as String
    WSData cXDESCLO	 as String
    WSData cTipo	 as String
    WSData cXMATSER	 as String
    WSData cGRUPO	 as String
    WSData cXGRPPRO	 as String
    WSData cXSUBGRP	 as String
    WSData cLocPad	 as String
    WSData cUM		 as String
    WSData cSEGUM	 as String
    WSData cCONV	 as String
    WSData cTIPCONV	 as String
    WSData cXTERUM 	 as String
    WSData cXCODFAB	 as String
    WSData cXBRASIN	 as String
    WSData cXSIMPRO	 as String
    WSData cXTUSS  	 as String
    WSData cXREFER 	 as String
    WSData cXANVISA	 as String
    WSData cXVALANV  as String
    WSData cXTCONV2	 as String
    WSData cXCONV2   as String
    WSData cSITPROD  as String
    WSData cXCONSUM  as String
    WSData cXP12FRO	 as String
    WSData cXFROP12	 as String
    WSData cXESTOQ 	 as String
    WSData cXBLOQ  	 as String
    WSData cXFATURA	 as String
    WSData cXCOMP    as String
    WSData cCONTA 	 as String
    WSData cNCM 	 as String
    WSData cXPARTNU  as String
    WSData cXMDMCOD  as String
    WSData cP17FATUR as String
    WSData cP17ESTOQ as String
    WSData cP17BLOQ  as String
    WSData cXATUAL   as String
    WSData cP17ATUAL as String    
EndWSStruct

WSStruct ProdutoStatus
	WSData cFilReg   as String
    WSData cCod		 as String
    WSData cP17BLOQ	 as String
    WsData CCODFRONT as String
EndWSStruct
