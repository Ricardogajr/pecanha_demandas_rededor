
//#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FINALeg
Utilizado para alterar as legendas de diversas rotinas do financeiro, como FINA040, FNA050, FINA740, FINA750 entre outras.
@type function
@version P12 
@author Ricardo
@since 14/03/2025
@return array, legenda
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "finxfin.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FINALEG
description ponto de entrada para adicionar legenda no titulo
@author  Ricardo Junior
@since   02/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FINALEG()	
	Local nReg := PARAMIXB[1] // Com valor: Abrir a telinha de legendas ### Sem valor: Retornar as regras
	Local cAlias := PARAMIXB[2] // SE1 ou SE2
	Local aRegras := {} //PARAMIXB[3] // Regras do padrão
	Local aLegendas := PARAMIXB[4] // Legendas do padrão
	
	If nReg = Nil
		If cAlias = "SE2"
			If FunName() $ "FINA050|FINA750|FINA080|FINA090|FINA091|FINC050"	
				aAdd(aRegras,{' E2_XAPRVSP == "2"',"BR_MARRON_OCEAN"})//NOVO MENU
				aEval(PARAMIXB[3],{|J| aAdd(aRegras,{J[1],J[2]}) })				
			Endif
		Endif
	Else // Abrir telinha de Legendas (BrwLegenda)
		BrwLegenda(cCadastro, "Legenda", aLegendas)
	Endif	
Return aRegras
