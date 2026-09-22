#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} APDPEXTREE
Ponto de Entrada para tratamento de exclusão dos itens na arvore de visão

(*) Não executar nenhuma informação de alerta dentro desse ponto de entrada, as mensagens
de retorno serão carregadas no log automaticamente pelo produto padrão.

@type function
@author		Ademar Fernandes
@since		27/03/2017
@version	1.0
@version	P12.1.7
@Project	MAN0000007423042_EF_007
@param1		cFil: carrega a filial posicionada
@param2		cCod: carrega o codigo da visão posicionado
@param3		aDados: possui as informações atualizadas dos itens da visão (RD4) que serão atualizados
@return 	aRet => Se ocorrer "erro", o array indica que nao deve continuar com o processamento/gravação
/*/
//---------------------------------------------------------------------------------------------------------------------------
User Function APDPEXTREE()
	
	LocaL nOpc	:= PARAMIXB[1]
	Local cMyAlias	:= PARAMIXB[2]
	Local cMyFilial:= PARAMIXB[3]
	Local cKeyDel	:= PARAMIXB[4]	// visão + item
	Local aLog	:= {}
	Local aRet	:= {}
	Local a1Area	:= GetArea()
	Local cMyVisao	:= Substr(cKeyDel,1,6)	//-123456
	Local cMyItem	:= Substr(cKeyDel,7,6)	//-123456
	/*
	varinfo('nOpc     -> ',nOpc)
	varinfo('cAlias   -> ',cMyAlias)
	varinfo('cFilVisao-> ',cMyFilial)
	varinfo('cKeyDel  -> ',cKeyDel)
	*/
	If nOpc == 6 .and. cMyAlias == 'RD4'
		
		//-Verifica se a Visao ja foi utilizada no Cad.Contr.Alçadas
		dbSelectArea("PAB")
		dbSetOrder(1)	//-PAB_FILIAL + PAB_CODIGO
		
		BeginSql Alias "QRY1TMP"
			
			SELECT *
			FROM %table:PAB% PAB (NOLOCK)
			WHERE PAB.%notDel%
			AND PAB_FILIAL = %exp:cMyFilial%
			AND PAB_VISAO  = %exp:cMyVisao%
			
		EndSql
		
		If !Eof()
			
			dbSelectArea("RD4")
			dbSetOrder(1)	//-RD4_FILIAL + RD4_CODIGO + RD4_ITEM + RD4_TREE + DTOS(RD4_DATA)
			DbSeek(cMyFilial + cMyVisao + cMyItem,.F.)
			
			dbSelectArea("PA9")
			dbSetOrder(1)	//-PA9_FILIAL + PA9_CODIGO
			
			BeginSql Alias "QRY2TMP"
				
				SELECT *
				FROM %table:PA9% PA9 (NOLOCK)
				WHERE PA9.%notDel%
				AND PA9_FILIAL = %exp:cMyFilial%
				AND PA9_CODIGO = %exp:cMyVisao%
				AND PA9_FILAPR = %exp:RD4->RD4_FILIDE%
				AND PA9_POSAPR = %exp:RD4->RD4_CODIDE%
				
			EndSql
			
			If !Eof()
				//??MsgAlert("O posto " + RD4->RD4_CODIDE + ", não pode ser Alterado pois está em uso no Controle de Alçadas de Solicitações!","Estrutura de Visões")
				
				//realizar as validações necessárias
				//no caso em que o resultado for negativo, preencher todas as mensagens obrigatórias de retorno
				//caso todas não estejam preenchidas, o resultado do ponto de entrada será desprezado!
				
				aLog := {}
				AAdd( aLog , 'O Posto não pode ser Excluído!' )
				AAdd( aRet , aLog )
				
				aLog := {}
				AAdd( aLog , 'O posto ' + RD4->RD4_CODIDE + ', não pode ser Alterado' )
				AAdd( aLog , 'pois está em uso no Controle de Alçadas de Solicitações!' )
				AAdd( aLog , '' )
				AAdd( aRet , aLog )
			EndIf
			
			QRY2TMP->(DbCloseArea())
		EndIf
		QRY1TMP->(DbCloseArea())
	EndIf
	
	RestArea(a1Area)
Return(aRet)
