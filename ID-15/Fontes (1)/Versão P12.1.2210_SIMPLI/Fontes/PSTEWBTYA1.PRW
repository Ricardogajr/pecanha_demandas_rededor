#Include 'Protheus.ch'
#INCLUDE "TopConn.ch"

/* 
{Protheus.doc} TEWBTYA1
Automatização do campo E2_FORMPAG (Esta função está sendo usada via gatilhos nos campos: E2_PORTADO, E2_FORBCO, E2_CODBAR, E2_LINDIG)
@Author     Ramon Teodoro e Silva
@Since      05/05/2016     
@Version    P12.7
@Return
*/
User Function TEWBTYA1(cCampo)

	Local cRet    := ""
	Local aArea   := GetArea()
	Local aAreaA2 := SA2->(GetArea())
	Local cPortad := M->E2_PORTADO
	Local cCnpjPg := Posicione("SA2", 1, xFilial("SA2")+M->E2_FORNECE+M->E2_LOJA, "A2_XCNPJPG")
	Local cBcoFor := IIF( !Empty(cCnpjPg), Posicione("SA2", 3, xFilial("SA2")+cCnpjPg, "A2_BANCO"), M->E2_FORBCO )
	Local cCodBar := IIF(!Empty(M->E2_CODBAR),M->E2_CODBAR,M->E2_LINDIG)
	Local cAliasTmp := GetNextAlias()

	Default cCampo := " "

	If !Empty(cPortad) .And. !IsInCallStack("FINA550") .And. !IsInCallStack("U_F0703301") .And. Alltrim(cCampo) == "E2_PORTADO"
		M->E2_XAGEPOR := SA6->A6_AGENCIA
		M->E2_XDVAPOR := SA6->A6_DVAGE
		M->E2_XCONPOR := SA6->A6_NUMCON
		M->E2_XDVCPOR := SA6->A6_DVCTA
	EndIf

	If Empty(cCodBar)
		If cPortad == cBcoFor .Or. (cPortad $ "409|341" .And. cBcoFor $ "341|409")
			cRet := "01" //Transf. Conta Corrente
		Else
			cRet := "41" //TED
		EndIf
	Else
		If SubStr(cCodBar, 1, 1) == "8"
			cRet := ""    //Impostos e concessionária 
		ElseIf cPortad == SubStr(cCodBar, 1, 3)
			cRet := "30" //Título mesmo banco
		Else
			cRet := "31" //Título outros bancos
		EndIf
	EndIf

	M->E2_FORMPAG := cRet
	If !Empty(cRet)
		If ExistTrigger('E2_FORMPAG')
			RunTrigger(1,nil,nil,,'E2_FORMPAG')
		Endif

		cRet := M->E2_FORMPAG
	EndIF
	RestArea(aArea)
	RestArea(aAreaA2)

Return cRet
