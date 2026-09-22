#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/*/{Protheus.doc} W0702101
WebService Server responsável pela integração de movimentação bancária
@type User function
@author anieli.rodrigues
@since 01/02/2017
@version 12.7
@project MAN0000007423041_EF_021
/*/

WSService W0702101 Description "Responsavel pela inclusão de registros de movimentação bancária Sage"
    WSData RegistroSage as Sage
    WSData cRetorno as String

    WSMethod InsertMovimentacaoBancaria Description "Realiza inclusão de registros de movimentação bancária Sage"
EndWSService 

WSMethod InsertMovimentacaoBancaria WSReceive RegistroSage WSSend cRetorno WSService W0702101
    Begin WSMethod
        ::cRetorno := U_F0702101(RegistroSage)
    End WSMethod 
Return .T.

WSStruct Sage
    WSData cFILREG  as String
    WSData cDATA    as String
    WSData cMOEDA   as String
    WSData cVALOR   as String
    WSData cNATUREZ as String
    WSData cBANCO   as String
    WSData cAGENCIA as String
    WSData cCONTA   as String
    WSData cHISTOR  as String
    WSData cTIPOLAN as String
    WSData cRECPAG  as String
    WSData cDEBITO  as String
    WSData cCREDITO as String
    WSData cCCUSTO  as String
    WSData cTIPO    as String
EndWSStruct