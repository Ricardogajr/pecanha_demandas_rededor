#Include 'Protheus.ch'

/*
{Protheus.doc}  F050INC()
Ponto de Entrada na geração do título aglutinado (INSS), será utilizado para a digitação e gravação do código de barras no campo E2_CODBAR,
apenas quando vier da rotina FINA870 e gravação auxiliar quando o título vier de integração.  
@Author  Ramon Teodoro e Silva	
@Since   05/01/2018       
@Version P12.7
*/
User Function F050INC()

// passou no FINA870 
Local lRet    := .T.
Local aArea   := GetArea()

If IsInCallStack("FINA870")

	If MsgYesNo("Deseja gravar código de barras para o título que está sendo gerado?", "Atenção")
		U_DigCodBar()
	EndIf

EndIf

If !Empty(SE2->E2_XID)

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	
	If SF1->(DbSeek(xFilial("SF1")+SE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA)))
		SE2->E2_XVLBRUT := SF1->F1_VALMERC
		SE2->E2_XDTAPRO := SF1->F1_RECBMTO
	EndIf
	
EndIf

RestArea(aArea)
Return lRet
