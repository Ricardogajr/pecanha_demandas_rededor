#INCLUDE "protheus.ch"
#include "totvs.ch"


/*/{Protheus.doc} F0703205
Inclusão de campos no cabeçalho da NFs

@since 13/11/2017
@version 1
@type function
@project MAN0000007423041
/*/
User Function F0703205()

	Local aArea     := GetArea()
	Local cNOMEP 	:=""
	Local cDATAP	:=""
	Local cCPFP 	:=""
	Local cNUMATEND :=""

	cNOMEP		 := SC5->C5_XNOMEPA
	CTOD(cDATAP) := SC5->C5_XDATANA
	cCPFP		 := SC5->C5_XCPFPAC
	cNUMATEND	 := SC5->C5_XNUMATE

	Reclock("SF2",.F.)

	SF2->F2_XNOMEPA	:= 	SC5->C5_XNOMEPA
	SF2->F2_XDATANA :=	SC5->C5_XDATANA
	SF2->F2_XCPFPAC	:=	SC5->C5_XCPFPAC
	SF2->F2_XNUMATE	:=	SC5->C5_XNUMATE

	SF2->(MsUnlock())

	RestArea(aArea)

Return