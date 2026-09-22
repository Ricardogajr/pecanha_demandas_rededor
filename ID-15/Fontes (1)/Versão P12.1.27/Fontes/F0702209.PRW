#Include 'PROTHEUS.CH'

/*{Protheus.doc} F0702209()
Função chamada pelo ponto de entrada MT120TEL.
Inclui o campo endereço de entrega no cabeçalho do Pedido de Compra.
@Author     Paulo Krüger
@Since		09/10/2017
@Version	P12.7
@project	MAN0000007423041_EF_022 
@Return		Nil*/

User Function F0702209(oDialog, aPosGet, nOpcx)

Default oDialog := Nil
Default aPosGet := {}
Default nOpcx   := 0

Public cEndFil	:= Space(60)

fEnderFil()
	
@ 062,aPosGet[2,5]-12 SAY 'End. Entrega' OF oDialog PIXEL SIZE 060,006
@ 062,aPosGet[2,6]-25 MSGET cEndFil PICTURE '@!' OF oDialog PIXEL SIZE 120,006 WHEN fEnderFil()

Return

Static Function fEnderFil()
	If Empty(cFilialEnt)
		cFilialEnt := cFilAnt
	EndIf
	cEndFil := Posicione("SM0",1,cEmpAnt+cFilialEnt,"M0_ENDCOB")
Return .F.