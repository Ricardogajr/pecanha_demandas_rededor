#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF Chr(13) + Chr(10)

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMSI0001 | AUTORA| Thais Paiva              | DATA | 08/09/2021    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Importação de arquivo CSV para inclusão de informações nas|//
//|            | Tabelas ACV e ACU                                                 |//
//+--------------------------------------------------------------------------------+//
//| CHAMADO    | 11930362 - DOR08917035  										   |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

User Function AMSI0001()

Local aArea    := GetArea()

Local cPerg    := "AMSI0001"
Local cTitulo  := "Importação do arquivo .CSV para tabela ACV/ACU"

Local nOpcao   := 0

Local aButtons := {}
Local aSays    := {}

Private oProcess := Nil

Pergunte(cPerg, .F.)

AADD(aSays,OemToAnsi("Importação do arquivo .CSV para tabela ACV ou ACU"))
AADD(aSays,"")
AADD(aSays,OemToAnsi("Clique no botão PARAM para informar o arquivo que será importado e a Tabela."))
AADD(aSays,"")
AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))

AADD(aButtons, { 1, .T., {|o| nOpcao := 1, o:oWnd:End()}} )
AADD(aButtons, { 2, .T., {|o| nOpcao := 2, o:oWnd:End()}} )
AADD(aButtons, { 5, .T., {| | Pergunte(cPerg, .T.)     }} )

FormBatch(cTitulo, aSays, aButtons,, 200, 530)

If nOpcao = 1
	oProcess := MsNewProcess():New( { || AMSI0001A(MV_PAR01,MV_PAR02) }, cTitulo, "Aguarde...", .F. )
	oProcess:Activate()
EndIf

RestArea(aArea)

Return

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMSI0001A| AUTORA| Thais Paiva              | DATA | 08/09/2021    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Importação de arquivo CSV para inclusão de informações nas|//
//|            | Tabelas ACV e ACU                                                 |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

Static Function AMSI0001A(cArquivo,nTabela)
Local cLinha    := ""
Local nHdl      := 0
Local nTamArq   := 0
Local nTamLinha := 0
Local nLinhas   := 0
Local nCont     := 0
Local lPrim := .T.
Local cTabela := "ACV"
Local lRetImp := .T.
Local aItens    := {}
Local _cFilAtu := ""
Private _aCmpObrig := {"ACV_FILIAL","ACV_CATEGO","ACV_GRUPO","ACV_CODPRO"}
Private aCabec := {}
Private _aFilial := {}


Default cArquivo := ""

If nTabela == 2
	cTabela := "ACU"
	_aCmpObrig := {"ACU_FILIAL","ACU_COD","ACU_DESC"}
EndIf

If (Upper(Right(AllTrim(cArquivo), 4)) != ".CSV" )
	MsgStop("Apenas arquivos com extensão CSV são aceitos!" + CRLF + "Verifique o arquivo informado!", "Atenção")
	Return
EndIf

If !File(cArquivo)
	MsgStop("O arquivo " + AllTrim(cArquivo) + " não existe, favor informar um arquivo existente!", "Atenção")
	Return
EndIf

nHdl := fOpen(cArquivo)

If nHdl == -1
	If fError() == 516
		Alert("Feche a planilha que gerou o Arquivo.")
	EndIf
EndIf

If nHdl == -1
	MsgAlert("O arquivo de nome " + AllTrim(cArquivo) + " nao pode ser aberto! Verifique os parametros.", "Atencao!")
	Return
Endif

fSeek(nHdl, 0, 0)	
nTamArq := fSeek(nHdl, 0, 2)	
fSeek(nHdl, 0, 0)	
fClose(nHdl)
FT_fUse(cArquivo)   
FT_fGoTop()        
nTamLinha := Len(FT_fReadln()) 
FT_fGoTop()	
nLinhas := FT_FLastRec()

oProcess:SetRegua1(nLinhas) 

DbSelectArea(cTabela)
DbSetOrder(1)
(cTabela)->(DbGoTop())

lPrim := .T.

