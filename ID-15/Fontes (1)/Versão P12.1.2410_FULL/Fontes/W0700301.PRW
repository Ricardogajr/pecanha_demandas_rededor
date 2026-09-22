#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} W0700301
Função de identificação do webservice de integração de setores.
@type 		function
@author 	alexandre.arume
@since 		24/01/2017
@version 	1.0
@project	MAN000007423041_EF_003
/*/
User Function W0700301();Return //--dummy

WSService W0700301 Description "WEBSERVICE PARA INTEGRAÇÃO DE SETORES"
	WSData RegSetor   as Setor
	WSData RegSetorID as SetorID
	WSData cRet       as String
	
	WSMethod UpsertSetor Description "INCLUSÃO E ALTERAÇÃO DE SETOR"
	WSMethod DeleteSetor Description "EXCLUSÃO DE SETOR"
EndWSService

WSMethod UpsertSetor WSReceive RegSetor WSSend cRet WSService W0700301
	::cRet := U_F0700301(::RegSetor, 1)
Return .T.

WSMethod DeleteSetor WSReceive RegSetorID WSSend cRet WSService W0700301
	::cRet := U_F0700301(::RegSetorID, 2)
Return .T.

WSStruct Setor
	WSData cFil    as String
	WSData cCod    as String
	WSData cDesc   as String
	WSData cCCusto as String
	WSData cMSBLQL as String
EndWSStruct

WSStruct SetorID
	WSData cFil as String
	WSData cCod as String
EndWSStruct