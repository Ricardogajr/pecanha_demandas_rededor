#Include 'Protheus.ch'

/*
{Protheus.doc}  CPAPUICMS()
Ponto de Entrada na geração do título aglutinado (ISS), será utilizado para a digitação e gravação do código de barras no campo E2_CODBAR e 
está sendo chamado pela rotina de Apuração de ISS
@Author  Ramon Teodoro e Silva	
@Since   11/01/2018       
@Version P12.7
*/
User Function CPAPUICMS()

Local lRet    := .T.
Local aArea   := GetArea()

If IsInCallStack("MATA954")

	If MsgYesNo("Deseja gravar código de barras para o título que está sendo gerado?", "Atenção")
		U_DigCodBar()
	EndIf
	
	SE2->E2_TIPO := "AIS"

EndIf

RestArea(aArea)
Return lRet
