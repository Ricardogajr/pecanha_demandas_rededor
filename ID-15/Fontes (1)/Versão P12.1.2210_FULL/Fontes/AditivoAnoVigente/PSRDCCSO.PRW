#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} PSRDCCSO
description Rotina responsável pela validacao de centro de custo de CAPEX e OPEX na solicitacao de Pagamento
@author  Ricardo Junior	
@since   01/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
user function PSRDCCSO()
	Local cCusto := M->C7_CC
	Local cEol  := chr(13)+chr(10)
	Local cFormulOPX := Getmv("FS_FORMOPX") //Formula com regra para validacao de centro de custo de CAPEX na solicitacao de Pagamento
	Local cFormulCPX := Getmv("FS_FORMCPX") //Formula com regra para validacao de centro de custo de OPEX  na solicitacao de Pagamento
	Local oModel   := FwModelActive()
	Local oModeiT := oModel:GetModel("MODEL_SC7")
	
	if U_VALSIMP(cFilAnt)
		lRegraOPX := FORMULA(cFormulOPX)
		lRegraCPX := FORMULA(cFormulCPX)
		cCusto := FWFldGet("C7_CC")

		If !Empty(cCusto) .And. (lRegraOPX .Or. lRegraCPX)
			If lRegraCPX
				Msginfo("A Conta contabil informada na natureza,"+cEol+" refere-se a uma conta de CAPEX,"+cEol+cEol+" por favor informe um centro de custo de CAPEX"+cEol+cEol+cEol+cEol+"AJUDA : INFORME UM CENTRO DE CUSTO INICIADO COM 04","AVISO - CAPEX")
				cCusto := ""
			ElseIf lRegraOPX
				Msginfo("A Conta contabil informada na natureza,"+cEol+" refere-se a uma conta de OPEX,"+cEol+cEol+" por favor informe um centro de custo de OPEX"+cEol+cEol+cEol+cEol+"AJUDA: INFORME UM CENTRO DE CUSTO INICIADO COM 01","AVISO - OPEX")
				cCusto := ""			
			EndIf
		EndIf		
		oModeiT:setValue("C7_CC", cCusto)			
	endif
Return cCusto
