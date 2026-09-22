#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ORG060MOV
Ponto de entrada especifico para tratar atualizações diretamente nos itens da visão (RD4), na atualização da estrutura.
Ele está sendo tratado no tudoOk da funcionalidade, onde irá receber as informações do aCol antes da atualização final.
A atualização no linhaOk não é possível, pois toda a estrutura é revalidada em qualquer atualização realizada.

@type function
@author		Ademar Fernandes
@since		27/03/2017
@version	1.0
@version	P12.1.7
@Project	MAN0000007423042_EF_006
@param1		cFil: carrega a filial posicionada
@param2		cCod: carrega o codigo da visão posicionado
@param3		aDados: possui as informações atualizadas dos itens da visão (RD4) que serão atualizados
@return 	lRet => Indica se deve ou nao continuar com o processamento/gravação
/*/
//---------------------------------------------------------------------------------------------------------------------------
User Function ORG060MOV()
	
	Local lRet	:= .T.
	LocaL cFil	:= PARAMIXB[1]
	Local cCod	:= PARAMIXB[2]
	Local aDados	:= PARAMIXB[3]
	Local aRD4	:= {}
	Local nPosDif	:= 999
	Local nX		:= 0
	Local a1Area	:= GetArea()
	
	//-Verifica se a Visao ja foi utilizada no Cad.Contr.Alçadas
	dbSelectArea("PAB")
	dbSetOrder(1)	//-PAB_FILIAL + PAB_CODIGO
	
	BeginSql Alias "QRY1TMP"
		
		SELECT *
		FROM %table:PAB% PAB (NOLOCK)
		WHERE PAB.%notDel%
		AND PAB_FILIAL = %exp:cFil%
		AND PAB_VISAO  = %exp:cCod%
		
	EndSql
	
	If !Eof()
		
		//-Monta um array com a Visao "original" da RD4 para comparar qual posto foi alterado
		dbSelectArea("RD4")
		dbSetOrder(1)	//-RD4_FILIAL + RD4_CODIGO + RD4_ITEM + RD4_TREE + DTOS(RD4_DATA)
		DbSeek(cFil + cCod,.F.)
		
		While !Eof() .And. RD4_FILIAL + RD4_CODIGO == cFil + cCod
			
			AAdd(aRD4,{	RD4_ITEM,;	//-01
						RD4_EMPIDE,;	//-02
						RD4_FILIDE,;	//-03
						RD4_CODIDE,;	//-04
						RD4_DESC,;	//-05
						RD4_TREE,;	//-06
						"RD4",;		//-07
						RECNO(),;		//-08
						.F.})		//-09
			dbSkip()
		EndDo
		
		//-Compara os 2 arrays para encontrar alterações
		If !Empty(aRD4)
			
			ArrayCompare( aRD4 , aDados , @nPosDif )
			
			If nPosDif > 0 .And. nPosDif <= LEN(aRD4) .And.;
				!( aRD4[nPosDif,02] + aRD4[nPosDif,03] + aRD4[nPosDif,04] == aDados[nPosDif,02] + aDados[nPosDif,03] + aDados[nPosDif,04] )
				
				dbSelectArea("PA9")
				dbSetOrder(1)	//-PA9_FILIAL + PA9_CODIGO
				
				BeginSql Alias "QRY2TMP"
					
					SELECT *
					FROM %table:PA9% PA9 (NOLOCK)
					WHERE PA9.%notDel%
					AND PA9_FILIAL = %exp:cFil%
					AND PA9_CODIGO = %exp:cCod%
					AND PA9_FILAPR = %exp:aRD4[nPosDif,03]%
					AND PA9_POSAPR = %exp:aRD4[nPosDif,04]%
					
				EndSql
				
				If !Eof()
					lRet := .F.
					MsgAlert("O posto " + aRD4[nPosDif,04] + ", na linha " + Alltrim(Str(nPosDif)) + ", não pode ser Alterado pois está em uso no Controle de Alçadas de Solicitações!","Estrutura de Visões")
				EndIf
				
				QRY2TMP->(DbCloseArea())
			EndIf
		EndIf
	EndIf
	
	QRY1TMP->(DbCloseArea())
	
	If lRet
		lRet := U_F0801901(cFil,cCod,aDados)
	EndIf
	
	RestArea(a1Area)
Return(lRet)