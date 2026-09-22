#Include 'Protheus.ch'

/*
{Protheus.doc} RS150GV()
Ponto de Entrada para gravacao de campos no SQG para cada candidato agendado
@Author     Bruno de Oliveira
@Since      31/03/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_006
*/
User Function RS150GV()

If FindFunction("U_F0100601")
	U_F0100601()
EndIf

If FindFunction("U_F0100324")
	U_F0100324(SQD->QD_VAGA,.T.)
EndIf

Return

