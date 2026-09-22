#Include "Protheus.ch"
#INCLUDE "APWebSrv.ch"

#Define __DESC "WebService de Títulos a Pagar - Previsto - XRT"
#Define __NAME "http://localhost:2002/"

User Function W201DMY()
Return

WSStruct W20001ENT
    WSData SOLICIT        As String
EndWSStruct

WSStruct W20001RET
    WSData QTDTIT     As Float
    WSData TITULOS    As Array Of W20001TIT Optional
EndWSStruct

WSStruct W20001TIT
    WSData EMPFIL         As String
    WSData CHAVE          As String
    WSData STATUSTIT      As Integer 
    WSData ORIGEM_SISTEMA As String
    WSData E2_XCHVXRT     As String
    WSData A2_NOME        As String
    WSData A2_CGC         As String
    WSData E2_VENCREA     As String 
    WSData E2_TIPO        As String
    WSData E5_DATA        As String Optional
    WSData E2_SALDO       As Float  
    WSData E2_NATUREZ     As String
    WSData E2_PORTADO     As String Optional
    WSData E2_XAGEPOR     As String Optional
    WSData E2_XCONPOR     As String Optional
    WSData E2_FORMPAG     As String Optional
	WSData E2_NUMBOR      As String Optional
    WSData E2_HIST        As String Optional
    WSData E2_MOEDA       As Float
    WSData E2_TXMOEDA     As Float  Optional
    WSData F1_NOTA        As String Optional
    WSData E2_XOPFXRT     As String Optional
    WSData E2_NUMBCO      As String Optional
     
EndWSStruct

WSStruct W20001ENT2
	WSData TITULOS    As Array Of W20001TIT2
EndWSStruct

WSStruct W20001TIT2
    WSData E2_XCHVXRT As String
	WSData STATUSIN   As String
	WSData ERRO       As String
EndWSStruct

WSStruct W20001RET2
	WSData STATUSOUT   As String
    WSData MSGOUT      As String
EndWSStruct

WSService W2000101 Description __DESC NameSpace __NAME
    WSData REQDATAIN   As W20001ENT
    WSData REQDATAOUT  As W20001RET
	WSData UPDDATAIN   As W20001ENT2
    WSData UPDDATAOUT  As W20001RET2

    WSMethod SOLICITTIT Description "Solicita dados dos títulos  - Previsto - XRT"
    WSMethod ATUALIZTIT Description "Atualiza status dos títulos - Previsto - XRT"

EndWSService

WSMethod SOLICITTIT WSReceive REQDATAIN WSSend REQDATAOUT WSService W2000101
    Begin WSMethod
        U_F2000103(::REQDATAIN, ::REQDATAOUT, 'EMPINIPREV', '1')
    End WSMethod
Return .T. 

WSMethod ATUALIZTIT WSReceive UPDDATAIN WSSend UPDDATAOUT WSService W2000101
    Begin WSMethod
        U_F2000104(::UPDDATAIN, ::UPDDATAOUT)
    End WSMethod
Return .T. 
