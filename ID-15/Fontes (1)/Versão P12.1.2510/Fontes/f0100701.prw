#Include 'Protheus.ch'

/*
{Protheus.doc} F0100701()
Verificação dos atestados médicos que estão com afastamento por doença
@Author   	Bruno de Oliveira
@Since    	11/04/2016
@Version  	P12.1.07
@Project  	MAN00000462901_EF_007
@Param		lRet, lógico, permite continuar .T. ou .F.
@Param		nOpc, númerico, operação do sistema
@Return 	lRet, permite continuar ou não
*/
User Function F0100701(lRet,nOpc)
	
	Local aArea		:= GetArea()
	Local cAssunto	:= "Verificar no site do INSS"
	Local cEmlMedic	:= ""
	Local cConteudo	:= ""
	Local lRet		:= .T.
	
	If lRet .AND. nOpc == 3
		
		If M->TNY_CODAFA == "004" .AND. M->TNY_QTDIAS >= 15
			
			DbSelectArea("TM0")
			TM0->(DbSetOrder(1))
			If TM0->(DbSeek(xFilial("TM0") + M->TNY_NUMFIC))
				cNome := Alltrim(TM0->TM0_NOMFIC)
				cCpf := TM0->TM0_CPF
				cMat := TM0->TM0_MAT
			EndIf
			
			cConteudo := '<html><body><pre>' + CRLF
			
			If !Empty(cMat)
				
				cConteudo += "Prezado," + CRLF
				cConteudo += CRLF
				cConteudo += "Por favor verifique o status do colaborador: " + cNome + ", "
				cConteudo += "CPF: " + cCpf + ", "
				cConteudo += "Matrícula: " + cMat + " no site do INSS."
				
				cConteudo += '</pre></body></html>'
				
				lRet := U_F0100702(cFilAnt,cAssunto,cConteudo,.T.)
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return lRet
