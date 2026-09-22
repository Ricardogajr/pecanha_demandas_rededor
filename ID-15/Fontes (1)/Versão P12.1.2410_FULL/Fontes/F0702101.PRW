#include "totvs.ch"

/*/{Protheus.doc} F0702101
Função responsável pelas integração de movimentação bancária
@type function
@author anieli.rodrigues
@since 01/02/2017
@version 12.7
@param oRegSage
@project MAN0000007423041_EF_021
@return cRET
/*/

User Function F0702101(oRegSage)

	Local aLinha  := {}
	Local aLog    := {}
	Local cFilMov := ""
	Local cRet    := "OK"
	Local lRet    := .T.
	Local nOpc    := 0
	Local nY      := 0
	Local cIdInt  := U_GetIntegID()
	Local nRegLog := 0

	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

	nRegLog := U_F07LOG01(cIdInt,{oRegSage})

	cFilMov := Alltrim(oRegSage:cFilReg)

	If Empty(cFilMov) .Or. !ExistCpo("SM0",cEmpAnt + cFilMov)
		lRet := .F.
		cRet := "ERRO|PARAMETRO OBRIGATORIO INVALIDO: CFILREG"
	Else 
		cFilAnt := cFilMov
	EndIf
	
	If lRet .And. !(oRegSage:cRecPag == "R" .Or. oRegSage:cRecPag == "P") 
		lRet := .F. 
		cRet := "ERRO|PARAMETRO OBRIGATORIO INVALIDO: CRECPAG"
	EndIf 
	
	If lRet 
		nOpc := Iif (oRegSage:cRecPag == "P",3,4)   
		
		AAdd(aLinha,{"E5_DATA"   , CtoD(oRegSage:cDATA), Nil})
		AAdd(aLinha,{"E5_MOEDA"  , oRegSage:cMoeda     , Nil})
		AAdd(aLinha,{"E5_VALOR"  , Val(oRegSage:cValor), Nil})
		AAdd(aLinha,{"E5_NATUREZ", oRegSage:cNaturez   , Nil})
		AAdd(aLinha,{"E5_BANCO"  , oRegSage:cBanco     , Nil})
		AAdd(aLinha,{"E5_AGENCIA", oRegSage:cAgencia   , Nil})
		AAdd(aLinha,{"E5_CONTA"  , oRegSage:cConta     , Nil})
		AAdd(aLinha,{"E5_HISTOR" , oRegSage:cHistor    , Nil})
		AAdd(aLinha,{"E5_TIPOLAN", oRegSage:cTipoLan   , Nil})
		AAdd(aLinha,{"E5_DEBITO" , oRegSage:cDebito    , Nil})
		AAdd(aLinha,{"E5_CREDITO", oRegSage:cCredito   , Nil})
		AAdd(aLinha,{"E5_CCUSTO" , oRegSage:cCCusto    , Nil})
		AAdd(aLinha,{"E5_TIPO"   , oRegSage:cTipo      , Nil})
	    AAdd(aLinha,{"E5_XID"    , cIdInt              , Nil}) //-- função pra pegar o ID    
		
		U_F07PADR(aLinha)

		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aLinha,nOpc)
		If lMsErroAuto
			cRet := "ERRO|EXECUCAO DA ROTINA AUTOMATICA" + CRLF
			aLog := GetAutoGRLog()
			For nY := 1 To Len(aLog)
				cRet += aLog[nY] + CRLF
			Next nY
		Else
			U_F07LOG02(nRegLog,cRet,.T.,'SE5',1,xFilial("SE5") + '|' + oRegSage:cDATA)
		EndIf

	EndIf

	If cRet != "OK"
		U_F07LOG02(nRegLog,cRet,.F.,'SE5',1,xFilial("SE5") + '|' + oRegSage:cDATA)
	EndIf
	 	
Return cRet
