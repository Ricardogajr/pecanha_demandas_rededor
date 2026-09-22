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

Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  6, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
Local oXmailFor

Default oDialog := Nil
Default aPosGet := {}
Default nOpcx   := 0


Public cEndFil	:= Space(60)
Public cXmailFor := ""


//Define o conteúdo para os campos
/*
// ------------------------------------
// C7_XMAILFO - CAMPO UTILIZADO PARA ADICIONAR O EMAIL DO FORNECEDOR CASO SEJA PRECISO
// ------------------------------------
*/
SC7->(DbGoTo(PARAMIXB[5]))
If nOpcx == 3
	cXmailFor := CriaVar("C7_XMAILFO",.F.)
Else
	cXmailFor := SC7->C7_XMAILFO
EndIf


fEnderFil()
	
@ 062,aPosGet[2,5]-12 SAY 'End. Entrega' OF oDialog PIXEL SIZE 060,006
@ 062,aPosGet[2,6]-25 MSGET cEndFil PICTURE '@!' OF oDialog PIXEL SIZE 120,006 WHEN fEnderFil()

//Criando na janela o campo EMAIL
@ 075, aPosGet[1,1]  SAY Alltrim(RetTitle("C7_XMAILFO")) OF oDialog PIXEL SIZE 060,006
@ 074, aPosGet[1,2]  MSGET oXmailFor VAR cXmailFor OF oDialog PIXEL SIZE 120,006 
oXmailFor:bHelp := {|| ShowHelpCpo( "C7_XMAILFO", {GetHlpSoluc("C7_XMAILFO")[1]}, 5  )}

//Se não houver edição, desabilita os gets
If !lEdit
	oXmailFor:lActive := .F.
EndIf

Return

Static Function fEnderFil()
	If Empty(cFilialEnt)
		cFilialEnt := cFilAnt
	EndIf
	cEndFil := Posicione("SM0",1,cEmpAnt+cFilialEnt,"M0_ENDCOB")
Return .F.
