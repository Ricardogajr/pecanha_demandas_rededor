#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ORG030MOV
Necessidade de implementação que permita controlar o processo de movimentação para congelamento e cancelamento de postos,
permitindo que funcionalidades customizadas possam aplicar validações especificas de acordo com cada negócio

@type function
@author		Ademar Fernandes
@since		13/02/2017
@version	1.0
@version	P12.1.7
@Project	MAN0000007423042_EF_006
@param1		nOperação: Esse parâmetro é responsável em identificar ao PE a operação que está sendo realizada no momento, de
			acordo com os seguintes conteúdos:
			Conteúdo: 1 indica se o processo é de prevalidação de um congelamento de posto
			Conteúdo: 2 indica se o processo é de pósprocessamento de um congelamento de posto
			Conteúdo: 3 indica se o processo é de prevalidação de um cancelamento de posto
			Conteúdo: 4 indica se o processo é de pósprocessamento de um cancelamento de posto
@param2		cFilial: carrega a filial posicionada da tabela RCL
@param3		cPosto: carrega o posto posicionado da tabela RCL
@param4		cDepartamento: carrega o departamento posicionado da tabela RCL
@param5		cStatus: carrega o status atual do registro posicionado da tabela RCL
@return 	lRet => Indica se deve ou nao continuar com o processamento/gravação
/*/
//---------------------------------------------------------------------------------------------------------------------------

// Ponto de Entrada para tratamento de congelamento/cancelamento de postos
User Function ORG030MOV()
	
	Local lRet		:= .T.
	LocaL nOperac	:= PARAMIXB[1]
	Local cFil		:= PARAMIXB[2]
	Local cPosto 	:= PARAMIXB[3]
	Local cDepto	:= PARAMIXB[4]
	Local cStatus	:= PARAMIXB[5]
	
	//-PreValidação de Congelamento e de Cancelamento
	If nOperac = 1 .OR. nOperac = 3
		dbSelectArea("PA9")
		dbSetOrder(1)	//-PA9_FILIAL + PA9_CODIGO
		
		BeginSql Alias "QRYTMP"
			   				
			SELECT *
			FROM %table:PA9% PA9 (NOLOCK)
			WHERE PA9.%notDel% 
		    AND PA9_FILAPR = %exp:cFil%
		    AND PA9_POSAPR = %exp:cPosto%
		    
		EndSql
		
		If !Eof()
			lRet := .F.
			If nOperac = 1
				MsgAlert("O posto não pode ser Congelado pois está em uso no Controle de Alçadas de Solicitações!","Movimento de Postos")
			Else
				MsgAlert("O posto não pode ser Cancelado pois está em uso no Controle de Alçadas de Solicitações!","Movimento de Postos")
			EndIf
		EndIf
		QRYTMP->(DbCloseArea())
			
	EndIf	
Return(lRet)
