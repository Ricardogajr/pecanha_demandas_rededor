#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GETCODTAB
Programa para localizar o Tabela de Preço utilizado no Contrato.
@type function
@author Ricardo da Silva
@since 13/07/2017
@version 1.0
@return cTabPrc
/*/

User Function GetCodTab()

	Local aArea		:= GetArea()
	Local cTabPrc 	:= ""
	
	// Verifica se esta executando a CTNA300
	If ( FunName() == "CNTA300" )
		
		// Localiza o Contrato
		DbSelectArea("AIA")
		AIA->( DbSetOrder(1) )
		// Verifica se Existe Contrato
		If (  ! Empty( SC7->C7_CODTAB ) ) // C7_CODTAB // C7_NUM // C8_NUMCON	
			
			// C7_FILIAL {C2}+C7_FORNECE {C6}+C7_LOJA {C2}+C7_CODTAB {C3}		
			If ( AIA->(DbSeek( SC7->(C7_FILIAL+C7_FORNECE+C7_LOJA+C7_CODTAB ) ) ) )
				
				// Recupera a Tabela de Preço
				cTabPrc 	  := AIA->AIA_CODTAB
				M->AIB_XCONTR := cTabPrc 
				
			EndIf
			
		EndIf
		
	EndIf
	
	RestArea( aArea )	

Return .T.