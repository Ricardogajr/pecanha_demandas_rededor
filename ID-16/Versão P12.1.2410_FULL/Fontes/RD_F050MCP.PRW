#Include 'Protheus.ch'

/*
{Protheus.doc}  F050MCP()
Ponto de entrada para adicionar campos para serem habilitados na opção alteração
@Author  Ramon Teodoro e Silva	
@Since   08/06/2016       
@Version P12.7
*/

User Function F050MCP()

Local aRet  := Paramixb

AADD(aRet,"E2_FORBCO")	
AADD(aRet,"E2_FORMPAG")
AADD(aRet,"E2_DESCONT")
AADD(aRet,"E2_MULTA")
AADD(aRet,"E2_JUROS")
Return aRet


