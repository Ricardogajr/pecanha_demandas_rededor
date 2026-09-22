#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0700601
 WebService Server
@type function
@author queizy.nascimento
@since 26/01/2017
@version 1.0
@Project MAN0000007423041_EF_006
/*/
User Function W0700601(); Return //--dummy
   
WSService W0700601 Description "Manutenção de Locais de Estoque"
	WSData oLocalEstoque   as LocalEstoque
	WSData oLocalEstoqueID as LocalEstoqueID
	WSData cRetorno        as String

	WSMethod UpsertLocalEstoque Description "Realiza inclusão/alteração de Locais de Estoque"
	WSMethod DeleteLocalEstoque Description "Exclusão de Locais de Estoque"
EndWSService

WSMethod UpsertLocalEstoque WSReceive oLocalEstoque WSSend cRetorno WSService W0700601
	Begin WSMethod
		::cRetorno := U_F0700602(oLocalEstoque)
	End WSMethod
Return .T.

WSMethod DeleteLocalEstoque WSReceive oLocalEstoqueID WSSend cRetorno WSService W0700601
	Begin WSMethod
		::cRetorno := U_F0700601(oLocalEstoqueID)
	End WSMethod
Return .T.

WSStruct LocalEstoque
	WSData cFil    as String
	WSData cCodigo as String
	WSData cDescri as String
	WSData cTipo   as String
	WSData cMsblql as String
	WSData cCCusto as String OPTIONAL
EndWSStruct

WSStruct LocalEstoqueID
	WSData cFil    as String
	WSData cCodigo as String
EndWSStruct