#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} AE_ESTLIB()
Função para estornar a liberação da solicitação de viagem e excluir o título gerado
@Author			Ramon Teodoro e Silva
@Since			17/07/2024
@Version		P12.2210
@Project    	
@Return		Nil	 */

User Function AE_ESTLIB(nOpcEx)

Local lRet  := .t.
Local aArea := GetArea() 

If nOpcEx == 1
  
      If Empty(LHP->LHP_DOCUME)

        MsgAlert("Não existe título a pagar para essa movimentação.", "Opção inválida!")
        lRet := .F.

    Else
      
        If MsgYesNo("Deseja estornar o adiantamento desta solicitação de viagem? Essa ação irá excluir o PA gerado no financeiro.", "Atenção!")    
      
            DbSelectArea("LHQ")
            DbSetOrder(1)

            If LHQ->(DbSeek(LHP->(LHP_FILIAL+LHP_CODIGO)))
                If LHP->LHP_XESTIT <> 'S'
                    U_AE_DVEXC()
                Else
                    MsgAlert("Estorno já realizado", "Opção inválida!")
                    lRet := .F.
                EndIf
            Else
                MsgAlert("Adiantamento não encontrado.")
                lRet := .F.
            EndIf
        
        EndIf

    EndIf
Else

    DbSelectArea("LHP")
    DbSetOrder(1)
    If LHP->(DbSeek(LHQ->(LHQ_FILIAL+LHQ_CODIGO)))

        If LHP->LHP_XESTIT <> "S" 
            If Empty(LHP->LHP_DOCUME)
                MsgAlert("Não existe título a pagar para essa movimentação.", "Opção inválida!")
                 lRet := .F.
            Else
                If MsgYesNo("Deseja estornar a liberação desta prestação de contas? Essa ação irá excluir o título gerado no financeiro.", "Atenção!")    
                    U_AE_DVEXC()
                EndIf
            EndIf
        Else
            MsgAlert("Estorno já realizado", "Opção inválida!")
            lRet := .F.
        EndIf
    
    EndIf
    
EndIf

RestArea(aArea)
Return lRet
