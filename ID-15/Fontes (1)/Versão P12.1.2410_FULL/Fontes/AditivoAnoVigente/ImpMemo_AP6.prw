#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPMEMO   ºAutor  ³Armando/Willy       º Data ³  12/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função auxiliar para campo impressão de campo memo.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// 01-> _nRow------> Posicao em Pixel da Linha
// 02-> _nCol------> Posicao em Pixel da Coluna
// 03-> _nRowPixel-> Tamanho em Pixel da largura da linha
// 04-> _nVert-----> Numero maximo de linhas a imprimir
// 05-> _nHoriz----> Tamanho de caracteres e imprimir na linha
// 06-> _cFonte----> Fonte utilizada na impressao (Courrier New)
// 07-> _cTexto----> Texto a ser impresso

User Function ImpMemo(_nRow, _nCol, _nRowPixel, _nVert, _nHoriz, _oFonte, _cTexto, oPrint)

Local _nPos   := 1
Local _nDesc  := 0
Local _nI,_nJ,_cLinha

_cTexto := _cTexto + ' '

ChkTemplate("CDV") 

For _nI := 1 to _nVert
	_cLinha := SubStr(_cTexto, _nPos, _nHoriz)
	For _nJ = len(_cLinha) to 1 Step -1
		If SubStr(_cLinha, _nJ, 1) <> ' '
			_nDesc++
		Else
			Exit
		EndIf
	Next
	oPrint:Say(_nRow, _nCol, AllTrim(SubStr(_cLinha, 1, len(_cLinha) - _nDesc)), _oFonte)
	_nPos  := _nPos + _nHoriz - _nDesc
	_nRow  := _nRow + _nRowPixel
	_nDesc := 0
Next

Return
