#include "totvs.ch"

/*/{Protheus.doc} FA050UPD
Pré valida inclusão alteração e exclusão de contas a pagar
@type User function
@author anieli.rodrigues
@since 20/02/2017
@version 12.7
@project MAN0000007423041_EF_033
@return lRet
/*/ 

User Function FA050UPD()

	Local aArea := GetArea()
	Local aAreaE2 := SE2->(GetArea())
	Local lRet := .T.
	Local lFilSimp := U_VALSIMP(cFilAnt)

	if lFilSimp
		If _Opc = 5
			If !(UPPER(ALLTRIM(funname())) $ "ETX_BRWS|AGL_MRKB|ETX_CANC")
				If SE2->E2_PREFIXO = "AGI" .AND. SE2->E2_TIPO = "INS" .AND. SE2->E2_FORNECE = cMV_FORINSS
					MsgStop("Este Tï¿½tulo ï¿½ um Aglutinador de INSS, para a Exclusï¿½o, deve-se utilizar a Rotina de Aglutinaï¿½ï¿½o de INSS","Erro")
					lRet := .F.
				Endif
				If ALLTRIM(SE2->E2_XNUMAGL) <> ""
					MsgStop("Este Tï¿½tulo deu origem a um Aglutinador de INSS, para a Cancelar a Baixa, deve-se utilizar a Rotina de Aglutinaï¿½ï¿½o de INSS","Erro")
					lRet := .F.
				Endif
			Endif
		Endif
	else
		lRet := U_F0703305()
	endif

		If (lRet .And. !INCLUI .And. !ALTERA)
			U_FLJMUNIC()//Função para mudar a loja do fornecedor de titulo de ISS para 1 caso exista.
		EndIf

		RestArea(aAreaE2)
		RestArea(aArea)
		Return lRet
