#Include "Protheus.ch" 
#INCLUDE "APWebSrv.ch"

#Define __DESC "WebService de Movimentos Bancários - XRT"
#Define __NAME "http://localhost:2002/"

User Function DummyF04()
Return

WSStruct W20004PR
	WSData Movimentos As Array Of W20004MV
EndWSStruct

WSStruct W20004MV 
	WSData EMP        As String
    WSData FIL        As String
	WSData E5_RECPAG  As String
	WSData ESTORNO    As String
	WSData CHVORIG    As String Optional
	WSData OPERAC     As String
	WSData E2_XOPFXRT As String Optional
    WSData E5_DATA    As String
	WSData E5_MOEDA   As String
	WSData E5_VALOR   As Float
	WSData E5_NATUREZ As String
	WSData E5_BANCO   As String
	WSData E5_AGENCIA As String
	WSData E5_CONTA   As String
	WSData E5_DEBITO  As String Optional
    WSData E5_CREDIT  As String Optional
    WSData E5_CCD     As String Optional
    WSData E5_CCC     As String Optional
	WSData E5_BENEF   As String Optional
	WSData E5_HISTOR  As String Optional
	WSData FK5_XCDXRT As String 
	WSData FK5_XPCXRT As String
EndWSStruct

WSStruct W20004RET
    WSData ITENS As Array Of W20004RETIT
EndWSStruct

WSStruct W20004RETIT
    WSData RETSTATUS   As String 
    WSData RETMSG      As String
    WSData FK5_XCDXRT  As String
EndWSStruct

WSService W2000401 Description __DESC NameSpace __NAME
    WSData PAGDADOS  As W20004PR
    WSData WRETORNO  As W20004RET

    WSMethod MOVMBANC Description "WebService de Movimentos Bancários - XRT"

EndWSService

WSMethod MOVMBANC WSReceive PAGDADOS WSSend WRETORNO WSService W2000401
	Begin WSMethod
		U_F2000401(::PAGDADOS, ::WRETORNO)
	End WSMethod
Return .T. 
