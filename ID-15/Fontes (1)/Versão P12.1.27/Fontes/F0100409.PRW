#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   

/*{Protheus.doc} F0100409()
Alteração de Grupo de Aprovação
@Author     Nairan Alves Silva
@Since      14/09/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Menu		*/
User Function F0100409()

Local aArea	:= GetArea()
Local aAreaP02	:= P02->(GetArea())
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSY1	:= SY1->(GetArea())
Local xRet		:= Nil
Local cTipo		:= ""

If IsInCallStack('U_F0100401') //Caso venha da Solicitação de Pagamento

	DbSelectArea("SC7")
	//cTipo := SC7->C7_XTIPO 9908052 - Thais Paiva
	cTipo := M->C7_XTIPO
	
	DbSelectArea("P02")
	SAL->(DbSetOrder(1))
	
	If P02->(DbSeek(xFilial('P02') + cTipo))
		dbSelectArea("SY1")
		//dbSetOrder(3) 9908052 - Thais Paiva
		dbSetOrder(1)
		//If SY1->(DbSeek(xFilial("SY1") + P02->P02_COMPRA)) 9908052 - Thais Paiva
		If SY1->(DbSeek(xFilial("SY1") + Alltrim(P02->P02_COMPRA)))
			xRet := SY1->Y1_GRAPROV
		EndIF
	Endif	
	
Else
	
	xRet :=	SuperGetMv("MV_PCAPROV")
	
	dbSelectArea('SY1')
	dbSetOrder(03)
	If dbSeek(xFilial('SY1') + RetCodUsr())
		xRet := If(!Empty(Y1_GRAPROV),SY1->Y1_GRAPROV,xRet)
	EndIf

EndIf

RestArea(aAreaP02)
RestArea(aAreaSC7)
RestArea(aAreaSY1)
RestArea(aArea)
Return xRet