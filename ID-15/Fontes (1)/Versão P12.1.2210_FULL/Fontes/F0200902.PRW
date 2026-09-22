#Include 'Protheus.ch'

/*/{Protheus.doc} F0200902
Função de validação de Data 
@type function 
@author queizy.nascimento
@since 10/10/2016
@version 1.0
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAte, data, (Descrição do parâmetro)
@param nOpcdt, numerico, (Descrição do parâmetro)
@return lRet, logico
@example
(examples)
@see (links_or_references)
@project MAN00000463301_EF_009
/*/
USer Function F0200902(dDataDe, dDataAte, nOpcdt)
	Local lRet := .F.
	
	If Empty (dDataAte)
		Alert ("Parametro Data até não pode ser vazio")
	Elseif dDataDe >  dDataAte
		If nOpcdt == 1
			MsgInfo ('Data final informada para o Período 1 é menor que a data inicial informada para o Período 1.' + Chr(13) + Chr(10) + 'Favor Verificar as Datas Informadas')
		ElseIf nOpcdt == 2
			MsgInfo ('Data inicial informada para o Período 2 é menor que a data final informada para o Período 1.' + Chr(13) + Chr(10) + 'Favor Verificar as Datas Informadas')
		ElseIf nOpcdt == 3
			MsgInfo ('Data final informada para o Período 2 é menor que a data inicial informada para o Período 2.' + Chr(13) + Chr(10) + 'Favor Verificar as Datas Informadas')
		EndIf
	Else
		lRet:= .T.
	Endif
	
Return lRet