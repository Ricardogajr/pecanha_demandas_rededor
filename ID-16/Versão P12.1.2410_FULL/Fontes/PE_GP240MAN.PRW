#Include 'Protheus.ch'
#include "rwmake.ch"
User Function GP240MAN()

Local oModel := FwModelActivate()

//Valida pelos parametros se essa empresa irá executar essas chamadas.
	If !U_VALIDEMP()
		Return
	EndIf

   /* ticket n° 11669194 - linhas comentadas.
   /* Atualização R8_XHROPER via Cadastro de Ausências via inicializador padrão
   /* Atualização R8_XHROPER via Atestado Médico via PE_MDTA6854

   // 416094 - Rogerio Carvalho - 13/07/2018 - DOR04520620 - AMS Rio 
      if PARAMIXB[1] == 3  .OR. PARAMIXB[1] == 4
         // ticket n° 9344859  -- Ponteirar registro para alteração de atestados anteriores
         If IsInCallStack('GPEA240') == .F.
            If !(M->TNY_CODAFA $ "001|002")
               DbSetOrder(6)
               If DbSeek(xFilial("SR8")+SRA->RA_MAT+DTOS(M->TNY_DTINIC)+M->TNY_CODAFA)
                    DbSelectArea("SR8")
                    RecLock("SR8",.F.)  
                    SR8->R8_XHROPER := TIME()
                    SR8->(MsUnlock())
               EndIf              
            EndIf
         // ticket n° 10753899 - Validação comentada. Via GPEA240 o campo será gravado pelo inicializador padrão.
         Else
         416094 - Rogerio Carvalho - 13/07/2018 - DOR04520620 - AMS Rio Inclusão ou Alteração no Cadastro de Afastamentos
            RecLock("SR8",.F.)
            SR8->R8_XHROPER := TIME() // Grava hora da Operação (em que ocorreu a ação no sistema)
            
            SR8->(MsUnlock())        // A data já é grava no campo R8_DATA como padrão pelo Protheus 
          Fim ticket n° 10753899 
         EndIf
      EndIf
   
   // Fim  DOR04520620 - Rogerio Carvalho - AMS Rio

    Fim ticket n°• 11669194 */
 Return
