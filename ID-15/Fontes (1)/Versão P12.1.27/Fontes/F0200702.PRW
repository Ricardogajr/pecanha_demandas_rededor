#Include 'Protheus.ch'
/*
{Protheus.doc} F0200702()
Compatibiliza tamanho de filiais em queries.
@Author     Paulo Krüger
@Since      01/09/2016
@Version    P12.7
@Project    MAN00000463301_EF_007      
@Return
@param aTabelas, array, descricao     
*/
User Function F0200702(aTabelas)

/*===================================================================|
|Parâmetros:                                                         |
|--------------------------------------------------------------------|
|            /                                  \                    |
|            |{<tabela origem>,<tabela destino>}|                    |
|aTabelas : < {<tabela origem>,<tabela destino>} >                   |
|            |{<tabela origem>,<tabela destino>}|                    |
|            \                                  /                    |
|===================================================================*/
Local nI			:= 0
Local aResult		:= {}
Local nLenTab01	:= 0
Local nLenTab02	:= 0
Local nTamFil		:= 0
Local cString		:= ''
Local cCpoTab01	:= ''
Local cCpoTab02	:= ''
Local cSubStr		:= If(Trim(TcGetDb()) = 'ORACLE','SUBSTR','SUBSTRING')
Default aTabelas	:= {}

For nI := 01 To Len(aTabelas)

	/*===================================================================|
	|Verifica compartilhamento de tabelas.                               |
	|===================================================================*/
	nLenTab01 := Len(AllTrim(xFilial(aTabelas[nI][01])))
	nLenTab02 := Len(AllTrim(xFilial(aTabelas[nI][02])))
	/*===================================================================|
	|Define tamanho da string de filial nos relacionamentos.             |
	|===================================================================*/
	If nLenTab01 < nLenTab02		
		nTamFil := nLenTab01
	Else
		nTamFil := nLenTab02
	EndIf
	/*===================================================================|
	|Define string de relacionamento.                                    |
	|===================================================================*/
	SX2->(dBSetOrder(01))
	If SX2->(DbSeek(aTabelas[nI][01]))
		If SUBSTR(aTabelas[nI][01],01,01) == 'S'
			cCpoTab01 := SUBSTR(aTabelas[nI][01],02,02) + '_FILIAL'
		Else
			cCpoTab01 := aTabelas[nI][01] + '_FILIAL'
		EndIf
	Else
		cCpoTab01 := aTabelas[nI][01] + '.FILIAL'
	EndIf

	SX2->(dBSetOrder(01))
	If SX2->(DbSeek(aTabelas[nI][02]))
		If SUBSTR(aTabelas[nI][02],01,01) == 'S'
			cCpoTab02 := SUBSTR(aTabelas[nI][02],02,02) + '_FILIAL'
		Else
			cCpoTab02 := aTabelas[nI][02] + '_FILIAL'
		EndIf
	Else
		cCpoTab02 := aTabelas[nI][02] + '.FILIAL'
	EndIf

	If nLenTab01 == 0 .or. nLenTab02 == 0
		cString := "'" + SPACE(TamSx3(cCpoTab01)[01]) + "'" + ' = ' + "'" + SPACE(TamSx3(cCpoTab02)[01]) + "'"
	Else
		cString := cSubStr + '(' + cCpoTab01 + ',1,' + ALLTRIM(STR(nTamFil)) + ') = ' + cSubStr + '(' + cCpoTab02 + ',1,' + ALLTRIM(STR(nTamFil)) + ')'
	EndIf
		
	AAdd(aResult,cString)
Next nI

Return(aResult)