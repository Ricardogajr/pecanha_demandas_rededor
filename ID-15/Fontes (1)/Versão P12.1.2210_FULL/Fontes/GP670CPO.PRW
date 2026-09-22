
#include 'totvs.ch'


/* 
{Protheus.doc} GP670CPO
Automatização do campo E2_FORMPAG (Esta função está sendo usada nos campos: E2_PORTADO, E2_FORBCO, E2_CODBAR, E2_LINDIG)
@Author     Thiago Pereira de Oliveira 
@Since      30/10/2020     
@Version    P12.27
@Return
*/

User Function GP670CPO()
Local cPortad 
Local cCnpjPg 
Local cBcoFor 
Local cCodBar 
Local aArea   := GetArea()
Local aAreaA2 := SA2->(GetArea())
Local cCampo := ""

DBSELECTAREA("SE2")

cPortad := SE2->E2_PORTADO 
if !Empty(cPortad)
  cCampo := "E2_PORTADO"
endif

cCnpjPg := Posicione("SA2", 1, xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA, "A2_XCNPJPG")
cBcoFor := IIF( !Empty(cCnpjPg), Posicione("SA2", 3, xFilial("SA2")+cCnpjPg, "A2_BANCO"), SE2->E2_FORBCO )
cCodBar := IIF(!Empty(SE2->E2_CODBAR),SE2->E2_CODBAR,SE2->E2_LINDIG)

//A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA

dbSelectArea("SA2")
SA2->(dbSetOrder(3))
SA2->(Dbseek(xFilial("SA2")+cCnpjPg))


RECLOCK("SE2",.F.)

//If !Empty(cPortad) .And. !IsInCallStack("FINA550") .And. !IsInCallStack("U_F0703301") .And. Alltrim(cCampo) == "E2_PORTADO"
//	SE2->E2_XAGEPOR := SA2->A2_AGENCIA
//	SE2->E2_XDVAPOR := SA2->A2_DVAGE
//	SE2->E2_XCONPOR := SA2->A2_NUMCON
//	SE2->E2_XDVCPOR := SA2->A2_DVCTA
//EndIf

If Empty(cCodBar)
	If cPortad == cBcoFor .Or. (cPortad $ "409|341" .And. cBcoFor $ "341|409")
		cRet := "01" //Transf. Conta Corrente
	Else
		cRet := "41" //TED
	EndIf
Else
	If cPortad == SubStr(cCodBar, 1, 3) 
		cRet := "30" //Título mesmo banco
	Else
		cRet := "31" //Título outros bancos
	EndIf
EndIf

SE2->E2_FORMPAG  := cRet

SE2->(MsUnlock() ) 


RestArea(aArea)
RestArea(aAreaA2)


Return nil
