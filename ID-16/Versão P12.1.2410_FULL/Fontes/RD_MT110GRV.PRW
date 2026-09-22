#include "Protheus.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |MT110GRV  |Autor  |TECNOSUM            | Data |  10/06/2016      |
|----------------------------------------------------------------------------|
|Descrição |Ponto de entrada para bloquear a SC                              |						  
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/
User Function MT110GRV()
	Local aArea := GetARea()
	Local cFilSC 	:= Space(TamSx3("C1_FILIAL")[1])
	Local cNumSc 	:= Space(TamSx3("C1_NUM")[1])
	Local lMVXAPROSC    := GetMv("MV_XAPROSC") //Parametro que indica se a empresa utiliza APROVAÇÃO DE SC
	Local cMVXTPSCAP    := ALLTRIM(GetMv("MV_XTPSCAP")) //Parametro que indica se O TIPO exige aprovação de SC
	Local nPosTipo 	:= ASCAN(aHeader,{|x| AllTrim(x[2]) == "C1_XTPSC"})
	Local nVlrEsti	:= 0
	Local cMotivo 	:= SC1->C1_XMOTIVO
	Local c_GrApro  := ""
	Local aItens	:= {}
	Local nRec		:= 0 

	DbSelectArea("SC1")
	DbSetOrder(1)
	DbSeek(SC1->C1_FILIAL+SC1->C1_NUM)
	cObsInfPac := SC1->C1_XINFPAC
	nRec := SC1->(Recno())
	cFilSC := SC1->C1_FILIAL
	cNumSC := SC1->C1_NUM
	cArmaz	:= SC1->C1_LOCAL
	While !SC1->(Eof()) .and. cFilSC + cNumSC = SC1->C1_FILIAL+SC1->C1_NUM
		nVlrEsti += SC1->C1_XTOTAL
		aAdd(aItens,{SC1->C1_ITEM," "})
		RecLock("SC1",.F.)
		If lMVXAPROSC .and. !(SC1->C1_XTPSC $ cMVXTPSCAP) //Caso tenha aprovação de SC e o tipo exige aprovacao
			SC1->C1_APROV := "B" //somente bloqueia a SC se o processo de WF estiver ativado
		Else
			SC1->C1_APROV := "L"
		Endif
		SC1->C1_GRUPCOM := Posicione("SBZ", 1, xFilial("SC1")+SC1->C1_PRODUTO, "BZ_XGRPCOM")
		SC1->C1_XINFPAC := If(Empty(pIncObsSC), cObsInfPac, pIncObsSC)
		SC1->(MsUnLock())
		SC1->(DbSkip())
	Enddo
	SC1->(DBGOTO(nRec))
	RestArea(aArea)
Return

