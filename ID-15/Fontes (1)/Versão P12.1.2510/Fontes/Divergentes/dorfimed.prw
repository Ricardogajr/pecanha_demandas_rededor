#include "protheus.ch"

/*/{Protheus.doc} DORFIMED
Automatização Ficha Médica na Abertura da FAP
@type  Function
@author Laura Peghini
@since 29/04/2025
@version 1.0
/*/
User Function DORFIMED()

Local nRecH3  := Recno()
Local cCdFtIn := GetNewPar("DR_FAPINT", "000072")
Local cH3Cod  := RH3_CODIGO
Local cH3Fil  := RH3_FILIAL
Local cCodAl  := RH3_XCODAL
Local cStatus := RH3_STATUS 
Local cAlias  := GetArea()
Local cSeqTM0 := ""
Local cMsg    := ""

    //Valida se a FAP não para vaga interna
    If cCodAl != cCdFtIn 
        If cStatus == '4' //"Aguardando Efetivacao RH"
            //PA2 tabela cadastro das FAPs
            DbSelectArea("PA2")
            PA2->(DbSetOrder(6))
            //Valida se a FAP existe e para buscar as informações da vaga e do candidato
            If PA2->(DbSeek(cH3Fil+cH3Cod))
                cCodVag := PA2->PA2_CDVAGA
                cCodCan := PA2->PA2_CDCAND
                cFilVag := PA2->PA2_FILVG
            else
                cMsg := "FAP não encontrada"
            EndIf
            PA2->(DbCloseArea())
            //SQG tabela candidatos
            DbSelectArea("SQG")
            SQG->(DbSetOrder(1))
            //Busca informações necessárias do candidato
            If SQG->(DbSeek(xFilial("SQG")+cCodCan))
                cNome   := SQG->QG_NOME
                dDtNas  := SQG->QG_DTNASC
                cRg     := SQG->QG_RG
                cCpf    := SQG->QG_CIC
            else
                cMsg := "Candidato não encontrado"
            EndIf
            SQG->(DBCloseArea())

            //SQS tabela vagas
            DbSelectArea("SQS")
            SQS->(DbSetOrder(1))
            //Busca informações necessárias da vaga
            If SQS->(DbSeek(cFilVag+cCodVag))
                cFuncao := SQS->QS_FUNCAO
                cCCusto := SQS->QS_CC
            else
                cMsg := "Vaga não encontrada"
            EndIf
            SQS->(DBCloseArea())

            //TM0 tabela ficha médica
            DbSelectArea("TM0")
            TM0->(DbSetOrder(5))
            //Valida se candidato já tem alguma ficha médica
            If TM0->(DbSeek(cFilVag+cCodCan))
                cMsg := "Ficha médica já existente" +CHR(13)+CHR(10)+ "Número: " +TM0->TM0_NUMFIC
            EndIf
            TM0->(DBCloseArea())

            //Se foi encontrada todas as informações necessárias
            If Empty(cMsg)
                Begin Transaction
                    //busca proximo número para cadastro da ficha médica
                    cSeqTM0 := GetSxeNum("TM0", "TM0_NUMFIC")
                    confirmSX8()
                    DbSelectArea("TM0")
                    TM0->(DbSetOrder(1))
                    TM0->(RecLock("TM0",.T.))
                        TM0_FILIAL := cFilVag
                        TM0_NUMFIC := cSeqTM0
                        TM0_CANDID := cCodCan
                        TM0_NOMFIC := cNome
                        TM0_DTNASC := dDtNas
                        TM0_DTIMPL := Date()
                        TM0_RG     := cRg
                        TM0_CPF    := cCpf
                        TM0_CODFUN := cFuncao
                        TM0_CC     := cCCusto
                    TM0->(MSUnLock())
                    TM0->(DBCloseArea())
                End Transaction
                FWAlertSuccess("Ficha Médica criada com sucesso." +CHR(13)+CHR(10)+ "Número: " +cSeqTM0, "Ficha Médica")
            Else
                FWAlertError("Erro na criação da Ficha Médica" +CHR(13)+CHR(10)+ cMsg, "Ficha Médica")
            EndIf
        Else
            cMsg := "Status diferente de 'Aguardando Efetivacao RH', não é permitida criação de ficha médica."
            FWAlertError("Erro na criação da Ficha Médica" +CHR(13)+CHR(10)+ cMsg, "Ficha Médica")
        EndIf
    Else
        cMsg := "FAP vaga interna, não é permitida criação de ficha médica."
        FWAlertError("Erro na criação da Ficha Médica" +CHR(13)+CHR(10)+ cMsg, "Ficha Médica")
    EndIf
    RestArea(cAlias)
    
Return 
