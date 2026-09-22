#INCLUDE "Protheus.ch"

/*
{Protheus.doc} FA750BRW()
PE para adicionar o botão recusa nas rotinas FINA750 
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@Return		aRotina, Vetor de Botões    
*/

User Function FA750BRW()

	Local aRotina    := {}
	Local aCliButt   := {}
	Local lExecPECli := SuperGetMV("FS_EXPECLI",,.T.)

	aRotina := U_F0400104(aRotina) //BANCO DE CONHECIMENTO

	aRotina := U_F0101005(aRotina) //RECUSA

	If lExecPECli .And. FindFunction("U_FSPE0001")
		aCliButt := U_FSPE0001()
		If !(ValType(aCliButt) == "A" .and. ValType(aCliButt[1]) == "A")
			ConOut(FwTimeStamp() + " Formato de retorno inválido na chamada 'U_FSPE0001'. " )
		Else
			AEval(aCliButt, {|aOpc| AAdd(aRotina, aOpc)})
		Endif
	EndIf

Return aRotina
