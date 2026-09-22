#include 'protheus.ch'
/*/{Protheus.doc} WsLogBio
 Rotina para montar Log no console.log
@type function
@author Ricardo
@since 01/06/2017
@version 1.0
@return 
/*/
User Function WsLogBio(cFonte, nTipo, cMsg)

	Local cTipo := ""
	Local nX	:= ""
	
	Default cMsg := ""
	
	If nTipo == 1
		cTipo := "**INICIANDO**"
	ElseIf nTipo == 2
		cTipo := "**PROCESSANDO**"
	ElseIf nTipo == 3
		cTipo := "**TERMINANDO**"
	EndIf
	
	ConOut(Repl("-", 80))
	ConOut(PadC(cTipo + " EXECUÇÃO DO FONTE " + cFonte +" HORA.: " + Time(), 80))
	If !Empty(cMsg)
		ConOut(Repl(" ", 80))
		nLinha := MlCount(cMsg, 75)
		For nX := 01 To nLinha
			ConOut(PadC(MemoLine(cMsg, 79, nX), 80))
		Next nX	
		ConOut(Repl("-", 80))
	Else
		ConOut(Repl("-", 80))
	EndIf
	
Return