#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"

/*/{Protheus.doc} DORADFMED
Automatiza��o Ficha M�dica na Abertura da FAP
@type  Function
@author Laura Peghini
@since 29/10/2025
@version 1.0
/*/
User Function DORADFMED(cFilFap,cCodCan,cCodVag)

Local cAlias  := GetArea()
Local cSeqTM0 := ""
Local cAntFil := cFilAnt
Local lRet    := .T.

    RpcSetEnv("01", cFilFap)

    //SQG tabela candidatos
    DbSelectArea("SQG")
    SQG->(DbSetOrder(1))
    //Busca informações necessárias do candidato
    If SQG->(DbSeek(xFilial("SQG")+cCodCan))
        cNome   := SQG->QG_NOME
        dDtNas  := SQG->QG_DTNASC
        cRg     := SQG->QG_RG
        cCpf    := SQG->QG_CIC
    EndIf
    SQG->(DBCloseArea())
    //SQS tabela vagas
    DbSelectArea("SQS")
    SQS->(DbSetOrder(1))
    //Busca informações necessárias da vaga
    If SQS->(DbSeek(cFilFap+cCodVag))
        cFuncao := SQS->QS_FUNCAO
        cCCusto := SQS->QS_CC
    EndIf
    SQS->(DBCloseArea())
    If cFilAnt <> cFilFap
        cFilAnt := cFilFap
    EndIf
    //TM0 tabela ficha médica
    DbSelectArea("TM0")
    TM0->(DbSetOrder(5))
    //Valida se candidato já tem alguma ficha médica
    If TM0->(DbSeek(cFilFap+cCodCan))
        If Empty(TM0->TM0_MAT)
            lRet := ValidSRA( cFilFap, cCpf )
            If lRet
                cSeqTM0 := GetSxeNum("TM0", "TM0_NUMFIC")
                confirmSX8()
                TM0->(RecLock("TM0",.T.))
                    TM0_FILIAL := cFilFap
                    TM0_NUMFIC := cSeqTM0
                    TM0_CANDID := cCodCan
                    TM0_NOMFIC := cNome
                    TM0_DTNASC := dDtNas
                    TM0_DTIMPL := Date()
                    TM0_RG     := cRg
                    TM0_CPF    := cCpf
                    TM0_CODFUN := cFuncao
                    TM0_CC     := cCCusto
                    TM0_FILFUN := cFilFap
                TM0->(MSUnLock())
            Else
                cSeqTM0 := ""
            EndIf
        Else
            cSeqTM0 := GetSxeNum("TM0", "TM0_NUMFIC")
            confirmSX8()
            TM0->(RecLock("TM0",.T.))
                TM0_FILIAL := cFilFap
                TM0_NUMFIC := cSeqTM0
                TM0_CANDID := cCodCan
                TM0_NOMFIC := cNome
                TM0_DTNASC := dDtNas
                TM0_DTIMPL := Date()
                TM0_RG     := cRg
                TM0_CPF    := cCpf
                TM0_CODFUN := cFuncao
                TM0_CC     := cCCusto
                TM0_FILFUN := cFilFap
            TM0->(MSUnLock())
        EndIf
    Else
        cSeqTM0 := GetSxeNum("TM0", "TM0_NUMFIC")
        confirmSX8()
        TM0->(RecLock("TM0",.T.))
            TM0_FILIAL := cFilFap
            TM0_NUMFIC := cSeqTM0
            TM0_CANDID := cCodCan
            TM0_NOMFIC := cNome
            TM0_DTNASC := dDtNas
            TM0_DTIMPL := Date()
            TM0_RG     := cRg
            TM0_CPF    := cCpf
            TM0_CODFUN := cFuncao
            TM0_CC     := cCCusto
            TM0_FILFUN := cFilFap
        TM0->(MSUnLock())
    EndIf
    TM0->(DBCloseArea())
    cFilAnt := cAntFil 

    RestArea(cAlias)
    
Return(cSeqTM0)

Static Function ValidSRA( cFilCand, cCPFCand )

Local cQuery 	:= ""
Local cAliasTrb := GetNextAlias() 
Local lRet      := .T.

    cQuery := "SELECT SRA.R_E_C_N_O_ AS RCNSRA "
	cQuery += "FROM " + RetSqlName("SRA") + " SRA "
	cQuery += "WHERE SRA.RA_FILIAL = '"+ cFilCand +"' "	
    cQuery += " AND SRA.RA_CIC = '" + cCPFCand + "' "
	cQuery += "	AND SRA.RA_SITFOLH <> 'D' "
	cQuery += "	AND SRA.D_E_L_E_T_ = ' ' "

	PLSQuery( cQuery, cAliasTrb )
	(cAliasTrb)->(DBGoTop())
    If !(cAliasTrb)->(Eof())
		lRet := .F.
	EndIf
	(cAliasTrb)->(DbCloseArea())

Return(lRet)
