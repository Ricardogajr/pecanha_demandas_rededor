#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} W0702801
Webservice para Integração de Recebimento Antecipado
@type User function
@author anieli.rodrigues
@since 09/03/2017
@version 12.7
@param
@project	MAN0000007423041_EF_028
@return lRet
/*/

WSService W0702801 Description "Responsavel pela Compensação RA/Acrescimo/Descrescimo/Estono da Compensação do RA"
    WSData oCompRecAntecipado as CompRecAnt
    WSData oAcreouDecreTitulo as AcreouDecre
    WSData oEstornoCompRA     as Estorno
    WSData cRetorno           as String

    WSMethod CompRecAntecipado Description "Compensação do RA"
    WSMethod AcreouDecreTitulo Description "Acrescimo ou decrescimo do Titulo"
    WSMethod EstornoCompensaRA Description "Estorno da compensação do RA"
EndWSService

WSMethod CompRecAntecipado WSReceive oCompRecAntecipado WSSend cRetorno WSService W0702801
    Begin WSMethod
        ::cRetorno := U_F0702801(oCompRecAntecipado,3)
    End WSMethod
Return .T.

WSMethod AcreouDecreTitulo WSReceive oAcreouDecreTitulo WSSend cRetorno WSService W0702801
    Begin WSMethod
        ::cRetorno := U_F0702803(oAcreouDecreTitulo)
    End WSMethod
Return .T.

WSMethod EstornoCompensaRA WSReceive oEstornoCompRA WSSend cRetorno WSService W0702801
    Begin WSMethod
        ::cRetorno := U_F0702801(oEstornoCompRA,5)
    End WSMethod
Return .T.

WSStruct CompRecAnt
    WSData cFILREG  as String
    WSData cDTCOMP  as String
    WSData cPREFRA  as String
    WSData cNUMRA   as String
    WSData cTIPORA  as String
    WSData cCLI_RA  as String
    WSData cLOJARA  as String
    WSData cPARCRA  as String
    WSData cPREFIXO as String
    WSData cNUM     as String
    WSData cTIPO    as String
    WSData cCLIENTE as String
    WSData cLOJA    as String
    WSData cPARCELA as String
    WSData cVALOR   as String
    WSData cXIDBXF  as String
EndWSStruct

WSStruct AcreouDecre
    WSData cFILREG  as String
    WSData cPREFIXO as String
    WSData cNUM     as String
    WSData cTIPO    as String
    WSData cPARCELA as String
    WSData cACRESC  as String
    WSData cDECRESC as String
    WSData cVALOR   as String
EndWSStruct

WSStruct Estorno
    WSData cFILREG  as String
    WSData cIDFK1   as String
EndWSStruct