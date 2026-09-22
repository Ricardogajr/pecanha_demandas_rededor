#Include 'Protheus.ch'

/*
+-------------------------------------------------------------------------------------------------------------------+
| Neste programa estão todas as User Functions que são chamadas em pontos de entrada do módulo de Gestão de Pessoal |
| Função     Ponto de Entrada                                                                                       |   
| FSPE0002   GPEM040                                                                                               |
+-------------------------------------------------------------------------------------------------------------------+*/


/*
{Protheus.doc}  FSPE0002()
Função chamada pelo ponto de entrada GPEM040 para verificar se existe algum ativo em responsabilidade do funcionário em 
processo de rescisão   
@Author  Ramon Teodoro e Silva	
@Since   23/02/2017       
@Version P12.7
*/

User Function FSPE0002()
Local lRet     := .t.
Local aArea    := GetArea()
Local aAreaSRA := SRA->(GetArea())
Local aParam   := Paramixb
Local cIdExec  := ""
Local cFunc    := ""
Local cDescAtv := ""

If !Empty(aParam)
	cIdExec := aParam[2]
EndIf 

If cIdExec == "MODELVLDACTIVE"

	//cFunc := SRA->RA_MAT
	DbSelectArea("RD0")
	RD0->(DbSetOrder(6))
		
	If RD0->(DbSeek(xFilial("RD0")+SRA->RA_CIC))
		
		cFunc := RD0->RD0_CODIGO
		
		DbSelectArea("SND")
		SND->(DbSetOrder(1))
		
		If SND->(DbSeek(xFilial("SND")+cFunc))
		
			While !SND->(Eof()) .And. SND->ND_CODRESP == cFunc
				cDescAtv := Alltrim(Posicione("SN1", 1, xFilial("SN1")+SND->ND_CBASE, "N1_DESCRIC")) 
				MsgAlert("Existe um ativo em posse do participante: " + Alltrim(SND->ND_CBASE) + " - " + cDescAtv +". Verificar com gestor responsável.", "Atenção")
				SND->(DbSkip())
			End
			
		EndIf
		
	EndIf
		
EndIf

RestArea(aAreaSRA)
RestArea(aArea)
Return lRet