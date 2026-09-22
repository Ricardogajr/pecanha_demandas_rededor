/*{Protheus.doc} F0500315
Este Ponto de Entrada tem como objetivo permitir alterar / incluir campos e valores a serem carregados na tela de Cadastro de Funcionários.
@type User Function
@author Ademar Fernandes
@since 20/06/2017
@version P12.1.7
@Project MAN0000007423039_EF_003
@return Nil
*/
User Function F0500315()
	Local nPos 	:= 0
	Local lRet	:= .F.
	PA2->(DbSetOrder(1))
	If PA2->(DbSeek(xFilial("PA2")+SQS->QS_VAGA+SQG->QG_CURRIC))
		While AllTrim(PA2->(PA2_FILIAL+PA2_CDVAGA+PA2_CDCAND)) == AllTrim(xFilial("PA2")+SQS->QS_VAGA+SQG->QG_CURRIC)
			If ALLTRIM(PA2->(PA2_SIT)) != "RE"
				lRet	:= .T.
				Exit
			EndIf
			PA2->(DbSkip())
		EndDo
	EndIf
	
	If lRet
		If (nPos := aScan(xParam1,{|x| x[2]=="M->RA_SALARIO"})) > 0
			If PA2->PA2_SLFECH > 0
				xParam1[nPos] := {PA2->PA2_SLFECH,"M->RA_SALARIO"}
			ElseIf PA2->PA2_VLVAGA > 0
				xParam1[nPos] := {PA2->PA2_VLVAGA,"M->RA_SALARIO"}
			EndIf
		EndIf
		
		If (nPos := aScan(xParam1,{|x| x[2]=="M->RA_ANTEAUM"})) > 0
			If PA2->PA2_SLFECH > 0
				xParam1[nPos] := {PA2->PA2_SLFECH,"M->RA_ANTEAUM"}
			ElseIf PA2->PA2_VLVAGA > 0
				xParam1[nPos] := {PA2->PA2_VLVAGA,"M->RA_ANTEAUM"}
			EndIf
		EndIf
	EndIf	
Return()
