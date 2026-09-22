#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"
#INCLUDE "FWMVCDEF.CH"

WSService W0700801 Description "Responsavel pela inclusão/alteração/exclusão de registros Fabricante"
    WSData RegistroFabricante   as Fabricante
    WSData RegistroFabricanteID as FabricanteID
    WSData cRetorno             as String

    WSMethod UpsertFabricante   Description "Realiza inclusão/alteração de registros Fabricante"
    WSMethod DeleteFabricante   Description "Realiza exclusão de registros Fabricante"
EndWSService 

WSMethod UpsertFabricante WSReceive RegistroFabricante WSSend cRetorno WSService W0700801
    Begin WSMethod    
        ::cRetorno := U_F0700801(RegistroFabricante)
    End WSMethod
Return .T.  

WSMethod DeleteFabricante WSReceive RegistroFabricanteID WSSend cRetorno WSService W0700801
    Begin WSMethod
        ::cRetorno := U_F0700802(RegistroFabricanteID)
    End WSMethod
Return .T.

WSStruct Fabricante
    WSData cFILFab as String
    WSData cCOD    as String
    WSData cDESCR  as String
    WSData cCGC    as String
    WSData cMSBLQL as String
    WSData cTIPO   as String
EndWSStruct

WSStruct FabricanteID
    WSData cFILFab as String
    WSData cCOD    as String
EndWSStruct