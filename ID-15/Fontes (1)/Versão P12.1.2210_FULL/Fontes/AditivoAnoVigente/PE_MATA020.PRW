#INCLUDE "RWMAKE.CH"

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | MATA020 | AUTORA| Thais Paiva              | DATA | 09/06/2022   |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Customizações após a gravação do Fornecedor. 					   |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function MATA020()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ""
    Local cIdPonto   := ""
    Local cIdModel   := ""
    Local lIsGrid    := .F.
    Local nLinha     := 0
    Local nQtdLinhas := 0
    Local cMsg       := ""
    Local nOp

    If INCLUI .OR. ALTERA
		If !Empty(SA2->A2_XCODES) .AND. !Empty(SA2->A2_COD_MUN)
			Reclock("SA2",.F.)
			SA2->A2_IBGE := (SA2->A2_XCODES + SA2->A2_COD_MUN)
			MsUnlock()
		EndIf
	EndIf
	
Return (xRet)