While !FT_FEOF()

	oProcess:IncRegua1("Validando Linha: " + Alltrim(Str(nCont)))
	cLinha := FT_FREADLN()
	
	If !("FIM DA IMPORTACAO" $ UPPER(ALLTRIM(cLinha)) )
	
		If lPrim
			
			aCabec := Separa(cLinha,";",.F.)
			lPrim := .F.
			
			If Len(aCabec) > 0
				If !AMSI0001D(aCabec,cTabela)
					lRetImp := .F.
					EXIT
				EndIf
			EndIf
			
			If lRetImp
				If cTabela == "ACV" .AND. Len(aCabec) < 4
					MsgAlert("O Cabeçalho da Tabela ACV não possui todos os itens conforme Layout. A importação será cancelada!", "Atencao!")
					lRetImp := .F.
					EXIT
				ElseIf cTabela == "ACU" .AND. Len(aCabec) < 3
					MsgAlert("O Cabeçalho da Tabela ACU não possui todos os itens conforme Layout. A importação será cancelada!", "Atencao!")
					lRetImp := .F.
					EXIT
				Else
					FT_FSKIP()
					nCont++
				EndIf
			EndIf
		
		Else
			
			aDados := Separa(cLinha,";",.T.)
			
			If AMSI0001C(aDados,cTabela,nCont)
				aAdd(aItens, aDados)
				If Empty(Alltrim(_cFilAtu)) .OR. (Alltrim(_cFilAtu) <> Alltrim(aDados[1]) .AND. AScan(_aFilial,aDados[1]) == 0 .AND. !Empty(Alltrim(_cFilAtu)))
					aAdd(_aFilial,Alltrim(aDados[1]))
					_cFilAtu := Alltrim(aDados[1])
				EndIf
				FT_FSKIP()
				nCont++
			Else
				lRetImp := .F.
				EXIT
			EndIf
			
		EndIf
	Else
		Exit
	EndIf

EndDo
FT_FUse()
fClose(nHdl)
(cTabela)->(DbCloseArea())

If lRetImp
	Processa( {||AMSI0001I(aItens,cTabela)}, "Aguarde...","Importando registros...", .T. )
EndIf

Return

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMSI0001D| AUTORA| Thais Paiva              | DATA | 08/09/2021    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Validações dicionário de Dados                            |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
Static Function AMSI0001D(aCampos, cTabela)

Local nX 		:= 0
Local lRet 		:= .T.
Local aArea 	:= GetArea()


For nX := 01 To Len(aCampos)
	
	cCampo := UPPER(Alltrim(aCampos[nX]))
	
	If Empty(cCampo)
		
		ADEL(aCabec, nX)
	
	ElseIf cTabela <> SUBSTR(UPPER(Alltrim(cCampo)),1,3)

		MsgAlert("Campo: " + UPPER(Alltrim(cCampo)) + " não pertence a tabela "+cTabela+". A importação será cancelada!", "Atencao!")
		lRet := .F.
		
	ElseIf FieldPos(cCampo) == 0

		MsgAlert("Campo: " + cCampo + " não existe na tabela "+cTabela+". A importação será cancelada!", "Atencao!")
		lRet := .F.
		
		EXIT		

	Else

		lRet := .T.

	EndIf
	
Next nX
	
If lRet

	If cTabela == "ACV"
			
		If UPPER(Alltrim(aCampos[1])) <> _aCmpObrig[1] .OR. UPPER(Alltrim(aCampos[2])) <> _aCmpObrig[2] .OR. ;
		   UPPER(Alltrim(aCampos[3])) <> _aCmpObrig[3] .OR. UPPER(Alltrim(aCampos[4])) <> _aCmpObrig[4]
		   
			MsgAlert("O cabeçalho da Planilha de importação da Tabela ACV não está na ordem ou um dos campos não foi informado conforme Layout. A importação será cancelada!", "Atencao!")
			lRet := .F.
			
		EndIf
		
	Else
		
		If UPPER(Alltrim(aCampos[1])) <> _aCmpObrig[1] .OR. UPPER(Alltrim(aCampos[2])) <> _aCmpObrig[2] .OR. ;
		   UPPER(Alltrim(aCampos[3])) <> _aCmpObrig[3]
		   
			MsgAlert("O cabeçalho da Planilha de importação da Tabela ACU não está na ordem ou um dos campos não foi informado conforme Layout. A importação será cancelada!", "Atencao!")
			lRet := .F.
			
		EndIf

	EndIf
	
EndIf

RestArea(aArea)
Return lRet


//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMSI0001C| AUTORA| Thais Paiva              | DATA | 09/09/2021    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Validações de Dados                                               |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
Static Function AMSI0001C(aItmTab,cTabela,nLinha)
Local aArea 	:= GetArea()
Local lRet := .T.

