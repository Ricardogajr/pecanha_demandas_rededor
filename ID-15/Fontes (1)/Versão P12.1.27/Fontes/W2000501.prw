#Include "Protheus.ch"
#INCLUDE "APWebSrv.ch"

#Define __DESC "WebService de Lançamentos Contábeis - XRT"
#Define __NAME "http://localhost:2002/"

User Function DummyF05()
Return

WSStruct W20005ENT
    WSData ITENS      As Array Of W20005Item
EndWSStruct

WSStruct W20005Item
    WSData EMP        As String
    WSData FIL        As String
    WSData ESTORNO    As String
	WSData CHVORIG    As String Optional
    WSData DDATALANC  As String
    WSData CT2_XPCXRT As String
    WSData CT2_XCDXRT As String
    WSData CT2_MOEDLC As String Optional
    WSData CT2_DC     As String
    WSData CT2_DEBITO As String Optional
    WSData CT2_CREDIT As String Optional
    WSData CT2_VALOR  As Float
    WSData CT2_CCD    As String Optional
    WSData CT2_CCC    As String Optional
    WSData CT2_ITEMD  As String Optional
    WSData CT2_ITEMC  As String Optional
    WSData CT2_HIST   As String
EndWSStruct

WSStruct W20005RET
    WSData ITENS As Array Of W20005RETIt
EndWSStruct

WSStruct W20005RETIt
    WSData RETSTATUS   As String 
    WSData RETMSG      As String
    WSData CT2_XCDXRT  As String
EndWSStruct

WSService W2000501 Description __DESC NameSpace __NAME
    WSData DADOS     As W20005ENT
    WSData WRETORNO  As W20005RET

    WSMethod LANCTBXRT Description "WebService de Lançamentos Contábeis - XRT"

EndWSService

WSMethod LANCTBXRT WSReceive DADOS WSSend WRETORNO WSService W2000501
	Begin WSMethod
		U_F2000501(::DADOS, ::WRETORNO)
	End WSMethod
Return .T. 
