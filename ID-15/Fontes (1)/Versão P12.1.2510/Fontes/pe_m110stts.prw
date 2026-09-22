#INCLUDE 'Protheus.ch'

/*
{Protheus.doc} M110STTS()
Ponto de Entrada para executar a Medição Automatizada após a Confirmação
Da Solicitação de Compras.
@Author		Mick William da Silva
@Since		18/07/2016
@Version	P12.7
@Project    MAN00000462901_EF_001
*/

User Function M110STTS()

	Local cNumSol    := Paramixb[1]
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)
	Local aDocument     := {}
	Local dDataRef      := CToD("  /  /    ")
	Local nOperation    := 0

	If lExecPECli .And. FindFunction("U_FSPE0003")
		U_FSPE0003()
	EndIf

Return
