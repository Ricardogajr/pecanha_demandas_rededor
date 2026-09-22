/*
{Protheus.doc} F0500209()
Altera a legenda quando a vaga for encerrada manualmente via customização.
@Author     Nairan Alves Silva
@Since      04/05/2017
@Version    P12.7
@Project    MAN00000462901_EF_002
@Return	 Nil
*/
User Function F0500209()

	Local aRet := {}
	Local n    := 0
	 
	 	//inclui a minha condição
	Aadd(aRet, {"SQS->QS_XSTATUS == '5'", "BR_CINZA", "Vagas Canceladas"} )
	Aadd(aRet, {"SQS->QS_XSTATUS != '7'", "BR_VERDE", "Vagas em Aberto"} )
	Aadd(aRet, {"SQS->QS_XSTATUS == '7'", "BR_VERMELHO", "Concluída"} ) //	Ticket nº6748352 - Yan Cordeiro - Vaga sem legenda
	
	//Conteudo da legenda padrão
	//Inclui legenda para verifcar se tem perda
	For n := 1 To Len(aColors)
		If !("VERDE" $ aColors[n,2])
			aadd(aRet,{aColors[n,1], aColors[n,2], aColors[n,3]})
		EndIf
	Next 

	aColors := aClone(aRet)

Return
