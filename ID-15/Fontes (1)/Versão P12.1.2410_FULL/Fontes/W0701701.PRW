#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0701701
Server TUSS 
@author izac.ciszevski
@since 19/01/2017
@Project MAN0000007423041_EF_017
/*/
user function W0701701();Return //--dummy

WSService W0701701 Description "Responsavel pela inclusão/alteração de registros Tuss"
    WSData RegistroTuss as Tuss
    WSData cRetorno     as String

    WSMethod UpsertTuss Description "Realiza inclusão/alteração de registros Tuss"
EndWSService 

WSMethod UpsertTuss WSReceive RegistroTuss WSSend cRetorno WSService W0701701
    Begin WSMethod
        ::cRetorno := U_F0701701(RegistroTuss)
    End WSMethod
Return .T.

WSStruct Tuss
    WSData cFilReg as String
    WSData cCOD    as String
    WSData cDESCR  as String
    WSData cAPRES  as String
    WSData cANVISA as String
    WSData cREFER  as String
    WSData cDTVIN  as String
    WSData cDTVFIM as String
    WSData cCLRISC as String
    WSData cTERMIN as String
    WSData cFABRIC as String
    WSData cDTIMPL as String
EndWSStruct