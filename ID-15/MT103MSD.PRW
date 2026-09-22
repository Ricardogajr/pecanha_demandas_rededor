#include "totvs.ch"

User Function MT103MSD()

	Local aArea := GetArea()
	Local aAreaE2 := SE2->(GetArea())
	local lFilSimp := U_VALSIMP(cFilAnt)
	/*Local cChavE2 := SF1->F1_FILIAL + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC
    Private lMsErroAuto := .F.*/


	U_FLJMUNIC()//Função para mudar a loja do fornecedor de titulo de ISS para 0 caso exista.
	if lFilSimp
		U_EXCTITNFE(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_SERIE)
	endif
/*	if lFilSimp
		DbSelectArea("SE2")
		SE2->(DbSetOrder(6))
		if SE2->(DbSeek(cChavE2)) 
			While !SE2->(Eof()) .And. SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM == cChavE2
				//aExcTit := {}
				//AAdd(aExcTit,{"E2_NUM" 		,SE2->E2_NUM		,NIL})
				//AAdd(aExcTit,{"E2_PREFIXO"	,SE2->E2_PREFIXO	,NIL})
				//AAdd(aExcTit,{"E2_PARCELA"	,SE2->E2_PARCELA	,NIL})
				//AAdd(aExcTit,{"E2_TIPO"		,"NFE"				,NIL})
				//AAdd(aExcTit,{"E2_FORNECE"	,SE2->E2_FORNECE	,NIL})
				//AAdd(aExcTit,{"E2_LOJA"		,SE2->E2_LOJA		,NIL})

				//MsExecAuto({|x,y,z| FINA050(x,y,z)},aExcTit,,5)
/*				
				/*If lMsErroAuto
					MostraErro()
				EndIf
				SE2->(DbSkip())
			EndDo
		EndIf
	Endif*/

	RestArea(aAreaE2)
	RestArea(aArea)
Return .T.
