#INCLUDE "AE_Colab_AP7.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_COLAB  ºAutor  ³Willy               º Data ³  24/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Manutenção do Cadastro de Colaboradores.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Template CDV - Controle de Despesas de Vaigens 			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_Colab()
Local cVldAlt := "U_ValAltCol()" // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "U_VldExcCol()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

ChkTemplate("CDV")

AxCadastro('LHT', STR0001,cVldExc,cVldAlt) //'Cadastro de Colaboradores'

Return

//***********************************************************************************************************/
//Validacao da Exclusao do Hotel - Se estiver relacionada com alguma solicitacao nao sera apagada
//***********************************************************************************************************/
User Function ValAltCol()
Local lRet := .T., _aArea := GetArea()
Local cBanco := LEFT(M->LHT_BCDEPS, 3), cAgencia := RIGHT(M->LHT_BCDEPS, 5), cNumCon := LHT_CTDEPS

DbSelectArea("SA2")
DbSetOrder(8) //A2_FILIAL+A2_MAT
If (DbSeek(xFilial() + LHT->LHT_CODMAT))
	RecLock("SA2", .F.)
		SA2->A2_BANCO 	:= cBanco
		SA2->A2_AGENCIA	:= cAgencia
		SA2->A2_NUMCON 	:= cNumCon
	MsUnlock()
EndIf

RestArea(_aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldExcCol ºAutor  ³Pablo Gollan Carrerasº Data ³  25/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao de exclusao para o AxCadastro                      º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV-AE_COLAB                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VldExcCol()

Local lRet		:= .T.
Local aArea		:= GetArea()
Local cMsgAl	:= ""
Local aMsg		:= {}
Local ni		:= 0
Local cArq		:= Nil       
Local nIdx		:= 0

//Verificacao  de solicitador
dbSelectArea("LHP")
LHP->(dbSetOrder(3))
If LHP->(dbSeek(xFilial("LHP") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0002)) //"Está associado a solicitações de viagem como solicitante."
	lRet := .F.	
Endif

//LHP - Verificacao de aprovador I
LHP->(dbSetOrder(5))
If LHP->(dbSeek(xFilial("LHP") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0003)) //"Está associado a solicitações de viagem como aprovador I."
	lRet := .F.			
Endif

//LHP - Verificacao de aprovador II
cArq := CriaTrab(Nil,.F.)
IndRegua("LHP",cArq,"LHP_FILIAL+LHP_DGRAR",,"")
dbSelectArea("LHP")
nIdx := RetIndex("LHP")
//#IFNDEF TOP
//	dbSetIndex(cArq + OrdBagExt())
//#ENDIF
LHP->(dbSetOrder(nIdx+1))
If LHP->(dbSeek(xFilial("LHP") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0004)) //"Está associado a solicitações de viagem como aprovador II."
	lRet := .F.			
Endif
RetIndex("LHP")
fErase(cArq + OrdBagExt())

//LHP - Verificao despesa viagem - solicitante
cArq := CriaTrab(Nil,.F.)
IndRegua("LHQ",cArq,"LHQ_FILIAL+LHQ_FUNC",,"")
dbSelectArea("LHQ")
nIdx := RetIndex("LHQ")
//#IFNDEF TOP
//	dbSetIndex(cArq + OrdBagExt())
//#ENDIF
LHQ->(dbSetOrder(nIdx+1))
If LHQ->(dbSeek(xFilial("LHQ") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0005)) //"Está associado a despesas de viagem como solicitante."
	lRet := .F.			
Endif
RetIndex("LHQ")
fErase(cArq + OrdBagExt())

//LHQ - Verificao despesa viagem - aprovador I
cArq := CriaTrab(Nil,.F.)
IndRegua("LHQ",cArq,"LHQ_FILIAL+LHQ_SUPIMD",,"")
dbSelectArea("LHQ")
nIdx := RetIndex("LHQ")
//#IFNDEF TOP
//	dbSetIndex(cArq + OrdBagExt())
//#ENDIF
LHQ->(dbSetOrder(nIdx+1))
If LHQ->(dbSeek(xFilial("LHQ") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0006)) //"Está associado a despesas de viagem como aprovador I."
	lRet := .F.			
Endif
RetIndex("LHQ")
fErase(cArq + OrdBagExt())

//LHQ - Verificao despesa viagem - aprovador II
cArq := CriaTrab(Nil,.F.)
IndRegua("LHQ",cArq,"LHQ_FILIAL+LHQ_DGRAR",,"")
dbSelectArea("LHQ")
nIdx := RetIndex("LHQ")
//#IFNDEF TOP
//	dbSetIndex(cArq + OrdBagExt())
//#ENDIF
LHQ->(dbSetOrder(nIdx+1))
If LHQ->(dbSeek(xFilial("LHQ") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0007)) //"Está associado a despesas de viagem como aprovador II."
	lRet := .F.			
Endif
RetIndex("LHQ")
fErase(cArq + OrdBagExt())

//LJI - Autorizacao uso de despesa por funcionario
dbSelectArea("LJI")
LJI->(dbSetOrder(1))
If LJI->(dbSeek(xFilial("LJI") + LHT->LHT_CODMAT))
	aAdd(aMsg,OemToAnsi(STR0008)) //"Está associado a lista de autorizacao de uso de despesa por funcionário."
	lRet := .F.			
Endif

If !lRet
	For ni := 1 to Len(aMsg) Step 1
		cMsgAl += AllTrim(Str(ni) + ". " + aMsg[ni]) + IIf(ni < Len(aMsg),Replicate(CRLF,2),"")
	Next ni
	MsgAlert(OemToAnsi(STR0009 + AllTrim(LHT->LHT_NOME) + " (" + AllTrim(LHT->LHT_CODMAT) + ") " + STR0010) + CRLF + CRLF + cMsgAl) //"O colaborador " //"não pode ser excluído pois:"
Endif
RestArea(aArea)

Return lRet