If cTabela == "ACV"
	
	If Empty(Alltrim(aItmTab[1])) .AND. Empty(Alltrim(aItmTab[2])) .AND. Empty(Alltrim(aItmTab[3])) .AND. Empty(Alltrim(aItmTab[4]))
		MsgAlert("Linha "+Alltrim(Str(nLinha))+" não possui informações. A importação será cancelada!", "Campos Obrigatórios!")
		lRet := .F.
	ElseIf Empty(Alltrim(aItmTab[1])) 
		MsgAlert("Filial não informada na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campo Obrigatório!")
		lRet := .F.
	ElseIf Empty(Alltrim(aItmTab[2])) 
		MsgAlert("Categoria não informada na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campo Obrigatório!")
		lRet := .F.
	ElseIf Empty(Alltrim(aItmTab[3])) .AND. Empty(Alltrim(aItmTab[4]))
		MsgAlert("Grupo e Código do Produto não informados na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campos Obrigatórios!")
		lRet := .F.
	ElseIf !Empty(Alltrim(aItmTab[3])) .AND. !Empty(Alltrim(aItmTab[4]))
		MsgAlert("Ambos os campos Grupo e Código do Produto estão preenchidos na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campos Obrigatórios!")
		lRet := .F.
	EndIf
	
Else

	If Empty(Alltrim(aItmTab[1])) .AND. Empty(Alltrim(aItmTab[2])) .AND. Empty(Alltrim(aItmTab[3]))
		MsgAlert("Linha "+Alltrim(Str(nLinha))+" não possui informações. A importação será cancelada!", "Campos Obrigatórios!")
		lRet := .F.
	ElseIf Empty(Alltrim(aItmTab[1])) 
		MsgAlert("Filial não informada na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campo Obrigatório!")
		lRet := .F.
	ElseIf Empty(Alltrim(aItmTab[2])) 
		MsgAlert("Código não informado na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campo Obrigatório!")
		lRet := .F.
	ElseIf Empty(Alltrim(aItmTab[3])) 
		MsgAlert("Descrição não informada na linha "+Alltrim(Str(nLinha))+". A importação será cancelada!", "Campo Obrigatório!")
		lRet := .F.
	EndIf

EndIf

RestArea(aArea)
	
Return lRet


//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | AMSI0001I| AUTORA| Thais Paiva              | DATA | 09/09/2021    |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Gravar informações na Tabela                              |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////
*/
Static Function AMSI0001I(aItmImp,cTabela)
Local _aArea := GetArea()
Local _nF := 0
Local _nA := 0
Local _nI := 0
Local dData := ddatabase
Local cHora := Time()
Local _nItm := 0
Local _cSeek := ""

Begin Transaction

DbSelectArea(cTabela)
DbSetOrder(1)
(cTabela)->(DbGoTop())
For _nF := 1 to Len(_aFilial)
	(cTabela)->(DbSeek(_aFilial[_nF]))
	While (cTabela)->&(aCabec[1]) == _aFilial[_nF]
		RecLock(cTabela, .F.)
		If cTabela == "ACV"
			(cTabela)->ACV_XDTLOG := dData
			(cTabela)->ACV_XHRLOG := cHora
		Else
			(cTabela)->ACU_XDTLOG := dData
			(cTabela)->ACU_XHRLOG := cHora
		Endif		
		(cTabela)->(DbDelete())
		(cTabela)->(MsUnLock())
		(cTabela)->(DbSkip())
	Enddo
Next _nF

For _nA := 1 to Len(aItmImp)
	If cTabela == "ACV"
		_cSeek := aItmImp[_nA][1]+aItmImp[_nA][2]+PADR(Alltrim(aItmImp[_nA][3]),TamSx3("ACV_GRUPO")[1])+PADR(Alltrim(aItmImp[_nA][4]),TamSx3("ACV_CODPRO")[1])
	Else
		_cSeek := aItmImp[_nA][1]+aItmImp[_nA][2]
	EndIf
	(cTabela)->(DbGoTop())
	If !(DbSeek(_cSeek))
		RecLock(cTabela, .T.)
		For _nI := 1 to Len(aCabec)
			If GetSx3Cache(aCabec[_nI], 'X3_TIPO') == 'N'
				(cTabela)->&(aCabec[_nI]) := Val(aItmImp[_nA][_nI])
			Else
				(cTabela)->&(aCabec[_nI]) := aItmImp[_nA][_nI]
			Endif
		Next _nI
		If cTabela == "ACV"
			(cTabela)->ACV_XDTLOG := dData
			(cTabela)->ACV_XHRLOG := cHora
		Else
			(cTabela)->ACU_XDTLOG := dData
			(cTabela)->ACU_XHRLOG := cHora
		Endif		
		(cTabela)->(MsUnLock())
		_nItm++
	EndIf
Next _nA
(cTabela)->(DbCloseArea())

End Transaction

MsgAlert("Foram importados "+Alltrim(Str(_nItm))+" registros.", "Importação Finalizada!")

RestArea(_aArea)
Return
