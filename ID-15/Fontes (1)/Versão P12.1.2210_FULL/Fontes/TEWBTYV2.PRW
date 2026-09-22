#Include 'Protheus.ch'
#Include 'TopConn.ch'
/*
{Protheus.doc} MT100TOK
Validação nas perguntas da rotina de Eliminação de Resíduo
@Author     Ramon Teodoro
@Since      13/04/2016       
@Version    P12.7
@Project     
@Return     lRet
*/
User Function TEWBTYV2()

Local lRet    := .T.
Local aArea   := GetArea()
Local cUser   := RetCodUsr()
Local lPedido := .T.
Local lSolic  := .T.
Local nOpcao  := 1
Local cRetGrp := ""

DbSelectArea("SY1")
SY1->(DbSetOrder(3))

DbSelectArea("SAI")
SAI->(DbSetOrder(2))

If SY1->(DbSeek(xFilial("SY1")+cUser))
	lPedido  := .T.
Else
	lPedido := .F.
EndIf

If !SAI->(DbSeek(xFilial("SAI")+cUser))
	aGrupos := fUserGrp(cUser)
	For nX := 01 To Len(aGrupos)
		cRetGrp += aGrupos[nX] + ","
	Next nX 
	cRetGrp := SubStr(cRetGrp, 1, Len(cRetGrp)-1)
	cQuery := "SELECT AI_XTPSC, AI_USER, AI_GRUSER FROM "+ RetSqlName("SAI")
	cQuery += "		WHERE AI_FILIAL = '" + xFilial("SAI") + "' AND AI_GRUSER IN " + FormatIn( cRetGrp, "," ) + " AND D_E_L_E_T_= ' '"	
	
	If Select("AITMP") > 0
		AITMP->(DbCloseArea())
	EndIf	
	
	TcQuery cQuery New Alias "AITMP"
	
	If AITMP->(Eof())
		lSolic := .F.		
	EndIf
		
EndIf


If lPedido .And. !lSolic .And. MV_PAR08 <> 1
	lRet := .F.
	MsgAlert("Este usuário só tem premisão para eliminar resíduo por Pedido Compra")
ElseIf lSolic .And. !lPedido .And. MV_PAR08 <> 5
	lRet := .F.  
	MsgAlert("Este usuário só tem premisão para eliminar resíduo por Solicitação Compra")
ElseIf lPedido .And. lSolic .And. MV_PAR08 <> 1 .And. MV_PAR08 <> 5
	MsgAlert("Opção inválida para este usuário, favor escolher as opção 'Pedido de Compra' ou 'Solicitação de Compra'")
	lRet := .F.
ElseIf !lPedido .And. !lSolic
	MsgAlert("Opção disponível apenas para usuários configurados como Compradores ou Solicitantes")
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet
/*
|----------------------------------------------------------------------------|
|Programa  |fGrpUser  |Autor  |TECNOSUM            | Data |  30/10/2017      |
|----------------------------------------------------------------------------|
|Descrição |Retorno o campo AI_GRUSER                                        |						  
|----------------------------------------------------------------------------|
|Uso       |CAMPO AI_GRUSER                                                  |						  
|----------------------------------------------------------------------------|
*/
Static Function fUserGrp(cUsuario)

Local aUserGrp	:= {}
Local aGrupos 	:= {}

PswOrder(1)
If (  PswSeek( cUsuario, .T. ) )
	// Retorna os Grupos
	aGrupos := Pswret(1)
	// O usuario corrente faz parte do grupo
	aUserGrp := aGrupos[1][10]					
EndIf
	
Return( aUserGrp )