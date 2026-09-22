#Include 'Protheus.ch'

/*
{Protheus.doc} F0100702()
Busca dos Medicos do Trabalho na Sesmt
@Author     Bruno de Oliveira
@Since      14/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_007
@Param		cFilTMK, caracter, Filial
@Param		cAssunto, caracter, assunto do e-mail
@Param		cConteudo, caracter, conteudo do e-mail
@Param		lIncAtes, lógico, incluindo atestado sim(.T.) ou não(.F.)
@Return 	lRet, envio com sucesso ou não
*/
User Function F0100702(cFilTMK,cAssunto,cConteudo,lIncAtest)
	
	Local cAlTMK  := GetNextAlias()
	Local dDtHj   := DTOS(dDataBase)
	Local cCcopia := ""
	Local cErrJb  := ""
	Local lRet    := .T.
	
	BeginSQL alias cAlTMK
		
		Select TMK_FILIAL,TMK_DTINIC,TMK_DTTERM,TMK_SESMT,TMK_INDFUN,TMK_EMAIL
		
		From %table:TMK% TMK
		
		Where TMK_FILIAL = %exp:cFilTMK%
		AND TMK_DTINIC <= %exp:dDtHj% AND (TMK_DTTERM >= %exp:dDtHj% OR TMK_DTTERM = '        ')
		AND TMK_SESMT = '1' AND TMK_INDFUN = '1'
		AND TMK.%notDel%
		
		Order By TMK_FILIAL,TMK_CODUSU
		
	EndSql
	
	cErro := "Não foi enviado o e-mail para a filial: " + cFilTMK + CRLF
	
	While (cAlTMK)->(!EOF())
		
		If !Empty((cAlTMK)->TMK_EMAIL)
			If lIncAtest
				lRet := U_F0100603((cAlTMK)->TMK_EMAIL,cAssunto,cConteudo,cCcopia,.F.)
				If !lRet
					Exit
				EndIf
			Else
				lRet := U_F0100603((cAlTMK)->TMK_EMAIL,cAssunto,cConteudo,cCcopia,.T.,@cErrJb)
				If !lRet
					cErro += cErrJb + CRLF
				EndIf
			EndIf
		EndIf
		
		(cAlTMK)->(DbSkip())
	End
	
	If Len(cErro) > 51
		lRet := .T.
		MemoWrite( "\JOBB91" + cFilTMK + ".txt", cErro )
	EndIf
	
Return lRet
