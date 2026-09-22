#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
/*
{Protheus.doc} F0100102()
Consulta Especifica tabela de preço por fornecedores
@Author			Jose Marcio da Silva Santos / Mick William da Silva
@Since			09/06/2016 / 07/07/2016
@Version		P12.7
@Project    	MAN00000462901_EF_001
@Return			cRet, Retorna o código da Tabela de Preços
	 
*/

User Function F0100102() 
	Local oModel		:= FWModelActive()
	Local oModelCNA		:= oModel:GetModel("CNADETAIL")
	Local lRet			:= .T.
	Local cQuery		:= ""
	Local cRet			:= ""
	Local cAlsQry		:= GetNextAlias()
	Local aTabPrc		:= {}
	Local oLb, oDlg
	Local lOk			:= .F.
	Local nPosAt		:= 0
	
	//-- Verifica se Fornecedor esta preenchido
	If !Empty(oModelCNA:GetValue("CNA_FORNEC")) .And. !Empty(oModelCNA:GetValue("CNA_LJFORN"))
		
		//-- Busca as tabelas de preço do Fornecedor 
		cQuery := " SELECT AIA.AIA_CODTAB, AIA.AIA_DESCRI, AIA.AIA_DATDE, AIA.AIA_DATATE "
		cQuery += " FROM " + RetSqlName("AIA") + " AIA "
		cQuery += " WHERE "
		cQuery += "     AIA.D_E_L_E_T_ = '' "
		cQuery += " AND AIA.AIA_FILIAL = '" + xFilial("AIA") + "' "
		cQuery += " AND AIA.AIA_CODFOR = '" + oModelCNA:GetValue("CNA_FORNEC") + "' "
		cQuery += " AND AIA.AIA_LOJFOR = '" + oModelCNA:GetValue("CNA_LJFORN") + "' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAlsQry, .T., .T.)
		
		If (cAlsQry)->(!EOF())
			While (cAlsQry)->(!EOF())
				
				//-- Verifica Vigencia
				If !Empty((cAlsQry)->AIA_DATATE)
					If sTod((cAlsQry)->AIA_DATDE) <= dDataBase .And. sTod((cAlsQry)->AIA_DATATE) >= dDataBase
						AAdd(aTabPrc, {(cAlsQry)->AIA_CODTAB, (cAlsQry)->AIA_DESCRI})
					EndIf
				Else
					AAdd(aTabPrc, {(cAlsQry)->AIA_CODTAB, (cAlsQry)->AIA_DESCRI})
				EndIf
				
				(cAlsQry)->(DbSkip())
			EndDo
		EndIf
		(cAlsQry)->(DbCloseArea())
		
		If !Empty(aTabPrc)
			//-- Exibe tela de seleção tabela de preço
			DEFINE MSDIALOG oDlg FROM 0, 0  TO 290, 500 TITLE OemToAnsi("Tabela de Preço") Of oMainWnd PIXEL
				oLB := TWBrowse():New( 05, 05, 245, 110, ,{"Tab.Preço", "Descrição"}, ,oDlg, ,, ,, ,, ,, ,, ,.F., ,.T., ,.F., ,, )
				
				oLB:SetArray(aTabPrc)
				oLB:bLDblClick := { || lOk:=.T., nPosAt:=oLB:nAt, Close(oDlg)}
				
				oLB:bLine := {|| {;
						aTabPrc[oLB:nAt, 1], ;
						aTabPrc[oLB:nAt, 2], ;
					}}
				
				@ 130, 190 BMPBUTTON TYPE 01 ACTION (lOk:=.T., nPosAt:=oLB:nAt, Close(oDlg))
				@ 130, 220 BMPBUTTON TYPE 02 ACTION (lOk:=.F., Close(oDlg))
			ACTIVATE MSDIALOG oDlg CENTERED
			
			If lOk
				cRet := aTabPrc[nPosAt][01]
			EndIf
		Else
			MsgAlert("Nenhuma Tabela de Compras foi Encontrada para o Fornecedor Informado.", "Tabela Não Encontrada")
		EndIf
	Else
		MsgAlert("Selecione um Fornecedor!", 'Obrigatório')
	EndIf
	
Return cRet