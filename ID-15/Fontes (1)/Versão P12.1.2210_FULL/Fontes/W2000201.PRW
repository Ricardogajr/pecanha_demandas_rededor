#Include "Protheus.ch"
#INCLUDE "APWebSrv.ch"

#Define __DESC "WebService de Títulos a Pagar - Realizado - XRT"
#Define __NAME "http://localhost:2002/"

User Function W202DMY()
Return

WSService W2000201 Description __DESC NameSpace __NAME
    WSData REQDATAIN   As W20001ENT //Estruturas descritas no fonte W2000101.prw
    WSData REQDATAOUT  As W20001RET
	WSData UPDDATAIN   As W20001ENT2
    WSData UPDDATAOUT  As W20001RET2

    WSMethod SOLICITTIT Description "Solicita dados dos títulos  - Realizado - XRT"
    WSMethod ATUALIZTIT Description "Atualiza status dos títulos - Realizado - XRT"

EndWSService

WSMethod SOLICITTIT WSReceive REQDATAIN WSSend REQDATAOUT WSService W2000201
    Begin WSMethod
        U_F2000103(::REQDATAIN, ::REQDATAOUT, 'EMPINIREAL', '2')
    End WSMethod
Return .T. 
 
WSMethod ATUALIZTIT WSReceive UPDDATAIN WSSend UPDDATAOUT WSService W2000201
    Begin WSMethod
        U_F2000104(::UPDDATAIN, ::UPDDATAOUT)
    End WSMethod
Return .T. 
