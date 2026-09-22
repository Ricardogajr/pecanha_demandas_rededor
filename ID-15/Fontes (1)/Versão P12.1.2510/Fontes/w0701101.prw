#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0701101
Server BrasIndice
@author izac.ciszevski
@since 19/01/2017
@Project MAN0000007423041_EF_011
/*/
user function W0701101();Return //--dummy

WSService W0701101 Description "Responsavel pela manutenção de registros Brasindice"
    WSData RegistroBrasindice as Brasindice
    WSData cRetorno as String

    WSMethod UpsertBrasindice   Description "Realiza inclusão/alteração de registros Brasindice"
EndWSService 

WSMethod UpsertBrasindice WSReceive RegistroBrasindice WSSend cRetorno WSService W0701101
    Begin WSMethod
        ::cRetorno := U_F0701101(RegistroBrasindice)
    End WSMethod
Return .T.

WSStruct Brasindice
    WSData cFilReg as String
    WSData cCOD    as String
    WSData cCODMED as String
    WSData cDESMED as String
    WSData cCODLAB as String
    WSData cDESLAB as String
    WSData cCODAPR as String
    WSData cDESAPR as String
    WSData cDTVAL  as String
    WSData cBRATUS as String
    WSData cBRATIS as String
    WSData cSTATUS as String
EndWSStruct
