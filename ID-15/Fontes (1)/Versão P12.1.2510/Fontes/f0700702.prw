#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static lExecVld := .T.

/*{Protheus.doc} F0700702
Validação do fabricante
@author Carlos A. Gomes Jr.
@since 25/09/2017
@Project MAN0000007423041_EF_007
*/
User Function F0700702()

	Local oModelP13
	Local oModP13
	Local cConteud := ""
	Local aConteud := {}
	Local lRetVld  := .F.
	
	If !lExecVld
		Return .T.
	EndIf

	lExecVld := .F.

	oModelP13 := FWModelActive()
	oModP13   := oModelP13:GetModel('MASTER')
	cConteud  := oModP13:GetValue("P13_DESCR")
	cConteud  := StrTran(cConteud,CHR(9)," ")
	aConteud  := StrTokArr(cConteud," ")

	cConteud := ""
	AEval(aConteud,{|cCont| cConteud += cCont + " " })
	M->P13_DESCR := PadR(cConteud,Len(P13->P13_DESCR)," ")
	oModP13:SetValue("P13_DESCR",M->P13_DESCR)

	lExecVld := .T.

	lRetVld := ExistChav("P13",M->P13_DESCR,3)

Return lRetVld
