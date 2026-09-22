#Include 'Protheus.ch' 

/*
{Protheus.doc}  FA080OWN()
PE para Validação de dados da baixa antes de efetuar a exlcusão\cancelamento
@Author  Ramon Teodoro e Silva	
@Since   30/03/2016       
@Version P12.7
*/
User Function FA080OWN()

Local lRet   := .T.
Local aArea := GetArea()
Local lAbertos := .F.

If !Empty(SE2->E2_XCAIXIN) //.And. Alltrim(SE2->E2_ORIGEM) == "FINA550"

	DbSelectArea("SET")
	DbSetOrder(1)
	DbGoTop()
	
	//lAbertos := Fa550ComAbe(SE2->E2_XCAIXIN)
	
	//If !lAbertos
		If DbSeek(xFilial("SET")+SE2->E2_XCAIXIN)
			
			If SET->ET_SALDO < nValPgto
				lRet := .F.
				MsgAlert("Operação cancelada. O saldo do caixinha " + Alltrim(SE2->E2_XCAIXIN) + " é inferior ao saldo do título", "Título vinculado a um caixinha") //"Valor maior que o permitido."	
			EndIf
			
		EndIf
/*	Else
		MsgStop("Existem movimentos em aberto para o caixinha relacionado a este título", "Operação não permitida")
		lRet := .F.
	EndIf*/
	
EndIf

RestArea(aArea)
Return lRet

