#Include 'Protheus.ch'

/*
{Protheus.doc} F0300101()
Alocação de Participantes para visões
@Author     Bruno de Oliveira
@Since      04/07/2016
@Version    P12.1.07
@Project    MAN00000463701_EF_001
@Param		nOpc, numerico, operação do sistema
@Param		cPosto, caracter, posto
@Param		cDepto, caracter, departamento
*/
User Function F0300101(nOpc,cPosto,cDepto)
	
	Local aArea     := GetArea()
	Local cFilPst   := ""
	Local cPartic   := ""
	Local cCPF      := ""
	Local cGrup     := ""
	
	DbSelectArea("RCX")
	RCX->(DbSetOrder(1))
	If RCX->(DbSeek(xFilial("RCX") + cPosto))
		
		While RCX->(!EOF()) .AND. RCX->(RCX_FILIAL + RCX_POSTO) == xFilial("RCX") + cPosto
			
			If RCX->RCX_DTINI <= dDatabase .AND. (RCX->RCX_DTFIM >= dDatabase .OR. Empty(RCX->RCX_DTFIM)) .AND. RCX->RCX_SUBST == "2" //Não Substituto
				
				If RCX->RCX_TIPOCU == "1" //Funcionário
					
					cFilPst := RCX->RCX_FILIAL
					
					DbSelectArea("SRA")
					SRA->(DbSetOrder(1))	//RA_FILIAL + RA_MAT
					If SRA->(DbSeek(RCX->(RCX_FILFUN + RCX_MATFUN)))
						cCPF := SRA->RA_CIC
					EndIf
					
					DbSelectArea("RD0")
					RD0->(DbSetOrder(6))	//RD0_FILIAL + RD0_CIC
					If RD0->(DbSeek(xFilial("RD0") + cCPF))
						cPartic := RD0->RD0_CODIGO
					EndIf
					
					cGrup := xFilial("SQB",SM0->M0_CODFIL)
					
					DbSelectArea("RD4")
					RD4->(DbSetOrder(6)) //RD4->RD4_FILIAL + RD4_EMPIDE + RD4_FILIDE + RD4_CODIDE
					
					If RD4->(DbSeek(xFilial("RD4") + cEmpAnt + cGrup + cDepto))
						
						While RD4->(!EOF()) .AND. xFilial("RD4") + cEmpAnt + cGrup + cDepto == RD4->(RD4_FILIAL + RD4_EMPIDE + RD4_FILIDE + RD4_CODIDE)
							
							DbSelectArea("RDE")
							RDE->(DbSetOrder(3)) //RDE_FILIAL + RDE_CODPAR + RDE_CODVIS + RDE_ITEVIS	
							If !RDE->(DbSeek(xFilial("RDE") + cPartic + RD4->(RD4_CODIGO + RD4_ITEM)))
								RecLock("RDE",.T.)
								RDE->RDE_FILIAL	:= xFilial("RDE")
								RDE->RDE_CODPAR	:= cPartic
								RDE->RDE_CODVIS	:= RD4->RD4_CODIGO
								RDE->RDE_ITEVIS	:= RD4->RD4_ITEM
								RDE->RDE_DATA	:= dDatabase
								RDE->RDE_STATUS	:= "1"
								RDE->(MsUnLock())
							Else
								If RDE->RDE_STATUS == "2"
									RecLock("RDE",.F.)
									RDE->RDE_STATUS	:= "1"
									RDE->(MsUnLock())
								EndIf
							EndIf
							
						RD4->(DbSkip())
						End
					EndIf
					
					If RD4->(DbSeek(xFilial("RD4") + cEmpAnt + cFilPst + cPosto))
						
						While RD4->(!EOF()) .AND. xFilial("RD4") + cEmpAnt + cFilPst + cPosto == RD4->(RD4_FILIAL + RD4_EMPIDE + RD4_FILIDE + RD4_CODIDE)
							
							DbSelectArea("RDE")
							RDE->(DbSetOrder(3)) //RDE_FILIAL + RDE_CODPAR + RDE_CODVIS + RDE_ITEVIS	
							If !RDE->(DbSeek(xFilial("RDE") + cPartic + RD4->(RD4_CODIGO + RD4_ITEM)))
								RecLock("RDE",.T.)
								RDE->RDE_FILIAL	:= xFilial("RDE")
								RDE->RDE_CODPAR	:= cPartic
								RDE->RDE_CODVIS	:= RD4->RD4_CODIGO
								RDE->RDE_ITEVIS	:= RD4->RD4_ITEM
								RDE->RDE_DATA	:= dDatabase
								RDE->RDE_STATUS	:= "1"
								RDE->(MsUnLock())
							Else
								If RDE->RDE_STATUS == "2"
									RecLock("RDE",.F.)
									RDE->RDE_STATUS	:= "1"
									RDE->(MsUnLock())
								EndIf
							EndIf
							
						RD4->(DbSkip())
						End
						
					EndIf
					
				EndIf
				
			EndIf
			
		RCX->(DbSkip())
		End
		
	EndIf
	
	RestArea(aArea)
	
Return
