#Include 'Protheus.ch'
#INCLUDE "apwebsrv.ch"

/*{Protheus.doc} W1205901
WebService Server de integração de LOG de Saída
@author CDE - Célula de Desenvolvimento Especifico
@since  18/09/2018
@Project MAN0000007423048_EF_059
*/
User Function W1205901()
Return

WSService W1205901 Description "WebService Server responsavel pela atualização dos status do LOG de saída"
    WSData cFilialID as String
    WSData cIDLOG    as String
    WSData cRetorno  as String

    WSMethod UPDLOGBAIX   Description "Realiza Baixa de registro da tabela P20"
    WSMethod UPDLOGREPROC Description "Realiza Reprocessamento de registro da tabela P20"
EndWSService 

WSMethod UPDLOGBAIX WSReceive cFilialID,cIDLOG WSSend cRetorno WSService W1205901
	Begin WSMethod
        ::cRetorno  := U_F1205901(::cFilialID,::cIDLOG,"1")
    End WSMethod
Return .T.

WSMethod UPDLOGREPROC WSReceive cFilialID,cIDLOG WSSend cRetorno WSService W1205901
	Begin WSMethod
        ::cRetorno  := U_F1205901(::cFilialID,::cIDLOG,"2")
    End WSMethod
Return .T.