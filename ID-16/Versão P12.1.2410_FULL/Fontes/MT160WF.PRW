#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT160WF
Ponto de entrada de Verificar se ocorreu a Geração do Contrato.
@type function
@author Ricardo da Silva
@since 13/07/2017
@version 1.0
@return NIL
/*/

User Function MT160WF()
	
	Local aArea	:= GetArea()
	
	// Verifica se esta executando a MATA161
	If ( FunName() == "MATA161" )
		
		// Localiza o Contrato
		DbSelectArea("AIA")
		AIA->( DbOrderNickName("NUMCONT") )
		// Verifica se Existe Contrato
		If (  ! Empty( SC8->C8_NUMCON ) )	
			
			// C8_FILIAL {C2}+C8_FORNECE {C6}+C8_LOJA {C2}+C8_NUMCON {C15}
			If ( AIA->(DbSeek( SC8->( C8_FILIAL+C8_FORNECE+C8_LOJA+C8_NUMCON ) ) ) )
				
				// Recupera o Contrato
				cContrato := AIA->AIA_XNUMCO
				
				// Localiza o Primeiro Item do Contrato pela Busca Aproximada
				DbSelectArea("AIB")
				AIB->( DbSetOrder(1) )
				// AIA_FILIAL{C2}+AIA_CODFOR{C6}+AIA_LOJFOR{C2}+AIA_XNUMCO{C15}
				If ( AIB->( MsSeek( AIA->( AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB ), .T. ) ) )
					
					// Monta a Chave a ser Processada
					Chave_AIA := AIA->( AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB )
					
					// Processa todos os Registros que pertencem ao Contrato
					While !AIB->( Eof() ) .And. ( AIB->( AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB ) == Chave_AIA )
						
						// Atualiza o Item com o Contrato
						AIB->( RecLock("AIB",.F.) )
							AIB->AIB_XCONTR := cContrato 
						AIB->( MsUnLock() )
						
						AIB->( DbSkip() )
						
					End
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	RestArea( aArea )	
	
Return