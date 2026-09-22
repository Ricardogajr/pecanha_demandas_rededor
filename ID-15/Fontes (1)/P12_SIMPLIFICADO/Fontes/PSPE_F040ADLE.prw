#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} F040ADLE
description ponto de entrada para adicionar legenda no titulo
@author  Ricardo Junior
@since   02/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F040ADLE
	Local aRet := {}
	if FunName() $ "FINA050|FINA750|FINA080|FINA090|FINA091|FINC050"
		aAdd(aRet, {"BR_MARRON_OCEAN", "Aguardando Aprovação SP"})
	endif
Return aRet
