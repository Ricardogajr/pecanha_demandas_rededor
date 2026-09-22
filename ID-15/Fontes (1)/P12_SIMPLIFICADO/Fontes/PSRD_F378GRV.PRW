#Include 'Protheus.ch'

/*
{Protheus.doc}  F378GRV()
Ponto de Entrada na geração do título aglutinado (PCC), será utilizado para a digitação e gravação do código de barras no campo E2_CODBAR e 
está sendo chamado pela rotina de Aglutinação de Pis, Cofins e Csll
@Author  Ramon Teodoro e Silva	
@Since   05/01/2018       
@Version P12.7
*/
User Function F378GRV()
 
Local lRet    := .T.
Local aArea   := GetArea()

If MsgYesNo("Deseja gravar código de barras para o título que está sendo gerado?", "Atenção")
	U_DigCodBar()
EndIf

RestArea(aArea)
Return lRet

