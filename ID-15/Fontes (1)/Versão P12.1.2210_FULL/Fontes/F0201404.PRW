#Include 'Protheus.ch'

/*
{Protheus.doc} F0201404()
Verifica se existe CPF no cadastro de contra indicados
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014 
@Param 	 cCurric
@Return	 lRet
*/
User Function F0201404(l150CDT)
	
	Local aAreas    := {PA0->(GetArea()),GetArea()}
	Local cCandiCPF := ""
	Local cMsg      := ""
	Local lRet      := .F.
	
	DEFAULT l150CDT := .F.
	
	If l150CDT .Or. (!(PARAMIXB[1])->TRX_CHECK .AND. VALTYPE((PARAMIXB[1])->TRX_CHECK) != "U")
		
		PA0->(dbSetOrder(1))
		
		If l150CDT
			cCandiCPF := SQG->QG_CIC
		Else
			cCandiCPF := POSICIONE("SQG", 1, xFilial("SQG") + (PARAMIXB[1])->TRX_CURRIC, "QG_CIC")
		EndIf
		
		IF PA0->(DbSeek(xFilial("PA0") + cCandiCPF))
			
			cMsg := "Candidato e/ou ex-colaborador integra a lista de inelegíveis e não está autorizado a participar do processo seletivo. Para maiores informações, entre em contato com a equipe de Segurança Institucional."
			lRet := .F.
			
			Alert(cMsg)
			
		Else
			lRet := .T.
		EndIf
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return lRet
