#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CNTA300.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "CRMDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PCMT
Ponto de entrada responsável pela alteração da data fim na tabela de preços após realizar uma alteração na revisão do contrato.

@author Lucas Miranda  
@since 13/04/2022 
/*/
//-------------------------------------------------------------------

User Function CN300PCMT()

    Local aArea := GetArea()
    Local lRet := .T.
    Local oModel := ParamIXB[1]
    Local cTabPc := oModel:GetValue("CNADETAIL","CNA_XTABPC")
    Local cFilPc := oModel:GetValue("CNADETAIL","CNA_FILIAL")
    Local cFornecPc := oModel:GetValue("CNADETAIL","CNA_FORNEC")
    Local cLojaPc := oModel:GetValue("CNADETAIL","CNA_LJFORN")
    Local dDataFim := oModel:GetValue("CN9MASTER","CN9_DTFIM")

    DbSelectArea("AIA")
    DbSetOrder(1)
    If AIA->(DbSeek(cFilPc+cFornecPc+cLojaPc+cTabPc))
        If AIA->AIA_DATATE <> dDataFim
            Reclock("AIA",.F.)
            AIA->AIA_DATATE := dDataFim
            AIA->(MsUnLock())
        EndIf
    EndIf

    RestArea(aArea)
Return lRet
