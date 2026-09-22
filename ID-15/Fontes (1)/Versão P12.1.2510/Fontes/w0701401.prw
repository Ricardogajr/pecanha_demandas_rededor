#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0701401
Server Simpro
@author izac.ciszevski
@since 19/01/2017
@Project MAN0000007423041_EF_014
/*/
user function W0701401(); Return //--dummy

WSService W0701401 Description "Responsavel pela inclusão/alteração de registros Simpro"
    WSData RegistroSimpro as Simpro
    WSData cRetorno as String

    WSMethod UpsertSimpro   Description "Realiza inclusão/alteração de registros Simpro"
EndWSService 

WSMethod UpsertSimpro WSReceive RegistroSimpro WSSend cRetorno WSService W0701401
    Begin WSMethod
        ::cRetorno := U_F0701401(RegistroSimpro)
    End WSMethod
Return .T.

WSStruct Simpro
    WSData cFilReg as String
    WSData cCOD    as String
    WSData cDESCR  as String
    WSData cDIV    as String
    WSData cDTVAL  as String
    WSData cSTUSS  as String
    WSData cSTATUS as String
    WSData cSTISS as String
EndWSStruct