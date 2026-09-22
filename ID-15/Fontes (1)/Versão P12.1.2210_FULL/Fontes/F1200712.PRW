/*/{Protheus.doc} F1200712
Verifica se foram escolhidas filiais diferentes na selecao.
@author 	Paulo Krüger
@since 		17/08/2017
@version 	P12.7
@Project    MAN0000007423046
@Return		lRet
/*/

User Function F1200712()

Local aArea		:= {}
Local nRecPos	:= 0
Local nAt		:= 0
Local cFilPos	:= ''
Local lRet		:= .T.

aArea	:=	GetArea()
cFilPos :=	(cArqTrab)->C1_FILIAL	 
nRecPos :=	(cArqTrab)->(Recno())
nAt 	:=	oMrkBrowse:At()

(cArqTrab)->(DbGoTop())

While (cArqTrab)->(!Eof())
	If !Empty((cArqTrab)->TMP_OK)
		If (cArqTrab)->C1_FILIAL <> cFilPos
			MSGALERT( 'Todos os Itens selecionados devem pertencer a mesma filial.', 'Selecao incorreta de itens.' )  
 			Reclock((cArqTrab),.F.)
			(cArqTrab)->TMP_OK := ''
			MsUnLock()
			lRet := .F.
		EndIf
	EndIf
	(cArqTrab)->(DbSkip())
EndDo

(cArqTrab)->(DbGoTo(nRecPos))
oMrkBrowse:GoTo(nAt)
oMrkBrowse:Refresh()
oMrkBrowse:SetMark('','cArqTrab','TMP_OK')

RestArea(aArea)

Return(lRet)
