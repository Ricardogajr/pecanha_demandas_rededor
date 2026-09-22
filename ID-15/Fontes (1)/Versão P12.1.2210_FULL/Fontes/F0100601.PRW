#Include 'Protheus.ch'
#INCLUDE "APWIZARD.CH"

/*
{Protheus.doc} F0100601()
Inclusão de comentários 
@Author     Bruno de Oliveira
@Since      31/03/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_006
@Return 	lRet
*/
User Function F0100601()

Local aArea		:= GetArea()
Local aAreaSRA	:= SRA->(GetArea())
Local cFilApr		:= SQD->QD_FILPROC
Local cMatApr		:= SQD->QD_MATPROC
Local cNome		:= ""

DbSelectArea("SRA")
SRA->(DbSetOrder(1))
If SRA->(DbSeek(cFilApr + cMatApr))
	cNome := SRA->RA_NOME
EndIf

If SQD->QD_TPPROCE == "02" .AND. SQD->QD_SITPROC == "1"
	SQG->QG_XOBS := MSMM(SQD->QD_CODOBSC)
	SQG->QG_XAPROV := cNome
EndIf

RestArea(aAreaSRA)
RestArea(aArea)

Return