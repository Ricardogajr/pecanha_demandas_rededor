#include "rwmake.ch"
#INCLUDE 'TOTVS.CH'

User Function FA260GRSE2()
	Local cCodPgt := "DDA"
	Local cFrmPgt := SE2->E2_FORMPAG
	Local lFilSimp := U_VALSIMP(cFilAnt)

	if !lFilSimp
		If (SE2->E2_XMNKSTA == "1" .And. !Empty(SE2->E2_XPORTAD))
			If  SUBSTR(SE2->E2_CODBAR,1,3) == SE2->E2_XPORTAD .and. Len(alltrim(SE2->E2_CODBAR)) < 48
				cCodPgt := "30"
			ElseIf SUBSTR(SE2->E2_CODBAR,1,3) <> SE2->E2_XPORTAD  .and. Len(alltrim(SE2->E2_CODBAR)) < 48
				cCodPgt := "31"
			EndIf
		Else
			If  SUBSTR(SE2->E2_CODBAR,1,3) == SE2->E2_PORTADO .and. Len(alltrim(SE2->E2_CODBAR)) < 48
				cCodPgt := "30"
			ElseIf SUBSTR(SE2->E2_CODBAR,1,3) <> SE2->E2_PORTADO  .and. Len(alltrim(SE2->E2_CODBAR)) < 48
				cCodPgt := "31"
			EndIf
		EndIf
	else
		Do Case
		Case  SUBSTR(SE2->E2_CODBAR,1,3) == SE2->E2_PORTADO .and. Len(alltrim(SE2->E2_CODBAR)) < 48
			cCodPgt := "30"
		Case SUBSTR(SE2->E2_CODBAR,1,3) <> SE2->E2_PORTADO  .and. Len(alltrim(SE2->E2_CODBAR)) < 48
			cCodPgt := "31"
		EndCase
	endif

	If cCOdPgt <> "DDA"
		SE2->E2_FORMPAG := cCOdPgt
	EndIf

	//If IsInCallStack("U_RDORDDA1")//cCodPgt == "DDA"
	IF Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE,"A2_XDDA") == "2"
		SE2->E2_CODBAR := ""
		SE2->E2_XDDA := "1"
		SE2->E2_LINDIG := ""
		SE2->E2_FORMPAG := cFrmPgt
	Else
		SE2->E2_XDDA := "2"
	EndIf
	//EndIf


Return Nil


//wHEN DO CAMPO E2_CODBAR E E2_LINDIG PARA NÃO HABILITAR A EDIÇÃO CASO O FORNECEDOR SEJA DDA = NÃO
//SOMENTE UM GRUPO DE USUÁRIOS PODERÃO EDITAR O CAMPO NESTE CASO
//Lucas Miranda de Aguiar 02/10/2024
User Function XBARDDA1(lAlt)

	Local lRet := .T.
	Local nX := 01
	Local cGrupos := GetNewPar("FS_DDAUSR","005026")
	Local aGrupos := StrTokArr(cGrupos,",")
	Local nY := 01
	Local aGrpUsr := UsrRetGrp(__cUserID)

	Default lAlt := .F. //Variavel criada para saber se a rotina está sendo chamada pelo PE_FA050ALT

	If ALTERA
		If __cUserID $ cGrupos
			Return lRet
		EndIf

		If Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE,"A2_XDDA") == "2"
			lRet := .F.
		EndIf

		If lAlt
			If !lRet
				If AllTrim(M->E2_CODBAR) <> AllTrim(SE2->E2_CODBAR) .Or. AllTrim(M->E2_LINDIG) <> AllTrim(SE2->E2_LINDIG)
					Help('',1,'A2_XDDA',,'Não é permitido alterar os campos E2_LINDIG e E2_CODBAR quando o fornecedor possui a flag DDA marcada. (A2_XDDA = 2)',1,0)
					M->E2_CODBAR := SE2->E2_CODBAR
					M->E2_LINDIG := SE2->E2_LINDIG
				Else
					lRet := .T.		
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
