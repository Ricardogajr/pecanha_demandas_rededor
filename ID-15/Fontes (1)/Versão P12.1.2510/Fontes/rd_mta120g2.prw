#Include 'Protheus.ch'

/*
{Protheus.doc}  MTA120G2()
Ponto de entrada para gravações complementares no pedido de compra
@Author  Ramon Teodoro e Silva	
@Since   17/04/2017       
@Version P12.7
*/

User Function MTA120G2() 
     
Local aArea   := GetArea()
Local lRet    := .T. 

if IsInCallStack("U_S0100401")
	Return lRet
endif

If IsInCallStack("U_F0702601") //integração pedido de compra
	nXDesFin := nIntValDes
EndIf 
 
If (IsInCallStack("MATA121") .Or. IsInCallStack("U_F0702601") .Or. !IsBlind()) .And. !IsInCallStack("U_F0100401")
	If Type("nXDesFin") == "U"
		nXDesFin := 00
	EndIf	
	SC7->C7_XDESFIN := nXDesFin
EndIf

// ------------------------------------
// BLOCO NOVO
// @Author  Sato
// @Since   22/02/2024
// ------------------------------------
// Adicionado para atender a demanda de melhoria do projeto Envio de Email Automatico do Pedido de Compra.
// Para gravar o email do fornecedor.
// ------------------------------------
If ( IsInCallStack("MATA121") .And. EMPTY(SC7->C7_CONTRA)  .And. EMPTY(SC7->C7_MEDICAO) ) 

	If TYPE("cXmailFor") != "U"
		SC7->C7_XMAILFO := cXmailFor
	Else
		SC7->C7_XMAILFO := space( TAMSX3('C7_XMAILFO')[1] )
	Endif

EndIf
// ------------------------------------

RestArea(aArea)
     
Return lRet
